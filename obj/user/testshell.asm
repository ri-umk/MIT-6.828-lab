
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 03 05 00 00       	call   800534 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  800040:	8b 7d 08             	mov    0x8(%ebp),%edi
  800043:	8b 75 0c             	mov    0xc(%ebp),%esi
  800046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800049:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004d:	89 3c 24             	mov    %edi,(%esp)
  800050:	e8 77 1a 00 00       	call   801acc <seek>
	seek(kfd, off);
  800055:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800059:	89 34 24             	mov    %esi,(%esp)
  80005c:	e8 6b 1a 00 00       	call   801acc <seek>

	cprintf("shell produced incorrect output.\n");
  800061:	c7 04 24 80 2c 80 00 	movl   $0x802c80,(%esp)
  800068:	e8 2f 06 00 00       	call   80069c <cprintf>
	cprintf("expected:\n===\n");
  80006d:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  800074:	e8 23 06 00 00       	call   80069c <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800079:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007c:	eb 0c                	jmp    80008a <wrong+0x56>
		sys_cputs(buf, n);
  80007e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800082:	89 1c 24             	mov    %ebx,(%esp)
  800085:	e8 e2 0e 00 00       	call   800f6c <sys_cputs>
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  80008a:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 c8 18 00 00       	call   801966 <read>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	7f dc                	jg     80007e <wrong+0x4a>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  8000a2:	c7 04 24 fa 2c 80 00 	movl   $0x802cfa,(%esp)
  8000a9:	e8 ee 05 00 00       	call   80069c <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ae:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b1:	eb 0c                	jmp    8000bf <wrong+0x8b>
		sys_cputs(buf, n);
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	89 1c 24             	mov    %ebx,(%esp)
  8000ba:	e8 ad 0e 00 00       	call   800f6c <sys_cputs>
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bf:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000c6:	00 
  8000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cb:	89 3c 24             	mov    %edi,(%esp)
  8000ce:	e8 93 18 00 00       	call   801966 <read>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7f dc                	jg     8000b3 <wrong+0x7f>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000d7:	c7 04 24 f5 2c 80 00 	movl   $0x802cf5,(%esp)
  8000de:	e8 b9 05 00 00       	call   80069c <cprintf>
	exit();
  8000e3:	e8 a0 04 00 00       	call   800588 <exit>
}
  8000e8:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 3c             	sub    $0x3c,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800103:	e8 fa 16 00 00       	call   801802 <close>
	close(1);
  800108:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010f:	e8 ee 16 00 00       	call   801802 <close>
	opencons();
  800114:	e8 c7 03 00 00       	call   8004e0 <opencons>
	opencons();
  800119:	e8 c2 03 00 00       	call   8004e0 <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 08 2d 80 00 	movl   $0x802d08,(%esp)
  80012d:	e8 db 1c 00 00       	call   801e0d <open>
  800132:	89 c3                	mov    %eax,%ebx
  800134:	85 c0                	test   %eax,%eax
  800136:	79 20                	jns    800158 <umain+0x65>
		panic("open testshell.sh: %e", rfd);
  800138:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013c:	c7 44 24 08 15 2d 80 	movl   $0x802d15,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 2b 2d 80 00 	movl   $0x802d2b,(%esp)
  800153:	e8 4c 04 00 00       	call   8005a4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  800158:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 ea 24 00 00       	call   80264d <pipe>
  800163:	85 c0                	test   %eax,%eax
  800165:	79 20                	jns    800187 <umain+0x94>
		panic("pipe: %e", wfd);
  800167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016b:	c7 44 24 08 3c 2d 80 	movl   $0x802d3c,0x8(%esp)
  800172:	00 
  800173:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80017a:	00 
  80017b:	c7 04 24 2b 2d 80 00 	movl   $0x802d2b,(%esp)
  800182:	e8 1d 04 00 00       	call   8005a4 <_panic>
	wfd = pfds[1];
  800187:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  80018a:	c7 04 24 a4 2c 80 00 	movl   $0x802ca4,(%esp)
  800191:	e8 06 05 00 00       	call   80069c <cprintf>
	if ((r = fork()) < 0)
  800196:	e8 30 12 00 00       	call   8013cb <fork>
  80019b:	85 c0                	test   %eax,%eax
  80019d:	79 20                	jns    8001bf <umain+0xcc>
		panic("fork: %e", r);
  80019f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a3:	c7 44 24 08 45 2d 80 	movl   $0x802d45,0x8(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8001b2:	00 
  8001b3:	c7 04 24 2b 2d 80 00 	movl   $0x802d2b,(%esp)
  8001ba:	e8 e5 03 00 00       	call   8005a4 <_panic>
	if (r == 0) {
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	0f 85 9f 00 00 00    	jne    800266 <umain+0x173>
		dup(rfd, 0);
  8001c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ce:	00 
  8001cf:	89 1c 24             	mov    %ebx,(%esp)
  8001d2:	e8 7c 16 00 00       	call   801853 <dup>
		dup(wfd, 1);
  8001d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001de:	00 
  8001df:	89 34 24             	mov    %esi,(%esp)
  8001e2:	e8 6c 16 00 00       	call   801853 <dup>
		close(rfd);
  8001e7:	89 1c 24             	mov    %ebx,(%esp)
  8001ea:	e8 13 16 00 00       	call   801802 <close>
		close(wfd);
  8001ef:	89 34 24             	mov    %esi,(%esp)
  8001f2:	e8 0b 16 00 00       	call   801802 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fe:	00 
  8001ff:	c7 44 24 08 4e 2d 80 	movl   $0x802d4e,0x8(%esp)
  800206:	00 
  800207:	c7 44 24 04 12 2d 80 	movl   $0x802d12,0x4(%esp)
  80020e:	00 
  80020f:	c7 04 24 51 2d 80 00 	movl   $0x802d51,(%esp)
  800216:	e8 ed 21 00 00       	call   802408 <spawnl>
  80021b:	89 c7                	mov    %eax,%edi
  80021d:	85 c0                	test   %eax,%eax
  80021f:	79 20                	jns    800241 <umain+0x14e>
			panic("spawn: %e", r);
  800221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800225:	c7 44 24 08 55 2d 80 	movl   $0x802d55,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 2b 2d 80 00 	movl   $0x802d2b,(%esp)
  80023c:	e8 63 03 00 00       	call   8005a4 <_panic>
		close(0);
  800241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800248:	e8 b5 15 00 00       	call   801802 <close>
		close(1);
  80024d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800254:	e8 a9 15 00 00       	call   801802 <close>
		wait(r);
  800259:	89 3c 24             	mov    %edi,(%esp)
  80025c:	e8 8f 25 00 00       	call   8027f0 <wait>
		exit();
  800261:	e8 22 03 00 00       	call   800588 <exit>
	}
	close(rfd);
  800266:	89 1c 24             	mov    %ebx,(%esp)
  800269:	e8 94 15 00 00       	call   801802 <close>
	close(wfd);
  80026e:	89 34 24             	mov    %esi,(%esp)
  800271:	e8 8c 15 00 00       	call   801802 <close>

	rfd = pfds[0];
  800276:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800279:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 5f 2d 80 00 	movl   $0x802d5f,(%esp)
  800288:	e8 80 1b 00 00       	call   801e0d <open>
  80028d:	89 c6                	mov    %eax,%esi
  80028f:	85 c0                	test   %eax,%eax
  800291:	79 20                	jns    8002b3 <umain+0x1c0>
		panic("open testshell.key for reading: %e", kfd);
  800293:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800297:	c7 44 24 08 c8 2c 80 	movl   $0x802cc8,0x8(%esp)
  80029e:	00 
  80029f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002a6:	00 
  8002a7:	c7 04 24 2b 2d 80 00 	movl   $0x802d2b,(%esp)
  8002ae:	e8 f1 02 00 00       	call   8005a4 <_panic>
	}
	close(rfd);
	close(wfd);

	rfd = pfds[0];
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8002b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  8002ba:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		panic("open testshell.key for reading: %e", kfd);

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  8002c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002c8:	00 
  8002c9:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	89 3c 24             	mov    %edi,(%esp)
  8002d3:	e8 8e 16 00 00       	call   801966 <read>
  8002d8:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002e1:	00 
  8002e2:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	e8 75 16 00 00       	call   801966 <read>
		if (n1 < 0)
  8002f1:	85 db                	test   %ebx,%ebx
  8002f3:	79 20                	jns    800315 <umain+0x222>
			panic("reading testshell.out: %e", n1);
  8002f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f9:	c7 44 24 08 6d 2d 80 	movl   $0x802d6d,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 2b 2d 80 00 	movl   $0x802d2b,(%esp)
  800310:	e8 8f 02 00 00       	call   8005a4 <_panic>
		if (n2 < 0)
  800315:	85 c0                	test   %eax,%eax
  800317:	79 20                	jns    800339 <umain+0x246>
			panic("reading testshell.key: %e", n2);
  800319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031d:	c7 44 24 08 87 2d 80 	movl   $0x802d87,0x8(%esp)
  800324:	00 
  800325:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  80032c:	00 
  80032d:	c7 04 24 2b 2d 80 00 	movl   $0x802d2b,(%esp)
  800334:	e8 6b 02 00 00       	call   8005a4 <_panic>
		if (n1 == 0 && n2 == 0)
  800339:	85 db                	test   %ebx,%ebx
  80033b:	75 06                	jne    800343 <umain+0x250>
  80033d:	85 c0                	test   %eax,%eax
  80033f:	75 14                	jne    800355 <umain+0x262>
  800341:	eb 39                	jmp    80037c <umain+0x289>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  800343:	83 fb 01             	cmp    $0x1,%ebx
  800346:	75 0d                	jne    800355 <umain+0x262>
  800348:	83 f8 01             	cmp    $0x1,%eax
  80034b:	75 08                	jne    800355 <umain+0x262>
  80034d:	8a 45 e6             	mov    -0x1a(%ebp),%al
  800350:	38 45 e7             	cmp    %al,-0x19(%ebp)
  800353:	74 13                	je     800368 <umain+0x275>
			wrong(rfd, kfd, nloff);
  800355:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800358:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800360:	89 3c 24             	mov    %edi,(%esp)
  800363:	e8 cc fc ff ff       	call   800034 <wrong>
		if (c1 == '\n')
  800368:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  80036c:	75 06                	jne    800374 <umain+0x281>
			nloff = off+1;
  80036e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800371:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800374:	ff 45 d4             	incl   -0x2c(%ebp)
	}
  800377:	e9 45 ff ff ff       	jmp    8002c1 <umain+0x1ce>
	cprintf("shell ran correctly\n");
  80037c:	c7 04 24 a1 2d 80 00 	movl   $0x802da1,(%esp)
  800383:	e8 14 03 00 00       	call   80069c <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800388:	cc                   	int3   

	breakpoint();
}
  800389:	83 c4 3c             	add    $0x3c,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    
  800391:	00 00                	add    %al,(%eax)
	...

00800394 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800397:	b8 00 00 00 00       	mov    $0x0,%eax
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8003a4:	c7 44 24 04 b6 2d 80 	movl   $0x802db6,0x4(%esp)
  8003ab:	00 
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	e8 90 08 00 00       	call   800c47 <strcpy>
	return 0;
}
  8003b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003d5:	eb 30                	jmp    800407 <devcons_write+0x49>
		m = n - tot;
  8003d7:	8b 75 10             	mov    0x10(%ebp),%esi
  8003da:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8003dc:	83 fe 7f             	cmp    $0x7f,%esi
  8003df:	76 05                	jbe    8003e6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8003e1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8003e6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003ea:	03 45 0c             	add    0xc(%ebp),%eax
  8003ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f1:	89 3c 24             	mov    %edi,(%esp)
  8003f4:	e8 c7 09 00 00       	call   800dc0 <memmove>
		sys_cputs(buf, m);
  8003f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fd:	89 3c 24             	mov    %edi,(%esp)
  800400:	e8 67 0b 00 00       	call   800f6c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800405:	01 f3                	add    %esi,%ebx
  800407:	89 d8                	mov    %ebx,%eax
  800409:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80040c:	72 c9                	jb     8003d7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80040e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800414:	5b                   	pop    %ebx
  800415:	5e                   	pop    %esi
  800416:	5f                   	pop    %edi
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80041f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800423:	75 07                	jne    80042c <devcons_read+0x13>
  800425:	eb 25                	jmp    80044c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800427:	e8 ee 0b 00 00       	call   80101a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80042c:	e8 59 0b 00 00       	call   800f8a <sys_cgetc>
  800431:	85 c0                	test   %eax,%eax
  800433:	74 f2                	je     800427 <devcons_read+0xe>
  800435:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800437:	85 c0                	test   %eax,%eax
  800439:	78 1d                	js     800458 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80043b:	83 f8 04             	cmp    $0x4,%eax
  80043e:	74 13                	je     800453 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	88 10                	mov    %dl,(%eax)
	return 1;
  800445:	b8 01 00 00 00       	mov    $0x1,%eax
  80044a:	eb 0c                	jmp    800458 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80044c:	b8 00 00 00 00       	mov    $0x0,%eax
  800451:	eb 05                	jmp    800458 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800458:	c9                   	leave  
  800459:	c3                   	ret    

0080045a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
  800463:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800466:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80046d:	00 
  80046e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 f3 0a 00 00       	call   800f6c <sys_cputs>
}
  800479:	c9                   	leave  
  80047a:	c3                   	ret    

0080047b <getchar>:

int
getchar(void)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800481:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800488:	00 
  800489:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800497:	e8 ca 14 00 00       	call   801966 <read>
	if (r < 0)
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 0f                	js     8004af <getchar+0x34>
		return r;
	if (r < 1)
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	7e 06                	jle    8004aa <getchar+0x2f>
		return -E_EOF;
	return c;
  8004a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8004a8:	eb 05                	jmp    8004af <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8004aa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8004af:	c9                   	leave  
  8004b0:	c3                   	ret    

008004b1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 04 24             	mov    %eax,(%esp)
  8004c4:	e8 01 12 00 00       	call   8016ca <fd_lookup>
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	78 11                	js     8004de <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8004cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004d0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8004d6:	39 10                	cmp    %edx,(%eax)
  8004d8:	0f 94 c0             	sete   %al
  8004db:	0f b6 c0             	movzbl %al,%eax
}
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    

008004e0 <opencons>:

int
opencons(void)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8004e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 86 11 00 00       	call   801677 <fd_alloc>
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	78 3c                	js     800531 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8004f5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8004fc:	00 
  8004fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800500:	89 44 24 04          	mov    %eax,0x4(%esp)
  800504:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80050b:	e8 29 0b 00 00       	call   801039 <sys_page_alloc>
  800510:	85 c0                	test   %eax,%eax
  800512:	78 1d                	js     800531 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800514:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80051a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80051d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80051f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800522:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	e8 1b 11 00 00       	call   80164c <fd2num>
}
  800531:	c9                   	leave  
  800532:	c3                   	ret    
	...

00800534 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	56                   	push   %esi
  800538:	53                   	push   %ebx
  800539:	83 ec 10             	sub    $0x10,%esp
  80053c:	8b 75 08             	mov    0x8(%ebp),%esi
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800542:	e8 b4 0a 00 00       	call   800ffb <sys_getenvid>
  800547:	25 ff 03 00 00       	and    $0x3ff,%eax
  80054c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800553:	c1 e0 07             	shl    $0x7,%eax
  800556:	29 d0                	sub    %edx,%eax
  800558:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80055d:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800562:	85 f6                	test   %esi,%esi
  800564:	7e 07                	jle    80056d <libmain+0x39>
		binaryname = argv[0];
  800566:	8b 03                	mov    (%ebx),%eax
  800568:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  80056d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 7a fb ff ff       	call   8000f3 <umain>

	// exit gracefully
	exit();
  800579:	e8 0a 00 00 00       	call   800588 <exit>
}
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	5b                   	pop    %ebx
  800582:	5e                   	pop    %esi
  800583:	5d                   	pop    %ebp
  800584:	c3                   	ret    
  800585:	00 00                	add    %al,(%eax)
	...

00800588 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800588:	55                   	push   %ebp
  800589:	89 e5                	mov    %esp,%ebp
  80058b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80058e:	e8 a0 12 00 00       	call   801833 <close_all>
	sys_env_destroy(0);
  800593:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80059a:	e8 0a 0a 00 00       	call   800fa9 <sys_env_destroy>
}
  80059f:	c9                   	leave  
  8005a0:	c3                   	ret    
  8005a1:	00 00                	add    %al,(%eax)
	...

008005a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	56                   	push   %esi
  8005a8:	53                   	push   %ebx
  8005a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005ac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005af:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  8005b5:	e8 41 0a 00 00       	call   800ffb <sys_getenvid>
  8005ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d0:	c7 04 24 cc 2d 80 00 	movl   $0x802dcc,(%esp)
  8005d7:	e8 c0 00 00 00       	call   80069c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e3:	89 04 24             	mov    %eax,(%esp)
  8005e6:	e8 50 00 00 00       	call   80063b <vcprintf>
	cprintf("\n");
  8005eb:	c7 04 24 f8 2c 80 00 	movl   $0x802cf8,(%esp)
  8005f2:	e8 a5 00 00 00       	call   80069c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005f7:	cc                   	int3   
  8005f8:	eb fd                	jmp    8005f7 <_panic+0x53>
	...

008005fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	53                   	push   %ebx
  800600:	83 ec 14             	sub    $0x14,%esp
  800603:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800606:	8b 03                	mov    (%ebx),%eax
  800608:	8b 55 08             	mov    0x8(%ebp),%edx
  80060b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80060f:	40                   	inc    %eax
  800610:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800612:	3d ff 00 00 00       	cmp    $0xff,%eax
  800617:	75 19                	jne    800632 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800619:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800620:	00 
  800621:	8d 43 08             	lea    0x8(%ebx),%eax
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	e8 40 09 00 00       	call   800f6c <sys_cputs>
		b->idx = 0;
  80062c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800632:	ff 43 04             	incl   0x4(%ebx)
}
  800635:	83 c4 14             	add    $0x14,%esp
  800638:	5b                   	pop    %ebx
  800639:	5d                   	pop    %ebp
  80063a:	c3                   	ret    

0080063b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800644:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80064b:	00 00 00 
	b.cnt = 0;
  80064e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800655:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800658:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	89 44 24 08          	mov    %eax,0x8(%esp)
  800666:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80066c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800670:	c7 04 24 fc 05 80 00 	movl   $0x8005fc,(%esp)
  800677:	e8 82 01 00 00       	call   8007fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80067c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800682:	89 44 24 04          	mov    %eax,0x4(%esp)
  800686:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	e8 d8 08 00 00       	call   800f6c <sys_cputs>

	return b.cnt;
}
  800694:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ac:	89 04 24             	mov    %eax,(%esp)
  8006af:	e8 87 ff ff ff       	call   80063b <vcprintf>
	va_end(ap);

	return cnt;
}
  8006b4:	c9                   	leave  
  8006b5:	c3                   	ret    
	...

008006b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 3c             	sub    $0x3c,%esp
  8006c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c4:	89 d7                	mov    %edx,%edi
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006d5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	75 08                	jne    8006e4 <printnum+0x2c>
  8006dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8006e2:	77 57                	ja     80073b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006e4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006e8:	4b                   	dec    %ebx
  8006e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8006f8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8006fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800703:	00 
  800704:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80070d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800711:	e8 16 23 00 00       	call   802a2c <__udivdi3>
  800716:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80071a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071e:	89 04 24             	mov    %eax,(%esp)
  800721:	89 54 24 04          	mov    %edx,0x4(%esp)
  800725:	89 fa                	mov    %edi,%edx
  800727:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80072a:	e8 89 ff ff ff       	call   8006b8 <printnum>
  80072f:	eb 0f                	jmp    800740 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800731:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800735:	89 34 24             	mov    %esi,(%esp)
  800738:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80073b:	4b                   	dec    %ebx
  80073c:	85 db                	test   %ebx,%ebx
  80073e:	7f f1                	jg     800731 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800740:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800744:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800748:	8b 45 10             	mov    0x10(%ebp),%eax
  80074b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800756:	00 
  800757:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80075a:	89 04 24             	mov    %eax,(%esp)
  80075d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	e8 e3 23 00 00       	call   802b4c <__umoddi3>
  800769:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076d:	0f be 80 ef 2d 80 00 	movsbl 0x802def(%eax),%eax
  800774:	89 04 24             	mov    %eax,(%esp)
  800777:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80077a:	83 c4 3c             	add    $0x3c,%esp
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5f                   	pop    %edi
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800785:	83 fa 01             	cmp    $0x1,%edx
  800788:	7e 0e                	jle    800798 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80078a:	8b 10                	mov    (%eax),%edx
  80078c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80078f:	89 08                	mov    %ecx,(%eax)
  800791:	8b 02                	mov    (%edx),%eax
  800793:	8b 52 04             	mov    0x4(%edx),%edx
  800796:	eb 22                	jmp    8007ba <getuint+0x38>
	else if (lflag)
  800798:	85 d2                	test   %edx,%edx
  80079a:	74 10                	je     8007ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80079c:	8b 10                	mov    (%eax),%edx
  80079e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a1:	89 08                	mov    %ecx,(%eax)
  8007a3:	8b 02                	mov    (%edx),%eax
  8007a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007aa:	eb 0e                	jmp    8007ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007ac:	8b 10                	mov    (%eax),%edx
  8007ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b1:	89 08                	mov    %ecx,(%eax)
  8007b3:	8b 02                	mov    (%edx),%eax
  8007b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007c5:	8b 10                	mov    (%eax),%edx
  8007c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ca:	73 08                	jae    8007d4 <sprintputch+0x18>
		*b->buf++ = ch;
  8007cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cf:	88 0a                	mov    %cl,(%edx)
  8007d1:	42                   	inc    %edx
  8007d2:	89 10                	mov    %edx,(%eax)
}
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	e8 02 00 00 00       	call   8007fe <vprintfmt>
	va_end(ap);
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	57                   	push   %edi
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	83 ec 4c             	sub    $0x4c,%esp
  800807:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080a:	8b 75 10             	mov    0x10(%ebp),%esi
  80080d:	eb 12                	jmp    800821 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80080f:	85 c0                	test   %eax,%eax
  800811:	0f 84 6b 03 00 00    	je     800b82 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800817:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800821:	0f b6 06             	movzbl (%esi),%eax
  800824:	46                   	inc    %esi
  800825:	83 f8 25             	cmp    $0x25,%eax
  800828:	75 e5                	jne    80080f <vprintfmt+0x11>
  80082a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80082e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800835:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80083a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800841:	b9 00 00 00 00       	mov    $0x0,%ecx
  800846:	eb 26                	jmp    80086e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800848:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80084b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80084f:	eb 1d                	jmp    80086e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800854:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800858:	eb 14                	jmp    80086e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80085d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800864:	eb 08                	jmp    80086e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800866:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800869:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086e:	0f b6 06             	movzbl (%esi),%eax
  800871:	8d 56 01             	lea    0x1(%esi),%edx
  800874:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800877:	8a 16                	mov    (%esi),%dl
  800879:	83 ea 23             	sub    $0x23,%edx
  80087c:	80 fa 55             	cmp    $0x55,%dl
  80087f:	0f 87 e1 02 00 00    	ja     800b66 <vprintfmt+0x368>
  800885:	0f b6 d2             	movzbl %dl,%edx
  800888:	ff 24 95 40 2f 80 00 	jmp    *0x802f40(,%edx,4)
  80088f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800892:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800897:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80089a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80089e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008a1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008a4:	83 fa 09             	cmp    $0x9,%edx
  8008a7:	77 2a                	ja     8008d3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008aa:	eb eb                	jmp    800897 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8d 50 04             	lea    0x4(%eax),%edx
  8008b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008ba:	eb 17                	jmp    8008d3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c0:	78 98                	js     80085a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c5:	eb a7                	jmp    80086e <vprintfmt+0x70>
  8008c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008ca:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008d1:	eb 9b                	jmp    80086e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8008d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d7:	79 95                	jns    80086e <vprintfmt+0x70>
  8008d9:	eb 8b                	jmp    800866 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008db:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008df:	eb 8d                	jmp    80086e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e4:	8d 50 04             	lea    0x4(%eax),%edx
  8008e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ee:	8b 00                	mov    (%eax),%eax
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008f9:	e9 23 ff ff ff       	jmp    800821 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800901:	8d 50 04             	lea    0x4(%eax),%edx
  800904:	89 55 14             	mov    %edx,0x14(%ebp)
  800907:	8b 00                	mov    (%eax),%eax
  800909:	85 c0                	test   %eax,%eax
  80090b:	79 02                	jns    80090f <vprintfmt+0x111>
  80090d:	f7 d8                	neg    %eax
  80090f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800911:	83 f8 0f             	cmp    $0xf,%eax
  800914:	7f 0b                	jg     800921 <vprintfmt+0x123>
  800916:	8b 04 85 a0 30 80 00 	mov    0x8030a0(,%eax,4),%eax
  80091d:	85 c0                	test   %eax,%eax
  80091f:	75 23                	jne    800944 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800921:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800925:	c7 44 24 08 07 2e 80 	movl   $0x802e07,0x8(%esp)
  80092c:	00 
  80092d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	89 04 24             	mov    %eax,(%esp)
  800937:	e8 9a fe ff ff       	call   8007d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80093f:	e9 dd fe ff ff       	jmp    800821 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800944:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800948:	c7 44 24 08 0a 33 80 	movl   $0x80330a,0x8(%esp)
  80094f:	00 
  800950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800954:	8b 55 08             	mov    0x8(%ebp),%edx
  800957:	89 14 24             	mov    %edx,(%esp)
  80095a:	e8 77 fe ff ff       	call   8007d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800962:	e9 ba fe ff ff       	jmp    800821 <vprintfmt+0x23>
  800967:	89 f9                	mov    %edi,%ecx
  800969:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80096c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80096f:	8b 45 14             	mov    0x14(%ebp),%eax
  800972:	8d 50 04             	lea    0x4(%eax),%edx
  800975:	89 55 14             	mov    %edx,0x14(%ebp)
  800978:	8b 30                	mov    (%eax),%esi
  80097a:	85 f6                	test   %esi,%esi
  80097c:	75 05                	jne    800983 <vprintfmt+0x185>
				p = "(null)";
  80097e:	be 00 2e 80 00       	mov    $0x802e00,%esi
			if (width > 0 && padc != '-')
  800983:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800987:	0f 8e 84 00 00 00    	jle    800a11 <vprintfmt+0x213>
  80098d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800991:	74 7e                	je     800a11 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800993:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800997:	89 34 24             	mov    %esi,(%esp)
  80099a:	e8 8b 02 00 00       	call   800c2a <strnlen>
  80099f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009a2:	29 c2                	sub    %eax,%edx
  8009a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009a7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009ab:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009ae:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009b1:	89 de                	mov    %ebx,%esi
  8009b3:	89 d3                	mov    %edx,%ebx
  8009b5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b7:	eb 0b                	jmp    8009c4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009bd:	89 3c 24             	mov    %edi,(%esp)
  8009c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c3:	4b                   	dec    %ebx
  8009c4:	85 db                	test   %ebx,%ebx
  8009c6:	7f f1                	jg     8009b9 <vprintfmt+0x1bb>
  8009c8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009cb:	89 f3                	mov    %esi,%ebx
  8009cd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8009d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	79 05                	jns    8009dc <vprintfmt+0x1de>
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009df:	29 c2                	sub    %eax,%edx
  8009e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009e4:	eb 2b                	jmp    800a11 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009ea:	74 18                	je     800a04 <vprintfmt+0x206>
  8009ec:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009ef:	83 fa 5e             	cmp    $0x5e,%edx
  8009f2:	76 10                	jbe    800a04 <vprintfmt+0x206>
					putch('?', putdat);
  8009f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009ff:	ff 55 08             	call   *0x8(%ebp)
  800a02:	eb 0a                	jmp    800a0e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0e:	ff 4d e4             	decl   -0x1c(%ebp)
  800a11:	0f be 06             	movsbl (%esi),%eax
  800a14:	46                   	inc    %esi
  800a15:	85 c0                	test   %eax,%eax
  800a17:	74 21                	je     800a3a <vprintfmt+0x23c>
  800a19:	85 ff                	test   %edi,%edi
  800a1b:	78 c9                	js     8009e6 <vprintfmt+0x1e8>
  800a1d:	4f                   	dec    %edi
  800a1e:	79 c6                	jns    8009e6 <vprintfmt+0x1e8>
  800a20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a23:	89 de                	mov    %ebx,%esi
  800a25:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a28:	eb 18                	jmp    800a42 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a35:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a37:	4b                   	dec    %ebx
  800a38:	eb 08                	jmp    800a42 <vprintfmt+0x244>
  800a3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3d:	89 de                	mov    %ebx,%esi
  800a3f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a42:	85 db                	test   %ebx,%ebx
  800a44:	7f e4                	jg     800a2a <vprintfmt+0x22c>
  800a46:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a49:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a4e:	e9 ce fd ff ff       	jmp    800821 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a53:	83 f9 01             	cmp    $0x1,%ecx
  800a56:	7e 10                	jle    800a68 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a58:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5b:	8d 50 08             	lea    0x8(%eax),%edx
  800a5e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a61:	8b 30                	mov    (%eax),%esi
  800a63:	8b 78 04             	mov    0x4(%eax),%edi
  800a66:	eb 26                	jmp    800a8e <vprintfmt+0x290>
	else if (lflag)
  800a68:	85 c9                	test   %ecx,%ecx
  800a6a:	74 12                	je     800a7e <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6f:	8d 50 04             	lea    0x4(%eax),%edx
  800a72:	89 55 14             	mov    %edx,0x14(%ebp)
  800a75:	8b 30                	mov    (%eax),%esi
  800a77:	89 f7                	mov    %esi,%edi
  800a79:	c1 ff 1f             	sar    $0x1f,%edi
  800a7c:	eb 10                	jmp    800a8e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a81:	8d 50 04             	lea    0x4(%eax),%edx
  800a84:	89 55 14             	mov    %edx,0x14(%ebp)
  800a87:	8b 30                	mov    (%eax),%esi
  800a89:	89 f7                	mov    %esi,%edi
  800a8b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a8e:	85 ff                	test   %edi,%edi
  800a90:	78 0a                	js     800a9c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a97:	e9 8c 00 00 00       	jmp    800b28 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800aa7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800aaa:	f7 de                	neg    %esi
  800aac:	83 d7 00             	adc    $0x0,%edi
  800aaf:	f7 df                	neg    %edi
			}
			base = 10;
  800ab1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ab6:	eb 70                	jmp    800b28 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ab8:	89 ca                	mov    %ecx,%edx
  800aba:	8d 45 14             	lea    0x14(%ebp),%eax
  800abd:	e8 c0 fc ff ff       	call   800782 <getuint>
  800ac2:	89 c6                	mov    %eax,%esi
  800ac4:	89 d7                	mov    %edx,%edi
			base = 10;
  800ac6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800acb:	eb 5b                	jmp    800b28 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800acd:	89 ca                	mov    %ecx,%edx
  800acf:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad2:	e8 ab fc ff ff       	call   800782 <getuint>
  800ad7:	89 c6                	mov    %eax,%esi
  800ad9:	89 d7                	mov    %edx,%edi
			base = 8;
  800adb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800ae0:	eb 46                	jmp    800b28 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800ae2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800aed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800af0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800afb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800afe:	8b 45 14             	mov    0x14(%ebp),%eax
  800b01:	8d 50 04             	lea    0x4(%eax),%edx
  800b04:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b07:	8b 30                	mov    (%eax),%esi
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b0e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b13:	eb 13                	jmp    800b28 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b15:	89 ca                	mov    %ecx,%edx
  800b17:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1a:	e8 63 fc ff ff       	call   800782 <getuint>
  800b1f:	89 c6                	mov    %eax,%esi
  800b21:	89 d7                	mov    %edx,%edi
			base = 16;
  800b23:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b28:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b2c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b33:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b3b:	89 34 24             	mov    %esi,(%esp)
  800b3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b42:	89 da                	mov    %ebx,%edx
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	e8 6c fb ff ff       	call   8006b8 <printnum>
			break;
  800b4c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b4f:	e9 cd fc ff ff       	jmp    800821 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b58:	89 04 24             	mov    %eax,(%esp)
  800b5b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b5e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b61:	e9 bb fc ff ff       	jmp    800821 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b6a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b71:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b74:	eb 01                	jmp    800b77 <vprintfmt+0x379>
  800b76:	4e                   	dec    %esi
  800b77:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b7b:	75 f9                	jne    800b76 <vprintfmt+0x378>
  800b7d:	e9 9f fc ff ff       	jmp    800821 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b82:	83 c4 4c             	add    $0x4c,%esp
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	83 ec 28             	sub    $0x28,%esp
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b99:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b9d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ba0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	74 30                	je     800bdb <vsnprintf+0x51>
  800bab:	85 d2                	test   %edx,%edx
  800bad:	7e 33                	jle    800be2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800baf:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bb6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bbd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc4:	c7 04 24 bc 07 80 00 	movl   $0x8007bc,(%esp)
  800bcb:	e8 2e fc ff ff       	call   8007fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bd3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd9:	eb 0c                	jmp    800be7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800be0:	eb 05                	jmp    800be7 <vsnprintf+0x5d>
  800be2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bf6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	89 04 24             	mov    %eax,(%esp)
  800c0a:	e8 7b ff ff ff       	call   800b8a <vsnprintf>
	va_end(ap);

	return rc;
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    
  800c11:	00 00                	add    %al,(%eax)
	...

00800c14 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	eb 01                	jmp    800c22 <strlen+0xe>
		n++;
  800c21:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c22:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c26:	75 f9                	jne    800c21 <strlen+0xd>
		n++;
	return n;
}
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c30:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c33:	b8 00 00 00 00       	mov    $0x0,%eax
  800c38:	eb 01                	jmp    800c3b <strnlen+0x11>
		n++;
  800c3a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3b:	39 d0                	cmp    %edx,%eax
  800c3d:	74 06                	je     800c45 <strnlen+0x1b>
  800c3f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c43:	75 f5                	jne    800c3a <strnlen+0x10>
		n++;
	return n;
}
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	53                   	push   %ebx
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c51:	ba 00 00 00 00       	mov    $0x0,%edx
  800c56:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c59:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c5c:	42                   	inc    %edx
  800c5d:	84 c9                	test   %cl,%cl
  800c5f:	75 f5                	jne    800c56 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c61:	5b                   	pop    %ebx
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	53                   	push   %ebx
  800c68:	83 ec 08             	sub    $0x8,%esp
  800c6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c6e:	89 1c 24             	mov    %ebx,(%esp)
  800c71:	e8 9e ff ff ff       	call   800c14 <strlen>
	strcpy(dst + len, src);
  800c76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c79:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c7d:	01 d8                	add    %ebx,%eax
  800c7f:	89 04 24             	mov    %eax,(%esp)
  800c82:	e8 c0 ff ff ff       	call   800c47 <strcpy>
	return dst;
}
  800c87:	89 d8                	mov    %ebx,%eax
  800c89:	83 c4 08             	add    $0x8,%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca2:	eb 0c                	jmp    800cb0 <strncpy+0x21>
		*dst++ = *src;
  800ca4:	8a 1a                	mov    (%edx),%bl
  800ca6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ca9:	80 3a 01             	cmpb   $0x1,(%edx)
  800cac:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800caf:	41                   	inc    %ecx
  800cb0:	39 f1                	cmp    %esi,%ecx
  800cb2:	75 f0                	jne    800ca4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cc6:	85 d2                	test   %edx,%edx
  800cc8:	75 0a                	jne    800cd4 <strlcpy+0x1c>
  800cca:	89 f0                	mov    %esi,%eax
  800ccc:	eb 1a                	jmp    800ce8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cce:	88 18                	mov    %bl,(%eax)
  800cd0:	40                   	inc    %eax
  800cd1:	41                   	inc    %ecx
  800cd2:	eb 02                	jmp    800cd6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cd4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800cd6:	4a                   	dec    %edx
  800cd7:	74 0a                	je     800ce3 <strlcpy+0x2b>
  800cd9:	8a 19                	mov    (%ecx),%bl
  800cdb:	84 db                	test   %bl,%bl
  800cdd:	75 ef                	jne    800cce <strlcpy+0x16>
  800cdf:	89 c2                	mov    %eax,%edx
  800ce1:	eb 02                	jmp    800ce5 <strlcpy+0x2d>
  800ce3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ce5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ce8:	29 f0                	sub    %esi,%eax
}
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cf7:	eb 02                	jmp    800cfb <strcmp+0xd>
		p++, q++;
  800cf9:	41                   	inc    %ecx
  800cfa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cfb:	8a 01                	mov    (%ecx),%al
  800cfd:	84 c0                	test   %al,%al
  800cff:	74 04                	je     800d05 <strcmp+0x17>
  800d01:	3a 02                	cmp    (%edx),%al
  800d03:	74 f4                	je     800cf9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d05:	0f b6 c0             	movzbl %al,%eax
  800d08:	0f b6 12             	movzbl (%edx),%edx
  800d0b:	29 d0                	sub    %edx,%eax
}
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	53                   	push   %ebx
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d1c:	eb 03                	jmp    800d21 <strncmp+0x12>
		n--, p++, q++;
  800d1e:	4a                   	dec    %edx
  800d1f:	40                   	inc    %eax
  800d20:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d21:	85 d2                	test   %edx,%edx
  800d23:	74 14                	je     800d39 <strncmp+0x2a>
  800d25:	8a 18                	mov    (%eax),%bl
  800d27:	84 db                	test   %bl,%bl
  800d29:	74 04                	je     800d2f <strncmp+0x20>
  800d2b:	3a 19                	cmp    (%ecx),%bl
  800d2d:	74 ef                	je     800d1e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d2f:	0f b6 00             	movzbl (%eax),%eax
  800d32:	0f b6 11             	movzbl (%ecx),%edx
  800d35:	29 d0                	sub    %edx,%eax
  800d37:	eb 05                	jmp    800d3e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d39:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	8b 45 08             	mov    0x8(%ebp),%eax
  800d47:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d4a:	eb 05                	jmp    800d51 <strchr+0x10>
		if (*s == c)
  800d4c:	38 ca                	cmp    %cl,%dl
  800d4e:	74 0c                	je     800d5c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d50:	40                   	inc    %eax
  800d51:	8a 10                	mov    (%eax),%dl
  800d53:	84 d2                	test   %dl,%dl
  800d55:	75 f5                	jne    800d4c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d67:	eb 05                	jmp    800d6e <strfind+0x10>
		if (*s == c)
  800d69:	38 ca                	cmp    %cl,%dl
  800d6b:	74 07                	je     800d74 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d6d:	40                   	inc    %eax
  800d6e:	8a 10                	mov    (%eax),%dl
  800d70:	84 d2                	test   %dl,%dl
  800d72:	75 f5                	jne    800d69 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d85:	85 c9                	test   %ecx,%ecx
  800d87:	74 30                	je     800db9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d8f:	75 25                	jne    800db6 <memset+0x40>
  800d91:	f6 c1 03             	test   $0x3,%cl
  800d94:	75 20                	jne    800db6 <memset+0x40>
		c &= 0xFF;
  800d96:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d99:	89 d3                	mov    %edx,%ebx
  800d9b:	c1 e3 08             	shl    $0x8,%ebx
  800d9e:	89 d6                	mov    %edx,%esi
  800da0:	c1 e6 18             	shl    $0x18,%esi
  800da3:	89 d0                	mov    %edx,%eax
  800da5:	c1 e0 10             	shl    $0x10,%eax
  800da8:	09 f0                	or     %esi,%eax
  800daa:	09 d0                	or     %edx,%eax
  800dac:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dae:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800db1:	fc                   	cld    
  800db2:	f3 ab                	rep stos %eax,%es:(%edi)
  800db4:	eb 03                	jmp    800db9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800db6:	fc                   	cld    
  800db7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800db9:	89 f8                	mov    %edi,%eax
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dce:	39 c6                	cmp    %eax,%esi
  800dd0:	73 34                	jae    800e06 <memmove+0x46>
  800dd2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dd5:	39 d0                	cmp    %edx,%eax
  800dd7:	73 2d                	jae    800e06 <memmove+0x46>
		s += n;
		d += n;
  800dd9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ddc:	f6 c2 03             	test   $0x3,%dl
  800ddf:	75 1b                	jne    800dfc <memmove+0x3c>
  800de1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800de7:	75 13                	jne    800dfc <memmove+0x3c>
  800de9:	f6 c1 03             	test   $0x3,%cl
  800dec:	75 0e                	jne    800dfc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800dee:	83 ef 04             	sub    $0x4,%edi
  800df1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800df4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800df7:	fd                   	std    
  800df8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dfa:	eb 07                	jmp    800e03 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800dfc:	4f                   	dec    %edi
  800dfd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e00:	fd                   	std    
  800e01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e03:	fc                   	cld    
  800e04:	eb 20                	jmp    800e26 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e0c:	75 13                	jne    800e21 <memmove+0x61>
  800e0e:	a8 03                	test   $0x3,%al
  800e10:	75 0f                	jne    800e21 <memmove+0x61>
  800e12:	f6 c1 03             	test   $0x3,%cl
  800e15:	75 0a                	jne    800e21 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e17:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e1a:	89 c7                	mov    %eax,%edi
  800e1c:	fc                   	cld    
  800e1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1f:	eb 05                	jmp    800e26 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e21:	89 c7                	mov    %eax,%edi
  800e23:	fc                   	cld    
  800e24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e30:	8b 45 10             	mov    0x10(%ebp),%eax
  800e33:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	89 04 24             	mov    %eax,(%esp)
  800e44:	e8 77 ff ff ff       	call   800dc0 <memmove>
}
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5f:	eb 16                	jmp    800e77 <memcmp+0x2c>
		if (*s1 != *s2)
  800e61:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e64:	42                   	inc    %edx
  800e65:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e69:	38 c8                	cmp    %cl,%al
  800e6b:	74 0a                	je     800e77 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800e6d:	0f b6 c0             	movzbl %al,%eax
  800e70:	0f b6 c9             	movzbl %cl,%ecx
  800e73:	29 c8                	sub    %ecx,%eax
  800e75:	eb 09                	jmp    800e80 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e77:	39 da                	cmp    %ebx,%edx
  800e79:	75 e6                	jne    800e61 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e8e:	89 c2                	mov    %eax,%edx
  800e90:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e93:	eb 05                	jmp    800e9a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e95:	38 08                	cmp    %cl,(%eax)
  800e97:	74 05                	je     800e9e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e99:	40                   	inc    %eax
  800e9a:	39 d0                	cmp    %edx,%eax
  800e9c:	72 f7                	jb     800e95 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eac:	eb 01                	jmp    800eaf <strtol+0xf>
		s++;
  800eae:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eaf:	8a 02                	mov    (%edx),%al
  800eb1:	3c 20                	cmp    $0x20,%al
  800eb3:	74 f9                	je     800eae <strtol+0xe>
  800eb5:	3c 09                	cmp    $0x9,%al
  800eb7:	74 f5                	je     800eae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eb9:	3c 2b                	cmp    $0x2b,%al
  800ebb:	75 08                	jne    800ec5 <strtol+0x25>
		s++;
  800ebd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ebe:	bf 00 00 00 00       	mov    $0x0,%edi
  800ec3:	eb 13                	jmp    800ed8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ec5:	3c 2d                	cmp    $0x2d,%al
  800ec7:	75 0a                	jne    800ed3 <strtol+0x33>
		s++, neg = 1;
  800ec9:	8d 52 01             	lea    0x1(%edx),%edx
  800ecc:	bf 01 00 00 00       	mov    $0x1,%edi
  800ed1:	eb 05                	jmp    800ed8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ed3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ed8:	85 db                	test   %ebx,%ebx
  800eda:	74 05                	je     800ee1 <strtol+0x41>
  800edc:	83 fb 10             	cmp    $0x10,%ebx
  800edf:	75 28                	jne    800f09 <strtol+0x69>
  800ee1:	8a 02                	mov    (%edx),%al
  800ee3:	3c 30                	cmp    $0x30,%al
  800ee5:	75 10                	jne    800ef7 <strtol+0x57>
  800ee7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800eeb:	75 0a                	jne    800ef7 <strtol+0x57>
		s += 2, base = 16;
  800eed:	83 c2 02             	add    $0x2,%edx
  800ef0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ef5:	eb 12                	jmp    800f09 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ef7:	85 db                	test   %ebx,%ebx
  800ef9:	75 0e                	jne    800f09 <strtol+0x69>
  800efb:	3c 30                	cmp    $0x30,%al
  800efd:	75 05                	jne    800f04 <strtol+0x64>
		s++, base = 8;
  800eff:	42                   	inc    %edx
  800f00:	b3 08                	mov    $0x8,%bl
  800f02:	eb 05                	jmp    800f09 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f04:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f10:	8a 0a                	mov    (%edx),%cl
  800f12:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f15:	80 fb 09             	cmp    $0x9,%bl
  800f18:	77 08                	ja     800f22 <strtol+0x82>
			dig = *s - '0';
  800f1a:	0f be c9             	movsbl %cl,%ecx
  800f1d:	83 e9 30             	sub    $0x30,%ecx
  800f20:	eb 1e                	jmp    800f40 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f22:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f25:	80 fb 19             	cmp    $0x19,%bl
  800f28:	77 08                	ja     800f32 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f2a:	0f be c9             	movsbl %cl,%ecx
  800f2d:	83 e9 57             	sub    $0x57,%ecx
  800f30:	eb 0e                	jmp    800f40 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f32:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f35:	80 fb 19             	cmp    $0x19,%bl
  800f38:	77 12                	ja     800f4c <strtol+0xac>
			dig = *s - 'A' + 10;
  800f3a:	0f be c9             	movsbl %cl,%ecx
  800f3d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f40:	39 f1                	cmp    %esi,%ecx
  800f42:	7d 0c                	jge    800f50 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f44:	42                   	inc    %edx
  800f45:	0f af c6             	imul   %esi,%eax
  800f48:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f4a:	eb c4                	jmp    800f10 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f4c:	89 c1                	mov    %eax,%ecx
  800f4e:	eb 02                	jmp    800f52 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f50:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f56:	74 05                	je     800f5d <strtol+0xbd>
		*endptr = (char *) s;
  800f58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f5b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f5d:	85 ff                	test   %edi,%edi
  800f5f:	74 04                	je     800f65 <strtol+0xc5>
  800f61:	89 c8                	mov    %ecx,%eax
  800f63:	f7 d8                	neg    %eax
}
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    
	...

00800f6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
  800f77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7d:	89 c3                	mov    %eax,%ebx
  800f7f:	89 c7                	mov    %eax,%edi
  800f81:	89 c6                	mov    %eax,%esi
  800f83:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	57                   	push   %edi
  800f8e:	56                   	push   %esi
  800f8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f90:	ba 00 00 00 00       	mov    $0x0,%edx
  800f95:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9a:	89 d1                	mov    %edx,%ecx
  800f9c:	89 d3                	mov    %edx,%ebx
  800f9e:	89 d7                	mov    %edx,%edi
  800fa0:	89 d6                	mov    %edx,%esi
  800fa2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	57                   	push   %edi
  800fad:	56                   	push   %esi
  800fae:	53                   	push   %ebx
  800faf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb7:	b8 03 00 00 00       	mov    $0x3,%eax
  800fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbf:	89 cb                	mov    %ecx,%ebx
  800fc1:	89 cf                	mov    %ecx,%edi
  800fc3:	89 ce                	mov    %ecx,%esi
  800fc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	7e 28                	jle    800ff3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fd6:	00 
  800fd7:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  800fde:	00 
  800fdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe6:	00 
  800fe7:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  800fee:	e8 b1 f5 ff ff       	call   8005a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ff3:	83 c4 2c             	add    $0x2c,%esp
  800ff6:	5b                   	pop    %ebx
  800ff7:	5e                   	pop    %esi
  800ff8:	5f                   	pop    %edi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	57                   	push   %edi
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801001:	ba 00 00 00 00       	mov    $0x0,%edx
  801006:	b8 02 00 00 00       	mov    $0x2,%eax
  80100b:	89 d1                	mov    %edx,%ecx
  80100d:	89 d3                	mov    %edx,%ebx
  80100f:	89 d7                	mov    %edx,%edi
  801011:	89 d6                	mov    %edx,%esi
  801013:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <sys_yield>:

void
sys_yield(void)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801020:	ba 00 00 00 00       	mov    $0x0,%edx
  801025:	b8 0b 00 00 00       	mov    $0xb,%eax
  80102a:	89 d1                	mov    %edx,%ecx
  80102c:	89 d3                	mov    %edx,%ebx
  80102e:	89 d7                	mov    %edx,%edi
  801030:	89 d6                	mov    %edx,%esi
  801032:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801042:	be 00 00 00 00       	mov    $0x0,%esi
  801047:	b8 04 00 00 00       	mov    $0x4,%eax
  80104c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80104f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801052:	8b 55 08             	mov    0x8(%ebp),%edx
  801055:	89 f7                	mov    %esi,%edi
  801057:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801059:	85 c0                	test   %eax,%eax
  80105b:	7e 28                	jle    801085 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801061:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801068:	00 
  801069:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  801070:	00 
  801071:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801078:	00 
  801079:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  801080:	e8 1f f5 ff ff       	call   8005a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801085:	83 c4 2c             	add    $0x2c,%esp
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801096:	b8 05 00 00 00       	mov    $0x5,%eax
  80109b:	8b 75 18             	mov    0x18(%ebp),%esi
  80109e:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	7e 28                	jle    8010d8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  8010c3:	00 
  8010c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cb:	00 
  8010cc:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  8010d3:	e8 cc f4 ff ff       	call   8005a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010d8:	83 c4 2c             	add    $0x2c,%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f9:	89 df                	mov    %ebx,%edi
  8010fb:	89 de                	mov    %ebx,%esi
  8010fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010ff:	85 c0                	test   %eax,%eax
  801101:	7e 28                	jle    80112b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801103:	89 44 24 10          	mov    %eax,0x10(%esp)
  801107:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80110e:	00 
  80110f:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  801116:	00 
  801117:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80111e:	00 
  80111f:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  801126:	e8 79 f4 ff ff       	call   8005a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80112b:	83 c4 2c             	add    $0x2c,%esp
  80112e:	5b                   	pop    %ebx
  80112f:	5e                   	pop    %esi
  801130:	5f                   	pop    %edi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801141:	b8 08 00 00 00       	mov    $0x8,%eax
  801146:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801149:	8b 55 08             	mov    0x8(%ebp),%edx
  80114c:	89 df                	mov    %ebx,%edi
  80114e:	89 de                	mov    %ebx,%esi
  801150:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801152:	85 c0                	test   %eax,%eax
  801154:	7e 28                	jle    80117e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801156:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801161:	00 
  801162:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  801169:	00 
  80116a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801171:	00 
  801172:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  801179:	e8 26 f4 ff ff       	call   8005a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80117e:	83 c4 2c             	add    $0x2c,%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	57                   	push   %edi
  80118a:	56                   	push   %esi
  80118b:	53                   	push   %ebx
  80118c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801194:	b8 09 00 00 00       	mov    $0x9,%eax
  801199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119c:	8b 55 08             	mov    0x8(%ebp),%edx
  80119f:	89 df                	mov    %ebx,%edi
  8011a1:	89 de                	mov    %ebx,%esi
  8011a3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	7e 28                	jle    8011d1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ad:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011b4:	00 
  8011b5:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c4:	00 
  8011c5:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  8011cc:	e8 d3 f3 ff ff       	call   8005a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011d1:	83 c4 2c             	add    $0x2c,%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f2:	89 df                	mov    %ebx,%edi
  8011f4:	89 de                	mov    %ebx,%esi
  8011f6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	7e 28                	jle    801224 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  801200:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801207:	00 
  801208:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  80120f:	00 
  801210:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801217:	00 
  801218:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  80121f:	e8 80 f3 ff ff       	call   8005a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801224:	83 c4 2c             	add    $0x2c,%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	57                   	push   %edi
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801232:	be 00 00 00 00       	mov    $0x0,%esi
  801237:	b8 0c 00 00 00       	mov    $0xc,%eax
  80123c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80123f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801245:	8b 55 08             	mov    0x8(%ebp),%edx
  801248:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80124a:	5b                   	pop    %ebx
  80124b:	5e                   	pop    %esi
  80124c:	5f                   	pop    %edi
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	57                   	push   %edi
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
  801255:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801258:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801262:	8b 55 08             	mov    0x8(%ebp),%edx
  801265:	89 cb                	mov    %ecx,%ebx
  801267:	89 cf                	mov    %ecx,%edi
  801269:	89 ce                	mov    %ecx,%esi
  80126b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80126d:	85 c0                	test   %eax,%eax
  80126f:	7e 28                	jle    801299 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801271:	89 44 24 10          	mov    %eax,0x10(%esp)
  801275:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80127c:	00 
  80127d:	c7 44 24 08 ff 30 80 	movl   $0x8030ff,0x8(%esp)
  801284:	00 
  801285:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80128c:	00 
  80128d:	c7 04 24 1c 31 80 00 	movl   $0x80311c,(%esp)
  801294:	e8 0b f3 ff ff       	call   8005a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801299:	83 c4 2c             	add    $0x2c,%esp
  80129c:	5b                   	pop    %ebx
  80129d:	5e                   	pop    %esi
  80129e:	5f                   	pop    %edi
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    
  8012a1:	00 00                	add    %al,(%eax)
	...

008012a4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 24             	sub    $0x24,%esp
  8012ab:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8012ae:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  8012b0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8012b4:	75 2d                	jne    8012e3 <pgfault+0x3f>
  8012b6:	89 d8                	mov    %ebx,%eax
  8012b8:	c1 e8 0c             	shr    $0xc,%eax
  8012bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c2:	f6 c4 08             	test   $0x8,%ah
  8012c5:	75 1c                	jne    8012e3 <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  8012c7:	c7 44 24 08 2c 31 80 	movl   $0x80312c,0x8(%esp)
  8012ce:	00 
  8012cf:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8012d6:	00 
  8012d7:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  8012de:	e8 c1 f2 ff ff       	call   8005a4 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8012e3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012ea:	00 
  8012eb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012f2:	00 
  8012f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012fa:	e8 3a fd ff ff       	call   801039 <sys_page_alloc>
  8012ff:	85 c0                	test   %eax,%eax
  801301:	79 20                	jns    801323 <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  801303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801307:	c7 44 24 08 9b 31 80 	movl   $0x80319b,0x8(%esp)
  80130e:	00 
  80130f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801316:	00 
  801317:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  80131e:	e8 81 f2 ff ff       	call   8005a4 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  801323:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  801329:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801330:	00 
  801331:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801335:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80133c:	e8 e9 fa ff ff       	call   800e2a <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801341:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801348:	00 
  801349:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80134d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801354:	00 
  801355:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80135c:	00 
  80135d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801364:	e8 24 fd ff ff       	call   80108d <sys_page_map>
  801369:	85 c0                	test   %eax,%eax
  80136b:	79 20                	jns    80138d <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  80136d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801371:	c7 44 24 08 ae 31 80 	movl   $0x8031ae,0x8(%esp)
  801378:	00 
  801379:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801380:	00 
  801381:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  801388:	e8 17 f2 ff ff       	call   8005a4 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  80138d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801394:	00 
  801395:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80139c:	e8 3f fd ff ff       	call   8010e0 <sys_page_unmap>
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	79 20                	jns    8013c5 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  8013a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a9:	c7 44 24 08 bf 31 80 	movl   $0x8031bf,0x8(%esp)
  8013b0:	00 
  8013b1:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8013b8:	00 
  8013b9:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  8013c0:	e8 df f1 ff ff       	call   8005a4 <_panic>
}
  8013c5:	83 c4 24             	add    $0x24,%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	57                   	push   %edi
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  8013d4:	c7 04 24 a4 12 80 00 	movl   $0x8012a4,(%esp)
  8013db:	e8 7c 14 00 00       	call   80285c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8013e0:	ba 07 00 00 00       	mov    $0x7,%edx
  8013e5:	89 d0                	mov    %edx,%eax
  8013e7:	cd 30                	int    $0x30
  8013e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	79 1c                	jns    80140f <fork+0x44>
		panic("sys_exofork failed\n");
  8013f3:	c7 44 24 08 d2 31 80 	movl   $0x8031d2,0x8(%esp)
  8013fa:	00 
  8013fb:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801402:	00 
  801403:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  80140a:	e8 95 f1 ff ff       	call   8005a4 <_panic>
	if(c_envid == 0){
  80140f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801413:	75 25                	jne    80143a <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  801415:	e8 e1 fb ff ff       	call   800ffb <sys_getenvid>
  80141a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80141f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801426:	c1 e0 07             	shl    $0x7,%eax
  801429:	29 d0                	sub    %edx,%eax
  80142b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801430:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  801435:	e9 e3 01 00 00       	jmp    80161d <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  80143a:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  80143f:	89 d8                	mov    %ebx,%eax
  801441:	c1 e8 16             	shr    $0x16,%eax
  801444:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80144b:	a8 01                	test   $0x1,%al
  80144d:	0f 84 0b 01 00 00    	je     80155e <fork+0x193>
  801453:	89 de                	mov    %ebx,%esi
  801455:	c1 ee 0c             	shr    $0xc,%esi
  801458:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80145f:	a8 05                	test   $0x5,%al
  801461:	0f 84 f7 00 00 00    	je     80155e <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  801467:	89 f7                	mov    %esi,%edi
  801469:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  80146c:	e8 8a fb ff ff       	call   800ffb <sys_getenvid>
  801471:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801474:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80147b:	a8 02                	test   $0x2,%al
  80147d:	75 10                	jne    80148f <fork+0xc4>
  80147f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801486:	f6 c4 08             	test   $0x8,%ah
  801489:	0f 84 89 00 00 00    	je     801518 <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  80148f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801496:	00 
  801497:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80149b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80149e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a9:	89 04 24             	mov    %eax,(%esp)
  8014ac:	e8 dc fb ff ff       	call   80108d <sys_page_map>
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	79 20                	jns    8014d5 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8014b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b9:	c7 44 24 08 e6 31 80 	movl   $0x8031e6,0x8(%esp)
  8014c0:	00 
  8014c1:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  8014c8:	00 
  8014c9:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  8014d0:	e8 cf f0 ff ff       	call   8005a4 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  8014d5:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8014dc:	00 
  8014dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ec:	89 04 24             	mov    %eax,(%esp)
  8014ef:	e8 99 fb ff ff       	call   80108d <sys_page_map>
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	79 66                	jns    80155e <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8014f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014fc:	c7 44 24 08 e6 31 80 	movl   $0x8031e6,0x8(%esp)
  801503:	00 
  801504:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  80150b:	00 
  80150c:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  801513:	e8 8c f0 ff ff       	call   8005a4 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  801518:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80151f:	00 
  801520:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801524:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801527:	89 44 24 08          	mov    %eax,0x8(%esp)
  80152b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80152f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801532:	89 04 24             	mov    %eax,(%esp)
  801535:	e8 53 fb ff ff       	call   80108d <sys_page_map>
  80153a:	85 c0                	test   %eax,%eax
  80153c:	79 20                	jns    80155e <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  80153e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801542:	c7 44 24 08 e6 31 80 	movl   $0x8031e6,0x8(%esp)
  801549:	00 
  80154a:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801551:	00 
  801552:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  801559:	e8 46 f0 ff ff       	call   8005a4 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  80155e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801564:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80156a:	0f 85 cf fe ff ff    	jne    80143f <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  801570:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801577:	00 
  801578:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80157f:	ee 
  801580:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801583:	89 04 24             	mov    %eax,(%esp)
  801586:	e8 ae fa ff ff       	call   801039 <sys_page_alloc>
  80158b:	85 c0                	test   %eax,%eax
  80158d:	79 20                	jns    8015af <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  80158f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801593:	c7 44 24 08 f8 31 80 	movl   $0x8031f8,0x8(%esp)
  80159a:	00 
  80159b:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8015a2:	00 
  8015a3:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  8015aa:	e8 f5 ef ff ff       	call   8005a4 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  8015af:	c7 44 24 04 a8 28 80 	movl   $0x8028a8,0x4(%esp)
  8015b6:	00 
  8015b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015ba:	89 04 24             	mov    %eax,(%esp)
  8015bd:	e8 17 fc ff ff       	call   8011d9 <sys_env_set_pgfault_upcall>
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	79 20                	jns    8015e6 <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8015c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ca:	c7 44 24 08 70 31 80 	movl   $0x803170,0x8(%esp)
  8015d1:	00 
  8015d2:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8015d9:	00 
  8015da:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  8015e1:	e8 be ef ff ff       	call   8005a4 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  8015e6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8015ed:	00 
  8015ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8015f1:	89 04 24             	mov    %eax,(%esp)
  8015f4:	e8 3a fb ff ff       	call   801133 <sys_env_set_status>
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	79 20                	jns    80161d <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  8015fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801601:	c7 44 24 08 0c 32 80 	movl   $0x80320c,0x8(%esp)
  801608:	00 
  801609:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801610:	00 
  801611:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  801618:	e8 87 ef ff ff       	call   8005a4 <_panic>
 
	return c_envid;	
}
  80161d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801620:	83 c4 3c             	add    $0x3c,%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	5f                   	pop    %edi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    

00801628 <sfork>:

// Challenge!
int
sfork(void)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80162e:	c7 44 24 08 24 32 80 	movl   $0x803224,0x8(%esp)
  801635:	00 
  801636:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  80163d:	00 
  80163e:	c7 04 24 90 31 80 00 	movl   $0x803190,(%esp)
  801645:	e8 5a ef ff ff       	call   8005a4 <_panic>
	...

0080164c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	05 00 00 00 30       	add    $0x30000000,%eax
  801657:	c1 e8 0c             	shr    $0xc,%eax
}
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801662:	8b 45 08             	mov    0x8(%ebp),%eax
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	e8 df ff ff ff       	call   80164c <fd2num>
  80166d:	05 20 00 0d 00       	add    $0xd0020,%eax
  801672:	c1 e0 0c             	shl    $0xc,%eax
}
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80167e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801683:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801685:	89 c2                	mov    %eax,%edx
  801687:	c1 ea 16             	shr    $0x16,%edx
  80168a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801691:	f6 c2 01             	test   $0x1,%dl
  801694:	74 11                	je     8016a7 <fd_alloc+0x30>
  801696:	89 c2                	mov    %eax,%edx
  801698:	c1 ea 0c             	shr    $0xc,%edx
  80169b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016a2:	f6 c2 01             	test   $0x1,%dl
  8016a5:	75 09                	jne    8016b0 <fd_alloc+0x39>
			*fd_store = fd;
  8016a7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8016a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ae:	eb 17                	jmp    8016c7 <fd_alloc+0x50>
  8016b0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016b5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016ba:	75 c7                	jne    801683 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8016c2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016c7:	5b                   	pop    %ebx
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016d0:	83 f8 1f             	cmp    $0x1f,%eax
  8016d3:	77 36                	ja     80170b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016d5:	05 00 00 0d 00       	add    $0xd0000,%eax
  8016da:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016dd:	89 c2                	mov    %eax,%edx
  8016df:	c1 ea 16             	shr    $0x16,%edx
  8016e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016e9:	f6 c2 01             	test   $0x1,%dl
  8016ec:	74 24                	je     801712 <fd_lookup+0x48>
  8016ee:	89 c2                	mov    %eax,%edx
  8016f0:	c1 ea 0c             	shr    $0xc,%edx
  8016f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016fa:	f6 c2 01             	test   $0x1,%dl
  8016fd:	74 1a                	je     801719 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801702:	89 02                	mov    %eax,(%edx)
	return 0;
  801704:	b8 00 00 00 00       	mov    $0x0,%eax
  801709:	eb 13                	jmp    80171e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80170b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801710:	eb 0c                	jmp    80171e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801717:	eb 05                	jmp    80171e <fd_lookup+0x54>
  801719:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	83 ec 14             	sub    $0x14,%esp
  801727:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80172a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80172d:	ba 00 00 00 00       	mov    $0x0,%edx
  801732:	eb 0e                	jmp    801742 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801734:	39 08                	cmp    %ecx,(%eax)
  801736:	75 09                	jne    801741 <dev_lookup+0x21>
			*dev = devtab[i];
  801738:	89 03                	mov    %eax,(%ebx)
			return 0;
  80173a:	b8 00 00 00 00       	mov    $0x0,%eax
  80173f:	eb 33                	jmp    801774 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801741:	42                   	inc    %edx
  801742:	8b 04 95 b8 32 80 00 	mov    0x8032b8(,%edx,4),%eax
  801749:	85 c0                	test   %eax,%eax
  80174b:	75 e7                	jne    801734 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80174d:	a1 04 50 80 00       	mov    0x805004,%eax
  801752:	8b 40 48             	mov    0x48(%eax),%eax
  801755:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175d:	c7 04 24 3c 32 80 00 	movl   $0x80323c,(%esp)
  801764:	e8 33 ef ff ff       	call   80069c <cprintf>
	*dev = 0;
  801769:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80176f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801774:	83 c4 14             	add    $0x14,%esp
  801777:	5b                   	pop    %ebx
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	56                   	push   %esi
  80177e:	53                   	push   %ebx
  80177f:	83 ec 30             	sub    $0x30,%esp
  801782:	8b 75 08             	mov    0x8(%ebp),%esi
  801785:	8a 45 0c             	mov    0xc(%ebp),%al
  801788:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80178b:	89 34 24             	mov    %esi,(%esp)
  80178e:	e8 b9 fe ff ff       	call   80164c <fd2num>
  801793:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801796:	89 54 24 04          	mov    %edx,0x4(%esp)
  80179a:	89 04 24             	mov    %eax,(%esp)
  80179d:	e8 28 ff ff ff       	call   8016ca <fd_lookup>
  8017a2:	89 c3                	mov    %eax,%ebx
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 05                	js     8017ad <fd_close+0x33>
	    || fd != fd2)
  8017a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8017ab:	74 0d                	je     8017ba <fd_close+0x40>
		return (must_exist ? r : 0);
  8017ad:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8017b1:	75 46                	jne    8017f9 <fd_close+0x7f>
  8017b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b8:	eb 3f                	jmp    8017f9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c1:	8b 06                	mov    (%esi),%eax
  8017c3:	89 04 24             	mov    %eax,(%esp)
  8017c6:	e8 55 ff ff ff       	call   801720 <dev_lookup>
  8017cb:	89 c3                	mov    %eax,%ebx
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 18                	js     8017e9 <fd_close+0x6f>
		if (dev->dev_close)
  8017d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d4:	8b 40 10             	mov    0x10(%eax),%eax
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	74 09                	je     8017e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8017db:	89 34 24             	mov    %esi,(%esp)
  8017de:	ff d0                	call   *%eax
  8017e0:	89 c3                	mov    %eax,%ebx
  8017e2:	eb 05                	jmp    8017e9 <fd_close+0x6f>
		else
			r = 0;
  8017e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f4:	e8 e7 f8 ff ff       	call   8010e0 <sys_page_unmap>
	return r;
}
  8017f9:	89 d8                	mov    %ebx,%eax
  8017fb:	83 c4 30             	add    $0x30,%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801808:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180f:	8b 45 08             	mov    0x8(%ebp),%eax
  801812:	89 04 24             	mov    %eax,(%esp)
  801815:	e8 b0 fe ff ff       	call   8016ca <fd_lookup>
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 13                	js     801831 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80181e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801825:	00 
  801826:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801829:	89 04 24             	mov    %eax,(%esp)
  80182c:	e8 49 ff ff ff       	call   80177a <fd_close>
}
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <close_all>:

void
close_all(void)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	53                   	push   %ebx
  801837:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80183a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80183f:	89 1c 24             	mov    %ebx,(%esp)
  801842:	e8 bb ff ff ff       	call   801802 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801847:	43                   	inc    %ebx
  801848:	83 fb 20             	cmp    $0x20,%ebx
  80184b:	75 f2                	jne    80183f <close_all+0xc>
		close(i);
}
  80184d:	83 c4 14             	add    $0x14,%esp
  801850:	5b                   	pop    %ebx
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    

00801853 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	57                   	push   %edi
  801857:	56                   	push   %esi
  801858:	53                   	push   %ebx
  801859:	83 ec 4c             	sub    $0x4c,%esp
  80185c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80185f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801862:	89 44 24 04          	mov    %eax,0x4(%esp)
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	89 04 24             	mov    %eax,(%esp)
  80186c:	e8 59 fe ff ff       	call   8016ca <fd_lookup>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	85 c0                	test   %eax,%eax
  801875:	0f 88 e1 00 00 00    	js     80195c <dup+0x109>
		return r;
	close(newfdnum);
  80187b:	89 3c 24             	mov    %edi,(%esp)
  80187e:	e8 7f ff ff ff       	call   801802 <close>

	newfd = INDEX2FD(newfdnum);
  801883:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801889:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80188c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80188f:	89 04 24             	mov    %eax,(%esp)
  801892:	e8 c5 fd ff ff       	call   80165c <fd2data>
  801897:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801899:	89 34 24             	mov    %esi,(%esp)
  80189c:	e8 bb fd ff ff       	call   80165c <fd2data>
  8018a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8018a4:	89 d8                	mov    %ebx,%eax
  8018a6:	c1 e8 16             	shr    $0x16,%eax
  8018a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018b0:	a8 01                	test   $0x1,%al
  8018b2:	74 46                	je     8018fa <dup+0xa7>
  8018b4:	89 d8                	mov    %ebx,%eax
  8018b6:	c1 e8 0c             	shr    $0xc,%eax
  8018b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018c0:	f6 c2 01             	test   $0x1,%dl
  8018c3:	74 35                	je     8018fa <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8018d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018e3:	00 
  8018e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ef:	e8 99 f7 ff ff       	call   80108d <sys_page_map>
  8018f4:	89 c3                	mov    %eax,%ebx
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 3b                	js     801935 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	c1 ea 0c             	shr    $0xc,%edx
  801902:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801909:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80190f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801913:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801917:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80191e:	00 
  80191f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801923:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192a:	e8 5e f7 ff ff       	call   80108d <sys_page_map>
  80192f:	89 c3                	mov    %eax,%ebx
  801931:	85 c0                	test   %eax,%eax
  801933:	79 25                	jns    80195a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801935:	89 74 24 04          	mov    %esi,0x4(%esp)
  801939:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801940:	e8 9b f7 ff ff       	call   8010e0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801945:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801953:	e8 88 f7 ff ff       	call   8010e0 <sys_page_unmap>
	return r;
  801958:	eb 02                	jmp    80195c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80195a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80195c:	89 d8                	mov    %ebx,%eax
  80195e:	83 c4 4c             	add    $0x4c,%esp
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5f                   	pop    %edi
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	53                   	push   %ebx
  80196a:	83 ec 24             	sub    $0x24,%esp
  80196d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801970:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801973:	89 44 24 04          	mov    %eax,0x4(%esp)
  801977:	89 1c 24             	mov    %ebx,(%esp)
  80197a:	e8 4b fd ff ff       	call   8016ca <fd_lookup>
  80197f:	85 c0                	test   %eax,%eax
  801981:	78 6d                	js     8019f0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801983:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801986:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198d:	8b 00                	mov    (%eax),%eax
  80198f:	89 04 24             	mov    %eax,(%esp)
  801992:	e8 89 fd ff ff       	call   801720 <dev_lookup>
  801997:	85 c0                	test   %eax,%eax
  801999:	78 55                	js     8019f0 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80199b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199e:	8b 50 08             	mov    0x8(%eax),%edx
  8019a1:	83 e2 03             	and    $0x3,%edx
  8019a4:	83 fa 01             	cmp    $0x1,%edx
  8019a7:	75 23                	jne    8019cc <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019a9:	a1 04 50 80 00       	mov    0x805004,%eax
  8019ae:	8b 40 48             	mov    0x48(%eax),%eax
  8019b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b9:	c7 04 24 7d 32 80 00 	movl   $0x80327d,(%esp)
  8019c0:	e8 d7 ec ff ff       	call   80069c <cprintf>
		return -E_INVAL;
  8019c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019ca:	eb 24                	jmp    8019f0 <read+0x8a>
	}
	if (!dev->dev_read)
  8019cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019cf:	8b 52 08             	mov    0x8(%edx),%edx
  8019d2:	85 d2                	test   %edx,%edx
  8019d4:	74 15                	je     8019eb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019e4:	89 04 24             	mov    %eax,(%esp)
  8019e7:	ff d2                	call   *%edx
  8019e9:	eb 05                	jmp    8019f0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8019f0:	83 c4 24             	add    $0x24,%esp
  8019f3:	5b                   	pop    %ebx
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	57                   	push   %edi
  8019fa:	56                   	push   %esi
  8019fb:	53                   	push   %ebx
  8019fc:	83 ec 1c             	sub    $0x1c,%esp
  8019ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a02:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a05:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a0a:	eb 23                	jmp    801a2f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a0c:	89 f0                	mov    %esi,%eax
  801a0e:	29 d8                	sub    %ebx,%eax
  801a10:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a17:	01 d8                	add    %ebx,%eax
  801a19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1d:	89 3c 24             	mov    %edi,(%esp)
  801a20:	e8 41 ff ff ff       	call   801966 <read>
		if (m < 0)
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 10                	js     801a39 <readn+0x43>
			return m;
		if (m == 0)
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	74 0a                	je     801a37 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a2d:	01 c3                	add    %eax,%ebx
  801a2f:	39 f3                	cmp    %esi,%ebx
  801a31:	72 d9                	jb     801a0c <readn+0x16>
  801a33:	89 d8                	mov    %ebx,%eax
  801a35:	eb 02                	jmp    801a39 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801a37:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a39:	83 c4 1c             	add    $0x1c,%esp
  801a3c:	5b                   	pop    %ebx
  801a3d:	5e                   	pop    %esi
  801a3e:	5f                   	pop    %edi
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    

00801a41 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	53                   	push   %ebx
  801a45:	83 ec 24             	sub    $0x24,%esp
  801a48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a52:	89 1c 24             	mov    %ebx,(%esp)
  801a55:	e8 70 fc ff ff       	call   8016ca <fd_lookup>
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 68                	js     801ac6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a68:	8b 00                	mov    (%eax),%eax
  801a6a:	89 04 24             	mov    %eax,(%esp)
  801a6d:	e8 ae fc ff ff       	call   801720 <dev_lookup>
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 50                	js     801ac6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a79:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a7d:	75 23                	jne    801aa2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a7f:	a1 04 50 80 00       	mov    0x805004,%eax
  801a84:	8b 40 48             	mov    0x48(%eax),%eax
  801a87:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8f:	c7 04 24 99 32 80 00 	movl   $0x803299,(%esp)
  801a96:	e8 01 ec ff ff       	call   80069c <cprintf>
		return -E_INVAL;
  801a9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801aa0:	eb 24                	jmp    801ac6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801aa2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa5:	8b 52 0c             	mov    0xc(%edx),%edx
  801aa8:	85 d2                	test   %edx,%edx
  801aaa:	74 15                	je     801ac1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801aac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801aaf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aba:	89 04 24             	mov    %eax,(%esp)
  801abd:	ff d2                	call   *%edx
  801abf:	eb 05                	jmp    801ac6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801ac1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801ac6:	83 c4 24             	add    $0x24,%esp
  801ac9:	5b                   	pop    %ebx
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <seek>:

int
seek(int fdnum, off_t offset)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  801adc:	89 04 24             	mov    %eax,(%esp)
  801adf:	e8 e6 fb ff ff       	call   8016ca <fd_lookup>
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 0e                	js     801af6 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801ae8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801aeb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801af1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	53                   	push   %ebx
  801afc:	83 ec 24             	sub    $0x24,%esp
  801aff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b09:	89 1c 24             	mov    %ebx,(%esp)
  801b0c:	e8 b9 fb ff ff       	call   8016ca <fd_lookup>
  801b11:	85 c0                	test   %eax,%eax
  801b13:	78 61                	js     801b76 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1f:	8b 00                	mov    (%eax),%eax
  801b21:	89 04 24             	mov    %eax,(%esp)
  801b24:	e8 f7 fb ff ff       	call   801720 <dev_lookup>
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 49                	js     801b76 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b30:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b34:	75 23                	jne    801b59 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b36:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b3b:	8b 40 48             	mov    0x48(%eax),%eax
  801b3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b46:	c7 04 24 5c 32 80 00 	movl   $0x80325c,(%esp)
  801b4d:	e8 4a eb ff ff       	call   80069c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b57:	eb 1d                	jmp    801b76 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801b59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b5c:	8b 52 18             	mov    0x18(%edx),%edx
  801b5f:	85 d2                	test   %edx,%edx
  801b61:	74 0e                	je     801b71 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b66:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b6a:	89 04 24             	mov    %eax,(%esp)
  801b6d:	ff d2                	call   *%edx
  801b6f:	eb 05                	jmp    801b76 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b71:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b76:	83 c4 24             	add    $0x24,%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	53                   	push   %ebx
  801b80:	83 ec 24             	sub    $0x24,%esp
  801b83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b90:	89 04 24             	mov    %eax,(%esp)
  801b93:	e8 32 fb ff ff       	call   8016ca <fd_lookup>
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	78 52                	js     801bee <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba6:	8b 00                	mov    (%eax),%eax
  801ba8:	89 04 24             	mov    %eax,(%esp)
  801bab:	e8 70 fb ff ff       	call   801720 <dev_lookup>
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	78 3a                	js     801bee <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801bbb:	74 2c                	je     801be9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801bbd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801bc0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801bc7:	00 00 00 
	stat->st_isdir = 0;
  801bca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bd1:	00 00 00 
	stat->st_dev = dev;
  801bd4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801bda:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bde:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801be1:	89 14 24             	mov    %edx,(%esp)
  801be4:	ff 50 14             	call   *0x14(%eax)
  801be7:	eb 05                	jmp    801bee <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801be9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bee:	83 c4 24             	add    $0x24,%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5d                   	pop    %ebp
  801bf3:	c3                   	ret    

00801bf4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	56                   	push   %esi
  801bf8:	53                   	push   %ebx
  801bf9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bfc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c03:	00 
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	89 04 24             	mov    %eax,(%esp)
  801c0a:	e8 fe 01 00 00       	call   801e0d <open>
  801c0f:	89 c3                	mov    %eax,%ebx
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 1b                	js     801c30 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1c:	89 1c 24             	mov    %ebx,(%esp)
  801c1f:	e8 58 ff ff ff       	call   801b7c <fstat>
  801c24:	89 c6                	mov    %eax,%esi
	close(fd);
  801c26:	89 1c 24             	mov    %ebx,(%esp)
  801c29:	e8 d4 fb ff ff       	call   801802 <close>
	return r;
  801c2e:	89 f3                	mov    %esi,%ebx
}
  801c30:	89 d8                	mov    %ebx,%eax
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	5b                   	pop    %ebx
  801c36:	5e                   	pop    %esi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    
  801c39:	00 00                	add    %al,(%eax)
	...

00801c3c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	83 ec 10             	sub    $0x10,%esp
  801c44:	89 c3                	mov    %eax,%ebx
  801c46:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c48:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801c4f:	75 11                	jne    801c62 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c58:	e8 46 0d 00 00       	call   8029a3 <ipc_find_env>
  801c5d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c62:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c69:	00 
  801c6a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c71:	00 
  801c72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c76:	a1 00 50 80 00       	mov    0x805000,%eax
  801c7b:	89 04 24             	mov    %eax,(%esp)
  801c7e:	e8 b6 0c 00 00       	call   802939 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c8a:	00 
  801c8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c96:	e8 35 0c 00 00       	call   8028d0 <ipc_recv>
}
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	5b                   	pop    %ebx
  801c9f:	5e                   	pop    %esi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cab:	8b 40 0c             	mov    0xc(%eax),%eax
  801cae:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb6:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc0:	b8 02 00 00 00       	mov    $0x2,%eax
  801cc5:	e8 72 ff ff ff       	call   801c3c <fsipc>
}
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd8:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce2:	b8 06 00 00 00       	mov    $0x6,%eax
  801ce7:	e8 50 ff ff ff       	call   801c3c <fsipc>
}
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	53                   	push   %ebx
  801cf2:	83 ec 14             	sub    $0x14,%esp
  801cf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	8b 40 0c             	mov    0xc(%eax),%eax
  801cfe:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d03:	ba 00 00 00 00       	mov    $0x0,%edx
  801d08:	b8 05 00 00 00       	mov    $0x5,%eax
  801d0d:	e8 2a ff ff ff       	call   801c3c <fsipc>
  801d12:	85 c0                	test   %eax,%eax
  801d14:	78 2b                	js     801d41 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d16:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d1d:	00 
  801d1e:	89 1c 24             	mov    %ebx,(%esp)
  801d21:	e8 21 ef ff ff       	call   800c47 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d26:	a1 80 60 80 00       	mov    0x806080,%eax
  801d2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d31:	a1 84 60 80 00       	mov    0x806084,%eax
  801d36:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d41:	83 c4 14             	add    $0x14,%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5d                   	pop    %ebp
  801d46:	c3                   	ret    

00801d47 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801d4d:	c7 44 24 08 c8 32 80 	movl   $0x8032c8,0x8(%esp)
  801d54:	00 
  801d55:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801d5c:	00 
  801d5d:	c7 04 24 e6 32 80 00 	movl   $0x8032e6,(%esp)
  801d64:	e8 3b e8 ff ff       	call   8005a4 <_panic>

00801d69 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
  801d6e:	83 ec 10             	sub    $0x10,%esp
  801d71:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d74:	8b 45 08             	mov    0x8(%ebp),%eax
  801d77:	8b 40 0c             	mov    0xc(%eax),%eax
  801d7a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801d7f:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d85:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8a:	b8 03 00 00 00       	mov    $0x3,%eax
  801d8f:	e8 a8 fe ff ff       	call   801c3c <fsipc>
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	85 c0                	test   %eax,%eax
  801d98:	78 6a                	js     801e04 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801d9a:	39 c6                	cmp    %eax,%esi
  801d9c:	73 24                	jae    801dc2 <devfile_read+0x59>
  801d9e:	c7 44 24 0c f1 32 80 	movl   $0x8032f1,0xc(%esp)
  801da5:	00 
  801da6:	c7 44 24 08 f8 32 80 	movl   $0x8032f8,0x8(%esp)
  801dad:	00 
  801dae:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801db5:	00 
  801db6:	c7 04 24 e6 32 80 00 	movl   $0x8032e6,(%esp)
  801dbd:	e8 e2 e7 ff ff       	call   8005a4 <_panic>
	assert(r <= PGSIZE);
  801dc2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801dc7:	7e 24                	jle    801ded <devfile_read+0x84>
  801dc9:	c7 44 24 0c 0d 33 80 	movl   $0x80330d,0xc(%esp)
  801dd0:	00 
  801dd1:	c7 44 24 08 f8 32 80 	movl   $0x8032f8,0x8(%esp)
  801dd8:	00 
  801dd9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801de0:	00 
  801de1:	c7 04 24 e6 32 80 00 	movl   $0x8032e6,(%esp)
  801de8:	e8 b7 e7 ff ff       	call   8005a4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ded:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df1:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801df8:	00 
  801df9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfc:	89 04 24             	mov    %eax,(%esp)
  801dff:	e8 bc ef ff ff       	call   800dc0 <memmove>
	return r;
}
  801e04:	89 d8                	mov    %ebx,%eax
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	5b                   	pop    %ebx
  801e0a:	5e                   	pop    %esi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    

00801e0d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	56                   	push   %esi
  801e11:	53                   	push   %ebx
  801e12:	83 ec 20             	sub    $0x20,%esp
  801e15:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e18:	89 34 24             	mov    %esi,(%esp)
  801e1b:	e8 f4 ed ff ff       	call   800c14 <strlen>
  801e20:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e25:	7f 60                	jg     801e87 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2a:	89 04 24             	mov    %eax,(%esp)
  801e2d:	e8 45 f8 ff ff       	call   801677 <fd_alloc>
  801e32:	89 c3                	mov    %eax,%ebx
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 54                	js     801e8c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e38:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e3c:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e43:	e8 ff ed ff ff       	call   800c47 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4b:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e53:	b8 01 00 00 00       	mov    $0x1,%eax
  801e58:	e8 df fd ff ff       	call   801c3c <fsipc>
  801e5d:	89 c3                	mov    %eax,%ebx
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	79 15                	jns    801e78 <open+0x6b>
		fd_close(fd, 0);
  801e63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e6a:	00 
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 04 f9 ff ff       	call   80177a <fd_close>
		return r;
  801e76:	eb 14                	jmp    801e8c <open+0x7f>
	}

	return fd2num(fd);
  801e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7b:	89 04 24             	mov    %eax,(%esp)
  801e7e:	e8 c9 f7 ff ff       	call   80164c <fd2num>
  801e83:	89 c3                	mov    %eax,%ebx
  801e85:	eb 05                	jmp    801e8c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e87:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e8c:	89 d8                	mov    %ebx,%eax
  801e8e:	83 c4 20             	add    $0x20,%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ea5:	e8 92 fd ff ff       	call   801c3c <fsipc>
}
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	57                   	push   %edi
  801eb0:	56                   	push   %esi
  801eb1:	53                   	push   %ebx
  801eb2:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801eb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ebf:	00 
  801ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec3:	89 04 24             	mov    %eax,(%esp)
  801ec6:	e8 42 ff ff ff       	call   801e0d <open>
  801ecb:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	0f 88 05 05 00 00    	js     8023de <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801ed9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801ee0:	00 
  801ee1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801ee7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eeb:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ef1:	89 04 24             	mov    %eax,(%esp)
  801ef4:	e8 fd fa ff ff       	call   8019f6 <readn>
  801ef9:	3d 00 02 00 00       	cmp    $0x200,%eax
  801efe:	75 0c                	jne    801f0c <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801f00:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801f07:	45 4c 46 
  801f0a:	74 3b                	je     801f47 <spawn+0x9b>
		close(fd);
  801f0c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801f12:	89 04 24             	mov    %eax,(%esp)
  801f15:	e8 e8 f8 ff ff       	call   801802 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801f1a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801f21:	46 
  801f22:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801f28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2c:	c7 04 24 19 33 80 00 	movl   $0x803319,(%esp)
  801f33:	e8 64 e7 ff ff       	call   80069c <cprintf>
		return -E_NOT_EXEC;
  801f38:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801f3f:	ff ff ff 
  801f42:	e9 a3 04 00 00       	jmp    8023ea <spawn+0x53e>
  801f47:	ba 07 00 00 00       	mov    $0x7,%edx
  801f4c:	89 d0                	mov    %edx,%eax
  801f4e:	cd 30                	int    $0x30
  801f50:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801f56:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	0f 88 86 04 00 00    	js     8023ea <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801f64:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801f70:	c1 e0 07             	shl    $0x7,%eax
  801f73:	29 d0                	sub    %edx,%eax
  801f75:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801f7b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801f81:	b9 11 00 00 00       	mov    $0x11,%ecx
  801f86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801f88:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801f8e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801f94:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801f99:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fa1:	eb 0d                	jmp    801fb0 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801fa3:	89 04 24             	mov    %eax,(%esp)
  801fa6:	e8 69 ec ff ff       	call   800c14 <strlen>
  801fab:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801faf:	46                   	inc    %esi
  801fb0:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801fb2:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801fb9:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	75 e3                	jne    801fa3 <spawn+0xf7>
  801fc0:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801fc6:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801fcc:	bf 00 10 40 00       	mov    $0x401000,%edi
  801fd1:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801fd3:	89 f8                	mov    %edi,%eax
  801fd5:	83 e0 fc             	and    $0xfffffffc,%eax
  801fd8:	f7 d2                	not    %edx
  801fda:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801fdd:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801fe3:	89 d0                	mov    %edx,%eax
  801fe5:	83 e8 08             	sub    $0x8,%eax
  801fe8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801fed:	0f 86 08 04 00 00    	jbe    8023fb <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ff3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ffa:	00 
  801ffb:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802002:	00 
  802003:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80200a:	e8 2a f0 ff ff       	call   801039 <sys_page_alloc>
  80200f:	85 c0                	test   %eax,%eax
  802011:	0f 88 e9 03 00 00    	js     802400 <spawn+0x554>
  802017:	bb 00 00 00 00       	mov    $0x0,%ebx
  80201c:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  802022:	8b 75 0c             	mov    0xc(%ebp),%esi
  802025:	eb 2e                	jmp    802055 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802027:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80202d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802033:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  802036:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802039:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203d:	89 3c 24             	mov    %edi,(%esp)
  802040:	e8 02 ec ff ff       	call   800c47 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802045:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802048:	89 04 24             	mov    %eax,(%esp)
  80204b:	e8 c4 eb ff ff       	call   800c14 <strlen>
  802050:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802054:	43                   	inc    %ebx
  802055:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80205b:	7c ca                	jl     802027 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80205d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802063:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802069:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802070:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802076:	74 24                	je     80209c <spawn+0x1f0>
  802078:	c7 44 24 0c 90 33 80 	movl   $0x803390,0xc(%esp)
  80207f:	00 
  802080:	c7 44 24 08 f8 32 80 	movl   $0x8032f8,0x8(%esp)
  802087:	00 
  802088:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  80208f:	00 
  802090:	c7 04 24 33 33 80 00 	movl   $0x803333,(%esp)
  802097:	e8 08 e5 ff ff       	call   8005a4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80209c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8020a2:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8020a7:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8020ad:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8020b0:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8020b6:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8020b9:	89 d0                	mov    %edx,%eax
  8020bb:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8020c0:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8020c6:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8020cd:	00 
  8020ce:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8020d5:	ee 
  8020d6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8020dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020e0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8020e7:	00 
  8020e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ef:	e8 99 ef ff ff       	call   80108d <sys_page_map>
  8020f4:	89 c3                	mov    %eax,%ebx
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	78 1a                	js     802114 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8020fa:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802101:	00 
  802102:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802109:	e8 d2 ef ff ff       	call   8010e0 <sys_page_unmap>
  80210e:	89 c3                	mov    %eax,%ebx
  802110:	85 c0                	test   %eax,%eax
  802112:	79 1f                	jns    802133 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802114:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80211b:	00 
  80211c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802123:	e8 b8 ef ff ff       	call   8010e0 <sys_page_unmap>
	return r;
  802128:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  80212e:	e9 b7 02 00 00       	jmp    8023ea <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802133:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  802139:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  80213f:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802145:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80214c:	00 00 00 
  80214f:	e9 bb 01 00 00       	jmp    80230f <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  802154:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80215a:	83 38 01             	cmpl   $0x1,(%eax)
  80215d:	0f 85 9f 01 00 00    	jne    802302 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802163:	89 c2                	mov    %eax,%edx
  802165:	8b 40 18             	mov    0x18(%eax),%eax
  802168:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  80216b:	83 f8 01             	cmp    $0x1,%eax
  80216e:	19 c0                	sbb    %eax,%eax
  802170:	83 e0 fe             	and    $0xfffffffe,%eax
  802173:	83 c0 07             	add    $0x7,%eax
  802176:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80217c:	8b 52 04             	mov    0x4(%edx),%edx
  80217f:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802185:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80218b:	8b 40 10             	mov    0x10(%eax),%eax
  80218e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802194:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  80219a:	8b 52 14             	mov    0x14(%edx),%edx
  80219d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  8021a3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8021a9:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8021ac:	89 f8                	mov    %edi,%eax
  8021ae:	25 ff 0f 00 00       	and    $0xfff,%eax
  8021b3:	74 16                	je     8021cb <spawn+0x31f>
		va -= i;
  8021b5:	29 c7                	sub    %eax,%edi
		memsz += i;
  8021b7:	01 c2                	add    %eax,%edx
  8021b9:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  8021bf:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  8021c5:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8021cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021d0:	e9 1f 01 00 00       	jmp    8022f4 <spawn+0x448>
		if (i >= filesz) {
  8021d5:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8021db:	77 2b                	ja     802208 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8021dd:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8021e3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021eb:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8021f1:	89 04 24             	mov    %eax,(%esp)
  8021f4:	e8 40 ee ff ff       	call   801039 <sys_page_alloc>
  8021f9:	85 c0                	test   %eax,%eax
  8021fb:	0f 89 e7 00 00 00    	jns    8022e8 <spawn+0x43c>
  802201:	89 c6                	mov    %eax,%esi
  802203:	e9 b2 01 00 00       	jmp    8023ba <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802208:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80220f:	00 
  802210:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802217:	00 
  802218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80221f:	e8 15 ee ff ff       	call   801039 <sys_page_alloc>
  802224:	85 c0                	test   %eax,%eax
  802226:	0f 88 84 01 00 00    	js     8023b0 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80222c:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802232:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802234:	89 44 24 04          	mov    %eax,0x4(%esp)
  802238:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80223e:	89 04 24             	mov    %eax,(%esp)
  802241:	e8 86 f8 ff ff       	call   801acc <seek>
  802246:	85 c0                	test   %eax,%eax
  802248:	0f 88 66 01 00 00    	js     8023b4 <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80224e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802254:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802256:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80225b:	76 05                	jbe    802262 <spawn+0x3b6>
  80225d:	b8 00 10 00 00       	mov    $0x1000,%eax
  802262:	89 44 24 08          	mov    %eax,0x8(%esp)
  802266:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80226d:	00 
  80226e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802274:	89 04 24             	mov    %eax,(%esp)
  802277:	e8 7a f7 ff ff       	call   8019f6 <readn>
  80227c:	85 c0                	test   %eax,%eax
  80227e:	0f 88 34 01 00 00    	js     8023b8 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802284:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80228a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80228e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802292:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802298:	89 44 24 08          	mov    %eax,0x8(%esp)
  80229c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022a3:	00 
  8022a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ab:	e8 dd ed ff ff       	call   80108d <sys_page_map>
  8022b0:	85 c0                	test   %eax,%eax
  8022b2:	79 20                	jns    8022d4 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  8022b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022b8:	c7 44 24 08 3f 33 80 	movl   $0x80333f,0x8(%esp)
  8022bf:	00 
  8022c0:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  8022c7:	00 
  8022c8:	c7 04 24 33 33 80 00 	movl   $0x803333,(%esp)
  8022cf:	e8 d0 e2 ff ff       	call   8005a4 <_panic>
			sys_page_unmap(0, UTEMP);
  8022d4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8022db:	00 
  8022dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e3:	e8 f8 ed ff ff       	call   8010e0 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8022e8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8022ee:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8022f4:	89 de                	mov    %ebx,%esi
  8022f6:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8022fc:	0f 87 d3 fe ff ff    	ja     8021d5 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802302:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802308:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  80230f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802316:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  80231c:	0f 8c 32 fe ff ff    	jl     802154 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802322:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802328:	89 04 24             	mov    %eax,(%esp)
  80232b:	e8 d2 f4 ff ff       	call   801802 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802330:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802337:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80233a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802340:	89 44 24 04          	mov    %eax,0x4(%esp)
  802344:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80234a:	89 04 24             	mov    %eax,(%esp)
  80234d:	e8 34 ee ff ff       	call   801186 <sys_env_set_trapframe>
  802352:	85 c0                	test   %eax,%eax
  802354:	79 20                	jns    802376 <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  802356:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80235a:	c7 44 24 08 5c 33 80 	movl   $0x80335c,0x8(%esp)
  802361:	00 
  802362:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  802369:	00 
  80236a:	c7 04 24 33 33 80 00 	movl   $0x803333,(%esp)
  802371:	e8 2e e2 ff ff       	call   8005a4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802376:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80237d:	00 
  80237e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802384:	89 04 24             	mov    %eax,(%esp)
  802387:	e8 a7 ed ff ff       	call   801133 <sys_env_set_status>
  80238c:	85 c0                	test   %eax,%eax
  80238e:	79 5a                	jns    8023ea <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  802390:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802394:	c7 44 24 08 76 33 80 	movl   $0x803376,0x8(%esp)
  80239b:	00 
  80239c:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8023a3:	00 
  8023a4:	c7 04 24 33 33 80 00 	movl   $0x803333,(%esp)
  8023ab:	e8 f4 e1 ff ff       	call   8005a4 <_panic>
  8023b0:	89 c6                	mov    %eax,%esi
  8023b2:	eb 06                	jmp    8023ba <spawn+0x50e>
  8023b4:	89 c6                	mov    %eax,%esi
  8023b6:	eb 02                	jmp    8023ba <spawn+0x50e>
  8023b8:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  8023ba:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8023c0:	89 04 24             	mov    %eax,(%esp)
  8023c3:	e8 e1 eb ff ff       	call   800fa9 <sys_env_destroy>
	close(fd);
  8023c8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8023ce:	89 04 24             	mov    %eax,(%esp)
  8023d1:	e8 2c f4 ff ff       	call   801802 <close>
	return r;
  8023d6:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  8023dc:	eb 0c                	jmp    8023ea <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8023de:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8023e4:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8023ea:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8023f0:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  8023f6:	5b                   	pop    %ebx
  8023f7:	5e                   	pop    %esi
  8023f8:	5f                   	pop    %edi
  8023f9:	5d                   	pop    %ebp
  8023fa:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8023fb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802400:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802406:	eb e2                	jmp    8023ea <spawn+0x53e>

00802408 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802408:	55                   	push   %ebp
  802409:	89 e5                	mov    %esp,%ebp
  80240b:	57                   	push   %edi
  80240c:	56                   	push   %esi
  80240d:	53                   	push   %ebx
  80240e:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802411:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802414:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802419:	eb 03                	jmp    80241e <spawnl+0x16>
		argc++;
  80241b:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80241c:	89 d0                	mov    %edx,%eax
  80241e:	8d 50 04             	lea    0x4(%eax),%edx
  802421:	83 38 00             	cmpl   $0x0,(%eax)
  802424:	75 f5                	jne    80241b <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802426:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  80242d:	83 e0 f0             	and    $0xfffffff0,%eax
  802430:	29 c4                	sub    %eax,%esp
  802432:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802436:	83 e7 f0             	and    $0xfffffff0,%edi
  802439:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  80243b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80243e:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802440:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802447:	00 

	va_start(vl, arg0);
  802448:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  80244b:	b8 00 00 00 00       	mov    $0x0,%eax
  802450:	eb 09                	jmp    80245b <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802452:	40                   	inc    %eax
  802453:	8b 1a                	mov    (%edx),%ebx
  802455:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802458:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80245b:	39 c8                	cmp    %ecx,%eax
  80245d:	75 f3                	jne    802452 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80245f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802463:	8b 45 08             	mov    0x8(%ebp),%eax
  802466:	89 04 24             	mov    %eax,(%esp)
  802469:	e8 3e fa ff ff       	call   801eac <spawn>
}
  80246e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802471:	5b                   	pop    %ebx
  802472:	5e                   	pop    %esi
  802473:	5f                   	pop    %edi
  802474:	5d                   	pop    %ebp
  802475:	c3                   	ret    
	...

00802478 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802478:	55                   	push   %ebp
  802479:	89 e5                	mov    %esp,%ebp
  80247b:	56                   	push   %esi
  80247c:	53                   	push   %ebx
  80247d:	83 ec 10             	sub    $0x10,%esp
  802480:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802483:	8b 45 08             	mov    0x8(%ebp),%eax
  802486:	89 04 24             	mov    %eax,(%esp)
  802489:	e8 ce f1 ff ff       	call   80165c <fd2data>
  80248e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802490:	c7 44 24 04 b8 33 80 	movl   $0x8033b8,0x4(%esp)
  802497:	00 
  802498:	89 34 24             	mov    %esi,(%esp)
  80249b:	e8 a7 e7 ff ff       	call   800c47 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8024a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8024a3:	2b 03                	sub    (%ebx),%eax
  8024a5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8024ab:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8024b2:	00 00 00 
	stat->st_dev = &devpipe;
  8024b5:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  8024bc:	40 80 00 
	return 0;
}
  8024bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8024c4:	83 c4 10             	add    $0x10,%esp
  8024c7:	5b                   	pop    %ebx
  8024c8:	5e                   	pop    %esi
  8024c9:	5d                   	pop    %ebp
  8024ca:	c3                   	ret    

008024cb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8024cb:	55                   	push   %ebp
  8024cc:	89 e5                	mov    %esp,%ebp
  8024ce:	53                   	push   %ebx
  8024cf:	83 ec 14             	sub    $0x14,%esp
  8024d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8024d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024e0:	e8 fb eb ff ff       	call   8010e0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8024e5:	89 1c 24             	mov    %ebx,(%esp)
  8024e8:	e8 6f f1 ff ff       	call   80165c <fd2data>
  8024ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f8:	e8 e3 eb ff ff       	call   8010e0 <sys_page_unmap>
}
  8024fd:	83 c4 14             	add    $0x14,%esp
  802500:	5b                   	pop    %ebx
  802501:	5d                   	pop    %ebp
  802502:	c3                   	ret    

00802503 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802503:	55                   	push   %ebp
  802504:	89 e5                	mov    %esp,%ebp
  802506:	57                   	push   %edi
  802507:	56                   	push   %esi
  802508:	53                   	push   %ebx
  802509:	83 ec 2c             	sub    $0x2c,%esp
  80250c:	89 c7                	mov    %eax,%edi
  80250e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802511:	a1 04 50 80 00       	mov    0x805004,%eax
  802516:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802519:	89 3c 24             	mov    %edi,(%esp)
  80251c:	e8 c7 04 00 00       	call   8029e8 <pageref>
  802521:	89 c6                	mov    %eax,%esi
  802523:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802526:	89 04 24             	mov    %eax,(%esp)
  802529:	e8 ba 04 00 00       	call   8029e8 <pageref>
  80252e:	39 c6                	cmp    %eax,%esi
  802530:	0f 94 c0             	sete   %al
  802533:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802536:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80253c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80253f:	39 cb                	cmp    %ecx,%ebx
  802541:	75 08                	jne    80254b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802543:	83 c4 2c             	add    $0x2c,%esp
  802546:	5b                   	pop    %ebx
  802547:	5e                   	pop    %esi
  802548:	5f                   	pop    %edi
  802549:	5d                   	pop    %ebp
  80254a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80254b:	83 f8 01             	cmp    $0x1,%eax
  80254e:	75 c1                	jne    802511 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802550:	8b 42 58             	mov    0x58(%edx),%eax
  802553:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80255a:	00 
  80255b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80255f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802563:	c7 04 24 bf 33 80 00 	movl   $0x8033bf,(%esp)
  80256a:	e8 2d e1 ff ff       	call   80069c <cprintf>
  80256f:	eb a0                	jmp    802511 <_pipeisclosed+0xe>

00802571 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802571:	55                   	push   %ebp
  802572:	89 e5                	mov    %esp,%ebp
  802574:	57                   	push   %edi
  802575:	56                   	push   %esi
  802576:	53                   	push   %ebx
  802577:	83 ec 1c             	sub    $0x1c,%esp
  80257a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80257d:	89 34 24             	mov    %esi,(%esp)
  802580:	e8 d7 f0 ff ff       	call   80165c <fd2data>
  802585:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802587:	bf 00 00 00 00       	mov    $0x0,%edi
  80258c:	eb 3c                	jmp    8025ca <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80258e:	89 da                	mov    %ebx,%edx
  802590:	89 f0                	mov    %esi,%eax
  802592:	e8 6c ff ff ff       	call   802503 <_pipeisclosed>
  802597:	85 c0                	test   %eax,%eax
  802599:	75 38                	jne    8025d3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80259b:	e8 7a ea ff ff       	call   80101a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8025a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8025a3:	8b 13                	mov    (%ebx),%edx
  8025a5:	83 c2 20             	add    $0x20,%edx
  8025a8:	39 d0                	cmp    %edx,%eax
  8025aa:	73 e2                	jae    80258e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8025ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025af:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8025b2:	89 c2                	mov    %eax,%edx
  8025b4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8025ba:	79 05                	jns    8025c1 <devpipe_write+0x50>
  8025bc:	4a                   	dec    %edx
  8025bd:	83 ca e0             	or     $0xffffffe0,%edx
  8025c0:	42                   	inc    %edx
  8025c1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8025c5:	40                   	inc    %eax
  8025c6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025c9:	47                   	inc    %edi
  8025ca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025cd:	75 d1                	jne    8025a0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8025cf:	89 f8                	mov    %edi,%eax
  8025d1:	eb 05                	jmp    8025d8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025d3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8025d8:	83 c4 1c             	add    $0x1c,%esp
  8025db:	5b                   	pop    %ebx
  8025dc:	5e                   	pop    %esi
  8025dd:	5f                   	pop    %edi
  8025de:	5d                   	pop    %ebp
  8025df:	c3                   	ret    

008025e0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025e0:	55                   	push   %ebp
  8025e1:	89 e5                	mov    %esp,%ebp
  8025e3:	57                   	push   %edi
  8025e4:	56                   	push   %esi
  8025e5:	53                   	push   %ebx
  8025e6:	83 ec 1c             	sub    $0x1c,%esp
  8025e9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8025ec:	89 3c 24             	mov    %edi,(%esp)
  8025ef:	e8 68 f0 ff ff       	call   80165c <fd2data>
  8025f4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025f6:	be 00 00 00 00       	mov    $0x0,%esi
  8025fb:	eb 3a                	jmp    802637 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8025fd:	85 f6                	test   %esi,%esi
  8025ff:	74 04                	je     802605 <devpipe_read+0x25>
				return i;
  802601:	89 f0                	mov    %esi,%eax
  802603:	eb 40                	jmp    802645 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802605:	89 da                	mov    %ebx,%edx
  802607:	89 f8                	mov    %edi,%eax
  802609:	e8 f5 fe ff ff       	call   802503 <_pipeisclosed>
  80260e:	85 c0                	test   %eax,%eax
  802610:	75 2e                	jne    802640 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802612:	e8 03 ea ff ff       	call   80101a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802617:	8b 03                	mov    (%ebx),%eax
  802619:	3b 43 04             	cmp    0x4(%ebx),%eax
  80261c:	74 df                	je     8025fd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80261e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802623:	79 05                	jns    80262a <devpipe_read+0x4a>
  802625:	48                   	dec    %eax
  802626:	83 c8 e0             	or     $0xffffffe0,%eax
  802629:	40                   	inc    %eax
  80262a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80262e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802631:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802634:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802636:	46                   	inc    %esi
  802637:	3b 75 10             	cmp    0x10(%ebp),%esi
  80263a:	75 db                	jne    802617 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80263c:	89 f0                	mov    %esi,%eax
  80263e:	eb 05                	jmp    802645 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802640:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802645:	83 c4 1c             	add    $0x1c,%esp
  802648:	5b                   	pop    %ebx
  802649:	5e                   	pop    %esi
  80264a:	5f                   	pop    %edi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    

0080264d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80264d:	55                   	push   %ebp
  80264e:	89 e5                	mov    %esp,%ebp
  802650:	57                   	push   %edi
  802651:	56                   	push   %esi
  802652:	53                   	push   %ebx
  802653:	83 ec 3c             	sub    $0x3c,%esp
  802656:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802659:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80265c:	89 04 24             	mov    %eax,(%esp)
  80265f:	e8 13 f0 ff ff       	call   801677 <fd_alloc>
  802664:	89 c3                	mov    %eax,%ebx
  802666:	85 c0                	test   %eax,%eax
  802668:	0f 88 45 01 00 00    	js     8027b3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80266e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802675:	00 
  802676:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802679:	89 44 24 04          	mov    %eax,0x4(%esp)
  80267d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802684:	e8 b0 e9 ff ff       	call   801039 <sys_page_alloc>
  802689:	89 c3                	mov    %eax,%ebx
  80268b:	85 c0                	test   %eax,%eax
  80268d:	0f 88 20 01 00 00    	js     8027b3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802693:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802696:	89 04 24             	mov    %eax,(%esp)
  802699:	e8 d9 ef ff ff       	call   801677 <fd_alloc>
  80269e:	89 c3                	mov    %eax,%ebx
  8026a0:	85 c0                	test   %eax,%eax
  8026a2:	0f 88 f8 00 00 00    	js     8027a0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026a8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026af:	00 
  8026b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026be:	e8 76 e9 ff ff       	call   801039 <sys_page_alloc>
  8026c3:	89 c3                	mov    %eax,%ebx
  8026c5:	85 c0                	test   %eax,%eax
  8026c7:	0f 88 d3 00 00 00    	js     8027a0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8026cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026d0:	89 04 24             	mov    %eax,(%esp)
  8026d3:	e8 84 ef ff ff       	call   80165c <fd2data>
  8026d8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026da:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026e1:	00 
  8026e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026ed:	e8 47 e9 ff ff       	call   801039 <sys_page_alloc>
  8026f2:	89 c3                	mov    %eax,%ebx
  8026f4:	85 c0                	test   %eax,%eax
  8026f6:	0f 88 91 00 00 00    	js     80278d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026ff:	89 04 24             	mov    %eax,(%esp)
  802702:	e8 55 ef ff ff       	call   80165c <fd2data>
  802707:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80270e:	00 
  80270f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802713:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80271a:	00 
  80271b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80271f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802726:	e8 62 e9 ff ff       	call   80108d <sys_page_map>
  80272b:	89 c3                	mov    %eax,%ebx
  80272d:	85 c0                	test   %eax,%eax
  80272f:	78 4c                	js     80277d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802731:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802737:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80273a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80273c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80273f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802746:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80274c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80274f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802751:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802754:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80275b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80275e:	89 04 24             	mov    %eax,(%esp)
  802761:	e8 e6 ee ff ff       	call   80164c <fd2num>
  802766:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802768:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80276b:	89 04 24             	mov    %eax,(%esp)
  80276e:	e8 d9 ee ff ff       	call   80164c <fd2num>
  802773:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802776:	bb 00 00 00 00       	mov    $0x0,%ebx
  80277b:	eb 36                	jmp    8027b3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80277d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802781:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802788:	e8 53 e9 ff ff       	call   8010e0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80278d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802790:	89 44 24 04          	mov    %eax,0x4(%esp)
  802794:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80279b:	e8 40 e9 ff ff       	call   8010e0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8027a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027ae:	e8 2d e9 ff ff       	call   8010e0 <sys_page_unmap>
    err:
	return r;
}
  8027b3:	89 d8                	mov    %ebx,%eax
  8027b5:	83 c4 3c             	add    $0x3c,%esp
  8027b8:	5b                   	pop    %ebx
  8027b9:	5e                   	pop    %esi
  8027ba:	5f                   	pop    %edi
  8027bb:	5d                   	pop    %ebp
  8027bc:	c3                   	ret    

008027bd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8027bd:	55                   	push   %ebp
  8027be:	89 e5                	mov    %esp,%ebp
  8027c0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8027cd:	89 04 24             	mov    %eax,(%esp)
  8027d0:	e8 f5 ee ff ff       	call   8016ca <fd_lookup>
  8027d5:	85 c0                	test   %eax,%eax
  8027d7:	78 15                	js     8027ee <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8027d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027dc:	89 04 24             	mov    %eax,(%esp)
  8027df:	e8 78 ee ff ff       	call   80165c <fd2data>
	return _pipeisclosed(fd, p);
  8027e4:	89 c2                	mov    %eax,%edx
  8027e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027e9:	e8 15 fd ff ff       	call   802503 <_pipeisclosed>
}
  8027ee:	c9                   	leave  
  8027ef:	c3                   	ret    

008027f0 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8027f0:	55                   	push   %ebp
  8027f1:	89 e5                	mov    %esp,%ebp
  8027f3:	56                   	push   %esi
  8027f4:	53                   	push   %ebx
  8027f5:	83 ec 10             	sub    $0x10,%esp
  8027f8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8027fb:	85 f6                	test   %esi,%esi
  8027fd:	75 24                	jne    802823 <wait+0x33>
  8027ff:	c7 44 24 0c d7 33 80 	movl   $0x8033d7,0xc(%esp)
  802806:	00 
  802807:	c7 44 24 08 f8 32 80 	movl   $0x8032f8,0x8(%esp)
  80280e:	00 
  80280f:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802816:	00 
  802817:	c7 04 24 e2 33 80 00 	movl   $0x8033e2,(%esp)
  80281e:	e8 81 dd ff ff       	call   8005a4 <_panic>
	e = &envs[ENVX(envid)];
  802823:	89 f3                	mov    %esi,%ebx
  802825:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80282b:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  802832:	c1 e3 07             	shl    $0x7,%ebx
  802835:	29 c3                	sub    %eax,%ebx
  802837:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80283d:	eb 05                	jmp    802844 <wait+0x54>
		sys_yield();
  80283f:	e8 d6 e7 ff ff       	call   80101a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802844:	8b 43 48             	mov    0x48(%ebx),%eax
  802847:	39 f0                	cmp    %esi,%eax
  802849:	75 07                	jne    802852 <wait+0x62>
  80284b:	8b 43 54             	mov    0x54(%ebx),%eax
  80284e:	85 c0                	test   %eax,%eax
  802850:	75 ed                	jne    80283f <wait+0x4f>
		sys_yield();
}
  802852:	83 c4 10             	add    $0x10,%esp
  802855:	5b                   	pop    %ebx
  802856:	5e                   	pop    %esi
  802857:	5d                   	pop    %ebp
  802858:	c3                   	ret    
  802859:	00 00                	add    %al,(%eax)
	...

0080285c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80285c:	55                   	push   %ebp
  80285d:	89 e5                	mov    %esp,%ebp
  80285f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802862:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802869:	75 32                	jne    80289d <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80286b:	e8 8b e7 ff ff       	call   800ffb <sys_getenvid>
  802870:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  802877:	00 
  802878:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80287f:	ee 
  802880:	89 04 24             	mov    %eax,(%esp)
  802883:	e8 b1 e7 ff ff       	call   801039 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  802888:	e8 6e e7 ff ff       	call   800ffb <sys_getenvid>
  80288d:	c7 44 24 04 a8 28 80 	movl   $0x8028a8,0x4(%esp)
  802894:	00 
  802895:	89 04 24             	mov    %eax,(%esp)
  802898:	e8 3c e9 ff ff       	call   8011d9 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80289d:	8b 45 08             	mov    0x8(%ebp),%eax
  8028a0:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8028a5:	c9                   	leave  
  8028a6:	c3                   	ret    
	...

008028a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8028a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8028a9:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8028ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8028b0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  8028b3:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  8028b7:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  8028ba:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  8028bf:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  8028c3:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  8028c6:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  8028c7:	83 c4 04             	add    $0x4,%esp
	popfl
  8028ca:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  8028cb:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  8028cc:	c3                   	ret    
  8028cd:	00 00                	add    %al,(%eax)
	...

008028d0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028d0:	55                   	push   %ebp
  8028d1:	89 e5                	mov    %esp,%ebp
  8028d3:	57                   	push   %edi
  8028d4:	56                   	push   %esi
  8028d5:	53                   	push   %ebx
  8028d6:	83 ec 1c             	sub    $0x1c,%esp
  8028d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8028dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8028df:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  8028e2:	85 db                	test   %ebx,%ebx
  8028e4:	75 05                	jne    8028eb <ipc_recv+0x1b>
		pg = (void *)UTOP;
  8028e6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8028eb:	89 1c 24             	mov    %ebx,(%esp)
  8028ee:	e8 5c e9 ff ff       	call   80124f <sys_ipc_recv>
  8028f3:	85 c0                	test   %eax,%eax
  8028f5:	79 16                	jns    80290d <ipc_recv+0x3d>
		*from_env_store = 0;
  8028f7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  8028fd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  802903:	89 1c 24             	mov    %ebx,(%esp)
  802906:	e8 44 e9 ff ff       	call   80124f <sys_ipc_recv>
  80290b:	eb 24                	jmp    802931 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  80290d:	85 f6                	test   %esi,%esi
  80290f:	74 0a                	je     80291b <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802911:	a1 04 50 80 00       	mov    0x805004,%eax
  802916:	8b 40 74             	mov    0x74(%eax),%eax
  802919:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80291b:	85 ff                	test   %edi,%edi
  80291d:	74 0a                	je     802929 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  80291f:	a1 04 50 80 00       	mov    0x805004,%eax
  802924:	8b 40 78             	mov    0x78(%eax),%eax
  802927:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  802929:	a1 04 50 80 00       	mov    0x805004,%eax
  80292e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802931:	83 c4 1c             	add    $0x1c,%esp
  802934:	5b                   	pop    %ebx
  802935:	5e                   	pop    %esi
  802936:	5f                   	pop    %edi
  802937:	5d                   	pop    %ebp
  802938:	c3                   	ret    

00802939 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802939:	55                   	push   %ebp
  80293a:	89 e5                	mov    %esp,%ebp
  80293c:	57                   	push   %edi
  80293d:	56                   	push   %esi
  80293e:	53                   	push   %ebx
  80293f:	83 ec 1c             	sub    $0x1c,%esp
  802942:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802945:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802948:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  80294b:	85 db                	test   %ebx,%ebx
  80294d:	75 05                	jne    802954 <ipc_send+0x1b>
		pg = (void *)-1;
  80294f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802954:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802958:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80295c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802960:	8b 45 08             	mov    0x8(%ebp),%eax
  802963:	89 04 24             	mov    %eax,(%esp)
  802966:	e8 c1 e8 ff ff       	call   80122c <sys_ipc_try_send>
		if (r == 0) {		
  80296b:	85 c0                	test   %eax,%eax
  80296d:	74 2c                	je     80299b <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80296f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802972:	75 07                	jne    80297b <ipc_send+0x42>
			sys_yield();
  802974:	e8 a1 e6 ff ff       	call   80101a <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  802979:	eb d9                	jmp    802954 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  80297b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80297f:	c7 44 24 08 ed 33 80 	movl   $0x8033ed,0x8(%esp)
  802986:	00 
  802987:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80298e:	00 
  80298f:	c7 04 24 fb 33 80 00 	movl   $0x8033fb,(%esp)
  802996:	e8 09 dc ff ff       	call   8005a4 <_panic>
		}
	}
}
  80299b:	83 c4 1c             	add    $0x1c,%esp
  80299e:	5b                   	pop    %ebx
  80299f:	5e                   	pop    %esi
  8029a0:	5f                   	pop    %edi
  8029a1:	5d                   	pop    %ebp
  8029a2:	c3                   	ret    

008029a3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8029a3:	55                   	push   %ebp
  8029a4:	89 e5                	mov    %esp,%ebp
  8029a6:	53                   	push   %ebx
  8029a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8029aa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8029af:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8029b6:	89 c2                	mov    %eax,%edx
  8029b8:	c1 e2 07             	shl    $0x7,%edx
  8029bb:	29 ca                	sub    %ecx,%edx
  8029bd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029c3:	8b 52 50             	mov    0x50(%edx),%edx
  8029c6:	39 da                	cmp    %ebx,%edx
  8029c8:	75 0f                	jne    8029d9 <ipc_find_env+0x36>
			return envs[i].env_id;
  8029ca:	c1 e0 07             	shl    $0x7,%eax
  8029cd:	29 c8                	sub    %ecx,%eax
  8029cf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8029d4:	8b 40 40             	mov    0x40(%eax),%eax
  8029d7:	eb 0c                	jmp    8029e5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8029d9:	40                   	inc    %eax
  8029da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029df:	75 ce                	jne    8029af <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8029e1:	66 b8 00 00          	mov    $0x0,%ax
}
  8029e5:	5b                   	pop    %ebx
  8029e6:	5d                   	pop    %ebp
  8029e7:	c3                   	ret    

008029e8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029e8:	55                   	push   %ebp
  8029e9:	89 e5                	mov    %esp,%ebp
  8029eb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029ee:	89 c2                	mov    %eax,%edx
  8029f0:	c1 ea 16             	shr    $0x16,%edx
  8029f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8029fa:	f6 c2 01             	test   $0x1,%dl
  8029fd:	74 1e                	je     802a1d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029ff:	c1 e8 0c             	shr    $0xc,%eax
  802a02:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802a09:	a8 01                	test   $0x1,%al
  802a0b:	74 17                	je     802a24 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a0d:	c1 e8 0c             	shr    $0xc,%eax
  802a10:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802a17:	ef 
  802a18:	0f b7 c0             	movzwl %ax,%eax
  802a1b:	eb 0c                	jmp    802a29 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  802a22:	eb 05                	jmp    802a29 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802a24:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802a29:	5d                   	pop    %ebp
  802a2a:	c3                   	ret    
	...

00802a2c <__udivdi3>:
  802a2c:	55                   	push   %ebp
  802a2d:	57                   	push   %edi
  802a2e:	56                   	push   %esi
  802a2f:	83 ec 10             	sub    $0x10,%esp
  802a32:	8b 74 24 20          	mov    0x20(%esp),%esi
  802a36:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802a3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a3e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802a42:	89 cd                	mov    %ecx,%ebp
  802a44:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802a48:	85 c0                	test   %eax,%eax
  802a4a:	75 2c                	jne    802a78 <__udivdi3+0x4c>
  802a4c:	39 f9                	cmp    %edi,%ecx
  802a4e:	77 68                	ja     802ab8 <__udivdi3+0x8c>
  802a50:	85 c9                	test   %ecx,%ecx
  802a52:	75 0b                	jne    802a5f <__udivdi3+0x33>
  802a54:	b8 01 00 00 00       	mov    $0x1,%eax
  802a59:	31 d2                	xor    %edx,%edx
  802a5b:	f7 f1                	div    %ecx
  802a5d:	89 c1                	mov    %eax,%ecx
  802a5f:	31 d2                	xor    %edx,%edx
  802a61:	89 f8                	mov    %edi,%eax
  802a63:	f7 f1                	div    %ecx
  802a65:	89 c7                	mov    %eax,%edi
  802a67:	89 f0                	mov    %esi,%eax
  802a69:	f7 f1                	div    %ecx
  802a6b:	89 c6                	mov    %eax,%esi
  802a6d:	89 f0                	mov    %esi,%eax
  802a6f:	89 fa                	mov    %edi,%edx
  802a71:	83 c4 10             	add    $0x10,%esp
  802a74:	5e                   	pop    %esi
  802a75:	5f                   	pop    %edi
  802a76:	5d                   	pop    %ebp
  802a77:	c3                   	ret    
  802a78:	39 f8                	cmp    %edi,%eax
  802a7a:	77 2c                	ja     802aa8 <__udivdi3+0x7c>
  802a7c:	0f bd f0             	bsr    %eax,%esi
  802a7f:	83 f6 1f             	xor    $0x1f,%esi
  802a82:	75 4c                	jne    802ad0 <__udivdi3+0xa4>
  802a84:	39 f8                	cmp    %edi,%eax
  802a86:	bf 00 00 00 00       	mov    $0x0,%edi
  802a8b:	72 0a                	jb     802a97 <__udivdi3+0x6b>
  802a8d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802a91:	0f 87 ad 00 00 00    	ja     802b44 <__udivdi3+0x118>
  802a97:	be 01 00 00 00       	mov    $0x1,%esi
  802a9c:	89 f0                	mov    %esi,%eax
  802a9e:	89 fa                	mov    %edi,%edx
  802aa0:	83 c4 10             	add    $0x10,%esp
  802aa3:	5e                   	pop    %esi
  802aa4:	5f                   	pop    %edi
  802aa5:	5d                   	pop    %ebp
  802aa6:	c3                   	ret    
  802aa7:	90                   	nop
  802aa8:	31 ff                	xor    %edi,%edi
  802aaa:	31 f6                	xor    %esi,%esi
  802aac:	89 f0                	mov    %esi,%eax
  802aae:	89 fa                	mov    %edi,%edx
  802ab0:	83 c4 10             	add    $0x10,%esp
  802ab3:	5e                   	pop    %esi
  802ab4:	5f                   	pop    %edi
  802ab5:	5d                   	pop    %ebp
  802ab6:	c3                   	ret    
  802ab7:	90                   	nop
  802ab8:	89 fa                	mov    %edi,%edx
  802aba:	89 f0                	mov    %esi,%eax
  802abc:	f7 f1                	div    %ecx
  802abe:	89 c6                	mov    %eax,%esi
  802ac0:	31 ff                	xor    %edi,%edi
  802ac2:	89 f0                	mov    %esi,%eax
  802ac4:	89 fa                	mov    %edi,%edx
  802ac6:	83 c4 10             	add    $0x10,%esp
  802ac9:	5e                   	pop    %esi
  802aca:	5f                   	pop    %edi
  802acb:	5d                   	pop    %ebp
  802acc:	c3                   	ret    
  802acd:	8d 76 00             	lea    0x0(%esi),%esi
  802ad0:	89 f1                	mov    %esi,%ecx
  802ad2:	d3 e0                	shl    %cl,%eax
  802ad4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ad8:	b8 20 00 00 00       	mov    $0x20,%eax
  802add:	29 f0                	sub    %esi,%eax
  802adf:	89 ea                	mov    %ebp,%edx
  802ae1:	88 c1                	mov    %al,%cl
  802ae3:	d3 ea                	shr    %cl,%edx
  802ae5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802ae9:	09 ca                	or     %ecx,%edx
  802aeb:	89 54 24 08          	mov    %edx,0x8(%esp)
  802aef:	89 f1                	mov    %esi,%ecx
  802af1:	d3 e5                	shl    %cl,%ebp
  802af3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802af7:	89 fd                	mov    %edi,%ebp
  802af9:	88 c1                	mov    %al,%cl
  802afb:	d3 ed                	shr    %cl,%ebp
  802afd:	89 fa                	mov    %edi,%edx
  802aff:	89 f1                	mov    %esi,%ecx
  802b01:	d3 e2                	shl    %cl,%edx
  802b03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802b07:	88 c1                	mov    %al,%cl
  802b09:	d3 ef                	shr    %cl,%edi
  802b0b:	09 d7                	or     %edx,%edi
  802b0d:	89 f8                	mov    %edi,%eax
  802b0f:	89 ea                	mov    %ebp,%edx
  802b11:	f7 74 24 08          	divl   0x8(%esp)
  802b15:	89 d1                	mov    %edx,%ecx
  802b17:	89 c7                	mov    %eax,%edi
  802b19:	f7 64 24 0c          	mull   0xc(%esp)
  802b1d:	39 d1                	cmp    %edx,%ecx
  802b1f:	72 17                	jb     802b38 <__udivdi3+0x10c>
  802b21:	74 09                	je     802b2c <__udivdi3+0x100>
  802b23:	89 fe                	mov    %edi,%esi
  802b25:	31 ff                	xor    %edi,%edi
  802b27:	e9 41 ff ff ff       	jmp    802a6d <__udivdi3+0x41>
  802b2c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802b30:	89 f1                	mov    %esi,%ecx
  802b32:	d3 e2                	shl    %cl,%edx
  802b34:	39 c2                	cmp    %eax,%edx
  802b36:	73 eb                	jae    802b23 <__udivdi3+0xf7>
  802b38:	8d 77 ff             	lea    -0x1(%edi),%esi
  802b3b:	31 ff                	xor    %edi,%edi
  802b3d:	e9 2b ff ff ff       	jmp    802a6d <__udivdi3+0x41>
  802b42:	66 90                	xchg   %ax,%ax
  802b44:	31 f6                	xor    %esi,%esi
  802b46:	e9 22 ff ff ff       	jmp    802a6d <__udivdi3+0x41>
	...

00802b4c <__umoddi3>:
  802b4c:	55                   	push   %ebp
  802b4d:	57                   	push   %edi
  802b4e:	56                   	push   %esi
  802b4f:	83 ec 20             	sub    $0x20,%esp
  802b52:	8b 44 24 30          	mov    0x30(%esp),%eax
  802b56:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  802b5a:	89 44 24 14          	mov    %eax,0x14(%esp)
  802b5e:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802b66:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802b6a:	89 c7                	mov    %eax,%edi
  802b6c:	89 f2                	mov    %esi,%edx
  802b6e:	85 ed                	test   %ebp,%ebp
  802b70:	75 16                	jne    802b88 <__umoddi3+0x3c>
  802b72:	39 f1                	cmp    %esi,%ecx
  802b74:	0f 86 a6 00 00 00    	jbe    802c20 <__umoddi3+0xd4>
  802b7a:	f7 f1                	div    %ecx
  802b7c:	89 d0                	mov    %edx,%eax
  802b7e:	31 d2                	xor    %edx,%edx
  802b80:	83 c4 20             	add    $0x20,%esp
  802b83:	5e                   	pop    %esi
  802b84:	5f                   	pop    %edi
  802b85:	5d                   	pop    %ebp
  802b86:	c3                   	ret    
  802b87:	90                   	nop
  802b88:	39 f5                	cmp    %esi,%ebp
  802b8a:	0f 87 ac 00 00 00    	ja     802c3c <__umoddi3+0xf0>
  802b90:	0f bd c5             	bsr    %ebp,%eax
  802b93:	83 f0 1f             	xor    $0x1f,%eax
  802b96:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b9a:	0f 84 a8 00 00 00    	je     802c48 <__umoddi3+0xfc>
  802ba0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ba4:	d3 e5                	shl    %cl,%ebp
  802ba6:	bf 20 00 00 00       	mov    $0x20,%edi
  802bab:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802baf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802bb3:	89 f9                	mov    %edi,%ecx
  802bb5:	d3 e8                	shr    %cl,%eax
  802bb7:	09 e8                	or     %ebp,%eax
  802bb9:	89 44 24 18          	mov    %eax,0x18(%esp)
  802bbd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802bc1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802bc5:	d3 e0                	shl    %cl,%eax
  802bc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802bcb:	89 f2                	mov    %esi,%edx
  802bcd:	d3 e2                	shl    %cl,%edx
  802bcf:	8b 44 24 14          	mov    0x14(%esp),%eax
  802bd3:	d3 e0                	shl    %cl,%eax
  802bd5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802bd9:	8b 44 24 14          	mov    0x14(%esp),%eax
  802bdd:	89 f9                	mov    %edi,%ecx
  802bdf:	d3 e8                	shr    %cl,%eax
  802be1:	09 d0                	or     %edx,%eax
  802be3:	d3 ee                	shr    %cl,%esi
  802be5:	89 f2                	mov    %esi,%edx
  802be7:	f7 74 24 18          	divl   0x18(%esp)
  802beb:	89 d6                	mov    %edx,%esi
  802bed:	f7 64 24 0c          	mull   0xc(%esp)
  802bf1:	89 c5                	mov    %eax,%ebp
  802bf3:	89 d1                	mov    %edx,%ecx
  802bf5:	39 d6                	cmp    %edx,%esi
  802bf7:	72 67                	jb     802c60 <__umoddi3+0x114>
  802bf9:	74 75                	je     802c70 <__umoddi3+0x124>
  802bfb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802bff:	29 e8                	sub    %ebp,%eax
  802c01:	19 ce                	sbb    %ecx,%esi
  802c03:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802c07:	d3 e8                	shr    %cl,%eax
  802c09:	89 f2                	mov    %esi,%edx
  802c0b:	89 f9                	mov    %edi,%ecx
  802c0d:	d3 e2                	shl    %cl,%edx
  802c0f:	09 d0                	or     %edx,%eax
  802c11:	89 f2                	mov    %esi,%edx
  802c13:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802c17:	d3 ea                	shr    %cl,%edx
  802c19:	83 c4 20             	add    $0x20,%esp
  802c1c:	5e                   	pop    %esi
  802c1d:	5f                   	pop    %edi
  802c1e:	5d                   	pop    %ebp
  802c1f:	c3                   	ret    
  802c20:	85 c9                	test   %ecx,%ecx
  802c22:	75 0b                	jne    802c2f <__umoddi3+0xe3>
  802c24:	b8 01 00 00 00       	mov    $0x1,%eax
  802c29:	31 d2                	xor    %edx,%edx
  802c2b:	f7 f1                	div    %ecx
  802c2d:	89 c1                	mov    %eax,%ecx
  802c2f:	89 f0                	mov    %esi,%eax
  802c31:	31 d2                	xor    %edx,%edx
  802c33:	f7 f1                	div    %ecx
  802c35:	89 f8                	mov    %edi,%eax
  802c37:	e9 3e ff ff ff       	jmp    802b7a <__umoddi3+0x2e>
  802c3c:	89 f2                	mov    %esi,%edx
  802c3e:	83 c4 20             	add    $0x20,%esp
  802c41:	5e                   	pop    %esi
  802c42:	5f                   	pop    %edi
  802c43:	5d                   	pop    %ebp
  802c44:	c3                   	ret    
  802c45:	8d 76 00             	lea    0x0(%esi),%esi
  802c48:	39 f5                	cmp    %esi,%ebp
  802c4a:	72 04                	jb     802c50 <__umoddi3+0x104>
  802c4c:	39 f9                	cmp    %edi,%ecx
  802c4e:	77 06                	ja     802c56 <__umoddi3+0x10a>
  802c50:	89 f2                	mov    %esi,%edx
  802c52:	29 cf                	sub    %ecx,%edi
  802c54:	19 ea                	sbb    %ebp,%edx
  802c56:	89 f8                	mov    %edi,%eax
  802c58:	83 c4 20             	add    $0x20,%esp
  802c5b:	5e                   	pop    %esi
  802c5c:	5f                   	pop    %edi
  802c5d:	5d                   	pop    %ebp
  802c5e:	c3                   	ret    
  802c5f:	90                   	nop
  802c60:	89 d1                	mov    %edx,%ecx
  802c62:	89 c5                	mov    %eax,%ebp
  802c64:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802c68:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802c6c:	eb 8d                	jmp    802bfb <__umoddi3+0xaf>
  802c6e:	66 90                	xchg   %ax,%ax
  802c70:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802c74:	72 ea                	jb     802c60 <__umoddi3+0x114>
  802c76:	89 f1                	mov    %esi,%ecx
  802c78:	eb 81                	jmp    802bfb <__umoddi3+0xaf>
