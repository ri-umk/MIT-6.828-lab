
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 b3 03 00 00       	call   8003e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800044:	ba 00 00 00 00       	mov    $0x0,%edx
  800049:	eb 0a                	jmp    800055 <sum+0x21>
		tot ^= i * s[i];
  80004b:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004f:	0f af ca             	imul   %edx,%ecx
  800052:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800054:	42                   	inc    %edx
  800055:	39 da                	cmp    %ebx,%edx
  800057:	7c f2                	jl     80004b <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  800059:	5b                   	pop    %ebx
  80005a:	5e                   	pop    %esi
  80005b:	5d                   	pop    %ebp
  80005c:	c3                   	ret    

0080005d <umain>:

void
umain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  800069:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006c:	c7 04 24 20 27 80 00 	movl   $0x802720,(%esp)
  800073:	e8 d4 04 00 00       	call   80054c <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800078:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <sum>
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 1a                	je     8000ad <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  80009a:	00 
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 e8 27 80 00 	movl   $0x8027e8,(%esp)
  8000a6:	e8 a1 04 00 00       	call   80054c <cprintf>
  8000ab:	eb 0c                	jmp    8000b9 <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ad:	c7 04 24 2f 27 80 00 	movl   $0x80272f,(%esp)
  8000b4:	e8 93 04 00 00       	call   80054c <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000b9:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000c0:	00 
  8000c1:	c7 04 24 20 50 80 00 	movl   $0x805020,(%esp)
  8000c8:	e8 67 ff ff ff       	call   800034 <sum>
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	74 12                	je     8000e3 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d5:	c7 04 24 24 28 80 00 	movl   $0x802824,(%esp)
  8000dc:	e8 6b 04 00 00       	call   80054c <cprintf>
  8000e1:	eb 0c                	jmp    8000ef <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000e3:	c7 04 24 46 27 80 00 	movl   $0x802746,(%esp)
  8000ea:	e8 5d 04 00 00       	call   80054c <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000ef:	c7 44 24 04 5c 27 80 	movl   $0x80275c,0x4(%esp)
  8000f6:	00 
  8000f7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000fd:	89 04 24             	mov    %eax,(%esp)
  800100:	e8 0f 0a 00 00       	call   800b14 <strcat>
	for (i = 0; i < argc; i++) {
  800105:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  80010a:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800110:	eb 30                	jmp    800142 <umain+0xe5>
		strcat(args, " '");
  800112:	c7 44 24 04 68 27 80 	movl   $0x802768,0x4(%esp)
  800119:	00 
  80011a:	89 34 24             	mov    %esi,(%esp)
  80011d:	e8 f2 09 00 00       	call   800b14 <strcat>
		strcat(args, argv[i]);
  800122:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	89 34 24             	mov    %esi,(%esp)
  80012c:	e8 e3 09 00 00       	call   800b14 <strcat>
		strcat(args, "'");
  800131:	c7 44 24 04 69 27 80 	movl   $0x802769,0x4(%esp)
  800138:	00 
  800139:	89 34 24             	mov    %esi,(%esp)
  80013c:	e8 d3 09 00 00       	call   800b14 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800141:	43                   	inc    %ebx
  800142:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800145:	7c cb                	jl     800112 <umain+0xb5>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800147:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 6b 27 80 00 	movl   $0x80276b,(%esp)
  800158:	e8 ef 03 00 00       	call   80054c <cprintf>

	cprintf("init: running sh\n");
  80015d:	c7 04 24 6f 27 80 00 	movl   $0x80276f,(%esp)
  800164:	e8 e3 03 00 00       	call   80054c <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800170:	e8 95 11 00 00       	call   80130a <close>
	if ((r = opencons()) < 0)
  800175:	e8 16 02 00 00       	call   800390 <opencons>
  80017a:	85 c0                	test   %eax,%eax
  80017c:	79 20                	jns    80019e <umain+0x141>
		panic("opencons: %e", r);
  80017e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800182:	c7 44 24 08 81 27 80 	movl   $0x802781,0x8(%esp)
  800189:	00 
  80018a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800191:	00 
  800192:	c7 04 24 8e 27 80 00 	movl   $0x80278e,(%esp)
  800199:	e8 b6 02 00 00       	call   800454 <_panic>
	if (r != 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	74 20                	je     8001c2 <umain+0x165>
		panic("first opencons used fd %d", r);
  8001a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a6:	c7 44 24 08 9a 27 80 	movl   $0x80279a,0x8(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8001b5:	00 
  8001b6:	c7 04 24 8e 27 80 00 	movl   $0x80278e,(%esp)
  8001bd:	e8 92 02 00 00       	call   800454 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c9:	00 
  8001ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001d1:	e8 85 11 00 00       	call   80135b <dup>
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	79 20                	jns    8001fa <umain+0x19d>
		panic("dup: %e", r);
  8001da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001de:	c7 44 24 08 b4 27 80 	movl   $0x8027b4,0x8(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8001ed:	00 
  8001ee:	c7 04 24 8e 27 80 00 	movl   $0x80278e,(%esp)
  8001f5:	e8 5a 02 00 00       	call   800454 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001fa:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  800201:	e8 46 03 00 00       	call   80054c <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800206:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 d0 27 80 	movl   $0x8027d0,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 cf 27 80 00 	movl   $0x8027cf,(%esp)
  80021d:	e8 ee 1c 00 00       	call   801f10 <spawnl>
		if (r < 0) {
  800222:	85 c0                	test   %eax,%eax
  800224:	79 12                	jns    800238 <umain+0x1db>
			cprintf("init: spawn sh: %e\n", r);
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	c7 04 24 d3 27 80 00 	movl   $0x8027d3,(%esp)
  800231:	e8 16 03 00 00       	call   80054c <cprintf>
			continue;
  800236:	eb c2                	jmp    8001fa <umain+0x19d>
		}
		wait(r);
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 b8 20 00 00       	call   8022f8 <wait>
  800240:	eb b8                	jmp    8001fa <umain+0x19d>
	...

00800244 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800247:	b8 00 00 00 00       	mov    $0x0,%eax
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800254:	c7 44 24 04 53 28 80 	movl   $0x802853,0x4(%esp)
  80025b:	00 
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 90 08 00 00       	call   800af7 <strcpy>
	return 0;
}
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	57                   	push   %edi
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
  800274:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80027f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800285:	eb 30                	jmp    8002b7 <devcons_write+0x49>
		m = n - tot;
  800287:	8b 75 10             	mov    0x10(%ebp),%esi
  80028a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80028c:	83 fe 7f             	cmp    $0x7f,%esi
  80028f:	76 05                	jbe    800296 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800291:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800296:	89 74 24 08          	mov    %esi,0x8(%esp)
  80029a:	03 45 0c             	add    0xc(%ebp),%eax
  80029d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a1:	89 3c 24             	mov    %edi,(%esp)
  8002a4:	e8 c7 09 00 00       	call   800c70 <memmove>
		sys_cputs(buf, m);
  8002a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ad:	89 3c 24             	mov    %edi,(%esp)
  8002b0:	e8 67 0b 00 00       	call   800e1c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8002b5:	01 f3                	add    %esi,%ebx
  8002b7:	89 d8                	mov    %ebx,%eax
  8002b9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8002bc:	72 c9                	jb     800287 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8002be:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8002cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002d3:	75 07                	jne    8002dc <devcons_read+0x13>
  8002d5:	eb 25                	jmp    8002fc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002d7:	e8 ee 0b 00 00       	call   800eca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002dc:	e8 59 0b 00 00       	call   800e3a <sys_cgetc>
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	74 f2                	je     8002d7 <devcons_read+0xe>
  8002e5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	78 1d                	js     800308 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002eb:	83 f8 04             	cmp    $0x4,%eax
  8002ee:	74 13                	je     800303 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f3:	88 10                	mov    %dl,(%eax)
	return 1;
  8002f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8002fa:	eb 0c                	jmp    800308 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8002fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800301:	eb 05                	jmp    800308 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800303:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800316:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80031d:	00 
  80031e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	e8 f3 0a 00 00       	call   800e1c <sys_cputs>
}
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <getchar>:

int
getchar(void)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800331:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800338:	00 
  800339:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80033c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800347:	e8 22 11 00 00       	call   80146e <read>
	if (r < 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	78 0f                	js     80035f <getchar+0x34>
		return r;
	if (r < 1)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 06                	jle    80035a <getchar+0x2f>
		return -E_EOF;
	return c;
  800354:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800358:	eb 05                	jmp    80035f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80035a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80036a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	e8 59 0e 00 00       	call   8011d2 <fd_lookup>
  800379:	85 c0                	test   %eax,%eax
  80037b:	78 11                	js     80038e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80037d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800380:	8b 15 70 47 80 00    	mov    0x804770,%edx
  800386:	39 10                	cmp    %edx,(%eax)
  800388:	0f 94 c0             	sete   %al
  80038b:	0f b6 c0             	movzbl %al,%eax
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <opencons>:

int
opencons(void)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800396:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800399:	89 04 24             	mov    %eax,(%esp)
  80039c:	e8 de 0d 00 00       	call   80117f <fd_alloc>
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	78 3c                	js     8003e1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003a5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8003ac:	00 
  8003ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003bb:	e8 29 0b 00 00       	call   800ee9 <sys_page_alloc>
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	78 1d                	js     8003e1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8003c4:	8b 15 70 47 80 00    	mov    0x804770,%edx
  8003ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003d9:	89 04 24             	mov    %eax,(%esp)
  8003dc:	e8 73 0d 00 00       	call   801154 <fd2num>
}
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    
	...

008003e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	56                   	push   %esi
  8003e8:	53                   	push   %ebx
  8003e9:	83 ec 10             	sub    $0x10,%esp
  8003ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8003f2:	e8 b4 0a 00 00       	call   800eab <sys_getenvid>
  8003f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800403:	c1 e0 07             	shl    $0x7,%eax
  800406:	29 d0                	sub    %edx,%eax
  800408:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80040d:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800412:	85 f6                	test   %esi,%esi
  800414:	7e 07                	jle    80041d <libmain+0x39>
		binaryname = argv[0];
  800416:	8b 03                	mov    (%ebx),%eax
  800418:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  80041d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800421:	89 34 24             	mov    %esi,(%esp)
  800424:	e8 34 fc ff ff       	call   80005d <umain>

	// exit gracefully
	exit();
  800429:	e8 0a 00 00 00       	call   800438 <exit>
}
  80042e:	83 c4 10             	add    $0x10,%esp
  800431:	5b                   	pop    %ebx
  800432:	5e                   	pop    %esi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    
  800435:	00 00                	add    %al,(%eax)
	...

00800438 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80043e:	e8 f8 0e 00 00       	call   80133b <close_all>
	sys_env_destroy(0);
  800443:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80044a:	e8 0a 0a 00 00       	call   800e59 <sys_env_destroy>
}
  80044f:	c9                   	leave  
  800450:	c3                   	ret    
  800451:	00 00                	add    %al,(%eax)
	...

00800454 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	56                   	push   %esi
  800458:	53                   	push   %ebx
  800459:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80045c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80045f:	8b 1d 8c 47 80 00    	mov    0x80478c,%ebx
  800465:	e8 41 0a 00 00       	call   800eab <sys_getenvid>
  80046a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800471:	8b 55 08             	mov    0x8(%ebp),%edx
  800474:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800478:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80047c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800480:	c7 04 24 6c 28 80 00 	movl   $0x80286c,(%esp)
  800487:	e8 c0 00 00 00       	call   80054c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80048c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800490:	8b 45 10             	mov    0x10(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 50 00 00 00       	call   8004eb <vcprintf>
	cprintf("\n");
  80049b:	c7 04 24 60 2d 80 00 	movl   $0x802d60,(%esp)
  8004a2:	e8 a5 00 00 00       	call   80054c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a7:	cc                   	int3   
  8004a8:	eb fd                	jmp    8004a7 <_panic+0x53>
	...

008004ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	53                   	push   %ebx
  8004b0:	83 ec 14             	sub    $0x14,%esp
  8004b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b6:	8b 03                	mov    (%ebx),%eax
  8004b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004bf:	40                   	inc    %eax
  8004c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004c7:	75 19                	jne    8004e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8004c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004d0:	00 
  8004d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 40 09 00 00       	call   800e1c <sys_cputs>
		b->idx = 0;
  8004dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004e2:	ff 43 04             	incl   0x4(%ebx)
}
  8004e5:	83 c4 14             	add    $0x14,%esp
  8004e8:	5b                   	pop    %ebx
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fb:	00 00 00 
	b.cnt = 0;
  8004fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800505:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	89 44 24 08          	mov    %eax,0x8(%esp)
  800516:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800520:	c7 04 24 ac 04 80 00 	movl   $0x8004ac,(%esp)
  800527:	e8 82 01 00 00       	call   8006ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800532:	89 44 24 04          	mov    %eax,0x4(%esp)
  800536:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	e8 d8 08 00 00       	call   800e1c <sys_cputs>

	return b.cnt;
}
  800544:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800552:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800555:	89 44 24 04          	mov    %eax,0x4(%esp)
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	e8 87 ff ff ff       	call   8004eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800564:	c9                   	leave  
  800565:	c3                   	ret    
	...

00800568 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	57                   	push   %edi
  80056c:	56                   	push   %esi
  80056d:	53                   	push   %ebx
  80056e:	83 ec 3c             	sub    $0x3c,%esp
  800571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800574:	89 d7                	mov    %edx,%edi
  800576:	8b 45 08             	mov    0x8(%ebp),%eax
  800579:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80057c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800582:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800585:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800588:	85 c0                	test   %eax,%eax
  80058a:	75 08                	jne    800594 <printnum+0x2c>
  80058c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80058f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800592:	77 57                	ja     8005eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800594:	89 74 24 10          	mov    %esi,0x10(%esp)
  800598:	4b                   	dec    %ebx
  800599:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80059d:	8b 45 10             	mov    0x10(%ebp),%eax
  8005a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8005a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8005ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005b3:	00 
  8005b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c1:	e8 fa 1e 00 00       	call   8024c0 <__udivdi3>
  8005c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d5:	89 fa                	mov    %edi,%edx
  8005d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005da:	e8 89 ff ff ff       	call   800568 <printnum>
  8005df:	eb 0f                	jmp    8005f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e5:	89 34 24             	mov    %esi,(%esp)
  8005e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005eb:	4b                   	dec    %ebx
  8005ec:	85 db                	test   %ebx,%ebx
  8005ee:	7f f1                	jg     8005e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8005fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800606:	00 
  800607:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800610:	89 44 24 04          	mov    %eax,0x4(%esp)
  800614:	e8 c7 1f 00 00       	call   8025e0 <__umoddi3>
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	0f be 80 8f 28 80 00 	movsbl 0x80288f(%eax),%eax
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80062a:	83 c4 3c             	add    $0x3c,%esp
  80062d:	5b                   	pop    %ebx
  80062e:	5e                   	pop    %esi
  80062f:	5f                   	pop    %edi
  800630:	5d                   	pop    %ebp
  800631:	c3                   	ret    

00800632 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800635:	83 fa 01             	cmp    $0x1,%edx
  800638:	7e 0e                	jle    800648 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80063f:	89 08                	mov    %ecx,(%eax)
  800641:	8b 02                	mov    (%edx),%eax
  800643:	8b 52 04             	mov    0x4(%edx),%edx
  800646:	eb 22                	jmp    80066a <getuint+0x38>
	else if (lflag)
  800648:	85 d2                	test   %edx,%edx
  80064a:	74 10                	je     80065c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800651:	89 08                	mov    %ecx,(%eax)
  800653:	8b 02                	mov    (%edx),%eax
  800655:	ba 00 00 00 00       	mov    $0x0,%edx
  80065a:	eb 0e                	jmp    80066a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800661:	89 08                	mov    %ecx,(%eax)
  800663:	8b 02                	mov    (%edx),%eax
  800665:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80066a:	5d                   	pop    %ebp
  80066b:	c3                   	ret    

0080066c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800672:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800675:	8b 10                	mov    (%eax),%edx
  800677:	3b 50 04             	cmp    0x4(%eax),%edx
  80067a:	73 08                	jae    800684 <sprintputch+0x18>
		*b->buf++ = ch;
  80067c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80067f:	88 0a                	mov    %cl,(%edx)
  800681:	42                   	inc    %edx
  800682:	89 10                	mov    %edx,(%eax)
}
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80068c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80068f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800693:	8b 45 10             	mov    0x10(%ebp),%eax
  800696:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	e8 02 00 00 00       	call   8006ae <vprintfmt>
	va_end(ap);
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    

008006ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	57                   	push   %edi
  8006b2:	56                   	push   %esi
  8006b3:	53                   	push   %ebx
  8006b4:	83 ec 4c             	sub    $0x4c,%esp
  8006b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8006bd:	eb 12                	jmp    8006d1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	0f 84 6b 03 00 00    	je     800a32 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8006c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cb:	89 04 24             	mov    %eax,(%esp)
  8006ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d1:	0f b6 06             	movzbl (%esi),%eax
  8006d4:	46                   	inc    %esi
  8006d5:	83 f8 25             	cmp    $0x25,%eax
  8006d8:	75 e5                	jne    8006bf <vprintfmt+0x11>
  8006da:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8006e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8006ea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f6:	eb 26                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006ff:	eb 1d                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800701:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800704:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800708:	eb 14                	jmp    80071e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80070d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800714:	eb 08                	jmp    80071e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800716:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800719:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	0f b6 06             	movzbl (%esi),%eax
  800721:	8d 56 01             	lea    0x1(%esi),%edx
  800724:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800727:	8a 16                	mov    (%esi),%dl
  800729:	83 ea 23             	sub    $0x23,%edx
  80072c:	80 fa 55             	cmp    $0x55,%dl
  80072f:	0f 87 e1 02 00 00    	ja     800a16 <vprintfmt+0x368>
  800735:	0f b6 d2             	movzbl %dl,%edx
  800738:	ff 24 95 e0 29 80 00 	jmp    *0x8029e0(,%edx,4)
  80073f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800742:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800747:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80074a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80074e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800751:	8d 50 d0             	lea    -0x30(%eax),%edx
  800754:	83 fa 09             	cmp    $0x9,%edx
  800757:	77 2a                	ja     800783 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800759:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80075a:	eb eb                	jmp    800747 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8d 50 04             	lea    0x4(%eax),%edx
  800762:	89 55 14             	mov    %edx,0x14(%ebp)
  800765:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800767:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80076a:	eb 17                	jmp    800783 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80076c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800770:	78 98                	js     80070a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800775:	eb a7                	jmp    80071e <vprintfmt+0x70>
  800777:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80077a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800781:	eb 9b                	jmp    80071e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800783:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800787:	79 95                	jns    80071e <vprintfmt+0x70>
  800789:	eb 8b                	jmp    800716 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80078b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80078f:	eb 8d                	jmp    80071e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 04             	lea    0x4(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)
  80079a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079e:	8b 00                	mov    (%eax),%eax
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007a9:	e9 23 ff ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 04             	lea    0x4(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	79 02                	jns    8007bf <vprintfmt+0x111>
  8007bd:	f7 d8                	neg    %eax
  8007bf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007c1:	83 f8 0f             	cmp    $0xf,%eax
  8007c4:	7f 0b                	jg     8007d1 <vprintfmt+0x123>
  8007c6:	8b 04 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%eax
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	75 23                	jne    8007f4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8007d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d5:	c7 44 24 08 a7 28 80 	movl   $0x8028a7,0x8(%esp)
  8007dc:	00 
  8007dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	e8 9a fe ff ff       	call   800686 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007ef:	e9 dd fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8007f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f8:	c7 44 24 08 9a 2c 80 	movl   $0x802c9a,0x8(%esp)
  8007ff:	00 
  800800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800804:	8b 55 08             	mov    0x8(%ebp),%edx
  800807:	89 14 24             	mov    %edx,(%esp)
  80080a:	e8 77 fe ff ff       	call   800686 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800812:	e9 ba fe ff ff       	jmp    8006d1 <vprintfmt+0x23>
  800817:	89 f9                	mov    %edi,%ecx
  800819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80081c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8d 50 04             	lea    0x4(%eax),%edx
  800825:	89 55 14             	mov    %edx,0x14(%ebp)
  800828:	8b 30                	mov    (%eax),%esi
  80082a:	85 f6                	test   %esi,%esi
  80082c:	75 05                	jne    800833 <vprintfmt+0x185>
				p = "(null)";
  80082e:	be a0 28 80 00       	mov    $0x8028a0,%esi
			if (width > 0 && padc != '-')
  800833:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800837:	0f 8e 84 00 00 00    	jle    8008c1 <vprintfmt+0x213>
  80083d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800841:	74 7e                	je     8008c1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800843:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800847:	89 34 24             	mov    %esi,(%esp)
  80084a:	e8 8b 02 00 00       	call   800ada <strnlen>
  80084f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800852:	29 c2                	sub    %eax,%edx
  800854:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800857:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80085b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80085e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800861:	89 de                	mov    %ebx,%esi
  800863:	89 d3                	mov    %edx,%ebx
  800865:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800867:	eb 0b                	jmp    800874 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800869:	89 74 24 04          	mov    %esi,0x4(%esp)
  80086d:	89 3c 24             	mov    %edi,(%esp)
  800870:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800873:	4b                   	dec    %ebx
  800874:	85 db                	test   %ebx,%ebx
  800876:	7f f1                	jg     800869 <vprintfmt+0x1bb>
  800878:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80087b:	89 f3                	mov    %esi,%ebx
  80087d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800883:	85 c0                	test   %eax,%eax
  800885:	79 05                	jns    80088c <vprintfmt+0x1de>
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
  80088c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80088f:	29 c2                	sub    %eax,%edx
  800891:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800894:	eb 2b                	jmp    8008c1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800896:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80089a:	74 18                	je     8008b4 <vprintfmt+0x206>
  80089c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80089f:	83 fa 5e             	cmp    $0x5e,%edx
  8008a2:	76 10                	jbe    8008b4 <vprintfmt+0x206>
					putch('?', putdat);
  8008a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008af:	ff 55 08             	call   *0x8(%ebp)
  8008b2:	eb 0a                	jmp    8008be <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8008b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b8:	89 04 24             	mov    %eax,(%esp)
  8008bb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008be:	ff 4d e4             	decl   -0x1c(%ebp)
  8008c1:	0f be 06             	movsbl (%esi),%eax
  8008c4:	46                   	inc    %esi
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	74 21                	je     8008ea <vprintfmt+0x23c>
  8008c9:	85 ff                	test   %edi,%edi
  8008cb:	78 c9                	js     800896 <vprintfmt+0x1e8>
  8008cd:	4f                   	dec    %edi
  8008ce:	79 c6                	jns    800896 <vprintfmt+0x1e8>
  8008d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d3:	89 de                	mov    %ebx,%esi
  8008d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008d8:	eb 18                	jmp    8008f2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008e7:	4b                   	dec    %ebx
  8008e8:	eb 08                	jmp    8008f2 <vprintfmt+0x244>
  8008ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ed:	89 de                	mov    %ebx,%esi
  8008ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008f2:	85 db                	test   %ebx,%ebx
  8008f4:	7f e4                	jg     8008da <vprintfmt+0x22c>
  8008f6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8008f9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008fe:	e9 ce fd ff ff       	jmp    8006d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800903:	83 f9 01             	cmp    $0x1,%ecx
  800906:	7e 10                	jle    800918 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	8d 50 08             	lea    0x8(%eax),%edx
  80090e:	89 55 14             	mov    %edx,0x14(%ebp)
  800911:	8b 30                	mov    (%eax),%esi
  800913:	8b 78 04             	mov    0x4(%eax),%edi
  800916:	eb 26                	jmp    80093e <vprintfmt+0x290>
	else if (lflag)
  800918:	85 c9                	test   %ecx,%ecx
  80091a:	74 12                	je     80092e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80091c:	8b 45 14             	mov    0x14(%ebp),%eax
  80091f:	8d 50 04             	lea    0x4(%eax),%edx
  800922:	89 55 14             	mov    %edx,0x14(%ebp)
  800925:	8b 30                	mov    (%eax),%esi
  800927:	89 f7                	mov    %esi,%edi
  800929:	c1 ff 1f             	sar    $0x1f,%edi
  80092c:	eb 10                	jmp    80093e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8d 50 04             	lea    0x4(%eax),%edx
  800934:	89 55 14             	mov    %edx,0x14(%ebp)
  800937:	8b 30                	mov    (%eax),%esi
  800939:	89 f7                	mov    %esi,%edi
  80093b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80093e:	85 ff                	test   %edi,%edi
  800940:	78 0a                	js     80094c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800942:	b8 0a 00 00 00       	mov    $0xa,%eax
  800947:	e9 8c 00 00 00       	jmp    8009d8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80094c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800950:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800957:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80095a:	f7 de                	neg    %esi
  80095c:	83 d7 00             	adc    $0x0,%edi
  80095f:	f7 df                	neg    %edi
			}
			base = 10;
  800961:	b8 0a 00 00 00       	mov    $0xa,%eax
  800966:	eb 70                	jmp    8009d8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800968:	89 ca                	mov    %ecx,%edx
  80096a:	8d 45 14             	lea    0x14(%ebp),%eax
  80096d:	e8 c0 fc ff ff       	call   800632 <getuint>
  800972:	89 c6                	mov    %eax,%esi
  800974:	89 d7                	mov    %edx,%edi
			base = 10;
  800976:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80097b:	eb 5b                	jmp    8009d8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80097d:	89 ca                	mov    %ecx,%edx
  80097f:	8d 45 14             	lea    0x14(%ebp),%eax
  800982:	e8 ab fc ff ff       	call   800632 <getuint>
  800987:	89 c6                	mov    %eax,%esi
  800989:	89 d7                	mov    %edx,%edi
			base = 8;
  80098b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800990:	eb 46                	jmp    8009d8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800992:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800996:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80099d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b1:	8d 50 04             	lea    0x4(%eax),%edx
  8009b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8009b7:	8b 30                	mov    (%eax),%esi
  8009b9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8009be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8009c3:	eb 13                	jmp    8009d8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009c5:	89 ca                	mov    %ecx,%edx
  8009c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ca:	e8 63 fc ff ff       	call   800632 <getuint>
  8009cf:	89 c6                	mov    %eax,%esi
  8009d1:	89 d7                	mov    %edx,%edi
			base = 16;
  8009d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009d8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8009dc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8009e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009eb:	89 34 24             	mov    %esi,(%esp)
  8009ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009f2:	89 da                	mov    %ebx,%edx
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	e8 6c fb ff ff       	call   800568 <printnum>
			break;
  8009fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009ff:	e9 cd fc ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a08:	89 04 24             	mov    %eax,(%esp)
  800a0b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a0e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a11:	e9 bb fc ff ff       	jmp    8006d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a21:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a24:	eb 01                	jmp    800a27 <vprintfmt+0x379>
  800a26:	4e                   	dec    %esi
  800a27:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800a2b:	75 f9                	jne    800a26 <vprintfmt+0x378>
  800a2d:	e9 9f fc ff ff       	jmp    8006d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800a32:	83 c4 4c             	add    $0x4c,%esp
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	83 ec 28             	sub    $0x28,%esp
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a46:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a49:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a4d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a57:	85 c0                	test   %eax,%eax
  800a59:	74 30                	je     800a8b <vsnprintf+0x51>
  800a5b:	85 d2                	test   %edx,%edx
  800a5d:	7e 33                	jle    800a92 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a62:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a66:	8b 45 10             	mov    0x10(%ebp),%eax
  800a69:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a74:	c7 04 24 6c 06 80 00 	movl   $0x80066c,(%esp)
  800a7b:	e8 2e fc ff ff       	call   8006ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a83:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a89:	eb 0c                	jmp    800a97 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a90:	eb 05                	jmp    800a97 <vsnprintf+0x5d>
  800a92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a9f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa6:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	89 04 24             	mov    %eax,(%esp)
  800aba:	e8 7b ff ff ff       	call   800a3a <vsnprintf>
	va_end(ap);

	return rc;
}
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    
  800ac1:	00 00                	add    %al,(%eax)
	...

00800ac4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	eb 01                	jmp    800ad2 <strlen+0xe>
		n++;
  800ad1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad6:	75 f9                	jne    800ad1 <strlen+0xd>
		n++;
	return n;
}
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800ae0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae8:	eb 01                	jmp    800aeb <strnlen+0x11>
		n++;
  800aea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aeb:	39 d0                	cmp    %edx,%eax
  800aed:	74 06                	je     800af5 <strnlen+0x1b>
  800aef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800af3:	75 f5                	jne    800aea <strnlen+0x10>
		n++;
	return n;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800b09:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b0c:	42                   	inc    %edx
  800b0d:	84 c9                	test   %cl,%cl
  800b0f:	75 f5                	jne    800b06 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b11:	5b                   	pop    %ebx
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	53                   	push   %ebx
  800b18:	83 ec 08             	sub    $0x8,%esp
  800b1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b1e:	89 1c 24             	mov    %ebx,(%esp)
  800b21:	e8 9e ff ff ff       	call   800ac4 <strlen>
	strcpy(dst + len, src);
  800b26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b29:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b2d:	01 d8                	add    %ebx,%eax
  800b2f:	89 04 24             	mov    %eax,(%esp)
  800b32:	e8 c0 ff ff ff       	call   800af7 <strcpy>
	return dst;
}
  800b37:	89 d8                	mov    %ebx,%eax
  800b39:	83 c4 08             	add    $0x8,%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	eb 0c                	jmp    800b60 <strncpy+0x21>
		*dst++ = *src;
  800b54:	8a 1a                	mov    (%edx),%bl
  800b56:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b59:	80 3a 01             	cmpb   $0x1,(%edx)
  800b5c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b5f:	41                   	inc    %ecx
  800b60:	39 f1                	cmp    %esi,%ecx
  800b62:	75 f0                	jne    800b54 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b76:	85 d2                	test   %edx,%edx
  800b78:	75 0a                	jne    800b84 <strlcpy+0x1c>
  800b7a:	89 f0                	mov    %esi,%eax
  800b7c:	eb 1a                	jmp    800b98 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b7e:	88 18                	mov    %bl,(%eax)
  800b80:	40                   	inc    %eax
  800b81:	41                   	inc    %ecx
  800b82:	eb 02                	jmp    800b86 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b84:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b86:	4a                   	dec    %edx
  800b87:	74 0a                	je     800b93 <strlcpy+0x2b>
  800b89:	8a 19                	mov    (%ecx),%bl
  800b8b:	84 db                	test   %bl,%bl
  800b8d:	75 ef                	jne    800b7e <strlcpy+0x16>
  800b8f:	89 c2                	mov    %eax,%edx
  800b91:	eb 02                	jmp    800b95 <strlcpy+0x2d>
  800b93:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b95:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b98:	29 f0                	sub    %esi,%eax
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ba7:	eb 02                	jmp    800bab <strcmp+0xd>
		p++, q++;
  800ba9:	41                   	inc    %ecx
  800baa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bab:	8a 01                	mov    (%ecx),%al
  800bad:	84 c0                	test   %al,%al
  800baf:	74 04                	je     800bb5 <strcmp+0x17>
  800bb1:	3a 02                	cmp    (%edx),%al
  800bb3:	74 f4                	je     800ba9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb5:	0f b6 c0             	movzbl %al,%eax
  800bb8:	0f b6 12             	movzbl (%edx),%edx
  800bbb:	29 d0                	sub    %edx,%eax
}
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800bcc:	eb 03                	jmp    800bd1 <strncmp+0x12>
		n--, p++, q++;
  800bce:	4a                   	dec    %edx
  800bcf:	40                   	inc    %eax
  800bd0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bd1:	85 d2                	test   %edx,%edx
  800bd3:	74 14                	je     800be9 <strncmp+0x2a>
  800bd5:	8a 18                	mov    (%eax),%bl
  800bd7:	84 db                	test   %bl,%bl
  800bd9:	74 04                	je     800bdf <strncmp+0x20>
  800bdb:	3a 19                	cmp    (%ecx),%bl
  800bdd:	74 ef                	je     800bce <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bdf:	0f b6 00             	movzbl (%eax),%eax
  800be2:	0f b6 11             	movzbl (%ecx),%edx
  800be5:	29 d0                	sub    %edx,%eax
  800be7:	eb 05                	jmp    800bee <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bfa:	eb 05                	jmp    800c01 <strchr+0x10>
		if (*s == c)
  800bfc:	38 ca                	cmp    %cl,%dl
  800bfe:	74 0c                	je     800c0c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c00:	40                   	inc    %eax
  800c01:	8a 10                	mov    (%eax),%dl
  800c03:	84 d2                	test   %dl,%dl
  800c05:	75 f5                	jne    800bfc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	8b 45 08             	mov    0x8(%ebp),%eax
  800c14:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800c17:	eb 05                	jmp    800c1e <strfind+0x10>
		if (*s == c)
  800c19:	38 ca                	cmp    %cl,%dl
  800c1b:	74 07                	je     800c24 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c1d:	40                   	inc    %eax
  800c1e:	8a 10                	mov    (%eax),%dl
  800c20:	84 d2                	test   %dl,%dl
  800c22:	75 f5                	jne    800c19 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c35:	85 c9                	test   %ecx,%ecx
  800c37:	74 30                	je     800c69 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c3f:	75 25                	jne    800c66 <memset+0x40>
  800c41:	f6 c1 03             	test   $0x3,%cl
  800c44:	75 20                	jne    800c66 <memset+0x40>
		c &= 0xFF;
  800c46:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c49:	89 d3                	mov    %edx,%ebx
  800c4b:	c1 e3 08             	shl    $0x8,%ebx
  800c4e:	89 d6                	mov    %edx,%esi
  800c50:	c1 e6 18             	shl    $0x18,%esi
  800c53:	89 d0                	mov    %edx,%eax
  800c55:	c1 e0 10             	shl    $0x10,%eax
  800c58:	09 f0                	or     %esi,%eax
  800c5a:	09 d0                	or     %edx,%eax
  800c5c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c5e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c61:	fc                   	cld    
  800c62:	f3 ab                	rep stos %eax,%es:(%edi)
  800c64:	eb 03                	jmp    800c69 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c66:	fc                   	cld    
  800c67:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c69:	89 f8                	mov    %edi,%eax
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c7e:	39 c6                	cmp    %eax,%esi
  800c80:	73 34                	jae    800cb6 <memmove+0x46>
  800c82:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c85:	39 d0                	cmp    %edx,%eax
  800c87:	73 2d                	jae    800cb6 <memmove+0x46>
		s += n;
		d += n;
  800c89:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8c:	f6 c2 03             	test   $0x3,%dl
  800c8f:	75 1b                	jne    800cac <memmove+0x3c>
  800c91:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c97:	75 13                	jne    800cac <memmove+0x3c>
  800c99:	f6 c1 03             	test   $0x3,%cl
  800c9c:	75 0e                	jne    800cac <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c9e:	83 ef 04             	sub    $0x4,%edi
  800ca1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ca7:	fd                   	std    
  800ca8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800caa:	eb 07                	jmp    800cb3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cac:	4f                   	dec    %edi
  800cad:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cb0:	fd                   	std    
  800cb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb3:	fc                   	cld    
  800cb4:	eb 20                	jmp    800cd6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cbc:	75 13                	jne    800cd1 <memmove+0x61>
  800cbe:	a8 03                	test   $0x3,%al
  800cc0:	75 0f                	jne    800cd1 <memmove+0x61>
  800cc2:	f6 c1 03             	test   $0x3,%cl
  800cc5:	75 0a                	jne    800cd1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cc7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cca:	89 c7                	mov    %eax,%edi
  800ccc:	fc                   	cld    
  800ccd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccf:	eb 05                	jmp    800cd6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd1:	89 c7                	mov    %eax,%edi
  800cd3:	fc                   	cld    
  800cd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ce0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	89 04 24             	mov    %eax,(%esp)
  800cf4:	e8 77 ff ff ff       	call   800c70 <memmove>
}
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	eb 16                	jmp    800d27 <memcmp+0x2c>
		if (*s1 != *s2)
  800d11:	8a 04 17             	mov    (%edi,%edx,1),%al
  800d14:	42                   	inc    %edx
  800d15:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800d19:	38 c8                	cmp    %cl,%al
  800d1b:	74 0a                	je     800d27 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800d1d:	0f b6 c0             	movzbl %al,%eax
  800d20:	0f b6 c9             	movzbl %cl,%ecx
  800d23:	29 c8                	sub    %ecx,%eax
  800d25:	eb 09                	jmp    800d30 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d27:	39 da                	cmp    %ebx,%edx
  800d29:	75 e6                	jne    800d11 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d3e:	89 c2                	mov    %eax,%edx
  800d40:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d43:	eb 05                	jmp    800d4a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d45:	38 08                	cmp    %cl,(%eax)
  800d47:	74 05                	je     800d4e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d49:	40                   	inc    %eax
  800d4a:	39 d0                	cmp    %edx,%eax
  800d4c:	72 f7                	jb     800d45 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5c:	eb 01                	jmp    800d5f <strtol+0xf>
		s++;
  800d5e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5f:	8a 02                	mov    (%edx),%al
  800d61:	3c 20                	cmp    $0x20,%al
  800d63:	74 f9                	je     800d5e <strtol+0xe>
  800d65:	3c 09                	cmp    $0x9,%al
  800d67:	74 f5                	je     800d5e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d69:	3c 2b                	cmp    $0x2b,%al
  800d6b:	75 08                	jne    800d75 <strtol+0x25>
		s++;
  800d6d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d73:	eb 13                	jmp    800d88 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d75:	3c 2d                	cmp    $0x2d,%al
  800d77:	75 0a                	jne    800d83 <strtol+0x33>
		s++, neg = 1;
  800d79:	8d 52 01             	lea    0x1(%edx),%edx
  800d7c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d81:	eb 05                	jmp    800d88 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d88:	85 db                	test   %ebx,%ebx
  800d8a:	74 05                	je     800d91 <strtol+0x41>
  800d8c:	83 fb 10             	cmp    $0x10,%ebx
  800d8f:	75 28                	jne    800db9 <strtol+0x69>
  800d91:	8a 02                	mov    (%edx),%al
  800d93:	3c 30                	cmp    $0x30,%al
  800d95:	75 10                	jne    800da7 <strtol+0x57>
  800d97:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d9b:	75 0a                	jne    800da7 <strtol+0x57>
		s += 2, base = 16;
  800d9d:	83 c2 02             	add    $0x2,%edx
  800da0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800da5:	eb 12                	jmp    800db9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800da7:	85 db                	test   %ebx,%ebx
  800da9:	75 0e                	jne    800db9 <strtol+0x69>
  800dab:	3c 30                	cmp    $0x30,%al
  800dad:	75 05                	jne    800db4 <strtol+0x64>
		s++, base = 8;
  800daf:	42                   	inc    %edx
  800db0:	b3 08                	mov    $0x8,%bl
  800db2:	eb 05                	jmp    800db9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800db4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc0:	8a 0a                	mov    (%edx),%cl
  800dc2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800dc5:	80 fb 09             	cmp    $0x9,%bl
  800dc8:	77 08                	ja     800dd2 <strtol+0x82>
			dig = *s - '0';
  800dca:	0f be c9             	movsbl %cl,%ecx
  800dcd:	83 e9 30             	sub    $0x30,%ecx
  800dd0:	eb 1e                	jmp    800df0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800dd2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800dd5:	80 fb 19             	cmp    $0x19,%bl
  800dd8:	77 08                	ja     800de2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800dda:	0f be c9             	movsbl %cl,%ecx
  800ddd:	83 e9 57             	sub    $0x57,%ecx
  800de0:	eb 0e                	jmp    800df0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800de2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800de5:	80 fb 19             	cmp    $0x19,%bl
  800de8:	77 12                	ja     800dfc <strtol+0xac>
			dig = *s - 'A' + 10;
  800dea:	0f be c9             	movsbl %cl,%ecx
  800ded:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800df0:	39 f1                	cmp    %esi,%ecx
  800df2:	7d 0c                	jge    800e00 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800df4:	42                   	inc    %edx
  800df5:	0f af c6             	imul   %esi,%eax
  800df8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800dfa:	eb c4                	jmp    800dc0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800dfc:	89 c1                	mov    %eax,%ecx
  800dfe:	eb 02                	jmp    800e02 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e00:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800e02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e06:	74 05                	je     800e0d <strtol+0xbd>
		*endptr = (char *) s;
  800e08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e0b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e0d:	85 ff                	test   %edi,%edi
  800e0f:	74 04                	je     800e15 <strtol+0xc5>
  800e11:	89 c8                	mov    %ecx,%eax
  800e13:	f7 d8                	neg    %eax
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
	...

00800e1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e22:	b8 00 00 00 00       	mov    $0x0,%eax
  800e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	89 c3                	mov    %eax,%ebx
  800e2f:	89 c7                	mov    %eax,%edi
  800e31:	89 c6                	mov    %eax,%esi
  800e33:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <sys_cgetc>:

int
sys_cgetc(void)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e40:	ba 00 00 00 00       	mov    $0x0,%edx
  800e45:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4a:	89 d1                	mov    %edx,%ecx
  800e4c:	89 d3                	mov    %edx,%ebx
  800e4e:	89 d7                	mov    %edx,%edi
  800e50:	89 d6                	mov    %edx,%esi
  800e52:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	57                   	push   %edi
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e67:	b8 03 00 00 00       	mov    $0x3,%eax
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	89 cb                	mov    %ecx,%ebx
  800e71:	89 cf                	mov    %ecx,%edi
  800e73:	89 ce                	mov    %ecx,%esi
  800e75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e77:	85 c0                	test   %eax,%eax
  800e79:	7e 28                	jle    800ea3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e86:	00 
  800e87:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e96:	00 
  800e97:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800e9e:	e8 b1 f5 ff ff       	call   800454 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ea3:	83 c4 2c             	add    $0x2c,%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ebb:	89 d1                	mov    %edx,%ecx
  800ebd:	89 d3                	mov    %edx,%ebx
  800ebf:	89 d7                	mov    %edx,%edi
  800ec1:	89 d6                	mov    %edx,%esi
  800ec3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <sys_yield>:

void
sys_yield(void)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eda:	89 d1                	mov    %edx,%ecx
  800edc:	89 d3                	mov    %edx,%ebx
  800ede:	89 d7                	mov    %edx,%edi
  800ee0:	89 d6                	mov    %edx,%esi
  800ee2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef2:	be 00 00 00 00       	mov    $0x0,%esi
  800ef7:	b8 04 00 00 00       	mov    $0x4,%eax
  800efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f02:	8b 55 08             	mov    0x8(%ebp),%edx
  800f05:	89 f7                	mov    %esi,%edi
  800f07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	7e 28                	jle    800f35 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f11:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f18:	00 
  800f19:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800f20:	00 
  800f21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f28:	00 
  800f29:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f30:	e8 1f f5 ff ff       	call   800454 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f35:	83 c4 2c             	add    $0x2c,%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	b8 05 00 00 00       	mov    $0x5,%eax
  800f4b:	8b 75 18             	mov    0x18(%ebp),%esi
  800f4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f57:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	7e 28                	jle    800f88 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f64:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800f83:	e8 cc f4 ff ff       	call   800454 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f88:	83 c4 2c             	add    $0x2c,%esp
  800f8b:	5b                   	pop    %ebx
  800f8c:	5e                   	pop    %esi
  800f8d:	5f                   	pop    %edi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa9:	89 df                	mov    %ebx,%edi
  800fab:	89 de                	mov    %ebx,%esi
  800fad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	7e 28                	jle    800fdb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  800fc6:	00 
  800fc7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fce:	00 
  800fcf:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  800fd6:	e8 79 f4 ff ff       	call   800454 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fdb:	83 c4 2c             	add    $0x2c,%esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800fec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ff6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	89 df                	mov    %ebx,%edi
  800ffe:	89 de                	mov    %ebx,%esi
  801000:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801002:	85 c0                	test   %eax,%eax
  801004:	7e 28                	jle    80102e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801006:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801011:	00 
  801012:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801019:	00 
  80101a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801021:	00 
  801022:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  801029:	e8 26 f4 ff ff       	call   800454 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80102e:	83 c4 2c             	add    $0x2c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
  80103c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801044:	b8 09 00 00 00       	mov    $0x9,%eax
  801049:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104c:	8b 55 08             	mov    0x8(%ebp),%edx
  80104f:	89 df                	mov    %ebx,%edi
  801051:	89 de                	mov    %ebx,%esi
  801053:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801055:	85 c0                	test   %eax,%eax
  801057:	7e 28                	jle    801081 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801059:	89 44 24 10          	mov    %eax,0x10(%esp)
  80105d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801064:	00 
  801065:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  80106c:	00 
  80106d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801074:	00 
  801075:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  80107c:	e8 d3 f3 ff ff       	call   800454 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801081:	83 c4 2c             	add    $0x2c,%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5f                   	pop    %edi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	57                   	push   %edi
  80108d:	56                   	push   %esi
  80108e:	53                   	push   %ebx
  80108f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801092:	bb 00 00 00 00       	mov    $0x0,%ebx
  801097:	b8 0a 00 00 00       	mov    $0xa,%eax
  80109c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109f:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a2:	89 df                	mov    %ebx,%edi
  8010a4:	89 de                	mov    %ebx,%esi
  8010a6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	7e 28                	jle    8010d4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8010b7:	00 
  8010b8:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c7:	00 
  8010c8:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  8010cf:	e8 80 f3 ff ff       	call   800454 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010d4:	83 c4 2c             	add    $0x2c,%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e2:	be 00 00 00 00       	mov    $0x0,%esi
  8010e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010ec:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801108:	b9 00 00 00 00       	mov    $0x0,%ecx
  80110d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801112:	8b 55 08             	mov    0x8(%ebp),%edx
  801115:	89 cb                	mov    %ecx,%ebx
  801117:	89 cf                	mov    %ecx,%edi
  801119:	89 ce                	mov    %ecx,%esi
  80111b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80111d:	85 c0                	test   %eax,%eax
  80111f:	7e 28                	jle    801149 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801121:	89 44 24 10          	mov    %eax,0x10(%esp)
  801125:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80112c:	00 
  80112d:	c7 44 24 08 9f 2b 80 	movl   $0x802b9f,0x8(%esp)
  801134:	00 
  801135:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80113c:	00 
  80113d:	c7 04 24 bc 2b 80 00 	movl   $0x802bbc,(%esp)
  801144:	e8 0b f3 ff ff       	call   800454 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801149:	83 c4 2c             	add    $0x2c,%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    
  801151:	00 00                	add    %al,(%eax)
	...

00801154 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801157:	8b 45 08             	mov    0x8(%ebp),%eax
  80115a:	05 00 00 00 30       	add    $0x30000000,%eax
  80115f:	c1 e8 0c             	shr    $0xc,%eax
}
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
  80116d:	89 04 24             	mov    %eax,(%esp)
  801170:	e8 df ff ff ff       	call   801154 <fd2num>
  801175:	05 20 00 0d 00       	add    $0xd0020,%eax
  80117a:	c1 e0 0c             	shl    $0xc,%eax
}
  80117d:	c9                   	leave  
  80117e:	c3                   	ret    

0080117f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	53                   	push   %ebx
  801183:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801186:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80118b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	c1 ea 16             	shr    $0x16,%edx
  801192:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801199:	f6 c2 01             	test   $0x1,%dl
  80119c:	74 11                	je     8011af <fd_alloc+0x30>
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	c1 ea 0c             	shr    $0xc,%edx
  8011a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011aa:	f6 c2 01             	test   $0x1,%dl
  8011ad:	75 09                	jne    8011b8 <fd_alloc+0x39>
			*fd_store = fd;
  8011af:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b6:	eb 17                	jmp    8011cf <fd_alloc+0x50>
  8011b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c2:	75 c7                	jne    80118b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011cf:	5b                   	pop    %ebx
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d8:	83 f8 1f             	cmp    $0x1f,%eax
  8011db:	77 36                	ja     801213 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011dd:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011e2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e5:	89 c2                	mov    %eax,%edx
  8011e7:	c1 ea 16             	shr    $0x16,%edx
  8011ea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f1:	f6 c2 01             	test   $0x1,%dl
  8011f4:	74 24                	je     80121a <fd_lookup+0x48>
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	c1 ea 0c             	shr    $0xc,%edx
  8011fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801202:	f6 c2 01             	test   $0x1,%dl
  801205:	74 1a                	je     801221 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801207:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120a:	89 02                	mov    %eax,(%edx)
	return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
  801211:	eb 13                	jmp    801226 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801213:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801218:	eb 0c                	jmp    801226 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80121a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121f:	eb 05                	jmp    801226 <fd_lookup+0x54>
  801221:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 14             	sub    $0x14,%esp
  80122f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801235:	ba 00 00 00 00       	mov    $0x0,%edx
  80123a:	eb 0e                	jmp    80124a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80123c:	39 08                	cmp    %ecx,(%eax)
  80123e:	75 09                	jne    801249 <dev_lookup+0x21>
			*dev = devtab[i];
  801240:	89 03                	mov    %eax,(%ebx)
			return 0;
  801242:	b8 00 00 00 00       	mov    $0x0,%eax
  801247:	eb 33                	jmp    80127c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801249:	42                   	inc    %edx
  80124a:	8b 04 95 48 2c 80 00 	mov    0x802c48(,%edx,4),%eax
  801251:	85 c0                	test   %eax,%eax
  801253:	75 e7                	jne    80123c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801255:	a1 90 67 80 00       	mov    0x806790,%eax
  80125a:	8b 40 48             	mov    0x48(%eax),%eax
  80125d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801261:	89 44 24 04          	mov    %eax,0x4(%esp)
  801265:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  80126c:	e8 db f2 ff ff       	call   80054c <cprintf>
	*dev = 0;
  801271:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801277:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80127c:	83 c4 14             	add    $0x14,%esp
  80127f:	5b                   	pop    %ebx
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
  801287:	83 ec 30             	sub    $0x30,%esp
  80128a:	8b 75 08             	mov    0x8(%ebp),%esi
  80128d:	8a 45 0c             	mov    0xc(%ebp),%al
  801290:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801293:	89 34 24             	mov    %esi,(%esp)
  801296:	e8 b9 fe ff ff       	call   801154 <fd2num>
  80129b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80129e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012a2:	89 04 24             	mov    %eax,(%esp)
  8012a5:	e8 28 ff ff ff       	call   8011d2 <fd_lookup>
  8012aa:	89 c3                	mov    %eax,%ebx
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 05                	js     8012b5 <fd_close+0x33>
	    || fd != fd2)
  8012b0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012b3:	74 0d                	je     8012c2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8012b5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012b9:	75 46                	jne    801301 <fd_close+0x7f>
  8012bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c0:	eb 3f                	jmp    801301 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c9:	8b 06                	mov    (%esi),%eax
  8012cb:	89 04 24             	mov    %eax,(%esp)
  8012ce:	e8 55 ff ff ff       	call   801228 <dev_lookup>
  8012d3:	89 c3                	mov    %eax,%ebx
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 18                	js     8012f1 <fd_close+0x6f>
		if (dev->dev_close)
  8012d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012dc:	8b 40 10             	mov    0x10(%eax),%eax
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	74 09                	je     8012ec <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012e3:	89 34 24             	mov    %esi,(%esp)
  8012e6:	ff d0                	call   *%eax
  8012e8:	89 c3                	mov    %eax,%ebx
  8012ea:	eb 05                	jmp    8012f1 <fd_close+0x6f>
		else
			r = 0;
  8012ec:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012fc:	e8 8f fc ff ff       	call   800f90 <sys_page_unmap>
	return r;
}
  801301:	89 d8                	mov    %ebx,%eax
  801303:	83 c4 30             	add    $0x30,%esp
  801306:	5b                   	pop    %ebx
  801307:	5e                   	pop    %esi
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    

0080130a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80130a:	55                   	push   %ebp
  80130b:	89 e5                	mov    %esp,%ebp
  80130d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801310:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801313:	89 44 24 04          	mov    %eax,0x4(%esp)
  801317:	8b 45 08             	mov    0x8(%ebp),%eax
  80131a:	89 04 24             	mov    %eax,(%esp)
  80131d:	e8 b0 fe ff ff       	call   8011d2 <fd_lookup>
  801322:	85 c0                	test   %eax,%eax
  801324:	78 13                	js     801339 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801326:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80132d:	00 
  80132e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801331:	89 04 24             	mov    %eax,(%esp)
  801334:	e8 49 ff ff ff       	call   801282 <fd_close>
}
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <close_all>:

void
close_all(void)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	53                   	push   %ebx
  80133f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801342:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801347:	89 1c 24             	mov    %ebx,(%esp)
  80134a:	e8 bb ff ff ff       	call   80130a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80134f:	43                   	inc    %ebx
  801350:	83 fb 20             	cmp    $0x20,%ebx
  801353:	75 f2                	jne    801347 <close_all+0xc>
		close(i);
}
  801355:	83 c4 14             	add    $0x14,%esp
  801358:	5b                   	pop    %ebx
  801359:	5d                   	pop    %ebp
  80135a:	c3                   	ret    

0080135b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	57                   	push   %edi
  80135f:	56                   	push   %esi
  801360:	53                   	push   %ebx
  801361:	83 ec 4c             	sub    $0x4c,%esp
  801364:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801367:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80136a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	89 04 24             	mov    %eax,(%esp)
  801374:	e8 59 fe ff ff       	call   8011d2 <fd_lookup>
  801379:	89 c3                	mov    %eax,%ebx
  80137b:	85 c0                	test   %eax,%eax
  80137d:	0f 88 e1 00 00 00    	js     801464 <dup+0x109>
		return r;
	close(newfdnum);
  801383:	89 3c 24             	mov    %edi,(%esp)
  801386:	e8 7f ff ff ff       	call   80130a <close>

	newfd = INDEX2FD(newfdnum);
  80138b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801391:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801394:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801397:	89 04 24             	mov    %eax,(%esp)
  80139a:	e8 c5 fd ff ff       	call   801164 <fd2data>
  80139f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013a1:	89 34 24             	mov    %esi,(%esp)
  8013a4:	e8 bb fd ff ff       	call   801164 <fd2data>
  8013a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ac:	89 d8                	mov    %ebx,%eax
  8013ae:	c1 e8 16             	shr    $0x16,%eax
  8013b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013b8:	a8 01                	test   $0x1,%al
  8013ba:	74 46                	je     801402 <dup+0xa7>
  8013bc:	89 d8                	mov    %ebx,%eax
  8013be:	c1 e8 0c             	shr    $0xc,%eax
  8013c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c8:	f6 c2 01             	test   $0x1,%dl
  8013cb:	74 35                	je     801402 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013eb:	00 
  8013ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f7:	e8 41 fb ff ff       	call   800f3d <sys_page_map>
  8013fc:	89 c3                	mov    %eax,%ebx
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 3b                	js     80143d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801402:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801405:	89 c2                	mov    %eax,%edx
  801407:	c1 ea 0c             	shr    $0xc,%edx
  80140a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801411:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801417:	89 54 24 10          	mov    %edx,0x10(%esp)
  80141b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80141f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801426:	00 
  801427:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801432:	e8 06 fb ff ff       	call   800f3d <sys_page_map>
  801437:	89 c3                	mov    %eax,%ebx
  801439:	85 c0                	test   %eax,%eax
  80143b:	79 25                	jns    801462 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80143d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801441:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801448:	e8 43 fb ff ff       	call   800f90 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80144d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801450:	89 44 24 04          	mov    %eax,0x4(%esp)
  801454:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145b:	e8 30 fb ff ff       	call   800f90 <sys_page_unmap>
	return r;
  801460:	eb 02                	jmp    801464 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801462:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801464:	89 d8                	mov    %ebx,%eax
  801466:	83 c4 4c             	add    $0x4c,%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	5f                   	pop    %edi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	53                   	push   %ebx
  801472:	83 ec 24             	sub    $0x24,%esp
  801475:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801478:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147f:	89 1c 24             	mov    %ebx,(%esp)
  801482:	e8 4b fd ff ff       	call   8011d2 <fd_lookup>
  801487:	85 c0                	test   %eax,%eax
  801489:	78 6d                	js     8014f8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801492:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801495:	8b 00                	mov    (%eax),%eax
  801497:	89 04 24             	mov    %eax,(%esp)
  80149a:	e8 89 fd ff ff       	call   801228 <dev_lookup>
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 55                	js     8014f8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a6:	8b 50 08             	mov    0x8(%eax),%edx
  8014a9:	83 e2 03             	and    $0x3,%edx
  8014ac:	83 fa 01             	cmp    $0x1,%edx
  8014af:	75 23                	jne    8014d4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b1:	a1 90 67 80 00       	mov    0x806790,%eax
  8014b6:	8b 40 48             	mov    0x48(%eax),%eax
  8014b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c1:	c7 04 24 0d 2c 80 00 	movl   $0x802c0d,(%esp)
  8014c8:	e8 7f f0 ff ff       	call   80054c <cprintf>
		return -E_INVAL;
  8014cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d2:	eb 24                	jmp    8014f8 <read+0x8a>
	}
	if (!dev->dev_read)
  8014d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d7:	8b 52 08             	mov    0x8(%edx),%edx
  8014da:	85 d2                	test   %edx,%edx
  8014dc:	74 15                	je     8014f3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014ec:	89 04 24             	mov    %eax,(%esp)
  8014ef:	ff d2                	call   *%edx
  8014f1:	eb 05                	jmp    8014f8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014f8:	83 c4 24             	add    $0x24,%esp
  8014fb:	5b                   	pop    %ebx
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	83 ec 1c             	sub    $0x1c,%esp
  801507:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801512:	eb 23                	jmp    801537 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801514:	89 f0                	mov    %esi,%eax
  801516:	29 d8                	sub    %ebx,%eax
  801518:	89 44 24 08          	mov    %eax,0x8(%esp)
  80151c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151f:	01 d8                	add    %ebx,%eax
  801521:	89 44 24 04          	mov    %eax,0x4(%esp)
  801525:	89 3c 24             	mov    %edi,(%esp)
  801528:	e8 41 ff ff ff       	call   80146e <read>
		if (m < 0)
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 10                	js     801541 <readn+0x43>
			return m;
		if (m == 0)
  801531:	85 c0                	test   %eax,%eax
  801533:	74 0a                	je     80153f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801535:	01 c3                	add    %eax,%ebx
  801537:	39 f3                	cmp    %esi,%ebx
  801539:	72 d9                	jb     801514 <readn+0x16>
  80153b:	89 d8                	mov    %ebx,%eax
  80153d:	eb 02                	jmp    801541 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80153f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801541:	83 c4 1c             	add    $0x1c,%esp
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	5f                   	pop    %edi
  801547:	5d                   	pop    %ebp
  801548:	c3                   	ret    

00801549 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	53                   	push   %ebx
  80154d:	83 ec 24             	sub    $0x24,%esp
  801550:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801553:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801556:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155a:	89 1c 24             	mov    %ebx,(%esp)
  80155d:	e8 70 fc ff ff       	call   8011d2 <fd_lookup>
  801562:	85 c0                	test   %eax,%eax
  801564:	78 68                	js     8015ce <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801566:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801570:	8b 00                	mov    (%eax),%eax
  801572:	89 04 24             	mov    %eax,(%esp)
  801575:	e8 ae fc ff ff       	call   801228 <dev_lookup>
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 50                	js     8015ce <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801581:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801585:	75 23                	jne    8015aa <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801587:	a1 90 67 80 00       	mov    0x806790,%eax
  80158c:	8b 40 48             	mov    0x48(%eax),%eax
  80158f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801593:	89 44 24 04          	mov    %eax,0x4(%esp)
  801597:	c7 04 24 29 2c 80 00 	movl   $0x802c29,(%esp)
  80159e:	e8 a9 ef ff ff       	call   80054c <cprintf>
		return -E_INVAL;
  8015a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a8:	eb 24                	jmp    8015ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b0:	85 d2                	test   %edx,%edx
  8015b2:	74 15                	je     8015c9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015c2:	89 04 24             	mov    %eax,(%esp)
  8015c5:	ff d2                	call   *%edx
  8015c7:	eb 05                	jmp    8015ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015ce:	83 c4 24             	add    $0x24,%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5d                   	pop    %ebp
  8015d3:	c3                   	ret    

008015d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e4:	89 04 24             	mov    %eax,(%esp)
  8015e7:	e8 e6 fb ff ff       	call   8011d2 <fd_lookup>
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 0e                	js     8015fe <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	53                   	push   %ebx
  801604:	83 ec 24             	sub    $0x24,%esp
  801607:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801611:	89 1c 24             	mov    %ebx,(%esp)
  801614:	e8 b9 fb ff ff       	call   8011d2 <fd_lookup>
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 61                	js     80167e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801620:	89 44 24 04          	mov    %eax,0x4(%esp)
  801624:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801627:	8b 00                	mov    (%eax),%eax
  801629:	89 04 24             	mov    %eax,(%esp)
  80162c:	e8 f7 fb ff ff       	call   801228 <dev_lookup>
  801631:	85 c0                	test   %eax,%eax
  801633:	78 49                	js     80167e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801635:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801638:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80163c:	75 23                	jne    801661 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80163e:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801643:	8b 40 48             	mov    0x48(%eax),%eax
  801646:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80164a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164e:	c7 04 24 ec 2b 80 00 	movl   $0x802bec,(%esp)
  801655:	e8 f2 ee ff ff       	call   80054c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80165a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80165f:	eb 1d                	jmp    80167e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801661:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801664:	8b 52 18             	mov    0x18(%edx),%edx
  801667:	85 d2                	test   %edx,%edx
  801669:	74 0e                	je     801679 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80166b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80166e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801672:	89 04 24             	mov    %eax,(%esp)
  801675:	ff d2                	call   *%edx
  801677:	eb 05                	jmp    80167e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801679:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80167e:	83 c4 24             	add    $0x24,%esp
  801681:	5b                   	pop    %ebx
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	53                   	push   %ebx
  801688:	83 ec 24             	sub    $0x24,%esp
  80168b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801691:	89 44 24 04          	mov    %eax,0x4(%esp)
  801695:	8b 45 08             	mov    0x8(%ebp),%eax
  801698:	89 04 24             	mov    %eax,(%esp)
  80169b:	e8 32 fb ff ff       	call   8011d2 <fd_lookup>
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	78 52                	js     8016f6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ae:	8b 00                	mov    (%eax),%eax
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	e8 70 fb ff ff       	call   801228 <dev_lookup>
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 3a                	js     8016f6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8016bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c3:	74 2c                	je     8016f1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016cf:	00 00 00 
	stat->st_isdir = 0;
  8016d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d9:	00 00 00 
	stat->st_dev = dev;
  8016dc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016e9:	89 14 24             	mov    %edx,(%esp)
  8016ec:	ff 50 14             	call   *0x14(%eax)
  8016ef:	eb 05                	jmp    8016f6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016f6:	83 c4 24             	add    $0x24,%esp
  8016f9:	5b                   	pop    %ebx
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801704:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80170b:	00 
  80170c:	8b 45 08             	mov    0x8(%ebp),%eax
  80170f:	89 04 24             	mov    %eax,(%esp)
  801712:	e8 fe 01 00 00       	call   801915 <open>
  801717:	89 c3                	mov    %eax,%ebx
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 1b                	js     801738 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80171d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801720:	89 44 24 04          	mov    %eax,0x4(%esp)
  801724:	89 1c 24             	mov    %ebx,(%esp)
  801727:	e8 58 ff ff ff       	call   801684 <fstat>
  80172c:	89 c6                	mov    %eax,%esi
	close(fd);
  80172e:	89 1c 24             	mov    %ebx,(%esp)
  801731:	e8 d4 fb ff ff       	call   80130a <close>
	return r;
  801736:	89 f3                	mov    %esi,%ebx
}
  801738:	89 d8                	mov    %ebx,%eax
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	5b                   	pop    %ebx
  80173e:	5e                   	pop    %esi
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    
  801741:	00 00                	add    %al,(%eax)
	...

00801744 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	56                   	push   %esi
  801748:	53                   	push   %ebx
  801749:	83 ec 10             	sub    $0x10,%esp
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801750:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801757:	75 11                	jne    80176a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801759:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801760:	e8 d2 0c 00 00       	call   802437 <ipc_find_env>
  801765:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80176a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801771:	00 
  801772:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801779:	00 
  80177a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80177e:	a1 00 50 80 00       	mov    0x805000,%eax
  801783:	89 04 24             	mov    %eax,(%esp)
  801786:	e8 42 0c 00 00       	call   8023cd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80178b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801792:	00 
  801793:	89 74 24 04          	mov    %esi,0x4(%esp)
  801797:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179e:	e8 c1 0b 00 00       	call   802364 <ipc_recv>
}
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	5b                   	pop    %ebx
  8017a7:	5e                   	pop    %esi
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b6:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8017bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017be:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017cd:	e8 72 ff ff ff       	call   801744 <fsipc>
}
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e0:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ef:	e8 50 ff ff ff       	call   801744 <fsipc>
}
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	53                   	push   %ebx
  8017fa:	83 ec 14             	sub    $0x14,%esp
  8017fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801800:	8b 45 08             	mov    0x8(%ebp),%eax
  801803:	8b 40 0c             	mov    0xc(%eax),%eax
  801806:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80180b:	ba 00 00 00 00       	mov    $0x0,%edx
  801810:	b8 05 00 00 00       	mov    $0x5,%eax
  801815:	e8 2a ff ff ff       	call   801744 <fsipc>
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 2b                	js     801849 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80181e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801825:	00 
  801826:	89 1c 24             	mov    %ebx,(%esp)
  801829:	e8 c9 f2 ff ff       	call   800af7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80182e:	a1 80 70 80 00       	mov    0x807080,%eax
  801833:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801839:	a1 84 70 80 00       	mov    0x807084,%eax
  80183e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801844:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801849:	83 c4 14             	add    $0x14,%esp
  80184c:	5b                   	pop    %ebx
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801855:	c7 44 24 08 58 2c 80 	movl   $0x802c58,0x8(%esp)
  80185c:	00 
  80185d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801864:	00 
  801865:	c7 04 24 76 2c 80 00 	movl   $0x802c76,(%esp)
  80186c:	e8 e3 eb ff ff       	call   800454 <_panic>

00801871 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	56                   	push   %esi
  801875:	53                   	push   %ebx
  801876:	83 ec 10             	sub    $0x10,%esp
  801879:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187c:	8b 45 08             	mov    0x8(%ebp),%eax
  80187f:	8b 40 0c             	mov    0xc(%eax),%eax
  801882:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801887:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188d:	ba 00 00 00 00       	mov    $0x0,%edx
  801892:	b8 03 00 00 00       	mov    $0x3,%eax
  801897:	e8 a8 fe ff ff       	call   801744 <fsipc>
  80189c:	89 c3                	mov    %eax,%ebx
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 6a                	js     80190c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8018a2:	39 c6                	cmp    %eax,%esi
  8018a4:	73 24                	jae    8018ca <devfile_read+0x59>
  8018a6:	c7 44 24 0c 81 2c 80 	movl   $0x802c81,0xc(%esp)
  8018ad:	00 
  8018ae:	c7 44 24 08 88 2c 80 	movl   $0x802c88,0x8(%esp)
  8018b5:	00 
  8018b6:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8018bd:	00 
  8018be:	c7 04 24 76 2c 80 00 	movl   $0x802c76,(%esp)
  8018c5:	e8 8a eb ff ff       	call   800454 <_panic>
	assert(r <= PGSIZE);
  8018ca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018cf:	7e 24                	jle    8018f5 <devfile_read+0x84>
  8018d1:	c7 44 24 0c 9d 2c 80 	movl   $0x802c9d,0xc(%esp)
  8018d8:	00 
  8018d9:	c7 44 24 08 88 2c 80 	movl   $0x802c88,0x8(%esp)
  8018e0:	00 
  8018e1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8018e8:	00 
  8018e9:	c7 04 24 76 2c 80 00 	movl   $0x802c76,(%esp)
  8018f0:	e8 5f eb ff ff       	call   800454 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018f9:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801900:	00 
  801901:	8b 45 0c             	mov    0xc(%ebp),%eax
  801904:	89 04 24             	mov    %eax,(%esp)
  801907:	e8 64 f3 ff ff       	call   800c70 <memmove>
	return r;
}
  80190c:	89 d8                	mov    %ebx,%eax
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	5b                   	pop    %ebx
  801912:	5e                   	pop    %esi
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	83 ec 20             	sub    $0x20,%esp
  80191d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801920:	89 34 24             	mov    %esi,(%esp)
  801923:	e8 9c f1 ff ff       	call   800ac4 <strlen>
  801928:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80192d:	7f 60                	jg     80198f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80192f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801932:	89 04 24             	mov    %eax,(%esp)
  801935:	e8 45 f8 ff ff       	call   80117f <fd_alloc>
  80193a:	89 c3                	mov    %eax,%ebx
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 54                	js     801994 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801940:	89 74 24 04          	mov    %esi,0x4(%esp)
  801944:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  80194b:	e8 a7 f1 ff ff       	call   800af7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801950:	8b 45 0c             	mov    0xc(%ebp),%eax
  801953:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801958:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80195b:	b8 01 00 00 00       	mov    $0x1,%eax
  801960:	e8 df fd ff ff       	call   801744 <fsipc>
  801965:	89 c3                	mov    %eax,%ebx
  801967:	85 c0                	test   %eax,%eax
  801969:	79 15                	jns    801980 <open+0x6b>
		fd_close(fd, 0);
  80196b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801972:	00 
  801973:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801976:	89 04 24             	mov    %eax,(%esp)
  801979:	e8 04 f9 ff ff       	call   801282 <fd_close>
		return r;
  80197e:	eb 14                	jmp    801994 <open+0x7f>
	}

	return fd2num(fd);
  801980:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801983:	89 04 24             	mov    %eax,(%esp)
  801986:	e8 c9 f7 ff ff       	call   801154 <fd2num>
  80198b:	89 c3                	mov    %eax,%ebx
  80198d:	eb 05                	jmp    801994 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80198f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801994:	89 d8                	mov    %ebx,%eax
  801996:	83 c4 20             	add    $0x20,%esp
  801999:	5b                   	pop    %ebx
  80199a:	5e                   	pop    %esi
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    

0080199d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ad:	e8 92 fd ff ff       	call   801744 <fsipc>
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	57                   	push   %edi
  8019b8:	56                   	push   %esi
  8019b9:	53                   	push   %ebx
  8019ba:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019c7:	00 
  8019c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cb:	89 04 24             	mov    %eax,(%esp)
  8019ce:	e8 42 ff ff ff       	call   801915 <open>
  8019d3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	0f 88 05 05 00 00    	js     801ee6 <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019e1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8019e8:	00 
  8019e9:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8019f9:	89 04 24             	mov    %eax,(%esp)
  8019fc:	e8 fd fa ff ff       	call   8014fe <readn>
  801a01:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a06:	75 0c                	jne    801a14 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801a08:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a0f:	45 4c 46 
  801a12:	74 3b                	je     801a4f <spawn+0x9b>
		close(fd);
  801a14:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a1a:	89 04 24             	mov    %eax,(%esp)
  801a1d:	e8 e8 f8 ff ff       	call   80130a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a22:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801a29:	46 
  801a2a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801a30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a34:	c7 04 24 a9 2c 80 00 	movl   $0x802ca9,(%esp)
  801a3b:	e8 0c eb ff ff       	call   80054c <cprintf>
		return -E_NOT_EXEC;
  801a40:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801a47:	ff ff ff 
  801a4a:	e9 a3 04 00 00       	jmp    801ef2 <spawn+0x53e>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801a4f:	ba 07 00 00 00       	mov    $0x7,%edx
  801a54:	89 d0                	mov    %edx,%eax
  801a56:	cd 30                	int    $0x30
  801a58:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a5e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a64:	85 c0                	test   %eax,%eax
  801a66:	0f 88 86 04 00 00    	js     801ef2 <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a6c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801a78:	c1 e0 07             	shl    $0x7,%eax
  801a7b:	29 d0                	sub    %edx,%eax
  801a7d:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801a83:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a89:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a90:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a96:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a9c:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801aa1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aa6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aa9:	eb 0d                	jmp    801ab8 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801aab:	89 04 24             	mov    %eax,(%esp)
  801aae:	e8 11 f0 ff ff       	call   800ac4 <strlen>
  801ab3:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ab7:	46                   	inc    %esi
  801ab8:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801aba:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ac1:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	75 e3                	jne    801aab <spawn+0xf7>
  801ac8:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801ace:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ad4:	bf 00 10 40 00       	mov    $0x401000,%edi
  801ad9:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801adb:	89 f8                	mov    %edi,%eax
  801add:	83 e0 fc             	and    $0xfffffffc,%eax
  801ae0:	f7 d2                	not    %edx
  801ae2:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801ae5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801aeb:	89 d0                	mov    %edx,%eax
  801aed:	83 e8 08             	sub    $0x8,%eax
  801af0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801af5:	0f 86 08 04 00 00    	jbe    801f03 <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801afb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b02:	00 
  801b03:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b0a:	00 
  801b0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b12:	e8 d2 f3 ff ff       	call   800ee9 <sys_page_alloc>
  801b17:	85 c0                	test   %eax,%eax
  801b19:	0f 88 e9 03 00 00    	js     801f08 <spawn+0x554>
  801b1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b24:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801b2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b2d:	eb 2e                	jmp    801b5d <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801b2f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b35:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b3b:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801b3e:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801b41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b45:	89 3c 24             	mov    %edi,(%esp)
  801b48:	e8 aa ef ff ff       	call   800af7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b4d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801b50:	89 04 24             	mov    %eax,(%esp)
  801b53:	e8 6c ef ff ff       	call   800ac4 <strlen>
  801b58:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b5c:	43                   	inc    %ebx
  801b5d:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801b63:	7c ca                	jl     801b2f <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b65:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b6b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b71:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b78:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b7e:	74 24                	je     801ba4 <spawn+0x1f0>
  801b80:	c7 44 24 0c 20 2d 80 	movl   $0x802d20,0xc(%esp)
  801b87:	00 
  801b88:	c7 44 24 08 88 2c 80 	movl   $0x802c88,0x8(%esp)
  801b8f:	00 
  801b90:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801b97:	00 
  801b98:	c7 04 24 c3 2c 80 00 	movl   $0x802cc3,(%esp)
  801b9f:	e8 b0 e8 ff ff       	call   800454 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ba4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801baa:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801baf:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801bb5:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801bb8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bbe:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801bc1:	89 d0                	mov    %edx,%eax
  801bc3:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801bc8:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801bce:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801bd5:	00 
  801bd6:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801bdd:	ee 
  801bde:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801be4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bef:	00 
  801bf0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf7:	e8 41 f3 ff ff       	call   800f3d <sys_page_map>
  801bfc:	89 c3                	mov    %eax,%ebx
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	78 1a                	js     801c1c <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c02:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c09:	00 
  801c0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c11:	e8 7a f3 ff ff       	call   800f90 <sys_page_unmap>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	79 1f                	jns    801c3b <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801c1c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c23:	00 
  801c24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c2b:	e8 60 f3 ff ff       	call   800f90 <sys_page_unmap>
	return r;
  801c30:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801c36:	e9 b7 02 00 00       	jmp    801ef2 <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c3b:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801c41:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801c47:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c4d:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801c54:	00 00 00 
  801c57:	e9 bb 01 00 00       	jmp    801e17 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  801c5c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c62:	83 38 01             	cmpl   $0x1,(%eax)
  801c65:	0f 85 9f 01 00 00    	jne    801e0a <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c6b:	89 c2                	mov    %eax,%edx
  801c6d:	8b 40 18             	mov    0x18(%eax),%eax
  801c70:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801c73:	83 f8 01             	cmp    $0x1,%eax
  801c76:	19 c0                	sbb    %eax,%eax
  801c78:	83 e0 fe             	and    $0xfffffffe,%eax
  801c7b:	83 c0 07             	add    $0x7,%eax
  801c7e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c84:	8b 52 04             	mov    0x4(%edx),%edx
  801c87:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801c8d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c93:	8b 40 10             	mov    0x10(%eax),%eax
  801c96:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c9c:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801ca2:	8b 52 14             	mov    0x14(%edx),%edx
  801ca5:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801cab:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cb1:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801cb4:	89 f8                	mov    %edi,%eax
  801cb6:	25 ff 0f 00 00       	and    $0xfff,%eax
  801cbb:	74 16                	je     801cd3 <spawn+0x31f>
		va -= i;
  801cbd:	29 c7                	sub    %eax,%edi
		memsz += i;
  801cbf:	01 c2                	add    %eax,%edx
  801cc1:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801cc7:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801ccd:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd8:	e9 1f 01 00 00       	jmp    801dfc <spawn+0x448>
		if (i >= filesz) {
  801cdd:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801ce3:	77 2b                	ja     801d10 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ce5:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801ceb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cef:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cf3:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801cf9:	89 04 24             	mov    %eax,(%esp)
  801cfc:	e8 e8 f1 ff ff       	call   800ee9 <sys_page_alloc>
  801d01:	85 c0                	test   %eax,%eax
  801d03:	0f 89 e7 00 00 00    	jns    801df0 <spawn+0x43c>
  801d09:	89 c6                	mov    %eax,%esi
  801d0b:	e9 b2 01 00 00       	jmp    801ec2 <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d10:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801d17:	00 
  801d18:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d1f:	00 
  801d20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d27:	e8 bd f1 ff ff       	call   800ee9 <sys_page_alloc>
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	0f 88 84 01 00 00    	js     801eb8 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801d34:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801d3a:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d40:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d46:	89 04 24             	mov    %eax,(%esp)
  801d49:	e8 86 f8 ff ff       	call   8015d4 <seek>
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	0f 88 66 01 00 00    	js     801ebc <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801d56:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d5c:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d5e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d63:	76 05                	jbe    801d6a <spawn+0x3b6>
  801d65:	b8 00 10 00 00       	mov    $0x1000,%eax
  801d6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d6e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d75:	00 
  801d76:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d7c:	89 04 24             	mov    %eax,(%esp)
  801d7f:	e8 7a f7 ff ff       	call   8014fe <readn>
  801d84:	85 c0                	test   %eax,%eax
  801d86:	0f 88 34 01 00 00    	js     801ec0 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d8c:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801d92:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d96:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d9a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801da0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801dab:	00 
  801dac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db3:	e8 85 f1 ff ff       	call   800f3d <sys_page_map>
  801db8:	85 c0                	test   %eax,%eax
  801dba:	79 20                	jns    801ddc <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801dbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dc0:	c7 44 24 08 cf 2c 80 	movl   $0x802ccf,0x8(%esp)
  801dc7:	00 
  801dc8:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801dcf:	00 
  801dd0:	c7 04 24 c3 2c 80 00 	movl   $0x802cc3,(%esp)
  801dd7:	e8 78 e6 ff ff       	call   800454 <_panic>
			sys_page_unmap(0, UTEMP);
  801ddc:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801de3:	00 
  801de4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801deb:	e8 a0 f1 ff ff       	call   800f90 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801df0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801df6:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801dfc:	89 de                	mov    %ebx,%esi
  801dfe:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801e04:	0f 87 d3 fe ff ff    	ja     801cdd <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e0a:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801e10:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801e17:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801e1e:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801e24:	0f 8c 32 fe ff ff    	jl     801c5c <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801e2a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e30:	89 04 24             	mov    %eax,(%esp)
  801e33:	e8 d2 f4 ff ff       	call   80130a <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e38:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e3f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e42:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4c:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e52:	89 04 24             	mov    %eax,(%esp)
  801e55:	e8 dc f1 ff ff       	call   801036 <sys_env_set_trapframe>
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	79 20                	jns    801e7e <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  801e5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e62:	c7 44 24 08 ec 2c 80 	movl   $0x802cec,0x8(%esp)
  801e69:	00 
  801e6a:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801e71:	00 
  801e72:	c7 04 24 c3 2c 80 00 	movl   $0x802cc3,(%esp)
  801e79:	e8 d6 e5 ff ff       	call   800454 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e7e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801e85:	00 
  801e86:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e8c:	89 04 24             	mov    %eax,(%esp)
  801e8f:	e8 4f f1 ff ff       	call   800fe3 <sys_env_set_status>
  801e94:	85 c0                	test   %eax,%eax
  801e96:	79 5a                	jns    801ef2 <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  801e98:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e9c:	c7 44 24 08 06 2d 80 	movl   $0x802d06,0x8(%esp)
  801ea3:	00 
  801ea4:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801eab:	00 
  801eac:	c7 04 24 c3 2c 80 00 	movl   $0x802cc3,(%esp)
  801eb3:	e8 9c e5 ff ff       	call   800454 <_panic>
  801eb8:	89 c6                	mov    %eax,%esi
  801eba:	eb 06                	jmp    801ec2 <spawn+0x50e>
  801ebc:	89 c6                	mov    %eax,%esi
  801ebe:	eb 02                	jmp    801ec2 <spawn+0x50e>
  801ec0:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801ec2:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801ec8:	89 04 24             	mov    %eax,(%esp)
  801ecb:	e8 89 ef ff ff       	call   800e59 <sys_env_destroy>
	close(fd);
  801ed0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ed6:	89 04 24             	mov    %eax,(%esp)
  801ed9:	e8 2c f4 ff ff       	call   80130a <close>
	return r;
  801ede:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  801ee4:	eb 0c                	jmp    801ef2 <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ee6:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801eec:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ef2:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801ef8:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801efe:	5b                   	pop    %ebx
  801eff:	5e                   	pop    %esi
  801f00:	5f                   	pop    %edi
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801f03:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801f08:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801f0e:	eb e2                	jmp    801ef2 <spawn+0x53e>

00801f10 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	57                   	push   %edi
  801f14:	56                   	push   %esi
  801f15:	53                   	push   %ebx
  801f16:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801f19:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f1c:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f21:	eb 03                	jmp    801f26 <spawnl+0x16>
		argc++;
  801f23:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f24:	89 d0                	mov    %edx,%eax
  801f26:	8d 50 04             	lea    0x4(%eax),%edx
  801f29:	83 38 00             	cmpl   $0x0,(%eax)
  801f2c:	75 f5                	jne    801f23 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f2e:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801f35:	83 e0 f0             	and    $0xfffffff0,%eax
  801f38:	29 c4                	sub    %eax,%esp
  801f3a:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801f3e:	83 e7 f0             	and    $0xfffffff0,%edi
  801f41:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801f43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f46:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801f48:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801f4f:	00 

	va_start(vl, arg0);
  801f50:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
  801f58:	eb 09                	jmp    801f63 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801f5a:	40                   	inc    %eax
  801f5b:	8b 1a                	mov    (%edx),%ebx
  801f5d:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801f60:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f63:	39 c8                	cmp    %ecx,%eax
  801f65:	75 f3                	jne    801f5a <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f67:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6e:	89 04 24             	mov    %eax,(%esp)
  801f71:	e8 3e fa ff ff       	call   8019b4 <spawn>
}
  801f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f79:	5b                   	pop    %ebx
  801f7a:	5e                   	pop    %esi
  801f7b:	5f                   	pop    %edi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    
	...

00801f80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	56                   	push   %esi
  801f84:	53                   	push   %ebx
  801f85:	83 ec 10             	sub    $0x10,%esp
  801f88:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8e:	89 04 24             	mov    %eax,(%esp)
  801f91:	e8 ce f1 ff ff       	call   801164 <fd2data>
  801f96:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801f98:	c7 44 24 04 48 2d 80 	movl   $0x802d48,0x4(%esp)
  801f9f:	00 
  801fa0:	89 34 24             	mov    %esi,(%esp)
  801fa3:	e8 4f eb ff ff       	call   800af7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fa8:	8b 43 04             	mov    0x4(%ebx),%eax
  801fab:	2b 03                	sub    (%ebx),%eax
  801fad:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801fb3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801fba:	00 00 00 
	stat->st_dev = &devpipe;
  801fbd:	c7 86 88 00 00 00 ac 	movl   $0x8047ac,0x88(%esi)
  801fc4:	47 80 00 
	return 0;
}
  801fc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fcc:	83 c4 10             	add    $0x10,%esp
  801fcf:	5b                   	pop    %ebx
  801fd0:	5e                   	pop    %esi
  801fd1:	5d                   	pop    %ebp
  801fd2:	c3                   	ret    

00801fd3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	53                   	push   %ebx
  801fd7:	83 ec 14             	sub    $0x14,%esp
  801fda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fe1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe8:	e8 a3 ef ff ff       	call   800f90 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fed:	89 1c 24             	mov    %ebx,(%esp)
  801ff0:	e8 6f f1 ff ff       	call   801164 <fd2data>
  801ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802000:	e8 8b ef ff ff       	call   800f90 <sys_page_unmap>
}
  802005:	83 c4 14             	add    $0x14,%esp
  802008:	5b                   	pop    %ebx
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    

0080200b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	57                   	push   %edi
  80200f:	56                   	push   %esi
  802010:	53                   	push   %ebx
  802011:	83 ec 2c             	sub    $0x2c,%esp
  802014:	89 c7                	mov    %eax,%edi
  802016:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802019:	a1 90 67 80 00       	mov    0x806790,%eax
  80201e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802021:	89 3c 24             	mov    %edi,(%esp)
  802024:	e8 53 04 00 00       	call   80247c <pageref>
  802029:	89 c6                	mov    %eax,%esi
  80202b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80202e:	89 04 24             	mov    %eax,(%esp)
  802031:	e8 46 04 00 00       	call   80247c <pageref>
  802036:	39 c6                	cmp    %eax,%esi
  802038:	0f 94 c0             	sete   %al
  80203b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80203e:	8b 15 90 67 80 00    	mov    0x806790,%edx
  802044:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802047:	39 cb                	cmp    %ecx,%ebx
  802049:	75 08                	jne    802053 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80204b:	83 c4 2c             	add    $0x2c,%esp
  80204e:	5b                   	pop    %ebx
  80204f:	5e                   	pop    %esi
  802050:	5f                   	pop    %edi
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802053:	83 f8 01             	cmp    $0x1,%eax
  802056:	75 c1                	jne    802019 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802058:	8b 42 58             	mov    0x58(%edx),%eax
  80205b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802062:	00 
  802063:	89 44 24 08          	mov    %eax,0x8(%esp)
  802067:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80206b:	c7 04 24 4f 2d 80 00 	movl   $0x802d4f,(%esp)
  802072:	e8 d5 e4 ff ff       	call   80054c <cprintf>
  802077:	eb a0                	jmp    802019 <_pipeisclosed+0xe>

00802079 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	57                   	push   %edi
  80207d:	56                   	push   %esi
  80207e:	53                   	push   %ebx
  80207f:	83 ec 1c             	sub    $0x1c,%esp
  802082:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802085:	89 34 24             	mov    %esi,(%esp)
  802088:	e8 d7 f0 ff ff       	call   801164 <fd2data>
  80208d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80208f:	bf 00 00 00 00       	mov    $0x0,%edi
  802094:	eb 3c                	jmp    8020d2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802096:	89 da                	mov    %ebx,%edx
  802098:	89 f0                	mov    %esi,%eax
  80209a:	e8 6c ff ff ff       	call   80200b <_pipeisclosed>
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	75 38                	jne    8020db <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020a3:	e8 22 ee ff ff       	call   800eca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8020ab:	8b 13                	mov    (%ebx),%edx
  8020ad:	83 c2 20             	add    $0x20,%edx
  8020b0:	39 d0                	cmp    %edx,%eax
  8020b2:	73 e2                	jae    802096 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8020ba:	89 c2                	mov    %eax,%edx
  8020bc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8020c2:	79 05                	jns    8020c9 <devpipe_write+0x50>
  8020c4:	4a                   	dec    %edx
  8020c5:	83 ca e0             	or     $0xffffffe0,%edx
  8020c8:	42                   	inc    %edx
  8020c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020cd:	40                   	inc    %eax
  8020ce:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d1:	47                   	inc    %edi
  8020d2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020d5:	75 d1                	jne    8020a8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020d7:	89 f8                	mov    %edi,%eax
  8020d9:	eb 05                	jmp    8020e0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020db:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    

008020e8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	57                   	push   %edi
  8020ec:	56                   	push   %esi
  8020ed:	53                   	push   %ebx
  8020ee:	83 ec 1c             	sub    $0x1c,%esp
  8020f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020f4:	89 3c 24             	mov    %edi,(%esp)
  8020f7:	e8 68 f0 ff ff       	call   801164 <fd2data>
  8020fc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020fe:	be 00 00 00 00       	mov    $0x0,%esi
  802103:	eb 3a                	jmp    80213f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802105:	85 f6                	test   %esi,%esi
  802107:	74 04                	je     80210d <devpipe_read+0x25>
				return i;
  802109:	89 f0                	mov    %esi,%eax
  80210b:	eb 40                	jmp    80214d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80210d:	89 da                	mov    %ebx,%edx
  80210f:	89 f8                	mov    %edi,%eax
  802111:	e8 f5 fe ff ff       	call   80200b <_pipeisclosed>
  802116:	85 c0                	test   %eax,%eax
  802118:	75 2e                	jne    802148 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80211a:	e8 ab ed ff ff       	call   800eca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80211f:	8b 03                	mov    (%ebx),%eax
  802121:	3b 43 04             	cmp    0x4(%ebx),%eax
  802124:	74 df                	je     802105 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802126:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80212b:	79 05                	jns    802132 <devpipe_read+0x4a>
  80212d:	48                   	dec    %eax
  80212e:	83 c8 e0             	or     $0xffffffe0,%eax
  802131:	40                   	inc    %eax
  802132:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802136:	8b 55 0c             	mov    0xc(%ebp),%edx
  802139:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80213c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80213e:	46                   	inc    %esi
  80213f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802142:	75 db                	jne    80211f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802144:	89 f0                	mov    %esi,%eax
  802146:	eb 05                	jmp    80214d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802148:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80214d:	83 c4 1c             	add    $0x1c,%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    

00802155 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	57                   	push   %edi
  802159:	56                   	push   %esi
  80215a:	53                   	push   %ebx
  80215b:	83 ec 3c             	sub    $0x3c,%esp
  80215e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802161:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802164:	89 04 24             	mov    %eax,(%esp)
  802167:	e8 13 f0 ff ff       	call   80117f <fd_alloc>
  80216c:	89 c3                	mov    %eax,%ebx
  80216e:	85 c0                	test   %eax,%eax
  802170:	0f 88 45 01 00 00    	js     8022bb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802176:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80217d:	00 
  80217e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802181:	89 44 24 04          	mov    %eax,0x4(%esp)
  802185:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80218c:	e8 58 ed ff ff       	call   800ee9 <sys_page_alloc>
  802191:	89 c3                	mov    %eax,%ebx
  802193:	85 c0                	test   %eax,%eax
  802195:	0f 88 20 01 00 00    	js     8022bb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80219b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80219e:	89 04 24             	mov    %eax,(%esp)
  8021a1:	e8 d9 ef ff ff       	call   80117f <fd_alloc>
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	0f 88 f8 00 00 00    	js     8022a8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021b7:	00 
  8021b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021c6:	e8 1e ed ff ff       	call   800ee9 <sys_page_alloc>
  8021cb:	89 c3                	mov    %eax,%ebx
  8021cd:	85 c0                	test   %eax,%eax
  8021cf:	0f 88 d3 00 00 00    	js     8022a8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021d8:	89 04 24             	mov    %eax,(%esp)
  8021db:	e8 84 ef ff ff       	call   801164 <fd2data>
  8021e0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021e9:	00 
  8021ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f5:	e8 ef ec ff ff       	call   800ee9 <sys_page_alloc>
  8021fa:	89 c3                	mov    %eax,%ebx
  8021fc:	85 c0                	test   %eax,%eax
  8021fe:	0f 88 91 00 00 00    	js     802295 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802204:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802207:	89 04 24             	mov    %eax,(%esp)
  80220a:	e8 55 ef ff ff       	call   801164 <fd2data>
  80220f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802216:	00 
  802217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80221b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802222:	00 
  802223:	89 74 24 04          	mov    %esi,0x4(%esp)
  802227:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80222e:	e8 0a ed ff ff       	call   800f3d <sys_page_map>
  802233:	89 c3                	mov    %eax,%ebx
  802235:	85 c0                	test   %eax,%eax
  802237:	78 4c                	js     802285 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802239:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80223f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802242:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802247:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80224e:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802254:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802257:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802259:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80225c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802263:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802266:	89 04 24             	mov    %eax,(%esp)
  802269:	e8 e6 ee ff ff       	call   801154 <fd2num>
  80226e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802270:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802273:	89 04 24             	mov    %eax,(%esp)
  802276:	e8 d9 ee ff ff       	call   801154 <fd2num>
  80227b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80227e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802283:	eb 36                	jmp    8022bb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802285:	89 74 24 04          	mov    %esi,0x4(%esp)
  802289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802290:	e8 fb ec ff ff       	call   800f90 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802295:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80229c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022a3:	e8 e8 ec ff ff       	call   800f90 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8022a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b6:	e8 d5 ec ff ff       	call   800f90 <sys_page_unmap>
    err:
	return r;
}
  8022bb:	89 d8                	mov    %ebx,%eax
  8022bd:	83 c4 3c             	add    $0x3c,%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    

008022c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d5:	89 04 24             	mov    %eax,(%esp)
  8022d8:	e8 f5 ee ff ff       	call   8011d2 <fd_lookup>
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	78 15                	js     8022f6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e4:	89 04 24             	mov    %eax,(%esp)
  8022e7:	e8 78 ee ff ff       	call   801164 <fd2data>
	return _pipeisclosed(fd, p);
  8022ec:	89 c2                	mov    %eax,%edx
  8022ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f1:	e8 15 fd ff ff       	call   80200b <_pipeisclosed>
}
  8022f6:	c9                   	leave  
  8022f7:	c3                   	ret    

008022f8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022f8:	55                   	push   %ebp
  8022f9:	89 e5                	mov    %esp,%ebp
  8022fb:	56                   	push   %esi
  8022fc:	53                   	push   %ebx
  8022fd:	83 ec 10             	sub    $0x10,%esp
  802300:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802303:	85 f6                	test   %esi,%esi
  802305:	75 24                	jne    80232b <wait+0x33>
  802307:	c7 44 24 0c 67 2d 80 	movl   $0x802d67,0xc(%esp)
  80230e:	00 
  80230f:	c7 44 24 08 88 2c 80 	movl   $0x802c88,0x8(%esp)
  802316:	00 
  802317:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80231e:	00 
  80231f:	c7 04 24 72 2d 80 00 	movl   $0x802d72,(%esp)
  802326:	e8 29 e1 ff ff       	call   800454 <_panic>
	e = &envs[ENVX(envid)];
  80232b:	89 f3                	mov    %esi,%ebx
  80232d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802333:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  80233a:	c1 e3 07             	shl    $0x7,%ebx
  80233d:	29 c3                	sub    %eax,%ebx
  80233f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802345:	eb 05                	jmp    80234c <wait+0x54>
		sys_yield();
  802347:	e8 7e eb ff ff       	call   800eca <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80234c:	8b 43 48             	mov    0x48(%ebx),%eax
  80234f:	39 f0                	cmp    %esi,%eax
  802351:	75 07                	jne    80235a <wait+0x62>
  802353:	8b 43 54             	mov    0x54(%ebx),%eax
  802356:	85 c0                	test   %eax,%eax
  802358:	75 ed                	jne    802347 <wait+0x4f>
		sys_yield();
}
  80235a:	83 c4 10             	add    $0x10,%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    
  802361:	00 00                	add    %al,(%eax)
	...

00802364 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802364:	55                   	push   %ebp
  802365:	89 e5                	mov    %esp,%ebp
  802367:	57                   	push   %edi
  802368:	56                   	push   %esi
  802369:	53                   	push   %ebx
  80236a:	83 ec 1c             	sub    $0x1c,%esp
  80236d:	8b 75 08             	mov    0x8(%ebp),%esi
  802370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802373:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  802376:	85 db                	test   %ebx,%ebx
  802378:	75 05                	jne    80237f <ipc_recv+0x1b>
		pg = (void *)UTOP;
  80237a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  80237f:	89 1c 24             	mov    %ebx,(%esp)
  802382:	e8 78 ed ff ff       	call   8010ff <sys_ipc_recv>
  802387:	85 c0                	test   %eax,%eax
  802389:	79 16                	jns    8023a1 <ipc_recv+0x3d>
		*from_env_store = 0;
  80238b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  802391:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  802397:	89 1c 24             	mov    %ebx,(%esp)
  80239a:	e8 60 ed ff ff       	call   8010ff <sys_ipc_recv>
  80239f:	eb 24                	jmp    8023c5 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  8023a1:	85 f6                	test   %esi,%esi
  8023a3:	74 0a                	je     8023af <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8023a5:	a1 90 67 80 00       	mov    0x806790,%eax
  8023aa:	8b 40 74             	mov    0x74(%eax),%eax
  8023ad:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8023af:	85 ff                	test   %edi,%edi
  8023b1:	74 0a                	je     8023bd <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8023b3:	a1 90 67 80 00       	mov    0x806790,%eax
  8023b8:	8b 40 78             	mov    0x78(%eax),%eax
  8023bb:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  8023bd:	a1 90 67 80 00       	mov    0x806790,%eax
  8023c2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023c5:	83 c4 1c             	add    $0x1c,%esp
  8023c8:	5b                   	pop    %ebx
  8023c9:	5e                   	pop    %esi
  8023ca:	5f                   	pop    %edi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    

008023cd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023cd:	55                   	push   %ebp
  8023ce:	89 e5                	mov    %esp,%ebp
  8023d0:	57                   	push   %edi
  8023d1:	56                   	push   %esi
  8023d2:	53                   	push   %ebx
  8023d3:	83 ec 1c             	sub    $0x1c,%esp
  8023d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023dc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8023df:	85 db                	test   %ebx,%ebx
  8023e1:	75 05                	jne    8023e8 <ipc_send+0x1b>
		pg = (void *)-1;
  8023e3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8023e8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8023ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f7:	89 04 24             	mov    %eax,(%esp)
  8023fa:	e8 dd ec ff ff       	call   8010dc <sys_ipc_try_send>
		if (r == 0) {		
  8023ff:	85 c0                	test   %eax,%eax
  802401:	74 2c                	je     80242f <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  802403:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802406:	75 07                	jne    80240f <ipc_send+0x42>
			sys_yield();
  802408:	e8 bd ea ff ff       	call   800eca <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  80240d:	eb d9                	jmp    8023e8 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  80240f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802413:	c7 44 24 08 7d 2d 80 	movl   $0x802d7d,0x8(%esp)
  80241a:	00 
  80241b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  802422:	00 
  802423:	c7 04 24 8b 2d 80 00 	movl   $0x802d8b,(%esp)
  80242a:	e8 25 e0 ff ff       	call   800454 <_panic>
		}
	}
}
  80242f:	83 c4 1c             	add    $0x1c,%esp
  802432:	5b                   	pop    %ebx
  802433:	5e                   	pop    %esi
  802434:	5f                   	pop    %edi
  802435:	5d                   	pop    %ebp
  802436:	c3                   	ret    

00802437 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802437:	55                   	push   %ebp
  802438:	89 e5                	mov    %esp,%ebp
  80243a:	53                   	push   %ebx
  80243b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80243e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802443:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80244a:	89 c2                	mov    %eax,%edx
  80244c:	c1 e2 07             	shl    $0x7,%edx
  80244f:	29 ca                	sub    %ecx,%edx
  802451:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802457:	8b 52 50             	mov    0x50(%edx),%edx
  80245a:	39 da                	cmp    %ebx,%edx
  80245c:	75 0f                	jne    80246d <ipc_find_env+0x36>
			return envs[i].env_id;
  80245e:	c1 e0 07             	shl    $0x7,%eax
  802461:	29 c8                	sub    %ecx,%eax
  802463:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802468:	8b 40 40             	mov    0x40(%eax),%eax
  80246b:	eb 0c                	jmp    802479 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80246d:	40                   	inc    %eax
  80246e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802473:	75 ce                	jne    802443 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802475:	66 b8 00 00          	mov    $0x0,%ax
}
  802479:	5b                   	pop    %ebx
  80247a:	5d                   	pop    %ebp
  80247b:	c3                   	ret    

0080247c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80247c:	55                   	push   %ebp
  80247d:	89 e5                	mov    %esp,%ebp
  80247f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802482:	89 c2                	mov    %eax,%edx
  802484:	c1 ea 16             	shr    $0x16,%edx
  802487:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80248e:	f6 c2 01             	test   $0x1,%dl
  802491:	74 1e                	je     8024b1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802493:	c1 e8 0c             	shr    $0xc,%eax
  802496:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80249d:	a8 01                	test   $0x1,%al
  80249f:	74 17                	je     8024b8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024a1:	c1 e8 0c             	shr    $0xc,%eax
  8024a4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8024ab:	ef 
  8024ac:	0f b7 c0             	movzwl %ax,%eax
  8024af:	eb 0c                	jmp    8024bd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8024b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b6:	eb 05                	jmp    8024bd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8024b8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8024bd:	5d                   	pop    %ebp
  8024be:	c3                   	ret    
	...

008024c0 <__udivdi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	83 ec 10             	sub    $0x10,%esp
  8024c6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8024ca:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8024ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8024d6:	89 cd                	mov    %ecx,%ebp
  8024d8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8024dc:	85 c0                	test   %eax,%eax
  8024de:	75 2c                	jne    80250c <__udivdi3+0x4c>
  8024e0:	39 f9                	cmp    %edi,%ecx
  8024e2:	77 68                	ja     80254c <__udivdi3+0x8c>
  8024e4:	85 c9                	test   %ecx,%ecx
  8024e6:	75 0b                	jne    8024f3 <__udivdi3+0x33>
  8024e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ed:	31 d2                	xor    %edx,%edx
  8024ef:	f7 f1                	div    %ecx
  8024f1:	89 c1                	mov    %eax,%ecx
  8024f3:	31 d2                	xor    %edx,%edx
  8024f5:	89 f8                	mov    %edi,%eax
  8024f7:	f7 f1                	div    %ecx
  8024f9:	89 c7                	mov    %eax,%edi
  8024fb:	89 f0                	mov    %esi,%eax
  8024fd:	f7 f1                	div    %ecx
  8024ff:	89 c6                	mov    %eax,%esi
  802501:	89 f0                	mov    %esi,%eax
  802503:	89 fa                	mov    %edi,%edx
  802505:	83 c4 10             	add    $0x10,%esp
  802508:	5e                   	pop    %esi
  802509:	5f                   	pop    %edi
  80250a:	5d                   	pop    %ebp
  80250b:	c3                   	ret    
  80250c:	39 f8                	cmp    %edi,%eax
  80250e:	77 2c                	ja     80253c <__udivdi3+0x7c>
  802510:	0f bd f0             	bsr    %eax,%esi
  802513:	83 f6 1f             	xor    $0x1f,%esi
  802516:	75 4c                	jne    802564 <__udivdi3+0xa4>
  802518:	39 f8                	cmp    %edi,%eax
  80251a:	bf 00 00 00 00       	mov    $0x0,%edi
  80251f:	72 0a                	jb     80252b <__udivdi3+0x6b>
  802521:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802525:	0f 87 ad 00 00 00    	ja     8025d8 <__udivdi3+0x118>
  80252b:	be 01 00 00 00       	mov    $0x1,%esi
  802530:	89 f0                	mov    %esi,%eax
  802532:	89 fa                	mov    %edi,%edx
  802534:	83 c4 10             	add    $0x10,%esp
  802537:	5e                   	pop    %esi
  802538:	5f                   	pop    %edi
  802539:	5d                   	pop    %ebp
  80253a:	c3                   	ret    
  80253b:	90                   	nop
  80253c:	31 ff                	xor    %edi,%edi
  80253e:	31 f6                	xor    %esi,%esi
  802540:	89 f0                	mov    %esi,%eax
  802542:	89 fa                	mov    %edi,%edx
  802544:	83 c4 10             	add    $0x10,%esp
  802547:	5e                   	pop    %esi
  802548:	5f                   	pop    %edi
  802549:	5d                   	pop    %ebp
  80254a:	c3                   	ret    
  80254b:	90                   	nop
  80254c:	89 fa                	mov    %edi,%edx
  80254e:	89 f0                	mov    %esi,%eax
  802550:	f7 f1                	div    %ecx
  802552:	89 c6                	mov    %eax,%esi
  802554:	31 ff                	xor    %edi,%edi
  802556:	89 f0                	mov    %esi,%eax
  802558:	89 fa                	mov    %edi,%edx
  80255a:	83 c4 10             	add    $0x10,%esp
  80255d:	5e                   	pop    %esi
  80255e:	5f                   	pop    %edi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    
  802561:	8d 76 00             	lea    0x0(%esi),%esi
  802564:	89 f1                	mov    %esi,%ecx
  802566:	d3 e0                	shl    %cl,%eax
  802568:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80256c:	b8 20 00 00 00       	mov    $0x20,%eax
  802571:	29 f0                	sub    %esi,%eax
  802573:	89 ea                	mov    %ebp,%edx
  802575:	88 c1                	mov    %al,%cl
  802577:	d3 ea                	shr    %cl,%edx
  802579:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80257d:	09 ca                	or     %ecx,%edx
  80257f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802583:	89 f1                	mov    %esi,%ecx
  802585:	d3 e5                	shl    %cl,%ebp
  802587:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80258b:	89 fd                	mov    %edi,%ebp
  80258d:	88 c1                	mov    %al,%cl
  80258f:	d3 ed                	shr    %cl,%ebp
  802591:	89 fa                	mov    %edi,%edx
  802593:	89 f1                	mov    %esi,%ecx
  802595:	d3 e2                	shl    %cl,%edx
  802597:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80259b:	88 c1                	mov    %al,%cl
  80259d:	d3 ef                	shr    %cl,%edi
  80259f:	09 d7                	or     %edx,%edi
  8025a1:	89 f8                	mov    %edi,%eax
  8025a3:	89 ea                	mov    %ebp,%edx
  8025a5:	f7 74 24 08          	divl   0x8(%esp)
  8025a9:	89 d1                	mov    %edx,%ecx
  8025ab:	89 c7                	mov    %eax,%edi
  8025ad:	f7 64 24 0c          	mull   0xc(%esp)
  8025b1:	39 d1                	cmp    %edx,%ecx
  8025b3:	72 17                	jb     8025cc <__udivdi3+0x10c>
  8025b5:	74 09                	je     8025c0 <__udivdi3+0x100>
  8025b7:	89 fe                	mov    %edi,%esi
  8025b9:	31 ff                	xor    %edi,%edi
  8025bb:	e9 41 ff ff ff       	jmp    802501 <__udivdi3+0x41>
  8025c0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025c4:	89 f1                	mov    %esi,%ecx
  8025c6:	d3 e2                	shl    %cl,%edx
  8025c8:	39 c2                	cmp    %eax,%edx
  8025ca:	73 eb                	jae    8025b7 <__udivdi3+0xf7>
  8025cc:	8d 77 ff             	lea    -0x1(%edi),%esi
  8025cf:	31 ff                	xor    %edi,%edi
  8025d1:	e9 2b ff ff ff       	jmp    802501 <__udivdi3+0x41>
  8025d6:	66 90                	xchg   %ax,%ax
  8025d8:	31 f6                	xor    %esi,%esi
  8025da:	e9 22 ff ff ff       	jmp    802501 <__udivdi3+0x41>
	...

008025e0 <__umoddi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	57                   	push   %edi
  8025e2:	56                   	push   %esi
  8025e3:	83 ec 20             	sub    $0x20,%esp
  8025e6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025ea:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8025ee:	89 44 24 14          	mov    %eax,0x14(%esp)
  8025f2:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025f6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025fa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8025fe:	89 c7                	mov    %eax,%edi
  802600:	89 f2                	mov    %esi,%edx
  802602:	85 ed                	test   %ebp,%ebp
  802604:	75 16                	jne    80261c <__umoddi3+0x3c>
  802606:	39 f1                	cmp    %esi,%ecx
  802608:	0f 86 a6 00 00 00    	jbe    8026b4 <__umoddi3+0xd4>
  80260e:	f7 f1                	div    %ecx
  802610:	89 d0                	mov    %edx,%eax
  802612:	31 d2                	xor    %edx,%edx
  802614:	83 c4 20             	add    $0x20,%esp
  802617:	5e                   	pop    %esi
  802618:	5f                   	pop    %edi
  802619:	5d                   	pop    %ebp
  80261a:	c3                   	ret    
  80261b:	90                   	nop
  80261c:	39 f5                	cmp    %esi,%ebp
  80261e:	0f 87 ac 00 00 00    	ja     8026d0 <__umoddi3+0xf0>
  802624:	0f bd c5             	bsr    %ebp,%eax
  802627:	83 f0 1f             	xor    $0x1f,%eax
  80262a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80262e:	0f 84 a8 00 00 00    	je     8026dc <__umoddi3+0xfc>
  802634:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802638:	d3 e5                	shl    %cl,%ebp
  80263a:	bf 20 00 00 00       	mov    $0x20,%edi
  80263f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802643:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802647:	89 f9                	mov    %edi,%ecx
  802649:	d3 e8                	shr    %cl,%eax
  80264b:	09 e8                	or     %ebp,%eax
  80264d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802651:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802655:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802659:	d3 e0                	shl    %cl,%eax
  80265b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80265f:	89 f2                	mov    %esi,%edx
  802661:	d3 e2                	shl    %cl,%edx
  802663:	8b 44 24 14          	mov    0x14(%esp),%eax
  802667:	d3 e0                	shl    %cl,%eax
  802669:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80266d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802671:	89 f9                	mov    %edi,%ecx
  802673:	d3 e8                	shr    %cl,%eax
  802675:	09 d0                	or     %edx,%eax
  802677:	d3 ee                	shr    %cl,%esi
  802679:	89 f2                	mov    %esi,%edx
  80267b:	f7 74 24 18          	divl   0x18(%esp)
  80267f:	89 d6                	mov    %edx,%esi
  802681:	f7 64 24 0c          	mull   0xc(%esp)
  802685:	89 c5                	mov    %eax,%ebp
  802687:	89 d1                	mov    %edx,%ecx
  802689:	39 d6                	cmp    %edx,%esi
  80268b:	72 67                	jb     8026f4 <__umoddi3+0x114>
  80268d:	74 75                	je     802704 <__umoddi3+0x124>
  80268f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802693:	29 e8                	sub    %ebp,%eax
  802695:	19 ce                	sbb    %ecx,%esi
  802697:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	89 f2                	mov    %esi,%edx
  80269f:	89 f9                	mov    %edi,%ecx
  8026a1:	d3 e2                	shl    %cl,%edx
  8026a3:	09 d0                	or     %edx,%eax
  8026a5:	89 f2                	mov    %esi,%edx
  8026a7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026ab:	d3 ea                	shr    %cl,%edx
  8026ad:	83 c4 20             	add    $0x20,%esp
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    
  8026b4:	85 c9                	test   %ecx,%ecx
  8026b6:	75 0b                	jne    8026c3 <__umoddi3+0xe3>
  8026b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8026bd:	31 d2                	xor    %edx,%edx
  8026bf:	f7 f1                	div    %ecx
  8026c1:	89 c1                	mov    %eax,%ecx
  8026c3:	89 f0                	mov    %esi,%eax
  8026c5:	31 d2                	xor    %edx,%edx
  8026c7:	f7 f1                	div    %ecx
  8026c9:	89 f8                	mov    %edi,%eax
  8026cb:	e9 3e ff ff ff       	jmp    80260e <__umoddi3+0x2e>
  8026d0:	89 f2                	mov    %esi,%edx
  8026d2:	83 c4 20             	add    $0x20,%esp
  8026d5:	5e                   	pop    %esi
  8026d6:	5f                   	pop    %edi
  8026d7:	5d                   	pop    %ebp
  8026d8:	c3                   	ret    
  8026d9:	8d 76 00             	lea    0x0(%esi),%esi
  8026dc:	39 f5                	cmp    %esi,%ebp
  8026de:	72 04                	jb     8026e4 <__umoddi3+0x104>
  8026e0:	39 f9                	cmp    %edi,%ecx
  8026e2:	77 06                	ja     8026ea <__umoddi3+0x10a>
  8026e4:	89 f2                	mov    %esi,%edx
  8026e6:	29 cf                	sub    %ecx,%edi
  8026e8:	19 ea                	sbb    %ebp,%edx
  8026ea:	89 f8                	mov    %edi,%eax
  8026ec:	83 c4 20             	add    $0x20,%esp
  8026ef:	5e                   	pop    %esi
  8026f0:	5f                   	pop    %edi
  8026f1:	5d                   	pop    %ebp
  8026f2:	c3                   	ret    
  8026f3:	90                   	nop
  8026f4:	89 d1                	mov    %edx,%ecx
  8026f6:	89 c5                	mov    %eax,%ebp
  8026f8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8026fc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802700:	eb 8d                	jmp    80268f <__umoddi3+0xaf>
  802702:	66 90                	xchg   %ax,%ax
  802704:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802708:	72 ea                	jb     8026f4 <__umoddi3+0x114>
  80270a:	89 f1                	mov    %esi,%ecx
  80270c:	eb 81                	jmp    80268f <__umoddi3+0xaf>
