
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 8b 02 00 00       	call   8002bc <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  800040:	e8 3d 0e 00 00       	call   800e82 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800045:	4b                   	dec    %ebx
  800046:	75 f8                	jne    800040 <umain+0xc>
		sys_yield();

	close(0);
  800048:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80004f:	e8 6e 12 00 00       	call   8012c2 <close>
	if ((r = opencons()) < 0)
  800054:	e8 0f 02 00 00       	call   800268 <opencons>
  800059:	85 c0                	test   %eax,%eax
  80005b:	79 20                	jns    80007d <umain+0x49>
		panic("opencons: %e", r);
  80005d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800061:	c7 44 24 08 e0 21 80 	movl   $0x8021e0,0x8(%esp)
  800068:	00 
  800069:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800070:	00 
  800071:	c7 04 24 ed 21 80 00 	movl   $0x8021ed,(%esp)
  800078:	e8 af 02 00 00       	call   80032c <_panic>
	if (r != 0)
  80007d:	85 c0                	test   %eax,%eax
  80007f:	74 20                	je     8000a1 <umain+0x6d>
		panic("first opencons used fd %d", r);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 fc 21 80 	movl   $0x8021fc,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 ed 21 80 00 	movl   $0x8021ed,(%esp)
  80009c:	e8 8b 02 00 00       	call   80032c <_panic>
	if ((r = dup(0, 1)) < 0)
  8000a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000a8:	00 
  8000a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b0:	e8 5e 12 00 00       	call   801313 <dup>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 20                	jns    8000d9 <umain+0xa5>
		panic("dup: %e", r);
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	c7 44 24 08 16 22 80 	movl   $0x802216,0x8(%esp)
  8000c4:	00 
  8000c5:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000cc:	00 
  8000cd:	c7 04 24 ed 21 80 00 	movl   $0x8021ed,(%esp)
  8000d4:	e8 53 02 00 00       	call   80032c <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000d9:	c7 04 24 1e 22 80 00 	movl   $0x80221e,(%esp)
  8000e0:	e8 b7 08 00 00       	call   80099c <readline>
		if (buf != NULL)
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	74 1a                	je     800103 <umain+0xcf>
			fprintf(1, "%s\n", buf);
  8000e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ed:	c7 44 24 04 2c 22 80 	movl   $0x80222c,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000fc:	e8 5f 19 00 00       	call   801a60 <fprintf>
  800101:	eb d6                	jmp    8000d9 <umain+0xa5>
		else
			fprintf(1, "(end of file received)\n");
  800103:	c7 44 24 04 30 22 80 	movl   $0x802230,0x4(%esp)
  80010a:	00 
  80010b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800112:	e8 49 19 00 00       	call   801a60 <fprintf>
  800117:	eb c0                	jmp    8000d9 <umain+0xa5>
  800119:	00 00                	add    %al,(%eax)
	...

0080011c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80011f:	b8 00 00 00 00       	mov    $0x0,%eax
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80012c:	c7 44 24 04 48 22 80 	movl   $0x802248,0x4(%esp)
  800133:	00 
  800134:	8b 45 0c             	mov    0xc(%ebp),%eax
  800137:	89 04 24             	mov    %eax,(%esp)
  80013a:	e8 70 09 00 00       	call   800aaf <strcpy>
	return 0;
}
  80013f:	b8 00 00 00 00       	mov    $0x0,%eax
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800152:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800157:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80015d:	eb 30                	jmp    80018f <devcons_write+0x49>
		m = n - tot;
  80015f:	8b 75 10             	mov    0x10(%ebp),%esi
  800162:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800164:	83 fe 7f             	cmp    $0x7f,%esi
  800167:	76 05                	jbe    80016e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800169:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80016e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800172:	03 45 0c             	add    0xc(%ebp),%eax
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	89 3c 24             	mov    %edi,(%esp)
  80017c:	e8 a7 0a 00 00       	call   800c28 <memmove>
		sys_cputs(buf, m);
  800181:	89 74 24 04          	mov    %esi,0x4(%esp)
  800185:	89 3c 24             	mov    %edi,(%esp)
  800188:	e8 47 0c 00 00       	call   800dd4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80018d:	01 f3                	add    %esi,%ebx
  80018f:	89 d8                	mov    %ebx,%eax
  800191:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800194:	72 c9                	jb     80015f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800196:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8001a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8001ab:	75 07                	jne    8001b4 <devcons_read+0x13>
  8001ad:	eb 25                	jmp    8001d4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8001af:	e8 ce 0c 00 00       	call   800e82 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8001b4:	e8 39 0c 00 00       	call   800df2 <sys_cgetc>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	74 f2                	je     8001af <devcons_read+0xe>
  8001bd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	78 1d                	js     8001e0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8001c3:	83 f8 04             	cmp    $0x4,%eax
  8001c6:	74 13                	je     8001db <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8001c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cb:	88 10                	mov    %dl,(%eax)
	return 1;
  8001cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8001d2:	eb 0c                	jmp    8001e0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8001d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d9:	eb 05                	jmp    8001e0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8001db:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001f5:	00 
  8001f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 d3 0b 00 00       	call   800dd4 <sys_cputs>
}
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <getchar>:

int
getchar(void)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800209:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800210:	00 
  800211:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80021f:	e8 02 12 00 00       	call   801426 <read>
	if (r < 0)
  800224:	85 c0                	test   %eax,%eax
  800226:	78 0f                	js     800237 <getchar+0x34>
		return r;
	if (r < 1)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7e 06                	jle    800232 <getchar+0x2f>
		return -E_EOF;
	return c;
  80022c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800230:	eb 05                	jmp    800237 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800232:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80023f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	e8 39 0f 00 00       	call   80118a <fd_lookup>
  800251:	85 c0                	test   %eax,%eax
  800253:	78 11                	js     800266 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800258:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80025e:	39 10                	cmp    %edx,(%eax)
  800260:	0f 94 c0             	sete   %al
  800263:	0f b6 c0             	movzbl %al,%eax
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <opencons>:

int
opencons(void)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80026e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	e8 be 0e 00 00       	call   801137 <fd_alloc>
  800279:	85 c0                	test   %eax,%eax
  80027b:	78 3c                	js     8002b9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80027d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800284:	00 
  800285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800293:	e8 09 0c 00 00       	call   800ea1 <sys_page_alloc>
  800298:	85 c0                	test   %eax,%eax
  80029a:	78 1d                	js     8002b9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80029c:	8b 15 00 30 80 00    	mov    0x803000,%edx
  8002a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8002a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	e8 53 0e 00 00       	call   80110c <fd2num>
}
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    
	...

008002bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 10             	sub    $0x10,%esp
  8002c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8002ca:	e8 94 0b 00 00       	call   800e63 <sys_getenvid>
  8002cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002db:	c1 e0 07             	shl    $0x7,%eax
  8002de:	29 d0                	sub    %edx,%eax
  8002e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e5:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002ea:	85 f6                	test   %esi,%esi
  8002ec:	7e 07                	jle    8002f5 <libmain+0x39>
		binaryname = argv[0];
  8002ee:	8b 03                	mov    (%ebx),%eax
  8002f0:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f9:	89 34 24             	mov    %esi,(%esp)
  8002fc:	e8 33 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800301:	e8 0a 00 00 00       	call   800310 <exit>
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    
  80030d:	00 00                	add    %al,(%eax)
	...

00800310 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800316:	e8 d8 0f 00 00       	call   8012f3 <close_all>
	sys_env_destroy(0);
  80031b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800322:	e8 ea 0a 00 00       	call   800e11 <sys_env_destroy>
}
  800327:	c9                   	leave  
  800328:	c3                   	ret    
  800329:	00 00                	add    %al,(%eax)
	...

0080032c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	56                   	push   %esi
  800330:	53                   	push   %ebx
  800331:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800334:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800337:	8b 1d 1c 30 80 00    	mov    0x80301c,%ebx
  80033d:	e8 21 0b 00 00       	call   800e63 <sys_getenvid>
  800342:	8b 55 0c             	mov    0xc(%ebp),%edx
  800345:	89 54 24 10          	mov    %edx,0x10(%esp)
  800349:	8b 55 08             	mov    0x8(%ebp),%edx
  80034c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800350:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800354:	89 44 24 04          	mov    %eax,0x4(%esp)
  800358:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  80035f:	e8 c0 00 00 00       	call   800424 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800364:	89 74 24 04          	mov    %esi,0x4(%esp)
  800368:	8b 45 10             	mov    0x10(%ebp),%eax
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	e8 50 00 00 00       	call   8003c3 <vcprintf>
	cprintf("\n");
  800373:	c7 04 24 46 22 80 00 	movl   $0x802246,(%esp)
  80037a:	e8 a5 00 00 00       	call   800424 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037f:	cc                   	int3   
  800380:	eb fd                	jmp    80037f <_panic+0x53>
	...

00800384 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	53                   	push   %ebx
  800388:	83 ec 14             	sub    $0x14,%esp
  80038b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038e:	8b 03                	mov    (%ebx),%eax
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800397:	40                   	inc    %eax
  800398:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80039a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039f:	75 19                	jne    8003ba <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003a1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003a8:	00 
  8003a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	e8 20 0a 00 00       	call   800dd4 <sys_cputs>
		b->idx = 0;
  8003b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003ba:	ff 43 04             	incl   0x4(%ebx)
}
  8003bd:	83 c4 14             	add    $0x14,%esp
  8003c0:	5b                   	pop    %ebx
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d3:	00 00 00 
	b.cnt = 0;
  8003d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f8:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  8003ff:	e8 82 01 00 00       	call   800586 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800404:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80040a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	e8 b8 09 00 00       	call   800dd4 <sys_cputs>

	return b.cnt;
}
  80041c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	e8 87 ff ff ff       	call   8003c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    
	...

00800440 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	57                   	push   %edi
  800444:	56                   	push   %esi
  800445:	53                   	push   %ebx
  800446:	83 ec 3c             	sub    $0x3c,%esp
  800449:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044c:	89 d7                	mov    %edx,%edi
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80045d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800460:	85 c0                	test   %eax,%eax
  800462:	75 08                	jne    80046c <printnum+0x2c>
  800464:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800467:	39 45 10             	cmp    %eax,0x10(%ebp)
  80046a:	77 57                	ja     8004c3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800470:	4b                   	dec    %ebx
  800471:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800475:	8b 45 10             	mov    0x10(%ebp),%eax
  800478:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800480:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800484:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80048b:	00 
  80048c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	e8 da 1a 00 00       	call   801f78 <__udivdi3>
  80049e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004a6:	89 04 24             	mov    %eax,(%esp)
  8004a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ad:	89 fa                	mov    %edi,%edx
  8004af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b2:	e8 89 ff ff ff       	call   800440 <printnum>
  8004b7:	eb 0f                	jmp    8004c8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004bd:	89 34 24             	mov    %esi,(%esp)
  8004c0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c3:	4b                   	dec    %ebx
  8004c4:	85 db                	test   %ebx,%ebx
  8004c6:	7f f1                	jg     8004b9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004de:	00 
  8004df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004e2:	89 04 24             	mov    %eax,(%esp)
  8004e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ec:	e8 a7 1b 00 00       	call   802098 <__umoddi3>
  8004f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f5:	0f be 80 83 22 80 00 	movsbl 0x802283(%eax),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800502:	83 c4 3c             	add    $0x3c,%esp
  800505:	5b                   	pop    %ebx
  800506:	5e                   	pop    %esi
  800507:	5f                   	pop    %edi
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80050d:	83 fa 01             	cmp    $0x1,%edx
  800510:	7e 0e                	jle    800520 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800512:	8b 10                	mov    (%eax),%edx
  800514:	8d 4a 08             	lea    0x8(%edx),%ecx
  800517:	89 08                	mov    %ecx,(%eax)
  800519:	8b 02                	mov    (%edx),%eax
  80051b:	8b 52 04             	mov    0x4(%edx),%edx
  80051e:	eb 22                	jmp    800542 <getuint+0x38>
	else if (lflag)
  800520:	85 d2                	test   %edx,%edx
  800522:	74 10                	je     800534 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800524:	8b 10                	mov    (%eax),%edx
  800526:	8d 4a 04             	lea    0x4(%edx),%ecx
  800529:	89 08                	mov    %ecx,(%eax)
  80052b:	8b 02                	mov    (%edx),%eax
  80052d:	ba 00 00 00 00       	mov    $0x0,%edx
  800532:	eb 0e                	jmp    800542 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800534:	8b 10                	mov    (%eax),%edx
  800536:	8d 4a 04             	lea    0x4(%edx),%ecx
  800539:	89 08                	mov    %ecx,(%eax)
  80053b:	8b 02                	mov    (%edx),%eax
  80053d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800542:	5d                   	pop    %ebp
  800543:	c3                   	ret    

00800544 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80054d:	8b 10                	mov    (%eax),%edx
  80054f:	3b 50 04             	cmp    0x4(%eax),%edx
  800552:	73 08                	jae    80055c <sprintputch+0x18>
		*b->buf++ = ch;
  800554:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800557:	88 0a                	mov    %cl,(%edx)
  800559:	42                   	inc    %edx
  80055a:	89 10                	mov    %edx,(%eax)
}
  80055c:	5d                   	pop    %ebp
  80055d:	c3                   	ret    

0080055e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800564:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800567:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056b:	8b 45 10             	mov    0x10(%ebp),%eax
  80056e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800572:	8b 45 0c             	mov    0xc(%ebp),%eax
  800575:	89 44 24 04          	mov    %eax,0x4(%esp)
  800579:	8b 45 08             	mov    0x8(%ebp),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	e8 02 00 00 00       	call   800586 <vprintfmt>
	va_end(ap);
}
  800584:	c9                   	leave  
  800585:	c3                   	ret    

00800586 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	57                   	push   %edi
  80058a:	56                   	push   %esi
  80058b:	53                   	push   %ebx
  80058c:	83 ec 4c             	sub    $0x4c,%esp
  80058f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800592:	8b 75 10             	mov    0x10(%ebp),%esi
  800595:	eb 12                	jmp    8005a9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800597:	85 c0                	test   %eax,%eax
  800599:	0f 84 6b 03 00 00    	je     80090a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80059f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a9:	0f b6 06             	movzbl (%esi),%eax
  8005ac:	46                   	inc    %esi
  8005ad:	83 f8 25             	cmp    $0x25,%eax
  8005b0:	75 e5                	jne    800597 <vprintfmt+0x11>
  8005b2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ce:	eb 26                	jmp    8005f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005d3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005d7:	eb 1d                	jmp    8005f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005dc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005e0:	eb 14                	jmp    8005f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005e5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005ec:	eb 08                	jmp    8005f6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005ee:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	0f b6 06             	movzbl (%esi),%eax
  8005f9:	8d 56 01             	lea    0x1(%esi),%edx
  8005fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ff:	8a 16                	mov    (%esi),%dl
  800601:	83 ea 23             	sub    $0x23,%edx
  800604:	80 fa 55             	cmp    $0x55,%dl
  800607:	0f 87 e1 02 00 00    	ja     8008ee <vprintfmt+0x368>
  80060d:	0f b6 d2             	movzbl %dl,%edx
  800610:	ff 24 95 c0 23 80 00 	jmp    *0x8023c0(,%edx,4)
  800617:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80061f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800622:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800626:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800629:	8d 50 d0             	lea    -0x30(%eax),%edx
  80062c:	83 fa 09             	cmp    $0x9,%edx
  80062f:	77 2a                	ja     80065b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800631:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800632:	eb eb                	jmp    80061f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800642:	eb 17                	jmp    80065b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800644:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800648:	78 98                	js     8005e2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064d:	eb a7                	jmp    8005f6 <vprintfmt+0x70>
  80064f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800652:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800659:	eb 9b                	jmp    8005f6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80065b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80065f:	79 95                	jns    8005f6 <vprintfmt+0x70>
  800661:	eb 8b                	jmp    8005ee <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800663:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800667:	eb 8d                	jmp    8005f6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)
  800672:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 04 24             	mov    %eax,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800681:	e9 23 ff ff ff       	jmp    8005a9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	79 02                	jns    800697 <vprintfmt+0x111>
  800695:	f7 d8                	neg    %eax
  800697:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800699:	83 f8 0f             	cmp    $0xf,%eax
  80069c:	7f 0b                	jg     8006a9 <vprintfmt+0x123>
  80069e:	8b 04 85 20 25 80 00 	mov    0x802520(,%eax,4),%eax
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	75 23                	jne    8006cc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ad:	c7 44 24 08 9b 22 80 	movl   $0x80229b,0x8(%esp)
  8006b4:	00 
  8006b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	89 04 24             	mov    %eax,(%esp)
  8006bf:	e8 9a fe ff ff       	call   80055e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006c7:	e9 dd fe ff ff       	jmp    8005a9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d0:	c7 44 24 08 8e 26 80 	movl   $0x80268e,0x8(%esp)
  8006d7:	00 
  8006d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006df:	89 14 24             	mov    %edx,(%esp)
  8006e2:	e8 77 fe ff ff       	call   80055e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ea:	e9 ba fe ff ff       	jmp    8005a9 <vprintfmt+0x23>
  8006ef:	89 f9                	mov    %edi,%ecx
  8006f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 30                	mov    (%eax),%esi
  800702:	85 f6                	test   %esi,%esi
  800704:	75 05                	jne    80070b <vprintfmt+0x185>
				p = "(null)";
  800706:	be 94 22 80 00       	mov    $0x802294,%esi
			if (width > 0 && padc != '-')
  80070b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80070f:	0f 8e 84 00 00 00    	jle    800799 <vprintfmt+0x213>
  800715:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800719:	74 7e                	je     800799 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80071b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80071f:	89 34 24             	mov    %esi,(%esp)
  800722:	e8 6b 03 00 00       	call   800a92 <strnlen>
  800727:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80072a:	29 c2                	sub    %eax,%edx
  80072c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80072f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800733:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800736:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800739:	89 de                	mov    %ebx,%esi
  80073b:	89 d3                	mov    %edx,%ebx
  80073d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80073f:	eb 0b                	jmp    80074c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800741:	89 74 24 04          	mov    %esi,0x4(%esp)
  800745:	89 3c 24             	mov    %edi,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074b:	4b                   	dec    %ebx
  80074c:	85 db                	test   %ebx,%ebx
  80074e:	7f f1                	jg     800741 <vprintfmt+0x1bb>
  800750:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800753:	89 f3                	mov    %esi,%ebx
  800755:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075b:	85 c0                	test   %eax,%eax
  80075d:	79 05                	jns    800764 <vprintfmt+0x1de>
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800767:	29 c2                	sub    %eax,%edx
  800769:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80076c:	eb 2b                	jmp    800799 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80076e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800772:	74 18                	je     80078c <vprintfmt+0x206>
  800774:	8d 50 e0             	lea    -0x20(%eax),%edx
  800777:	83 fa 5e             	cmp    $0x5e,%edx
  80077a:	76 10                	jbe    80078c <vprintfmt+0x206>
					putch('?', putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
  80078a:	eb 0a                	jmp    800796 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80078c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800796:	ff 4d e4             	decl   -0x1c(%ebp)
  800799:	0f be 06             	movsbl (%esi),%eax
  80079c:	46                   	inc    %esi
  80079d:	85 c0                	test   %eax,%eax
  80079f:	74 21                	je     8007c2 <vprintfmt+0x23c>
  8007a1:	85 ff                	test   %edi,%edi
  8007a3:	78 c9                	js     80076e <vprintfmt+0x1e8>
  8007a5:	4f                   	dec    %edi
  8007a6:	79 c6                	jns    80076e <vprintfmt+0x1e8>
  8007a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ab:	89 de                	mov    %ebx,%esi
  8007ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007b0:	eb 18                	jmp    8007ca <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007bd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007bf:	4b                   	dec    %ebx
  8007c0:	eb 08                	jmp    8007ca <vprintfmt+0x244>
  8007c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c5:	89 de                	mov    %ebx,%esi
  8007c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007ca:	85 db                	test   %ebx,%ebx
  8007cc:	7f e4                	jg     8007b2 <vprintfmt+0x22c>
  8007ce:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007d1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007d6:	e9 ce fd ff ff       	jmp    8005a9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007db:	83 f9 01             	cmp    $0x1,%ecx
  8007de:	7e 10                	jle    8007f0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 08             	lea    0x8(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	8b 30                	mov    (%eax),%esi
  8007eb:	8b 78 04             	mov    0x4(%eax),%edi
  8007ee:	eb 26                	jmp    800816 <vprintfmt+0x290>
	else if (lflag)
  8007f0:	85 c9                	test   %ecx,%ecx
  8007f2:	74 12                	je     800806 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8d 50 04             	lea    0x4(%eax),%edx
  8007fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fd:	8b 30                	mov    (%eax),%esi
  8007ff:	89 f7                	mov    %esi,%edi
  800801:	c1 ff 1f             	sar    $0x1f,%edi
  800804:	eb 10                	jmp    800816 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 30                	mov    (%eax),%esi
  800811:	89 f7                	mov    %esi,%edi
  800813:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800816:	85 ff                	test   %edi,%edi
  800818:	78 0a                	js     800824 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081f:	e9 8c 00 00 00       	jmp    8008b0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800824:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800828:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80082f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800832:	f7 de                	neg    %esi
  800834:	83 d7 00             	adc    $0x0,%edi
  800837:	f7 df                	neg    %edi
			}
			base = 10;
  800839:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083e:	eb 70                	jmp    8008b0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800840:	89 ca                	mov    %ecx,%edx
  800842:	8d 45 14             	lea    0x14(%ebp),%eax
  800845:	e8 c0 fc ff ff       	call   80050a <getuint>
  80084a:	89 c6                	mov    %eax,%esi
  80084c:	89 d7                	mov    %edx,%edi
			base = 10;
  80084e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800853:	eb 5b                	jmp    8008b0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800855:	89 ca                	mov    %ecx,%edx
  800857:	8d 45 14             	lea    0x14(%ebp),%eax
  80085a:	e8 ab fc ff ff       	call   80050a <getuint>
  80085f:	89 c6                	mov    %eax,%esi
  800861:	89 d7                	mov    %edx,%edi
			base = 8;
  800863:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800868:	eb 46                	jmp    8008b0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80086a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800875:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800878:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800883:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800886:	8b 45 14             	mov    0x14(%ebp),%eax
  800889:	8d 50 04             	lea    0x4(%eax),%edx
  80088c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80088f:	8b 30                	mov    (%eax),%esi
  800891:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800896:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80089b:	eb 13                	jmp    8008b0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80089d:	89 ca                	mov    %ecx,%edx
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a2:	e8 63 fc ff ff       	call   80050a <getuint>
  8008a7:	89 c6                	mov    %eax,%esi
  8008a9:	89 d7                	mov    %edx,%edi
			base = 16;
  8008ab:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008b4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c3:	89 34 24             	mov    %esi,(%esp)
  8008c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ca:	89 da                	mov    %ebx,%edx
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	e8 6c fb ff ff       	call   800440 <printnum>
			break;
  8008d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008d7:	e9 cd fc ff ff       	jmp    8005a9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e0:	89 04 24             	mov    %eax,(%esp)
  8008e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e9:	e9 bb fc ff ff       	jmp    8005a9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008f9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fc:	eb 01                	jmp    8008ff <vprintfmt+0x379>
  8008fe:	4e                   	dec    %esi
  8008ff:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800903:	75 f9                	jne    8008fe <vprintfmt+0x378>
  800905:	e9 9f fc ff ff       	jmp    8005a9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80090a:	83 c4 4c             	add    $0x4c,%esp
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 28             	sub    $0x28,%esp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800921:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800925:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800928:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092f:	85 c0                	test   %eax,%eax
  800931:	74 30                	je     800963 <vsnprintf+0x51>
  800933:	85 d2                	test   %edx,%edx
  800935:	7e 33                	jle    80096a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093e:	8b 45 10             	mov    0x10(%ebp),%eax
  800941:	89 44 24 08          	mov    %eax,0x8(%esp)
  800945:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094c:	c7 04 24 44 05 80 00 	movl   $0x800544,(%esp)
  800953:	e8 2e fc ff ff       	call   800586 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800958:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800961:	eb 0c                	jmp    80096f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800963:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800968:	eb 05                	jmp    80096f <vsnprintf+0x5d>
  80096a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800977:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097e:	8b 45 10             	mov    0x10(%ebp),%eax
  800981:	89 44 24 08          	mov    %eax,0x8(%esp)
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	89 04 24             	mov    %eax,(%esp)
  800992:	e8 7b ff ff ff       	call   800912 <vsnprintf>
	va_end(ap);

	return rc;
}
  800997:	c9                   	leave  
  800998:	c3                   	ret    
  800999:	00 00                	add    %al,(%eax)
	...

0080099c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 1c             	sub    $0x1c,%esp
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8009a8:	85 c0                	test   %eax,%eax
  8009aa:	74 18                	je     8009c4 <readline+0x28>
		fprintf(1, "%s", prompt);
  8009ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b0:	c7 44 24 04 8e 26 80 	movl   $0x80268e,0x4(%esp)
  8009b7:	00 
  8009b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009bf:	e8 9c 10 00 00       	call   801a60 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8009c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009cb:	e8 69 f8 ff ff       	call   800239 <iscons>
  8009d0:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8009d2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8009d7:	e8 27 f8 ff ff       	call   800203 <getchar>
  8009dc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009de:	85 c0                	test   %eax,%eax
  8009e0:	79 20                	jns    800a02 <readline+0x66>
			if (c != -E_EOF)
  8009e2:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8009e5:	0f 84 82 00 00 00    	je     800a6d <readline+0xd1>
				cprintf("read error: %e\n", c);
  8009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ef:	c7 04 24 7f 25 80 00 	movl   $0x80257f,(%esp)
  8009f6:	e8 29 fa ff ff       	call   800424 <cprintf>
			return NULL;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	eb 70                	jmp    800a72 <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a02:	83 f8 08             	cmp    $0x8,%eax
  800a05:	74 05                	je     800a0c <readline+0x70>
  800a07:	83 f8 7f             	cmp    $0x7f,%eax
  800a0a:	75 17                	jne    800a23 <readline+0x87>
  800a0c:	85 f6                	test   %esi,%esi
  800a0e:	7e 13                	jle    800a23 <readline+0x87>
			if (echoing)
  800a10:	85 ff                	test   %edi,%edi
  800a12:	74 0c                	je     800a20 <readline+0x84>
				cputchar('\b');
  800a14:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800a1b:	e8 c2 f7 ff ff       	call   8001e2 <cputchar>
			i--;
  800a20:	4e                   	dec    %esi
  800a21:	eb b4                	jmp    8009d7 <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a23:	83 fb 1f             	cmp    $0x1f,%ebx
  800a26:	7e 1d                	jle    800a45 <readline+0xa9>
  800a28:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a2e:	7f 15                	jg     800a45 <readline+0xa9>
			if (echoing)
  800a30:	85 ff                	test   %edi,%edi
  800a32:	74 08                	je     800a3c <readline+0xa0>
				cputchar(c);
  800a34:	89 1c 24             	mov    %ebx,(%esp)
  800a37:	e8 a6 f7 ff ff       	call   8001e2 <cputchar>
			buf[i++] = c;
  800a3c:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a42:	46                   	inc    %esi
  800a43:	eb 92                	jmp    8009d7 <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  800a45:	83 fb 0a             	cmp    $0xa,%ebx
  800a48:	74 05                	je     800a4f <readline+0xb3>
  800a4a:	83 fb 0d             	cmp    $0xd,%ebx
  800a4d:	75 88                	jne    8009d7 <readline+0x3b>
			if (echoing)
  800a4f:	85 ff                	test   %edi,%edi
  800a51:	74 0c                	je     800a5f <readline+0xc3>
				cputchar('\n');
  800a53:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800a5a:	e8 83 f7 ff ff       	call   8001e2 <cputchar>
			buf[i] = 0;
  800a5f:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a66:	b8 00 40 80 00       	mov    $0x804000,%eax
  800a6b:	eb 05                	jmp    800a72 <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  800a72:	83 c4 1c             	add    $0x1c,%esp
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    
	...

00800a7c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	eb 01                	jmp    800a8a <strlen+0xe>
		n++;
  800a89:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a8a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a8e:	75 f9                	jne    800a89 <strlen+0xd>
		n++;
	return n;
}
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a98:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	eb 01                	jmp    800aa3 <strnlen+0x11>
		n++;
  800aa2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa3:	39 d0                	cmp    %edx,%eax
  800aa5:	74 06                	je     800aad <strnlen+0x1b>
  800aa7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aab:	75 f5                	jne    800aa2 <strnlen+0x10>
		n++;
	return n;
}
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	53                   	push   %ebx
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ac1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ac4:	42                   	inc    %edx
  800ac5:	84 c9                	test   %cl,%cl
  800ac7:	75 f5                	jne    800abe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	53                   	push   %ebx
  800ad0:	83 ec 08             	sub    $0x8,%esp
  800ad3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad6:	89 1c 24             	mov    %ebx,(%esp)
  800ad9:	e8 9e ff ff ff       	call   800a7c <strlen>
	strcpy(dst + len, src);
  800ade:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ae5:	01 d8                	add    %ebx,%eax
  800ae7:	89 04 24             	mov    %eax,(%esp)
  800aea:	e8 c0 ff ff ff       	call   800aaf <strcpy>
	return dst;
}
  800aef:	89 d8                	mov    %ebx,%eax
  800af1:	83 c4 08             	add    $0x8,%esp
  800af4:	5b                   	pop    %ebx
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b02:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0a:	eb 0c                	jmp    800b18 <strncpy+0x21>
		*dst++ = *src;
  800b0c:	8a 1a                	mov    (%edx),%bl
  800b0e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b11:	80 3a 01             	cmpb   $0x1,(%edx)
  800b14:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b17:	41                   	inc    %ecx
  800b18:	39 f1                	cmp    %esi,%ecx
  800b1a:	75 f0                	jne    800b0c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 75 08             	mov    0x8(%ebp),%esi
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b2e:	85 d2                	test   %edx,%edx
  800b30:	75 0a                	jne    800b3c <strlcpy+0x1c>
  800b32:	89 f0                	mov    %esi,%eax
  800b34:	eb 1a                	jmp    800b50 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b36:	88 18                	mov    %bl,(%eax)
  800b38:	40                   	inc    %eax
  800b39:	41                   	inc    %ecx
  800b3a:	eb 02                	jmp    800b3e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b3c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b3e:	4a                   	dec    %edx
  800b3f:	74 0a                	je     800b4b <strlcpy+0x2b>
  800b41:	8a 19                	mov    (%ecx),%bl
  800b43:	84 db                	test   %bl,%bl
  800b45:	75 ef                	jne    800b36 <strlcpy+0x16>
  800b47:	89 c2                	mov    %eax,%edx
  800b49:	eb 02                	jmp    800b4d <strlcpy+0x2d>
  800b4b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b4d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b50:	29 f0                	sub    %esi,%eax
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b5f:	eb 02                	jmp    800b63 <strcmp+0xd>
		p++, q++;
  800b61:	41                   	inc    %ecx
  800b62:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b63:	8a 01                	mov    (%ecx),%al
  800b65:	84 c0                	test   %al,%al
  800b67:	74 04                	je     800b6d <strcmp+0x17>
  800b69:	3a 02                	cmp    (%edx),%al
  800b6b:	74 f4                	je     800b61 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6d:	0f b6 c0             	movzbl %al,%eax
  800b70:	0f b6 12             	movzbl (%edx),%edx
  800b73:	29 d0                	sub    %edx,%eax
}
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	53                   	push   %ebx
  800b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b81:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b84:	eb 03                	jmp    800b89 <strncmp+0x12>
		n--, p++, q++;
  800b86:	4a                   	dec    %edx
  800b87:	40                   	inc    %eax
  800b88:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b89:	85 d2                	test   %edx,%edx
  800b8b:	74 14                	je     800ba1 <strncmp+0x2a>
  800b8d:	8a 18                	mov    (%eax),%bl
  800b8f:	84 db                	test   %bl,%bl
  800b91:	74 04                	je     800b97 <strncmp+0x20>
  800b93:	3a 19                	cmp    (%ecx),%bl
  800b95:	74 ef                	je     800b86 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b97:	0f b6 00             	movzbl (%eax),%eax
  800b9a:	0f b6 11             	movzbl (%ecx),%edx
  800b9d:	29 d0                	sub    %edx,%eax
  800b9f:	eb 05                	jmp    800ba6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	8b 45 08             	mov    0x8(%ebp),%eax
  800baf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bb2:	eb 05                	jmp    800bb9 <strchr+0x10>
		if (*s == c)
  800bb4:	38 ca                	cmp    %cl,%dl
  800bb6:	74 0c                	je     800bc4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bb8:	40                   	inc    %eax
  800bb9:	8a 10                	mov    (%eax),%dl
  800bbb:	84 d2                	test   %dl,%dl
  800bbd:	75 f5                	jne    800bb4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bcf:	eb 05                	jmp    800bd6 <strfind+0x10>
		if (*s == c)
  800bd1:	38 ca                	cmp    %cl,%dl
  800bd3:	74 07                	je     800bdc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bd5:	40                   	inc    %eax
  800bd6:	8a 10                	mov    (%eax),%dl
  800bd8:	84 d2                	test   %dl,%dl
  800bda:	75 f5                	jne    800bd1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bed:	85 c9                	test   %ecx,%ecx
  800bef:	74 30                	je     800c21 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bf7:	75 25                	jne    800c1e <memset+0x40>
  800bf9:	f6 c1 03             	test   $0x3,%cl
  800bfc:	75 20                	jne    800c1e <memset+0x40>
		c &= 0xFF;
  800bfe:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	c1 e3 08             	shl    $0x8,%ebx
  800c06:	89 d6                	mov    %edx,%esi
  800c08:	c1 e6 18             	shl    $0x18,%esi
  800c0b:	89 d0                	mov    %edx,%eax
  800c0d:	c1 e0 10             	shl    $0x10,%eax
  800c10:	09 f0                	or     %esi,%eax
  800c12:	09 d0                	or     %edx,%eax
  800c14:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c16:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c19:	fc                   	cld    
  800c1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c1c:	eb 03                	jmp    800c21 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c1e:	fc                   	cld    
  800c1f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c21:	89 f8                	mov    %edi,%eax
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c36:	39 c6                	cmp    %eax,%esi
  800c38:	73 34                	jae    800c6e <memmove+0x46>
  800c3a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c3d:	39 d0                	cmp    %edx,%eax
  800c3f:	73 2d                	jae    800c6e <memmove+0x46>
		s += n;
		d += n;
  800c41:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c44:	f6 c2 03             	test   $0x3,%dl
  800c47:	75 1b                	jne    800c64 <memmove+0x3c>
  800c49:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c4f:	75 13                	jne    800c64 <memmove+0x3c>
  800c51:	f6 c1 03             	test   $0x3,%cl
  800c54:	75 0e                	jne    800c64 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c56:	83 ef 04             	sub    $0x4,%edi
  800c59:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c5c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c5f:	fd                   	std    
  800c60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c62:	eb 07                	jmp    800c6b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c64:	4f                   	dec    %edi
  800c65:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c68:	fd                   	std    
  800c69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c6b:	fc                   	cld    
  800c6c:	eb 20                	jmp    800c8e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c74:	75 13                	jne    800c89 <memmove+0x61>
  800c76:	a8 03                	test   $0x3,%al
  800c78:	75 0f                	jne    800c89 <memmove+0x61>
  800c7a:	f6 c1 03             	test   $0x3,%cl
  800c7d:	75 0a                	jne    800c89 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c7f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c82:	89 c7                	mov    %eax,%edi
  800c84:	fc                   	cld    
  800c85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c87:	eb 05                	jmp    800c8e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c89:	89 c7                	mov    %eax,%edi
  800c8b:	fc                   	cld    
  800c8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c98:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca9:	89 04 24             	mov    %eax,(%esp)
  800cac:	e8 77 ff ff ff       	call   800c28 <memmove>
}
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc7:	eb 16                	jmp    800cdf <memcmp+0x2c>
		if (*s1 != *s2)
  800cc9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ccc:	42                   	inc    %edx
  800ccd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cd1:	38 c8                	cmp    %cl,%al
  800cd3:	74 0a                	je     800cdf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cd5:	0f b6 c0             	movzbl %al,%eax
  800cd8:	0f b6 c9             	movzbl %cl,%ecx
  800cdb:	29 c8                	sub    %ecx,%eax
  800cdd:	eb 09                	jmp    800ce8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdf:	39 da                	cmp    %ebx,%edx
  800ce1:	75 e6                	jne    800cc9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf6:	89 c2                	mov    %eax,%edx
  800cf8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cfb:	eb 05                	jmp    800d02 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cfd:	38 08                	cmp    %cl,(%eax)
  800cff:	74 05                	je     800d06 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d01:	40                   	inc    %eax
  800d02:	39 d0                	cmp    %edx,%eax
  800d04:	72 f7                	jb     800cfd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d14:	eb 01                	jmp    800d17 <strtol+0xf>
		s++;
  800d16:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d17:	8a 02                	mov    (%edx),%al
  800d19:	3c 20                	cmp    $0x20,%al
  800d1b:	74 f9                	je     800d16 <strtol+0xe>
  800d1d:	3c 09                	cmp    $0x9,%al
  800d1f:	74 f5                	je     800d16 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d21:	3c 2b                	cmp    $0x2b,%al
  800d23:	75 08                	jne    800d2d <strtol+0x25>
		s++;
  800d25:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d26:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2b:	eb 13                	jmp    800d40 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d2d:	3c 2d                	cmp    $0x2d,%al
  800d2f:	75 0a                	jne    800d3b <strtol+0x33>
		s++, neg = 1;
  800d31:	8d 52 01             	lea    0x1(%edx),%edx
  800d34:	bf 01 00 00 00       	mov    $0x1,%edi
  800d39:	eb 05                	jmp    800d40 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d40:	85 db                	test   %ebx,%ebx
  800d42:	74 05                	je     800d49 <strtol+0x41>
  800d44:	83 fb 10             	cmp    $0x10,%ebx
  800d47:	75 28                	jne    800d71 <strtol+0x69>
  800d49:	8a 02                	mov    (%edx),%al
  800d4b:	3c 30                	cmp    $0x30,%al
  800d4d:	75 10                	jne    800d5f <strtol+0x57>
  800d4f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d53:	75 0a                	jne    800d5f <strtol+0x57>
		s += 2, base = 16;
  800d55:	83 c2 02             	add    $0x2,%edx
  800d58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d5d:	eb 12                	jmp    800d71 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d5f:	85 db                	test   %ebx,%ebx
  800d61:	75 0e                	jne    800d71 <strtol+0x69>
  800d63:	3c 30                	cmp    $0x30,%al
  800d65:	75 05                	jne    800d6c <strtol+0x64>
		s++, base = 8;
  800d67:	42                   	inc    %edx
  800d68:	b3 08                	mov    $0x8,%bl
  800d6a:	eb 05                	jmp    800d71 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
  800d76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d78:	8a 0a                	mov    (%edx),%cl
  800d7a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d7d:	80 fb 09             	cmp    $0x9,%bl
  800d80:	77 08                	ja     800d8a <strtol+0x82>
			dig = *s - '0';
  800d82:	0f be c9             	movsbl %cl,%ecx
  800d85:	83 e9 30             	sub    $0x30,%ecx
  800d88:	eb 1e                	jmp    800da8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d8a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d8d:	80 fb 19             	cmp    $0x19,%bl
  800d90:	77 08                	ja     800d9a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d92:	0f be c9             	movsbl %cl,%ecx
  800d95:	83 e9 57             	sub    $0x57,%ecx
  800d98:	eb 0e                	jmp    800da8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d9a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d9d:	80 fb 19             	cmp    $0x19,%bl
  800da0:	77 12                	ja     800db4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800da2:	0f be c9             	movsbl %cl,%ecx
  800da5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800da8:	39 f1                	cmp    %esi,%ecx
  800daa:	7d 0c                	jge    800db8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800dac:	42                   	inc    %edx
  800dad:	0f af c6             	imul   %esi,%eax
  800db0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800db2:	eb c4                	jmp    800d78 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800db4:	89 c1                	mov    %eax,%ecx
  800db6:	eb 02                	jmp    800dba <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800db8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dbe:	74 05                	je     800dc5 <strtol+0xbd>
		*endptr = (char *) s;
  800dc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dc5:	85 ff                	test   %edi,%edi
  800dc7:	74 04                	je     800dcd <strtol+0xc5>
  800dc9:	89 c8                	mov    %ecx,%eax
  800dcb:	f7 d8                	neg    %eax
}
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    
	...

00800dd4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800dda:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	89 c7                	mov    %eax,%edi
  800de9:	89 c6                	mov    %eax,%esi
  800deb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfd:	b8 01 00 00 00       	mov    $0x1,%eax
  800e02:	89 d1                	mov    %edx,%ecx
  800e04:	89 d3                	mov    %edx,%ebx
  800e06:	89 d7                	mov    %edx,%edi
  800e08:	89 d6                	mov    %edx,%esi
  800e0a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	57                   	push   %edi
  800e15:	56                   	push   %esi
  800e16:	53                   	push   %ebx
  800e17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 cb                	mov    %ecx,%ebx
  800e29:	89 cf                	mov    %ecx,%edi
  800e2b:	89 ce                	mov    %ecx,%esi
  800e2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	7e 28                	jle    800e5b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e37:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  800e46:	00 
  800e47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4e:	00 
  800e4f:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  800e56:	e8 d1 f4 ff ff       	call   80032c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e5b:	83 c4 2c             	add    $0x2c,%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	89 d3                	mov    %edx,%ebx
  800e77:	89 d7                	mov    %edx,%edi
  800e79:	89 d6                	mov    %edx,%esi
  800e7b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <sys_yield>:

void
sys_yield(void)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e92:	89 d1                	mov    %edx,%ecx
  800e94:	89 d3                	mov    %edx,%ebx
  800e96:	89 d7                	mov    %edx,%edi
  800e98:	89 d6                	mov    %edx,%esi
  800e9a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
  800ea7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaa:	be 00 00 00 00       	mov    $0x0,%esi
  800eaf:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	89 f7                	mov    %esi,%edi
  800ebf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	7e 28                	jle    800eed <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  800ee8:	e8 3f f4 ff ff       	call   80032c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eed:	83 c4 2c             	add    $0x2c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
  800efb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	b8 05 00 00 00       	mov    $0x5,%eax
  800f03:	8b 75 18             	mov    0x18(%ebp),%esi
  800f06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f14:	85 c0                	test   %eax,%eax
  800f16:	7e 28                	jle    800f40 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f23:	00 
  800f24:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f33:	00 
  800f34:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  800f3b:	e8 ec f3 ff ff       	call   80032c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f40:	83 c4 2c             	add    $0x2c,%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	57                   	push   %edi
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
  800f4e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f56:	b8 06 00 00 00       	mov    $0x6,%eax
  800f5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f61:	89 df                	mov    %ebx,%edi
  800f63:	89 de                	mov    %ebx,%esi
  800f65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f67:	85 c0                	test   %eax,%eax
  800f69:	7e 28                	jle    800f93 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f76:	00 
  800f77:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f86:	00 
  800f87:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  800f8e:	e8 99 f3 ff ff       	call   80032c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f93:	83 c4 2c             	add    $0x2c,%esp
  800f96:	5b                   	pop    %ebx
  800f97:	5e                   	pop    %esi
  800f98:	5f                   	pop    %edi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa9:	b8 08 00 00 00       	mov    $0x8,%eax
  800fae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb4:	89 df                	mov    %ebx,%edi
  800fb6:	89 de                	mov    %ebx,%esi
  800fb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	7e 28                	jle    800fe6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fc9:	00 
  800fca:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd9:	00 
  800fda:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  800fe1:	e8 46 f3 ff ff       	call   80032c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fe6:	83 c4 2c             	add    $0x2c,%esp
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffc:	b8 09 00 00 00       	mov    $0x9,%eax
  801001:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801004:	8b 55 08             	mov    0x8(%ebp),%edx
  801007:	89 df                	mov    %ebx,%edi
  801009:	89 de                	mov    %ebx,%esi
  80100b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	7e 28                	jle    801039 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801011:	89 44 24 10          	mov    %eax,0x10(%esp)
  801015:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80101c:	00 
  80101d:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  801024:	00 
  801025:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80102c:	00 
  80102d:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  801034:	e8 f3 f2 ff ff       	call   80032c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801039:	83 c4 2c             	add    $0x2c,%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	57                   	push   %edi
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801054:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801057:	8b 55 08             	mov    0x8(%ebp),%edx
  80105a:	89 df                	mov    %ebx,%edi
  80105c:	89 de                	mov    %ebx,%esi
  80105e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801060:	85 c0                	test   %eax,%eax
  801062:	7e 28                	jle    80108c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801064:	89 44 24 10          	mov    %eax,0x10(%esp)
  801068:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80106f:	00 
  801070:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  801077:	00 
  801078:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107f:	00 
  801080:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  801087:	e8 a0 f2 ff ff       	call   80032c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80108c:	83 c4 2c             	add    $0x2c,%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109a:	be 00 00 00 00       	mov    $0x0,%esi
  80109f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010a4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010b2:	5b                   	pop    %ebx
  8010b3:	5e                   	pop    %esi
  8010b4:	5f                   	pop    %edi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cd:	89 cb                	mov    %ecx,%ebx
  8010cf:	89 cf                	mov    %ecx,%edi
  8010d1:	89 ce                	mov    %ecx,%esi
  8010d3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	7e 28                	jle    801101 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010dd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  8010ec:	00 
  8010ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f4:	00 
  8010f5:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  8010fc:	e8 2b f2 ff ff       	call   80032c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801101:	83 c4 2c             	add    $0x2c,%esp
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    
  801109:	00 00                	add    %al,(%eax)
	...

0080110c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	05 00 00 00 30       	add    $0x30000000,%eax
  801117:	c1 e8 0c             	shr    $0xc,%eax
}
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801122:	8b 45 08             	mov    0x8(%ebp),%eax
  801125:	89 04 24             	mov    %eax,(%esp)
  801128:	e8 df ff ff ff       	call   80110c <fd2num>
  80112d:	05 20 00 0d 00       	add    $0xd0020,%eax
  801132:	c1 e0 0c             	shl    $0xc,%eax
}
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	53                   	push   %ebx
  80113b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80113e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801143:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801145:	89 c2                	mov    %eax,%edx
  801147:	c1 ea 16             	shr    $0x16,%edx
  80114a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801151:	f6 c2 01             	test   $0x1,%dl
  801154:	74 11                	je     801167 <fd_alloc+0x30>
  801156:	89 c2                	mov    %eax,%edx
  801158:	c1 ea 0c             	shr    $0xc,%edx
  80115b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801162:	f6 c2 01             	test   $0x1,%dl
  801165:	75 09                	jne    801170 <fd_alloc+0x39>
			*fd_store = fd;
  801167:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801169:	b8 00 00 00 00       	mov    $0x0,%eax
  80116e:	eb 17                	jmp    801187 <fd_alloc+0x50>
  801170:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801175:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80117a:	75 c7                	jne    801143 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80117c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801182:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801187:	5b                   	pop    %ebx
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801190:	83 f8 1f             	cmp    $0x1f,%eax
  801193:	77 36                	ja     8011cb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801195:	05 00 00 0d 00       	add    $0xd0000,%eax
  80119a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	c1 ea 16             	shr    $0x16,%edx
  8011a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a9:	f6 c2 01             	test   $0x1,%dl
  8011ac:	74 24                	je     8011d2 <fd_lookup+0x48>
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	c1 ea 0c             	shr    $0xc,%edx
  8011b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ba:	f6 c2 01             	test   $0x1,%dl
  8011bd:	74 1a                	je     8011d9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c2:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c9:	eb 13                	jmp    8011de <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d0:	eb 0c                	jmp    8011de <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d7:	eb 05                	jmp    8011de <fd_lookup+0x54>
  8011d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	53                   	push   %ebx
  8011e4:	83 ec 14             	sub    $0x14,%esp
  8011e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8011ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f2:	eb 0e                	jmp    801202 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8011f4:	39 08                	cmp    %ecx,(%eax)
  8011f6:	75 09                	jne    801201 <dev_lookup+0x21>
			*dev = devtab[i];
  8011f8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ff:	eb 33                	jmp    801234 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801201:	42                   	inc    %edx
  801202:	8b 04 95 3c 26 80 00 	mov    0x80263c(,%edx,4),%eax
  801209:	85 c0                	test   %eax,%eax
  80120b:	75 e7                	jne    8011f4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80120d:	a1 04 44 80 00       	mov    0x804404,%eax
  801212:	8b 40 48             	mov    0x48(%eax),%eax
  801215:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121d:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  801224:	e8 fb f1 ff ff       	call   800424 <cprintf>
	*dev = 0;
  801229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80122f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801234:	83 c4 14             	add    $0x14,%esp
  801237:	5b                   	pop    %ebx
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	56                   	push   %esi
  80123e:	53                   	push   %ebx
  80123f:	83 ec 30             	sub    $0x30,%esp
  801242:	8b 75 08             	mov    0x8(%ebp),%esi
  801245:	8a 45 0c             	mov    0xc(%ebp),%al
  801248:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80124b:	89 34 24             	mov    %esi,(%esp)
  80124e:	e8 b9 fe ff ff       	call   80110c <fd2num>
  801253:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801256:	89 54 24 04          	mov    %edx,0x4(%esp)
  80125a:	89 04 24             	mov    %eax,(%esp)
  80125d:	e8 28 ff ff ff       	call   80118a <fd_lookup>
  801262:	89 c3                	mov    %eax,%ebx
  801264:	85 c0                	test   %eax,%eax
  801266:	78 05                	js     80126d <fd_close+0x33>
	    || fd != fd2)
  801268:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80126b:	74 0d                	je     80127a <fd_close+0x40>
		return (must_exist ? r : 0);
  80126d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801271:	75 46                	jne    8012b9 <fd_close+0x7f>
  801273:	bb 00 00 00 00       	mov    $0x0,%ebx
  801278:	eb 3f                	jmp    8012b9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80127a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801281:	8b 06                	mov    (%esi),%eax
  801283:	89 04 24             	mov    %eax,(%esp)
  801286:	e8 55 ff ff ff       	call   8011e0 <dev_lookup>
  80128b:	89 c3                	mov    %eax,%ebx
  80128d:	85 c0                	test   %eax,%eax
  80128f:	78 18                	js     8012a9 <fd_close+0x6f>
		if (dev->dev_close)
  801291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801294:	8b 40 10             	mov    0x10(%eax),%eax
  801297:	85 c0                	test   %eax,%eax
  801299:	74 09                	je     8012a4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80129b:	89 34 24             	mov    %esi,(%esp)
  80129e:	ff d0                	call   *%eax
  8012a0:	89 c3                	mov    %eax,%ebx
  8012a2:	eb 05                	jmp    8012a9 <fd_close+0x6f>
		else
			r = 0;
  8012a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b4:	e8 8f fc ff ff       	call   800f48 <sys_page_unmap>
	return r;
}
  8012b9:	89 d8                	mov    %ebx,%eax
  8012bb:	83 c4 30             	add    $0x30,%esp
  8012be:	5b                   	pop    %ebx
  8012bf:	5e                   	pop    %esi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d2:	89 04 24             	mov    %eax,(%esp)
  8012d5:	e8 b0 fe ff ff       	call   80118a <fd_lookup>
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 13                	js     8012f1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8012de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012e5:	00 
  8012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e9:	89 04 24             	mov    %eax,(%esp)
  8012ec:	e8 49 ff ff ff       	call   80123a <fd_close>
}
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <close_all>:

void
close_all(void)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ff:	89 1c 24             	mov    %ebx,(%esp)
  801302:	e8 bb ff ff ff       	call   8012c2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801307:	43                   	inc    %ebx
  801308:	83 fb 20             	cmp    $0x20,%ebx
  80130b:	75 f2                	jne    8012ff <close_all+0xc>
		close(i);
}
  80130d:	83 c4 14             	add    $0x14,%esp
  801310:	5b                   	pop    %ebx
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    

00801313 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	57                   	push   %edi
  801317:	56                   	push   %esi
  801318:	53                   	push   %ebx
  801319:	83 ec 4c             	sub    $0x4c,%esp
  80131c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80131f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801322:	89 44 24 04          	mov    %eax,0x4(%esp)
  801326:	8b 45 08             	mov    0x8(%ebp),%eax
  801329:	89 04 24             	mov    %eax,(%esp)
  80132c:	e8 59 fe ff ff       	call   80118a <fd_lookup>
  801331:	89 c3                	mov    %eax,%ebx
  801333:	85 c0                	test   %eax,%eax
  801335:	0f 88 e1 00 00 00    	js     80141c <dup+0x109>
		return r;
	close(newfdnum);
  80133b:	89 3c 24             	mov    %edi,(%esp)
  80133e:	e8 7f ff ff ff       	call   8012c2 <close>

	newfd = INDEX2FD(newfdnum);
  801343:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801349:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80134c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80134f:	89 04 24             	mov    %eax,(%esp)
  801352:	e8 c5 fd ff ff       	call   80111c <fd2data>
  801357:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801359:	89 34 24             	mov    %esi,(%esp)
  80135c:	e8 bb fd ff ff       	call   80111c <fd2data>
  801361:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801364:	89 d8                	mov    %ebx,%eax
  801366:	c1 e8 16             	shr    $0x16,%eax
  801369:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801370:	a8 01                	test   $0x1,%al
  801372:	74 46                	je     8013ba <dup+0xa7>
  801374:	89 d8                	mov    %ebx,%eax
  801376:	c1 e8 0c             	shr    $0xc,%eax
  801379:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801380:	f6 c2 01             	test   $0x1,%dl
  801383:	74 35                	je     8013ba <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801385:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80138c:	25 07 0e 00 00       	and    $0xe07,%eax
  801391:	89 44 24 10          	mov    %eax,0x10(%esp)
  801395:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801398:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013a3:	00 
  8013a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013af:	e8 41 fb ff ff       	call   800ef5 <sys_page_map>
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 3b                	js     8013f5 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013bd:	89 c2                	mov    %eax,%edx
  8013bf:	c1 ea 0c             	shr    $0xc,%edx
  8013c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c9:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013cf:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013de:	00 
  8013df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ea:	e8 06 fb ff ff       	call   800ef5 <sys_page_map>
  8013ef:	89 c3                	mov    %eax,%ebx
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	79 25                	jns    80141a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801400:	e8 43 fb ff ff       	call   800f48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801405:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801413:	e8 30 fb ff ff       	call   800f48 <sys_page_unmap>
	return r;
  801418:	eb 02                	jmp    80141c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80141a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80141c:	89 d8                	mov    %ebx,%eax
  80141e:	83 c4 4c             	add    $0x4c,%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	53                   	push   %ebx
  80142a:	83 ec 24             	sub    $0x24,%esp
  80142d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801430:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801433:	89 44 24 04          	mov    %eax,0x4(%esp)
  801437:	89 1c 24             	mov    %ebx,(%esp)
  80143a:	e8 4b fd ff ff       	call   80118a <fd_lookup>
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 6d                	js     8014b0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801446:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	8b 00                	mov    (%eax),%eax
  80144f:	89 04 24             	mov    %eax,(%esp)
  801452:	e8 89 fd ff ff       	call   8011e0 <dev_lookup>
  801457:	85 c0                	test   %eax,%eax
  801459:	78 55                	js     8014b0 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145e:	8b 50 08             	mov    0x8(%eax),%edx
  801461:	83 e2 03             	and    $0x3,%edx
  801464:	83 fa 01             	cmp    $0x1,%edx
  801467:	75 23                	jne    80148c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801469:	a1 04 44 80 00       	mov    0x804404,%eax
  80146e:	8b 40 48             	mov    0x48(%eax),%eax
  801471:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801475:	89 44 24 04          	mov    %eax,0x4(%esp)
  801479:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  801480:	e8 9f ef ff ff       	call   800424 <cprintf>
		return -E_INVAL;
  801485:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80148a:	eb 24                	jmp    8014b0 <read+0x8a>
	}
	if (!dev->dev_read)
  80148c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148f:	8b 52 08             	mov    0x8(%edx),%edx
  801492:	85 d2                	test   %edx,%edx
  801494:	74 15                	je     8014ab <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801496:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801499:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80149d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014a4:	89 04 24             	mov    %eax,(%esp)
  8014a7:	ff d2                	call   *%edx
  8014a9:	eb 05                	jmp    8014b0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014b0:	83 c4 24             	add    $0x24,%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	57                   	push   %edi
  8014ba:	56                   	push   %esi
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 1c             	sub    $0x1c,%esp
  8014bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ca:	eb 23                	jmp    8014ef <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014cc:	89 f0                	mov    %esi,%eax
  8014ce:	29 d8                	sub    %ebx,%eax
  8014d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d7:	01 d8                	add    %ebx,%eax
  8014d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014dd:	89 3c 24             	mov    %edi,(%esp)
  8014e0:	e8 41 ff ff ff       	call   801426 <read>
		if (m < 0)
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 10                	js     8014f9 <readn+0x43>
			return m;
		if (m == 0)
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	74 0a                	je     8014f7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ed:	01 c3                	add    %eax,%ebx
  8014ef:	39 f3                	cmp    %esi,%ebx
  8014f1:	72 d9                	jb     8014cc <readn+0x16>
  8014f3:	89 d8                	mov    %ebx,%eax
  8014f5:	eb 02                	jmp    8014f9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8014f7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8014f9:	83 c4 1c             	add    $0x1c,%esp
  8014fc:	5b                   	pop    %ebx
  8014fd:	5e                   	pop    %esi
  8014fe:	5f                   	pop    %edi
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    

00801501 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	53                   	push   %ebx
  801505:	83 ec 24             	sub    $0x24,%esp
  801508:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801512:	89 1c 24             	mov    %ebx,(%esp)
  801515:	e8 70 fc ff ff       	call   80118a <fd_lookup>
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 68                	js     801586 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801521:	89 44 24 04          	mov    %eax,0x4(%esp)
  801525:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801528:	8b 00                	mov    (%eax),%eax
  80152a:	89 04 24             	mov    %eax,(%esp)
  80152d:	e8 ae fc ff ff       	call   8011e0 <dev_lookup>
  801532:	85 c0                	test   %eax,%eax
  801534:	78 50                	js     801586 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801536:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801539:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153d:	75 23                	jne    801562 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80153f:	a1 04 44 80 00       	mov    0x804404,%eax
  801544:	8b 40 48             	mov    0x48(%eax),%eax
  801547:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80154b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154f:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  801556:	e8 c9 ee ff ff       	call   800424 <cprintf>
		return -E_INVAL;
  80155b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801560:	eb 24                	jmp    801586 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801565:	8b 52 0c             	mov    0xc(%edx),%edx
  801568:	85 d2                	test   %edx,%edx
  80156a:	74 15                	je     801581 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80156f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801573:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801576:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80157a:	89 04 24             	mov    %eax,(%esp)
  80157d:	ff d2                	call   *%edx
  80157f:	eb 05                	jmp    801586 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801581:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801586:	83 c4 24             	add    $0x24,%esp
  801589:	5b                   	pop    %ebx
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <seek>:

int
seek(int fdnum, off_t offset)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801592:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801595:	89 44 24 04          	mov    %eax,0x4(%esp)
  801599:	8b 45 08             	mov    0x8(%ebp),%eax
  80159c:	89 04 24             	mov    %eax,(%esp)
  80159f:	e8 e6 fb ff ff       	call   80118a <fd_lookup>
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 0e                	js     8015b6 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ae:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 24             	sub    $0x24,%esp
  8015bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c9:	89 1c 24             	mov    %ebx,(%esp)
  8015cc:	e8 b9 fb ff ff       	call   80118a <fd_lookup>
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 61                	js     801636 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015df:	8b 00                	mov    (%eax),%eax
  8015e1:	89 04 24             	mov    %eax,(%esp)
  8015e4:	e8 f7 fb ff ff       	call   8011e0 <dev_lookup>
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 49                	js     801636 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f4:	75 23                	jne    801619 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f6:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fb:	8b 40 48             	mov    0x48(%eax),%eax
  8015fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801602:	89 44 24 04          	mov    %eax,0x4(%esp)
  801606:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  80160d:	e8 12 ee ff ff       	call   800424 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801612:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801617:	eb 1d                	jmp    801636 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801619:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161c:	8b 52 18             	mov    0x18(%edx),%edx
  80161f:	85 d2                	test   %edx,%edx
  801621:	74 0e                	je     801631 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801623:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801626:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80162a:	89 04 24             	mov    %eax,(%esp)
  80162d:	ff d2                	call   *%edx
  80162f:	eb 05                	jmp    801636 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801631:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801636:	83 c4 24             	add    $0x24,%esp
  801639:	5b                   	pop    %ebx
  80163a:	5d                   	pop    %ebp
  80163b:	c3                   	ret    

0080163c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	53                   	push   %ebx
  801640:	83 ec 24             	sub    $0x24,%esp
  801643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801646:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801649:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164d:	8b 45 08             	mov    0x8(%ebp),%eax
  801650:	89 04 24             	mov    %eax,(%esp)
  801653:	e8 32 fb ff ff       	call   80118a <fd_lookup>
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 52                	js     8016ae <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	8b 00                	mov    (%eax),%eax
  801668:	89 04 24             	mov    %eax,(%esp)
  80166b:	e8 70 fb ff ff       	call   8011e0 <dev_lookup>
  801670:	85 c0                	test   %eax,%eax
  801672:	78 3a                	js     8016ae <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801677:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167b:	74 2c                	je     8016a9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80167d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801680:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801687:	00 00 00 
	stat->st_isdir = 0;
  80168a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801691:	00 00 00 
	stat->st_dev = dev;
  801694:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80169a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80169e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016a1:	89 14 24             	mov    %edx,(%esp)
  8016a4:	ff 50 14             	call   *0x14(%eax)
  8016a7:	eb 05                	jmp    8016ae <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ae:	83 c4 24             	add    $0x24,%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016c3:	00 
  8016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c7:	89 04 24             	mov    %eax,(%esp)
  8016ca:	e8 fe 01 00 00       	call   8018cd <open>
  8016cf:	89 c3                	mov    %eax,%ebx
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 1b                	js     8016f0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8016d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dc:	89 1c 24             	mov    %ebx,(%esp)
  8016df:	e8 58 ff ff ff       	call   80163c <fstat>
  8016e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e6:	89 1c 24             	mov    %ebx,(%esp)
  8016e9:	e8 d4 fb ff ff       	call   8012c2 <close>
	return r;
  8016ee:	89 f3                	mov    %esi,%ebx
}
  8016f0:	89 d8                	mov    %ebx,%eax
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    
  8016f9:	00 00                	add    %al,(%eax)
	...

008016fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	83 ec 10             	sub    $0x10,%esp
  801704:	89 c3                	mov    %eax,%ebx
  801706:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801708:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80170f:	75 11                	jne    801722 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801711:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801718:	e8 d2 07 00 00       	call   801eef <ipc_find_env>
  80171d:	a3 00 44 80 00       	mov    %eax,0x804400
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801722:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801729:	00 
  80172a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801731:	00 
  801732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801736:	a1 00 44 80 00       	mov    0x804400,%eax
  80173b:	89 04 24             	mov    %eax,(%esp)
  80173e:	e8 42 07 00 00       	call   801e85 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801743:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80174a:	00 
  80174b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80174f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801756:	e8 c1 06 00 00       	call   801e1c <ipc_recv>
}
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801768:	8b 45 08             	mov    0x8(%ebp),%eax
  80176b:	8b 40 0c             	mov    0xc(%eax),%eax
  80176e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801773:	8b 45 0c             	mov    0xc(%ebp),%eax
  801776:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80177b:	ba 00 00 00 00       	mov    $0x0,%edx
  801780:	b8 02 00 00 00       	mov    $0x2,%eax
  801785:	e8 72 ff ff ff       	call   8016fc <fsipc>
}
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	8b 40 0c             	mov    0xc(%eax),%eax
  801798:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80179d:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017a7:	e8 50 ff ff ff       	call   8016fc <fsipc>
}
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	53                   	push   %ebx
  8017b2:	83 ec 14             	sub    $0x14,%esp
  8017b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017be:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8017cd:	e8 2a ff ff ff       	call   8016fc <fsipc>
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	78 2b                	js     801801 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017d6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017dd:	00 
  8017de:	89 1c 24             	mov    %ebx,(%esp)
  8017e1:	e8 c9 f2 ff ff       	call   800aaf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8017eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8017f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801801:	83 c4 14             	add    $0x14,%esp
  801804:	5b                   	pop    %ebx
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80180d:	c7 44 24 08 4c 26 80 	movl   $0x80264c,0x8(%esp)
  801814:	00 
  801815:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  80181c:	00 
  80181d:	c7 04 24 6a 26 80 00 	movl   $0x80266a,(%esp)
  801824:	e8 03 eb ff ff       	call   80032c <_panic>

00801829 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	56                   	push   %esi
  80182d:	53                   	push   %ebx
  80182e:	83 ec 10             	sub    $0x10,%esp
  801831:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801834:	8b 45 08             	mov    0x8(%ebp),%eax
  801837:	8b 40 0c             	mov    0xc(%eax),%eax
  80183a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80183f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801845:	ba 00 00 00 00       	mov    $0x0,%edx
  80184a:	b8 03 00 00 00       	mov    $0x3,%eax
  80184f:	e8 a8 fe ff ff       	call   8016fc <fsipc>
  801854:	89 c3                	mov    %eax,%ebx
  801856:	85 c0                	test   %eax,%eax
  801858:	78 6a                	js     8018c4 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80185a:	39 c6                	cmp    %eax,%esi
  80185c:	73 24                	jae    801882 <devfile_read+0x59>
  80185e:	c7 44 24 0c 75 26 80 	movl   $0x802675,0xc(%esp)
  801865:	00 
  801866:	c7 44 24 08 7c 26 80 	movl   $0x80267c,0x8(%esp)
  80186d:	00 
  80186e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801875:	00 
  801876:	c7 04 24 6a 26 80 00 	movl   $0x80266a,(%esp)
  80187d:	e8 aa ea ff ff       	call   80032c <_panic>
	assert(r <= PGSIZE);
  801882:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801887:	7e 24                	jle    8018ad <devfile_read+0x84>
  801889:	c7 44 24 0c 91 26 80 	movl   $0x802691,0xc(%esp)
  801890:	00 
  801891:	c7 44 24 08 7c 26 80 	movl   $0x80267c,0x8(%esp)
  801898:	00 
  801899:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8018a0:	00 
  8018a1:	c7 04 24 6a 26 80 00 	movl   $0x80266a,(%esp)
  8018a8:	e8 7f ea ff ff       	call   80032c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b1:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018b8:	00 
  8018b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bc:	89 04 24             	mov    %eax,(%esp)
  8018bf:	e8 64 f3 ff ff       	call   800c28 <memmove>
	return r;
}
  8018c4:	89 d8                	mov    %ebx,%eax
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	5b                   	pop    %ebx
  8018ca:	5e                   	pop    %esi
  8018cb:	5d                   	pop    %ebp
  8018cc:	c3                   	ret    

008018cd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	56                   	push   %esi
  8018d1:	53                   	push   %ebx
  8018d2:	83 ec 20             	sub    $0x20,%esp
  8018d5:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d8:	89 34 24             	mov    %esi,(%esp)
  8018db:	e8 9c f1 ff ff       	call   800a7c <strlen>
  8018e0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e5:	7f 60                	jg     801947 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ea:	89 04 24             	mov    %eax,(%esp)
  8018ed:	e8 45 f8 ff ff       	call   801137 <fd_alloc>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 54                	js     80194c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018fc:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801903:	e8 a7 f1 ff ff       	call   800aaf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801910:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801913:	b8 01 00 00 00       	mov    $0x1,%eax
  801918:	e8 df fd ff ff       	call   8016fc <fsipc>
  80191d:	89 c3                	mov    %eax,%ebx
  80191f:	85 c0                	test   %eax,%eax
  801921:	79 15                	jns    801938 <open+0x6b>
		fd_close(fd, 0);
  801923:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80192a:	00 
  80192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192e:	89 04 24             	mov    %eax,(%esp)
  801931:	e8 04 f9 ff ff       	call   80123a <fd_close>
		return r;
  801936:	eb 14                	jmp    80194c <open+0x7f>
	}

	return fd2num(fd);
  801938:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193b:	89 04 24             	mov    %eax,(%esp)
  80193e:	e8 c9 f7 ff ff       	call   80110c <fd2num>
  801943:	89 c3                	mov    %eax,%ebx
  801945:	eb 05                	jmp    80194c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801947:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80194c:	89 d8                	mov    %ebx,%eax
  80194e:	83 c4 20             	add    $0x20,%esp
  801951:	5b                   	pop    %ebx
  801952:	5e                   	pop    %esi
  801953:	5d                   	pop    %ebp
  801954:	c3                   	ret    

00801955 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195b:	ba 00 00 00 00       	mov    $0x0,%edx
  801960:	b8 08 00 00 00       	mov    $0x8,%eax
  801965:	e8 92 fd ff ff       	call   8016fc <fsipc>
}
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	53                   	push   %ebx
  801970:	83 ec 14             	sub    $0x14,%esp
  801973:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801975:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801979:	7e 32                	jle    8019ad <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80197b:	8b 40 04             	mov    0x4(%eax),%eax
  80197e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801982:	8d 43 10             	lea    0x10(%ebx),%eax
  801985:	89 44 24 04          	mov    %eax,0x4(%esp)
  801989:	8b 03                	mov    (%ebx),%eax
  80198b:	89 04 24             	mov    %eax,(%esp)
  80198e:	e8 6e fb ff ff       	call   801501 <write>
		if (result > 0)
  801993:	85 c0                	test   %eax,%eax
  801995:	7e 03                	jle    80199a <writebuf+0x2e>
			b->result += result;
  801997:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80199a:	39 43 04             	cmp    %eax,0x4(%ebx)
  80199d:	74 0e                	je     8019ad <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  80199f:	89 c2                	mov    %eax,%edx
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	7e 05                	jle    8019aa <writebuf+0x3e>
  8019a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019aa:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8019ad:	83 c4 14             	add    $0x14,%esp
  8019b0:	5b                   	pop    %ebx
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    

008019b3 <putch>:

static void
putch(int ch, void *thunk)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	53                   	push   %ebx
  8019b7:	83 ec 04             	sub    $0x4,%esp
  8019ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8019c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8019c3:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8019c7:	40                   	inc    %eax
  8019c8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8019cb:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019d0:	75 0e                	jne    8019e0 <putch+0x2d>
		writebuf(b);
  8019d2:	89 d8                	mov    %ebx,%eax
  8019d4:	e8 93 ff ff ff       	call   80196c <writebuf>
		b->idx = 0;
  8019d9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8019e0:	83 c4 04             	add    $0x4,%esp
  8019e3:	5b                   	pop    %ebx
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019f8:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019ff:	00 00 00 
	b.result = 0;
  801a02:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a09:	00 00 00 
	b.error = 1;
  801a0c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a13:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a16:	8b 45 10             	mov    0x10(%ebp),%eax
  801a19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a20:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a24:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2e:	c7 04 24 b3 19 80 00 	movl   $0x8019b3,(%esp)
  801a35:	e8 4c eb ff ff       	call   800586 <vprintfmt>
	if (b.idx > 0)
  801a3a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a41:	7e 0b                	jle    801a4e <vfprintf+0x68>
		writebuf(&b);
  801a43:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a49:	e8 1e ff ff ff       	call   80196c <writebuf>

	return (b.result ? b.result : b.error);
  801a4e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a54:	85 c0                	test   %eax,%eax
  801a56:	75 06                	jne    801a5e <vfprintf+0x78>
  801a58:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a66:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a69:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	89 04 24             	mov    %eax,(%esp)
  801a7a:	e8 67 ff ff ff       	call   8019e6 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <printf>:

int
printf(const char *fmt, ...)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a87:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a9c:	e8 45 ff ff ff       	call   8019e6 <vfprintf>
	va_end(ap);

	return cnt;
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    
	...

00801aa4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 10             	sub    $0x10,%esp
  801aac:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab2:	89 04 24             	mov    %eax,(%esp)
  801ab5:	e8 62 f6 ff ff       	call   80111c <fd2data>
  801aba:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801abc:	c7 44 24 04 9d 26 80 	movl   $0x80269d,0x4(%esp)
  801ac3:	00 
  801ac4:	89 34 24             	mov    %esi,(%esp)
  801ac7:	e8 e3 ef ff ff       	call   800aaf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801acc:	8b 43 04             	mov    0x4(%ebx),%eax
  801acf:	2b 03                	sub    (%ebx),%eax
  801ad1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ad7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801ade:	00 00 00 
	stat->st_dev = &devpipe;
  801ae1:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801ae8:	30 80 00 
	return 0;
}
  801aeb:	b8 00 00 00 00       	mov    $0x0,%eax
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	5b                   	pop    %ebx
  801af4:	5e                   	pop    %esi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	53                   	push   %ebx
  801afb:	83 ec 14             	sub    $0x14,%esp
  801afe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b0c:	e8 37 f4 ff ff       	call   800f48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b11:	89 1c 24             	mov    %ebx,(%esp)
  801b14:	e8 03 f6 ff ff       	call   80111c <fd2data>
  801b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b24:	e8 1f f4 ff ff       	call   800f48 <sys_page_unmap>
}
  801b29:	83 c4 14             	add    $0x14,%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	57                   	push   %edi
  801b33:	56                   	push   %esi
  801b34:	53                   	push   %ebx
  801b35:	83 ec 2c             	sub    $0x2c,%esp
  801b38:	89 c7                	mov    %eax,%edi
  801b3a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b3d:	a1 04 44 80 00       	mov    0x804404,%eax
  801b42:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b45:	89 3c 24             	mov    %edi,(%esp)
  801b48:	e8 e7 03 00 00       	call   801f34 <pageref>
  801b4d:	89 c6                	mov    %eax,%esi
  801b4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b52:	89 04 24             	mov    %eax,(%esp)
  801b55:	e8 da 03 00 00       	call   801f34 <pageref>
  801b5a:	39 c6                	cmp    %eax,%esi
  801b5c:	0f 94 c0             	sete   %al
  801b5f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801b62:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801b68:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b6b:	39 cb                	cmp    %ecx,%ebx
  801b6d:	75 08                	jne    801b77 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801b6f:	83 c4 2c             	add    $0x2c,%esp
  801b72:	5b                   	pop    %ebx
  801b73:	5e                   	pop    %esi
  801b74:	5f                   	pop    %edi
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801b77:	83 f8 01             	cmp    $0x1,%eax
  801b7a:	75 c1                	jne    801b3d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b7c:	8b 42 58             	mov    0x58(%edx),%eax
  801b7f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801b86:	00 
  801b87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b8f:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  801b96:	e8 89 e8 ff ff       	call   800424 <cprintf>
  801b9b:	eb a0                	jmp    801b3d <_pipeisclosed+0xe>

00801b9d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	57                   	push   %edi
  801ba1:	56                   	push   %esi
  801ba2:	53                   	push   %ebx
  801ba3:	83 ec 1c             	sub    $0x1c,%esp
  801ba6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ba9:	89 34 24             	mov    %esi,(%esp)
  801bac:	e8 6b f5 ff ff       	call   80111c <fd2data>
  801bb1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb3:	bf 00 00 00 00       	mov    $0x0,%edi
  801bb8:	eb 3c                	jmp    801bf6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bba:	89 da                	mov    %ebx,%edx
  801bbc:	89 f0                	mov    %esi,%eax
  801bbe:	e8 6c ff ff ff       	call   801b2f <_pipeisclosed>
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	75 38                	jne    801bff <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bc7:	e8 b6 f2 ff ff       	call   800e82 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bcc:	8b 43 04             	mov    0x4(%ebx),%eax
  801bcf:	8b 13                	mov    (%ebx),%edx
  801bd1:	83 c2 20             	add    $0x20,%edx
  801bd4:	39 d0                	cmp    %edx,%eax
  801bd6:	73 e2                	jae    801bba <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bdb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801bde:	89 c2                	mov    %eax,%edx
  801be0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801be6:	79 05                	jns    801bed <devpipe_write+0x50>
  801be8:	4a                   	dec    %edx
  801be9:	83 ca e0             	or     $0xffffffe0,%edx
  801bec:	42                   	inc    %edx
  801bed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bf1:	40                   	inc    %eax
  801bf2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf5:	47                   	inc    %edi
  801bf6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bf9:	75 d1                	jne    801bcc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bfb:	89 f8                	mov    %edi,%eax
  801bfd:	eb 05                	jmp    801c04 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c04:	83 c4 1c             	add    $0x1c,%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5f                   	pop    %edi
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    

00801c0c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	57                   	push   %edi
  801c10:	56                   	push   %esi
  801c11:	53                   	push   %ebx
  801c12:	83 ec 1c             	sub    $0x1c,%esp
  801c15:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c18:	89 3c 24             	mov    %edi,(%esp)
  801c1b:	e8 fc f4 ff ff       	call   80111c <fd2data>
  801c20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c22:	be 00 00 00 00       	mov    $0x0,%esi
  801c27:	eb 3a                	jmp    801c63 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c29:	85 f6                	test   %esi,%esi
  801c2b:	74 04                	je     801c31 <devpipe_read+0x25>
				return i;
  801c2d:	89 f0                	mov    %esi,%eax
  801c2f:	eb 40                	jmp    801c71 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c31:	89 da                	mov    %ebx,%edx
  801c33:	89 f8                	mov    %edi,%eax
  801c35:	e8 f5 fe ff ff       	call   801b2f <_pipeisclosed>
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	75 2e                	jne    801c6c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c3e:	e8 3f f2 ff ff       	call   800e82 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c43:	8b 03                	mov    (%ebx),%eax
  801c45:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c48:	74 df                	je     801c29 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c4a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c4f:	79 05                	jns    801c56 <devpipe_read+0x4a>
  801c51:	48                   	dec    %eax
  801c52:	83 c8 e0             	or     $0xffffffe0,%eax
  801c55:	40                   	inc    %eax
  801c56:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801c60:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c62:	46                   	inc    %esi
  801c63:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c66:	75 db                	jne    801c43 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c68:	89 f0                	mov    %esi,%eax
  801c6a:	eb 05                	jmp    801c71 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c71:	83 c4 1c             	add    $0x1c,%esp
  801c74:	5b                   	pop    %ebx
  801c75:	5e                   	pop    %esi
  801c76:	5f                   	pop    %edi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	57                   	push   %edi
  801c7d:	56                   	push   %esi
  801c7e:	53                   	push   %ebx
  801c7f:	83 ec 3c             	sub    $0x3c,%esp
  801c82:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c85:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c88:	89 04 24             	mov    %eax,(%esp)
  801c8b:	e8 a7 f4 ff ff       	call   801137 <fd_alloc>
  801c90:	89 c3                	mov    %eax,%ebx
  801c92:	85 c0                	test   %eax,%eax
  801c94:	0f 88 45 01 00 00    	js     801ddf <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ca1:	00 
  801ca2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ca5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb0:	e8 ec f1 ff ff       	call   800ea1 <sys_page_alloc>
  801cb5:	89 c3                	mov    %eax,%ebx
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	0f 88 20 01 00 00    	js     801ddf <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cbf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801cc2:	89 04 24             	mov    %eax,(%esp)
  801cc5:	e8 6d f4 ff ff       	call   801137 <fd_alloc>
  801cca:	89 c3                	mov    %eax,%ebx
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	0f 88 f8 00 00 00    	js     801dcc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cdb:	00 
  801cdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cea:	e8 b2 f1 ff ff       	call   800ea1 <sys_page_alloc>
  801cef:	89 c3                	mov    %eax,%ebx
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	0f 88 d3 00 00 00    	js     801dcc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cfc:	89 04 24             	mov    %eax,(%esp)
  801cff:	e8 18 f4 ff ff       	call   80111c <fd2data>
  801d04:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d06:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d0d:	00 
  801d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d19:	e8 83 f1 ff ff       	call   800ea1 <sys_page_alloc>
  801d1e:	89 c3                	mov    %eax,%ebx
  801d20:	85 c0                	test   %eax,%eax
  801d22:	0f 88 91 00 00 00    	js     801db9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d2b:	89 04 24             	mov    %eax,(%esp)
  801d2e:	e8 e9 f3 ff ff       	call   80111c <fd2data>
  801d33:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801d3a:	00 
  801d3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d46:	00 
  801d47:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d52:	e8 9e f1 ff ff       	call   800ef5 <sys_page_map>
  801d57:	89 c3                	mov    %eax,%ebx
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	78 4c                	js     801da9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d5d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d66:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d6b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d72:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d7b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d80:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d8a:	89 04 24             	mov    %eax,(%esp)
  801d8d:	e8 7a f3 ff ff       	call   80110c <fd2num>
  801d92:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d97:	89 04 24             	mov    %eax,(%esp)
  801d9a:	e8 6d f3 ff ff       	call   80110c <fd2num>
  801d9f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801da2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801da7:	eb 36                	jmp    801ddf <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801da9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db4:	e8 8f f1 ff ff       	call   800f48 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801db9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc7:	e8 7c f1 ff ff       	call   800f48 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801dcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dda:	e8 69 f1 ff ff       	call   800f48 <sys_page_unmap>
    err:
	return r;
}
  801ddf:	89 d8                	mov    %ebx,%eax
  801de1:	83 c4 3c             	add    $0x3c,%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    

00801de9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801def:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df6:	8b 45 08             	mov    0x8(%ebp),%eax
  801df9:	89 04 24             	mov    %eax,(%esp)
  801dfc:	e8 89 f3 ff ff       	call   80118a <fd_lookup>
  801e01:	85 c0                	test   %eax,%eax
  801e03:	78 15                	js     801e1a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	e8 0c f3 ff ff       	call   80111c <fd2data>
	return _pipeisclosed(fd, p);
  801e10:	89 c2                	mov    %eax,%edx
  801e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e15:	e8 15 fd ff ff       	call   801b2f <_pipeisclosed>
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	57                   	push   %edi
  801e20:	56                   	push   %esi
  801e21:	53                   	push   %ebx
  801e22:	83 ec 1c             	sub    $0x1c,%esp
  801e25:	8b 75 08             	mov    0x8(%ebp),%esi
  801e28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e2b:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801e2e:	85 db                	test   %ebx,%ebx
  801e30:	75 05                	jne    801e37 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801e32:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801e37:	89 1c 24             	mov    %ebx,(%esp)
  801e3a:	e8 78 f2 ff ff       	call   8010b7 <sys_ipc_recv>
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	79 16                	jns    801e59 <ipc_recv+0x3d>
		*from_env_store = 0;
  801e43:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801e49:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801e4f:	89 1c 24             	mov    %ebx,(%esp)
  801e52:	e8 60 f2 ff ff       	call   8010b7 <sys_ipc_recv>
  801e57:	eb 24                	jmp    801e7d <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801e59:	85 f6                	test   %esi,%esi
  801e5b:	74 0a                	je     801e67 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801e5d:	a1 04 44 80 00       	mov    0x804404,%eax
  801e62:	8b 40 74             	mov    0x74(%eax),%eax
  801e65:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801e67:	85 ff                	test   %edi,%edi
  801e69:	74 0a                	je     801e75 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801e6b:	a1 04 44 80 00       	mov    0x804404,%eax
  801e70:	8b 40 78             	mov    0x78(%eax),%eax
  801e73:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801e75:	a1 04 44 80 00       	mov    0x804404,%eax
  801e7a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e7d:	83 c4 1c             	add    $0x1c,%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5e                   	pop    %esi
  801e82:	5f                   	pop    %edi
  801e83:	5d                   	pop    %ebp
  801e84:	c3                   	ret    

00801e85 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	57                   	push   %edi
  801e89:	56                   	push   %esi
  801e8a:	53                   	push   %ebx
  801e8b:	83 ec 1c             	sub    $0x1c,%esp
  801e8e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e94:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801e97:	85 db                	test   %ebx,%ebx
  801e99:	75 05                	jne    801ea0 <ipc_send+0x1b>
		pg = (void *)-1;
  801e9b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ea0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ea4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ea8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801eac:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaf:	89 04 24             	mov    %eax,(%esp)
  801eb2:	e8 dd f1 ff ff       	call   801094 <sys_ipc_try_send>
		if (r == 0) {		
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	74 2c                	je     801ee7 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801ebb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ebe:	75 07                	jne    801ec7 <ipc_send+0x42>
			sys_yield();
  801ec0:	e8 bd ef ff ff       	call   800e82 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801ec5:	eb d9                	jmp    801ea0 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801ec7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ecb:	c7 44 24 08 bc 26 80 	movl   $0x8026bc,0x8(%esp)
  801ed2:	00 
  801ed3:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801eda:	00 
  801edb:	c7 04 24 ca 26 80 00 	movl   $0x8026ca,(%esp)
  801ee2:	e8 45 e4 ff ff       	call   80032c <_panic>
		}
	}
}
  801ee7:	83 c4 1c             	add    $0x1c,%esp
  801eea:	5b                   	pop    %ebx
  801eeb:	5e                   	pop    %esi
  801eec:	5f                   	pop    %edi
  801eed:	5d                   	pop    %ebp
  801eee:	c3                   	ret    

00801eef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	53                   	push   %ebx
  801ef3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801ef6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801efb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f02:	89 c2                	mov    %eax,%edx
  801f04:	c1 e2 07             	shl    $0x7,%edx
  801f07:	29 ca                	sub    %ecx,%edx
  801f09:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f0f:	8b 52 50             	mov    0x50(%edx),%edx
  801f12:	39 da                	cmp    %ebx,%edx
  801f14:	75 0f                	jne    801f25 <ipc_find_env+0x36>
			return envs[i].env_id;
  801f16:	c1 e0 07             	shl    $0x7,%eax
  801f19:	29 c8                	sub    %ecx,%eax
  801f1b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f20:	8b 40 40             	mov    0x40(%eax),%eax
  801f23:	eb 0c                	jmp    801f31 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f25:	40                   	inc    %eax
  801f26:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f2b:	75 ce                	jne    801efb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f2d:	66 b8 00 00          	mov    $0x0,%ax
}
  801f31:	5b                   	pop    %ebx
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    

00801f34 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3a:	89 c2                	mov    %eax,%edx
  801f3c:	c1 ea 16             	shr    $0x16,%edx
  801f3f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f46:	f6 c2 01             	test   $0x1,%dl
  801f49:	74 1e                	je     801f69 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f4b:	c1 e8 0c             	shr    $0xc,%eax
  801f4e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f55:	a8 01                	test   $0x1,%al
  801f57:	74 17                	je     801f70 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f59:	c1 e8 0c             	shr    $0xc,%eax
  801f5c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f63:	ef 
  801f64:	0f b7 c0             	movzwl %ax,%eax
  801f67:	eb 0c                	jmp    801f75 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f69:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6e:	eb 05                	jmp    801f75 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f70:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    
	...

00801f78 <__udivdi3>:
  801f78:	55                   	push   %ebp
  801f79:	57                   	push   %edi
  801f7a:	56                   	push   %esi
  801f7b:	83 ec 10             	sub    $0x10,%esp
  801f7e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f82:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f8a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801f8e:	89 cd                	mov    %ecx,%ebp
  801f90:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801f94:	85 c0                	test   %eax,%eax
  801f96:	75 2c                	jne    801fc4 <__udivdi3+0x4c>
  801f98:	39 f9                	cmp    %edi,%ecx
  801f9a:	77 68                	ja     802004 <__udivdi3+0x8c>
  801f9c:	85 c9                	test   %ecx,%ecx
  801f9e:	75 0b                	jne    801fab <__udivdi3+0x33>
  801fa0:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa5:	31 d2                	xor    %edx,%edx
  801fa7:	f7 f1                	div    %ecx
  801fa9:	89 c1                	mov    %eax,%ecx
  801fab:	31 d2                	xor    %edx,%edx
  801fad:	89 f8                	mov    %edi,%eax
  801faf:	f7 f1                	div    %ecx
  801fb1:	89 c7                	mov    %eax,%edi
  801fb3:	89 f0                	mov    %esi,%eax
  801fb5:	f7 f1                	div    %ecx
  801fb7:	89 c6                	mov    %eax,%esi
  801fb9:	89 f0                	mov    %esi,%eax
  801fbb:	89 fa                	mov    %edi,%edx
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	5e                   	pop    %esi
  801fc1:	5f                   	pop    %edi
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    
  801fc4:	39 f8                	cmp    %edi,%eax
  801fc6:	77 2c                	ja     801ff4 <__udivdi3+0x7c>
  801fc8:	0f bd f0             	bsr    %eax,%esi
  801fcb:	83 f6 1f             	xor    $0x1f,%esi
  801fce:	75 4c                	jne    80201c <__udivdi3+0xa4>
  801fd0:	39 f8                	cmp    %edi,%eax
  801fd2:	bf 00 00 00 00       	mov    $0x0,%edi
  801fd7:	72 0a                	jb     801fe3 <__udivdi3+0x6b>
  801fd9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801fdd:	0f 87 ad 00 00 00    	ja     802090 <__udivdi3+0x118>
  801fe3:	be 01 00 00 00       	mov    $0x1,%esi
  801fe8:	89 f0                	mov    %esi,%eax
  801fea:	89 fa                	mov    %edi,%edx
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	5e                   	pop    %esi
  801ff0:	5f                   	pop    %edi
  801ff1:	5d                   	pop    %ebp
  801ff2:	c3                   	ret    
  801ff3:	90                   	nop
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	31 f6                	xor    %esi,%esi
  801ff8:	89 f0                	mov    %esi,%eax
  801ffa:	89 fa                	mov    %edi,%edx
  801ffc:	83 c4 10             	add    $0x10,%esp
  801fff:	5e                   	pop    %esi
  802000:	5f                   	pop    %edi
  802001:	5d                   	pop    %ebp
  802002:	c3                   	ret    
  802003:	90                   	nop
  802004:	89 fa                	mov    %edi,%edx
  802006:	89 f0                	mov    %esi,%eax
  802008:	f7 f1                	div    %ecx
  80200a:	89 c6                	mov    %eax,%esi
  80200c:	31 ff                	xor    %edi,%edi
  80200e:	89 f0                	mov    %esi,%eax
  802010:	89 fa                	mov    %edi,%edx
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	5e                   	pop    %esi
  802016:	5f                   	pop    %edi
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    
  802019:	8d 76 00             	lea    0x0(%esi),%esi
  80201c:	89 f1                	mov    %esi,%ecx
  80201e:	d3 e0                	shl    %cl,%eax
  802020:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802024:	b8 20 00 00 00       	mov    $0x20,%eax
  802029:	29 f0                	sub    %esi,%eax
  80202b:	89 ea                	mov    %ebp,%edx
  80202d:	88 c1                	mov    %al,%cl
  80202f:	d3 ea                	shr    %cl,%edx
  802031:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802035:	09 ca                	or     %ecx,%edx
  802037:	89 54 24 08          	mov    %edx,0x8(%esp)
  80203b:	89 f1                	mov    %esi,%ecx
  80203d:	d3 e5                	shl    %cl,%ebp
  80203f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  802043:	89 fd                	mov    %edi,%ebp
  802045:	88 c1                	mov    %al,%cl
  802047:	d3 ed                	shr    %cl,%ebp
  802049:	89 fa                	mov    %edi,%edx
  80204b:	89 f1                	mov    %esi,%ecx
  80204d:	d3 e2                	shl    %cl,%edx
  80204f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802053:	88 c1                	mov    %al,%cl
  802055:	d3 ef                	shr    %cl,%edi
  802057:	09 d7                	or     %edx,%edi
  802059:	89 f8                	mov    %edi,%eax
  80205b:	89 ea                	mov    %ebp,%edx
  80205d:	f7 74 24 08          	divl   0x8(%esp)
  802061:	89 d1                	mov    %edx,%ecx
  802063:	89 c7                	mov    %eax,%edi
  802065:	f7 64 24 0c          	mull   0xc(%esp)
  802069:	39 d1                	cmp    %edx,%ecx
  80206b:	72 17                	jb     802084 <__udivdi3+0x10c>
  80206d:	74 09                	je     802078 <__udivdi3+0x100>
  80206f:	89 fe                	mov    %edi,%esi
  802071:	31 ff                	xor    %edi,%edi
  802073:	e9 41 ff ff ff       	jmp    801fb9 <__udivdi3+0x41>
  802078:	8b 54 24 04          	mov    0x4(%esp),%edx
  80207c:	89 f1                	mov    %esi,%ecx
  80207e:	d3 e2                	shl    %cl,%edx
  802080:	39 c2                	cmp    %eax,%edx
  802082:	73 eb                	jae    80206f <__udivdi3+0xf7>
  802084:	8d 77 ff             	lea    -0x1(%edi),%esi
  802087:	31 ff                	xor    %edi,%edi
  802089:	e9 2b ff ff ff       	jmp    801fb9 <__udivdi3+0x41>
  80208e:	66 90                	xchg   %ax,%ax
  802090:	31 f6                	xor    %esi,%esi
  802092:	e9 22 ff ff ff       	jmp    801fb9 <__udivdi3+0x41>
	...

00802098 <__umoddi3>:
  802098:	55                   	push   %ebp
  802099:	57                   	push   %edi
  80209a:	56                   	push   %esi
  80209b:	83 ec 20             	sub    $0x20,%esp
  80209e:	8b 44 24 30          	mov    0x30(%esp),%eax
  8020a2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8020a6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8020aa:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020b2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020b6:	89 c7                	mov    %eax,%edi
  8020b8:	89 f2                	mov    %esi,%edx
  8020ba:	85 ed                	test   %ebp,%ebp
  8020bc:	75 16                	jne    8020d4 <__umoddi3+0x3c>
  8020be:	39 f1                	cmp    %esi,%ecx
  8020c0:	0f 86 a6 00 00 00    	jbe    80216c <__umoddi3+0xd4>
  8020c6:	f7 f1                	div    %ecx
  8020c8:	89 d0                	mov    %edx,%eax
  8020ca:	31 d2                	xor    %edx,%edx
  8020cc:	83 c4 20             	add    $0x20,%esp
  8020cf:	5e                   	pop    %esi
  8020d0:	5f                   	pop    %edi
  8020d1:	5d                   	pop    %ebp
  8020d2:	c3                   	ret    
  8020d3:	90                   	nop
  8020d4:	39 f5                	cmp    %esi,%ebp
  8020d6:	0f 87 ac 00 00 00    	ja     802188 <__umoddi3+0xf0>
  8020dc:	0f bd c5             	bsr    %ebp,%eax
  8020df:	83 f0 1f             	xor    $0x1f,%eax
  8020e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020e6:	0f 84 a8 00 00 00    	je     802194 <__umoddi3+0xfc>
  8020ec:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020f0:	d3 e5                	shl    %cl,%ebp
  8020f2:	bf 20 00 00 00       	mov    $0x20,%edi
  8020f7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8020fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020ff:	89 f9                	mov    %edi,%ecx
  802101:	d3 e8                	shr    %cl,%eax
  802103:	09 e8                	or     %ebp,%eax
  802105:	89 44 24 18          	mov    %eax,0x18(%esp)
  802109:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80210d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802111:	d3 e0                	shl    %cl,%eax
  802113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802117:	89 f2                	mov    %esi,%edx
  802119:	d3 e2                	shl    %cl,%edx
  80211b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80211f:	d3 e0                	shl    %cl,%eax
  802121:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802125:	8b 44 24 14          	mov    0x14(%esp),%eax
  802129:	89 f9                	mov    %edi,%ecx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	09 d0                	or     %edx,%eax
  80212f:	d3 ee                	shr    %cl,%esi
  802131:	89 f2                	mov    %esi,%edx
  802133:	f7 74 24 18          	divl   0x18(%esp)
  802137:	89 d6                	mov    %edx,%esi
  802139:	f7 64 24 0c          	mull   0xc(%esp)
  80213d:	89 c5                	mov    %eax,%ebp
  80213f:	89 d1                	mov    %edx,%ecx
  802141:	39 d6                	cmp    %edx,%esi
  802143:	72 67                	jb     8021ac <__umoddi3+0x114>
  802145:	74 75                	je     8021bc <__umoddi3+0x124>
  802147:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80214b:	29 e8                	sub    %ebp,%eax
  80214d:	19 ce                	sbb    %ecx,%esi
  80214f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802153:	d3 e8                	shr    %cl,%eax
  802155:	89 f2                	mov    %esi,%edx
  802157:	89 f9                	mov    %edi,%ecx
  802159:	d3 e2                	shl    %cl,%edx
  80215b:	09 d0                	or     %edx,%eax
  80215d:	89 f2                	mov    %esi,%edx
  80215f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802163:	d3 ea                	shr    %cl,%edx
  802165:	83 c4 20             	add    $0x20,%esp
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	85 c9                	test   %ecx,%ecx
  80216e:	75 0b                	jne    80217b <__umoddi3+0xe3>
  802170:	b8 01 00 00 00       	mov    $0x1,%eax
  802175:	31 d2                	xor    %edx,%edx
  802177:	f7 f1                	div    %ecx
  802179:	89 c1                	mov    %eax,%ecx
  80217b:	89 f0                	mov    %esi,%eax
  80217d:	31 d2                	xor    %edx,%edx
  80217f:	f7 f1                	div    %ecx
  802181:	89 f8                	mov    %edi,%eax
  802183:	e9 3e ff ff ff       	jmp    8020c6 <__umoddi3+0x2e>
  802188:	89 f2                	mov    %esi,%edx
  80218a:	83 c4 20             	add    $0x20,%esp
  80218d:	5e                   	pop    %esi
  80218e:	5f                   	pop    %edi
  80218f:	5d                   	pop    %ebp
  802190:	c3                   	ret    
  802191:	8d 76 00             	lea    0x0(%esi),%esi
  802194:	39 f5                	cmp    %esi,%ebp
  802196:	72 04                	jb     80219c <__umoddi3+0x104>
  802198:	39 f9                	cmp    %edi,%ecx
  80219a:	77 06                	ja     8021a2 <__umoddi3+0x10a>
  80219c:	89 f2                	mov    %esi,%edx
  80219e:	29 cf                	sub    %ecx,%edi
  8021a0:	19 ea                	sbb    %ebp,%edx
  8021a2:	89 f8                	mov    %edi,%eax
  8021a4:	83 c4 20             	add    $0x20,%esp
  8021a7:	5e                   	pop    %esi
  8021a8:	5f                   	pop    %edi
  8021a9:	5d                   	pop    %ebp
  8021aa:	c3                   	ret    
  8021ab:	90                   	nop
  8021ac:	89 d1                	mov    %edx,%ecx
  8021ae:	89 c5                	mov    %eax,%ebp
  8021b0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8021b4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8021b8:	eb 8d                	jmp    802147 <__umoddi3+0xaf>
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8021c0:	72 ea                	jb     8021ac <__umoddi3+0x114>
  8021c2:	89 f1                	mov    %esi,%ecx
  8021c4:	eb 81                	jmp    802147 <__umoddi3+0xaf>
