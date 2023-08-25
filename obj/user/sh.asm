
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 63 09 00 00       	call   800994 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800043:	85 db                	test   %ebx,%ebx
  800045:	75 1e                	jne    800065 <_gettoken+0x31>
		if (debug > 1)
  800047:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80004e:	0f 8e 19 01 00 00    	jle    80016d <_gettoken+0x139>
			cprintf("GETTOKEN NULL\n");
  800054:	c7 04 24 60 34 80 00 	movl   $0x803460,(%esp)
  80005b:	e8 9c 0a 00 00       	call   800afc <cprintf>
  800060:	e9 1b 01 00 00       	jmp    800180 <_gettoken+0x14c>
		return 0;
	}

	if (debug > 1)
  800065:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80006c:	7e 10                	jle    80007e <_gettoken+0x4a>
		cprintf("GETTOKEN: %s\n", s);
  80006e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800072:	c7 04 24 6f 34 80 00 	movl   $0x80346f,(%esp)
  800079:	e8 7e 0a 00 00       	call   800afc <cprintf>

	*p1 = 0;
  80007e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800084:	8b 45 10             	mov    0x10(%ebp),%eax
  800087:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80008d:	eb 04                	jmp    800093 <_gettoken+0x5f>
		*s++ = 0;
  80008f:	c6 03 00             	movb   $0x0,(%ebx)
  800092:	43                   	inc    %ebx
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  800093:	0f be 03             	movsbl (%ebx),%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 7d 34 80 00 	movl   $0x80347d,(%esp)
  8000a1:	e8 db 11 00 00       	call   801281 <strchr>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 e5                	jne    80008f <_gettoken+0x5b>
  8000aa:	89 de                	mov    %ebx,%esi
		*s++ = 0;
	if (*s == 0) {
  8000ac:	8a 03                	mov    (%ebx),%al
  8000ae:	84 c0                	test   %al,%al
  8000b0:	75 23                	jne    8000d5 <_gettoken+0xa1>
		if (debug > 1)
  8000b2:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000b9:	0f 8e b5 00 00 00    	jle    800174 <_gettoken+0x140>
			cprintf("EOL\n");
  8000bf:	c7 04 24 82 34 80 00 	movl   $0x803482,(%esp)
  8000c6:	e8 31 0a 00 00       	call   800afc <cprintf>
		return 0;
  8000cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000d0:	e9 ab 00 00 00       	jmp    800180 <_gettoken+0x14c>
	}
	if (strchr(SYMBOLS, *s)) {
  8000d5:	0f be c0             	movsbl %al,%eax
  8000d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000dc:	c7 04 24 93 34 80 00 	movl   $0x803493,(%esp)
  8000e3:	e8 99 11 00 00       	call   801281 <strchr>
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	74 29                	je     800115 <_gettoken+0xe1>
		t = *s;
  8000ec:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  8000ef:	89 37                	mov    %esi,(%edi)
		*s++ = 0;
  8000f1:	c6 06 00             	movb   $0x0,(%esi)
  8000f4:	46                   	inc    %esi
  8000f5:	8b 55 10             	mov    0x10(%ebp),%edx
  8000f8:	89 32                	mov    %esi,(%edx)
		*p2 = s;
		if (debug > 1)
  8000fa:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800101:	7e 7d                	jle    800180 <_gettoken+0x14c>
			cprintf("TOK %c\n", t);
  800103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800107:	c7 04 24 87 34 80 00 	movl   $0x803487,(%esp)
  80010e:	e8 e9 09 00 00       	call   800afc <cprintf>
  800113:	eb 6b                	jmp    800180 <_gettoken+0x14c>
		return t;
	}
	*p1 = s;
  800115:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800117:	eb 01                	jmp    80011a <_gettoken+0xe6>
		s++;
  800119:	43                   	inc    %ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80011a:	8a 03                	mov    (%ebx),%al
  80011c:	84 c0                	test   %al,%al
  80011e:	74 17                	je     800137 <_gettoken+0x103>
  800120:	0f be c0             	movsbl %al,%eax
  800123:	89 44 24 04          	mov    %eax,0x4(%esp)
  800127:	c7 04 24 8f 34 80 00 	movl   $0x80348f,(%esp)
  80012e:	e8 4e 11 00 00       	call   801281 <strchr>
  800133:	85 c0                	test   %eax,%eax
  800135:	74 e2                	je     800119 <_gettoken+0xe5>
		s++;
	*p2 = s;
  800137:	8b 45 10             	mov    0x10(%ebp),%eax
  80013a:	89 18                	mov    %ebx,(%eax)
	if (debug > 1) {
  80013c:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800143:	7e 36                	jle    80017b <_gettoken+0x147>
		t = **p2;
  800145:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800148:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80014b:	8b 07                	mov    (%edi),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 9b 34 80 00 	movl   $0x80349b,(%esp)
  800158:	e8 9f 09 00 00       	call   800afc <cprintf>
		**p2 = t;
  80015d:	8b 55 10             	mov    0x10(%ebp),%edx
  800160:	8b 02                	mov    (%edx),%eax
  800162:	89 f2                	mov    %esi,%edx
  800164:	88 10                	mov    %dl,(%eax)
	}
	return 'w';
  800166:	bb 77 00 00 00       	mov    $0x77,%ebx
  80016b:	eb 13                	jmp    800180 <_gettoken+0x14c>
	int t;

	if (s == 0) {
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  80016d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800172:	eb 0c                	jmp    800180 <_gettoken+0x14c>
	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  800174:	bb 00 00 00 00       	mov    $0x0,%ebx
  800179:	eb 05                	jmp    800180 <_gettoken+0x14c>
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  80017b:	bb 77 00 00 00       	mov    $0x77,%ebx
}
  800180:	89 d8                	mov    %ebx,%eax
  800182:	83 c4 1c             	add    $0x1c,%esp
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <gettoken>:

int
gettoken(char *s, char **p1)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 18             	sub    $0x18,%esp
  800190:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  800193:	85 c0                	test   %eax,%eax
  800195:	74 24                	je     8001bb <gettoken+0x31>
		nc = _gettoken(s, &np1, &np2);
  800197:	c7 44 24 08 08 50 80 	movl   $0x805008,0x8(%esp)
  80019e:	00 
  80019f:	c7 44 24 04 04 50 80 	movl   $0x805004,0x4(%esp)
  8001a6:	00 
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 85 fe ff ff       	call   800034 <_gettoken>
  8001af:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  8001b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b9:	eb 3c                	jmp    8001f7 <gettoken+0x6d>
	}
	c = nc;
  8001bb:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8001c0:	a3 10 50 80 00       	mov    %eax,0x805010
	*p1 = np1;
  8001c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c8:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8001ce:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d0:	c7 44 24 08 08 50 80 	movl   $0x805008,0x8(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 04 04 50 80 	movl   $0x805004,0x4(%esp)
  8001df:	00 
  8001e0:	a1 08 50 80 00       	mov    0x805008,%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 47 fe ff ff       	call   800034 <_gettoken>
  8001ed:	a3 0c 50 80 00       	mov    %eax,0x80500c
	return c;
  8001f2:	a1 10 50 80 00       	mov    0x805010,%eax
}
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	57                   	push   %edi
  8001fd:	56                   	push   %esi
  8001fe:	53                   	push   %ebx
  8001ff:	81 ec 6c 04 00 00    	sub    $0x46c,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800205:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80020c:	00 
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	e8 72 ff ff ff       	call   80018a <gettoken>

again:
	argc = 0;
  800218:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80021d:	8d 5d a4             	lea    -0x5c(%ebp),%ebx
  800220:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80022b:	e8 5a ff ff ff       	call   80018a <gettoken>
  800230:	83 f8 77             	cmp    $0x77,%eax
  800233:	74 2e                	je     800263 <runcmd+0x6a>
  800235:	83 f8 77             	cmp    $0x77,%eax
  800238:	7f 1b                	jg     800255 <runcmd+0x5c>
  80023a:	83 f8 3c             	cmp    $0x3c,%eax
  80023d:	74 44                	je     800283 <runcmd+0x8a>
  80023f:	83 f8 3e             	cmp    $0x3e,%eax
  800242:	0f 84 80 00 00 00    	je     8002c8 <runcmd+0xcf>
  800248:	85 c0                	test   %eax,%eax
  80024a:	0f 84 06 02 00 00    	je     800456 <runcmd+0x25d>
  800250:	e9 e1 01 00 00       	jmp    800436 <runcmd+0x23d>
  800255:	83 f8 7c             	cmp    $0x7c,%eax
  800258:	0f 85 d8 01 00 00    	jne    800436 <runcmd+0x23d>
  80025e:	e9 e6 00 00 00       	jmp    800349 <runcmd+0x150>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  800263:	83 fe 10             	cmp    $0x10,%esi
  800266:	75 11                	jne    800279 <runcmd+0x80>
				cprintf("too many arguments\n");
  800268:	c7 04 24 a5 34 80 00 	movl   $0x8034a5,(%esp)
  80026f:	e8 88 08 00 00       	call   800afc <cprintf>
				exit();
  800274:	e8 6f 07 00 00       	call   8009e8 <exit>
			}
			argv[argc++] = t;
  800279:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80027c:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  800280:	46                   	inc    %esi
			break;
  800281:	eb 9d                	jmp    800220 <runcmd+0x27>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800283:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  800286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800291:	e8 f4 fe ff ff       	call   80018a <gettoken>
  800296:	83 f8 77             	cmp    $0x77,%eax
  800299:	74 11                	je     8002ac <runcmd+0xb3>
				cprintf("syntax error: < not followed by word\n");
  80029b:	c7 04 24 00 36 80 00 	movl   $0x803600,(%esp)
  8002a2:	e8 55 08 00 00       	call   800afc <cprintf>
				exit();
  8002a7:	e8 3c 07 00 00       	call   8009e8 <exit>
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			panic("< redirection not implemented");
  8002ac:	c7 44 24 08 b9 34 80 	movl   $0x8034b9,0x8(%esp)
  8002b3:	00 
  8002b4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8002bb:	00 
  8002bc:	c7 04 24 d7 34 80 00 	movl   $0x8034d7,(%esp)
  8002c3:	e8 3c 07 00 00       	call   800a04 <_panic>
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  8002c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002d3:	e8 b2 fe ff ff       	call   80018a <gettoken>
  8002d8:	83 f8 77             	cmp    $0x77,%eax
  8002db:	74 11                	je     8002ee <runcmd+0xf5>
				cprintf("syntax error: > not followed by word\n");
  8002dd:	c7 04 24 28 36 80 00 	movl   $0x803628,(%esp)
  8002e4:	e8 13 08 00 00       	call   800afc <cprintf>
				exit();
  8002e9:	e8 fa 06 00 00       	call   8009e8 <exit>
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  8002ee:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
  8002f5:	00 
  8002f6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002f9:	89 04 24             	mov    %eax,(%esp)
  8002fc:	e8 a4 21 00 00       	call   8024a5 <open>
  800301:	89 c7                	mov    %eax,%edi
  800303:	85 c0                	test   %eax,%eax
  800305:	79 1c                	jns    800323 <runcmd+0x12a>
				cprintf("open %s for write: %e", t, fd);
  800307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80030e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800312:	c7 04 24 e1 34 80 00 	movl   $0x8034e1,(%esp)
  800319:	e8 de 07 00 00       	call   800afc <cprintf>
				exit();
  80031e:	e8 c5 06 00 00       	call   8009e8 <exit>
			}
			if (fd != 1) {
  800323:	83 ff 01             	cmp    $0x1,%edi
  800326:	0f 84 f4 fe ff ff    	je     800220 <runcmd+0x27>
				dup(fd, 1);
  80032c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800333:	00 
  800334:	89 3c 24             	mov    %edi,(%esp)
  800337:	e8 af 1b 00 00       	call   801eeb <dup>
				close(fd);
  80033c:	89 3c 24             	mov    %edi,(%esp)
  80033f:	e8 56 1b 00 00       	call   801e9a <close>
  800344:	e9 d7 fe ff ff       	jmp    800220 <runcmd+0x27>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  800349:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	e8 c6 2a 00 00       	call   802e1d <pipe>
  800357:	85 c0                	test   %eax,%eax
  800359:	79 15                	jns    800370 <runcmd+0x177>
				cprintf("pipe: %e", r);
  80035b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035f:	c7 04 24 f7 34 80 00 	movl   $0x8034f7,(%esp)
  800366:	e8 91 07 00 00       	call   800afc <cprintf>
				exit();
  80036b:	e8 78 06 00 00       	call   8009e8 <exit>
			}
			if (debug)
  800370:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800377:	74 20                	je     800399 <runcmd+0x1a0>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800379:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80037f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800383:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800389:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038d:	c7 04 24 00 35 80 00 	movl   $0x803500,(%esp)
  800394:	e8 63 07 00 00       	call   800afc <cprintf>
			if ((r = fork()) < 0) {
  800399:	e8 6d 15 00 00       	call   80190b <fork>
  80039e:	89 c7                	mov    %eax,%edi
  8003a0:	85 c0                	test   %eax,%eax
  8003a2:	79 15                	jns    8003b9 <runcmd+0x1c0>
				cprintf("fork: %e", r);
  8003a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a8:	c7 04 24 0d 35 80 00 	movl   $0x80350d,(%esp)
  8003af:	e8 48 07 00 00       	call   800afc <cprintf>
				exit();
  8003b4:	e8 2f 06 00 00       	call   8009e8 <exit>
			}
			if (r == 0) {
  8003b9:	85 ff                	test   %edi,%edi
  8003bb:	75 40                	jne    8003fd <runcmd+0x204>
				if (p[0] != 0) {
  8003bd:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003c3:	85 c0                	test   %eax,%eax
  8003c5:	74 1e                	je     8003e5 <runcmd+0x1ec>
					dup(p[0], 0);
  8003c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003ce:	00 
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	e8 14 1b 00 00       	call   801eeb <dup>
					close(p[0]);
  8003d7:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003dd:	89 04 24             	mov    %eax,(%esp)
  8003e0:	e8 b5 1a 00 00       	call   801e9a <close>
				}
				close(p[1]);
  8003e5:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  8003eb:	89 04 24             	mov    %eax,(%esp)
  8003ee:	e8 a7 1a 00 00       	call   801e9a <close>

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  8003f3:	be 00 00 00 00       	mov    $0x0,%esi
				if (p[0] != 0) {
					dup(p[0], 0);
					close(p[0]);
				}
				close(p[1]);
				goto again;
  8003f8:	e9 23 fe ff ff       	jmp    800220 <runcmd+0x27>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  8003fd:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800403:	83 f8 01             	cmp    $0x1,%eax
  800406:	74 1e                	je     800426 <runcmd+0x22d>
					dup(p[1], 1);
  800408:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80040f:	00 
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	e8 d3 1a 00 00       	call   801eeb <dup>
					close(p[1]);
  800418:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80041e:	89 04 24             	mov    %eax,(%esp)
  800421:	e8 74 1a 00 00       	call   801e9a <close>
				}
				close(p[0]);
  800426:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	e8 66 1a 00 00       	call   801e9a <close>
				goto runit;
  800434:	eb 25                	jmp    80045b <runcmd+0x262>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800436:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043a:	c7 44 24 08 16 35 80 	movl   $0x803516,0x8(%esp)
  800441:	00 
  800442:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800449:	00 
  80044a:	c7 04 24 d7 34 80 00 	movl   $0x8034d7,(%esp)
  800451:	e8 ae 05 00 00       	call   800a04 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800456:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80045b:	85 f6                	test   %esi,%esi
  80045d:	75 1e                	jne    80047d <runcmd+0x284>
		if (debug)
  80045f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800466:	0f 84 76 01 00 00    	je     8005e2 <runcmd+0x3e9>
			cprintf("EMPTY COMMAND\n");
  80046c:	c7 04 24 32 35 80 00 	movl   $0x803532,(%esp)
  800473:	e8 84 06 00 00       	call   800afc <cprintf>
  800478:	e9 65 01 00 00       	jmp    8005e2 <runcmd+0x3e9>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  80047d:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800480:	80 38 2f             	cmpb   $0x2f,(%eax)
  800483:	74 22                	je     8004a7 <runcmd+0x2ae>
		argv0buf[0] = '/';
  800485:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  800496:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 e3 0c 00 00       	call   801187 <strcpy>
		argv[0] = argv0buf;
  8004a4:	89 5d a8             	mov    %ebx,-0x58(%ebp)
	}
	argv[argc] = 0;
  8004a7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004ae:	00 

	// Print the command.
	if (debug) {
  8004af:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004b6:	74 43                	je     8004fb <runcmd+0x302>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004b8:	a1 24 54 80 00       	mov    0x805424,%eax
  8004bd:	8b 40 48             	mov    0x48(%eax),%eax
  8004c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c4:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  8004cb:	e8 2c 06 00 00       	call   800afc <cprintf>
  8004d0:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  8004d3:	eb 10                	jmp    8004e5 <runcmd+0x2ec>
			cprintf(" %s", argv[i]);
  8004d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d9:	c7 04 24 cc 35 80 00 	movl   $0x8035cc,(%esp)
  8004e0:	e8 17 06 00 00       	call   800afc <cprintf>
  8004e5:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  8004e8:	8b 43 fc             	mov    -0x4(%ebx),%eax
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	75 e6                	jne    8004d5 <runcmd+0x2dc>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  8004ef:	c7 04 24 80 34 80 00 	movl   $0x803480,(%esp)
  8004f6:	e8 01 06 00 00       	call   800afc <cprintf>
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  8004fb:	8d 45 a8             	lea    -0x58(%ebp),%eax
  8004fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800502:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	e8 6f 21 00 00       	call   80267c <spawn>
  80050d:	89 c3                	mov    %eax,%ebx
  80050f:	85 c0                	test   %eax,%eax
  800511:	79 1e                	jns    800531 <runcmd+0x338>
		cprintf("spawn %s: %e\n", argv[0], r);
  800513:	89 44 24 08          	mov    %eax,0x8(%esp)
  800517:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80051a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051e:	c7 04 24 4f 35 80 00 	movl   $0x80354f,(%esp)
  800525:	e8 d2 05 00 00       	call   800afc <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  80052a:	e8 9c 19 00 00       	call   801ecb <close_all>
  80052f:	eb 5a                	jmp    80058b <runcmd+0x392>
  800531:	e8 95 19 00 00       	call   801ecb <close_all>
	if (r >= 0) {
		if (debug)
  800536:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80053d:	74 23                	je     800562 <runcmd+0x369>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80053f:	a1 24 54 80 00       	mov    0x805424,%eax
  800544:	8b 40 48             	mov    0x48(%eax),%eax
  800547:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80054b:	8b 55 a8             	mov    -0x58(%ebp),%edx
  80054e:	89 54 24 08          	mov    %edx,0x8(%esp)
  800552:	89 44 24 04          	mov    %eax,0x4(%esp)
  800556:	c7 04 24 5d 35 80 00 	movl   $0x80355d,(%esp)
  80055d:	e8 9a 05 00 00       	call   800afc <cprintf>
		wait(r);
  800562:	89 1c 24             	mov    %ebx,(%esp)
  800565:	e8 56 2a 00 00       	call   802fc0 <wait>
		if (debug)
  80056a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800571:	74 18                	je     80058b <runcmd+0x392>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800573:	a1 24 54 80 00       	mov    0x805424,%eax
  800578:	8b 40 48             	mov    0x48(%eax),%eax
  80057b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057f:	c7 04 24 72 35 80 00 	movl   $0x803572,(%esp)
  800586:	e8 71 05 00 00       	call   800afc <cprintf>
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80058b:	85 ff                	test   %edi,%edi
  80058d:	74 4e                	je     8005dd <runcmd+0x3e4>
		if (debug)
  80058f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800596:	74 1c                	je     8005b4 <runcmd+0x3bb>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  800598:	a1 24 54 80 00       	mov    0x805424,%eax
  80059d:	8b 40 48             	mov    0x48(%eax),%eax
  8005a0:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a8:	c7 04 24 88 35 80 00 	movl   $0x803588,(%esp)
  8005af:	e8 48 05 00 00       	call   800afc <cprintf>
		wait(pipe_child);
  8005b4:	89 3c 24             	mov    %edi,(%esp)
  8005b7:	e8 04 2a 00 00       	call   802fc0 <wait>
		if (debug)
  8005bc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c3:	74 18                	je     8005dd <runcmd+0x3e4>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005c5:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ca:	8b 40 48             	mov    0x48(%eax),%eax
  8005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d1:	c7 04 24 72 35 80 00 	movl   $0x803572,(%esp)
  8005d8:	e8 1f 05 00 00       	call   800afc <cprintf>
	}

	// Done!
	exit();
  8005dd:	e8 06 04 00 00       	call   8009e8 <exit>
}
  8005e2:	81 c4 6c 04 00 00    	add    $0x46c,%esp
  8005e8:	5b                   	pop    %ebx
  8005e9:	5e                   	pop    %esi
  8005ea:	5f                   	pop    %edi
  8005eb:	5d                   	pop    %ebp
  8005ec:	c3                   	ret    

008005ed <usage>:
}


void
usage(void)
{
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  8005f3:	c7 04 24 50 36 80 00 	movl   $0x803650,(%esp)
  8005fa:	e8 fd 04 00 00       	call   800afc <cprintf>
	exit();
  8005ff:	e8 e4 03 00 00       	call   8009e8 <exit>
}
  800604:	c9                   	leave  
  800605:	c3                   	ret    

00800606 <umain>:

void
umain(int argc, char **argv)
{
  800606:	55                   	push   %ebp
  800607:	89 e5                	mov    %esp,%ebp
  800609:	57                   	push   %edi
  80060a:	56                   	push   %esi
  80060b:	53                   	push   %ebx
  80060c:	83 ec 4c             	sub    $0x4c,%esp
  80060f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800612:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800615:	89 44 24 08          	mov    %eax,0x8(%esp)
  800619:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061d:	8d 45 08             	lea    0x8(%ebp),%eax
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	e8 64 15 00 00       	call   801b8c <argstart>
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800628:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80062f:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800634:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800637:	eb 2e                	jmp    800667 <umain+0x61>
		switch (r) {
  800639:	83 f8 69             	cmp    $0x69,%eax
  80063c:	74 0c                	je     80064a <umain+0x44>
  80063e:	83 f8 78             	cmp    $0x78,%eax
  800641:	74 1d                	je     800660 <umain+0x5a>
  800643:	83 f8 64             	cmp    $0x64,%eax
  800646:	75 11                	jne    800659 <umain+0x53>
  800648:	eb 07                	jmp    800651 <umain+0x4b>
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  80064a:	bf 01 00 00 00       	mov    $0x1,%edi
  80064f:	eb 16                	jmp    800667 <umain+0x61>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  800651:	ff 05 00 50 80 00    	incl   0x805000
			break;
  800657:	eb 0e                	jmp    800667 <umain+0x61>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  800659:	e8 8f ff ff ff       	call   8005ed <usage>
  80065e:	eb 07                	jmp    800667 <umain+0x61>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800660:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800667:	89 1c 24             	mov    %ebx,(%esp)
  80066a:	e8 56 15 00 00       	call   801bc5 <argnext>
  80066f:	85 c0                	test   %eax,%eax
  800671:	79 c6                	jns    800639 <umain+0x33>
  800673:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  800675:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800679:	7e 05                	jle    800680 <umain+0x7a>
		usage();
  80067b:	e8 6d ff ff ff       	call   8005ed <usage>
	if (argc == 2) {
  800680:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800684:	75 72                	jne    8006f8 <umain+0xf2>
		close(0);
  800686:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80068d:	e8 08 18 00 00       	call   801e9a <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  800692:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800699:	00 
  80069a:	8b 46 04             	mov    0x4(%esi),%eax
  80069d:	89 04 24             	mov    %eax,(%esp)
  8006a0:	e8 00 1e 00 00       	call   8024a5 <open>
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	79 27                	jns    8006d0 <umain+0xca>
			panic("open %s: %e", argv[1], r);
  8006a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ad:	8b 46 04             	mov    0x4(%esi),%eax
  8006b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b4:	c7 44 24 08 a8 35 80 	movl   $0x8035a8,0x8(%esp)
  8006bb:	00 
  8006bc:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  8006c3:	00 
  8006c4:	c7 04 24 d7 34 80 00 	movl   $0x8034d7,(%esp)
  8006cb:	e8 34 03 00 00       	call   800a04 <_panic>
		assert(r == 0);
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 24                	je     8006f8 <umain+0xf2>
  8006d4:	c7 44 24 0c b4 35 80 	movl   $0x8035b4,0xc(%esp)
  8006db:	00 
  8006dc:	c7 44 24 08 bb 35 80 	movl   $0x8035bb,0x8(%esp)
  8006e3:	00 
  8006e4:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  8006eb:	00 
  8006ec:	c7 04 24 d7 34 80 00 	movl   $0x8034d7,(%esp)
  8006f3:	e8 0c 03 00 00       	call   800a04 <_panic>
	}
	if (interactive == '?')
  8006f8:	83 fb 3f             	cmp    $0x3f,%ebx
  8006fb:	75 0e                	jne    80070b <umain+0x105>
		interactive = iscons(0);
  8006fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800704:	e8 08 02 00 00       	call   800911 <iscons>
  800709:	89 c7                	mov    %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80070b:	85 ff                	test   %edi,%edi
  80070d:	74 07                	je     800716 <umain+0x110>
  80070f:	b8 a5 35 80 00       	mov    $0x8035a5,%eax
  800714:	eb 05                	jmp    80071b <umain+0x115>
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	e8 51 09 00 00       	call   801074 <readline>
  800723:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800725:	85 c0                	test   %eax,%eax
  800727:	75 1a                	jne    800743 <umain+0x13d>
			if (debug)
  800729:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800730:	74 0c                	je     80073e <umain+0x138>
				cprintf("EXITING\n");
  800732:	c7 04 24 d0 35 80 00 	movl   $0x8035d0,(%esp)
  800739:	e8 be 03 00 00       	call   800afc <cprintf>
			exit();	// end of file
  80073e:	e8 a5 02 00 00       	call   8009e8 <exit>
		}
		if (debug)
  800743:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80074a:	74 10                	je     80075c <umain+0x156>
			cprintf("LINE: %s\n", buf);
  80074c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800750:	c7 04 24 d9 35 80 00 	movl   $0x8035d9,(%esp)
  800757:	e8 a0 03 00 00       	call   800afc <cprintf>
		if (buf[0] == '#')
  80075c:	80 3b 23             	cmpb   $0x23,(%ebx)
  80075f:	74 aa                	je     80070b <umain+0x105>
			continue;
		if (echocmds)
  800761:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800765:	74 10                	je     800777 <umain+0x171>
			printf("# %s\n", buf);
  800767:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076b:	c7 04 24 e3 35 80 00 	movl   $0x8035e3,(%esp)
  800772:	e8 e2 1e 00 00       	call   802659 <printf>
		if (debug)
  800777:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80077e:	74 0c                	je     80078c <umain+0x186>
			cprintf("BEFORE FORK\n");
  800780:	c7 04 24 e9 35 80 00 	movl   $0x8035e9,(%esp)
  800787:	e8 70 03 00 00       	call   800afc <cprintf>
		if ((r = fork()) < 0)
  80078c:	e8 7a 11 00 00       	call   80190b <fork>
  800791:	89 c6                	mov    %eax,%esi
  800793:	85 c0                	test   %eax,%eax
  800795:	79 20                	jns    8007b7 <umain+0x1b1>
			panic("fork: %e", r);
  800797:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079b:	c7 44 24 08 0d 35 80 	movl   $0x80350d,0x8(%esp)
  8007a2:	00 
  8007a3:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
  8007aa:	00 
  8007ab:	c7 04 24 d7 34 80 00 	movl   $0x8034d7,(%esp)
  8007b2:	e8 4d 02 00 00       	call   800a04 <_panic>
		if (debug)
  8007b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007be:	74 10                	je     8007d0 <umain+0x1ca>
			cprintf("FORK: %d\n", r);
  8007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c4:	c7 04 24 f6 35 80 00 	movl   $0x8035f6,(%esp)
  8007cb:	e8 2c 03 00 00       	call   800afc <cprintf>
		if (r == 0) {
  8007d0:	85 f6                	test   %esi,%esi
  8007d2:	75 12                	jne    8007e6 <umain+0x1e0>
			runcmd(buf);
  8007d4:	89 1c 24             	mov    %ebx,(%esp)
  8007d7:	e8 1d fa ff ff       	call   8001f9 <runcmd>
			exit();
  8007dc:	e8 07 02 00 00       	call   8009e8 <exit>
  8007e1:	e9 25 ff ff ff       	jmp    80070b <umain+0x105>
		} else
			wait(r);
  8007e6:	89 34 24             	mov    %esi,(%esp)
  8007e9:	e8 d2 27 00 00       	call   802fc0 <wait>
  8007ee:	e9 18 ff ff ff       	jmp    80070b <umain+0x105>
	...

008007f4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800804:	c7 44 24 04 71 36 80 	movl   $0x803671,0x4(%esp)
  80080b:	00 
  80080c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080f:	89 04 24             	mov    %eax,(%esp)
  800812:	e8 70 09 00 00       	call   801187 <strcpy>
	return 0;
}
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	57                   	push   %edi
  800822:	56                   	push   %esi
  800823:	53                   	push   %ebx
  800824:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80082a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80082f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800835:	eb 30                	jmp    800867 <devcons_write+0x49>
		m = n - tot;
  800837:	8b 75 10             	mov    0x10(%ebp),%esi
  80083a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80083c:	83 fe 7f             	cmp    $0x7f,%esi
  80083f:	76 05                	jbe    800846 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800841:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800846:	89 74 24 08          	mov    %esi,0x8(%esp)
  80084a:	03 45 0c             	add    0xc(%ebp),%eax
  80084d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800851:	89 3c 24             	mov    %edi,(%esp)
  800854:	e8 a7 0a 00 00       	call   801300 <memmove>
		sys_cputs(buf, m);
  800859:	89 74 24 04          	mov    %esi,0x4(%esp)
  80085d:	89 3c 24             	mov    %edi,(%esp)
  800860:	e8 47 0c 00 00       	call   8014ac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800865:	01 f3                	add    %esi,%ebx
  800867:	89 d8                	mov    %ebx,%eax
  800869:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80086c:	72 c9                	jb     800837 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80086e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5f                   	pop    %edi
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80087f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800883:	75 07                	jne    80088c <devcons_read+0x13>
  800885:	eb 25                	jmp    8008ac <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800887:	e8 ce 0c 00 00       	call   80155a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80088c:	e8 39 0c 00 00       	call   8014ca <sys_cgetc>
  800891:	85 c0                	test   %eax,%eax
  800893:	74 f2                	je     800887 <devcons_read+0xe>
  800895:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800897:	85 c0                	test   %eax,%eax
  800899:	78 1d                	js     8008b8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80089b:	83 f8 04             	cmp    $0x4,%eax
  80089e:	74 13                	je     8008b3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8008a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a3:	88 10                	mov    %dl,(%eax)
	return 1;
  8008a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8008aa:	eb 0c                	jmp    8008b8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b1:	eb 05                	jmp    8008b8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8008cd:	00 
  8008ce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008d1:	89 04 24             	mov    %eax,(%esp)
  8008d4:	e8 d3 0b 00 00       	call   8014ac <sys_cputs>
}
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <getchar>:

int
getchar(void)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8008e1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8008e8:	00 
  8008e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8008f7:	e8 02 17 00 00       	call   801ffe <read>
	if (r < 0)
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	78 0f                	js     80090f <getchar+0x34>
		return r;
	if (r < 1)
  800900:	85 c0                	test   %eax,%eax
  800902:	7e 06                	jle    80090a <getchar+0x2f>
		return -E_EOF;
	return c;
  800904:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800908:	eb 05                	jmp    80090f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80090a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80091a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	89 04 24             	mov    %eax,(%esp)
  800924:	e8 39 14 00 00       	call   801d62 <fd_lookup>
  800929:	85 c0                	test   %eax,%eax
  80092b:	78 11                	js     80093e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80092d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800930:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800936:	39 10                	cmp    %edx,(%eax)
  800938:	0f 94 c0             	sete   %al
  80093b:	0f b6 c0             	movzbl %al,%eax
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <opencons>:

int
opencons(void)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800946:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800949:	89 04 24             	mov    %eax,(%esp)
  80094c:	e8 be 13 00 00       	call   801d0f <fd_alloc>
  800951:	85 c0                	test   %eax,%eax
  800953:	78 3c                	js     800991 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800955:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80095c:	00 
  80095d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800960:	89 44 24 04          	mov    %eax,0x4(%esp)
  800964:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80096b:	e8 09 0c 00 00       	call   801579 <sys_page_alloc>
  800970:	85 c0                	test   %eax,%eax
  800972:	78 1d                	js     800991 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800974:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80097a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80097f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800982:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800989:	89 04 24             	mov    %eax,(%esp)
  80098c:	e8 53 13 00 00       	call   801ce4 <fd2num>
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    
	...

00800994 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	83 ec 10             	sub    $0x10,%esp
  80099c:	8b 75 08             	mov    0x8(%ebp),%esi
  80099f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  8009a2:	e8 94 0b 00 00       	call   80153b <sys_getenvid>
  8009a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8009b3:	c1 e0 07             	shl    $0x7,%eax
  8009b6:	29 d0                	sub    %edx,%eax
  8009b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009bd:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009c2:	85 f6                	test   %esi,%esi
  8009c4:	7e 07                	jle    8009cd <libmain+0x39>
		binaryname = argv[0];
  8009c6:	8b 03                	mov    (%ebx),%eax
  8009c8:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d1:	89 34 24             	mov    %esi,(%esp)
  8009d4:	e8 2d fc ff ff       	call   800606 <umain>

	// exit gracefully
	exit();
  8009d9:	e8 0a 00 00 00       	call   8009e8 <exit>
}
  8009de:	83 c4 10             	add    $0x10,%esp
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    
  8009e5:	00 00                	add    %al,(%eax)
	...

008009e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8009ee:	e8 d8 14 00 00       	call   801ecb <close_all>
	sys_env_destroy(0);
  8009f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009fa:	e8 ea 0a 00 00       	call   8014e9 <sys_env_destroy>
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    
  800a01:	00 00                	add    %al,(%eax)
	...

00800a04 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800a0c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a0f:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  800a15:	e8 21 0b 00 00       	call   80153b <sys_getenvid>
  800a1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a21:	8b 55 08             	mov    0x8(%ebp),%edx
  800a24:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a28:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a30:	c7 04 24 88 36 80 00 	movl   $0x803688,(%esp)
  800a37:	e8 c0 00 00 00       	call   800afc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a40:	8b 45 10             	mov    0x10(%ebp),%eax
  800a43:	89 04 24             	mov    %eax,(%esp)
  800a46:	e8 50 00 00 00       	call   800a9b <vcprintf>
	cprintf("\n");
  800a4b:	c7 04 24 80 34 80 00 	movl   $0x803480,(%esp)
  800a52:	e8 a5 00 00 00       	call   800afc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a57:	cc                   	int3   
  800a58:	eb fd                	jmp    800a57 <_panic+0x53>
	...

00800a5c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 14             	sub    $0x14,%esp
  800a63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a66:	8b 03                	mov    (%ebx),%eax
  800a68:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800a6f:	40                   	inc    %eax
  800a70:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800a72:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a77:	75 19                	jne    800a92 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800a79:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800a80:	00 
  800a81:	8d 43 08             	lea    0x8(%ebx),%eax
  800a84:	89 04 24             	mov    %eax,(%esp)
  800a87:	e8 20 0a 00 00       	call   8014ac <sys_cputs>
		b->idx = 0;
  800a8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800a92:	ff 43 04             	incl   0x4(%ebx)
}
  800a95:	83 c4 14             	add    $0x14,%esp
  800a98:	5b                   	pop    %ebx
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800aa4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aab:	00 00 00 
	b.cnt = 0;
  800aae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad0:	c7 04 24 5c 0a 80 00 	movl   $0x800a5c,(%esp)
  800ad7:	e8 82 01 00 00       	call   800c5e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800adc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800aec:	89 04 24             	mov    %eax,(%esp)
  800aef:	e8 b8 09 00 00       	call   8014ac <sys_cputs>

	return b.cnt;
}
  800af4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800afa:	c9                   	leave  
  800afb:	c3                   	ret    

00800afc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b02:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	89 04 24             	mov    %eax,(%esp)
  800b0f:	e8 87 ff ff ff       	call   800a9b <vcprintf>
	va_end(ap);

	return cnt;
}
  800b14:	c9                   	leave  
  800b15:	c3                   	ret    
	...

00800b18 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 3c             	sub    $0x3c,%esp
  800b21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b32:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800b35:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	75 08                	jne    800b44 <printnum+0x2c>
  800b3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b3f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b42:	77 57                	ja     800b9b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b44:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b48:	4b                   	dec    %ebx
  800b49:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b54:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800b58:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800b5c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b63:	00 
  800b64:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b67:	89 04 24             	mov    %eax,(%esp)
  800b6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b71:	e8 86 26 00 00       	call   8031fc <__udivdi3>
  800b76:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b7a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b7e:	89 04 24             	mov    %eax,(%esp)
  800b81:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b85:	89 fa                	mov    %edi,%edx
  800b87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b8a:	e8 89 ff ff ff       	call   800b18 <printnum>
  800b8f:	eb 0f                	jmp    800ba0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b91:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b95:	89 34 24             	mov    %esi,(%esp)
  800b98:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b9b:	4b                   	dec    %ebx
  800b9c:	85 db                	test   %ebx,%ebx
  800b9e:	7f f1                	jg     800b91 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ba0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ba4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ba8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800baf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800bb6:	00 
  800bb7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800bba:	89 04 24             	mov    %eax,(%esp)
  800bbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc4:	e8 53 27 00 00       	call   80331c <__umoddi3>
  800bc9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bcd:	0f be 80 ab 36 80 00 	movsbl 0x8036ab(%eax),%eax
  800bd4:	89 04 24             	mov    %eax,(%esp)
  800bd7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800bda:	83 c4 3c             	add    $0x3c,%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800be5:	83 fa 01             	cmp    $0x1,%edx
  800be8:	7e 0e                	jle    800bf8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bea:	8b 10                	mov    (%eax),%edx
  800bec:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bef:	89 08                	mov    %ecx,(%eax)
  800bf1:	8b 02                	mov    (%edx),%eax
  800bf3:	8b 52 04             	mov    0x4(%edx),%edx
  800bf6:	eb 22                	jmp    800c1a <getuint+0x38>
	else if (lflag)
  800bf8:	85 d2                	test   %edx,%edx
  800bfa:	74 10                	je     800c0c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bfc:	8b 10                	mov    (%eax),%edx
  800bfe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c01:	89 08                	mov    %ecx,(%eax)
  800c03:	8b 02                	mov    (%edx),%eax
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	eb 0e                	jmp    800c1a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c0c:	8b 10                	mov    (%eax),%edx
  800c0e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c11:	89 08                	mov    %ecx,(%eax)
  800c13:	8b 02                	mov    (%edx),%eax
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c22:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c25:	8b 10                	mov    (%eax),%edx
  800c27:	3b 50 04             	cmp    0x4(%eax),%edx
  800c2a:	73 08                	jae    800c34 <sprintputch+0x18>
		*b->buf++ = ch;
  800c2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2f:	88 0a                	mov    %cl,(%edx)
  800c31:	42                   	inc    %edx
  800c32:	89 10                	mov    %edx,(%eax)
}
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c3c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c43:	8b 45 10             	mov    0x10(%ebp),%eax
  800c46:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	89 04 24             	mov    %eax,(%esp)
  800c57:	e8 02 00 00 00       	call   800c5e <vprintfmt>
	va_end(ap);
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 4c             	sub    $0x4c,%esp
  800c67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c6a:	8b 75 10             	mov    0x10(%ebp),%esi
  800c6d:	eb 12                	jmp    800c81 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	0f 84 6b 03 00 00    	je     800fe2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800c77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c7b:	89 04 24             	mov    %eax,(%esp)
  800c7e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c81:	0f b6 06             	movzbl (%esi),%eax
  800c84:	46                   	inc    %esi
  800c85:	83 f8 25             	cmp    $0x25,%eax
  800c88:	75 e5                	jne    800c6f <vprintfmt+0x11>
  800c8a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800c8e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c95:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800c9a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800ca1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca6:	eb 26                	jmp    800cce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800cab:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800caf:	eb 1d                	jmp    800cce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cb4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800cb8:	eb 14                	jmp    800cce <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800cbd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800cc4:	eb 08                	jmp    800cce <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800cc6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800cc9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cce:	0f b6 06             	movzbl (%esi),%eax
  800cd1:	8d 56 01             	lea    0x1(%esi),%edx
  800cd4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800cd7:	8a 16                	mov    (%esi),%dl
  800cd9:	83 ea 23             	sub    $0x23,%edx
  800cdc:	80 fa 55             	cmp    $0x55,%dl
  800cdf:	0f 87 e1 02 00 00    	ja     800fc6 <vprintfmt+0x368>
  800ce5:	0f b6 d2             	movzbl %dl,%edx
  800ce8:	ff 24 95 e0 37 80 00 	jmp    *0x8037e0(,%edx,4)
  800cef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800cf2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cf7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800cfa:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800cfe:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d01:	8d 50 d0             	lea    -0x30(%eax),%edx
  800d04:	83 fa 09             	cmp    $0x9,%edx
  800d07:	77 2a                	ja     800d33 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d09:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d0a:	eb eb                	jmp    800cf7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0f:	8d 50 04             	lea    0x4(%eax),%edx
  800d12:	89 55 14             	mov    %edx,0x14(%ebp)
  800d15:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d17:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d1a:	eb 17                	jmp    800d33 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800d1c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d20:	78 98                	js     800cba <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d22:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d25:	eb a7                	jmp    800cce <vprintfmt+0x70>
  800d27:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d2a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800d31:	eb 9b                	jmp    800cce <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800d33:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d37:	79 95                	jns    800cce <vprintfmt+0x70>
  800d39:	eb 8b                	jmp    800cc6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d3b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d3f:	eb 8d                	jmp    800cce <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d41:	8b 45 14             	mov    0x14(%ebp),%eax
  800d44:	8d 50 04             	lea    0x4(%eax),%edx
  800d47:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d4e:	8b 00                	mov    (%eax),%eax
  800d50:	89 04 24             	mov    %eax,(%esp)
  800d53:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d56:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d59:	e9 23 ff ff ff       	jmp    800c81 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d61:	8d 50 04             	lea    0x4(%eax),%edx
  800d64:	89 55 14             	mov    %edx,0x14(%ebp)
  800d67:	8b 00                	mov    (%eax),%eax
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	79 02                	jns    800d6f <vprintfmt+0x111>
  800d6d:	f7 d8                	neg    %eax
  800d6f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d71:	83 f8 0f             	cmp    $0xf,%eax
  800d74:	7f 0b                	jg     800d81 <vprintfmt+0x123>
  800d76:	8b 04 85 40 39 80 00 	mov    0x803940(,%eax,4),%eax
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	75 23                	jne    800da4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800d81:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d85:	c7 44 24 08 c3 36 80 	movl   $0x8036c3,0x8(%esp)
  800d8c:	00 
  800d8d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	89 04 24             	mov    %eax,(%esp)
  800d97:	e8 9a fe ff ff       	call   800c36 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d9c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d9f:	e9 dd fe ff ff       	jmp    800c81 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800da4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800da8:	c7 44 24 08 cd 35 80 	movl   $0x8035cd,0x8(%esp)
  800daf:	00 
  800db0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	89 14 24             	mov    %edx,(%esp)
  800dba:	e8 77 fe ff ff       	call   800c36 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dbf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800dc2:	e9 ba fe ff ff       	jmp    800c81 <vprintfmt+0x23>
  800dc7:	89 f9                	mov    %edi,%ecx
  800dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dcc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800dcf:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd2:	8d 50 04             	lea    0x4(%eax),%edx
  800dd5:	89 55 14             	mov    %edx,0x14(%ebp)
  800dd8:	8b 30                	mov    (%eax),%esi
  800dda:	85 f6                	test   %esi,%esi
  800ddc:	75 05                	jne    800de3 <vprintfmt+0x185>
				p = "(null)";
  800dde:	be bc 36 80 00       	mov    $0x8036bc,%esi
			if (width > 0 && padc != '-')
  800de3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800de7:	0f 8e 84 00 00 00    	jle    800e71 <vprintfmt+0x213>
  800ded:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800df1:	74 7e                	je     800e71 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800df3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800df7:	89 34 24             	mov    %esi,(%esp)
  800dfa:	e8 6b 03 00 00       	call   80116a <strnlen>
  800dff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e02:	29 c2                	sub    %eax,%edx
  800e04:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800e07:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800e0b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800e0e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800e11:	89 de                	mov    %ebx,%esi
  800e13:	89 d3                	mov    %edx,%ebx
  800e15:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e17:	eb 0b                	jmp    800e24 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800e19:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e1d:	89 3c 24             	mov    %edi,(%esp)
  800e20:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e23:	4b                   	dec    %ebx
  800e24:	85 db                	test   %ebx,%ebx
  800e26:	7f f1                	jg     800e19 <vprintfmt+0x1bb>
  800e28:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800e2b:	89 f3                	mov    %esi,%ebx
  800e2d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e33:	85 c0                	test   %eax,%eax
  800e35:	79 05                	jns    800e3c <vprintfmt+0x1de>
  800e37:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e3f:	29 c2                	sub    %eax,%edx
  800e41:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e44:	eb 2b                	jmp    800e71 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e46:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e4a:	74 18                	je     800e64 <vprintfmt+0x206>
  800e4c:	8d 50 e0             	lea    -0x20(%eax),%edx
  800e4f:	83 fa 5e             	cmp    $0x5e,%edx
  800e52:	76 10                	jbe    800e64 <vprintfmt+0x206>
					putch('?', putdat);
  800e54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e58:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800e5f:	ff 55 08             	call   *0x8(%ebp)
  800e62:	eb 0a                	jmp    800e6e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800e64:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e68:	89 04 24             	mov    %eax,(%esp)
  800e6b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e6e:	ff 4d e4             	decl   -0x1c(%ebp)
  800e71:	0f be 06             	movsbl (%esi),%eax
  800e74:	46                   	inc    %esi
  800e75:	85 c0                	test   %eax,%eax
  800e77:	74 21                	je     800e9a <vprintfmt+0x23c>
  800e79:	85 ff                	test   %edi,%edi
  800e7b:	78 c9                	js     800e46 <vprintfmt+0x1e8>
  800e7d:	4f                   	dec    %edi
  800e7e:	79 c6                	jns    800e46 <vprintfmt+0x1e8>
  800e80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e83:	89 de                	mov    %ebx,%esi
  800e85:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e88:	eb 18                	jmp    800ea2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e8a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e8e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e95:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e97:	4b                   	dec    %ebx
  800e98:	eb 08                	jmp    800ea2 <vprintfmt+0x244>
  800e9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e9d:	89 de                	mov    %ebx,%esi
  800e9f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ea2:	85 db                	test   %ebx,%ebx
  800ea4:	7f e4                	jg     800e8a <vprintfmt+0x22c>
  800ea6:	89 7d 08             	mov    %edi,0x8(%ebp)
  800ea9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800eab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800eae:	e9 ce fd ff ff       	jmp    800c81 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800eb3:	83 f9 01             	cmp    $0x1,%ecx
  800eb6:	7e 10                	jle    800ec8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800eb8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebb:	8d 50 08             	lea    0x8(%eax),%edx
  800ebe:	89 55 14             	mov    %edx,0x14(%ebp)
  800ec1:	8b 30                	mov    (%eax),%esi
  800ec3:	8b 78 04             	mov    0x4(%eax),%edi
  800ec6:	eb 26                	jmp    800eee <vprintfmt+0x290>
	else if (lflag)
  800ec8:	85 c9                	test   %ecx,%ecx
  800eca:	74 12                	je     800ede <vprintfmt+0x280>
		return va_arg(*ap, long);
  800ecc:	8b 45 14             	mov    0x14(%ebp),%eax
  800ecf:	8d 50 04             	lea    0x4(%eax),%edx
  800ed2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed5:	8b 30                	mov    (%eax),%esi
  800ed7:	89 f7                	mov    %esi,%edi
  800ed9:	c1 ff 1f             	sar    $0x1f,%edi
  800edc:	eb 10                	jmp    800eee <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800ede:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee1:	8d 50 04             	lea    0x4(%eax),%edx
  800ee4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ee7:	8b 30                	mov    (%eax),%esi
  800ee9:	89 f7                	mov    %esi,%edi
  800eeb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800eee:	85 ff                	test   %edi,%edi
  800ef0:	78 0a                	js     800efc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ef2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef7:	e9 8c 00 00 00       	jmp    800f88 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800efc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f00:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800f07:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800f0a:	f7 de                	neg    %esi
  800f0c:	83 d7 00             	adc    $0x0,%edi
  800f0f:	f7 df                	neg    %edi
			}
			base = 10;
  800f11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f16:	eb 70                	jmp    800f88 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f18:	89 ca                	mov    %ecx,%edx
  800f1a:	8d 45 14             	lea    0x14(%ebp),%eax
  800f1d:	e8 c0 fc ff ff       	call   800be2 <getuint>
  800f22:	89 c6                	mov    %eax,%esi
  800f24:	89 d7                	mov    %edx,%edi
			base = 10;
  800f26:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f2b:	eb 5b                	jmp    800f88 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800f2d:	89 ca                	mov    %ecx,%edx
  800f2f:	8d 45 14             	lea    0x14(%ebp),%eax
  800f32:	e8 ab fc ff ff       	call   800be2 <getuint>
  800f37:	89 c6                	mov    %eax,%esi
  800f39:	89 d7                	mov    %edx,%edi
			base = 8;
  800f3b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800f40:	eb 46                	jmp    800f88 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800f42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f46:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f4d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f54:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f5b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f61:	8d 50 04             	lea    0x4(%eax),%edx
  800f64:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f67:	8b 30                	mov    (%eax),%esi
  800f69:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f6e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800f73:	eb 13                	jmp    800f88 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f75:	89 ca                	mov    %ecx,%edx
  800f77:	8d 45 14             	lea    0x14(%ebp),%eax
  800f7a:	e8 63 fc ff ff       	call   800be2 <getuint>
  800f7f:	89 c6                	mov    %eax,%esi
  800f81:	89 d7                	mov    %edx,%edi
			base = 16;
  800f83:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f88:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800f8c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f93:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9b:	89 34 24             	mov    %esi,(%esp)
  800f9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fa2:	89 da                	mov    %ebx,%edx
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa7:	e8 6c fb ff ff       	call   800b18 <printnum>
			break;
  800fac:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800faf:	e9 cd fc ff ff       	jmp    800c81 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fb4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fb8:	89 04 24             	mov    %eax,(%esp)
  800fbb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fbe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fc1:	e9 bb fc ff ff       	jmp    800c81 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fc6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fca:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800fd1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fd4:	eb 01                	jmp    800fd7 <vprintfmt+0x379>
  800fd6:	4e                   	dec    %esi
  800fd7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800fdb:	75 f9                	jne    800fd6 <vprintfmt+0x378>
  800fdd:	e9 9f fc ff ff       	jmp    800c81 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800fe2:	83 c4 4c             	add    $0x4c,%esp
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	83 ec 28             	sub    $0x28,%esp
  800ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ff6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ff9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ffd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801000:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801007:	85 c0                	test   %eax,%eax
  801009:	74 30                	je     80103b <vsnprintf+0x51>
  80100b:	85 d2                	test   %edx,%edx
  80100d:	7e 33                	jle    801042 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80100f:	8b 45 14             	mov    0x14(%ebp),%eax
  801012:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801016:	8b 45 10             	mov    0x10(%ebp),%eax
  801019:	89 44 24 08          	mov    %eax,0x8(%esp)
  80101d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801020:	89 44 24 04          	mov    %eax,0x4(%esp)
  801024:	c7 04 24 1c 0c 80 00 	movl   $0x800c1c,(%esp)
  80102b:	e8 2e fc ff ff       	call   800c5e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801030:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801033:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801036:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801039:	eb 0c                	jmp    801047 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80103b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801040:	eb 05                	jmp    801047 <vsnprintf+0x5d>
  801042:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801047:	c9                   	leave  
  801048:	c3                   	ret    

00801049 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80104f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801052:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801056:	8b 45 10             	mov    0x10(%ebp),%eax
  801059:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801060:	89 44 24 04          	mov    %eax,0x4(%esp)
  801064:	8b 45 08             	mov    0x8(%ebp),%eax
  801067:	89 04 24             	mov    %eax,(%esp)
  80106a:	e8 7b ff ff ff       	call   800fea <vsnprintf>
	va_end(ap);

	return rc;
}
  80106f:	c9                   	leave  
  801070:	c3                   	ret    
  801071:	00 00                	add    %al,(%eax)
	...

00801074 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 1c             	sub    $0x1c,%esp
  80107d:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801080:	85 c0                	test   %eax,%eax
  801082:	74 18                	je     80109c <readline+0x28>
		fprintf(1, "%s", prompt);
  801084:	89 44 24 08          	mov    %eax,0x8(%esp)
  801088:	c7 44 24 04 cd 35 80 	movl   $0x8035cd,0x4(%esp)
  80108f:	00 
  801090:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801097:	e8 9c 15 00 00       	call   802638 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  80109c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a3:	e8 69 f8 ff ff       	call   800911 <iscons>
  8010a8:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010aa:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010af:	e8 27 f8 ff ff       	call   8008db <getchar>
  8010b4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	79 20                	jns    8010da <readline+0x66>
			if (c != -E_EOF)
  8010ba:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8010bd:	0f 84 82 00 00 00    	je     801145 <readline+0xd1>
				cprintf("read error: %e\n", c);
  8010c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c7:	c7 04 24 9f 39 80 00 	movl   $0x80399f,(%esp)
  8010ce:	e8 29 fa ff ff       	call   800afc <cprintf>
			return NULL;
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d8:	eb 70                	jmp    80114a <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010da:	83 f8 08             	cmp    $0x8,%eax
  8010dd:	74 05                	je     8010e4 <readline+0x70>
  8010df:	83 f8 7f             	cmp    $0x7f,%eax
  8010e2:	75 17                	jne    8010fb <readline+0x87>
  8010e4:	85 f6                	test   %esi,%esi
  8010e6:	7e 13                	jle    8010fb <readline+0x87>
			if (echoing)
  8010e8:	85 ff                	test   %edi,%edi
  8010ea:	74 0c                	je     8010f8 <readline+0x84>
				cputchar('\b');
  8010ec:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010f3:	e8 c2 f7 ff ff       	call   8008ba <cputchar>
			i--;
  8010f8:	4e                   	dec    %esi
  8010f9:	eb b4                	jmp    8010af <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010fb:	83 fb 1f             	cmp    $0x1f,%ebx
  8010fe:	7e 1d                	jle    80111d <readline+0xa9>
  801100:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801106:	7f 15                	jg     80111d <readline+0xa9>
			if (echoing)
  801108:	85 ff                	test   %edi,%edi
  80110a:	74 08                	je     801114 <readline+0xa0>
				cputchar(c);
  80110c:	89 1c 24             	mov    %ebx,(%esp)
  80110f:	e8 a6 f7 ff ff       	call   8008ba <cputchar>
			buf[i++] = c;
  801114:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  80111a:	46                   	inc    %esi
  80111b:	eb 92                	jmp    8010af <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  80111d:	83 fb 0a             	cmp    $0xa,%ebx
  801120:	74 05                	je     801127 <readline+0xb3>
  801122:	83 fb 0d             	cmp    $0xd,%ebx
  801125:	75 88                	jne    8010af <readline+0x3b>
			if (echoing)
  801127:	85 ff                	test   %edi,%edi
  801129:	74 0c                	je     801137 <readline+0xc3>
				cputchar('\n');
  80112b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801132:	e8 83 f7 ff ff       	call   8008ba <cputchar>
			buf[i] = 0;
  801137:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80113e:	b8 20 50 80 00       	mov    $0x805020,%eax
  801143:	eb 05                	jmp    80114a <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  80114a:	83 c4 1c             	add    $0x1c,%esp
  80114d:	5b                   	pop    %ebx
  80114e:	5e                   	pop    %esi
  80114f:	5f                   	pop    %edi
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    
	...

00801154 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80115a:	b8 00 00 00 00       	mov    $0x0,%eax
  80115f:	eb 01                	jmp    801162 <strlen+0xe>
		n++;
  801161:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801162:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801166:	75 f9                	jne    801161 <strlen+0xd>
		n++;
	return n;
}
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801170:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801173:	b8 00 00 00 00       	mov    $0x0,%eax
  801178:	eb 01                	jmp    80117b <strnlen+0x11>
		n++;
  80117a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80117b:	39 d0                	cmp    %edx,%eax
  80117d:	74 06                	je     801185 <strnlen+0x1b>
  80117f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801183:	75 f5                	jne    80117a <strnlen+0x10>
		n++;
	return n;
}
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	53                   	push   %ebx
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
  80118e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801191:	ba 00 00 00 00       	mov    $0x0,%edx
  801196:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801199:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80119c:	42                   	inc    %edx
  80119d:	84 c9                	test   %cl,%cl
  80119f:	75 f5                	jne    801196 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8011a1:	5b                   	pop    %ebx
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	53                   	push   %ebx
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011ae:	89 1c 24             	mov    %ebx,(%esp)
  8011b1:	e8 9e ff ff ff       	call   801154 <strlen>
	strcpy(dst + len, src);
  8011b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011bd:	01 d8                	add    %ebx,%eax
  8011bf:	89 04 24             	mov    %eax,(%esp)
  8011c2:	e8 c0 ff ff ff       	call   801187 <strcpy>
	return dst;
}
  8011c7:	89 d8                	mov    %ebx,%eax
  8011c9:	83 c4 08             	add    $0x8,%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
  8011d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011da:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e2:	eb 0c                	jmp    8011f0 <strncpy+0x21>
		*dst++ = *src;
  8011e4:	8a 1a                	mov    (%edx),%bl
  8011e6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011e9:	80 3a 01             	cmpb   $0x1,(%edx)
  8011ec:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011ef:	41                   	inc    %ecx
  8011f0:	39 f1                	cmp    %esi,%ecx
  8011f2:	75 f0                	jne    8011e4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801206:	85 d2                	test   %edx,%edx
  801208:	75 0a                	jne    801214 <strlcpy+0x1c>
  80120a:	89 f0                	mov    %esi,%eax
  80120c:	eb 1a                	jmp    801228 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80120e:	88 18                	mov    %bl,(%eax)
  801210:	40                   	inc    %eax
  801211:	41                   	inc    %ecx
  801212:	eb 02                	jmp    801216 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801214:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801216:	4a                   	dec    %edx
  801217:	74 0a                	je     801223 <strlcpy+0x2b>
  801219:	8a 19                	mov    (%ecx),%bl
  80121b:	84 db                	test   %bl,%bl
  80121d:	75 ef                	jne    80120e <strlcpy+0x16>
  80121f:	89 c2                	mov    %eax,%edx
  801221:	eb 02                	jmp    801225 <strlcpy+0x2d>
  801223:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801225:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801228:	29 f0                	sub    %esi,%eax
}
  80122a:	5b                   	pop    %ebx
  80122b:	5e                   	pop    %esi
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801234:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801237:	eb 02                	jmp    80123b <strcmp+0xd>
		p++, q++;
  801239:	41                   	inc    %ecx
  80123a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80123b:	8a 01                	mov    (%ecx),%al
  80123d:	84 c0                	test   %al,%al
  80123f:	74 04                	je     801245 <strcmp+0x17>
  801241:	3a 02                	cmp    (%edx),%al
  801243:	74 f4                	je     801239 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801245:	0f b6 c0             	movzbl %al,%eax
  801248:	0f b6 12             	movzbl (%edx),%edx
  80124b:	29 d0                	sub    %edx,%eax
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	53                   	push   %ebx
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801259:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80125c:	eb 03                	jmp    801261 <strncmp+0x12>
		n--, p++, q++;
  80125e:	4a                   	dec    %edx
  80125f:	40                   	inc    %eax
  801260:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801261:	85 d2                	test   %edx,%edx
  801263:	74 14                	je     801279 <strncmp+0x2a>
  801265:	8a 18                	mov    (%eax),%bl
  801267:	84 db                	test   %bl,%bl
  801269:	74 04                	je     80126f <strncmp+0x20>
  80126b:	3a 19                	cmp    (%ecx),%bl
  80126d:	74 ef                	je     80125e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80126f:	0f b6 00             	movzbl (%eax),%eax
  801272:	0f b6 11             	movzbl (%ecx),%edx
  801275:	29 d0                	sub    %edx,%eax
  801277:	eb 05                	jmp    80127e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80127e:	5b                   	pop    %ebx
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	8b 45 08             	mov    0x8(%ebp),%eax
  801287:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80128a:	eb 05                	jmp    801291 <strchr+0x10>
		if (*s == c)
  80128c:	38 ca                	cmp    %cl,%dl
  80128e:	74 0c                	je     80129c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801290:	40                   	inc    %eax
  801291:	8a 10                	mov    (%eax),%dl
  801293:	84 d2                	test   %dl,%dl
  801295:	75 f5                	jne    80128c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012a7:	eb 05                	jmp    8012ae <strfind+0x10>
		if (*s == c)
  8012a9:	38 ca                	cmp    %cl,%dl
  8012ab:	74 07                	je     8012b4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8012ad:	40                   	inc    %eax
  8012ae:	8a 10                	mov    (%eax),%dl
  8012b0:	84 d2                	test   %dl,%dl
  8012b2:	75 f5                	jne    8012a9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    

008012b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	57                   	push   %edi
  8012ba:	56                   	push   %esi
  8012bb:	53                   	push   %ebx
  8012bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012c5:	85 c9                	test   %ecx,%ecx
  8012c7:	74 30                	je     8012f9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012cf:	75 25                	jne    8012f6 <memset+0x40>
  8012d1:	f6 c1 03             	test   $0x3,%cl
  8012d4:	75 20                	jne    8012f6 <memset+0x40>
		c &= 0xFF;
  8012d6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012d9:	89 d3                	mov    %edx,%ebx
  8012db:	c1 e3 08             	shl    $0x8,%ebx
  8012de:	89 d6                	mov    %edx,%esi
  8012e0:	c1 e6 18             	shl    $0x18,%esi
  8012e3:	89 d0                	mov    %edx,%eax
  8012e5:	c1 e0 10             	shl    $0x10,%eax
  8012e8:	09 f0                	or     %esi,%eax
  8012ea:	09 d0                	or     %edx,%eax
  8012ec:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8012ee:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8012f1:	fc                   	cld    
  8012f2:	f3 ab                	rep stos %eax,%es:(%edi)
  8012f4:	eb 03                	jmp    8012f9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012f6:	fc                   	cld    
  8012f7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012f9:	89 f8                	mov    %edi,%eax
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5f                   	pop    %edi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	57                   	push   %edi
  801304:	56                   	push   %esi
  801305:	8b 45 08             	mov    0x8(%ebp),%eax
  801308:	8b 75 0c             	mov    0xc(%ebp),%esi
  80130b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80130e:	39 c6                	cmp    %eax,%esi
  801310:	73 34                	jae    801346 <memmove+0x46>
  801312:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801315:	39 d0                	cmp    %edx,%eax
  801317:	73 2d                	jae    801346 <memmove+0x46>
		s += n;
		d += n;
  801319:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80131c:	f6 c2 03             	test   $0x3,%dl
  80131f:	75 1b                	jne    80133c <memmove+0x3c>
  801321:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801327:	75 13                	jne    80133c <memmove+0x3c>
  801329:	f6 c1 03             	test   $0x3,%cl
  80132c:	75 0e                	jne    80133c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80132e:	83 ef 04             	sub    $0x4,%edi
  801331:	8d 72 fc             	lea    -0x4(%edx),%esi
  801334:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801337:	fd                   	std    
  801338:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80133a:	eb 07                	jmp    801343 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80133c:	4f                   	dec    %edi
  80133d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801340:	fd                   	std    
  801341:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801343:	fc                   	cld    
  801344:	eb 20                	jmp    801366 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801346:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80134c:	75 13                	jne    801361 <memmove+0x61>
  80134e:	a8 03                	test   $0x3,%al
  801350:	75 0f                	jne    801361 <memmove+0x61>
  801352:	f6 c1 03             	test   $0x3,%cl
  801355:	75 0a                	jne    801361 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801357:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80135a:	89 c7                	mov    %eax,%edi
  80135c:	fc                   	cld    
  80135d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80135f:	eb 05                	jmp    801366 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801361:	89 c7                	mov    %eax,%edi
  801363:	fc                   	cld    
  801364:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801366:	5e                   	pop    %esi
  801367:	5f                   	pop    %edi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801370:	8b 45 10             	mov    0x10(%ebp),%eax
  801373:	89 44 24 08          	mov    %eax,0x8(%esp)
  801377:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137e:	8b 45 08             	mov    0x8(%ebp),%eax
  801381:	89 04 24             	mov    %eax,(%esp)
  801384:	e8 77 ff ff ff       	call   801300 <memmove>
}
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	57                   	push   %edi
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	8b 7d 08             	mov    0x8(%ebp),%edi
  801394:	8b 75 0c             	mov    0xc(%ebp),%esi
  801397:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80139a:	ba 00 00 00 00       	mov    $0x0,%edx
  80139f:	eb 16                	jmp    8013b7 <memcmp+0x2c>
		if (*s1 != *s2)
  8013a1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8013a4:	42                   	inc    %edx
  8013a5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8013a9:	38 c8                	cmp    %cl,%al
  8013ab:	74 0a                	je     8013b7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8013ad:	0f b6 c0             	movzbl %al,%eax
  8013b0:	0f b6 c9             	movzbl %cl,%ecx
  8013b3:	29 c8                	sub    %ecx,%eax
  8013b5:	eb 09                	jmp    8013c0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013b7:	39 da                	cmp    %ebx,%edx
  8013b9:	75 e6                	jne    8013a1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c0:	5b                   	pop    %ebx
  8013c1:	5e                   	pop    %esi
  8013c2:	5f                   	pop    %edi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8013ce:	89 c2                	mov    %eax,%edx
  8013d0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8013d3:	eb 05                	jmp    8013da <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013d5:	38 08                	cmp    %cl,(%eax)
  8013d7:	74 05                	je     8013de <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013d9:	40                   	inc    %eax
  8013da:	39 d0                	cmp    %edx,%eax
  8013dc:	72 f7                	jb     8013d5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	57                   	push   %edi
  8013e4:	56                   	push   %esi
  8013e5:	53                   	push   %ebx
  8013e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013ec:	eb 01                	jmp    8013ef <strtol+0xf>
		s++;
  8013ee:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013ef:	8a 02                	mov    (%edx),%al
  8013f1:	3c 20                	cmp    $0x20,%al
  8013f3:	74 f9                	je     8013ee <strtol+0xe>
  8013f5:	3c 09                	cmp    $0x9,%al
  8013f7:	74 f5                	je     8013ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013f9:	3c 2b                	cmp    $0x2b,%al
  8013fb:	75 08                	jne    801405 <strtol+0x25>
		s++;
  8013fd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8013fe:	bf 00 00 00 00       	mov    $0x0,%edi
  801403:	eb 13                	jmp    801418 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801405:	3c 2d                	cmp    $0x2d,%al
  801407:	75 0a                	jne    801413 <strtol+0x33>
		s++, neg = 1;
  801409:	8d 52 01             	lea    0x1(%edx),%edx
  80140c:	bf 01 00 00 00       	mov    $0x1,%edi
  801411:	eb 05                	jmp    801418 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801413:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801418:	85 db                	test   %ebx,%ebx
  80141a:	74 05                	je     801421 <strtol+0x41>
  80141c:	83 fb 10             	cmp    $0x10,%ebx
  80141f:	75 28                	jne    801449 <strtol+0x69>
  801421:	8a 02                	mov    (%edx),%al
  801423:	3c 30                	cmp    $0x30,%al
  801425:	75 10                	jne    801437 <strtol+0x57>
  801427:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80142b:	75 0a                	jne    801437 <strtol+0x57>
		s += 2, base = 16;
  80142d:	83 c2 02             	add    $0x2,%edx
  801430:	bb 10 00 00 00       	mov    $0x10,%ebx
  801435:	eb 12                	jmp    801449 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801437:	85 db                	test   %ebx,%ebx
  801439:	75 0e                	jne    801449 <strtol+0x69>
  80143b:	3c 30                	cmp    $0x30,%al
  80143d:	75 05                	jne    801444 <strtol+0x64>
		s++, base = 8;
  80143f:	42                   	inc    %edx
  801440:	b3 08                	mov    $0x8,%bl
  801442:	eb 05                	jmp    801449 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801444:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801449:	b8 00 00 00 00       	mov    $0x0,%eax
  80144e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801450:	8a 0a                	mov    (%edx),%cl
  801452:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801455:	80 fb 09             	cmp    $0x9,%bl
  801458:	77 08                	ja     801462 <strtol+0x82>
			dig = *s - '0';
  80145a:	0f be c9             	movsbl %cl,%ecx
  80145d:	83 e9 30             	sub    $0x30,%ecx
  801460:	eb 1e                	jmp    801480 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801462:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801465:	80 fb 19             	cmp    $0x19,%bl
  801468:	77 08                	ja     801472 <strtol+0x92>
			dig = *s - 'a' + 10;
  80146a:	0f be c9             	movsbl %cl,%ecx
  80146d:	83 e9 57             	sub    $0x57,%ecx
  801470:	eb 0e                	jmp    801480 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801472:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801475:	80 fb 19             	cmp    $0x19,%bl
  801478:	77 12                	ja     80148c <strtol+0xac>
			dig = *s - 'A' + 10;
  80147a:	0f be c9             	movsbl %cl,%ecx
  80147d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801480:	39 f1                	cmp    %esi,%ecx
  801482:	7d 0c                	jge    801490 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801484:	42                   	inc    %edx
  801485:	0f af c6             	imul   %esi,%eax
  801488:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80148a:	eb c4                	jmp    801450 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80148c:	89 c1                	mov    %eax,%ecx
  80148e:	eb 02                	jmp    801492 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801490:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801492:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801496:	74 05                	je     80149d <strtol+0xbd>
		*endptr = (char *) s;
  801498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80149d:	85 ff                	test   %edi,%edi
  80149f:	74 04                	je     8014a5 <strtol+0xc5>
  8014a1:	89 c8                	mov    %ecx,%eax
  8014a3:	f7 d8                	neg    %eax
}
  8014a5:	5b                   	pop    %ebx
  8014a6:	5e                   	pop    %esi
  8014a7:	5f                   	pop    %edi
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    
	...

008014ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	57                   	push   %edi
  8014b0:	56                   	push   %esi
  8014b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bd:	89 c3                	mov    %eax,%ebx
  8014bf:	89 c7                	mov    %eax,%edi
  8014c1:	89 c6                	mov    %eax,%esi
  8014c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014c5:	5b                   	pop    %ebx
  8014c6:	5e                   	pop    %esi
  8014c7:	5f                   	pop    %edi
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	57                   	push   %edi
  8014ce:	56                   	push   %esi
  8014cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8014da:	89 d1                	mov    %edx,%ecx
  8014dc:	89 d3                	mov    %edx,%ebx
  8014de:	89 d7                	mov    %edx,%edi
  8014e0:	89 d6                	mov    %edx,%esi
  8014e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014e4:	5b                   	pop    %ebx
  8014e5:	5e                   	pop    %esi
  8014e6:	5f                   	pop    %edi
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    

008014e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	57                   	push   %edi
  8014ed:	56                   	push   %esi
  8014ee:	53                   	push   %ebx
  8014ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ff:	89 cb                	mov    %ecx,%ebx
  801501:	89 cf                	mov    %ecx,%edi
  801503:	89 ce                	mov    %ecx,%esi
  801505:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801507:	85 c0                	test   %eax,%eax
  801509:	7e 28                	jle    801533 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80150b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80150f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801516:	00 
  801517:	c7 44 24 08 af 39 80 	movl   $0x8039af,0x8(%esp)
  80151e:	00 
  80151f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801526:	00 
  801527:	c7 04 24 cc 39 80 00 	movl   $0x8039cc,(%esp)
  80152e:	e8 d1 f4 ff ff       	call   800a04 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801533:	83 c4 2c             	add    $0x2c,%esp
  801536:	5b                   	pop    %ebx
  801537:	5e                   	pop    %esi
  801538:	5f                   	pop    %edi
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	57                   	push   %edi
  80153f:	56                   	push   %esi
  801540:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	b8 02 00 00 00       	mov    $0x2,%eax
  80154b:	89 d1                	mov    %edx,%ecx
  80154d:	89 d3                	mov    %edx,%ebx
  80154f:	89 d7                	mov    %edx,%edi
  801551:	89 d6                	mov    %edx,%esi
  801553:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801555:	5b                   	pop    %ebx
  801556:	5e                   	pop    %esi
  801557:	5f                   	pop    %edi
  801558:	5d                   	pop    %ebp
  801559:	c3                   	ret    

0080155a <sys_yield>:

void
sys_yield(void)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	57                   	push   %edi
  80155e:	56                   	push   %esi
  80155f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801560:	ba 00 00 00 00       	mov    $0x0,%edx
  801565:	b8 0b 00 00 00       	mov    $0xb,%eax
  80156a:	89 d1                	mov    %edx,%ecx
  80156c:	89 d3                	mov    %edx,%ebx
  80156e:	89 d7                	mov    %edx,%edi
  801570:	89 d6                	mov    %edx,%esi
  801572:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801574:	5b                   	pop    %ebx
  801575:	5e                   	pop    %esi
  801576:	5f                   	pop    %edi
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    

00801579 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	57                   	push   %edi
  80157d:	56                   	push   %esi
  80157e:	53                   	push   %ebx
  80157f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801582:	be 00 00 00 00       	mov    $0x0,%esi
  801587:	b8 04 00 00 00       	mov    $0x4,%eax
  80158c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80158f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801592:	8b 55 08             	mov    0x8(%ebp),%edx
  801595:	89 f7                	mov    %esi,%edi
  801597:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801599:	85 c0                	test   %eax,%eax
  80159b:	7e 28                	jle    8015c5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80159d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015a1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8015a8:	00 
  8015a9:	c7 44 24 08 af 39 80 	movl   $0x8039af,0x8(%esp)
  8015b0:	00 
  8015b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015b8:	00 
  8015b9:	c7 04 24 cc 39 80 00 	movl   $0x8039cc,(%esp)
  8015c0:	e8 3f f4 ff ff       	call   800a04 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015c5:	83 c4 2c             	add    $0x2c,%esp
  8015c8:	5b                   	pop    %ebx
  8015c9:	5e                   	pop    %esi
  8015ca:	5f                   	pop    %edi
  8015cb:	5d                   	pop    %ebp
  8015cc:	c3                   	ret    

008015cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	57                   	push   %edi
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8015db:	8b 75 18             	mov    0x18(%ebp),%esi
  8015de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	7e 28                	jle    801618 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015f4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8015fb:	00 
  8015fc:	c7 44 24 08 af 39 80 	movl   $0x8039af,0x8(%esp)
  801603:	00 
  801604:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80160b:	00 
  80160c:	c7 04 24 cc 39 80 00 	movl   $0x8039cc,(%esp)
  801613:	e8 ec f3 ff ff       	call   800a04 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801618:	83 c4 2c             	add    $0x2c,%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5f                   	pop    %edi
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    

00801620 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	57                   	push   %edi
  801624:	56                   	push   %esi
  801625:	53                   	push   %ebx
  801626:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801629:	bb 00 00 00 00       	mov    $0x0,%ebx
  80162e:	b8 06 00 00 00       	mov    $0x6,%eax
  801633:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801636:	8b 55 08             	mov    0x8(%ebp),%edx
  801639:	89 df                	mov    %ebx,%edi
  80163b:	89 de                	mov    %ebx,%esi
  80163d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80163f:	85 c0                	test   %eax,%eax
  801641:	7e 28                	jle    80166b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801643:	89 44 24 10          	mov    %eax,0x10(%esp)
  801647:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80164e:	00 
  80164f:	c7 44 24 08 af 39 80 	movl   $0x8039af,0x8(%esp)
  801656:	00 
  801657:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80165e:	00 
  80165f:	c7 04 24 cc 39 80 00 	movl   $0x8039cc,(%esp)
  801666:	e8 99 f3 ff ff       	call   800a04 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80166b:	83 c4 2c             	add    $0x2c,%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5f                   	pop    %edi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	57                   	push   %edi
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80167c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801681:	b8 08 00 00 00       	mov    $0x8,%eax
  801686:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801689:	8b 55 08             	mov    0x8(%ebp),%edx
  80168c:	89 df                	mov    %ebx,%edi
  80168e:	89 de                	mov    %ebx,%esi
  801690:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801692:	85 c0                	test   %eax,%eax
  801694:	7e 28                	jle    8016be <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801696:	89 44 24 10          	mov    %eax,0x10(%esp)
  80169a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8016a1:	00 
  8016a2:	c7 44 24 08 af 39 80 	movl   $0x8039af,0x8(%esp)
  8016a9:	00 
  8016aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016b1:	00 
  8016b2:	c7 04 24 cc 39 80 00 	movl   $0x8039cc,(%esp)
  8016b9:	e8 46 f3 ff ff       	call   800a04 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016be:	83 c4 2c             	add    $0x2c,%esp
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	5f                   	pop    %edi
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	57                   	push   %edi
  8016ca:	56                   	push   %esi
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8016d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8016df:	89 df                	mov    %ebx,%edi
  8016e1:	89 de                	mov    %ebx,%esi
  8016e3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	7e 28                	jle    801711 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8016f4:	00 
  8016f5:	c7 44 24 08 af 39 80 	movl   $0x8039af,0x8(%esp)
  8016fc:	00 
  8016fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801704:	00 
  801705:	c7 04 24 cc 39 80 00 	movl   $0x8039cc,(%esp)
  80170c:	e8 f3 f2 ff ff       	call   800a04 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801711:	83 c4 2c             	add    $0x2c,%esp
  801714:	5b                   	pop    %ebx
  801715:	5e                   	pop    %esi
  801716:	5f                   	pop    %edi
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	57                   	push   %edi
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801722:	bb 00 00 00 00       	mov    $0x0,%ebx
  801727:	b8 0a 00 00 00       	mov    $0xa,%eax
  80172c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172f:	8b 55 08             	mov    0x8(%ebp),%edx
  801732:	89 df                	mov    %ebx,%edi
  801734:	89 de                	mov    %ebx,%esi
  801736:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801738:	85 c0                	test   %eax,%eax
  80173a:	7e 28                	jle    801764 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80173c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801740:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801747:	00 
  801748:	c7 44 24 08 af 39 80 	movl   $0x8039af,0x8(%esp)
  80174f:	00 
  801750:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801757:	00 
  801758:	c7 04 24 cc 39 80 00 	movl   $0x8039cc,(%esp)
  80175f:	e8 a0 f2 ff ff       	call   800a04 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801764:	83 c4 2c             	add    $0x2c,%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5f                   	pop    %edi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	57                   	push   %edi
  801770:	56                   	push   %esi
  801771:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801772:	be 00 00 00 00       	mov    $0x0,%esi
  801777:	b8 0c 00 00 00       	mov    $0xc,%eax
  80177c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80177f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801785:	8b 55 08             	mov    0x8(%ebp),%edx
  801788:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5f                   	pop    %edi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	57                   	push   %edi
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801798:	b9 00 00 00 00       	mov    $0x0,%ecx
  80179d:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a5:	89 cb                	mov    %ecx,%ebx
  8017a7:	89 cf                	mov    %ecx,%edi
  8017a9:	89 ce                	mov    %ecx,%esi
  8017ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	7e 28                	jle    8017d9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017b5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8017bc:	00 
  8017bd:	c7 44 24 08 af 39 80 	movl   $0x8039af,0x8(%esp)
  8017c4:	00 
  8017c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8017cc:	00 
  8017cd:	c7 04 24 cc 39 80 00 	movl   $0x8039cc,(%esp)
  8017d4:	e8 2b f2 ff ff       	call   800a04 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8017d9:	83 c4 2c             	add    $0x2c,%esp
  8017dc:	5b                   	pop    %ebx
  8017dd:	5e                   	pop    %esi
  8017de:	5f                   	pop    %edi
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    
  8017e1:	00 00                	add    %al,(%eax)
	...

008017e4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	53                   	push   %ebx
  8017e8:	83 ec 24             	sub    $0x24,%esp
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017ee:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW)){
  8017f0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017f4:	75 2d                	jne    801823 <pgfault+0x3f>
  8017f6:	89 d8                	mov    %ebx,%eax
  8017f8:	c1 e8 0c             	shr    $0xc,%eax
  8017fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801802:	f6 c4 08             	test   $0x8,%ah
  801805:	75 1c                	jne    801823 <pgfault+0x3f>
		panic("page fault: Write exception and the page's PTE is marked as COW\n");
  801807:	c7 44 24 08 dc 39 80 	movl   $0x8039dc,0x8(%esp)
  80180e:	00 
  80180f:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801816:	00 
  801817:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  80181e:	e8 e1 f1 ff ff       	call   800a04 <_panic>
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801823:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80182a:	00 
  80182b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801832:	00 
  801833:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80183a:	e8 3a fd ff ff       	call   801579 <sys_page_alloc>
  80183f:	85 c0                	test   %eax,%eax
  801841:	79 20                	jns    801863 <pgfault+0x7f>
  		panic("sys_page_alloc: %e", r);
  801843:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801847:	c7 44 24 08 4b 3a 80 	movl   $0x803a4b,0x8(%esp)
  80184e:	00 
  80184f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801856:	00 
  801857:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  80185e:	e8 a1 f1 ff ff       	call   800a04 <_panic>
// copy the data from the old page to the new page, then move the new
// page to the old page's address.
// Hint:
//   You should make three system calls.
//   No need to explicitly delete the old page's mapping.
	addr = ROUNDDOWN(addr, PGSIZE);
  801863:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  		panic("sys_page_alloc: %e", r);
	memcpy((void *)PFTEMP, addr, PGSIZE);
  801869:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801870:	00 
  801871:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801875:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80187c:	e8 e9 fa ff ff       	call   80136a <memcpy>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801881:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801888:	00 
  801889:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80188d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801894:	00 
  801895:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80189c:	00 
  80189d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a4:	e8 24 fd ff ff       	call   8015cd <sys_page_map>
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	79 20                	jns    8018cd <pgfault+0xe9>
  		panic("sys_page_map: %e", r);
  8018ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018b1:	c7 44 24 08 5e 3a 80 	movl   $0x803a5e,0x8(%esp)
  8018b8:	00 
  8018b9:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8018c0:	00 
  8018c1:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  8018c8:	e8 37 f1 ff ff       	call   800a04 <_panic>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8018cd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018d4:	00 
  8018d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018dc:	e8 3f fd ff ff       	call   801620 <sys_page_unmap>
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	79 20                	jns    801905 <pgfault+0x121>
  		panic("sys_page_unmap: %e", r);
  8018e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018e9:	c7 44 24 08 6f 3a 80 	movl   $0x803a6f,0x8(%esp)
  8018f0:	00 
  8018f1:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8018f8:	00 
  8018f9:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  801900:	e8 ff f0 ff ff       	call   800a04 <_panic>
}
  801905:	83 c4 24             	add    $0x24,%esp
  801908:	5b                   	pop    %ebx
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	57                   	push   %edi
  80190f:	56                   	push   %esi
  801910:	53                   	push   %ebx
  801911:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
 	extern void _pgfault_upcall(void);
	int r;
	uintptr_t va;
	
	set_pgfault_handler(pgfault);
  801914:	c7 04 24 e4 17 80 00 	movl   $0x8017e4,(%esp)
  80191b:	e8 0c 17 00 00       	call   80302c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801920:	ba 07 00 00 00       	mov    $0x7,%edx
  801925:	89 d0                	mov    %edx,%eax
  801927:	cd 30                	int    $0x30
  801929:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80192c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
  80192f:	85 c0                	test   %eax,%eax
  801931:	79 1c                	jns    80194f <fork+0x44>
		panic("sys_exofork failed\n");
  801933:	c7 44 24 08 82 3a 80 	movl   $0x803a82,0x8(%esp)
  80193a:	00 
  80193b:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801942:	00 
  801943:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  80194a:	e8 b5 f0 ff ff       	call   800a04 <_panic>
	if(c_envid == 0){
  80194f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801953:	75 25                	jne    80197a <fork+0x6f>
		thisenv = &envs[ENVX(sys_getenvid())];
  801955:	e8 e1 fb ff ff       	call   80153b <sys_getenvid>
  80195a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80195f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801966:	c1 e0 07             	shl    $0x7,%eax
  801969:	29 d0                	sub    %edx,%eax
  80196b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801970:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  801975:	e9 e3 01 00 00       	jmp    801b5d <fork+0x252>
	set_pgfault_handler(pgfault);
	envid_t c_envid = sys_exofork();
	
	if(c_envid < 0)
		panic("sys_exofork failed\n");
	if(c_envid == 0){
  80197a:	bb 00 00 00 00       	mov    $0x0,%ebx
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & (PTE_P | PTE_U))){
  80197f:	89 d8                	mov    %ebx,%eax
  801981:	c1 e8 16             	shr    $0x16,%eax
  801984:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80198b:	a8 01                	test   $0x1,%al
  80198d:	0f 84 0b 01 00 00    	je     801a9e <fork+0x193>
  801993:	89 de                	mov    %ebx,%esi
  801995:	c1 ee 0c             	shr    $0xc,%esi
  801998:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80199f:	a8 05                	test   $0x5,%al
  8019a1:	0f 84 f7 00 00 00    	je     801a9e <fork+0x193>
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t va = pn * PGSIZE;
  8019a7:	89 f7                	mov    %esi,%edi
  8019a9:	c1 e7 0c             	shl    $0xc,%edi
	envid_t cur_envid = sys_getenvid();
  8019ac:	e8 8a fb ff ff       	call   80153b <sys_getenvid>
  8019b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// LAB 4: Your code here.
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  8019b4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019bb:	a8 02                	test   $0x2,%al
  8019bd:	75 10                	jne    8019cf <fork+0xc4>
  8019bf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019c6:	f6 c4 08             	test   $0x8,%ah
  8019c9:	0f 84 89 00 00 00    	je     801a58 <fork+0x14d>
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | PTE_U 
  8019cf:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8019d6:	00 
  8019d7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019e9:	89 04 24             	mov    %eax,(%esp)
  8019ec:	e8 dc fb ff ff       	call   8015cd <sys_page_map>
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	79 20                	jns    801a15 <fork+0x10a>
			| PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  8019f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019f9:	c7 44 24 08 96 3a 80 	movl   $0x803a96,0x8(%esp)
  801a00:	00 
  801a01:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  801a08:	00 
  801a09:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  801a10:	e8 ef ef ff ff       	call   800a04 <_panic>
		if((r = sys_page_map(cur_envid, (void *)va, cur_envid, (void *)va, PTE_P | 
  801a15:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801a1c:	00 
  801a1d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a24:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a28:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a2c:	89 04 24             	mov    %eax,(%esp)
  801a2f:	e8 99 fb ff ff       	call   8015cd <sys_page_map>
  801a34:	85 c0                	test   %eax,%eax
  801a36:	79 66                	jns    801a9e <fork+0x193>
			PTE_U | PTE_COW)) < 0)
			panic("sys_page_map: %e\n", r);
  801a38:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a3c:	c7 44 24 08 96 3a 80 	movl   $0x803a96,0x8(%esp)
  801a43:	00 
  801a44:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  801a4b:	00 
  801a4c:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  801a53:	e8 ac ef ff ff       	call   800a04 <_panic>
	} else {
		if((r = sys_page_map(cur_envid, (void *)va, envid, (void *)va, PTE_P | 
  801a58:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801a5f:	00 
  801a60:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a64:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a67:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a6b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a72:	89 04 24             	mov    %eax,(%esp)
  801a75:	e8 53 fb ff ff       	call   8015cd <sys_page_map>
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	79 20                	jns    801a9e <fork+0x193>
			PTE_U)) < 0)
			panic("sys_page_map: %e\n", r);
  801a7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a82:	c7 44 24 08 96 3a 80 	movl   $0x803a96,0x8(%esp)
  801a89:	00 
  801a8a:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801a91:	00 
  801a92:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  801a99:	e8 66 ef ff ff       	call   800a04 <_panic>
	if(c_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// Copy our address space and page fault handler setup to the child.	
	for(va = 0; va < USTACKTOP; va += PGSIZE){
  801a9e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801aa4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801aaa:	0f 85 cf fe ff ff    	jne    80197f <fork+0x74>
			duppage(c_envid, PGNUM(va));
		} 
	}
	
	// alloc a page and map child exception stack
	if ((r = sys_page_alloc(c_envid, (void *)(UXSTACKTOP-PGSIZE), 
  801ab0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ab7:	00 
  801ab8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801abf:	ee 
  801ac0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801ac3:	89 04 24             	mov    %eax,(%esp)
  801ac6:	e8 ae fa ff ff       	call   801579 <sys_page_alloc>
  801acb:	85 c0                	test   %eax,%eax
  801acd:	79 20                	jns    801aef <fork+0x1e4>
		PTE_U | PTE_P | PTE_W)) < 0)
     		panic("sys_page_alloc: %e\n", r);
  801acf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ad3:	c7 44 24 08 a8 3a 80 	movl   $0x803aa8,0x8(%esp)
  801ada:	00 
  801adb:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ae2:	00 
  801ae3:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  801aea:	e8 15 ef ff ff       	call   800a04 <_panic>

 	if ((r = sys_env_set_pgfault_upcall(c_envid, _pgfault_upcall)) < 0)
  801aef:	c7 44 24 04 78 30 80 	movl   $0x803078,0x4(%esp)
  801af6:	00 
  801af7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801afa:	89 04 24             	mov    %eax,(%esp)
  801afd:	e8 17 fc ff ff       	call   801719 <sys_env_set_pgfault_upcall>
  801b02:	85 c0                	test   %eax,%eax
  801b04:	79 20                	jns    801b26 <fork+0x21b>
     		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801b06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b0a:	c7 44 24 08 20 3a 80 	movl   $0x803a20,0x8(%esp)
  801b11:	00 
  801b12:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801b19:	00 
  801b1a:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  801b21:	e8 de ee ff ff       	call   800a04 <_panic>

	// Start the child environment running
	if ((r = sys_env_set_status(c_envid, ENV_RUNNABLE)) < 0)
  801b26:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801b2d:	00 
  801b2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b31:	89 04 24             	mov    %eax,(%esp)
  801b34:	e8 3a fb ff ff       	call   801673 <sys_env_set_status>
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	79 20                	jns    801b5d <fork+0x252>
		panic("sys_env_set_status: %e\n", r);
  801b3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b41:	c7 44 24 08 bc 3a 80 	movl   $0x803abc,0x8(%esp)
  801b48:	00 
  801b49:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801b50:	00 
  801b51:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  801b58:	e8 a7 ee ff ff       	call   800a04 <_panic>
 
	return c_envid;	
}
  801b5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801b60:	83 c4 3c             	add    $0x3c,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5f                   	pop    %edi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <sfork>:

// Challenge!
int
sfork(void)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801b6e:	c7 44 24 08 d4 3a 80 	movl   $0x803ad4,0x8(%esp)
  801b75:	00 
  801b76:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
  801b7d:	00 
  801b7e:	c7 04 24 40 3a 80 00 	movl   $0x803a40,(%esp)
  801b85:	e8 7a ee ff ff       	call   800a04 <_panic>
	...

00801b8c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  801b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b95:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801b98:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801b9a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801b9d:	83 3a 01             	cmpl   $0x1,(%edx)
  801ba0:	7e 0b                	jle    801bad <argstart+0x21>
  801ba2:	85 c9                	test   %ecx,%ecx
  801ba4:	75 0e                	jne    801bb4 <argstart+0x28>
  801ba6:	ba 00 00 00 00       	mov    $0x0,%edx
  801bab:	eb 0c                	jmp    801bb9 <argstart+0x2d>
  801bad:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb2:	eb 05                	jmp    801bb9 <argstart+0x2d>
  801bb4:	ba 81 34 80 00       	mov    $0x803481,%edx
  801bb9:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801bbc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801bc3:	5d                   	pop    %ebp
  801bc4:	c3                   	ret    

00801bc5 <argnext>:

int
argnext(struct Argstate *args)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	53                   	push   %ebx
  801bc9:	83 ec 14             	sub    $0x14,%esp
  801bcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801bcf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801bd6:	8b 43 08             	mov    0x8(%ebx),%eax
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	74 6c                	je     801c49 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  801bdd:	80 38 00             	cmpb   $0x0,(%eax)
  801be0:	75 4d                	jne    801c2f <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801be2:	8b 0b                	mov    (%ebx),%ecx
  801be4:	83 39 01             	cmpl   $0x1,(%ecx)
  801be7:	74 52                	je     801c3b <argnext+0x76>
		    || args->argv[1][0] != '-'
  801be9:	8b 53 04             	mov    0x4(%ebx),%edx
  801bec:	8b 42 04             	mov    0x4(%edx),%eax
  801bef:	80 38 2d             	cmpb   $0x2d,(%eax)
  801bf2:	75 47                	jne    801c3b <argnext+0x76>
		    || args->argv[1][1] == '\0')
  801bf4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801bf8:	74 41                	je     801c3b <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801bfa:	40                   	inc    %eax
  801bfb:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bfe:	8b 01                	mov    (%ecx),%eax
  801c00:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801c07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c0b:	8d 42 08             	lea    0x8(%edx),%eax
  801c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c12:	83 c2 04             	add    $0x4,%edx
  801c15:	89 14 24             	mov    %edx,(%esp)
  801c18:	e8 e3 f6 ff ff       	call   801300 <memmove>
		(*args->argc)--;
  801c1d:	8b 03                	mov    (%ebx),%eax
  801c1f:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801c21:	8b 43 08             	mov    0x8(%ebx),%eax
  801c24:	80 38 2d             	cmpb   $0x2d,(%eax)
  801c27:	75 06                	jne    801c2f <argnext+0x6a>
  801c29:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801c2d:	74 0c                	je     801c3b <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801c2f:	8b 53 08             	mov    0x8(%ebx),%edx
  801c32:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801c35:	42                   	inc    %edx
  801c36:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801c39:	eb 13                	jmp    801c4e <argnext+0x89>

    endofargs:
	args->curarg = 0;
  801c3b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801c42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c47:	eb 05                	jmp    801c4e <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801c49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801c4e:	83 c4 14             	add    $0x14,%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    

00801c54 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	53                   	push   %ebx
  801c58:	83 ec 14             	sub    $0x14,%esp
  801c5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801c5e:	8b 43 08             	mov    0x8(%ebx),%eax
  801c61:	85 c0                	test   %eax,%eax
  801c63:	74 59                	je     801cbe <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  801c65:	80 38 00             	cmpb   $0x0,(%eax)
  801c68:	74 0c                	je     801c76 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801c6a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801c6d:	c7 43 08 81 34 80 00 	movl   $0x803481,0x8(%ebx)
  801c74:	eb 43                	jmp    801cb9 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  801c76:	8b 03                	mov    (%ebx),%eax
  801c78:	83 38 01             	cmpl   $0x1,(%eax)
  801c7b:	7e 2e                	jle    801cab <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  801c7d:	8b 53 04             	mov    0x4(%ebx),%edx
  801c80:	8b 4a 04             	mov    0x4(%edx),%ecx
  801c83:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801c86:	8b 00                	mov    (%eax),%eax
  801c88:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801c8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c93:	8d 42 08             	lea    0x8(%edx),%eax
  801c96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9a:	83 c2 04             	add    $0x4,%edx
  801c9d:	89 14 24             	mov    %edx,(%esp)
  801ca0:	e8 5b f6 ff ff       	call   801300 <memmove>
		(*args->argc)--;
  801ca5:	8b 03                	mov    (%ebx),%eax
  801ca7:	ff 08                	decl   (%eax)
  801ca9:	eb 0e                	jmp    801cb9 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  801cab:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801cb2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801cb9:	8b 43 0c             	mov    0xc(%ebx),%eax
  801cbc:	eb 05                	jmp    801cc3 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801cc3:	83 c4 14             	add    $0x14,%esp
  801cc6:	5b                   	pop    %ebx
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	83 ec 18             	sub    $0x18,%esp
  801ccf:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801cd2:	8b 42 0c             	mov    0xc(%edx),%eax
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	75 08                	jne    801ce1 <argvalue+0x18>
  801cd9:	89 14 24             	mov    %edx,(%esp)
  801cdc:	e8 73 ff ff ff       	call   801c54 <argnextvalue>
}
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    
	...

00801ce4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cea:	05 00 00 00 30       	add    $0x30000000,%eax
  801cef:	c1 e8 0c             	shr    $0xc,%eax
}
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    

00801cf4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfd:	89 04 24             	mov    %eax,(%esp)
  801d00:	e8 df ff ff ff       	call   801ce4 <fd2num>
  801d05:	05 20 00 0d 00       	add    $0xd0020,%eax
  801d0a:	c1 e0 0c             	shl    $0xc,%eax
}
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	53                   	push   %ebx
  801d13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801d16:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801d1b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801d1d:	89 c2                	mov    %eax,%edx
  801d1f:	c1 ea 16             	shr    $0x16,%edx
  801d22:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d29:	f6 c2 01             	test   $0x1,%dl
  801d2c:	74 11                	je     801d3f <fd_alloc+0x30>
  801d2e:	89 c2                	mov    %eax,%edx
  801d30:	c1 ea 0c             	shr    $0xc,%edx
  801d33:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d3a:	f6 c2 01             	test   $0x1,%dl
  801d3d:	75 09                	jne    801d48 <fd_alloc+0x39>
			*fd_store = fd;
  801d3f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801d41:	b8 00 00 00 00       	mov    $0x0,%eax
  801d46:	eb 17                	jmp    801d5f <fd_alloc+0x50>
  801d48:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801d4d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801d52:	75 c7                	jne    801d1b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801d54:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801d5a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801d5f:	5b                   	pop    %ebx
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801d68:	83 f8 1f             	cmp    $0x1f,%eax
  801d6b:	77 36                	ja     801da3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801d6d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801d72:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801d75:	89 c2                	mov    %eax,%edx
  801d77:	c1 ea 16             	shr    $0x16,%edx
  801d7a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d81:	f6 c2 01             	test   $0x1,%dl
  801d84:	74 24                	je     801daa <fd_lookup+0x48>
  801d86:	89 c2                	mov    %eax,%edx
  801d88:	c1 ea 0c             	shr    $0xc,%edx
  801d8b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d92:	f6 c2 01             	test   $0x1,%dl
  801d95:	74 1a                	je     801db1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9a:	89 02                	mov    %eax,(%edx)
	return 0;
  801d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801da1:	eb 13                	jmp    801db6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801da3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801da8:	eb 0c                	jmp    801db6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801daa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801daf:	eb 05                	jmp    801db6 <fd_lookup+0x54>
  801db1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    

00801db8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	53                   	push   %ebx
  801dbc:	83 ec 14             	sub    $0x14,%esp
  801dbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801dc5:	ba 00 00 00 00       	mov    $0x0,%edx
  801dca:	eb 0e                	jmp    801dda <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801dcc:	39 08                	cmp    %ecx,(%eax)
  801dce:	75 09                	jne    801dd9 <dev_lookup+0x21>
			*dev = devtab[i];
  801dd0:	89 03                	mov    %eax,(%ebx)
			return 0;
  801dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd7:	eb 33                	jmp    801e0c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801dd9:	42                   	inc    %edx
  801dda:	8b 04 95 68 3b 80 00 	mov    0x803b68(,%edx,4),%eax
  801de1:	85 c0                	test   %eax,%eax
  801de3:	75 e7                	jne    801dcc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801de5:	a1 24 54 80 00       	mov    0x805424,%eax
  801dea:	8b 40 48             	mov    0x48(%eax),%eax
  801ded:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801df1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df5:	c7 04 24 ec 3a 80 00 	movl   $0x803aec,(%esp)
  801dfc:	e8 fb ec ff ff       	call   800afc <cprintf>
	*dev = 0;
  801e01:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801e07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801e0c:	83 c4 14             	add    $0x14,%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	56                   	push   %esi
  801e16:	53                   	push   %ebx
  801e17:	83 ec 30             	sub    $0x30,%esp
  801e1a:	8b 75 08             	mov    0x8(%ebp),%esi
  801e1d:	8a 45 0c             	mov    0xc(%ebp),%al
  801e20:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801e23:	89 34 24             	mov    %esi,(%esp)
  801e26:	e8 b9 fe ff ff       	call   801ce4 <fd2num>
  801e2b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e32:	89 04 24             	mov    %eax,(%esp)
  801e35:	e8 28 ff ff ff       	call   801d62 <fd_lookup>
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 05                	js     801e45 <fd_close+0x33>
	    || fd != fd2)
  801e40:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801e43:	74 0d                	je     801e52 <fd_close+0x40>
		return (must_exist ? r : 0);
  801e45:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801e49:	75 46                	jne    801e91 <fd_close+0x7f>
  801e4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e50:	eb 3f                	jmp    801e91 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801e52:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e59:	8b 06                	mov    (%esi),%eax
  801e5b:	89 04 24             	mov    %eax,(%esp)
  801e5e:	e8 55 ff ff ff       	call   801db8 <dev_lookup>
  801e63:	89 c3                	mov    %eax,%ebx
  801e65:	85 c0                	test   %eax,%eax
  801e67:	78 18                	js     801e81 <fd_close+0x6f>
		if (dev->dev_close)
  801e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6c:	8b 40 10             	mov    0x10(%eax),%eax
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	74 09                	je     801e7c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801e73:	89 34 24             	mov    %esi,(%esp)
  801e76:	ff d0                	call   *%eax
  801e78:	89 c3                	mov    %eax,%ebx
  801e7a:	eb 05                	jmp    801e81 <fd_close+0x6f>
		else
			r = 0;
  801e7c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801e81:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e8c:	e8 8f f7 ff ff       	call   801620 <sys_page_unmap>
	return r;
}
  801e91:	89 d8                	mov    %ebx,%eax
  801e93:	83 c4 30             	add    $0x30,%esp
  801e96:	5b                   	pop    %ebx
  801e97:	5e                   	pop    %esi
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    

00801e9a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaa:	89 04 24             	mov    %eax,(%esp)
  801ead:	e8 b0 fe ff ff       	call   801d62 <fd_lookup>
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	78 13                	js     801ec9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801eb6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ebd:	00 
  801ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec1:	89 04 24             	mov    %eax,(%esp)
  801ec4:	e8 49 ff ff ff       	call   801e12 <fd_close>
}
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    

00801ecb <close_all>:

void
close_all(void)
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	53                   	push   %ebx
  801ecf:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801ed2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801ed7:	89 1c 24             	mov    %ebx,(%esp)
  801eda:	e8 bb ff ff ff       	call   801e9a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801edf:	43                   	inc    %ebx
  801ee0:	83 fb 20             	cmp    $0x20,%ebx
  801ee3:	75 f2                	jne    801ed7 <close_all+0xc>
		close(i);
}
  801ee5:	83 c4 14             	add    $0x14,%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    

00801eeb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	57                   	push   %edi
  801eef:	56                   	push   %esi
  801ef0:	53                   	push   %ebx
  801ef1:	83 ec 4c             	sub    $0x4c,%esp
  801ef4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ef7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801efa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efe:	8b 45 08             	mov    0x8(%ebp),%eax
  801f01:	89 04 24             	mov    %eax,(%esp)
  801f04:	e8 59 fe ff ff       	call   801d62 <fd_lookup>
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	0f 88 e1 00 00 00    	js     801ff4 <dup+0x109>
		return r;
	close(newfdnum);
  801f13:	89 3c 24             	mov    %edi,(%esp)
  801f16:	e8 7f ff ff ff       	call   801e9a <close>

	newfd = INDEX2FD(newfdnum);
  801f1b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801f21:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801f24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f27:	89 04 24             	mov    %eax,(%esp)
  801f2a:	e8 c5 fd ff ff       	call   801cf4 <fd2data>
  801f2f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801f31:	89 34 24             	mov    %esi,(%esp)
  801f34:	e8 bb fd ff ff       	call   801cf4 <fd2data>
  801f39:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801f3c:	89 d8                	mov    %ebx,%eax
  801f3e:	c1 e8 16             	shr    $0x16,%eax
  801f41:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f48:	a8 01                	test   $0x1,%al
  801f4a:	74 46                	je     801f92 <dup+0xa7>
  801f4c:	89 d8                	mov    %ebx,%eax
  801f4e:	c1 e8 0c             	shr    $0xc,%eax
  801f51:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801f58:	f6 c2 01             	test   $0x1,%dl
  801f5b:	74 35                	je     801f92 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801f5d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f64:	25 07 0e 00 00       	and    $0xe07,%eax
  801f69:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f6d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801f70:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f7b:	00 
  801f7c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f87:	e8 41 f6 ff ff       	call   8015cd <sys_page_map>
  801f8c:	89 c3                	mov    %eax,%ebx
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 3b                	js     801fcd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f95:	89 c2                	mov    %eax,%edx
  801f97:	c1 ea 0c             	shr    $0xc,%edx
  801f9a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801fa1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801fa7:	89 54 24 10          	mov    %edx,0x10(%esp)
  801fab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801faf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fb6:	00 
  801fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc2:	e8 06 f6 ff ff       	call   8015cd <sys_page_map>
  801fc7:	89 c3                	mov    %eax,%ebx
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	79 25                	jns    801ff2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801fcd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd8:	e8 43 f6 ff ff       	call   801620 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801fdd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801feb:	e8 30 f6 ff ff       	call   801620 <sys_page_unmap>
	return r;
  801ff0:	eb 02                	jmp    801ff4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801ff2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	83 c4 4c             	add    $0x4c,%esp
  801ff9:	5b                   	pop    %ebx
  801ffa:	5e                   	pop    %esi
  801ffb:	5f                   	pop    %edi
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    

00801ffe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	53                   	push   %ebx
  802002:	83 ec 24             	sub    $0x24,%esp
  802005:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802008:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80200b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200f:	89 1c 24             	mov    %ebx,(%esp)
  802012:	e8 4b fd ff ff       	call   801d62 <fd_lookup>
  802017:	85 c0                	test   %eax,%eax
  802019:	78 6d                	js     802088 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80201b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802022:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802025:	8b 00                	mov    (%eax),%eax
  802027:	89 04 24             	mov    %eax,(%esp)
  80202a:	e8 89 fd ff ff       	call   801db8 <dev_lookup>
  80202f:	85 c0                	test   %eax,%eax
  802031:	78 55                	js     802088 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802033:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802036:	8b 50 08             	mov    0x8(%eax),%edx
  802039:	83 e2 03             	and    $0x3,%edx
  80203c:	83 fa 01             	cmp    $0x1,%edx
  80203f:	75 23                	jne    802064 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802041:	a1 24 54 80 00       	mov    0x805424,%eax
  802046:	8b 40 48             	mov    0x48(%eax),%eax
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802051:	c7 04 24 2d 3b 80 00 	movl   $0x803b2d,(%esp)
  802058:	e8 9f ea ff ff       	call   800afc <cprintf>
		return -E_INVAL;
  80205d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802062:	eb 24                	jmp    802088 <read+0x8a>
	}
	if (!dev->dev_read)
  802064:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802067:	8b 52 08             	mov    0x8(%edx),%edx
  80206a:	85 d2                	test   %edx,%edx
  80206c:	74 15                	je     802083 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80206e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802071:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802075:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802078:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80207c:	89 04 24             	mov    %eax,(%esp)
  80207f:	ff d2                	call   *%edx
  802081:	eb 05                	jmp    802088 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802083:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  802088:	83 c4 24             	add    $0x24,%esp
  80208b:	5b                   	pop    %ebx
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    

0080208e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 7d 08             	mov    0x8(%ebp),%edi
  80209a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80209d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020a2:	eb 23                	jmp    8020c7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8020a4:	89 f0                	mov    %esi,%eax
  8020a6:	29 d8                	sub    %ebx,%eax
  8020a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020af:	01 d8                	add    %ebx,%eax
  8020b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b5:	89 3c 24             	mov    %edi,(%esp)
  8020b8:	e8 41 ff ff ff       	call   801ffe <read>
		if (m < 0)
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	78 10                	js     8020d1 <readn+0x43>
			return m;
		if (m == 0)
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	74 0a                	je     8020cf <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8020c5:	01 c3                	add    %eax,%ebx
  8020c7:	39 f3                	cmp    %esi,%ebx
  8020c9:	72 d9                	jb     8020a4 <readn+0x16>
  8020cb:	89 d8                	mov    %ebx,%eax
  8020cd:	eb 02                	jmp    8020d1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8020cf:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8020d1:	83 c4 1c             	add    $0x1c,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    

008020d9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8020d9:	55                   	push   %ebp
  8020da:	89 e5                	mov    %esp,%ebp
  8020dc:	53                   	push   %ebx
  8020dd:	83 ec 24             	sub    $0x24,%esp
  8020e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ea:	89 1c 24             	mov    %ebx,(%esp)
  8020ed:	e8 70 fc ff ff       	call   801d62 <fd_lookup>
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	78 68                	js     80215e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802100:	8b 00                	mov    (%eax),%eax
  802102:	89 04 24             	mov    %eax,(%esp)
  802105:	e8 ae fc ff ff       	call   801db8 <dev_lookup>
  80210a:	85 c0                	test   %eax,%eax
  80210c:	78 50                	js     80215e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80210e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802111:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802115:	75 23                	jne    80213a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802117:	a1 24 54 80 00       	mov    0x805424,%eax
  80211c:	8b 40 48             	mov    0x48(%eax),%eax
  80211f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802123:	89 44 24 04          	mov    %eax,0x4(%esp)
  802127:	c7 04 24 49 3b 80 00 	movl   $0x803b49,(%esp)
  80212e:	e8 c9 e9 ff ff       	call   800afc <cprintf>
		return -E_INVAL;
  802133:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802138:	eb 24                	jmp    80215e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80213a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80213d:	8b 52 0c             	mov    0xc(%edx),%edx
  802140:	85 d2                	test   %edx,%edx
  802142:	74 15                	je     802159 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802144:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802147:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80214b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80214e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802152:	89 04 24             	mov    %eax,(%esp)
  802155:	ff d2                	call   *%edx
  802157:	eb 05                	jmp    80215e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802159:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80215e:	83 c4 24             	add    $0x24,%esp
  802161:	5b                   	pop    %ebx
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    

00802164 <seek>:

int
seek(int fdnum, off_t offset)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80216a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80216d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802171:	8b 45 08             	mov    0x8(%ebp),%eax
  802174:	89 04 24             	mov    %eax,(%esp)
  802177:	e8 e6 fb ff ff       	call   801d62 <fd_lookup>
  80217c:	85 c0                	test   %eax,%eax
  80217e:	78 0e                	js     80218e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802180:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802183:	8b 55 0c             	mov    0xc(%ebp),%edx
  802186:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802189:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80218e:	c9                   	leave  
  80218f:	c3                   	ret    

00802190 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	53                   	push   %ebx
  802194:	83 ec 24             	sub    $0x24,%esp
  802197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80219a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80219d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a1:	89 1c 24             	mov    %ebx,(%esp)
  8021a4:	e8 b9 fb ff ff       	call   801d62 <fd_lookup>
  8021a9:	85 c0                	test   %eax,%eax
  8021ab:	78 61                	js     80220e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b7:	8b 00                	mov    (%eax),%eax
  8021b9:	89 04 24             	mov    %eax,(%esp)
  8021bc:	e8 f7 fb ff ff       	call   801db8 <dev_lookup>
  8021c1:	85 c0                	test   %eax,%eax
  8021c3:	78 49                	js     80220e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8021c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8021cc:	75 23                	jne    8021f1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8021ce:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8021d3:	8b 40 48             	mov    0x48(%eax),%eax
  8021d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021de:	c7 04 24 0c 3b 80 00 	movl   $0x803b0c,(%esp)
  8021e5:	e8 12 e9 ff ff       	call   800afc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8021ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8021ef:	eb 1d                	jmp    80220e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8021f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021f4:	8b 52 18             	mov    0x18(%edx),%edx
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	74 0e                	je     802209 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8021fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802202:	89 04 24             	mov    %eax,(%esp)
  802205:	ff d2                	call   *%edx
  802207:	eb 05                	jmp    80220e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802209:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80220e:	83 c4 24             	add    $0x24,%esp
  802211:	5b                   	pop    %ebx
  802212:	5d                   	pop    %ebp
  802213:	c3                   	ret    

00802214 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	53                   	push   %ebx
  802218:	83 ec 24             	sub    $0x24,%esp
  80221b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80221e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802221:	89 44 24 04          	mov    %eax,0x4(%esp)
  802225:	8b 45 08             	mov    0x8(%ebp),%eax
  802228:	89 04 24             	mov    %eax,(%esp)
  80222b:	e8 32 fb ff ff       	call   801d62 <fd_lookup>
  802230:	85 c0                	test   %eax,%eax
  802232:	78 52                	js     802286 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802234:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80223e:	8b 00                	mov    (%eax),%eax
  802240:	89 04 24             	mov    %eax,(%esp)
  802243:	e8 70 fb ff ff       	call   801db8 <dev_lookup>
  802248:	85 c0                	test   %eax,%eax
  80224a:	78 3a                	js     802286 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80224c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802253:	74 2c                	je     802281 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802255:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802258:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80225f:	00 00 00 
	stat->st_isdir = 0;
  802262:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802269:	00 00 00 
	stat->st_dev = dev;
  80226c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802272:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802276:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802279:	89 14 24             	mov    %edx,(%esp)
  80227c:	ff 50 14             	call   *0x14(%eax)
  80227f:	eb 05                	jmp    802286 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802281:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802286:	83 c4 24             	add    $0x24,%esp
  802289:	5b                   	pop    %ebx
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    

0080228c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	56                   	push   %esi
  802290:	53                   	push   %ebx
  802291:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802294:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80229b:	00 
  80229c:	8b 45 08             	mov    0x8(%ebp),%eax
  80229f:	89 04 24             	mov    %eax,(%esp)
  8022a2:	e8 fe 01 00 00       	call   8024a5 <open>
  8022a7:	89 c3                	mov    %eax,%ebx
  8022a9:	85 c0                	test   %eax,%eax
  8022ab:	78 1b                	js     8022c8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8022ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b4:	89 1c 24             	mov    %ebx,(%esp)
  8022b7:	e8 58 ff ff ff       	call   802214 <fstat>
  8022bc:	89 c6                	mov    %eax,%esi
	close(fd);
  8022be:	89 1c 24             	mov    %ebx,(%esp)
  8022c1:	e8 d4 fb ff ff       	call   801e9a <close>
	return r;
  8022c6:	89 f3                	mov    %esi,%ebx
}
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	83 c4 10             	add    $0x10,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    
  8022d1:	00 00                	add    %al,(%eax)
	...

008022d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8022d4:	55                   	push   %ebp
  8022d5:	89 e5                	mov    %esp,%ebp
  8022d7:	56                   	push   %esi
  8022d8:	53                   	push   %ebx
  8022d9:	83 ec 10             	sub    $0x10,%esp
  8022dc:	89 c3                	mov    %eax,%ebx
  8022de:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8022e0:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8022e7:	75 11                	jne    8022fa <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8022e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8022f0:	e8 7e 0e 00 00       	call   803173 <ipc_find_env>
  8022f5:	a3 20 54 80 00       	mov    %eax,0x805420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8022fa:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802301:	00 
  802302:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802309:	00 
  80230a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80230e:	a1 20 54 80 00       	mov    0x805420,%eax
  802313:	89 04 24             	mov    %eax,(%esp)
  802316:	e8 ee 0d 00 00       	call   803109 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80231b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802322:	00 
  802323:	89 74 24 04          	mov    %esi,0x4(%esp)
  802327:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80232e:	e8 6d 0d 00 00       	call   8030a0 <ipc_recv>
}
  802333:	83 c4 10             	add    $0x10,%esp
  802336:	5b                   	pop    %ebx
  802337:	5e                   	pop    %esi
  802338:	5d                   	pop    %ebp
  802339:	c3                   	ret    

0080233a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80233a:	55                   	push   %ebp
  80233b:	89 e5                	mov    %esp,%ebp
  80233d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802340:	8b 45 08             	mov    0x8(%ebp),%eax
  802343:	8b 40 0c             	mov    0xc(%eax),%eax
  802346:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80234b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80234e:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802353:	ba 00 00 00 00       	mov    $0x0,%edx
  802358:	b8 02 00 00 00       	mov    $0x2,%eax
  80235d:	e8 72 ff ff ff       	call   8022d4 <fsipc>
}
  802362:	c9                   	leave  
  802363:	c3                   	ret    

00802364 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802364:	55                   	push   %ebp
  802365:	89 e5                	mov    %esp,%ebp
  802367:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80236a:	8b 45 08             	mov    0x8(%ebp),%eax
  80236d:	8b 40 0c             	mov    0xc(%eax),%eax
  802370:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802375:	ba 00 00 00 00       	mov    $0x0,%edx
  80237a:	b8 06 00 00 00       	mov    $0x6,%eax
  80237f:	e8 50 ff ff ff       	call   8022d4 <fsipc>
}
  802384:	c9                   	leave  
  802385:	c3                   	ret    

00802386 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802386:	55                   	push   %ebp
  802387:	89 e5                	mov    %esp,%ebp
  802389:	53                   	push   %ebx
  80238a:	83 ec 14             	sub    $0x14,%esp
  80238d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802390:	8b 45 08             	mov    0x8(%ebp),%eax
  802393:	8b 40 0c             	mov    0xc(%eax),%eax
  802396:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80239b:	ba 00 00 00 00       	mov    $0x0,%edx
  8023a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8023a5:	e8 2a ff ff ff       	call   8022d4 <fsipc>
  8023aa:	85 c0                	test   %eax,%eax
  8023ac:	78 2b                	js     8023d9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8023ae:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8023b5:	00 
  8023b6:	89 1c 24             	mov    %ebx,(%esp)
  8023b9:	e8 c9 ed ff ff       	call   801187 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8023be:	a1 80 60 80 00       	mov    0x806080,%eax
  8023c3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8023c9:	a1 84 60 80 00       	mov    0x806084,%eax
  8023ce:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8023d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023d9:	83 c4 14             	add    $0x14,%esp
  8023dc:	5b                   	pop    %ebx
  8023dd:	5d                   	pop    %ebp
  8023de:	c3                   	ret    

008023df <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8023df:	55                   	push   %ebp
  8023e0:	89 e5                	mov    %esp,%ebp
  8023e2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8023e5:	c7 44 24 08 78 3b 80 	movl   $0x803b78,0x8(%esp)
  8023ec:	00 
  8023ed:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8023f4:	00 
  8023f5:	c7 04 24 96 3b 80 00 	movl   $0x803b96,(%esp)
  8023fc:	e8 03 e6 ff ff       	call   800a04 <_panic>

00802401 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802401:	55                   	push   %ebp
  802402:	89 e5                	mov    %esp,%ebp
  802404:	56                   	push   %esi
  802405:	53                   	push   %ebx
  802406:	83 ec 10             	sub    $0x10,%esp
  802409:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80240c:	8b 45 08             	mov    0x8(%ebp),%eax
  80240f:	8b 40 0c             	mov    0xc(%eax),%eax
  802412:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802417:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80241d:	ba 00 00 00 00       	mov    $0x0,%edx
  802422:	b8 03 00 00 00       	mov    $0x3,%eax
  802427:	e8 a8 fe ff ff       	call   8022d4 <fsipc>
  80242c:	89 c3                	mov    %eax,%ebx
  80242e:	85 c0                	test   %eax,%eax
  802430:	78 6a                	js     80249c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802432:	39 c6                	cmp    %eax,%esi
  802434:	73 24                	jae    80245a <devfile_read+0x59>
  802436:	c7 44 24 0c a1 3b 80 	movl   $0x803ba1,0xc(%esp)
  80243d:	00 
  80243e:	c7 44 24 08 bb 35 80 	movl   $0x8035bb,0x8(%esp)
  802445:	00 
  802446:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80244d:	00 
  80244e:	c7 04 24 96 3b 80 00 	movl   $0x803b96,(%esp)
  802455:	e8 aa e5 ff ff       	call   800a04 <_panic>
	assert(r <= PGSIZE);
  80245a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80245f:	7e 24                	jle    802485 <devfile_read+0x84>
  802461:	c7 44 24 0c a8 3b 80 	movl   $0x803ba8,0xc(%esp)
  802468:	00 
  802469:	c7 44 24 08 bb 35 80 	movl   $0x8035bb,0x8(%esp)
  802470:	00 
  802471:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  802478:	00 
  802479:	c7 04 24 96 3b 80 00 	movl   $0x803b96,(%esp)
  802480:	e8 7f e5 ff ff       	call   800a04 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802485:	89 44 24 08          	mov    %eax,0x8(%esp)
  802489:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802490:	00 
  802491:	8b 45 0c             	mov    0xc(%ebp),%eax
  802494:	89 04 24             	mov    %eax,(%esp)
  802497:	e8 64 ee ff ff       	call   801300 <memmove>
	return r;
}
  80249c:	89 d8                	mov    %ebx,%eax
  80249e:	83 c4 10             	add    $0x10,%esp
  8024a1:	5b                   	pop    %ebx
  8024a2:	5e                   	pop    %esi
  8024a3:	5d                   	pop    %ebp
  8024a4:	c3                   	ret    

008024a5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8024a5:	55                   	push   %ebp
  8024a6:	89 e5                	mov    %esp,%ebp
  8024a8:	56                   	push   %esi
  8024a9:	53                   	push   %ebx
  8024aa:	83 ec 20             	sub    $0x20,%esp
  8024ad:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8024b0:	89 34 24             	mov    %esi,(%esp)
  8024b3:	e8 9c ec ff ff       	call   801154 <strlen>
  8024b8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8024bd:	7f 60                	jg     80251f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8024bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024c2:	89 04 24             	mov    %eax,(%esp)
  8024c5:	e8 45 f8 ff ff       	call   801d0f <fd_alloc>
  8024ca:	89 c3                	mov    %eax,%ebx
  8024cc:	85 c0                	test   %eax,%eax
  8024ce:	78 54                	js     802524 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8024d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d4:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8024db:	e8 a7 ec ff ff       	call   801187 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8024e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024e3:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8024e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f0:	e8 df fd ff ff       	call   8022d4 <fsipc>
  8024f5:	89 c3                	mov    %eax,%ebx
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	79 15                	jns    802510 <open+0x6b>
		fd_close(fd, 0);
  8024fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802502:	00 
  802503:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802506:	89 04 24             	mov    %eax,(%esp)
  802509:	e8 04 f9 ff ff       	call   801e12 <fd_close>
		return r;
  80250e:	eb 14                	jmp    802524 <open+0x7f>
	}

	return fd2num(fd);
  802510:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802513:	89 04 24             	mov    %eax,(%esp)
  802516:	e8 c9 f7 ff ff       	call   801ce4 <fd2num>
  80251b:	89 c3                	mov    %eax,%ebx
  80251d:	eb 05                	jmp    802524 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80251f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802524:	89 d8                	mov    %ebx,%eax
  802526:	83 c4 20             	add    $0x20,%esp
  802529:	5b                   	pop    %ebx
  80252a:	5e                   	pop    %esi
  80252b:	5d                   	pop    %ebp
  80252c:	c3                   	ret    

0080252d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80252d:	55                   	push   %ebp
  80252e:	89 e5                	mov    %esp,%ebp
  802530:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802533:	ba 00 00 00 00       	mov    $0x0,%edx
  802538:	b8 08 00 00 00       	mov    $0x8,%eax
  80253d:	e8 92 fd ff ff       	call   8022d4 <fsipc>
}
  802542:	c9                   	leave  
  802543:	c3                   	ret    

00802544 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  802544:	55                   	push   %ebp
  802545:	89 e5                	mov    %esp,%ebp
  802547:	53                   	push   %ebx
  802548:	83 ec 14             	sub    $0x14,%esp
  80254b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80254d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802551:	7e 32                	jle    802585 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  802553:	8b 40 04             	mov    0x4(%eax),%eax
  802556:	89 44 24 08          	mov    %eax,0x8(%esp)
  80255a:	8d 43 10             	lea    0x10(%ebx),%eax
  80255d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802561:	8b 03                	mov    (%ebx),%eax
  802563:	89 04 24             	mov    %eax,(%esp)
  802566:	e8 6e fb ff ff       	call   8020d9 <write>
		if (result > 0)
  80256b:	85 c0                	test   %eax,%eax
  80256d:	7e 03                	jle    802572 <writebuf+0x2e>
			b->result += result;
  80256f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802572:	39 43 04             	cmp    %eax,0x4(%ebx)
  802575:	74 0e                	je     802585 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  802577:	89 c2                	mov    %eax,%edx
  802579:	85 c0                	test   %eax,%eax
  80257b:	7e 05                	jle    802582 <writebuf+0x3e>
  80257d:	ba 00 00 00 00       	mov    $0x0,%edx
  802582:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  802585:	83 c4 14             	add    $0x14,%esp
  802588:	5b                   	pop    %ebx
  802589:	5d                   	pop    %ebp
  80258a:	c3                   	ret    

0080258b <putch>:

static void
putch(int ch, void *thunk)
{
  80258b:	55                   	push   %ebp
  80258c:	89 e5                	mov    %esp,%ebp
  80258e:	53                   	push   %ebx
  80258f:	83 ec 04             	sub    $0x4,%esp
  802592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802595:	8b 43 04             	mov    0x4(%ebx),%eax
  802598:	8b 55 08             	mov    0x8(%ebp),%edx
  80259b:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80259f:	40                   	inc    %eax
  8025a0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8025a3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8025a8:	75 0e                	jne    8025b8 <putch+0x2d>
		writebuf(b);
  8025aa:	89 d8                	mov    %ebx,%eax
  8025ac:	e8 93 ff ff ff       	call   802544 <writebuf>
		b->idx = 0;
  8025b1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8025b8:	83 c4 04             	add    $0x4,%esp
  8025bb:	5b                   	pop    %ebx
  8025bc:	5d                   	pop    %ebp
  8025bd:	c3                   	ret    

008025be <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8025be:	55                   	push   %ebp
  8025bf:	89 e5                	mov    %esp,%ebp
  8025c1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8025c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ca:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8025d0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8025d7:	00 00 00 
	b.result = 0;
  8025da:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8025e1:	00 00 00 
	b.error = 1;
  8025e4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8025eb:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8025ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8025f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025fc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802602:	89 44 24 04          	mov    %eax,0x4(%esp)
  802606:	c7 04 24 8b 25 80 00 	movl   $0x80258b,(%esp)
  80260d:	e8 4c e6 ff ff       	call   800c5e <vprintfmt>
	if (b.idx > 0)
  802612:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802619:	7e 0b                	jle    802626 <vfprintf+0x68>
		writebuf(&b);
  80261b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802621:	e8 1e ff ff ff       	call   802544 <writebuf>

	return (b.result ? b.result : b.error);
  802626:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80262c:	85 c0                	test   %eax,%eax
  80262e:	75 06                	jne    802636 <vfprintf+0x78>
  802630:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  802636:	c9                   	leave  
  802637:	c3                   	ret    

00802638 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802638:	55                   	push   %ebp
  802639:	89 e5                	mov    %esp,%ebp
  80263b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80263e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802641:	89 44 24 08          	mov    %eax,0x8(%esp)
  802645:	8b 45 0c             	mov    0xc(%ebp),%eax
  802648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80264c:	8b 45 08             	mov    0x8(%ebp),%eax
  80264f:	89 04 24             	mov    %eax,(%esp)
  802652:	e8 67 ff ff ff       	call   8025be <vfprintf>
	va_end(ap);

	return cnt;
}
  802657:	c9                   	leave  
  802658:	c3                   	ret    

00802659 <printf>:

int
printf(const char *fmt, ...)
{
  802659:	55                   	push   %ebp
  80265a:	89 e5                	mov    %esp,%ebp
  80265c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80265f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802662:	89 44 24 08          	mov    %eax,0x8(%esp)
  802666:	8b 45 08             	mov    0x8(%ebp),%eax
  802669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80266d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802674:	e8 45 ff ff ff       	call   8025be <vfprintf>
	va_end(ap);

	return cnt;
}
  802679:	c9                   	leave  
  80267a:	c3                   	ret    
	...

0080267c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80267c:	55                   	push   %ebp
  80267d:	89 e5                	mov    %esp,%ebp
  80267f:	57                   	push   %edi
  802680:	56                   	push   %esi
  802681:	53                   	push   %ebx
  802682:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802688:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80268f:	00 
  802690:	8b 45 08             	mov    0x8(%ebp),%eax
  802693:	89 04 24             	mov    %eax,(%esp)
  802696:	e8 0a fe ff ff       	call   8024a5 <open>
  80269b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8026a1:	85 c0                	test   %eax,%eax
  8026a3:	0f 88 05 05 00 00    	js     802bae <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8026a9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8026b0:	00 
  8026b1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8026b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026bb:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026c1:	89 04 24             	mov    %eax,(%esp)
  8026c4:	e8 c5 f9 ff ff       	call   80208e <readn>
  8026c9:	3d 00 02 00 00       	cmp    $0x200,%eax
  8026ce:	75 0c                	jne    8026dc <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  8026d0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8026d7:	45 4c 46 
  8026da:	74 3b                	je     802717 <spawn+0x9b>
		close(fd);
  8026dc:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026e2:	89 04 24             	mov    %eax,(%esp)
  8026e5:	e8 b0 f7 ff ff       	call   801e9a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8026ea:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  8026f1:	46 
  8026f2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  8026f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026fc:	c7 04 24 b4 3b 80 00 	movl   $0x803bb4,(%esp)
  802703:	e8 f4 e3 ff ff       	call   800afc <cprintf>
		return -E_NOT_EXEC;
  802708:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  80270f:	ff ff ff 
  802712:	e9 a3 04 00 00       	jmp    802bba <spawn+0x53e>
  802717:	ba 07 00 00 00       	mov    $0x7,%edx
  80271c:	89 d0                	mov    %edx,%eax
  80271e:	cd 30                	int    $0x30
  802720:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802726:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80272c:	85 c0                	test   %eax,%eax
  80272e:	0f 88 86 04 00 00    	js     802bba <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802734:	25 ff 03 00 00       	and    $0x3ff,%eax
  802739:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802740:	c1 e0 07             	shl    $0x7,%eax
  802743:	29 d0                	sub    %edx,%eax
  802745:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  80274b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802751:	b9 11 00 00 00       	mov    $0x11,%ecx
  802756:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802758:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80275e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802764:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802769:	bb 00 00 00 00       	mov    $0x0,%ebx
  80276e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802771:	eb 0d                	jmp    802780 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802773:	89 04 24             	mov    %eax,(%esp)
  802776:	e8 d9 e9 ff ff       	call   801154 <strlen>
  80277b:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80277f:	46                   	inc    %esi
  802780:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802782:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802789:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  80278c:	85 c0                	test   %eax,%eax
  80278e:	75 e3                	jne    802773 <spawn+0xf7>
  802790:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802796:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80279c:	bf 00 10 40 00       	mov    $0x401000,%edi
  8027a1:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8027a3:	89 f8                	mov    %edi,%eax
  8027a5:	83 e0 fc             	and    $0xfffffffc,%eax
  8027a8:	f7 d2                	not    %edx
  8027aa:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8027ad:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8027b3:	89 d0                	mov    %edx,%eax
  8027b5:	83 e8 08             	sub    $0x8,%eax
  8027b8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8027bd:	0f 86 08 04 00 00    	jbe    802bcb <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027c3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8027ca:	00 
  8027cb:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8027d2:	00 
  8027d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027da:	e8 9a ed ff ff       	call   801579 <sys_page_alloc>
  8027df:	85 c0                	test   %eax,%eax
  8027e1:	0f 88 e9 03 00 00    	js     802bd0 <spawn+0x554>
  8027e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027ec:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8027f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8027f5:	eb 2e                	jmp    802825 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8027f7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8027fd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802803:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  802806:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80280d:	89 3c 24             	mov    %edi,(%esp)
  802810:	e8 72 e9 ff ff       	call   801187 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802815:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802818:	89 04 24             	mov    %eax,(%esp)
  80281b:	e8 34 e9 ff ff       	call   801154 <strlen>
  802820:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802824:	43                   	inc    %ebx
  802825:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80282b:	7c ca                	jl     8027f7 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80282d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802833:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802839:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802840:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802846:	74 24                	je     80286c <spawn+0x1f0>
  802848:	c7 44 24 0c 28 3c 80 	movl   $0x803c28,0xc(%esp)
  80284f:	00 
  802850:	c7 44 24 08 bb 35 80 	movl   $0x8035bb,0x8(%esp)
  802857:	00 
  802858:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  80285f:	00 
  802860:	c7 04 24 ce 3b 80 00 	movl   $0x803bce,(%esp)
  802867:	e8 98 e1 ff ff       	call   800a04 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80286c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802872:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802877:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80287d:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802880:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802886:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802889:	89 d0                	mov    %edx,%eax
  80288b:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802890:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802896:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80289d:	00 
  80289e:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8028a5:	ee 
  8028a6:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8028ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028b0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8028b7:	00 
  8028b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028bf:	e8 09 ed ff ff       	call   8015cd <sys_page_map>
  8028c4:	89 c3                	mov    %eax,%ebx
  8028c6:	85 c0                	test   %eax,%eax
  8028c8:	78 1a                	js     8028e4 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8028ca:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8028d1:	00 
  8028d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028d9:	e8 42 ed ff ff       	call   801620 <sys_page_unmap>
  8028de:	89 c3                	mov    %eax,%ebx
  8028e0:	85 c0                	test   %eax,%eax
  8028e2:	79 1f                	jns    802903 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8028e4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8028eb:	00 
  8028ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028f3:	e8 28 ed ff ff       	call   801620 <sys_page_unmap>
	return r;
  8028f8:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8028fe:	e9 b7 02 00 00       	jmp    802bba <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802903:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  802909:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  80290f:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802915:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80291c:	00 00 00 
  80291f:	e9 bb 01 00 00       	jmp    802adf <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  802924:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80292a:	83 38 01             	cmpl   $0x1,(%eax)
  80292d:	0f 85 9f 01 00 00    	jne    802ad2 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802933:	89 c2                	mov    %eax,%edx
  802935:	8b 40 18             	mov    0x18(%eax),%eax
  802938:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  80293b:	83 f8 01             	cmp    $0x1,%eax
  80293e:	19 c0                	sbb    %eax,%eax
  802940:	83 e0 fe             	and    $0xfffffffe,%eax
  802943:	83 c0 07             	add    $0x7,%eax
  802946:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80294c:	8b 52 04             	mov    0x4(%edx),%edx
  80294f:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802955:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80295b:	8b 40 10             	mov    0x10(%eax),%eax
  80295e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802964:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  80296a:	8b 52 14             	mov    0x14(%edx),%edx
  80296d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802973:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802979:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80297c:	89 f8                	mov    %edi,%eax
  80297e:	25 ff 0f 00 00       	and    $0xfff,%eax
  802983:	74 16                	je     80299b <spawn+0x31f>
		va -= i;
  802985:	29 c7                	sub    %eax,%edi
		memsz += i;
  802987:	01 c2                	add    %eax,%edx
  802989:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  80298f:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802995:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80299b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029a0:	e9 1f 01 00 00       	jmp    802ac4 <spawn+0x448>
		if (i >= filesz) {
  8029a5:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8029ab:	77 2b                	ja     8029d8 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8029ad:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8029b3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8029b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8029bb:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8029c1:	89 04 24             	mov    %eax,(%esp)
  8029c4:	e8 b0 eb ff ff       	call   801579 <sys_page_alloc>
  8029c9:	85 c0                	test   %eax,%eax
  8029cb:	0f 89 e7 00 00 00    	jns    802ab8 <spawn+0x43c>
  8029d1:	89 c6                	mov    %eax,%esi
  8029d3:	e9 b2 01 00 00       	jmp    802b8a <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8029d8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8029df:	00 
  8029e0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8029e7:	00 
  8029e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029ef:	e8 85 eb ff ff       	call   801579 <sys_page_alloc>
  8029f4:	85 c0                	test   %eax,%eax
  8029f6:	0f 88 84 01 00 00    	js     802b80 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8029fc:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802a02:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a08:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802a0e:	89 04 24             	mov    %eax,(%esp)
  802a11:	e8 4e f7 ff ff       	call   802164 <seek>
  802a16:	85 c0                	test   %eax,%eax
  802a18:	0f 88 66 01 00 00    	js     802b84 <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802a1e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802a24:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a26:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802a2b:	76 05                	jbe    802a32 <spawn+0x3b6>
  802a2d:	b8 00 10 00 00       	mov    $0x1000,%eax
  802a32:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a36:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802a3d:	00 
  802a3e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802a44:	89 04 24             	mov    %eax,(%esp)
  802a47:	e8 42 f6 ff ff       	call   80208e <readn>
  802a4c:	85 c0                	test   %eax,%eax
  802a4e:	0f 88 34 01 00 00    	js     802b88 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802a54:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802a5a:	89 54 24 10          	mov    %edx,0x10(%esp)
  802a5e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a62:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802a68:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a6c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802a73:	00 
  802a74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a7b:	e8 4d eb ff ff       	call   8015cd <sys_page_map>
  802a80:	85 c0                	test   %eax,%eax
  802a82:	79 20                	jns    802aa4 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  802a84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a88:	c7 44 24 08 da 3b 80 	movl   $0x803bda,0x8(%esp)
  802a8f:	00 
  802a90:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  802a97:	00 
  802a98:	c7 04 24 ce 3b 80 00 	movl   $0x803bce,(%esp)
  802a9f:	e8 60 df ff ff       	call   800a04 <_panic>
			sys_page_unmap(0, UTEMP);
  802aa4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802aab:	00 
  802aac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ab3:	e8 68 eb ff ff       	call   801620 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802ab8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802abe:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802ac4:	89 de                	mov    %ebx,%esi
  802ac6:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  802acc:	0f 87 d3 fe ff ff    	ja     8029a5 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802ad2:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802ad8:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802adf:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802ae6:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  802aec:	0f 8c 32 fe ff ff    	jl     802924 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802af2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802af8:	89 04 24             	mov    %eax,(%esp)
  802afb:	e8 9a f3 ff ff       	call   801e9a <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802b00:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802b07:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802b0a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802b10:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b14:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802b1a:	89 04 24             	mov    %eax,(%esp)
  802b1d:	e8 a4 eb ff ff       	call   8016c6 <sys_env_set_trapframe>
  802b22:	85 c0                	test   %eax,%eax
  802b24:	79 20                	jns    802b46 <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  802b26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b2a:	c7 44 24 08 f7 3b 80 	movl   $0x803bf7,0x8(%esp)
  802b31:	00 
  802b32:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  802b39:	00 
  802b3a:	c7 04 24 ce 3b 80 00 	movl   $0x803bce,(%esp)
  802b41:	e8 be de ff ff       	call   800a04 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802b46:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802b4d:	00 
  802b4e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802b54:	89 04 24             	mov    %eax,(%esp)
  802b57:	e8 17 eb ff ff       	call   801673 <sys_env_set_status>
  802b5c:	85 c0                	test   %eax,%eax
  802b5e:	79 5a                	jns    802bba <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  802b60:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b64:	c7 44 24 08 11 3c 80 	movl   $0x803c11,0x8(%esp)
  802b6b:	00 
  802b6c:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  802b73:	00 
  802b74:	c7 04 24 ce 3b 80 00 	movl   $0x803bce,(%esp)
  802b7b:	e8 84 de ff ff       	call   800a04 <_panic>
  802b80:	89 c6                	mov    %eax,%esi
  802b82:	eb 06                	jmp    802b8a <spawn+0x50e>
  802b84:	89 c6                	mov    %eax,%esi
  802b86:	eb 02                	jmp    802b8a <spawn+0x50e>
  802b88:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802b8a:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802b90:	89 04 24             	mov    %eax,(%esp)
  802b93:	e8 51 e9 ff ff       	call   8014e9 <sys_env_destroy>
	close(fd);
  802b98:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b9e:	89 04 24             	mov    %eax,(%esp)
  802ba1:	e8 f4 f2 ff ff       	call   801e9a <close>
	return r;
  802ba6:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  802bac:	eb 0c                	jmp    802bba <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802bae:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802bb4:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802bba:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802bc0:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802bc6:	5b                   	pop    %ebx
  802bc7:	5e                   	pop    %esi
  802bc8:	5f                   	pop    %edi
  802bc9:	5d                   	pop    %ebp
  802bca:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802bcb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802bd0:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802bd6:	eb e2                	jmp    802bba <spawn+0x53e>

00802bd8 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802bd8:	55                   	push   %ebp
  802bd9:	89 e5                	mov    %esp,%ebp
  802bdb:	57                   	push   %edi
  802bdc:	56                   	push   %esi
  802bdd:	53                   	push   %ebx
  802bde:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802be1:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802be4:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802be9:	eb 03                	jmp    802bee <spawnl+0x16>
		argc++;
  802beb:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802bec:	89 d0                	mov    %edx,%eax
  802bee:	8d 50 04             	lea    0x4(%eax),%edx
  802bf1:	83 38 00             	cmpl   $0x0,(%eax)
  802bf4:	75 f5                	jne    802beb <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802bf6:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802bfd:	83 e0 f0             	and    $0xfffffff0,%eax
  802c00:	29 c4                	sub    %eax,%esp
  802c02:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802c06:	83 e7 f0             	and    $0xfffffff0,%edi
  802c09:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c0e:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802c10:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802c17:	00 

	va_start(vl, arg0);
  802c18:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  802c20:	eb 09                	jmp    802c2b <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802c22:	40                   	inc    %eax
  802c23:	8b 1a                	mov    (%edx),%ebx
  802c25:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802c28:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802c2b:	39 c8                	cmp    %ecx,%eax
  802c2d:	75 f3                	jne    802c22 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802c2f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c33:	8b 45 08             	mov    0x8(%ebp),%eax
  802c36:	89 04 24             	mov    %eax,(%esp)
  802c39:	e8 3e fa ff ff       	call   80267c <spawn>
}
  802c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c41:	5b                   	pop    %ebx
  802c42:	5e                   	pop    %esi
  802c43:	5f                   	pop    %edi
  802c44:	5d                   	pop    %ebp
  802c45:	c3                   	ret    
	...

00802c48 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802c48:	55                   	push   %ebp
  802c49:	89 e5                	mov    %esp,%ebp
  802c4b:	56                   	push   %esi
  802c4c:	53                   	push   %ebx
  802c4d:	83 ec 10             	sub    $0x10,%esp
  802c50:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802c53:	8b 45 08             	mov    0x8(%ebp),%eax
  802c56:	89 04 24             	mov    %eax,(%esp)
  802c59:	e8 96 f0 ff ff       	call   801cf4 <fd2data>
  802c5e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802c60:	c7 44 24 04 50 3c 80 	movl   $0x803c50,0x4(%esp)
  802c67:	00 
  802c68:	89 34 24             	mov    %esi,(%esp)
  802c6b:	e8 17 e5 ff ff       	call   801187 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802c70:	8b 43 04             	mov    0x4(%ebx),%eax
  802c73:	2b 03                	sub    (%ebx),%eax
  802c75:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802c7b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802c82:	00 00 00 
	stat->st_dev = &devpipe;
  802c85:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802c8c:	40 80 00 
	return 0;
}
  802c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  802c94:	83 c4 10             	add    $0x10,%esp
  802c97:	5b                   	pop    %ebx
  802c98:	5e                   	pop    %esi
  802c99:	5d                   	pop    %ebp
  802c9a:	c3                   	ret    

00802c9b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802c9b:	55                   	push   %ebp
  802c9c:	89 e5                	mov    %esp,%ebp
  802c9e:	53                   	push   %ebx
  802c9f:	83 ec 14             	sub    $0x14,%esp
  802ca2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802ca5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802ca9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cb0:	e8 6b e9 ff ff       	call   801620 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802cb5:	89 1c 24             	mov    %ebx,(%esp)
  802cb8:	e8 37 f0 ff ff       	call   801cf4 <fd2data>
  802cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cc8:	e8 53 e9 ff ff       	call   801620 <sys_page_unmap>
}
  802ccd:	83 c4 14             	add    $0x14,%esp
  802cd0:	5b                   	pop    %ebx
  802cd1:	5d                   	pop    %ebp
  802cd2:	c3                   	ret    

00802cd3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802cd3:	55                   	push   %ebp
  802cd4:	89 e5                	mov    %esp,%ebp
  802cd6:	57                   	push   %edi
  802cd7:	56                   	push   %esi
  802cd8:	53                   	push   %ebx
  802cd9:	83 ec 2c             	sub    $0x2c,%esp
  802cdc:	89 c7                	mov    %eax,%edi
  802cde:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802ce1:	a1 24 54 80 00       	mov    0x805424,%eax
  802ce6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802ce9:	89 3c 24             	mov    %edi,(%esp)
  802cec:	e8 c7 04 00 00       	call   8031b8 <pageref>
  802cf1:	89 c6                	mov    %eax,%esi
  802cf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802cf6:	89 04 24             	mov    %eax,(%esp)
  802cf9:	e8 ba 04 00 00       	call   8031b8 <pageref>
  802cfe:	39 c6                	cmp    %eax,%esi
  802d00:	0f 94 c0             	sete   %al
  802d03:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802d06:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802d0c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802d0f:	39 cb                	cmp    %ecx,%ebx
  802d11:	75 08                	jne    802d1b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802d13:	83 c4 2c             	add    $0x2c,%esp
  802d16:	5b                   	pop    %ebx
  802d17:	5e                   	pop    %esi
  802d18:	5f                   	pop    %edi
  802d19:	5d                   	pop    %ebp
  802d1a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802d1b:	83 f8 01             	cmp    $0x1,%eax
  802d1e:	75 c1                	jne    802ce1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802d20:	8b 42 58             	mov    0x58(%edx),%eax
  802d23:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802d2a:	00 
  802d2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  802d2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802d33:	c7 04 24 57 3c 80 00 	movl   $0x803c57,(%esp)
  802d3a:	e8 bd dd ff ff       	call   800afc <cprintf>
  802d3f:	eb a0                	jmp    802ce1 <_pipeisclosed+0xe>

00802d41 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802d41:	55                   	push   %ebp
  802d42:	89 e5                	mov    %esp,%ebp
  802d44:	57                   	push   %edi
  802d45:	56                   	push   %esi
  802d46:	53                   	push   %ebx
  802d47:	83 ec 1c             	sub    $0x1c,%esp
  802d4a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802d4d:	89 34 24             	mov    %esi,(%esp)
  802d50:	e8 9f ef ff ff       	call   801cf4 <fd2data>
  802d55:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802d57:	bf 00 00 00 00       	mov    $0x0,%edi
  802d5c:	eb 3c                	jmp    802d9a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802d5e:	89 da                	mov    %ebx,%edx
  802d60:	89 f0                	mov    %esi,%eax
  802d62:	e8 6c ff ff ff       	call   802cd3 <_pipeisclosed>
  802d67:	85 c0                	test   %eax,%eax
  802d69:	75 38                	jne    802da3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802d6b:	e8 ea e7 ff ff       	call   80155a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802d70:	8b 43 04             	mov    0x4(%ebx),%eax
  802d73:	8b 13                	mov    (%ebx),%edx
  802d75:	83 c2 20             	add    $0x20,%edx
  802d78:	39 d0                	cmp    %edx,%eax
  802d7a:	73 e2                	jae    802d5e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d7f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802d82:	89 c2                	mov    %eax,%edx
  802d84:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802d8a:	79 05                	jns    802d91 <devpipe_write+0x50>
  802d8c:	4a                   	dec    %edx
  802d8d:	83 ca e0             	or     $0xffffffe0,%edx
  802d90:	42                   	inc    %edx
  802d91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802d95:	40                   	inc    %eax
  802d96:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802d99:	47                   	inc    %edi
  802d9a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802d9d:	75 d1                	jne    802d70 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802d9f:	89 f8                	mov    %edi,%eax
  802da1:	eb 05                	jmp    802da8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802da3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802da8:	83 c4 1c             	add    $0x1c,%esp
  802dab:	5b                   	pop    %ebx
  802dac:	5e                   	pop    %esi
  802dad:	5f                   	pop    %edi
  802dae:	5d                   	pop    %ebp
  802daf:	c3                   	ret    

00802db0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802db0:	55                   	push   %ebp
  802db1:	89 e5                	mov    %esp,%ebp
  802db3:	57                   	push   %edi
  802db4:	56                   	push   %esi
  802db5:	53                   	push   %ebx
  802db6:	83 ec 1c             	sub    $0x1c,%esp
  802db9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802dbc:	89 3c 24             	mov    %edi,(%esp)
  802dbf:	e8 30 ef ff ff       	call   801cf4 <fd2data>
  802dc4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802dc6:	be 00 00 00 00       	mov    $0x0,%esi
  802dcb:	eb 3a                	jmp    802e07 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802dcd:	85 f6                	test   %esi,%esi
  802dcf:	74 04                	je     802dd5 <devpipe_read+0x25>
				return i;
  802dd1:	89 f0                	mov    %esi,%eax
  802dd3:	eb 40                	jmp    802e15 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802dd5:	89 da                	mov    %ebx,%edx
  802dd7:	89 f8                	mov    %edi,%eax
  802dd9:	e8 f5 fe ff ff       	call   802cd3 <_pipeisclosed>
  802dde:	85 c0                	test   %eax,%eax
  802de0:	75 2e                	jne    802e10 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802de2:	e8 73 e7 ff ff       	call   80155a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802de7:	8b 03                	mov    (%ebx),%eax
  802de9:	3b 43 04             	cmp    0x4(%ebx),%eax
  802dec:	74 df                	je     802dcd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802dee:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802df3:	79 05                	jns    802dfa <devpipe_read+0x4a>
  802df5:	48                   	dec    %eax
  802df6:	83 c8 e0             	or     $0xffffffe0,%eax
  802df9:	40                   	inc    %eax
  802dfa:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802dfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e01:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802e04:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e06:	46                   	inc    %esi
  802e07:	3b 75 10             	cmp    0x10(%ebp),%esi
  802e0a:	75 db                	jne    802de7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802e0c:	89 f0                	mov    %esi,%eax
  802e0e:	eb 05                	jmp    802e15 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802e10:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802e15:	83 c4 1c             	add    $0x1c,%esp
  802e18:	5b                   	pop    %ebx
  802e19:	5e                   	pop    %esi
  802e1a:	5f                   	pop    %edi
  802e1b:	5d                   	pop    %ebp
  802e1c:	c3                   	ret    

00802e1d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802e1d:	55                   	push   %ebp
  802e1e:	89 e5                	mov    %esp,%ebp
  802e20:	57                   	push   %edi
  802e21:	56                   	push   %esi
  802e22:	53                   	push   %ebx
  802e23:	83 ec 3c             	sub    $0x3c,%esp
  802e26:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802e29:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802e2c:	89 04 24             	mov    %eax,(%esp)
  802e2f:	e8 db ee ff ff       	call   801d0f <fd_alloc>
  802e34:	89 c3                	mov    %eax,%ebx
  802e36:	85 c0                	test   %eax,%eax
  802e38:	0f 88 45 01 00 00    	js     802f83 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802e3e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802e45:	00 
  802e46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802e49:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e54:	e8 20 e7 ff ff       	call   801579 <sys_page_alloc>
  802e59:	89 c3                	mov    %eax,%ebx
  802e5b:	85 c0                	test   %eax,%eax
  802e5d:	0f 88 20 01 00 00    	js     802f83 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802e63:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802e66:	89 04 24             	mov    %eax,(%esp)
  802e69:	e8 a1 ee ff ff       	call   801d0f <fd_alloc>
  802e6e:	89 c3                	mov    %eax,%ebx
  802e70:	85 c0                	test   %eax,%eax
  802e72:	0f 88 f8 00 00 00    	js     802f70 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802e78:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802e7f:	00 
  802e80:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e8e:	e8 e6 e6 ff ff       	call   801579 <sys_page_alloc>
  802e93:	89 c3                	mov    %eax,%ebx
  802e95:	85 c0                	test   %eax,%eax
  802e97:	0f 88 d3 00 00 00    	js     802f70 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802e9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ea0:	89 04 24             	mov    %eax,(%esp)
  802ea3:	e8 4c ee ff ff       	call   801cf4 <fd2data>
  802ea8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802eaa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802eb1:	00 
  802eb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  802eb6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ebd:	e8 b7 e6 ff ff       	call   801579 <sys_page_alloc>
  802ec2:	89 c3                	mov    %eax,%ebx
  802ec4:	85 c0                	test   %eax,%eax
  802ec6:	0f 88 91 00 00 00    	js     802f5d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ecc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802ecf:	89 04 24             	mov    %eax,(%esp)
  802ed2:	e8 1d ee ff ff       	call   801cf4 <fd2data>
  802ed7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802ede:	00 
  802edf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ee3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802eea:	00 
  802eeb:	89 74 24 04          	mov    %esi,0x4(%esp)
  802eef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ef6:	e8 d2 e6 ff ff       	call   8015cd <sys_page_map>
  802efb:	89 c3                	mov    %eax,%ebx
  802efd:	85 c0                	test   %eax,%eax
  802eff:	78 4c                	js     802f4d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802f01:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802f07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f0a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802f0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f0f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802f16:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f1f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802f21:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f24:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802f2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f2e:	89 04 24             	mov    %eax,(%esp)
  802f31:	e8 ae ed ff ff       	call   801ce4 <fd2num>
  802f36:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802f38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f3b:	89 04 24             	mov    %eax,(%esp)
  802f3e:	e8 a1 ed ff ff       	call   801ce4 <fd2num>
  802f43:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802f46:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f4b:	eb 36                	jmp    802f83 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802f4d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802f51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f58:	e8 c3 e6 ff ff       	call   801620 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802f5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f60:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f6b:	e8 b0 e6 ff ff       	call   801620 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802f70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f73:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f7e:	e8 9d e6 ff ff       	call   801620 <sys_page_unmap>
    err:
	return r;
}
  802f83:	89 d8                	mov    %ebx,%eax
  802f85:	83 c4 3c             	add    $0x3c,%esp
  802f88:	5b                   	pop    %ebx
  802f89:	5e                   	pop    %esi
  802f8a:	5f                   	pop    %edi
  802f8b:	5d                   	pop    %ebp
  802f8c:	c3                   	ret    

00802f8d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802f8d:	55                   	push   %ebp
  802f8e:	89 e5                	mov    %esp,%ebp
  802f90:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802f93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f96:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  802f9d:	89 04 24             	mov    %eax,(%esp)
  802fa0:	e8 bd ed ff ff       	call   801d62 <fd_lookup>
  802fa5:	85 c0                	test   %eax,%eax
  802fa7:	78 15                	js     802fbe <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fac:	89 04 24             	mov    %eax,(%esp)
  802faf:	e8 40 ed ff ff       	call   801cf4 <fd2data>
	return _pipeisclosed(fd, p);
  802fb4:	89 c2                	mov    %eax,%edx
  802fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fb9:	e8 15 fd ff ff       	call   802cd3 <_pipeisclosed>
}
  802fbe:	c9                   	leave  
  802fbf:	c3                   	ret    

00802fc0 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802fc0:	55                   	push   %ebp
  802fc1:	89 e5                	mov    %esp,%ebp
  802fc3:	56                   	push   %esi
  802fc4:	53                   	push   %ebx
  802fc5:	83 ec 10             	sub    $0x10,%esp
  802fc8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802fcb:	85 f6                	test   %esi,%esi
  802fcd:	75 24                	jne    802ff3 <wait+0x33>
  802fcf:	c7 44 24 0c 6f 3c 80 	movl   $0x803c6f,0xc(%esp)
  802fd6:	00 
  802fd7:	c7 44 24 08 bb 35 80 	movl   $0x8035bb,0x8(%esp)
  802fde:	00 
  802fdf:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802fe6:	00 
  802fe7:	c7 04 24 7a 3c 80 00 	movl   $0x803c7a,(%esp)
  802fee:	e8 11 da ff ff       	call   800a04 <_panic>
	e = &envs[ENVX(envid)];
  802ff3:	89 f3                	mov    %esi,%ebx
  802ff5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802ffb:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  803002:	c1 e3 07             	shl    $0x7,%ebx
  803005:	29 c3                	sub    %eax,%ebx
  803007:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80300d:	eb 05                	jmp    803014 <wait+0x54>
		sys_yield();
  80300f:	e8 46 e5 ff ff       	call   80155a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803014:	8b 43 48             	mov    0x48(%ebx),%eax
  803017:	39 f0                	cmp    %esi,%eax
  803019:	75 07                	jne    803022 <wait+0x62>
  80301b:	8b 43 54             	mov    0x54(%ebx),%eax
  80301e:	85 c0                	test   %eax,%eax
  803020:	75 ed                	jne    80300f <wait+0x4f>
		sys_yield();
}
  803022:	83 c4 10             	add    $0x10,%esp
  803025:	5b                   	pop    %ebx
  803026:	5e                   	pop    %esi
  803027:	5d                   	pop    %ebp
  803028:	c3                   	ret    
  803029:	00 00                	add    %al,(%eax)
	...

0080302c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80302c:	55                   	push   %ebp
  80302d:	89 e5                	mov    %esp,%ebp
  80302f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  803032:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  803039:	75 32                	jne    80306d <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80303b:	e8 fb e4 ff ff       	call   80153b <sys_getenvid>
  803040:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  803047:	00 
  803048:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80304f:	ee 
  803050:	89 04 24             	mov    %eax,(%esp)
  803053:	e8 21 e5 ff ff       	call   801579 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  803058:	e8 de e4 ff ff       	call   80153b <sys_getenvid>
  80305d:	c7 44 24 04 78 30 80 	movl   $0x803078,0x4(%esp)
  803064:	00 
  803065:	89 04 24             	mov    %eax,(%esp)
  803068:	e8 ac e6 ff ff       	call   801719 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80306d:	8b 45 08             	mov    0x8(%ebp),%eax
  803070:	a3 00 70 80 00       	mov    %eax,0x807000
}
  803075:	c9                   	leave  
  803076:	c3                   	ret    
	...

00803078 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  803078:	54                   	push   %esp
	movl _pgfault_handler, %eax
  803079:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80307e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803080:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  803083:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  803087:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  80308a:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  80308f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  803093:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  803096:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  803097:	83 c4 04             	add    $0x4,%esp
	popfl
  80309a:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  80309b:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  80309c:	c3                   	ret    
  80309d:	00 00                	add    %al,(%eax)
	...

008030a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8030a0:	55                   	push   %ebp
  8030a1:	89 e5                	mov    %esp,%ebp
  8030a3:	57                   	push   %edi
  8030a4:	56                   	push   %esi
  8030a5:	53                   	push   %ebx
  8030a6:	83 ec 1c             	sub    $0x1c,%esp
  8030a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8030ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8030af:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  8030b2:	85 db                	test   %ebx,%ebx
  8030b4:	75 05                	jne    8030bb <ipc_recv+0x1b>
		pg = (void *)UTOP;
  8030b6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8030bb:	89 1c 24             	mov    %ebx,(%esp)
  8030be:	e8 cc e6 ff ff       	call   80178f <sys_ipc_recv>
  8030c3:	85 c0                	test   %eax,%eax
  8030c5:	79 16                	jns    8030dd <ipc_recv+0x3d>
		*from_env_store = 0;
  8030c7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  8030cd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  8030d3:	89 1c 24             	mov    %ebx,(%esp)
  8030d6:	e8 b4 e6 ff ff       	call   80178f <sys_ipc_recv>
  8030db:	eb 24                	jmp    803101 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  8030dd:	85 f6                	test   %esi,%esi
  8030df:	74 0a                	je     8030eb <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8030e1:	a1 24 54 80 00       	mov    0x805424,%eax
  8030e6:	8b 40 74             	mov    0x74(%eax),%eax
  8030e9:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8030eb:	85 ff                	test   %edi,%edi
  8030ed:	74 0a                	je     8030f9 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8030ef:	a1 24 54 80 00       	mov    0x805424,%eax
  8030f4:	8b 40 78             	mov    0x78(%eax),%eax
  8030f7:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  8030f9:	a1 24 54 80 00       	mov    0x805424,%eax
  8030fe:	8b 40 70             	mov    0x70(%eax),%eax
}
  803101:	83 c4 1c             	add    $0x1c,%esp
  803104:	5b                   	pop    %ebx
  803105:	5e                   	pop    %esi
  803106:	5f                   	pop    %edi
  803107:	5d                   	pop    %ebp
  803108:	c3                   	ret    

00803109 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803109:	55                   	push   %ebp
  80310a:	89 e5                	mov    %esp,%ebp
  80310c:	57                   	push   %edi
  80310d:	56                   	push   %esi
  80310e:	53                   	push   %ebx
  80310f:	83 ec 1c             	sub    $0x1c,%esp
  803112:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803115:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803118:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  80311b:	85 db                	test   %ebx,%ebx
  80311d:	75 05                	jne    803124 <ipc_send+0x1b>
		pg = (void *)-1;
  80311f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  803124:	89 74 24 0c          	mov    %esi,0xc(%esp)
  803128:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80312c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  803130:	8b 45 08             	mov    0x8(%ebp),%eax
  803133:	89 04 24             	mov    %eax,(%esp)
  803136:	e8 31 e6 ff ff       	call   80176c <sys_ipc_try_send>
		if (r == 0) {		
  80313b:	85 c0                	test   %eax,%eax
  80313d:	74 2c                	je     80316b <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80313f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803142:	75 07                	jne    80314b <ipc_send+0x42>
			sys_yield();
  803144:	e8 11 e4 ff ff       	call   80155a <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  803149:	eb d9                	jmp    803124 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  80314b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80314f:	c7 44 24 08 85 3c 80 	movl   $0x803c85,0x8(%esp)
  803156:	00 
  803157:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80315e:	00 
  80315f:	c7 04 24 93 3c 80 00 	movl   $0x803c93,(%esp)
  803166:	e8 99 d8 ff ff       	call   800a04 <_panic>
		}
	}
}
  80316b:	83 c4 1c             	add    $0x1c,%esp
  80316e:	5b                   	pop    %ebx
  80316f:	5e                   	pop    %esi
  803170:	5f                   	pop    %edi
  803171:	5d                   	pop    %ebp
  803172:	c3                   	ret    

00803173 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803173:	55                   	push   %ebp
  803174:	89 e5                	mov    %esp,%ebp
  803176:	53                   	push   %ebx
  803177:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80317a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80317f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  803186:	89 c2                	mov    %eax,%edx
  803188:	c1 e2 07             	shl    $0x7,%edx
  80318b:	29 ca                	sub    %ecx,%edx
  80318d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803193:	8b 52 50             	mov    0x50(%edx),%edx
  803196:	39 da                	cmp    %ebx,%edx
  803198:	75 0f                	jne    8031a9 <ipc_find_env+0x36>
			return envs[i].env_id;
  80319a:	c1 e0 07             	shl    $0x7,%eax
  80319d:	29 c8                	sub    %ecx,%eax
  80319f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8031a4:	8b 40 40             	mov    0x40(%eax),%eax
  8031a7:	eb 0c                	jmp    8031b5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8031a9:	40                   	inc    %eax
  8031aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8031af:	75 ce                	jne    80317f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8031b1:	66 b8 00 00          	mov    $0x0,%ax
}
  8031b5:	5b                   	pop    %ebx
  8031b6:	5d                   	pop    %ebp
  8031b7:	c3                   	ret    

008031b8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8031b8:	55                   	push   %ebp
  8031b9:	89 e5                	mov    %esp,%ebp
  8031bb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8031be:	89 c2                	mov    %eax,%edx
  8031c0:	c1 ea 16             	shr    $0x16,%edx
  8031c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8031ca:	f6 c2 01             	test   $0x1,%dl
  8031cd:	74 1e                	je     8031ed <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8031cf:	c1 e8 0c             	shr    $0xc,%eax
  8031d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8031d9:	a8 01                	test   $0x1,%al
  8031db:	74 17                	je     8031f4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8031dd:	c1 e8 0c             	shr    $0xc,%eax
  8031e0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8031e7:	ef 
  8031e8:	0f b7 c0             	movzwl %ax,%eax
  8031eb:	eb 0c                	jmp    8031f9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8031ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8031f2:	eb 05                	jmp    8031f9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8031f4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8031f9:	5d                   	pop    %ebp
  8031fa:	c3                   	ret    
	...

008031fc <__udivdi3>:
  8031fc:	55                   	push   %ebp
  8031fd:	57                   	push   %edi
  8031fe:	56                   	push   %esi
  8031ff:	83 ec 10             	sub    $0x10,%esp
  803202:	8b 74 24 20          	mov    0x20(%esp),%esi
  803206:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80320a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80320e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  803212:	89 cd                	mov    %ecx,%ebp
  803214:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  803218:	85 c0                	test   %eax,%eax
  80321a:	75 2c                	jne    803248 <__udivdi3+0x4c>
  80321c:	39 f9                	cmp    %edi,%ecx
  80321e:	77 68                	ja     803288 <__udivdi3+0x8c>
  803220:	85 c9                	test   %ecx,%ecx
  803222:	75 0b                	jne    80322f <__udivdi3+0x33>
  803224:	b8 01 00 00 00       	mov    $0x1,%eax
  803229:	31 d2                	xor    %edx,%edx
  80322b:	f7 f1                	div    %ecx
  80322d:	89 c1                	mov    %eax,%ecx
  80322f:	31 d2                	xor    %edx,%edx
  803231:	89 f8                	mov    %edi,%eax
  803233:	f7 f1                	div    %ecx
  803235:	89 c7                	mov    %eax,%edi
  803237:	89 f0                	mov    %esi,%eax
  803239:	f7 f1                	div    %ecx
  80323b:	89 c6                	mov    %eax,%esi
  80323d:	89 f0                	mov    %esi,%eax
  80323f:	89 fa                	mov    %edi,%edx
  803241:	83 c4 10             	add    $0x10,%esp
  803244:	5e                   	pop    %esi
  803245:	5f                   	pop    %edi
  803246:	5d                   	pop    %ebp
  803247:	c3                   	ret    
  803248:	39 f8                	cmp    %edi,%eax
  80324a:	77 2c                	ja     803278 <__udivdi3+0x7c>
  80324c:	0f bd f0             	bsr    %eax,%esi
  80324f:	83 f6 1f             	xor    $0x1f,%esi
  803252:	75 4c                	jne    8032a0 <__udivdi3+0xa4>
  803254:	39 f8                	cmp    %edi,%eax
  803256:	bf 00 00 00 00       	mov    $0x0,%edi
  80325b:	72 0a                	jb     803267 <__udivdi3+0x6b>
  80325d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803261:	0f 87 ad 00 00 00    	ja     803314 <__udivdi3+0x118>
  803267:	be 01 00 00 00       	mov    $0x1,%esi
  80326c:	89 f0                	mov    %esi,%eax
  80326e:	89 fa                	mov    %edi,%edx
  803270:	83 c4 10             	add    $0x10,%esp
  803273:	5e                   	pop    %esi
  803274:	5f                   	pop    %edi
  803275:	5d                   	pop    %ebp
  803276:	c3                   	ret    
  803277:	90                   	nop
  803278:	31 ff                	xor    %edi,%edi
  80327a:	31 f6                	xor    %esi,%esi
  80327c:	89 f0                	mov    %esi,%eax
  80327e:	89 fa                	mov    %edi,%edx
  803280:	83 c4 10             	add    $0x10,%esp
  803283:	5e                   	pop    %esi
  803284:	5f                   	pop    %edi
  803285:	5d                   	pop    %ebp
  803286:	c3                   	ret    
  803287:	90                   	nop
  803288:	89 fa                	mov    %edi,%edx
  80328a:	89 f0                	mov    %esi,%eax
  80328c:	f7 f1                	div    %ecx
  80328e:	89 c6                	mov    %eax,%esi
  803290:	31 ff                	xor    %edi,%edi
  803292:	89 f0                	mov    %esi,%eax
  803294:	89 fa                	mov    %edi,%edx
  803296:	83 c4 10             	add    $0x10,%esp
  803299:	5e                   	pop    %esi
  80329a:	5f                   	pop    %edi
  80329b:	5d                   	pop    %ebp
  80329c:	c3                   	ret    
  80329d:	8d 76 00             	lea    0x0(%esi),%esi
  8032a0:	89 f1                	mov    %esi,%ecx
  8032a2:	d3 e0                	shl    %cl,%eax
  8032a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8032a8:	b8 20 00 00 00       	mov    $0x20,%eax
  8032ad:	29 f0                	sub    %esi,%eax
  8032af:	89 ea                	mov    %ebp,%edx
  8032b1:	88 c1                	mov    %al,%cl
  8032b3:	d3 ea                	shr    %cl,%edx
  8032b5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8032b9:	09 ca                	or     %ecx,%edx
  8032bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8032bf:	89 f1                	mov    %esi,%ecx
  8032c1:	d3 e5                	shl    %cl,%ebp
  8032c3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8032c7:	89 fd                	mov    %edi,%ebp
  8032c9:	88 c1                	mov    %al,%cl
  8032cb:	d3 ed                	shr    %cl,%ebp
  8032cd:	89 fa                	mov    %edi,%edx
  8032cf:	89 f1                	mov    %esi,%ecx
  8032d1:	d3 e2                	shl    %cl,%edx
  8032d3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8032d7:	88 c1                	mov    %al,%cl
  8032d9:	d3 ef                	shr    %cl,%edi
  8032db:	09 d7                	or     %edx,%edi
  8032dd:	89 f8                	mov    %edi,%eax
  8032df:	89 ea                	mov    %ebp,%edx
  8032e1:	f7 74 24 08          	divl   0x8(%esp)
  8032e5:	89 d1                	mov    %edx,%ecx
  8032e7:	89 c7                	mov    %eax,%edi
  8032e9:	f7 64 24 0c          	mull   0xc(%esp)
  8032ed:	39 d1                	cmp    %edx,%ecx
  8032ef:	72 17                	jb     803308 <__udivdi3+0x10c>
  8032f1:	74 09                	je     8032fc <__udivdi3+0x100>
  8032f3:	89 fe                	mov    %edi,%esi
  8032f5:	31 ff                	xor    %edi,%edi
  8032f7:	e9 41 ff ff ff       	jmp    80323d <__udivdi3+0x41>
  8032fc:	8b 54 24 04          	mov    0x4(%esp),%edx
  803300:	89 f1                	mov    %esi,%ecx
  803302:	d3 e2                	shl    %cl,%edx
  803304:	39 c2                	cmp    %eax,%edx
  803306:	73 eb                	jae    8032f3 <__udivdi3+0xf7>
  803308:	8d 77 ff             	lea    -0x1(%edi),%esi
  80330b:	31 ff                	xor    %edi,%edi
  80330d:	e9 2b ff ff ff       	jmp    80323d <__udivdi3+0x41>
  803312:	66 90                	xchg   %ax,%ax
  803314:	31 f6                	xor    %esi,%esi
  803316:	e9 22 ff ff ff       	jmp    80323d <__udivdi3+0x41>
	...

0080331c <__umoddi3>:
  80331c:	55                   	push   %ebp
  80331d:	57                   	push   %edi
  80331e:	56                   	push   %esi
  80331f:	83 ec 20             	sub    $0x20,%esp
  803322:	8b 44 24 30          	mov    0x30(%esp),%eax
  803326:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80332a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80332e:	8b 74 24 34          	mov    0x34(%esp),%esi
  803332:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803336:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80333a:	89 c7                	mov    %eax,%edi
  80333c:	89 f2                	mov    %esi,%edx
  80333e:	85 ed                	test   %ebp,%ebp
  803340:	75 16                	jne    803358 <__umoddi3+0x3c>
  803342:	39 f1                	cmp    %esi,%ecx
  803344:	0f 86 a6 00 00 00    	jbe    8033f0 <__umoddi3+0xd4>
  80334a:	f7 f1                	div    %ecx
  80334c:	89 d0                	mov    %edx,%eax
  80334e:	31 d2                	xor    %edx,%edx
  803350:	83 c4 20             	add    $0x20,%esp
  803353:	5e                   	pop    %esi
  803354:	5f                   	pop    %edi
  803355:	5d                   	pop    %ebp
  803356:	c3                   	ret    
  803357:	90                   	nop
  803358:	39 f5                	cmp    %esi,%ebp
  80335a:	0f 87 ac 00 00 00    	ja     80340c <__umoddi3+0xf0>
  803360:	0f bd c5             	bsr    %ebp,%eax
  803363:	83 f0 1f             	xor    $0x1f,%eax
  803366:	89 44 24 10          	mov    %eax,0x10(%esp)
  80336a:	0f 84 a8 00 00 00    	je     803418 <__umoddi3+0xfc>
  803370:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803374:	d3 e5                	shl    %cl,%ebp
  803376:	bf 20 00 00 00       	mov    $0x20,%edi
  80337b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80337f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803383:	89 f9                	mov    %edi,%ecx
  803385:	d3 e8                	shr    %cl,%eax
  803387:	09 e8                	or     %ebp,%eax
  803389:	89 44 24 18          	mov    %eax,0x18(%esp)
  80338d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803391:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803395:	d3 e0                	shl    %cl,%eax
  803397:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80339b:	89 f2                	mov    %esi,%edx
  80339d:	d3 e2                	shl    %cl,%edx
  80339f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8033a3:	d3 e0                	shl    %cl,%eax
  8033a5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8033a9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8033ad:	89 f9                	mov    %edi,%ecx
  8033af:	d3 e8                	shr    %cl,%eax
  8033b1:	09 d0                	or     %edx,%eax
  8033b3:	d3 ee                	shr    %cl,%esi
  8033b5:	89 f2                	mov    %esi,%edx
  8033b7:	f7 74 24 18          	divl   0x18(%esp)
  8033bb:	89 d6                	mov    %edx,%esi
  8033bd:	f7 64 24 0c          	mull   0xc(%esp)
  8033c1:	89 c5                	mov    %eax,%ebp
  8033c3:	89 d1                	mov    %edx,%ecx
  8033c5:	39 d6                	cmp    %edx,%esi
  8033c7:	72 67                	jb     803430 <__umoddi3+0x114>
  8033c9:	74 75                	je     803440 <__umoddi3+0x124>
  8033cb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8033cf:	29 e8                	sub    %ebp,%eax
  8033d1:	19 ce                	sbb    %ecx,%esi
  8033d3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8033d7:	d3 e8                	shr    %cl,%eax
  8033d9:	89 f2                	mov    %esi,%edx
  8033db:	89 f9                	mov    %edi,%ecx
  8033dd:	d3 e2                	shl    %cl,%edx
  8033df:	09 d0                	or     %edx,%eax
  8033e1:	89 f2                	mov    %esi,%edx
  8033e3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8033e7:	d3 ea                	shr    %cl,%edx
  8033e9:	83 c4 20             	add    $0x20,%esp
  8033ec:	5e                   	pop    %esi
  8033ed:	5f                   	pop    %edi
  8033ee:	5d                   	pop    %ebp
  8033ef:	c3                   	ret    
  8033f0:	85 c9                	test   %ecx,%ecx
  8033f2:	75 0b                	jne    8033ff <__umoddi3+0xe3>
  8033f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8033f9:	31 d2                	xor    %edx,%edx
  8033fb:	f7 f1                	div    %ecx
  8033fd:	89 c1                	mov    %eax,%ecx
  8033ff:	89 f0                	mov    %esi,%eax
  803401:	31 d2                	xor    %edx,%edx
  803403:	f7 f1                	div    %ecx
  803405:	89 f8                	mov    %edi,%eax
  803407:	e9 3e ff ff ff       	jmp    80334a <__umoddi3+0x2e>
  80340c:	89 f2                	mov    %esi,%edx
  80340e:	83 c4 20             	add    $0x20,%esp
  803411:	5e                   	pop    %esi
  803412:	5f                   	pop    %edi
  803413:	5d                   	pop    %ebp
  803414:	c3                   	ret    
  803415:	8d 76 00             	lea    0x0(%esi),%esi
  803418:	39 f5                	cmp    %esi,%ebp
  80341a:	72 04                	jb     803420 <__umoddi3+0x104>
  80341c:	39 f9                	cmp    %edi,%ecx
  80341e:	77 06                	ja     803426 <__umoddi3+0x10a>
  803420:	89 f2                	mov    %esi,%edx
  803422:	29 cf                	sub    %ecx,%edi
  803424:	19 ea                	sbb    %ebp,%edx
  803426:	89 f8                	mov    %edi,%eax
  803428:	83 c4 20             	add    $0x20,%esp
  80342b:	5e                   	pop    %esi
  80342c:	5f                   	pop    %edi
  80342d:	5d                   	pop    %ebp
  80342e:	c3                   	ret    
  80342f:	90                   	nop
  803430:	89 d1                	mov    %edx,%ecx
  803432:	89 c5                	mov    %eax,%ebp
  803434:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  803438:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80343c:	eb 8d                	jmp    8033cb <__umoddi3+0xaf>
  80343e:	66 90                	xchg   %ax,%ax
  803440:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803444:	72 ea                	jb     803430 <__umoddi3+0x114>
  803446:	89 f1                	mov    %esi,%ecx
  803448:	eb 81                	jmp    8033cb <__umoddi3+0xaf>
