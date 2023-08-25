
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 f7 02 00 00       	call   800328 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003e:	8a 45 0c             	mov    0xc(%ebp),%al
  800041:	88 45 f7             	mov    %al,-0x9(%ebp)
	const char *sep;

	if(flag['l'])
  800044:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  80004b:	74 21                	je     80006e <ls1+0x3a>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  80004d:	3c 01                	cmp    $0x1,%al
  80004f:	19 c0                	sbb    %eax,%eax
  800051:	83 e0 c9             	and    $0xffffffc9,%eax
  800054:	83 c0 64             	add    $0x64,%eax
  800057:	89 44 24 08          	mov    %eax,0x8(%esp)
  80005b:	8b 45 10             	mov    0x10(%ebp),%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 62 24 80 00 	movl   $0x802462,(%esp)
  800069:	e8 f7 1a 00 00       	call   801b65 <printf>
	if(prefix) {
  80006e:	85 db                	test   %ebx,%ebx
  800070:	74 3b                	je     8000ad <ls1+0x79>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800072:	80 3b 00             	cmpb   $0x0,(%ebx)
  800075:	74 16                	je     80008d <ls1+0x59>
  800077:	89 1c 24             	mov    %ebx,(%esp)
  80007a:	e8 89 09 00 00       	call   800a08 <strlen>
  80007f:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800084:	74 0e                	je     800094 <ls1+0x60>
			sep = "/";
  800086:	b8 60 24 80 00       	mov    $0x802460,%eax
  80008b:	eb 0c                	jmp    800099 <ls1+0x65>
		else
			sep = "";
  80008d:	b8 c8 24 80 00       	mov    $0x8024c8,%eax
  800092:	eb 05                	jmp    800099 <ls1+0x65>
  800094:	b8 c8 24 80 00       	mov    $0x8024c8,%eax
		printf("%s%s", prefix, sep);
  800099:	89 44 24 08          	mov    %eax,0x8(%esp)
  80009d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a1:	c7 04 24 6b 24 80 00 	movl   $0x80246b,(%esp)
  8000a8:	e8 b8 1a 00 00       	call   801b65 <printf>
	}
	printf("%s", name);
  8000ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8000b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b4:	c7 04 24 1e 29 80 00 	movl   $0x80291e,(%esp)
  8000bb:	e8 a5 1a 00 00       	call   801b65 <printf>
	if(flag['F'] && isdir)
  8000c0:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000c7:	74 12                	je     8000db <ls1+0xa7>
  8000c9:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  8000cd:	74 0c                	je     8000db <ls1+0xa7>
		printf("/");
  8000cf:	c7 04 24 60 24 80 00 	movl   $0x802460,(%esp)
  8000d6:	e8 8a 1a 00 00       	call   801b65 <printf>
	printf("\n");
  8000db:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  8000e2:	e8 7e 1a 00 00       	call   801b65 <printf>
}
  8000e7:	83 c4 24             	add    $0x24,%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  8000f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800103:	00 
  800104:	8b 45 08             	mov    0x8(%ebp),%eax
  800107:	89 04 24             	mov    %eax,(%esp)
  80010a:	e8 a2 18 00 00       	call   8019b1 <open>
  80010f:	89 c6                	mov    %eax,%esi
  800111:	85 c0                	test   %eax,%eax
  800113:	79 59                	jns    80016e <lsdir+0x81>
		panic("open %s: %e", path, fd);
  800115:	89 44 24 10          	mov    %eax,0x10(%esp)
  800119:	8b 45 08             	mov    0x8(%ebp),%eax
  80011c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800120:	c7 44 24 08 70 24 80 	movl   $0x802470,0x8(%esp)
  800127:	00 
  800128:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80012f:	00 
  800130:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  800137:	e8 5c 02 00 00       	call   800398 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  80013c:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  800143:	74 2f                	je     800174 <lsdir+0x87>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800145:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800149:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80014f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800153:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80015a:	0f 94 c0             	sete   %al
  80015d:	0f b6 c0             	movzbl %al,%eax
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	89 3c 24             	mov    %edi,(%esp)
  800167:	e8 c8 fe ff ff       	call   800034 <ls1>
  80016c:	eb 06                	jmp    800174 <lsdir+0x87>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80016e:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
  800174:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  80017b:	00 
  80017c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800180:	89 34 24             	mov    %esi,(%esp)
  800183:	e8 12 14 00 00       	call   80159a <readn>
  800188:	3d 00 01 00 00       	cmp    $0x100,%eax
  80018d:	74 ad                	je     80013c <lsdir+0x4f>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80018f:	85 c0                	test   %eax,%eax
  800191:	7e 23                	jle    8001b6 <lsdir+0xc9>
		panic("short read in directory %s", path);
  800193:	8b 45 08             	mov    0x8(%ebp),%eax
  800196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019a:	c7 44 24 08 86 24 80 	movl   $0x802486,0x8(%esp)
  8001a1:	00 
  8001a2:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8001a9:	00 
  8001aa:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  8001b1:	e8 e2 01 00 00       	call   800398 <_panic>
	if (n < 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	79 27                	jns    8001e1 <lsdir+0xf4>
		panic("error reading directory %s: %e", path, n);
  8001ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c5:	c7 44 24 08 cc 24 80 	movl   $0x8024cc,0x8(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8001d4:	00 
  8001d5:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  8001dc:	e8 b7 01 00 00       	call   800398 <_panic>
}
  8001e1:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5f                   	pop    %edi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	53                   	push   %ebx
  8001f0:	81 ec b4 00 00 00    	sub    $0xb4,%esp
  8001f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001f9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800203:	89 1c 24             	mov    %ebx,(%esp)
  800206:	e8 8d 15 00 00       	call   801798 <stat>
  80020b:	85 c0                	test   %eax,%eax
  80020d:	79 24                	jns    800233 <ls+0x47>
		panic("stat %s: %e", path, r);
  80020f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800213:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800217:	c7 44 24 08 a1 24 80 	movl   $0x8024a1,0x8(%esp)
  80021e:	00 
  80021f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800226:	00 
  800227:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  80022e:	e8 65 01 00 00       	call   800398 <_panic>
	if (st.st_isdir && !flag['d'])
  800233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800236:	85 c0                	test   %eax,%eax
  800238:	74 1a                	je     800254 <ls+0x68>
  80023a:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  800241:	75 11                	jne    800254 <ls+0x68>
		lsdir(path, prefix);
  800243:	8b 45 0c             	mov    0xc(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	89 1c 24             	mov    %ebx,(%esp)
  80024d:	e8 9b fe ff ff       	call   8000ed <lsdir>
  800252:	eb 23                	jmp    800277 <ls+0x8b>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  800254:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800258:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80025b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80025f:	85 c0                	test   %eax,%eax
  800261:	0f 95 c0             	setne  %al
  800264:	0f b6 c0             	movzbl %al,%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800272:	e8 bd fd ff ff       	call   800034 <ls1>
}
  800277:	81 c4 b4 00 00 00    	add    $0xb4,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <usage>:
	printf("\n");
}

void
usage(void)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 18             	sub    $0x18,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800286:	c7 04 24 ad 24 80 00 	movl   $0x8024ad,(%esp)
  80028d:	e8 d3 18 00 00       	call   801b65 <printf>
	exit();
  800292:	e8 e5 00 00 00       	call   80037c <exit>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <umain>:

void
umain(int argc, char **argv)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 20             	sub    $0x20,%esp
  8002a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  8002a4:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002af:	8d 45 08             	lea    0x8(%ebp),%eax
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	e8 de 0d 00 00       	call   801098 <argstart>
	while ((i = argnext(&args)) >= 0)
  8002ba:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  8002bd:	eb 1d                	jmp    8002dc <umain+0x43>
		switch (i) {
  8002bf:	83 f8 64             	cmp    $0x64,%eax
  8002c2:	74 0a                	je     8002ce <umain+0x35>
  8002c4:	83 f8 6c             	cmp    $0x6c,%eax
  8002c7:	74 05                	je     8002ce <umain+0x35>
  8002c9:	83 f8 46             	cmp    $0x46,%eax
  8002cc:	75 09                	jne    8002d7 <umain+0x3e>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  8002ce:	ff 04 85 20 40 80 00 	incl   0x804020(,%eax,4)
			break;
  8002d5:	eb 05                	jmp    8002dc <umain+0x43>
		default:
			usage();
  8002d7:	e8 a4 ff ff ff       	call   800280 <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  8002dc:	89 1c 24             	mov    %ebx,(%esp)
  8002df:	e8 ed 0d 00 00       	call   8010d1 <argnext>
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	79 d7                	jns    8002bf <umain+0x26>
			break;
		default:
			usage();
		}

	if (argc == 1)
  8002e8:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8002ec:	75 28                	jne    800316 <umain+0x7d>
		ls("/", "");
  8002ee:	c7 44 24 04 c8 24 80 	movl   $0x8024c8,0x4(%esp)
  8002f5:	00 
  8002f6:	c7 04 24 60 24 80 00 	movl   $0x802460,(%esp)
  8002fd:	e8 ea fe ff ff       	call   8001ec <ls>
  800302:	eb 1c                	jmp    800320 <umain+0x87>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  800304:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	e8 d9 fe ff ff       	call   8001ec <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  800313:	43                   	inc    %ebx
  800314:	eb 05                	jmp    80031b <umain+0x82>
			break;
		default:
			usage();
		}

	if (argc == 1)
  800316:	bb 01 00 00 00       	mov    $0x1,%ebx
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  80031b:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80031e:	7c e4                	jl     800304 <umain+0x6b>
			ls(argv[i], argv[i]);
	}
}
  800320:	83 c4 20             	add    $0x20,%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    
	...

00800328 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	83 ec 10             	sub    $0x10,%esp
  800330:	8b 75 08             	mov    0x8(%ebp),%esi
  800333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800336:	e8 b4 0a 00 00       	call   800def <sys_getenvid>
  80033b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800340:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800347:	c1 e0 07             	shl    $0x7,%eax
  80034a:	29 d0                	sub    %edx,%eax
  80034c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800351:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800356:	85 f6                	test   %esi,%esi
  800358:	7e 07                	jle    800361 <libmain+0x39>
		binaryname = argv[0];
  80035a:	8b 03                	mov    (%ebx),%eax
  80035c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800361:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800365:	89 34 24             	mov    %esi,(%esp)
  800368:	e8 2c ff ff ff       	call   800299 <umain>

	// exit gracefully
	exit();
  80036d:	e8 0a 00 00 00       	call   80037c <exit>
}
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    
  800379:	00 00                	add    %al,(%eax)
	...

0080037c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800382:	e8 50 10 00 00       	call   8013d7 <close_all>
	sys_env_destroy(0);
  800387:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80038e:	e8 0a 0a 00 00       	call   800d9d <sys_env_destroy>
}
  800393:	c9                   	leave  
  800394:	c3                   	ret    
  800395:	00 00                	add    %al,(%eax)
	...

00800398 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8003a9:	e8 41 0a 00 00       	call   800def <sys_getenvid>
  8003ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c4:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  8003cb:	e8 c0 00 00 00       	call   800490 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	e8 50 00 00 00       	call   80042f <vcprintf>
	cprintf("\n");
  8003df:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  8003e6:	e8 a5 00 00 00       	call   800490 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003eb:	cc                   	int3   
  8003ec:	eb fd                	jmp    8003eb <_panic+0x53>
	...

008003f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 14             	sub    $0x14,%esp
  8003f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003fa:	8b 03                	mov    (%ebx),%eax
  8003fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800403:	40                   	inc    %eax
  800404:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800406:	3d ff 00 00 00       	cmp    $0xff,%eax
  80040b:	75 19                	jne    800426 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80040d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800414:	00 
  800415:	8d 43 08             	lea    0x8(%ebx),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 40 09 00 00       	call   800d60 <sys_cputs>
		b->idx = 0;
  800420:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800426:	ff 43 04             	incl   0x4(%ebx)
}
  800429:	83 c4 14             	add    $0x14,%esp
  80042c:	5b                   	pop    %ebx
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800438:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80043f:	00 00 00 
	b.cnt = 0;
  800442:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800449:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80044c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800453:	8b 45 08             	mov    0x8(%ebp),%eax
  800456:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	c7 04 24 f0 03 80 00 	movl   $0x8003f0,(%esp)
  80046b:	e8 82 01 00 00       	call   8005f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800470:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 d8 08 00 00       	call   800d60 <sys_cputs>

	return b.cnt;
}
  800488:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80048e:	c9                   	leave  
  80048f:	c3                   	ret    

00800490 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800496:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 87 ff ff ff       	call   80042f <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    
	...

008004ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 3c             	sub    $0x3c,%esp
  8004b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b8:	89 d7                	mov    %edx,%edi
  8004ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	75 08                	jne    8004d8 <printnum+0x2c>
  8004d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004d6:	77 57                	ja     80052f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004dc:	4b                   	dec    %ebx
  8004dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f7:	00 
  8004f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	e8 f2 1c 00 00       	call   8021fc <__udivdi3>
  80050a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80050e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	89 54 24 04          	mov    %edx,0x4(%esp)
  800519:	89 fa                	mov    %edi,%edx
  80051b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051e:	e8 89 ff ff ff       	call   8004ac <printnum>
  800523:	eb 0f                	jmp    800534 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800529:	89 34 24             	mov    %esi,(%esp)
  80052c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80052f:	4b                   	dec    %ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f f1                	jg     800525 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800534:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800538:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80053c:	8b 45 10             	mov    0x10(%ebp),%eax
  80053f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800543:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054a:	00 
  80054b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800554:	89 44 24 04          	mov    %eax,0x4(%esp)
  800558:	e8 bf 1d 00 00       	call   80231c <__umoddi3>
  80055d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800561:	0f be 80 1b 25 80 00 	movsbl 0x80251b(%eax),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80056e:	83 c4 3c             	add    $0x3c,%esp
  800571:	5b                   	pop    %ebx
  800572:	5e                   	pop    %esi
  800573:	5f                   	pop    %edi
  800574:	5d                   	pop    %ebp
  800575:	c3                   	ret    

00800576 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800579:	83 fa 01             	cmp    $0x1,%edx
  80057c:	7e 0e                	jle    80058c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80057e:	8b 10                	mov    (%eax),%edx
  800580:	8d 4a 08             	lea    0x8(%edx),%ecx
  800583:	89 08                	mov    %ecx,(%eax)
  800585:	8b 02                	mov    (%edx),%eax
  800587:	8b 52 04             	mov    0x4(%edx),%edx
  80058a:	eb 22                	jmp    8005ae <getuint+0x38>
	else if (lflag)
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 10                	je     8005a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
  80059e:	eb 0e                	jmp    8005ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a0:	8b 10                	mov    (%eax),%edx
  8005a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a5:	89 08                	mov    %ecx,(%eax)
  8005a7:	8b 02                	mov    (%edx),%eax
  8005a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005b6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005be:	73 08                	jae    8005c8 <sprintputch+0x18>
		*b->buf++ = ch;
  8005c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c3:	88 0a                	mov    %cl,(%edx)
  8005c5:	42                   	inc    %edx
  8005c6:	89 10                	mov    %edx,(%eax)
}
  8005c8:	5d                   	pop    %ebp
  8005c9:	c3                   	ret    

008005ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ca:	55                   	push   %ebp
  8005cb:	89 e5                	mov    %esp,%ebp
  8005cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	e8 02 00 00 00       	call   8005f2 <vprintfmt>
	va_end(ap);
}
  8005f0:	c9                   	leave  
  8005f1:	c3                   	ret    

008005f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	57                   	push   %edi
  8005f6:	56                   	push   %esi
  8005f7:	53                   	push   %ebx
  8005f8:	83 ec 4c             	sub    $0x4c,%esp
  8005fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fe:	8b 75 10             	mov    0x10(%ebp),%esi
  800601:	eb 12                	jmp    800615 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800603:	85 c0                	test   %eax,%eax
  800605:	0f 84 6b 03 00 00    	je     800976 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80060b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800615:	0f b6 06             	movzbl (%esi),%eax
  800618:	46                   	inc    %esi
  800619:	83 f8 25             	cmp    $0x25,%eax
  80061c:	75 e5                	jne    800603 <vprintfmt+0x11>
  80061e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800622:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800629:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80062e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063a:	eb 26                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80063f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800643:	eb 1d                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800648:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80064c:	eb 14                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800651:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800658:	eb 08                	jmp    800662 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80065a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80065d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	0f b6 06             	movzbl (%esi),%eax
  800665:	8d 56 01             	lea    0x1(%esi),%edx
  800668:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80066b:	8a 16                	mov    (%esi),%dl
  80066d:	83 ea 23             	sub    $0x23,%edx
  800670:	80 fa 55             	cmp    $0x55,%dl
  800673:	0f 87 e1 02 00 00    	ja     80095a <vprintfmt+0x368>
  800679:	0f b6 d2             	movzbl %dl,%edx
  80067c:	ff 24 95 60 26 80 00 	jmp    *0x802660(,%edx,4)
  800683:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800686:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80068b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80068e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800692:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800695:	8d 50 d0             	lea    -0x30(%eax),%edx
  800698:	83 fa 09             	cmp    $0x9,%edx
  80069b:	77 2a                	ja     8006c7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80069d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80069e:	eb eb                	jmp    80068b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006ae:	eb 17                	jmp    8006c7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b4:	78 98                	js     80064e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b9:	eb a7                	jmp    800662 <vprintfmt+0x70>
  8006bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006be:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006c5:	eb 9b                	jmp    800662 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006cb:	79 95                	jns    800662 <vprintfmt+0x70>
  8006cd:	eb 8b                	jmp    80065a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006cf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006d3:	eb 8d                	jmp    800662 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006ed:	e9 23 ff ff ff       	jmp    800615 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	79 02                	jns    800703 <vprintfmt+0x111>
  800701:	f7 d8                	neg    %eax
  800703:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800705:	83 f8 0f             	cmp    $0xf,%eax
  800708:	7f 0b                	jg     800715 <vprintfmt+0x123>
  80070a:	8b 04 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%eax
  800711:	85 c0                	test   %eax,%eax
  800713:	75 23                	jne    800738 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800715:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800719:	c7 44 24 08 33 25 80 	movl   $0x802533,0x8(%esp)
  800720:	00 
  800721:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	e8 9a fe ff ff       	call   8005ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800730:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800733:	e9 dd fe ff ff       	jmp    800615 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800738:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073c:	c7 44 24 08 1e 29 80 	movl   $0x80291e,0x8(%esp)
  800743:	00 
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	8b 55 08             	mov    0x8(%ebp),%edx
  80074b:	89 14 24             	mov    %edx,(%esp)
  80074e:	e8 77 fe ff ff       	call   8005ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800753:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800756:	e9 ba fe ff ff       	jmp    800615 <vprintfmt+0x23>
  80075b:	89 f9                	mov    %edi,%ecx
  80075d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800760:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 30                	mov    (%eax),%esi
  80076e:	85 f6                	test   %esi,%esi
  800770:	75 05                	jne    800777 <vprintfmt+0x185>
				p = "(null)";
  800772:	be 2c 25 80 00       	mov    $0x80252c,%esi
			if (width > 0 && padc != '-')
  800777:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80077b:	0f 8e 84 00 00 00    	jle    800805 <vprintfmt+0x213>
  800781:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800785:	74 7e                	je     800805 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800787:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078b:	89 34 24             	mov    %esi,(%esp)
  80078e:	e8 8b 02 00 00       	call   800a1e <strnlen>
  800793:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800796:	29 c2                	sub    %eax,%edx
  800798:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80079b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80079f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007a5:	89 de                	mov    %ebx,%esi
  8007a7:	89 d3                	mov    %edx,%ebx
  8007a9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ab:	eb 0b                	jmp    8007b8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b1:	89 3c 24             	mov    %edi,(%esp)
  8007b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b7:	4b                   	dec    %ebx
  8007b8:	85 db                	test   %ebx,%ebx
  8007ba:	7f f1                	jg     8007ad <vprintfmt+0x1bb>
  8007bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007bf:	89 f3                	mov    %esi,%ebx
  8007c1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	79 05                	jns    8007d0 <vprintfmt+0x1de>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d3:	29 c2                	sub    %eax,%edx
  8007d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007d8:	eb 2b                	jmp    800805 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007de:	74 18                	je     8007f8 <vprintfmt+0x206>
  8007e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007e3:	83 fa 5e             	cmp    $0x5e,%edx
  8007e6:	76 10                	jbe    8007f8 <vprintfmt+0x206>
					putch('?', putdat);
  8007e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
  8007f6:	eb 0a                	jmp    800802 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fc:	89 04 24             	mov    %eax,(%esp)
  8007ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800802:	ff 4d e4             	decl   -0x1c(%ebp)
  800805:	0f be 06             	movsbl (%esi),%eax
  800808:	46                   	inc    %esi
  800809:	85 c0                	test   %eax,%eax
  80080b:	74 21                	je     80082e <vprintfmt+0x23c>
  80080d:	85 ff                	test   %edi,%edi
  80080f:	78 c9                	js     8007da <vprintfmt+0x1e8>
  800811:	4f                   	dec    %edi
  800812:	79 c6                	jns    8007da <vprintfmt+0x1e8>
  800814:	8b 7d 08             	mov    0x8(%ebp),%edi
  800817:	89 de                	mov    %ebx,%esi
  800819:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80081c:	eb 18                	jmp    800836 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80081e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800822:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800829:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80082b:	4b                   	dec    %ebx
  80082c:	eb 08                	jmp    800836 <vprintfmt+0x244>
  80082e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800831:	89 de                	mov    %ebx,%esi
  800833:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800836:	85 db                	test   %ebx,%ebx
  800838:	7f e4                	jg     80081e <vprintfmt+0x22c>
  80083a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80083d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800842:	e9 ce fd ff ff       	jmp    800615 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800847:	83 f9 01             	cmp    $0x1,%ecx
  80084a:	7e 10                	jle    80085c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 08             	lea    0x8(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)
  800855:	8b 30                	mov    (%eax),%esi
  800857:	8b 78 04             	mov    0x4(%eax),%edi
  80085a:	eb 26                	jmp    800882 <vprintfmt+0x290>
	else if (lflag)
  80085c:	85 c9                	test   %ecx,%ecx
  80085e:	74 12                	je     800872 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8d 50 04             	lea    0x4(%eax),%edx
  800866:	89 55 14             	mov    %edx,0x14(%ebp)
  800869:	8b 30                	mov    (%eax),%esi
  80086b:	89 f7                	mov    %esi,%edi
  80086d:	c1 ff 1f             	sar    $0x1f,%edi
  800870:	eb 10                	jmp    800882 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8d 50 04             	lea    0x4(%eax),%edx
  800878:	89 55 14             	mov    %edx,0x14(%ebp)
  80087b:	8b 30                	mov    (%eax),%esi
  80087d:	89 f7                	mov    %esi,%edi
  80087f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800882:	85 ff                	test   %edi,%edi
  800884:	78 0a                	js     800890 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800886:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088b:	e9 8c 00 00 00       	jmp    80091c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800890:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800894:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80089b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80089e:	f7 de                	neg    %esi
  8008a0:	83 d7 00             	adc    $0x0,%edi
  8008a3:	f7 df                	neg    %edi
			}
			base = 10;
  8008a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008aa:	eb 70                	jmp    80091c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008ac:	89 ca                	mov    %ecx,%edx
  8008ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b1:	e8 c0 fc ff ff       	call   800576 <getuint>
  8008b6:	89 c6                	mov    %eax,%esi
  8008b8:	89 d7                	mov    %edx,%edi
			base = 10;
  8008ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008bf:	eb 5b                	jmp    80091c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008c1:	89 ca                	mov    %ecx,%edx
  8008c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c6:	e8 ab fc ff ff       	call   800576 <getuint>
  8008cb:	89 c6                	mov    %eax,%esi
  8008cd:	89 d7                	mov    %edx,%edi
			base = 8;
  8008cf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008d4:	eb 46                	jmp    80091c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8008d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008da:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008e1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8d 50 04             	lea    0x4(%eax),%edx
  8008f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008fb:	8b 30                	mov    (%eax),%esi
  8008fd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800902:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800907:	eb 13                	jmp    80091c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800909:	89 ca                	mov    %ecx,%edx
  80090b:	8d 45 14             	lea    0x14(%ebp),%eax
  80090e:	e8 63 fc ff ff       	call   800576 <getuint>
  800913:	89 c6                	mov    %eax,%esi
  800915:	89 d7                	mov    %edx,%edi
			base = 16;
  800917:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80091c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800920:	89 54 24 10          	mov    %edx,0x10(%esp)
  800924:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800927:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80092b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092f:	89 34 24             	mov    %esi,(%esp)
  800932:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800936:	89 da                	mov    %ebx,%edx
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	e8 6c fb ff ff       	call   8004ac <printnum>
			break;
  800940:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800943:	e9 cd fc ff ff       	jmp    800615 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800948:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800952:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800955:	e9 bb fc ff ff       	jmp    800615 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80095a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800965:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800968:	eb 01                	jmp    80096b <vprintfmt+0x379>
  80096a:	4e                   	dec    %esi
  80096b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80096f:	75 f9                	jne    80096a <vprintfmt+0x378>
  800971:	e9 9f fc ff ff       	jmp    800615 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800976:	83 c4 4c             	add    $0x4c,%esp
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	83 ec 28             	sub    $0x28,%esp
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80098d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800991:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800994:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099b:	85 c0                	test   %eax,%eax
  80099d:	74 30                	je     8009cf <vsnprintf+0x51>
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	7e 33                	jle    8009d6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b8:	c7 04 24 b0 05 80 00 	movl   $0x8005b0,(%esp)
  8009bf:	e8 2e fc ff ff       	call   8005f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009cd:	eb 0c                	jmp    8009db <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009d4:	eb 05                	jmp    8009db <vsnprintf+0x5d>
  8009d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	89 04 24             	mov    %eax,(%esp)
  8009fe:	e8 7b ff ff ff       	call   80097e <vsnprintf>
	va_end(ap);

	return rc;
}
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    
  800a05:	00 00                	add    %al,(%eax)
	...

00800a08 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a13:	eb 01                	jmp    800a16 <strlen+0xe>
		n++;
  800a15:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a16:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a1a:	75 f9                	jne    800a15 <strlen+0xd>
		n++;
	return n;
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a24:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2c:	eb 01                	jmp    800a2f <strnlen+0x11>
		n++;
  800a2e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2f:	39 d0                	cmp    %edx,%eax
  800a31:	74 06                	je     800a39 <strnlen+0x1b>
  800a33:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a37:	75 f5                	jne    800a2e <strnlen+0x10>
		n++;
	return n;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a4d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a50:	42                   	inc    %edx
  800a51:	84 c9                	test   %cl,%cl
  800a53:	75 f5                	jne    800a4a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a55:	5b                   	pop    %ebx
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	53                   	push   %ebx
  800a5c:	83 ec 08             	sub    $0x8,%esp
  800a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a62:	89 1c 24             	mov    %ebx,(%esp)
  800a65:	e8 9e ff ff ff       	call   800a08 <strlen>
	strcpy(dst + len, src);
  800a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a71:	01 d8                	add    %ebx,%eax
  800a73:	89 04 24             	mov    %eax,(%esp)
  800a76:	e8 c0 ff ff ff       	call   800a3b <strcpy>
	return dst;
}
  800a7b:	89 d8                	mov    %ebx,%eax
  800a7d:	83 c4 08             	add    $0x8,%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a96:	eb 0c                	jmp    800aa4 <strncpy+0x21>
		*dst++ = *src;
  800a98:	8a 1a                	mov    (%edx),%bl
  800a9a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9d:	80 3a 01             	cmpb   $0x1,(%edx)
  800aa0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa3:	41                   	inc    %ecx
  800aa4:	39 f1                	cmp    %esi,%ecx
  800aa6:	75 f0                	jne    800a98 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aba:	85 d2                	test   %edx,%edx
  800abc:	75 0a                	jne    800ac8 <strlcpy+0x1c>
  800abe:	89 f0                	mov    %esi,%eax
  800ac0:	eb 1a                	jmp    800adc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac2:	88 18                	mov    %bl,(%eax)
  800ac4:	40                   	inc    %eax
  800ac5:	41                   	inc    %ecx
  800ac6:	eb 02                	jmp    800aca <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800aca:	4a                   	dec    %edx
  800acb:	74 0a                	je     800ad7 <strlcpy+0x2b>
  800acd:	8a 19                	mov    (%ecx),%bl
  800acf:	84 db                	test   %bl,%bl
  800ad1:	75 ef                	jne    800ac2 <strlcpy+0x16>
  800ad3:	89 c2                	mov    %eax,%edx
  800ad5:	eb 02                	jmp    800ad9 <strlcpy+0x2d>
  800ad7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ad9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800adc:	29 f0                	sub    %esi,%eax
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aeb:	eb 02                	jmp    800aef <strcmp+0xd>
		p++, q++;
  800aed:	41                   	inc    %ecx
  800aee:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aef:	8a 01                	mov    (%ecx),%al
  800af1:	84 c0                	test   %al,%al
  800af3:	74 04                	je     800af9 <strcmp+0x17>
  800af5:	3a 02                	cmp    (%edx),%al
  800af7:	74 f4                	je     800aed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af9:	0f b6 c0             	movzbl %al,%eax
  800afc:	0f b6 12             	movzbl (%edx),%edx
  800aff:	29 d0                	sub    %edx,%eax
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	53                   	push   %ebx
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b10:	eb 03                	jmp    800b15 <strncmp+0x12>
		n--, p++, q++;
  800b12:	4a                   	dec    %edx
  800b13:	40                   	inc    %eax
  800b14:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b15:	85 d2                	test   %edx,%edx
  800b17:	74 14                	je     800b2d <strncmp+0x2a>
  800b19:	8a 18                	mov    (%eax),%bl
  800b1b:	84 db                	test   %bl,%bl
  800b1d:	74 04                	je     800b23 <strncmp+0x20>
  800b1f:	3a 19                	cmp    (%ecx),%bl
  800b21:	74 ef                	je     800b12 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b23:	0f b6 00             	movzbl (%eax),%eax
  800b26:	0f b6 11             	movzbl (%ecx),%edx
  800b29:	29 d0                	sub    %edx,%eax
  800b2b:	eb 05                	jmp    800b32 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b32:	5b                   	pop    %ebx
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b3e:	eb 05                	jmp    800b45 <strchr+0x10>
		if (*s == c)
  800b40:	38 ca                	cmp    %cl,%dl
  800b42:	74 0c                	je     800b50 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b44:	40                   	inc    %eax
  800b45:	8a 10                	mov    (%eax),%dl
  800b47:	84 d2                	test   %dl,%dl
  800b49:	75 f5                	jne    800b40 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b5b:	eb 05                	jmp    800b62 <strfind+0x10>
		if (*s == c)
  800b5d:	38 ca                	cmp    %cl,%dl
  800b5f:	74 07                	je     800b68 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b61:	40                   	inc    %eax
  800b62:	8a 10                	mov    (%eax),%dl
  800b64:	84 d2                	test   %dl,%dl
  800b66:	75 f5                	jne    800b5d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
  800b70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b79:	85 c9                	test   %ecx,%ecx
  800b7b:	74 30                	je     800bad <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b83:	75 25                	jne    800baa <memset+0x40>
  800b85:	f6 c1 03             	test   $0x3,%cl
  800b88:	75 20                	jne    800baa <memset+0x40>
		c &= 0xFF;
  800b8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	c1 e3 08             	shl    $0x8,%ebx
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	c1 e6 18             	shl    $0x18,%esi
  800b97:	89 d0                	mov    %edx,%eax
  800b99:	c1 e0 10             	shl    $0x10,%eax
  800b9c:	09 f0                	or     %esi,%eax
  800b9e:	09 d0                	or     %edx,%eax
  800ba0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ba2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba5:	fc                   	cld    
  800ba6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba8:	eb 03                	jmp    800bad <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800baa:	fc                   	cld    
  800bab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bad:	89 f8                	mov    %edi,%eax
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc2:	39 c6                	cmp    %eax,%esi
  800bc4:	73 34                	jae    800bfa <memmove+0x46>
  800bc6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc9:	39 d0                	cmp    %edx,%eax
  800bcb:	73 2d                	jae    800bfa <memmove+0x46>
		s += n;
		d += n;
  800bcd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd0:	f6 c2 03             	test   $0x3,%dl
  800bd3:	75 1b                	jne    800bf0 <memmove+0x3c>
  800bd5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdb:	75 13                	jne    800bf0 <memmove+0x3c>
  800bdd:	f6 c1 03             	test   $0x3,%cl
  800be0:	75 0e                	jne    800bf0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be2:	83 ef 04             	sub    $0x4,%edi
  800be5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800beb:	fd                   	std    
  800bec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bee:	eb 07                	jmp    800bf7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bf0:	4f                   	dec    %edi
  800bf1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf4:	fd                   	std    
  800bf5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf7:	fc                   	cld    
  800bf8:	eb 20                	jmp    800c1a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c00:	75 13                	jne    800c15 <memmove+0x61>
  800c02:	a8 03                	test   $0x3,%al
  800c04:	75 0f                	jne    800c15 <memmove+0x61>
  800c06:	f6 c1 03             	test   $0x3,%cl
  800c09:	75 0a                	jne    800c15 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c0b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	fc                   	cld    
  800c11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c13:	eb 05                	jmp    800c1a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c15:	89 c7                	mov    %eax,%edi
  800c17:	fc                   	cld    
  800c18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c24:	8b 45 10             	mov    0x10(%ebp),%eax
  800c27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
  800c35:	89 04 24             	mov    %eax,(%esp)
  800c38:	e8 77 ff ff ff       	call   800bb4 <memmove>
}
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c53:	eb 16                	jmp    800c6b <memcmp+0x2c>
		if (*s1 != *s2)
  800c55:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c58:	42                   	inc    %edx
  800c59:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c5d:	38 c8                	cmp    %cl,%al
  800c5f:	74 0a                	je     800c6b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c61:	0f b6 c0             	movzbl %al,%eax
  800c64:	0f b6 c9             	movzbl %cl,%ecx
  800c67:	29 c8                	sub    %ecx,%eax
  800c69:	eb 09                	jmp    800c74 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6b:	39 da                	cmp    %ebx,%edx
  800c6d:	75 e6                	jne    800c55 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c82:	89 c2                	mov    %eax,%edx
  800c84:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c87:	eb 05                	jmp    800c8e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c89:	38 08                	cmp    %cl,(%eax)
  800c8b:	74 05                	je     800c92 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c8d:	40                   	inc    %eax
  800c8e:	39 d0                	cmp    %edx,%eax
  800c90:	72 f7                	jb     800c89 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca0:	eb 01                	jmp    800ca3 <strtol+0xf>
		s++;
  800ca2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca3:	8a 02                	mov    (%edx),%al
  800ca5:	3c 20                	cmp    $0x20,%al
  800ca7:	74 f9                	je     800ca2 <strtol+0xe>
  800ca9:	3c 09                	cmp    $0x9,%al
  800cab:	74 f5                	je     800ca2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cad:	3c 2b                	cmp    $0x2b,%al
  800caf:	75 08                	jne    800cb9 <strtol+0x25>
		s++;
  800cb1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb7:	eb 13                	jmp    800ccc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb9:	3c 2d                	cmp    $0x2d,%al
  800cbb:	75 0a                	jne    800cc7 <strtol+0x33>
		s++, neg = 1;
  800cbd:	8d 52 01             	lea    0x1(%edx),%edx
  800cc0:	bf 01 00 00 00       	mov    $0x1,%edi
  800cc5:	eb 05                	jmp    800ccc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ccc:	85 db                	test   %ebx,%ebx
  800cce:	74 05                	je     800cd5 <strtol+0x41>
  800cd0:	83 fb 10             	cmp    $0x10,%ebx
  800cd3:	75 28                	jne    800cfd <strtol+0x69>
  800cd5:	8a 02                	mov    (%edx),%al
  800cd7:	3c 30                	cmp    $0x30,%al
  800cd9:	75 10                	jne    800ceb <strtol+0x57>
  800cdb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cdf:	75 0a                	jne    800ceb <strtol+0x57>
		s += 2, base = 16;
  800ce1:	83 c2 02             	add    $0x2,%edx
  800ce4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce9:	eb 12                	jmp    800cfd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ceb:	85 db                	test   %ebx,%ebx
  800ced:	75 0e                	jne    800cfd <strtol+0x69>
  800cef:	3c 30                	cmp    $0x30,%al
  800cf1:	75 05                	jne    800cf8 <strtol+0x64>
		s++, base = 8;
  800cf3:	42                   	inc    %edx
  800cf4:	b3 08                	mov    $0x8,%bl
  800cf6:	eb 05                	jmp    800cfd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cf8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800d02:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d04:	8a 0a                	mov    (%edx),%cl
  800d06:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d09:	80 fb 09             	cmp    $0x9,%bl
  800d0c:	77 08                	ja     800d16 <strtol+0x82>
			dig = *s - '0';
  800d0e:	0f be c9             	movsbl %cl,%ecx
  800d11:	83 e9 30             	sub    $0x30,%ecx
  800d14:	eb 1e                	jmp    800d34 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d16:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d19:	80 fb 19             	cmp    $0x19,%bl
  800d1c:	77 08                	ja     800d26 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d1e:	0f be c9             	movsbl %cl,%ecx
  800d21:	83 e9 57             	sub    $0x57,%ecx
  800d24:	eb 0e                	jmp    800d34 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d26:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d29:	80 fb 19             	cmp    $0x19,%bl
  800d2c:	77 12                	ja     800d40 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d2e:	0f be c9             	movsbl %cl,%ecx
  800d31:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d34:	39 f1                	cmp    %esi,%ecx
  800d36:	7d 0c                	jge    800d44 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d38:	42                   	inc    %edx
  800d39:	0f af c6             	imul   %esi,%eax
  800d3c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d3e:	eb c4                	jmp    800d04 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d40:	89 c1                	mov    %eax,%ecx
  800d42:	eb 02                	jmp    800d46 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d44:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d4a:	74 05                	je     800d51 <strtol+0xbd>
		*endptr = (char *) s;
  800d4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d4f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d51:	85 ff                	test   %edi,%edi
  800d53:	74 04                	je     800d59 <strtol+0xc5>
  800d55:	89 c8                	mov    %ecx,%eax
  800d57:	f7 d8                	neg    %eax
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    
	...

00800d60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	89 c3                	mov    %eax,%ebx
  800d73:	89 c7                	mov    %eax,%edi
  800d75:	89 c6                	mov    %eax,%esi
  800d77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d84:	ba 00 00 00 00       	mov    $0x0,%edx
  800d89:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8e:	89 d1                	mov    %edx,%ecx
  800d90:	89 d3                	mov    %edx,%ebx
  800d92:	89 d7                	mov    %edx,%edi
  800d94:	89 d6                	mov    %edx,%esi
  800d96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dab:	b8 03 00 00 00       	mov    $0x3,%eax
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 cb                	mov    %ecx,%ebx
  800db5:	89 cf                	mov    %ecx,%edi
  800db7:	89 ce                	mov    %ecx,%esi
  800db9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7e 28                	jle    800de7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dca:	00 
  800dcb:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800dd2:	00 
  800dd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dda:	00 
  800ddb:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800de2:	e8 b1 f5 ff ff       	call   800398 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800de7:	83 c4 2c             	add    $0x2c,%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfa:	b8 02 00 00 00       	mov    $0x2,%eax
  800dff:	89 d1                	mov    %edx,%ecx
  800e01:	89 d3                	mov    %edx,%ebx
  800e03:	89 d7                	mov    %edx,%edi
  800e05:	89 d6                	mov    %edx,%esi
  800e07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_yield>:

void
sys_yield(void)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	ba 00 00 00 00       	mov    $0x0,%edx
  800e19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1e:	89 d1                	mov    %edx,%ecx
  800e20:	89 d3                	mov    %edx,%ebx
  800e22:	89 d7                	mov    %edx,%edi
  800e24:	89 d6                	mov    %edx,%esi
  800e26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800e36:	be 00 00 00 00       	mov    $0x0,%esi
  800e3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800e40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 f7                	mov    %esi,%edi
  800e4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7e 28                	jle    800e79 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e55:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800e64:	00 
  800e65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6c:	00 
  800e6d:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800e74:	e8 1f f5 ff ff       	call   800398 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e79:	83 c4 2c             	add    $0x2c,%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 28                	jle    800ecc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800ec7:	e8 cc f4 ff ff       	call   800398 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ecc:	83 c4 2c             	add    $0x2c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ee7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
  800eed:	89 df                	mov    %ebx,%edi
  800eef:	89 de                	mov    %ebx,%esi
  800ef1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	7e 28                	jle    800f1f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f02:	00 
  800f03:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800f0a:	00 
  800f0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f12:	00 
  800f13:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800f1a:	e8 79 f4 ff ff       	call   800398 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f1f:	83 c4 2c             	add    $0x2c,%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f35:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	89 df                	mov    %ebx,%edi
  800f42:	89 de                	mov    %ebx,%esi
  800f44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7e 28                	jle    800f72 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f55:	00 
  800f56:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800f5d:	00 
  800f5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f65:	00 
  800f66:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800f6d:	e8 26 f4 ff ff       	call   800398 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f72:	83 c4 2c             	add    $0x2c,%esp
  800f75:	5b                   	pop    %ebx
  800f76:	5e                   	pop    %esi
  800f77:	5f                   	pop    %edi
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    

00800f7a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
  800f80:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f88:	b8 09 00 00 00       	mov    $0x9,%eax
  800f8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f90:	8b 55 08             	mov    0x8(%ebp),%edx
  800f93:	89 df                	mov    %ebx,%edi
  800f95:	89 de                	mov    %ebx,%esi
  800f97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	7e 28                	jle    800fc5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb8:	00 
  800fb9:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  800fc0:	e8 d3 f3 ff ff       	call   800398 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc5:	83 c4 2c             	add    $0x2c,%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fe0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe6:	89 df                	mov    %ebx,%edi
  800fe8:	89 de                	mov    %ebx,%esi
  800fea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fec:	85 c0                	test   %eax,%eax
  800fee:	7e 28                	jle    801018 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  801003:	00 
  801004:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100b:	00 
  80100c:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801013:	e8 80 f3 ff ff       	call   800398 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801018:	83 c4 2c             	add    $0x2c,%esp
  80101b:	5b                   	pop    %ebx
  80101c:	5e                   	pop    %esi
  80101d:	5f                   	pop    %edi
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801026:	be 00 00 00 00       	mov    $0x0,%esi
  80102b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801030:	8b 7d 14             	mov    0x14(%ebp),%edi
  801033:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801036:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801039:	8b 55 08             	mov    0x8(%ebp),%edx
  80103c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801051:	b8 0d 00 00 00       	mov    $0xd,%eax
  801056:	8b 55 08             	mov    0x8(%ebp),%edx
  801059:	89 cb                	mov    %ecx,%ebx
  80105b:	89 cf                	mov    %ecx,%edi
  80105d:	89 ce                	mov    %ecx,%esi
  80105f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801061:	85 c0                	test   %eax,%eax
  801063:	7e 28                	jle    80108d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801065:	89 44 24 10          	mov    %eax,0x10(%esp)
  801069:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801070:	00 
  801071:	c7 44 24 08 1f 28 80 	movl   $0x80281f,0x8(%esp)
  801078:	00 
  801079:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801080:	00 
  801081:	c7 04 24 3c 28 80 00 	movl   $0x80283c,(%esp)
  801088:	e8 0b f3 ff ff       	call   800398 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80108d:	83 c4 2c             	add    $0x2c,%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    
  801095:	00 00                	add    %al,(%eax)
	...

00801098 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	8b 55 08             	mov    0x8(%ebp),%edx
  80109e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a1:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  8010a4:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  8010a6:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  8010a9:	83 3a 01             	cmpl   $0x1,(%edx)
  8010ac:	7e 0b                	jle    8010b9 <argstart+0x21>
  8010ae:	85 c9                	test   %ecx,%ecx
  8010b0:	75 0e                	jne    8010c0 <argstart+0x28>
  8010b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b7:	eb 0c                	jmp    8010c5 <argstart+0x2d>
  8010b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010be:	eb 05                	jmp    8010c5 <argstart+0x2d>
  8010c0:	ba c8 24 80 00       	mov    $0x8024c8,%edx
  8010c5:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  8010c8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <argnext>:

int
argnext(struct Argstate *args)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	53                   	push   %ebx
  8010d5:	83 ec 14             	sub    $0x14,%esp
  8010d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  8010db:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  8010e2:	8b 43 08             	mov    0x8(%ebx),%eax
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	74 6c                	je     801155 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  8010e9:	80 38 00             	cmpb   $0x0,(%eax)
  8010ec:	75 4d                	jne    80113b <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8010ee:	8b 0b                	mov    (%ebx),%ecx
  8010f0:	83 39 01             	cmpl   $0x1,(%ecx)
  8010f3:	74 52                	je     801147 <argnext+0x76>
		    || args->argv[1][0] != '-'
  8010f5:	8b 53 04             	mov    0x4(%ebx),%edx
  8010f8:	8b 42 04             	mov    0x4(%edx),%eax
  8010fb:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010fe:	75 47                	jne    801147 <argnext+0x76>
		    || args->argv[1][1] == '\0')
  801100:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801104:	74 41                	je     801147 <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801106:	40                   	inc    %eax
  801107:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80110a:	8b 01                	mov    (%ecx),%eax
  80110c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801113:	89 44 24 08          	mov    %eax,0x8(%esp)
  801117:	8d 42 08             	lea    0x8(%edx),%eax
  80111a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80111e:	83 c2 04             	add    $0x4,%edx
  801121:	89 14 24             	mov    %edx,(%esp)
  801124:	e8 8b fa ff ff       	call   800bb4 <memmove>
		(*args->argc)--;
  801129:	8b 03                	mov    (%ebx),%eax
  80112b:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80112d:	8b 43 08             	mov    0x8(%ebx),%eax
  801130:	80 38 2d             	cmpb   $0x2d,(%eax)
  801133:	75 06                	jne    80113b <argnext+0x6a>
  801135:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801139:	74 0c                	je     801147 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80113b:	8b 53 08             	mov    0x8(%ebx),%edx
  80113e:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801141:	42                   	inc    %edx
  801142:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801145:	eb 13                	jmp    80115a <argnext+0x89>

    endofargs:
	args->curarg = 0;
  801147:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80114e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801153:	eb 05                	jmp    80115a <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801155:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  80115a:	83 c4 14             	add    $0x14,%esp
  80115d:	5b                   	pop    %ebx
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	53                   	push   %ebx
  801164:	83 ec 14             	sub    $0x14,%esp
  801167:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  80116a:	8b 43 08             	mov    0x8(%ebx),%eax
  80116d:	85 c0                	test   %eax,%eax
  80116f:	74 59                	je     8011ca <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  801171:	80 38 00             	cmpb   $0x0,(%eax)
  801174:	74 0c                	je     801182 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801176:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801179:	c7 43 08 c8 24 80 00 	movl   $0x8024c8,0x8(%ebx)
  801180:	eb 43                	jmp    8011c5 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  801182:	8b 03                	mov    (%ebx),%eax
  801184:	83 38 01             	cmpl   $0x1,(%eax)
  801187:	7e 2e                	jle    8011b7 <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  801189:	8b 53 04             	mov    0x4(%ebx),%edx
  80118c:	8b 4a 04             	mov    0x4(%edx),%ecx
  80118f:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801192:	8b 00                	mov    (%eax),%eax
  801194:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80119b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80119f:	8d 42 08             	lea    0x8(%edx),%eax
  8011a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a6:	83 c2 04             	add    $0x4,%edx
  8011a9:	89 14 24             	mov    %edx,(%esp)
  8011ac:	e8 03 fa ff ff       	call   800bb4 <memmove>
		(*args->argc)--;
  8011b1:	8b 03                	mov    (%ebx),%eax
  8011b3:	ff 08                	decl   (%eax)
  8011b5:	eb 0e                	jmp    8011c5 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  8011b7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8011be:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8011c5:	8b 43 0c             	mov    0xc(%ebx),%eax
  8011c8:	eb 05                	jmp    8011cf <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8011cf:	83 c4 14             	add    $0x14,%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 18             	sub    $0x18,%esp
  8011db:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8011de:	8b 42 0c             	mov    0xc(%edx),%eax
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	75 08                	jne    8011ed <argvalue+0x18>
  8011e5:	89 14 24             	mov    %edx,(%esp)
  8011e8:	e8 73 ff ff ff       	call   801160 <argnextvalue>
}
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    
	...

008011f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801206:	8b 45 08             	mov    0x8(%ebp),%eax
  801209:	89 04 24             	mov    %eax,(%esp)
  80120c:	e8 df ff ff ff       	call   8011f0 <fd2num>
  801211:	05 20 00 0d 00       	add    $0xd0020,%eax
  801216:	c1 e0 0c             	shl    $0xc,%eax
}
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	53                   	push   %ebx
  80121f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801222:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801227:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801229:	89 c2                	mov    %eax,%edx
  80122b:	c1 ea 16             	shr    $0x16,%edx
  80122e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801235:	f6 c2 01             	test   $0x1,%dl
  801238:	74 11                	je     80124b <fd_alloc+0x30>
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	c1 ea 0c             	shr    $0xc,%edx
  80123f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801246:	f6 c2 01             	test   $0x1,%dl
  801249:	75 09                	jne    801254 <fd_alloc+0x39>
			*fd_store = fd;
  80124b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80124d:	b8 00 00 00 00       	mov    $0x0,%eax
  801252:	eb 17                	jmp    80126b <fd_alloc+0x50>
  801254:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801259:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80125e:	75 c7                	jne    801227 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801260:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801266:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80126b:	5b                   	pop    %ebx
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801274:	83 f8 1f             	cmp    $0x1f,%eax
  801277:	77 36                	ja     8012af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801279:	05 00 00 0d 00       	add    $0xd0000,%eax
  80127e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801281:	89 c2                	mov    %eax,%edx
  801283:	c1 ea 16             	shr    $0x16,%edx
  801286:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	74 24                	je     8012b6 <fd_lookup+0x48>
  801292:	89 c2                	mov    %eax,%edx
  801294:	c1 ea 0c             	shr    $0xc,%edx
  801297:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129e:	f6 c2 01             	test   $0x1,%dl
  8012a1:	74 1a                	je     8012bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ad:	eb 13                	jmp    8012c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b4:	eb 0c                	jmp    8012c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bb:	eb 05                	jmp    8012c2 <fd_lookup+0x54>
  8012bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 14             	sub    $0x14,%esp
  8012cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d6:	eb 0e                	jmp    8012e6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8012d8:	39 08                	cmp    %ecx,(%eax)
  8012da:	75 09                	jne    8012e5 <dev_lookup+0x21>
			*dev = devtab[i];
  8012dc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8012de:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e3:	eb 33                	jmp    801318 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e5:	42                   	inc    %edx
  8012e6:	8b 04 95 cc 28 80 00 	mov    0x8028cc(,%edx,4),%eax
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	75 e7                	jne    8012d8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f1:	a1 20 44 80 00       	mov    0x804420,%eax
  8012f6:	8b 40 48             	mov    0x48(%eax),%eax
  8012f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801301:	c7 04 24 4c 28 80 00 	movl   $0x80284c,(%esp)
  801308:	e8 83 f1 ff ff       	call   800490 <cprintf>
	*dev = 0;
  80130d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801318:	83 c4 14             	add    $0x14,%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	56                   	push   %esi
  801322:	53                   	push   %ebx
  801323:	83 ec 30             	sub    $0x30,%esp
  801326:	8b 75 08             	mov    0x8(%ebp),%esi
  801329:	8a 45 0c             	mov    0xc(%ebp),%al
  80132c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80132f:	89 34 24             	mov    %esi,(%esp)
  801332:	e8 b9 fe ff ff       	call   8011f0 <fd2num>
  801337:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80133a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80133e:	89 04 24             	mov    %eax,(%esp)
  801341:	e8 28 ff ff ff       	call   80126e <fd_lookup>
  801346:	89 c3                	mov    %eax,%ebx
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 05                	js     801351 <fd_close+0x33>
	    || fd != fd2)
  80134c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80134f:	74 0d                	je     80135e <fd_close+0x40>
		return (must_exist ? r : 0);
  801351:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801355:	75 46                	jne    80139d <fd_close+0x7f>
  801357:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135c:	eb 3f                	jmp    80139d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80135e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801361:	89 44 24 04          	mov    %eax,0x4(%esp)
  801365:	8b 06                	mov    (%esi),%eax
  801367:	89 04 24             	mov    %eax,(%esp)
  80136a:	e8 55 ff ff ff       	call   8012c4 <dev_lookup>
  80136f:	89 c3                	mov    %eax,%ebx
  801371:	85 c0                	test   %eax,%eax
  801373:	78 18                	js     80138d <fd_close+0x6f>
		if (dev->dev_close)
  801375:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801378:	8b 40 10             	mov    0x10(%eax),%eax
  80137b:	85 c0                	test   %eax,%eax
  80137d:	74 09                	je     801388 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80137f:	89 34 24             	mov    %esi,(%esp)
  801382:	ff d0                	call   *%eax
  801384:	89 c3                	mov    %eax,%ebx
  801386:	eb 05                	jmp    80138d <fd_close+0x6f>
		else
			r = 0;
  801388:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80138d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801391:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801398:	e8 37 fb ff ff       	call   800ed4 <sys_page_unmap>
	return r;
}
  80139d:	89 d8                	mov    %ebx,%eax
  80139f:	83 c4 30             	add    $0x30,%esp
  8013a2:	5b                   	pop    %ebx
  8013a3:	5e                   	pop    %esi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b6:	89 04 24             	mov    %eax,(%esp)
  8013b9:	e8 b0 fe ff ff       	call   80126e <fd_lookup>
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 13                	js     8013d5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8013c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8013c9:	00 
  8013ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cd:	89 04 24             	mov    %eax,(%esp)
  8013d0:	e8 49 ff ff ff       	call   80131e <fd_close>
}
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <close_all>:

void
close_all(void)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	53                   	push   %ebx
  8013db:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013de:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013e3:	89 1c 24             	mov    %ebx,(%esp)
  8013e6:	e8 bb ff ff ff       	call   8013a6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013eb:	43                   	inc    %ebx
  8013ec:	83 fb 20             	cmp    $0x20,%ebx
  8013ef:	75 f2                	jne    8013e3 <close_all+0xc>
		close(i);
}
  8013f1:	83 c4 14             	add    $0x14,%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	57                   	push   %edi
  8013fb:	56                   	push   %esi
  8013fc:	53                   	push   %ebx
  8013fd:	83 ec 4c             	sub    $0x4c,%esp
  801400:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801403:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801406:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140a:	8b 45 08             	mov    0x8(%ebp),%eax
  80140d:	89 04 24             	mov    %eax,(%esp)
  801410:	e8 59 fe ff ff       	call   80126e <fd_lookup>
  801415:	89 c3                	mov    %eax,%ebx
  801417:	85 c0                	test   %eax,%eax
  801419:	0f 88 e1 00 00 00    	js     801500 <dup+0x109>
		return r;
	close(newfdnum);
  80141f:	89 3c 24             	mov    %edi,(%esp)
  801422:	e8 7f ff ff ff       	call   8013a6 <close>

	newfd = INDEX2FD(newfdnum);
  801427:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80142d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801430:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801433:	89 04 24             	mov    %eax,(%esp)
  801436:	e8 c5 fd ff ff       	call   801200 <fd2data>
  80143b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80143d:	89 34 24             	mov    %esi,(%esp)
  801440:	e8 bb fd ff ff       	call   801200 <fd2data>
  801445:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801448:	89 d8                	mov    %ebx,%eax
  80144a:	c1 e8 16             	shr    $0x16,%eax
  80144d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801454:	a8 01                	test   $0x1,%al
  801456:	74 46                	je     80149e <dup+0xa7>
  801458:	89 d8                	mov    %ebx,%eax
  80145a:	c1 e8 0c             	shr    $0xc,%eax
  80145d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801464:	f6 c2 01             	test   $0x1,%dl
  801467:	74 35                	je     80149e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801469:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801470:	25 07 0e 00 00       	and    $0xe07,%eax
  801475:	89 44 24 10          	mov    %eax,0x10(%esp)
  801479:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80147c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801480:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801487:	00 
  801488:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80148c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801493:	e8 e9 f9 ff ff       	call   800e81 <sys_page_map>
  801498:	89 c3                	mov    %eax,%ebx
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 3b                	js     8014d9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a1:	89 c2                	mov    %eax,%edx
  8014a3:	c1 ea 0c             	shr    $0xc,%edx
  8014a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ad:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014b3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8014bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014c2:	00 
  8014c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ce:	e8 ae f9 ff ff       	call   800e81 <sys_page_map>
  8014d3:	89 c3                	mov    %eax,%ebx
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	79 25                	jns    8014fe <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e4:	e8 eb f9 ff ff       	call   800ed4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f7:	e8 d8 f9 ff ff       	call   800ed4 <sys_page_unmap>
	return r;
  8014fc:	eb 02                	jmp    801500 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014fe:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801500:	89 d8                	mov    %ebx,%eax
  801502:	83 c4 4c             	add    $0x4c,%esp
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5f                   	pop    %edi
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	53                   	push   %ebx
  80150e:	83 ec 24             	sub    $0x24,%esp
  801511:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801514:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151b:	89 1c 24             	mov    %ebx,(%esp)
  80151e:	e8 4b fd ff ff       	call   80126e <fd_lookup>
  801523:	85 c0                	test   %eax,%eax
  801525:	78 6d                	js     801594 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801527:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801531:	8b 00                	mov    (%eax),%eax
  801533:	89 04 24             	mov    %eax,(%esp)
  801536:	e8 89 fd ff ff       	call   8012c4 <dev_lookup>
  80153b:	85 c0                	test   %eax,%eax
  80153d:	78 55                	js     801594 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80153f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801542:	8b 50 08             	mov    0x8(%eax),%edx
  801545:	83 e2 03             	and    $0x3,%edx
  801548:	83 fa 01             	cmp    $0x1,%edx
  80154b:	75 23                	jne    801570 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80154d:	a1 20 44 80 00       	mov    0x804420,%eax
  801552:	8b 40 48             	mov    0x48(%eax),%eax
  801555:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155d:	c7 04 24 90 28 80 00 	movl   $0x802890,(%esp)
  801564:	e8 27 ef ff ff       	call   800490 <cprintf>
		return -E_INVAL;
  801569:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156e:	eb 24                	jmp    801594 <read+0x8a>
	}
	if (!dev->dev_read)
  801570:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801573:	8b 52 08             	mov    0x8(%edx),%edx
  801576:	85 d2                	test   %edx,%edx
  801578:	74 15                	je     80158f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80157a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80157d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801581:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801584:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801588:	89 04 24             	mov    %eax,(%esp)
  80158b:	ff d2                	call   *%edx
  80158d:	eb 05                	jmp    801594 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80158f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801594:	83 c4 24             	add    $0x24,%esp
  801597:	5b                   	pop    %ebx
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	57                   	push   %edi
  80159e:	56                   	push   %esi
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 1c             	sub    $0x1c,%esp
  8015a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ae:	eb 23                	jmp    8015d3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015b0:	89 f0                	mov    %esi,%eax
  8015b2:	29 d8                	sub    %ebx,%eax
  8015b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015bb:	01 d8                	add    %ebx,%eax
  8015bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c1:	89 3c 24             	mov    %edi,(%esp)
  8015c4:	e8 41 ff ff ff       	call   80150a <read>
		if (m < 0)
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 10                	js     8015dd <readn+0x43>
			return m;
		if (m == 0)
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	74 0a                	je     8015db <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d1:	01 c3                	add    %eax,%ebx
  8015d3:	39 f3                	cmp    %esi,%ebx
  8015d5:	72 d9                	jb     8015b0 <readn+0x16>
  8015d7:	89 d8                	mov    %ebx,%eax
  8015d9:	eb 02                	jmp    8015dd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015db:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015dd:	83 c4 1c             	add    $0x1c,%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5f                   	pop    %edi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	53                   	push   %ebx
  8015e9:	83 ec 24             	sub    $0x24,%esp
  8015ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f6:	89 1c 24             	mov    %ebx,(%esp)
  8015f9:	e8 70 fc ff ff       	call   80126e <fd_lookup>
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 68                	js     80166a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801602:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801605:	89 44 24 04          	mov    %eax,0x4(%esp)
  801609:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160c:	8b 00                	mov    (%eax),%eax
  80160e:	89 04 24             	mov    %eax,(%esp)
  801611:	e8 ae fc ff ff       	call   8012c4 <dev_lookup>
  801616:	85 c0                	test   %eax,%eax
  801618:	78 50                	js     80166a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801621:	75 23                	jne    801646 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801623:	a1 20 44 80 00       	mov    0x804420,%eax
  801628:	8b 40 48             	mov    0x48(%eax),%eax
  80162b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80162f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801633:	c7 04 24 ac 28 80 00 	movl   $0x8028ac,(%esp)
  80163a:	e8 51 ee ff ff       	call   800490 <cprintf>
		return -E_INVAL;
  80163f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801644:	eb 24                	jmp    80166a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801646:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801649:	8b 52 0c             	mov    0xc(%edx),%edx
  80164c:	85 d2                	test   %edx,%edx
  80164e:	74 15                	je     801665 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801650:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801653:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801657:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80165e:	89 04 24             	mov    %eax,(%esp)
  801661:	ff d2                	call   *%edx
  801663:	eb 05                	jmp    80166a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801665:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80166a:	83 c4 24             	add    $0x24,%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    

00801670 <seek>:

int
seek(int fdnum, off_t offset)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801676:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801679:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167d:	8b 45 08             	mov    0x8(%ebp),%eax
  801680:	89 04 24             	mov    %eax,(%esp)
  801683:	e8 e6 fb ff ff       	call   80126e <fd_lookup>
  801688:	85 c0                	test   %eax,%eax
  80168a:	78 0e                	js     80169a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80168c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80168f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801692:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 24             	sub    $0x24,%esp
  8016a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ad:	89 1c 24             	mov    %ebx,(%esp)
  8016b0:	e8 b9 fb ff ff       	call   80126e <fd_lookup>
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	78 61                	js     80171a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c3:	8b 00                	mov    (%eax),%eax
  8016c5:	89 04 24             	mov    %eax,(%esp)
  8016c8:	e8 f7 fb ff ff       	call   8012c4 <dev_lookup>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 49                	js     80171a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d8:	75 23                	jne    8016fd <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016da:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016df:	8b 40 48             	mov    0x48(%eax),%eax
  8016e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ea:	c7 04 24 6c 28 80 00 	movl   $0x80286c,(%esp)
  8016f1:	e8 9a ed ff ff       	call   800490 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016fb:	eb 1d                	jmp    80171a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8016fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801700:	8b 52 18             	mov    0x18(%edx),%edx
  801703:	85 d2                	test   %edx,%edx
  801705:	74 0e                	je     801715 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801707:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80170e:	89 04 24             	mov    %eax,(%esp)
  801711:	ff d2                	call   *%edx
  801713:	eb 05                	jmp    80171a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801715:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80171a:	83 c4 24             	add    $0x24,%esp
  80171d:	5b                   	pop    %ebx
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	83 ec 24             	sub    $0x24,%esp
  801727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801731:	8b 45 08             	mov    0x8(%ebp),%eax
  801734:	89 04 24             	mov    %eax,(%esp)
  801737:	e8 32 fb ff ff       	call   80126e <fd_lookup>
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 52                	js     801792 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801740:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801743:	89 44 24 04          	mov    %eax,0x4(%esp)
  801747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174a:	8b 00                	mov    (%eax),%eax
  80174c:	89 04 24             	mov    %eax,(%esp)
  80174f:	e8 70 fb ff ff       	call   8012c4 <dev_lookup>
  801754:	85 c0                	test   %eax,%eax
  801756:	78 3a                	js     801792 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80175f:	74 2c                	je     80178d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801761:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801764:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80176b:	00 00 00 
	stat->st_isdir = 0;
  80176e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801775:	00 00 00 
	stat->st_dev = dev;
  801778:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80177e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801782:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801785:	89 14 24             	mov    %edx,(%esp)
  801788:	ff 50 14             	call   *0x14(%eax)
  80178b:	eb 05                	jmp    801792 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80178d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801792:	83 c4 24             	add    $0x24,%esp
  801795:	5b                   	pop    %ebx
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017a7:	00 
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	89 04 24             	mov    %eax,(%esp)
  8017ae:	e8 fe 01 00 00       	call   8019b1 <open>
  8017b3:	89 c3                	mov    %eax,%ebx
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 1b                	js     8017d4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8017b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c0:	89 1c 24             	mov    %ebx,(%esp)
  8017c3:	e8 58 ff ff ff       	call   801720 <fstat>
  8017c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ca:	89 1c 24             	mov    %ebx,(%esp)
  8017cd:	e8 d4 fb ff ff       	call   8013a6 <close>
	return r;
  8017d2:	89 f3                	mov    %esi,%ebx
}
  8017d4:	89 d8                	mov    %ebx,%eax
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5e                   	pop    %esi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    
  8017dd:	00 00                	add    %al,(%eax)
	...

008017e0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	56                   	push   %esi
  8017e4:	53                   	push   %ebx
  8017e5:	83 ec 10             	sub    $0x10,%esp
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017ec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017f3:	75 11                	jne    801806 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017fc:	e8 72 09 00 00       	call   802173 <ipc_find_env>
  801801:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801806:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80180d:	00 
  80180e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801815:	00 
  801816:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80181a:	a1 00 40 80 00       	mov    0x804000,%eax
  80181f:	89 04 24             	mov    %eax,(%esp)
  801822:	e8 e2 08 00 00       	call   802109 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801827:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80182e:	00 
  80182f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801833:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80183a:	e8 61 08 00 00       	call   8020a0 <ipc_recv>
}
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80184c:	8b 45 08             	mov    0x8(%ebp),%eax
  80184f:	8b 40 0c             	mov    0xc(%eax),%eax
  801852:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
  801864:	b8 02 00 00 00       	mov    $0x2,%eax
  801869:	e8 72 ff ff ff       	call   8017e0 <fsipc>
}
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 40 0c             	mov    0xc(%eax),%eax
  80187c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801881:	ba 00 00 00 00       	mov    $0x0,%edx
  801886:	b8 06 00 00 00       	mov    $0x6,%eax
  80188b:	e8 50 ff ff ff       	call   8017e0 <fsipc>
}
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	53                   	push   %ebx
  801896:	83 ec 14             	sub    $0x14,%esp
  801899:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80189c:	8b 45 08             	mov    0x8(%ebp),%eax
  80189f:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b1:	e8 2a ff ff ff       	call   8017e0 <fsipc>
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 2b                	js     8018e5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ba:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018c1:	00 
  8018c2:	89 1c 24             	mov    %ebx,(%esp)
  8018c5:	e8 71 f1 ff ff       	call   800a3b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ca:	a1 80 50 80 00       	mov    0x805080,%eax
  8018cf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018d5:	a1 84 50 80 00       	mov    0x805084,%eax
  8018da:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e5:	83 c4 14             	add    $0x14,%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8018f1:	c7 44 24 08 dc 28 80 	movl   $0x8028dc,0x8(%esp)
  8018f8:	00 
  8018f9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801900:	00 
  801901:	c7 04 24 fa 28 80 00 	movl   $0x8028fa,(%esp)
  801908:	e8 8b ea ff ff       	call   800398 <_panic>

0080190d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	83 ec 10             	sub    $0x10,%esp
  801915:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801918:	8b 45 08             	mov    0x8(%ebp),%eax
  80191b:	8b 40 0c             	mov    0xc(%eax),%eax
  80191e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801923:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801929:	ba 00 00 00 00       	mov    $0x0,%edx
  80192e:	b8 03 00 00 00       	mov    $0x3,%eax
  801933:	e8 a8 fe ff ff       	call   8017e0 <fsipc>
  801938:	89 c3                	mov    %eax,%ebx
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 6a                	js     8019a8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80193e:	39 c6                	cmp    %eax,%esi
  801940:	73 24                	jae    801966 <devfile_read+0x59>
  801942:	c7 44 24 0c 05 29 80 	movl   $0x802905,0xc(%esp)
  801949:	00 
  80194a:	c7 44 24 08 0c 29 80 	movl   $0x80290c,0x8(%esp)
  801951:	00 
  801952:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801959:	00 
  80195a:	c7 04 24 fa 28 80 00 	movl   $0x8028fa,(%esp)
  801961:	e8 32 ea ff ff       	call   800398 <_panic>
	assert(r <= PGSIZE);
  801966:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80196b:	7e 24                	jle    801991 <devfile_read+0x84>
  80196d:	c7 44 24 0c 21 29 80 	movl   $0x802921,0xc(%esp)
  801974:	00 
  801975:	c7 44 24 08 0c 29 80 	movl   $0x80290c,0x8(%esp)
  80197c:	00 
  80197d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801984:	00 
  801985:	c7 04 24 fa 28 80 00 	movl   $0x8028fa,(%esp)
  80198c:	e8 07 ea ff ff       	call   800398 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801991:	89 44 24 08          	mov    %eax,0x8(%esp)
  801995:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80199c:	00 
  80199d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a0:	89 04 24             	mov    %eax,(%esp)
  8019a3:	e8 0c f2 ff ff       	call   800bb4 <memmove>
	return r;
}
  8019a8:	89 d8                	mov    %ebx,%eax
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	5b                   	pop    %ebx
  8019ae:	5e                   	pop    %esi
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    

008019b1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	83 ec 20             	sub    $0x20,%esp
  8019b9:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019bc:	89 34 24             	mov    %esi,(%esp)
  8019bf:	e8 44 f0 ff ff       	call   800a08 <strlen>
  8019c4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c9:	7f 60                	jg     801a2b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ce:	89 04 24             	mov    %eax,(%esp)
  8019d1:	e8 45 f8 ff ff       	call   80121b <fd_alloc>
  8019d6:	89 c3                	mov    %eax,%ebx
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 54                	js     801a30 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019e0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019e7:	e8 4f f0 ff ff       	call   800a3b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ef:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fc:	e8 df fd ff ff       	call   8017e0 <fsipc>
  801a01:	89 c3                	mov    %eax,%ebx
  801a03:	85 c0                	test   %eax,%eax
  801a05:	79 15                	jns    801a1c <open+0x6b>
		fd_close(fd, 0);
  801a07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a0e:	00 
  801a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 04 f9 ff ff       	call   80131e <fd_close>
		return r;
  801a1a:	eb 14                	jmp    801a30 <open+0x7f>
	}

	return fd2num(fd);
  801a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1f:	89 04 24             	mov    %eax,(%esp)
  801a22:	e8 c9 f7 ff ff       	call   8011f0 <fd2num>
  801a27:	89 c3                	mov    %eax,%ebx
  801a29:	eb 05                	jmp    801a30 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a2b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a30:	89 d8                	mov    %ebx,%eax
  801a32:	83 c4 20             	add    $0x20,%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a44:	b8 08 00 00 00       	mov    $0x8,%eax
  801a49:	e8 92 fd ff ff       	call   8017e0 <fsipc>
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	53                   	push   %ebx
  801a54:	83 ec 14             	sub    $0x14,%esp
  801a57:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801a59:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a5d:	7e 32                	jle    801a91 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a5f:	8b 40 04             	mov    0x4(%eax),%eax
  801a62:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a66:	8d 43 10             	lea    0x10(%ebx),%eax
  801a69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6d:	8b 03                	mov    (%ebx),%eax
  801a6f:	89 04 24             	mov    %eax,(%esp)
  801a72:	e8 6e fb ff ff       	call   8015e5 <write>
		if (result > 0)
  801a77:	85 c0                	test   %eax,%eax
  801a79:	7e 03                	jle    801a7e <writebuf+0x2e>
			b->result += result;
  801a7b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a7e:	39 43 04             	cmp    %eax,0x4(%ebx)
  801a81:	74 0e                	je     801a91 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801a83:	89 c2                	mov    %eax,%edx
  801a85:	85 c0                	test   %eax,%eax
  801a87:	7e 05                	jle    801a8e <writebuf+0x3e>
  801a89:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8e:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801a91:	83 c4 14             	add    $0x14,%esp
  801a94:	5b                   	pop    %ebx
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <putch>:

static void
putch(int ch, void *thunk)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	53                   	push   %ebx
  801a9b:	83 ec 04             	sub    $0x4,%esp
  801a9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801aa1:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa4:	8b 55 08             	mov    0x8(%ebp),%edx
  801aa7:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801aab:	40                   	inc    %eax
  801aac:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801aaf:	3d 00 01 00 00       	cmp    $0x100,%eax
  801ab4:	75 0e                	jne    801ac4 <putch+0x2d>
		writebuf(b);
  801ab6:	89 d8                	mov    %ebx,%eax
  801ab8:	e8 93 ff ff ff       	call   801a50 <writebuf>
		b->idx = 0;
  801abd:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801ac4:	83 c4 04             	add    $0x4,%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad6:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801adc:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801ae3:	00 00 00 
	b.result = 0;
  801ae6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801aed:	00 00 00 
	b.error = 1;
  801af0:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801af7:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801afa:	8b 45 10             	mov    0x10(%ebp),%eax
  801afd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b04:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b08:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b12:	c7 04 24 97 1a 80 00 	movl   $0x801a97,(%esp)
  801b19:	e8 d4 ea ff ff       	call   8005f2 <vprintfmt>
	if (b.idx > 0)
  801b1e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801b25:	7e 0b                	jle    801b32 <vfprintf+0x68>
		writebuf(&b);
  801b27:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b2d:	e8 1e ff ff ff       	call   801a50 <writebuf>

	return (b.result ? b.result : b.error);
  801b32:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	75 06                	jne    801b42 <vfprintf+0x78>
  801b3c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b4a:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801b4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b58:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5b:	89 04 24             	mov    %eax,(%esp)
  801b5e:	e8 67 ff ff ff       	call   801aca <vfprintf>
	va_end(ap);

	return cnt;
}
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <printf>:

int
printf(const char *fmt, ...)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b6b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b72:	8b 45 08             	mov    0x8(%ebp),%eax
  801b75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b80:	e8 45 ff ff ff       	call   801aca <vfprintf>
	va_end(ap);

	return cnt;
}
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    
	...

00801b88 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 10             	sub    $0x10,%esp
  801b90:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b93:	8b 45 08             	mov    0x8(%ebp),%eax
  801b96:	89 04 24             	mov    %eax,(%esp)
  801b99:	e8 62 f6 ff ff       	call   801200 <fd2data>
  801b9e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ba0:	c7 44 24 04 2d 29 80 	movl   $0x80292d,0x4(%esp)
  801ba7:	00 
  801ba8:	89 34 24             	mov    %esi,(%esp)
  801bab:	e8 8b ee ff ff       	call   800a3b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bb0:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb3:	2b 03                	sub    (%ebx),%eax
  801bb5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801bbb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801bc2:	00 00 00 
	stat->st_dev = &devpipe;
  801bc5:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801bcc:	30 80 00 
	return 0;
}
  801bcf:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	5b                   	pop    %ebx
  801bd8:	5e                   	pop    %esi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	53                   	push   %ebx
  801bdf:	83 ec 14             	sub    $0x14,%esp
  801be2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801be5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801be9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf0:	e8 df f2 ff ff       	call   800ed4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bf5:	89 1c 24             	mov    %ebx,(%esp)
  801bf8:	e8 03 f6 ff ff       	call   801200 <fd2data>
  801bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c08:	e8 c7 f2 ff ff       	call   800ed4 <sys_page_unmap>
}
  801c0d:	83 c4 14             	add    $0x14,%esp
  801c10:	5b                   	pop    %ebx
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    

00801c13 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	57                   	push   %edi
  801c17:	56                   	push   %esi
  801c18:	53                   	push   %ebx
  801c19:	83 ec 2c             	sub    $0x2c,%esp
  801c1c:	89 c7                	mov    %eax,%edi
  801c1e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c21:	a1 20 44 80 00       	mov    0x804420,%eax
  801c26:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c29:	89 3c 24             	mov    %edi,(%esp)
  801c2c:	e8 87 05 00 00       	call   8021b8 <pageref>
  801c31:	89 c6                	mov    %eax,%esi
  801c33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c36:	89 04 24             	mov    %eax,(%esp)
  801c39:	e8 7a 05 00 00       	call   8021b8 <pageref>
  801c3e:	39 c6                	cmp    %eax,%esi
  801c40:	0f 94 c0             	sete   %al
  801c43:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c46:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801c4c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c4f:	39 cb                	cmp    %ecx,%ebx
  801c51:	75 08                	jne    801c5b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c53:	83 c4 2c             	add    $0x2c,%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5f                   	pop    %edi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c5b:	83 f8 01             	cmp    $0x1,%eax
  801c5e:	75 c1                	jne    801c21 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c60:	8b 42 58             	mov    0x58(%edx),%eax
  801c63:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c6a:	00 
  801c6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c73:	c7 04 24 34 29 80 00 	movl   $0x802934,(%esp)
  801c7a:	e8 11 e8 ff ff       	call   800490 <cprintf>
  801c7f:	eb a0                	jmp    801c21 <_pipeisclosed+0xe>

00801c81 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	57                   	push   %edi
  801c85:	56                   	push   %esi
  801c86:	53                   	push   %ebx
  801c87:	83 ec 1c             	sub    $0x1c,%esp
  801c8a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c8d:	89 34 24             	mov    %esi,(%esp)
  801c90:	e8 6b f5 ff ff       	call   801200 <fd2data>
  801c95:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c97:	bf 00 00 00 00       	mov    $0x0,%edi
  801c9c:	eb 3c                	jmp    801cda <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c9e:	89 da                	mov    %ebx,%edx
  801ca0:	89 f0                	mov    %esi,%eax
  801ca2:	e8 6c ff ff ff       	call   801c13 <_pipeisclosed>
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	75 38                	jne    801ce3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cab:	e8 5e f1 ff ff       	call   800e0e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cb0:	8b 43 04             	mov    0x4(%ebx),%eax
  801cb3:	8b 13                	mov    (%ebx),%edx
  801cb5:	83 c2 20             	add    $0x20,%edx
  801cb8:	39 d0                	cmp    %edx,%eax
  801cba:	73 e2                	jae    801c9e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cbf:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801cc2:	89 c2                	mov    %eax,%edx
  801cc4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801cca:	79 05                	jns    801cd1 <devpipe_write+0x50>
  801ccc:	4a                   	dec    %edx
  801ccd:	83 ca e0             	or     $0xffffffe0,%edx
  801cd0:	42                   	inc    %edx
  801cd1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cd5:	40                   	inc    %eax
  801cd6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cd9:	47                   	inc    %edi
  801cda:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cdd:	75 d1                	jne    801cb0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cdf:	89 f8                	mov    %edi,%eax
  801ce1:	eb 05                	jmp    801ce8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ce3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ce8:	83 c4 1c             	add    $0x1c,%esp
  801ceb:	5b                   	pop    %ebx
  801cec:	5e                   	pop    %esi
  801ced:	5f                   	pop    %edi
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	57                   	push   %edi
  801cf4:	56                   	push   %esi
  801cf5:	53                   	push   %ebx
  801cf6:	83 ec 1c             	sub    $0x1c,%esp
  801cf9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cfc:	89 3c 24             	mov    %edi,(%esp)
  801cff:	e8 fc f4 ff ff       	call   801200 <fd2data>
  801d04:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d06:	be 00 00 00 00       	mov    $0x0,%esi
  801d0b:	eb 3a                	jmp    801d47 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d0d:	85 f6                	test   %esi,%esi
  801d0f:	74 04                	je     801d15 <devpipe_read+0x25>
				return i;
  801d11:	89 f0                	mov    %esi,%eax
  801d13:	eb 40                	jmp    801d55 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d15:	89 da                	mov    %ebx,%edx
  801d17:	89 f8                	mov    %edi,%eax
  801d19:	e8 f5 fe ff ff       	call   801c13 <_pipeisclosed>
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	75 2e                	jne    801d50 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d22:	e8 e7 f0 ff ff       	call   800e0e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d27:	8b 03                	mov    (%ebx),%eax
  801d29:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d2c:	74 df                	je     801d0d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d2e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d33:	79 05                	jns    801d3a <devpipe_read+0x4a>
  801d35:	48                   	dec    %eax
  801d36:	83 c8 e0             	or     $0xffffffe0,%eax
  801d39:	40                   	inc    %eax
  801d3a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d41:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d44:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d46:	46                   	inc    %esi
  801d47:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d4a:	75 db                	jne    801d27 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d4c:	89 f0                	mov    %esi,%eax
  801d4e:	eb 05                	jmp    801d55 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d50:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d55:	83 c4 1c             	add    $0x1c,%esp
  801d58:	5b                   	pop    %ebx
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    

00801d5d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	57                   	push   %edi
  801d61:	56                   	push   %esi
  801d62:	53                   	push   %ebx
  801d63:	83 ec 3c             	sub    $0x3c,%esp
  801d66:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d69:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d6c:	89 04 24             	mov    %eax,(%esp)
  801d6f:	e8 a7 f4 ff ff       	call   80121b <fd_alloc>
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	85 c0                	test   %eax,%eax
  801d78:	0f 88 45 01 00 00    	js     801ec3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d85:	00 
  801d86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d94:	e8 94 f0 ff ff       	call   800e2d <sys_page_alloc>
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	0f 88 20 01 00 00    	js     801ec3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801da3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801da6:	89 04 24             	mov    %eax,(%esp)
  801da9:	e8 6d f4 ff ff       	call   80121b <fd_alloc>
  801dae:	89 c3                	mov    %eax,%ebx
  801db0:	85 c0                	test   %eax,%eax
  801db2:	0f 88 f8 00 00 00    	js     801eb0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dbf:	00 
  801dc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801dc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dce:	e8 5a f0 ff ff       	call   800e2d <sys_page_alloc>
  801dd3:	89 c3                	mov    %eax,%ebx
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	0f 88 d3 00 00 00    	js     801eb0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ddd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801de0:	89 04 24             	mov    %eax,(%esp)
  801de3:	e8 18 f4 ff ff       	call   801200 <fd2data>
  801de8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dea:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801df1:	00 
  801df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dfd:	e8 2b f0 ff ff       	call   800e2d <sys_page_alloc>
  801e02:	89 c3                	mov    %eax,%ebx
  801e04:	85 c0                	test   %eax,%eax
  801e06:	0f 88 91 00 00 00    	js     801e9d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e0f:	89 04 24             	mov    %eax,(%esp)
  801e12:	e8 e9 f3 ff ff       	call   801200 <fd2data>
  801e17:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e1e:	00 
  801e1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e23:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e2a:	00 
  801e2b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e36:	e8 46 f0 ff ff       	call   800e81 <sys_page_map>
  801e3b:	89 c3                	mov    %eax,%ebx
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	78 4c                	js     801e8d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e41:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e4a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e4f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e56:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e5f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e61:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e64:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 7a f3 ff ff       	call   8011f0 <fd2num>
  801e76:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e7b:	89 04 24             	mov    %eax,(%esp)
  801e7e:	e8 6d f3 ff ff       	call   8011f0 <fd2num>
  801e83:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e86:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e8b:	eb 36                	jmp    801ec3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801e8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e98:	e8 37 f0 ff ff       	call   800ed4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801e9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eab:	e8 24 f0 ff ff       	call   800ed4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801eb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebe:	e8 11 f0 ff ff       	call   800ed4 <sys_page_unmap>
    err:
	return r;
}
  801ec3:	89 d8                	mov    %ebx,%eax
  801ec5:	83 c4 3c             	add    $0x3c,%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    

00801ecd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eda:	8b 45 08             	mov    0x8(%ebp),%eax
  801edd:	89 04 24             	mov    %eax,(%esp)
  801ee0:	e8 89 f3 ff ff       	call   80126e <fd_lookup>
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 15                	js     801efe <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eec:	89 04 24             	mov    %eax,(%esp)
  801eef:	e8 0c f3 ff ff       	call   801200 <fd2data>
	return _pipeisclosed(fd, p);
  801ef4:	89 c2                	mov    %eax,%edx
  801ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef9:	e8 15 fd ff ff       	call   801c13 <_pipeisclosed>
}
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    

00801f0a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f10:	c7 44 24 04 4c 29 80 	movl   $0x80294c,0x4(%esp)
  801f17:	00 
  801f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1b:	89 04 24             	mov    %eax,(%esp)
  801f1e:	e8 18 eb ff ff       	call   800a3b <strcpy>
	return 0;
}
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	57                   	push   %edi
  801f2e:	56                   	push   %esi
  801f2f:	53                   	push   %ebx
  801f30:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f36:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f3b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f41:	eb 30                	jmp    801f73 <devcons_write+0x49>
		m = n - tot;
  801f43:	8b 75 10             	mov    0x10(%ebp),%esi
  801f46:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f48:	83 fe 7f             	cmp    $0x7f,%esi
  801f4b:	76 05                	jbe    801f52 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f4d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f52:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f56:	03 45 0c             	add    0xc(%ebp),%eax
  801f59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5d:	89 3c 24             	mov    %edi,(%esp)
  801f60:	e8 4f ec ff ff       	call   800bb4 <memmove>
		sys_cputs(buf, m);
  801f65:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f69:	89 3c 24             	mov    %edi,(%esp)
  801f6c:	e8 ef ed ff ff       	call   800d60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f71:	01 f3                	add    %esi,%ebx
  801f73:	89 d8                	mov    %ebx,%eax
  801f75:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f78:	72 c9                	jb     801f43 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f7a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801f80:	5b                   	pop    %ebx
  801f81:	5e                   	pop    %esi
  801f82:	5f                   	pop    %edi
  801f83:	5d                   	pop    %ebp
  801f84:	c3                   	ret    

00801f85 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f8b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f8f:	75 07                	jne    801f98 <devcons_read+0x13>
  801f91:	eb 25                	jmp    801fb8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f93:	e8 76 ee ff ff       	call   800e0e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f98:	e8 e1 ed ff ff       	call   800d7e <sys_cgetc>
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	74 f2                	je     801f93 <devcons_read+0xe>
  801fa1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	78 1d                	js     801fc4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fa7:	83 f8 04             	cmp    $0x4,%eax
  801faa:	74 13                	je     801fbf <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801fac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801faf:	88 10                	mov    %dl,(%eax)
	return 1;
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	eb 0c                	jmp    801fc4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbd:	eb 05                	jmp    801fc4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fbf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fc4:	c9                   	leave  
  801fc5:	c3                   	ret    

00801fc6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fd2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801fd9:	00 
  801fda:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fdd:	89 04 24             	mov    %eax,(%esp)
  801fe0:	e8 7b ed ff ff       	call   800d60 <sys_cputs>
}
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    

00801fe7 <getchar>:

int
getchar(void)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ff4:	00 
  801ff5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802003:	e8 02 f5 ff ff       	call   80150a <read>
	if (r < 0)
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 0f                	js     80201b <getchar+0x34>
		return r;
	if (r < 1)
  80200c:	85 c0                	test   %eax,%eax
  80200e:	7e 06                	jle    802016 <getchar+0x2f>
		return -E_EOF;
	return c;
  802010:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802014:	eb 05                	jmp    80201b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802016:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80201b:	c9                   	leave  
  80201c:	c3                   	ret    

0080201d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802023:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802026:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202a:	8b 45 08             	mov    0x8(%ebp),%eax
  80202d:	89 04 24             	mov    %eax,(%esp)
  802030:	e8 39 f2 ff ff       	call   80126e <fd_lookup>
  802035:	85 c0                	test   %eax,%eax
  802037:	78 11                	js     80204a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802039:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802042:	39 10                	cmp    %edx,(%eax)
  802044:	0f 94 c0             	sete   %al
  802047:	0f b6 c0             	movzbl %al,%eax
}
  80204a:	c9                   	leave  
  80204b:	c3                   	ret    

0080204c <opencons>:

int
opencons(void)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
  80204f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802052:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802055:	89 04 24             	mov    %eax,(%esp)
  802058:	e8 be f1 ff ff       	call   80121b <fd_alloc>
  80205d:	85 c0                	test   %eax,%eax
  80205f:	78 3c                	js     80209d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802061:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802068:	00 
  802069:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802070:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802077:	e8 b1 ed ff ff       	call   800e2d <sys_page_alloc>
  80207c:	85 c0                	test   %eax,%eax
  80207e:	78 1d                	js     80209d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802080:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802086:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802089:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80208b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802095:	89 04 24             	mov    %eax,(%esp)
  802098:	e8 53 f1 ff ff       	call   8011f0 <fd2num>
}
  80209d:	c9                   	leave  
  80209e:	c3                   	ret    
	...

008020a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	57                   	push   %edi
  8020a4:	56                   	push   %esi
  8020a5:	53                   	push   %ebx
  8020a6:	83 ec 1c             	sub    $0x1c,%esp
  8020a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8020ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020af:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  8020b2:	85 db                	test   %ebx,%ebx
  8020b4:	75 05                	jne    8020bb <ipc_recv+0x1b>
		pg = (void *)UTOP;
  8020b6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8020bb:	89 1c 24             	mov    %ebx,(%esp)
  8020be:	e8 80 ef ff ff       	call   801043 <sys_ipc_recv>
  8020c3:	85 c0                	test   %eax,%eax
  8020c5:	79 16                	jns    8020dd <ipc_recv+0x3d>
		*from_env_store = 0;
  8020c7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  8020cd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  8020d3:	89 1c 24             	mov    %ebx,(%esp)
  8020d6:	e8 68 ef ff ff       	call   801043 <sys_ipc_recv>
  8020db:	eb 24                	jmp    802101 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  8020dd:	85 f6                	test   %esi,%esi
  8020df:	74 0a                	je     8020eb <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8020e1:	a1 20 44 80 00       	mov    0x804420,%eax
  8020e6:	8b 40 74             	mov    0x74(%eax),%eax
  8020e9:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8020eb:	85 ff                	test   %edi,%edi
  8020ed:	74 0a                	je     8020f9 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8020ef:	a1 20 44 80 00       	mov    0x804420,%eax
  8020f4:	8b 40 78             	mov    0x78(%eax),%eax
  8020f7:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  8020f9:	a1 20 44 80 00       	mov    0x804420,%eax
  8020fe:	8b 40 70             	mov    0x70(%eax),%eax
}
  802101:	83 c4 1c             	add    $0x1c,%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    

00802109 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802109:	55                   	push   %ebp
  80210a:	89 e5                	mov    %esp,%ebp
  80210c:	57                   	push   %edi
  80210d:	56                   	push   %esi
  80210e:	53                   	push   %ebx
  80210f:	83 ec 1c             	sub    $0x1c,%esp
  802112:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802115:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802118:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  80211b:	85 db                	test   %ebx,%ebx
  80211d:	75 05                	jne    802124 <ipc_send+0x1b>
		pg = (void *)-1;
  80211f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802124:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802128:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80212c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802130:	8b 45 08             	mov    0x8(%ebp),%eax
  802133:	89 04 24             	mov    %eax,(%esp)
  802136:	e8 e5 ee ff ff       	call   801020 <sys_ipc_try_send>
		if (r == 0) {		
  80213b:	85 c0                	test   %eax,%eax
  80213d:	74 2c                	je     80216b <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80213f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802142:	75 07                	jne    80214b <ipc_send+0x42>
			sys_yield();
  802144:	e8 c5 ec ff ff       	call   800e0e <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  802149:	eb d9                	jmp    802124 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  80214b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214f:	c7 44 24 08 58 29 80 	movl   $0x802958,0x8(%esp)
  802156:	00 
  802157:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80215e:	00 
  80215f:	c7 04 24 66 29 80 00 	movl   $0x802966,(%esp)
  802166:	e8 2d e2 ff ff       	call   800398 <_panic>
		}
	}
}
  80216b:	83 c4 1c             	add    $0x1c,%esp
  80216e:	5b                   	pop    %ebx
  80216f:	5e                   	pop    %esi
  802170:	5f                   	pop    %edi
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    

00802173 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	53                   	push   %ebx
  802177:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80217a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80217f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802186:	89 c2                	mov    %eax,%edx
  802188:	c1 e2 07             	shl    $0x7,%edx
  80218b:	29 ca                	sub    %ecx,%edx
  80218d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802193:	8b 52 50             	mov    0x50(%edx),%edx
  802196:	39 da                	cmp    %ebx,%edx
  802198:	75 0f                	jne    8021a9 <ipc_find_env+0x36>
			return envs[i].env_id;
  80219a:	c1 e0 07             	shl    $0x7,%eax
  80219d:	29 c8                	sub    %ecx,%eax
  80219f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021a4:	8b 40 40             	mov    0x40(%eax),%eax
  8021a7:	eb 0c                	jmp    8021b5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021a9:	40                   	inc    %eax
  8021aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021af:	75 ce                	jne    80217f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021b1:	66 b8 00 00          	mov    $0x0,%ax
}
  8021b5:	5b                   	pop    %ebx
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    

008021b8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021be:	89 c2                	mov    %eax,%edx
  8021c0:	c1 ea 16             	shr    $0x16,%edx
  8021c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021ca:	f6 c2 01             	test   $0x1,%dl
  8021cd:	74 1e                	je     8021ed <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021cf:	c1 e8 0c             	shr    $0xc,%eax
  8021d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021d9:	a8 01                	test   $0x1,%al
  8021db:	74 17                	je     8021f4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021dd:	c1 e8 0c             	shr    $0xc,%eax
  8021e0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8021e7:	ef 
  8021e8:	0f b7 c0             	movzwl %ax,%eax
  8021eb:	eb 0c                	jmp    8021f9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8021ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f2:	eb 05                	jmp    8021f9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8021f4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8021f9:	5d                   	pop    %ebp
  8021fa:	c3                   	ret    
	...

008021fc <__udivdi3>:
  8021fc:	55                   	push   %ebp
  8021fd:	57                   	push   %edi
  8021fe:	56                   	push   %esi
  8021ff:	83 ec 10             	sub    $0x10,%esp
  802202:	8b 74 24 20          	mov    0x20(%esp),%esi
  802206:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80220a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802212:	89 cd                	mov    %ecx,%ebp
  802214:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  802218:	85 c0                	test   %eax,%eax
  80221a:	75 2c                	jne    802248 <__udivdi3+0x4c>
  80221c:	39 f9                	cmp    %edi,%ecx
  80221e:	77 68                	ja     802288 <__udivdi3+0x8c>
  802220:	85 c9                	test   %ecx,%ecx
  802222:	75 0b                	jne    80222f <__udivdi3+0x33>
  802224:	b8 01 00 00 00       	mov    $0x1,%eax
  802229:	31 d2                	xor    %edx,%edx
  80222b:	f7 f1                	div    %ecx
  80222d:	89 c1                	mov    %eax,%ecx
  80222f:	31 d2                	xor    %edx,%edx
  802231:	89 f8                	mov    %edi,%eax
  802233:	f7 f1                	div    %ecx
  802235:	89 c7                	mov    %eax,%edi
  802237:	89 f0                	mov    %esi,%eax
  802239:	f7 f1                	div    %ecx
  80223b:	89 c6                	mov    %eax,%esi
  80223d:	89 f0                	mov    %esi,%eax
  80223f:	89 fa                	mov    %edi,%edx
  802241:	83 c4 10             	add    $0x10,%esp
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	39 f8                	cmp    %edi,%eax
  80224a:	77 2c                	ja     802278 <__udivdi3+0x7c>
  80224c:	0f bd f0             	bsr    %eax,%esi
  80224f:	83 f6 1f             	xor    $0x1f,%esi
  802252:	75 4c                	jne    8022a0 <__udivdi3+0xa4>
  802254:	39 f8                	cmp    %edi,%eax
  802256:	bf 00 00 00 00       	mov    $0x0,%edi
  80225b:	72 0a                	jb     802267 <__udivdi3+0x6b>
  80225d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802261:	0f 87 ad 00 00 00    	ja     802314 <__udivdi3+0x118>
  802267:	be 01 00 00 00       	mov    $0x1,%esi
  80226c:	89 f0                	mov    %esi,%eax
  80226e:	89 fa                	mov    %edi,%edx
  802270:	83 c4 10             	add    $0x10,%esp
  802273:	5e                   	pop    %esi
  802274:	5f                   	pop    %edi
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    
  802277:	90                   	nop
  802278:	31 ff                	xor    %edi,%edi
  80227a:	31 f6                	xor    %esi,%esi
  80227c:	89 f0                	mov    %esi,%eax
  80227e:	89 fa                	mov    %edi,%edx
  802280:	83 c4 10             	add    $0x10,%esp
  802283:	5e                   	pop    %esi
  802284:	5f                   	pop    %edi
  802285:	5d                   	pop    %ebp
  802286:	c3                   	ret    
  802287:	90                   	nop
  802288:	89 fa                	mov    %edi,%edx
  80228a:	89 f0                	mov    %esi,%eax
  80228c:	f7 f1                	div    %ecx
  80228e:	89 c6                	mov    %eax,%esi
  802290:	31 ff                	xor    %edi,%edi
  802292:	89 f0                	mov    %esi,%eax
  802294:	89 fa                	mov    %edi,%edx
  802296:	83 c4 10             	add    $0x10,%esp
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	89 f1                	mov    %esi,%ecx
  8022a2:	d3 e0                	shl    %cl,%eax
  8022a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022a8:	b8 20 00 00 00       	mov    $0x20,%eax
  8022ad:	29 f0                	sub    %esi,%eax
  8022af:	89 ea                	mov    %ebp,%edx
  8022b1:	88 c1                	mov    %al,%cl
  8022b3:	d3 ea                	shr    %cl,%edx
  8022b5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022b9:	09 ca                	or     %ecx,%edx
  8022bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022bf:	89 f1                	mov    %esi,%ecx
  8022c1:	d3 e5                	shl    %cl,%ebp
  8022c3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8022c7:	89 fd                	mov    %edi,%ebp
  8022c9:	88 c1                	mov    %al,%cl
  8022cb:	d3 ed                	shr    %cl,%ebp
  8022cd:	89 fa                	mov    %edi,%edx
  8022cf:	89 f1                	mov    %esi,%ecx
  8022d1:	d3 e2                	shl    %cl,%edx
  8022d3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8022d7:	88 c1                	mov    %al,%cl
  8022d9:	d3 ef                	shr    %cl,%edi
  8022db:	09 d7                	or     %edx,%edi
  8022dd:	89 f8                	mov    %edi,%eax
  8022df:	89 ea                	mov    %ebp,%edx
  8022e1:	f7 74 24 08          	divl   0x8(%esp)
  8022e5:	89 d1                	mov    %edx,%ecx
  8022e7:	89 c7                	mov    %eax,%edi
  8022e9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ed:	39 d1                	cmp    %edx,%ecx
  8022ef:	72 17                	jb     802308 <__udivdi3+0x10c>
  8022f1:	74 09                	je     8022fc <__udivdi3+0x100>
  8022f3:	89 fe                	mov    %edi,%esi
  8022f5:	31 ff                	xor    %edi,%edi
  8022f7:	e9 41 ff ff ff       	jmp    80223d <__udivdi3+0x41>
  8022fc:	8b 54 24 04          	mov    0x4(%esp),%edx
  802300:	89 f1                	mov    %esi,%ecx
  802302:	d3 e2                	shl    %cl,%edx
  802304:	39 c2                	cmp    %eax,%edx
  802306:	73 eb                	jae    8022f3 <__udivdi3+0xf7>
  802308:	8d 77 ff             	lea    -0x1(%edi),%esi
  80230b:	31 ff                	xor    %edi,%edi
  80230d:	e9 2b ff ff ff       	jmp    80223d <__udivdi3+0x41>
  802312:	66 90                	xchg   %ax,%ax
  802314:	31 f6                	xor    %esi,%esi
  802316:	e9 22 ff ff ff       	jmp    80223d <__udivdi3+0x41>
	...

0080231c <__umoddi3>:
  80231c:	55                   	push   %ebp
  80231d:	57                   	push   %edi
  80231e:	56                   	push   %esi
  80231f:	83 ec 20             	sub    $0x20,%esp
  802322:	8b 44 24 30          	mov    0x30(%esp),%eax
  802326:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80232a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80232e:	8b 74 24 34          	mov    0x34(%esp),%esi
  802332:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802336:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80233a:	89 c7                	mov    %eax,%edi
  80233c:	89 f2                	mov    %esi,%edx
  80233e:	85 ed                	test   %ebp,%ebp
  802340:	75 16                	jne    802358 <__umoddi3+0x3c>
  802342:	39 f1                	cmp    %esi,%ecx
  802344:	0f 86 a6 00 00 00    	jbe    8023f0 <__umoddi3+0xd4>
  80234a:	f7 f1                	div    %ecx
  80234c:	89 d0                	mov    %edx,%eax
  80234e:	31 d2                	xor    %edx,%edx
  802350:	83 c4 20             	add    $0x20,%esp
  802353:	5e                   	pop    %esi
  802354:	5f                   	pop    %edi
  802355:	5d                   	pop    %ebp
  802356:	c3                   	ret    
  802357:	90                   	nop
  802358:	39 f5                	cmp    %esi,%ebp
  80235a:	0f 87 ac 00 00 00    	ja     80240c <__umoddi3+0xf0>
  802360:	0f bd c5             	bsr    %ebp,%eax
  802363:	83 f0 1f             	xor    $0x1f,%eax
  802366:	89 44 24 10          	mov    %eax,0x10(%esp)
  80236a:	0f 84 a8 00 00 00    	je     802418 <__umoddi3+0xfc>
  802370:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802374:	d3 e5                	shl    %cl,%ebp
  802376:	bf 20 00 00 00       	mov    $0x20,%edi
  80237b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80237f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802383:	89 f9                	mov    %edi,%ecx
  802385:	d3 e8                	shr    %cl,%eax
  802387:	09 e8                	or     %ebp,%eax
  802389:	89 44 24 18          	mov    %eax,0x18(%esp)
  80238d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802391:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802395:	d3 e0                	shl    %cl,%eax
  802397:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80239b:	89 f2                	mov    %esi,%edx
  80239d:	d3 e2                	shl    %cl,%edx
  80239f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023a3:	d3 e0                	shl    %cl,%eax
  8023a5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8023a9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023ad:	89 f9                	mov    %edi,%ecx
  8023af:	d3 e8                	shr    %cl,%eax
  8023b1:	09 d0                	or     %edx,%eax
  8023b3:	d3 ee                	shr    %cl,%esi
  8023b5:	89 f2                	mov    %esi,%edx
  8023b7:	f7 74 24 18          	divl   0x18(%esp)
  8023bb:	89 d6                	mov    %edx,%esi
  8023bd:	f7 64 24 0c          	mull   0xc(%esp)
  8023c1:	89 c5                	mov    %eax,%ebp
  8023c3:	89 d1                	mov    %edx,%ecx
  8023c5:	39 d6                	cmp    %edx,%esi
  8023c7:	72 67                	jb     802430 <__umoddi3+0x114>
  8023c9:	74 75                	je     802440 <__umoddi3+0x124>
  8023cb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8023cf:	29 e8                	sub    %ebp,%eax
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	89 f2                	mov    %esi,%edx
  8023db:	89 f9                	mov    %edi,%ecx
  8023dd:	d3 e2                	shl    %cl,%edx
  8023df:	09 d0                	or     %edx,%eax
  8023e1:	89 f2                	mov    %esi,%edx
  8023e3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023e7:	d3 ea                	shr    %cl,%edx
  8023e9:	83 c4 20             	add    $0x20,%esp
  8023ec:	5e                   	pop    %esi
  8023ed:	5f                   	pop    %edi
  8023ee:	5d                   	pop    %ebp
  8023ef:	c3                   	ret    
  8023f0:	85 c9                	test   %ecx,%ecx
  8023f2:	75 0b                	jne    8023ff <__umoddi3+0xe3>
  8023f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f9:	31 d2                	xor    %edx,%edx
  8023fb:	f7 f1                	div    %ecx
  8023fd:	89 c1                	mov    %eax,%ecx
  8023ff:	89 f0                	mov    %esi,%eax
  802401:	31 d2                	xor    %edx,%edx
  802403:	f7 f1                	div    %ecx
  802405:	89 f8                	mov    %edi,%eax
  802407:	e9 3e ff ff ff       	jmp    80234a <__umoddi3+0x2e>
  80240c:	89 f2                	mov    %esi,%edx
  80240e:	83 c4 20             	add    $0x20,%esp
  802411:	5e                   	pop    %esi
  802412:	5f                   	pop    %edi
  802413:	5d                   	pop    %ebp
  802414:	c3                   	ret    
  802415:	8d 76 00             	lea    0x0(%esi),%esi
  802418:	39 f5                	cmp    %esi,%ebp
  80241a:	72 04                	jb     802420 <__umoddi3+0x104>
  80241c:	39 f9                	cmp    %edi,%ecx
  80241e:	77 06                	ja     802426 <__umoddi3+0x10a>
  802420:	89 f2                	mov    %esi,%edx
  802422:	29 cf                	sub    %ecx,%edi
  802424:	19 ea                	sbb    %ebp,%edx
  802426:	89 f8                	mov    %edi,%eax
  802428:	83 c4 20             	add    $0x20,%esp
  80242b:	5e                   	pop    %esi
  80242c:	5f                   	pop    %edi
  80242d:	5d                   	pop    %ebp
  80242e:	c3                   	ret    
  80242f:	90                   	nop
  802430:	89 d1                	mov    %edx,%ecx
  802432:	89 c5                	mov    %eax,%ebp
  802434:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802438:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80243c:	eb 8d                	jmp    8023cb <__umoddi3+0xaf>
  80243e:	66 90                	xchg   %ax,%ax
  802440:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802444:	72 ea                	jb     802430 <__umoddi3+0x114>
  802446:	89 f1                	mov    %esi,%ecx
  802448:	eb 81                	jmp    8023cb <__umoddi3+0xaf>
