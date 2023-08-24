
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 5f 1d 00 00       	call   801d90 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	88 c1                	mov    %al,%cl

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80003a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003f:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800040:	0f b6 c0             	movzbl %al,%eax
  800043:	89 c3                	mov    %eax,%ebx
  800045:	81 e3 c0 00 00 00    	and    $0xc0,%ebx
  80004b:	83 fb 40             	cmp    $0x40,%ebx
  80004e:	75 ef                	jne    80003f <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  800050:	84 c9                	test   %cl,%cl
  800052:	74 0c                	je     800060 <ide_wait_ready+0x2c>
  800054:	83 e0 21             	and    $0x21,%eax
		return -1;
	return 0;
  800057:	83 f8 01             	cmp    $0x1,%eax
  80005a:	19 c0                	sbb    %eax,%eax
  80005c:	f7 d0                	not    %eax
  80005e:	eb 05                	jmp    800065 <ide_wait_ready+0x31>
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800065:	5b                   	pop    %ebx
  800066:	5d                   	pop    %ebp
  800067:	c3                   	ret    

00800068 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	53                   	push   %ebx
  80006c:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80006f:	b8 00 00 00 00       	mov    $0x0,%eax
  800074:	e8 bb ff ff ff       	call   800034 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800079:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007e:	b0 f0                	mov    $0xf0,%al
  800080:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800081:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800086:	b2 f7                	mov    $0xf7,%dl
  800088:	eb 09                	jmp    800093 <ide_probe_disk1+0x2b>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  80008a:	43                   	inc    %ebx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008b:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  800091:	74 05                	je     800098 <ide_probe_disk1+0x30>
  800093:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800094:	a8 a1                	test   $0xa1,%al
  800096:	75 f2                	jne    80008a <ide_probe_disk1+0x22>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800098:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009d:	b0 e0                	mov    $0xe0,%al
  80009f:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a0:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000a6:	0f 9e c0             	setle  %al
  8000a9:	0f b6 c0             	movzbl %al,%eax
  8000ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b0:	c7 04 24 a0 3c 80 00 	movl   $0x803ca0,(%esp)
  8000b7:	e8 3c 1e 00 00       	call   801ef8 <cprintf>
	return (x < 1000);
  8000bc:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000c2:	0f 9e c0             	setle  %al
}
  8000c5:	83 c4 14             	add    $0x14,%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 18             	sub    $0x18,%esp
  8000d1:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000d4:	83 f8 01             	cmp    $0x1,%eax
  8000d7:	76 1c                	jbe    8000f5 <ide_set_disk+0x2a>
		panic("bad disk number");
  8000d9:	c7 44 24 08 b7 3c 80 	movl   $0x803cb7,0x8(%esp)
  8000e0:	00 
  8000e1:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e8:	00 
  8000e9:	c7 04 24 c7 3c 80 00 	movl   $0x803cc7,(%esp)
  8000f0:	e8 0b 1d 00 00       	call   801e00 <_panic>
	diskno = d;
  8000f5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	83 ec 1c             	sub    $0x1c,%esp
  800105:	8b 7d 08             	mov    0x8(%ebp),%edi
  800108:	8b 75 0c             	mov    0xc(%ebp),%esi
  80010b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  80010e:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  800114:	76 24                	jbe    80013a <ide_read+0x3e>
  800116:	c7 44 24 0c d0 3c 80 	movl   $0x803cd0,0xc(%esp)
  80011d:	00 
  80011e:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  800125:	00 
  800126:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  80012d:	00 
  80012e:	c7 04 24 c7 3c 80 00 	movl   $0x803cc7,(%esp)
  800135:	e8 c6 1c 00 00       	call   801e00 <_panic>

	ide_wait_ready(0);
  80013a:	b8 00 00 00 00       	mov    $0x0,%eax
  80013f:	e8 f0 fe ff ff       	call   800034 <ide_wait_ready>
  800144:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800149:	88 d8                	mov    %bl,%al
  80014b:	ee                   	out    %al,(%dx)
  80014c:	b2 f3                	mov    $0xf3,%dl
  80014e:	89 f8                	mov    %edi,%eax
  800150:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800151:	89 f8                	mov    %edi,%eax
  800153:	c1 e8 08             	shr    $0x8,%eax
  800156:	b2 f4                	mov    $0xf4,%dl
  800158:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800159:	89 f8                	mov    %edi,%eax
  80015b:	c1 e8 10             	shr    $0x10,%eax
  80015e:	b2 f5                	mov    $0xf5,%dl
  800160:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800161:	a1 00 50 80 00       	mov    0x805000,%eax
  800166:	83 e0 01             	and    $0x1,%eax
  800169:	c1 e0 04             	shl    $0x4,%eax
  80016c:	83 c8 e0             	or     $0xffffffe0,%eax
  80016f:	c1 ef 18             	shr    $0x18,%edi
  800172:	83 e7 0f             	and    $0xf,%edi
  800175:	09 f8                	or     %edi,%eax
  800177:	b2 f6                	mov    $0xf6,%dl
  800179:	ee                   	out    %al,(%dx)
  80017a:	b2 f7                	mov    $0xf7,%dl
  80017c:	b0 20                	mov    $0x20,%al
  80017e:	ee                   	out    %al,(%dx)
  80017f:	eb 24                	jmp    8001a5 <ide_read+0xa9>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800181:	b8 01 00 00 00       	mov    $0x1,%eax
  800186:	e8 a9 fe ff ff       	call   800034 <ide_wait_ready>
  80018b:	85 c0                	test   %eax,%eax
  80018d:	78 1f                	js     8001ae <ide_read+0xb2>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018f:	89 f7                	mov    %esi,%edi
  800191:	b9 80 00 00 00       	mov    $0x80,%ecx
  800196:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80019b:	fc                   	cld    
  80019c:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80019e:	4b                   	dec    %ebx
  80019f:	81 c6 00 02 00 00    	add    $0x200,%esi
  8001a5:	85 db                	test   %ebx,%ebx
  8001a7:	75 d8                	jne    800181 <ide_read+0x85>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001ae:	83 c4 1c             	add    $0x1c,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5f                   	pop    %edi
  8001b4:	5d                   	pop    %ebp
  8001b5:	c3                   	ret    

008001b6 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 1c             	sub    $0x1c,%esp
  8001bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  8001c8:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  8001ce:	76 24                	jbe    8001f4 <ide_write+0x3e>
  8001d0:	c7 44 24 0c d0 3c 80 	movl   $0x803cd0,0xc(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8001df:	00 
  8001e0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e7:	00 
  8001e8:	c7 04 24 c7 3c 80 00 	movl   $0x803cc7,(%esp)
  8001ef:	e8 0c 1c 00 00       	call   801e00 <_panic>

	ide_wait_ready(0);
  8001f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001f9:	e8 36 fe ff ff       	call   800034 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001fe:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800203:	88 d8                	mov    %bl,%al
  800205:	ee                   	out    %al,(%dx)
  800206:	b2 f3                	mov    $0xf3,%dl
  800208:	89 f0                	mov    %esi,%eax
  80020a:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  80020b:	89 f0                	mov    %esi,%eax
  80020d:	c1 e8 08             	shr    $0x8,%eax
  800210:	b2 f4                	mov    $0xf4,%dl
  800212:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800213:	89 f0                	mov    %esi,%eax
  800215:	c1 e8 10             	shr    $0x10,%eax
  800218:	b2 f5                	mov    $0xf5,%dl
  80021a:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80021b:	a1 00 50 80 00       	mov    0x805000,%eax
  800220:	83 e0 01             	and    $0x1,%eax
  800223:	c1 e0 04             	shl    $0x4,%eax
  800226:	83 c8 e0             	or     $0xffffffe0,%eax
  800229:	c1 ee 18             	shr    $0x18,%esi
  80022c:	83 e6 0f             	and    $0xf,%esi
  80022f:	09 f0                	or     %esi,%eax
  800231:	b2 f6                	mov    $0xf6,%dl
  800233:	ee                   	out    %al,(%dx)
  800234:	b2 f7                	mov    $0xf7,%dl
  800236:	b0 30                	mov    $0x30,%al
  800238:	ee                   	out    %al,(%dx)
  800239:	eb 24                	jmp    80025f <ide_write+0xa9>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80023b:	b8 01 00 00 00       	mov    $0x1,%eax
  800240:	e8 ef fd ff ff       	call   800034 <ide_wait_ready>
  800245:	85 c0                	test   %eax,%eax
  800247:	78 1f                	js     800268 <ide_write+0xb2>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800249:	89 fe                	mov    %edi,%esi
  80024b:	b9 80 00 00 00       	mov    $0x80,%ecx
  800250:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800255:	fc                   	cld    
  800256:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800258:	4b                   	dec    %ebx
  800259:	81 c7 00 02 00 00    	add    $0x200,%edi
  80025f:	85 db                	test   %ebx,%ebx
  800261:	75 d8                	jne    80023b <ide_write+0x85>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800268:	83 c4 1c             	add    $0x1c,%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 20             	sub    $0x20,%esp
  800278:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80027b:	8b 18                	mov    (%eax),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80027d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
  800283:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800289:	76 2e                	jbe    8002b9 <bc_pgfault+0x49>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  80028b:	8b 50 04             	mov    0x4(%eax),%edx
  80028e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800292:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800296:	8b 40 28             	mov    0x28(%eax),%eax
  800299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029d:	c7 44 24 08 f4 3c 80 	movl   $0x803cf4,0x8(%esp)
  8002a4:	00 
  8002a5:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8002ac:	00 
  8002ad:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  8002b4:	e8 47 1b 00 00       	call   801e00 <_panic>
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8002b9:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi
  8002bf:	c1 ee 0c             	shr    $0xc,%esi
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002c2:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	74 25                	je     8002f0 <bc_pgfault+0x80>
  8002cb:	3b 70 04             	cmp    0x4(%eax),%esi
  8002ce:	72 20                	jb     8002f0 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  8002d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d4:	c7 44 24 08 24 3d 80 	movl   $0x803d24,0x8(%esp)
  8002db:	00 
  8002dc:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8002e3:	00 
  8002e4:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  8002eb:	e8 10 1b 00 00       	call   801e00 <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
  8002f0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, addr, PTE_P | PTE_W | PTE_U)) < 0){
  8002f6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8002fd:	00 
  8002fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800302:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800309:	e8 87 25 00 00       	call   802895 <sys_page_alloc>
  80030e:	85 c0                	test   %eax,%eax
  800310:	79 20                	jns    800332 <bc_pgfault+0xc2>
		panic("In bc_pgfault, sys_page_alloc fault: %e", r);
  800312:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800316:	c7 44 24 08 48 3d 80 	movl   $0x803d48,0x8(%esp)
  80031d:	00 
  80031e:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  800325:	00 
  800326:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  80032d:	e8 ce 1a 00 00       	call   801e00 <_panic>
	}
	if ((r = ide_read(blockno*BLKSECTS, addr, BLKSECTS)) < 0){
  800332:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  800339:	00 
  80033a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033e:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	e8 af fd ff ff       	call   8000fc <ide_read>
  80034d:	85 c0                	test   %eax,%eax
  80034f:	79 20                	jns    800371 <bc_pgfault+0x101>
		panic("In bc_pgfault, ide_read fault: %e", r);
  800351:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800355:	c7 44 24 08 70 3d 80 	movl   $0x803d70,0x8(%esp)
  80035c:	00 
  80035d:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800364:	00 
  800365:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  80036c:	e8 8f 1a 00 00       	call   801e00 <_panic>
	}
	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800371:	89 d8                	mov    %ebx,%eax
  800373:	c1 e8 0c             	shr    $0xc,%eax
  800376:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80037d:	25 07 0e 00 00       	and    $0xe07,%eax
  800382:	89 44 24 10          	mov    %eax,0x10(%esp)
  800386:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80038a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800391:	00 
  800392:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800396:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80039d:	e8 47 25 00 00       	call   8028e9 <sys_page_map>
  8003a2:	85 c0                	test   %eax,%eax
  8003a4:	79 20                	jns    8003c6 <bc_pgfault+0x156>
		panic("in bc_pgfault, sys_page_map: %e", r);
  8003a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003aa:	c7 44 24 08 94 3d 80 	movl   $0x803d94,0x8(%esp)
  8003b1:	00 
  8003b2:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  8003b9:	00 
  8003ba:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  8003c1:	e8 3a 1a 00 00       	call   801e00 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003c6:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8003cd:	74 2c                	je     8003fb <bc_pgfault+0x18b>
  8003cf:	89 34 24             	mov    %esi,(%esp)
  8003d2:	e8 80 05 00 00       	call   800957 <block_is_free>
  8003d7:	84 c0                	test   %al,%al
  8003d9:	74 20                	je     8003fb <bc_pgfault+0x18b>
		panic("reading free block %08x\n", blockno);
  8003db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003df:	c7 44 24 08 50 3e 80 	movl   $0x803e50,0x8(%esp)
  8003e6:	00 
  8003e7:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  8003ee:	00 
  8003ef:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  8003f6:	e8 05 1a 00 00       	call   801e00 <_panic>
}
  8003fb:	83 c4 20             	add    $0x20,%esp
  8003fe:	5b                   	pop    %ebx
  8003ff:	5e                   	pop    %esi
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	83 ec 18             	sub    $0x18,%esp
  800408:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80040b:	85 c0                	test   %eax,%eax
  80040d:	74 0f                	je     80041e <diskaddr+0x1c>
  80040f:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800415:	85 d2                	test   %edx,%edx
  800417:	74 25                	je     80043e <diskaddr+0x3c>
  800419:	3b 42 04             	cmp    0x4(%edx),%eax
  80041c:	72 20                	jb     80043e <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  80041e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800422:	c7 44 24 08 b4 3d 80 	movl   $0x803db4,0x8(%esp)
  800429:	00 
  80042a:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800431:	00 
  800432:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  800439:	e8 c2 19 00 00       	call   801e00 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  80043e:	05 00 00 01 00       	add    $0x10000,%eax
  800443:	c1 e0 0c             	shl    $0xc,%eax
}
  800446:	c9                   	leave  
  800447:	c3                   	ret    

00800448 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  80044e:	89 c2                	mov    %eax,%edx
  800450:	c1 ea 16             	shr    $0x16,%edx
  800453:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80045a:	f6 c2 01             	test   $0x1,%dl
  80045d:	74 0f                	je     80046e <va_is_mapped+0x26>
  80045f:	c1 e8 0c             	shr    $0xc,%eax
  800462:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800469:	83 e0 01             	and    $0x1,%eax
  80046c:	eb 05                	jmp    800473 <va_is_mapped+0x2b>
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    

00800475 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  800475:	55                   	push   %ebp
  800476:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800478:	8b 45 08             	mov    0x8(%ebp),%eax
  80047b:	c1 e8 0c             	shr    $0xc,%eax
  80047e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800485:	a8 40                	test   $0x40,%al
  800487:	0f 95 c0             	setne  %al
}
  80048a:	5d                   	pop    %ebp
  80048b:	c3                   	ret    

0080048c <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	56                   	push   %esi
  800490:	53                   	push   %ebx
  800491:	83 ec 20             	sub    $0x20,%esp
  800494:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800497:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  80049d:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8004a2:	76 20                	jbe    8004c4 <flush_block+0x38>
		panic("flush_block of bad va %08x", addr);
  8004a4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004a8:	c7 44 24 08 69 3e 80 	movl   $0x803e69,0x8(%esp)
  8004af:	00 
  8004b0:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8004b7:	00 
  8004b8:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  8004bf:	e8 3c 19 00 00       	call   801e00 <_panic>

	// LAB 5: Your code here.
	int r;
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
  8004c4:	89 f3                	mov    %esi,%ebx
  8004c6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(va_is_mapped(addr) && va_is_dirty(addr)){
  8004cc:	89 1c 24             	mov    %ebx,(%esp)
  8004cf:	e8 74 ff ff ff       	call   800448 <va_is_mapped>
  8004d4:	84 c0                	test   %al,%al
  8004d6:	0f 84 a9 00 00 00    	je     800585 <flush_block+0xf9>
  8004dc:	89 1c 24             	mov    %ebx,(%esp)
  8004df:	e8 91 ff ff ff       	call   800475 <va_is_dirty>
  8004e4:	84 c0                	test   %al,%al
  8004e6:	0f 84 99 00 00 00    	je     800585 <flush_block+0xf9>
		if ((r = ide_write(blockno * BLKSECTS,addr,BLKSECTS)) < 0 ) 
  8004ec:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8004f3:	00 
  8004f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8004f8:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
  8004fe:	c1 ee 0c             	shr    $0xc,%esi

	// LAB 5: Your code here.
	int r;
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	if(va_is_mapped(addr) && va_is_dirty(addr)){
		if ((r = ide_write(blockno * BLKSECTS,addr,BLKSECTS)) < 0 ) 
  800501:	c1 e6 03             	shl    $0x3,%esi
  800504:	89 34 24             	mov    %esi,(%esp)
  800507:	e8 aa fc ff ff       	call   8001b6 <ide_write>
  80050c:	85 c0                	test   %eax,%eax
  80050e:	79 20                	jns    800530 <flush_block+0xa4>
			panic("in flush block ,ide_write fault: %e",r);
  800510:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800514:	c7 44 24 08 d8 3d 80 	movl   $0x803dd8,0x8(%esp)
  80051b:	00 
  80051c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800523:	00 
  800524:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  80052b:	e8 d0 18 00 00       	call   801e00 <_panic>
		if((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] &
  800530:	89 d8                	mov    %ebx,%eax
  800532:	c1 e8 0c             	shr    $0xc,%eax
  800535:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80053c:	25 07 0e 00 00       	and    $0xe07,%eax
  800541:	89 44 24 10          	mov    %eax,0x10(%esp)
  800545:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800549:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800550:	00 
  800551:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800555:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80055c:	e8 88 23 00 00       	call   8028e9 <sys_page_map>
  800561:	85 c0                	test   %eax,%eax
  800563:	79 20                	jns    800585 <flush_block+0xf9>
			PTE_SYSCALL)) < 0)
			panic("In flush_block, sys_page_map fault: %e", r);	
  800565:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800569:	c7 44 24 08 fc 3d 80 	movl   $0x803dfc,0x8(%esp)
  800570:	00 
  800571:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  800578:	00 
  800579:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  800580:	e8 7b 18 00 00       	call   801e00 <_panic>
	} else {
		return;
	}
}
  800585:	83 c4 20             	add    $0x20,%esp
  800588:	5b                   	pop    %ebx
  800589:	5e                   	pop    %esi
  80058a:	5d                   	pop    %ebp
  80058b:	c3                   	ret    

0080058c <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	53                   	push   %ebx
  800590:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  800596:	c7 04 24 70 02 80 00 	movl   $0x800270,(%esp)
  80059d:	e8 5e 25 00 00       	call   802b00 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8005a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005a9:	e8 54 fe ff ff       	call   800402 <diskaddr>
  8005ae:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8005b5:	00 
  8005b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ba:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	e8 54 20 00 00       	call   80261c <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8005c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005cf:	e8 2e fe ff ff       	call   800402 <diskaddr>
  8005d4:	c7 44 24 04 84 3e 80 	movl   $0x803e84,0x4(%esp)
  8005db:	00 
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	e8 bf 1e 00 00       	call   8024a3 <strcpy>
	flush_block(diskaddr(1));
  8005e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005eb:	e8 12 fe ff ff       	call   800402 <diskaddr>
  8005f0:	89 04 24             	mov    %eax,(%esp)
  8005f3:	e8 94 fe ff ff       	call   80048c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8005f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ff:	e8 fe fd ff ff       	call   800402 <diskaddr>
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	e8 3c fe ff ff       	call   800448 <va_is_mapped>
  80060c:	84 c0                	test   %al,%al
  80060e:	75 24                	jne    800634 <bc_init+0xa8>
  800610:	c7 44 24 0c a6 3e 80 	movl   $0x803ea6,0xc(%esp)
  800617:	00 
  800618:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  80061f:	00 
  800620:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800627:	00 
  800628:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  80062f:	e8 cc 17 00 00       	call   801e00 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800634:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80063b:	e8 c2 fd ff ff       	call   800402 <diskaddr>
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	e8 2d fe ff ff       	call   800475 <va_is_dirty>
  800648:	84 c0                	test   %al,%al
  80064a:	74 24                	je     800670 <bc_init+0xe4>
  80064c:	c7 44 24 0c 8b 3e 80 	movl   $0x803e8b,0xc(%esp)
  800653:	00 
  800654:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  80065b:	00 
  80065c:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800663:	00 
  800664:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  80066b:	e8 90 17 00 00       	call   801e00 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800670:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800677:	e8 86 fd ff ff       	call   800402 <diskaddr>
  80067c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800680:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800687:	e8 b0 22 00 00       	call   80293c <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80068c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800693:	e8 6a fd ff ff       	call   800402 <diskaddr>
  800698:	89 04 24             	mov    %eax,(%esp)
  80069b:	e8 a8 fd ff ff       	call   800448 <va_is_mapped>
  8006a0:	84 c0                	test   %al,%al
  8006a2:	74 24                	je     8006c8 <bc_init+0x13c>
  8006a4:	c7 44 24 0c a5 3e 80 	movl   $0x803ea5,0xc(%esp)
  8006ab:	00 
  8006ac:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8006b3:	00 
  8006b4:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006bb:	00 
  8006bc:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  8006c3:	e8 38 17 00 00       	call   801e00 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006cf:	e8 2e fd ff ff       	call   800402 <diskaddr>
  8006d4:	c7 44 24 04 84 3e 80 	movl   $0x803e84,0x4(%esp)
  8006db:	00 
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	e8 66 1e 00 00       	call   80254a <strcmp>
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 24                	je     80070c <bc_init+0x180>
  8006e8:	c7 44 24 0c 24 3e 80 	movl   $0x803e24,0xc(%esp)
  8006ef:	00 
  8006f0:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8006f7:	00 
  8006f8:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  8006ff:	00 
  800700:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  800707:	e8 f4 16 00 00       	call   801e00 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80070c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800713:	e8 ea fc ff ff       	call   800402 <diskaddr>
  800718:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80071f:	00 
  800720:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800726:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072a:	89 04 24             	mov    %eax,(%esp)
  80072d:	e8 ea 1e 00 00       	call   80261c <memmove>
	flush_block(diskaddr(1));
  800732:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800739:	e8 c4 fc ff ff       	call   800402 <diskaddr>
  80073e:	89 04 24             	mov    %eax,(%esp)
  800741:	e8 46 fd ff ff       	call   80048c <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800746:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80074d:	e8 b0 fc ff ff       	call   800402 <diskaddr>
  800752:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800759:	00 
  80075a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075e:	89 1c 24             	mov    %ebx,(%esp)
  800761:	e8 b6 1e 00 00       	call   80261c <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800766:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80076d:	e8 90 fc ff ff       	call   800402 <diskaddr>
  800772:	c7 44 24 04 84 3e 80 	movl   $0x803e84,0x4(%esp)
  800779:	00 
  80077a:	89 04 24             	mov    %eax,(%esp)
  80077d:	e8 21 1d 00 00       	call   8024a3 <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  800782:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800789:	e8 74 fc ff ff       	call   800402 <diskaddr>
  80078e:	83 c0 14             	add    $0x14,%eax
  800791:	89 04 24             	mov    %eax,(%esp)
  800794:	e8 f3 fc ff ff       	call   80048c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800799:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8007a0:	e8 5d fc ff ff       	call   800402 <diskaddr>
  8007a5:	89 04 24             	mov    %eax,(%esp)
  8007a8:	e8 9b fc ff ff       	call   800448 <va_is_mapped>
  8007ad:	84 c0                	test   %al,%al
  8007af:	75 24                	jne    8007d5 <bc_init+0x249>
  8007b1:	c7 44 24 0c a6 3e 80 	movl   $0x803ea6,0xc(%esp)
  8007b8:	00 
  8007b9:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8007c0:	00 
  8007c1:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8007c8:	00 
  8007c9:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  8007d0:	e8 2b 16 00 00       	call   801e00 <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8007d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8007dc:	e8 21 fc ff ff       	call   800402 <diskaddr>
  8007e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007ec:	e8 4b 21 00 00       	call   80293c <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8007f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8007f8:	e8 05 fc ff ff       	call   800402 <diskaddr>
  8007fd:	89 04 24             	mov    %eax,(%esp)
  800800:	e8 43 fc ff ff       	call   800448 <va_is_mapped>
  800805:	84 c0                	test   %al,%al
  800807:	74 24                	je     80082d <bc_init+0x2a1>
  800809:	c7 44 24 0c a5 3e 80 	movl   $0x803ea5,0xc(%esp)
  800810:	00 
  800811:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  800818:	00 
  800819:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
  800820:	00 
  800821:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  800828:	e8 d3 15 00 00       	call   801e00 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80082d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800834:	e8 c9 fb ff ff       	call   800402 <diskaddr>
  800839:	c7 44 24 04 84 3e 80 	movl   $0x803e84,0x4(%esp)
  800840:	00 
  800841:	89 04 24             	mov    %eax,(%esp)
  800844:	e8 01 1d 00 00       	call   80254a <strcmp>
  800849:	85 c0                	test   %eax,%eax
  80084b:	74 24                	je     800871 <bc_init+0x2e5>
  80084d:	c7 44 24 0c 24 3e 80 	movl   $0x803e24,0xc(%esp)
  800854:	00 
  800855:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  80085c:	00 
  80085d:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  800864:	00 
  800865:	c7 04 24 48 3e 80 00 	movl   $0x803e48,(%esp)
  80086c:	e8 8f 15 00 00       	call   801e00 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800871:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800878:	e8 85 fb ff ff       	call   800402 <diskaddr>
  80087d:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800884:	00 
  800885:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  80088b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80088f:	89 04 24             	mov    %eax,(%esp)
  800892:	e8 85 1d 00 00       	call   80261c <memmove>
	flush_block(diskaddr(1));
  800897:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80089e:	e8 5f fb ff ff       	call   800402 <diskaddr>
  8008a3:	89 04 24             	mov    %eax,(%esp)
  8008a6:	e8 e1 fb ff ff       	call   80048c <flush_block>

	cprintf("block cache is good\n");
  8008ab:	c7 04 24 c0 3e 80 00 	movl   $0x803ec0,(%esp)
  8008b2:	e8 41 16 00 00       	call   801ef8 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  8008b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8008be:	e8 3f fb ff ff       	call   800402 <diskaddr>
  8008c3:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8008ca:	00 
  8008cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008d5:	89 04 24             	mov    %eax,(%esp)
  8008d8:	e8 3f 1d 00 00       	call   80261c <memmove>
}
  8008dd:	81 c4 24 02 00 00    	add    $0x224,%esp
  8008e3:	5b                   	pop    %ebx
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    
	...

008008e8 <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  8008eb:	eb 01                	jmp    8008ee <skip_slash+0x6>
		p++;
  8008ed:	40                   	inc    %eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8008ee:	80 38 2f             	cmpb   $0x2f,(%eax)
  8008f1:	74 fa                	je     8008ed <skip_slash+0x5>
		p++;
	return p;
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  8008fb:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800900:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800906:	74 1c                	je     800924 <check_super+0x2f>
		panic("bad file system magic number");
  800908:	c7 44 24 08 d5 3e 80 	movl   $0x803ed5,0x8(%esp)
  80090f:	00 
  800910:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800917:	00 
  800918:	c7 04 24 f2 3e 80 00 	movl   $0x803ef2,(%esp)
  80091f:	e8 dc 14 00 00       	call   801e00 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800924:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  80092b:	76 1c                	jbe    800949 <check_super+0x54>
		panic("file system is too large");
  80092d:	c7 44 24 08 fa 3e 80 	movl   $0x803efa,0x8(%esp)
  800934:	00 
  800935:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  80093c:	00 
  80093d:	c7 04 24 f2 3e 80 00 	movl   $0x803ef2,(%esp)
  800944:	e8 b7 14 00 00       	call   801e00 <_panic>

	cprintf("superblock is good\n");
  800949:	c7 04 24 13 3f 80 00 	movl   $0x803f13,(%esp)
  800950:	e8 a3 15 00 00       	call   801ef8 <cprintf>
}
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80095d:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800962:	85 c0                	test   %eax,%eax
  800964:	74 1d                	je     800983 <block_is_free+0x2c>
  800966:	39 48 04             	cmp    %ecx,0x4(%eax)
  800969:	76 1c                	jbe    800987 <block_is_free+0x30>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80096b:	b8 01 00 00 00       	mov    $0x1,%eax
  800970:	d3 e0                	shl    %cl,%eax
  800972:	c1 e9 05             	shr    $0x5,%ecx
// --------------------------------------------------------------

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
  800975:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80097b:	85 04 8a             	test   %eax,(%edx,%ecx,4)
  80097e:	0f 95 c0             	setne  %al
  800981:	eb 06                	jmp    800989 <block_is_free+0x32>
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800983:	b0 00                	mov    $0x0,%al
  800985:	eb 02                	jmp    800989 <block_is_free+0x32>
  800987:	b0 00                	mov    $0x0,%al
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 18             	sub    $0x18,%esp
  800991:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800994:	85 c9                	test   %ecx,%ecx
  800996:	75 1c                	jne    8009b4 <free_block+0x29>
		panic("attempt to free zero block");
  800998:	c7 44 24 08 27 3f 80 	movl   $0x803f27,0x8(%esp)
  80099f:	00 
  8009a0:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8009a7:	00 
  8009a8:	c7 04 24 f2 3e 80 00 	movl   $0x803ef2,(%esp)
  8009af:	e8 4c 14 00 00       	call   801e00 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  8009b4:	89 c8                	mov    %ecx,%eax
  8009b6:	c1 e8 05             	shr    $0x5,%eax
  8009b9:	c1 e0 02             	shl    $0x2,%eax
  8009bc:	03 05 04 a0 80 00    	add    0x80a004,%eax
  8009c2:	ba 01 00 00 00       	mov    $0x1,%edx
  8009c7:	d3 e2                	shl    %cl,%edx
  8009c9:	09 10                	or     %edx,(%eax)
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	57                   	push   %edi
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	83 ec 1c             	sub    $0x1c,%esp
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	size_t i;
	for(i = 1; i < super->s_nblocks; i++){
  8009d6:	bb 01 00 00 00       	mov    $0x1,%ebx
  8009db:	eb 3c                	jmp    800a19 <alloc_block+0x4c>
		if(block_is_free(i)){
  8009dd:	89 1c 24             	mov    %ebx,(%esp)
  8009e0:	e8 72 ff ff ff       	call   800957 <block_is_free>
  8009e5:	84 c0                	test   %al,%al
  8009e7:	74 2f                	je     800a18 <alloc_block+0x4b>
			bitmap[i / 32] &= ~(1 << (i % 32));
  8009e9:	89 d8                	mov    %ebx,%eax
  8009eb:	c1 e8 05             	shr    $0x5,%eax
  8009ee:	c1 e0 02             	shl    $0x2,%eax
  8009f1:	89 c2                	mov    %eax,%edx
  8009f3:	03 15 04 a0 80 00    	add    0x80a004,%edx
  8009f9:	89 de                	mov    %ebx,%esi
  8009fb:	bf 01 00 00 00       	mov    $0x1,%edi
  800a00:	89 d9                	mov    %ebx,%ecx
  800a02:	d3 e7                	shl    %cl,%edi
  800a04:	f7 d7                	not    %edi
  800a06:	21 3a                	and    %edi,(%edx)
			flush_block(&bitmap[i / 32]);
  800a08:	03 05 04 a0 80 00    	add    0x80a004,%eax
  800a0e:	89 04 24             	mov    %eax,(%esp)
  800a11:	e8 76 fa ff ff       	call   80048c <flush_block>
			return i;
  800a16:	eb 10                	jmp    800a28 <alloc_block+0x5b>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	size_t i;
	for(i = 1; i < super->s_nblocks; i++){
  800a18:	43                   	inc    %ebx
  800a19:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800a1e:	3b 58 04             	cmp    0x4(%eax),%ebx
  800a21:	72 ba                	jb     8009dd <alloc_block+0x10>
			bitmap[i / 32] &= ~(1 << (i % 32));
			flush_block(&bitmap[i / 32]);
			return i;
		}
	} 
	return -E_NO_DISK;
  800a23:	be f7 ff ff ff       	mov    $0xfffffff7,%esi
}
  800a28:	89 f0                	mov    %esi,%eax
  800a2a:	83 c4 1c             	add    $0x1c,%esp
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	57                   	push   %edi
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	83 ec 2c             	sub    $0x2c,%esp
  800a3b:	89 c3                	mov    %eax,%ebx
  800a3d:	89 d6                	mov    %edx,%esi
  800a3f:	89 cf                	mov    %ecx,%edi
  800a41:	8a 45 08             	mov    0x8(%ebp),%al
	// LAB 5: Your code here.
	uint32_t blockno;
	
    //Check if it is in a direct block 
	if (filebno < NDIRECT){
  800a44:	83 fa 09             	cmp    $0x9,%edx
  800a47:	77 14                	ja     800a5d <file_block_walk+0x2b>
		if(ppdiskbno){
  800a49:	85 c9                	test   %ecx,%ecx
  800a4b:	74 10                	je     800a5d <file_block_walk+0x2b>
			*ppdiskbno = &(f->f_direct[filebno]);
  800a4d:	8d 84 93 88 00 00 00 	lea    0x88(%ebx,%edx,4),%eax
  800a54:	89 01                	mov    %eax,(%ecx)
			return 0;
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	eb 7d                	jmp    800ada <file_block_walk+0xa8>
		}
	}
    
	//Check if it's out of bounds
	if (filebno >= NDIRECT + NINDIRECT)
  800a5d:	81 fe 09 04 00 00    	cmp    $0x409,%esi
  800a63:	77 69                	ja     800ace <file_block_walk+0x9c>
		return -E_INVAL;

	filebno -= NDIRECT;
    
	//Allocate an indirection block.	
	if(f->f_indirect == 0){
  800a65:	83 bb b0 00 00 00 00 	cmpl   $0x0,0xb0(%ebx)
  800a6c:	75 45                	jne    800ab3 <file_block_walk+0x81>
		if (alloc == 0)
  800a6e:	84 c0                	test   %al,%al
  800a70:	74 63                	je     800ad5 <file_block_walk+0xa3>
			return -E_NOT_FOUND;
		if ((blockno = alloc_block()) < 0)
  800a72:	e8 56 ff ff ff       	call   8009cd <alloc_block>
  800a77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			return -E_NO_DISK;
		f->f_indirect = blockno;		
  800a7a:	89 83 b0 00 00 00    	mov    %eax,0xb0(%ebx)
		memset(diskaddr(blockno), 0, BLKSIZE);
  800a80:	89 04 24             	mov    %eax,(%esp)
  800a83:	e8 7a f9 ff ff       	call   800402 <diskaddr>
  800a88:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800a8f:	00 
  800a90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a97:	00 
  800a98:	89 04 24             	mov    %eax,(%esp)
  800a9b:	e8 32 1b 00 00       	call   8025d2 <memset>
		flush_block(diskaddr(blockno));
  800aa0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	e8 57 f9 ff ff       	call   800402 <diskaddr>
  800aab:	89 04 24             	mov    %eax,(%esp)
  800aae:	e8 d9 f9 ff ff       	call   80048c <flush_block>
	}
	
	*ppdiskbno = (uint32_t *)diskaddr(f->f_indirect) + filebno;
  800ab3:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800ab9:	89 04 24             	mov    %eax,(%esp)
  800abc:	e8 41 f9 ff ff       	call   800402 <diskaddr>
  800ac1:	8d 44 b0 d8          	lea    -0x28(%eax,%esi,4),%eax
  800ac5:	89 07                	mov    %eax,(%edi)
	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  800acc:	eb 0c                	jmp    800ada <file_block_walk+0xa8>
		}
	}
    
	//Check if it's out of bounds
	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800ace:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ad3:	eb 05                	jmp    800ada <file_block_walk+0xa8>
	filebno -= NDIRECT;
    
	//Allocate an indirection block.	
	if(f->f_indirect == 0){
		if (alloc == 0)
			return -E_NOT_FOUND;
  800ad5:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
		flush_block(diskaddr(blockno));
	}
	
	*ppdiskbno = (uint32_t *)diskaddr(f->f_indirect) + filebno;
	return 0;
}
  800ada:	83 c4 2c             	add    $0x2c,%esp
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	53                   	push   %ebx
  800ae6:	83 ec 14             	sub    $0x14,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800ae9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aee:	eb 34                	jmp    800b24 <check_bitmap+0x42>
		assert(!block_is_free(2+i));
  800af0:	8d 43 02             	lea    0x2(%ebx),%eax
  800af3:	89 04 24             	mov    %eax,(%esp)
  800af6:	e8 5c fe ff ff       	call   800957 <block_is_free>
  800afb:	84 c0                	test   %al,%al
  800afd:	74 24                	je     800b23 <check_bitmap+0x41>
  800aff:	c7 44 24 0c 42 3f 80 	movl   $0x803f42,0xc(%esp)
  800b06:	00 
  800b07:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  800b0e:	00 
  800b0f:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  800b16:	00 
  800b17:	c7 04 24 f2 3e 80 00 	movl   $0x803ef2,(%esp)
  800b1e:	e8 dd 12 00 00       	call   801e00 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800b23:	43                   	inc    %ebx
  800b24:	89 da                	mov    %ebx,%edx
  800b26:	c1 e2 0f             	shl    $0xf,%edx
  800b29:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800b2e:	3b 50 04             	cmp    0x4(%eax),%edx
  800b31:	72 bd                	jb     800af0 <check_bitmap+0xe>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800b33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b3a:	e8 18 fe ff ff       	call   800957 <block_is_free>
  800b3f:	84 c0                	test   %al,%al
  800b41:	74 24                	je     800b67 <check_bitmap+0x85>
  800b43:	c7 44 24 0c 56 3f 80 	movl   $0x803f56,0xc(%esp)
  800b4a:	00 
  800b4b:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  800b52:	00 
  800b53:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800b5a:	00 
  800b5b:	c7 04 24 f2 3e 80 00 	movl   $0x803ef2,(%esp)
  800b62:	e8 99 12 00 00       	call   801e00 <_panic>
	assert(!block_is_free(1));
  800b67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b6e:	e8 e4 fd ff ff       	call   800957 <block_is_free>
  800b73:	84 c0                	test   %al,%al
  800b75:	74 24                	je     800b9b <check_bitmap+0xb9>
  800b77:	c7 44 24 0c 68 3f 80 	movl   $0x803f68,0xc(%esp)
  800b7e:	00 
  800b7f:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  800b86:	00 
  800b87:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  800b8e:	00 
  800b8f:	c7 04 24 f2 3e 80 00 	movl   $0x803ef2,(%esp)
  800b96:	e8 65 12 00 00       	call   801e00 <_panic>

	cprintf("bitmap is good\n");
  800b9b:	c7 04 24 7a 3f 80 00 	movl   $0x803f7a,(%esp)
  800ba2:	e8 51 13 00 00       	call   801ef8 <cprintf>
}
  800ba7:	83 c4 14             	add    $0x14,%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800bb3:	e8 b0 f4 ff ff       	call   800068 <ide_probe_disk1>
  800bb8:	84 c0                	test   %al,%al
  800bba:	74 0e                	je     800bca <fs_init+0x1d>
		ide_set_disk(1);
  800bbc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800bc3:	e8 03 f5 ff ff       	call   8000cb <ide_set_disk>
  800bc8:	eb 0c                	jmp    800bd6 <fs_init+0x29>
	else
		ide_set_disk(0);
  800bca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bd1:	e8 f5 f4 ff ff       	call   8000cb <ide_set_disk>
	bc_init();
  800bd6:	e8 b1 f9 ff ff       	call   80058c <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800bdb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800be2:	e8 1b f8 ff ff       	call   800402 <diskaddr>
  800be7:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800bec:	e8 04 fd ff ff       	call   8008f5 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800bf1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800bf8:	e8 05 f8 ff ff       	call   800402 <diskaddr>
  800bfd:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800c02:	e8 db fe ff ff       	call   800ae2 <check_bitmap>
	
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 24             	sub    $0x24,%esp
  800c10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 5: Your code here.
	int r;
	uint32_t *pdiskbno;
	// 调用 file_block_walk 函数来获得文件块的磁盘块号指针	
	if((r = file_block_walk(f, filebno, &pdiskbno, 1)) < 0)
  800c13:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c1a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800c1d:	89 da                	mov    %ebx,%edx
  800c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c22:	e8 0b fe ff ff       	call   800a32 <file_block_walk>
  800c27:	85 c0                	test   %eax,%eax
  800c29:	78 6b                	js     800c96 <file_get_block+0x8d>
		return r;
	if (filebno >= NDIRECT + NINDIRECT)
  800c2b:	81 fb 09 04 00 00    	cmp    $0x409,%ebx
  800c31:	77 57                	ja     800c8a <file_get_block+0x81>
		return -E_INVAL;
    // 如果磁盘块号指针指向的内容为 0，说明该块还未分配
	if (*pdiskbno == 0){
  800c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c36:	83 38 00             	cmpl   $0x0,(%eax)
  800c39:	75 2e                	jne    800c69 <file_get_block+0x60>
		if ((r = alloc_block()) < 0)
  800c3b:	e8 8d fd ff ff       	call   8009cd <alloc_block>
  800c40:	85 c0                	test   %eax,%eax
  800c42:	78 4d                	js     800c91 <file_get_block+0x88>
			return -E_NO_DISK;
		*pdiskbno = r;
  800c44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c47:	89 02                	mov    %eax,(%edx)
		memset(diskaddr(r), 0, BLKSIZE);
  800c49:	89 04 24             	mov    %eax,(%esp)
  800c4c:	e8 b1 f7 ff ff       	call   800402 <diskaddr>
  800c51:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800c58:	00 
  800c59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c60:	00 
  800c61:	89 04 24             	mov    %eax,(%esp)
  800c64:	e8 69 19 00 00       	call   8025d2 <memset>
	}
	// 最终将指向该块的指针存入 blk 指向的位置
	*blk = diskaddr(*pdiskbno);
  800c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c6c:	8b 00                	mov    (%eax),%eax
  800c6e:	89 04 24             	mov    %eax,(%esp)
  800c71:	e8 8c f7 ff ff       	call   800402 <diskaddr>
  800c76:	8b 55 10             	mov    0x10(%ebp),%edx
  800c79:	89 02                	mov    %eax,(%edx)
	flush_block(*blk);
  800c7b:	89 04 24             	mov    %eax,(%esp)
  800c7e:	e8 09 f8 ff ff       	call   80048c <flush_block>
	return 0;
  800c83:	b8 00 00 00 00       	mov    $0x0,%eax
  800c88:	eb 0c                	jmp    800c96 <file_get_block+0x8d>
	uint32_t *pdiskbno;
	// 调用 file_block_walk 函数来获得文件块的磁盘块号指针	
	if((r = file_block_walk(f, filebno, &pdiskbno, 1)) < 0)
		return r;
	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800c8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c8f:	eb 05                	jmp    800c96 <file_get_block+0x8d>
    // 如果磁盘块号指针指向的内容为 0，说明该块还未分配
	if (*pdiskbno == 0){
		if ((r = alloc_block()) < 0)
			return -E_NO_DISK;
  800c91:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
	}
	// 最终将指向该块的指针存入 blk 指向的位置
	*blk = diskaddr(*pdiskbno);
	flush_block(*blk);
	return 0;
}
  800c96:	83 c4 24             	add    $0x24,%esp
  800c99:	5b                   	pop    %ebx
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  800ca8:	89 95 44 ff ff ff    	mov    %edx,-0xbc(%ebp)
  800cae:	89 8d 40 ff ff ff    	mov    %ecx,-0xc0(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  800cb4:	e8 2f fc ff ff       	call   8008e8 <skip_slash>
  800cb9:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	f = &super->s_root;
  800cbf:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800cc4:	83 c0 08             	add    $0x8,%eax
  800cc7:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
	dir = 0;
	name[0] = 0;
  800ccd:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800cd4:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800cdb:	74 0c                	je     800ce9 <walk_path+0x4d>
		*pdir = 0;
  800cdd:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800ce3:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	*pf = 0;
  800ce9:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800cef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800cfa:	e9 95 01 00 00       	jmp    800e94 <walk_path+0x1f8>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800cff:	46                   	inc    %esi
  800d00:	eb 06                	jmp    800d08 <walk_path+0x6c>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800d02:	8b b5 4c ff ff ff    	mov    -0xb4(%ebp),%esi
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800d08:	8a 06                	mov    (%esi),%al
  800d0a:	3c 2f                	cmp    $0x2f,%al
  800d0c:	74 04                	je     800d12 <walk_path+0x76>
  800d0e:	84 c0                	test   %al,%al
  800d10:	75 ed                	jne    800cff <walk_path+0x63>
			path++;
		if (path - p >= MAXNAMELEN)
  800d12:	89 f3                	mov    %esi,%ebx
  800d14:	2b 9d 4c ff ff ff    	sub    -0xb4(%ebp),%ebx
  800d1a:	83 fb 7f             	cmp    $0x7f,%ebx
  800d1d:	0f 8f a6 01 00 00    	jg     800ec9 <walk_path+0x22d>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800d23:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d27:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d31:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800d37:	89 14 24             	mov    %edx,(%esp)
  800d3a:	e8 dd 18 00 00       	call   80261c <memmove>
		name[path - p] = '\0';
  800d3f:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800d46:	00 
		path = skip_slash(path);
  800d47:	89 f0                	mov    %esi,%eax
  800d49:	e8 9a fb ff ff       	call   8008e8 <skip_slash>
  800d4e:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)

		if (dir->f_type != FTYPE_DIR)
  800d54:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800d5a:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800d61:	0f 85 69 01 00 00    	jne    800ed0 <walk_path+0x234>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800d67:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800d6d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800d72:	74 24                	je     800d98 <walk_path+0xfc>
  800d74:	c7 44 24 0c 8a 3f 80 	movl   $0x803f8a,0xc(%esp)
  800d7b:	00 
  800d7c:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  800d83:	00 
  800d84:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  800d8b:	00 
  800d8c:	c7 04 24 f2 3e 80 00 	movl   $0x803ef2,(%esp)
  800d93:	e8 68 10 00 00       	call   801e00 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800d98:	89 c2                	mov    %eax,%edx
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	79 06                	jns    800da4 <walk_path+0x108>
  800d9e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800da4:	c1 fa 0c             	sar    $0xc,%edx
  800da7:	89 95 48 ff ff ff    	mov    %edx,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800dad:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  800db4:	00 00 00 
  800db7:	eb 62                	jmp    800e1b <walk_path+0x17f>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800db9:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800dbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc3:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  800dc9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dcd:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800dd3:	89 04 24             	mov    %eax,(%esp)
  800dd6:	e8 2e fe ff ff       	call   800c09 <file_get_block>
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	78 4c                	js     800e2b <walk_path+0x18f>
			return r;
		f = (struct File*) blk;
  800ddf:	8b bd 64 ff ff ff    	mov    -0x9c(%ebp),%edi
  800de5:	bb 00 00 00 00       	mov    $0x0,%ebx
// and set *pdir to the directory the file is in.
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
  800dea:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
  800ded:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800df3:	89 54 24 04          	mov    %edx,0x4(%esp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800df7:	89 34 24             	mov    %esi,(%esp)
  800dfa:	e8 4b 17 00 00       	call   80254a <strcmp>
  800dff:	85 c0                	test   %eax,%eax
  800e01:	0f 84 81 00 00 00    	je     800e88 <walk_path+0x1ec>
  800e07:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800e0d:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  800e13:	75 d5                	jne    800dea <walk_path+0x14e>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800e15:	ff 85 54 ff ff ff    	incl   -0xac(%ebp)
  800e1b:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800e21:	39 85 48 ff ff ff    	cmp    %eax,-0xb8(%ebp)
  800e27:	75 90                	jne    800db9 <walk_path+0x11d>
  800e29:	eb 09                	jmp    800e34 <walk_path+0x198>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800e2b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800e2e:	0f 85 a8 00 00 00    	jne    800edc <walk_path+0x240>
  800e34:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800e3a:	80 38 00             	cmpb   $0x0,(%eax)
  800e3d:	0f 85 94 00 00 00    	jne    800ed7 <walk_path+0x23b>
				if (pdir)
  800e43:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800e4a:	74 0e                	je     800e5a <walk_path+0x1be>
					*pdir = dir;
  800e4c:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800e52:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800e58:	89 02                	mov    %eax,(%edx)
				if (lastelem)
  800e5a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e5e:	74 15                	je     800e75 <walk_path+0x1d9>
					strcpy(lastelem, name);
  800e60:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800e66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	89 14 24             	mov    %edx,(%esp)
  800e70:	e8 2e 16 00 00       	call   8024a3 <strcpy>
				*pf = 0;
  800e75:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800e7b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800e81:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800e86:	eb 54                	jmp    800edc <walk_path+0x240>
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800e88:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800e8e:	89 b5 50 ff ff ff    	mov    %esi,-0xb0(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800e94:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800e9a:	80 3a 00             	cmpb   $0x0,(%edx)
  800e9d:	0f 85 5f fe ff ff    	jne    800d02 <walk_path+0x66>
			}
			return r;
		}
	}

	if (pdir)
  800ea3:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800eaa:	74 08                	je     800eb4 <walk_path+0x218>
		*pdir = dir;
  800eac:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800eb2:	89 02                	mov    %eax,(%edx)
	*pf = f;
  800eb4:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800eba:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800ec0:	89 10                	mov    %edx,(%eax)
	return 0;
  800ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec7:	eb 13                	jmp    800edc <walk_path+0x240>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800ec9:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800ece:	eb 0c                	jmp    800edc <walk_path+0x240>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800ed0:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800ed5:	eb 05                	jmp    800edc <walk_path+0x240>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800ed7:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800edc:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  800eed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	ba 00 00 00 00       	mov    $0x0,%edx
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	e8 98 fd ff ff       	call   800c9c <walk_path>
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 3c             	sub    $0x3c,%esp
  800f0f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f12:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f15:	8b 45 14             	mov    0x14(%ebp),%eax
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800f18:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f1b:	8b 93 80 00 00 00    	mov    0x80(%ebx),%edx
  800f21:	39 c2                	cmp    %eax,%edx
  800f23:	0f 8e 8a 00 00 00    	jle    800fb3 <file_read+0xad>
		return 0;

	count = MIN(count, f->f_size - offset);
  800f29:	29 c2                	sub    %eax,%edx
  800f2b:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800f2e:	39 ca                	cmp    %ecx,%edx
  800f30:	76 03                	jbe    800f35 <file_read+0x2f>
  800f32:	89 4d d0             	mov    %ecx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800f35:	89 c3                	mov    %eax,%ebx
  800f37:	03 45 d0             	add    -0x30(%ebp),%eax
  800f3a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f3d:	eb 68                	jmp    800fa7 <file_read+0xa1>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f3f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f42:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f46:	89 d8                	mov    %ebx,%eax
  800f48:	85 db                	test   %ebx,%ebx
  800f4a:	79 06                	jns    800f52 <file_read+0x4c>
  800f4c:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800f52:	c1 f8 0c             	sar    $0xc,%eax
  800f55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5c:	89 04 24             	mov    %eax,(%esp)
  800f5f:	e8 a5 fc ff ff       	call   800c09 <file_get_block>
  800f64:	85 c0                	test   %eax,%eax
  800f66:	78 50                	js     800fb8 <file_read+0xb2>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f68:	89 d8                	mov    %ebx,%eax
  800f6a:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  800f6f:	79 07                	jns    800f78 <file_read+0x72>
  800f71:	48                   	dec    %eax
  800f72:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  800f77:	40                   	inc    %eax
  800f78:	89 c2                	mov    %eax,%edx
  800f7a:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800f7f:	29 c1                	sub    %eax,%ecx
  800f81:	89 c8                	mov    %ecx,%eax
  800f83:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800f86:	29 f1                	sub    %esi,%ecx
  800f88:	89 c6                	mov    %eax,%esi
  800f8a:	39 c8                	cmp    %ecx,%eax
  800f8c:	76 02                	jbe    800f90 <file_read+0x8a>
  800f8e:	89 ce                	mov    %ecx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800f90:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f94:	03 55 e4             	add    -0x1c(%ebp),%edx
  800f97:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f9b:	89 3c 24             	mov    %edi,(%esp)
  800f9e:	e8 79 16 00 00       	call   80261c <memmove>
		pos += bn;
  800fa3:	01 f3                	add    %esi,%ebx
		buf += bn;
  800fa5:	01 f7                	add    %esi,%edi
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800fa7:	89 de                	mov    %ebx,%esi
  800fa9:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  800fac:	72 91                	jb     800f3f <file_read+0x39>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800fae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800fb1:	eb 05                	jmp    800fb8 <file_read+0xb2>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800fb3:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  800fb8:	83 c4 3c             	add    $0x3c,%esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
  800fc6:	83 ec 3c             	sub    $0x3c,%esp
  800fc9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800fcc:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800fd2:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800fd5:	0f 8e 9c 00 00 00    	jle    801077 <file_set_size+0xb7>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800fdb:	05 ff 0f 00 00       	add    $0xfff,%eax
  800fe0:	89 c7                	mov    %eax,%edi
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	79 06                	jns    800fec <file_set_size+0x2c>
  800fe6:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
  800fec:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800fef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff2:	05 ff 0f 00 00       	add    $0xfff,%eax
  800ff7:	89 c2                	mov    %eax,%edx
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	79 06                	jns    801003 <file_set_size+0x43>
  800ffd:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801003:	c1 fa 0c             	sar    $0xc,%edx
  801006:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  801009:	89 d3                	mov    %edx,%ebx
  80100b:	eb 44                	jmp    801051 <file_set_size+0x91>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  80100d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801014:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  801017:	89 da                	mov    %ebx,%edx
  801019:	89 f0                	mov    %esi,%eax
  80101b:	e8 12 fa ff ff       	call   800a32 <file_block_walk>
  801020:	85 c0                	test   %eax,%eax
  801022:	78 1c                	js     801040 <file_set_size+0x80>
		return r;
	if (*ptr) {
  801024:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801027:	8b 00                	mov    (%eax),%eax
  801029:	85 c0                	test   %eax,%eax
  80102b:	74 23                	je     801050 <file_set_size+0x90>
		free_block(*ptr);
  80102d:	89 04 24             	mov    %eax,(%esp)
  801030:	e8 56 f9 ff ff       	call   80098b <free_block>
		*ptr = 0;
  801035:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801038:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  80103e:	eb 10                	jmp    801050 <file_set_size+0x90>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  801040:	89 44 24 04          	mov    %eax,0x4(%esp)
  801044:	c7 04 24 a7 3f 80 00 	movl   $0x803fa7,(%esp)
  80104b:	e8 a8 0e 00 00       	call   801ef8 <cprintf>
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  801050:	43                   	inc    %ebx
  801051:	39 df                	cmp    %ebx,%edi
  801053:	77 b8                	ja     80100d <file_set_size+0x4d>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  801055:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  801059:	77 1c                	ja     801077 <file_set_size+0xb7>
  80105b:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  801061:	85 c0                	test   %eax,%eax
  801063:	74 12                	je     801077 <file_set_size+0xb7>
		free_block(f->f_indirect);
  801065:	89 04 24             	mov    %eax,(%esp)
  801068:	e8 1e f9 ff ff       	call   80098b <free_block>
		f->f_indirect = 0;
  80106d:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  801074:	00 00 00 
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  801077:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107a:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  801080:	89 34 24             	mov    %esi,(%esp)
  801083:	e8 04 f4 ff ff       	call   80048c <flush_block>
	return 0;
}
  801088:	b8 00 00 00 00       	mov    $0x0,%eax
  80108d:	83 c4 3c             	add    $0x3c,%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
  80109b:	83 ec 3c             	sub    $0x3c,%esp
  80109e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  8010a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8010a7:	01 d8                	add    %ebx,%eax
  8010a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8010ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8010af:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  8010b5:	76 7a                	jbe    801131 <file_write+0x9c>
		if ((r = file_set_size(f, offset + count)) < 0)
  8010b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bb:	89 14 24             	mov    %edx,(%esp)
  8010be:	e8 fd fe ff ff       	call   800fc0 <file_set_size>
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	79 6a                	jns    801131 <file_write+0x9c>
  8010c7:	eb 72                	jmp    80113b <file_write+0xa6>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  8010c9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8010cc:	89 54 24 08          	mov    %edx,0x8(%esp)
  8010d0:	89 d8                	mov    %ebx,%eax
  8010d2:	85 db                	test   %ebx,%ebx
  8010d4:	79 06                	jns    8010dc <file_write+0x47>
  8010d6:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  8010dc:	c1 f8 0c             	sar    $0xc,%eax
  8010df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e6:	89 0c 24             	mov    %ecx,(%esp)
  8010e9:	e8 1b fb ff ff       	call   800c09 <file_get_block>
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	78 49                	js     80113b <file_write+0xa6>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  8010f2:	89 d8                	mov    %ebx,%eax
  8010f4:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  8010f9:	79 07                	jns    801102 <file_write+0x6d>
  8010fb:	48                   	dec    %eax
  8010fc:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  801101:	40                   	inc    %eax
  801102:	89 c2                	mov    %eax,%edx
  801104:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801109:	29 c1                	sub    %eax,%ecx
  80110b:	89 c8                	mov    %ecx,%eax
  80110d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801110:	29 f1                	sub    %esi,%ecx
  801112:	89 c6                	mov    %eax,%esi
  801114:	39 c8                	cmp    %ecx,%eax
  801116:	76 02                	jbe    80111a <file_write+0x85>
  801118:	89 ce                	mov    %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  80111a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80111e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801122:	03 55 e4             	add    -0x1c(%ebp),%edx
  801125:	89 14 24             	mov    %edx,(%esp)
  801128:	e8 ef 14 00 00       	call   80261c <memmove>
		pos += bn;
  80112d:	01 f3                	add    %esi,%ebx
		buf += bn;
  80112f:	01 f7                	add    %esi,%edi
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  801131:	89 de                	mov    %ebx,%esi
  801133:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  801136:	77 91                	ja     8010c9 <file_write+0x34>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  801138:	8b 45 10             	mov    0x10(%ebp),%eax
}
  80113b:	83 c4 3c             	add    $0x3c,%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 20             	sub    $0x20,%esp
  80114b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  80114e:	be 00 00 00 00       	mov    $0x0,%esi
  801153:	eb 35                	jmp    80118a <file_flush+0x47>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801155:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80115c:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  80115f:	89 f2                	mov    %esi,%edx
  801161:	89 d8                	mov    %ebx,%eax
  801163:	e8 ca f8 ff ff       	call   800a32 <file_block_walk>
  801168:	85 c0                	test   %eax,%eax
  80116a:	78 1d                	js     801189 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  80116c:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80116f:	85 c0                	test   %eax,%eax
  801171:	74 16                	je     801189 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  801173:	8b 00                	mov    (%eax),%eax
  801175:	85 c0                	test   %eax,%eax
  801177:	74 10                	je     801189 <file_flush+0x46>
			continue;
		flush_block(diskaddr(*pdiskbno));
  801179:	89 04 24             	mov    %eax,(%esp)
  80117c:	e8 81 f2 ff ff       	call   800402 <diskaddr>
  801181:	89 04 24             	mov    %eax,(%esp)
  801184:	e8 03 f3 ff ff       	call   80048c <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801189:	46                   	inc    %esi
  80118a:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  801190:	05 ff 0f 00 00       	add    $0xfff,%eax
  801195:	89 c2                	mov    %eax,%edx
  801197:	85 c0                	test   %eax,%eax
  801199:	79 06                	jns    8011a1 <file_flush+0x5e>
  80119b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8011a1:	c1 fa 0c             	sar    $0xc,%edx
  8011a4:	39 d6                	cmp    %edx,%esi
  8011a6:	7c ad                	jl     801155 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  8011a8:	89 1c 24             	mov    %ebx,(%esp)
  8011ab:	e8 dc f2 ff ff       	call   80048c <flush_block>
	if (f->f_indirect)
  8011b0:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	74 10                	je     8011ca <file_flush+0x87>
		flush_block(diskaddr(f->f_indirect));
  8011ba:	89 04 24             	mov    %eax,(%esp)
  8011bd:	e8 40 f2 ff ff       	call   800402 <diskaddr>
  8011c2:	89 04 24             	mov    %eax,(%esp)
  8011c5:	e8 c2 f2 ff ff       	call   80048c <flush_block>
}
  8011ca:	83 c4 20             	add    $0x20,%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	57                   	push   %edi
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
  8011d7:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  8011dd:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8011e3:	89 04 24             	mov    %eax,(%esp)
  8011e6:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  8011ec:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  8011f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f5:	e8 a2 fa ff ff       	call   800c9c <walk_path>
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	0f 84 dc 00 00 00    	je     8012de <file_create+0x10d>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  801202:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801205:	0f 85 d8 00 00 00    	jne    8012e3 <file_create+0x112>
  80120b:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  801211:	85 db                	test   %ebx,%ebx
  801213:	0f 84 ca 00 00 00    	je     8012e3 <file_create+0x112>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  801219:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  80121f:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801224:	74 24                	je     80124a <file_create+0x79>
  801226:	c7 44 24 0c 8a 3f 80 	movl   $0x803f8a,0xc(%esp)
  80122d:	00 
  80122e:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  801235:	00 
  801236:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  80123d:	00 
  80123e:	c7 04 24 f2 3e 80 00 	movl   $0x803ef2,(%esp)
  801245:	e8 b6 0b 00 00       	call   801e00 <_panic>
	nblock = dir->f_size / BLKSIZE;
  80124a:	89 c2                	mov    %eax,%edx
  80124c:	85 c0                	test   %eax,%eax
  80124e:	79 06                	jns    801256 <file_create+0x85>
  801250:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801256:	c1 fa 0c             	sar    $0xc,%edx
  801259:	89 95 54 ff ff ff    	mov    %edx,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  80125f:	be 00 00 00 00       	mov    $0x0,%esi
		if ((r = file_get_block(dir, i, &blk)) < 0)
  801264:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  80126a:	eb 38                	jmp    8012a4 <file_create+0xd3>
  80126c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801270:	89 74 24 04          	mov    %esi,0x4(%esp)
  801274:	89 1c 24             	mov    %ebx,(%esp)
  801277:	e8 8d f9 ff ff       	call   800c09 <file_get_block>
  80127c:	85 c0                	test   %eax,%eax
  80127e:	78 63                	js     8012e3 <file_create+0x112>
  801280:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  801286:	ba 00 00 00 00       	mov    $0x0,%edx
			if (f[j].f_name[0] == '\0') {
  80128b:	80 38 00             	cmpb   $0x0,(%eax)
  80128e:	75 08                	jne    801298 <file_create+0xc7>
				*file = &f[j];
  801290:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801296:	eb 56                	jmp    8012ee <file_create+0x11d>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  801298:	42                   	inc    %edx
  801299:	05 00 01 00 00       	add    $0x100,%eax
  80129e:	83 fa 10             	cmp    $0x10,%edx
  8012a1:	75 e8                	jne    80128b <file_create+0xba>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8012a3:	46                   	inc    %esi
  8012a4:	39 b5 54 ff ff ff    	cmp    %esi,-0xac(%ebp)
  8012aa:	75 c0                	jne    80126c <file_create+0x9b>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8012ac:	81 83 80 00 00 00 00 	addl   $0x1000,0x80(%ebx)
  8012b3:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8012b6:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8012bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012c4:	89 1c 24             	mov    %ebx,(%esp)
  8012c7:	e8 3d f9 ff ff       	call   800c09 <file_get_block>
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 13                	js     8012e3 <file_create+0x112>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  8012d0:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8012d6:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8012dc:	eb 10                	jmp    8012ee <file_create+0x11d>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  8012de:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  8012e3:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  8012e9:	5b                   	pop    %ebx
  8012ea:	5e                   	pop    %esi
  8012eb:	5f                   	pop    %edi
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  8012ee:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8012f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f8:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8012fe:	89 04 24             	mov    %eax,(%esp)
  801301:	e8 9d 11 00 00       	call   8024a3 <strcpy>
	*pf = f;
  801306:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  80130c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130f:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801311:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  801317:	89 04 24             	mov    %eax,(%esp)
  80131a:	e8 24 fe ff ff       	call   801143 <file_flush>
	return 0;
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
  801324:	eb bd                	jmp    8012e3 <file_create+0x112>

00801326 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	53                   	push   %ebx
  80132a:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80132d:	bb 01 00 00 00       	mov    $0x1,%ebx
  801332:	eb 11                	jmp    801345 <fs_sync+0x1f>
		flush_block(diskaddr(i));
  801334:	89 1c 24             	mov    %ebx,(%esp)
  801337:	e8 c6 f0 ff ff       	call   800402 <diskaddr>
  80133c:	89 04 24             	mov    %eax,(%esp)
  80133f:	e8 48 f1 ff ff       	call   80048c <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801344:	43                   	inc    %ebx
  801345:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80134a:	3b 58 04             	cmp    0x4(%eax),%ebx
  80134d:	72 e5                	jb     801334 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80134f:	83 c4 14             	add    $0x14,%esp
  801352:	5b                   	pop    %ebx
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    
  801355:	00 00                	add    %al,(%eax)
	...

00801358 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80135e:	e8 c3 ff ff ff       	call   801326 <fs_sync>
	return 0;
}
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
  801368:	c9                   	leave  
  801369:	c3                   	ret    

0080136a <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  80136d:	ba 60 50 80 00       	mov    $0x805060,%edx

void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
  801372:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801377:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  80137c:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80137e:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  801381:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801387:	40                   	inc    %eax
  801388:	83 c2 10             	add    $0x10,%edx
  80138b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801390:	75 ea                	jne    80137c <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	56                   	push   %esi
  801398:	53                   	push   %ebx
  801399:	83 ec 10             	sub    $0x10,%esp
  80139c:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80139f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
  8013a4:	89 d8                	mov    %ebx,%eax
  8013a6:	c1 e0 04             	shl    $0x4,%eax
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  8013a9:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  8013af:	89 04 24             	mov    %eax,(%esp)
  8013b2:	e8 35 21 00 00       	call   8034ec <pageref>
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	74 07                	je     8013c2 <openfile_alloc+0x2e>
  8013bb:	83 f8 01             	cmp    $0x1,%eax
  8013be:	75 62                	jne    801422 <openfile_alloc+0x8e>
  8013c0:	eb 27                	jmp    8013e9 <openfile_alloc+0x55>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8013c2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013c9:	00 
  8013ca:	89 d8                	mov    %ebx,%eax
  8013cc:	c1 e0 04             	shl    $0x4,%eax
  8013cf:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  8013d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e0:	e8 b0 14 00 00       	call   802895 <sys_page_alloc>
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 4b                	js     801434 <openfile_alloc+0xa0>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8013e9:	c1 e3 04             	shl    $0x4,%ebx
  8013ec:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8013f2:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8013f9:	04 00 00 
			*o = &opentab[i];
  8013fc:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8013fe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801405:	00 
  801406:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80140d:	00 
  80140e:	8b 83 6c 50 80 00    	mov    0x80506c(%ebx),%eax
  801414:	89 04 24             	mov    %eax,(%esp)
  801417:	e8 b6 11 00 00       	call   8025d2 <memset>
			return (*o)->o_fileid;
  80141c:	8b 06                	mov    (%esi),%eax
  80141e:	8b 00                	mov    (%eax),%eax
  801420:	eb 12                	jmp    801434 <openfile_alloc+0xa0>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801422:	43                   	inc    %ebx
  801423:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801429:	0f 85 75 ff ff ff    	jne    8013a4 <openfile_alloc+0x10>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  80142f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	57                   	push   %edi
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	83 ec 1c             	sub    $0x1c,%esp
  801444:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801447:	89 fe                	mov    %edi,%esi
  801449:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80144f:	c1 e6 04             	shl    $0x4,%esi
  801452:	8d 9e 60 50 80 00    	lea    0x805060(%esi),%ebx
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801458:	8b 86 6c 50 80 00    	mov    0x80506c(%esi),%eax
  80145e:	89 04 24             	mov    %eax,(%esp)
  801461:	e8 86 20 00 00       	call   8034ec <pageref>
  801466:	83 f8 01             	cmp    $0x1,%eax
  801469:	7e 14                	jle    80147f <openfile_lookup+0x44>
  80146b:	39 be 60 50 80 00    	cmp    %edi,0x805060(%esi)
  801471:	75 13                	jne    801486 <openfile_lookup+0x4b>
		return -E_INVAL;
	*po = o;
  801473:	8b 45 10             	mov    0x10(%ebp),%eax
  801476:	89 18                	mov    %ebx,(%eax)
	return 0;
  801478:	b8 00 00 00 00       	mov    $0x0,%eax
  80147d:	eb 0c                	jmp    80148b <openfile_lookup+0x50>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  80147f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801484:	eb 05                	jmp    80148b <openfile_lookup+0x50>
  801486:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80148b:	83 c4 1c             	add    $0x1c,%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5e                   	pop    %esi
  801490:	5f                   	pop    %edi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801499:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a3:	8b 00                	mov    (%eax),%eax
  8014a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	e8 87 ff ff ff       	call   80143b <openfile_lookup>
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 13                	js     8014cb <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  8014b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bb:	8b 40 04             	mov    0x4(%eax),%eax
  8014be:	89 04 24             	mov    %eax,(%esp)
  8014c1:	e8 7d fc ff ff       	call   801143 <file_flush>
	return 0;
  8014c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    

008014cd <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	53                   	push   %ebx
  8014d1:	83 ec 24             	sub    $0x24,%esp
  8014d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014de:	8b 03                	mov    (%ebx),%eax
  8014e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e7:	89 04 24             	mov    %eax,(%esp)
  8014ea:	e8 4c ff ff ff       	call   80143b <openfile_lookup>
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 3f                	js     801532 <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8014f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f6:	8b 40 04             	mov    0x4(%eax),%eax
  8014f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fd:	89 1c 24             	mov    %ebx,(%esp)
  801500:	e8 9e 0f 00 00       	call   8024a3 <strcpy>
	ret->ret_size = o->o_file->f_size;
  801505:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801508:	8b 50 04             	mov    0x4(%eax),%edx
  80150b:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801511:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  801517:	8b 40 04             	mov    0x4(%eax),%eax
  80151a:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801521:	0f 94 c0             	sete   %al
  801524:	0f b6 c0             	movzbl %al,%eax
  801527:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80152d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801532:	83 c4 24             	add    $0x24,%esp
  801535:	5b                   	pop    %ebx
  801536:	5d                   	pop    %ebp
  801537:	c3                   	ret    

00801538 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	53                   	push   %ebx
  80153c:	83 ec 24             	sub    $0x24,%esp
  80153f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	int r;
	struct OpenFile *o;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801542:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801545:	89 44 24 08          	mov    %eax,0x8(%esp)
  801549:	8b 03                	mov    (%ebx),%eax
  80154b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154f:	8b 45 08             	mov    0x8(%ebp),%eax
  801552:	89 04 24             	mov    %eax,(%esp)
  801555:	e8 e1 fe ff ff       	call   80143b <openfile_lookup>
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 3f                	js     80159d <serve_write+0x65>
		return r;

	//确保不会写入超过一页大小的数据，避免越界访问。
	int reqn = req->req_n > PGSIZE? PGSIZE:req->req_n;
	if ((r = file_write(o->o_file, req->req_buf, reqn, o->o_fd->fd_offset)) < 0)
  80155e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801561:	8b 42 0c             	mov    0xc(%edx),%eax
  801564:	8b 40 04             	mov    0x4(%eax),%eax
  801567:	89 44 24 0c          	mov    %eax,0xc(%esp)
	struct OpenFile *o;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	//确保不会写入超过一页大小的数据，避免越界访问。
	int reqn = req->req_n > PGSIZE? PGSIZE:req->req_n;
  80156b:	8b 43 04             	mov    0x4(%ebx),%eax
  80156e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801573:	76 05                	jbe    80157a <serve_write+0x42>
  801575:	b8 00 10 00 00       	mov    $0x1000,%eax
	if ((r = file_write(o->o_file, req->req_buf, reqn, o->o_fd->fd_offset)) < 0)
  80157a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80157e:	83 c3 08             	add    $0x8,%ebx
  801581:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801585:	8b 42 04             	mov    0x4(%edx),%eax
  801588:	89 04 24             	mov    %eax,(%esp)
  80158b:	e8 05 fb ff ff       	call   801095 <file_write>
  801590:	85 c0                	test   %eax,%eax
  801592:	78 09                	js     80159d <serve_write+0x65>
		return r;
	
	o->o_fd->fd_offset += r;
  801594:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801597:	8b 52 0c             	mov    0xc(%edx),%edx
  80159a:	01 42 04             	add    %eax,0x4(%edx)
	return r;
}
  80159d:	83 c4 24             	add    $0x24,%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5d                   	pop    %ebp
  8015a2:	c3                   	ret    

008015a3 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 24             	sub    $0x24,%esp
  8015aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8015ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b4:	8b 03                	mov    (%ebx),%eax
  8015b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bd:	89 04 24             	mov    %eax,(%esp)
  8015c0:	e8 76 fe ff ff       	call   80143b <openfile_lookup>
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 30                	js     8015f9 <serve_read+0x56>
		return r;
	if ((r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  8015c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cc:	8b 50 0c             	mov    0xc(%eax),%edx
  8015cf:	8b 52 04             	mov    0x4(%edx),%edx
  8015d2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015d6:	8b 53 04             	mov    0x4(%ebx),%edx
  8015d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e1:	8b 40 04             	mov    0x4(%eax),%eax
  8015e4:	89 04 24             	mov    %eax,(%esp)
  8015e7:	e8 1a f9 ff ff       	call   800f06 <file_read>
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 09                	js     8015f9 <serve_read+0x56>
		return r;
	
	o->o_fd->fd_offset += r;
  8015f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f6:	01 42 04             	add    %eax,0x4(%edx)
	return r;
}
  8015f9:	83 c4 24             	add    $0x24,%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    

008015ff <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	53                   	push   %ebx
  801603:	83 ec 24             	sub    $0x24,%esp
  801606:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801609:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801610:	8b 03                	mov    (%ebx),%eax
  801612:	89 44 24 04          	mov    %eax,0x4(%esp)
  801616:	8b 45 08             	mov    0x8(%ebp),%eax
  801619:	89 04 24             	mov    %eax,(%esp)
  80161c:	e8 1a fe ff ff       	call   80143b <openfile_lookup>
  801621:	85 c0                	test   %eax,%eax
  801623:	78 15                	js     80163a <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801625:	8b 43 04             	mov    0x4(%ebx),%eax
  801628:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162f:	8b 40 04             	mov    0x4(%eax),%eax
  801632:	89 04 24             	mov    %eax,(%esp)
  801635:	e8 86 f9 ff ff       	call   800fc0 <file_set_size>
}
  80163a:	83 c4 24             	add    $0x24,%esp
  80163d:	5b                   	pop    %ebx
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	53                   	push   %ebx
  801644:	81 ec 24 04 00 00    	sub    $0x424,%esp
  80164a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  80164d:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801654:	00 
  801655:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801659:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80165f:	89 04 24             	mov    %eax,(%esp)
  801662:	e8 b5 0f 00 00       	call   80261c <memmove>
	path[MAXPATHLEN-1] = 0;
  801667:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80166b:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801671:	89 04 24             	mov    %eax,(%esp)
  801674:	e8 1b fd ff ff       	call   801394 <openfile_alloc>
  801679:	85 c0                	test   %eax,%eax
  80167b:	0f 88 f0 00 00 00    	js     801771 <serve_open+0x131>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801681:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801688:	74 32                	je     8016bc <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  80168a:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801690:	89 44 24 04          	mov    %eax,0x4(%esp)
  801694:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80169a:	89 04 24             	mov    %eax,(%esp)
  80169d:	e8 2f fb ff ff       	call   8011d1 <file_create>
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	79 36                	jns    8016dc <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8016a6:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8016ad:	0f 85 be 00 00 00    	jne    801771 <serve_open+0x131>
  8016b3:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8016b6:	0f 85 b5 00 00 00    	jne    801771 <serve_open+0x131>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8016bc:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8016c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c6:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8016cc:	89 04 24             	mov    %eax,(%esp)
  8016cf:	e8 13 f8 ff ff       	call   800ee7 <file_open>
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	0f 88 95 00 00 00    	js     801771 <serve_open+0x131>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8016dc:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8016e3:	74 1a                	je     8016ff <serve_open+0xbf>
		if ((r = file_set_size(f, 0)) < 0) {
  8016e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016ec:	00 
  8016ed:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  8016f3:	89 04 24             	mov    %eax,(%esp)
  8016f6:	e8 c5 f8 ff ff       	call   800fc0 <file_set_size>
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 72                	js     801771 <serve_open+0x131>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8016ff:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801705:	89 44 24 04          	mov    %eax,0x4(%esp)
  801709:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80170f:	89 04 24             	mov    %eax,(%esp)
  801712:	e8 d0 f7 ff ff       	call   800ee7 <file_open>
  801717:	85 c0                	test   %eax,%eax
  801719:	78 56                	js     801771 <serve_open+0x131>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  80171b:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801721:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801727:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  80172a:	8b 50 0c             	mov    0xc(%eax),%edx
  80172d:	8b 08                	mov    (%eax),%ecx
  80172f:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801732:	8b 50 0c             	mov    0xc(%eax),%edx
  801735:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  80173b:	83 e1 03             	and    $0x3,%ecx
  80173e:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801741:	8b 40 0c             	mov    0xc(%eax),%eax
  801744:	8b 15 64 90 80 00    	mov    0x809064,%edx
  80174a:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80174c:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801752:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801758:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80175b:	8b 50 0c             	mov    0xc(%eax),%edx
  80175e:	8b 45 10             	mov    0x10(%ebp),%eax
  801761:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801763:	8b 45 14             	mov    0x14(%ebp),%eax
  801766:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80176c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801771:	81 c4 24 04 00 00    	add    $0x424,%esp
  801777:	5b                   	pop    %ebx
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	56                   	push   %esi
  80177e:	53                   	push   %ebx
  80177f:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801782:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801785:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801788:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80178f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801793:	a1 44 50 80 00       	mov    0x805044,%eax
  801798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179c:	89 34 24             	mov    %esi,(%esp)
  80179f:	e8 d0 13 00 00       	call   802b74 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  8017a4:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  8017a8:	75 15                	jne    8017bf <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  8017aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b1:	c7 04 24 c4 3f 80 00 	movl   $0x803fc4,(%esp)
  8017b8:	e8 3b 07 00 00       	call   801ef8 <cprintf>
				whom);
			continue; // just leave it hanging...
  8017bd:	eb c9                	jmp    801788 <serve+0xe>
		}

		pg = NULL;
  8017bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8017c6:	83 f8 01             	cmp    $0x1,%eax
  8017c9:	75 21                	jne    8017ec <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8017cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d6:	a1 44 50 80 00       	mov    0x805044,%eax
  8017db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e2:	89 04 24             	mov    %eax,(%esp)
  8017e5:	e8 56 fe ff ff       	call   801640 <serve_open>
  8017ea:	eb 3f                	jmp    80182b <serve+0xb1>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8017ec:	83 f8 08             	cmp    $0x8,%eax
  8017ef:	77 1e                	ja     80180f <serve+0x95>
  8017f1:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8017f8:	85 d2                	test   %edx,%edx
  8017fa:	74 13                	je     80180f <serve+0x95>
			r = handlers[req](whom, fsreq);
  8017fc:	a1 44 50 80 00       	mov    0x805044,%eax
  801801:	89 44 24 04          	mov    %eax,0x4(%esp)
  801805:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801808:	89 04 24             	mov    %eax,(%esp)
  80180b:	ff d2                	call   *%edx
  80180d:	eb 1c                	jmp    80182b <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  80180f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801812:	89 54 24 08          	mov    %edx,0x8(%esp)
  801816:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181a:	c7 04 24 f4 3f 80 00 	movl   $0x803ff4,(%esp)
  801821:	e8 d2 06 00 00       	call   801ef8 <cprintf>
			r = -E_INVAL;
  801826:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  80182b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80182e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801832:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801835:	89 54 24 08          	mov    %edx,0x8(%esp)
  801839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801840:	89 04 24             	mov    %eax,(%esp)
  801843:	e8 95 13 00 00       	call   802bdd <ipc_send>
		sys_page_unmap(0, fsreq);
  801848:	a1 44 50 80 00       	mov    0x805044,%eax
  80184d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801851:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801858:	e8 df 10 00 00       	call   80293c <sys_page_unmap>
  80185d:	e9 26 ff ff ff       	jmp    801788 <serve+0xe>

00801862 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801868:	c7 05 60 90 80 00 17 	movl   $0x804017,0x809060
  80186f:	40 80 00 
	cprintf("FS is running\n");
  801872:	c7 04 24 1a 40 80 00 	movl   $0x80401a,(%esp)
  801879:	e8 7a 06 00 00       	call   801ef8 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80187e:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801883:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801888:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80188a:	c7 04 24 29 40 80 00 	movl   $0x804029,(%esp)
  801891:	e8 62 06 00 00       	call   801ef8 <cprintf>

	serve_init();
  801896:	e8 cf fa ff ff       	call   80136a <serve_init>
	fs_init();
  80189b:	e8 0d f3 ff ff       	call   800bad <fs_init>
        fs_test();
  8018a0:	e8 07 00 00 00       	call   8018ac <fs_test>
	serve();
  8018a5:	e8 d0 fe ff ff       	call   80177a <serve>
	...

008018ac <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8018b3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018ba:	00 
  8018bb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  8018c2:	00 
  8018c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ca:	e8 c6 0f 00 00       	call   802895 <sys_page_alloc>
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	79 20                	jns    8018f3 <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  8018d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018d7:	c7 44 24 08 38 40 80 	movl   $0x804038,0x8(%esp)
  8018de:	00 
  8018df:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8018e6:	00 
  8018e7:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  8018ee:	e8 0d 05 00 00       	call   801e00 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8018f3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8018fa:	00 
  8018fb:	a1 04 a0 80 00       	mov    0x80a004,%eax
  801900:	89 44 24 04          	mov    %eax,0x4(%esp)
  801904:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  80190b:	e8 0c 0d 00 00       	call   80261c <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801910:	e8 b8 f0 ff ff       	call   8009cd <alloc_block>
  801915:	85 c0                	test   %eax,%eax
  801917:	79 20                	jns    801939 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  801919:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80191d:	c7 44 24 08 55 40 80 	movl   $0x804055,0x8(%esp)
  801924:	00 
  801925:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  80192c:	00 
  80192d:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801934:	e8 c7 04 00 00       	call   801e00 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801939:	89 c2                	mov    %eax,%edx
  80193b:	85 c0                	test   %eax,%eax
  80193d:	79 03                	jns    801942 <fs_test+0x96>
  80193f:	8d 50 1f             	lea    0x1f(%eax),%edx
  801942:	c1 fa 05             	sar    $0x5,%edx
  801945:	c1 e2 02             	shl    $0x2,%edx
  801948:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80194d:	79 05                	jns    801954 <fs_test+0xa8>
  80194f:	48                   	dec    %eax
  801950:	83 c8 e0             	or     $0xffffffe0,%eax
  801953:	40                   	inc    %eax
  801954:	bb 01 00 00 00       	mov    $0x1,%ebx
  801959:	88 c1                	mov    %al,%cl
  80195b:	d3 e3                	shl    %cl,%ebx
  80195d:	85 9a 00 10 00 00    	test   %ebx,0x1000(%edx)
  801963:	75 24                	jne    801989 <fs_test+0xdd>
  801965:	c7 44 24 0c 65 40 80 	movl   $0x804065,0xc(%esp)
  80196c:	00 
  80196d:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  801974:	00 
  801975:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80197c:	00 
  80197d:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801984:	e8 77 04 00 00       	call   801e00 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801989:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  80198f:	85 1c 11             	test   %ebx,(%ecx,%edx,1)
  801992:	74 24                	je     8019b8 <fs_test+0x10c>
  801994:	c7 44 24 0c e0 41 80 	movl   $0x8041e0,0xc(%esp)
  80199b:	00 
  80199c:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8019a3:	00 
  8019a4:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8019ab:	00 
  8019ac:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  8019b3:	e8 48 04 00 00       	call   801e00 <_panic>
	cprintf("alloc_block is good\n");
  8019b8:	c7 04 24 80 40 80 00 	movl   $0x804080,(%esp)
  8019bf:	e8 34 05 00 00       	call   801ef8 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  8019c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cb:	c7 04 24 95 40 80 00 	movl   $0x804095,(%esp)
  8019d2:	e8 10 f5 ff ff       	call   800ee7 <file_open>
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	79 25                	jns    801a00 <fs_test+0x154>
  8019db:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8019de:	74 40                	je     801a20 <fs_test+0x174>
		panic("file_open /not-found: %e", r);
  8019e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019e4:	c7 44 24 08 a0 40 80 	movl   $0x8040a0,0x8(%esp)
  8019eb:	00 
  8019ec:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8019f3:	00 
  8019f4:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  8019fb:	e8 00 04 00 00       	call   801e00 <_panic>
	else if (r == 0)
  801a00:	85 c0                	test   %eax,%eax
  801a02:	75 1c                	jne    801a20 <fs_test+0x174>
		panic("file_open /not-found succeeded!");
  801a04:	c7 44 24 08 00 42 80 	movl   $0x804200,0x8(%esp)
  801a0b:	00 
  801a0c:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801a13:	00 
  801a14:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801a1b:	e8 e0 03 00 00       	call   801e00 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801a20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a27:	c7 04 24 b9 40 80 00 	movl   $0x8040b9,(%esp)
  801a2e:	e8 b4 f4 ff ff       	call   800ee7 <file_open>
  801a33:	85 c0                	test   %eax,%eax
  801a35:	79 20                	jns    801a57 <fs_test+0x1ab>
		panic("file_open /newmotd: %e", r);
  801a37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a3b:	c7 44 24 08 c2 40 80 	movl   $0x8040c2,0x8(%esp)
  801a42:	00 
  801a43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801a4a:	00 
  801a4b:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801a52:	e8 a9 03 00 00       	call   801e00 <_panic>
	cprintf("file_open is good\n");
  801a57:	c7 04 24 d9 40 80 00 	movl   $0x8040d9,(%esp)
  801a5e:	e8 95 04 00 00       	call   801ef8 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801a63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a66:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a71:	00 
  801a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a75:	89 04 24             	mov    %eax,(%esp)
  801a78:	e8 8c f1 ff ff       	call   800c09 <file_get_block>
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	79 20                	jns    801aa1 <fs_test+0x1f5>
		panic("file_get_block: %e", r);
  801a81:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a85:	c7 44 24 08 ec 40 80 	movl   $0x8040ec,0x8(%esp)
  801a8c:	00 
  801a8d:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801a94:	00 
  801a95:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801a9c:	e8 5f 03 00 00       	call   801e00 <_panic>
	if (strcmp(blk, msg) != 0)
  801aa1:	c7 44 24 04 20 42 80 	movl   $0x804220,0x4(%esp)
  801aa8:	00 
  801aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aac:	89 04 24             	mov    %eax,(%esp)
  801aaf:	e8 96 0a 00 00       	call   80254a <strcmp>
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	74 1c                	je     801ad4 <fs_test+0x228>
		panic("file_get_block returned wrong data");
  801ab8:	c7 44 24 08 48 42 80 	movl   $0x804248,0x8(%esp)
  801abf:	00 
  801ac0:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801ac7:	00 
  801ac8:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801acf:	e8 2c 03 00 00       	call   801e00 <_panic>
	cprintf("file_get_block is good\n");
  801ad4:	c7 04 24 ff 40 80 00 	movl   $0x8040ff,(%esp)
  801adb:	e8 18 04 00 00       	call   801ef8 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae3:	8a 10                	mov    (%eax),%dl
  801ae5:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aea:	c1 e8 0c             	shr    $0xc,%eax
  801aed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801af4:	a8 40                	test   $0x40,%al
  801af6:	75 24                	jne    801b1c <fs_test+0x270>
  801af8:	c7 44 24 0c 18 41 80 	movl   $0x804118,0xc(%esp)
  801aff:	00 
  801b00:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  801b07:	00 
  801b08:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801b0f:	00 
  801b10:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801b17:	e8 e4 02 00 00       	call   801e00 <_panic>
	file_flush(f);
  801b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1f:	89 04 24             	mov    %eax,(%esp)
  801b22:	e8 1c f6 ff ff       	call   801143 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b2a:	c1 e8 0c             	shr    $0xc,%eax
  801b2d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b34:	a8 40                	test   $0x40,%al
  801b36:	74 24                	je     801b5c <fs_test+0x2b0>
  801b38:	c7 44 24 0c 17 41 80 	movl   $0x804117,0xc(%esp)
  801b3f:	00 
  801b40:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  801b47:	00 
  801b48:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801b4f:	00 
  801b50:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801b57:	e8 a4 02 00 00       	call   801e00 <_panic>
	cprintf("file_flush is good\n");
  801b5c:	c7 04 24 33 41 80 00 	movl   $0x804133,(%esp)
  801b63:	e8 90 03 00 00       	call   801ef8 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801b68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b6f:	00 
  801b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b73:	89 04 24             	mov    %eax,(%esp)
  801b76:	e8 45 f4 ff ff       	call   800fc0 <file_set_size>
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	79 20                	jns    801b9f <fs_test+0x2f3>
		panic("file_set_size: %e", r);
  801b7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b83:	c7 44 24 08 47 41 80 	movl   $0x804147,0x8(%esp)
  801b8a:	00 
  801b8b:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801b92:	00 
  801b93:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801b9a:	e8 61 02 00 00       	call   801e00 <_panic>
	assert(f->f_direct[0] == 0);
  801b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba2:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801ba9:	74 24                	je     801bcf <fs_test+0x323>
  801bab:	c7 44 24 0c 59 41 80 	movl   $0x804159,0xc(%esp)
  801bb2:	00 
  801bb3:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  801bba:	00 
  801bbb:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801bc2:	00 
  801bc3:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801bca:	e8 31 02 00 00       	call   801e00 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801bcf:	c1 e8 0c             	shr    $0xc,%eax
  801bd2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bd9:	a8 40                	test   $0x40,%al
  801bdb:	74 24                	je     801c01 <fs_test+0x355>
  801bdd:	c7 44 24 0c 6d 41 80 	movl   $0x80416d,0xc(%esp)
  801be4:	00 
  801be5:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  801bec:	00 
  801bed:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801bf4:	00 
  801bf5:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801bfc:	e8 ff 01 00 00       	call   801e00 <_panic>
	cprintf("file_truncate is good\n");
  801c01:	c7 04 24 87 41 80 00 	movl   $0x804187,(%esp)
  801c08:	e8 eb 02 00 00       	call   801ef8 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801c0d:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  801c14:	e8 57 08 00 00       	call   802470 <strlen>
  801c19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c20:	89 04 24             	mov    %eax,(%esp)
  801c23:	e8 98 f3 ff ff       	call   800fc0 <file_set_size>
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	79 20                	jns    801c4c <fs_test+0x3a0>
		panic("file_set_size 2: %e", r);
  801c2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c30:	c7 44 24 08 9e 41 80 	movl   $0x80419e,0x8(%esp)
  801c37:	00 
  801c38:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801c3f:	00 
  801c40:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801c47:	e8 b4 01 00 00       	call   801e00 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4f:	89 c2                	mov    %eax,%edx
  801c51:	c1 ea 0c             	shr    $0xc,%edx
  801c54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c5b:	f6 c2 40             	test   $0x40,%dl
  801c5e:	74 24                	je     801c84 <fs_test+0x3d8>
  801c60:	c7 44 24 0c 6d 41 80 	movl   $0x80416d,0xc(%esp)
  801c67:	00 
  801c68:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  801c6f:	00 
  801c70:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801c77:	00 
  801c78:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801c7f:	e8 7c 01 00 00       	call   801e00 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801c84:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801c87:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c92:	00 
  801c93:	89 04 24             	mov    %eax,(%esp)
  801c96:	e8 6e ef ff ff       	call   800c09 <file_get_block>
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	79 20                	jns    801cbf <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  801c9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ca3:	c7 44 24 08 b2 41 80 	movl   $0x8041b2,0x8(%esp)
  801caa:	00 
  801cab:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801cb2:	00 
  801cb3:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801cba:	e8 41 01 00 00       	call   801e00 <_panic>
	strcpy(blk, msg);
  801cbf:	c7 44 24 04 20 42 80 	movl   $0x804220,0x4(%esp)
  801cc6:	00 
  801cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cca:	89 04 24             	mov    %eax,(%esp)
  801ccd:	e8 d1 07 00 00       	call   8024a3 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd5:	c1 e8 0c             	shr    $0xc,%eax
  801cd8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801cdf:	a8 40                	test   $0x40,%al
  801ce1:	75 24                	jne    801d07 <fs_test+0x45b>
  801ce3:	c7 44 24 0c 18 41 80 	movl   $0x804118,0xc(%esp)
  801cea:	00 
  801ceb:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  801cf2:	00 
  801cf3:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801cfa:	00 
  801cfb:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801d02:	e8 f9 00 00 00       	call   801e00 <_panic>
	file_flush(f);
  801d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0a:	89 04 24             	mov    %eax,(%esp)
  801d0d:	e8 31 f4 ff ff       	call   801143 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d15:	c1 e8 0c             	shr    $0xc,%eax
  801d18:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d1f:	a8 40                	test   $0x40,%al
  801d21:	74 24                	je     801d47 <fs_test+0x49b>
  801d23:	c7 44 24 0c 17 41 80 	movl   $0x804117,0xc(%esp)
  801d2a:	00 
  801d2b:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  801d32:	00 
  801d33:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801d3a:	00 
  801d3b:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801d42:	e8 b9 00 00 00       	call   801e00 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4a:	c1 e8 0c             	shr    $0xc,%eax
  801d4d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d54:	a8 40                	test   $0x40,%al
  801d56:	74 24                	je     801d7c <fs_test+0x4d0>
  801d58:	c7 44 24 0c 6d 41 80 	movl   $0x80416d,0xc(%esp)
  801d5f:	00 
  801d60:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  801d67:	00 
  801d68:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801d6f:	00 
  801d70:	c7 04 24 4b 40 80 00 	movl   $0x80404b,(%esp)
  801d77:	e8 84 00 00 00       	call   801e00 <_panic>
	cprintf("file rewrite is good\n");
  801d7c:	c7 04 24 c7 41 80 00 	movl   $0x8041c7,(%esp)
  801d83:	e8 70 01 00 00       	call   801ef8 <cprintf>
}
  801d88:	83 c4 24             	add    $0x24,%esp
  801d8b:	5b                   	pop    %ebx
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    
	...

00801d90 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	56                   	push   %esi
  801d94:	53                   	push   %ebx
  801d95:	83 ec 10             	sub    $0x10,%esp
  801d98:	8b 75 08             	mov    0x8(%ebp),%esi
  801d9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  801d9e:	e8 b4 0a 00 00       	call   802857 <sys_getenvid>
  801da3:	25 ff 03 00 00       	and    $0x3ff,%eax
  801da8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801daf:	c1 e0 07             	shl    $0x7,%eax
  801db2:	29 d0                	sub    %edx,%eax
  801db4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801db9:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801dbe:	85 f6                	test   %esi,%esi
  801dc0:	7e 07                	jle    801dc9 <libmain+0x39>
		binaryname = argv[0];
  801dc2:	8b 03                	mov    (%ebx),%eax
  801dc4:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801dc9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dcd:	89 34 24             	mov    %esi,(%esp)
  801dd0:	e8 8d fa ff ff       	call   801862 <umain>

	// exit gracefully
	exit();
  801dd5:	e8 0a 00 00 00       	call   801de4 <exit>
}
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	5b                   	pop    %ebx
  801dde:	5e                   	pop    %esi
  801ddf:	5d                   	pop    %ebp
  801de0:	c3                   	ret    
  801de1:	00 00                	add    %al,(%eax)
	...

00801de4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  801dea:	e8 84 10 00 00       	call   802e73 <close_all>
	sys_env_destroy(0);
  801def:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df6:	e8 0a 0a 00 00       	call   802805 <sys_env_destroy>
}
  801dfb:	c9                   	leave  
  801dfc:	c3                   	ret    
  801dfd:	00 00                	add    %al,(%eax)
	...

00801e00 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	56                   	push   %esi
  801e04:	53                   	push   %ebx
  801e05:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801e08:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e0b:	8b 1d 60 90 80 00    	mov    0x809060,%ebx
  801e11:	e8 41 0a 00 00       	call   802857 <sys_getenvid>
  801e16:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e19:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  801e20:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e24:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2c:	c7 04 24 78 42 80 00 	movl   $0x804278,(%esp)
  801e33:	e8 c0 00 00 00       	call   801ef8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e38:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e3c:	8b 45 10             	mov    0x10(%ebp),%eax
  801e3f:	89 04 24             	mov    %eax,(%esp)
  801e42:	e8 50 00 00 00       	call   801e97 <vcprintf>
	cprintf("\n");
  801e47:	c7 04 24 89 3e 80 00 	movl   $0x803e89,(%esp)
  801e4e:	e8 a5 00 00 00       	call   801ef8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e53:	cc                   	int3   
  801e54:	eb fd                	jmp    801e53 <_panic+0x53>
	...

00801e58 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	53                   	push   %ebx
  801e5c:	83 ec 14             	sub    $0x14,%esp
  801e5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801e62:	8b 03                	mov    (%ebx),%eax
  801e64:	8b 55 08             	mov    0x8(%ebp),%edx
  801e67:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801e6b:	40                   	inc    %eax
  801e6c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801e6e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801e73:	75 19                	jne    801e8e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801e75:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801e7c:	00 
  801e7d:	8d 43 08             	lea    0x8(%ebx),%eax
  801e80:	89 04 24             	mov    %eax,(%esp)
  801e83:	e8 40 09 00 00       	call   8027c8 <sys_cputs>
		b->idx = 0;
  801e88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801e8e:	ff 43 04             	incl   0x4(%ebx)
}
  801e91:	83 c4 14             	add    $0x14,%esp
  801e94:	5b                   	pop    %ebx
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    

00801e97 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801ea0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801ea7:	00 00 00 
	b.cnt = 0;
  801eaa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801eb1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecc:	c7 04 24 58 1e 80 00 	movl   $0x801e58,(%esp)
  801ed3:	e8 82 01 00 00       	call   80205a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801ed8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801ede:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801ee8:	89 04 24             	mov    %eax,(%esp)
  801eeb:	e8 d8 08 00 00       	call   8027c8 <sys_cputs>

	return b.cnt;
}
  801ef0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801efe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801f01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f05:	8b 45 08             	mov    0x8(%ebp),%eax
  801f08:	89 04 24             	mov    %eax,(%esp)
  801f0b:	e8 87 ff ff ff       	call   801e97 <vcprintf>
	va_end(ap);

	return cnt;
}
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    
	...

00801f14 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	57                   	push   %edi
  801f18:	56                   	push   %esi
  801f19:	53                   	push   %ebx
  801f1a:	83 ec 3c             	sub    $0x3c,%esp
  801f1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f20:	89 d7                	mov    %edx,%edi
  801f22:	8b 45 08             	mov    0x8(%ebp),%eax
  801f25:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801f28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f2e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801f31:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801f34:	85 c0                	test   %eax,%eax
  801f36:	75 08                	jne    801f40 <printnum+0x2c>
  801f38:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801f3b:	39 45 10             	cmp    %eax,0x10(%ebp)
  801f3e:	77 57                	ja     801f97 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801f40:	89 74 24 10          	mov    %esi,0x10(%esp)
  801f44:	4b                   	dec    %ebx
  801f45:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f49:	8b 45 10             	mov    0x10(%ebp),%eax
  801f4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f50:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801f54:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801f58:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f5f:	00 
  801f60:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801f63:	89 04 24             	mov    %eax,(%esp)
  801f66:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6d:	e8 d6 1a 00 00       	call   803a48 <__udivdi3>
  801f72:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f76:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f7a:	89 04 24             	mov    %eax,(%esp)
  801f7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f81:	89 fa                	mov    %edi,%edx
  801f83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f86:	e8 89 ff ff ff       	call   801f14 <printnum>
  801f8b:	eb 0f                	jmp    801f9c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801f8d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f91:	89 34 24             	mov    %esi,(%esp)
  801f94:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801f97:	4b                   	dec    %ebx
  801f98:	85 db                	test   %ebx,%ebx
  801f9a:	7f f1                	jg     801f8d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801f9c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fa0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801fa4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801fb2:	00 
  801fb3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801fb6:	89 04 24             	mov    %eax,(%esp)
  801fb9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc0:	e8 a3 1b 00 00       	call   803b68 <__umoddi3>
  801fc5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801fc9:	0f be 80 9b 42 80 00 	movsbl 0x80429b(%eax),%eax
  801fd0:	89 04 24             	mov    %eax,(%esp)
  801fd3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801fd6:	83 c4 3c             	add    $0x3c,%esp
  801fd9:	5b                   	pop    %ebx
  801fda:	5e                   	pop    %esi
  801fdb:	5f                   	pop    %edi
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801fe1:	83 fa 01             	cmp    $0x1,%edx
  801fe4:	7e 0e                	jle    801ff4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801fe6:	8b 10                	mov    (%eax),%edx
  801fe8:	8d 4a 08             	lea    0x8(%edx),%ecx
  801feb:	89 08                	mov    %ecx,(%eax)
  801fed:	8b 02                	mov    (%edx),%eax
  801fef:	8b 52 04             	mov    0x4(%edx),%edx
  801ff2:	eb 22                	jmp    802016 <getuint+0x38>
	else if (lflag)
  801ff4:	85 d2                	test   %edx,%edx
  801ff6:	74 10                	je     802008 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801ff8:	8b 10                	mov    (%eax),%edx
  801ffa:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ffd:	89 08                	mov    %ecx,(%eax)
  801fff:	8b 02                	mov    (%edx),%eax
  802001:	ba 00 00 00 00       	mov    $0x0,%edx
  802006:	eb 0e                	jmp    802016 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  802008:	8b 10                	mov    (%eax),%edx
  80200a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80200d:	89 08                	mov    %ecx,(%eax)
  80200f:	8b 02                	mov    (%edx),%eax
  802011:	ba 00 00 00 00       	mov    $0x0,%edx
}
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    

00802018 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80201e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  802021:	8b 10                	mov    (%eax),%edx
  802023:	3b 50 04             	cmp    0x4(%eax),%edx
  802026:	73 08                	jae    802030 <sprintputch+0x18>
		*b->buf++ = ch;
  802028:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80202b:	88 0a                	mov    %cl,(%edx)
  80202d:	42                   	inc    %edx
  80202e:	89 10                	mov    %edx,(%eax)
}
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  802038:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80203b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203f:	8b 45 10             	mov    0x10(%ebp),%eax
  802042:	89 44 24 08          	mov    %eax,0x8(%esp)
  802046:	8b 45 0c             	mov    0xc(%ebp),%eax
  802049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204d:	8b 45 08             	mov    0x8(%ebp),%eax
  802050:	89 04 24             	mov    %eax,(%esp)
  802053:	e8 02 00 00 00       	call   80205a <vprintfmt>
	va_end(ap);
}
  802058:	c9                   	leave  
  802059:	c3                   	ret    

0080205a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	57                   	push   %edi
  80205e:	56                   	push   %esi
  80205f:	53                   	push   %ebx
  802060:	83 ec 4c             	sub    $0x4c,%esp
  802063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802066:	8b 75 10             	mov    0x10(%ebp),%esi
  802069:	eb 12                	jmp    80207d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80206b:	85 c0                	test   %eax,%eax
  80206d:	0f 84 6b 03 00 00    	je     8023de <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  802073:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802077:	89 04 24             	mov    %eax,(%esp)
  80207a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80207d:	0f b6 06             	movzbl (%esi),%eax
  802080:	46                   	inc    %esi
  802081:	83 f8 25             	cmp    $0x25,%eax
  802084:	75 e5                	jne    80206b <vprintfmt+0x11>
  802086:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80208a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  802091:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  802096:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80209d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020a2:	eb 26                	jmp    8020ca <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020a4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8020a7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8020ab:	eb 1d                	jmp    8020ca <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8020b0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8020b4:	eb 14                	jmp    8020ca <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8020b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8020c0:	eb 08                	jmp    8020ca <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8020c2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8020c5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020ca:	0f b6 06             	movzbl (%esi),%eax
  8020cd:	8d 56 01             	lea    0x1(%esi),%edx
  8020d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8020d3:	8a 16                	mov    (%esi),%dl
  8020d5:	83 ea 23             	sub    $0x23,%edx
  8020d8:	80 fa 55             	cmp    $0x55,%dl
  8020db:	0f 87 e1 02 00 00    	ja     8023c2 <vprintfmt+0x368>
  8020e1:	0f b6 d2             	movzbl %dl,%edx
  8020e4:	ff 24 95 e0 43 80 00 	jmp    *0x8043e0(,%edx,4)
  8020eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8020ee:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8020f3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8020f6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8020fa:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8020fd:	8d 50 d0             	lea    -0x30(%eax),%edx
  802100:	83 fa 09             	cmp    $0x9,%edx
  802103:	77 2a                	ja     80212f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  802105:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  802106:	eb eb                	jmp    8020f3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  802108:	8b 45 14             	mov    0x14(%ebp),%eax
  80210b:	8d 50 04             	lea    0x4(%eax),%edx
  80210e:	89 55 14             	mov    %edx,0x14(%ebp)
  802111:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802113:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  802116:	eb 17                	jmp    80212f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  802118:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80211c:	78 98                	js     8020b6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80211e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802121:	eb a7                	jmp    8020ca <vprintfmt+0x70>
  802123:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  802126:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80212d:	eb 9b                	jmp    8020ca <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80212f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  802133:	79 95                	jns    8020ca <vprintfmt+0x70>
  802135:	eb 8b                	jmp    8020c2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  802137:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802138:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80213b:	eb 8d                	jmp    8020ca <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80213d:	8b 45 14             	mov    0x14(%ebp),%eax
  802140:	8d 50 04             	lea    0x4(%eax),%edx
  802143:	89 55 14             	mov    %edx,0x14(%ebp)
  802146:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80214a:	8b 00                	mov    (%eax),%eax
  80214c:	89 04 24             	mov    %eax,(%esp)
  80214f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802152:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  802155:	e9 23 ff ff ff       	jmp    80207d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80215a:	8b 45 14             	mov    0x14(%ebp),%eax
  80215d:	8d 50 04             	lea    0x4(%eax),%edx
  802160:	89 55 14             	mov    %edx,0x14(%ebp)
  802163:	8b 00                	mov    (%eax),%eax
  802165:	85 c0                	test   %eax,%eax
  802167:	79 02                	jns    80216b <vprintfmt+0x111>
  802169:	f7 d8                	neg    %eax
  80216b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80216d:	83 f8 0f             	cmp    $0xf,%eax
  802170:	7f 0b                	jg     80217d <vprintfmt+0x123>
  802172:	8b 04 85 40 45 80 00 	mov    0x804540(,%eax,4),%eax
  802179:	85 c0                	test   %eax,%eax
  80217b:	75 23                	jne    8021a0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80217d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802181:	c7 44 24 08 b3 42 80 	movl   $0x8042b3,0x8(%esp)
  802188:	00 
  802189:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80218d:	8b 45 08             	mov    0x8(%ebp),%eax
  802190:	89 04 24             	mov    %eax,(%esp)
  802193:	e8 9a fe ff ff       	call   802032 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802198:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80219b:	e9 dd fe ff ff       	jmp    80207d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8021a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021a4:	c7 44 24 08 ef 3c 80 	movl   $0x803cef,0x8(%esp)
  8021ab:	00 
  8021ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8021b3:	89 14 24             	mov    %edx,(%esp)
  8021b6:	e8 77 fe ff ff       	call   802032 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8021bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8021be:	e9 ba fe ff ff       	jmp    80207d <vprintfmt+0x23>
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8021cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8021ce:	8d 50 04             	lea    0x4(%eax),%edx
  8021d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8021d4:	8b 30                	mov    (%eax),%esi
  8021d6:	85 f6                	test   %esi,%esi
  8021d8:	75 05                	jne    8021df <vprintfmt+0x185>
				p = "(null)";
  8021da:	be ac 42 80 00       	mov    $0x8042ac,%esi
			if (width > 0 && padc != '-')
  8021df:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8021e3:	0f 8e 84 00 00 00    	jle    80226d <vprintfmt+0x213>
  8021e9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8021ed:	74 7e                	je     80226d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8021ef:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021f3:	89 34 24             	mov    %esi,(%esp)
  8021f6:	e8 8b 02 00 00       	call   802486 <strnlen>
  8021fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8021fe:	29 c2                	sub    %eax,%edx
  802200:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  802203:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  802207:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80220a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80220d:	89 de                	mov    %ebx,%esi
  80220f:	89 d3                	mov    %edx,%ebx
  802211:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802213:	eb 0b                	jmp    802220 <vprintfmt+0x1c6>
					putch(padc, putdat);
  802215:	89 74 24 04          	mov    %esi,0x4(%esp)
  802219:	89 3c 24             	mov    %edi,(%esp)
  80221c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80221f:	4b                   	dec    %ebx
  802220:	85 db                	test   %ebx,%ebx
  802222:	7f f1                	jg     802215 <vprintfmt+0x1bb>
  802224:	8b 7d cc             	mov    -0x34(%ebp),%edi
  802227:	89 f3                	mov    %esi,%ebx
  802229:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80222c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80222f:	85 c0                	test   %eax,%eax
  802231:	79 05                	jns    802238 <vprintfmt+0x1de>
  802233:	b8 00 00 00 00       	mov    $0x0,%eax
  802238:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80223b:	29 c2                	sub    %eax,%edx
  80223d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802240:	eb 2b                	jmp    80226d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  802242:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  802246:	74 18                	je     802260 <vprintfmt+0x206>
  802248:	8d 50 e0             	lea    -0x20(%eax),%edx
  80224b:	83 fa 5e             	cmp    $0x5e,%edx
  80224e:	76 10                	jbe    802260 <vprintfmt+0x206>
					putch('?', putdat);
  802250:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802254:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80225b:	ff 55 08             	call   *0x8(%ebp)
  80225e:	eb 0a                	jmp    80226a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  802260:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802264:	89 04 24             	mov    %eax,(%esp)
  802267:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80226a:	ff 4d e4             	decl   -0x1c(%ebp)
  80226d:	0f be 06             	movsbl (%esi),%eax
  802270:	46                   	inc    %esi
  802271:	85 c0                	test   %eax,%eax
  802273:	74 21                	je     802296 <vprintfmt+0x23c>
  802275:	85 ff                	test   %edi,%edi
  802277:	78 c9                	js     802242 <vprintfmt+0x1e8>
  802279:	4f                   	dec    %edi
  80227a:	79 c6                	jns    802242 <vprintfmt+0x1e8>
  80227c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80227f:	89 de                	mov    %ebx,%esi
  802281:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802284:	eb 18                	jmp    80229e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  802286:	89 74 24 04          	mov    %esi,0x4(%esp)
  80228a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  802291:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  802293:	4b                   	dec    %ebx
  802294:	eb 08                	jmp    80229e <vprintfmt+0x244>
  802296:	8b 7d 08             	mov    0x8(%ebp),%edi
  802299:	89 de                	mov    %ebx,%esi
  80229b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80229e:	85 db                	test   %ebx,%ebx
  8022a0:	7f e4                	jg     802286 <vprintfmt+0x22c>
  8022a2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8022a5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8022a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8022aa:	e9 ce fd ff ff       	jmp    80207d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8022af:	83 f9 01             	cmp    $0x1,%ecx
  8022b2:	7e 10                	jle    8022c4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8022b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8022b7:	8d 50 08             	lea    0x8(%eax),%edx
  8022ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8022bd:	8b 30                	mov    (%eax),%esi
  8022bf:	8b 78 04             	mov    0x4(%eax),%edi
  8022c2:	eb 26                	jmp    8022ea <vprintfmt+0x290>
	else if (lflag)
  8022c4:	85 c9                	test   %ecx,%ecx
  8022c6:	74 12                	je     8022da <vprintfmt+0x280>
		return va_arg(*ap, long);
  8022c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8022cb:	8d 50 04             	lea    0x4(%eax),%edx
  8022ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8022d1:	8b 30                	mov    (%eax),%esi
  8022d3:	89 f7                	mov    %esi,%edi
  8022d5:	c1 ff 1f             	sar    $0x1f,%edi
  8022d8:	eb 10                	jmp    8022ea <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8022da:	8b 45 14             	mov    0x14(%ebp),%eax
  8022dd:	8d 50 04             	lea    0x4(%eax),%edx
  8022e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8022e3:	8b 30                	mov    (%eax),%esi
  8022e5:	89 f7                	mov    %esi,%edi
  8022e7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8022ea:	85 ff                	test   %edi,%edi
  8022ec:	78 0a                	js     8022f8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8022ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8022f3:	e9 8c 00 00 00       	jmp    802384 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8022f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022fc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  802303:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  802306:	f7 de                	neg    %esi
  802308:	83 d7 00             	adc    $0x0,%edi
  80230b:	f7 df                	neg    %edi
			}
			base = 10;
  80230d:	b8 0a 00 00 00       	mov    $0xa,%eax
  802312:	eb 70                	jmp    802384 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  802314:	89 ca                	mov    %ecx,%edx
  802316:	8d 45 14             	lea    0x14(%ebp),%eax
  802319:	e8 c0 fc ff ff       	call   801fde <getuint>
  80231e:	89 c6                	mov    %eax,%esi
  802320:	89 d7                	mov    %edx,%edi
			base = 10;
  802322:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  802327:	eb 5b                	jmp    802384 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  802329:	89 ca                	mov    %ecx,%edx
  80232b:	8d 45 14             	lea    0x14(%ebp),%eax
  80232e:	e8 ab fc ff ff       	call   801fde <getuint>
  802333:	89 c6                	mov    %eax,%esi
  802335:	89 d7                	mov    %edx,%edi
			base = 8;
  802337:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80233c:	eb 46                	jmp    802384 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80233e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802342:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  802349:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80234c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802350:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  802357:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80235a:	8b 45 14             	mov    0x14(%ebp),%eax
  80235d:	8d 50 04             	lea    0x4(%eax),%edx
  802360:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  802363:	8b 30                	mov    (%eax),%esi
  802365:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80236a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80236f:	eb 13                	jmp    802384 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802371:	89 ca                	mov    %ecx,%edx
  802373:	8d 45 14             	lea    0x14(%ebp),%eax
  802376:	e8 63 fc ff ff       	call   801fde <getuint>
  80237b:	89 c6                	mov    %eax,%esi
  80237d:	89 d7                	mov    %edx,%edi
			base = 16;
  80237f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  802384:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  802388:	89 54 24 10          	mov    %edx,0x10(%esp)
  80238c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80238f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802393:	89 44 24 08          	mov    %eax,0x8(%esp)
  802397:	89 34 24             	mov    %esi,(%esp)
  80239a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80239e:	89 da                	mov    %ebx,%edx
  8023a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a3:	e8 6c fb ff ff       	call   801f14 <printnum>
			break;
  8023a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8023ab:	e9 cd fc ff ff       	jmp    80207d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8023b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023b4:	89 04 24             	mov    %eax,(%esp)
  8023b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8023ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8023bd:	e9 bb fc ff ff       	jmp    80207d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8023c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023c6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8023cd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8023d0:	eb 01                	jmp    8023d3 <vprintfmt+0x379>
  8023d2:	4e                   	dec    %esi
  8023d3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8023d7:	75 f9                	jne    8023d2 <vprintfmt+0x378>
  8023d9:	e9 9f fc ff ff       	jmp    80207d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8023de:	83 c4 4c             	add    $0x4c,%esp
  8023e1:	5b                   	pop    %ebx
  8023e2:	5e                   	pop    %esi
  8023e3:	5f                   	pop    %edi
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    

008023e6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8023e6:	55                   	push   %ebp
  8023e7:	89 e5                	mov    %esp,%ebp
  8023e9:	83 ec 28             	sub    $0x28,%esp
  8023ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8023f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8023f5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8023f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8023fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802403:	85 c0                	test   %eax,%eax
  802405:	74 30                	je     802437 <vsnprintf+0x51>
  802407:	85 d2                	test   %edx,%edx
  802409:	7e 33                	jle    80243e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80240b:	8b 45 14             	mov    0x14(%ebp),%eax
  80240e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802412:	8b 45 10             	mov    0x10(%ebp),%eax
  802415:	89 44 24 08          	mov    %eax,0x8(%esp)
  802419:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80241c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802420:	c7 04 24 18 20 80 00 	movl   $0x802018,(%esp)
  802427:	e8 2e fc ff ff       	call   80205a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80242c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80242f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802432:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802435:	eb 0c                	jmp    802443 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  802437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80243c:	eb 05                	jmp    802443 <vsnprintf+0x5d>
  80243e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802443:	c9                   	leave  
  802444:	c3                   	ret    

00802445 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802445:	55                   	push   %ebp
  802446:	89 e5                	mov    %esp,%ebp
  802448:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80244b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80244e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802452:	8b 45 10             	mov    0x10(%ebp),%eax
  802455:	89 44 24 08          	mov    %eax,0x8(%esp)
  802459:	8b 45 0c             	mov    0xc(%ebp),%eax
  80245c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802460:	8b 45 08             	mov    0x8(%ebp),%eax
  802463:	89 04 24             	mov    %eax,(%esp)
  802466:	e8 7b ff ff ff       	call   8023e6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80246b:	c9                   	leave  
  80246c:	c3                   	ret    
  80246d:	00 00                	add    %al,(%eax)
	...

00802470 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802476:	b8 00 00 00 00       	mov    $0x0,%eax
  80247b:	eb 01                	jmp    80247e <strlen+0xe>
		n++;
  80247d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80247e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802482:	75 f9                	jne    80247d <strlen+0xd>
		n++;
	return n;
}
  802484:	5d                   	pop    %ebp
  802485:	c3                   	ret    

00802486 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802486:	55                   	push   %ebp
  802487:	89 e5                	mov    %esp,%ebp
  802489:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80248c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80248f:	b8 00 00 00 00       	mov    $0x0,%eax
  802494:	eb 01                	jmp    802497 <strnlen+0x11>
		n++;
  802496:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802497:	39 d0                	cmp    %edx,%eax
  802499:	74 06                	je     8024a1 <strnlen+0x1b>
  80249b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80249f:	75 f5                	jne    802496 <strnlen+0x10>
		n++;
	return n;
}
  8024a1:	5d                   	pop    %ebp
  8024a2:	c3                   	ret    

008024a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8024a3:	55                   	push   %ebp
  8024a4:	89 e5                	mov    %esp,%ebp
  8024a6:	53                   	push   %ebx
  8024a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8024ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8024b2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8024b5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8024b8:	42                   	inc    %edx
  8024b9:	84 c9                	test   %cl,%cl
  8024bb:	75 f5                	jne    8024b2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8024bd:	5b                   	pop    %ebx
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    

008024c0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 08             	sub    $0x8,%esp
  8024c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8024ca:	89 1c 24             	mov    %ebx,(%esp)
  8024cd:	e8 9e ff ff ff       	call   802470 <strlen>
	strcpy(dst + len, src);
  8024d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024d9:	01 d8                	add    %ebx,%eax
  8024db:	89 04 24             	mov    %eax,(%esp)
  8024de:	e8 c0 ff ff ff       	call   8024a3 <strcpy>
	return dst;
}
  8024e3:	89 d8                	mov    %ebx,%eax
  8024e5:	83 c4 08             	add    $0x8,%esp
  8024e8:	5b                   	pop    %ebx
  8024e9:	5d                   	pop    %ebp
  8024ea:	c3                   	ret    

008024eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8024eb:	55                   	push   %ebp
  8024ec:	89 e5                	mov    %esp,%ebp
  8024ee:	56                   	push   %esi
  8024ef:	53                   	push   %ebx
  8024f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024f6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8024f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8024fe:	eb 0c                	jmp    80250c <strncpy+0x21>
		*dst++ = *src;
  802500:	8a 1a                	mov    (%edx),%bl
  802502:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802505:	80 3a 01             	cmpb   $0x1,(%edx)
  802508:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80250b:	41                   	inc    %ecx
  80250c:	39 f1                	cmp    %esi,%ecx
  80250e:	75 f0                	jne    802500 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    

00802514 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802514:	55                   	push   %ebp
  802515:	89 e5                	mov    %esp,%ebp
  802517:	56                   	push   %esi
  802518:	53                   	push   %ebx
  802519:	8b 75 08             	mov    0x8(%ebp),%esi
  80251c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80251f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802522:	85 d2                	test   %edx,%edx
  802524:	75 0a                	jne    802530 <strlcpy+0x1c>
  802526:	89 f0                	mov    %esi,%eax
  802528:	eb 1a                	jmp    802544 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80252a:	88 18                	mov    %bl,(%eax)
  80252c:	40                   	inc    %eax
  80252d:	41                   	inc    %ecx
  80252e:	eb 02                	jmp    802532 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802530:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  802532:	4a                   	dec    %edx
  802533:	74 0a                	je     80253f <strlcpy+0x2b>
  802535:	8a 19                	mov    (%ecx),%bl
  802537:	84 db                	test   %bl,%bl
  802539:	75 ef                	jne    80252a <strlcpy+0x16>
  80253b:	89 c2                	mov    %eax,%edx
  80253d:	eb 02                	jmp    802541 <strlcpy+0x2d>
  80253f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  802541:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  802544:	29 f0                	sub    %esi,%eax
}
  802546:	5b                   	pop    %ebx
  802547:	5e                   	pop    %esi
  802548:	5d                   	pop    %ebp
  802549:	c3                   	ret    

0080254a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80254a:	55                   	push   %ebp
  80254b:	89 e5                	mov    %esp,%ebp
  80254d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802550:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802553:	eb 02                	jmp    802557 <strcmp+0xd>
		p++, q++;
  802555:	41                   	inc    %ecx
  802556:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802557:	8a 01                	mov    (%ecx),%al
  802559:	84 c0                	test   %al,%al
  80255b:	74 04                	je     802561 <strcmp+0x17>
  80255d:	3a 02                	cmp    (%edx),%al
  80255f:	74 f4                	je     802555 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802561:	0f b6 c0             	movzbl %al,%eax
  802564:	0f b6 12             	movzbl (%edx),%edx
  802567:	29 d0                	sub    %edx,%eax
}
  802569:	5d                   	pop    %ebp
  80256a:	c3                   	ret    

0080256b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80256b:	55                   	push   %ebp
  80256c:	89 e5                	mov    %esp,%ebp
  80256e:	53                   	push   %ebx
  80256f:	8b 45 08             	mov    0x8(%ebp),%eax
  802572:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802575:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  802578:	eb 03                	jmp    80257d <strncmp+0x12>
		n--, p++, q++;
  80257a:	4a                   	dec    %edx
  80257b:	40                   	inc    %eax
  80257c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80257d:	85 d2                	test   %edx,%edx
  80257f:	74 14                	je     802595 <strncmp+0x2a>
  802581:	8a 18                	mov    (%eax),%bl
  802583:	84 db                	test   %bl,%bl
  802585:	74 04                	je     80258b <strncmp+0x20>
  802587:	3a 19                	cmp    (%ecx),%bl
  802589:	74 ef                	je     80257a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80258b:	0f b6 00             	movzbl (%eax),%eax
  80258e:	0f b6 11             	movzbl (%ecx),%edx
  802591:	29 d0                	sub    %edx,%eax
  802593:	eb 05                	jmp    80259a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802595:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80259a:	5b                   	pop    %ebx
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    

0080259d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80259d:	55                   	push   %ebp
  80259e:	89 e5                	mov    %esp,%ebp
  8025a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8025a6:	eb 05                	jmp    8025ad <strchr+0x10>
		if (*s == c)
  8025a8:	38 ca                	cmp    %cl,%dl
  8025aa:	74 0c                	je     8025b8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8025ac:	40                   	inc    %eax
  8025ad:	8a 10                	mov    (%eax),%dl
  8025af:	84 d2                	test   %dl,%dl
  8025b1:	75 f5                	jne    8025a8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8025b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025b8:	5d                   	pop    %ebp
  8025b9:	c3                   	ret    

008025ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8025ba:	55                   	push   %ebp
  8025bb:	89 e5                	mov    %esp,%ebp
  8025bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8025c3:	eb 05                	jmp    8025ca <strfind+0x10>
		if (*s == c)
  8025c5:	38 ca                	cmp    %cl,%dl
  8025c7:	74 07                	je     8025d0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8025c9:	40                   	inc    %eax
  8025ca:	8a 10                	mov    (%eax),%dl
  8025cc:	84 d2                	test   %dl,%dl
  8025ce:	75 f5                	jne    8025c5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8025d0:	5d                   	pop    %ebp
  8025d1:	c3                   	ret    

008025d2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8025d2:	55                   	push   %ebp
  8025d3:	89 e5                	mov    %esp,%ebp
  8025d5:	57                   	push   %edi
  8025d6:	56                   	push   %esi
  8025d7:	53                   	push   %ebx
  8025d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8025e1:	85 c9                	test   %ecx,%ecx
  8025e3:	74 30                	je     802615 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8025e5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8025eb:	75 25                	jne    802612 <memset+0x40>
  8025ed:	f6 c1 03             	test   $0x3,%cl
  8025f0:	75 20                	jne    802612 <memset+0x40>
		c &= 0xFF;
  8025f2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8025f5:	89 d3                	mov    %edx,%ebx
  8025f7:	c1 e3 08             	shl    $0x8,%ebx
  8025fa:	89 d6                	mov    %edx,%esi
  8025fc:	c1 e6 18             	shl    $0x18,%esi
  8025ff:	89 d0                	mov    %edx,%eax
  802601:	c1 e0 10             	shl    $0x10,%eax
  802604:	09 f0                	or     %esi,%eax
  802606:	09 d0                	or     %edx,%eax
  802608:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80260a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80260d:	fc                   	cld    
  80260e:	f3 ab                	rep stos %eax,%es:(%edi)
  802610:	eb 03                	jmp    802615 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802612:	fc                   	cld    
  802613:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802615:	89 f8                	mov    %edi,%eax
  802617:	5b                   	pop    %ebx
  802618:	5e                   	pop    %esi
  802619:	5f                   	pop    %edi
  80261a:	5d                   	pop    %ebp
  80261b:	c3                   	ret    

0080261c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80261c:	55                   	push   %ebp
  80261d:	89 e5                	mov    %esp,%ebp
  80261f:	57                   	push   %edi
  802620:	56                   	push   %esi
  802621:	8b 45 08             	mov    0x8(%ebp),%eax
  802624:	8b 75 0c             	mov    0xc(%ebp),%esi
  802627:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80262a:	39 c6                	cmp    %eax,%esi
  80262c:	73 34                	jae    802662 <memmove+0x46>
  80262e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802631:	39 d0                	cmp    %edx,%eax
  802633:	73 2d                	jae    802662 <memmove+0x46>
		s += n;
		d += n;
  802635:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802638:	f6 c2 03             	test   $0x3,%dl
  80263b:	75 1b                	jne    802658 <memmove+0x3c>
  80263d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802643:	75 13                	jne    802658 <memmove+0x3c>
  802645:	f6 c1 03             	test   $0x3,%cl
  802648:	75 0e                	jne    802658 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80264a:	83 ef 04             	sub    $0x4,%edi
  80264d:	8d 72 fc             	lea    -0x4(%edx),%esi
  802650:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  802653:	fd                   	std    
  802654:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802656:	eb 07                	jmp    80265f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  802658:	4f                   	dec    %edi
  802659:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80265c:	fd                   	std    
  80265d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80265f:	fc                   	cld    
  802660:	eb 20                	jmp    802682 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802662:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802668:	75 13                	jne    80267d <memmove+0x61>
  80266a:	a8 03                	test   $0x3,%al
  80266c:	75 0f                	jne    80267d <memmove+0x61>
  80266e:	f6 c1 03             	test   $0x3,%cl
  802671:	75 0a                	jne    80267d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802673:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  802676:	89 c7                	mov    %eax,%edi
  802678:	fc                   	cld    
  802679:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80267b:	eb 05                	jmp    802682 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80267d:	89 c7                	mov    %eax,%edi
  80267f:	fc                   	cld    
  802680:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802682:	5e                   	pop    %esi
  802683:	5f                   	pop    %edi
  802684:	5d                   	pop    %ebp
  802685:	c3                   	ret    

00802686 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802686:	55                   	push   %ebp
  802687:	89 e5                	mov    %esp,%ebp
  802689:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80268c:	8b 45 10             	mov    0x10(%ebp),%eax
  80268f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802693:	8b 45 0c             	mov    0xc(%ebp),%eax
  802696:	89 44 24 04          	mov    %eax,0x4(%esp)
  80269a:	8b 45 08             	mov    0x8(%ebp),%eax
  80269d:	89 04 24             	mov    %eax,(%esp)
  8026a0:	e8 77 ff ff ff       	call   80261c <memmove>
}
  8026a5:	c9                   	leave  
  8026a6:	c3                   	ret    

008026a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8026a7:	55                   	push   %ebp
  8026a8:	89 e5                	mov    %esp,%ebp
  8026aa:	57                   	push   %edi
  8026ab:	56                   	push   %esi
  8026ac:	53                   	push   %ebx
  8026ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8026b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8026bb:	eb 16                	jmp    8026d3 <memcmp+0x2c>
		if (*s1 != *s2)
  8026bd:	8a 04 17             	mov    (%edi,%edx,1),%al
  8026c0:	42                   	inc    %edx
  8026c1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8026c5:	38 c8                	cmp    %cl,%al
  8026c7:	74 0a                	je     8026d3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8026c9:	0f b6 c0             	movzbl %al,%eax
  8026cc:	0f b6 c9             	movzbl %cl,%ecx
  8026cf:	29 c8                	sub    %ecx,%eax
  8026d1:	eb 09                	jmp    8026dc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8026d3:	39 da                	cmp    %ebx,%edx
  8026d5:	75 e6                	jne    8026bd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8026d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026dc:	5b                   	pop    %ebx
  8026dd:	5e                   	pop    %esi
  8026de:	5f                   	pop    %edi
  8026df:	5d                   	pop    %ebp
  8026e0:	c3                   	ret    

008026e1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8026e1:	55                   	push   %ebp
  8026e2:	89 e5                	mov    %esp,%ebp
  8026e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8026e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8026ea:	89 c2                	mov    %eax,%edx
  8026ec:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8026ef:	eb 05                	jmp    8026f6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8026f1:	38 08                	cmp    %cl,(%eax)
  8026f3:	74 05                	je     8026fa <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8026f5:	40                   	inc    %eax
  8026f6:	39 d0                	cmp    %edx,%eax
  8026f8:	72 f7                	jb     8026f1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8026fa:	5d                   	pop    %ebp
  8026fb:	c3                   	ret    

008026fc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8026fc:	55                   	push   %ebp
  8026fd:	89 e5                	mov    %esp,%ebp
  8026ff:	57                   	push   %edi
  802700:	56                   	push   %esi
  802701:	53                   	push   %ebx
  802702:	8b 55 08             	mov    0x8(%ebp),%edx
  802705:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802708:	eb 01                	jmp    80270b <strtol+0xf>
		s++;
  80270a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80270b:	8a 02                	mov    (%edx),%al
  80270d:	3c 20                	cmp    $0x20,%al
  80270f:	74 f9                	je     80270a <strtol+0xe>
  802711:	3c 09                	cmp    $0x9,%al
  802713:	74 f5                	je     80270a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802715:	3c 2b                	cmp    $0x2b,%al
  802717:	75 08                	jne    802721 <strtol+0x25>
		s++;
  802719:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80271a:	bf 00 00 00 00       	mov    $0x0,%edi
  80271f:	eb 13                	jmp    802734 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802721:	3c 2d                	cmp    $0x2d,%al
  802723:	75 0a                	jne    80272f <strtol+0x33>
		s++, neg = 1;
  802725:	8d 52 01             	lea    0x1(%edx),%edx
  802728:	bf 01 00 00 00       	mov    $0x1,%edi
  80272d:	eb 05                	jmp    802734 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80272f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802734:	85 db                	test   %ebx,%ebx
  802736:	74 05                	je     80273d <strtol+0x41>
  802738:	83 fb 10             	cmp    $0x10,%ebx
  80273b:	75 28                	jne    802765 <strtol+0x69>
  80273d:	8a 02                	mov    (%edx),%al
  80273f:	3c 30                	cmp    $0x30,%al
  802741:	75 10                	jne    802753 <strtol+0x57>
  802743:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802747:	75 0a                	jne    802753 <strtol+0x57>
		s += 2, base = 16;
  802749:	83 c2 02             	add    $0x2,%edx
  80274c:	bb 10 00 00 00       	mov    $0x10,%ebx
  802751:	eb 12                	jmp    802765 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  802753:	85 db                	test   %ebx,%ebx
  802755:	75 0e                	jne    802765 <strtol+0x69>
  802757:	3c 30                	cmp    $0x30,%al
  802759:	75 05                	jne    802760 <strtol+0x64>
		s++, base = 8;
  80275b:	42                   	inc    %edx
  80275c:	b3 08                	mov    $0x8,%bl
  80275e:	eb 05                	jmp    802765 <strtol+0x69>
	else if (base == 0)
		base = 10;
  802760:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802765:	b8 00 00 00 00       	mov    $0x0,%eax
  80276a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80276c:	8a 0a                	mov    (%edx),%cl
  80276e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802771:	80 fb 09             	cmp    $0x9,%bl
  802774:	77 08                	ja     80277e <strtol+0x82>
			dig = *s - '0';
  802776:	0f be c9             	movsbl %cl,%ecx
  802779:	83 e9 30             	sub    $0x30,%ecx
  80277c:	eb 1e                	jmp    80279c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80277e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802781:	80 fb 19             	cmp    $0x19,%bl
  802784:	77 08                	ja     80278e <strtol+0x92>
			dig = *s - 'a' + 10;
  802786:	0f be c9             	movsbl %cl,%ecx
  802789:	83 e9 57             	sub    $0x57,%ecx
  80278c:	eb 0e                	jmp    80279c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80278e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802791:	80 fb 19             	cmp    $0x19,%bl
  802794:	77 12                	ja     8027a8 <strtol+0xac>
			dig = *s - 'A' + 10;
  802796:	0f be c9             	movsbl %cl,%ecx
  802799:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80279c:	39 f1                	cmp    %esi,%ecx
  80279e:	7d 0c                	jge    8027ac <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8027a0:	42                   	inc    %edx
  8027a1:	0f af c6             	imul   %esi,%eax
  8027a4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8027a6:	eb c4                	jmp    80276c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8027a8:	89 c1                	mov    %eax,%ecx
  8027aa:	eb 02                	jmp    8027ae <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8027ac:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8027ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8027b2:	74 05                	je     8027b9 <strtol+0xbd>
		*endptr = (char *) s;
  8027b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8027b7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8027b9:	85 ff                	test   %edi,%edi
  8027bb:	74 04                	je     8027c1 <strtol+0xc5>
  8027bd:	89 c8                	mov    %ecx,%eax
  8027bf:	f7 d8                	neg    %eax
}
  8027c1:	5b                   	pop    %ebx
  8027c2:	5e                   	pop    %esi
  8027c3:	5f                   	pop    %edi
  8027c4:	5d                   	pop    %ebp
  8027c5:	c3                   	ret    
	...

008027c8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8027c8:	55                   	push   %ebp
  8027c9:	89 e5                	mov    %esp,%ebp
  8027cb:	57                   	push   %edi
  8027cc:	56                   	push   %esi
  8027cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8027d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8027d9:	89 c3                	mov    %eax,%ebx
  8027db:	89 c7                	mov    %eax,%edi
  8027dd:	89 c6                	mov    %eax,%esi
  8027df:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8027e1:	5b                   	pop    %ebx
  8027e2:	5e                   	pop    %esi
  8027e3:	5f                   	pop    %edi
  8027e4:	5d                   	pop    %ebp
  8027e5:	c3                   	ret    

008027e6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8027e6:	55                   	push   %ebp
  8027e7:	89 e5                	mov    %esp,%ebp
  8027e9:	57                   	push   %edi
  8027ea:	56                   	push   %esi
  8027eb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8027f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8027f6:	89 d1                	mov    %edx,%ecx
  8027f8:	89 d3                	mov    %edx,%ebx
  8027fa:	89 d7                	mov    %edx,%edi
  8027fc:	89 d6                	mov    %edx,%esi
  8027fe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802800:	5b                   	pop    %ebx
  802801:	5e                   	pop    %esi
  802802:	5f                   	pop    %edi
  802803:	5d                   	pop    %ebp
  802804:	c3                   	ret    

00802805 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802805:	55                   	push   %ebp
  802806:	89 e5                	mov    %esp,%ebp
  802808:	57                   	push   %edi
  802809:	56                   	push   %esi
  80280a:	53                   	push   %ebx
  80280b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80280e:	b9 00 00 00 00       	mov    $0x0,%ecx
  802813:	b8 03 00 00 00       	mov    $0x3,%eax
  802818:	8b 55 08             	mov    0x8(%ebp),%edx
  80281b:	89 cb                	mov    %ecx,%ebx
  80281d:	89 cf                	mov    %ecx,%edi
  80281f:	89 ce                	mov    %ecx,%esi
  802821:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802823:	85 c0                	test   %eax,%eax
  802825:	7e 28                	jle    80284f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802827:	89 44 24 10          	mov    %eax,0x10(%esp)
  80282b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802832:	00 
  802833:	c7 44 24 08 9f 45 80 	movl   $0x80459f,0x8(%esp)
  80283a:	00 
  80283b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802842:	00 
  802843:	c7 04 24 bc 45 80 00 	movl   $0x8045bc,(%esp)
  80284a:	e8 b1 f5 ff ff       	call   801e00 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80284f:	83 c4 2c             	add    $0x2c,%esp
  802852:	5b                   	pop    %ebx
  802853:	5e                   	pop    %esi
  802854:	5f                   	pop    %edi
  802855:	5d                   	pop    %ebp
  802856:	c3                   	ret    

00802857 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802857:	55                   	push   %ebp
  802858:	89 e5                	mov    %esp,%ebp
  80285a:	57                   	push   %edi
  80285b:	56                   	push   %esi
  80285c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80285d:	ba 00 00 00 00       	mov    $0x0,%edx
  802862:	b8 02 00 00 00       	mov    $0x2,%eax
  802867:	89 d1                	mov    %edx,%ecx
  802869:	89 d3                	mov    %edx,%ebx
  80286b:	89 d7                	mov    %edx,%edi
  80286d:	89 d6                	mov    %edx,%esi
  80286f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802871:	5b                   	pop    %ebx
  802872:	5e                   	pop    %esi
  802873:	5f                   	pop    %edi
  802874:	5d                   	pop    %ebp
  802875:	c3                   	ret    

00802876 <sys_yield>:

void
sys_yield(void)
{
  802876:	55                   	push   %ebp
  802877:	89 e5                	mov    %esp,%ebp
  802879:	57                   	push   %edi
  80287a:	56                   	push   %esi
  80287b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80287c:	ba 00 00 00 00       	mov    $0x0,%edx
  802881:	b8 0b 00 00 00       	mov    $0xb,%eax
  802886:	89 d1                	mov    %edx,%ecx
  802888:	89 d3                	mov    %edx,%ebx
  80288a:	89 d7                	mov    %edx,%edi
  80288c:	89 d6                	mov    %edx,%esi
  80288e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802890:	5b                   	pop    %ebx
  802891:	5e                   	pop    %esi
  802892:	5f                   	pop    %edi
  802893:	5d                   	pop    %ebp
  802894:	c3                   	ret    

00802895 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802895:	55                   	push   %ebp
  802896:	89 e5                	mov    %esp,%ebp
  802898:	57                   	push   %edi
  802899:	56                   	push   %esi
  80289a:	53                   	push   %ebx
  80289b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80289e:	be 00 00 00 00       	mov    $0x0,%esi
  8028a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8028a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8028ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8028b1:	89 f7                	mov    %esi,%edi
  8028b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8028b5:	85 c0                	test   %eax,%eax
  8028b7:	7e 28                	jle    8028e1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8028b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028bd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8028c4:	00 
  8028c5:	c7 44 24 08 9f 45 80 	movl   $0x80459f,0x8(%esp)
  8028cc:	00 
  8028cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8028d4:	00 
  8028d5:	c7 04 24 bc 45 80 00 	movl   $0x8045bc,(%esp)
  8028dc:	e8 1f f5 ff ff       	call   801e00 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8028e1:	83 c4 2c             	add    $0x2c,%esp
  8028e4:	5b                   	pop    %ebx
  8028e5:	5e                   	pop    %esi
  8028e6:	5f                   	pop    %edi
  8028e7:	5d                   	pop    %ebp
  8028e8:	c3                   	ret    

008028e9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8028e9:	55                   	push   %ebp
  8028ea:	89 e5                	mov    %esp,%ebp
  8028ec:	57                   	push   %edi
  8028ed:	56                   	push   %esi
  8028ee:	53                   	push   %ebx
  8028ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8028f7:	8b 75 18             	mov    0x18(%ebp),%esi
  8028fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8028fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802900:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802903:	8b 55 08             	mov    0x8(%ebp),%edx
  802906:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802908:	85 c0                	test   %eax,%eax
  80290a:	7e 28                	jle    802934 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80290c:	89 44 24 10          	mov    %eax,0x10(%esp)
  802910:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  802917:	00 
  802918:	c7 44 24 08 9f 45 80 	movl   $0x80459f,0x8(%esp)
  80291f:	00 
  802920:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802927:	00 
  802928:	c7 04 24 bc 45 80 00 	movl   $0x8045bc,(%esp)
  80292f:	e8 cc f4 ff ff       	call   801e00 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802934:	83 c4 2c             	add    $0x2c,%esp
  802937:	5b                   	pop    %ebx
  802938:	5e                   	pop    %esi
  802939:	5f                   	pop    %edi
  80293a:	5d                   	pop    %ebp
  80293b:	c3                   	ret    

0080293c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80293c:	55                   	push   %ebp
  80293d:	89 e5                	mov    %esp,%ebp
  80293f:	57                   	push   %edi
  802940:	56                   	push   %esi
  802941:	53                   	push   %ebx
  802942:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802945:	bb 00 00 00 00       	mov    $0x0,%ebx
  80294a:	b8 06 00 00 00       	mov    $0x6,%eax
  80294f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802952:	8b 55 08             	mov    0x8(%ebp),%edx
  802955:	89 df                	mov    %ebx,%edi
  802957:	89 de                	mov    %ebx,%esi
  802959:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80295b:	85 c0                	test   %eax,%eax
  80295d:	7e 28                	jle    802987 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80295f:	89 44 24 10          	mov    %eax,0x10(%esp)
  802963:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80296a:	00 
  80296b:	c7 44 24 08 9f 45 80 	movl   $0x80459f,0x8(%esp)
  802972:	00 
  802973:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80297a:	00 
  80297b:	c7 04 24 bc 45 80 00 	movl   $0x8045bc,(%esp)
  802982:	e8 79 f4 ff ff       	call   801e00 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802987:	83 c4 2c             	add    $0x2c,%esp
  80298a:	5b                   	pop    %ebx
  80298b:	5e                   	pop    %esi
  80298c:	5f                   	pop    %edi
  80298d:	5d                   	pop    %ebp
  80298e:	c3                   	ret    

0080298f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80298f:	55                   	push   %ebp
  802990:	89 e5                	mov    %esp,%ebp
  802992:	57                   	push   %edi
  802993:	56                   	push   %esi
  802994:	53                   	push   %ebx
  802995:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802998:	bb 00 00 00 00       	mov    $0x0,%ebx
  80299d:	b8 08 00 00 00       	mov    $0x8,%eax
  8029a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8029a8:	89 df                	mov    %ebx,%edi
  8029aa:	89 de                	mov    %ebx,%esi
  8029ac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8029ae:	85 c0                	test   %eax,%eax
  8029b0:	7e 28                	jle    8029da <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8029b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029b6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8029bd:	00 
  8029be:	c7 44 24 08 9f 45 80 	movl   $0x80459f,0x8(%esp)
  8029c5:	00 
  8029c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8029cd:	00 
  8029ce:	c7 04 24 bc 45 80 00 	movl   $0x8045bc,(%esp)
  8029d5:	e8 26 f4 ff ff       	call   801e00 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8029da:	83 c4 2c             	add    $0x2c,%esp
  8029dd:	5b                   	pop    %ebx
  8029de:	5e                   	pop    %esi
  8029df:	5f                   	pop    %edi
  8029e0:	5d                   	pop    %ebp
  8029e1:	c3                   	ret    

008029e2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8029e2:	55                   	push   %ebp
  8029e3:	89 e5                	mov    %esp,%ebp
  8029e5:	57                   	push   %edi
  8029e6:	56                   	push   %esi
  8029e7:	53                   	push   %ebx
  8029e8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8029eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029f0:	b8 09 00 00 00       	mov    $0x9,%eax
  8029f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8029fb:	89 df                	mov    %ebx,%edi
  8029fd:	89 de                	mov    %ebx,%esi
  8029ff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802a01:	85 c0                	test   %eax,%eax
  802a03:	7e 28                	jle    802a2d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802a05:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a09:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  802a10:	00 
  802a11:	c7 44 24 08 9f 45 80 	movl   $0x80459f,0x8(%esp)
  802a18:	00 
  802a19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a20:	00 
  802a21:	c7 04 24 bc 45 80 00 	movl   $0x8045bc,(%esp)
  802a28:	e8 d3 f3 ff ff       	call   801e00 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802a2d:	83 c4 2c             	add    $0x2c,%esp
  802a30:	5b                   	pop    %ebx
  802a31:	5e                   	pop    %esi
  802a32:	5f                   	pop    %edi
  802a33:	5d                   	pop    %ebp
  802a34:	c3                   	ret    

00802a35 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802a35:	55                   	push   %ebp
  802a36:	89 e5                	mov    %esp,%ebp
  802a38:	57                   	push   %edi
  802a39:	56                   	push   %esi
  802a3a:	53                   	push   %ebx
  802a3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a43:	b8 0a 00 00 00       	mov    $0xa,%eax
  802a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a4b:	8b 55 08             	mov    0x8(%ebp),%edx
  802a4e:	89 df                	mov    %ebx,%edi
  802a50:	89 de                	mov    %ebx,%esi
  802a52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802a54:	85 c0                	test   %eax,%eax
  802a56:	7e 28                	jle    802a80 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802a58:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a5c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802a63:	00 
  802a64:	c7 44 24 08 9f 45 80 	movl   $0x80459f,0x8(%esp)
  802a6b:	00 
  802a6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a73:	00 
  802a74:	c7 04 24 bc 45 80 00 	movl   $0x8045bc,(%esp)
  802a7b:	e8 80 f3 ff ff       	call   801e00 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802a80:	83 c4 2c             	add    $0x2c,%esp
  802a83:	5b                   	pop    %ebx
  802a84:	5e                   	pop    %esi
  802a85:	5f                   	pop    %edi
  802a86:	5d                   	pop    %ebp
  802a87:	c3                   	ret    

00802a88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802a88:	55                   	push   %ebp
  802a89:	89 e5                	mov    %esp,%ebp
  802a8b:	57                   	push   %edi
  802a8c:	56                   	push   %esi
  802a8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a8e:	be 00 00 00 00       	mov    $0x0,%esi
  802a93:	b8 0c 00 00 00       	mov    $0xc,%eax
  802a98:	8b 7d 14             	mov    0x14(%ebp),%edi
  802a9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802a9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802aa1:	8b 55 08             	mov    0x8(%ebp),%edx
  802aa4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802aa6:	5b                   	pop    %ebx
  802aa7:	5e                   	pop    %esi
  802aa8:	5f                   	pop    %edi
  802aa9:	5d                   	pop    %ebp
  802aaa:	c3                   	ret    

00802aab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802aab:	55                   	push   %ebp
  802aac:	89 e5                	mov    %esp,%ebp
  802aae:	57                   	push   %edi
  802aaf:	56                   	push   %esi
  802ab0:	53                   	push   %ebx
  802ab1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802ab4:	b9 00 00 00 00       	mov    $0x0,%ecx
  802ab9:	b8 0d 00 00 00       	mov    $0xd,%eax
  802abe:	8b 55 08             	mov    0x8(%ebp),%edx
  802ac1:	89 cb                	mov    %ecx,%ebx
  802ac3:	89 cf                	mov    %ecx,%edi
  802ac5:	89 ce                	mov    %ecx,%esi
  802ac7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802ac9:	85 c0                	test   %eax,%eax
  802acb:	7e 28                	jle    802af5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802acd:	89 44 24 10          	mov    %eax,0x10(%esp)
  802ad1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  802ad8:	00 
  802ad9:	c7 44 24 08 9f 45 80 	movl   $0x80459f,0x8(%esp)
  802ae0:	00 
  802ae1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802ae8:	00 
  802ae9:	c7 04 24 bc 45 80 00 	movl   $0x8045bc,(%esp)
  802af0:	e8 0b f3 ff ff       	call   801e00 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802af5:	83 c4 2c             	add    $0x2c,%esp
  802af8:	5b                   	pop    %ebx
  802af9:	5e                   	pop    %esi
  802afa:	5f                   	pop    %edi
  802afb:	5d                   	pop    %ebp
  802afc:	c3                   	ret    
  802afd:	00 00                	add    %al,(%eax)
	...

00802b00 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802b00:	55                   	push   %ebp
  802b01:	89 e5                	mov    %esp,%ebp
  802b03:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802b06:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802b0d:	75 32                	jne    802b41 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802b0f:	e8 43 fd ff ff       	call   802857 <sys_getenvid>
  802b14:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  802b1b:	00 
  802b1c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802b23:	ee 
  802b24:	89 04 24             	mov    %eax,(%esp)
  802b27:	e8 69 fd ff ff       	call   802895 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  802b2c:	e8 26 fd ff ff       	call   802857 <sys_getenvid>
  802b31:	c7 44 24 04 4c 2b 80 	movl   $0x802b4c,0x4(%esp)
  802b38:	00 
  802b39:	89 04 24             	mov    %eax,(%esp)
  802b3c:	e8 f4 fe ff ff       	call   802a35 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802b41:	8b 45 08             	mov    0x8(%ebp),%eax
  802b44:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  802b49:	c9                   	leave  
  802b4a:	c3                   	ret    
	...

00802b4c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b4c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b4d:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802b52:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802b54:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  802b57:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  802b5b:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  802b5e:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  802b63:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  802b67:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  802b6a:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  802b6b:	83 c4 04             	add    $0x4,%esp
	popfl
  802b6e:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  802b6f:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  802b70:	c3                   	ret    
  802b71:	00 00                	add    %al,(%eax)
	...

00802b74 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802b74:	55                   	push   %ebp
  802b75:	89 e5                	mov    %esp,%ebp
  802b77:	57                   	push   %edi
  802b78:	56                   	push   %esi
  802b79:	53                   	push   %ebx
  802b7a:	83 ec 1c             	sub    $0x1c,%esp
  802b7d:	8b 75 08             	mov    0x8(%ebp),%esi
  802b80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802b83:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  802b86:	85 db                	test   %ebx,%ebx
  802b88:	75 05                	jne    802b8f <ipc_recv+0x1b>
		pg = (void *)UTOP;
  802b8a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  802b8f:	89 1c 24             	mov    %ebx,(%esp)
  802b92:	e8 14 ff ff ff       	call   802aab <sys_ipc_recv>
  802b97:	85 c0                	test   %eax,%eax
  802b99:	79 16                	jns    802bb1 <ipc_recv+0x3d>
		*from_env_store = 0;
  802b9b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  802ba1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  802ba7:	89 1c 24             	mov    %ebx,(%esp)
  802baa:	e8 fc fe ff ff       	call   802aab <sys_ipc_recv>
  802baf:	eb 24                	jmp    802bd5 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  802bb1:	85 f6                	test   %esi,%esi
  802bb3:	74 0a                	je     802bbf <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802bb5:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802bba:	8b 40 74             	mov    0x74(%eax),%eax
  802bbd:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802bbf:	85 ff                	test   %edi,%edi
  802bc1:	74 0a                	je     802bcd <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802bc3:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802bc8:	8b 40 78             	mov    0x78(%eax),%eax
  802bcb:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  802bcd:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802bd2:	8b 40 70             	mov    0x70(%eax),%eax
}
  802bd5:	83 c4 1c             	add    $0x1c,%esp
  802bd8:	5b                   	pop    %ebx
  802bd9:	5e                   	pop    %esi
  802bda:	5f                   	pop    %edi
  802bdb:	5d                   	pop    %ebp
  802bdc:	c3                   	ret    

00802bdd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802bdd:	55                   	push   %ebp
  802bde:	89 e5                	mov    %esp,%ebp
  802be0:	57                   	push   %edi
  802be1:	56                   	push   %esi
  802be2:	53                   	push   %ebx
  802be3:	83 ec 1c             	sub    $0x1c,%esp
  802be6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802be9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802bec:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802bef:	85 db                	test   %ebx,%ebx
  802bf1:	75 05                	jne    802bf8 <ipc_send+0x1b>
		pg = (void *)-1;
  802bf3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802bf8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802bfc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c00:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c04:	8b 45 08             	mov    0x8(%ebp),%eax
  802c07:	89 04 24             	mov    %eax,(%esp)
  802c0a:	e8 79 fe ff ff       	call   802a88 <sys_ipc_try_send>
		if (r == 0) {		
  802c0f:	85 c0                	test   %eax,%eax
  802c11:	74 2c                	je     802c3f <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  802c13:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802c16:	75 07                	jne    802c1f <ipc_send+0x42>
			sys_yield();
  802c18:	e8 59 fc ff ff       	call   802876 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  802c1d:	eb d9                	jmp    802bf8 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  802c1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c23:	c7 44 24 08 ca 45 80 	movl   $0x8045ca,0x8(%esp)
  802c2a:	00 
  802c2b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  802c32:	00 
  802c33:	c7 04 24 d8 45 80 00 	movl   $0x8045d8,(%esp)
  802c3a:	e8 c1 f1 ff ff       	call   801e00 <_panic>
		}
	}
}
  802c3f:	83 c4 1c             	add    $0x1c,%esp
  802c42:	5b                   	pop    %ebx
  802c43:	5e                   	pop    %esi
  802c44:	5f                   	pop    %edi
  802c45:	5d                   	pop    %ebp
  802c46:	c3                   	ret    

00802c47 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802c47:	55                   	push   %ebp
  802c48:	89 e5                	mov    %esp,%ebp
  802c4a:	53                   	push   %ebx
  802c4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802c4e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802c53:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802c5a:	89 c2                	mov    %eax,%edx
  802c5c:	c1 e2 07             	shl    $0x7,%edx
  802c5f:	29 ca                	sub    %ecx,%edx
  802c61:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802c67:	8b 52 50             	mov    0x50(%edx),%edx
  802c6a:	39 da                	cmp    %ebx,%edx
  802c6c:	75 0f                	jne    802c7d <ipc_find_env+0x36>
			return envs[i].env_id;
  802c6e:	c1 e0 07             	shl    $0x7,%eax
  802c71:	29 c8                	sub    %ecx,%eax
  802c73:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802c78:	8b 40 40             	mov    0x40(%eax),%eax
  802c7b:	eb 0c                	jmp    802c89 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802c7d:	40                   	inc    %eax
  802c7e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802c83:	75 ce                	jne    802c53 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802c85:	66 b8 00 00          	mov    $0x0,%ax
}
  802c89:	5b                   	pop    %ebx
  802c8a:	5d                   	pop    %ebp
  802c8b:	c3                   	ret    

00802c8c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802c8c:	55                   	push   %ebp
  802c8d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  802c92:	05 00 00 00 30       	add    $0x30000000,%eax
  802c97:	c1 e8 0c             	shr    $0xc,%eax
}
  802c9a:	5d                   	pop    %ebp
  802c9b:	c3                   	ret    

00802c9c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802c9c:	55                   	push   %ebp
  802c9d:	89 e5                	mov    %esp,%ebp
  802c9f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  802ca5:	89 04 24             	mov    %eax,(%esp)
  802ca8:	e8 df ff ff ff       	call   802c8c <fd2num>
  802cad:	05 20 00 0d 00       	add    $0xd0020,%eax
  802cb2:	c1 e0 0c             	shl    $0xc,%eax
}
  802cb5:	c9                   	leave  
  802cb6:	c3                   	ret    

00802cb7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802cb7:	55                   	push   %ebp
  802cb8:	89 e5                	mov    %esp,%ebp
  802cba:	53                   	push   %ebx
  802cbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802cbe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  802cc3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802cc5:	89 c2                	mov    %eax,%edx
  802cc7:	c1 ea 16             	shr    $0x16,%edx
  802cca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802cd1:	f6 c2 01             	test   $0x1,%dl
  802cd4:	74 11                	je     802ce7 <fd_alloc+0x30>
  802cd6:	89 c2                	mov    %eax,%edx
  802cd8:	c1 ea 0c             	shr    $0xc,%edx
  802cdb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802ce2:	f6 c2 01             	test   $0x1,%dl
  802ce5:	75 09                	jne    802cf0 <fd_alloc+0x39>
			*fd_store = fd;
  802ce7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  802ce9:	b8 00 00 00 00       	mov    $0x0,%eax
  802cee:	eb 17                	jmp    802d07 <fd_alloc+0x50>
  802cf0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802cf5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802cfa:	75 c7                	jne    802cc3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802cfc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  802d02:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802d07:	5b                   	pop    %ebx
  802d08:	5d                   	pop    %ebp
  802d09:	c3                   	ret    

00802d0a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802d0a:	55                   	push   %ebp
  802d0b:	89 e5                	mov    %esp,%ebp
  802d0d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802d10:	83 f8 1f             	cmp    $0x1f,%eax
  802d13:	77 36                	ja     802d4b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802d15:	05 00 00 0d 00       	add    $0xd0000,%eax
  802d1a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802d1d:	89 c2                	mov    %eax,%edx
  802d1f:	c1 ea 16             	shr    $0x16,%edx
  802d22:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802d29:	f6 c2 01             	test   $0x1,%dl
  802d2c:	74 24                	je     802d52 <fd_lookup+0x48>
  802d2e:	89 c2                	mov    %eax,%edx
  802d30:	c1 ea 0c             	shr    $0xc,%edx
  802d33:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802d3a:	f6 c2 01             	test   $0x1,%dl
  802d3d:	74 1a                	je     802d59 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802d3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d42:	89 02                	mov    %eax,(%edx)
	return 0;
  802d44:	b8 00 00 00 00       	mov    $0x0,%eax
  802d49:	eb 13                	jmp    802d5e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802d4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d50:	eb 0c                	jmp    802d5e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802d52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d57:	eb 05                	jmp    802d5e <fd_lookup+0x54>
  802d59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802d5e:	5d                   	pop    %ebp
  802d5f:	c3                   	ret    

00802d60 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802d60:	55                   	push   %ebp
  802d61:	89 e5                	mov    %esp,%ebp
  802d63:	53                   	push   %ebx
  802d64:	83 ec 14             	sub    $0x14,%esp
  802d67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  802d6d:	ba 00 00 00 00       	mov    $0x0,%edx
  802d72:	eb 0e                	jmp    802d82 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  802d74:	39 08                	cmp    %ecx,(%eax)
  802d76:	75 09                	jne    802d81 <dev_lookup+0x21>
			*dev = devtab[i];
  802d78:	89 03                	mov    %eax,(%ebx)
			return 0;
  802d7a:	b8 00 00 00 00       	mov    $0x0,%eax
  802d7f:	eb 33                	jmp    802db4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802d81:	42                   	inc    %edx
  802d82:	8b 04 95 64 46 80 00 	mov    0x804664(,%edx,4),%eax
  802d89:	85 c0                	test   %eax,%eax
  802d8b:	75 e7                	jne    802d74 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802d8d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802d92:	8b 40 48             	mov    0x48(%eax),%eax
  802d95:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d99:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d9d:	c7 04 24 e4 45 80 00 	movl   $0x8045e4,(%esp)
  802da4:	e8 4f f1 ff ff       	call   801ef8 <cprintf>
	*dev = 0;
  802da9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  802daf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802db4:	83 c4 14             	add    $0x14,%esp
  802db7:	5b                   	pop    %ebx
  802db8:	5d                   	pop    %ebp
  802db9:	c3                   	ret    

00802dba <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802dba:	55                   	push   %ebp
  802dbb:	89 e5                	mov    %esp,%ebp
  802dbd:	56                   	push   %esi
  802dbe:	53                   	push   %ebx
  802dbf:	83 ec 30             	sub    $0x30,%esp
  802dc2:	8b 75 08             	mov    0x8(%ebp),%esi
  802dc5:	8a 45 0c             	mov    0xc(%ebp),%al
  802dc8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802dcb:	89 34 24             	mov    %esi,(%esp)
  802dce:	e8 b9 fe ff ff       	call   802c8c <fd2num>
  802dd3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802dd6:	89 54 24 04          	mov    %edx,0x4(%esp)
  802dda:	89 04 24             	mov    %eax,(%esp)
  802ddd:	e8 28 ff ff ff       	call   802d0a <fd_lookup>
  802de2:	89 c3                	mov    %eax,%ebx
  802de4:	85 c0                	test   %eax,%eax
  802de6:	78 05                	js     802ded <fd_close+0x33>
	    || fd != fd2)
  802de8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802deb:	74 0d                	je     802dfa <fd_close+0x40>
		return (must_exist ? r : 0);
  802ded:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  802df1:	75 46                	jne    802e39 <fd_close+0x7f>
  802df3:	bb 00 00 00 00       	mov    $0x0,%ebx
  802df8:	eb 3f                	jmp    802e39 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802dfa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802dfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e01:	8b 06                	mov    (%esi),%eax
  802e03:	89 04 24             	mov    %eax,(%esp)
  802e06:	e8 55 ff ff ff       	call   802d60 <dev_lookup>
  802e0b:	89 c3                	mov    %eax,%ebx
  802e0d:	85 c0                	test   %eax,%eax
  802e0f:	78 18                	js     802e29 <fd_close+0x6f>
		if (dev->dev_close)
  802e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e14:	8b 40 10             	mov    0x10(%eax),%eax
  802e17:	85 c0                	test   %eax,%eax
  802e19:	74 09                	je     802e24 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802e1b:	89 34 24             	mov    %esi,(%esp)
  802e1e:	ff d0                	call   *%eax
  802e20:	89 c3                	mov    %eax,%ebx
  802e22:	eb 05                	jmp    802e29 <fd_close+0x6f>
		else
			r = 0;
  802e24:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802e29:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e34:	e8 03 fb ff ff       	call   80293c <sys_page_unmap>
	return r;
}
  802e39:	89 d8                	mov    %ebx,%eax
  802e3b:	83 c4 30             	add    $0x30,%esp
  802e3e:	5b                   	pop    %ebx
  802e3f:	5e                   	pop    %esi
  802e40:	5d                   	pop    %ebp
  802e41:	c3                   	ret    

00802e42 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802e42:	55                   	push   %ebp
  802e43:	89 e5                	mov    %esp,%ebp
  802e45:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  802e52:	89 04 24             	mov    %eax,(%esp)
  802e55:	e8 b0 fe ff ff       	call   802d0a <fd_lookup>
  802e5a:	85 c0                	test   %eax,%eax
  802e5c:	78 13                	js     802e71 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  802e5e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802e65:	00 
  802e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e69:	89 04 24             	mov    %eax,(%esp)
  802e6c:	e8 49 ff ff ff       	call   802dba <fd_close>
}
  802e71:	c9                   	leave  
  802e72:	c3                   	ret    

00802e73 <close_all>:

void
close_all(void)
{
  802e73:	55                   	push   %ebp
  802e74:	89 e5                	mov    %esp,%ebp
  802e76:	53                   	push   %ebx
  802e77:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802e7a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802e7f:	89 1c 24             	mov    %ebx,(%esp)
  802e82:	e8 bb ff ff ff       	call   802e42 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802e87:	43                   	inc    %ebx
  802e88:	83 fb 20             	cmp    $0x20,%ebx
  802e8b:	75 f2                	jne    802e7f <close_all+0xc>
		close(i);
}
  802e8d:	83 c4 14             	add    $0x14,%esp
  802e90:	5b                   	pop    %ebx
  802e91:	5d                   	pop    %ebp
  802e92:	c3                   	ret    

00802e93 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802e93:	55                   	push   %ebp
  802e94:	89 e5                	mov    %esp,%ebp
  802e96:	57                   	push   %edi
  802e97:	56                   	push   %esi
  802e98:	53                   	push   %ebx
  802e99:	83 ec 4c             	sub    $0x4c,%esp
  802e9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802e9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802ea2:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  802ea9:	89 04 24             	mov    %eax,(%esp)
  802eac:	e8 59 fe ff ff       	call   802d0a <fd_lookup>
  802eb1:	89 c3                	mov    %eax,%ebx
  802eb3:	85 c0                	test   %eax,%eax
  802eb5:	0f 88 e1 00 00 00    	js     802f9c <dup+0x109>
		return r;
	close(newfdnum);
  802ebb:	89 3c 24             	mov    %edi,(%esp)
  802ebe:	e8 7f ff ff ff       	call   802e42 <close>

	newfd = INDEX2FD(newfdnum);
  802ec3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  802ec9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  802ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ecf:	89 04 24             	mov    %eax,(%esp)
  802ed2:	e8 c5 fd ff ff       	call   802c9c <fd2data>
  802ed7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802ed9:	89 34 24             	mov    %esi,(%esp)
  802edc:	e8 bb fd ff ff       	call   802c9c <fd2data>
  802ee1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802ee4:	89 d8                	mov    %ebx,%eax
  802ee6:	c1 e8 16             	shr    $0x16,%eax
  802ee9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802ef0:	a8 01                	test   $0x1,%al
  802ef2:	74 46                	je     802f3a <dup+0xa7>
  802ef4:	89 d8                	mov    %ebx,%eax
  802ef6:	c1 e8 0c             	shr    $0xc,%eax
  802ef9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802f00:	f6 c2 01             	test   $0x1,%dl
  802f03:	74 35                	je     802f3a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802f05:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802f0c:	25 07 0e 00 00       	and    $0xe07,%eax
  802f11:	89 44 24 10          	mov    %eax,0x10(%esp)
  802f15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802f18:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802f1c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802f23:	00 
  802f24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802f28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f2f:	e8 b5 f9 ff ff       	call   8028e9 <sys_page_map>
  802f34:	89 c3                	mov    %eax,%ebx
  802f36:	85 c0                	test   %eax,%eax
  802f38:	78 3b                	js     802f75 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802f3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f3d:	89 c2                	mov    %eax,%edx
  802f3f:	c1 ea 0c             	shr    $0xc,%edx
  802f42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802f49:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802f4f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802f53:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802f57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802f5e:	00 
  802f5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f6a:	e8 7a f9 ff ff       	call   8028e9 <sys_page_map>
  802f6f:	89 c3                	mov    %eax,%ebx
  802f71:	85 c0                	test   %eax,%eax
  802f73:	79 25                	jns    802f9a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802f75:	89 74 24 04          	mov    %esi,0x4(%esp)
  802f79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f80:	e8 b7 f9 ff ff       	call   80293c <sys_page_unmap>
	sys_page_unmap(0, nva);
  802f85:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802f88:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f93:	e8 a4 f9 ff ff       	call   80293c <sys_page_unmap>
	return r;
  802f98:	eb 02                	jmp    802f9c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  802f9a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802f9c:	89 d8                	mov    %ebx,%eax
  802f9e:	83 c4 4c             	add    $0x4c,%esp
  802fa1:	5b                   	pop    %ebx
  802fa2:	5e                   	pop    %esi
  802fa3:	5f                   	pop    %edi
  802fa4:	5d                   	pop    %ebp
  802fa5:	c3                   	ret    

00802fa6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802fa6:	55                   	push   %ebp
  802fa7:	89 e5                	mov    %esp,%ebp
  802fa9:	53                   	push   %ebx
  802faa:	83 ec 24             	sub    $0x24,%esp
  802fad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802fb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fb7:	89 1c 24             	mov    %ebx,(%esp)
  802fba:	e8 4b fd ff ff       	call   802d0a <fd_lookup>
  802fbf:	85 c0                	test   %eax,%eax
  802fc1:	78 6d                	js     803030 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802fc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fcd:	8b 00                	mov    (%eax),%eax
  802fcf:	89 04 24             	mov    %eax,(%esp)
  802fd2:	e8 89 fd ff ff       	call   802d60 <dev_lookup>
  802fd7:	85 c0                	test   %eax,%eax
  802fd9:	78 55                	js     803030 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802fdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fde:	8b 50 08             	mov    0x8(%eax),%edx
  802fe1:	83 e2 03             	and    $0x3,%edx
  802fe4:	83 fa 01             	cmp    $0x1,%edx
  802fe7:	75 23                	jne    80300c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802fe9:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802fee:	8b 40 48             	mov    0x48(%eax),%eax
  802ff1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ff9:	c7 04 24 28 46 80 00 	movl   $0x804628,(%esp)
  803000:	e8 f3 ee ff ff       	call   801ef8 <cprintf>
		return -E_INVAL;
  803005:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80300a:	eb 24                	jmp    803030 <read+0x8a>
	}
	if (!dev->dev_read)
  80300c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80300f:	8b 52 08             	mov    0x8(%edx),%edx
  803012:	85 d2                	test   %edx,%edx
  803014:	74 15                	je     80302b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  803016:	8b 4d 10             	mov    0x10(%ebp),%ecx
  803019:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80301d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803020:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803024:	89 04 24             	mov    %eax,(%esp)
  803027:	ff d2                	call   *%edx
  803029:	eb 05                	jmp    803030 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80302b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  803030:	83 c4 24             	add    $0x24,%esp
  803033:	5b                   	pop    %ebx
  803034:	5d                   	pop    %ebp
  803035:	c3                   	ret    

00803036 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  803036:	55                   	push   %ebp
  803037:	89 e5                	mov    %esp,%ebp
  803039:	57                   	push   %edi
  80303a:	56                   	push   %esi
  80303b:	53                   	push   %ebx
  80303c:	83 ec 1c             	sub    $0x1c,%esp
  80303f:	8b 7d 08             	mov    0x8(%ebp),%edi
  803042:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803045:	bb 00 00 00 00       	mov    $0x0,%ebx
  80304a:	eb 23                	jmp    80306f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80304c:	89 f0                	mov    %esi,%eax
  80304e:	29 d8                	sub    %ebx,%eax
  803050:	89 44 24 08          	mov    %eax,0x8(%esp)
  803054:	8b 45 0c             	mov    0xc(%ebp),%eax
  803057:	01 d8                	add    %ebx,%eax
  803059:	89 44 24 04          	mov    %eax,0x4(%esp)
  80305d:	89 3c 24             	mov    %edi,(%esp)
  803060:	e8 41 ff ff ff       	call   802fa6 <read>
		if (m < 0)
  803065:	85 c0                	test   %eax,%eax
  803067:	78 10                	js     803079 <readn+0x43>
			return m;
		if (m == 0)
  803069:	85 c0                	test   %eax,%eax
  80306b:	74 0a                	je     803077 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80306d:	01 c3                	add    %eax,%ebx
  80306f:	39 f3                	cmp    %esi,%ebx
  803071:	72 d9                	jb     80304c <readn+0x16>
  803073:	89 d8                	mov    %ebx,%eax
  803075:	eb 02                	jmp    803079 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  803077:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  803079:	83 c4 1c             	add    $0x1c,%esp
  80307c:	5b                   	pop    %ebx
  80307d:	5e                   	pop    %esi
  80307e:	5f                   	pop    %edi
  80307f:	5d                   	pop    %ebp
  803080:	c3                   	ret    

00803081 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  803081:	55                   	push   %ebp
  803082:	89 e5                	mov    %esp,%ebp
  803084:	53                   	push   %ebx
  803085:	83 ec 24             	sub    $0x24,%esp
  803088:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80308b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80308e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803092:	89 1c 24             	mov    %ebx,(%esp)
  803095:	e8 70 fc ff ff       	call   802d0a <fd_lookup>
  80309a:	85 c0                	test   %eax,%eax
  80309c:	78 68                	js     803106 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80309e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030a8:	8b 00                	mov    (%eax),%eax
  8030aa:	89 04 24             	mov    %eax,(%esp)
  8030ad:	e8 ae fc ff ff       	call   802d60 <dev_lookup>
  8030b2:	85 c0                	test   %eax,%eax
  8030b4:	78 50                	js     803106 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8030b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8030bd:	75 23                	jne    8030e2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8030bf:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8030c4:	8b 40 48             	mov    0x48(%eax),%eax
  8030c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030cf:	c7 04 24 44 46 80 00 	movl   $0x804644,(%esp)
  8030d6:	e8 1d ee ff ff       	call   801ef8 <cprintf>
		return -E_INVAL;
  8030db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8030e0:	eb 24                	jmp    803106 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8030e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8030e8:	85 d2                	test   %edx,%edx
  8030ea:	74 15                	je     803101 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8030ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8030ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8030f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8030fa:	89 04 24             	mov    %eax,(%esp)
  8030fd:	ff d2                	call   *%edx
  8030ff:	eb 05                	jmp    803106 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  803101:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  803106:	83 c4 24             	add    $0x24,%esp
  803109:	5b                   	pop    %ebx
  80310a:	5d                   	pop    %ebp
  80310b:	c3                   	ret    

0080310c <seek>:

int
seek(int fdnum, off_t offset)
{
  80310c:	55                   	push   %ebp
  80310d:	89 e5                	mov    %esp,%ebp
  80310f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803112:	8d 45 fc             	lea    -0x4(%ebp),%eax
  803115:	89 44 24 04          	mov    %eax,0x4(%esp)
  803119:	8b 45 08             	mov    0x8(%ebp),%eax
  80311c:	89 04 24             	mov    %eax,(%esp)
  80311f:	e8 e6 fb ff ff       	call   802d0a <fd_lookup>
  803124:	85 c0                	test   %eax,%eax
  803126:	78 0e                	js     803136 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  803128:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80312b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80312e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  803131:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803136:	c9                   	leave  
  803137:	c3                   	ret    

00803138 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  803138:	55                   	push   %ebp
  803139:	89 e5                	mov    %esp,%ebp
  80313b:	53                   	push   %ebx
  80313c:	83 ec 24             	sub    $0x24,%esp
  80313f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803142:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803145:	89 44 24 04          	mov    %eax,0x4(%esp)
  803149:	89 1c 24             	mov    %ebx,(%esp)
  80314c:	e8 b9 fb ff ff       	call   802d0a <fd_lookup>
  803151:	85 c0                	test   %eax,%eax
  803153:	78 61                	js     8031b6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803155:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80315c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80315f:	8b 00                	mov    (%eax),%eax
  803161:	89 04 24             	mov    %eax,(%esp)
  803164:	e8 f7 fb ff ff       	call   802d60 <dev_lookup>
  803169:	85 c0                	test   %eax,%eax
  80316b:	78 49                	js     8031b6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80316d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803170:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803174:	75 23                	jne    803199 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  803176:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80317b:	8b 40 48             	mov    0x48(%eax),%eax
  80317e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803182:	89 44 24 04          	mov    %eax,0x4(%esp)
  803186:	c7 04 24 04 46 80 00 	movl   $0x804604,(%esp)
  80318d:	e8 66 ed ff ff       	call   801ef8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  803192:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803197:	eb 1d                	jmp    8031b6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  803199:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80319c:	8b 52 18             	mov    0x18(%edx),%edx
  80319f:	85 d2                	test   %edx,%edx
  8031a1:	74 0e                	je     8031b1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8031a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8031a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8031aa:	89 04 24             	mov    %eax,(%esp)
  8031ad:	ff d2                	call   *%edx
  8031af:	eb 05                	jmp    8031b6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8031b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8031b6:	83 c4 24             	add    $0x24,%esp
  8031b9:	5b                   	pop    %ebx
  8031ba:	5d                   	pop    %ebp
  8031bb:	c3                   	ret    

008031bc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8031bc:	55                   	push   %ebp
  8031bd:	89 e5                	mov    %esp,%ebp
  8031bf:	53                   	push   %ebx
  8031c0:	83 ec 24             	sub    $0x24,%esp
  8031c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8031c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8031d0:	89 04 24             	mov    %eax,(%esp)
  8031d3:	e8 32 fb ff ff       	call   802d0a <fd_lookup>
  8031d8:	85 c0                	test   %eax,%eax
  8031da:	78 52                	js     80322e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8031dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031e6:	8b 00                	mov    (%eax),%eax
  8031e8:	89 04 24             	mov    %eax,(%esp)
  8031eb:	e8 70 fb ff ff       	call   802d60 <dev_lookup>
  8031f0:	85 c0                	test   %eax,%eax
  8031f2:	78 3a                	js     80322e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8031f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031f7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8031fb:	74 2c                	je     803229 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8031fd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  803200:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  803207:	00 00 00 
	stat->st_isdir = 0;
  80320a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803211:	00 00 00 
	stat->st_dev = dev;
  803214:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80321a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80321e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803221:	89 14 24             	mov    %edx,(%esp)
  803224:	ff 50 14             	call   *0x14(%eax)
  803227:	eb 05                	jmp    80322e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  803229:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80322e:	83 c4 24             	add    $0x24,%esp
  803231:	5b                   	pop    %ebx
  803232:	5d                   	pop    %ebp
  803233:	c3                   	ret    

00803234 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  803234:	55                   	push   %ebp
  803235:	89 e5                	mov    %esp,%ebp
  803237:	56                   	push   %esi
  803238:	53                   	push   %ebx
  803239:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80323c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803243:	00 
  803244:	8b 45 08             	mov    0x8(%ebp),%eax
  803247:	89 04 24             	mov    %eax,(%esp)
  80324a:	e8 fe 01 00 00       	call   80344d <open>
  80324f:	89 c3                	mov    %eax,%ebx
  803251:	85 c0                	test   %eax,%eax
  803253:	78 1b                	js     803270 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  803255:	8b 45 0c             	mov    0xc(%ebp),%eax
  803258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80325c:	89 1c 24             	mov    %ebx,(%esp)
  80325f:	e8 58 ff ff ff       	call   8031bc <fstat>
  803264:	89 c6                	mov    %eax,%esi
	close(fd);
  803266:	89 1c 24             	mov    %ebx,(%esp)
  803269:	e8 d4 fb ff ff       	call   802e42 <close>
	return r;
  80326e:	89 f3                	mov    %esi,%ebx
}
  803270:	89 d8                	mov    %ebx,%eax
  803272:	83 c4 10             	add    $0x10,%esp
  803275:	5b                   	pop    %ebx
  803276:	5e                   	pop    %esi
  803277:	5d                   	pop    %ebp
  803278:	c3                   	ret    
  803279:	00 00                	add    %al,(%eax)
	...

0080327c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80327c:	55                   	push   %ebp
  80327d:	89 e5                	mov    %esp,%ebp
  80327f:	56                   	push   %esi
  803280:	53                   	push   %ebx
  803281:	83 ec 10             	sub    $0x10,%esp
  803284:	89 c3                	mov    %eax,%ebx
  803286:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  803288:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  80328f:	75 11                	jne    8032a2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  803291:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  803298:	e8 aa f9 ff ff       	call   802c47 <ipc_find_env>
  80329d:	a3 00 a0 80 00       	mov    %eax,0x80a000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8032a2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8032a9:	00 
  8032aa:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  8032b1:	00 
  8032b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8032b6:	a1 00 a0 80 00       	mov    0x80a000,%eax
  8032bb:	89 04 24             	mov    %eax,(%esp)
  8032be:	e8 1a f9 ff ff       	call   802bdd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8032c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8032ca:	00 
  8032cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8032d6:	e8 99 f8 ff ff       	call   802b74 <ipc_recv>
}
  8032db:	83 c4 10             	add    $0x10,%esp
  8032de:	5b                   	pop    %ebx
  8032df:	5e                   	pop    %esi
  8032e0:	5d                   	pop    %ebp
  8032e1:	c3                   	ret    

008032e2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8032e2:	55                   	push   %ebp
  8032e3:	89 e5                	mov    %esp,%ebp
  8032e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8032e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8032eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8032ee:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  8032f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032f6:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8032fb:	ba 00 00 00 00       	mov    $0x0,%edx
  803300:	b8 02 00 00 00       	mov    $0x2,%eax
  803305:	e8 72 ff ff ff       	call   80327c <fsipc>
}
  80330a:	c9                   	leave  
  80330b:	c3                   	ret    

0080330c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80330c:	55                   	push   %ebp
  80330d:	89 e5                	mov    %esp,%ebp
  80330f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803312:	8b 45 08             	mov    0x8(%ebp),%eax
  803315:	8b 40 0c             	mov    0xc(%eax),%eax
  803318:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  80331d:	ba 00 00 00 00       	mov    $0x0,%edx
  803322:	b8 06 00 00 00       	mov    $0x6,%eax
  803327:	e8 50 ff ff ff       	call   80327c <fsipc>
}
  80332c:	c9                   	leave  
  80332d:	c3                   	ret    

0080332e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80332e:	55                   	push   %ebp
  80332f:	89 e5                	mov    %esp,%ebp
  803331:	53                   	push   %ebx
  803332:	83 ec 14             	sub    $0x14,%esp
  803335:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803338:	8b 45 08             	mov    0x8(%ebp),%eax
  80333b:	8b 40 0c             	mov    0xc(%eax),%eax
  80333e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803343:	ba 00 00 00 00       	mov    $0x0,%edx
  803348:	b8 05 00 00 00       	mov    $0x5,%eax
  80334d:	e8 2a ff ff ff       	call   80327c <fsipc>
  803352:	85 c0                	test   %eax,%eax
  803354:	78 2b                	js     803381 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803356:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  80335d:	00 
  80335e:	89 1c 24             	mov    %ebx,(%esp)
  803361:	e8 3d f1 ff ff       	call   8024a3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803366:	a1 80 b0 80 00       	mov    0x80b080,%eax
  80336b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803371:	a1 84 b0 80 00       	mov    0x80b084,%eax
  803376:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80337c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803381:	83 c4 14             	add    $0x14,%esp
  803384:	5b                   	pop    %ebx
  803385:	5d                   	pop    %ebp
  803386:	c3                   	ret    

00803387 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803387:	55                   	push   %ebp
  803388:	89 e5                	mov    %esp,%ebp
  80338a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80338d:	c7 44 24 08 74 46 80 	movl   $0x804674,0x8(%esp)
  803394:	00 
  803395:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  80339c:	00 
  80339d:	c7 04 24 92 46 80 00 	movl   $0x804692,(%esp)
  8033a4:	e8 57 ea ff ff       	call   801e00 <_panic>

008033a9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8033a9:	55                   	push   %ebp
  8033aa:	89 e5                	mov    %esp,%ebp
  8033ac:	56                   	push   %esi
  8033ad:	53                   	push   %ebx
  8033ae:	83 ec 10             	sub    $0x10,%esp
  8033b1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8033b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8033b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8033ba:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  8033bf:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8033c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8033ca:	b8 03 00 00 00       	mov    $0x3,%eax
  8033cf:	e8 a8 fe ff ff       	call   80327c <fsipc>
  8033d4:	89 c3                	mov    %eax,%ebx
  8033d6:	85 c0                	test   %eax,%eax
  8033d8:	78 6a                	js     803444 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8033da:	39 c6                	cmp    %eax,%esi
  8033dc:	73 24                	jae    803402 <devfile_read+0x59>
  8033de:	c7 44 24 0c 9d 46 80 	movl   $0x80469d,0xc(%esp)
  8033e5:	00 
  8033e6:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  8033ed:	00 
  8033ee:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8033f5:	00 
  8033f6:	c7 04 24 92 46 80 00 	movl   $0x804692,(%esp)
  8033fd:	e8 fe e9 ff ff       	call   801e00 <_panic>
	assert(r <= PGSIZE);
  803402:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803407:	7e 24                	jle    80342d <devfile_read+0x84>
  803409:	c7 44 24 0c a4 46 80 	movl   $0x8046a4,0xc(%esp)
  803410:	00 
  803411:	c7 44 24 08 dd 3c 80 	movl   $0x803cdd,0x8(%esp)
  803418:	00 
  803419:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  803420:	00 
  803421:	c7 04 24 92 46 80 00 	movl   $0x804692,(%esp)
  803428:	e8 d3 e9 ff ff       	call   801e00 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80342d:	89 44 24 08          	mov    %eax,0x8(%esp)
  803431:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  803438:	00 
  803439:	8b 45 0c             	mov    0xc(%ebp),%eax
  80343c:	89 04 24             	mov    %eax,(%esp)
  80343f:	e8 d8 f1 ff ff       	call   80261c <memmove>
	return r;
}
  803444:	89 d8                	mov    %ebx,%eax
  803446:	83 c4 10             	add    $0x10,%esp
  803449:	5b                   	pop    %ebx
  80344a:	5e                   	pop    %esi
  80344b:	5d                   	pop    %ebp
  80344c:	c3                   	ret    

0080344d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80344d:	55                   	push   %ebp
  80344e:	89 e5                	mov    %esp,%ebp
  803450:	56                   	push   %esi
  803451:	53                   	push   %ebx
  803452:	83 ec 20             	sub    $0x20,%esp
  803455:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  803458:	89 34 24             	mov    %esi,(%esp)
  80345b:	e8 10 f0 ff ff       	call   802470 <strlen>
  803460:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803465:	7f 60                	jg     8034c7 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  803467:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80346a:	89 04 24             	mov    %eax,(%esp)
  80346d:	e8 45 f8 ff ff       	call   802cb7 <fd_alloc>
  803472:	89 c3                	mov    %eax,%ebx
  803474:	85 c0                	test   %eax,%eax
  803476:	78 54                	js     8034cc <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  803478:	89 74 24 04          	mov    %esi,0x4(%esp)
  80347c:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  803483:	e8 1b f0 ff ff       	call   8024a3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  803488:	8b 45 0c             	mov    0xc(%ebp),%eax
  80348b:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803490:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803493:	b8 01 00 00 00       	mov    $0x1,%eax
  803498:	e8 df fd ff ff       	call   80327c <fsipc>
  80349d:	89 c3                	mov    %eax,%ebx
  80349f:	85 c0                	test   %eax,%eax
  8034a1:	79 15                	jns    8034b8 <open+0x6b>
		fd_close(fd, 0);
  8034a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8034aa:	00 
  8034ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034ae:	89 04 24             	mov    %eax,(%esp)
  8034b1:	e8 04 f9 ff ff       	call   802dba <fd_close>
		return r;
  8034b6:	eb 14                	jmp    8034cc <open+0x7f>
	}

	return fd2num(fd);
  8034b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034bb:	89 04 24             	mov    %eax,(%esp)
  8034be:	e8 c9 f7 ff ff       	call   802c8c <fd2num>
  8034c3:	89 c3                	mov    %eax,%ebx
  8034c5:	eb 05                	jmp    8034cc <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8034c7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8034cc:	89 d8                	mov    %ebx,%eax
  8034ce:	83 c4 20             	add    $0x20,%esp
  8034d1:	5b                   	pop    %ebx
  8034d2:	5e                   	pop    %esi
  8034d3:	5d                   	pop    %ebp
  8034d4:	c3                   	ret    

008034d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8034d5:	55                   	push   %ebp
  8034d6:	89 e5                	mov    %esp,%ebp
  8034d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8034db:	ba 00 00 00 00       	mov    $0x0,%edx
  8034e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8034e5:	e8 92 fd ff ff       	call   80327c <fsipc>
}
  8034ea:	c9                   	leave  
  8034eb:	c3                   	ret    

008034ec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8034ec:	55                   	push   %ebp
  8034ed:	89 e5                	mov    %esp,%ebp
  8034ef:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8034f2:	89 c2                	mov    %eax,%edx
  8034f4:	c1 ea 16             	shr    $0x16,%edx
  8034f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8034fe:	f6 c2 01             	test   $0x1,%dl
  803501:	74 1e                	je     803521 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  803503:	c1 e8 0c             	shr    $0xc,%eax
  803506:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80350d:	a8 01                	test   $0x1,%al
  80350f:	74 17                	je     803528 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803511:	c1 e8 0c             	shr    $0xc,%eax
  803514:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80351b:	ef 
  80351c:	0f b7 c0             	movzwl %ax,%eax
  80351f:	eb 0c                	jmp    80352d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  803521:	b8 00 00 00 00       	mov    $0x0,%eax
  803526:	eb 05                	jmp    80352d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  803528:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80352d:	5d                   	pop    %ebp
  80352e:	c3                   	ret    
	...

00803530 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803530:	55                   	push   %ebp
  803531:	89 e5                	mov    %esp,%ebp
  803533:	56                   	push   %esi
  803534:	53                   	push   %ebx
  803535:	83 ec 10             	sub    $0x10,%esp
  803538:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80353b:	8b 45 08             	mov    0x8(%ebp),%eax
  80353e:	89 04 24             	mov    %eax,(%esp)
  803541:	e8 56 f7 ff ff       	call   802c9c <fd2data>
  803546:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  803548:	c7 44 24 04 b0 46 80 	movl   $0x8046b0,0x4(%esp)
  80354f:	00 
  803550:	89 34 24             	mov    %esi,(%esp)
  803553:	e8 4b ef ff ff       	call   8024a3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803558:	8b 43 04             	mov    0x4(%ebx),%eax
  80355b:	2b 03                	sub    (%ebx),%eax
  80355d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  803563:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80356a:	00 00 00 
	stat->st_dev = &devpipe;
  80356d:	c7 86 88 00 00 00 80 	movl   $0x809080,0x88(%esi)
  803574:	90 80 00 
	return 0;
}
  803577:	b8 00 00 00 00       	mov    $0x0,%eax
  80357c:	83 c4 10             	add    $0x10,%esp
  80357f:	5b                   	pop    %ebx
  803580:	5e                   	pop    %esi
  803581:	5d                   	pop    %ebp
  803582:	c3                   	ret    

00803583 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803583:	55                   	push   %ebp
  803584:	89 e5                	mov    %esp,%ebp
  803586:	53                   	push   %ebx
  803587:	83 ec 14             	sub    $0x14,%esp
  80358a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80358d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803591:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803598:	e8 9f f3 ff ff       	call   80293c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80359d:	89 1c 24             	mov    %ebx,(%esp)
  8035a0:	e8 f7 f6 ff ff       	call   802c9c <fd2data>
  8035a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035b0:	e8 87 f3 ff ff       	call   80293c <sys_page_unmap>
}
  8035b5:	83 c4 14             	add    $0x14,%esp
  8035b8:	5b                   	pop    %ebx
  8035b9:	5d                   	pop    %ebp
  8035ba:	c3                   	ret    

008035bb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8035bb:	55                   	push   %ebp
  8035bc:	89 e5                	mov    %esp,%ebp
  8035be:	57                   	push   %edi
  8035bf:	56                   	push   %esi
  8035c0:	53                   	push   %ebx
  8035c1:	83 ec 2c             	sub    $0x2c,%esp
  8035c4:	89 c7                	mov    %eax,%edi
  8035c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8035c9:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8035ce:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8035d1:	89 3c 24             	mov    %edi,(%esp)
  8035d4:	e8 13 ff ff ff       	call   8034ec <pageref>
  8035d9:	89 c6                	mov    %eax,%esi
  8035db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8035de:	89 04 24             	mov    %eax,(%esp)
  8035e1:	e8 06 ff ff ff       	call   8034ec <pageref>
  8035e6:	39 c6                	cmp    %eax,%esi
  8035e8:	0f 94 c0             	sete   %al
  8035eb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8035ee:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8035f4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8035f7:	39 cb                	cmp    %ecx,%ebx
  8035f9:	75 08                	jne    803603 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8035fb:	83 c4 2c             	add    $0x2c,%esp
  8035fe:	5b                   	pop    %ebx
  8035ff:	5e                   	pop    %esi
  803600:	5f                   	pop    %edi
  803601:	5d                   	pop    %ebp
  803602:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  803603:	83 f8 01             	cmp    $0x1,%eax
  803606:	75 c1                	jne    8035c9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803608:	8b 42 58             	mov    0x58(%edx),%eax
  80360b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  803612:	00 
  803613:	89 44 24 08          	mov    %eax,0x8(%esp)
  803617:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80361b:	c7 04 24 b7 46 80 00 	movl   $0x8046b7,(%esp)
  803622:	e8 d1 e8 ff ff       	call   801ef8 <cprintf>
  803627:	eb a0                	jmp    8035c9 <_pipeisclosed+0xe>

00803629 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803629:	55                   	push   %ebp
  80362a:	89 e5                	mov    %esp,%ebp
  80362c:	57                   	push   %edi
  80362d:	56                   	push   %esi
  80362e:	53                   	push   %ebx
  80362f:	83 ec 1c             	sub    $0x1c,%esp
  803632:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803635:	89 34 24             	mov    %esi,(%esp)
  803638:	e8 5f f6 ff ff       	call   802c9c <fd2data>
  80363d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80363f:	bf 00 00 00 00       	mov    $0x0,%edi
  803644:	eb 3c                	jmp    803682 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803646:	89 da                	mov    %ebx,%edx
  803648:	89 f0                	mov    %esi,%eax
  80364a:	e8 6c ff ff ff       	call   8035bb <_pipeisclosed>
  80364f:	85 c0                	test   %eax,%eax
  803651:	75 38                	jne    80368b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803653:	e8 1e f2 ff ff       	call   802876 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803658:	8b 43 04             	mov    0x4(%ebx),%eax
  80365b:	8b 13                	mov    (%ebx),%edx
  80365d:	83 c2 20             	add    $0x20,%edx
  803660:	39 d0                	cmp    %edx,%eax
  803662:	73 e2                	jae    803646 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803664:	8b 55 0c             	mov    0xc(%ebp),%edx
  803667:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80366a:	89 c2                	mov    %eax,%edx
  80366c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  803672:	79 05                	jns    803679 <devpipe_write+0x50>
  803674:	4a                   	dec    %edx
  803675:	83 ca e0             	or     $0xffffffe0,%edx
  803678:	42                   	inc    %edx
  803679:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80367d:	40                   	inc    %eax
  80367e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803681:	47                   	inc    %edi
  803682:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803685:	75 d1                	jne    803658 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803687:	89 f8                	mov    %edi,%eax
  803689:	eb 05                	jmp    803690 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80368b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803690:	83 c4 1c             	add    $0x1c,%esp
  803693:	5b                   	pop    %ebx
  803694:	5e                   	pop    %esi
  803695:	5f                   	pop    %edi
  803696:	5d                   	pop    %ebp
  803697:	c3                   	ret    

00803698 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803698:	55                   	push   %ebp
  803699:	89 e5                	mov    %esp,%ebp
  80369b:	57                   	push   %edi
  80369c:	56                   	push   %esi
  80369d:	53                   	push   %ebx
  80369e:	83 ec 1c             	sub    $0x1c,%esp
  8036a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8036a4:	89 3c 24             	mov    %edi,(%esp)
  8036a7:	e8 f0 f5 ff ff       	call   802c9c <fd2data>
  8036ac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8036ae:	be 00 00 00 00       	mov    $0x0,%esi
  8036b3:	eb 3a                	jmp    8036ef <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8036b5:	85 f6                	test   %esi,%esi
  8036b7:	74 04                	je     8036bd <devpipe_read+0x25>
				return i;
  8036b9:	89 f0                	mov    %esi,%eax
  8036bb:	eb 40                	jmp    8036fd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8036bd:	89 da                	mov    %ebx,%edx
  8036bf:	89 f8                	mov    %edi,%eax
  8036c1:	e8 f5 fe ff ff       	call   8035bb <_pipeisclosed>
  8036c6:	85 c0                	test   %eax,%eax
  8036c8:	75 2e                	jne    8036f8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8036ca:	e8 a7 f1 ff ff       	call   802876 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8036cf:	8b 03                	mov    (%ebx),%eax
  8036d1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8036d4:	74 df                	je     8036b5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8036d6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8036db:	79 05                	jns    8036e2 <devpipe_read+0x4a>
  8036dd:	48                   	dec    %eax
  8036de:	83 c8 e0             	or     $0xffffffe0,%eax
  8036e1:	40                   	inc    %eax
  8036e2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8036e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8036e9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8036ec:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8036ee:	46                   	inc    %esi
  8036ef:	3b 75 10             	cmp    0x10(%ebp),%esi
  8036f2:	75 db                	jne    8036cf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8036f4:	89 f0                	mov    %esi,%eax
  8036f6:	eb 05                	jmp    8036fd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8036f8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8036fd:	83 c4 1c             	add    $0x1c,%esp
  803700:	5b                   	pop    %ebx
  803701:	5e                   	pop    %esi
  803702:	5f                   	pop    %edi
  803703:	5d                   	pop    %ebp
  803704:	c3                   	ret    

00803705 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803705:	55                   	push   %ebp
  803706:	89 e5                	mov    %esp,%ebp
  803708:	57                   	push   %edi
  803709:	56                   	push   %esi
  80370a:	53                   	push   %ebx
  80370b:	83 ec 3c             	sub    $0x3c,%esp
  80370e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803711:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803714:	89 04 24             	mov    %eax,(%esp)
  803717:	e8 9b f5 ff ff       	call   802cb7 <fd_alloc>
  80371c:	89 c3                	mov    %eax,%ebx
  80371e:	85 c0                	test   %eax,%eax
  803720:	0f 88 45 01 00 00    	js     80386b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803726:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80372d:	00 
  80372e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803731:	89 44 24 04          	mov    %eax,0x4(%esp)
  803735:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80373c:	e8 54 f1 ff ff       	call   802895 <sys_page_alloc>
  803741:	89 c3                	mov    %eax,%ebx
  803743:	85 c0                	test   %eax,%eax
  803745:	0f 88 20 01 00 00    	js     80386b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80374b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80374e:	89 04 24             	mov    %eax,(%esp)
  803751:	e8 61 f5 ff ff       	call   802cb7 <fd_alloc>
  803756:	89 c3                	mov    %eax,%ebx
  803758:	85 c0                	test   %eax,%eax
  80375a:	0f 88 f8 00 00 00    	js     803858 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803760:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803767:	00 
  803768:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80376b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80376f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803776:	e8 1a f1 ff ff       	call   802895 <sys_page_alloc>
  80377b:	89 c3                	mov    %eax,%ebx
  80377d:	85 c0                	test   %eax,%eax
  80377f:	0f 88 d3 00 00 00    	js     803858 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803785:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803788:	89 04 24             	mov    %eax,(%esp)
  80378b:	e8 0c f5 ff ff       	call   802c9c <fd2data>
  803790:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803792:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803799:	00 
  80379a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80379e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8037a5:	e8 eb f0 ff ff       	call   802895 <sys_page_alloc>
  8037aa:	89 c3                	mov    %eax,%ebx
  8037ac:	85 c0                	test   %eax,%eax
  8037ae:	0f 88 91 00 00 00    	js     803845 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8037b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8037b7:	89 04 24             	mov    %eax,(%esp)
  8037ba:	e8 dd f4 ff ff       	call   802c9c <fd2data>
  8037bf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8037c6:	00 
  8037c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8037cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8037d2:	00 
  8037d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8037d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8037de:	e8 06 f1 ff ff       	call   8028e9 <sys_page_map>
  8037e3:	89 c3                	mov    %eax,%ebx
  8037e5:	85 c0                	test   %eax,%eax
  8037e7:	78 4c                	js     803835 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8037e9:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8037ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037f2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8037f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8037fe:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803804:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803807:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803809:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80380c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803813:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803816:	89 04 24             	mov    %eax,(%esp)
  803819:	e8 6e f4 ff ff       	call   802c8c <fd2num>
  80381e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  803820:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803823:	89 04 24             	mov    %eax,(%esp)
  803826:	e8 61 f4 ff ff       	call   802c8c <fd2num>
  80382b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80382e:	bb 00 00 00 00       	mov    $0x0,%ebx
  803833:	eb 36                	jmp    80386b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  803835:	89 74 24 04          	mov    %esi,0x4(%esp)
  803839:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803840:	e8 f7 f0 ff ff       	call   80293c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  803845:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80384c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803853:	e8 e4 f0 ff ff       	call   80293c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  803858:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80385b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80385f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803866:	e8 d1 f0 ff ff       	call   80293c <sys_page_unmap>
    err:
	return r;
}
  80386b:	89 d8                	mov    %ebx,%eax
  80386d:	83 c4 3c             	add    $0x3c,%esp
  803870:	5b                   	pop    %ebx
  803871:	5e                   	pop    %esi
  803872:	5f                   	pop    %edi
  803873:	5d                   	pop    %ebp
  803874:	c3                   	ret    

00803875 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803875:	55                   	push   %ebp
  803876:	89 e5                	mov    %esp,%ebp
  803878:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80387b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80387e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803882:	8b 45 08             	mov    0x8(%ebp),%eax
  803885:	89 04 24             	mov    %eax,(%esp)
  803888:	e8 7d f4 ff ff       	call   802d0a <fd_lookup>
  80388d:	85 c0                	test   %eax,%eax
  80388f:	78 15                	js     8038a6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803891:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803894:	89 04 24             	mov    %eax,(%esp)
  803897:	e8 00 f4 ff ff       	call   802c9c <fd2data>
	return _pipeisclosed(fd, p);
  80389c:	89 c2                	mov    %eax,%edx
  80389e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038a1:	e8 15 fd ff ff       	call   8035bb <_pipeisclosed>
}
  8038a6:	c9                   	leave  
  8038a7:	c3                   	ret    

008038a8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8038a8:	55                   	push   %ebp
  8038a9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8038ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8038b0:	5d                   	pop    %ebp
  8038b1:	c3                   	ret    

008038b2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8038b2:	55                   	push   %ebp
  8038b3:	89 e5                	mov    %esp,%ebp
  8038b5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8038b8:	c7 44 24 04 cf 46 80 	movl   $0x8046cf,0x4(%esp)
  8038bf:	00 
  8038c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8038c3:	89 04 24             	mov    %eax,(%esp)
  8038c6:	e8 d8 eb ff ff       	call   8024a3 <strcpy>
	return 0;
}
  8038cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8038d0:	c9                   	leave  
  8038d1:	c3                   	ret    

008038d2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8038d2:	55                   	push   %ebp
  8038d3:	89 e5                	mov    %esp,%ebp
  8038d5:	57                   	push   %edi
  8038d6:	56                   	push   %esi
  8038d7:	53                   	push   %ebx
  8038d8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8038de:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8038e3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8038e9:	eb 30                	jmp    80391b <devcons_write+0x49>
		m = n - tot;
  8038eb:	8b 75 10             	mov    0x10(%ebp),%esi
  8038ee:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8038f0:	83 fe 7f             	cmp    $0x7f,%esi
  8038f3:	76 05                	jbe    8038fa <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8038f5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8038fa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8038fe:	03 45 0c             	add    0xc(%ebp),%eax
  803901:	89 44 24 04          	mov    %eax,0x4(%esp)
  803905:	89 3c 24             	mov    %edi,(%esp)
  803908:	e8 0f ed ff ff       	call   80261c <memmove>
		sys_cputs(buf, m);
  80390d:	89 74 24 04          	mov    %esi,0x4(%esp)
  803911:	89 3c 24             	mov    %edi,(%esp)
  803914:	e8 af ee ff ff       	call   8027c8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803919:	01 f3                	add    %esi,%ebx
  80391b:	89 d8                	mov    %ebx,%eax
  80391d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803920:	72 c9                	jb     8038eb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803922:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  803928:	5b                   	pop    %ebx
  803929:	5e                   	pop    %esi
  80392a:	5f                   	pop    %edi
  80392b:	5d                   	pop    %ebp
  80392c:	c3                   	ret    

0080392d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80392d:	55                   	push   %ebp
  80392e:	89 e5                	mov    %esp,%ebp
  803930:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  803933:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803937:	75 07                	jne    803940 <devcons_read+0x13>
  803939:	eb 25                	jmp    803960 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80393b:	e8 36 ef ff ff       	call   802876 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803940:	e8 a1 ee ff ff       	call   8027e6 <sys_cgetc>
  803945:	85 c0                	test   %eax,%eax
  803947:	74 f2                	je     80393b <devcons_read+0xe>
  803949:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80394b:	85 c0                	test   %eax,%eax
  80394d:	78 1d                	js     80396c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80394f:	83 f8 04             	cmp    $0x4,%eax
  803952:	74 13                	je     803967 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  803954:	8b 45 0c             	mov    0xc(%ebp),%eax
  803957:	88 10                	mov    %dl,(%eax)
	return 1;
  803959:	b8 01 00 00 00       	mov    $0x1,%eax
  80395e:	eb 0c                	jmp    80396c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  803960:	b8 00 00 00 00       	mov    $0x0,%eax
  803965:	eb 05                	jmp    80396c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803967:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80396c:	c9                   	leave  
  80396d:	c3                   	ret    

0080396e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80396e:	55                   	push   %ebp
  80396f:	89 e5                	mov    %esp,%ebp
  803971:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  803974:	8b 45 08             	mov    0x8(%ebp),%eax
  803977:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80397a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803981:	00 
  803982:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803985:	89 04 24             	mov    %eax,(%esp)
  803988:	e8 3b ee ff ff       	call   8027c8 <sys_cputs>
}
  80398d:	c9                   	leave  
  80398e:	c3                   	ret    

0080398f <getchar>:

int
getchar(void)
{
  80398f:	55                   	push   %ebp
  803990:	89 e5                	mov    %esp,%ebp
  803992:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803995:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80399c:	00 
  80399d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8039a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8039a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8039ab:	e8 f6 f5 ff ff       	call   802fa6 <read>
	if (r < 0)
  8039b0:	85 c0                	test   %eax,%eax
  8039b2:	78 0f                	js     8039c3 <getchar+0x34>
		return r;
	if (r < 1)
  8039b4:	85 c0                	test   %eax,%eax
  8039b6:	7e 06                	jle    8039be <getchar+0x2f>
		return -E_EOF;
	return c;
  8039b8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8039bc:	eb 05                	jmp    8039c3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8039be:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8039c3:	c9                   	leave  
  8039c4:	c3                   	ret    

008039c5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8039c5:	55                   	push   %ebp
  8039c6:	89 e5                	mov    %esp,%ebp
  8039c8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8039cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8039ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8039d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8039d5:	89 04 24             	mov    %eax,(%esp)
  8039d8:	e8 2d f3 ff ff       	call   802d0a <fd_lookup>
  8039dd:	85 c0                	test   %eax,%eax
  8039df:	78 11                	js     8039f2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8039e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039e4:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8039ea:	39 10                	cmp    %edx,(%eax)
  8039ec:	0f 94 c0             	sete   %al
  8039ef:	0f b6 c0             	movzbl %al,%eax
}
  8039f2:	c9                   	leave  
  8039f3:	c3                   	ret    

008039f4 <opencons>:

int
opencons(void)
{
  8039f4:	55                   	push   %ebp
  8039f5:	89 e5                	mov    %esp,%ebp
  8039f7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8039fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8039fd:	89 04 24             	mov    %eax,(%esp)
  803a00:	e8 b2 f2 ff ff       	call   802cb7 <fd_alloc>
  803a05:	85 c0                	test   %eax,%eax
  803a07:	78 3c                	js     803a45 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803a09:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803a10:	00 
  803a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  803a18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803a1f:	e8 71 ee ff ff       	call   802895 <sys_page_alloc>
  803a24:	85 c0                	test   %eax,%eax
  803a26:	78 1d                	js     803a45 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803a28:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a31:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a36:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803a3d:	89 04 24             	mov    %eax,(%esp)
  803a40:	e8 47 f2 ff ff       	call   802c8c <fd2num>
}
  803a45:	c9                   	leave  
  803a46:	c3                   	ret    
	...

00803a48 <__udivdi3>:
  803a48:	55                   	push   %ebp
  803a49:	57                   	push   %edi
  803a4a:	56                   	push   %esi
  803a4b:	83 ec 10             	sub    $0x10,%esp
  803a4e:	8b 74 24 20          	mov    0x20(%esp),%esi
  803a52:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  803a56:	89 74 24 04          	mov    %esi,0x4(%esp)
  803a5a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  803a5e:	89 cd                	mov    %ecx,%ebp
  803a60:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  803a64:	85 c0                	test   %eax,%eax
  803a66:	75 2c                	jne    803a94 <__udivdi3+0x4c>
  803a68:	39 f9                	cmp    %edi,%ecx
  803a6a:	77 68                	ja     803ad4 <__udivdi3+0x8c>
  803a6c:	85 c9                	test   %ecx,%ecx
  803a6e:	75 0b                	jne    803a7b <__udivdi3+0x33>
  803a70:	b8 01 00 00 00       	mov    $0x1,%eax
  803a75:	31 d2                	xor    %edx,%edx
  803a77:	f7 f1                	div    %ecx
  803a79:	89 c1                	mov    %eax,%ecx
  803a7b:	31 d2                	xor    %edx,%edx
  803a7d:	89 f8                	mov    %edi,%eax
  803a7f:	f7 f1                	div    %ecx
  803a81:	89 c7                	mov    %eax,%edi
  803a83:	89 f0                	mov    %esi,%eax
  803a85:	f7 f1                	div    %ecx
  803a87:	89 c6                	mov    %eax,%esi
  803a89:	89 f0                	mov    %esi,%eax
  803a8b:	89 fa                	mov    %edi,%edx
  803a8d:	83 c4 10             	add    $0x10,%esp
  803a90:	5e                   	pop    %esi
  803a91:	5f                   	pop    %edi
  803a92:	5d                   	pop    %ebp
  803a93:	c3                   	ret    
  803a94:	39 f8                	cmp    %edi,%eax
  803a96:	77 2c                	ja     803ac4 <__udivdi3+0x7c>
  803a98:	0f bd f0             	bsr    %eax,%esi
  803a9b:	83 f6 1f             	xor    $0x1f,%esi
  803a9e:	75 4c                	jne    803aec <__udivdi3+0xa4>
  803aa0:	39 f8                	cmp    %edi,%eax
  803aa2:	bf 00 00 00 00       	mov    $0x0,%edi
  803aa7:	72 0a                	jb     803ab3 <__udivdi3+0x6b>
  803aa9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803aad:	0f 87 ad 00 00 00    	ja     803b60 <__udivdi3+0x118>
  803ab3:	be 01 00 00 00       	mov    $0x1,%esi
  803ab8:	89 f0                	mov    %esi,%eax
  803aba:	89 fa                	mov    %edi,%edx
  803abc:	83 c4 10             	add    $0x10,%esp
  803abf:	5e                   	pop    %esi
  803ac0:	5f                   	pop    %edi
  803ac1:	5d                   	pop    %ebp
  803ac2:	c3                   	ret    
  803ac3:	90                   	nop
  803ac4:	31 ff                	xor    %edi,%edi
  803ac6:	31 f6                	xor    %esi,%esi
  803ac8:	89 f0                	mov    %esi,%eax
  803aca:	89 fa                	mov    %edi,%edx
  803acc:	83 c4 10             	add    $0x10,%esp
  803acf:	5e                   	pop    %esi
  803ad0:	5f                   	pop    %edi
  803ad1:	5d                   	pop    %ebp
  803ad2:	c3                   	ret    
  803ad3:	90                   	nop
  803ad4:	89 fa                	mov    %edi,%edx
  803ad6:	89 f0                	mov    %esi,%eax
  803ad8:	f7 f1                	div    %ecx
  803ada:	89 c6                	mov    %eax,%esi
  803adc:	31 ff                	xor    %edi,%edi
  803ade:	89 f0                	mov    %esi,%eax
  803ae0:	89 fa                	mov    %edi,%edx
  803ae2:	83 c4 10             	add    $0x10,%esp
  803ae5:	5e                   	pop    %esi
  803ae6:	5f                   	pop    %edi
  803ae7:	5d                   	pop    %ebp
  803ae8:	c3                   	ret    
  803ae9:	8d 76 00             	lea    0x0(%esi),%esi
  803aec:	89 f1                	mov    %esi,%ecx
  803aee:	d3 e0                	shl    %cl,%eax
  803af0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803af4:	b8 20 00 00 00       	mov    $0x20,%eax
  803af9:	29 f0                	sub    %esi,%eax
  803afb:	89 ea                	mov    %ebp,%edx
  803afd:	88 c1                	mov    %al,%cl
  803aff:	d3 ea                	shr    %cl,%edx
  803b01:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  803b05:	09 ca                	or     %ecx,%edx
  803b07:	89 54 24 08          	mov    %edx,0x8(%esp)
  803b0b:	89 f1                	mov    %esi,%ecx
  803b0d:	d3 e5                	shl    %cl,%ebp
  803b0f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  803b13:	89 fd                	mov    %edi,%ebp
  803b15:	88 c1                	mov    %al,%cl
  803b17:	d3 ed                	shr    %cl,%ebp
  803b19:	89 fa                	mov    %edi,%edx
  803b1b:	89 f1                	mov    %esi,%ecx
  803b1d:	d3 e2                	shl    %cl,%edx
  803b1f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803b23:	88 c1                	mov    %al,%cl
  803b25:	d3 ef                	shr    %cl,%edi
  803b27:	09 d7                	or     %edx,%edi
  803b29:	89 f8                	mov    %edi,%eax
  803b2b:	89 ea                	mov    %ebp,%edx
  803b2d:	f7 74 24 08          	divl   0x8(%esp)
  803b31:	89 d1                	mov    %edx,%ecx
  803b33:	89 c7                	mov    %eax,%edi
  803b35:	f7 64 24 0c          	mull   0xc(%esp)
  803b39:	39 d1                	cmp    %edx,%ecx
  803b3b:	72 17                	jb     803b54 <__udivdi3+0x10c>
  803b3d:	74 09                	je     803b48 <__udivdi3+0x100>
  803b3f:	89 fe                	mov    %edi,%esi
  803b41:	31 ff                	xor    %edi,%edi
  803b43:	e9 41 ff ff ff       	jmp    803a89 <__udivdi3+0x41>
  803b48:	8b 54 24 04          	mov    0x4(%esp),%edx
  803b4c:	89 f1                	mov    %esi,%ecx
  803b4e:	d3 e2                	shl    %cl,%edx
  803b50:	39 c2                	cmp    %eax,%edx
  803b52:	73 eb                	jae    803b3f <__udivdi3+0xf7>
  803b54:	8d 77 ff             	lea    -0x1(%edi),%esi
  803b57:	31 ff                	xor    %edi,%edi
  803b59:	e9 2b ff ff ff       	jmp    803a89 <__udivdi3+0x41>
  803b5e:	66 90                	xchg   %ax,%ax
  803b60:	31 f6                	xor    %esi,%esi
  803b62:	e9 22 ff ff ff       	jmp    803a89 <__udivdi3+0x41>
	...

00803b68 <__umoddi3>:
  803b68:	55                   	push   %ebp
  803b69:	57                   	push   %edi
  803b6a:	56                   	push   %esi
  803b6b:	83 ec 20             	sub    $0x20,%esp
  803b6e:	8b 44 24 30          	mov    0x30(%esp),%eax
  803b72:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  803b76:	89 44 24 14          	mov    %eax,0x14(%esp)
  803b7a:	8b 74 24 34          	mov    0x34(%esp),%esi
  803b7e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803b82:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  803b86:	89 c7                	mov    %eax,%edi
  803b88:	89 f2                	mov    %esi,%edx
  803b8a:	85 ed                	test   %ebp,%ebp
  803b8c:	75 16                	jne    803ba4 <__umoddi3+0x3c>
  803b8e:	39 f1                	cmp    %esi,%ecx
  803b90:	0f 86 a6 00 00 00    	jbe    803c3c <__umoddi3+0xd4>
  803b96:	f7 f1                	div    %ecx
  803b98:	89 d0                	mov    %edx,%eax
  803b9a:	31 d2                	xor    %edx,%edx
  803b9c:	83 c4 20             	add    $0x20,%esp
  803b9f:	5e                   	pop    %esi
  803ba0:	5f                   	pop    %edi
  803ba1:	5d                   	pop    %ebp
  803ba2:	c3                   	ret    
  803ba3:	90                   	nop
  803ba4:	39 f5                	cmp    %esi,%ebp
  803ba6:	0f 87 ac 00 00 00    	ja     803c58 <__umoddi3+0xf0>
  803bac:	0f bd c5             	bsr    %ebp,%eax
  803baf:	83 f0 1f             	xor    $0x1f,%eax
  803bb2:	89 44 24 10          	mov    %eax,0x10(%esp)
  803bb6:	0f 84 a8 00 00 00    	je     803c64 <__umoddi3+0xfc>
  803bbc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803bc0:	d3 e5                	shl    %cl,%ebp
  803bc2:	bf 20 00 00 00       	mov    $0x20,%edi
  803bc7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  803bcb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803bcf:	89 f9                	mov    %edi,%ecx
  803bd1:	d3 e8                	shr    %cl,%eax
  803bd3:	09 e8                	or     %ebp,%eax
  803bd5:	89 44 24 18          	mov    %eax,0x18(%esp)
  803bd9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803bdd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803be1:	d3 e0                	shl    %cl,%eax
  803be3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803be7:	89 f2                	mov    %esi,%edx
  803be9:	d3 e2                	shl    %cl,%edx
  803beb:	8b 44 24 14          	mov    0x14(%esp),%eax
  803bef:	d3 e0                	shl    %cl,%eax
  803bf1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  803bf5:	8b 44 24 14          	mov    0x14(%esp),%eax
  803bf9:	89 f9                	mov    %edi,%ecx
  803bfb:	d3 e8                	shr    %cl,%eax
  803bfd:	09 d0                	or     %edx,%eax
  803bff:	d3 ee                	shr    %cl,%esi
  803c01:	89 f2                	mov    %esi,%edx
  803c03:	f7 74 24 18          	divl   0x18(%esp)
  803c07:	89 d6                	mov    %edx,%esi
  803c09:	f7 64 24 0c          	mull   0xc(%esp)
  803c0d:	89 c5                	mov    %eax,%ebp
  803c0f:	89 d1                	mov    %edx,%ecx
  803c11:	39 d6                	cmp    %edx,%esi
  803c13:	72 67                	jb     803c7c <__umoddi3+0x114>
  803c15:	74 75                	je     803c8c <__umoddi3+0x124>
  803c17:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  803c1b:	29 e8                	sub    %ebp,%eax
  803c1d:	19 ce                	sbb    %ecx,%esi
  803c1f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803c23:	d3 e8                	shr    %cl,%eax
  803c25:	89 f2                	mov    %esi,%edx
  803c27:	89 f9                	mov    %edi,%ecx
  803c29:	d3 e2                	shl    %cl,%edx
  803c2b:	09 d0                	or     %edx,%eax
  803c2d:	89 f2                	mov    %esi,%edx
  803c2f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803c33:	d3 ea                	shr    %cl,%edx
  803c35:	83 c4 20             	add    $0x20,%esp
  803c38:	5e                   	pop    %esi
  803c39:	5f                   	pop    %edi
  803c3a:	5d                   	pop    %ebp
  803c3b:	c3                   	ret    
  803c3c:	85 c9                	test   %ecx,%ecx
  803c3e:	75 0b                	jne    803c4b <__umoddi3+0xe3>
  803c40:	b8 01 00 00 00       	mov    $0x1,%eax
  803c45:	31 d2                	xor    %edx,%edx
  803c47:	f7 f1                	div    %ecx
  803c49:	89 c1                	mov    %eax,%ecx
  803c4b:	89 f0                	mov    %esi,%eax
  803c4d:	31 d2                	xor    %edx,%edx
  803c4f:	f7 f1                	div    %ecx
  803c51:	89 f8                	mov    %edi,%eax
  803c53:	e9 3e ff ff ff       	jmp    803b96 <__umoddi3+0x2e>
  803c58:	89 f2                	mov    %esi,%edx
  803c5a:	83 c4 20             	add    $0x20,%esp
  803c5d:	5e                   	pop    %esi
  803c5e:	5f                   	pop    %edi
  803c5f:	5d                   	pop    %ebp
  803c60:	c3                   	ret    
  803c61:	8d 76 00             	lea    0x0(%esi),%esi
  803c64:	39 f5                	cmp    %esi,%ebp
  803c66:	72 04                	jb     803c6c <__umoddi3+0x104>
  803c68:	39 f9                	cmp    %edi,%ecx
  803c6a:	77 06                	ja     803c72 <__umoddi3+0x10a>
  803c6c:	89 f2                	mov    %esi,%edx
  803c6e:	29 cf                	sub    %ecx,%edi
  803c70:	19 ea                	sbb    %ebp,%edx
  803c72:	89 f8                	mov    %edi,%eax
  803c74:	83 c4 20             	add    $0x20,%esp
  803c77:	5e                   	pop    %esi
  803c78:	5f                   	pop    %edi
  803c79:	5d                   	pop    %ebp
  803c7a:	c3                   	ret    
  803c7b:	90                   	nop
  803c7c:	89 d1                	mov    %edx,%ecx
  803c7e:	89 c5                	mov    %eax,%ebp
  803c80:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  803c84:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  803c88:	eb 8d                	jmp    803c17 <__umoddi3+0xaf>
  803c8a:	66 90                	xchg   %ax,%ax
  803c8c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803c90:	72 ea                	jb     803c7c <__umoddi3+0x114>
  803c92:	89 f1                	mov    %esi,%ecx
  803c94:	eb 81                	jmp    803c17 <__umoddi3+0xaf>
