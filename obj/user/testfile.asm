
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 3b 07 00 00       	call   80076c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800048:	e8 32 0e 00 00       	call   800e7f <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80005a:	e8 50 15 00 00       	call   8015af <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 c6 14 00 00       	call   801545 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 41 14 00 00       	call   8014dc <ipc_recv>
}
  80009b:	83 c4 14             	add    $0x14,%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <umain>:

void
umain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	81 ec cc 02 00 00    	sub    $0x2cc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b2:	b8 00 26 80 00       	mov    $0x802600,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 0b 26 80 	movl   $0x80260b,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8000e0:	e8 f7 06 00 00       	call   8007dc <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 c0 27 80 	movl   $0x8027c0,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8000fc:	e8 db 06 00 00       	call   8007dc <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 35 26 80 00       	mov    $0x802635,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 3e 26 80 	movl   $0x80263e,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  80012f:	e8 a8 06 00 00       	call   8007dc <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 e4 27 80 	movl   $0x8027e4,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  800166:	e8 71 06 00 00       	call   8007dc <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 56 26 80 00 	movl   $0x802656,(%esp)
  800172:	e8 5d 07 00 00       	call   8008d4 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 1c 30 80 00    	call   *0x80301c
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 6a 26 80 	movl   $0x80266a,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8001ad:	e8 2a 06 00 00       	call   8007dc <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 30 80 00       	mov    0x803000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 8d 0c 00 00       	call   800e4c <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 30 80 00       	mov    0x803000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 7b 0c 00 00       	call   800e4c <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 14 28 80 	movl   $0x802814,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8001f3:	e8 e4 05 00 00       	call   8007dc <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 78 26 80 00 	movl   $0x802678,(%esp)
  8001ff:	e8 d0 06 00 00       	call   8008d4 <cprintf>

	memset(buf, 0, sizeof buf);
  800204:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800213:	00 
  800214:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	e8 8c 0d 00 00       	call   800fae <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800222:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800229:	00 
  80022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800235:	ff 15 10 30 80 00    	call   *0x803010
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 8b 26 80 	movl   $0x80268b,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  80025a:	e8 7d 05 00 00       	call   8007dc <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 30 80 00       	mov    0x803000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 b0 0c 00 00       	call   800f26 <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 99 26 80 	movl   $0x802699,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  800291:	e8 46 05 00 00       	call   8007dc <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 b7 26 80 00 	movl   $0x8026b7,(%esp)
  80029d:	e8 32 06 00 00       	call   8008d4 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 18 30 80 00    	call   *0x803018
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 ca 26 80 	movl   $0x8026ca,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8002ce:	e8 09 05 00 00       	call   8007dc <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 d9 26 80 00 	movl   $0x8026d9,(%esp)
  8002da:	e8 f5 05 00 00       	call   8008d4 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002df:	be 00 c0 cc cc       	mov    $0xccccc000,%esi
  8002e4:	8d 7d d8             	lea    -0x28(%ebp),%edi
  8002e7:	b9 04 00 00 00       	mov    $0x4,%ecx
  8002ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	sys_page_unmap(0, FVA);
  8002ee:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  8002f5:	cc 
  8002f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002fd:	e8 16 10 00 00       	call   801318 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800302:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800309:	00 
  80030a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 15 10 30 80 00    	call   *0x803010
  800320:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800323:	74 20                	je     800345 <umain+0x2a4>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800329:	c7 44 24 08 3c 28 80 	movl   $0x80283c,0x8(%esp)
  800330:	00 
  800331:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800338:	00 
  800339:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  800340:	e8 97 04 00 00       	call   8007dc <_panic>
	cprintf("stale fileid is good\n");
  800345:	c7 04 24 ed 26 80 00 	movl   $0x8026ed,(%esp)
  80034c:	e8 83 05 00 00       	call   8008d4 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800351:	ba 02 01 00 00       	mov    $0x102,%edx
  800356:	b8 03 27 80 00       	mov    $0x802703,%eax
  80035b:	e8 d4 fc ff ff       	call   800034 <xopen>
  800360:	85 c0                	test   %eax,%eax
  800362:	79 20                	jns    800384 <umain+0x2e3>
		panic("serve_open /new-file: %e", r);
  800364:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800368:	c7 44 24 08 0d 27 80 	movl   $0x80270d,0x8(%esp)
  80036f:	00 
  800370:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800377:	00 
  800378:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  80037f:	e8 58 04 00 00       	call   8007dc <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800384:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  80038a:	a1 00 30 80 00       	mov    0x803000,%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	e8 b5 0a 00 00       	call   800e4c <strlen>
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	a1 00 30 80 00       	mov    0x803000,%eax
  8003a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a4:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003ab:	ff d3                	call   *%ebx
  8003ad:	89 c3                	mov    %eax,%ebx
  8003af:	a1 00 30 80 00       	mov    0x803000,%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 90 0a 00 00       	call   800e4c <strlen>
  8003bc:	39 c3                	cmp    %eax,%ebx
  8003be:	74 20                	je     8003e0 <umain+0x33f>
		panic("file_write: %e", r);
  8003c0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c4:	c7 44 24 08 26 27 80 	movl   $0x802726,0x8(%esp)
  8003cb:	00 
  8003cc:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8003d3:	00 
  8003d4:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8003db:	e8 fc 03 00 00       	call   8007dc <_panic>
	cprintf("file_write is good\n");
  8003e0:	c7 04 24 35 27 80 00 	movl   $0x802735,(%esp)
  8003e7:	e8 e8 04 00 00       	call   8008d4 <cprintf>

	FVA->fd_offset = 0;
  8003ec:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  8003f3:	00 00 00 
	memset(buf, 0, sizeof buf);
  8003f6:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8003fd:	00 
  8003fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800405:	00 
  800406:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80040c:	89 1c 24             	mov    %ebx,(%esp)
  80040f:	e8 9a 0b 00 00       	call   800fae <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800414:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80041b:	00 
  80041c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800420:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800427:	ff 15 10 30 80 00    	call   *0x803010
  80042d:	89 c3                	mov    %eax,%ebx
  80042f:	85 c0                	test   %eax,%eax
  800431:	79 20                	jns    800453 <umain+0x3b2>
		panic("file_read after file_write: %e", r);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	c7 44 24 08 74 28 80 	movl   $0x802874,0x8(%esp)
  80043e:	00 
  80043f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800446:	00 
  800447:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  80044e:	e8 89 03 00 00       	call   8007dc <_panic>
	if (r != strlen(msg))
  800453:	a1 00 30 80 00       	mov    0x803000,%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 ec 09 00 00       	call   800e4c <strlen>
  800460:	39 d8                	cmp    %ebx,%eax
  800462:	74 20                	je     800484 <umain+0x3e3>
		panic("file_read after file_write returned wrong length: %d", r);
  800464:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800468:	c7 44 24 08 94 28 80 	movl   $0x802894,0x8(%esp)
  80046f:	00 
  800470:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800477:	00 
  800478:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  80047f:	e8 58 03 00 00       	call   8007dc <_panic>
	if (strcmp(buf, msg) != 0)
  800484:	a1 00 30 80 00       	mov    0x803000,%eax
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 8b 0a 00 00       	call   800f26 <strcmp>
  80049b:	85 c0                	test   %eax,%eax
  80049d:	74 1c                	je     8004bb <umain+0x41a>
		panic("file_read after file_write returned wrong data");
  80049f:	c7 44 24 08 cc 28 80 	movl   $0x8028cc,0x8(%esp)
  8004a6:	00 
  8004a7:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8004ae:	00 
  8004af:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8004b6:	e8 21 03 00 00       	call   8007dc <_panic>
	cprintf("file_read after file_write is good\n");
  8004bb:	c7 04 24 fc 28 80 00 	movl   $0x8028fc,(%esp)
  8004c2:	e8 0d 04 00 00       	call   8008d4 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  8004d6:	e8 da 18 00 00       	call   801db5 <open>
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	79 25                	jns    800504 <umain+0x463>
  8004df:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004e2:	74 3c                	je     800520 <umain+0x47f>
		panic("open /not-found: %e", r);
  8004e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e8:	c7 44 24 08 11 26 80 	movl   $0x802611,0x8(%esp)
  8004ef:	00 
  8004f0:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8004f7:	00 
  8004f8:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8004ff:	e8 d8 02 00 00       	call   8007dc <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800504:	c7 44 24 08 49 27 80 	movl   $0x802749,0x8(%esp)
  80050b:	00 
  80050c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800513:	00 
  800514:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  80051b:	e8 bc 02 00 00       	call   8007dc <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800520:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800527:	00 
  800528:	c7 04 24 35 26 80 00 	movl   $0x802635,(%esp)
  80052f:	e8 81 18 00 00       	call   801db5 <open>
  800534:	85 c0                	test   %eax,%eax
  800536:	79 20                	jns    800558 <umain+0x4b7>
		panic("open /newmotd: %e", r);
  800538:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053c:	c7 44 24 08 44 26 80 	movl   $0x802644,0x8(%esp)
  800543:	00 
  800544:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80054b:	00 
  80054c:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  800553:	e8 84 02 00 00       	call   8007dc <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800558:	05 00 00 0d 00       	add    $0xd0000,%eax
  80055d:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800560:	83 38 66             	cmpl   $0x66,(%eax)
  800563:	75 0c                	jne    800571 <umain+0x4d0>
  800565:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800569:	75 06                	jne    800571 <umain+0x4d0>
  80056b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80056f:	74 1c                	je     80058d <umain+0x4ec>
		panic("open did not fill struct Fd correctly\n");
  800571:	c7 44 24 08 20 29 80 	movl   $0x802920,0x8(%esp)
  800578:	00 
  800579:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800580:	00 
  800581:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  800588:	e8 4f 02 00 00       	call   8007dc <_panic>
	cprintf("open is good\n");
  80058d:	c7 04 24 5c 26 80 00 	movl   $0x80265c,(%esp)
  800594:	e8 3b 03 00 00       	call   8008d4 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  800599:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005a0:	00 
  8005a1:	c7 04 24 64 27 80 00 	movl   $0x802764,(%esp)
  8005a8:	e8 08 18 00 00       	call   801db5 <open>
  8005ad:	89 c7                	mov    %eax,%edi
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	79 20                	jns    8005d3 <umain+0x532>
		panic("creat /big: %e", f);
  8005b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b7:	c7 44 24 08 69 27 80 	movl   $0x802769,0x8(%esp)
  8005be:	00 
  8005bf:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8005c6:	00 
  8005c7:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8005ce:	e8 09 02 00 00       	call   8007dc <_panic>
	memset(buf, 0, sizeof(buf));
  8005d3:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005da:	00 
  8005db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005e2:	00 
  8005e3:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	e8 bd 09 00 00       	call   800fae <memset>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005f1:	be 00 00 00 00       	mov    $0x0,%esi
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8005f6:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8005fc:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800602:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800609:	00 
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	89 3c 24             	mov    %edi,(%esp)
  800611:	e8 d3 13 00 00       	call   8019e9 <write>
  800616:	85 c0                	test   %eax,%eax
  800618:	79 24                	jns    80063e <umain+0x59d>
			panic("write /big@%d: %e", i, r);
  80061a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80061e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800622:	c7 44 24 08 78 27 80 	movl   $0x802778,0x8(%esp)
  800629:	00 
  80062a:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800631:	00 
  800632:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  800639:	e8 9e 01 00 00       	call   8007dc <_panic>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
  80063e:	8d 86 00 02 00 00    	lea    0x200(%esi),%eax
  800644:	89 c6                	mov    %eax,%esi

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800646:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  80064b:	75 af                	jne    8005fc <umain+0x55b>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  80064d:	89 3c 24             	mov    %edi,(%esp)
  800650:	e8 55 11 00 00       	call   8017aa <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800655:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80065c:	00 
  80065d:	c7 04 24 64 27 80 00 	movl   $0x802764,(%esp)
  800664:	e8 4c 17 00 00       	call   801db5 <open>
  800669:	89 c3                	mov    %eax,%ebx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	79 20                	jns    80068f <umain+0x5ee>
		panic("open /big: %e", f);
  80066f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800673:	c7 44 24 08 8a 27 80 	movl   $0x80278a,0x8(%esp)
  80067a:	00 
  80067b:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800682:	00 
  800683:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  80068a:	e8 4d 01 00 00       	call   8007dc <_panic>
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
  80068f:	be 00 00 00 00       	mov    $0x0,%esi
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800694:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  80069a:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006a0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006a7:	00 
  8006a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ac:	89 1c 24             	mov    %ebx,(%esp)
  8006af:	e8 ea 12 00 00       	call   80199e <readn>
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	79 24                	jns    8006dc <umain+0x63b>
			panic("read /big@%d: %e", i, r);
  8006b8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006c0:	c7 44 24 08 98 27 80 	movl   $0x802798,0x8(%esp)
  8006c7:	00 
  8006c8:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006cf:	00 
  8006d0:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  8006d7:	e8 00 01 00 00       	call   8007dc <_panic>
		if (r != sizeof(buf))
  8006dc:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006e1:	74 2c                	je     80070f <umain+0x66e>
			panic("read /big from %d returned %d < %d bytes",
  8006e3:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  8006ea:	00 
  8006eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006f3:	c7 44 24 08 48 29 80 	movl   $0x802948,0x8(%esp)
  8006fa:	00 
  8006fb:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800702:	00 
  800703:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  80070a:	e8 cd 00 00 00       	call   8007dc <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  80070f:	8b 07                	mov    (%edi),%eax
  800711:	39 f0                	cmp    %esi,%eax
  800713:	74 24                	je     800739 <umain+0x698>
			panic("read /big from %d returned bad data %d",
  800715:	89 44 24 10          	mov    %eax,0x10(%esp)
  800719:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80071d:	c7 44 24 08 74 29 80 	movl   $0x802974,0x8(%esp)
  800724:	00 
  800725:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  80072c:	00 
  80072d:	c7 04 24 25 26 80 00 	movl   $0x802625,(%esp)
  800734:	e8 a3 00 00 00       	call   8007dc <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800739:	8d b0 00 02 00 00    	lea    0x200(%eax),%esi
  80073f:	81 fe ff df 01 00    	cmp    $0x1dfff,%esi
  800745:	0f 8e 4f ff ff ff    	jle    80069a <umain+0x5f9>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  80074b:	89 1c 24             	mov    %ebx,(%esp)
  80074e:	e8 57 10 00 00       	call   8017aa <close>
	cprintf("large file is good\n");
  800753:	c7 04 24 a9 27 80 00 	movl   $0x8027a9,(%esp)
  80075a:	e8 75 01 00 00       	call   8008d4 <cprintf>
}
  80075f:	81 c4 cc 02 00 00    	add    $0x2cc,%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    
	...

0080076c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	56                   	push   %esi
  800770:	53                   	push   %ebx
  800771:	83 ec 10             	sub    $0x10,%esp
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  80077a:	e8 b4 0a 00 00       	call   801233 <sys_getenvid>
  80077f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800784:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80078b:	c1 e0 07             	shl    $0x7,%eax
  80078e:	29 d0                	sub    %edx,%eax
  800790:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800795:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80079a:	85 f6                	test   %esi,%esi
  80079c:	7e 07                	jle    8007a5 <libmain+0x39>
		binaryname = argv[0];
  80079e:	8b 03                	mov    (%ebx),%eax
  8007a0:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8007a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a9:	89 34 24             	mov    %esi,(%esp)
  8007ac:	e8 f0 f8 ff ff       	call   8000a1 <umain>

	// exit gracefully
	exit();
  8007b1:	e8 0a 00 00 00       	call   8007c0 <exit>
}
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    
  8007bd:	00 00                	add    %al,(%eax)
	...

008007c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8007c6:	e8 10 10 00 00       	call   8017db <close_all>
	sys_env_destroy(0);
  8007cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007d2:	e8 0a 0a 00 00       	call   8011e1 <sys_env_destroy>
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
  8007d9:	00 00                	add    %al,(%eax)
	...

008007dc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007e7:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8007ed:	e8 41 0a 00 00       	call   801233 <sys_getenvid>
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8007fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800800:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800804:	89 44 24 04          	mov    %eax,0x4(%esp)
  800808:	c7 04 24 cc 29 80 00 	movl   $0x8029cc,(%esp)
  80080f:	e8 c0 00 00 00       	call   8008d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800814:	89 74 24 04          	mov    %esi,0x4(%esp)
  800818:	8b 45 10             	mov    0x10(%ebp),%eax
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	e8 50 00 00 00       	call   800873 <vcprintf>
	cprintf("\n");
  800823:	c7 04 24 3d 2e 80 00 	movl   $0x802e3d,(%esp)
  80082a:	e8 a5 00 00 00       	call   8008d4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80082f:	cc                   	int3   
  800830:	eb fd                	jmp    80082f <_panic+0x53>
	...

00800834 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	83 ec 14             	sub    $0x14,%esp
  80083b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80083e:	8b 03                	mov    (%ebx),%eax
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
  800843:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800847:	40                   	inc    %eax
  800848:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80084a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80084f:	75 19                	jne    80086a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800851:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800858:	00 
  800859:	8d 43 08             	lea    0x8(%ebx),%eax
  80085c:	89 04 24             	mov    %eax,(%esp)
  80085f:	e8 40 09 00 00       	call   8011a4 <sys_cputs>
		b->idx = 0;
  800864:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80086a:	ff 43 04             	incl   0x4(%ebx)
}
  80086d:	83 c4 14             	add    $0x14,%esp
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80087c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800883:	00 00 00 
	b.cnt = 0;
  800886:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80088d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800890:	8b 45 0c             	mov    0xc(%ebp),%eax
  800893:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a8:	c7 04 24 34 08 80 00 	movl   $0x800834,(%esp)
  8008af:	e8 82 01 00 00       	call   800a36 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008b4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8008ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008c4:	89 04 24             	mov    %eax,(%esp)
  8008c7:	e8 d8 08 00 00       	call   8011a4 <sys_cputs>

	return b.cnt;
}
  8008cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	89 04 24             	mov    %eax,(%esp)
  8008e7:	e8 87 ff ff ff       	call   800873 <vcprintf>
	va_end(ap);

	return cnt;
}
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    
	...

008008f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	83 ec 3c             	sub    $0x3c,%esp
  8008f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008fc:	89 d7                	mov    %edx,%edi
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800904:	8b 45 0c             	mov    0xc(%ebp),%eax
  800907:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80090a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80090d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800910:	85 c0                	test   %eax,%eax
  800912:	75 08                	jne    80091c <printnum+0x2c>
  800914:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800917:	39 45 10             	cmp    %eax,0x10(%ebp)
  80091a:	77 57                	ja     800973 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80091c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800920:	4b                   	dec    %ebx
  800921:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800925:	8b 45 10             	mov    0x10(%ebp),%eax
  800928:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800930:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800934:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80093b:	00 
  80093c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80093f:	89 04 24             	mov    %eax,(%esp)
  800942:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800945:	89 44 24 04          	mov    %eax,0x4(%esp)
  800949:	e8 62 1a 00 00       	call   8023b0 <__udivdi3>
  80094e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800952:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800956:	89 04 24             	mov    %eax,(%esp)
  800959:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095d:	89 fa                	mov    %edi,%edx
  80095f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800962:	e8 89 ff ff ff       	call   8008f0 <printnum>
  800967:	eb 0f                	jmp    800978 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800969:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80096d:	89 34 24             	mov    %esi,(%esp)
  800970:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800973:	4b                   	dec    %ebx
  800974:	85 db                	test   %ebx,%ebx
  800976:	7f f1                	jg     800969 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800978:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800980:	8b 45 10             	mov    0x10(%ebp),%eax
  800983:	89 44 24 08          	mov    %eax,0x8(%esp)
  800987:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80098e:	00 
  80098f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800992:	89 04 24             	mov    %eax,(%esp)
  800995:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800998:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099c:	e8 2f 1b 00 00       	call   8024d0 <__umoddi3>
  8009a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009a5:	0f be 80 ef 29 80 00 	movsbl 0x8029ef(%eax),%eax
  8009ac:	89 04 24             	mov    %eax,(%esp)
  8009af:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8009b2:	83 c4 3c             	add    $0x3c,%esp
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009bd:	83 fa 01             	cmp    $0x1,%edx
  8009c0:	7e 0e                	jle    8009d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8009c2:	8b 10                	mov    (%eax),%edx
  8009c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8009c7:	89 08                	mov    %ecx,(%eax)
  8009c9:	8b 02                	mov    (%edx),%eax
  8009cb:	8b 52 04             	mov    0x4(%edx),%edx
  8009ce:	eb 22                	jmp    8009f2 <getuint+0x38>
	else if (lflag)
  8009d0:	85 d2                	test   %edx,%edx
  8009d2:	74 10                	je     8009e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8009d4:	8b 10                	mov    (%eax),%edx
  8009d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009d9:	89 08                	mov    %ecx,(%eax)
  8009db:	8b 02                	mov    (%edx),%eax
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e2:	eb 0e                	jmp    8009f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8009e4:	8b 10                	mov    (%eax),%edx
  8009e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009e9:	89 08                	mov    %ecx,(%eax)
  8009eb:	8b 02                	mov    (%edx),%eax
  8009ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009fa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8009fd:	8b 10                	mov    (%eax),%edx
  8009ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800a02:	73 08                	jae    800a0c <sprintputch+0x18>
		*b->buf++ = ch;
  800a04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a07:	88 0a                	mov    %cl,(%edx)
  800a09:	42                   	inc    %edx
  800a0a:	89 10                	mov    %edx,(%eax)
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800a14:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	89 04 24             	mov    %eax,(%esp)
  800a2f:	e8 02 00 00 00       	call   800a36 <vprintfmt>
	va_end(ap);
}
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	83 ec 4c             	sub    $0x4c,%esp
  800a3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a42:	8b 75 10             	mov    0x10(%ebp),%esi
  800a45:	eb 12                	jmp    800a59 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a47:	85 c0                	test   %eax,%eax
  800a49:	0f 84 6b 03 00 00    	je     800dba <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800a4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a53:	89 04 24             	mov    %eax,(%esp)
  800a56:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a59:	0f b6 06             	movzbl (%esi),%eax
  800a5c:	46                   	inc    %esi
  800a5d:	83 f8 25             	cmp    $0x25,%eax
  800a60:	75 e5                	jne    800a47 <vprintfmt+0x11>
  800a62:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800a66:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a6d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800a72:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7e:	eb 26                	jmp    800aa6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a80:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a83:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800a87:	eb 1d                	jmp    800aa6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a89:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a8c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800a90:	eb 14                	jmp    800aa6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a92:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800a95:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800a9c:	eb 08                	jmp    800aa6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a9e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800aa1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aa6:	0f b6 06             	movzbl (%esi),%eax
  800aa9:	8d 56 01             	lea    0x1(%esi),%edx
  800aac:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800aaf:	8a 16                	mov    (%esi),%dl
  800ab1:	83 ea 23             	sub    $0x23,%edx
  800ab4:	80 fa 55             	cmp    $0x55,%dl
  800ab7:	0f 87 e1 02 00 00    	ja     800d9e <vprintfmt+0x368>
  800abd:	0f b6 d2             	movzbl %dl,%edx
  800ac0:	ff 24 95 40 2b 80 00 	jmp    *0x802b40(,%edx,4)
  800ac7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800aca:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800acf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800ad2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800ad6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800ad9:	8d 50 d0             	lea    -0x30(%eax),%edx
  800adc:	83 fa 09             	cmp    $0x9,%edx
  800adf:	77 2a                	ja     800b0b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ae1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ae2:	eb eb                	jmp    800acf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ae4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae7:	8d 50 04             	lea    0x4(%eax),%edx
  800aea:	89 55 14             	mov    %edx,0x14(%ebp)
  800aed:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800af2:	eb 17                	jmp    800b0b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800af4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800af8:	78 98                	js     800a92 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800afa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800afd:	eb a7                	jmp    800aa6 <vprintfmt+0x70>
  800aff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b02:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800b09:	eb 9b                	jmp    800aa6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800b0b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b0f:	79 95                	jns    800aa6 <vprintfmt+0x70>
  800b11:	eb 8b                	jmp    800a9e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b13:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b14:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b17:	eb 8d                	jmp    800aa6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b19:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1c:	8d 50 04             	lea    0x4(%eax),%edx
  800b1f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b26:	8b 00                	mov    (%eax),%eax
  800b28:	89 04 24             	mov    %eax,(%esp)
  800b2b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b2e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b31:	e9 23 ff ff ff       	jmp    800a59 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b36:	8b 45 14             	mov    0x14(%ebp),%eax
  800b39:	8d 50 04             	lea    0x4(%eax),%edx
  800b3c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b3f:	8b 00                	mov    (%eax),%eax
  800b41:	85 c0                	test   %eax,%eax
  800b43:	79 02                	jns    800b47 <vprintfmt+0x111>
  800b45:	f7 d8                	neg    %eax
  800b47:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b49:	83 f8 0f             	cmp    $0xf,%eax
  800b4c:	7f 0b                	jg     800b59 <vprintfmt+0x123>
  800b4e:	8b 04 85 a0 2c 80 00 	mov    0x802ca0(,%eax,4),%eax
  800b55:	85 c0                	test   %eax,%eax
  800b57:	75 23                	jne    800b7c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800b59:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b5d:	c7 44 24 08 07 2a 80 	movl   $0x802a07,0x8(%esp)
  800b64:	00 
  800b65:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	89 04 24             	mov    %eax,(%esp)
  800b6f:	e8 9a fe ff ff       	call   800a0e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b74:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b77:	e9 dd fe ff ff       	jmp    800a59 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800b7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b80:	c7 44 24 08 16 2e 80 	movl   $0x802e16,0x8(%esp)
  800b87:	00 
  800b88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	89 14 24             	mov    %edx,(%esp)
  800b92:	e8 77 fe ff ff       	call   800a0e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b97:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b9a:	e9 ba fe ff ff       	jmp    800a59 <vprintfmt+0x23>
  800b9f:	89 f9                	mov    %edi,%ecx
  800ba1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ba4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800ba7:	8b 45 14             	mov    0x14(%ebp),%eax
  800baa:	8d 50 04             	lea    0x4(%eax),%edx
  800bad:	89 55 14             	mov    %edx,0x14(%ebp)
  800bb0:	8b 30                	mov    (%eax),%esi
  800bb2:	85 f6                	test   %esi,%esi
  800bb4:	75 05                	jne    800bbb <vprintfmt+0x185>
				p = "(null)";
  800bb6:	be 00 2a 80 00       	mov    $0x802a00,%esi
			if (width > 0 && padc != '-')
  800bbb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800bbf:	0f 8e 84 00 00 00    	jle    800c49 <vprintfmt+0x213>
  800bc5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800bc9:	74 7e                	je     800c49 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800bcb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bcf:	89 34 24             	mov    %esi,(%esp)
  800bd2:	e8 8b 02 00 00       	call   800e62 <strnlen>
  800bd7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800bda:	29 c2                	sub    %eax,%edx
  800bdc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800bdf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800be3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800be6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800be9:	89 de                	mov    %ebx,%esi
  800beb:	89 d3                	mov    %edx,%ebx
  800bed:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bef:	eb 0b                	jmp    800bfc <vprintfmt+0x1c6>
					putch(padc, putdat);
  800bf1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf5:	89 3c 24             	mov    %edi,(%esp)
  800bf8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bfb:	4b                   	dec    %ebx
  800bfc:	85 db                	test   %ebx,%ebx
  800bfe:	7f f1                	jg     800bf1 <vprintfmt+0x1bb>
  800c00:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800c03:	89 f3                	mov    %esi,%ebx
  800c05:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800c08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	79 05                	jns    800c14 <vprintfmt+0x1de>
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c17:	29 c2                	sub    %eax,%edx
  800c19:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c1c:	eb 2b                	jmp    800c49 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c1e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c22:	74 18                	je     800c3c <vprintfmt+0x206>
  800c24:	8d 50 e0             	lea    -0x20(%eax),%edx
  800c27:	83 fa 5e             	cmp    $0x5e,%edx
  800c2a:	76 10                	jbe    800c3c <vprintfmt+0x206>
					putch('?', putdat);
  800c2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c30:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c37:	ff 55 08             	call   *0x8(%ebp)
  800c3a:	eb 0a                	jmp    800c46 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800c3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c40:	89 04 24             	mov    %eax,(%esp)
  800c43:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c46:	ff 4d e4             	decl   -0x1c(%ebp)
  800c49:	0f be 06             	movsbl (%esi),%eax
  800c4c:	46                   	inc    %esi
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	74 21                	je     800c72 <vprintfmt+0x23c>
  800c51:	85 ff                	test   %edi,%edi
  800c53:	78 c9                	js     800c1e <vprintfmt+0x1e8>
  800c55:	4f                   	dec    %edi
  800c56:	79 c6                	jns    800c1e <vprintfmt+0x1e8>
  800c58:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c60:	eb 18                	jmp    800c7a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c62:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c66:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c6d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c6f:	4b                   	dec    %ebx
  800c70:	eb 08                	jmp    800c7a <vprintfmt+0x244>
  800c72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c75:	89 de                	mov    %ebx,%esi
  800c77:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c7a:	85 db                	test   %ebx,%ebx
  800c7c:	7f e4                	jg     800c62 <vprintfmt+0x22c>
  800c7e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800c81:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c83:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c86:	e9 ce fd ff ff       	jmp    800a59 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c8b:	83 f9 01             	cmp    $0x1,%ecx
  800c8e:	7e 10                	jle    800ca0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800c90:	8b 45 14             	mov    0x14(%ebp),%eax
  800c93:	8d 50 08             	lea    0x8(%eax),%edx
  800c96:	89 55 14             	mov    %edx,0x14(%ebp)
  800c99:	8b 30                	mov    (%eax),%esi
  800c9b:	8b 78 04             	mov    0x4(%eax),%edi
  800c9e:	eb 26                	jmp    800cc6 <vprintfmt+0x290>
	else if (lflag)
  800ca0:	85 c9                	test   %ecx,%ecx
  800ca2:	74 12                	je     800cb6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800ca4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca7:	8d 50 04             	lea    0x4(%eax),%edx
  800caa:	89 55 14             	mov    %edx,0x14(%ebp)
  800cad:	8b 30                	mov    (%eax),%esi
  800caf:	89 f7                	mov    %esi,%edi
  800cb1:	c1 ff 1f             	sar    $0x1f,%edi
  800cb4:	eb 10                	jmp    800cc6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800cb6:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb9:	8d 50 04             	lea    0x4(%eax),%edx
  800cbc:	89 55 14             	mov    %edx,0x14(%ebp)
  800cbf:	8b 30                	mov    (%eax),%esi
  800cc1:	89 f7                	mov    %esi,%edi
  800cc3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800cc6:	85 ff                	test   %edi,%edi
  800cc8:	78 0a                	js     800cd4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800cca:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ccf:	e9 8c 00 00 00       	jmp    800d60 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800cd4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800cdf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ce2:	f7 de                	neg    %esi
  800ce4:	83 d7 00             	adc    $0x0,%edi
  800ce7:	f7 df                	neg    %edi
			}
			base = 10;
  800ce9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cee:	eb 70                	jmp    800d60 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800cf0:	89 ca                	mov    %ecx,%edx
  800cf2:	8d 45 14             	lea    0x14(%ebp),%eax
  800cf5:	e8 c0 fc ff ff       	call   8009ba <getuint>
  800cfa:	89 c6                	mov    %eax,%esi
  800cfc:	89 d7                	mov    %edx,%edi
			base = 10;
  800cfe:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800d03:	eb 5b                	jmp    800d60 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800d05:	89 ca                	mov    %ecx,%edx
  800d07:	8d 45 14             	lea    0x14(%ebp),%eax
  800d0a:	e8 ab fc ff ff       	call   8009ba <getuint>
  800d0f:	89 c6                	mov    %eax,%esi
  800d11:	89 d7                	mov    %edx,%edi
			base = 8;
  800d13:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800d18:	eb 46                	jmp    800d60 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800d1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d1e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d25:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800d28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d2c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d33:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d36:	8b 45 14             	mov    0x14(%ebp),%eax
  800d39:	8d 50 04             	lea    0x4(%eax),%edx
  800d3c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d3f:	8b 30                	mov    (%eax),%esi
  800d41:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d46:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800d4b:	eb 13                	jmp    800d60 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d4d:	89 ca                	mov    %ecx,%edx
  800d4f:	8d 45 14             	lea    0x14(%ebp),%eax
  800d52:	e8 63 fc ff ff       	call   8009ba <getuint>
  800d57:	89 c6                	mov    %eax,%esi
  800d59:	89 d7                	mov    %edx,%edi
			base = 16;
  800d5b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d60:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800d64:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d68:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d6b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d73:	89 34 24             	mov    %esi,(%esp)
  800d76:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d7a:	89 da                	mov    %ebx,%edx
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	e8 6c fb ff ff       	call   8008f0 <printnum>
			break;
  800d84:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d87:	e9 cd fc ff ff       	jmp    800a59 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d90:	89 04 24             	mov    %eax,(%esp)
  800d93:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d96:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d99:	e9 bb fc ff ff       	jmp    800a59 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800da9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800dac:	eb 01                	jmp    800daf <vprintfmt+0x379>
  800dae:	4e                   	dec    %esi
  800daf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800db3:	75 f9                	jne    800dae <vprintfmt+0x378>
  800db5:	e9 9f fc ff ff       	jmp    800a59 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800dba:	83 c4 4c             	add    $0x4c,%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	83 ec 28             	sub    $0x28,%esp
  800dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dd1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800dd5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800dd8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	74 30                	je     800e13 <vsnprintf+0x51>
  800de3:	85 d2                	test   %edx,%edx
  800de5:	7e 33                	jle    800e1a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800de7:	8b 45 14             	mov    0x14(%ebp),%eax
  800dea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dee:	8b 45 10             	mov    0x10(%ebp),%eax
  800df1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800df8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dfc:	c7 04 24 f4 09 80 00 	movl   $0x8009f4,(%esp)
  800e03:	e8 2e fc ff ff       	call   800a36 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e0b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e11:	eb 0c                	jmp    800e1f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e18:	eb 05                	jmp    800e1f <vsnprintf+0x5d>
  800e1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e27:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800e31:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3f:	89 04 24             	mov    %eax,(%esp)
  800e42:	e8 7b ff ff ff       	call   800dc2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800e47:	c9                   	leave  
  800e48:	c3                   	ret    
  800e49:	00 00                	add    %al,(%eax)
	...

00800e4c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e52:	b8 00 00 00 00       	mov    $0x0,%eax
  800e57:	eb 01                	jmp    800e5a <strlen+0xe>
		n++;
  800e59:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e5a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e5e:	75 f9                	jne    800e59 <strlen+0xd>
		n++;
	return n;
}
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800e68:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e70:	eb 01                	jmp    800e73 <strnlen+0x11>
		n++;
  800e72:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e73:	39 d0                	cmp    %edx,%eax
  800e75:	74 06                	je     800e7d <strnlen+0x1b>
  800e77:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800e7b:	75 f5                	jne    800e72 <strnlen+0x10>
		n++;
	return n;
}
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	53                   	push   %ebx
  800e83:	8b 45 08             	mov    0x8(%ebp),%eax
  800e86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e89:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800e91:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e94:	42                   	inc    %edx
  800e95:	84 c9                	test   %cl,%cl
  800e97:	75 f5                	jne    800e8e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e99:	5b                   	pop    %ebx
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 08             	sub    $0x8,%esp
  800ea3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ea6:	89 1c 24             	mov    %ebx,(%esp)
  800ea9:	e8 9e ff ff ff       	call   800e4c <strlen>
	strcpy(dst + len, src);
  800eae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eb5:	01 d8                	add    %ebx,%eax
  800eb7:	89 04 24             	mov    %eax,(%esp)
  800eba:	e8 c0 ff ff ff       	call   800e7f <strcpy>
	return dst;
}
  800ebf:	89 d8                	mov    %ebx,%eax
  800ec1:	83 c4 08             	add    $0x8,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ed5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eda:	eb 0c                	jmp    800ee8 <strncpy+0x21>
		*dst++ = *src;
  800edc:	8a 1a                	mov    (%edx),%bl
  800ede:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ee1:	80 3a 01             	cmpb   $0x1,(%edx)
  800ee4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ee7:	41                   	inc    %ecx
  800ee8:	39 f1                	cmp    %esi,%ecx
  800eea:	75 f0                	jne    800edc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800efe:	85 d2                	test   %edx,%edx
  800f00:	75 0a                	jne    800f0c <strlcpy+0x1c>
  800f02:	89 f0                	mov    %esi,%eax
  800f04:	eb 1a                	jmp    800f20 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f06:	88 18                	mov    %bl,(%eax)
  800f08:	40                   	inc    %eax
  800f09:	41                   	inc    %ecx
  800f0a:	eb 02                	jmp    800f0e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f0c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800f0e:	4a                   	dec    %edx
  800f0f:	74 0a                	je     800f1b <strlcpy+0x2b>
  800f11:	8a 19                	mov    (%ecx),%bl
  800f13:	84 db                	test   %bl,%bl
  800f15:	75 ef                	jne    800f06 <strlcpy+0x16>
  800f17:	89 c2                	mov    %eax,%edx
  800f19:	eb 02                	jmp    800f1d <strlcpy+0x2d>
  800f1b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800f1d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800f20:	29 f0                	sub    %esi,%eax
}
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f2f:	eb 02                	jmp    800f33 <strcmp+0xd>
		p++, q++;
  800f31:	41                   	inc    %ecx
  800f32:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f33:	8a 01                	mov    (%ecx),%al
  800f35:	84 c0                	test   %al,%al
  800f37:	74 04                	je     800f3d <strcmp+0x17>
  800f39:	3a 02                	cmp    (%edx),%al
  800f3b:	74 f4                	je     800f31 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f3d:	0f b6 c0             	movzbl %al,%eax
  800f40:	0f b6 12             	movzbl (%edx),%edx
  800f43:	29 d0                	sub    %edx,%eax
}
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	53                   	push   %ebx
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f51:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800f54:	eb 03                	jmp    800f59 <strncmp+0x12>
		n--, p++, q++;
  800f56:	4a                   	dec    %edx
  800f57:	40                   	inc    %eax
  800f58:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f59:	85 d2                	test   %edx,%edx
  800f5b:	74 14                	je     800f71 <strncmp+0x2a>
  800f5d:	8a 18                	mov    (%eax),%bl
  800f5f:	84 db                	test   %bl,%bl
  800f61:	74 04                	je     800f67 <strncmp+0x20>
  800f63:	3a 19                	cmp    (%ecx),%bl
  800f65:	74 ef                	je     800f56 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f67:	0f b6 00             	movzbl (%eax),%eax
  800f6a:	0f b6 11             	movzbl (%ecx),%edx
  800f6d:	29 d0                	sub    %edx,%eax
  800f6f:	eb 05                	jmp    800f76 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f76:	5b                   	pop    %ebx
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800f82:	eb 05                	jmp    800f89 <strchr+0x10>
		if (*s == c)
  800f84:	38 ca                	cmp    %cl,%dl
  800f86:	74 0c                	je     800f94 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f88:	40                   	inc    %eax
  800f89:	8a 10                	mov    (%eax),%dl
  800f8b:	84 d2                	test   %dl,%dl
  800f8d:	75 f5                	jne    800f84 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800f8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800f9f:	eb 05                	jmp    800fa6 <strfind+0x10>
		if (*s == c)
  800fa1:	38 ca                	cmp    %cl,%dl
  800fa3:	74 07                	je     800fac <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800fa5:	40                   	inc    %eax
  800fa6:	8a 10                	mov    (%eax),%dl
  800fa8:	84 d2                	test   %dl,%dl
  800faa:	75 f5                	jne    800fa1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	53                   	push   %ebx
  800fb4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fbd:	85 c9                	test   %ecx,%ecx
  800fbf:	74 30                	je     800ff1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fc1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fc7:	75 25                	jne    800fee <memset+0x40>
  800fc9:	f6 c1 03             	test   $0x3,%cl
  800fcc:	75 20                	jne    800fee <memset+0x40>
		c &= 0xFF;
  800fce:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800fd1:	89 d3                	mov    %edx,%ebx
  800fd3:	c1 e3 08             	shl    $0x8,%ebx
  800fd6:	89 d6                	mov    %edx,%esi
  800fd8:	c1 e6 18             	shl    $0x18,%esi
  800fdb:	89 d0                	mov    %edx,%eax
  800fdd:	c1 e0 10             	shl    $0x10,%eax
  800fe0:	09 f0                	or     %esi,%eax
  800fe2:	09 d0                	or     %edx,%eax
  800fe4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800fe6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800fe9:	fc                   	cld    
  800fea:	f3 ab                	rep stos %eax,%es:(%edi)
  800fec:	eb 03                	jmp    800ff1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800fee:	fc                   	cld    
  800fef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ff1:	89 f8                	mov    %edi,%eax
  800ff3:	5b                   	pop    %ebx
  800ff4:	5e                   	pop    %esi
  800ff5:	5f                   	pop    %edi
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    

00800ff8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	57                   	push   %edi
  800ffc:	56                   	push   %esi
  800ffd:	8b 45 08             	mov    0x8(%ebp),%eax
  801000:	8b 75 0c             	mov    0xc(%ebp),%esi
  801003:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801006:	39 c6                	cmp    %eax,%esi
  801008:	73 34                	jae    80103e <memmove+0x46>
  80100a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80100d:	39 d0                	cmp    %edx,%eax
  80100f:	73 2d                	jae    80103e <memmove+0x46>
		s += n;
		d += n;
  801011:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801014:	f6 c2 03             	test   $0x3,%dl
  801017:	75 1b                	jne    801034 <memmove+0x3c>
  801019:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80101f:	75 13                	jne    801034 <memmove+0x3c>
  801021:	f6 c1 03             	test   $0x3,%cl
  801024:	75 0e                	jne    801034 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801026:	83 ef 04             	sub    $0x4,%edi
  801029:	8d 72 fc             	lea    -0x4(%edx),%esi
  80102c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80102f:	fd                   	std    
  801030:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801032:	eb 07                	jmp    80103b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801034:	4f                   	dec    %edi
  801035:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801038:	fd                   	std    
  801039:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80103b:	fc                   	cld    
  80103c:	eb 20                	jmp    80105e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80103e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801044:	75 13                	jne    801059 <memmove+0x61>
  801046:	a8 03                	test   $0x3,%al
  801048:	75 0f                	jne    801059 <memmove+0x61>
  80104a:	f6 c1 03             	test   $0x3,%cl
  80104d:	75 0a                	jne    801059 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80104f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801052:	89 c7                	mov    %eax,%edi
  801054:	fc                   	cld    
  801055:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801057:	eb 05                	jmp    80105e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801059:	89 c7                	mov    %eax,%edi
  80105b:	fc                   	cld    
  80105c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80105e:	5e                   	pop    %esi
  80105f:	5f                   	pop    %edi
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801068:	8b 45 10             	mov    0x10(%ebp),%eax
  80106b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80106f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801072:	89 44 24 04          	mov    %eax,0x4(%esp)
  801076:	8b 45 08             	mov    0x8(%ebp),%eax
  801079:	89 04 24             	mov    %eax,(%esp)
  80107c:	e8 77 ff ff ff       	call   800ff8 <memmove>
}
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80108f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801092:	ba 00 00 00 00       	mov    $0x0,%edx
  801097:	eb 16                	jmp    8010af <memcmp+0x2c>
		if (*s1 != *s2)
  801099:	8a 04 17             	mov    (%edi,%edx,1),%al
  80109c:	42                   	inc    %edx
  80109d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8010a1:	38 c8                	cmp    %cl,%al
  8010a3:	74 0a                	je     8010af <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8010a5:	0f b6 c0             	movzbl %al,%eax
  8010a8:	0f b6 c9             	movzbl %cl,%ecx
  8010ab:	29 c8                	sub    %ecx,%eax
  8010ad:	eb 09                	jmp    8010b8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010af:	39 da                	cmp    %ebx,%edx
  8010b1:	75 e6                	jne    801099 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5f                   	pop    %edi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8010c6:	89 c2                	mov    %eax,%edx
  8010c8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010cb:	eb 05                	jmp    8010d2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010cd:	38 08                	cmp    %cl,(%eax)
  8010cf:	74 05                	je     8010d6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010d1:	40                   	inc    %eax
  8010d2:	39 d0                	cmp    %edx,%eax
  8010d4:	72 f7                	jb     8010cd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	57                   	push   %edi
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
  8010de:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010e4:	eb 01                	jmp    8010e7 <strtol+0xf>
		s++;
  8010e6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010e7:	8a 02                	mov    (%edx),%al
  8010e9:	3c 20                	cmp    $0x20,%al
  8010eb:	74 f9                	je     8010e6 <strtol+0xe>
  8010ed:	3c 09                	cmp    $0x9,%al
  8010ef:	74 f5                	je     8010e6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010f1:	3c 2b                	cmp    $0x2b,%al
  8010f3:	75 08                	jne    8010fd <strtol+0x25>
		s++;
  8010f5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010f6:	bf 00 00 00 00       	mov    $0x0,%edi
  8010fb:	eb 13                	jmp    801110 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010fd:	3c 2d                	cmp    $0x2d,%al
  8010ff:	75 0a                	jne    80110b <strtol+0x33>
		s++, neg = 1;
  801101:	8d 52 01             	lea    0x1(%edx),%edx
  801104:	bf 01 00 00 00       	mov    $0x1,%edi
  801109:	eb 05                	jmp    801110 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80110b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801110:	85 db                	test   %ebx,%ebx
  801112:	74 05                	je     801119 <strtol+0x41>
  801114:	83 fb 10             	cmp    $0x10,%ebx
  801117:	75 28                	jne    801141 <strtol+0x69>
  801119:	8a 02                	mov    (%edx),%al
  80111b:	3c 30                	cmp    $0x30,%al
  80111d:	75 10                	jne    80112f <strtol+0x57>
  80111f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801123:	75 0a                	jne    80112f <strtol+0x57>
		s += 2, base = 16;
  801125:	83 c2 02             	add    $0x2,%edx
  801128:	bb 10 00 00 00       	mov    $0x10,%ebx
  80112d:	eb 12                	jmp    801141 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80112f:	85 db                	test   %ebx,%ebx
  801131:	75 0e                	jne    801141 <strtol+0x69>
  801133:	3c 30                	cmp    $0x30,%al
  801135:	75 05                	jne    80113c <strtol+0x64>
		s++, base = 8;
  801137:	42                   	inc    %edx
  801138:	b3 08                	mov    $0x8,%bl
  80113a:	eb 05                	jmp    801141 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80113c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801148:	8a 0a                	mov    (%edx),%cl
  80114a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80114d:	80 fb 09             	cmp    $0x9,%bl
  801150:	77 08                	ja     80115a <strtol+0x82>
			dig = *s - '0';
  801152:	0f be c9             	movsbl %cl,%ecx
  801155:	83 e9 30             	sub    $0x30,%ecx
  801158:	eb 1e                	jmp    801178 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80115a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80115d:	80 fb 19             	cmp    $0x19,%bl
  801160:	77 08                	ja     80116a <strtol+0x92>
			dig = *s - 'a' + 10;
  801162:	0f be c9             	movsbl %cl,%ecx
  801165:	83 e9 57             	sub    $0x57,%ecx
  801168:	eb 0e                	jmp    801178 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80116a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80116d:	80 fb 19             	cmp    $0x19,%bl
  801170:	77 12                	ja     801184 <strtol+0xac>
			dig = *s - 'A' + 10;
  801172:	0f be c9             	movsbl %cl,%ecx
  801175:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801178:	39 f1                	cmp    %esi,%ecx
  80117a:	7d 0c                	jge    801188 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80117c:	42                   	inc    %edx
  80117d:	0f af c6             	imul   %esi,%eax
  801180:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801182:	eb c4                	jmp    801148 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801184:	89 c1                	mov    %eax,%ecx
  801186:	eb 02                	jmp    80118a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801188:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80118a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80118e:	74 05                	je     801195 <strtol+0xbd>
		*endptr = (char *) s;
  801190:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801193:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801195:	85 ff                	test   %edi,%edi
  801197:	74 04                	je     80119d <strtol+0xc5>
  801199:	89 c8                	mov    %ecx,%eax
  80119b:	f7 d8                	neg    %eax
}
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    
	...

008011a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	57                   	push   %edi
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b5:	89 c3                	mov    %eax,%ebx
  8011b7:	89 c7                	mov    %eax,%edi
  8011b9:	89 c6                	mov    %eax,%esi
  8011bb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5f                   	pop    %edi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	57                   	push   %edi
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d2:	89 d1                	mov    %edx,%ecx
  8011d4:	89 d3                	mov    %edx,%ebx
  8011d6:	89 d7                	mov    %edx,%edi
  8011d8:	89 d6                	mov    %edx,%esi
  8011da:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	57                   	push   %edi
  8011e5:	56                   	push   %esi
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8011f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f7:	89 cb                	mov    %ecx,%ebx
  8011f9:	89 cf                	mov    %ecx,%edi
  8011fb:	89 ce                	mov    %ecx,%esi
  8011fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ff:	85 c0                	test   %eax,%eax
  801201:	7e 28                	jle    80122b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801203:	89 44 24 10          	mov    %eax,0x10(%esp)
  801207:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80120e:	00 
  80120f:	c7 44 24 08 ff 2c 80 	movl   $0x802cff,0x8(%esp)
  801216:	00 
  801217:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80121e:	00 
  80121f:	c7 04 24 1c 2d 80 00 	movl   $0x802d1c,(%esp)
  801226:	e8 b1 f5 ff ff       	call   8007dc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80122b:	83 c4 2c             	add    $0x2c,%esp
  80122e:	5b                   	pop    %ebx
  80122f:	5e                   	pop    %esi
  801230:	5f                   	pop    %edi
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801239:	ba 00 00 00 00       	mov    $0x0,%edx
  80123e:	b8 02 00 00 00       	mov    $0x2,%eax
  801243:	89 d1                	mov    %edx,%ecx
  801245:	89 d3                	mov    %edx,%ebx
  801247:	89 d7                	mov    %edx,%edi
  801249:	89 d6                	mov    %edx,%esi
  80124b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <sys_yield>:

void
sys_yield(void)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801258:	ba 00 00 00 00       	mov    $0x0,%edx
  80125d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801262:	89 d1                	mov    %edx,%ecx
  801264:	89 d3                	mov    %edx,%ebx
  801266:	89 d7                	mov    %edx,%edi
  801268:	89 d6                	mov    %edx,%esi
  80126a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5f                   	pop    %edi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	57                   	push   %edi
  801275:	56                   	push   %esi
  801276:	53                   	push   %ebx
  801277:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127a:	be 00 00 00 00       	mov    $0x0,%esi
  80127f:	b8 04 00 00 00       	mov    $0x4,%eax
  801284:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801287:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128a:	8b 55 08             	mov    0x8(%ebp),%edx
  80128d:	89 f7                	mov    %esi,%edi
  80128f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801291:	85 c0                	test   %eax,%eax
  801293:	7e 28                	jle    8012bd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801295:	89 44 24 10          	mov    %eax,0x10(%esp)
  801299:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8012a0:	00 
  8012a1:	c7 44 24 08 ff 2c 80 	movl   $0x802cff,0x8(%esp)
  8012a8:	00 
  8012a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012b0:	00 
  8012b1:	c7 04 24 1c 2d 80 00 	movl   $0x802d1c,(%esp)
  8012b8:	e8 1f f5 ff ff       	call   8007dc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012bd:	83 c4 2c             	add    $0x2c,%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	57                   	push   %edi
  8012c9:	56                   	push   %esi
  8012ca:	53                   	push   %ebx
  8012cb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8012d3:	8b 75 18             	mov    0x18(%ebp),%esi
  8012d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012df:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	7e 28                	jle    801310 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012ec:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012f3:	00 
  8012f4:	c7 44 24 08 ff 2c 80 	movl   $0x802cff,0x8(%esp)
  8012fb:	00 
  8012fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801303:	00 
  801304:	c7 04 24 1c 2d 80 00 	movl   $0x802d1c,(%esp)
  80130b:	e8 cc f4 ff ff       	call   8007dc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801310:	83 c4 2c             	add    $0x2c,%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801321:	bb 00 00 00 00       	mov    $0x0,%ebx
  801326:	b8 06 00 00 00       	mov    $0x6,%eax
  80132b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132e:	8b 55 08             	mov    0x8(%ebp),%edx
  801331:	89 df                	mov    %ebx,%edi
  801333:	89 de                	mov    %ebx,%esi
  801335:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801337:	85 c0                	test   %eax,%eax
  801339:	7e 28                	jle    801363 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80133b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80133f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801346:	00 
  801347:	c7 44 24 08 ff 2c 80 	movl   $0x802cff,0x8(%esp)
  80134e:	00 
  80134f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801356:	00 
  801357:	c7 04 24 1c 2d 80 00 	movl   $0x802d1c,(%esp)
  80135e:	e8 79 f4 ff ff       	call   8007dc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801363:	83 c4 2c             	add    $0x2c,%esp
  801366:	5b                   	pop    %ebx
  801367:	5e                   	pop    %esi
  801368:	5f                   	pop    %edi
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	57                   	push   %edi
  80136f:	56                   	push   %esi
  801370:	53                   	push   %ebx
  801371:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801374:	bb 00 00 00 00       	mov    $0x0,%ebx
  801379:	b8 08 00 00 00       	mov    $0x8,%eax
  80137e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801381:	8b 55 08             	mov    0x8(%ebp),%edx
  801384:	89 df                	mov    %ebx,%edi
  801386:	89 de                	mov    %ebx,%esi
  801388:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80138a:	85 c0                	test   %eax,%eax
  80138c:	7e 28                	jle    8013b6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80138e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801392:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801399:	00 
  80139a:	c7 44 24 08 ff 2c 80 	movl   $0x802cff,0x8(%esp)
  8013a1:	00 
  8013a2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013a9:	00 
  8013aa:	c7 04 24 1c 2d 80 00 	movl   $0x802d1c,(%esp)
  8013b1:	e8 26 f4 ff ff       	call   8007dc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013b6:	83 c4 2c             	add    $0x2c,%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5e                   	pop    %esi
  8013bb:	5f                   	pop    %edi
  8013bc:	5d                   	pop    %ebp
  8013bd:	c3                   	ret    

008013be <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	57                   	push   %edi
  8013c2:	56                   	push   %esi
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013cc:	b8 09 00 00 00       	mov    $0x9,%eax
  8013d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d7:	89 df                	mov    %ebx,%edi
  8013d9:	89 de                	mov    %ebx,%esi
  8013db:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	7e 28                	jle    801409 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013ec:	00 
  8013ed:	c7 44 24 08 ff 2c 80 	movl   $0x802cff,0x8(%esp)
  8013f4:	00 
  8013f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013fc:	00 
  8013fd:	c7 04 24 1c 2d 80 00 	movl   $0x802d1c,(%esp)
  801404:	e8 d3 f3 ff ff       	call   8007dc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801409:	83 c4 2c             	add    $0x2c,%esp
  80140c:	5b                   	pop    %ebx
  80140d:	5e                   	pop    %esi
  80140e:	5f                   	pop    %edi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	57                   	push   %edi
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80141a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801427:	8b 55 08             	mov    0x8(%ebp),%edx
  80142a:	89 df                	mov    %ebx,%edi
  80142c:	89 de                	mov    %ebx,%esi
  80142e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801430:	85 c0                	test   %eax,%eax
  801432:	7e 28                	jle    80145c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801434:	89 44 24 10          	mov    %eax,0x10(%esp)
  801438:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80143f:	00 
  801440:	c7 44 24 08 ff 2c 80 	movl   $0x802cff,0x8(%esp)
  801447:	00 
  801448:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80144f:	00 
  801450:	c7 04 24 1c 2d 80 00 	movl   $0x802d1c,(%esp)
  801457:	e8 80 f3 ff ff       	call   8007dc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80145c:	83 c4 2c             	add    $0x2c,%esp
  80145f:	5b                   	pop    %ebx
  801460:	5e                   	pop    %esi
  801461:	5f                   	pop    %edi
  801462:	5d                   	pop    %ebp
  801463:	c3                   	ret    

00801464 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	57                   	push   %edi
  801468:	56                   	push   %esi
  801469:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80146a:	be 00 00 00 00       	mov    $0x0,%esi
  80146f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801474:	8b 7d 14             	mov    0x14(%ebp),%edi
  801477:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80147a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80147d:	8b 55 08             	mov    0x8(%ebp),%edx
  801480:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801482:	5b                   	pop    %ebx
  801483:	5e                   	pop    %esi
  801484:	5f                   	pop    %edi
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	57                   	push   %edi
  80148b:	56                   	push   %esi
  80148c:	53                   	push   %ebx
  80148d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801490:	b9 00 00 00 00       	mov    $0x0,%ecx
  801495:	b8 0d 00 00 00       	mov    $0xd,%eax
  80149a:	8b 55 08             	mov    0x8(%ebp),%edx
  80149d:	89 cb                	mov    %ecx,%ebx
  80149f:	89 cf                	mov    %ecx,%edi
  8014a1:	89 ce                	mov    %ecx,%esi
  8014a3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	7e 28                	jle    8014d1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014ad:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8014b4:	00 
  8014b5:	c7 44 24 08 ff 2c 80 	movl   $0x802cff,0x8(%esp)
  8014bc:	00 
  8014bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014c4:	00 
  8014c5:	c7 04 24 1c 2d 80 00 	movl   $0x802d1c,(%esp)
  8014cc:	e8 0b f3 ff ff       	call   8007dc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014d1:	83 c4 2c             	add    $0x2c,%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5e                   	pop    %esi
  8014d6:	5f                   	pop    %edi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    
  8014d9:	00 00                	add    %al,(%eax)
	...

008014dc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	57                   	push   %edi
  8014e0:	56                   	push   %esi
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 1c             	sub    $0x1c,%esp
  8014e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014eb:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  8014ee:	85 db                	test   %ebx,%ebx
  8014f0:	75 05                	jne    8014f7 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  8014f2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8014f7:	89 1c 24             	mov    %ebx,(%esp)
  8014fa:	e8 88 ff ff ff       	call   801487 <sys_ipc_recv>
  8014ff:	85 c0                	test   %eax,%eax
  801501:	79 16                	jns    801519 <ipc_recv+0x3d>
		*from_env_store = 0;
  801503:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801509:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  80150f:	89 1c 24             	mov    %ebx,(%esp)
  801512:	e8 70 ff ff ff       	call   801487 <sys_ipc_recv>
  801517:	eb 24                	jmp    80153d <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801519:	85 f6                	test   %esi,%esi
  80151b:	74 0a                	je     801527 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  80151d:	a1 04 40 80 00       	mov    0x804004,%eax
  801522:	8b 40 74             	mov    0x74(%eax),%eax
  801525:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801527:	85 ff                	test   %edi,%edi
  801529:	74 0a                	je     801535 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  80152b:	a1 04 40 80 00       	mov    0x804004,%eax
  801530:	8b 40 78             	mov    0x78(%eax),%eax
  801533:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801535:	a1 04 40 80 00       	mov    0x804004,%eax
  80153a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80153d:	83 c4 1c             	add    $0x1c,%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5f                   	pop    %edi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	57                   	push   %edi
  801549:	56                   	push   %esi
  80154a:	53                   	push   %ebx
  80154b:	83 ec 1c             	sub    $0x1c,%esp
  80154e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801551:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801554:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801557:	85 db                	test   %ebx,%ebx
  801559:	75 05                	jne    801560 <ipc_send+0x1b>
		pg = (void *)-1;
  80155b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801560:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801564:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801568:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80156c:	8b 45 08             	mov    0x8(%ebp),%eax
  80156f:	89 04 24             	mov    %eax,(%esp)
  801572:	e8 ed fe ff ff       	call   801464 <sys_ipc_try_send>
		if (r == 0) {		
  801577:	85 c0                	test   %eax,%eax
  801579:	74 2c                	je     8015a7 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80157b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80157e:	75 07                	jne    801587 <ipc_send+0x42>
			sys_yield();
  801580:	e8 cd fc ff ff       	call   801252 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801585:	eb d9                	jmp    801560 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801587:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80158b:	c7 44 24 08 2a 2d 80 	movl   $0x802d2a,0x8(%esp)
  801592:	00 
  801593:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80159a:	00 
  80159b:	c7 04 24 38 2d 80 00 	movl   $0x802d38,(%esp)
  8015a2:	e8 35 f2 ff ff       	call   8007dc <_panic>
		}
	}
}
  8015a7:	83 c4 1c             	add    $0x1c,%esp
  8015aa:	5b                   	pop    %ebx
  8015ab:	5e                   	pop    %esi
  8015ac:	5f                   	pop    %edi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    

008015af <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	53                   	push   %ebx
  8015b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8015b6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8015bb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8015c2:	89 c2                	mov    %eax,%edx
  8015c4:	c1 e2 07             	shl    $0x7,%edx
  8015c7:	29 ca                	sub    %ecx,%edx
  8015c9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8015cf:	8b 52 50             	mov    0x50(%edx),%edx
  8015d2:	39 da                	cmp    %ebx,%edx
  8015d4:	75 0f                	jne    8015e5 <ipc_find_env+0x36>
			return envs[i].env_id;
  8015d6:	c1 e0 07             	shl    $0x7,%eax
  8015d9:	29 c8                	sub    %ecx,%eax
  8015db:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8015e0:	8b 40 40             	mov    0x40(%eax),%eax
  8015e3:	eb 0c                	jmp    8015f1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8015e5:	40                   	inc    %eax
  8015e6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8015eb:	75 ce                	jne    8015bb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8015ed:	66 b8 00 00          	mov    $0x0,%ax
}
  8015f1:	5b                   	pop    %ebx
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8015ff:	c1 e8 0c             	shr    $0xc,%eax
}
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    

00801604 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80160a:	8b 45 08             	mov    0x8(%ebp),%eax
  80160d:	89 04 24             	mov    %eax,(%esp)
  801610:	e8 df ff ff ff       	call   8015f4 <fd2num>
  801615:	05 20 00 0d 00       	add    $0xd0020,%eax
  80161a:	c1 e0 0c             	shl    $0xc,%eax
}
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	53                   	push   %ebx
  801623:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801626:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80162b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	c1 ea 16             	shr    $0x16,%edx
  801632:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801639:	f6 c2 01             	test   $0x1,%dl
  80163c:	74 11                	je     80164f <fd_alloc+0x30>
  80163e:	89 c2                	mov    %eax,%edx
  801640:	c1 ea 0c             	shr    $0xc,%edx
  801643:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80164a:	f6 c2 01             	test   $0x1,%dl
  80164d:	75 09                	jne    801658 <fd_alloc+0x39>
			*fd_store = fd;
  80164f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801651:	b8 00 00 00 00       	mov    $0x0,%eax
  801656:	eb 17                	jmp    80166f <fd_alloc+0x50>
  801658:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80165d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801662:	75 c7                	jne    80162b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801664:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80166a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80166f:	5b                   	pop    %ebx
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801678:	83 f8 1f             	cmp    $0x1f,%eax
  80167b:	77 36                	ja     8016b3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80167d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801682:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801685:	89 c2                	mov    %eax,%edx
  801687:	c1 ea 16             	shr    $0x16,%edx
  80168a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801691:	f6 c2 01             	test   $0x1,%dl
  801694:	74 24                	je     8016ba <fd_lookup+0x48>
  801696:	89 c2                	mov    %eax,%edx
  801698:	c1 ea 0c             	shr    $0xc,%edx
  80169b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016a2:	f6 c2 01             	test   $0x1,%dl
  8016a5:	74 1a                	je     8016c1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016aa:	89 02                	mov    %eax,(%edx)
	return 0;
  8016ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b1:	eb 13                	jmp    8016c6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b8:	eb 0c                	jmp    8016c6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016bf:	eb 05                	jmp    8016c6 <fd_lookup+0x54>
  8016c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 14             	sub    $0x14,%esp
  8016cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8016d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016da:	eb 0e                	jmp    8016ea <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8016dc:	39 08                	cmp    %ecx,(%eax)
  8016de:	75 09                	jne    8016e9 <dev_lookup+0x21>
			*dev = devtab[i];
  8016e0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8016e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e7:	eb 33                	jmp    80171c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016e9:	42                   	inc    %edx
  8016ea:	8b 04 95 c4 2d 80 00 	mov    0x802dc4(,%edx,4),%eax
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	75 e7                	jne    8016dc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8016fa:	8b 40 48             	mov    0x48(%eax),%eax
  8016fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801701:	89 44 24 04          	mov    %eax,0x4(%esp)
  801705:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  80170c:	e8 c3 f1 ff ff       	call   8008d4 <cprintf>
	*dev = 0;
  801711:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801717:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80171c:	83 c4 14             	add    $0x14,%esp
  80171f:	5b                   	pop    %ebx
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	83 ec 30             	sub    $0x30,%esp
  80172a:	8b 75 08             	mov    0x8(%ebp),%esi
  80172d:	8a 45 0c             	mov    0xc(%ebp),%al
  801730:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801733:	89 34 24             	mov    %esi,(%esp)
  801736:	e8 b9 fe ff ff       	call   8015f4 <fd2num>
  80173b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80173e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801742:	89 04 24             	mov    %eax,(%esp)
  801745:	e8 28 ff ff ff       	call   801672 <fd_lookup>
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 05                	js     801755 <fd_close+0x33>
	    || fd != fd2)
  801750:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801753:	74 0d                	je     801762 <fd_close+0x40>
		return (must_exist ? r : 0);
  801755:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801759:	75 46                	jne    8017a1 <fd_close+0x7f>
  80175b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801760:	eb 3f                	jmp    8017a1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801762:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801765:	89 44 24 04          	mov    %eax,0x4(%esp)
  801769:	8b 06                	mov    (%esi),%eax
  80176b:	89 04 24             	mov    %eax,(%esp)
  80176e:	e8 55 ff ff ff       	call   8016c8 <dev_lookup>
  801773:	89 c3                	mov    %eax,%ebx
  801775:	85 c0                	test   %eax,%eax
  801777:	78 18                	js     801791 <fd_close+0x6f>
		if (dev->dev_close)
  801779:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177c:	8b 40 10             	mov    0x10(%eax),%eax
  80177f:	85 c0                	test   %eax,%eax
  801781:	74 09                	je     80178c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801783:	89 34 24             	mov    %esi,(%esp)
  801786:	ff d0                	call   *%eax
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	eb 05                	jmp    801791 <fd_close+0x6f>
		else
			r = 0;
  80178c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801791:	89 74 24 04          	mov    %esi,0x4(%esp)
  801795:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179c:	e8 77 fb ff ff       	call   801318 <sys_page_unmap>
	return r;
}
  8017a1:	89 d8                	mov    %ebx,%eax
  8017a3:	83 c4 30             	add    $0x30,%esp
  8017a6:	5b                   	pop    %ebx
  8017a7:	5e                   	pop    %esi
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	89 04 24             	mov    %eax,(%esp)
  8017bd:	e8 b0 fe ff ff       	call   801672 <fd_lookup>
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 13                	js     8017d9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8017c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017cd:	00 
  8017ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d1:	89 04 24             	mov    %eax,(%esp)
  8017d4:	e8 49 ff ff ff       	call   801722 <fd_close>
}
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <close_all>:

void
close_all(void)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	53                   	push   %ebx
  8017df:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8017e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8017e7:	89 1c 24             	mov    %ebx,(%esp)
  8017ea:	e8 bb ff ff ff       	call   8017aa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8017ef:	43                   	inc    %ebx
  8017f0:	83 fb 20             	cmp    $0x20,%ebx
  8017f3:	75 f2                	jne    8017e7 <close_all+0xc>
		close(i);
}
  8017f5:	83 c4 14             	add    $0x14,%esp
  8017f8:	5b                   	pop    %ebx
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	57                   	push   %edi
  8017ff:	56                   	push   %esi
  801800:	53                   	push   %ebx
  801801:	83 ec 4c             	sub    $0x4c,%esp
  801804:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801807:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80180a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	89 04 24             	mov    %eax,(%esp)
  801814:	e8 59 fe ff ff       	call   801672 <fd_lookup>
  801819:	89 c3                	mov    %eax,%ebx
  80181b:	85 c0                	test   %eax,%eax
  80181d:	0f 88 e1 00 00 00    	js     801904 <dup+0x109>
		return r;
	close(newfdnum);
  801823:	89 3c 24             	mov    %edi,(%esp)
  801826:	e8 7f ff ff ff       	call   8017aa <close>

	newfd = INDEX2FD(newfdnum);
  80182b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801831:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801837:	89 04 24             	mov    %eax,(%esp)
  80183a:	e8 c5 fd ff ff       	call   801604 <fd2data>
  80183f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801841:	89 34 24             	mov    %esi,(%esp)
  801844:	e8 bb fd ff ff       	call   801604 <fd2data>
  801849:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80184c:	89 d8                	mov    %ebx,%eax
  80184e:	c1 e8 16             	shr    $0x16,%eax
  801851:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801858:	a8 01                	test   $0x1,%al
  80185a:	74 46                	je     8018a2 <dup+0xa7>
  80185c:	89 d8                	mov    %ebx,%eax
  80185e:	c1 e8 0c             	shr    $0xc,%eax
  801861:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801868:	f6 c2 01             	test   $0x1,%dl
  80186b:	74 35                	je     8018a2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80186d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801874:	25 07 0e 00 00       	and    $0xe07,%eax
  801879:	89 44 24 10          	mov    %eax,0x10(%esp)
  80187d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801880:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801884:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80188b:	00 
  80188c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801890:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801897:	e8 29 fa ff ff       	call   8012c5 <sys_page_map>
  80189c:	89 c3                	mov    %eax,%ebx
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 3b                	js     8018dd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018a5:	89 c2                	mov    %eax,%edx
  8018a7:	c1 ea 0c             	shr    $0xc,%edx
  8018aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018b1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8018b7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018c6:	00 
  8018c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d2:	e8 ee f9 ff ff       	call   8012c5 <sys_page_map>
  8018d7:	89 c3                	mov    %eax,%ebx
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	79 25                	jns    801902 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e8:	e8 2b fa ff ff       	call   801318 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8018ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fb:	e8 18 fa ff ff       	call   801318 <sys_page_unmap>
	return r;
  801900:	eb 02                	jmp    801904 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801902:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801904:	89 d8                	mov    %ebx,%eax
  801906:	83 c4 4c             	add    $0x4c,%esp
  801909:	5b                   	pop    %ebx
  80190a:	5e                   	pop    %esi
  80190b:	5f                   	pop    %edi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	53                   	push   %ebx
  801912:	83 ec 24             	sub    $0x24,%esp
  801915:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801918:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191f:	89 1c 24             	mov    %ebx,(%esp)
  801922:	e8 4b fd ff ff       	call   801672 <fd_lookup>
  801927:	85 c0                	test   %eax,%eax
  801929:	78 6d                	js     801998 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80192b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801932:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801935:	8b 00                	mov    (%eax),%eax
  801937:	89 04 24             	mov    %eax,(%esp)
  80193a:	e8 89 fd ff ff       	call   8016c8 <dev_lookup>
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 55                	js     801998 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801943:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801946:	8b 50 08             	mov    0x8(%eax),%edx
  801949:	83 e2 03             	and    $0x3,%edx
  80194c:	83 fa 01             	cmp    $0x1,%edx
  80194f:	75 23                	jne    801974 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801951:	a1 04 40 80 00       	mov    0x804004,%eax
  801956:	8b 40 48             	mov    0x48(%eax),%eax
  801959:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80195d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801961:	c7 04 24 88 2d 80 00 	movl   $0x802d88,(%esp)
  801968:	e8 67 ef ff ff       	call   8008d4 <cprintf>
		return -E_INVAL;
  80196d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801972:	eb 24                	jmp    801998 <read+0x8a>
	}
	if (!dev->dev_read)
  801974:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801977:	8b 52 08             	mov    0x8(%edx),%edx
  80197a:	85 d2                	test   %edx,%edx
  80197c:	74 15                	je     801993 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80197e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801981:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801985:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801988:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80198c:	89 04 24             	mov    %eax,(%esp)
  80198f:	ff d2                	call   *%edx
  801991:	eb 05                	jmp    801998 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801993:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801998:	83 c4 24             	add    $0x24,%esp
  80199b:	5b                   	pop    %ebx
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	57                   	push   %edi
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	83 ec 1c             	sub    $0x1c,%esp
  8019a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b2:	eb 23                	jmp    8019d7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019b4:	89 f0                	mov    %esi,%eax
  8019b6:	29 d8                	sub    %ebx,%eax
  8019b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bf:	01 d8                	add    %ebx,%eax
  8019c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c5:	89 3c 24             	mov    %edi,(%esp)
  8019c8:	e8 41 ff ff ff       	call   80190e <read>
		if (m < 0)
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	78 10                	js     8019e1 <readn+0x43>
			return m;
		if (m == 0)
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	74 0a                	je     8019df <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019d5:	01 c3                	add    %eax,%ebx
  8019d7:	39 f3                	cmp    %esi,%ebx
  8019d9:	72 d9                	jb     8019b4 <readn+0x16>
  8019db:	89 d8                	mov    %ebx,%eax
  8019dd:	eb 02                	jmp    8019e1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8019df:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8019e1:	83 c4 1c             	add    $0x1c,%esp
  8019e4:	5b                   	pop    %ebx
  8019e5:	5e                   	pop    %esi
  8019e6:	5f                   	pop    %edi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 24             	sub    $0x24,%esp
  8019f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fa:	89 1c 24             	mov    %ebx,(%esp)
  8019fd:	e8 70 fc ff ff       	call   801672 <fd_lookup>
  801a02:	85 c0                	test   %eax,%eax
  801a04:	78 68                	js     801a6e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a10:	8b 00                	mov    (%eax),%eax
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 ae fc ff ff       	call   8016c8 <dev_lookup>
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 50                	js     801a6e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a21:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a25:	75 23                	jne    801a4a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a27:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2c:	8b 40 48             	mov    0x48(%eax),%eax
  801a2f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a37:	c7 04 24 a4 2d 80 00 	movl   $0x802da4,(%esp)
  801a3e:	e8 91 ee ff ff       	call   8008d4 <cprintf>
		return -E_INVAL;
  801a43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a48:	eb 24                	jmp    801a6e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a4d:	8b 52 0c             	mov    0xc(%edx),%edx
  801a50:	85 d2                	test   %edx,%edx
  801a52:	74 15                	je     801a69 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a54:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a57:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a62:	89 04 24             	mov    %eax,(%esp)
  801a65:	ff d2                	call   *%edx
  801a67:	eb 05                	jmp    801a6e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a69:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801a6e:	83 c4 24             	add    $0x24,%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a7a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	89 04 24             	mov    %eax,(%esp)
  801a87:	e8 e6 fb ff ff       	call   801672 <fd_lookup>
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	78 0e                	js     801a9e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a90:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a93:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a96:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	53                   	push   %ebx
  801aa4:	83 ec 24             	sub    $0x24,%esp
  801aa7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aaa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab1:	89 1c 24             	mov    %ebx,(%esp)
  801ab4:	e8 b9 fb ff ff       	call   801672 <fd_lookup>
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	78 61                	js     801b1e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801abd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac7:	8b 00                	mov    (%eax),%eax
  801ac9:	89 04 24             	mov    %eax,(%esp)
  801acc:	e8 f7 fb ff ff       	call   8016c8 <dev_lookup>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 49                	js     801b1e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801adc:	75 23                	jne    801b01 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ade:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801ae3:	8b 40 48             	mov    0x48(%eax),%eax
  801ae6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801aea:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aee:	c7 04 24 64 2d 80 00 	movl   $0x802d64,(%esp)
  801af5:	e8 da ed ff ff       	call   8008d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801afa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801aff:	eb 1d                	jmp    801b1e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801b01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b04:	8b 52 18             	mov    0x18(%edx),%edx
  801b07:	85 d2                	test   %edx,%edx
  801b09:	74 0e                	je     801b19 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b12:	89 04 24             	mov    %eax,(%esp)
  801b15:	ff d2                	call   *%edx
  801b17:	eb 05                	jmp    801b1e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b19:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b1e:	83 c4 24             	add    $0x24,%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	53                   	push   %ebx
  801b28:	83 ec 24             	sub    $0x24,%esp
  801b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b35:	8b 45 08             	mov    0x8(%ebp),%eax
  801b38:	89 04 24             	mov    %eax,(%esp)
  801b3b:	e8 32 fb ff ff       	call   801672 <fd_lookup>
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 52                	js     801b96 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4e:	8b 00                	mov    (%eax),%eax
  801b50:	89 04 24             	mov    %eax,(%esp)
  801b53:	e8 70 fb ff ff       	call   8016c8 <dev_lookup>
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	78 3a                	js     801b96 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b63:	74 2c                	je     801b91 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b65:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b68:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b6f:	00 00 00 
	stat->st_isdir = 0;
  801b72:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b79:	00 00 00 
	stat->st_dev = dev;
  801b7c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b86:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b89:	89 14 24             	mov    %edx,(%esp)
  801b8c:	ff 50 14             	call   *0x14(%eax)
  801b8f:	eb 05                	jmp    801b96 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b91:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b96:	83 c4 24             	add    $0x24,%esp
  801b99:	5b                   	pop    %ebx
  801b9a:	5d                   	pop    %ebp
  801b9b:	c3                   	ret    

00801b9c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ba4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bab:	00 
  801bac:	8b 45 08             	mov    0x8(%ebp),%eax
  801baf:	89 04 24             	mov    %eax,(%esp)
  801bb2:	e8 fe 01 00 00       	call   801db5 <open>
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	78 1b                	js     801bd8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc4:	89 1c 24             	mov    %ebx,(%esp)
  801bc7:	e8 58 ff ff ff       	call   801b24 <fstat>
  801bcc:	89 c6                	mov    %eax,%esi
	close(fd);
  801bce:	89 1c 24             	mov    %ebx,(%esp)
  801bd1:	e8 d4 fb ff ff       	call   8017aa <close>
	return r;
  801bd6:	89 f3                	mov    %esi,%ebx
}
  801bd8:	89 d8                	mov    %ebx,%eax
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    
  801be1:	00 00                	add    %al,(%eax)
	...

00801be4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	83 ec 10             	sub    $0x10,%esp
  801bec:	89 c3                	mov    %eax,%ebx
  801bee:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801bf0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801bf7:	75 11                	jne    801c0a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801bf9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c00:	e8 aa f9 ff ff       	call   8015af <ipc_find_env>
  801c05:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c0a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c11:	00 
  801c12:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c19:	00 
  801c1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c1e:	a1 00 40 80 00       	mov    0x804000,%eax
  801c23:	89 04 24             	mov    %eax,(%esp)
  801c26:	e8 1a f9 ff ff       	call   801545 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c32:	00 
  801c33:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c3e:	e8 99 f8 ff ff       	call   8014dc <ipc_recv>
}
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	5b                   	pop    %ebx
  801c47:	5e                   	pop    %esi
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c50:	8b 45 08             	mov    0x8(%ebp),%eax
  801c53:	8b 40 0c             	mov    0xc(%eax),%eax
  801c56:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c63:	ba 00 00 00 00       	mov    $0x0,%edx
  801c68:	b8 02 00 00 00       	mov    $0x2,%eax
  801c6d:	e8 72 ff ff ff       	call   801be4 <fsipc>
}
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c80:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c85:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8a:	b8 06 00 00 00       	mov    $0x6,%eax
  801c8f:	e8 50 ff ff ff       	call   801be4 <fsipc>
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	53                   	push   %ebx
  801c9a:	83 ec 14             	sub    $0x14,%esp
  801c9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ca6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cab:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb0:	b8 05 00 00 00       	mov    $0x5,%eax
  801cb5:	e8 2a ff ff ff       	call   801be4 <fsipc>
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	78 2b                	js     801ce9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cbe:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cc5:	00 
  801cc6:	89 1c 24             	mov    %ebx,(%esp)
  801cc9:	e8 b1 f1 ff ff       	call   800e7f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cce:	a1 80 50 80 00       	mov    0x805080,%eax
  801cd3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cd9:	a1 84 50 80 00       	mov    0x805084,%eax
  801cde:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ce4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ce9:	83 c4 14             	add    $0x14,%esp
  801cec:	5b                   	pop    %ebx
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    

00801cef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801cf5:	c7 44 24 08 d4 2d 80 	movl   $0x802dd4,0x8(%esp)
  801cfc:	00 
  801cfd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801d04:	00 
  801d05:	c7 04 24 f2 2d 80 00 	movl   $0x802df2,(%esp)
  801d0c:	e8 cb ea ff ff       	call   8007dc <_panic>

00801d11 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	56                   	push   %esi
  801d15:	53                   	push   %ebx
  801d16:	83 ec 10             	sub    $0x10,%esp
  801d19:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d22:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d27:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d32:	b8 03 00 00 00       	mov    $0x3,%eax
  801d37:	e8 a8 fe ff ff       	call   801be4 <fsipc>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 6a                	js     801dac <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801d42:	39 c6                	cmp    %eax,%esi
  801d44:	73 24                	jae    801d6a <devfile_read+0x59>
  801d46:	c7 44 24 0c fd 2d 80 	movl   $0x802dfd,0xc(%esp)
  801d4d:	00 
  801d4e:	c7 44 24 08 04 2e 80 	movl   $0x802e04,0x8(%esp)
  801d55:	00 
  801d56:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801d5d:	00 
  801d5e:	c7 04 24 f2 2d 80 00 	movl   $0x802df2,(%esp)
  801d65:	e8 72 ea ff ff       	call   8007dc <_panic>
	assert(r <= PGSIZE);
  801d6a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d6f:	7e 24                	jle    801d95 <devfile_read+0x84>
  801d71:	c7 44 24 0c 19 2e 80 	movl   $0x802e19,0xc(%esp)
  801d78:	00 
  801d79:	c7 44 24 08 04 2e 80 	movl   $0x802e04,0x8(%esp)
  801d80:	00 
  801d81:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801d88:	00 
  801d89:	c7 04 24 f2 2d 80 00 	movl   $0x802df2,(%esp)
  801d90:	e8 47 ea ff ff       	call   8007dc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d95:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d99:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801da0:	00 
  801da1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da4:	89 04 24             	mov    %eax,(%esp)
  801da7:	e8 4c f2 ff ff       	call   800ff8 <memmove>
	return r;
}
  801dac:	89 d8                	mov    %ebx,%eax
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    

00801db5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	83 ec 20             	sub    $0x20,%esp
  801dbd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801dc0:	89 34 24             	mov    %esi,(%esp)
  801dc3:	e8 84 f0 ff ff       	call   800e4c <strlen>
  801dc8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801dcd:	7f 60                	jg     801e2f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801dcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd2:	89 04 24             	mov    %eax,(%esp)
  801dd5:	e8 45 f8 ff ff       	call   80161f <fd_alloc>
  801dda:	89 c3                	mov    %eax,%ebx
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 54                	js     801e34 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801de0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801de4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801deb:	e8 8f f0 ff ff       	call   800e7f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801df0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801df8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dfb:	b8 01 00 00 00       	mov    $0x1,%eax
  801e00:	e8 df fd ff ff       	call   801be4 <fsipc>
  801e05:	89 c3                	mov    %eax,%ebx
  801e07:	85 c0                	test   %eax,%eax
  801e09:	79 15                	jns    801e20 <open+0x6b>
		fd_close(fd, 0);
  801e0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e12:	00 
  801e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e16:	89 04 24             	mov    %eax,(%esp)
  801e19:	e8 04 f9 ff ff       	call   801722 <fd_close>
		return r;
  801e1e:	eb 14                	jmp    801e34 <open+0x7f>
	}

	return fd2num(fd);
  801e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e23:	89 04 24             	mov    %eax,(%esp)
  801e26:	e8 c9 f7 ff ff       	call   8015f4 <fd2num>
  801e2b:	89 c3                	mov    %eax,%ebx
  801e2d:	eb 05                	jmp    801e34 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e2f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e34:	89 d8                	mov    %ebx,%eax
  801e36:	83 c4 20             	add    $0x20,%esp
  801e39:	5b                   	pop    %ebx
  801e3a:	5e                   	pop    %esi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    

00801e3d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e43:	ba 00 00 00 00       	mov    $0x0,%edx
  801e48:	b8 08 00 00 00       	mov    $0x8,%eax
  801e4d:	e8 92 fd ff ff       	call   801be4 <fsipc>
}
  801e52:	c9                   	leave  
  801e53:	c3                   	ret    

00801e54 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	56                   	push   %esi
  801e58:	53                   	push   %ebx
  801e59:	83 ec 10             	sub    $0x10,%esp
  801e5c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e62:	89 04 24             	mov    %eax,(%esp)
  801e65:	e8 9a f7 ff ff       	call   801604 <fd2data>
  801e6a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e6c:	c7 44 24 04 25 2e 80 	movl   $0x802e25,0x4(%esp)
  801e73:	00 
  801e74:	89 34 24             	mov    %esi,(%esp)
  801e77:	e8 03 f0 ff ff       	call   800e7f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e7c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e7f:	2b 03                	sub    (%ebx),%eax
  801e81:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e87:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e8e:	00 00 00 
	stat->st_dev = &devpipe;
  801e91:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801e98:	30 80 00 
	return 0;
}
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	53                   	push   %ebx
  801eab:	83 ec 14             	sub    $0x14,%esp
  801eae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eb1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebc:	e8 57 f4 ff ff       	call   801318 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ec1:	89 1c 24             	mov    %ebx,(%esp)
  801ec4:	e8 3b f7 ff ff       	call   801604 <fd2data>
  801ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed4:	e8 3f f4 ff ff       	call   801318 <sys_page_unmap>
}
  801ed9:	83 c4 14             	add    $0x14,%esp
  801edc:	5b                   	pop    %ebx
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	57                   	push   %edi
  801ee3:	56                   	push   %esi
  801ee4:	53                   	push   %ebx
  801ee5:	83 ec 2c             	sub    $0x2c,%esp
  801ee8:	89 c7                	mov    %eax,%edi
  801eea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801eed:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ef5:	89 3c 24             	mov    %edi,(%esp)
  801ef8:	e8 6f 04 00 00       	call   80236c <pageref>
  801efd:	89 c6                	mov    %eax,%esi
  801eff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f02:	89 04 24             	mov    %eax,(%esp)
  801f05:	e8 62 04 00 00       	call   80236c <pageref>
  801f0a:	39 c6                	cmp    %eax,%esi
  801f0c:	0f 94 c0             	sete   %al
  801f0f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f12:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f18:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f1b:	39 cb                	cmp    %ecx,%ebx
  801f1d:	75 08                	jne    801f27 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f1f:	83 c4 2c             	add    $0x2c,%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5f                   	pop    %edi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f27:	83 f8 01             	cmp    $0x1,%eax
  801f2a:	75 c1                	jne    801eed <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f2c:	8b 42 58             	mov    0x58(%edx),%eax
  801f2f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801f36:	00 
  801f37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f3f:	c7 04 24 2c 2e 80 00 	movl   $0x802e2c,(%esp)
  801f46:	e8 89 e9 ff ff       	call   8008d4 <cprintf>
  801f4b:	eb a0                	jmp    801eed <_pipeisclosed+0xe>

00801f4d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	57                   	push   %edi
  801f51:	56                   	push   %esi
  801f52:	53                   	push   %ebx
  801f53:	83 ec 1c             	sub    $0x1c,%esp
  801f56:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f59:	89 34 24             	mov    %esi,(%esp)
  801f5c:	e8 a3 f6 ff ff       	call   801604 <fd2data>
  801f61:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f63:	bf 00 00 00 00       	mov    $0x0,%edi
  801f68:	eb 3c                	jmp    801fa6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f6a:	89 da                	mov    %ebx,%edx
  801f6c:	89 f0                	mov    %esi,%eax
  801f6e:	e8 6c ff ff ff       	call   801edf <_pipeisclosed>
  801f73:	85 c0                	test   %eax,%eax
  801f75:	75 38                	jne    801faf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f77:	e8 d6 f2 ff ff       	call   801252 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f7c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f7f:	8b 13                	mov    (%ebx),%edx
  801f81:	83 c2 20             	add    $0x20,%edx
  801f84:	39 d0                	cmp    %edx,%eax
  801f86:	73 e2                	jae    801f6a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f88:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801f8e:	89 c2                	mov    %eax,%edx
  801f90:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f96:	79 05                	jns    801f9d <devpipe_write+0x50>
  801f98:	4a                   	dec    %edx
  801f99:	83 ca e0             	or     $0xffffffe0,%edx
  801f9c:	42                   	inc    %edx
  801f9d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fa1:	40                   	inc    %eax
  801fa2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa5:	47                   	inc    %edi
  801fa6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fa9:	75 d1                	jne    801f7c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fab:	89 f8                	mov    %edi,%eax
  801fad:	eb 05                	jmp    801fb4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801faf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fb4:	83 c4 1c             	add    $0x1c,%esp
  801fb7:	5b                   	pop    %ebx
  801fb8:	5e                   	pop    %esi
  801fb9:	5f                   	pop    %edi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    

00801fbc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	57                   	push   %edi
  801fc0:	56                   	push   %esi
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 1c             	sub    $0x1c,%esp
  801fc5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fc8:	89 3c 24             	mov    %edi,(%esp)
  801fcb:	e8 34 f6 ff ff       	call   801604 <fd2data>
  801fd0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd2:	be 00 00 00 00       	mov    $0x0,%esi
  801fd7:	eb 3a                	jmp    802013 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fd9:	85 f6                	test   %esi,%esi
  801fdb:	74 04                	je     801fe1 <devpipe_read+0x25>
				return i;
  801fdd:	89 f0                	mov    %esi,%eax
  801fdf:	eb 40                	jmp    802021 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fe1:	89 da                	mov    %ebx,%edx
  801fe3:	89 f8                	mov    %edi,%eax
  801fe5:	e8 f5 fe ff ff       	call   801edf <_pipeisclosed>
  801fea:	85 c0                	test   %eax,%eax
  801fec:	75 2e                	jne    80201c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fee:	e8 5f f2 ff ff       	call   801252 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ff3:	8b 03                	mov    (%ebx),%eax
  801ff5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ff8:	74 df                	je     801fd9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ffa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801fff:	79 05                	jns    802006 <devpipe_read+0x4a>
  802001:	48                   	dec    %eax
  802002:	83 c8 e0             	or     $0xffffffe0,%eax
  802005:	40                   	inc    %eax
  802006:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80200a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802010:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802012:	46                   	inc    %esi
  802013:	3b 75 10             	cmp    0x10(%ebp),%esi
  802016:	75 db                	jne    801ff3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802018:	89 f0                	mov    %esi,%eax
  80201a:	eb 05                	jmp    802021 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80201c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802021:	83 c4 1c             	add    $0x1c,%esp
  802024:	5b                   	pop    %ebx
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	57                   	push   %edi
  80202d:	56                   	push   %esi
  80202e:	53                   	push   %ebx
  80202f:	83 ec 3c             	sub    $0x3c,%esp
  802032:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802035:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802038:	89 04 24             	mov    %eax,(%esp)
  80203b:	e8 df f5 ff ff       	call   80161f <fd_alloc>
  802040:	89 c3                	mov    %eax,%ebx
  802042:	85 c0                	test   %eax,%eax
  802044:	0f 88 45 01 00 00    	js     80218f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802051:	00 
  802052:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802055:	89 44 24 04          	mov    %eax,0x4(%esp)
  802059:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802060:	e8 0c f2 ff ff       	call   801271 <sys_page_alloc>
  802065:	89 c3                	mov    %eax,%ebx
  802067:	85 c0                	test   %eax,%eax
  802069:	0f 88 20 01 00 00    	js     80218f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80206f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802072:	89 04 24             	mov    %eax,(%esp)
  802075:	e8 a5 f5 ff ff       	call   80161f <fd_alloc>
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	85 c0                	test   %eax,%eax
  80207e:	0f 88 f8 00 00 00    	js     80217c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802084:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80208b:	00 
  80208c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80208f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802093:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209a:	e8 d2 f1 ff ff       	call   801271 <sys_page_alloc>
  80209f:	89 c3                	mov    %eax,%ebx
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	0f 88 d3 00 00 00    	js     80217c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ac:	89 04 24             	mov    %eax,(%esp)
  8020af:	e8 50 f5 ff ff       	call   801604 <fd2data>
  8020b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020bd:	00 
  8020be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c9:	e8 a3 f1 ff ff       	call   801271 <sys_page_alloc>
  8020ce:	89 c3                	mov    %eax,%ebx
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	0f 88 91 00 00 00    	js     802169 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020db:	89 04 24             	mov    %eax,(%esp)
  8020de:	e8 21 f5 ff ff       	call   801604 <fd2data>
  8020e3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8020ea:	00 
  8020eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020f6:	00 
  8020f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802102:	e8 be f1 ff ff       	call   8012c5 <sys_page_map>
  802107:	89 c3                	mov    %eax,%ebx
  802109:	85 c0                	test   %eax,%eax
  80210b:	78 4c                	js     802159 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80210d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802116:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802118:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80211b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802122:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802128:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80212b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80212d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802130:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80213a:	89 04 24             	mov    %eax,(%esp)
  80213d:	e8 b2 f4 ff ff       	call   8015f4 <fd2num>
  802142:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802144:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802147:	89 04 24             	mov    %eax,(%esp)
  80214a:	e8 a5 f4 ff ff       	call   8015f4 <fd2num>
  80214f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802152:	bb 00 00 00 00       	mov    $0x0,%ebx
  802157:	eb 36                	jmp    80218f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802159:	89 74 24 04          	mov    %esi,0x4(%esp)
  80215d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802164:	e8 af f1 ff ff       	call   801318 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802169:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80216c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802177:	e8 9c f1 ff ff       	call   801318 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80217c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80217f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802183:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80218a:	e8 89 f1 ff ff       	call   801318 <sys_page_unmap>
    err:
	return r;
}
  80218f:	89 d8                	mov    %ebx,%eax
  802191:	83 c4 3c             	add    $0x3c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    

00802199 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80219f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a9:	89 04 24             	mov    %eax,(%esp)
  8021ac:	e8 c1 f4 ff ff       	call   801672 <fd_lookup>
  8021b1:	85 c0                	test   %eax,%eax
  8021b3:	78 15                	js     8021ca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b8:	89 04 24             	mov    %eax,(%esp)
  8021bb:	e8 44 f4 ff ff       	call   801604 <fd2data>
	return _pipeisclosed(fd, p);
  8021c0:	89 c2                	mov    %eax,%edx
  8021c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c5:	e8 15 fd ff ff       	call   801edf <_pipeisclosed>
}
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8021dc:	c7 44 24 04 44 2e 80 	movl   $0x802e44,0x4(%esp)
  8021e3:	00 
  8021e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e7:	89 04 24             	mov    %eax,(%esp)
  8021ea:	e8 90 ec ff ff       	call   800e7f <strcpy>
	return 0;
}
  8021ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f4:	c9                   	leave  
  8021f5:	c3                   	ret    

008021f6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021f6:	55                   	push   %ebp
  8021f7:	89 e5                	mov    %esp,%ebp
  8021f9:	57                   	push   %edi
  8021fa:	56                   	push   %esi
  8021fb:	53                   	push   %ebx
  8021fc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802202:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802207:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80220d:	eb 30                	jmp    80223f <devcons_write+0x49>
		m = n - tot;
  80220f:	8b 75 10             	mov    0x10(%ebp),%esi
  802212:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802214:	83 fe 7f             	cmp    $0x7f,%esi
  802217:	76 05                	jbe    80221e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802219:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80221e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802222:	03 45 0c             	add    0xc(%ebp),%eax
  802225:	89 44 24 04          	mov    %eax,0x4(%esp)
  802229:	89 3c 24             	mov    %edi,(%esp)
  80222c:	e8 c7 ed ff ff       	call   800ff8 <memmove>
		sys_cputs(buf, m);
  802231:	89 74 24 04          	mov    %esi,0x4(%esp)
  802235:	89 3c 24             	mov    %edi,(%esp)
  802238:	e8 67 ef ff ff       	call   8011a4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80223d:	01 f3                	add    %esi,%ebx
  80223f:	89 d8                	mov    %ebx,%eax
  802241:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802244:	72 c9                	jb     80220f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802246:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80224c:	5b                   	pop    %ebx
  80224d:	5e                   	pop    %esi
  80224e:	5f                   	pop    %edi
  80224f:	5d                   	pop    %ebp
  802250:	c3                   	ret    

00802251 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802251:	55                   	push   %ebp
  802252:	89 e5                	mov    %esp,%ebp
  802254:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802257:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80225b:	75 07                	jne    802264 <devcons_read+0x13>
  80225d:	eb 25                	jmp    802284 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80225f:	e8 ee ef ff ff       	call   801252 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802264:	e8 59 ef ff ff       	call   8011c2 <sys_cgetc>
  802269:	85 c0                	test   %eax,%eax
  80226b:	74 f2                	je     80225f <devcons_read+0xe>
  80226d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80226f:	85 c0                	test   %eax,%eax
  802271:	78 1d                	js     802290 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802273:	83 f8 04             	cmp    $0x4,%eax
  802276:	74 13                	je     80228b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80227b:	88 10                	mov    %dl,(%eax)
	return 1;
  80227d:	b8 01 00 00 00       	mov    $0x1,%eax
  802282:	eb 0c                	jmp    802290 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802284:	b8 00 00 00 00       	mov    $0x0,%eax
  802289:	eb 05                	jmp    802290 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80228b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802298:	8b 45 08             	mov    0x8(%ebp),%eax
  80229b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80229e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8022a5:	00 
  8022a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a9:	89 04 24             	mov    %eax,(%esp)
  8022ac:	e8 f3 ee ff ff       	call   8011a4 <sys_cputs>
}
  8022b1:	c9                   	leave  
  8022b2:	c3                   	ret    

008022b3 <getchar>:

int
getchar(void)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8022c0:	00 
  8022c1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022cf:	e8 3a f6 ff ff       	call   80190e <read>
	if (r < 0)
  8022d4:	85 c0                	test   %eax,%eax
  8022d6:	78 0f                	js     8022e7 <getchar+0x34>
		return r;
	if (r < 1)
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	7e 06                	jle    8022e2 <getchar+0x2f>
		return -E_EOF;
	return c;
  8022dc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022e0:	eb 05                	jmp    8022e7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022e2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022e7:	c9                   	leave  
  8022e8:	c3                   	ret    

008022e9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f9:	89 04 24             	mov    %eax,(%esp)
  8022fc:	e8 71 f3 ff ff       	call   801672 <fd_lookup>
  802301:	85 c0                	test   %eax,%eax
  802303:	78 11                	js     802316 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802305:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802308:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80230e:	39 10                	cmp    %edx,(%eax)
  802310:	0f 94 c0             	sete   %al
  802313:	0f b6 c0             	movzbl %al,%eax
}
  802316:	c9                   	leave  
  802317:	c3                   	ret    

00802318 <opencons>:

int
opencons(void)
{
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80231e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802321:	89 04 24             	mov    %eax,(%esp)
  802324:	e8 f6 f2 ff ff       	call   80161f <fd_alloc>
  802329:	85 c0                	test   %eax,%eax
  80232b:	78 3c                	js     802369 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80232d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802334:	00 
  802335:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802343:	e8 29 ef ff ff       	call   801271 <sys_page_alloc>
  802348:	85 c0                	test   %eax,%eax
  80234a:	78 1d                	js     802369 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80234c:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802355:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802361:	89 04 24             	mov    %eax,(%esp)
  802364:	e8 8b f2 ff ff       	call   8015f4 <fd2num>
}
  802369:	c9                   	leave  
  80236a:	c3                   	ret    
	...

0080236c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802372:	89 c2                	mov    %eax,%edx
  802374:	c1 ea 16             	shr    $0x16,%edx
  802377:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80237e:	f6 c2 01             	test   $0x1,%dl
  802381:	74 1e                	je     8023a1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802383:	c1 e8 0c             	shr    $0xc,%eax
  802386:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80238d:	a8 01                	test   $0x1,%al
  80238f:	74 17                	je     8023a8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802391:	c1 e8 0c             	shr    $0xc,%eax
  802394:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80239b:	ef 
  80239c:	0f b7 c0             	movzwl %ax,%eax
  80239f:	eb 0c                	jmp    8023ad <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8023a6:	eb 05                	jmp    8023ad <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023a8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023ad:	5d                   	pop    %ebp
  8023ae:	c3                   	ret    
	...

008023b0 <__udivdi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	83 ec 10             	sub    $0x10,%esp
  8023b6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023ba:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8023be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023c2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8023c6:	89 cd                	mov    %ecx,%ebp
  8023c8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8023cc:	85 c0                	test   %eax,%eax
  8023ce:	75 2c                	jne    8023fc <__udivdi3+0x4c>
  8023d0:	39 f9                	cmp    %edi,%ecx
  8023d2:	77 68                	ja     80243c <__udivdi3+0x8c>
  8023d4:	85 c9                	test   %ecx,%ecx
  8023d6:	75 0b                	jne    8023e3 <__udivdi3+0x33>
  8023d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8023dd:	31 d2                	xor    %edx,%edx
  8023df:	f7 f1                	div    %ecx
  8023e1:	89 c1                	mov    %eax,%ecx
  8023e3:	31 d2                	xor    %edx,%edx
  8023e5:	89 f8                	mov    %edi,%eax
  8023e7:	f7 f1                	div    %ecx
  8023e9:	89 c7                	mov    %eax,%edi
  8023eb:	89 f0                	mov    %esi,%eax
  8023ed:	f7 f1                	div    %ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	89 f0                	mov    %esi,%eax
  8023f3:	89 fa                	mov    %edi,%edx
  8023f5:	83 c4 10             	add    $0x10,%esp
  8023f8:	5e                   	pop    %esi
  8023f9:	5f                   	pop    %edi
  8023fa:	5d                   	pop    %ebp
  8023fb:	c3                   	ret    
  8023fc:	39 f8                	cmp    %edi,%eax
  8023fe:	77 2c                	ja     80242c <__udivdi3+0x7c>
  802400:	0f bd f0             	bsr    %eax,%esi
  802403:	83 f6 1f             	xor    $0x1f,%esi
  802406:	75 4c                	jne    802454 <__udivdi3+0xa4>
  802408:	39 f8                	cmp    %edi,%eax
  80240a:	bf 00 00 00 00       	mov    $0x0,%edi
  80240f:	72 0a                	jb     80241b <__udivdi3+0x6b>
  802411:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802415:	0f 87 ad 00 00 00    	ja     8024c8 <__udivdi3+0x118>
  80241b:	be 01 00 00 00       	mov    $0x1,%esi
  802420:	89 f0                	mov    %esi,%eax
  802422:	89 fa                	mov    %edi,%edx
  802424:	83 c4 10             	add    $0x10,%esp
  802427:	5e                   	pop    %esi
  802428:	5f                   	pop    %edi
  802429:	5d                   	pop    %ebp
  80242a:	c3                   	ret    
  80242b:	90                   	nop
  80242c:	31 ff                	xor    %edi,%edi
  80242e:	31 f6                	xor    %esi,%esi
  802430:	89 f0                	mov    %esi,%eax
  802432:	89 fa                	mov    %edi,%edx
  802434:	83 c4 10             	add    $0x10,%esp
  802437:	5e                   	pop    %esi
  802438:	5f                   	pop    %edi
  802439:	5d                   	pop    %ebp
  80243a:	c3                   	ret    
  80243b:	90                   	nop
  80243c:	89 fa                	mov    %edi,%edx
  80243e:	89 f0                	mov    %esi,%eax
  802440:	f7 f1                	div    %ecx
  802442:	89 c6                	mov    %eax,%esi
  802444:	31 ff                	xor    %edi,%edi
  802446:	89 f0                	mov    %esi,%eax
  802448:	89 fa                	mov    %edi,%edx
  80244a:	83 c4 10             	add    $0x10,%esp
  80244d:	5e                   	pop    %esi
  80244e:	5f                   	pop    %edi
  80244f:	5d                   	pop    %ebp
  802450:	c3                   	ret    
  802451:	8d 76 00             	lea    0x0(%esi),%esi
  802454:	89 f1                	mov    %esi,%ecx
  802456:	d3 e0                	shl    %cl,%eax
  802458:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80245c:	b8 20 00 00 00       	mov    $0x20,%eax
  802461:	29 f0                	sub    %esi,%eax
  802463:	89 ea                	mov    %ebp,%edx
  802465:	88 c1                	mov    %al,%cl
  802467:	d3 ea                	shr    %cl,%edx
  802469:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80246d:	09 ca                	or     %ecx,%edx
  80246f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802473:	89 f1                	mov    %esi,%ecx
  802475:	d3 e5                	shl    %cl,%ebp
  802477:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80247b:	89 fd                	mov    %edi,%ebp
  80247d:	88 c1                	mov    %al,%cl
  80247f:	d3 ed                	shr    %cl,%ebp
  802481:	89 fa                	mov    %edi,%edx
  802483:	89 f1                	mov    %esi,%ecx
  802485:	d3 e2                	shl    %cl,%edx
  802487:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80248b:	88 c1                	mov    %al,%cl
  80248d:	d3 ef                	shr    %cl,%edi
  80248f:	09 d7                	or     %edx,%edi
  802491:	89 f8                	mov    %edi,%eax
  802493:	89 ea                	mov    %ebp,%edx
  802495:	f7 74 24 08          	divl   0x8(%esp)
  802499:	89 d1                	mov    %edx,%ecx
  80249b:	89 c7                	mov    %eax,%edi
  80249d:	f7 64 24 0c          	mull   0xc(%esp)
  8024a1:	39 d1                	cmp    %edx,%ecx
  8024a3:	72 17                	jb     8024bc <__udivdi3+0x10c>
  8024a5:	74 09                	je     8024b0 <__udivdi3+0x100>
  8024a7:	89 fe                	mov    %edi,%esi
  8024a9:	31 ff                	xor    %edi,%edi
  8024ab:	e9 41 ff ff ff       	jmp    8023f1 <__udivdi3+0x41>
  8024b0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024b4:	89 f1                	mov    %esi,%ecx
  8024b6:	d3 e2                	shl    %cl,%edx
  8024b8:	39 c2                	cmp    %eax,%edx
  8024ba:	73 eb                	jae    8024a7 <__udivdi3+0xf7>
  8024bc:	8d 77 ff             	lea    -0x1(%edi),%esi
  8024bf:	31 ff                	xor    %edi,%edi
  8024c1:	e9 2b ff ff ff       	jmp    8023f1 <__udivdi3+0x41>
  8024c6:	66 90                	xchg   %ax,%ax
  8024c8:	31 f6                	xor    %esi,%esi
  8024ca:	e9 22 ff ff ff       	jmp    8023f1 <__udivdi3+0x41>
	...

008024d0 <__umoddi3>:
  8024d0:	55                   	push   %ebp
  8024d1:	57                   	push   %edi
  8024d2:	56                   	push   %esi
  8024d3:	83 ec 20             	sub    $0x20,%esp
  8024d6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024da:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8024de:	89 44 24 14          	mov    %eax,0x14(%esp)
  8024e2:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024e6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024ea:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8024ee:	89 c7                	mov    %eax,%edi
  8024f0:	89 f2                	mov    %esi,%edx
  8024f2:	85 ed                	test   %ebp,%ebp
  8024f4:	75 16                	jne    80250c <__umoddi3+0x3c>
  8024f6:	39 f1                	cmp    %esi,%ecx
  8024f8:	0f 86 a6 00 00 00    	jbe    8025a4 <__umoddi3+0xd4>
  8024fe:	f7 f1                	div    %ecx
  802500:	89 d0                	mov    %edx,%eax
  802502:	31 d2                	xor    %edx,%edx
  802504:	83 c4 20             	add    $0x20,%esp
  802507:	5e                   	pop    %esi
  802508:	5f                   	pop    %edi
  802509:	5d                   	pop    %ebp
  80250a:	c3                   	ret    
  80250b:	90                   	nop
  80250c:	39 f5                	cmp    %esi,%ebp
  80250e:	0f 87 ac 00 00 00    	ja     8025c0 <__umoddi3+0xf0>
  802514:	0f bd c5             	bsr    %ebp,%eax
  802517:	83 f0 1f             	xor    $0x1f,%eax
  80251a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80251e:	0f 84 a8 00 00 00    	je     8025cc <__umoddi3+0xfc>
  802524:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802528:	d3 e5                	shl    %cl,%ebp
  80252a:	bf 20 00 00 00       	mov    $0x20,%edi
  80252f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802533:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802537:	89 f9                	mov    %edi,%ecx
  802539:	d3 e8                	shr    %cl,%eax
  80253b:	09 e8                	or     %ebp,%eax
  80253d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802541:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802545:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802549:	d3 e0                	shl    %cl,%eax
  80254b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80254f:	89 f2                	mov    %esi,%edx
  802551:	d3 e2                	shl    %cl,%edx
  802553:	8b 44 24 14          	mov    0x14(%esp),%eax
  802557:	d3 e0                	shl    %cl,%eax
  802559:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80255d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802561:	89 f9                	mov    %edi,%ecx
  802563:	d3 e8                	shr    %cl,%eax
  802565:	09 d0                	or     %edx,%eax
  802567:	d3 ee                	shr    %cl,%esi
  802569:	89 f2                	mov    %esi,%edx
  80256b:	f7 74 24 18          	divl   0x18(%esp)
  80256f:	89 d6                	mov    %edx,%esi
  802571:	f7 64 24 0c          	mull   0xc(%esp)
  802575:	89 c5                	mov    %eax,%ebp
  802577:	89 d1                	mov    %edx,%ecx
  802579:	39 d6                	cmp    %edx,%esi
  80257b:	72 67                	jb     8025e4 <__umoddi3+0x114>
  80257d:	74 75                	je     8025f4 <__umoddi3+0x124>
  80257f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802583:	29 e8                	sub    %ebp,%eax
  802585:	19 ce                	sbb    %ecx,%esi
  802587:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	89 f2                	mov    %esi,%edx
  80258f:	89 f9                	mov    %edi,%ecx
  802591:	d3 e2                	shl    %cl,%edx
  802593:	09 d0                	or     %edx,%eax
  802595:	89 f2                	mov    %esi,%edx
  802597:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80259b:	d3 ea                	shr    %cl,%edx
  80259d:	83 c4 20             	add    $0x20,%esp
  8025a0:	5e                   	pop    %esi
  8025a1:	5f                   	pop    %edi
  8025a2:	5d                   	pop    %ebp
  8025a3:	c3                   	ret    
  8025a4:	85 c9                	test   %ecx,%ecx
  8025a6:	75 0b                	jne    8025b3 <__umoddi3+0xe3>
  8025a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ad:	31 d2                	xor    %edx,%edx
  8025af:	f7 f1                	div    %ecx
  8025b1:	89 c1                	mov    %eax,%ecx
  8025b3:	89 f0                	mov    %esi,%eax
  8025b5:	31 d2                	xor    %edx,%edx
  8025b7:	f7 f1                	div    %ecx
  8025b9:	89 f8                	mov    %edi,%eax
  8025bb:	e9 3e ff ff ff       	jmp    8024fe <__umoddi3+0x2e>
  8025c0:	89 f2                	mov    %esi,%edx
  8025c2:	83 c4 20             	add    $0x20,%esp
  8025c5:	5e                   	pop    %esi
  8025c6:	5f                   	pop    %edi
  8025c7:	5d                   	pop    %ebp
  8025c8:	c3                   	ret    
  8025c9:	8d 76 00             	lea    0x0(%esi),%esi
  8025cc:	39 f5                	cmp    %esi,%ebp
  8025ce:	72 04                	jb     8025d4 <__umoddi3+0x104>
  8025d0:	39 f9                	cmp    %edi,%ecx
  8025d2:	77 06                	ja     8025da <__umoddi3+0x10a>
  8025d4:	89 f2                	mov    %esi,%edx
  8025d6:	29 cf                	sub    %ecx,%edi
  8025d8:	19 ea                	sbb    %ebp,%edx
  8025da:	89 f8                	mov    %edi,%eax
  8025dc:	83 c4 20             	add    $0x20,%esp
  8025df:	5e                   	pop    %esi
  8025e0:	5f                   	pop    %edi
  8025e1:	5d                   	pop    %ebp
  8025e2:	c3                   	ret    
  8025e3:	90                   	nop
  8025e4:	89 d1                	mov    %edx,%ecx
  8025e6:	89 c5                	mov    %eax,%ebp
  8025e8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8025ec:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8025f0:	eb 8d                	jmp    80257f <__umoddi3+0xaf>
  8025f2:	66 90                	xchg   %ax,%ax
  8025f4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8025f8:	72 ea                	jb     8025e4 <__umoddi3+0x114>
  8025fa:	89 f1                	mov    %esi,%ecx
  8025fc:	eb 81                	jmp    80257f <__umoddi3+0xaf>
