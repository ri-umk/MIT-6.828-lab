
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc b0 b5 10 80       	mov    $0x8010b5b0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 6c 2b 10 80       	mov    $0x80102b6c,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	53                   	push   %ebx
80100038:	83 ec 14             	sub    $0x14,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003b:	c7 44 24 04 00 68 10 	movl   $0x80106800,0x4(%esp)
80100042:	80 
80100043:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
8010004a:	e8 a1 3c 00 00       	call   80103cf0 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 0c fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd0c
80100056:	fc 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 10 fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd10
80100060:	fc 10 80 
80100063:	ba bc fc 10 80       	mov    $0x8010fcbc,%edx
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100068:	bb f4 b5 10 80       	mov    $0x8010b5f4,%ebx
8010006d:	eb 05                	jmp    80100074 <binit+0x40>
8010006f:	90                   	nop
80100070:	89 da                	mov    %ebx,%edx
80100072:	89 c3                	mov    %eax,%ebx
    b->next = bcache.head.next;
80100074:	89 53 54             	mov    %edx,0x54(%ebx)
    b->prev = &bcache.head;
80100077:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
8010007e:	c7 44 24 04 07 68 10 	movl   $0x80106807,0x4(%esp)
80100085:	80 
80100086:	8d 43 0c             	lea    0xc(%ebx),%eax
80100089:	89 04 24             	mov    %eax,(%esp)
8010008c:	e8 53 3b 00 00       	call   80103be4 <initsleeplock>
    bcache.head.next->prev = b;
80100091:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
80100096:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100099:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	8d 83 5c 02 00 00    	lea    0x25c(%ebx),%eax
801000a5:	3d bc fc 10 80       	cmp    $0x8010fcbc,%eax
801000aa:	72 c4                	jb     80100070 <binit+0x3c>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ac:	83 c4 14             	add    $0x14,%esp
801000af:	5b                   	pop    %ebx
801000b0:	5d                   	pop    %ebp
801000b1:	c3                   	ret    
801000b2:	66 90                	xchg   %ax,%ax

801000b4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000b4:	55                   	push   %ebp
801000b5:	89 e5                	mov    %esp,%ebp
801000b7:	57                   	push   %edi
801000b8:	56                   	push   %esi
801000b9:	53                   	push   %ebx
801000ba:	83 ec 1c             	sub    $0x1c,%esp
801000bd:	8b 75 08             	mov    0x8(%ebp),%esi
801000c0:	8b 7d 0c             	mov    0xc(%ebp),%edi
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  acquire(&bcache.lock);
801000c3:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801000ca:	e8 5d 3d 00 00       	call   80103e2c <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000cf:	8b 1d 10 fd 10 80    	mov    0x8010fd10,%ebx
801000d5:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000db:	75 0e                	jne    801000eb <bread+0x37>
801000dd:	eb 1d                	jmp    801000fc <bread+0x48>
801000df:	90                   	nop
801000e0:	8b 5b 54             	mov    0x54(%ebx),%ebx
801000e3:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000e9:	74 11                	je     801000fc <bread+0x48>
    if(b->dev == dev && b->blockno == blockno){
801000eb:	3b 73 04             	cmp    0x4(%ebx),%esi
801000ee:	75 f0                	jne    801000e0 <bread+0x2c>
801000f0:	3b 7b 08             	cmp    0x8(%ebx),%edi
801000f3:	75 eb                	jne    801000e0 <bread+0x2c>
      b->refcnt++;
801000f5:	ff 43 4c             	incl   0x4c(%ebx)
801000f8:	eb 3c                	jmp    80100136 <bread+0x82>
801000fa:	66 90                	xchg   %ax,%ax
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801000fc:	8b 1d 0c fd 10 80    	mov    0x8010fd0c,%ebx
80100102:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
80100108:	75 0d                	jne    80100117 <bread+0x63>
8010010a:	eb 58                	jmp    80100164 <bread+0xb0>
8010010c:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010010f:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
80100115:	74 4d                	je     80100164 <bread+0xb0>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100117:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010011a:	85 c0                	test   %eax,%eax
8010011c:	75 ee                	jne    8010010c <bread+0x58>
8010011e:	f6 03 04             	testb  $0x4,(%ebx)
80100121:	75 e9                	jne    8010010c <bread+0x58>
      b->dev = dev;
80100123:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
80100126:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
80100129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
8010012f:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100136:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
8010013d:	e8 4e 3d 00 00       	call   80103e90 <release>
      acquiresleep(&b->lock);
80100142:	8d 43 0c             	lea    0xc(%ebx),%eax
80100145:	89 04 24             	mov    %eax,(%esp)
80100148:	e8 cf 3a 00 00       	call   80103c1c <acquiresleep>
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
8010014d:	f6 03 02             	testb  $0x2,(%ebx)
80100150:	75 08                	jne    8010015a <bread+0xa6>
    iderw(b);
80100152:	89 1c 24             	mov    %ebx,(%esp)
80100155:	e8 8a 1e 00 00       	call   80101fe4 <iderw>
  }
  return b;
}
8010015a:	89 d8                	mov    %ebx,%eax
8010015c:	83 c4 1c             	add    $0x1c,%esp
8010015f:	5b                   	pop    %ebx
80100160:	5e                   	pop    %esi
80100161:	5f                   	pop    %edi
80100162:	5d                   	pop    %ebp
80100163:	c3                   	ret    
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100164:	c7 04 24 0e 68 10 80 	movl   $0x8010680e,(%esp)
8010016b:	e8 ac 01 00 00       	call   8010031c <panic>

80100170 <bwrite>:
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100170:	55                   	push   %ebp
80100171:	89 e5                	mov    %esp,%ebp
80100173:	53                   	push   %ebx
80100174:	83 ec 14             	sub    $0x14,%esp
80100177:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
8010017a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010017d:	89 04 24             	mov    %eax,(%esp)
80100180:	e8 23 3b 00 00       	call   80103ca8 <holdingsleep>
80100185:	85 c0                	test   %eax,%eax
80100187:	74 10                	je     80100199 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
80100189:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
8010018c:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010018f:	83 c4 14             	add    $0x14,%esp
80100192:	5b                   	pop    %ebx
80100193:	5d                   	pop    %ebp
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  b->flags |= B_DIRTY;
  iderw(b);
80100194:	e9 4b 1e 00 00       	jmp    80101fe4 <iderw>
// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
80100199:	c7 04 24 1f 68 10 80 	movl   $0x8010681f,(%esp)
801001a0:	e8 77 01 00 00       	call   8010031c <panic>
801001a5:	8d 76 00             	lea    0x0(%esi),%esi

801001a8 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001a8:	55                   	push   %ebp
801001a9:	89 e5                	mov    %esp,%ebp
801001ab:	56                   	push   %esi
801001ac:	53                   	push   %ebx
801001ad:	83 ec 10             	sub    $0x10,%esp
801001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001b3:	8d 73 0c             	lea    0xc(%ebx),%esi
801001b6:	89 34 24             	mov    %esi,(%esp)
801001b9:	e8 ea 3a 00 00       	call   80103ca8 <holdingsleep>
801001be:	85 c0                	test   %eax,%eax
801001c0:	74 60                	je     80100222 <brelse+0x7a>
    panic("brelse");

  releasesleep(&b->lock);
801001c2:	89 34 24             	mov    %esi,(%esp)
801001c5:	e8 a2 3a 00 00       	call   80103c6c <releasesleep>

  acquire(&bcache.lock);
801001ca:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801001d1:	e8 56 3c 00 00       	call   80103e2c <acquire>
  b->refcnt--;
801001d6:	8b 43 4c             	mov    0x4c(%ebx),%eax
801001d9:	48                   	dec    %eax
801001da:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
801001dd:	85 c0                	test   %eax,%eax
801001df:	75 2f                	jne    80100210 <brelse+0x68>
    // no one is waiting for it.
    b->next->prev = b->prev;
801001e1:	8b 43 54             	mov    0x54(%ebx),%eax
801001e4:	8b 53 50             	mov    0x50(%ebx),%edx
801001e7:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801001ea:	8b 43 50             	mov    0x50(%ebx),%eax
801001ed:	8b 53 54             	mov    0x54(%ebx),%edx
801001f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801001f3:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
801001f8:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
801001fb:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    bcache.head.next->prev = b;
80100202:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
80100207:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010020a:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  }
  
  release(&bcache.lock);
80100210:	c7 45 08 c0 b5 10 80 	movl   $0x8010b5c0,0x8(%ebp)
}
80100217:	83 c4 10             	add    $0x10,%esp
8010021a:	5b                   	pop    %ebx
8010021b:	5e                   	pop    %esi
8010021c:	5d                   	pop    %ebp
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
  
  release(&bcache.lock);
8010021d:	e9 6e 3c 00 00       	jmp    80103e90 <release>
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");
80100222:	c7 04 24 26 68 10 80 	movl   $0x80106826,(%esp)
80100229:	e8 ee 00 00 00       	call   8010031c <panic>
	...

80100230 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100230:	55                   	push   %ebp
80100231:	89 e5                	mov    %esp,%ebp
80100233:	57                   	push   %edi
80100234:	56                   	push   %esi
80100235:	53                   	push   %ebx
80100236:	83 ec 2c             	sub    $0x2c,%esp
80100239:	8b 75 08             	mov    0x8(%ebp),%esi
8010023c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010023f:	89 34 24             	mov    %esi,(%esp)
80100242:	e8 61 14 00 00       	call   801016a8 <iunlock>
  target = n;
80100247:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
8010024a:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100251:	e8 d6 3b 00 00       	call   80103e2c <acquire>
  while(n > 0){
80100256:	85 db                	test   %ebx,%ebx
80100258:	7f 26                	jg     80100280 <consoleread+0x50>
8010025a:	e9 b7 00 00 00       	jmp    80100316 <consoleread+0xe6>
8010025f:	90                   	nop
    while(input.r == input.w){
      if(myproc()->killed){
80100260:	e8 53 31 00 00       	call   801033b8 <myproc>
80100265:	8b 40 24             	mov    0x24(%eax),%eax
80100268:	85 c0                	test   %eax,%eax
8010026a:	75 58                	jne    801002c4 <consoleread+0x94>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
8010026c:	c7 44 24 04 20 a5 10 	movl   $0x8010a520,0x4(%esp)
80100273:	80 
80100274:	c7 04 24 a0 ff 10 80 	movl   $0x8010ffa0,(%esp)
8010027b:	e8 54 36 00 00       	call   801038d4 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100280:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
80100285:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
8010028b:	74 d3                	je     80100260 <consoleread+0x30>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 7f             	and    $0x7f,%edx
80100292:	8a 8a 20 ff 10 80    	mov    -0x7fef00e0(%edx),%cl
80100298:	0f be d1             	movsbl %cl,%edx
8010029b:	8d 78 01             	lea    0x1(%eax),%edi
8010029e:	89 3d a0 ff 10 80    	mov    %edi,0x8010ffa0
    if(c == C('D')){  // EOF
801002a4:	83 fa 04             	cmp    $0x4,%edx
801002a7:	74 3c                	je     801002e5 <consoleread+0xb5>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
801002a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801002ac:	88 08                	mov    %cl,(%eax)
801002ae:	40                   	inc    %eax
801002af:	89 45 0c             	mov    %eax,0xc(%ebp)
    --n;
801002b2:	4b                   	dec    %ebx
    if(c == '\n')
801002b3:	83 fa 0a             	cmp    $0xa,%edx
801002b6:	74 37                	je     801002ef <consoleread+0xbf>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
801002b8:	85 db                	test   %ebx,%ebx
801002ba:	75 c4                	jne    80100280 <consoleread+0x50>
801002bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801002bf:	eb 33                	jmp    801002f4 <consoleread+0xc4>
801002c1:	8d 76 00             	lea    0x0(%esi),%esi
    while(input.r == input.w){
      if(myproc()->killed){
        release(&cons.lock);
801002c4:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801002cb:	e8 c0 3b 00 00       	call   80103e90 <release>
        ilock(ip);
801002d0:	89 34 24             	mov    %esi,(%esp)
801002d3:	e8 00 13 00 00       	call   801015d8 <ilock>
        return -1;
801002d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002dd:	83 c4 2c             	add    $0x2c,%esp
801002e0:	5b                   	pop    %ebx
801002e1:	5e                   	pop    %esi
801002e2:	5f                   	pop    %edi
801002e3:	5d                   	pop    %ebp
801002e4:	c3                   	ret    
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
    if(c == C('D')){  // EOF
      if(n < target){
801002e5:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
801002e8:	76 05                	jbe    801002ef <consoleread+0xbf>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801002ea:	a3 a0 ff 10 80       	mov    %eax,0x8010ffa0
801002ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801002f2:	29 d8                	sub    %ebx,%eax
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
801002f4:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801002fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
801002fe:	e8 8d 3b 00 00       	call   80103e90 <release>
  ilock(ip);
80100303:	89 34 24             	mov    %esi,(%esp)
80100306:	e8 cd 12 00 00       	call   801015d8 <ilock>
8010030b:	8b 45 e0             	mov    -0x20(%ebp),%eax

  return target - n;
}
8010030e:	83 c4 2c             	add    $0x2c,%esp
80100311:	5b                   	pop    %ebx
80100312:	5e                   	pop    %esi
80100313:	5f                   	pop    %edi
80100314:	5d                   	pop    %ebp
80100315:	c3                   	ret    
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100316:	31 c0                	xor    %eax,%eax
80100318:	eb da                	jmp    801002f4 <consoleread+0xc4>
8010031a:	66 90                	xchg   %ax,%ax

8010031c <panic>:
    release(&cons.lock);
}

void
panic(char *s)
{
8010031c:	55                   	push   %ebp
8010031d:	89 e5                	mov    %esp,%ebp
8010031f:	56                   	push   %esi
80100320:	53                   	push   %ebx
80100321:	83 ec 40             	sub    $0x40,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100324:	fa                   	cli    
  int i;
  uint pcs[10];

  cli();
  cons.locking = 0;
80100325:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
8010032c:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
8010032f:	e8 a0 21 00 00       	call   801024d4 <lapicid>
80100334:	89 44 24 04          	mov    %eax,0x4(%esp)
80100338:	c7 04 24 2d 68 10 80 	movl   $0x8010682d,(%esp)
8010033f:	e8 78 02 00 00       	call   801005bc <cprintf>
  cprintf(s);
80100344:	8b 45 08             	mov    0x8(%ebp),%eax
80100347:	89 04 24             	mov    %eax,(%esp)
8010034a:	e8 6d 02 00 00       	call   801005bc <cprintf>
  cprintf("\n");
8010034f:	c7 04 24 bd 6f 10 80 	movl   $0x80106fbd,(%esp)
80100356:	e8 61 02 00 00       	call   801005bc <cprintf>
  getcallerpcs(&s, pcs);
8010035b:	8d 5d d0             	lea    -0x30(%ebp),%ebx
8010035e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80100362:	8d 45 08             	lea    0x8(%ebp),%eax
80100365:	89 04 24             	mov    %eax,(%esp)
80100368:	e8 9f 39 00 00       	call   80103d0c <getcallerpcs>
  if(locking)
    release(&cons.lock);
}

void
panic(char *s)
8010036d:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
    cprintf(" %p", pcs[i]);
80100370:	8b 03                	mov    (%ebx),%eax
80100372:	89 44 24 04          	mov    %eax,0x4(%esp)
80100376:	c7 04 24 41 68 10 80 	movl   $0x80106841,(%esp)
8010037d:	e8 3a 02 00 00       	call   801005bc <cprintf>
80100382:	83 c3 04             	add    $0x4,%ebx
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
80100385:	39 f3                	cmp    %esi,%ebx
80100387:	75 e7                	jne    80100370 <panic+0x54>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
80100389:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
80100390:	00 00 00 
80100393:	eb fe                	jmp    80100393 <panic+0x77>
80100395:	8d 76 00             	lea    0x0(%esi),%esi

80100398 <consputc>:
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
{
80100398:	55                   	push   %ebp
80100399:	89 e5                	mov    %esp,%ebp
8010039b:	57                   	push   %edi
8010039c:	56                   	push   %esi
8010039d:	53                   	push   %ebx
8010039e:	83 ec 1c             	sub    $0x1c,%esp
801003a1:	89 c7                	mov    %eax,%edi
  if(panicked){
801003a3:	8b 15 58 a5 10 80    	mov    0x8010a558,%edx
801003a9:	85 d2                	test   %edx,%edx
801003ab:	74 03                	je     801003b0 <consputc+0x18>
801003ad:	fa                   	cli    
801003ae:	eb fe                	jmp    801003ae <consputc+0x16>
    cli();
    for(;;)
      ;
  }

  if(c == BACKSPACE){
801003b0:	3d 00 01 00 00       	cmp    $0x100,%eax
801003b5:	0f 84 a0 00 00 00    	je     8010045b <consputc+0xc3>
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
801003bb:	89 04 24             	mov    %eax,(%esp)
801003be:	e8 f1 4f 00 00       	call   801053b4 <uartputc>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003c3:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003c8:	b0 0e                	mov    $0xe,%al
801003ca:	89 ca                	mov    %ecx,%edx
801003cc:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003cd:	be d5 03 00 00       	mov    $0x3d5,%esi
801003d2:	89 f2                	mov    %esi,%edx
801003d4:	ec                   	in     (%dx),%al
{
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
  pos = inb(CRTPORT+1) << 8;
801003d5:	0f b6 d8             	movzbl %al,%ebx
801003d8:	c1 e3 08             	shl    $0x8,%ebx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003db:	b0 0f                	mov    $0xf,%al
801003dd:	89 ca                	mov    %ecx,%edx
801003df:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003e0:	89 f2                	mov    %esi,%edx
801003e2:	ec                   	in     (%dx),%al
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);
801003e3:	0f b6 c0             	movzbl %al,%eax
801003e6:	09 c3                	or     %eax,%ebx

  if(c == '\n')
801003e8:	83 ff 0a             	cmp    $0xa,%edi
801003eb:	0f 84 f7 00 00 00    	je     801004e8 <consputc+0x150>
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
801003f1:	81 ff 00 01 00 00    	cmp    $0x100,%edi
801003f7:	0f 84 dd 00 00 00    	je     801004da <consputc+0x142>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801003fd:	81 e7 ff 00 00 00    	and    $0xff,%edi
80100403:	81 cf 00 07 00 00    	or     $0x700,%edi
80100409:	66 89 bc 1b 00 80 0b 	mov    %di,-0x7ff48000(%ebx,%ebx,1)
80100410:	80 
80100411:	43                   	inc    %ebx

  if(pos < 0 || pos > 25*80)
80100412:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100418:	0f 87 b0 00 00 00    	ja     801004ce <consputc+0x136>
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
8010041e:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100424:	7f 5e                	jg     80100484 <consputc+0xec>
80100426:	8d bc 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edi
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010042d:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
80100432:	b0 0e                	mov    $0xe,%al
80100434:	89 ca                	mov    %ecx,%edx
80100436:	ee                   	out    %al,(%dx)
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  }

  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
80100437:	89 d8                	mov    %ebx,%eax
80100439:	c1 f8 08             	sar    $0x8,%eax
8010043c:	be d5 03 00 00       	mov    $0x3d5,%esi
80100441:	89 f2                	mov    %esi,%edx
80100443:	ee                   	out    %al,(%dx)
80100444:	b0 0f                	mov    $0xf,%al
80100446:	89 ca                	mov    %ecx,%edx
80100448:	ee                   	out    %al,(%dx)
80100449:	88 d8                	mov    %bl,%al
8010044b:	89 f2                	mov    %esi,%edx
8010044d:	ee                   	out    %al,(%dx)
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
8010044e:	66 c7 07 20 07       	movw   $0x720,(%edi)
  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
  cgaputc(c);
}
80100453:	83 c4 1c             	add    $0x1c,%esp
80100456:	5b                   	pop    %ebx
80100457:	5e                   	pop    %esi
80100458:	5f                   	pop    %edi
80100459:	5d                   	pop    %ebp
8010045a:	c3                   	ret    
    for(;;)
      ;
  }

  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010045b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100462:	e8 4d 4f 00 00       	call   801053b4 <uartputc>
80100467:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010046e:	e8 41 4f 00 00       	call   801053b4 <uartputc>
80100473:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010047a:	e8 35 4f 00 00       	call   801053b4 <uartputc>
8010047f:	e9 3f ff ff ff       	jmp    801003c3 <consputc+0x2b>

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100484:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
8010048b:	00 
8010048c:	c7 44 24 04 a0 80 0b 	movl   $0x800b80a0,0x4(%esp)
80100493:	80 
80100494:	c7 04 24 00 80 0b 80 	movl   $0x800b8000,(%esp)
8010049b:	e8 c8 3a 00 00       	call   80103f68 <memmove>
    pos -= 80;
801004a0:	8d 73 b0             	lea    -0x50(%ebx),%esi
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004a3:	8d bc 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%edi
801004aa:	b8 d0 07 00 00       	mov    $0x7d0,%eax
801004af:	29 d8                	sub    %ebx,%eax
801004b1:	d1 e0                	shl    %eax
801004b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801004b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801004be:	00 
801004bf:	89 3c 24             	mov    %edi,(%esp)
801004c2:	e8 11 3a 00 00       	call   80103ed8 <memset>
  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
    pos -= 80;
801004c7:	89 f3                	mov    %esi,%ebx
801004c9:	e9 5f ff ff ff       	jmp    8010042d <consputc+0x95>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");
801004ce:	c7 04 24 45 68 10 80 	movl   $0x80106845,(%esp)
801004d5:	e8 42 fe ff ff       	call   8010031c <panic>
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
    if(pos > 0) --pos;
801004da:	85 db                	test   %ebx,%ebx
801004dc:	0f 8e 30 ff ff ff    	jle    80100412 <consputc+0x7a>
801004e2:	4b                   	dec    %ebx
801004e3:	e9 2a ff ff ff       	jmp    80100412 <consputc+0x7a>
  pos = inb(CRTPORT+1) << 8;
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
801004e8:	b9 50 00 00 00       	mov    $0x50,%ecx
801004ed:	89 d8                	mov    %ebx,%eax
801004ef:	99                   	cltd   
801004f0:	f7 f9                	idiv   %ecx
801004f2:	29 d1                	sub    %edx,%ecx
801004f4:	01 cb                	add    %ecx,%ebx
801004f6:	e9 17 ff ff ff       	jmp    80100412 <consputc+0x7a>
801004fb:	90                   	nop

801004fc <consolewrite>:
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
801004fc:	55                   	push   %ebp
801004fd:	89 e5                	mov    %esp,%ebp
801004ff:	57                   	push   %edi
80100500:	56                   	push   %esi
80100501:	53                   	push   %ebx
80100502:	83 ec 1c             	sub    $0x1c,%esp
80100505:	8b 7d 0c             	mov    0xc(%ebp),%edi
80100508:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
8010050b:	8b 45 08             	mov    0x8(%ebp),%eax
8010050e:	89 04 24             	mov    %eax,(%esp)
80100511:	e8 92 11 00 00       	call   801016a8 <iunlock>
  acquire(&cons.lock);
80100516:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010051d:	e8 0a 39 00 00       	call   80103e2c <acquire>
  for(i = 0; i < n; i++)
80100522:	85 f6                	test   %esi,%esi
80100524:	7e 10                	jle    80100536 <consolewrite+0x3a>
80100526:	31 db                	xor    %ebx,%ebx
    consputc(buf[i] & 0xff);
80100528:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
8010052c:	e8 67 fe ff ff       	call   80100398 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100531:	43                   	inc    %ebx
80100532:	39 f3                	cmp    %esi,%ebx
80100534:	75 f2                	jne    80100528 <consolewrite+0x2c>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100536:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010053d:	e8 4e 39 00 00       	call   80103e90 <release>
  ilock(ip);
80100542:	8b 45 08             	mov    0x8(%ebp),%eax
80100545:	89 04 24             	mov    %eax,(%esp)
80100548:	e8 8b 10 00 00       	call   801015d8 <ilock>

  return n;
}
8010054d:	89 f0                	mov    %esi,%eax
8010054f:	83 c4 1c             	add    $0x1c,%esp
80100552:	5b                   	pop    %ebx
80100553:	5e                   	pop    %esi
80100554:	5f                   	pop    %edi
80100555:	5d                   	pop    %ebp
80100556:	c3                   	ret    
80100557:	90                   	nop

80100558 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100558:	55                   	push   %ebp
80100559:	89 e5                	mov    %esp,%ebp
8010055b:	56                   	push   %esi
8010055c:	53                   	push   %ebx
8010055d:	83 ec 10             	sub    $0x10,%esp
80100560:	89 d3                	mov    %edx,%ebx
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100562:	85 c9                	test   %ecx,%ecx
80100564:	74 52                	je     801005b8 <printint+0x60>
80100566:	85 c0                	test   %eax,%eax
80100568:	79 4e                	jns    801005b8 <printint+0x60>
    x = -xx;
8010056a:	f7 d8                	neg    %eax
8010056c:	be 01 00 00 00       	mov    $0x1,%esi
  else
    x = xx;

  i = 0;
80100571:	31 c9                	xor    %ecx,%ecx
80100573:	eb 05                	jmp    8010057a <printint+0x22>
80100575:	8d 76 00             	lea    0x0(%esi),%esi
  do{
    buf[i++] = digits[x % base];
80100578:	89 d1                	mov    %edx,%ecx
8010057a:	31 d2                	xor    %edx,%edx
8010057c:	f7 f3                	div    %ebx
8010057e:	8a 92 70 68 10 80    	mov    -0x7fef9790(%edx),%dl
80100584:	88 54 0d e8          	mov    %dl,-0x18(%ebp,%ecx,1)
80100588:	8d 51 01             	lea    0x1(%ecx),%edx
  }while((x /= base) != 0);
8010058b:	85 c0                	test   %eax,%eax
8010058d:	75 e9                	jne    80100578 <printint+0x20>

  if(sign)
8010058f:	85 f6                	test   %esi,%esi
80100591:	74 08                	je     8010059b <printint+0x43>
    buf[i++] = '-';
80100593:	c6 44 15 e8 2d       	movb   $0x2d,-0x18(%ebp,%edx,1)
80100598:	8d 51 02             	lea    0x2(%ecx),%edx

  while(--i >= 0)
8010059b:	8d 5a ff             	lea    -0x1(%edx),%ebx
8010059e:	66 90                	xchg   %ax,%ax
    consputc(buf[i]);
801005a0:	0f be 44 1d e8       	movsbl -0x18(%ebp,%ebx,1),%eax
801005a5:	e8 ee fd ff ff       	call   80100398 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801005aa:	4b                   	dec    %ebx
801005ab:	83 fb ff             	cmp    $0xffffffff,%ebx
801005ae:	75 f0                	jne    801005a0 <printint+0x48>
    consputc(buf[i]);
}
801005b0:	83 c4 10             	add    $0x10,%esp
801005b3:	5b                   	pop    %ebx
801005b4:	5e                   	pop    %esi
801005b5:	5d                   	pop    %ebp
801005b6:	c3                   	ret    
801005b7:	90                   	nop
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  else
    x = xx;
801005b8:	31 f6                	xor    %esi,%esi
801005ba:	eb b5                	jmp    80100571 <printint+0x19>

801005bc <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801005bc:	55                   	push   %ebp
801005bd:	89 e5                	mov    %esp,%ebp
801005bf:	57                   	push   %edi
801005c0:	56                   	push   %esi
801005c1:	53                   	push   %ebx
801005c2:	83 ec 2c             	sub    $0x2c,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801005c5:	8b 3d 54 a5 10 80    	mov    0x8010a554,%edi
  if(locking)
801005cb:	85 ff                	test   %edi,%edi
801005cd:	0f 85 01 01 00 00    	jne    801006d4 <cprintf+0x118>
    acquire(&cons.lock);

  if (fmt == 0)
801005d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801005d6:	85 c9                	test   %ecx,%ecx
801005d8:	0f 84 11 01 00 00    	je     801006ef <cprintf+0x133>
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801005de:	0f b6 01             	movzbl (%ecx),%eax
801005e1:	85 c0                	test   %eax,%eax
801005e3:	74 77                	je     8010065c <cprintf+0xa0>
801005e5:	8d 75 0c             	lea    0xc(%ebp),%esi
801005e8:	31 db                	xor    %ebx,%ebx
801005ea:	eb 31                	jmp    8010061d <cprintf+0x61>
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
801005ec:	83 fa 25             	cmp    $0x25,%edx
801005ef:	0f 84 9b 00 00 00    	je     80100690 <cprintf+0xd4>
801005f5:	83 fa 64             	cmp    $0x64,%edx
801005f8:	74 7a                	je     80100674 <cprintf+0xb8>
    case '%':
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801005fa:	b8 25 00 00 00       	mov    $0x25,%eax
801005ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80100602:	e8 91 fd ff ff       	call   80100398 <consputc>
      consputc(c);
80100607:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010060a:	89 d0                	mov    %edx,%eax
8010060c:	e8 87 fd ff ff       	call   80100398 <consputc>
80100611:	8b 4d 08             	mov    0x8(%ebp),%ecx

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100614:	43                   	inc    %ebx
80100615:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
80100619:	85 c0                	test   %eax,%eax
8010061b:	74 3f                	je     8010065c <cprintf+0xa0>
    if(c != '%'){
8010061d:	83 f8 25             	cmp    $0x25,%eax
80100620:	75 ea                	jne    8010060c <cprintf+0x50>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
80100622:	43                   	inc    %ebx
80100623:	0f b6 14 19          	movzbl (%ecx,%ebx,1),%edx
    if(c == 0)
80100627:	85 d2                	test   %edx,%edx
80100629:	74 31                	je     8010065c <cprintf+0xa0>
      break;
    switch(c){
8010062b:	83 fa 70             	cmp    $0x70,%edx
8010062e:	74 0c                	je     8010063c <cprintf+0x80>
80100630:	7e ba                	jle    801005ec <cprintf+0x30>
80100632:	83 fa 73             	cmp    $0x73,%edx
80100635:	74 6d                	je     801006a4 <cprintf+0xe8>
80100637:	83 fa 78             	cmp    $0x78,%edx
8010063a:	75 be                	jne    801005fa <cprintf+0x3e>
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010063c:	8b 06                	mov    (%esi),%eax
8010063e:	83 c6 04             	add    $0x4,%esi
80100641:	31 c9                	xor    %ecx,%ecx
80100643:	ba 10 00 00 00       	mov    $0x10,%edx
80100648:	e8 0b ff ff ff       	call   80100558 <printint>
8010064d:	8b 4d 08             	mov    0x8(%ebp),%ecx

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100650:	43                   	inc    %ebx
80100651:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
80100655:	85 c0                	test   %eax,%eax
80100657:	75 c4                	jne    8010061d <cprintf+0x61>
80100659:	8d 76 00             	lea    0x0(%esi),%esi
      consputc(c);
      break;
    }
  }

  if(locking)
8010065c:	85 ff                	test   %edi,%edi
8010065e:	74 0c                	je     8010066c <cprintf+0xb0>
    release(&cons.lock);
80100660:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100667:	e8 24 38 00 00       	call   80103e90 <release>
}
8010066c:	83 c4 2c             	add    $0x2c,%esp
8010066f:	5b                   	pop    %ebx
80100670:	5e                   	pop    %esi
80100671:	5f                   	pop    %edi
80100672:	5d                   	pop    %ebp
80100673:	c3                   	ret    
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    case 'd':
      printint(*argp++, 10, 1);
80100674:	8b 06                	mov    (%esi),%eax
80100676:	83 c6 04             	add    $0x4,%esi
80100679:	b9 01 00 00 00       	mov    $0x1,%ecx
8010067e:	ba 0a 00 00 00       	mov    $0xa,%edx
80100683:	e8 d0 fe ff ff       	call   80100558 <printint>
80100688:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
8010068b:	eb 87                	jmp    80100614 <cprintf+0x58>
8010068d:	8d 76 00             	lea    0x0(%esi),%esi
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
80100690:	b8 25 00 00 00       	mov    $0x25,%eax
80100695:	e8 fe fc ff ff       	call   80100398 <consputc>
8010069a:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
8010069d:	e9 72 ff ff ff       	jmp    80100614 <cprintf+0x58>
801006a2:	66 90                	xchg   %ax,%ax
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
801006a4:	8b 16                	mov    (%esi),%edx
801006a6:	83 c6 04             	add    $0x4,%esi
801006a9:	85 d2                	test   %edx,%edx
801006ab:	74 3b                	je     801006e8 <cprintf+0x12c>
        s = "(null)";
      for(; *s; s++)
801006ad:	8a 02                	mov    (%edx),%al
801006af:	84 c0                	test   %al,%al
801006b1:	0f 84 5d ff ff ff    	je     80100614 <cprintf+0x58>
801006b7:	90                   	nop
        consputc(*s);
801006b8:	0f be c0             	movsbl %al,%eax
801006bb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801006be:	e8 d5 fc ff ff       	call   80100398 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801006c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801006c6:	42                   	inc    %edx
801006c7:	8a 02                	mov    (%edx),%al
801006c9:	84 c0                	test   %al,%al
801006cb:	75 eb                	jne    801006b8 <cprintf+0xfc>
801006cd:	e9 3f ff ff ff       	jmp    80100611 <cprintf+0x55>
801006d2:	66 90                	xchg   %ax,%ax
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);
801006d4:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801006db:	e8 4c 37 00 00       	call   80103e2c <acquire>
801006e0:	e9 ee fe ff ff       	jmp    801005d3 <cprintf+0x17>
801006e5:	8d 76 00             	lea    0x0(%esi),%esi
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
801006e8:	ba 58 68 10 80       	mov    $0x80106858,%edx
801006ed:	eb be                	jmp    801006ad <cprintf+0xf1>
  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);

  if (fmt == 0)
    panic("null fmt");
801006ef:	c7 04 24 5f 68 10 80 	movl   $0x8010685f,(%esp)
801006f6:	e8 21 fc ff ff       	call   8010031c <panic>
801006fb:	90                   	nop

801006fc <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801006fc:	55                   	push   %ebp
801006fd:	89 e5                	mov    %esp,%ebp
801006ff:	57                   	push   %edi
80100700:	56                   	push   %esi
80100701:	53                   	push   %ebx
80100702:	83 ec 1c             	sub    $0x1c,%esp
80100705:	8b 75 08             	mov    0x8(%ebp),%esi
  int c, doprocdump = 0;

  acquire(&cons.lock);
80100708:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010070f:	e8 18 37 00 00       	call   80103e2c <acquire>
#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;
80100714:	31 ff                	xor    %edi,%edi
80100716:	66 90                	xchg   %ax,%ax

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100718:	ff d6                	call   *%esi
8010071a:	89 c3                	mov    %eax,%ebx
8010071c:	85 c0                	test   %eax,%eax
8010071e:	0f 88 8c 00 00 00    	js     801007b0 <consoleintr+0xb4>
    switch(c){
80100724:	83 fb 10             	cmp    $0x10,%ebx
80100727:	0f 84 d3 00 00 00    	je     80100800 <consoleintr+0x104>
8010072d:	0f 8f 99 00 00 00    	jg     801007cc <consoleintr+0xd0>
80100733:	83 fb 08             	cmp    $0x8,%ebx
80100736:	0f 84 9e 00 00 00    	je     801007da <consoleintr+0xde>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010073c:	85 db                	test   %ebx,%ebx
8010073e:	74 d8                	je     80100718 <consoleintr+0x1c>
80100740:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100745:	89 c2                	mov    %eax,%edx
80100747:	2b 15 a0 ff 10 80    	sub    0x8010ffa0,%edx
8010074d:	83 fa 7f             	cmp    $0x7f,%edx
80100750:	77 c6                	ja     80100718 <consoleintr+0x1c>
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
80100752:	89 c2                	mov    %eax,%edx
80100754:	83 e2 7f             	and    $0x7f,%edx
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
80100757:	83 fb 0d             	cmp    $0xd,%ebx
8010075a:	0f 84 00 01 00 00    	je     80100860 <consoleintr+0x164>
        input.buf[input.e++ % INPUT_BUF] = c;
80100760:	88 9a 20 ff 10 80    	mov    %bl,-0x7fef00e0(%edx)
80100766:	40                   	inc    %eax
80100767:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(c);
8010076c:	89 d8                	mov    %ebx,%eax
8010076e:	e8 25 fc ff ff       	call   80100398 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100773:	83 fb 0a             	cmp    $0xa,%ebx
80100776:	0f 84 fb 00 00 00    	je     80100877 <consoleintr+0x17b>
8010077c:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100781:	83 fb 04             	cmp    $0x4,%ebx
80100784:	74 0d                	je     80100793 <consoleintr+0x97>
80100786:	8b 15 a0 ff 10 80    	mov    0x8010ffa0,%edx
8010078c:	83 ea 80             	sub    $0xffffff80,%edx
8010078f:	39 d0                	cmp    %edx,%eax
80100791:	75 85                	jne    80100718 <consoleintr+0x1c>
          input.w = input.e;
80100793:	a3 a4 ff 10 80       	mov    %eax,0x8010ffa4
          wakeup(&input.r);
80100798:	c7 04 24 a0 ff 10 80 	movl   $0x8010ffa0,(%esp)
8010079f:	e8 b0 32 00 00       	call   80103a54 <wakeup>
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
801007a4:	ff d6                	call   *%esi
801007a6:	89 c3                	mov    %eax,%ebx
801007a8:	85 c0                	test   %eax,%eax
801007aa:	0f 89 74 ff ff ff    	jns    80100724 <consoleintr+0x28>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801007b0:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801007b7:	e8 d4 36 00 00       	call   80103e90 <release>
  if(doprocdump) {
801007bc:	85 ff                	test   %edi,%edi
801007be:	0f 85 90 00 00 00    	jne    80100854 <consoleintr+0x158>
    procdump();  // now call procdump() wo. cons.lock held
  }
}
801007c4:	83 c4 1c             	add    $0x1c,%esp
801007c7:	5b                   	pop    %ebx
801007c8:	5e                   	pop    %esi
801007c9:	5f                   	pop    %edi
801007ca:	5d                   	pop    %ebp
801007cb:	c3                   	ret    
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
801007cc:	83 fb 15             	cmp    $0x15,%ebx
801007cf:	74 3b                	je     8010080c <consoleintr+0x110>
801007d1:	83 fb 7f             	cmp    $0x7f,%ebx
801007d4:	0f 85 62 ff ff ff    	jne    8010073c <consoleintr+0x40>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801007da:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
801007df:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801007e5:	0f 84 2d ff ff ff    	je     80100718 <consoleintr+0x1c>
        input.e--;
801007eb:	48                   	dec    %eax
801007ec:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
801007f1:	b8 00 01 00 00       	mov    $0x100,%eax
801007f6:	e8 9d fb ff ff       	call   80100398 <consputc>
801007fb:	e9 18 ff ff ff       	jmp    80100718 <consoleintr+0x1c>
  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100800:	bf 01 00 00 00       	mov    $0x1,%edi
80100805:	e9 0e ff ff ff       	jmp    80100718 <consoleintr+0x1c>
8010080a:	66 90                	xchg   %ax,%ax
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080c:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100811:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
80100817:	75 27                	jne    80100840 <consoleintr+0x144>
80100819:	e9 fa fe ff ff       	jmp    80100718 <consoleintr+0x1c>
8010081e:	66 90                	xchg   %ax,%ax
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100820:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
80100825:	b8 00 01 00 00       	mov    $0x100,%eax
8010082a:	e8 69 fb ff ff       	call   80100398 <consputc>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010082f:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100834:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
8010083a:	0f 84 d8 fe ff ff    	je     80100718 <consoleintr+0x1c>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100840:	48                   	dec    %eax
80100841:	89 c2                	mov    %eax,%edx
80100843:	83 e2 7f             	and    $0x7f,%edx
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100846:	80 ba 20 ff 10 80 0a 	cmpb   $0xa,-0x7fef00e0(%edx)
8010084d:	75 d1                	jne    80100820 <consoleintr+0x124>
8010084f:	e9 c4 fe ff ff       	jmp    80100718 <consoleintr+0x1c>
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
}
80100854:	83 c4 1c             	add    $0x1c,%esp
80100857:	5b                   	pop    %ebx
80100858:	5e                   	pop    %esi
80100859:	5f                   	pop    %edi
8010085a:	5d                   	pop    %ebp
      break;
    }
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
8010085b:	e9 d0 32 00 00       	jmp    80103b30 <procdump>
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
80100860:	c6 82 20 ff 10 80 0a 	movb   $0xa,-0x7fef00e0(%edx)
80100867:	40                   	inc    %eax
80100868:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(c);
8010086d:	b8 0a 00 00 00       	mov    $0xa,%eax
80100872:	e8 21 fb ff ff       	call   80100398 <consputc>
80100877:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
8010087c:	e9 12 ff ff ff       	jmp    80100793 <consoleintr+0x97>
80100881:	8d 76 00             	lea    0x0(%esi),%esi

80100884 <consoleinit>:
  return n;
}

void
consoleinit(void)
{
80100884:	55                   	push   %ebp
80100885:	89 e5                	mov    %esp,%ebp
80100887:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
8010088a:	c7 44 24 04 68 68 10 	movl   $0x80106868,0x4(%esp)
80100891:	80 
80100892:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100899:	e8 52 34 00 00       	call   80103cf0 <initlock>

  devsw[CONSOLE].write = consolewrite;
8010089e:	c7 05 6c 09 11 80 fc 	movl   $0x801004fc,0x8011096c
801008a5:	04 10 80 
  devsw[CONSOLE].read = consoleread;
801008a8:	c7 05 68 09 11 80 30 	movl   $0x80100230,0x80110968
801008af:	02 10 80 
  cons.locking = 1;
801008b2:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
801008b9:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801008c3:	00 
801008c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801008cb:	e8 84 18 00 00       	call   80102154 <ioapicenable>
}
801008d0:	c9                   	leave  
801008d1:	c3                   	ret    
	...

801008d4 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008d4:	55                   	push   %ebp
801008d5:	89 e5                	mov    %esp,%ebp
801008d7:	57                   	push   %edi
801008d8:	56                   	push   %esi
801008d9:	53                   	push   %ebx
801008da:	81 ec 3c 01 00 00    	sub    $0x13c,%esp
801008e0:	8b 75 08             	mov    0x8(%ebp),%esi
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008e3:	e8 d0 2a 00 00       	call   801033b8 <myproc>
801008e8:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008ee:	e8 dd 1f 00 00       	call   801028d0 <begin_op>

  if((ip = namei(path)) == 0){
801008f3:	89 34 24             	mov    %esi,(%esp)
801008f6:	e8 0d 15 00 00       	call   80101e08 <namei>
801008fb:	89 c3                	mov    %eax,%ebx
801008fd:	85 c0                	test   %eax,%eax
801008ff:	0f 84 3c 02 00 00    	je     80100b41 <exec+0x26d>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100905:	89 04 24             	mov    %eax,(%esp)
80100908:	e8 cb 0c 00 00       	call   801015d8 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100914:	00 
80100915:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010091c:	00 
8010091d:	8d 45 94             	lea    -0x6c(%ebp),%eax
80100920:	89 44 24 04          	mov    %eax,0x4(%esp)
80100924:	89 1c 24             	mov    %ebx,(%esp)
80100927:	e8 48 0f 00 00       	call   80101874 <readi>
8010092c:	83 f8 34             	cmp    $0x34,%eax
8010092f:	74 1f                	je     80100950 <exec+0x7c>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100931:	89 1c 24             	mov    %ebx,(%esp)
80100934:	e8 ef 0e 00 00       	call   80101828 <iunlockput>
    end_op();
80100939:	e8 f2 1f 00 00       	call   80102930 <end_op>
  }
  return -1;
8010093e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100943:	81 c4 3c 01 00 00    	add    $0x13c,%esp
80100949:	5b                   	pop    %ebx
8010094a:	5e                   	pop    %esi
8010094b:	5f                   	pop    %edi
8010094c:	5d                   	pop    %ebp
8010094d:	c3                   	ret    
8010094e:	66 90                	xchg   %ax,%ax
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100950:	81 7d 94 7f 45 4c 46 	cmpl   $0x464c457f,-0x6c(%ebp)
80100957:	75 d8                	jne    80100931 <exec+0x5d>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100959:	e8 32 5c 00 00       	call   80106590 <setupkvm>
8010095e:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
80100964:	85 c0                	test   %eax,%eax
80100966:	74 c9                	je     80100931 <exec+0x5d>
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100968:	8b 7d b0             	mov    -0x50(%ebp),%edi
8010096b:	66 83 7d c0 00       	cmpw   $0x0,-0x40(%ebp)

  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
80100970:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100977:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
8010097a:	0f 84 cd 00 00 00    	je     80100a4d <exec+0x179>
80100980:	31 d2                	xor    %edx,%edx
80100982:	89 b5 e8 fe ff ff    	mov    %esi,-0x118(%ebp)
80100988:	89 d6                	mov    %edx,%esi
8010098a:	eb 10                	jmp    8010099c <exec+0xc8>
8010098c:	46                   	inc    %esi
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
8010098d:	83 c7 20             	add    $0x20,%edi
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100990:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80100994:	39 f0                	cmp    %esi,%eax
80100996:	0f 8e ab 00 00 00    	jle    80100a47 <exec+0x173>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
8010099c:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
801009a3:	00 
801009a4:	89 7c 24 08          	mov    %edi,0x8(%esp)
801009a8:	8d 45 c8             	lea    -0x38(%ebp),%eax
801009ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801009af:	89 1c 24             	mov    %ebx,(%esp)
801009b2:	e8 bd 0e 00 00       	call   80101874 <readi>
801009b7:	83 f8 20             	cmp    $0x20,%eax
801009ba:	75 70                	jne    80100a2c <exec+0x158>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
801009bc:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
801009c0:	75 ca                	jne    8010098c <exec+0xb8>
      continue;
    if(ph.memsz < ph.filesz)
801009c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
801009c8:	72 62                	jb     80100a2c <exec+0x158>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009ca:	03 45 d0             	add    -0x30(%ebp),%eax
801009cd:	72 5d                	jb     80100a2c <exec+0x158>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801009d3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801009dd:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
801009e3:	89 04 24             	mov    %eax,(%esp)
801009e6:	e8 05 5a 00 00       	call   801063f0 <allocuvm>
801009eb:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009f1:	85 c0                	test   %eax,%eax
801009f3:	74 37                	je     80100a2c <exec+0x158>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
801009f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801009f8:	a9 ff 0f 00 00       	test   $0xfff,%eax
801009fd:	75 2d                	jne    80100a2c <exec+0x158>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
801009ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100a02:	89 54 24 10          	mov    %edx,0x10(%esp)
80100a06:	8b 55 cc             	mov    -0x34(%ebp),%edx
80100a09:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100a0d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80100a11:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a15:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a1b:	89 04 24             	mov    %eax,(%esp)
80100a1e:	e8 61 58 00 00       	call   80106284 <loaduvm>
80100a23:	85 c0                	test   %eax,%eax
80100a25:	0f 89 61 ff ff ff    	jns    8010098c <exec+0xb8>
80100a2b:	90                   	nop
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
80100a2c:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a32:	89 04 24             	mov    %eax,(%esp)
80100a35:	e8 e2 5a 00 00       	call   8010651c <freevm>
  if(ip){
80100a3a:	85 db                	test   %ebx,%ebx
80100a3c:	0f 85 ef fe ff ff    	jne    80100931 <exec+0x5d>
80100a42:	e9 f7 fe ff ff       	jmp    8010093e <exec+0x6a>
80100a47:	8b b5 e8 fe ff ff    	mov    -0x118(%ebp),%esi
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100a4d:	89 1c 24             	mov    %ebx,(%esp)
80100a50:	e8 d3 0d 00 00       	call   80101828 <iunlockput>
  end_op();
80100a55:	e8 d6 1e 00 00       	call   80102930 <end_op>
  ip = 0;

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100a5a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100a60:	05 ff 0f 00 00       	add    $0xfff,%eax
80100a65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a6a:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a70:	89 54 24 08          	mov    %edx,0x8(%esp)
80100a74:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a78:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a7e:	89 04 24             	mov    %eax,(%esp)
80100a81:	e8 6a 59 00 00       	call   801063f0 <allocuvm>
80100a86:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a8c:	85 c0                	test   %eax,%eax
80100a8e:	75 04                	jne    80100a94 <exec+0x1c0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;
80100a90:	31 db                	xor    %ebx,%ebx
80100a92:	eb 98                	jmp    80100a2c <exec+0x158>
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100a94:	2d 00 20 00 00       	sub    $0x2000,%eax
80100a99:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a9d:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100aa3:	89 04 24             	mov    %eax,(%esp)
80100aa6:	e8 85 5b 00 00       	call   80106630 <clearpteu>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100aab:	8b 55 0c             	mov    0xc(%ebp),%edx
80100aae:	8b 02                	mov    (%edx),%eax
80100ab0:	85 c0                	test   %eax,%eax
80100ab2:	0f 84 80 01 00 00    	je     80100c38 <exec+0x364>
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
80100ab8:	83 c2 04             	add    $0x4,%edx
80100abb:	8b 9d f0 fe ff ff    	mov    -0x110(%ebp),%ebx
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ac1:	31 ff                	xor    %edi,%edi
80100ac3:	89 b5 e8 fe ff ff    	mov    %esi,-0x118(%ebp)
80100ac9:	89 d6                	mov    %edx,%esi
80100acb:	8b 55 0c             	mov    0xc(%ebp),%edx
80100ace:	eb 1e                	jmp    80100aee <exec+0x21a>
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
80100ad0:	8d 8d 04 ff ff ff    	lea    -0xfc(%ebp),%ecx
80100ad6:	89 9c bd 10 ff ff ff 	mov    %ebx,-0xf0(%ebp,%edi,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100add:	47                   	inc    %edi
80100ade:	89 f2                	mov    %esi,%edx
80100ae0:	8b 06                	mov    (%esi),%eax
80100ae2:	85 c0                	test   %eax,%eax
80100ae4:	74 76                	je     80100b5c <exec+0x288>
80100ae6:	83 c6 04             	add    $0x4,%esi
    if(argc >= MAXARG)
80100ae9:	83 ff 20             	cmp    $0x20,%edi
80100aec:	74 a2                	je     80100a90 <exec+0x1bc>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100aee:	89 04 24             	mov    %eax,(%esp)
80100af1:	89 95 e4 fe ff ff    	mov    %edx,-0x11c(%ebp)
80100af7:	e8 94 35 00 00       	call   80104090 <strlen>
80100afc:	f7 d0                	not    %eax
80100afe:	01 c3                	add    %eax,%ebx
80100b00:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100b03:	8b 95 e4 fe ff ff    	mov    -0x11c(%ebp),%edx
80100b09:	8b 02                	mov    (%edx),%eax
80100b0b:	89 04 24             	mov    %eax,(%esp)
80100b0e:	e8 7d 35 00 00       	call   80104090 <strlen>
80100b13:	40                   	inc    %eax
80100b14:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100b18:	8b 95 e4 fe ff ff    	mov    -0x11c(%ebp),%edx
80100b1e:	8b 02                	mov    (%edx),%eax
80100b20:	89 44 24 08          	mov    %eax,0x8(%esp)
80100b24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80100b28:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100b2e:	89 04 24             	mov    %eax,(%esp)
80100b31:	e8 32 5c 00 00       	call   80106768 <copyout>
80100b36:	85 c0                	test   %eax,%eax
80100b38:	79 96                	jns    80100ad0 <exec+0x1fc>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;
80100b3a:	31 db                	xor    %ebx,%ebx
80100b3c:	e9 eb fe ff ff       	jmp    80100a2c <exec+0x158>
  struct proc *curproc = myproc();

  begin_op();

  if((ip = namei(path)) == 0){
    end_op();
80100b41:	e8 ea 1d 00 00       	call   80102930 <end_op>
    cprintf("exec: fail\n");
80100b46:	c7 04 24 81 68 10 80 	movl   $0x80106881,(%esp)
80100b4d:	e8 6a fa ff ff       	call   801005bc <cprintf>
    return -1;
80100b52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b57:	e9 e7 fd ff ff       	jmp    80100943 <exec+0x6f>
80100b5c:	8b b5 e8 fe ff ff    	mov    -0x118(%ebp),%esi
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100b62:	c7 84 bd 10 ff ff ff 	movl   $0x0,-0xf0(%ebp,%edi,4)
80100b69:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100b6d:	c7 85 04 ff ff ff ff 	movl   $0xffffffff,-0xfc(%ebp)
80100b74:	ff ff ff 
  ustack[1] = argc;
80100b77:	89 bd 08 ff ff ff    	mov    %edi,-0xf8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b7d:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100b84:	89 da                	mov    %ebx,%edx
80100b86:	29 c2                	sub    %eax,%edx
80100b88:	89 95 0c ff ff ff    	mov    %edx,-0xf4(%ebp)

  sp -= (3+argc+1) * 4;
80100b8e:	8d 04 bd 10 00 00 00 	lea    0x10(,%edi,4),%eax
80100b95:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b97:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100b9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80100b9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80100ba3:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ba9:	89 04 24             	mov    %eax,(%esp)
80100bac:	e8 b7 5b 00 00       	call   80106768 <copyout>
80100bb1:	85 c0                	test   %eax,%eax
80100bb3:	0f 88 d7 fe ff ff    	js     80100a90 <exec+0x1bc>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100bb9:	8a 16                	mov    (%esi),%dl
80100bbb:	84 d2                	test   %dl,%dl
80100bbd:	74 16                	je     80100bd5 <exec+0x301>
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
80100bbf:	8d 46 01             	lea    0x1(%esi),%eax
80100bc2:	eb 08                	jmp    80100bcc <exec+0x2f8>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
80100bc4:	40                   	inc    %eax
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100bc5:	8a 50 ff             	mov    -0x1(%eax),%dl
80100bc8:	84 d2                	test   %dl,%dl
80100bca:	74 09                	je     80100bd5 <exec+0x301>
    if(*s == '/')
80100bcc:	80 fa 2f             	cmp    $0x2f,%dl
80100bcf:	75 f3                	jne    80100bc4 <exec+0x2f0>
      last = s+1;
80100bd1:	89 c6                	mov    %eax,%esi
80100bd3:	eb ef                	jmp    80100bc4 <exec+0x2f0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100bd5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100bdc:	00 
80100bdd:	89 74 24 04          	mov    %esi,0x4(%esp)
80100be1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100be7:	83 c0 6c             	add    $0x6c,%eax
80100bea:	89 04 24             	mov    %eax,(%esp)
80100bed:	e8 72 34 00 00       	call   80104064 <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100bf2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100bf8:	8b 70 04             	mov    0x4(%eax),%esi
  curproc->pgdir = pgdir;
80100bfb:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100c01:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100c04:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c0a:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100c0c:	8b 40 18             	mov    0x18(%eax),%eax
80100c0f:	8b 55 ac             	mov    -0x54(%ebp),%edx
80100c12:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100c15:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c1b:	8b 42 18             	mov    0x18(%edx),%eax
80100c1e:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100c21:	89 14 24             	mov    %edx,(%esp)
80100c24:	e8 d3 54 00 00       	call   801060fc <switchuvm>
  freevm(oldpgdir);
80100c29:	89 34 24             	mov    %esi,(%esp)
80100c2c:	e8 eb 58 00 00       	call   8010651c <freevm>
  return 0;
80100c31:	31 c0                	xor    %eax,%eax
80100c33:	e9 0b fd ff ff       	jmp    80100943 <exec+0x6f>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100c38:	8b 9d f0 fe ff ff    	mov    -0x110(%ebp),%ebx
80100c3e:	31 ff                	xor    %edi,%edi
80100c40:	8d 8d 04 ff ff ff    	lea    -0xfc(%ebp),%ecx
80100c46:	e9 17 ff ff ff       	jmp    80100b62 <exec+0x28e>
	...

80100c4c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c4c:	55                   	push   %ebp
80100c4d:	89 e5                	mov    %esp,%ebp
80100c4f:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100c52:	c7 44 24 04 8d 68 10 	movl   $0x8010688d,0x4(%esp)
80100c59:	80 
80100c5a:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100c61:	e8 8a 30 00 00       	call   80103cf0 <initlock>
}
80100c66:	c9                   	leave  
80100c67:	c3                   	ret    

80100c68 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c68:	55                   	push   %ebp
80100c69:	89 e5                	mov    %esp,%ebp
80100c6b:	53                   	push   %ebx
80100c6c:	83 ec 14             	sub    $0x14,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c6f:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100c76:	e8 b1 31 00 00       	call   80103e2c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c7b:	bb f4 ff 10 80       	mov    $0x8010fff4,%ebx
    if(f->ref == 0){
80100c80:	8b 15 f8 ff 10 80    	mov    0x8010fff8,%edx
80100c86:	85 d2                	test   %edx,%edx
80100c88:	74 14                	je     80100c9e <filealloc+0x36>
80100c8a:	66 90                	xchg   %ax,%ax
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c8c:	83 c3 18             	add    $0x18,%ebx
80100c8f:	81 fb 54 09 11 80    	cmp    $0x80110954,%ebx
80100c95:	73 25                	jae    80100cbc <filealloc+0x54>
    if(f->ref == 0){
80100c97:	8b 43 04             	mov    0x4(%ebx),%eax
80100c9a:	85 c0                	test   %eax,%eax
80100c9c:	75 ee                	jne    80100c8c <filealloc+0x24>
      f->ref = 1;
80100c9e:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100ca5:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100cac:	e8 df 31 00 00       	call   80103e90 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100cb1:	89 d8                	mov    %ebx,%eax
80100cb3:	83 c4 14             	add    $0x14,%esp
80100cb6:	5b                   	pop    %ebx
80100cb7:	5d                   	pop    %ebp
80100cb8:	c3                   	ret    
80100cb9:	8d 76 00             	lea    0x0(%esi),%esi
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100cbc:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100cc3:	e8 c8 31 00 00       	call   80103e90 <release>
  return 0;
80100cc8:	31 db                	xor    %ebx,%ebx
}
80100cca:	89 d8                	mov    %ebx,%eax
80100ccc:	83 c4 14             	add    $0x14,%esp
80100ccf:	5b                   	pop    %ebx
80100cd0:	5d                   	pop    %ebp
80100cd1:	c3                   	ret    
80100cd2:	66 90                	xchg   %ax,%ax

80100cd4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100cd4:	55                   	push   %ebp
80100cd5:	89 e5                	mov    %esp,%ebp
80100cd7:	53                   	push   %ebx
80100cd8:	83 ec 14             	sub    $0x14,%esp
80100cdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100cde:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100ce5:	e8 42 31 00 00       	call   80103e2c <acquire>
  if(f->ref < 1)
80100cea:	8b 43 04             	mov    0x4(%ebx),%eax
80100ced:	85 c0                	test   %eax,%eax
80100cef:	7e 18                	jle    80100d09 <filedup+0x35>
    panic("filedup");
  f->ref++;
80100cf1:	40                   	inc    %eax
80100cf2:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cf5:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100cfc:	e8 8f 31 00 00       	call   80103e90 <release>
  return f;
}
80100d01:	89 d8                	mov    %ebx,%eax
80100d03:	83 c4 14             	add    $0x14,%esp
80100d06:	5b                   	pop    %ebx
80100d07:	5d                   	pop    %ebp
80100d08:	c3                   	ret    
struct file*
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
80100d09:	c7 04 24 94 68 10 80 	movl   $0x80106894,(%esp)
80100d10:	e8 07 f6 ff ff       	call   8010031c <panic>
80100d15:	8d 76 00             	lea    0x0(%esi),%esi

80100d18 <fileclose>:
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100d18:	55                   	push   %ebp
80100d19:	89 e5                	mov    %esp,%ebp
80100d1b:	57                   	push   %edi
80100d1c:	56                   	push   %esi
80100d1d:	53                   	push   %ebx
80100d1e:	83 ec 2c             	sub    $0x2c,%esp
80100d21:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100d24:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100d2b:	e8 fc 30 00 00       	call   80103e2c <acquire>
  if(f->ref < 1)
80100d30:	8b 43 04             	mov    0x4(%ebx),%eax
80100d33:	85 c0                	test   %eax,%eax
80100d35:	0f 8e 86 00 00 00    	jle    80100dc1 <fileclose+0xa9>
    panic("fileclose");
  if(--f->ref > 0){
80100d3b:	48                   	dec    %eax
80100d3c:	89 43 04             	mov    %eax,0x4(%ebx)
80100d3f:	85 c0                	test   %eax,%eax
80100d41:	74 15                	je     80100d58 <fileclose+0x40>
    release(&ftable.lock);
80100d43:	c7 45 08 c0 ff 10 80 	movl   $0x8010ffc0,0x8(%ebp)
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d4a:	83 c4 2c             	add    $0x2c,%esp
80100d4d:	5b                   	pop    %ebx
80100d4e:	5e                   	pop    %esi
80100d4f:	5f                   	pop    %edi
80100d50:	5d                   	pop    %ebp

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
80100d51:	e9 3a 31 00 00       	jmp    80103e90 <release>
80100d56:	66 90                	xchg   %ax,%ax
    return;
  }
  ff = *f;
80100d58:	8b 33                	mov    (%ebx),%esi
80100d5a:	8a 43 09             	mov    0x9(%ebx),%al
80100d5d:	88 45 e7             	mov    %al,-0x19(%ebp)
80100d60:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d63:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d66:	8b 7b 10             	mov    0x10(%ebx),%edi
  f->ref = 0;
  f->type = FD_NONE;
80100d69:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d6f:	c7 04 24 c0 ff 10 80 	movl   $0x8010ffc0,(%esp)
80100d76:	e8 15 31 00 00       	call   80103e90 <release>

  if(ff.type == FD_PIPE)
80100d7b:	83 fe 01             	cmp    $0x1,%esi
80100d7e:	74 2c                	je     80100dac <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100d80:	83 fe 02             	cmp    $0x2,%esi
80100d83:	74 0b                	je     80100d90 <fileclose+0x78>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d85:	83 c4 2c             	add    $0x2c,%esp
80100d88:	5b                   	pop    %ebx
80100d89:	5e                   	pop    %esi
80100d8a:	5f                   	pop    %edi
80100d8b:	5d                   	pop    %ebp
80100d8c:	c3                   	ret    
80100d8d:	8d 76 00             	lea    0x0(%esi),%esi
  release(&ftable.lock);

  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
    begin_op();
80100d90:	e8 3b 1b 00 00       	call   801028d0 <begin_op>
    iput(ff.ip);
80100d95:	89 3c 24             	mov    %edi,(%esp)
80100d98:	e8 4b 09 00 00       	call   801016e8 <iput>
    end_op();
  }
}
80100d9d:	83 c4 2c             	add    $0x2c,%esp
80100da0:	5b                   	pop    %ebx
80100da1:	5e                   	pop    %esi
80100da2:	5f                   	pop    %edi
80100da3:	5d                   	pop    %ebp
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
80100da4:	e9 87 1b 00 00       	jmp    80102930 <end_op>
80100da9:	8d 76 00             	lea    0x0(%esi),%esi
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);

  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
80100dac:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
80100db0:	89 44 24 04          	mov    %eax,0x4(%esp)
80100db4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100db7:	89 04 24             	mov    %eax,(%esp)
80100dba:	e8 c5 21 00 00       	call   80102f84 <pipeclose>
80100dbf:	eb c4                	jmp    80100d85 <fileclose+0x6d>
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
80100dc1:	c7 04 24 9c 68 10 80 	movl   $0x8010689c,(%esp)
80100dc8:	e8 4f f5 ff ff       	call   8010031c <panic>
80100dcd:	8d 76 00             	lea    0x0(%esi),%esi

80100dd0 <filestat>:
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100dd0:	55                   	push   %ebp
80100dd1:	89 e5                	mov    %esp,%ebp
80100dd3:	53                   	push   %ebx
80100dd4:	83 ec 14             	sub    $0x14,%esp
80100dd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100dda:	83 3b 02             	cmpl   $0x2,(%ebx)
80100ddd:	75 31                	jne    80100e10 <filestat+0x40>
    ilock(f->ip);
80100ddf:	8b 43 10             	mov    0x10(%ebx),%eax
80100de2:	89 04 24             	mov    %eax,(%esp)
80100de5:	e8 ee 07 00 00       	call   801015d8 <ilock>
    stati(f->ip, st);
80100dea:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ded:	89 44 24 04          	mov    %eax,0x4(%esp)
80100df1:	8b 43 10             	mov    0x10(%ebx),%eax
80100df4:	89 04 24             	mov    %eax,(%esp)
80100df7:	e8 4c 0a 00 00       	call   80101848 <stati>
    iunlock(f->ip);
80100dfc:	8b 43 10             	mov    0x10(%ebx),%eax
80100dff:	89 04 24             	mov    %eax,(%esp)
80100e02:	e8 a1 08 00 00       	call   801016a8 <iunlock>
    return 0;
80100e07:	31 c0                	xor    %eax,%eax
  }
  return -1;
}
80100e09:	83 c4 14             	add    $0x14,%esp
80100e0c:	5b                   	pop    %ebx
80100e0d:	5d                   	pop    %ebp
80100e0e:	c3                   	ret    
80100e0f:	90                   	nop
    ilock(f->ip);
    stati(f->ip, st);
    iunlock(f->ip);
    return 0;
  }
  return -1;
80100e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100e15:	83 c4 14             	add    $0x14,%esp
80100e18:	5b                   	pop    %ebx
80100e19:	5d                   	pop    %ebp
80100e1a:	c3                   	ret    
80100e1b:	90                   	nop

80100e1c <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100e1c:	55                   	push   %ebp
80100e1d:	89 e5                	mov    %esp,%ebp
80100e1f:	57                   	push   %edi
80100e20:	56                   	push   %esi
80100e21:	53                   	push   %ebx
80100e22:	83 ec 2c             	sub    $0x2c,%esp
80100e25:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100e28:	8b 75 0c             	mov    0xc(%ebp),%esi
80100e2b:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80100e2e:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100e32:	74 68                	je     80100e9c <fileread+0x80>
    return -1;
  if(f->type == FD_PIPE)
80100e34:	8b 03                	mov    (%ebx),%eax
80100e36:	83 f8 01             	cmp    $0x1,%eax
80100e39:	74 4d                	je     80100e88 <fileread+0x6c>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e3b:	83 f8 02             	cmp    $0x2,%eax
80100e3e:	75 63                	jne    80100ea3 <fileread+0x87>
    ilock(f->ip);
80100e40:	8b 43 10             	mov    0x10(%ebx),%eax
80100e43:	89 04 24             	mov    %eax,(%esp)
80100e46:	e8 8d 07 00 00       	call   801015d8 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100e4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80100e4f:	8b 43 14             	mov    0x14(%ebx),%eax
80100e52:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e56:	89 74 24 04          	mov    %esi,0x4(%esp)
80100e5a:	8b 43 10             	mov    0x10(%ebx),%eax
80100e5d:	89 04 24             	mov    %eax,(%esp)
80100e60:	e8 0f 0a 00 00       	call   80101874 <readi>
80100e65:	85 c0                	test   %eax,%eax
80100e67:	7e 03                	jle    80100e6c <fileread+0x50>
      f->off += r;
80100e69:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e6c:	8b 53 10             	mov    0x10(%ebx),%edx
80100e6f:	89 14 24             	mov    %edx,(%esp)
80100e72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100e75:	e8 2e 08 00 00       	call   801016a8 <iunlock>
    return r;
80100e7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("fileread");
}
80100e7d:	83 c4 2c             	add    $0x2c,%esp
80100e80:	5b                   	pop    %ebx
80100e81:	5e                   	pop    %esi
80100e82:	5f                   	pop    %edi
80100e83:	5d                   	pop    %ebp
80100e84:	c3                   	ret    
80100e85:	8d 76 00             	lea    0x0(%esi),%esi
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
80100e88:	8b 43 0c             	mov    0xc(%ebx),%eax
80100e8b:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
80100e8e:	83 c4 2c             	add    $0x2c,%esp
80100e91:	5b                   	pop    %ebx
80100e92:	5e                   	pop    %esi
80100e93:	5f                   	pop    %edi
80100e94:	5d                   	pop    %ebp
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
80100e95:	e9 52 22 00 00       	jmp    801030ec <piperead>
80100e9a:	66 90                	xchg   %ax,%ax
fileread(struct file *f, char *addr, int n)
{
  int r;

  if(f->readable == 0)
    return -1;
80100e9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ea1:	eb da                	jmp    80100e7d <fileread+0x61>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
80100ea3:	c7 04 24 a6 68 10 80 	movl   $0x801068a6,(%esp)
80100eaa:	e8 6d f4 ff ff       	call   8010031c <panic>
80100eaf:	90                   	nop

80100eb0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100eb0:	55                   	push   %ebp
80100eb1:	89 e5                	mov    %esp,%ebp
80100eb3:	57                   	push   %edi
80100eb4:	56                   	push   %esi
80100eb5:	53                   	push   %ebx
80100eb6:	83 ec 2c             	sub    $0x2c,%esp
80100eb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ebf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ec2:	8b 45 10             	mov    0x10(%ebp),%eax
80100ec5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int r;

  if(f->writable == 0)
80100ec8:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100ecc:	0f 84 a9 00 00 00    	je     80100f7b <filewrite+0xcb>
    return -1;
  if(f->type == FD_PIPE)
80100ed2:	8b 03                	mov    (%ebx),%eax
80100ed4:	83 f8 01             	cmp    $0x1,%eax
80100ed7:	0f 84 ba 00 00 00    	je     80100f97 <filewrite+0xe7>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100edd:	83 f8 02             	cmp    $0x2,%eax
80100ee0:	0f 85 cf 00 00 00    	jne    80100fb5 <filewrite+0x105>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80100ee6:	31 f6                	xor    %esi,%esi
80100ee8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80100eeb:	85 c9                	test   %ecx,%ecx
80100eed:	7f 2d                	jg     80100f1c <filewrite+0x6c>
80100eef:	e9 94 00 00 00       	jmp    80100f88 <filewrite+0xd8>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80100ef4:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ef7:	8b 53 10             	mov    0x10(%ebx),%edx
80100efa:	89 14 24             	mov    %edx,(%esp)
80100efd:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100f00:	e8 a3 07 00 00       	call   801016a8 <iunlock>
      end_op();
80100f05:	e8 26 1a 00 00       	call   80102930 <end_op>
80100f0a:	8b 45 dc             	mov    -0x24(%ebp),%eax

      if(r < 0)
        break;
      if(r != n1)
80100f0d:	39 f8                	cmp    %edi,%eax
80100f0f:	0f 85 94 00 00 00    	jne    80100fa9 <filewrite+0xf9>
        panic("short filewrite");
      i += r;
80100f15:	01 c6                	add    %eax,%esi
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80100f17:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100f1a:	7e 6c                	jle    80100f88 <filewrite+0xd8>
      int n1 = n - i;
80100f1c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80100f1f:	29 f7                	sub    %esi,%edi
80100f21:	81 ff 00 06 00 00    	cmp    $0x600,%edi
80100f27:	7e 05                	jle    80100f2e <filewrite+0x7e>
80100f29:	bf 00 06 00 00       	mov    $0x600,%edi
      if(n1 > max)
        n1 = max;

      begin_op();
80100f2e:	e8 9d 19 00 00       	call   801028d0 <begin_op>
      ilock(f->ip);
80100f33:	8b 43 10             	mov    0x10(%ebx),%eax
80100f36:	89 04 24             	mov    %eax,(%esp)
80100f39:	e8 9a 06 00 00       	call   801015d8 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100f3e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80100f42:	8b 43 14             	mov    0x14(%ebx),%eax
80100f45:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f49:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f4c:	01 f0                	add    %esi,%eax
80100f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f52:	8b 43 10             	mov    0x10(%ebx),%eax
80100f55:	89 04 24             	mov    %eax,(%esp)
80100f58:	e8 43 0a 00 00       	call   801019a0 <writei>
80100f5d:	85 c0                	test   %eax,%eax
80100f5f:	7f 93                	jg     80100ef4 <filewrite+0x44>
        f->off += r;
      iunlock(f->ip);
80100f61:	8b 53 10             	mov    0x10(%ebx),%edx
80100f64:	89 14 24             	mov    %edx,(%esp)
80100f67:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100f6a:	e8 39 07 00 00       	call   801016a8 <iunlock>
      end_op();
80100f6f:	e8 bc 19 00 00       	call   80102930 <end_op>

      if(r < 0)
80100f74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f77:	85 c0                	test   %eax,%eax
80100f79:	74 92                	je     80100f0d <filewrite+0x5d>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80100f7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80100f80:	83 c4 2c             	add    $0x2c,%esp
80100f83:	5b                   	pop    %ebx
80100f84:	5e                   	pop    %esi
80100f85:	5f                   	pop    %edi
80100f86:	5d                   	pop    %ebp
80100f87:	c3                   	ret    
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80100f88:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
80100f8b:	75 ee                	jne    80100f7b <filewrite+0xcb>
80100f8d:	89 f0                	mov    %esi,%eax
  }
  panic("filewrite");
}
80100f8f:	83 c4 2c             	add    $0x2c,%esp
80100f92:	5b                   	pop    %ebx
80100f93:	5e                   	pop    %esi
80100f94:	5f                   	pop    %edi
80100f95:	5d                   	pop    %ebp
80100f96:	c3                   	ret    
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
80100f97:	8b 43 0c             	mov    0xc(%ebx),%eax
80100f9a:	89 45 08             	mov    %eax,0x8(%ebp)
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
80100f9d:	83 c4 2c             	add    $0x2c,%esp
80100fa0:	5b                   	pop    %ebx
80100fa1:	5e                   	pop    %esi
80100fa2:	5f                   	pop    %edi
80100fa3:	5d                   	pop    %ebp
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
80100fa4:	e9 63 20 00 00       	jmp    8010300c <pipewrite>
      end_op();

      if(r < 0)
        break;
      if(r != n1)
        panic("short filewrite");
80100fa9:	c7 04 24 af 68 10 80 	movl   $0x801068af,(%esp)
80100fb0:	e8 67 f3 ff ff       	call   8010031c <panic>
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
80100fb5:	c7 04 24 b5 68 10 80 	movl   $0x801068b5,(%esp)
80100fbc:	e8 5b f3 ff ff       	call   8010031c <panic>
80100fc1:	00 00                	add    %al,(%eax)
	...

80100fc4 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80100fc4:	55                   	push   %ebp
80100fc5:	89 e5                	mov    %esp,%ebp
80100fc7:	57                   	push   %edi
80100fc8:	56                   	push   %esi
80100fc9:	53                   	push   %ebx
80100fca:	83 ec 2c             	sub    $0x2c,%esp
80100fcd:	89 c3                	mov    %eax,%ebx
80100fcf:	89 d7                	mov    %edx,%edi
  struct inode *ip, *empty;

  acquire(&icache.lock);
80100fd1:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80100fd8:	e8 4f 2e 00 00       	call   80103e2c <acquire>

  // Is the inode already cached?
  empty = 0;
80100fdd:	31 f6                	xor    %esi,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80100fdf:	b8 14 0a 11 80       	mov    $0x80110a14,%eax
80100fe4:	eb 12                	jmp    80100ff8 <iget+0x34>
80100fe6:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80100fe8:	85 f6                	test   %esi,%esi
80100fea:	74 3c                	je     80101028 <iget+0x64>

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80100fec:	05 90 00 00 00       	add    $0x90,%eax
80100ff1:	3d 34 26 11 80       	cmp    $0x80112634,%eax
80100ff6:	73 44                	jae    8010103c <iget+0x78>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80100ff8:	8b 48 08             	mov    0x8(%eax),%ecx
80100ffb:	85 c9                	test   %ecx,%ecx
80100ffd:	7e e9                	jle    80100fe8 <iget+0x24>
80100fff:	39 18                	cmp    %ebx,(%eax)
80101001:	75 e5                	jne    80100fe8 <iget+0x24>
80101003:	39 78 04             	cmp    %edi,0x4(%eax)
80101006:	75 e0                	jne    80100fe8 <iget+0x24>
      ip->ref++;
80101008:	41                   	inc    %ecx
80101009:	89 48 08             	mov    %ecx,0x8(%eax)
      release(&icache.lock);
8010100c:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101013:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101016:	e8 75 2e 00 00       	call   80103e90 <release>
      return ip;
8010101b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);

  return ip;
}
8010101e:	83 c4 2c             	add    $0x2c,%esp
80101021:	5b                   	pop    %ebx
80101022:	5e                   	pop    %esi
80101023:	5f                   	pop    %edi
80101024:	5d                   	pop    %ebp
80101025:	c3                   	ret    
80101026:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101028:	85 c9                	test   %ecx,%ecx
8010102a:	75 c0                	jne    80100fec <iget+0x28>
8010102c:	89 c6                	mov    %eax,%esi

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010102e:	05 90 00 00 00       	add    $0x90,%eax
80101033:	3d 34 26 11 80       	cmp    $0x80112634,%eax
80101038:	72 be                	jb     80100ff8 <iget+0x34>
8010103a:	66 90                	xchg   %ax,%ax
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010103c:	85 f6                	test   %esi,%esi
8010103e:	74 29                	je     80101069 <iget+0xa5>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
80101040:	89 1e                	mov    %ebx,(%esi)
  ip->inum = inum;
80101042:	89 7e 04             	mov    %edi,0x4(%esi)
  ip->ref = 1;
80101045:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
8010104c:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
80101053:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
8010105a:	e8 31 2e 00 00       	call   80103e90 <release>

  return ip;
8010105f:	89 f0                	mov    %esi,%eax
}
80101061:	83 c4 2c             	add    $0x2c,%esp
80101064:	5b                   	pop    %ebx
80101065:	5e                   	pop    %esi
80101066:	5f                   	pop    %edi
80101067:	5d                   	pop    %ebp
80101068:	c3                   	ret    
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
    panic("iget: no inodes");
80101069:	c7 04 24 bf 68 10 80 	movl   $0x801068bf,(%esp)
80101070:	e8 a7 f2 ff ff       	call   8010031c <panic>
80101075:	8d 76 00             	lea    0x0(%esi),%esi

80101078 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101078:	55                   	push   %ebp
80101079:	89 e5                	mov    %esp,%ebp
8010107b:	57                   	push   %edi
8010107c:	56                   	push   %esi
8010107d:	53                   	push   %ebx
8010107e:	83 ec 1c             	sub    $0x1c,%esp
80101081:	89 d6                	mov    %edx,%esi
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
80101083:	c1 ea 0c             	shr    $0xc,%edx
80101086:	03 15 d8 09 11 80    	add    0x801109d8,%edx
8010108c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101090:	89 04 24             	mov    %eax,(%esp)
80101093:	e8 1c f0 ff ff       	call   801000b4 <bread>
80101098:	89 c7                	mov    %eax,%edi
  bi = b % BPB;
8010109a:	89 f3                	mov    %esi,%ebx
8010109c:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
  m = 1 << (bi % 8);
801010a2:	89 f1                	mov    %esi,%ecx
801010a4:	83 e1 07             	and    $0x7,%ecx
801010a7:	be 01 00 00 00       	mov    $0x1,%esi
801010ac:	d3 e6                	shl    %cl,%esi
  if((bp->data[bi/8] & m) == 0)
801010ae:	c1 fb 03             	sar    $0x3,%ebx
801010b1:	8a 54 18 5c          	mov    0x5c(%eax,%ebx,1),%dl
801010b5:	0f b6 c2             	movzbl %dl,%eax
801010b8:	85 f0                	test   %esi,%eax
801010ba:	74 22                	je     801010de <bfree+0x66>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
801010bc:	89 f0                	mov    %esi,%eax
801010be:	f7 d0                	not    %eax
801010c0:	21 d0                	and    %edx,%eax
801010c2:	88 44 1f 5c          	mov    %al,0x5c(%edi,%ebx,1)
  log_write(bp);
801010c6:	89 3c 24             	mov    %edi,(%esp)
801010c9:	e8 8a 19 00 00       	call   80102a58 <log_write>
  brelse(bp);
801010ce:	89 3c 24             	mov    %edi,(%esp)
801010d1:	e8 d2 f0 ff ff       	call   801001a8 <brelse>
}
801010d6:	83 c4 1c             	add    $0x1c,%esp
801010d9:	5b                   	pop    %ebx
801010da:	5e                   	pop    %esi
801010db:	5f                   	pop    %edi
801010dc:	5d                   	pop    %ebp
801010dd:	c3                   	ret    

  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
801010de:	c7 04 24 cf 68 10 80 	movl   $0x801068cf,(%esp)
801010e5:	e8 32 f2 ff ff       	call   8010031c <panic>
801010ea:	66 90                	xchg   %ax,%ax

801010ec <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801010ec:	55                   	push   %ebp
801010ed:	89 e5                	mov    %esp,%ebp
801010ef:	57                   	push   %edi
801010f0:	56                   	push   %esi
801010f1:	53                   	push   %ebx
801010f2:	83 ec 3c             	sub    $0x3c,%esp
801010f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801010f8:	a1 c0 09 11 80       	mov    0x801109c0,%eax
801010fd:	85 c0                	test   %eax,%eax
801010ff:	0f 84 82 00 00 00    	je     80101187 <balloc+0x9b>
80101105:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
8010110c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010110f:	c1 f8 0c             	sar    $0xc,%eax
80101112:	03 05 d8 09 11 80    	add    0x801109d8,%eax
80101118:	89 44 24 04          	mov    %eax,0x4(%esp)
8010111c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010111f:	89 04 24             	mov    %eax,(%esp)
80101122:	e8 8d ef ff ff       	call   801000b4 <bread>
80101127:	8b 15 c0 09 11 80    	mov    0x801109c0,%edx
8010112d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101130:	8b 5d dc             	mov    -0x24(%ebp),%ebx
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101133:	31 d2                	xor    %edx,%edx
80101135:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101138:	eb 2b                	jmp    80101165 <balloc+0x79>
8010113a:	66 90                	xchg   %ax,%ax
      m = 1 << (bi % 8);
8010113c:	89 d1                	mov    %edx,%ecx
8010113e:	83 e1 07             	and    $0x7,%ecx
80101141:	bf 01 00 00 00       	mov    $0x1,%edi
80101146:	d3 e7                	shl    %cl,%edi
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101148:	89 d1                	mov    %edx,%ecx
8010114a:	c1 f9 03             	sar    $0x3,%ecx
8010114d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80101150:	8a 44 0e 5c          	mov    0x5c(%esi,%ecx,1),%al
80101154:	0f b6 f0             	movzbl %al,%esi
80101157:	85 fe                	test   %edi,%esi
80101159:	74 39                	je     80101194 <balloc+0xa8>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010115b:	42                   	inc    %edx
8010115c:	43                   	inc    %ebx
8010115d:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
80101163:	74 05                	je     8010116a <balloc+0x7e>
80101165:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
80101168:	72 d2                	jb     8010113c <balloc+0x50>
8010116a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010116d:	89 04 24             	mov    %eax,(%esp)
80101170:	e8 33 f0 ff ff       	call   801001a8 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101175:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
8010117c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010117f:	3b 15 c0 09 11 80    	cmp    0x801109c0,%edx
80101185:	72 85                	jb     8010110c <balloc+0x20>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101187:	c7 04 24 e2 68 10 80 	movl   $0x801068e2,(%esp)
8010118e:	e8 89 f1 ff ff       	call   8010031c <panic>
80101193:	90                   	nop
80101194:	88 c2                	mov    %al,%dl
80101196:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use.
80101199:	09 fa                	or     %edi,%edx
8010119b:	88 54 08 5c          	mov    %dl,0x5c(%eax,%ecx,1)
        log_write(bp);
8010119f:	89 04 24             	mov    %eax,(%esp)
801011a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801011a5:	e8 ae 18 00 00       	call   80102a58 <log_write>
        brelse(bp);
801011aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801011ad:	89 04 24             	mov    %eax,(%esp)
801011b0:	e8 f3 ef ff ff       	call   801001a8 <brelse>
static void
bzero(int dev, int bno)
{
  struct buf *bp;

  bp = bread(dev, bno);
801011b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801011b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801011bc:	89 04 24             	mov    %eax,(%esp)
801011bf:	e8 f0 ee ff ff       	call   801000b4 <bread>
801011c4:	89 c6                	mov    %eax,%esi
  memset(bp->data, 0, BSIZE);
801011c6:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801011cd:	00 
801011ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801011d5:	00 
801011d6:	8d 40 5c             	lea    0x5c(%eax),%eax
801011d9:	89 04 24             	mov    %eax,(%esp)
801011dc:	e8 f7 2c 00 00       	call   80103ed8 <memset>
  log_write(bp);
801011e1:	89 34 24             	mov    %esi,(%esp)
801011e4:	e8 6f 18 00 00       	call   80102a58 <log_write>
  brelse(bp);
801011e9:	89 34 24             	mov    %esi,(%esp)
801011ec:	e8 b7 ef ff ff       	call   801001a8 <brelse>
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801011f1:	89 d8                	mov    %ebx,%eax
801011f3:	83 c4 3c             	add    $0x3c,%esp
801011f6:	5b                   	pop    %ebx
801011f7:	5e                   	pop    %esi
801011f8:	5f                   	pop    %edi
801011f9:	5d                   	pop    %ebp
801011fa:	c3                   	ret    
801011fb:	90                   	nop

801011fc <bmap.part.0>:
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
801011fc:	55                   	push   %ebp
801011fd:	89 e5                	mov    %esp,%ebp
801011ff:	57                   	push   %edi
80101200:	56                   	push   %esi
80101201:	53                   	push   %ebx
80101202:	83 ec 2c             	sub    $0x2c,%esp
80101205:	89 c3                	mov    %eax,%ebx
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101207:	8d 72 f5             	lea    -0xb(%edx),%esi
  
  //First-order indirection block
  if(bn < NINDIRECT){
8010120a:	83 fe 7f             	cmp    $0x7f,%esi
8010120d:	77 45                	ja     80101254 <bmap.part.0+0x58>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
8010120f:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80101215:	85 c0                	test   %eax,%eax
80101217:	0f 84 f7 00 00 00    	je     80101314 <bmap.part.0+0x118>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
8010121d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101221:	8b 03                	mov    (%ebx),%eax
80101223:	89 04 24             	mov    %eax,(%esp)
80101226:	e8 89 ee ff ff       	call   801000b4 <bread>
8010122b:	89 c7                	mov    %eax,%edi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
8010122d:	8d 74 b0 5c          	lea    0x5c(%eax,%esi,4),%esi
80101231:	8b 06                	mov    (%esi),%eax
80101233:	85 c0                	test   %eax,%eax
80101235:	0f 84 bd 00 00 00    	je     801012f8 <bmap.part.0+0xfc>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
8010123b:	89 3c 24             	mov    %edi,(%esp)
8010123e:	89 45 dc             	mov    %eax,-0x24(%ebp)
80101241:	e8 62 ef ff ff       	call   801001a8 <brelse>
80101246:	8b 45 dc             	mov    -0x24(%ebp),%eax
    return addr;
  }
  

  panic("bmap: out of range");
}
80101249:	83 c4 2c             	add    $0x2c,%esp
8010124c:	5b                   	pop    %ebx
8010124d:	5e                   	pop    %esi
8010124e:	5f                   	pop    %edi
8010124f:	5d                   	pop    %ebp
80101250:	c3                   	ret    
80101251:	8d 76 00             	lea    0x0(%esi),%esi
      log_write(bp);
    }
    brelse(bp);
    return addr;
  }
  bn -= NINDIRECT; 
80101254:	81 ea 8b 00 00 00    	sub    $0x8b,%edx
8010125a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  
  //Second-order indirection block
  if(bn < NDINDIRECT){
8010125d:	81 fa ff 3f 00 00    	cmp    $0x3fff,%edx
80101263:	0f 87 f5 00 00 00    	ja     8010135e <bmap.part.0+0x162>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT+1]) == 0)
80101269:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010126f:	85 c0                	test   %eax,%eax
80101271:	0f 84 d5 00 00 00    	je     8010134c <bmap.part.0+0x150>
      ip->addrs[NDIRECT+1] = addr = balloc(ip->dev);
      
    bp = bread(ip->dev, addr);
80101277:	89 44 24 04          	mov    %eax,0x4(%esp)
8010127b:	8b 03                	mov    (%ebx),%eax
8010127d:	89 04 24             	mov    %eax,(%esp)
80101280:	e8 2f ee ff ff       	call   801000b4 <bread>
80101285:	89 c6                	mov    %eax,%esi
    // First level index
    a = (uint*)bp->data;
80101287:	8d 78 5c             	lea    0x5c(%eax),%edi
    if((addr = a[bn/NINDIRECT]) == 0){
8010128a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010128d:	c1 e8 07             	shr    $0x7,%eax
80101290:	8d 14 87             	lea    (%edi,%eax,4),%edx
80101293:	8b 02                	mov    (%edx),%eax
80101295:	85 c0                	test   %eax,%eax
80101297:	0f 84 8b 00 00 00    	je     80101328 <bmap.part.0+0x12c>
      a[bn/NINDIRECT] = addr = balloc(ip->dev);
      log_write(bp);
    }
    
    bp2 = bread(ip->dev, addr);
8010129d:	89 44 24 04          	mov    %eax,0x4(%esp)
801012a1:	8b 03                	mov    (%ebx),%eax
801012a3:	89 04 24             	mov    %eax,(%esp)
801012a6:	e8 09 ee ff ff       	call   801000b4 <bread>
801012ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // Secondary page table
    a = (uint*)bp->data;
    if((addr = a[bn%NINDIRECT]) == 0){
801012ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801012b1:	83 e0 7f             	and    $0x7f,%eax
801012b4:	8d 3c 87             	lea    (%edi,%eax,4),%edi
801012b7:	8b 07                	mov    (%edi),%eax
801012b9:	85 c0                	test   %eax,%eax
801012bb:	75 1a                	jne    801012d7 <bmap.part.0+0xdb>
      a[bn%NINDIRECT] = addr = balloc(ip->dev);
801012bd:	8b 03                	mov    (%ebx),%eax
801012bf:	e8 28 fe ff ff       	call   801010ec <balloc>
801012c4:	89 07                	mov    %eax,(%edi)
      log_write(bp2);
801012c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801012c9:	89 14 24             	mov    %edx,(%esp)
801012cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
801012cf:	e8 84 17 00 00       	call   80102a58 <log_write>
801012d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
    }   
    
    brelse(bp);
801012d7:	89 34 24             	mov    %esi,(%esp)
801012da:	89 45 dc             	mov    %eax,-0x24(%ebp)
801012dd:	e8 c6 ee ff ff       	call   801001a8 <brelse>
    brelse(bp2);
801012e2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801012e5:	89 14 24             	mov    %edx,(%esp)
801012e8:	e8 bb ee ff ff       	call   801001a8 <brelse>
801012ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
    return addr;
  }
  

  panic("bmap: out of range");
}
801012f0:	83 c4 2c             	add    $0x2c,%esp
801012f3:	5b                   	pop    %ebx
801012f4:	5e                   	pop    %esi
801012f5:	5f                   	pop    %edi
801012f6:	5d                   	pop    %ebp
801012f7:	c3                   	ret    
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
      a[bn] = addr = balloc(ip->dev);
801012f8:	8b 03                	mov    (%ebx),%eax
801012fa:	e8 ed fd ff ff       	call   801010ec <balloc>
801012ff:	89 06                	mov    %eax,(%esi)
      log_write(bp);
80101301:	89 3c 24             	mov    %edi,(%esp)
80101304:	89 45 dc             	mov    %eax,-0x24(%ebp)
80101307:	e8 4c 17 00 00       	call   80102a58 <log_write>
8010130c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010130f:	e9 27 ff ff ff       	jmp    8010123b <bmap.part.0+0x3f>
  
  //First-order indirection block
  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101314:	8b 03                	mov    (%ebx),%eax
80101316:	e8 d1 fd ff ff       	call   801010ec <balloc>
8010131b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
80101321:	e9 f7 fe ff ff       	jmp    8010121d <bmap.part.0+0x21>
80101326:	66 90                	xchg   %ax,%ax
      
    bp = bread(ip->dev, addr);
    // First level index
    a = (uint*)bp->data;
    if((addr = a[bn/NINDIRECT]) == 0){
      a[bn/NINDIRECT] = addr = balloc(ip->dev);
80101328:	8b 03                	mov    (%ebx),%eax
8010132a:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010132d:	e8 ba fd ff ff       	call   801010ec <balloc>
80101332:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101335:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101337:	89 34 24             	mov    %esi,(%esp)
8010133a:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010133d:	e8 16 17 00 00       	call   80102a58 <log_write>
80101342:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101345:	e9 53 ff ff ff       	jmp    8010129d <bmap.part.0+0xa1>
8010134a:	66 90                	xchg   %ax,%ax
  
  //Second-order indirection block
  if(bn < NDINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT+1]) == 0)
      ip->addrs[NDIRECT+1] = addr = balloc(ip->dev);
8010134c:	8b 03                	mov    (%ebx),%eax
8010134e:	e8 99 fd ff ff       	call   801010ec <balloc>
80101353:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
80101359:	e9 19 ff ff ff       	jmp    80101277 <bmap.part.0+0x7b>
    brelse(bp2);
    return addr;
  }
  

  panic("bmap: out of range");
8010135e:	c7 04 24 f8 68 10 80 	movl   $0x801068f8,(%esp)
80101365:	e8 b2 ef ff ff       	call   8010031c <panic>
8010136a:	66 90                	xchg   %ax,%ax

8010136c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010136c:	55                   	push   %ebp
8010136d:	89 e5                	mov    %esp,%ebp
8010136f:	56                   	push   %esi
80101370:	53                   	push   %ebx
80101371:	83 ec 10             	sub    $0x10,%esp
80101374:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct buf *bp;

  bp = bread(dev, 1);
80101377:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010137e:	00 
8010137f:	8b 45 08             	mov    0x8(%ebp),%eax
80101382:	89 04 24             	mov    %eax,(%esp)
80101385:	e8 2a ed ff ff       	call   801000b4 <bread>
8010138a:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010138c:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101393:	00 
80101394:	8d 40 5c             	lea    0x5c(%eax),%eax
80101397:	89 44 24 04          	mov    %eax,0x4(%esp)
8010139b:	89 34 24             	mov    %esi,(%esp)
8010139e:	e8 c5 2b 00 00       	call   80103f68 <memmove>
  brelse(bp);
801013a3:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801013a6:	83 c4 10             	add    $0x10,%esp
801013a9:	5b                   	pop    %ebx
801013aa:	5e                   	pop    %esi
801013ab:	5d                   	pop    %ebp
{
  struct buf *bp;

  bp = bread(dev, 1);
  memmove(sb, bp->data, sizeof(*sb));
  brelse(bp);
801013ac:	e9 f7 ed ff ff       	jmp    801001a8 <brelse>
801013b1:	8d 76 00             	lea    0x0(%esi),%esi

801013b4 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801013b4:	55                   	push   %ebp
801013b5:	89 e5                	mov    %esp,%ebp
801013b7:	53                   	push   %ebx
801013b8:	83 ec 24             	sub    $0x24,%esp
  int i = 0;
  
  initlock(&icache.lock, "icache");
801013bb:	c7 44 24 04 0b 69 10 	movl   $0x8010690b,0x4(%esp)
801013c2:	80 
801013c3:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801013ca:	e8 21 29 00 00       	call   80103cf0 <initlock>
  for(i = 0; i < NINODE; i++) {
801013cf:	31 db                	xor    %ebx,%ebx
801013d1:	8d 76 00             	lea    0x0(%esi),%esi
    initsleeplock(&icache.inode[i].lock, "inode");
801013d4:	c7 44 24 04 12 69 10 	movl   $0x80106912,0x4(%esp)
801013db:	80 
801013dc:	8d 04 db             	lea    (%ebx,%ebx,8),%eax
801013df:	c1 e0 04             	shl    $0x4,%eax
801013e2:	05 20 0a 11 80       	add    $0x80110a20,%eax
801013e7:	89 04 24             	mov    %eax,(%esp)
801013ea:	e8 f5 27 00 00       	call   80103be4 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
801013ef:	43                   	inc    %ebx
801013f0:	83 fb 32             	cmp    $0x32,%ebx
801013f3:	75 df                	jne    801013d4 <iinit+0x20>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
801013f5:	c7 44 24 04 c0 09 11 	movl   $0x801109c0,0x4(%esp)
801013fc:	80 
801013fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101400:	89 04 24             	mov    %eax,(%esp)
80101403:	e8 64 ff ff ff       	call   8010136c <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101408:	a1 d8 09 11 80       	mov    0x801109d8,%eax
8010140d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101411:	a1 d4 09 11 80       	mov    0x801109d4,%eax
80101416:	89 44 24 18          	mov    %eax,0x18(%esp)
8010141a:	a1 d0 09 11 80       	mov    0x801109d0,%eax
8010141f:	89 44 24 14          	mov    %eax,0x14(%esp)
80101423:	a1 cc 09 11 80       	mov    0x801109cc,%eax
80101428:	89 44 24 10          	mov    %eax,0x10(%esp)
8010142c:	a1 c8 09 11 80       	mov    0x801109c8,%eax
80101431:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101435:	a1 c4 09 11 80       	mov    0x801109c4,%eax
8010143a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010143e:	a1 c0 09 11 80       	mov    0x801109c0,%eax
80101443:	89 44 24 04          	mov    %eax,0x4(%esp)
80101447:	c7 04 24 78 69 10 80 	movl   $0x80106978,(%esp)
8010144e:	e8 69 f1 ff ff       	call   801005bc <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101453:	83 c4 24             	add    $0x24,%esp
80101456:	5b                   	pop    %ebx
80101457:	5d                   	pop    %ebp
80101458:	c3                   	ret    
80101459:	8d 76 00             	lea    0x0(%esi),%esi

8010145c <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010145c:	55                   	push   %ebp
8010145d:	89 e5                	mov    %esp,%ebp
8010145f:	57                   	push   %edi
80101460:	56                   	push   %esi
80101461:	53                   	push   %ebx
80101462:	83 ec 2c             	sub    $0x2c,%esp
80101465:	8b 45 08             	mov    0x8(%ebp),%eax
80101468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010146b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010146e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101472:	83 3d c8 09 11 80 01 	cmpl   $0x1,0x801109c8
80101479:	0f 86 94 00 00 00    	jbe    80101513 <ialloc+0xb7>
8010147f:	be 01 00 00 00       	mov    $0x1,%esi
80101484:	bb 01 00 00 00       	mov    $0x1,%ebx
80101489:	eb 14                	jmp    8010149f <ialloc+0x43>
8010148b:	90                   	nop
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
8010148c:	89 3c 24             	mov    %edi,(%esp)
8010148f:	e8 14 ed ff ff       	call   801001a8 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101494:	43                   	inc    %ebx
80101495:	89 de                	mov    %ebx,%esi
80101497:	3b 1d c8 09 11 80    	cmp    0x801109c8,%ebx
8010149d:	73 74                	jae    80101513 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010149f:	89 f0                	mov    %esi,%eax
801014a1:	c1 e8 03             	shr    $0x3,%eax
801014a4:	03 05 d4 09 11 80    	add    0x801109d4,%eax
801014aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801014ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014b1:	89 04 24             	mov    %eax,(%esp)
801014b4:	e8 fb eb ff ff       	call   801000b4 <bread>
801014b9:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
801014bb:	89 f0                	mov    %esi,%eax
801014bd:	83 e0 07             	and    $0x7,%eax
801014c0:	c1 e0 06             	shl    $0x6,%eax
801014c3:	8d 54 07 5c          	lea    0x5c(%edi,%eax,1),%edx
    if(dip->type == 0){  // a free inode
801014c7:	66 83 3a 00          	cmpw   $0x0,(%edx)
801014cb:	75 bf                	jne    8010148c <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801014cd:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801014d4:	00 
801014d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801014dc:	00 
801014dd:	89 14 24             	mov    %edx,(%esp)
801014e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
801014e3:	e8 f0 29 00 00       	call   80103ed8 <memset>
      dip->type = type;
801014e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801014eb:	66 8b 45 e2          	mov    -0x1e(%ebp),%ax
801014ef:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
801014f2:	89 3c 24             	mov    %edi,(%esp)
801014f5:	e8 5e 15 00 00       	call   80102a58 <log_write>
      brelse(bp);
801014fa:	89 3c 24             	mov    %edi,(%esp)
801014fd:	e8 a6 ec ff ff       	call   801001a8 <brelse>
      return iget(dev, inum);
80101502:	89 f2                	mov    %esi,%edx
80101504:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101507:	83 c4 2c             	add    $0x2c,%esp
8010150a:	5b                   	pop    %ebx
8010150b:	5e                   	pop    %esi
8010150c:	5f                   	pop    %edi
8010150d:	5d                   	pop    %ebp
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
8010150e:	e9 b1 fa ff ff       	jmp    80100fc4 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101513:	c7 04 24 18 69 10 80 	movl   $0x80106918,(%esp)
8010151a:	e8 fd ed ff ff       	call   8010031c <panic>
8010151f:	90                   	nop

80101520 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101520:	55                   	push   %ebp
80101521:	89 e5                	mov    %esp,%ebp
80101523:	56                   	push   %esi
80101524:	53                   	push   %ebx
80101525:	83 ec 10             	sub    $0x10,%esp
80101528:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010152b:	8b 43 04             	mov    0x4(%ebx),%eax
8010152e:	c1 e8 03             	shr    $0x3,%eax
80101531:	03 05 d4 09 11 80    	add    0x801109d4,%eax
80101537:	89 44 24 04          	mov    %eax,0x4(%esp)
8010153b:	8b 03                	mov    (%ebx),%eax
8010153d:	89 04 24             	mov    %eax,(%esp)
80101540:	e8 6f eb ff ff       	call   801000b4 <bread>
80101545:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101547:	8b 43 04             	mov    0x4(%ebx),%eax
8010154a:	83 e0 07             	and    $0x7,%eax
8010154d:	c1 e0 06             	shl    $0x6,%eax
80101550:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101554:	8b 53 50             	mov    0x50(%ebx),%edx
80101557:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010155a:	66 8b 53 52          	mov    0x52(%ebx),%dx
8010155e:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101562:	8b 53 54             	mov    0x54(%ebx),%edx
80101565:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101569:	66 8b 53 56          	mov    0x56(%ebx),%dx
8010156d:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101571:	8b 53 58             	mov    0x58(%ebx),%edx
80101574:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101577:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010157e:	00 
8010157f:	83 c3 5c             	add    $0x5c,%ebx
80101582:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101586:	83 c0 0c             	add    $0xc,%eax
80101589:	89 04 24             	mov    %eax,(%esp)
8010158c:	e8 d7 29 00 00       	call   80103f68 <memmove>
  log_write(bp);
80101591:	89 34 24             	mov    %esi,(%esp)
80101594:	e8 bf 14 00 00       	call   80102a58 <log_write>
  brelse(bp);
80101599:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010159c:	83 c4 10             	add    $0x10,%esp
8010159f:	5b                   	pop    %ebx
801015a0:	5e                   	pop    %esi
801015a1:	5d                   	pop    %ebp
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  log_write(bp);
  brelse(bp);
801015a2:	e9 01 ec ff ff       	jmp    801001a8 <brelse>
801015a7:	90                   	nop

801015a8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	53                   	push   %ebx
801015ac:	83 ec 14             	sub    $0x14,%esp
801015af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801015b2:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801015b9:	e8 6e 28 00 00       	call   80103e2c <acquire>
  ip->ref++;
801015be:	ff 43 08             	incl   0x8(%ebx)
  release(&icache.lock);
801015c1:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801015c8:	e8 c3 28 00 00       	call   80103e90 <release>
  return ip;
}
801015cd:	89 d8                	mov    %ebx,%eax
801015cf:	83 c4 14             	add    $0x14,%esp
801015d2:	5b                   	pop    %ebx
801015d3:	5d                   	pop    %ebp
801015d4:	c3                   	ret    
801015d5:	8d 76 00             	lea    0x0(%esi),%esi

801015d8 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801015d8:	55                   	push   %ebp
801015d9:	89 e5                	mov    %esp,%ebp
801015db:	56                   	push   %esi
801015dc:	53                   	push   %ebx
801015dd:	83 ec 10             	sub    $0x10,%esp
801015e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801015e3:	85 db                	test   %ebx,%ebx
801015e5:	0f 84 b1 00 00 00    	je     8010169c <ilock+0xc4>
801015eb:	8b 4b 08             	mov    0x8(%ebx),%ecx
801015ee:	85 c9                	test   %ecx,%ecx
801015f0:	0f 8e a6 00 00 00    	jle    8010169c <ilock+0xc4>
    panic("ilock");

  acquiresleep(&ip->lock);
801015f6:	8d 43 0c             	lea    0xc(%ebx),%eax
801015f9:	89 04 24             	mov    %eax,(%esp)
801015fc:	e8 1b 26 00 00       	call   80103c1c <acquiresleep>

  if(ip->valid == 0){
80101601:	8b 53 4c             	mov    0x4c(%ebx),%edx
80101604:	85 d2                	test   %edx,%edx
80101606:	74 08                	je     80101610 <ilock+0x38>
    brelse(bp);
    ip->valid = 1;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}
80101608:	83 c4 10             	add    $0x10,%esp
8010160b:	5b                   	pop    %ebx
8010160c:	5e                   	pop    %esi
8010160d:	5d                   	pop    %ebp
8010160e:	c3                   	ret    
8010160f:	90                   	nop
    panic("ilock");

  acquiresleep(&ip->lock);

  if(ip->valid == 0){
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101610:	8b 43 04             	mov    0x4(%ebx),%eax
80101613:	c1 e8 03             	shr    $0x3,%eax
80101616:	03 05 d4 09 11 80    	add    0x801109d4,%eax
8010161c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101620:	8b 03                	mov    (%ebx),%eax
80101622:	89 04 24             	mov    %eax,(%esp)
80101625:	e8 8a ea ff ff       	call   801000b4 <bread>
8010162a:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010162c:	8b 43 04             	mov    0x4(%ebx),%eax
8010162f:	83 e0 07             	and    $0x7,%eax
80101632:	c1 e0 06             	shl    $0x6,%eax
80101635:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101639:	8b 10                	mov    (%eax),%edx
8010163b:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
8010163f:	66 8b 50 02          	mov    0x2(%eax),%dx
80101643:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
80101647:	8b 50 04             	mov    0x4(%eax),%edx
8010164a:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
8010164e:	66 8b 50 06          	mov    0x6(%eax),%dx
80101652:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101656:	8b 50 08             	mov    0x8(%eax),%edx
80101659:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010165c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101663:	00 
80101664:	83 c0 0c             	add    $0xc,%eax
80101667:	89 44 24 04          	mov    %eax,0x4(%esp)
8010166b:	8d 43 5c             	lea    0x5c(%ebx),%eax
8010166e:	89 04 24             	mov    %eax,(%esp)
80101671:	e8 f2 28 00 00       	call   80103f68 <memmove>
    brelse(bp);
80101676:	89 34 24             	mov    %esi,(%esp)
80101679:	e8 2a eb ff ff       	call   801001a8 <brelse>
    ip->valid = 1;
8010167e:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101685:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
8010168a:	0f 85 78 ff ff ff    	jne    80101608 <ilock+0x30>
      panic("ilock: no type");
80101690:	c7 04 24 30 69 10 80 	movl   $0x80106930,(%esp)
80101697:	e8 80 ec ff ff       	call   8010031c <panic>
{
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    panic("ilock");
8010169c:	c7 04 24 2a 69 10 80 	movl   $0x8010692a,(%esp)
801016a3:	e8 74 ec ff ff       	call   8010031c <panic>

801016a8 <iunlock>:
}

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801016a8:	55                   	push   %ebp
801016a9:	89 e5                	mov    %esp,%ebp
801016ab:	56                   	push   %esi
801016ac:	53                   	push   %ebx
801016ad:	83 ec 10             	sub    $0x10,%esp
801016b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801016b3:	85 db                	test   %ebx,%ebx
801016b5:	74 24                	je     801016db <iunlock+0x33>
801016b7:	8d 73 0c             	lea    0xc(%ebx),%esi
801016ba:	89 34 24             	mov    %esi,(%esp)
801016bd:	e8 e6 25 00 00       	call   80103ca8 <holdingsleep>
801016c2:	85 c0                	test   %eax,%eax
801016c4:	74 15                	je     801016db <iunlock+0x33>
801016c6:	8b 5b 08             	mov    0x8(%ebx),%ebx
801016c9:	85 db                	test   %ebx,%ebx
801016cb:	7e 0e                	jle    801016db <iunlock+0x33>
    panic("iunlock");

  releasesleep(&ip->lock);
801016cd:	89 75 08             	mov    %esi,0x8(%ebp)
}
801016d0:	83 c4 10             	add    $0x10,%esp
801016d3:	5b                   	pop    %ebx
801016d4:	5e                   	pop    %esi
801016d5:	5d                   	pop    %ebp
iunlock(struct inode *ip)
{
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    panic("iunlock");

  releasesleep(&ip->lock);
801016d6:	e9 91 25 00 00       	jmp    80103c6c <releasesleep>
// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    panic("iunlock");
801016db:	c7 04 24 3f 69 10 80 	movl   $0x8010693f,(%esp)
801016e2:	e8 35 ec ff ff       	call   8010031c <panic>
801016e7:	90                   	nop

801016e8 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
801016e8:	55                   	push   %ebp
801016e9:	89 e5                	mov    %esp,%ebp
801016eb:	57                   	push   %edi
801016ec:	56                   	push   %esi
801016ed:	53                   	push   %ebx
801016ee:	83 ec 2c             	sub    $0x2c,%esp
801016f1:	8b 75 08             	mov    0x8(%ebp),%esi
  acquiresleep(&ip->lock);
801016f4:	8d 7e 0c             	lea    0xc(%esi),%edi
801016f7:	89 3c 24             	mov    %edi,(%esp)
801016fa:	e8 1d 25 00 00       	call   80103c1c <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801016ff:	8b 46 4c             	mov    0x4c(%esi),%eax
80101702:	85 c0                	test   %eax,%eax
80101704:	74 07                	je     8010170d <iput+0x25>
80101706:	66 83 7e 56 00       	cmpw   $0x0,0x56(%esi)
8010170b:	74 2b                	je     80101738 <iput+0x50>
      ip->type = 0;
      iupdate(ip);
      ip->valid = 0;
    }
  }
  releasesleep(&ip->lock);
8010170d:	89 3c 24             	mov    %edi,(%esp)
80101710:	e8 57 25 00 00       	call   80103c6c <releasesleep>

  acquire(&icache.lock);
80101715:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
8010171c:	e8 0b 27 00 00       	call   80103e2c <acquire>
  ip->ref--;
80101721:	ff 4e 08             	decl   0x8(%esi)
  release(&icache.lock);
80101724:	c7 45 08 e0 09 11 80 	movl   $0x801109e0,0x8(%ebp)
}
8010172b:	83 c4 2c             	add    $0x2c,%esp
8010172e:	5b                   	pop    %ebx
8010172f:	5e                   	pop    %esi
80101730:	5f                   	pop    %edi
80101731:	5d                   	pop    %ebp
  }
  releasesleep(&ip->lock);

  acquire(&icache.lock);
  ip->ref--;
  release(&icache.lock);
80101732:	e9 59 27 00 00       	jmp    80103e90 <release>
80101737:	90                   	nop
void
iput(struct inode *ip)
{
  acquiresleep(&ip->lock);
  if(ip->valid && ip->nlink == 0){
    acquire(&icache.lock);
80101738:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
8010173f:	e8 e8 26 00 00       	call   80103e2c <acquire>
    int r = ip->ref;
80101744:	8b 5e 08             	mov    0x8(%esi),%ebx
    release(&icache.lock);
80101747:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
8010174e:	e8 3d 27 00 00       	call   80103e90 <release>
    if(r == 1){
80101753:	4b                   	dec    %ebx
80101754:	75 b7                	jne    8010170d <iput+0x25>
80101756:	89 f3                	mov    %esi,%ebx
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
80101758:	8d 4e 2c             	lea    0x2c(%esi),%ecx
8010175b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010175e:	89 cf                	mov    %ecx,%edi
80101760:	eb 09                	jmp    8010176b <iput+0x83>
80101762:	66 90                	xchg   %ax,%ax
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
80101764:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101767:	39 fb                	cmp    %edi,%ebx
80101769:	74 19                	je     80101784 <iput+0x9c>
    if(ip->addrs[i]){
8010176b:	8b 53 5c             	mov    0x5c(%ebx),%edx
8010176e:	85 d2                	test   %edx,%edx
80101770:	74 f2                	je     80101764 <iput+0x7c>
      bfree(ip->dev, ip->addrs[i]);
80101772:	8b 06                	mov    (%esi),%eax
80101774:	e8 ff f8 ff ff       	call   80101078 <bfree>
      ip->addrs[i] = 0;
80101779:	c7 43 5c 00 00 00 00 	movl   $0x0,0x5c(%ebx)
80101780:	eb e2                	jmp    80101764 <iput+0x7c>
80101782:	66 90                	xchg   %ax,%ax
80101784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    }
  }

  if(ip->addrs[NDIRECT]){
80101787:	8b 86 88 00 00 00    	mov    0x88(%esi),%eax
8010178d:	85 c0                	test   %eax,%eax
8010178f:	75 2b                	jne    801017bc <iput+0xd4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
80101791:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
80101798:	89 34 24             	mov    %esi,(%esp)
8010179b:	e8 80 fd ff ff       	call   80101520 <iupdate>
    int r = ip->ref;
    release(&icache.lock);
    if(r == 1){
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
      ip->type = 0;
801017a0:	66 c7 46 50 00 00    	movw   $0x0,0x50(%esi)
      iupdate(ip);
801017a6:	89 34 24             	mov    %esi,(%esp)
801017a9:	e8 72 fd ff ff       	call   80101520 <iupdate>
      ip->valid = 0;
801017ae:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
801017b5:	e9 53 ff ff ff       	jmp    8010170d <iput+0x25>
801017ba:	66 90                	xchg   %ax,%ax
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801017bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801017c0:	8b 06                	mov    (%esi),%eax
801017c2:	89 04 24             	mov    %eax,(%esp)
801017c5:	e8 ea e8 ff ff       	call   801000b4 <bread>
801017ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
801017cd:	89 c1                	mov    %eax,%ecx
801017cf:	83 c1 5c             	add    $0x5c,%ecx
    for(j = 0; j < NINDIRECT; j++){
801017d2:	31 c0                	xor    %eax,%eax
801017d4:	31 db                	xor    %ebx,%ebx
801017d6:	89 7d e0             	mov    %edi,-0x20(%ebp)
801017d9:	89 f7                	mov    %esi,%edi
801017db:	89 ce                	mov    %ecx,%esi
801017dd:	eb 0c                	jmp    801017eb <iput+0x103>
801017df:	90                   	nop
801017e0:	43                   	inc    %ebx
801017e1:	89 d8                	mov    %ebx,%eax
801017e3:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
801017e9:	74 10                	je     801017fb <iput+0x113>
      if(a[j])
801017eb:	8b 14 86             	mov    (%esi,%eax,4),%edx
801017ee:	85 d2                	test   %edx,%edx
801017f0:	74 ee                	je     801017e0 <iput+0xf8>
        bfree(ip->dev, a[j]);
801017f2:	8b 07                	mov    (%edi),%eax
801017f4:	e8 7f f8 ff ff       	call   80101078 <bfree>
801017f9:	eb e5                	jmp    801017e0 <iput+0xf8>
801017fb:	89 fe                	mov    %edi,%esi
801017fd:	8b 7d e0             	mov    -0x20(%ebp),%edi
    }
    brelse(bp);
80101800:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101803:	89 04 24             	mov    %eax,(%esp)
80101806:	e8 9d e9 ff ff       	call   801001a8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
8010180b:	8b 96 88 00 00 00    	mov    0x88(%esi),%edx
80101811:	8b 06                	mov    (%esi),%eax
80101813:	e8 60 f8 ff ff       	call   80101078 <bfree>
    ip->addrs[NDIRECT] = 0;
80101818:	c7 86 88 00 00 00 00 	movl   $0x0,0x88(%esi)
8010181f:	00 00 00 
80101822:	e9 6a ff ff ff       	jmp    80101791 <iput+0xa9>
80101827:	90                   	nop

80101828 <iunlockput>:
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101828:	55                   	push   %ebp
80101829:	89 e5                	mov    %esp,%ebp
8010182b:	53                   	push   %ebx
8010182c:	83 ec 14             	sub    $0x14,%esp
8010182f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101832:	89 1c 24             	mov    %ebx,(%esp)
80101835:	e8 6e fe ff ff       	call   801016a8 <iunlock>
  iput(ip);
8010183a:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010183d:	83 c4 14             	add    $0x14,%esp
80101840:	5b                   	pop    %ebx
80101841:	5d                   	pop    %ebp
// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
80101842:	e9 a1 fe ff ff       	jmp    801016e8 <iput>
80101847:	90                   	nop

80101848 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101848:	55                   	push   %ebp
80101849:	89 e5                	mov    %esp,%ebp
8010184b:	8b 55 08             	mov    0x8(%ebp),%edx
8010184e:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101851:	8b 0a                	mov    (%edx),%ecx
80101853:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101856:	8b 4a 04             	mov    0x4(%edx),%ecx
80101859:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010185c:	8b 4a 50             	mov    0x50(%edx),%ecx
8010185f:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101862:	66 8b 4a 56          	mov    0x56(%edx),%cx
80101866:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
8010186a:	8b 52 58             	mov    0x58(%edx),%edx
8010186d:	89 50 10             	mov    %edx,0x10(%eax)
}
80101870:	5d                   	pop    %ebp
80101871:	c3                   	ret    
80101872:	66 90                	xchg   %ax,%ax

80101874 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101874:	55                   	push   %ebp
80101875:	89 e5                	mov    %esp,%ebp
80101877:	57                   	push   %edi
80101878:	56                   	push   %esi
80101879:	53                   	push   %ebx
8010187a:	83 ec 2c             	sub    $0x2c,%esp
8010187d:	8b 75 08             	mov    0x8(%ebp),%esi
80101880:	8b 45 0c             	mov    0xc(%ebp),%eax
80101883:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101886:	8b 5d 10             	mov    0x10(%ebp),%ebx
80101889:	8b 55 14             	mov    0x14(%ebp),%edx
8010188c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010188f:	66 83 7e 50 03       	cmpw   $0x3,0x50(%esi)
80101894:	0f 84 da 00 00 00    	je     80101974 <readi+0x100>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
8010189a:	8b 46 58             	mov    0x58(%esi),%eax
8010189d:	39 d8                	cmp    %ebx,%eax
8010189f:	0f 82 f3 00 00 00    	jb     80101998 <readi+0x124>
801018a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
801018a8:	01 da                	add    %ebx,%edx
801018aa:	0f 82 e8 00 00 00    	jb     80101998 <readi+0x124>
    return -1;
  if(off + n > ip->size)
801018b0:	39 d0                	cmp    %edx,%eax
801018b2:	0f 82 b0 00 00 00    	jb     80101968 <readi+0xf4>
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801018b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801018bb:	85 c0                	test   %eax,%eax
801018bd:	0f 84 99 00 00 00    	je     8010195c <readi+0xe8>
801018c3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801018ca:	eb 6a                	jmp    80101936 <readi+0xc2>
  struct buf *bp;
  struct buf *bp2;

  //Direct block
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
801018cc:	8d 7a 14             	lea    0x14(%edx),%edi
801018cf:	8b 44 be 0c          	mov    0xc(%esi,%edi,4),%eax
801018d3:	85 c0                	test   %eax,%eax
801018d5:	74 75                	je     8010194c <readi+0xd8>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801018db:	8b 06                	mov    (%esi),%eax
801018dd:	89 04 24             	mov    %eax,(%esp)
801018e0:	e8 cf e7 ff ff       	call   801000b4 <bread>
801018e5:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
801018e7:	89 d8                	mov    %ebx,%eax
801018e9:	25 ff 01 00 00       	and    $0x1ff,%eax
801018ee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801018f1:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
801018f4:	bf 00 02 00 00       	mov    $0x200,%edi
801018f9:	29 c7                	sub    %eax,%edi
801018fb:	39 cf                	cmp    %ecx,%edi
801018fd:	76 02                	jbe    80101901 <readi+0x8d>
801018ff:	89 cf                	mov    %ecx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
80101901:	89 7c 24 08          	mov    %edi,0x8(%esp)
80101905:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
80101909:	89 44 24 04          	mov    %eax,0x4(%esp)
8010190d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101910:	89 04 24             	mov    %eax,(%esp)
80101913:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101916:	e8 4d 26 00 00       	call   80103f68 <memmove>
    brelse(bp);
8010191b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010191e:	89 14 24             	mov    %edx,(%esp)
80101921:	e8 82 e8 ff ff       	call   801001a8 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101926:	01 7d e4             	add    %edi,-0x1c(%ebp)
80101929:	01 fb                	add    %edi,%ebx
8010192b:	01 7d e0             	add    %edi,-0x20(%ebp)
8010192e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101931:	39 55 dc             	cmp    %edx,-0x24(%ebp)
80101934:	76 26                	jbe    8010195c <readi+0xe8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101936:	89 da                	mov    %ebx,%edx
80101938:	c1 ea 09             	shr    $0x9,%edx
  uint addr, *a;
  struct buf *bp;
  struct buf *bp2;

  //Direct block
  if(bn < NDIRECT){
8010193b:	83 fa 0a             	cmp    $0xa,%edx
8010193e:	76 8c                	jbe    801018cc <readi+0x58>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
80101940:	89 f0                	mov    %esi,%eax
80101942:	e8 b5 f8 ff ff       	call   801011fc <bmap.part.0>
80101947:	eb 8e                	jmp    801018d7 <readi+0x63>
80101949:	8d 76 00             	lea    0x0(%esi),%esi
8010194c:	8b 06                	mov    (%esi),%eax
8010194e:	e8 99 f7 ff ff       	call   801010ec <balloc>
80101953:	89 44 be 0c          	mov    %eax,0xc(%esi,%edi,4)
80101957:	e9 7b ff ff ff       	jmp    801018d7 <readi+0x63>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010195c:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010195f:	83 c4 2c             	add    $0x2c,%esp
80101962:	5b                   	pop    %ebx
80101963:	5e                   	pop    %esi
80101964:	5f                   	pop    %edi
80101965:	5d                   	pop    %ebp
80101966:	c3                   	ret    
80101967:	90                   	nop
  }

  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101968:	29 d8                	sub    %ebx,%eax
8010196a:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010196d:	e9 46 ff ff ff       	jmp    801018b8 <readi+0x44>
80101972:	66 90                	xchg   %ax,%ax
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101974:	66 8b 46 52          	mov    0x52(%esi),%ax
80101978:	66 83 f8 09          	cmp    $0x9,%ax
8010197c:	77 1a                	ja     80101998 <readi+0x124>
8010197e:	98                   	cwtl   
8010197f:	8b 04 c5 60 09 11 80 	mov    -0x7feef6a0(,%eax,8),%eax
80101986:	85 c0                	test   %eax,%eax
80101988:	74 0e                	je     80101998 <readi+0x124>
      return -1;
    return devsw[ip->major].read(ip, dst, n);
8010198a:	89 55 10             	mov    %edx,0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
}
8010198d:	83 c4 2c             	add    $0x2c,%esp
80101990:	5b                   	pop    %ebx
80101991:	5e                   	pop    %esi
80101992:	5f                   	pop    %edi
80101993:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
80101994:	ff e0                	jmp    *%eax
80101996:	66 90                	xchg   %ax,%ax
  }

  if(off > ip->size || off + n < off)
    return -1;
80101998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010199d:	eb c0                	jmp    8010195f <readi+0xeb>
8010199f:	90                   	nop

801019a0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801019a0:	55                   	push   %ebp
801019a1:	89 e5                	mov    %esp,%ebp
801019a3:	57                   	push   %edi
801019a4:	56                   	push   %esi
801019a5:	53                   	push   %ebx
801019a6:	83 ec 2c             	sub    $0x2c,%esp
801019a9:	8b 75 08             	mov    0x8(%ebp),%esi
801019ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801019af:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801019b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
801019b5:	8b 4d 14             	mov    0x14(%ebp),%ecx
801019b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801019bb:	66 83 7e 50 03       	cmpw   $0x3,0x50(%esi)
801019c0:	0f 84 ea 00 00 00    	je     80101ab0 <writei+0x110>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
801019c6:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019c9:	0f 82 05 01 00 00    	jb     80101ad4 <writei+0x134>
801019cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
801019d2:	01 d8                	add    %ebx,%eax
801019d4:	0f 82 fa 00 00 00    	jb     80101ad4 <writei+0x134>
    return -1;
  if(off + n > MAXFILE*BSIZE)
801019da:	3d 00 16 81 00       	cmp    $0x811600,%eax
801019df:	0f 87 ef 00 00 00    	ja     80101ad4 <writei+0x134>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801019e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801019e8:	85 c0                	test   %eax,%eax
801019ea:	0f 84 b4 00 00 00    	je     80101aa4 <writei+0x104>
801019f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801019f7:	eb 78                	jmp    80101a71 <writei+0xd1>
801019f9:	8d 76 00             	lea    0x0(%esi),%esi
  struct buf *bp;
  struct buf *bp2;

  //Direct block
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
801019fc:	8d 7a 14             	lea    0x14(%edx),%edi
801019ff:	8b 44 be 0c          	mov    0xc(%esi,%edi,4),%eax
80101a03:	85 c0                	test   %eax,%eax
80101a05:	74 7d                	je     80101a84 <writei+0xe4>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101a07:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a0b:	8b 06                	mov    (%esi),%eax
80101a0d:	89 04 24             	mov    %eax,(%esp)
80101a10:	e8 9f e6 ff ff       	call   801000b4 <bread>
80101a15:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101a17:	89 d8                	mov    %ebx,%eax
80101a19:	25 ff 01 00 00       	and    $0x1ff,%eax
80101a1e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80101a21:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
80101a24:	bf 00 02 00 00       	mov    $0x200,%edi
80101a29:	29 c7                	sub    %eax,%edi
80101a2b:	39 cf                	cmp    %ecx,%edi
80101a2d:	76 02                	jbe    80101a31 <writei+0x91>
80101a2f:	89 cf                	mov    %ecx,%edi
    memmove(bp->data + off%BSIZE, src, m);
80101a31:	89 7c 24 08          	mov    %edi,0x8(%esp)
80101a35:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80101a38:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80101a3c:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
80101a40:	89 04 24             	mov    %eax,(%esp)
80101a43:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101a46:	e8 1d 25 00 00       	call   80103f68 <memmove>
    log_write(bp);
80101a4b:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101a4e:	89 14 24             	mov    %edx,(%esp)
80101a51:	e8 02 10 00 00       	call   80102a58 <log_write>
    brelse(bp);
80101a56:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101a59:	89 14 24             	mov    %edx,(%esp)
80101a5c:	e8 47 e7 ff ff       	call   801001a8 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101a61:	01 7d e4             	add    %edi,-0x1c(%ebp)
80101a64:	01 fb                	add    %edi,%ebx
80101a66:	01 7d e0             	add    %edi,-0x20(%ebp)
80101a69:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101a6c:	39 4d dc             	cmp    %ecx,-0x24(%ebp)
80101a6f:	76 23                	jbe    80101a94 <writei+0xf4>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101a71:	89 da                	mov    %ebx,%edx
80101a73:	c1 ea 09             	shr    $0x9,%edx
  uint addr, *a;
  struct buf *bp;
  struct buf *bp2;

  //Direct block
  if(bn < NDIRECT){
80101a76:	83 fa 0a             	cmp    $0xa,%edx
80101a79:	76 81                	jbe    801019fc <writei+0x5c>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
80101a7b:	89 f0                	mov    %esi,%eax
80101a7d:	e8 7a f7 ff ff       	call   801011fc <bmap.part.0>
80101a82:	eb 83                	jmp    80101a07 <writei+0x67>
80101a84:	8b 06                	mov    (%esi),%eax
80101a86:	e8 61 f6 ff ff       	call   801010ec <balloc>
80101a8b:	89 44 be 0c          	mov    %eax,0xc(%esi,%edi,4)
80101a8f:	e9 73 ff ff ff       	jmp    80101a07 <writei+0x67>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80101a94:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101a97:	73 0b                	jae    80101aa4 <writei+0x104>
    ip->size = off;
80101a99:	89 5e 58             	mov    %ebx,0x58(%esi)
    iupdate(ip);
80101a9c:	89 34 24             	mov    %esi,(%esp)
80101a9f:	e8 7c fa ff ff       	call   80101520 <iupdate>
  }
  return n;
80101aa4:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80101aa7:	83 c4 2c             	add    $0x2c,%esp
80101aaa:	5b                   	pop    %ebx
80101aab:	5e                   	pop    %esi
80101aac:	5f                   	pop    %edi
80101aad:	5d                   	pop    %ebp
80101aae:	c3                   	ret    
80101aaf:	90                   	nop
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ab0:	66 8b 46 52          	mov    0x52(%esi),%ax
80101ab4:	66 83 f8 09          	cmp    $0x9,%ax
80101ab8:	77 1a                	ja     80101ad4 <writei+0x134>
80101aba:	98                   	cwtl   
80101abb:	8b 04 c5 64 09 11 80 	mov    -0x7feef69c(,%eax,8),%eax
80101ac2:	85 c0                	test   %eax,%eax
80101ac4:	74 0e                	je     80101ad4 <writei+0x134>
      return -1;
    return devsw[ip->major].write(ip, src, n);
80101ac6:	89 4d 10             	mov    %ecx,0x10(%ebp)
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
80101ac9:	83 c4 2c             	add    $0x2c,%esp
80101acc:	5b                   	pop    %ebx
80101acd:	5e                   	pop    %esi
80101ace:	5f                   	pop    %edi
80101acf:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
80101ad0:	ff e0                	jmp    *%eax
80101ad2:	66 90                	xchg   %ax,%ax
  }

  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;
80101ad4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
80101ad9:	83 c4 2c             	add    $0x2c,%esp
80101adc:	5b                   	pop    %ebx
80101add:	5e                   	pop    %esi
80101ade:	5f                   	pop    %edi
80101adf:	5d                   	pop    %ebp
80101ae0:	c3                   	ret    
80101ae1:	8d 76 00             	lea    0x0(%esi),%esi

80101ae4 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101ae4:	55                   	push   %ebp
80101ae5:	89 e5                	mov    %esp,%ebp
80101ae7:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80101aea:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101af1:	00 
80101af2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101af5:	89 44 24 04          	mov    %eax,0x4(%esp)
80101af9:	8b 45 08             	mov    0x8(%ebp),%eax
80101afc:	89 04 24             	mov    %eax,(%esp)
80101aff:	e8 c4 24 00 00       	call   80103fc8 <strncmp>
}
80101b04:	c9                   	leave  
80101b05:	c3                   	ret    
80101b06:	66 90                	xchg   %ax,%ax

80101b08 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101b08:	55                   	push   %ebp
80101b09:	89 e5                	mov    %esp,%ebp
80101b0b:	57                   	push   %edi
80101b0c:	56                   	push   %esi
80101b0d:	53                   	push   %ebx
80101b0e:	83 ec 2c             	sub    $0x2c,%esp
80101b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101b14:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101b19:	0f 85 8b 00 00 00    	jne    80101baa <dirlookup+0xa2>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101b1f:	8b 43 58             	mov    0x58(%ebx),%eax
80101b22:	85 c0                	test   %eax,%eax
80101b24:	74 6e                	je     80101b94 <dirlookup+0x8c>
80101b26:	31 f6                	xor    %esi,%esi
80101b28:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b2b:	eb 0b                	jmp    80101b38 <dirlookup+0x30>
80101b2d:	8d 76 00             	lea    0x0(%esi),%esi
80101b30:	83 c6 10             	add    $0x10,%esi
80101b33:	39 73 58             	cmp    %esi,0x58(%ebx)
80101b36:	76 5c                	jbe    80101b94 <dirlookup+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b38:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101b3f:	00 
80101b40:	89 74 24 08          	mov    %esi,0x8(%esp)
80101b44:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101b48:	89 1c 24             	mov    %ebx,(%esp)
80101b4b:	e8 24 fd ff ff       	call   80101874 <readi>
80101b50:	83 f8 10             	cmp    $0x10,%eax
80101b53:	75 49                	jne    80101b9e <dirlookup+0x96>
      panic("dirlookup read");
    if(de.inum == 0)
80101b55:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b5a:	74 d4                	je     80101b30 <dirlookup+0x28>
      continue;
    if(namecmp(name, de.name) == 0){
80101b5c:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101b63:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b66:	89 04 24             	mov    %eax,(%esp)
80101b69:	e8 76 ff ff ff       	call   80101ae4 <namecmp>
80101b6e:	85 c0                	test   %eax,%eax
80101b70:	75 be                	jne    80101b30 <dirlookup+0x28>
      // entry matches path element
      if(poff)
80101b72:	8b 45 10             	mov    0x10(%ebp),%eax
80101b75:	85 c0                	test   %eax,%eax
80101b77:	74 05                	je     80101b7e <dirlookup+0x76>
        *poff = off;
80101b79:	8b 45 10             	mov    0x10(%ebp),%eax
80101b7c:	89 30                	mov    %esi,(%eax)
      inum = de.inum;
80101b7e:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101b82:	8b 03                	mov    (%ebx),%eax
80101b84:	e8 3b f4 ff ff       	call   80100fc4 <iget>
    }
  }

  return 0;
}
80101b89:	83 c4 2c             	add    $0x2c,%esp
80101b8c:	5b                   	pop    %ebx
80101b8d:	5e                   	pop    %esi
80101b8e:	5f                   	pop    %edi
80101b8f:	5d                   	pop    %ebp
80101b90:	c3                   	ret    
80101b91:	8d 76 00             	lea    0x0(%esi),%esi
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80101b94:	31 c0                	xor    %eax,%eax
}
80101b96:	83 c4 2c             	add    $0x2c,%esp
80101b99:	5b                   	pop    %ebx
80101b9a:	5e                   	pop    %esi
80101b9b:	5f                   	pop    %edi
80101b9c:	5d                   	pop    %ebp
80101b9d:	c3                   	ret    
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
80101b9e:	c7 04 24 59 69 10 80 	movl   $0x80106959,(%esp)
80101ba5:	e8 72 e7 ff ff       	call   8010031c <panic>
{
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");
80101baa:	c7 04 24 47 69 10 80 	movl   $0x80106947,(%esp)
80101bb1:	e8 66 e7 ff ff       	call   8010031c <panic>
80101bb6:	66 90                	xchg   %ax,%ax

80101bb8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101bb8:	55                   	push   %ebp
80101bb9:	89 e5                	mov    %esp,%ebp
80101bbb:	57                   	push   %edi
80101bbc:	56                   	push   %esi
80101bbd:	53                   	push   %ebx
80101bbe:	83 ec 2c             	sub    $0x2c,%esp
80101bc1:	89 c3                	mov    %eax,%ebx
80101bc3:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101bc6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101bc9:	80 38 2f             	cmpb   $0x2f,(%eax)
80101bcc:	0f 84 01 01 00 00    	je     80101cd3 <namex+0x11b>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101bd2:	e8 e1 17 00 00       	call   801033b8 <myproc>
80101bd7:	8b 40 68             	mov    0x68(%eax),%eax
80101bda:	89 04 24             	mov    %eax,(%esp)
80101bdd:	e8 c6 f9 ff ff       	call   801015a8 <idup>
80101be2:	89 c7                	mov    %eax,%edi
80101be4:	eb 03                	jmp    80101be9 <namex+0x31>
80101be6:	66 90                	xchg   %ax,%ax
{
  char *s;
  int len;

  while(*path == '/')
    path++;
80101be8:	43                   	inc    %ebx
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80101be9:	8a 03                	mov    (%ebx),%al
80101beb:	3c 2f                	cmp    $0x2f,%al
80101bed:	74 f9                	je     80101be8 <namex+0x30>
    path++;
  if(*path == 0)
80101bef:	84 c0                	test   %al,%al
80101bf1:	75 15                	jne    80101c08 <namex+0x50>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101bf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101bf6:	85 c0                	test   %eax,%eax
80101bf8:	0f 85 22 01 00 00    	jne    80101d20 <namex+0x168>
    iput(ip);
    return 0;
  }
  return ip;
}
80101bfe:	89 f8                	mov    %edi,%eax
80101c00:	83 c4 2c             	add    $0x2c,%esp
80101c03:	5b                   	pop    %ebx
80101c04:	5e                   	pop    %esi
80101c05:	5f                   	pop    %edi
80101c06:	5d                   	pop    %ebp
80101c07:	c3                   	ret    
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101c08:	8a 03                	mov    (%ebx),%al
80101c0a:	89 de                	mov    %ebx,%esi
80101c0c:	3c 2f                	cmp    $0x2f,%al
80101c0e:	0f 84 95 00 00 00    	je     80101ca9 <namex+0xf1>
80101c14:	84 c0                	test   %al,%al
80101c16:	75 0c                	jne    80101c24 <namex+0x6c>
80101c18:	e9 8c 00 00 00       	jmp    80101ca9 <namex+0xf1>
80101c1d:	8d 76 00             	lea    0x0(%esi),%esi
80101c20:	84 c0                	test   %al,%al
80101c22:	74 07                	je     80101c2b <namex+0x73>
    path++;
80101c24:	46                   	inc    %esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101c25:	8a 06                	mov    (%esi),%al
80101c27:	3c 2f                	cmp    $0x2f,%al
80101c29:	75 f5                	jne    80101c20 <namex+0x68>
80101c2b:	89 f2                	mov    %esi,%edx
80101c2d:	29 da                	sub    %ebx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
80101c2f:	83 fa 0d             	cmp    $0xd,%edx
80101c32:	7e 78                	jle    80101cac <namex+0xf4>
    memmove(name, s, DIRSIZ);
80101c34:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101c3b:	00 
80101c3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101c40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c43:	89 04 24             	mov    %eax,(%esp)
80101c46:	e8 1d 23 00 00       	call   80103f68 <memmove>
80101c4b:	89 f3                	mov    %esi,%ebx
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80101c4d:	80 3e 2f             	cmpb   $0x2f,(%esi)
80101c50:	75 08                	jne    80101c5a <namex+0xa2>
80101c52:	66 90                	xchg   %ax,%ax
    path++;
80101c54:	43                   	inc    %ebx
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80101c55:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101c58:	74 fa                	je     80101c54 <namex+0x9c>
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80101c5a:	85 db                	test   %ebx,%ebx
80101c5c:	74 95                	je     80101bf3 <namex+0x3b>
    ilock(ip);
80101c5e:	89 3c 24             	mov    %edi,(%esp)
80101c61:	e8 72 f9 ff ff       	call   801015d8 <ilock>
    if(ip->type != T_DIR){
80101c66:	66 83 7f 50 01       	cmpw   $0x1,0x50(%edi)
80101c6b:	75 7c                	jne    80101ce9 <namex+0x131>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101c6d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101c70:	85 d2                	test   %edx,%edx
80101c72:	74 09                	je     80101c7d <namex+0xc5>
80101c74:	80 3b 00             	cmpb   $0x0,(%ebx)
80101c77:	0f 84 91 00 00 00    	je     80101d0e <namex+0x156>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101c7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80101c84:	00 
80101c85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c88:	89 44 24 04          	mov    %eax,0x4(%esp)
80101c8c:	89 3c 24             	mov    %edi,(%esp)
80101c8f:	e8 74 fe ff ff       	call   80101b08 <dirlookup>
80101c94:	89 c6                	mov    %eax,%esi
      iunlockput(ip);
80101c96:	89 3c 24             	mov    %edi,(%esp)
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101c99:	85 c0                	test   %eax,%eax
80101c9b:	74 60                	je     80101cfd <namex+0x145>
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
80101c9d:	e8 86 fb ff ff       	call   80101828 <iunlockput>
    ip = next;
80101ca2:	89 f7                	mov    %esi,%edi
80101ca4:	e9 40 ff ff ff       	jmp    80101be9 <namex+0x31>
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101ca9:	31 d2                	xor    %edx,%edx
80101cab:	90                   	nop
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80101cac:	89 54 24 08          	mov    %edx,0x8(%esp)
80101cb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101cb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101cb7:	89 04 24             	mov    %eax,(%esp)
80101cba:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101cbd:	e8 a6 22 00 00       	call   80103f68 <memmove>
    name[len] = 0;
80101cc2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101cc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101cc8:	c6 04 10 00          	movb   $0x0,(%eax,%edx,1)
80101ccc:	89 f3                	mov    %esi,%ebx
80101cce:	e9 7a ff ff ff       	jmp    80101c4d <namex+0x95>
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
80101cd3:	ba 01 00 00 00       	mov    $0x1,%edx
80101cd8:	b8 01 00 00 00       	mov    $0x1,%eax
80101cdd:	e8 e2 f2 ff ff       	call   80100fc4 <iget>
80101ce2:	89 c7                	mov    %eax,%edi
80101ce4:	e9 00 ff ff ff       	jmp    80101be9 <namex+0x31>
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101ce9:	89 3c 24             	mov    %edi,(%esp)
80101cec:	e8 37 fb ff ff       	call   80101828 <iunlockput>
      return 0;
80101cf1:	31 ff                	xor    %edi,%edi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101cf3:	89 f8                	mov    %edi,%eax
80101cf5:	83 c4 2c             	add    $0x2c,%esp
80101cf8:	5b                   	pop    %ebx
80101cf9:	5e                   	pop    %esi
80101cfa:	5f                   	pop    %edi
80101cfb:	5d                   	pop    %ebp
80101cfc:	c3                   	ret    
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
80101cfd:	e8 26 fb ff ff       	call   80101828 <iunlockput>
      return 0;
80101d02:	31 ff                	xor    %edi,%edi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101d04:	89 f8                	mov    %edi,%eax
80101d06:	83 c4 2c             	add    $0x2c,%esp
80101d09:	5b                   	pop    %ebx
80101d0a:	5e                   	pop    %esi
80101d0b:	5f                   	pop    %edi
80101d0c:	5d                   	pop    %ebp
80101d0d:	c3                   	ret    
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
80101d0e:	89 3c 24             	mov    %edi,(%esp)
80101d11:	e8 92 f9 ff ff       	call   801016a8 <iunlock>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101d16:	89 f8                	mov    %edi,%eax
80101d18:	83 c4 2c             	add    $0x2c,%esp
80101d1b:	5b                   	pop    %ebx
80101d1c:	5e                   	pop    %esi
80101d1d:	5f                   	pop    %edi
80101d1e:	5d                   	pop    %ebp
80101d1f:	c3                   	ret    
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
80101d20:	89 3c 24             	mov    %edi,(%esp)
80101d23:	e8 c0 f9 ff ff       	call   801016e8 <iput>
    return 0;
80101d28:	31 ff                	xor    %edi,%edi
80101d2a:	e9 cf fe ff ff       	jmp    80101bfe <namex+0x46>
80101d2f:	90                   	nop

80101d30 <dirlink>:
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80101d30:	55                   	push   %ebp
80101d31:	89 e5                	mov    %esp,%ebp
80101d33:	57                   	push   %edi
80101d34:	56                   	push   %esi
80101d35:	53                   	push   %ebx
80101d36:	83 ec 2c             	sub    $0x2c,%esp
80101d39:	8b 75 08             	mov    0x8(%ebp),%esi
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80101d3c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80101d43:	00 
80101d44:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d47:	89 44 24 04          	mov    %eax,0x4(%esp)
80101d4b:	89 34 24             	mov    %esi,(%esp)
80101d4e:	e8 b5 fd ff ff       	call   80101b08 <dirlookup>
80101d53:	85 c0                	test   %eax,%eax
80101d55:	0f 85 85 00 00 00    	jne    80101de0 <dirlink+0xb0>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80101d5b:	31 db                	xor    %ebx,%ebx
80101d5d:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101d60:	8b 4e 58             	mov    0x58(%esi),%ecx
80101d63:	85 c9                	test   %ecx,%ecx
80101d65:	75 0d                	jne    80101d74 <dirlink+0x44>
80101d67:	eb 2f                	jmp    80101d98 <dirlink+0x68>
80101d69:	8d 76 00             	lea    0x0(%esi),%esi
80101d6c:	83 c3 10             	add    $0x10,%ebx
80101d6f:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101d72:	76 24                	jbe    80101d98 <dirlink+0x68>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101d74:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101d7b:	00 
80101d7c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80101d80:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101d84:	89 34 24             	mov    %esi,(%esp)
80101d87:	e8 e8 fa ff ff       	call   80101874 <readi>
80101d8c:	83 f8 10             	cmp    $0x10,%eax
80101d8f:	75 5e                	jne    80101def <dirlink+0xbf>
      panic("dirlink read");
    if(de.inum == 0)
80101d91:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101d96:	75 d4                	jne    80101d6c <dirlink+0x3c>
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80101d98:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101d9f:	00 
80101da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101da3:	89 44 24 04          	mov    %eax,0x4(%esp)
80101da7:	8d 45 da             	lea    -0x26(%ebp),%eax
80101daa:	89 04 24             	mov    %eax,(%esp)
80101dad:	e8 76 22 00 00       	call   80104028 <strncpy>
  de.inum = inum;
80101db2:	8b 45 10             	mov    0x10(%ebp),%eax
80101db5:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101db9:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101dc0:	00 
80101dc1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80101dc5:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101dc9:	89 34 24             	mov    %esi,(%esp)
80101dcc:	e8 cf fb ff ff       	call   801019a0 <writei>
80101dd1:	83 f8 10             	cmp    $0x10,%eax
80101dd4:	75 25                	jne    80101dfb <dirlink+0xcb>
    panic("dirlink");

  return 0;
80101dd6:	31 c0                	xor    %eax,%eax
}
80101dd8:	83 c4 2c             	add    $0x2c,%esp
80101ddb:	5b                   	pop    %ebx
80101ddc:	5e                   	pop    %esi
80101ddd:	5f                   	pop    %edi
80101dde:	5d                   	pop    %ebp
80101ddf:	c3                   	ret    
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
80101de0:	89 04 24             	mov    %eax,(%esp)
80101de3:	e8 00 f9 ff ff       	call   801016e8 <iput>
    return -1;
80101de8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ded:	eb e9                	jmp    80101dd8 <dirlink+0xa8>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
80101def:	c7 04 24 68 69 10 80 	movl   $0x80106968,(%esp)
80101df6:	e8 21 e5 ff ff       	call   8010031c <panic>
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
80101dfb:	c7 04 24 46 6f 10 80 	movl   $0x80106f46,(%esp)
80101e02:	e8 15 e5 ff ff       	call   8010031c <panic>
80101e07:	90                   	nop

80101e08 <namei>:
  return ip;
}

struct inode*
namei(char *path)
{
80101e08:	55                   	push   %ebp
80101e09:	89 e5                	mov    %esp,%ebp
80101e0b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101e0e:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101e11:	31 d2                	xor    %edx,%edx
80101e13:	8b 45 08             	mov    0x8(%ebp),%eax
80101e16:	e8 9d fd ff ff       	call   80101bb8 <namex>
}
80101e1b:	c9                   	leave  
80101e1c:	c3                   	ret    
80101e1d:	8d 76 00             	lea    0x0(%esi),%esi

80101e20 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101e20:	55                   	push   %ebp
80101e21:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80101e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101e26:	ba 01 00 00 00       	mov    $0x1,%edx
80101e2b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101e2e:	5d                   	pop    %ebp
}

struct inode*
nameiparent(char *path, char *name)
{
  return namex(path, 1, name);
80101e2f:	e9 84 fd ff ff       	jmp    80101bb8 <namex>

80101e34 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101e34:	55                   	push   %ebp
80101e35:	89 e5                	mov    %esp,%ebp
80101e37:	56                   	push   %esi
80101e38:	53                   	push   %ebx
80101e39:	83 ec 10             	sub    $0x10,%esp
80101e3c:	89 c6                	mov    %eax,%esi
  if(b == 0)
80101e3e:	85 c0                	test   %eax,%eax
80101e40:	0f 84 8e 00 00 00    	je     80101ed4 <idestart+0xa0>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101e46:	8b 48 08             	mov    0x8(%eax),%ecx
80101e49:	81 f9 cf 07 00 00    	cmp    $0x7cf,%ecx
80101e4f:	77 77                	ja     80101ec8 <idestart+0x94>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101e51:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101e56:	66 90                	xchg   %ax,%ax
80101e58:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101e59:	25 c0 00 00 00       	and    $0xc0,%eax
80101e5e:	83 f8 40             	cmp    $0x40,%eax
80101e61:	75 f5                	jne    80101e58 <idestart+0x24>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101e63:	31 db                	xor    %ebx,%ebx
80101e65:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101e6a:	88 d8                	mov    %bl,%al
80101e6c:	ee                   	out    %al,(%dx)
80101e6d:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101e72:	b0 01                	mov    $0x1,%al
80101e74:	ee                   	out    %al,(%dx)
80101e75:	b2 f3                	mov    $0xf3,%dl
80101e77:	88 c8                	mov    %cl,%al
80101e79:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101e7a:	89 c8                	mov    %ecx,%eax
80101e7c:	c1 f8 08             	sar    $0x8,%eax
80101e7f:	b2 f4                	mov    $0xf4,%dl
80101e81:	ee                   	out    %al,(%dx)
80101e82:	b2 f5                	mov    $0xf5,%dl
80101e84:	88 d8                	mov    %bl,%al
80101e86:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101e87:	8b 46 04             	mov    0x4(%esi),%eax
80101e8a:	83 e0 01             	and    $0x1,%eax
80101e8d:	c1 e0 04             	shl    $0x4,%eax
80101e90:	83 c8 e0             	or     $0xffffffe0,%eax
80101e93:	b2 f6                	mov    $0xf6,%dl
80101e95:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101e96:	f6 06 04             	testb  $0x4,(%esi)
80101e99:	75 11                	jne    80101eac <idestart+0x78>
80101e9b:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ea0:	b0 20                	mov    $0x20,%al
80101ea2:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101ea3:	83 c4 10             	add    $0x10,%esp
80101ea6:	5b                   	pop    %ebx
80101ea7:	5e                   	pop    %esi
80101ea8:	5d                   	pop    %ebp
80101ea9:	c3                   	ret    
80101eaa:	66 90                	xchg   %ax,%ax
80101eac:	b2 f7                	mov    $0xf7,%dl
80101eae:	b0 30                	mov    $0x30,%al
80101eb0:	ee                   	out    %al,(%dx)
  outb(0x1f4, (sector >> 8) & 0xff);
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101eb1:	83 c6 5c             	add    $0x5c,%esi
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  asm volatile("cld; rep outsl" :
80101eb4:	b9 80 00 00 00       	mov    $0x80,%ecx
80101eb9:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101ebe:	fc                   	cld    
80101ebf:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101ec1:	83 c4 10             	add    $0x10,%esp
80101ec4:	5b                   	pop    %ebx
80101ec5:	5e                   	pop    %esi
80101ec6:	5d                   	pop    %ebp
80101ec7:	c3                   	ret    
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
  if(b->blockno >= FSSIZE)
    panic("incorrect blockno");
80101ec8:	c7 04 24 d4 69 10 80 	movl   $0x801069d4,(%esp)
80101ecf:	e8 48 e4 ff ff       	call   8010031c <panic>
// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
80101ed4:	c7 04 24 cb 69 10 80 	movl   $0x801069cb,(%esp)
80101edb:	e8 3c e4 ff ff       	call   8010031c <panic>

80101ee0 <ideinit>:
  return 0;
}

void
ideinit(void)
{
80101ee0:	55                   	push   %ebp
80101ee1:	89 e5                	mov    %esp,%ebp
80101ee3:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80101ee6:	c7 44 24 04 e6 69 10 	movl   $0x801069e6,0x4(%esp)
80101eed:	80 
80101eee:	c7 04 24 60 a5 10 80 	movl   $0x8010a560,(%esp)
80101ef5:	e8 f6 1d 00 00       	call   80103cf0 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101efa:	a1 00 2d 11 80       	mov    0x80112d00,%eax
80101eff:	48                   	dec    %eax
80101f00:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f04:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80101f0b:	e8 44 02 00 00       	call   80102154 <ioapicenable>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101f10:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101f15:	8d 76 00             	lea    0x0(%esi),%esi
80101f18:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101f19:	25 c0 00 00 00       	and    $0xc0,%eax
80101f1e:	83 f8 40             	cmp    $0x40,%eax
80101f21:	75 f5                	jne    80101f18 <ideinit+0x38>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101f23:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101f28:	b0 f0                	mov    $0xf0,%al
80101f2a:	ee                   	out    %al,(%dx)
80101f2b:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101f30:	b2 f7                	mov    $0xf7,%dl
80101f32:	eb 03                	jmp    80101f37 <ideinit+0x57>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80101f34:	49                   	dec    %ecx
80101f35:	74 0f                	je     80101f46 <ideinit+0x66>
80101f37:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101f38:	84 c0                	test   %al,%al
80101f3a:	74 f8                	je     80101f34 <ideinit+0x54>
      havedisk1 = 1;
80101f3c:	c7 05 94 a5 10 80 01 	movl   $0x1,0x8010a594
80101f43:	00 00 00 
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101f46:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101f4b:	b0 e0                	mov    $0xe0,%al
80101f4d:	ee                   	out    %al,(%dx)
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
}
80101f4e:	c9                   	leave  
80101f4f:	c3                   	ret    

80101f50 <ideintr>:
}

// Interrupt handler.
void
ideintr(void)
{
80101f50:	55                   	push   %ebp
80101f51:	89 e5                	mov    %esp,%ebp
80101f53:	57                   	push   %edi
80101f54:	53                   	push   %ebx
80101f55:	83 ec 10             	sub    $0x10,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101f58:	c7 04 24 60 a5 10 80 	movl   $0x8010a560,(%esp)
80101f5f:	e8 c8 1e 00 00       	call   80103e2c <acquire>

  if((b = idequeue) == 0){
80101f64:	8b 1d 98 a5 10 80    	mov    0x8010a598,%ebx
80101f6a:	85 db                	test   %ebx,%ebx
80101f6c:	74 2d                	je     80101f9b <ideintr+0x4b>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101f6e:	8b 43 58             	mov    0x58(%ebx),%eax
80101f71:	a3 98 a5 10 80       	mov    %eax,0x8010a598

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101f76:	8b 0b                	mov    (%ebx),%ecx
80101f78:	f6 c1 04             	test   $0x4,%cl
80101f7b:	74 33                	je     80101fb0 <ideintr+0x60>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101f7d:	83 c9 02             	or     $0x2,%ecx
  b->flags &= ~B_DIRTY;
80101f80:	83 e1 fb             	and    $0xfffffffb,%ecx
80101f83:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
80101f85:	89 1c 24             	mov    %ebx,(%esp)
80101f88:	e8 c7 1a 00 00       	call   80103a54 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101f8d:	a1 98 a5 10 80       	mov    0x8010a598,%eax
80101f92:	85 c0                	test   %eax,%eax
80101f94:	74 05                	je     80101f9b <ideintr+0x4b>
    idestart(idequeue);
80101f96:	e8 99 fe ff ff       	call   80101e34 <idestart>

  release(&idelock);
80101f9b:	c7 04 24 60 a5 10 80 	movl   $0x8010a560,(%esp)
80101fa2:	e8 e9 1e 00 00       	call   80103e90 <release>
}
80101fa7:	83 c4 10             	add    $0x10,%esp
80101faa:	5b                   	pop    %ebx
80101fab:	5f                   	pop    %edi
80101fac:	5d                   	pop    %ebp
80101fad:	c3                   	ret    
80101fae:	66 90                	xchg   %ax,%ax
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101fb0:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101fb5:	8d 76 00             	lea    0x0(%esi),%esi
80101fb8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101fb9:	0f b6 c0             	movzbl %al,%eax
80101fbc:	89 c7                	mov    %eax,%edi
80101fbe:	81 e7 c0 00 00 00    	and    $0xc0,%edi
80101fc4:	83 ff 40             	cmp    $0x40,%edi
80101fc7:	75 ef                	jne    80101fb8 <ideintr+0x68>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101fc9:	a8 21                	test   $0x21,%al
80101fcb:	75 b0                	jne    80101f7d <ideintr+0x2d>
  }
  idequeue = b->qnext;

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
    insl(0x1f0, b->data, BSIZE/4);
80101fcd:	8d 7b 5c             	lea    0x5c(%ebx),%edi
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
80101fd0:	b9 80 00 00 00       	mov    $0x80,%ecx
80101fd5:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101fda:	fc                   	cld    
80101fdb:	f3 6d                	rep insl (%dx),%es:(%edi)
80101fdd:	8b 0b                	mov    (%ebx),%ecx
80101fdf:	eb 9c                	jmp    80101f7d <ideintr+0x2d>
80101fe1:	8d 76 00             	lea    0x0(%esi),%esi

80101fe4 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101fe4:	55                   	push   %ebp
80101fe5:	89 e5                	mov    %esp,%ebp
80101fe7:	53                   	push   %ebx
80101fe8:	83 ec 14             	sub    $0x14,%esp
80101feb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101fee:	8d 43 0c             	lea    0xc(%ebx),%eax
80101ff1:	89 04 24             	mov    %eax,(%esp)
80101ff4:	e8 af 1c 00 00       	call   80103ca8 <holdingsleep>
80101ff9:	85 c0                	test   %eax,%eax
80101ffb:	0f 84 8e 00 00 00    	je     8010208f <iderw+0xab>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102001:	8b 03                	mov    (%ebx),%eax
80102003:	83 e0 06             	and    $0x6,%eax
80102006:	83 f8 02             	cmp    $0x2,%eax
80102009:	0f 84 98 00 00 00    	je     801020a7 <iderw+0xc3>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010200f:	8b 53 04             	mov    0x4(%ebx),%edx
80102012:	85 d2                	test   %edx,%edx
80102014:	74 09                	je     8010201f <iderw+0x3b>
80102016:	a1 94 a5 10 80       	mov    0x8010a594,%eax
8010201b:	85 c0                	test   %eax,%eax
8010201d:	74 7c                	je     8010209b <iderw+0xb7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
8010201f:	c7 04 24 60 a5 10 80 	movl   $0x8010a560,(%esp)
80102026:	e8 01 1e 00 00       	call   80103e2c <acquire>

  // Append b to idequeue.
  b->qnext = 0;
8010202b:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102032:	a1 98 a5 10 80       	mov    0x8010a598,%eax
80102037:	85 c0                	test   %eax,%eax
80102039:	74 44                	je     8010207f <iderw+0x9b>
8010203b:	90                   	nop
8010203c:	8d 50 58             	lea    0x58(%eax),%edx
8010203f:	8b 40 58             	mov    0x58(%eax),%eax
80102042:	85 c0                	test   %eax,%eax
80102044:	75 f6                	jne    8010203c <iderw+0x58>
    ;
  *pp = b;
80102046:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80102048:	39 1d 98 a5 10 80    	cmp    %ebx,0x8010a598
8010204e:	75 14                	jne    80102064 <iderw+0x80>
80102050:	eb 34                	jmp    80102086 <iderw+0xa2>
80102052:	66 90                	xchg   %ax,%ax
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80102054:	c7 44 24 04 60 a5 10 	movl   $0x8010a560,0x4(%esp)
8010205b:	80 
8010205c:	89 1c 24             	mov    %ebx,(%esp)
8010205f:	e8 70 18 00 00       	call   801038d4 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102064:	8b 03                	mov    (%ebx),%eax
80102066:	83 e0 06             	and    $0x6,%eax
80102069:	83 f8 02             	cmp    $0x2,%eax
8010206c:	75 e6                	jne    80102054 <iderw+0x70>
    sleep(b, &idelock);
  }


  release(&idelock);
8010206e:	c7 45 08 60 a5 10 80 	movl   $0x8010a560,0x8(%ebp)
}
80102075:	83 c4 14             	add    $0x14,%esp
80102078:	5b                   	pop    %ebx
80102079:	5d                   	pop    %ebp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  }


  release(&idelock);
8010207a:	e9 11 1e 00 00       	jmp    80103e90 <release>

  acquire(&idelock);  //DOC:acquire-lock

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010207f:	ba 98 a5 10 80       	mov    $0x8010a598,%edx
80102084:	eb c0                	jmp    80102046 <iderw+0x62>
    ;
  *pp = b;

  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
80102086:	89 d8                	mov    %ebx,%eax
80102088:	e8 a7 fd ff ff       	call   80101e34 <idestart>
8010208d:	eb d5                	jmp    80102064 <iderw+0x80>
iderw(struct buf *b)
{
  struct buf **pp;

  if(!holdingsleep(&b->lock))
    panic("iderw: buf not locked");
8010208f:	c7 04 24 ea 69 10 80 	movl   $0x801069ea,(%esp)
80102096:	e8 81 e2 ff ff       	call   8010031c <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
    panic("iderw: ide disk 1 not present");
8010209b:	c7 04 24 15 6a 10 80 	movl   $0x80106a15,(%esp)
801020a2:	e8 75 e2 ff ff       	call   8010031c <panic>
  struct buf **pp;

  if(!holdingsleep(&b->lock))
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
801020a7:	c7 04 24 00 6a 10 80 	movl   $0x80106a00,(%esp)
801020ae:	e8 69 e2 ff ff       	call   8010031c <panic>
	...

801020b4 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
801020b4:	55                   	push   %ebp
801020b5:	89 e5                	mov    %esp,%ebp
801020b7:	56                   	push   %esi
801020b8:	53                   	push   %ebx
801020b9:	83 ec 10             	sub    $0x10,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801020bc:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
801020c3:	00 c0 fe 
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
801020c6:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
801020cd:	00 00 00 
  return ioapic->data;
801020d0:	8b 35 10 00 c0 fe    	mov    0xfec00010,%esi
ioapicinit(void)
{
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801020d6:	c1 ee 10             	shr    $0x10,%esi
801020d9:	81 e6 ff 00 00 00    	and    $0xff,%esi
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
801020df:	c7 05 00 00 c0 fe 00 	movl   $0x0,0xfec00000
801020e6:	00 00 00 
  return ioapic->data;
801020e9:	bb 00 00 c0 fe       	mov    $0xfec00000,%ebx
801020ee:	a1 10 00 c0 fe       	mov    0xfec00010,%eax
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
801020f3:	0f b6 15 60 27 11 80 	movzbl 0x80112760,%edx
{
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
801020fa:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
801020fd:	39 c2                	cmp    %eax,%edx
801020ff:	74 12                	je     80102113 <ioapicinit+0x5f>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102101:	c7 04 24 34 6a 10 80 	movl   $0x80106a34,(%esp)
80102108:	e8 af e4 ff ff       	call   801005bc <cprintf>
8010210d:	8b 1d 34 26 11 80    	mov    0x80112634,%ebx
  ioapic->data = data;
}

void
ioapicinit(void)
{
80102113:	ba 10 00 00 00       	mov    $0x10,%edx
80102118:	31 c0                	xor    %eax,%eax
8010211a:	66 90                	xchg   %ax,%ax
  ioapic->reg = reg;
  ioapic->data = data;
}

void
ioapicinit(void)
8010211c:	8d 48 20             	lea    0x20(%eax),%ecx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010211f:	81 c9 00 00 01 00    	or     $0x10000,%ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102125:	89 13                	mov    %edx,(%ebx)
  ioapic->data = data;
80102127:	8b 1d 34 26 11 80    	mov    0x80112634,%ebx
8010212d:	89 4b 10             	mov    %ecx,0x10(%ebx)
}

void
ioapicinit(void)
80102130:	8d 4a 01             	lea    0x1(%edx),%ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102133:	89 0b                	mov    %ecx,(%ebx)
  ioapic->data = data;
80102135:	8b 1d 34 26 11 80    	mov    0x80112634,%ebx
8010213b:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102142:	40                   	inc    %eax
80102143:	83 c2 02             	add    $0x2,%edx
80102146:	39 c6                	cmp    %eax,%esi
80102148:	7d d2                	jge    8010211c <ioapicinit+0x68>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010214a:	83 c4 10             	add    $0x10,%esp
8010214d:	5b                   	pop    %ebx
8010214e:	5e                   	pop    %esi
8010214f:	5d                   	pop    %ebp
80102150:	c3                   	ret    
80102151:	8d 76 00             	lea    0x0(%esi),%esi

80102154 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102154:	55                   	push   %ebp
80102155:	89 e5                	mov    %esp,%ebp
80102157:	53                   	push   %ebx
80102158:	8b 55 08             	mov    0x8(%ebp),%edx
8010215b:	8b 45 0c             	mov    0xc(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010215e:	8d 5a 20             	lea    0x20(%edx),%ebx
80102161:	8d 4c 12 10          	lea    0x10(%edx,%edx,1),%ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102165:	8b 15 34 26 11 80    	mov    0x80112634,%edx
8010216b:	89 0a                	mov    %ecx,(%edx)
  ioapic->data = data;
8010216d:	8b 15 34 26 11 80    	mov    0x80112634,%edx
80102173:	89 5a 10             	mov    %ebx,0x10(%edx)
{
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102176:	c1 e0 18             	shl    $0x18,%eax
80102179:	41                   	inc    %ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
8010217a:	89 0a                	mov    %ecx,(%edx)
  ioapic->data = data;
8010217c:	8b 15 34 26 11 80    	mov    0x80112634,%edx
80102182:	89 42 10             	mov    %eax,0x10(%edx)
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102185:	5b                   	pop    %ebx
80102186:	5d                   	pop    %ebp
80102187:	c3                   	ret    

80102188 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102188:	55                   	push   %ebp
80102189:	89 e5                	mov    %esp,%ebp
8010218b:	53                   	push   %ebx
8010218c:	83 ec 14             	sub    $0x14,%esp
8010218f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102192:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102198:	75 78                	jne    80102212 <kfree+0x8a>
8010219a:	81 fb a8 57 11 80    	cmp    $0x801157a8,%ebx
801021a0:	72 70                	jb     80102212 <kfree+0x8a>
801021a2:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801021a8:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801021ad:	77 63                	ja     80102212 <kfree+0x8a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801021af:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801021b6:	00 
801021b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801021be:	00 
801021bf:	89 1c 24             	mov    %ebx,(%esp)
801021c2:	e8 11 1d 00 00       	call   80103ed8 <memset>

  if(kmem.use_lock)
801021c7:	8b 15 74 26 11 80    	mov    0x80112674,%edx
801021cd:	85 d2                	test   %edx,%edx
801021cf:	75 33                	jne    80102204 <kfree+0x7c>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
801021d1:	a1 78 26 11 80       	mov    0x80112678,%eax
801021d6:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
801021d8:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
  if(kmem.use_lock)
801021de:	a1 74 26 11 80       	mov    0x80112674,%eax
801021e3:	85 c0                	test   %eax,%eax
801021e5:	75 09                	jne    801021f0 <kfree+0x68>
    release(&kmem.lock);
}
801021e7:	83 c4 14             	add    $0x14,%esp
801021ea:	5b                   	pop    %ebx
801021eb:	5d                   	pop    %ebp
801021ec:	c3                   	ret    
801021ed:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  if(kmem.use_lock)
    release(&kmem.lock);
801021f0:	c7 45 08 40 26 11 80 	movl   $0x80112640,0x8(%ebp)
}
801021f7:	83 c4 14             	add    $0x14,%esp
801021fa:	5b                   	pop    %ebx
801021fb:	5d                   	pop    %ebp
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  if(kmem.use_lock)
    release(&kmem.lock);
801021fc:	e9 8f 1c 00 00       	jmp    80103e90 <release>
80102201:	8d 76 00             	lea    0x0(%esi),%esi

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);

  if(kmem.use_lock)
    acquire(&kmem.lock);
80102204:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
8010220b:	e8 1c 1c 00 00       	call   80103e2c <acquire>
80102210:	eb bf                	jmp    801021d1 <kfree+0x49>
kfree(char *v)
{
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
    panic("kfree");
80102212:	c7 04 24 66 6a 10 80 	movl   $0x80106a66,(%esp)
80102219:	e8 fe e0 ff ff       	call   8010031c <panic>
8010221e:	66 90                	xchg   %ax,%ax

80102220 <freerange>:
  kmem.use_lock = 1;
}

void
freerange(void *vstart, void *vend)
{
80102220:	55                   	push   %ebp
80102221:	89 e5                	mov    %esp,%ebp
80102223:	56                   	push   %esi
80102224:	53                   	push   %ebx
80102225:	83 ec 10             	sub    $0x10,%esp
80102228:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
8010222b:	8b 55 08             	mov    0x8(%ebp),%edx
8010222e:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
80102234:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010223a:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
80102240:	39 de                	cmp    %ebx,%esi
80102242:	73 08                	jae    8010224c <freerange+0x2c>
80102244:	eb 18                	jmp    8010225e <freerange+0x3e>
80102246:	66 90                	xchg   %ax,%ax
80102248:	89 da                	mov    %ebx,%edx
8010224a:	89 c3                	mov    %eax,%ebx
    kfree(p);
8010224c:	89 14 24             	mov    %edx,(%esp)
8010224f:	e8 34 ff ff ff       	call   80102188 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102254:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
8010225a:	39 f0                	cmp    %esi,%eax
8010225c:	76 ea                	jbe    80102248 <freerange+0x28>
    kfree(p);
}
8010225e:	83 c4 10             	add    $0x10,%esp
80102261:	5b                   	pop    %ebx
80102262:	5e                   	pop    %esi
80102263:	5d                   	pop    %ebp
80102264:	c3                   	ret    
80102265:	8d 76 00             	lea    0x0(%esi),%esi

80102268 <kinit2>:
  freerange(vstart, vend);
}

void
kinit2(void *vstart, void *vend)
{
80102268:	55                   	push   %ebp
80102269:	89 e5                	mov    %esp,%ebp
8010226b:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
8010226e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102271:	89 44 24 04          	mov    %eax,0x4(%esp)
80102275:	8b 45 08             	mov    0x8(%ebp),%eax
80102278:	89 04 24             	mov    %eax,(%esp)
8010227b:	e8 a0 ff ff ff       	call   80102220 <freerange>
  kmem.use_lock = 1;
80102280:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
80102287:	00 00 00 
}
8010228a:	c9                   	leave  
8010228b:	c3                   	ret    

8010228c <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010228c:	55                   	push   %ebp
8010228d:	89 e5                	mov    %esp,%ebp
8010228f:	56                   	push   %esi
80102290:	53                   	push   %ebx
80102291:	83 ec 10             	sub    $0x10,%esp
80102294:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102297:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
8010229a:	c7 44 24 04 6c 6a 10 	movl   $0x80106a6c,0x4(%esp)
801022a1:	80 
801022a2:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
801022a9:	e8 42 1a 00 00       	call   80103cf0 <initlock>
  kmem.use_lock = 0;
801022ae:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
801022b5:	00 00 00 
  freerange(vstart, vend);
801022b8:	89 75 0c             	mov    %esi,0xc(%ebp)
801022bb:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801022be:	83 c4 10             	add    $0x10,%esp
801022c1:	5b                   	pop    %ebx
801022c2:	5e                   	pop    %esi
801022c3:	5d                   	pop    %ebp
void
kinit1(void *vstart, void *vend)
{
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
801022c4:	e9 57 ff ff ff       	jmp    80102220 <freerange>
801022c9:	8d 76 00             	lea    0x0(%esi),%esi

801022cc <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801022cc:	55                   	push   %ebp
801022cd:	89 e5                	mov    %esp,%ebp
801022cf:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
801022d2:	8b 0d 74 26 11 80    	mov    0x80112674,%ecx
801022d8:	85 c9                	test   %ecx,%ecx
801022da:	75 30                	jne    8010230c <kalloc+0x40>
801022dc:	31 d2                	xor    %edx,%edx
    acquire(&kmem.lock);
  r = kmem.freelist;
801022de:	a1 78 26 11 80       	mov    0x80112678,%eax
  if(r)
801022e3:	85 c0                	test   %eax,%eax
801022e5:	74 08                	je     801022ef <kalloc+0x23>
    kmem.freelist = r->next;
801022e7:	8b 08                	mov    (%eax),%ecx
801022e9:	89 0d 78 26 11 80    	mov    %ecx,0x80112678
  if(kmem.use_lock)
801022ef:	85 d2                	test   %edx,%edx
801022f1:	75 05                	jne    801022f8 <kalloc+0x2c>
    release(&kmem.lock);
  return (char*)r;
}
801022f3:	c9                   	leave  
801022f4:	c3                   	ret    
801022f5:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  if(kmem.use_lock)
    release(&kmem.lock);
801022f8:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
801022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102302:	e8 89 1b 00 00       	call   80103e90 <release>
80102307:	8b 45 f4             	mov    -0xc(%ebp),%eax
  return (char*)r;
}
8010230a:	c9                   	leave  
8010230b:	c3                   	ret    
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
    acquire(&kmem.lock);
8010230c:	c7 04 24 40 26 11 80 	movl   $0x80112640,(%esp)
80102313:	e8 14 1b 00 00       	call   80103e2c <acquire>
80102318:	8b 15 74 26 11 80    	mov    0x80112674,%edx
8010231e:	eb be                	jmp    801022de <kalloc+0x12>

80102320 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102320:	55                   	push   %ebp
80102321:	89 e5                	mov    %esp,%ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102323:	ba 64 00 00 00       	mov    $0x64,%edx
80102328:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102329:	a8 01                	test   $0x1,%al
8010232b:	0f 84 a3 00 00 00    	je     801023d4 <kbdgetc+0xb4>
80102331:	b2 60                	mov    $0x60,%dl
80102333:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102334:	0f b6 c0             	movzbl %al,%eax

  if(data == 0xE0){
80102337:	3d e0 00 00 00       	cmp    $0xe0,%eax
8010233c:	74 7a                	je     801023b8 <kbdgetc+0x98>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
8010233e:	a8 80                	test   $0x80,%al
80102340:	74 2a                	je     8010236c <kbdgetc+0x4c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102342:	8b 15 9c a5 10 80    	mov    0x8010a59c,%edx
80102348:	f6 c2 40             	test   $0x40,%dl
8010234b:	75 03                	jne    80102350 <kbdgetc+0x30>
8010234d:	83 e0 7f             	and    $0x7f,%eax
    shift &= ~(shiftcode[data] | E0ESC);
80102350:	8a 80 80 6a 10 80    	mov    -0x7fef9580(%eax),%al
80102356:	83 c8 40             	or     $0x40,%eax
80102359:	0f b6 c0             	movzbl %al,%eax
8010235c:	f7 d0                	not    %eax
8010235e:	21 d0                	and    %edx,%eax
80102360:	a3 9c a5 10 80       	mov    %eax,0x8010a59c
    return 0;
80102365:	31 c0                	xor    %eax,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102367:	5d                   	pop    %ebp
80102368:	c3                   	ret    
80102369:	8d 76 00             	lea    0x0(%esi),%esi
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010236c:	8b 0d 9c a5 10 80    	mov    0x8010a59c,%ecx
80102372:	f6 c1 40             	test   $0x40,%cl
80102375:	74 05                	je     8010237c <kbdgetc+0x5c>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102377:	0c 80                	or     $0x80,%al
    shift &= ~E0ESC;
80102379:	83 e1 bf             	and    $0xffffffbf,%ecx
  }

  shift |= shiftcode[data];
8010237c:	0f b6 90 80 6a 10 80 	movzbl -0x7fef9580(%eax),%edx
80102383:	09 ca                	or     %ecx,%edx
  shift ^= togglecode[data];
80102385:	0f b6 88 80 6b 10 80 	movzbl -0x7fef9480(%eax),%ecx
8010238c:	31 ca                	xor    %ecx,%edx
8010238e:	89 15 9c a5 10 80    	mov    %edx,0x8010a59c
  c = charcode[shift & (CTL | SHIFT)][data];
80102394:	89 d1                	mov    %edx,%ecx
80102396:	83 e1 03             	and    $0x3,%ecx
80102399:	8b 0c 8d 80 6c 10 80 	mov    -0x7fef9380(,%ecx,4),%ecx
801023a0:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
  if(shift & CAPSLOCK){
801023a4:	83 e2 08             	and    $0x8,%edx
801023a7:	74 be                	je     80102367 <kbdgetc+0x47>
    if('a' <= c && c <= 'z')
801023a9:	8d 50 9f             	lea    -0x61(%eax),%edx
801023ac:	83 fa 19             	cmp    $0x19,%edx
801023af:	77 13                	ja     801023c4 <kbdgetc+0xa4>
      c += 'A' - 'a';
801023b1:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801023b4:	5d                   	pop    %ebp
801023b5:	c3                   	ret    
801023b6:	66 90                	xchg   %ax,%ax
  if((st & KBS_DIB) == 0)
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
801023b8:	83 0d 9c a5 10 80 40 	orl    $0x40,0x8010a59c
    return 0;
801023bf:	30 c0                	xor    %al,%al
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801023c1:	5d                   	pop    %ebp
801023c2:	c3                   	ret    
801023c3:	90                   	nop
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
    if('a' <= c && c <= 'z')
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
801023c4:	8d 50 bf             	lea    -0x41(%eax),%edx
801023c7:	83 fa 19             	cmp    $0x19,%edx
801023ca:	77 9b                	ja     80102367 <kbdgetc+0x47>
      c += 'a' - 'A';
801023cc:	83 c0 20             	add    $0x20,%eax
  }
  return c;
}
801023cf:	5d                   	pop    %ebp
801023d0:	c3                   	ret    
801023d1:	8d 76 00             	lea    0x0(%esi),%esi
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
    return -1;
801023d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801023d9:	5d                   	pop    %ebp
801023da:	c3                   	ret    
801023db:	90                   	nop

801023dc <kbdintr>:

void
kbdintr(void)
{
801023dc:	55                   	push   %ebp
801023dd:	89 e5                	mov    %esp,%ebp
801023df:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
801023e2:	c7 04 24 20 23 10 80 	movl   $0x80102320,(%esp)
801023e9:	e8 0e e3 ff ff       	call   801006fc <consoleintr>
}
801023ee:	c9                   	leave  
801023ef:	c3                   	ret    

801023f0 <lapicinit>:
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(void)
{
801023f0:	55                   	push   %ebp
801023f1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801023f3:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801023f8:	85 c0                	test   %eax,%eax
801023fa:	0f 84 c0 00 00 00    	je     801024c0 <lapicinit+0xd0>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102400:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102407:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010240a:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010240d:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102414:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102417:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010241a:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
80102421:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102424:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102427:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010242e:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
80102431:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102434:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
8010243b:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010243e:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102441:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102448:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010244b:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010244e:	8b 50 30             	mov    0x30(%eax),%edx
80102451:	c1 ea 10             	shr    $0x10,%edx
80102454:	80 fa 03             	cmp    $0x3,%dl
80102457:	77 6b                	ja     801024c4 <lapicinit+0xd4>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102459:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102460:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102463:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102466:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010246d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102470:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102473:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010247a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010247d:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102480:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102487:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010248a:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010248d:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102494:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102497:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010249a:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
801024a1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
801024a4:	8b 50 20             	mov    0x20(%eax),%edx
801024a7:	90                   	nop
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
801024a8:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
801024ae:	80 e6 10             	and    $0x10,%dh
801024b1:	75 f5                	jne    801024a8 <lapicinit+0xb8>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801024b3:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801024ba:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801024bd:	8b 40 20             	mov    0x20(%eax),%eax
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801024c0:	5d                   	pop    %ebp
801024c1:	c3                   	ret    
801024c2:	66 90                	xchg   %ax,%ax

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801024c4:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
801024cb:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801024ce:	8b 50 20             	mov    0x20(%eax),%edx
801024d1:	eb 86                	jmp    80102459 <lapicinit+0x69>
801024d3:	90                   	nop

801024d4 <lapicid>:
  lapicw(TPR, 0);
}

int
lapicid(void)
{
801024d4:	55                   	push   %ebp
801024d5:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801024d7:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801024dc:	85 c0                	test   %eax,%eax
801024de:	74 08                	je     801024e8 <lapicid+0x14>
    return 0;
  return lapic[ID] >> 24;
801024e0:	8b 40 20             	mov    0x20(%eax),%eax
801024e3:	c1 e8 18             	shr    $0x18,%eax
}
801024e6:	5d                   	pop    %ebp
801024e7:	c3                   	ret    

int
lapicid(void)
{
  if (!lapic)
    return 0;
801024e8:	31 c0                	xor    %eax,%eax
  return lapic[ID] >> 24;
}
801024ea:	5d                   	pop    %ebp
801024eb:	c3                   	ret    

801024ec <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801024ec:	55                   	push   %ebp
801024ed:	89 e5                	mov    %esp,%ebp
  if(lapic)
801024ef:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801024f4:	85 c0                	test   %eax,%eax
801024f6:	74 0d                	je     80102505 <lapiceoi+0x19>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801024f8:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
801024ff:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102502:	8b 40 20             	mov    0x20(%eax),%eax
void
lapiceoi(void)
{
  if(lapic)
    lapicw(EOI, 0);
}
80102505:	5d                   	pop    %ebp
80102506:	c3                   	ret    
80102507:	90                   	nop

80102508 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102508:	55                   	push   %ebp
80102509:	89 e5                	mov    %esp,%ebp
}
8010250b:	5d                   	pop    %ebp
8010250c:	c3                   	ret    
8010250d:	8d 76 00             	lea    0x0(%esi),%esi

80102510 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102510:	55                   	push   %ebp
80102511:	89 e5                	mov    %esp,%ebp
80102513:	53                   	push   %ebx
80102514:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102517:	8a 5d 08             	mov    0x8(%ebp),%bl
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010251a:	ba 70 00 00 00       	mov    $0x70,%edx
8010251f:	b0 0f                	mov    $0xf,%al
80102521:	ee                   	out    %al,(%dx)
80102522:	b2 71                	mov    $0x71,%dl
80102524:	b0 0a                	mov    $0xa,%al
80102526:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102527:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
8010252e:	00 00 
  wrv[1] = addr >> 4;
80102530:	89 c8                	mov    %ecx,%eax
80102532:	c1 e8 04             	shr    $0x4,%eax
80102535:	66 a3 69 04 00 80    	mov    %ax,0x80000469

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010253b:	a1 7c 26 11 80       	mov    0x8011267c,%eax
  wrv[0] = 0;
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102540:	c1 e3 18             	shl    $0x18,%ebx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102543:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102549:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010254c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102553:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102556:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102559:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102560:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102563:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102566:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010256c:	8b 50 20             	mov    0x20(%eax),%edx
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
8010256f:	c1 e9 0c             	shr    $0xc,%ecx
80102572:	80 cd 06             	or     $0x6,%ch

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102575:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010257b:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010257e:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102584:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102587:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010258d:	8b 40 20             	mov    0x20(%eax),%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80102590:	5b                   	pop    %ebx
80102591:	5d                   	pop    %ebp
80102592:	c3                   	ret    
80102593:	90                   	nop

80102594 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102594:	55                   	push   %ebp
80102595:	89 e5                	mov    %esp,%ebp
80102597:	57                   	push   %edi
80102598:	56                   	push   %esi
80102599:	53                   	push   %ebx
8010259a:	83 ec 6c             	sub    $0x6c,%esp
8010259d:	ba 70 00 00 00       	mov    $0x70,%edx
801025a2:	b0 0b                	mov    $0xb,%al
801025a4:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025a5:	b2 71                	mov    $0x71,%dl
801025a7:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
801025a8:	89 c2                	mov    %eax,%edx
801025aa:	83 e2 04             	and    $0x4,%edx
801025ad:	89 55 a0             	mov    %edx,-0x60(%ebp)
801025b0:	8d 45 b8             	lea    -0x48(%ebp),%eax
801025b3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b6:	be 70 00 00 00       	mov    $0x70,%esi
801025bb:	90                   	nop
801025bc:	31 c0                	xor    %eax,%eax
801025be:	89 f2                	mov    %esi,%edx
801025c0:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025c1:	b9 71 00 00 00       	mov    $0x71,%ecx
801025c6:	89 ca                	mov    %ecx,%edx
801025c8:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801025c9:	0f b6 d8             	movzbl %al,%ebx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025cc:	b0 02                	mov    $0x2,%al
801025ce:	89 f2                	mov    %esi,%edx
801025d0:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025d1:	89 ca                	mov    %ecx,%edx
801025d3:	ec                   	in     (%dx),%al
801025d4:	0f b6 c0             	movzbl %al,%eax
801025d7:	89 45 b0             	mov    %eax,-0x50(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025da:	b0 04                	mov    $0x4,%al
801025dc:	89 f2                	mov    %esi,%edx
801025de:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025df:	89 ca                	mov    %ecx,%edx
801025e1:	ec                   	in     (%dx),%al
801025e2:	0f b6 c0             	movzbl %al,%eax
801025e5:	89 45 ac             	mov    %eax,-0x54(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025e8:	b0 07                	mov    $0x7,%al
801025ea:	89 f2                	mov    %esi,%edx
801025ec:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025ed:	89 ca                	mov    %ecx,%edx
801025ef:	ec                   	in     (%dx),%al
801025f0:	0f b6 c0             	movzbl %al,%eax
801025f3:	89 45 a8             	mov    %eax,-0x58(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025f6:	b0 08                	mov    $0x8,%al
801025f8:	89 f2                	mov    %esi,%edx
801025fa:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025fb:	89 ca                	mov    %ecx,%edx
801025fd:	ec                   	in     (%dx),%al
801025fe:	0f b6 c0             	movzbl %al,%eax
80102601:	89 45 a4             	mov    %eax,-0x5c(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102604:	b0 09                	mov    $0x9,%al
80102606:	89 f2                	mov    %esi,%edx
80102608:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102609:	89 ca                	mov    %ecx,%edx
8010260b:	ec                   	in     (%dx),%al
8010260c:	0f b6 f8             	movzbl %al,%edi
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010260f:	b0 0a                	mov    $0xa,%al
80102611:	89 f2                	mov    %esi,%edx
80102613:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102614:	89 ca                	mov    %ecx,%edx
80102616:	ec                   	in     (%dx),%al
  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102617:	a8 80                	test   $0x80,%al
80102619:	75 a1                	jne    801025bc <cmostime+0x28>
8010261b:	89 5d b8             	mov    %ebx,-0x48(%ebp)
8010261e:	8b 45 b0             	mov    -0x50(%ebp),%eax
80102621:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102624:	8b 55 ac             	mov    -0x54(%ebp),%edx
80102627:	89 55 c0             	mov    %edx,-0x40(%ebp)
8010262a:	8b 45 a8             	mov    -0x58(%ebp),%eax
8010262d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102630:	8b 55 a4             	mov    -0x5c(%ebp),%edx
80102633:	89 55 c8             	mov    %edx,-0x38(%ebp)
80102636:	89 7d cc             	mov    %edi,-0x34(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102639:	31 c0                	xor    %eax,%eax
8010263b:	89 f2                	mov    %esi,%edx
8010263d:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010263e:	89 ca                	mov    %ecx,%edx
80102640:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102641:	0f b6 c0             	movzbl %al,%eax
80102644:	89 45 d0             	mov    %eax,-0x30(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102647:	b0 02                	mov    $0x2,%al
80102649:	89 f2                	mov    %esi,%edx
8010264b:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010264c:	89 ca                	mov    %ecx,%edx
8010264e:	ec                   	in     (%dx),%al
8010264f:	0f b6 c0             	movzbl %al,%eax
80102652:	89 45 d4             	mov    %eax,-0x2c(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102655:	b0 04                	mov    $0x4,%al
80102657:	89 f2                	mov    %esi,%edx
80102659:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010265a:	89 ca                	mov    %ecx,%edx
8010265c:	ec                   	in     (%dx),%al
8010265d:	0f b6 c0             	movzbl %al,%eax
80102660:	89 45 d8             	mov    %eax,-0x28(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102663:	b0 07                	mov    $0x7,%al
80102665:	89 f2                	mov    %esi,%edx
80102667:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102668:	89 ca                	mov    %ecx,%edx
8010266a:	ec                   	in     (%dx),%al
8010266b:	0f b6 c0             	movzbl %al,%eax
8010266e:	89 45 dc             	mov    %eax,-0x24(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102671:	b0 08                	mov    $0x8,%al
80102673:	89 f2                	mov    %esi,%edx
80102675:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102676:	89 ca                	mov    %ecx,%edx
80102678:	ec                   	in     (%dx),%al
80102679:	0f b6 c0             	movzbl %al,%eax
8010267c:	89 45 e0             	mov    %eax,-0x20(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010267f:	b0 09                	mov    $0x9,%al
80102681:	89 f2                	mov    %esi,%edx
80102683:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102684:	89 ca                	mov    %ecx,%edx
80102686:	ec                   	in     (%dx),%al
80102687:	0f b6 c8             	movzbl %al,%ecx
8010268a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010268d:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80102694:	00 
80102695:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102698:	89 44 24 04          	mov    %eax,0x4(%esp)
8010269c:	8d 55 b8             	lea    -0x48(%ebp),%edx
8010269f:	89 14 24             	mov    %edx,(%esp)
801026a2:	e8 79 18 00 00       	call   80103f20 <memcmp>
801026a7:	85 c0                	test   %eax,%eax
801026a9:	0f 85 0d ff ff ff    	jne    801025bc <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
801026af:	8b 45 a0             	mov    -0x60(%ebp),%eax
801026b2:	85 c0                	test   %eax,%eax
801026b4:	75 78                	jne    8010272e <cmostime+0x19a>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801026b6:	8b 45 b8             	mov    -0x48(%ebp),%eax
801026b9:	89 c2                	mov    %eax,%edx
801026bb:	c1 ea 04             	shr    $0x4,%edx
801026be:	8d 14 92             	lea    (%edx,%edx,4),%edx
801026c1:	83 e0 0f             	and    $0xf,%eax
801026c4:	8d 04 50             	lea    (%eax,%edx,2),%eax
801026c7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
801026ca:	8b 45 bc             	mov    -0x44(%ebp),%eax
801026cd:	89 c2                	mov    %eax,%edx
801026cf:	c1 ea 04             	shr    $0x4,%edx
801026d2:	8d 14 92             	lea    (%edx,%edx,4),%edx
801026d5:	83 e0 0f             	and    $0xf,%eax
801026d8:	8d 04 50             	lea    (%eax,%edx,2),%eax
801026db:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
801026de:	8b 45 c0             	mov    -0x40(%ebp),%eax
801026e1:	89 c2                	mov    %eax,%edx
801026e3:	c1 ea 04             	shr    $0x4,%edx
801026e6:	8d 14 92             	lea    (%edx,%edx,4),%edx
801026e9:	83 e0 0f             	and    $0xf,%eax
801026ec:	8d 04 50             	lea    (%eax,%edx,2),%eax
801026ef:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
801026f2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801026f5:	89 c2                	mov    %eax,%edx
801026f7:	c1 ea 04             	shr    $0x4,%edx
801026fa:	8d 14 92             	lea    (%edx,%edx,4),%edx
801026fd:	83 e0 0f             	and    $0xf,%eax
80102700:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102703:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102706:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102709:	89 c2                	mov    %eax,%edx
8010270b:	c1 ea 04             	shr    $0x4,%edx
8010270e:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102711:	83 e0 0f             	and    $0xf,%eax
80102714:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102717:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
8010271a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010271d:	89 c2                	mov    %eax,%edx
8010271f:	c1 ea 04             	shr    $0x4,%edx
80102722:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102725:	83 e0 0f             	and    $0xf,%eax
80102728:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010272b:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
8010272e:	b9 06 00 00 00       	mov    $0x6,%ecx
80102733:	8b 7d 08             	mov    0x8(%ebp),%edi
80102736:	8b 75 b4             	mov    -0x4c(%ebp),%esi
80102739:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010273b:	8b 45 08             	mov    0x8(%ebp),%eax
8010273e:	81 40 14 d0 07 00 00 	addl   $0x7d0,0x14(%eax)
}
80102745:	83 c4 6c             	add    $0x6c,%esp
80102748:	5b                   	pop    %ebx
80102749:	5e                   	pop    %esi
8010274a:	5f                   	pop    %edi
8010274b:	5d                   	pop    %ebp
8010274c:	c3                   	ret    
8010274d:	00 00                	add    %al,(%eax)
	...

80102750 <install_trans>:
}

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102750:	55                   	push   %ebp
80102751:	89 e5                	mov    %esp,%ebp
80102753:	57                   	push   %edi
80102754:	56                   	push   %esi
80102755:	53                   	push   %ebx
80102756:	83 ec 1c             	sub    $0x1c,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102759:	a1 c8 26 11 80       	mov    0x801126c8,%eax
8010275e:	85 c0                	test   %eax,%eax
80102760:	7e 72                	jle    801027d4 <install_trans+0x84>
80102762:	31 db                	xor    %ebx,%ebx
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102764:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102769:	01 d8                	add    %ebx,%eax
8010276b:	40                   	inc    %eax
8010276c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102770:	a1 c4 26 11 80       	mov    0x801126c4,%eax
80102775:	89 04 24             	mov    %eax,(%esp)
80102778:	e8 37 d9 ff ff       	call   801000b4 <bread>
8010277d:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010277f:	8b 04 9d cc 26 11 80 	mov    -0x7feed934(,%ebx,4),%eax
80102786:	89 44 24 04          	mov    %eax,0x4(%esp)
8010278a:	a1 c4 26 11 80       	mov    0x801126c4,%eax
8010278f:	89 04 24             	mov    %eax,(%esp)
80102792:	e8 1d d9 ff ff       	call   801000b4 <bread>
80102797:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102799:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801027a0:	00 
801027a1:	8d 47 5c             	lea    0x5c(%edi),%eax
801027a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801027a8:	8d 46 5c             	lea    0x5c(%esi),%eax
801027ab:	89 04 24             	mov    %eax,(%esp)
801027ae:	e8 b5 17 00 00       	call   80103f68 <memmove>
    bwrite(dbuf);  // write dst to disk
801027b3:	89 34 24             	mov    %esi,(%esp)
801027b6:	e8 b5 d9 ff ff       	call   80100170 <bwrite>
    brelse(lbuf);
801027bb:	89 3c 24             	mov    %edi,(%esp)
801027be:	e8 e5 d9 ff ff       	call   801001a8 <brelse>
    brelse(dbuf);
801027c3:	89 34 24             	mov    %esi,(%esp)
801027c6:	e8 dd d9 ff ff       	call   801001a8 <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801027cb:	43                   	inc    %ebx
801027cc:	39 1d c8 26 11 80    	cmp    %ebx,0x801126c8
801027d2:	7f 90                	jg     80102764 <install_trans+0x14>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801027d4:	83 c4 1c             	add    $0x1c,%esp
801027d7:	5b                   	pop    %ebx
801027d8:	5e                   	pop    %esi
801027d9:	5f                   	pop    %edi
801027da:	5d                   	pop    %ebp
801027db:	c3                   	ret    

801027dc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801027dc:	55                   	push   %ebp
801027dd:	89 e5                	mov    %esp,%ebp
801027df:	57                   	push   %edi
801027e0:	56                   	push   %esi
801027e1:	53                   	push   %ebx
801027e2:	83 ec 1c             	sub    $0x1c,%esp
  struct buf *buf = bread(log.dev, log.start);
801027e5:	a1 b4 26 11 80       	mov    0x801126b4,%eax
801027ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801027ee:	a1 c4 26 11 80       	mov    0x801126c4,%eax
801027f3:	89 04 24             	mov    %eax,(%esp)
801027f6:	e8 b9 d8 ff ff       	call   801000b4 <bread>
801027fb:	89 c7                	mov    %eax,%edi
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801027fd:	8b 1d c8 26 11 80    	mov    0x801126c8,%ebx
80102803:	89 58 5c             	mov    %ebx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102806:	85 db                	test   %ebx,%ebx
80102808:	7e 16                	jle    80102820 <write_head+0x44>
8010280a:	31 d2                	xor    %edx,%edx
8010280c:	8d 70 5c             	lea    0x5c(%eax),%esi
8010280f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102810:	8b 0c 95 cc 26 11 80 	mov    -0x7feed934(,%edx,4),%ecx
80102817:	89 4c 96 04          	mov    %ecx,0x4(%esi,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010281b:	42                   	inc    %edx
8010281c:	39 da                	cmp    %ebx,%edx
8010281e:	75 f0                	jne    80102810 <write_head+0x34>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80102820:	89 3c 24             	mov    %edi,(%esp)
80102823:	e8 48 d9 ff ff       	call   80100170 <bwrite>
  brelse(buf);
80102828:	89 3c 24             	mov    %edi,(%esp)
8010282b:	e8 78 d9 ff ff       	call   801001a8 <brelse>
}
80102830:	83 c4 1c             	add    $0x1c,%esp
80102833:	5b                   	pop    %ebx
80102834:	5e                   	pop    %esi
80102835:	5f                   	pop    %edi
80102836:	5d                   	pop    %ebp
80102837:	c3                   	ret    

80102838 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102838:	55                   	push   %ebp
80102839:	89 e5                	mov    %esp,%ebp
8010283b:	56                   	push   %esi
8010283c:	53                   	push   %ebx
8010283d:	83 ec 30             	sub    $0x30,%esp
80102840:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102843:	c7 44 24 04 90 6c 10 	movl   $0x80106c90,0x4(%esp)
8010284a:	80 
8010284b:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102852:	e8 99 14 00 00       	call   80103cf0 <initlock>
  readsb(dev, &sb);
80102857:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010285a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010285e:	89 1c 24             	mov    %ebx,(%esp)
80102861:	e8 06 eb ff ff       	call   8010136c <readsb>
  log.start = sb.logstart;
80102866:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102869:	a3 b4 26 11 80       	mov    %eax,0x801126b4
  log.size = sb.nlog;
8010286e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102871:	89 15 b8 26 11 80    	mov    %edx,0x801126b8
  log.dev = dev;
80102877:	89 1d c4 26 11 80    	mov    %ebx,0x801126c4

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
8010287d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102881:	89 1c 24             	mov    %ebx,(%esp)
80102884:	e8 2b d8 ff ff       	call   801000b4 <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102889:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010288c:	89 1d c8 26 11 80    	mov    %ebx,0x801126c8
  for (i = 0; i < log.lh.n; i++) {
80102892:	85 db                	test   %ebx,%ebx
80102894:	7e 16                	jle    801028ac <initlog+0x74>
80102896:	31 d2                	xor    %edx,%edx
80102898:	8d 70 5c             	lea    0x5c(%eax),%esi
8010289b:	90                   	nop
    log.lh.block[i] = lh->block[i];
8010289c:	8b 4c 96 04          	mov    0x4(%esi,%edx,4),%ecx
801028a0:	89 0c 95 cc 26 11 80 	mov    %ecx,-0x7feed934(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801028a7:	42                   	inc    %edx
801028a8:	39 da                	cmp    %ebx,%edx
801028aa:	75 f0                	jne    8010289c <initlog+0x64>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801028ac:	89 04 24             	mov    %eax,(%esp)
801028af:	e8 f4 d8 ff ff       	call   801001a8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
801028b4:	e8 97 fe ff ff       	call   80102750 <install_trans>
  log.lh.n = 0;
801028b9:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
801028c0:	00 00 00 
  write_head(); // clear the log
801028c3:	e8 14 ff ff ff       	call   801027dc <write_head>
  readsb(dev, &sb);
  log.start = sb.logstart;
  log.size = sb.nlog;
  log.dev = dev;
  recover_from_log();
}
801028c8:	83 c4 30             	add    $0x30,%esp
801028cb:	5b                   	pop    %ebx
801028cc:	5e                   	pop    %esi
801028cd:	5d                   	pop    %ebp
801028ce:	c3                   	ret    
801028cf:	90                   	nop

801028d0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
801028d0:	55                   	push   %ebp
801028d1:	89 e5                	mov    %esp,%ebp
801028d3:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801028d6:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028dd:	e8 4a 15 00 00       	call   80103e2c <acquire>
801028e2:	eb 14                	jmp    801028f8 <begin_op+0x28>
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801028e4:	c7 44 24 04 80 26 11 	movl   $0x80112680,0x4(%esp)
801028eb:	80 
801028ec:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
801028f3:	e8 dc 0f 00 00       	call   801038d4 <sleep>
void
begin_op(void)
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
801028f8:	a1 c0 26 11 80       	mov    0x801126c0,%eax
801028fd:	85 c0                	test   %eax,%eax
801028ff:	75 e3                	jne    801028e4 <begin_op+0x14>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102901:	8b 15 bc 26 11 80    	mov    0x801126bc,%edx
80102907:	42                   	inc    %edx
80102908:	8d 04 92             	lea    (%edx,%edx,4),%eax
8010290b:	8b 0d c8 26 11 80    	mov    0x801126c8,%ecx
80102911:	8d 04 41             	lea    (%ecx,%eax,2),%eax
80102914:	83 f8 1e             	cmp    $0x1e,%eax
80102917:	7f cb                	jg     801028e4 <begin_op+0x14>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
80102919:	89 15 bc 26 11 80    	mov    %edx,0x801126bc
      release(&log.lock);
8010291f:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102926:	e8 65 15 00 00       	call   80103e90 <release>
      break;
    }
  }
}
8010292b:	c9                   	leave  
8010292c:	c3                   	ret    
8010292d:	8d 76 00             	lea    0x0(%esi),%esi

80102930 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102930:	55                   	push   %ebp
80102931:	89 e5                	mov    %esp,%ebp
80102933:	57                   	push   %edi
80102934:	56                   	push   %esi
80102935:	53                   	push   %ebx
80102936:	83 ec 1c             	sub    $0x1c,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102939:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102940:	e8 e7 14 00 00       	call   80103e2c <acquire>
  log.outstanding -= 1;
80102945:	a1 bc 26 11 80       	mov    0x801126bc,%eax
8010294a:	48                   	dec    %eax
8010294b:	a3 bc 26 11 80       	mov    %eax,0x801126bc
  if(log.committing)
80102950:	8b 15 c0 26 11 80    	mov    0x801126c0,%edx
80102956:	85 d2                	test   %edx,%edx
80102958:	0f 85 ed 00 00 00    	jne    80102a4b <end_op+0x11b>
    panic("log.committing");
  if(log.outstanding == 0){
8010295e:	85 c0                	test   %eax,%eax
80102960:	0f 85 c5 00 00 00    	jne    80102a2b <end_op+0xfb>
    do_commit = 1;
    log.committing = 1;
80102966:	c7 05 c0 26 11 80 01 	movl   $0x1,0x801126c0
8010296d:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102970:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102977:	e8 14 15 00 00       	call   80103e90 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
8010297c:	a1 c8 26 11 80       	mov    0x801126c8,%eax
80102981:	85 c0                	test   %eax,%eax
80102983:	0f 8e 8c 00 00 00    	jle    80102a15 <end_op+0xe5>
80102989:	31 db                	xor    %ebx,%ebx
8010298b:	90                   	nop
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010298c:	a1 b4 26 11 80       	mov    0x801126b4,%eax
80102991:	01 d8                	add    %ebx,%eax
80102993:	40                   	inc    %eax
80102994:	89 44 24 04          	mov    %eax,0x4(%esp)
80102998:	a1 c4 26 11 80       	mov    0x801126c4,%eax
8010299d:	89 04 24             	mov    %eax,(%esp)
801029a0:	e8 0f d7 ff ff       	call   801000b4 <bread>
801029a5:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801029a7:	8b 04 9d cc 26 11 80 	mov    -0x7feed934(,%ebx,4),%eax
801029ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b2:	a1 c4 26 11 80       	mov    0x801126c4,%eax
801029b7:	89 04 24             	mov    %eax,(%esp)
801029ba:	e8 f5 d6 ff ff       	call   801000b4 <bread>
801029bf:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801029c1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801029c8:	00 
801029c9:	8d 40 5c             	lea    0x5c(%eax),%eax
801029cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801029d0:	8d 46 5c             	lea    0x5c(%esi),%eax
801029d3:	89 04 24             	mov    %eax,(%esp)
801029d6:	e8 8d 15 00 00       	call   80103f68 <memmove>
    bwrite(to);  // write the log
801029db:	89 34 24             	mov    %esi,(%esp)
801029de:	e8 8d d7 ff ff       	call   80100170 <bwrite>
    brelse(from);
801029e3:	89 3c 24             	mov    %edi,(%esp)
801029e6:	e8 bd d7 ff ff       	call   801001a8 <brelse>
    brelse(to);
801029eb:	89 34 24             	mov    %esi,(%esp)
801029ee:	e8 b5 d7 ff ff       	call   801001a8 <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801029f3:	43                   	inc    %ebx
801029f4:	3b 1d c8 26 11 80    	cmp    0x801126c8,%ebx
801029fa:	7c 90                	jl     8010298c <end_op+0x5c>
static void
commit()
{
  if (log.lh.n > 0) {
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
801029fc:	e8 db fd ff ff       	call   801027dc <write_head>
    install_trans(); // Now install writes to home locations
80102a01:	e8 4a fd ff ff       	call   80102750 <install_trans>
    log.lh.n = 0;
80102a06:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
80102a0d:	00 00 00 
    write_head();    // Erase the transaction from the log
80102a10:	e8 c7 fd ff ff       	call   801027dc <write_head>

  if(do_commit){
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
    acquire(&log.lock);
80102a15:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102a1c:	e8 0b 14 00 00       	call   80103e2c <acquire>
    log.committing = 0;
80102a21:	c7 05 c0 26 11 80 00 	movl   $0x0,0x801126c0
80102a28:	00 00 00 
    wakeup(&log);
80102a2b:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102a32:	e8 1d 10 00 00       	call   80103a54 <wakeup>
    release(&log.lock);
80102a37:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102a3e:	e8 4d 14 00 00       	call   80103e90 <release>
  }
}
80102a43:	83 c4 1c             	add    $0x1c,%esp
80102a46:	5b                   	pop    %ebx
80102a47:	5e                   	pop    %esi
80102a48:	5f                   	pop    %edi
80102a49:	5d                   	pop    %ebp
80102a4a:	c3                   	ret    
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
  if(log.committing)
    panic("log.committing");
80102a4b:	c7 04 24 94 6c 10 80 	movl   $0x80106c94,(%esp)
80102a52:	e8 c5 d8 ff ff       	call   8010031c <panic>
80102a57:	90                   	nop

80102a58 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102a58:	55                   	push   %ebp
80102a59:	89 e5                	mov    %esp,%ebp
80102a5b:	53                   	push   %ebx
80102a5c:	83 ec 14             	sub    $0x14,%esp
80102a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102a62:	a1 c8 26 11 80       	mov    0x801126c8,%eax
80102a67:	83 f8 1d             	cmp    $0x1d,%eax
80102a6a:	0f 8f 84 00 00 00    	jg     80102af4 <log_write+0x9c>
80102a70:	8b 15 b8 26 11 80    	mov    0x801126b8,%edx
80102a76:	4a                   	dec    %edx
80102a77:	39 d0                	cmp    %edx,%eax
80102a79:	7d 79                	jge    80102af4 <log_write+0x9c>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102a7b:	8b 0d bc 26 11 80    	mov    0x801126bc,%ecx
80102a81:	85 c9                	test   %ecx,%ecx
80102a83:	7e 7b                	jle    80102b00 <log_write+0xa8>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102a85:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102a8c:	e8 9b 13 00 00       	call   80103e2c <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102a91:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
80102a97:	83 fa 00             	cmp    $0x0,%edx
80102a9a:	7e 49                	jle    80102ae5 <log_write+0x8d>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102a9c:	8b 4b 08             	mov    0x8(%ebx),%ecx
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80102a9f:	31 c0                	xor    %eax,%eax
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102aa1:	39 0d cc 26 11 80    	cmp    %ecx,0x801126cc
80102aa7:	75 0c                	jne    80102ab5 <log_write+0x5d>
80102aa9:	eb 31                	jmp    80102adc <log_write+0x84>
80102aab:	90                   	nop
80102aac:	39 0c 85 cc 26 11 80 	cmp    %ecx,-0x7feed934(,%eax,4)
80102ab3:	74 27                	je     80102adc <log_write+0x84>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80102ab5:	40                   	inc    %eax
80102ab6:	39 d0                	cmp    %edx,%eax
80102ab8:	75 f2                	jne    80102aac <log_write+0x54>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80102aba:	89 0c 95 cc 26 11 80 	mov    %ecx,-0x7feed934(,%edx,4)
  if (i == log.lh.n)
    log.lh.n++;
80102ac1:	42                   	inc    %edx
80102ac2:	89 15 c8 26 11 80    	mov    %edx,0x801126c8
  b->flags |= B_DIRTY; // prevent eviction
80102ac8:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102acb:	c7 45 08 80 26 11 80 	movl   $0x80112680,0x8(%ebp)
}
80102ad2:	83 c4 14             	add    $0x14,%esp
80102ad5:	5b                   	pop    %ebx
80102ad6:	5d                   	pop    %ebp
  }
  log.lh.block[i] = b->blockno;
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
  release(&log.lock);
80102ad7:	e9 b4 13 00 00       	jmp    80103e90 <release>
  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80102adc:	89 0c 85 cc 26 11 80 	mov    %ecx,-0x7feed934(,%eax,4)
80102ae3:	eb e3                	jmp    80102ac8 <log_write+0x70>
80102ae5:	8b 43 08             	mov    0x8(%ebx),%eax
80102ae8:	a3 cc 26 11 80       	mov    %eax,0x801126cc
  if (i == log.lh.n)
80102aed:	75 d9                	jne    80102ac8 <log_write+0x70>
80102aef:	eb d0                	jmp    80102ac1 <log_write+0x69>
80102af1:	8d 76 00             	lea    0x0(%esi),%esi
log_write(struct buf *b)
{
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
80102af4:	c7 04 24 a3 6c 10 80 	movl   $0x80106ca3,(%esp)
80102afb:	e8 1c d8 ff ff       	call   8010031c <panic>
  if (log.outstanding < 1)
    panic("log_write outside of trans");
80102b00:	c7 04 24 b9 6c 10 80 	movl   $0x80106cb9,(%esp)
80102b07:	e8 10 d8 ff ff       	call   8010031c <panic>

80102b0c <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80102b0c:	55                   	push   %ebp
80102b0d:	89 e5                	mov    %esp,%ebp
80102b0f:	53                   	push   %ebx
80102b10:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102b13:	e8 6c 08 00 00       	call   80103384 <cpuid>
80102b18:	89 c3                	mov    %eax,%ebx
80102b1a:	e8 65 08 00 00       	call   80103384 <cpuid>
80102b1f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80102b23:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b27:	c7 04 24 d4 6c 10 80 	movl   $0x80106cd4,(%esp)
80102b2e:	e8 89 da ff ff       	call   801005bc <cprintf>
  idtinit();       // load idt register
80102b33:	e8 d0 24 00 00       	call   80105008 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102b38:	e8 d3 07 00 00       	call   80103310 <mycpu>
80102b3d:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102b3f:	b8 01 00 00 00       	mov    $0x1,%eax
80102b44:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102b4b:	e8 fc 0a 00 00       	call   8010364c <scheduler>

80102b50 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80102b50:	55                   	push   %ebp
80102b51:	89 e5                	mov    %esp,%ebp
80102b53:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102b56:	e8 8d 35 00 00       	call   801060e8 <switchkvm>
  seginit();
80102b5b:	e8 30 34 00 00       	call   80105f90 <seginit>
  lapicinit();
80102b60:	e8 8b f8 ff ff       	call   801023f0 <lapicinit>
  mpmain();
80102b65:	e8 a2 ff ff ff       	call   80102b0c <mpmain>
	...

80102b6c <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80102b6c:	55                   	push   %ebp
80102b6d:	89 e5                	mov    %esp,%ebp
80102b6f:	53                   	push   %ebx
80102b70:	83 e4 f0             	and    $0xfffffff0,%esp
80102b73:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102b76:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80102b7d:	80 
80102b7e:	c7 04 24 a8 57 11 80 	movl   $0x801157a8,(%esp)
80102b85:	e8 02 f7 ff ff       	call   8010228c <kinit1>
  kvmalloc();      // kernel page table
80102b8a:	e8 85 3a 00 00       	call   80106614 <kvmalloc>
  mpinit();        // detect other processors
80102b8f:	e8 58 01 00 00       	call   80102cec <mpinit>
  lapicinit();     // interrupt controller
80102b94:	e8 57 f8 ff ff       	call   801023f0 <lapicinit>
  seginit();       // segment descriptors
80102b99:	e8 f2 33 00 00       	call   80105f90 <seginit>
  picinit();       // disable pic
80102b9e:	e8 e1 02 00 00       	call   80102e84 <picinit>
  ioapicinit();    // another interrupt controller
80102ba3:	e8 0c f5 ff ff       	call   801020b4 <ioapicinit>
  consoleinit();   // console hardware
80102ba8:	e8 d7 dc ff ff       	call   80100884 <consoleinit>
  uartinit();      // serial port
80102bad:	e8 4a 28 00 00       	call   801053fc <uartinit>
  pinit();         // process table
80102bb2:	e8 3d 07 00 00       	call   801032f4 <pinit>
  tvinit();        // trap vectors
80102bb7:	e8 c8 23 00 00       	call   80104f84 <tvinit>
  binit();         // buffer cache
80102bbc:	e8 73 d4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80102bc1:	e8 86 e0 ff ff       	call   80100c4c <fileinit>
  ideinit();       // disk 
80102bc6:	e8 15 f3 ff ff       	call   80101ee0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102bcb:	c7 44 24 08 8a 00 00 	movl   $0x8a,0x8(%esp)
80102bd2:	00 
80102bd3:	c7 44 24 04 8c a4 10 	movl   $0x8010a48c,0x4(%esp)
80102bda:	80 
80102bdb:	c7 04 24 00 70 00 80 	movl   $0x80007000,(%esp)
80102be2:	e8 81 13 00 00       	call   80103f68 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102be7:	a1 00 2d 11 80       	mov    0x80112d00,%eax
80102bec:	8d 14 80             	lea    (%eax,%eax,4),%edx
80102bef:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102bf2:	c1 e0 04             	shl    $0x4,%eax
80102bf5:	05 80 27 11 80       	add    $0x80112780,%eax
80102bfa:	3d 80 27 11 80       	cmp    $0x80112780,%eax
80102bff:	76 6e                	jbe    80102c6f <main+0x103>
80102c01:	bb 80 27 11 80       	mov    $0x80112780,%ebx
80102c06:	66 90                	xchg   %ax,%ax
    if(c == mycpu())  // We've started already.
80102c08:	e8 03 07 00 00       	call   80103310 <mycpu>
80102c0d:	39 d8                	cmp    %ebx,%eax
80102c0f:	74 41                	je     80102c52 <main+0xe6>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102c11:	e8 b6 f6 ff ff       	call   801022cc <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102c16:	05 00 10 00 00       	add    $0x1000,%eax
80102c1b:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102c20:	c7 05 f8 6f 00 80 50 	movl   $0x80102b50,0x80006ff8
80102c27:	2b 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102c2a:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102c31:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102c34:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
80102c3b:	00 
80102c3c:	0f b6 03             	movzbl (%ebx),%eax
80102c3f:	89 04 24             	mov    %eax,(%esp)
80102c42:	e8 c9 f8 ff ff       	call   80102510 <lapicstartap>
80102c47:	90                   	nop

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102c48:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102c4e:	85 c0                	test   %eax,%eax
80102c50:	74 f6                	je     80102c48 <main+0xdc>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80102c52:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102c58:	a1 00 2d 11 80       	mov    0x80112d00,%eax
80102c5d:	8d 14 80             	lea    (%eax,%eax,4),%edx
80102c60:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102c63:	c1 e0 04             	shl    $0x4,%eax
80102c66:	05 80 27 11 80       	add    $0x80112780,%eax
80102c6b:	39 c3                	cmp    %eax,%ebx
80102c6d:	72 99                	jb     80102c08 <main+0x9c>
  tvinit();        // trap vectors
  binit();         // buffer cache
  fileinit();      // file table
  ideinit();       // disk 
  startothers();   // start other processors
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102c6f:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80102c76:	8e 
80102c77:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80102c7e:	e8 e5 f5 ff ff       	call   80102268 <kinit2>
  userinit();      // first user process
80102c83:	e8 50 07 00 00       	call   801033d8 <userinit>
  mpmain();        // finish this processor's setup
80102c88:	e8 7f fe ff ff       	call   80102b0c <mpmain>
80102c8d:	00 00                	add    %al,(%eax)
	...

80102c90 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102c90:	55                   	push   %ebp
80102c91:	89 e5                	mov    %esp,%ebp
80102c93:	56                   	push   %esi
80102c94:	53                   	push   %ebx
80102c95:	83 ec 10             	sub    $0x10,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80102c98:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
  e = addr+len;
80102c9e:	8d 34 13             	lea    (%ebx,%edx,1),%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102ca1:	39 f3                	cmp    %esi,%ebx
80102ca3:	73 3a                	jae    80102cdf <mpsearch1+0x4f>
80102ca5:	8d 76 00             	lea    0x0(%esi),%esi
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102ca8:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80102caf:	00 
80102cb0:	c7 44 24 04 e8 6c 10 	movl   $0x80106ce8,0x4(%esp)
80102cb7:	80 
80102cb8:	89 1c 24             	mov    %ebx,(%esp)
80102cbb:	e8 60 12 00 00       	call   80103f20 <memcmp>
80102cc0:	85 c0                	test   %eax,%eax
80102cc2:	75 14                	jne    80102cd8 <mpsearch1+0x48>
80102cc4:	31 d2                	xor    %edx,%edx
80102cc6:	66 90                	xchg   %ax,%ax
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
    sum += addr[i];
80102cc8:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
80102ccc:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80102cce:	40                   	inc    %eax
80102ccf:	83 f8 10             	cmp    $0x10,%eax
80102cd2:	75 f4                	jne    80102cc8 <mpsearch1+0x38>
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102cd4:	84 d2                	test   %dl,%dl
80102cd6:	74 09                	je     80102ce1 <mpsearch1+0x51>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80102cd8:	83 c3 10             	add    $0x10,%ebx
80102cdb:	39 de                	cmp    %ebx,%esi
80102cdd:	77 c9                	ja     80102ca8 <mpsearch1+0x18>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80102cdf:	31 db                	xor    %ebx,%ebx
}
80102ce1:	89 d8                	mov    %ebx,%eax
80102ce3:	83 c4 10             	add    $0x10,%esp
80102ce6:	5b                   	pop    %ebx
80102ce7:	5e                   	pop    %esi
80102ce8:	5d                   	pop    %ebp
80102ce9:	c3                   	ret    
80102cea:	66 90                	xchg   %ax,%ax

80102cec <mpinit>:
  return conf;
}

void
mpinit(void)
{
80102cec:	55                   	push   %ebp
80102ced:	89 e5                	mov    %esp,%ebp
80102cef:	57                   	push   %edi
80102cf0:	56                   	push   %esi
80102cf1:	53                   	push   %ebx
80102cf2:	83 ec 2c             	sub    $0x2c,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102cf5:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102cfc:	c1 e0 08             	shl    $0x8,%eax
80102cff:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102d06:	09 d0                	or     %edx,%eax
80102d08:	c1 e0 04             	shl    $0x4,%eax
80102d0b:	75 1b                	jne    80102d28 <mpinit+0x3c>
    if((mp = mpsearch1(p, 1024)))
      return mp;
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102d0d:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102d14:	c1 e0 08             	shl    $0x8,%eax
80102d17:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102d1e:	09 d0                	or     %edx,%eax
80102d20:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102d23:	2d 00 04 00 00       	sub    $0x400,%eax
80102d28:	ba 00 04 00 00       	mov    $0x400,%edx
80102d2d:	e8 5e ff ff ff       	call   80102c90 <mpsearch1>
80102d32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80102d35:	85 c0                	test   %eax,%eax
80102d37:	0f 84 15 01 00 00    	je     80102e52 <mpinit+0x166>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102d3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d40:	8b 58 04             	mov    0x4(%eax),%ebx
80102d43:	85 db                	test   %ebx,%ebx
80102d45:	0f 84 21 01 00 00    	je     80102e6c <mpinit+0x180>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102d4b:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102d51:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80102d58:	00 
80102d59:	c7 44 24 04 ed 6c 10 	movl   $0x80106ced,0x4(%esp)
80102d60:	80 
80102d61:	89 34 24             	mov    %esi,(%esp)
80102d64:	e8 b7 11 00 00       	call   80103f20 <memcmp>
80102d69:	85 c0                	test   %eax,%eax
80102d6b:	0f 85 fb 00 00 00    	jne    80102e6c <mpinit+0x180>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102d71:	8a 83 06 00 00 80    	mov    -0x7ffffffa(%ebx),%al
80102d77:	3c 01                	cmp    $0x1,%al
80102d79:	74 08                	je     80102d83 <mpinit+0x97>
80102d7b:	3c 04                	cmp    $0x4,%al
80102d7d:	0f 85 e9 00 00 00    	jne    80102e6c <mpinit+0x180>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102d83:	0f b7 bb 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edi
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80102d8a:	85 ff                	test   %edi,%edi
80102d8c:	74 1d                	je     80102dab <mpinit+0xbf>
80102d8e:	31 d2                	xor    %edx,%edx
80102d90:	31 c0                	xor    %eax,%eax
80102d92:	66 90                	xchg   %ax,%ax
    sum += addr[i];
80102d94:	0f b6 8c 03 00 00 00 	movzbl -0x80000000(%ebx,%eax,1),%ecx
80102d9b:	80 
80102d9c:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80102d9e:	40                   	inc    %eax
80102d9f:	39 c7                	cmp    %eax,%edi
80102da1:	7f f1                	jg     80102d94 <mpinit+0xa8>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102da3:	84 d2                	test   %dl,%dl
80102da5:	0f 85 c1 00 00 00    	jne    80102e6c <mpinit+0x180>
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102dab:	85 f6                	test   %esi,%esi
80102dad:	0f 84 b9 00 00 00    	je     80102e6c <mpinit+0x180>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102db3:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
80102db9:	a3 7c 26 11 80       	mov    %eax,0x8011267c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102dbe:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
80102dc4:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102dcb:	01 d6                	add    %edx,%esi
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
80102dcd:	b9 01 00 00 00       	mov    $0x1,%ecx
80102dd2:	66 90                	xchg   %ax,%ax
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102dd4:	39 f0                	cmp    %esi,%eax
80102dd6:	73 1f                	jae    80102df7 <mpinit+0x10b>
80102dd8:	8a 10                	mov    (%eax),%dl
    switch(*p){
80102dda:	80 fa 04             	cmp    $0x4,%dl
80102ddd:	76 07                	jbe    80102de6 <mpinit+0xfa>
    case MPIOINTR:
    case MPLINTR:
      p += 8;
      continue;
    default:
      ismp = 0;
80102ddf:	31 c9                	xor    %ecx,%ecx
  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
80102de1:	80 fa 04             	cmp    $0x4,%dl
80102de4:	77 f9                	ja     80102ddf <mpinit+0xf3>
80102de6:	0f b6 d2             	movzbl %dl,%edx
80102de9:	ff 24 95 2c 6d 10 80 	jmp    *-0x7fef92d4(,%edx,4)
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102df0:	83 c0 08             	add    $0x8,%eax

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102df3:	39 f0                	cmp    %esi,%eax
80102df5:	72 e1                	jb     80102dd8 <mpinit+0xec>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102df7:	85 c9                	test   %ecx,%ecx
80102df9:	74 7d                	je     80102e78 <mpinit+0x18c>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102dfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102dfe:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102e02:	74 0f                	je     80102e13 <mpinit+0x127>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e04:	ba 22 00 00 00       	mov    $0x22,%edx
80102e09:	b0 70                	mov    $0x70,%al
80102e0b:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e0c:	b2 23                	mov    $0x23,%dl
80102e0e:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102e0f:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e12:	ee                   	out    %al,(%dx)
  }
}
80102e13:	83 c4 2c             	add    $0x2c,%esp
80102e16:	5b                   	pop    %ebx
80102e17:	5e                   	pop    %esi
80102e18:	5f                   	pop    %edi
80102e19:	5d                   	pop    %ebp
80102e1a:	c3                   	ret    
80102e1b:	90                   	nop
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102e1c:	8b 15 00 2d 11 80    	mov    0x80112d00,%edx
80102e22:	83 fa 07             	cmp    $0x7,%edx
80102e25:	7f 18                	jg     80102e3f <mpinit+0x153>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102e27:	8a 58 01             	mov    0x1(%eax),%bl
80102e2a:	8d 3c 92             	lea    (%edx,%edx,4),%edi
80102e2d:	8d 14 7a             	lea    (%edx,%edi,2),%edx
80102e30:	c1 e2 04             	shl    $0x4,%edx
80102e33:	88 9a 80 27 11 80    	mov    %bl,-0x7feed880(%edx)
        ncpu++;
80102e39:	ff 05 00 2d 11 80    	incl   0x80112d00
      }
      p += sizeof(struct mpproc);
80102e3f:	83 c0 14             	add    $0x14,%eax
      continue;
80102e42:	eb 90                	jmp    80102dd4 <mpinit+0xe8>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102e44:	8a 50 01             	mov    0x1(%eax),%dl
80102e47:	88 15 60 27 11 80    	mov    %dl,0x80112760
      p += sizeof(struct mpioapic);
80102e4d:	83 c0 08             	add    $0x8,%eax
      continue;
80102e50:	eb 82                	jmp    80102dd4 <mpinit+0xe8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102e52:	ba 00 00 01 00       	mov    $0x10000,%edx
80102e57:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102e5c:	e8 2f fe ff ff       	call   80102c90 <mpsearch1>
80102e61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102e64:	85 c0                	test   %eax,%eax
80102e66:	0f 85 d1 fe ff ff    	jne    80102d3d <mpinit+0x51>
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
80102e6c:	c7 04 24 f2 6c 10 80 	movl   $0x80106cf2,(%esp)
80102e73:	e8 a4 d4 ff ff       	call   8010031c <panic>
      ismp = 0;
      break;
    }
  }
  if(!ismp)
    panic("Didn't find a suitable machine");
80102e78:	c7 04 24 0c 6d 10 80 	movl   $0x80106d0c,(%esp)
80102e7f:	e8 98 d4 ff ff       	call   8010031c <panic>

80102e84 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102e84:	55                   	push   %ebp
80102e85:	89 e5                	mov    %esp,%ebp
80102e87:	ba 21 00 00 00       	mov    $0x21,%edx
80102e8c:	b0 ff                	mov    $0xff,%al
80102e8e:	ee                   	out    %al,(%dx)
80102e8f:	b2 a1                	mov    $0xa1,%dl
80102e91:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102e92:	5d                   	pop    %ebp
80102e93:	c3                   	ret    

80102e94 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102e94:	55                   	push   %ebp
80102e95:	89 e5                	mov    %esp,%ebp
80102e97:	56                   	push   %esi
80102e98:	53                   	push   %ebx
80102e99:	83 ec 20             	sub    $0x20,%esp
80102e9c:	8b 75 08             	mov    0x8(%ebp),%esi
80102e9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102ea2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80102ea8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102eae:	e8 b5 dd ff ff       	call   80100c68 <filealloc>
80102eb3:	89 06                	mov    %eax,(%esi)
80102eb5:	85 c0                	test   %eax,%eax
80102eb7:	0f 84 a1 00 00 00    	je     80102f5e <pipealloc+0xca>
80102ebd:	e8 a6 dd ff ff       	call   80100c68 <filealloc>
80102ec2:	89 03                	mov    %eax,(%ebx)
80102ec4:	85 c0                	test   %eax,%eax
80102ec6:	0f 84 84 00 00 00    	je     80102f50 <pipealloc+0xbc>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102ecc:	e8 fb f3 ff ff       	call   801022cc <kalloc>
80102ed1:	85 c0                	test   %eax,%eax
80102ed3:	74 7b                	je     80102f50 <pipealloc+0xbc>
    goto bad;
  p->readopen = 1;
80102ed5:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102edc:	00 00 00 
  p->writeopen = 1;
80102edf:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102ee6:	00 00 00 
  p->nwrite = 0;
80102ee9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102ef0:	00 00 00 
  p->nread = 0;
80102ef3:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102efa:	00 00 00 
  initlock(&p->lock, "pipe");
80102efd:	c7 44 24 04 40 6d 10 	movl   $0x80106d40,0x4(%esp)
80102f04:	80 
80102f05:	89 04 24             	mov    %eax,(%esp)
80102f08:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102f0b:	e8 e0 0d 00 00       	call   80103cf0 <initlock>
  (*f0)->type = FD_PIPE;
80102f10:	8b 16                	mov    (%esi),%edx
80102f12:	c7 02 01 00 00 00    	movl   $0x1,(%edx)
  (*f0)->readable = 1;
80102f18:	8b 16                	mov    (%esi),%edx
80102f1a:	c6 42 08 01          	movb   $0x1,0x8(%edx)
  (*f0)->writable = 0;
80102f1e:	8b 16                	mov    (%esi),%edx
80102f20:	c6 42 09 00          	movb   $0x0,0x9(%edx)
  (*f0)->pipe = p;
80102f24:	8b 16                	mov    (%esi),%edx
80102f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f29:	89 42 0c             	mov    %eax,0xc(%edx)
  (*f1)->type = FD_PIPE;
80102f2c:	8b 13                	mov    (%ebx),%edx
80102f2e:	c7 02 01 00 00 00    	movl   $0x1,(%edx)
  (*f1)->readable = 0;
80102f34:	8b 13                	mov    (%ebx),%edx
80102f36:	c6 42 08 00          	movb   $0x0,0x8(%edx)
  (*f1)->writable = 1;
80102f3a:	8b 13                	mov    (%ebx),%edx
80102f3c:	c6 42 09 01          	movb   $0x1,0x9(%edx)
  (*f1)->pipe = p;
80102f40:	8b 13                	mov    (%ebx),%edx
80102f42:	89 42 0c             	mov    %eax,0xc(%edx)
  return 0;
80102f45:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
80102f47:	83 c4 20             	add    $0x20,%esp
80102f4a:	5b                   	pop    %ebx
80102f4b:	5e                   	pop    %esi
80102f4c:	5d                   	pop    %ebp
80102f4d:	c3                   	ret    
80102f4e:	66 90                	xchg   %ax,%ax

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102f50:	8b 06                	mov    (%esi),%eax
80102f52:	85 c0                	test   %eax,%eax
80102f54:	74 08                	je     80102f5e <pipealloc+0xca>
    fileclose(*f0);
80102f56:	89 04 24             	mov    %eax,(%esp)
80102f59:	e8 ba dd ff ff       	call   80100d18 <fileclose>
  if(*f1)
80102f5e:	8b 03                	mov    (%ebx),%eax
80102f60:	85 c0                	test   %eax,%eax
80102f62:	74 14                	je     80102f78 <pipealloc+0xe4>
    fileclose(*f1);
80102f64:	89 04 24             	mov    %eax,(%esp)
80102f67:	e8 ac dd ff ff       	call   80100d18 <fileclose>
  return -1;
80102f6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f71:	83 c4 20             	add    $0x20,%esp
80102f74:	5b                   	pop    %ebx
80102f75:	5e                   	pop    %esi
80102f76:	5d                   	pop    %ebp
80102f77:	c3                   	ret    
    kfree((char*)p);
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
80102f78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f7d:	83 c4 20             	add    $0x20,%esp
80102f80:	5b                   	pop    %ebx
80102f81:	5e                   	pop    %esi
80102f82:	5d                   	pop    %ebp
80102f83:	c3                   	ret    

80102f84 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102f84:	55                   	push   %ebp
80102f85:	89 e5                	mov    %esp,%ebp
80102f87:	56                   	push   %esi
80102f88:	53                   	push   %ebx
80102f89:	83 ec 10             	sub    $0x10,%esp
80102f8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102f8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
80102f92:	89 1c 24             	mov    %ebx,(%esp)
80102f95:	e8 92 0e 00 00       	call   80103e2c <acquire>
  if(writable){
80102f9a:	85 f6                	test   %esi,%esi
80102f9c:	74 3a                	je     80102fd8 <pipeclose+0x54>
    p->writeopen = 0;
80102f9e:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102fa5:	00 00 00 
    wakeup(&p->nread);
80102fa8:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fae:	89 04 24             	mov    %eax,(%esp)
80102fb1:	e8 9e 0a 00 00       	call   80103a54 <wakeup>
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102fb6:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
80102fbc:	85 d2                	test   %edx,%edx
80102fbe:	75 0a                	jne    80102fca <pipeclose+0x46>
80102fc0:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80102fc6:	85 c0                	test   %eax,%eax
80102fc8:	74 2a                	je     80102ff4 <pipeclose+0x70>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102fca:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80102fcd:	83 c4 10             	add    $0x10,%esp
80102fd0:	5b                   	pop    %ebx
80102fd1:	5e                   	pop    %esi
80102fd2:	5d                   	pop    %ebp
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102fd3:	e9 b8 0e 00 00       	jmp    80103e90 <release>
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
80102fd8:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102fdf:	00 00 00 
    wakeup(&p->nwrite);
80102fe2:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102fe8:	89 04 24             	mov    %eax,(%esp)
80102feb:	e8 64 0a 00 00       	call   80103a54 <wakeup>
80102ff0:	eb c4                	jmp    80102fb6 <pipeclose+0x32>
80102ff2:	66 90                	xchg   %ax,%ax
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
80102ff4:	89 1c 24             	mov    %ebx,(%esp)
80102ff7:	e8 94 0e 00 00       	call   80103e90 <release>
    kfree((char*)p);
80102ffc:	89 5d 08             	mov    %ebx,0x8(%ebp)
  } else
    release(&p->lock);
}
80102fff:	83 c4 10             	add    $0x10,%esp
80103002:	5b                   	pop    %ebx
80103003:	5e                   	pop    %esi
80103004:	5d                   	pop    %ebp
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
80103005:	e9 7e f1 ff ff       	jmp    80102188 <kfree>
8010300a:	66 90                	xchg   %ax,%ax

8010300c <pipewrite>:
}

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010300c:	55                   	push   %ebp
8010300d:	89 e5                	mov    %esp,%ebp
8010300f:	57                   	push   %edi
80103010:	56                   	push   %esi
80103011:	53                   	push   %ebx
80103012:	83 ec 2c             	sub    $0x2c,%esp
80103015:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103018:	89 1c 24             	mov    %ebx,(%esp)
8010301b:	e8 0c 0e 00 00       	call   80103e2c <acquire>
  for(i = 0; i < n; i++){
80103020:	8b 45 10             	mov    0x10(%ebp),%eax
80103023:	85 c0                	test   %eax,%eax
80103025:	0f 8e 8a 00 00 00    	jle    801030b5 <pipewrite+0xa9>
8010302b:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103031:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103038:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010303e:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
80103044:	eb 32                	jmp    80103078 <pipewrite+0x6c>
80103046:	66 90                	xchg   %ax,%ax
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103048:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
8010304e:	85 c0                	test   %eax,%eax
80103050:	74 7e                	je     801030d0 <pipewrite+0xc4>
80103052:	e8 61 03 00 00       	call   801033b8 <myproc>
80103057:	8b 48 24             	mov    0x24(%eax),%ecx
8010305a:	85 c9                	test   %ecx,%ecx
8010305c:	75 72                	jne    801030d0 <pipewrite+0xc4>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
8010305e:	89 3c 24             	mov    %edi,(%esp)
80103061:	e8 ee 09 00 00       	call   80103a54 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103066:	89 5c 24 04          	mov    %ebx,0x4(%esp)
8010306a:	89 34 24             	mov    %esi,(%esp)
8010306d:	e8 62 08 00 00       	call   801038d4 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103072:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103078:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
8010307e:	81 c2 00 02 00 00    	add    $0x200,%edx
80103084:	39 d0                	cmp    %edx,%eax
80103086:	74 c0                	je     80103048 <pipewrite+0x3c>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103088:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010308b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010308e:	8a 14 11             	mov    (%ecx,%edx,1),%dl
80103091:	88 55 e3             	mov    %dl,-0x1d(%ebp)
80103094:	89 c2                	mov    %eax,%edx
80103096:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010309c:	8a 4d e3             	mov    -0x1d(%ebp),%cl
8010309f:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
801030a3:	40                   	inc    %eax
801030a4:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801030aa:	ff 45 e4             	incl   -0x1c(%ebp)
801030ad:	8b 55 10             	mov    0x10(%ebp),%edx
801030b0:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
801030b3:	75 c3                	jne    80103078 <pipewrite+0x6c>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801030b5:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030bb:	89 04 24             	mov    %eax,(%esp)
801030be:	e8 91 09 00 00       	call   80103a54 <wakeup>
  release(&p->lock);
801030c3:	89 1c 24             	mov    %ebx,(%esp)
801030c6:	e8 c5 0d 00 00       	call   80103e90 <release>
  return n;
801030cb:	eb 12                	jmp    801030df <pipewrite+0xd3>
801030cd:	8d 76 00             	lea    0x0(%esi),%esi

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
801030d0:	89 1c 24             	mov    %ebx,(%esp)
801030d3:	e8 b8 0d 00 00       	call   80103e90 <release>
        return -1;
801030d8:	c7 45 10 ff ff ff ff 	movl   $0xffffffff,0x10(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
801030df:	8b 45 10             	mov    0x10(%ebp),%eax
801030e2:	83 c4 2c             	add    $0x2c,%esp
801030e5:	5b                   	pop    %ebx
801030e6:	5e                   	pop    %esi
801030e7:	5f                   	pop    %edi
801030e8:	5d                   	pop    %ebp
801030e9:	c3                   	ret    
801030ea:	66 90                	xchg   %ax,%ax

801030ec <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801030ec:	55                   	push   %ebp
801030ed:	89 e5                	mov    %esp,%ebp
801030ef:	57                   	push   %edi
801030f0:	56                   	push   %esi
801030f1:	53                   	push   %ebx
801030f2:	83 ec 2c             	sub    $0x2c,%esp
801030f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
801030f8:	8b 7d 10             	mov    0x10(%ebp),%edi
  int i;

  acquire(&p->lock);
801030fb:	89 1c 24             	mov    %ebx,(%esp)
801030fe:	e8 29 0d 00 00       	call   80103e2c <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103103:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
80103109:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
8010310f:	75 5b                	jne    8010316c <piperead+0x80>
80103111:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103117:	85 c0                	test   %eax,%eax
80103119:	74 51                	je     8010316c <piperead+0x80>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010311b:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
80103121:	eb 25                	jmp    80103148 <piperead+0x5c>
80103123:	90                   	nop
80103124:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80103128:	89 34 24             	mov    %esi,(%esp)
8010312b:	e8 a4 07 00 00       	call   801038d4 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103130:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
80103136:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
8010313c:	75 2e                	jne    8010316c <piperead+0x80>
8010313e:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103144:	85 c0                	test   %eax,%eax
80103146:	74 24                	je     8010316c <piperead+0x80>
    if(myproc()->killed){
80103148:	e8 6b 02 00 00       	call   801033b8 <myproc>
8010314d:	8b 40 24             	mov    0x24(%eax),%eax
80103150:	85 c0                	test   %eax,%eax
80103152:	74 d0                	je     80103124 <piperead+0x38>
      release(&p->lock);
80103154:	89 1c 24             	mov    %ebx,(%esp)
80103157:	e8 34 0d 00 00       	call   80103e90 <release>
      return -1;
8010315c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
80103161:	83 c4 2c             	add    $0x2c,%esp
80103164:	5b                   	pop    %ebx
80103165:	5e                   	pop    %esi
80103166:	5f                   	pop    %edi
80103167:	5d                   	pop    %ebp
80103168:	c3                   	ret    
80103169:	8d 76 00             	lea    0x0(%esi),%esi
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
8010316c:	31 c0                	xor    %eax,%eax
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010316e:	85 ff                	test   %edi,%edi
80103170:	7e 35                	jle    801031a7 <piperead+0xbb>
    if(p->nread == p->nwrite)
80103172:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
80103178:	74 2d                	je     801031a7 <piperead+0xbb>
  release(&p->lock);
  return n;
}

int
piperead(struct pipe *p, char *addr, int n)
8010317a:	8b 75 0c             	mov    0xc(%ebp),%esi
8010317d:	29 d6                	sub    %edx,%esi
8010317f:	eb 0b                	jmp    8010318c <piperead+0xa0>
80103181:	8d 76 00             	lea    0x0(%esi),%esi
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
80103184:	39 93 38 02 00 00    	cmp    %edx,0x238(%ebx)
8010318a:	74 1b                	je     801031a7 <piperead+0xbb>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010318c:	89 d1                	mov    %edx,%ecx
8010318e:	81 e1 ff 01 00 00    	and    $0x1ff,%ecx
80103194:	8a 4c 0b 34          	mov    0x34(%ebx,%ecx,1),%cl
80103198:	88 0c 16             	mov    %cl,(%esi,%edx,1)
8010319b:	42                   	inc    %edx
8010319c:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801031a2:	40                   	inc    %eax
801031a3:	39 f8                	cmp    %edi,%eax
801031a5:	75 dd                	jne    80103184 <piperead+0x98>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801031a7:	8d 93 38 02 00 00    	lea    0x238(%ebx),%edx
801031ad:	89 14 24             	mov    %edx,(%esp)
801031b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801031b3:	e8 9c 08 00 00       	call   80103a54 <wakeup>
  release(&p->lock);
801031b8:	89 1c 24             	mov    %ebx,(%esp)
801031bb:	e8 d0 0c 00 00       	call   80103e90 <release>
801031c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  return i;
}
801031c3:	83 c4 2c             	add    $0x2c,%esp
801031c6:	5b                   	pop    %ebx
801031c7:	5e                   	pop    %esi
801031c8:	5f                   	pop    %edi
801031c9:	5d                   	pop    %ebp
801031ca:	c3                   	ret    
	...

801031cc <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801031cc:	55                   	push   %ebp
801031cd:	89 e5                	mov    %esp,%ebp
801031cf:	53                   	push   %ebx
801031d0:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  char *sp;
  
  acquire(&ptable.lock);
801031d3:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801031da:	e8 4d 0c 00 00       	call   80103e2c <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031df:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
    if(p->state == UNUSED)
801031e4:	8b 15 60 2d 11 80    	mov    0x80112d60,%edx
801031ea:	85 d2                	test   %edx,%edx
801031ec:	74 1b                	je     80103209 <allocproc+0x3d>
801031ee:	66 90                	xchg   %ax,%ax
  struct proc *p;
  char *sp;
  
  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031f0:	81 c3 88 00 00 00    	add    $0x88,%ebx
801031f6:	81 fb 54 4f 11 80    	cmp    $0x80114f54,%ebx
801031fc:	0f 83 8a 00 00 00    	jae    8010328c <allocproc+0xc0>
    if(p->state == UNUSED)
80103202:	8b 43 0c             	mov    0xc(%ebx),%eax
80103205:	85 c0                	test   %eax,%eax
80103207:	75 e7                	jne    801031f0 <allocproc+0x24>

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80103209:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103210:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80103215:	89 43 10             	mov    %eax,0x10(%ebx)
80103218:	40                   	inc    %eax
80103219:	a3 00 a0 10 80       	mov    %eax,0x8010a000

  release(&ptable.lock);
8010321e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103225:	e8 66 0c 00 00       	call   80103e90 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010322a:	e8 9d f0 ff ff       	call   801022cc <kalloc>
8010322f:	89 43 08             	mov    %eax,0x8(%ebx)
80103232:	85 c0                	test   %eax,%eax
80103234:	74 6c                	je     801032a2 <allocproc+0xd6>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103236:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
8010323c:	89 53 18             	mov    %edx,0x18(%ebx)
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
8010323f:	c7 80 b0 0f 00 00 78 	movl   $0x80104f78,0xfb0(%eax)
80103246:	4f 10 80 

  sp -= sizeof *p->context;
80103249:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
8010324e:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103251:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80103258:	00 
80103259:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103260:	00 
80103261:	89 04 24             	mov    %eax,(%esp)
80103264:	e8 6f 0c 00 00       	call   80103ed8 <memset>
  p->context->eip = (uint)forkret;
80103269:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010326c:	c7 40 10 b0 32 10 80 	movl   $0x801032b0,0x10(%eax)
  p->curalarmticks = 0;
80103273:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
8010327a:	00 00 00 
  p->alarmticks = 0xFFFFFFFF;
8010327d:	c7 43 7c ff ff ff ff 	movl   $0xffffffff,0x7c(%ebx)

  return p;
}
80103284:	89 d8                	mov    %ebx,%eax
80103286:	83 c4 14             	add    $0x14,%esp
80103289:	5b                   	pop    %ebx
8010328a:	5d                   	pop    %ebp
8010328b:	c3                   	ret    

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
8010328c:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103293:	e8 f8 0b 00 00       	call   80103e90 <release>
  return 0;
80103298:	31 db                	xor    %ebx,%ebx
  p->context->eip = (uint)forkret;
  p->curalarmticks = 0;
  p->alarmticks = 0xFFFFFFFF;

  return p;
}
8010329a:	89 d8                	mov    %ebx,%eax
8010329c:	83 c4 14             	add    $0x14,%esp
8010329f:	5b                   	pop    %ebx
801032a0:	5d                   	pop    %ebp
801032a1:	c3                   	ret    

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801032a2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801032a9:	31 db                	xor    %ebx,%ebx
801032ab:	eb d7                	jmp    80103284 <allocproc+0xb8>
801032ad:	8d 76 00             	lea    0x0(%esi),%esi

801032b0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801032b0:	55                   	push   %ebp
801032b1:	89 e5                	mov    %esp,%ebp
801032b3:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801032b6:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801032bd:	e8 ce 0b 00 00       	call   80103e90 <release>

  if (first) {
801032c2:	8b 0d 04 a0 10 80    	mov    0x8010a004,%ecx
801032c8:	85 c9                	test   %ecx,%ecx
801032ca:	75 04                	jne    801032d0 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
801032cc:	c9                   	leave  
801032cd:	c3                   	ret    
801032ce:	66 90                	xchg   %ax,%ax

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801032d0:	c7 05 04 a0 10 80 00 	movl   $0x0,0x8010a004
801032d7:	00 00 00 
    iinit(ROOTDEV);
801032da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801032e1:	e8 ce e0 ff ff       	call   801013b4 <iinit>
    initlog(ROOTDEV);
801032e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801032ed:	e8 46 f5 ff ff       	call   80102838 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
801032f2:	c9                   	leave  
801032f3:	c3                   	ret    

801032f4 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801032f4:	55                   	push   %ebp
801032f5:	89 e5                	mov    %esp,%ebp
801032f7:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801032fa:	c7 44 24 04 45 6d 10 	movl   $0x80106d45,0x4(%esp)
80103301:	80 
80103302:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103309:	e8 e2 09 00 00       	call   80103cf0 <initlock>
}
8010330e:	c9                   	leave  
8010330f:	c3                   	ret    

80103310 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103310:	55                   	push   %ebp
80103311:	89 e5                	mov    %esp,%ebp
80103313:	56                   	push   %esi
80103314:	53                   	push   %ebx
80103315:	83 ec 10             	sub    $0x10,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103318:	9c                   	pushf  
80103319:	58                   	pop    %eax
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010331a:	f6 c4 02             	test   $0x2,%ah
8010331d:	75 58                	jne    80103377 <mycpu+0x67>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
8010331f:	e8 b0 f1 ff ff       	call   801024d4 <lapicid>
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103324:	8b 35 00 2d 11 80    	mov    0x80112d00,%esi
8010332a:	85 f6                	test   %esi,%esi
8010332c:	7e 3d                	jle    8010336b <mycpu+0x5b>
    if (cpus[i].apicid == apicid)
8010332e:	0f b6 15 80 27 11 80 	movzbl 0x80112780,%edx
80103335:	39 c2                	cmp    %eax,%edx
80103337:	74 2e                	je     80103367 <mycpu+0x57>
      return &cpus[i];
80103339:	b9 30 28 11 80       	mov    $0x80112830,%ecx
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010333e:	31 d2                	xor    %edx,%edx
80103340:	42                   	inc    %edx
80103341:	39 f2                	cmp    %esi,%edx
80103343:	74 26                	je     8010336b <mycpu+0x5b>
    if (cpus[i].apicid == apicid)
80103345:	0f b6 19             	movzbl (%ecx),%ebx
80103348:	81 c1 b0 00 00 00    	add    $0xb0,%ecx
8010334e:	39 c3                	cmp    %eax,%ebx
80103350:	75 ee                	jne    80103340 <mycpu+0x30>
      return &cpus[i];
80103352:	8d 04 92             	lea    (%edx,%edx,4),%eax
80103355:	8d 04 42             	lea    (%edx,%eax,2),%eax
80103358:	c1 e0 04             	shl    $0x4,%eax
8010335b:	05 80 27 11 80       	add    $0x80112780,%eax
  }
  panic("unknown apicid\n");
}
80103360:	83 c4 10             	add    $0x10,%esp
80103363:	5b                   	pop    %ebx
80103364:	5e                   	pop    %esi
80103365:	5d                   	pop    %ebp
80103366:	c3                   	ret    
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
80103367:	31 d2                	xor    %edx,%edx
80103369:	eb e7                	jmp    80103352 <mycpu+0x42>
      return &cpus[i];
  }
  panic("unknown apicid\n");
8010336b:	c7 04 24 4c 6d 10 80 	movl   $0x80106d4c,(%esp)
80103372:	e8 a5 cf ff ff       	call   8010031c <panic>
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
80103377:	c7 04 24 28 6e 10 80 	movl   $0x80106e28,(%esp)
8010337e:	e8 99 cf ff ff       	call   8010031c <panic>
80103383:	90                   	nop

80103384 <cpuid>:
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
80103384:	55                   	push   %ebp
80103385:	89 e5                	mov    %esp,%ebp
80103387:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010338a:	e8 81 ff ff ff       	call   80103310 <mycpu>
8010338f:	2d 80 27 11 80       	sub    $0x80112780,%eax
80103394:	c1 f8 04             	sar    $0x4,%eax
80103397:	8d 0c c0             	lea    (%eax,%eax,8),%ecx
8010339a:	89 ca                	mov    %ecx,%edx
8010339c:	c1 e2 05             	shl    $0x5,%edx
8010339f:	29 ca                	sub    %ecx,%edx
801033a1:	8d 14 90             	lea    (%eax,%edx,4),%edx
801033a4:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
801033a7:	89 ca                	mov    %ecx,%edx
801033a9:	c1 e2 0f             	shl    $0xf,%edx
801033ac:	29 ca                	sub    %ecx,%edx
801033ae:	8d 04 90             	lea    (%eax,%edx,4),%eax
801033b1:	f7 d8                	neg    %eax
}
801033b3:	c9                   	leave  
801033b4:	c3                   	ret    
801033b5:	8d 76 00             	lea    0x0(%esi),%esi

801033b8 <myproc>:
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801033b8:	55                   	push   %ebp
801033b9:	89 e5                	mov    %esp,%ebp
801033bb:	53                   	push   %ebx
801033bc:	53                   	push   %ebx
  struct cpu *c;
  struct proc *p;
  pushcli();
801033bd:	e8 96 09 00 00       	call   80103d58 <pushcli>
  c = mycpu();
801033c2:	e8 49 ff ff ff       	call   80103310 <mycpu>
  p = c->proc;
801033c7:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801033cd:	e8 be 09 00 00       	call   80103d90 <popcli>
  return p;
}
801033d2:	89 d8                	mov    %ebx,%eax
801033d4:	5a                   	pop    %edx
801033d5:	5b                   	pop    %ebx
801033d6:	5d                   	pop    %ebp
801033d7:	c3                   	ret    

801033d8 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801033d8:	55                   	push   %ebp
801033d9:	89 e5                	mov    %esp,%ebp
801033db:	53                   	push   %ebx
801033dc:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801033df:	e8 e8 fd ff ff       	call   801031cc <allocproc>
801033e4:	89 c3                	mov    %eax,%ebx
  
  initproc = p;
801033e6:	a3 a0 a5 10 80       	mov    %eax,0x8010a5a0
  if((p->pgdir = setupkvm()) == 0)
801033eb:	e8 a0 31 00 00       	call   80106590 <setupkvm>
801033f0:	89 43 04             	mov    %eax,0x4(%ebx)
801033f3:	85 c0                	test   %eax,%eax
801033f5:	0f 84 cc 00 00 00    	je     801034c7 <userinit+0xef>
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801033fb:	c7 44 24 08 2c 00 00 	movl   $0x2c,0x8(%esp)
80103402:	00 
80103403:	c7 44 24 04 60 a4 10 	movl   $0x8010a460,0x4(%esp)
8010340a:	80 
8010340b:	89 04 24             	mov    %eax,(%esp)
8010340e:	e8 e5 2d 00 00       	call   801061f8 <inituvm>
  p->sz = PGSIZE;
80103413:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103419:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80103420:	00 
80103421:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103428:	00 
80103429:	8b 43 18             	mov    0x18(%ebx),%eax
8010342c:	89 04 24             	mov    %eax,(%esp)
8010342f:	e8 a4 0a 00 00       	call   80103ed8 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103434:	8b 43 18             	mov    0x18(%ebx),%eax
80103437:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010343d:	8b 43 18             	mov    0x18(%ebx),%eax
80103440:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103446:	8b 43 18             	mov    0x18(%ebx),%eax
80103449:	8b 50 2c             	mov    0x2c(%eax),%edx
8010344c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103450:	8b 43 18             	mov    0x18(%ebx),%eax
80103453:	8b 50 2c             	mov    0x2c(%eax),%edx
80103456:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010345a:	8b 43 18             	mov    0x18(%ebx),%eax
8010345d:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103464:	8b 43 18             	mov    0x18(%ebx),%eax
80103467:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010346e:	8b 43 18             	mov    0x18(%ebx),%eax
80103471:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103478:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010347f:	00 
80103480:	c7 44 24 04 75 6d 10 	movl   $0x80106d75,0x4(%esp)
80103487:	80 
80103488:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010348b:	89 04 24             	mov    %eax,(%esp)
8010348e:	e8 d1 0b 00 00       	call   80104064 <safestrcpy>
  p->cwd = namei("/");
80103493:	c7 04 24 7e 6d 10 80 	movl   $0x80106d7e,(%esp)
8010349a:	e8 69 e9 ff ff       	call   80101e08 <namei>
8010349f:	89 43 68             	mov    %eax,0x68(%ebx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801034a2:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801034a9:	e8 7e 09 00 00       	call   80103e2c <acquire>

  p->state = RUNNABLE;
801034ae:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)

  release(&ptable.lock);
801034b5:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801034bc:	e8 cf 09 00 00       	call   80103e90 <release>
}
801034c1:	83 c4 14             	add    $0x14,%esp
801034c4:	5b                   	pop    %ebx
801034c5:	5d                   	pop    %ebp
801034c6:	c3                   	ret    

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
801034c7:	c7 04 24 5c 6d 10 80 	movl   $0x80106d5c,(%esp)
801034ce:	e8 49 ce ff ff       	call   8010031c <panic>
801034d3:	90                   	nop

801034d4 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801034d4:	55                   	push   %ebp
801034d5:	89 e5                	mov    %esp,%ebp
801034d7:	56                   	push   %esi
801034d8:	53                   	push   %ebx
801034d9:	83 ec 10             	sub    $0x10,%esp
801034dc:	8b 75 08             	mov    0x8(%ebp),%esi
  uint sz;
  struct proc *curproc = myproc();
801034df:	e8 d4 fe ff ff       	call   801033b8 <myproc>
801034e4:	89 c3                	mov    %eax,%ebx

  sz = curproc->sz;
801034e6:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801034e8:	83 fe 00             	cmp    $0x0,%esi
801034eb:	7e 2f                	jle    8010351c <growproc+0x48>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034ed:	01 c6                	add    %eax,%esi
801034ef:	89 74 24 08          	mov    %esi,0x8(%esp)
801034f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801034f7:	8b 43 04             	mov    0x4(%ebx),%eax
801034fa:	89 04 24             	mov    %eax,(%esp)
801034fd:	e8 ee 2e 00 00       	call   801063f0 <allocuvm>
80103502:	85 c0                	test   %eax,%eax
80103504:	74 32                	je     80103538 <growproc+0x64>
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
80103506:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103508:	89 1c 24             	mov    %ebx,(%esp)
8010350b:	e8 ec 2b 00 00       	call   801060fc <switchuvm>
  return 0;
80103510:	31 c0                	xor    %eax,%eax
}
80103512:	83 c4 10             	add    $0x10,%esp
80103515:	5b                   	pop    %ebx
80103516:	5e                   	pop    %esi
80103517:	5d                   	pop    %ebp
80103518:	c3                   	ret    
80103519:	8d 76 00             	lea    0x0(%esi),%esi

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
8010351c:	74 e8                	je     80103506 <growproc+0x32>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010351e:	01 c6                	add    %eax,%esi
80103520:	89 74 24 08          	mov    %esi,0x8(%esp)
80103524:	89 44 24 04          	mov    %eax,0x4(%esp)
80103528:	8b 43 04             	mov    0x4(%ebx),%eax
8010352b:	89 04 24             	mov    %eax,(%esp)
8010352e:	e8 15 2e 00 00       	call   80106348 <deallocuvm>
80103533:	85 c0                	test   %eax,%eax
80103535:	75 cf                	jne    80103506 <growproc+0x32>
80103537:	90                   	nop
      return -1;
80103538:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010353d:	eb d3                	jmp    80103512 <growproc+0x3e>
8010353f:	90                   	nop

80103540 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103540:	55                   	push   %ebp
80103541:	89 e5                	mov    %esp,%ebp
80103543:	57                   	push   %edi
80103544:	56                   	push   %esi
80103545:	53                   	push   %ebx
80103546:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103549:	e8 6a fe ff ff       	call   801033b8 <myproc>
8010354e:	89 c3                	mov    %eax,%ebx

  // Allocate process.
  if((np = allocproc()) == 0){
80103550:	e8 77 fc ff ff       	call   801031cc <allocproc>
80103555:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103558:	85 c0                	test   %eax,%eax
8010355a:	0f 84 c0 00 00 00    	je     80103620 <fork+0xe0>
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103560:	8b 03                	mov    (%ebx),%eax
80103562:	89 44 24 04          	mov    %eax,0x4(%esp)
80103566:	8b 43 04             	mov    0x4(%ebx),%eax
80103569:	89 04 24             	mov    %eax,(%esp)
8010356c:	e8 e7 30 00 00       	call   80106658 <copyuvm>
80103571:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103574:	89 42 04             	mov    %eax,0x4(%edx)
80103577:	85 c0                	test   %eax,%eax
80103579:	0f 84 a8 00 00 00    	je     80103627 <fork+0xe7>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
8010357f:	8b 03                	mov    (%ebx),%eax
80103581:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103584:	89 02                	mov    %eax,(%edx)
  np->parent = curproc;
80103586:	89 5a 14             	mov    %ebx,0x14(%edx)
  *np->tf = *curproc->tf;
80103589:	8b 42 18             	mov    0x18(%edx),%eax
8010358c:	8b 73 18             	mov    0x18(%ebx),%esi
8010358f:	b9 13 00 00 00       	mov    $0x13,%ecx
80103594:	89 c7                	mov    %eax,%edi
80103596:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103598:	8b 42 18             	mov    0x18(%edx),%eax
8010359b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801035a2:	31 f6                	xor    %esi,%esi
    if(curproc->ofile[i])
801035a4:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801035a8:	85 c0                	test   %eax,%eax
801035aa:	74 0f                	je     801035bb <fork+0x7b>
      np->ofile[i] = filedup(curproc->ofile[i]);
801035ac:	89 04 24             	mov    %eax,(%esp)
801035af:	e8 20 d7 ff ff       	call   80100cd4 <filedup>
801035b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801035b7:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801035bb:	46                   	inc    %esi
801035bc:	83 fe 10             	cmp    $0x10,%esi
801035bf:	75 e3                	jne    801035a4 <fork+0x64>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801035c1:	8b 43 68             	mov    0x68(%ebx),%eax
801035c4:	89 04 24             	mov    %eax,(%esp)
801035c7:	e8 dc df ff ff       	call   801015a8 <idup>
801035cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801035cf:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801035d2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801035d9:	00 
801035da:	83 c3 6c             	add    $0x6c,%ebx
801035dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801035e1:	89 d0                	mov    %edx,%eax
801035e3:	83 c0 6c             	add    $0x6c,%eax
801035e6:	89 04 24             	mov    %eax,(%esp)
801035e9:	e8 76 0a 00 00       	call   80104064 <safestrcpy>

  pid = np->pid;
801035ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801035f1:	8b 58 10             	mov    0x10(%eax),%ebx

  acquire(&ptable.lock);
801035f4:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801035fb:	e8 2c 08 00 00       	call   80103e2c <acquire>

  np->state = RUNNABLE;
80103600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103603:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010360a:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103611:	e8 7a 08 00 00       	call   80103e90 <release>

  return pid;
}
80103616:	89 d8                	mov    %ebx,%eax
80103618:	83 c4 2c             	add    $0x2c,%esp
8010361b:	5b                   	pop    %ebx
8010361c:	5e                   	pop    %esi
8010361d:	5f                   	pop    %edi
8010361e:	5d                   	pop    %ebp
8010361f:	c3                   	ret    
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
80103620:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103625:	eb ef                	jmp    80103616 <fork+0xd6>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
80103627:	8b 42 08             	mov    0x8(%edx),%eax
8010362a:	89 04 24             	mov    %eax,(%esp)
8010362d:	e8 56 eb ff ff       	call   80102188 <kfree>
    np->kstack = 0;
80103632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103635:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010363c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103643:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103648:	eb cc                	jmp    80103616 <fork+0xd6>
8010364a:	66 90                	xchg   %ax,%ax

8010364c <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010364c:	55                   	push   %ebp
8010364d:	89 e5                	mov    %esp,%ebp
8010364f:	57                   	push   %edi
80103650:	56                   	push   %esi
80103651:	53                   	push   %ebx
80103652:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80103655:	e8 b6 fc ff ff       	call   80103310 <mycpu>
8010365a:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010365c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103663:	00 00 00 
80103666:	8d 78 04             	lea    0x4(%eax),%edi
80103669:	8d 76 00             	lea    0x0(%esi),%esi
}

static inline void
sti(void)
{
  asm volatile("sti");
8010366c:	fb                   	sti    
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010366d:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103674:	e8 b3 07 00 00       	call   80103e2c <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103679:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
8010367e:	eb 0e                	jmp    8010368e <scheduler+0x42>
80103680:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103686:	81 fb 54 4f 11 80    	cmp    $0x80114f54,%ebx
8010368c:	73 4a                	jae    801036d8 <scheduler+0x8c>
      if(p->state != RUNNABLE)
8010368e:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103692:	75 ec                	jne    80103680 <scheduler+0x34>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80103694:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010369a:	89 1c 24             	mov    %ebx,(%esp)
8010369d:	e8 5a 2a 00 00       	call   801060fc <switchuvm>
      p->state = RUNNING;
801036a2:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)

      swtch(&(c->scheduler), p->context);
801036a9:	8b 43 1c             	mov    0x1c(%ebx),%eax
801036ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801036b0:	89 3c 24             	mov    %edi,(%esp)
801036b3:	e8 f4 09 00 00       	call   801040ac <swtch>
      switchkvm();
801036b8:	e8 2b 2a 00 00       	call   801060e8 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801036bd:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801036c4:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036c7:	81 c3 88 00 00 00    	add    $0x88,%ebx
801036cd:	81 fb 54 4f 11 80    	cmp    $0x80114f54,%ebx
801036d3:	72 b9                	jb     8010368e <scheduler+0x42>
801036d5:	8d 76 00             	lea    0x0(%esi),%esi

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
801036d8:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801036df:	e8 ac 07 00 00       	call   80103e90 <release>

  }
801036e4:	eb 86                	jmp    8010366c <scheduler+0x20>
801036e6:	66 90                	xchg   %ax,%ax

801036e8 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801036e8:	55                   	push   %ebp
801036e9:	89 e5                	mov    %esp,%ebp
801036eb:	56                   	push   %esi
801036ec:	53                   	push   %ebx
801036ed:	83 ec 10             	sub    $0x10,%esp
  int intena;
  struct proc *p = myproc();
801036f0:	e8 c3 fc ff ff       	call   801033b8 <myproc>
801036f5:	89 c3                	mov    %eax,%ebx

  if(!holding(&ptable.lock))
801036f7:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801036fe:	e8 ed 06 00 00       	call   80103df0 <holding>
80103703:	85 c0                	test   %eax,%eax
80103705:	74 4f                	je     80103756 <sched+0x6e>
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
80103707:	e8 04 fc ff ff       	call   80103310 <mycpu>
8010370c:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103713:	75 65                	jne    8010377a <sched+0x92>
    panic("sched locks");
  if(p->state == RUNNING)
80103715:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103719:	74 53                	je     8010376e <sched+0x86>

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010371b:	9c                   	pushf  
8010371c:	58                   	pop    %eax
    panic("sched running");
  if(readeflags()&FL_IF)
8010371d:	f6 c4 02             	test   $0x2,%ah
80103720:	75 40                	jne    80103762 <sched+0x7a>
    panic("sched interruptible");
  intena = mycpu()->intena;
80103722:	e8 e9 fb ff ff       	call   80103310 <mycpu>
80103727:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
8010372d:	e8 de fb ff ff       	call   80103310 <mycpu>
80103732:	8b 40 04             	mov    0x4(%eax),%eax
80103735:	89 44 24 04          	mov    %eax,0x4(%esp)
80103739:	83 c3 1c             	add    $0x1c,%ebx
8010373c:	89 1c 24             	mov    %ebx,(%esp)
8010373f:	e8 68 09 00 00       	call   801040ac <swtch>
  mycpu()->intena = intena;
80103744:	e8 c7 fb ff ff       	call   80103310 <mycpu>
80103749:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010374f:	83 c4 10             	add    $0x10,%esp
80103752:	5b                   	pop    %ebx
80103753:	5e                   	pop    %esi
80103754:	5d                   	pop    %ebp
80103755:	c3                   	ret    
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
80103756:	c7 04 24 80 6d 10 80 	movl   $0x80106d80,(%esp)
8010375d:	e8 ba cb ff ff       	call   8010031c <panic>
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
80103762:	c7 04 24 ac 6d 10 80 	movl   $0x80106dac,(%esp)
80103769:	e8 ae cb ff ff       	call   8010031c <panic>
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
8010376e:	c7 04 24 9e 6d 10 80 	movl   $0x80106d9e,(%esp)
80103775:	e8 a2 cb ff ff       	call   8010031c <panic>
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
8010377a:	c7 04 24 92 6d 10 80 	movl   $0x80106d92,(%esp)
80103781:	e8 96 cb ff ff       	call   8010031c <panic>
80103786:	66 90                	xchg   %ax,%ax

80103788 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103788:	55                   	push   %ebp
80103789:	89 e5                	mov    %esp,%ebp
8010378b:	56                   	push   %esi
8010378c:	53                   	push   %ebx
8010378d:	83 ec 10             	sub    $0x10,%esp
  struct proc *curproc = myproc();
80103790:	e8 23 fc ff ff       	call   801033b8 <myproc>
80103795:	89 c3                	mov    %eax,%ebx
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103797:	3b 05 a0 a5 10 80    	cmp    0x8010a5a0,%eax
8010379d:	0f 84 ef 00 00 00    	je     80103892 <exit+0x10a>
801037a3:	31 f6                	xor    %esi,%esi
801037a5:	8d 76 00             	lea    0x0(%esi),%esi
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
801037a8:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801037ac:	85 c0                	test   %eax,%eax
801037ae:	74 10                	je     801037c0 <exit+0x38>
      fileclose(curproc->ofile[fd]);
801037b0:	89 04 24             	mov    %eax,(%esp)
801037b3:	e8 60 d5 ff ff       	call   80100d18 <fileclose>
      curproc->ofile[fd] = 0;
801037b8:	c7 44 b3 28 00 00 00 	movl   $0x0,0x28(%ebx,%esi,4)
801037bf:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801037c0:	46                   	inc    %esi
801037c1:	83 fe 10             	cmp    $0x10,%esi
801037c4:	75 e2                	jne    801037a8 <exit+0x20>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
801037c6:	e8 05 f1 ff ff       	call   801028d0 <begin_op>
  iput(curproc->cwd);
801037cb:	8b 43 68             	mov    0x68(%ebx),%eax
801037ce:	89 04 24             	mov    %eax,(%esp)
801037d1:	e8 12 df ff ff       	call   801016e8 <iput>
  end_op();
801037d6:	e8 55 f1 ff ff       	call   80102930 <end_op>
  curproc->cwd = 0;
801037db:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

  acquire(&ptable.lock);
801037e2:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801037e9:	e8 3e 06 00 00       	call   80103e2c <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801037ee:	8b 43 14             	mov    0x14(%ebx),%eax
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801037f1:	ba 54 2d 11 80       	mov    $0x80112d54,%edx
801037f6:	eb 0e                	jmp    80103806 <exit+0x7e>
801037f8:	81 c2 88 00 00 00    	add    $0x88,%edx
801037fe:	81 fa 54 4f 11 80    	cmp    $0x80114f54,%edx
80103804:	73 20                	jae    80103826 <exit+0x9e>
    if(p->state == SLEEPING && p->chan == chan)
80103806:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010380a:	75 ec                	jne    801037f8 <exit+0x70>
8010380c:	3b 42 20             	cmp    0x20(%edx),%eax
8010380f:	75 e7                	jne    801037f8 <exit+0x70>
      p->state = RUNNABLE;
80103811:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103818:	81 c2 88 00 00 00    	add    $0x88,%edx
8010381e:	81 fa 54 4f 11 80    	cmp    $0x80114f54,%edx
80103824:	72 e0                	jb     80103806 <exit+0x7e>
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
80103826:	a1 a0 a5 10 80       	mov    0x8010a5a0,%eax
8010382b:	b9 54 2d 11 80       	mov    $0x80112d54,%ecx
80103830:	eb 10                	jmp    80103842 <exit+0xba>
80103832:	66 90                	xchg   %ax,%ax

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103834:	81 c1 88 00 00 00    	add    $0x88,%ecx
8010383a:	81 f9 54 4f 11 80    	cmp    $0x80114f54,%ecx
80103840:	73 38                	jae    8010387a <exit+0xf2>
    if(p->parent == curproc){
80103842:	39 59 14             	cmp    %ebx,0x14(%ecx)
80103845:	75 ed                	jne    80103834 <exit+0xac>
      p->parent = initproc;
80103847:	89 41 14             	mov    %eax,0x14(%ecx)
      if(p->state == ZOMBIE)
8010384a:	83 79 0c 05          	cmpl   $0x5,0xc(%ecx)
8010384e:	75 e4                	jne    80103834 <exit+0xac>
80103850:	ba 54 2d 11 80       	mov    $0x80112d54,%edx
80103855:	eb 0f                	jmp    80103866 <exit+0xde>
80103857:	90                   	nop
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103858:	81 c2 88 00 00 00    	add    $0x88,%edx
8010385e:	81 fa 54 4f 11 80    	cmp    $0x80114f54,%edx
80103864:	73 ce                	jae    80103834 <exit+0xac>
    if(p->state == SLEEPING && p->chan == chan)
80103866:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010386a:	75 ec                	jne    80103858 <exit+0xd0>
8010386c:	3b 42 20             	cmp    0x20(%edx),%eax
8010386f:	75 e7                	jne    80103858 <exit+0xd0>
      p->state = RUNNABLE;
80103871:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
80103878:	eb de                	jmp    80103858 <exit+0xd0>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010387a:	c7 43 0c 05 00 00 00 	movl   $0x5,0xc(%ebx)
  sched();
80103881:	e8 62 fe ff ff       	call   801036e8 <sched>
  panic("zombie exit");
80103886:	c7 04 24 cd 6d 10 80 	movl   $0x80106dcd,(%esp)
8010388d:	e8 8a ca ff ff       	call   8010031c <panic>
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");
80103892:	c7 04 24 c0 6d 10 80 	movl   $0x80106dc0,(%esp)
80103899:	e8 7e ca ff ff       	call   8010031c <panic>
8010389e:	66 90                	xchg   %ax,%ax

801038a0 <yield>:
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
801038a0:	55                   	push   %ebp
801038a1:	89 e5                	mov    %esp,%ebp
801038a3:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801038a6:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038ad:	e8 7a 05 00 00       	call   80103e2c <acquire>
  myproc()->state = RUNNABLE;
801038b2:	e8 01 fb ff ff       	call   801033b8 <myproc>
801038b7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801038be:	e8 25 fe ff ff       	call   801036e8 <sched>
  release(&ptable.lock);
801038c3:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038ca:	e8 c1 05 00 00       	call   80103e90 <release>
}
801038cf:	c9                   	leave  
801038d0:	c3                   	ret    
801038d1:	8d 76 00             	lea    0x0(%esi),%esi

801038d4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801038d4:	55                   	push   %ebp
801038d5:	89 e5                	mov    %esp,%ebp
801038d7:	57                   	push   %edi
801038d8:	56                   	push   %esi
801038d9:	53                   	push   %ebx
801038da:	83 ec 1c             	sub    $0x1c,%esp
801038dd:	8b 75 08             	mov    0x8(%ebp),%esi
801038e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
801038e3:	e8 d0 fa ff ff       	call   801033b8 <myproc>
801038e8:	89 c7                	mov    %eax,%edi
  
  if(p == 0)
801038ea:	85 c0                	test   %eax,%eax
801038ec:	74 7c                	je     8010396a <sleep+0x96>
    panic("sleep");

  if(lk == 0)
801038ee:	85 db                	test   %ebx,%ebx
801038f0:	74 6c                	je     8010395e <sleep+0x8a>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801038f2:	81 fb 20 2d 11 80    	cmp    $0x80112d20,%ebx
801038f8:	74 46                	je     80103940 <sleep+0x6c>
    acquire(&ptable.lock);  //DOC: sleeplock1
801038fa:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103901:	e8 26 05 00 00       	call   80103e2c <acquire>
    release(lk);
80103906:	89 1c 24             	mov    %ebx,(%esp)
80103909:	e8 82 05 00 00       	call   80103e90 <release>
  }
  // Go to sleep.
  p->chan = chan;
8010390e:	89 77 20             	mov    %esi,0x20(%edi)
  p->state = SLEEPING;
80103911:	c7 47 0c 02 00 00 00 	movl   $0x2,0xc(%edi)

  sched();
80103918:	e8 cb fd ff ff       	call   801036e8 <sched>

  // Tidy up.
  p->chan = 0;
8010391d:	c7 47 20 00 00 00 00 	movl   $0x0,0x20(%edi)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
80103924:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010392b:	e8 60 05 00 00       	call   80103e90 <release>
    acquire(lk);
80103930:	89 5d 08             	mov    %ebx,0x8(%ebp)
  }
}
80103933:	83 c4 1c             	add    $0x1c,%esp
80103936:	5b                   	pop    %ebx
80103937:	5e                   	pop    %esi
80103938:	5f                   	pop    %edi
80103939:	5d                   	pop    %ebp
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
8010393a:	e9 ed 04 00 00       	jmp    80103e2c <acquire>
8010393f:	90                   	nop
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
80103940:	89 70 20             	mov    %esi,0x20(%eax)
  p->state = SLEEPING;
80103943:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010394a:	e8 99 fd ff ff       	call   801036e8 <sched>

  // Tidy up.
  p->chan = 0;
8010394f:	c7 47 20 00 00 00 00 	movl   $0x0,0x20(%edi)
  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}
80103956:	83 c4 1c             	add    $0x1c,%esp
80103959:	5b                   	pop    %ebx
8010395a:	5e                   	pop    %esi
8010395b:	5f                   	pop    %edi
8010395c:	5d                   	pop    %ebp
8010395d:	c3                   	ret    
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");
8010395e:	c7 04 24 df 6d 10 80 	movl   $0x80106ddf,(%esp)
80103965:	e8 b2 c9 ff ff       	call   8010031c <panic>
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");
8010396a:	c7 04 24 d9 6d 10 80 	movl   $0x80106dd9,(%esp)
80103971:	e8 a6 c9 ff ff       	call   8010031c <panic>
80103976:	66 90                	xchg   %ax,%ax

80103978 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
8010397b:	56                   	push   %esi
8010397c:	53                   	push   %ebx
8010397d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103980:	e8 33 fa ff ff       	call   801033b8 <myproc>
80103985:	89 c6                	mov    %eax,%esi
  
  acquire(&ptable.lock);
80103987:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010398e:	e8 99 04 00 00       	call   80103e2c <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103993:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103995:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
8010399a:	eb 0e                	jmp    801039aa <wait+0x32>
8010399c:	81 c3 88 00 00 00    	add    $0x88,%ebx
801039a2:	81 fb 54 4f 11 80    	cmp    $0x80114f54,%ebx
801039a8:	73 1e                	jae    801039c8 <wait+0x50>
      if(p->parent != curproc)
801039aa:	39 73 14             	cmp    %esi,0x14(%ebx)
801039ad:	75 ed                	jne    8010399c <wait+0x24>
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
801039af:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801039b3:	74 30                	je     801039e5 <wait+0x6d>
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
801039b5:	b8 01 00 00 00       	mov    $0x1,%eax
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039ba:	81 c3 88 00 00 00    	add    $0x88,%ebx
801039c0:	81 fb 54 4f 11 80    	cmp    $0x80114f54,%ebx
801039c6:	72 e2                	jb     801039aa <wait+0x32>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 6e                	je     80103a3a <wait+0xc2>
801039cc:	8b 4e 24             	mov    0x24(%esi),%ecx
801039cf:	85 c9                	test   %ecx,%ecx
801039d1:	75 67                	jne    80103a3a <wait+0xc2>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801039d3:	c7 44 24 04 20 2d 11 	movl   $0x80112d20,0x4(%esp)
801039da:	80 
801039db:	89 34 24             	mov    %esi,(%esp)
801039de:	e8 f1 fe ff ff       	call   801038d4 <sleep>
  }
801039e3:	eb ae                	jmp    80103993 <wait+0x1b>
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
801039e5:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801039e8:	8b 43 08             	mov    0x8(%ebx),%eax
801039eb:	89 04 24             	mov    %eax,(%esp)
801039ee:	e8 95 e7 ff ff       	call   80102188 <kfree>
        p->kstack = 0;
801039f3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801039fa:	8b 43 04             	mov    0x4(%ebx),%eax
801039fd:	89 04 24             	mov    %eax,(%esp)
80103a00:	e8 17 2b 00 00       	call   8010651c <freevm>
        p->pid = 0;
80103a05:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103a0c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103a13:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103a17:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103a1e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103a25:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103a2c:	e8 5f 04 00 00       	call   80103e90 <release>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}
80103a31:	89 f0                	mov    %esi,%eax
80103a33:	83 c4 10             	add    $0x10,%esp
80103a36:	5b                   	pop    %ebx
80103a37:	5e                   	pop    %esi
80103a38:	5d                   	pop    %ebp
80103a39:	c3                   	ret    
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
80103a3a:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103a41:	e8 4a 04 00 00       	call   80103e90 <release>
      return -1;
80103a46:	be ff ff ff ff       	mov    $0xffffffff,%esi
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}
80103a4b:	89 f0                	mov    %esi,%eax
80103a4d:	83 c4 10             	add    $0x10,%esp
80103a50:	5b                   	pop    %ebx
80103a51:	5e                   	pop    %esi
80103a52:	5d                   	pop    %ebp
80103a53:	c3                   	ret    

80103a54 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103a54:	55                   	push   %ebp
80103a55:	89 e5                	mov    %esp,%ebp
80103a57:	53                   	push   %ebx
80103a58:	83 ec 14             	sub    $0x14,%esp
80103a5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
80103a5e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103a65:	e8 c2 03 00 00       	call   80103e2c <acquire>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6a:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103a6f:	eb 0f                	jmp    80103a80 <wakeup+0x2c>
80103a71:	8d 76 00             	lea    0x0(%esi),%esi
80103a74:	05 88 00 00 00       	add    $0x88,%eax
80103a79:	3d 54 4f 11 80       	cmp    $0x80114f54,%eax
80103a7e:	73 20                	jae    80103aa0 <wakeup+0x4c>
    if(p->state == SLEEPING && p->chan == chan)
80103a80:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103a84:	75 ee                	jne    80103a74 <wakeup+0x20>
80103a86:	3b 58 20             	cmp    0x20(%eax),%ebx
80103a89:	75 e9                	jne    80103a74 <wakeup+0x20>
      p->state = RUNNABLE;
80103a8b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a92:	05 88 00 00 00       	add    $0x88,%eax
80103a97:	3d 54 4f 11 80       	cmp    $0x80114f54,%eax
80103a9c:	72 e2                	jb     80103a80 <wakeup+0x2c>
80103a9e:	66 90                	xchg   %ax,%ax
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
80103aa0:	c7 45 08 20 2d 11 80 	movl   $0x80112d20,0x8(%ebp)
}
80103aa7:	83 c4 14             	add    $0x14,%esp
80103aaa:	5b                   	pop    %ebx
80103aab:	5d                   	pop    %ebp
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
80103aac:	e9 df 03 00 00       	jmp    80103e90 <release>
80103ab1:	8d 76 00             	lea    0x0(%esi),%esi

80103ab4 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103ab4:	55                   	push   %ebp
80103ab5:	89 e5                	mov    %esp,%ebp
80103ab7:	53                   	push   %ebx
80103ab8:	83 ec 14             	sub    $0x14,%esp
80103abb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103abe:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103ac5:	e8 62 03 00 00       	call   80103e2c <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103aca:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
    if(p->pid == pid){
80103acf:	39 1d 64 2d 11 80    	cmp    %ebx,0x80112d64
80103ad5:	74 12                	je     80103ae9 <kill+0x35>
80103ad7:	90                   	nop
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ad8:	05 88 00 00 00       	add    $0x88,%eax
80103add:	3d 54 4f 11 80       	cmp    $0x80114f54,%eax
80103ae2:	73 34                	jae    80103b18 <kill+0x64>
    if(p->pid == pid){
80103ae4:	39 58 10             	cmp    %ebx,0x10(%eax)
80103ae7:	75 ef                	jne    80103ad8 <kill+0x24>
      p->killed = 1;
80103ae9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103af0:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103af4:	74 16                	je     80103b0c <kill+0x58>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103af6:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103afd:	e8 8e 03 00 00       	call   80103e90 <release>
      return 0;
80103b02:	31 c0                	xor    %eax,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103b04:	83 c4 14             	add    $0x14,%esp
80103b07:	5b                   	pop    %ebx
80103b08:	5d                   	pop    %ebp
80103b09:	c3                   	ret    
80103b0a:	66 90                	xchg   %ax,%ax
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
80103b0c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103b13:	eb e1                	jmp    80103af6 <kill+0x42>
80103b15:	8d 76 00             	lea    0x0(%esi),%esi
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80103b18:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103b1f:	e8 6c 03 00 00       	call   80103e90 <release>
  return -1;
80103b24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103b29:	83 c4 14             	add    $0x14,%esp
80103b2c:	5b                   	pop    %ebx
80103b2d:	5d                   	pop    %ebp
80103b2e:	c3                   	ret    
80103b2f:	90                   	nop

80103b30 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103b30:	55                   	push   %ebp
80103b31:	89 e5                	mov    %esp,%ebp
80103b33:	57                   	push   %edi
80103b34:	56                   	push   %esi
80103b35:	53                   	push   %ebx
80103b36:	83 ec 4c             	sub    $0x4c,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b39:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
80103b3e:	8d 7d e8             	lea    -0x18(%ebp),%edi
80103b41:	eb 4a                	jmp    80103b8d <procdump+0x5d>
80103b43:	90                   	nop
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103b44:	8b 04 85 50 6e 10 80 	mov    -0x7fef91b0(,%eax,4),%eax
80103b4b:	85 c0                	test   %eax,%eax
80103b4d:	74 4a                	je     80103b99 <procdump+0x69>
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
80103b4f:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103b52:	89 54 24 0c          	mov    %edx,0xc(%esp)
80103b56:	89 44 24 08          	mov    %eax,0x8(%esp)
80103b5a:	8b 43 10             	mov    0x10(%ebx),%eax
80103b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b61:	c7 04 24 f4 6d 10 80 	movl   $0x80106df4,(%esp)
80103b68:	e8 4f ca ff ff       	call   801005bc <cprintf>
    if(p->state == SLEEPING){
80103b6d:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103b71:	74 2d                	je     80103ba0 <procdump+0x70>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103b73:	c7 04 24 bd 6f 10 80 	movl   $0x80106fbd,(%esp)
80103b7a:	e8 3d ca ff ff       	call   801005bc <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b7f:	81 c3 88 00 00 00    	add    $0x88,%ebx
80103b85:	81 fb 54 4f 11 80    	cmp    $0x80114f54,%ebx
80103b8b:	73 4f                	jae    80103bdc <procdump+0xac>
    if(p->state == UNUSED)
80103b8d:	8b 43 0c             	mov    0xc(%ebx),%eax
80103b90:	85 c0                	test   %eax,%eax
80103b92:	74 eb                	je     80103b7f <procdump+0x4f>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103b94:	83 f8 05             	cmp    $0x5,%eax
80103b97:	76 ab                	jbe    80103b44 <procdump+0x14>
      state = states[p->state];
    else
      state = "???";
80103b99:	b8 f0 6d 10 80       	mov    $0x80106df0,%eax
80103b9e:	eb af                	jmp    80103b4f <procdump+0x1f>
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103ba0:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ba7:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103baa:	8b 40 0c             	mov    0xc(%eax),%eax
80103bad:	83 c0 08             	add    $0x8,%eax
80103bb0:	89 04 24             	mov    %eax,(%esp)
80103bb3:	e8 54 01 00 00       	call   80103d0c <getcallerpcs>
80103bb8:	8d 75 c0             	lea    -0x40(%ebp),%esi
80103bbb:	90                   	nop
      for(i=0; i<10 && pc[i] != 0; i++)
80103bbc:	8b 06                	mov    (%esi),%eax
80103bbe:	85 c0                	test   %eax,%eax
80103bc0:	74 b1                	je     80103b73 <procdump+0x43>
        cprintf(" %p", pc[i]);
80103bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bc6:	c7 04 24 41 68 10 80 	movl   $0x80106841,(%esp)
80103bcd:	e8 ea c9 ff ff       	call   801005bc <cprintf>
80103bd2:	83 c6 04             	add    $0x4,%esi
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80103bd5:	39 fe                	cmp    %edi,%esi
80103bd7:	75 e3                	jne    80103bbc <procdump+0x8c>
80103bd9:	eb 98                	jmp    80103b73 <procdump+0x43>
80103bdb:	90                   	nop
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80103bdc:	83 c4 4c             	add    $0x4c,%esp
80103bdf:	5b                   	pop    %ebx
80103be0:	5e                   	pop    %esi
80103be1:	5f                   	pop    %edi
80103be2:	5d                   	pop    %ebp
80103be3:	c3                   	ret    

80103be4 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103be4:	55                   	push   %ebp
80103be5:	89 e5                	mov    %esp,%ebp
80103be7:	53                   	push   %ebx
80103be8:	83 ec 14             	sub    $0x14,%esp
80103beb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103bee:	c7 44 24 04 68 6e 10 	movl   $0x80106e68,0x4(%esp)
80103bf5:	80 
80103bf6:	8d 43 04             	lea    0x4(%ebx),%eax
80103bf9:	89 04 24             	mov    %eax,(%esp)
80103bfc:	e8 ef 00 00 00       	call   80103cf0 <initlock>
  lk->name = name;
80103c01:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c04:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103c07:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103c0d:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103c14:	83 c4 14             	add    $0x14,%esp
80103c17:	5b                   	pop    %ebx
80103c18:	5d                   	pop    %ebp
80103c19:	c3                   	ret    
80103c1a:	66 90                	xchg   %ax,%ax

80103c1c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103c1c:	55                   	push   %ebp
80103c1d:	89 e5                	mov    %esp,%ebp
80103c1f:	56                   	push   %esi
80103c20:	53                   	push   %ebx
80103c21:	83 ec 10             	sub    $0x10,%esp
80103c24:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c27:	8d 73 04             	lea    0x4(%ebx),%esi
80103c2a:	89 34 24             	mov    %esi,(%esp)
80103c2d:	e8 fa 01 00 00       	call   80103e2c <acquire>
  while (lk->locked) {
80103c32:	8b 13                	mov    (%ebx),%edx
80103c34:	85 d2                	test   %edx,%edx
80103c36:	74 12                	je     80103c4a <acquiresleep+0x2e>
    sleep(lk, &lk->lk);
80103c38:	89 74 24 04          	mov    %esi,0x4(%esp)
80103c3c:	89 1c 24             	mov    %ebx,(%esp)
80103c3f:	e8 90 fc ff ff       	call   801038d4 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80103c44:	8b 03                	mov    (%ebx),%eax
80103c46:	85 c0                	test   %eax,%eax
80103c48:	75 ee                	jne    80103c38 <acquiresleep+0x1c>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80103c4a:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103c50:	e8 63 f7 ff ff       	call   801033b8 <myproc>
80103c55:	8b 40 10             	mov    0x10(%eax),%eax
80103c58:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103c5b:	89 75 08             	mov    %esi,0x8(%ebp)
}
80103c5e:	83 c4 10             	add    $0x10,%esp
80103c61:	5b                   	pop    %ebx
80103c62:	5e                   	pop    %esi
80103c63:	5d                   	pop    %ebp
  while (lk->locked) {
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
  lk->pid = myproc()->pid;
  release(&lk->lk);
80103c64:	e9 27 02 00 00       	jmp    80103e90 <release>
80103c69:	8d 76 00             	lea    0x0(%esi),%esi

80103c6c <releasesleep>:
}

void
releasesleep(struct sleeplock *lk)
{
80103c6c:	55                   	push   %ebp
80103c6d:	89 e5                	mov    %esp,%ebp
80103c6f:	56                   	push   %esi
80103c70:	53                   	push   %ebx
80103c71:	83 ec 10             	sub    $0x10,%esp
80103c74:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c77:	8d 73 04             	lea    0x4(%ebx),%esi
80103c7a:	89 34 24             	mov    %esi,(%esp)
80103c7d:	e8 aa 01 00 00       	call   80103e2c <acquire>
  lk->locked = 0;
80103c82:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103c88:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103c8f:	89 1c 24             	mov    %ebx,(%esp)
80103c92:	e8 bd fd ff ff       	call   80103a54 <wakeup>
  release(&lk->lk);
80103c97:	89 75 08             	mov    %esi,0x8(%ebp)
}
80103c9a:	83 c4 10             	add    $0x10,%esp
80103c9d:	5b                   	pop    %ebx
80103c9e:	5e                   	pop    %esi
80103c9f:	5d                   	pop    %ebp
{
  acquire(&lk->lk);
  lk->locked = 0;
  lk->pid = 0;
  wakeup(lk);
  release(&lk->lk);
80103ca0:	e9 eb 01 00 00       	jmp    80103e90 <release>
80103ca5:	8d 76 00             	lea    0x0(%esi),%esi

80103ca8 <holdingsleep>:
}

int
holdingsleep(struct sleeplock *lk)
{
80103ca8:	55                   	push   %ebp
80103ca9:	89 e5                	mov    %esp,%ebp
80103cab:	56                   	push   %esi
80103cac:	53                   	push   %ebx
80103cad:	83 ec 10             	sub    $0x10,%esp
80103cb0:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;
  
  acquire(&lk->lk);
80103cb3:	8d 5e 04             	lea    0x4(%esi),%ebx
80103cb6:	89 1c 24             	mov    %ebx,(%esp)
80103cb9:	e8 6e 01 00 00       	call   80103e2c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103cbe:	8b 0e                	mov    (%esi),%ecx
80103cc0:	85 c9                	test   %ecx,%ecx
80103cc2:	75 14                	jne    80103cd8 <holdingsleep+0x30>
80103cc4:	31 f6                	xor    %esi,%esi
  release(&lk->lk);
80103cc6:	89 1c 24             	mov    %ebx,(%esp)
80103cc9:	e8 c2 01 00 00       	call   80103e90 <release>
  return r;
}
80103cce:	89 f0                	mov    %esi,%eax
80103cd0:	83 c4 10             	add    $0x10,%esp
80103cd3:	5b                   	pop    %ebx
80103cd4:	5e                   	pop    %esi
80103cd5:	5d                   	pop    %ebp
80103cd6:	c3                   	ret    
80103cd7:	90                   	nop
holdingsleep(struct sleeplock *lk)
{
  int r;
  
  acquire(&lk->lk);
  r = lk->locked && (lk->pid == myproc()->pid);
80103cd8:	8b 76 3c             	mov    0x3c(%esi),%esi
80103cdb:	e8 d8 f6 ff ff       	call   801033b8 <myproc>
80103ce0:	3b 70 10             	cmp    0x10(%eax),%esi
80103ce3:	0f 94 c0             	sete   %al
80103ce6:	0f b6 c0             	movzbl %al,%eax
80103ce9:	89 c6                	mov    %eax,%esi
80103ceb:	eb d9                	jmp    80103cc6 <holdingsleep+0x1e>
80103ced:	00 00                	add    %al,(%eax)
	...

80103cf0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103cf0:	55                   	push   %ebp
80103cf1:	89 e5                	mov    %esp,%ebp
80103cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103cf6:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cf9:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103cfc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103d02:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103d09:	5d                   	pop    %ebp
80103d0a:	c3                   	ret    
80103d0b:	90                   	nop

80103d0c <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103d0c:	55                   	push   %ebp
80103d0d:	89 e5                	mov    %esp,%ebp
80103d0f:	53                   	push   %ebx
80103d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103d13:	8b 55 08             	mov    0x8(%ebp),%edx
80103d16:	83 ea 08             	sub    $0x8,%edx
  for(i = 0; i < 10; i++){
80103d19:	31 c0                	xor    %eax,%eax
80103d1b:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103d1c:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103d22:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103d28:	77 12                	ja     80103d3c <getcallerpcs+0x30>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103d2a:	8b 5a 04             	mov    0x4(%edx),%ebx
80103d2d:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103d30:	8b 12                	mov    (%edx),%edx
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80103d32:	40                   	inc    %eax
80103d33:	83 f8 0a             	cmp    $0xa,%eax
80103d36:	75 e4                	jne    80103d1c <getcallerpcs+0x10>
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
80103d38:	5b                   	pop    %ebx
80103d39:	5d                   	pop    %ebp
80103d3a:	c3                   	ret    
80103d3b:	90                   	nop
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103d3c:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80103d43:	40                   	inc    %eax
80103d44:	83 f8 0a             	cmp    $0xa,%eax
80103d47:	74 ef                	je     80103d38 <getcallerpcs+0x2c>
    pcs[i] = 0;
80103d49:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80103d50:	40                   	inc    %eax
80103d51:	83 f8 0a             	cmp    $0xa,%eax
80103d54:	75 e6                	jne    80103d3c <getcallerpcs+0x30>
80103d56:	eb e0                	jmp    80103d38 <getcallerpcs+0x2c>

80103d58 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103d58:	55                   	push   %ebp
80103d59:	89 e5                	mov    %esp,%ebp
80103d5b:	53                   	push   %ebx
80103d5c:	52                   	push   %edx
80103d5d:	9c                   	pushf  
80103d5e:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
80103d5f:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103d60:	e8 ab f5 ff ff       	call   80103310 <mycpu>
80103d65:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103d6b:	85 c9                	test   %ecx,%ecx
80103d6d:	75 11                	jne    80103d80 <pushcli+0x28>
    mycpu()->intena = eflags & FL_IF;
80103d6f:	e8 9c f5 ff ff       	call   80103310 <mycpu>
80103d74:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103d7a:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
  mycpu()->ncli += 1;
80103d80:	e8 8b f5 ff ff       	call   80103310 <mycpu>
80103d85:	ff 80 a4 00 00 00    	incl   0xa4(%eax)
}
80103d8b:	58                   	pop    %eax
80103d8c:	5b                   	pop    %ebx
80103d8d:	5d                   	pop    %ebp
80103d8e:	c3                   	ret    
80103d8f:	90                   	nop

80103d90 <popcli>:

void
popcli(void)
{
80103d90:	55                   	push   %ebp
80103d91:	89 e5                	mov    %esp,%ebp
80103d93:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103d96:	9c                   	pushf  
80103d97:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103d98:	f6 c4 02             	test   $0x2,%ah
80103d9b:	75 45                	jne    80103de2 <popcli+0x52>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103d9d:	e8 6e f5 ff ff       	call   80103310 <mycpu>
80103da2:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80103da8:	4a                   	dec    %edx
80103da9:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103daf:	85 d2                	test   %edx,%edx
80103db1:	78 23                	js     80103dd6 <popcli+0x46>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103db3:	e8 58 f5 ff ff       	call   80103310 <mycpu>
80103db8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80103dbe:	85 c0                	test   %eax,%eax
80103dc0:	74 02                	je     80103dc4 <popcli+0x34>
    sti();
}
80103dc2:	c9                   	leave  
80103dc3:	c3                   	ret    
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103dc4:	e8 47 f5 ff ff       	call   80103310 <mycpu>
80103dc9:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103dcf:	85 c0                	test   %eax,%eax
80103dd1:	74 ef                	je     80103dc2 <popcli+0x32>
}

static inline void
sti(void)
{
  asm volatile("sti");
80103dd3:	fb                   	sti    
    sti();
}
80103dd4:	c9                   	leave  
80103dd5:	c3                   	ret    
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
    panic("popcli");
80103dd6:	c7 04 24 8a 6e 10 80 	movl   $0x80106e8a,(%esp)
80103ddd:	e8 3a c5 ff ff       	call   8010031c <panic>

void
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
80103de2:	c7 04 24 73 6e 10 80 	movl   $0x80106e73,(%esp)
80103de9:	e8 2e c5 ff ff       	call   8010031c <panic>
80103dee:	66 90                	xchg   %ax,%ax

80103df0 <holding>:
}

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80103df0:	55                   	push   %ebp
80103df1:	89 e5                	mov    %esp,%ebp
80103df3:	53                   	push   %ebx
80103df4:	51                   	push   %ecx
80103df5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  pushcli();
80103df8:	e8 5b ff ff ff       	call   80103d58 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103dfd:	8b 03                	mov    (%ebx),%eax
80103dff:	85 c0                	test   %eax,%eax
80103e01:	75 0d                	jne    80103e10 <holding+0x20>
80103e03:	31 db                	xor    %ebx,%ebx
  popcli();
80103e05:	e8 86 ff ff ff       	call   80103d90 <popcli>
  return r;
}
80103e0a:	89 d8                	mov    %ebx,%eax
80103e0c:	5a                   	pop    %edx
80103e0d:	5b                   	pop    %ebx
80103e0e:	5d                   	pop    %ebp
80103e0f:	c3                   	ret    
int
holding(struct spinlock *lock)
{
  int r;
  pushcli();
  r = lock->locked && lock->cpu == mycpu();
80103e10:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103e13:	e8 f8 f4 ff ff       	call   80103310 <mycpu>
80103e18:	39 c3                	cmp    %eax,%ebx
80103e1a:	0f 94 c3             	sete   %bl
80103e1d:	0f b6 db             	movzbl %bl,%ebx
  popcli();
80103e20:	e8 6b ff ff ff       	call   80103d90 <popcli>
  return r;
}
80103e25:	89 d8                	mov    %ebx,%eax
80103e27:	5a                   	pop    %edx
80103e28:	5b                   	pop    %ebx
80103e29:	5d                   	pop    %ebp
80103e2a:	c3                   	ret    
80103e2b:	90                   	nop

80103e2c <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80103e2c:	55                   	push   %ebp
80103e2d:	89 e5                	mov    %esp,%ebp
80103e2f:	53                   	push   %ebx
80103e30:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103e33:	e8 20 ff ff ff       	call   80103d58 <pushcli>
  if(holding(lk))
80103e38:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3b:	89 04 24             	mov    %eax,(%esp)
80103e3e:	e8 ad ff ff ff       	call   80103df0 <holding>
80103e43:	85 c0                	test   %eax,%eax
80103e45:	75 3c                	jne    80103e83 <acquire+0x57>
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103e47:	b9 01 00 00 00       	mov    $0x1,%ecx
    panic("acquire");

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80103e4c:	8b 55 08             	mov    0x8(%ebp),%edx
80103e4f:	89 c8                	mov    %ecx,%eax
80103e51:	f0 87 02             	lock xchg %eax,(%edx)
80103e54:	85 c0                	test   %eax,%eax
80103e56:	75 f4                	jne    80103e4c <acquire+0x20>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80103e58:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80103e5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103e60:	e8 ab f4 ff ff       	call   80103310 <mycpu>
80103e65:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103e68:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6b:	83 c0 0c             	add    $0xc,%eax
80103e6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e72:	8d 45 08             	lea    0x8(%ebp),%eax
80103e75:	89 04 24             	mov    %eax,(%esp)
80103e78:	e8 8f fe ff ff       	call   80103d0c <getcallerpcs>
}
80103e7d:	83 c4 14             	add    $0x14,%esp
80103e80:	5b                   	pop    %ebx
80103e81:	5d                   	pop    %ebp
80103e82:	c3                   	ret    
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");
80103e83:	c7 04 24 91 6e 10 80 	movl   $0x80106e91,(%esp)
80103e8a:	e8 8d c4 ff ff       	call   8010031c <panic>
80103e8f:	90                   	nop

80103e90 <release>:
}

// Release the lock.
void
release(struct spinlock *lk)
{
80103e90:	55                   	push   %ebp
80103e91:	89 e5                	mov    %esp,%ebp
80103e93:	53                   	push   %ebx
80103e94:	83 ec 14             	sub    $0x14,%esp
80103e97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103e9a:	89 1c 24             	mov    %ebx,(%esp)
80103e9d:	e8 4e ff ff ff       	call   80103df0 <holding>
80103ea2:	85 c0                	test   %eax,%eax
80103ea4:	74 23                	je     80103ec9 <release+0x39>
    panic("release");

  lk->pcs[0] = 0;
80103ea6:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103ead:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80103eb4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103eb9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

  popcli();
}
80103ebf:	83 c4 14             	add    $0x14,%esp
80103ec2:	5b                   	pop    %ebx
80103ec3:	5d                   	pop    %ebp
  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );

  popcli();
80103ec4:	e9 c7 fe ff ff       	jmp    80103d90 <popcli>
// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");
80103ec9:	c7 04 24 99 6e 10 80 	movl   $0x80106e99,(%esp)
80103ed0:	e8 47 c4 ff ff       	call   8010031c <panic>
80103ed5:	00 00                	add    %al,(%eax)
	...

80103ed8 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103ed8:	55                   	push   %ebp
80103ed9:	89 e5                	mov    %esp,%ebp
80103edb:	57                   	push   %edi
80103edc:	53                   	push   %ebx
80103edd:	8b 55 08             	mov    0x8(%ebp),%edx
80103ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ee3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103ee6:	f6 c2 03             	test   $0x3,%dl
80103ee9:	75 05                	jne    80103ef0 <memset+0x18>
80103eeb:	f6 c1 03             	test   $0x3,%cl
80103eee:	74 0c                	je     80103efc <memset+0x24>
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
80103ef0:	89 d7                	mov    %edx,%edi
80103ef2:	fc                   	cld    
80103ef3:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103ef5:	89 d0                	mov    %edx,%eax
80103ef7:	5b                   	pop    %ebx
80103ef8:	5f                   	pop    %edi
80103ef9:	5d                   	pop    %ebp
80103efa:	c3                   	ret    
80103efb:	90                   	nop

void*
memset(void *dst, int c, uint n)
{
  if ((int)dst%4 == 0 && n%4 == 0){
    c &= 0xFF;
80103efc:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103eff:	c1 e9 02             	shr    $0x2,%ecx
80103f02:	89 f8                	mov    %edi,%eax
80103f04:	c1 e0 18             	shl    $0x18,%eax
80103f07:	89 fb                	mov    %edi,%ebx
80103f09:	c1 e3 10             	shl    $0x10,%ebx
80103f0c:	09 d8                	or     %ebx,%eax
80103f0e:	09 f8                	or     %edi,%eax
80103f10:	c1 e7 08             	shl    $0x8,%edi
80103f13:	09 f8                	or     %edi,%eax
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
80103f15:	89 d7                	mov    %edx,%edi
80103f17:	fc                   	cld    
80103f18:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103f1a:	89 d0                	mov    %edx,%eax
80103f1c:	5b                   	pop    %ebx
80103f1d:	5f                   	pop    %edi
80103f1e:	5d                   	pop    %ebp
80103f1f:	c3                   	ret    

80103f20 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103f20:	55                   	push   %ebp
80103f21:	89 e5                	mov    %esp,%ebp
80103f23:	57                   	push   %edi
80103f24:	56                   	push   %esi
80103f25:	53                   	push   %ebx
80103f26:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103f29:	8b 75 0c             	mov    0xc(%ebp),%esi
80103f2c:	8b 7d 10             	mov    0x10(%ebp),%edi
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103f2f:	85 ff                	test   %edi,%edi
80103f31:	74 1d                	je     80103f50 <memcmp+0x30>
    if(*s1 != *s2)
80103f33:	8a 03                	mov    (%ebx),%al
80103f35:	8a 0e                	mov    (%esi),%cl
80103f37:	38 c8                	cmp    %cl,%al
80103f39:	75 1d                	jne    80103f58 <memcmp+0x38>
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103f3b:	4f                   	dec    %edi
80103f3c:	31 d2                	xor    %edx,%edx
80103f3e:	eb 0c                	jmp    80103f4c <memcmp+0x2c>
    if(*s1 != *s2)
80103f40:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
80103f44:	42                   	inc    %edx
80103f45:	8a 0c 16             	mov    (%esi,%edx,1),%cl
80103f48:	38 c8                	cmp    %cl,%al
80103f4a:	75 0c                	jne    80103f58 <memcmp+0x38>
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103f4c:	39 d7                	cmp    %edx,%edi
80103f4e:	75 f0                	jne    80103f40 <memcmp+0x20>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80103f50:	31 c0                	xor    %eax,%eax
}
80103f52:	5b                   	pop    %ebx
80103f53:	5e                   	pop    %esi
80103f54:	5f                   	pop    %edi
80103f55:	5d                   	pop    %ebp
80103f56:	c3                   	ret    
80103f57:	90                   	nop

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
      return *s1 - *s2;
80103f58:	0f b6 c0             	movzbl %al,%eax
80103f5b:	0f b6 c9             	movzbl %cl,%ecx
80103f5e:	29 c8                	sub    %ecx,%eax
    s1++, s2++;
  }

  return 0;
}
80103f60:	5b                   	pop    %ebx
80103f61:	5e                   	pop    %esi
80103f62:	5f                   	pop    %edi
80103f63:	5d                   	pop    %ebp
80103f64:	c3                   	ret    
80103f65:	8d 76 00             	lea    0x0(%esi),%esi

80103f68 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103f68:	55                   	push   %ebp
80103f69:	89 e5                	mov    %esp,%ebp
80103f6b:	57                   	push   %edi
80103f6c:	56                   	push   %esi
80103f6d:	53                   	push   %ebx
80103f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f71:	8b 75 0c             	mov    0xc(%ebp),%esi
80103f74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103f77:	39 c6                	cmp    %eax,%esi
80103f79:	73 29                	jae    80103fa4 <memmove+0x3c>
80103f7b:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
80103f7e:	39 c8                	cmp    %ecx,%eax
80103f80:	73 22                	jae    80103fa4 <memmove+0x3c>
    s += n;
    d += n;
    while(n-- > 0)
80103f82:	85 db                	test   %ebx,%ebx
80103f84:	74 19                	je     80103f9f <memmove+0x37>

  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
80103f86:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
80103f89:	89 da                	mov    %ebx,%edx

  return 0;
}

void*
memmove(void *dst, const void *src, uint n)
80103f8b:	f7 db                	neg    %ebx
80103f8d:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
80103f90:	01 fb                	add    %edi,%ebx
80103f92:	66 90                	xchg   %ax,%ax
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
80103f94:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
80103f98:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80103f9c:	4a                   	dec    %edx
80103f9d:	75 f5                	jne    80103f94 <memmove+0x2c>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80103f9f:	5b                   	pop    %ebx
80103fa0:	5e                   	pop    %esi
80103fa1:	5f                   	pop    %edi
80103fa2:	5d                   	pop    %ebp
80103fa3:	c3                   	ret    
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80103fa4:	85 db                	test   %ebx,%ebx
80103fa6:	74 f7                	je     80103f9f <memmove+0x37>
80103fa8:	31 d2                	xor    %edx,%edx
80103faa:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
80103fac:	8a 0c 16             	mov    (%esi,%edx,1),%cl
80103faf:	88 0c 10             	mov    %cl,(%eax,%edx,1)
80103fb2:	42                   	inc    %edx
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80103fb3:	39 d3                	cmp    %edx,%ebx
80103fb5:	75 f5                	jne    80103fac <memmove+0x44>
      *d++ = *s++;

  return dst;
}
80103fb7:	5b                   	pop    %ebx
80103fb8:	5e                   	pop    %esi
80103fb9:	5f                   	pop    %edi
80103fba:	5d                   	pop    %ebp
80103fbb:	c3                   	ret    

80103fbc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103fbc:	55                   	push   %ebp
80103fbd:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
80103fbf:	5d                   	pop    %ebp

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80103fc0:	e9 a3 ff ff ff       	jmp    80103f68 <memmove>
80103fc5:	8d 76 00             	lea    0x0(%esi),%esi

80103fc8 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	57                   	push   %edi
80103fcc:	56                   	push   %esi
80103fcd:	53                   	push   %ebx
80103fce:	51                   	push   %ecx
80103fcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103fd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103fd5:	8b 7d 10             	mov    0x10(%ebp),%edi
  while(n > 0 && *p && *p == *q)
80103fd8:	85 ff                	test   %edi,%edi
80103fda:	74 2d                	je     80104009 <strncmp+0x41>
80103fdc:	8a 01                	mov    (%ecx),%al
80103fde:	84 c0                	test   %al,%al
80103fe0:	74 2f                	je     80104011 <strncmp+0x49>
80103fe2:	8a 13                	mov    (%ebx),%dl
80103fe4:	88 55 f3             	mov    %dl,-0xd(%ebp)
80103fe7:	38 d0                	cmp    %dl,%al
80103fe9:	74 1b                	je     80104006 <strncmp+0x3e>
80103feb:	eb 2b                	jmp    80104018 <strncmp+0x50>
80103fed:	8d 76 00             	lea    0x0(%esi),%esi
    n--, p++, q++;
80103ff0:	41                   	inc    %ecx
80103ff1:	8d 73 01             	lea    0x1(%ebx),%esi
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80103ff4:	8a 01                	mov    (%ecx),%al
80103ff6:	8a 5b 01             	mov    0x1(%ebx),%bl
80103ff9:	88 5d f3             	mov    %bl,-0xd(%ebp)
80103ffc:	84 c0                	test   %al,%al
80103ffe:	74 18                	je     80104018 <strncmp+0x50>
80104000:	38 d8                	cmp    %bl,%al
80104002:	75 14                	jne    80104018 <strncmp+0x50>
    n--, p++, q++;
80104004:	89 f3                	mov    %esi,%ebx
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80104006:	4f                   	dec    %edi
80104007:	75 e7                	jne    80103ff0 <strncmp+0x28>
    n--, p++, q++;
  if(n == 0)
    return 0;
80104009:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}
8010400b:	5a                   	pop    %edx
8010400c:	5b                   	pop    %ebx
8010400d:	5e                   	pop    %esi
8010400e:	5f                   	pop    %edi
8010400f:	5d                   	pop    %ebp
80104010:	c3                   	ret    
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80104011:	8a 1b                	mov    (%ebx),%bl
80104013:	88 5d f3             	mov    %bl,-0xd(%ebp)
80104016:	66 90                	xchg   %ax,%ax
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80104018:	0f b6 c0             	movzbl %al,%eax
8010401b:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
8010401f:	29 d0                	sub    %edx,%eax
}
80104021:	5a                   	pop    %edx
80104022:	5b                   	pop    %ebx
80104023:	5e                   	pop    %esi
80104024:	5f                   	pop    %edi
80104025:	5d                   	pop    %ebp
80104026:	c3                   	ret    
80104027:	90                   	nop

80104028 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104028:	55                   	push   %ebp
80104029:	89 e5                	mov    %esp,%ebp
8010402b:	57                   	push   %edi
8010402c:	56                   	push   %esi
8010402d:	53                   	push   %ebx
8010402e:	8b 7d 08             	mov    0x8(%ebp),%edi
80104031:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104034:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104037:	89 fa                	mov    %edi,%edx
80104039:	eb 0b                	jmp    80104046 <strncpy+0x1e>
8010403b:	90                   	nop
8010403c:	8a 03                	mov    (%ebx),%al
8010403e:	88 02                	mov    %al,(%edx)
80104040:	42                   	inc    %edx
80104041:	43                   	inc    %ebx
80104042:	84 c0                	test   %al,%al
80104044:	74 08                	je     8010404e <strncpy+0x26>
80104046:	49                   	dec    %ecx
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
80104047:	8d 71 01             	lea    0x1(%ecx),%esi
{
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
8010404a:	85 f6                	test   %esi,%esi
8010404c:	7f ee                	jg     8010403c <strncpy+0x14>
    ;
  while(n-- > 0)
8010404e:	85 c9                	test   %ecx,%ecx
80104050:	7e 0a                	jle    8010405c <strncpy+0x34>
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
80104052:	01 d1                	add    %edx,%ecx

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
    *s++ = 0;
80104054:	c6 02 00             	movb   $0x0,(%edx)
80104057:	42                   	inc    %edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80104058:	39 ca                	cmp    %ecx,%edx
8010405a:	75 f8                	jne    80104054 <strncpy+0x2c>
    *s++ = 0;
  return os;
}
8010405c:	89 f8                	mov    %edi,%eax
8010405e:	5b                   	pop    %ebx
8010405f:	5e                   	pop    %esi
80104060:	5f                   	pop    %edi
80104061:	5d                   	pop    %ebp
80104062:	c3                   	ret    
80104063:	90                   	nop

80104064 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104064:	55                   	push   %ebp
80104065:	89 e5                	mov    %esp,%ebp
80104067:	56                   	push   %esi
80104068:	53                   	push   %ebx
80104069:	8b 75 08             	mov    0x8(%ebp),%esi
8010406c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010406f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104072:	85 d2                	test   %edx,%edx
80104074:	7e 12                	jle    80104088 <safestrcpy+0x24>
80104076:	89 f1                	mov    %esi,%ecx
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104078:	4a                   	dec    %edx
80104079:	74 0a                	je     80104085 <safestrcpy+0x21>
8010407b:	8a 03                	mov    (%ebx),%al
8010407d:	88 01                	mov    %al,(%ecx)
8010407f:	41                   	inc    %ecx
80104080:	43                   	inc    %ebx
80104081:	84 c0                	test   %al,%al
80104083:	75 f3                	jne    80104078 <safestrcpy+0x14>
    ;
  *s = 0;
80104085:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104088:	89 f0                	mov    %esi,%eax
8010408a:	5b                   	pop    %ebx
8010408b:	5e                   	pop    %esi
8010408c:	5d                   	pop    %ebp
8010408d:	c3                   	ret    
8010408e:	66 90                	xchg   %ax,%ax

80104090 <strlen>:

int
strlen(const char *s)
{
80104090:	55                   	push   %ebp
80104091:	89 e5                	mov    %esp,%ebp
80104093:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80104096:	31 c0                	xor    %eax,%eax
80104098:	80 3a 00             	cmpb   $0x0,(%edx)
8010409b:	74 0a                	je     801040a7 <strlen+0x17>
8010409d:	8d 76 00             	lea    0x0(%esi),%esi
801040a0:	40                   	inc    %eax
801040a1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801040a5:	75 f9                	jne    801040a0 <strlen+0x10>
    ;
  return n;
}
801040a7:	5d                   	pop    %ebp
801040a8:	c3                   	ret    
801040a9:	00 00                	add    %al,(%eax)
	...

801040ac <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801040ac:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801040b0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801040b4:	55                   	push   %ebp
  pushl %ebx
801040b5:	53                   	push   %ebx
  pushl %esi
801040b6:	56                   	push   %esi
  pushl %edi
801040b7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801040b8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801040ba:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801040bc:	5f                   	pop    %edi
  popl %esi
801040bd:	5e                   	pop    %esi
  popl %ebx
801040be:	5b                   	pop    %ebx
  popl %ebp
801040bf:	5d                   	pop    %ebp
  ret
801040c0:	c3                   	ret    
801040c1:	00 00                	add    %al,(%eax)
	...

801040c4 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801040c4:	55                   	push   %ebp
801040c5:	89 e5                	mov    %esp,%ebp
801040c7:	53                   	push   %ebx
801040c8:	51                   	push   %ecx
801040c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801040cc:	e8 e7 f2 ff ff       	call   801033b8 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801040d1:	8b 00                	mov    (%eax),%eax
801040d3:	39 d8                	cmp    %ebx,%eax
801040d5:	76 15                	jbe    801040ec <fetchint+0x28>
801040d7:	8d 53 04             	lea    0x4(%ebx),%edx
801040da:	39 d0                	cmp    %edx,%eax
801040dc:	72 0e                	jb     801040ec <fetchint+0x28>
    return -1;
  *ip = *(int*)(addr);
801040de:	8b 13                	mov    (%ebx),%edx
801040e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e3:	89 10                	mov    %edx,(%eax)
  return 0;
801040e5:	31 c0                	xor    %eax,%eax
}
801040e7:	5a                   	pop    %edx
801040e8:	5b                   	pop    %ebx
801040e9:	5d                   	pop    %ebp
801040ea:	c3                   	ret    
801040eb:	90                   	nop
fetchint(uint addr, int *ip)
{
  struct proc *curproc = myproc();

  if(addr >= curproc->sz || addr+4 > curproc->sz)
    return -1;
801040ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040f1:	eb f4                	jmp    801040e7 <fetchint+0x23>
801040f3:	90                   	nop

801040f4 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801040f4:	55                   	push   %ebp
801040f5:	89 e5                	mov    %esp,%ebp
801040f7:	53                   	push   %ebx
801040f8:	50                   	push   %eax
801040f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801040fc:	e8 b7 f2 ff ff       	call   801033b8 <myproc>

  if(addr >= curproc->sz)
80104101:	39 18                	cmp    %ebx,(%eax)
80104103:	76 21                	jbe    80104126 <fetchstr+0x32>
    return -1;
  *pp = (char*)addr;
80104105:	8b 55 0c             	mov    0xc(%ebp),%edx
80104108:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010410a:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
8010410c:	39 d3                	cmp    %edx,%ebx
8010410e:	73 16                	jae    80104126 <fetchstr+0x32>
    if(*s == 0)
80104110:	80 3b 00             	cmpb   $0x0,(%ebx)
80104113:	74 21                	je     80104136 <fetchstr+0x42>
80104115:	89 d8                	mov    %ebx,%eax
80104117:	eb 08                	jmp    80104121 <fetchstr+0x2d>
80104119:	8d 76 00             	lea    0x0(%esi),%esi
8010411c:	80 38 00             	cmpb   $0x0,(%eax)
8010411f:	74 0f                	je     80104130 <fetchstr+0x3c>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80104121:	40                   	inc    %eax
80104122:	39 c2                	cmp    %eax,%edx
80104124:	77 f6                	ja     8010411c <fetchstr+0x28>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80104126:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010412b:	5b                   	pop    %ebx
8010412c:	5b                   	pop    %ebx
8010412d:	5d                   	pop    %ebp
8010412e:	c3                   	ret    
8010412f:	90                   	nop
  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
    if(*s == 0)
80104130:	29 d8                	sub    %ebx,%eax
      return s - *pp;
  }
  return -1;
}
80104132:	5b                   	pop    %ebx
80104133:	5b                   	pop    %ebx
80104134:	5d                   	pop    %ebp
80104135:	c3                   	ret    
  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
    if(*s == 0)
80104136:	31 c0                	xor    %eax,%eax
      return s - *pp;
80104138:	eb f1                	jmp    8010412b <fetchstr+0x37>
8010413a:	66 90                	xchg   %ax,%ax

8010413c <argint>:
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010413c:	55                   	push   %ebp
8010413d:	89 e5                	mov    %esp,%ebp
8010413f:	56                   	push   %esi
80104140:	53                   	push   %ebx
80104141:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104144:	8b 75 0c             	mov    0xc(%ebp),%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104147:	e8 6c f2 ff ff       	call   801033b8 <myproc>
8010414c:	89 75 0c             	mov    %esi,0xc(%ebp)
8010414f:	8b 40 18             	mov    0x18(%eax),%eax
80104152:	8b 40 44             	mov    0x44(%eax),%eax
80104155:	8d 44 98 04          	lea    0x4(%eax,%ebx,4),%eax
80104159:	89 45 08             	mov    %eax,0x8(%ebp)
}
8010415c:	5b                   	pop    %ebx
8010415d:	5e                   	pop    %esi
8010415e:	5d                   	pop    %ebp

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010415f:	e9 60 ff ff ff       	jmp    801040c4 <fetchint>

80104164 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104164:	55                   	push   %ebp
80104165:	89 e5                	mov    %esp,%ebp
80104167:	56                   	push   %esi
80104168:	53                   	push   %ebx
80104169:	83 ec 20             	sub    $0x20,%esp
8010416c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010416f:	e8 44 f2 ff ff       	call   801033b8 <myproc>
80104174:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104176:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104179:	89 44 24 04          	mov    %eax,0x4(%esp)
8010417d:	8b 45 08             	mov    0x8(%ebp),%eax
80104180:	89 04 24             	mov    %eax,(%esp)
80104183:	e8 b4 ff ff ff       	call   8010413c <argint>
80104188:	85 c0                	test   %eax,%eax
8010418a:	78 24                	js     801041b0 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010418c:	85 db                	test   %ebx,%ebx
8010418e:	78 20                	js     801041b0 <argptr+0x4c>
80104190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104193:	8b 16                	mov    (%esi),%edx
80104195:	39 d0                	cmp    %edx,%eax
80104197:	73 17                	jae    801041b0 <argptr+0x4c>
80104199:	01 c3                	add    %eax,%ebx
8010419b:	39 da                	cmp    %ebx,%edx
8010419d:	72 11                	jb     801041b0 <argptr+0x4c>
    return -1;
  *pp = (char*)i;
8010419f:	8b 55 0c             	mov    0xc(%ebp),%edx
801041a2:	89 02                	mov    %eax,(%edx)
  return 0;
801041a4:	31 c0                	xor    %eax,%eax
}
801041a6:	83 c4 20             	add    $0x20,%esp
801041a9:	5b                   	pop    %ebx
801041aa:	5e                   	pop    %esi
801041ab:	5d                   	pop    %ebp
801041ac:	c3                   	ret    
801041ad:	8d 76 00             	lea    0x0(%esi),%esi
  struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
    return -1;
801041b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  *pp = (char*)i;
  return 0;
}
801041b5:	83 c4 20             	add    $0x20,%esp
801041b8:	5b                   	pop    %ebx
801041b9:	5e                   	pop    %esi
801041ba:	5d                   	pop    %ebp
801041bb:	c3                   	ret    

801041bc <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801041bc:	55                   	push   %ebp
801041bd:	89 e5                	mov    %esp,%ebp
801041bf:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
801041c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801041c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801041c9:	8b 45 08             	mov    0x8(%ebp),%eax
801041cc:	89 04 24             	mov    %eax,(%esp)
801041cf:	e8 68 ff ff ff       	call   8010413c <argint>
801041d4:	85 c0                	test   %eax,%eax
801041d6:	78 14                	js     801041ec <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
801041d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801041db:	89 44 24 04          	mov    %eax,0x4(%esp)
801041df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e2:	89 04 24             	mov    %eax,(%esp)
801041e5:	e8 0a ff ff ff       	call   801040f4 <fetchstr>
}
801041ea:	c9                   	leave  
801041eb:	c3                   	ret    
int
argstr(int n, char **pp)
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
801041ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchstr(addr, pp);
}
801041f1:	c9                   	leave  
801041f2:	c3                   	ret    
801041f3:	90                   	nop

801041f4 <syscall>:
};
*/

void
syscall(void)
{
801041f4:	55                   	push   %ebp
801041f5:	89 e5                	mov    %esp,%ebp
801041f7:	53                   	push   %ebx
801041f8:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
801041fb:	e8 b8 f1 ff ff       	call   801033b8 <myproc>

  num = curproc->tf->eax;
80104200:	8b 58 18             	mov    0x18(%eax),%ebx
80104203:	8b 53 1c             	mov    0x1c(%ebx),%edx
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104206:	8d 4a ff             	lea    -0x1(%edx),%ecx
80104209:	83 f9 16             	cmp    $0x16,%ecx
8010420c:	77 16                	ja     80104224 <syscall+0x30>
8010420e:	8b 0c 95 c0 6e 10 80 	mov    -0x7fef9140(,%edx,4),%ecx
80104215:	85 c9                	test   %ecx,%ecx
80104217:	74 0b                	je     80104224 <syscall+0x30>
    curproc->tf->eax = syscalls[num]();
80104219:	ff d1                	call   *%ecx
8010421b:	89 43 1c             	mov    %eax,0x1c(%ebx)
*/  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
8010421e:	83 c4 24             	add    $0x24,%esp
80104221:	5b                   	pop    %ebx
80104222:	5d                   	pop    %ebp
80104223:	c3                   	ret    
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
/*    cprintf("%s -> %d\n", 
    	    syscalls_num[num], curproc->tf->eax);
*/  } else {
    cprintf("%d %s: unknown sys call %d\n",
80104224:	89 54 24 0c          	mov    %edx,0xc(%esp)
            curproc->pid, curproc->name, num);
80104228:	8d 50 6c             	lea    0x6c(%eax),%edx
8010422b:	89 54 24 08          	mov    %edx,0x8(%esp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
/*    cprintf("%s -> %d\n", 
    	    syscalls_num[num], curproc->tf->eax);
*/  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010422f:	8b 50 10             	mov    0x10(%eax),%edx
80104232:	89 54 24 04          	mov    %edx,0x4(%esp)
80104236:	c7 04 24 a1 6e 10 80 	movl   $0x80106ea1,(%esp)
8010423d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104240:	e8 77 c3 ff ff       	call   801005bc <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80104245:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104248:	8b 40 18             	mov    0x18(%eax),%eax
8010424b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104252:	83 c4 24             	add    $0x24,%esp
80104255:	5b                   	pop    %ebx
80104256:	5d                   	pop    %ebp
80104257:	c3                   	ret    

80104258 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104258:	55                   	push   %ebp
80104259:	89 e5                	mov    %esp,%ebp
8010425b:	53                   	push   %ebx
8010425c:	53                   	push   %ebx
8010425d:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
8010425f:	e8 54 f1 ff ff       	call   801033b8 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
80104264:	31 d2                	xor    %edx,%edx
80104266:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80104268:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
8010426c:	85 c9                	test   %ecx,%ecx
8010426e:	74 14                	je     80104284 <fdalloc+0x2c>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80104270:	42                   	inc    %edx
80104271:	83 fa 10             	cmp    $0x10,%edx
80104274:	75 f2                	jne    80104268 <fdalloc+0x10>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80104276:	ba ff ff ff ff       	mov    $0xffffffff,%edx
}
8010427b:	89 d0                	mov    %edx,%eax
8010427d:	5a                   	pop    %edx
8010427e:	5b                   	pop    %ebx
8010427f:	5d                   	pop    %ebp
80104280:	c3                   	ret    
80104281:	8d 76 00             	lea    0x0(%esi),%esi
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
80104284:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
80104288:	89 d0                	mov    %edx,%eax
8010428a:	5a                   	pop    %edx
8010428b:	5b                   	pop    %ebx
8010428c:	5d                   	pop    %ebp
8010428d:	c3                   	ret    
8010428e:	66 90                	xchg   %ax,%ax

80104290 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104290:	55                   	push   %ebp
80104291:	89 e5                	mov    %esp,%ebp
80104293:	57                   	push   %edi
80104294:	56                   	push   %esi
80104295:	53                   	push   %ebx
80104296:	83 ec 3c             	sub    $0x3c,%esp
80104299:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
8010429c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010429f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801042a2:	89 d7                	mov    %edx,%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801042a4:	8d 75 da             	lea    -0x26(%ebp),%esi
801042a7:	89 74 24 04          	mov    %esi,0x4(%esp)
801042ab:	89 04 24             	mov    %eax,(%esp)
801042ae:	e8 6d db ff ff       	call   80101e20 <nameiparent>
801042b3:	85 c0                	test   %eax,%eax
801042b5:	0f 84 e9 00 00 00    	je     801043a4 <create+0x114>
    return 0;
  ilock(dp);
801042bb:	89 04 24             	mov    %eax,(%esp)
801042be:	89 45 cc             	mov    %eax,-0x34(%ebp)
801042c1:	e8 12 d3 ff ff       	call   801015d8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801042c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801042cd:	00 
801042ce:	89 74 24 04          	mov    %esi,0x4(%esp)
801042d2:	8b 55 cc             	mov    -0x34(%ebp),%edx
801042d5:	89 14 24             	mov    %edx,(%esp)
801042d8:	e8 2b d8 ff ff       	call   80101b08 <dirlookup>
801042dd:	89 c3                	mov    %eax,%ebx
801042df:	85 c0                	test   %eax,%eax
801042e1:	8b 55 cc             	mov    -0x34(%ebp),%edx
801042e4:	74 3e                	je     80104324 <create+0x94>
    iunlockput(dp);
801042e6:	89 14 24             	mov    %edx,(%esp)
801042e9:	e8 3a d5 ff ff       	call   80101828 <iunlockput>
    ilock(ip);
801042ee:	89 1c 24             	mov    %ebx,(%esp)
801042f1:	e8 e2 d2 ff ff       	call   801015d8 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801042f6:	66 83 ff 02          	cmp    $0x2,%di
801042fa:	75 14                	jne    80104310 <create+0x80>
801042fc:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104301:	75 0d                	jne    80104310 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104303:	89 d8                	mov    %ebx,%eax
80104305:	83 c4 3c             	add    $0x3c,%esp
80104308:	5b                   	pop    %ebx
80104309:	5e                   	pop    %esi
8010430a:	5f                   	pop    %edi
8010430b:	5d                   	pop    %ebp
8010430c:	c3                   	ret    
8010430d:	8d 76 00             	lea    0x0(%esi),%esi
  if((ip = dirlookup(dp, name, 0)) != 0){
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
80104310:	89 1c 24             	mov    %ebx,(%esp)
80104313:	e8 10 d5 ff ff       	call   80101828 <iunlockput>
    return 0;
80104318:	31 db                	xor    %ebx,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010431a:	89 d8                	mov    %ebx,%eax
8010431c:	83 c4 3c             	add    $0x3c,%esp
8010431f:	5b                   	pop    %ebx
80104320:	5e                   	pop    %esi
80104321:	5f                   	pop    %edi
80104322:	5d                   	pop    %ebp
80104323:	c3                   	ret    
      return ip;
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80104324:	0f bf c7             	movswl %di,%eax
80104327:	89 44 24 04          	mov    %eax,0x4(%esp)
8010432b:	8b 02                	mov    (%edx),%eax
8010432d:	89 04 24             	mov    %eax,(%esp)
80104330:	89 55 cc             	mov    %edx,-0x34(%ebp)
80104333:	e8 24 d1 ff ff       	call   8010145c <ialloc>
80104338:	89 c3                	mov    %eax,%ebx
8010433a:	85 c0                	test   %eax,%eax
8010433c:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010433f:	0f 84 ce 00 00 00    	je     80104413 <create+0x183>
    panic("create: ialloc");

  ilock(ip);
80104345:	89 04 24             	mov    %eax,(%esp)
80104348:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010434b:	e8 88 d2 ff ff       	call   801015d8 <ilock>
  ip->major = major;
80104350:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104353:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104357:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010435a:	66 89 4b 54          	mov    %cx,0x54(%ebx)
  ip->nlink = 1;
8010435e:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104364:	89 1c 24             	mov    %ebx,(%esp)
80104367:	e8 b4 d1 ff ff       	call   80101520 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010436c:	66 4f                	dec    %di
8010436e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104371:	74 39                	je     801043ac <create+0x11c>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
80104373:	8b 43 04             	mov    0x4(%ebx),%eax
80104376:	89 44 24 08          	mov    %eax,0x8(%esp)
8010437a:	89 74 24 04          	mov    %esi,0x4(%esp)
8010437e:	89 14 24             	mov    %edx,(%esp)
80104381:	89 55 cc             	mov    %edx,-0x34(%ebp)
80104384:	e8 a7 d9 ff ff       	call   80101d30 <dirlink>
80104389:	85 c0                	test   %eax,%eax
8010438b:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010438e:	78 77                	js     80104407 <create+0x177>
    panic("create: dirlink");

  iunlockput(dp);
80104390:	89 14 24             	mov    %edx,(%esp)
80104393:	e8 90 d4 ff ff       	call   80101828 <iunlockput>

  return ip;
}
80104398:	89 d8                	mov    %ebx,%eax
8010439a:	83 c4 3c             	add    $0x3c,%esp
8010439d:	5b                   	pop    %ebx
8010439e:	5e                   	pop    %esi
8010439f:	5f                   	pop    %edi
801043a0:	5d                   	pop    %ebp
801043a1:	c3                   	ret    
801043a2:	66 90                	xchg   %ax,%ax
{
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    return 0;
801043a4:	31 db                	xor    %ebx,%ebx
801043a6:	e9 58 ff ff ff       	jmp    80104303 <create+0x73>
801043ab:	90                   	nop
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
801043ac:	66 ff 42 56          	incw   0x56(%edx)
    iupdate(dp);
801043b0:	89 14 24             	mov    %edx,(%esp)
801043b3:	89 55 cc             	mov    %edx,-0x34(%ebp)
801043b6:	e8 65 d1 ff ff       	call   80101520 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801043bb:	8b 43 04             	mov    0x4(%ebx),%eax
801043be:	89 44 24 08          	mov    %eax,0x8(%esp)
801043c2:	c7 44 24 04 30 6f 10 	movl   $0x80106f30,0x4(%esp)
801043c9:	80 
801043ca:	89 1c 24             	mov    %ebx,(%esp)
801043cd:	e8 5e d9 ff ff       	call   80101d30 <dirlink>
801043d2:	85 c0                	test   %eax,%eax
801043d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
801043d7:	78 22                	js     801043fb <create+0x16b>
801043d9:	8b 42 04             	mov    0x4(%edx),%eax
801043dc:	89 44 24 08          	mov    %eax,0x8(%esp)
801043e0:	c7 44 24 04 2f 6f 10 	movl   $0x80106f2f,0x4(%esp)
801043e7:	80 
801043e8:	89 1c 24             	mov    %ebx,(%esp)
801043eb:	e8 40 d9 ff ff       	call   80101d30 <dirlink>
801043f0:	85 c0                	test   %eax,%eax
801043f2:	8b 55 cc             	mov    -0x34(%ebp),%edx
801043f5:	0f 89 78 ff ff ff    	jns    80104373 <create+0xe3>
      panic("create dots");
801043fb:	c7 04 24 32 6f 10 80 	movl   $0x80106f32,(%esp)
80104402:	e8 15 bf ff ff       	call   8010031c <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");
80104407:	c7 04 24 3e 6f 10 80 	movl   $0x80106f3e,(%esp)
8010440e:	e8 09 bf ff ff       	call   8010031c <panic>
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");
80104413:	c7 04 24 20 6f 10 80 	movl   $0x80106f20,(%esp)
8010441a:	e8 fd be ff ff       	call   8010031c <panic>
8010441f:	90                   	nop

80104420 <argfd.constprop.0>:
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
80104420:	55                   	push   %ebp
80104421:	89 e5                	mov    %esp,%ebp
80104423:	56                   	push   %esi
80104424:	53                   	push   %ebx
80104425:	83 ec 20             	sub    $0x20,%esp
80104428:	89 c3                	mov    %eax,%ebx
8010442a:	89 d6                	mov    %edx,%esi
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010442c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010442f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104433:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010443a:	e8 fd fc ff ff       	call   8010413c <argint>
8010443f:	85 c0                	test   %eax,%eax
80104441:	78 2d                	js     80104470 <argfd.constprop.0+0x50>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104443:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104447:	77 27                	ja     80104470 <argfd.constprop.0+0x50>
80104449:	e8 6a ef ff ff       	call   801033b8 <myproc>
8010444e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104451:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104455:	85 c0                	test   %eax,%eax
80104457:	74 17                	je     80104470 <argfd.constprop.0+0x50>
    return -1;
  if(pfd)
80104459:	85 db                	test   %ebx,%ebx
8010445b:	74 02                	je     8010445f <argfd.constprop.0+0x3f>
    *pfd = fd;
8010445d:	89 13                	mov    %edx,(%ebx)
  if(pf)
8010445f:	85 f6                	test   %esi,%esi
80104461:	74 19                	je     8010447c <argfd.constprop.0+0x5c>
    *pf = f;
80104463:	89 06                	mov    %eax,(%esi)
  return 0;
80104465:	31 c0                	xor    %eax,%eax
}
80104467:	83 c4 20             	add    $0x20,%esp
8010446a:	5b                   	pop    %ebx
8010446b:	5e                   	pop    %esi
8010446c:	5d                   	pop    %ebp
8010446d:	c3                   	ret    
8010446e:	66 90                	xchg   %ax,%ax
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    return -1;
80104470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  return 0;
}
80104475:	83 c4 20             	add    $0x20,%esp
80104478:	5b                   	pop    %ebx
80104479:	5e                   	pop    %esi
8010447a:	5d                   	pop    %ebp
8010447b:	c3                   	ret    
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  return 0;
8010447c:	31 c0                	xor    %eax,%eax
8010447e:	eb e7                	jmp    80104467 <argfd.constprop.0+0x47>

80104480 <sys_dup>:
  return -1;
}

int
sys_dup(void)
{
80104480:	55                   	push   %ebp
80104481:	89 e5                	mov    %esp,%ebp
80104483:	53                   	push   %ebx
80104484:	83 ec 24             	sub    $0x24,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104487:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010448a:	31 c0                	xor    %eax,%eax
8010448c:	e8 8f ff ff ff       	call   80104420 <argfd.constprop.0>
80104491:	85 c0                	test   %eax,%eax
80104493:	78 23                	js     801044b8 <sys_dup+0x38>
    return -1;
  if((fd=fdalloc(f)) < 0)
80104495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104498:	e8 bb fd ff ff       	call   80104258 <fdalloc>
8010449d:	89 c3                	mov    %eax,%ebx
8010449f:	85 c0                	test   %eax,%eax
801044a1:	78 15                	js     801044b8 <sys_dup+0x38>
    return -1;
  filedup(f);
801044a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a6:	89 04 24             	mov    %eax,(%esp)
801044a9:	e8 26 c8 ff ff       	call   80100cd4 <filedup>
  return fd;
}
801044ae:	89 d8                	mov    %ebx,%eax
801044b0:	83 c4 24             	add    $0x24,%esp
801044b3:	5b                   	pop    %ebx
801044b4:	5d                   	pop    %ebp
801044b5:	c3                   	ret    
801044b6:	66 90                	xchg   %ax,%ax
  int fd;

  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
801044b8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044bd:	eb ef                	jmp    801044ae <sys_dup+0x2e>
801044bf:	90                   	nop

801044c0 <sys_read>:
  return fd;
}

int
sys_read(void)
{
801044c0:	55                   	push   %ebp
801044c1:	89 e5                	mov    %esp,%ebp
801044c3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801044c6:	8d 55 ec             	lea    -0x14(%ebp),%edx
801044c9:	31 c0                	xor    %eax,%eax
801044cb:	e8 50 ff ff ff       	call   80104420 <argfd.constprop.0>
801044d0:	85 c0                	test   %eax,%eax
801044d2:	78 50                	js     80104524 <sys_read+0x64>
801044d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801044db:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801044e2:	e8 55 fc ff ff       	call   8010413c <argint>
801044e7:	85 c0                	test   %eax,%eax
801044e9:	78 39                	js     80104524 <sys_read+0x64>
801044eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ee:	89 44 24 08          	mov    %eax,0x8(%esp)
801044f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801044f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801044f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104500:	e8 5f fc ff ff       	call   80104164 <argptr>
80104505:	85 c0                	test   %eax,%eax
80104507:	78 1b                	js     80104524 <sys_read+0x64>
    return -1;
  return fileread(f, p, n);
80104509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010450c:	89 44 24 08          	mov    %eax,0x8(%esp)
80104510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104513:	89 44 24 04          	mov    %eax,0x4(%esp)
80104517:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010451a:	89 04 24             	mov    %eax,(%esp)
8010451d:	e8 fa c8 ff ff       	call   80100e1c <fileread>
}
80104522:	c9                   	leave  
80104523:	c3                   	ret    
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
    return -1;
80104524:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fileread(f, p, n);
}
80104529:	c9                   	leave  
8010452a:	c3                   	ret    
8010452b:	90                   	nop

8010452c <sys_write>:

int
sys_write(void)
{
8010452c:	55                   	push   %ebp
8010452d:	89 e5                	mov    %esp,%ebp
8010452f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104532:	8d 55 ec             	lea    -0x14(%ebp),%edx
80104535:	31 c0                	xor    %eax,%eax
80104537:	e8 e4 fe ff ff       	call   80104420 <argfd.constprop.0>
8010453c:	85 c0                	test   %eax,%eax
8010453e:	78 50                	js     80104590 <sys_write+0x64>
80104540:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104543:	89 44 24 04          	mov    %eax,0x4(%esp)
80104547:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010454e:	e8 e9 fb ff ff       	call   8010413c <argint>
80104553:	85 c0                	test   %eax,%eax
80104555:	78 39                	js     80104590 <sys_write+0x64>
80104557:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010455a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010455e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104561:	89 44 24 04          	mov    %eax,0x4(%esp)
80104565:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010456c:	e8 f3 fb ff ff       	call   80104164 <argptr>
80104571:	85 c0                	test   %eax,%eax
80104573:	78 1b                	js     80104590 <sys_write+0x64>
    return -1;
  return filewrite(f, p, n);
80104575:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104578:	89 44 24 08          	mov    %eax,0x8(%esp)
8010457c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104583:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104586:	89 04 24             	mov    %eax,(%esp)
80104589:	e8 22 c9 ff ff       	call   80100eb0 <filewrite>
}
8010458e:	c9                   	leave  
8010458f:	c3                   	ret    
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
    return -1;
80104590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return filewrite(f, p, n);
}
80104595:	c9                   	leave  
80104596:	c3                   	ret    
80104597:	90                   	nop

80104598 <sys_close>:

int
sys_close(void)
{
80104598:	55                   	push   %ebp
80104599:	89 e5                	mov    %esp,%ebp
8010459b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010459e:	8d 55 f4             	lea    -0xc(%ebp),%edx
801045a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801045a4:	e8 77 fe ff ff       	call   80104420 <argfd.constprop.0>
801045a9:	85 c0                	test   %eax,%eax
801045ab:	78 1f                	js     801045cc <sys_close+0x34>
    return -1;
  myproc()->ofile[fd] = 0;
801045ad:	e8 06 ee ff ff       	call   801033b8 <myproc>
801045b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045b5:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801045bc:	00 
  fileclose(f);
801045bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c0:	89 04 24             	mov    %eax,(%esp)
801045c3:	e8 50 c7 ff ff       	call   80100d18 <fileclose>
  return 0;
801045c8:	31 c0                	xor    %eax,%eax
}
801045ca:	c9                   	leave  
801045cb:	c3                   	ret    
{
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    return -1;
801045cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  myproc()->ofile[fd] = 0;
  fileclose(f);
  return 0;
}
801045d1:	c9                   	leave  
801045d2:	c3                   	ret    
801045d3:	90                   	nop

801045d4 <sys_fstat>:

int
sys_fstat(void)
{
801045d4:	55                   	push   %ebp
801045d5:	89 e5                	mov    %esp,%ebp
801045d7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801045da:	8d 55 f0             	lea    -0x10(%ebp),%edx
801045dd:	31 c0                	xor    %eax,%eax
801045df:	e8 3c fe ff ff       	call   80104420 <argfd.constprop.0>
801045e4:	85 c0                	test   %eax,%eax
801045e6:	78 34                	js     8010461c <sys_fstat+0x48>
801045e8:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801045ef:	00 
801045f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801045f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801045f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801045fe:	e8 61 fb ff ff       	call   80104164 <argptr>
80104603:	85 c0                	test   %eax,%eax
80104605:	78 15                	js     8010461c <sys_fstat+0x48>
    return -1;
  return filestat(f, st);
80104607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010460e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104611:	89 04 24             	mov    %eax,(%esp)
80104614:	e8 b7 c7 ff ff       	call   80100dd0 <filestat>
}
80104619:	c9                   	leave  
8010461a:	c3                   	ret    
8010461b:	90                   	nop
{
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
    return -1;
8010461c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return filestat(f, st);
}
80104621:	c9                   	leave  
80104622:	c3                   	ret    
80104623:	90                   	nop

80104624 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80104624:	55                   	push   %ebp
80104625:	89 e5                	mov    %esp,%ebp
80104627:	57                   	push   %edi
80104628:	56                   	push   %esi
80104629:	53                   	push   %ebx
8010462a:	83 ec 3c             	sub    $0x3c,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010462d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104630:	89 44 24 04          	mov    %eax,0x4(%esp)
80104634:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010463b:	e8 7c fb ff ff       	call   801041bc <argstr>
80104640:	85 c0                	test   %eax,%eax
80104642:	0f 88 f0 00 00 00    	js     80104738 <sys_link+0x114>
80104648:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010464b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010464f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104656:	e8 61 fb ff ff       	call   801041bc <argstr>
8010465b:	85 c0                	test   %eax,%eax
8010465d:	0f 88 d5 00 00 00    	js     80104738 <sys_link+0x114>
    return -1;

  begin_op();
80104663:	e8 68 e2 ff ff       	call   801028d0 <begin_op>
  if((ip = namei(old)) == 0){
80104668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010466b:	89 04 24             	mov    %eax,(%esp)
8010466e:	e8 95 d7 ff ff       	call   80101e08 <namei>
80104673:	89 c3                	mov    %eax,%ebx
80104675:	85 c0                	test   %eax,%eax
80104677:	0f 84 a7 00 00 00    	je     80104724 <sys_link+0x100>
    end_op();
    return -1;
  }

  ilock(ip);
8010467d:	89 04 24             	mov    %eax,(%esp)
80104680:	e8 53 cf ff ff       	call   801015d8 <ilock>
  if(ip->type == T_DIR){
80104685:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010468a:	0f 84 b0 00 00 00    	je     80104740 <sys_link+0x11c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
80104690:	66 ff 43 56          	incw   0x56(%ebx)
  iupdate(ip);
80104694:	89 1c 24             	mov    %ebx,(%esp)
80104697:	e8 84 ce ff ff       	call   80101520 <iupdate>
  iunlock(ip);
8010469c:	89 1c 24             	mov    %ebx,(%esp)
8010469f:	e8 04 d0 ff ff       	call   801016a8 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801046a4:	8d 7d d2             	lea    -0x2e(%ebp),%edi
801046a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
801046ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ae:	89 04 24             	mov    %eax,(%esp)
801046b1:	e8 6a d7 ff ff       	call   80101e20 <nameiparent>
801046b6:	89 c6                	mov    %eax,%esi
801046b8:	85 c0                	test   %eax,%eax
801046ba:	74 4c                	je     80104708 <sys_link+0xe4>
    goto bad;
  ilock(dp);
801046bc:	89 04 24             	mov    %eax,(%esp)
801046bf:	e8 14 cf ff ff       	call   801015d8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801046c4:	8b 03                	mov    (%ebx),%eax
801046c6:	39 06                	cmp    %eax,(%esi)
801046c8:	75 36                	jne    80104700 <sys_link+0xdc>
801046ca:	8b 43 04             	mov    0x4(%ebx),%eax
801046cd:	89 44 24 08          	mov    %eax,0x8(%esp)
801046d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
801046d5:	89 34 24             	mov    %esi,(%esp)
801046d8:	e8 53 d6 ff ff       	call   80101d30 <dirlink>
801046dd:	85 c0                	test   %eax,%eax
801046df:	78 1f                	js     80104700 <sys_link+0xdc>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
801046e1:	89 34 24             	mov    %esi,(%esp)
801046e4:	e8 3f d1 ff ff       	call   80101828 <iunlockput>
  iput(ip);
801046e9:	89 1c 24             	mov    %ebx,(%esp)
801046ec:	e8 f7 cf ff ff       	call   801016e8 <iput>

  end_op();
801046f1:	e8 3a e2 ff ff       	call   80102930 <end_op>

  return 0;
801046f6:	31 c0                	xor    %eax,%eax
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  end_op();
  return -1;
}
801046f8:	83 c4 3c             	add    $0x3c,%esp
801046fb:	5b                   	pop    %ebx
801046fc:	5e                   	pop    %esi
801046fd:	5f                   	pop    %edi
801046fe:	5d                   	pop    %ebp
801046ff:	c3                   	ret    

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
80104700:	89 34 24             	mov    %esi,(%esp)
80104703:	e8 20 d1 ff ff       	call   80101828 <iunlockput>
  end_op();

  return 0;

bad:
  ilock(ip);
80104708:	89 1c 24             	mov    %ebx,(%esp)
8010470b:	e8 c8 ce ff ff       	call   801015d8 <ilock>
  ip->nlink--;
80104710:	66 ff 4b 56          	decw   0x56(%ebx)
  iupdate(ip);
80104714:	89 1c 24             	mov    %ebx,(%esp)
80104717:	e8 04 ce ff ff       	call   80101520 <iupdate>
  iunlockput(ip);
8010471c:	89 1c 24             	mov    %ebx,(%esp)
8010471f:	e8 04 d1 ff ff       	call   80101828 <iunlockput>
  end_op();
80104724:	e8 07 e2 ff ff       	call   80102930 <end_op>
  return -1;
80104729:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010472e:	83 c4 3c             	add    $0x3c,%esp
80104731:	5b                   	pop    %ebx
80104732:	5e                   	pop    %esi
80104733:	5f                   	pop    %edi
80104734:	5d                   	pop    %ebp
80104735:	c3                   	ret    
80104736:	66 90                	xchg   %ax,%ax
{
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
    return -1;
80104738:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010473d:	eb b9                	jmp    801046f8 <sys_link+0xd4>
8010473f:	90                   	nop
    return -1;
  }

  ilock(ip);
  if(ip->type == T_DIR){
    iunlockput(ip);
80104740:	89 1c 24             	mov    %ebx,(%esp)
80104743:	e8 e0 d0 ff ff       	call   80101828 <iunlockput>
    end_op();
80104748:	e8 e3 e1 ff ff       	call   80102930 <end_op>
    return -1;
8010474d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104752:	eb a4                	jmp    801046f8 <sys_link+0xd4>

80104754 <sys_unlink>:
}

//PAGEBREAK!
int
sys_unlink(void)
{
80104754:	55                   	push   %ebp
80104755:	89 e5                	mov    %esp,%ebp
80104757:	57                   	push   %edi
80104758:	56                   	push   %esi
80104759:	53                   	push   %ebx
8010475a:	83 ec 6c             	sub    $0x6c,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010475d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104760:	89 44 24 04          	mov    %eax,0x4(%esp)
80104764:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010476b:	e8 4c fa ff ff       	call   801041bc <argstr>
80104770:	85 c0                	test   %eax,%eax
80104772:	0f 88 94 01 00 00    	js     8010490c <sys_unlink+0x1b8>
    return -1;

  begin_op();
80104778:	e8 53 e1 ff ff       	call   801028d0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010477d:	8d 5d d2             	lea    -0x2e(%ebp),%ebx
80104780:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80104784:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104787:	89 04 24             	mov    %eax,(%esp)
8010478a:	e8 91 d6 ff ff       	call   80101e20 <nameiparent>
8010478f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
80104792:	85 c0                	test   %eax,%eax
80104794:	0f 84 49 01 00 00    	je     801048e3 <sys_unlink+0x18f>
    end_op();
    return -1;
  }

  ilock(dp);
8010479a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010479d:	89 04 24             	mov    %eax,(%esp)
801047a0:	e8 33 ce ff ff       	call   801015d8 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801047a5:	c7 44 24 04 30 6f 10 	movl   $0x80106f30,0x4(%esp)
801047ac:	80 
801047ad:	89 1c 24             	mov    %ebx,(%esp)
801047b0:	e8 2f d3 ff ff       	call   80101ae4 <namecmp>
801047b5:	85 c0                	test   %eax,%eax
801047b7:	0f 84 1b 01 00 00    	je     801048d8 <sys_unlink+0x184>
801047bd:	c7 44 24 04 2f 6f 10 	movl   $0x80106f2f,0x4(%esp)
801047c4:	80 
801047c5:	89 1c 24             	mov    %ebx,(%esp)
801047c8:	e8 17 d3 ff ff       	call   80101ae4 <namecmp>
801047cd:	85 c0                	test   %eax,%eax
801047cf:	0f 84 03 01 00 00    	je     801048d8 <sys_unlink+0x184>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801047d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801047d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801047dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801047e0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801047e3:	89 04 24             	mov    %eax,(%esp)
801047e6:	e8 1d d3 ff ff       	call   80101b08 <dirlookup>
801047eb:	89 c6                	mov    %eax,%esi
801047ed:	85 c0                	test   %eax,%eax
801047ef:	0f 84 e3 00 00 00    	je     801048d8 <sys_unlink+0x184>
    goto bad;
  ilock(ip);
801047f5:	89 04 24             	mov    %eax,(%esp)
801047f8:	e8 db cd ff ff       	call   801015d8 <ilock>

  if(ip->nlink < 1)
801047fd:	66 83 7e 56 00       	cmpw   $0x0,0x56(%esi)
80104802:	0f 8e 1a 01 00 00    	jle    80104922 <sys_unlink+0x1ce>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
80104808:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010480d:	74 7d                	je     8010488c <sys_unlink+0x138>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
8010480f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104816:	00 
80104817:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010481e:	00 
8010481f:	8d 5d b2             	lea    -0x4e(%ebp),%ebx
80104822:	89 1c 24             	mov    %ebx,(%esp)
80104825:	e8 ae f6 ff ff       	call   80103ed8 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010482a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80104831:	00 
80104832:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104835:	89 44 24 08          	mov    %eax,0x8(%esp)
80104839:	89 5c 24 04          	mov    %ebx,0x4(%esp)
8010483d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80104840:	89 04 24             	mov    %eax,(%esp)
80104843:	e8 58 d1 ff ff       	call   801019a0 <writei>
80104848:	83 f8 10             	cmp    $0x10,%eax
8010484b:	0f 85 dd 00 00 00    	jne    8010492e <sys_unlink+0x1da>
    panic("unlink: writei");
  if(ip->type == T_DIR){
80104851:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104856:	0f 84 9c 00 00 00    	je     801048f8 <sys_unlink+0x1a4>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
8010485c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010485f:	89 04 24             	mov    %eax,(%esp)
80104862:	e8 c1 cf ff ff       	call   80101828 <iunlockput>

  ip->nlink--;
80104867:	66 ff 4e 56          	decw   0x56(%esi)
  iupdate(ip);
8010486b:	89 34 24             	mov    %esi,(%esp)
8010486e:	e8 ad cc ff ff       	call   80101520 <iupdate>
  iunlockput(ip);
80104873:	89 34 24             	mov    %esi,(%esp)
80104876:	e8 ad cf ff ff       	call   80101828 <iunlockput>

  end_op();
8010487b:	e8 b0 e0 ff ff       	call   80102930 <end_op>

  return 0;
80104880:	31 c0                	xor    %eax,%eax

bad:
  iunlockput(dp);
  end_op();
  return -1;
}
80104882:	83 c4 6c             	add    $0x6c,%esp
80104885:	5b                   	pop    %ebx
80104886:	5e                   	pop    %esi
80104887:	5f                   	pop    %edi
80104888:	5d                   	pop    %ebp
80104889:	c3                   	ret    
8010488a:	66 90                	xchg   %ax,%ax
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010488c:	83 7e 58 20          	cmpl   $0x20,0x58(%esi)
80104890:	0f 86 79 ff ff ff    	jbe    8010480f <sys_unlink+0xbb>
80104896:	bb 20 00 00 00       	mov    $0x20,%ebx
8010489b:	8d 7d c2             	lea    -0x3e(%ebp),%edi
8010489e:	eb 0c                	jmp    801048ac <sys_unlink+0x158>
801048a0:	83 c3 10             	add    $0x10,%ebx
801048a3:	3b 5e 58             	cmp    0x58(%esi),%ebx
801048a6:	0f 83 63 ff ff ff    	jae    8010480f <sys_unlink+0xbb>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801048ac:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801048b3:	00 
801048b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801048b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
801048bc:	89 34 24             	mov    %esi,(%esp)
801048bf:	e8 b0 cf ff ff       	call   80101874 <readi>
801048c4:	83 f8 10             	cmp    $0x10,%eax
801048c7:	75 4d                	jne    80104916 <sys_unlink+0x1c2>
      panic("isdirempty: readi");
    if(de.inum != 0)
801048c9:	66 83 7d c2 00       	cmpw   $0x0,-0x3e(%ebp)
801048ce:	74 d0                	je     801048a0 <sys_unlink+0x14c>
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
801048d0:	89 34 24             	mov    %esi,(%esp)
801048d3:	e8 50 cf ff ff       	call   80101828 <iunlockput>
  end_op();

  return 0;

bad:
  iunlockput(dp);
801048d8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801048db:	89 04 24             	mov    %eax,(%esp)
801048de:	e8 45 cf ff ff       	call   80101828 <iunlockput>
  end_op();
801048e3:	e8 48 e0 ff ff       	call   80102930 <end_op>
  return -1;
801048e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801048ed:	83 c4 6c             	add    $0x6c,%esp
801048f0:	5b                   	pop    %ebx
801048f1:	5e                   	pop    %esi
801048f2:	5f                   	pop    %edi
801048f3:	5d                   	pop    %ebp
801048f4:	c3                   	ret    
801048f5:	8d 76 00             	lea    0x0(%esi),%esi

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
801048f8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801048fb:	66 ff 48 56          	decw   0x56(%eax)
    iupdate(dp);
801048ff:	89 04 24             	mov    %eax,(%esp)
80104902:	e8 19 cc ff ff       	call   80101520 <iupdate>
80104907:	e9 50 ff ff ff       	jmp    8010485c <sys_unlink+0x108>
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
    return -1;
8010490c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104911:	e9 6c ff ff ff       	jmp    80104882 <sys_unlink+0x12e>
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
80104916:	c7 04 24 60 6f 10 80 	movl   $0x80106f60,(%esp)
8010491d:	e8 fa b9 ff ff       	call   8010031c <panic>
  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
80104922:	c7 04 24 4e 6f 10 80 	movl   $0x80106f4e,(%esp)
80104929:	e8 ee b9 ff ff       	call   8010031c <panic>
    goto bad;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
8010492e:	c7 04 24 72 6f 10 80 	movl   $0x80106f72,(%esp)
80104935:	e8 e2 b9 ff ff       	call   8010031c <panic>
8010493a:	66 90                	xchg   %ax,%ax

8010493c <sys_open>:
  return ip;
}

int
sys_open(void)
{
8010493c:	55                   	push   %ebp
8010493d:	89 e5                	mov    %esp,%ebp
8010493f:	56                   	push   %esi
80104940:	53                   	push   %ebx
80104941:	83 ec 30             	sub    $0x30,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104944:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104947:	89 44 24 04          	mov    %eax,0x4(%esp)
8010494b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104952:	e8 65 f8 ff ff       	call   801041bc <argstr>
80104957:	85 c0                	test   %eax,%eax
80104959:	0f 88 e9 00 00 00    	js     80104a48 <sys_open+0x10c>
8010495f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104962:	89 44 24 04          	mov    %eax,0x4(%esp)
80104966:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010496d:	e8 ca f7 ff ff       	call   8010413c <argint>
80104972:	85 c0                	test   %eax,%eax
80104974:	0f 88 ce 00 00 00    	js     80104a48 <sys_open+0x10c>
    return -1;

  begin_op();
8010497a:	e8 51 df ff ff       	call   801028d0 <begin_op>

  if(omode & O_CREATE){
8010497f:	f6 45 f5 02          	testb  $0x2,-0xb(%ebp)
80104983:	75 7b                	jne    80104a00 <sys_open+0xc4>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
80104985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104988:	89 04 24             	mov    %eax,(%esp)
8010498b:	e8 78 d4 ff ff       	call   80101e08 <namei>
80104990:	89 c6                	mov    %eax,%esi
80104992:	85 c0                	test   %eax,%eax
80104994:	0f 84 82 00 00 00    	je     80104a1c <sys_open+0xe0>
      end_op();
      return -1;
    }
    ilock(ip);
8010499a:	89 04 24             	mov    %eax,(%esp)
8010499d:	e8 36 cc ff ff       	call   801015d8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801049a2:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801049a7:	74 7f                	je     80104a28 <sys_open+0xec>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801049a9:	e8 ba c2 ff ff       	call   80100c68 <filealloc>
801049ae:	89 c3                	mov    %eax,%ebx
801049b0:	85 c0                	test   %eax,%eax
801049b2:	0f 84 a0 00 00 00    	je     80104a58 <sys_open+0x11c>
801049b8:	e8 9b f8 ff ff       	call   80104258 <fdalloc>
801049bd:	85 c0                	test   %eax,%eax
801049bf:	0f 88 8b 00 00 00    	js     80104a50 <sys_open+0x114>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801049c5:	89 34 24             	mov    %esi,(%esp)
801049c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801049cb:	e8 d8 cc ff ff       	call   801016a8 <iunlock>
  end_op();
801049d0:	e8 5b df ff ff       	call   80102930 <end_op>

  f->type = FD_INODE;
801049d5:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801049db:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801049de:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
801049e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049e8:	f6 c2 01             	test   $0x1,%dl
801049eb:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801049ef:	83 e2 03             	and    $0x3,%edx
801049f2:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
801049f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
801049f9:	83 c4 30             	add    $0x30,%esp
801049fc:	5b                   	pop    %ebx
801049fd:	5e                   	pop    %esi
801049fe:	5d                   	pop    %ebp
801049ff:	c3                   	ret    
    return -1;

  begin_op();

  if(omode & O_CREATE){
    ip = create(path, T_FILE, 0, 0);
80104a00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104a07:	31 c9                	xor    %ecx,%ecx
80104a09:	ba 02 00 00 00       	mov    $0x2,%edx
80104a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a11:	e8 7a f8 ff ff       	call   80104290 <create>
80104a16:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104a18:	85 c0                	test   %eax,%eax
80104a1a:	75 8d                	jne    801049a9 <sys_open+0x6d>

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
    iunlockput(ip);
    end_op();
80104a1c:	e8 0f df ff ff       	call   80102930 <end_op>
    return -1;
80104a21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a26:	eb d1                	jmp    801049f9 <sys_open+0xbd>
    if((ip = namei(path)) == 0){
      end_op();
      return -1;
    }
    ilock(ip);
    if(ip->type == T_DIR && omode != O_RDONLY){
80104a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2b:	85 c0                	test   %eax,%eax
80104a2d:	0f 84 76 ff ff ff    	je     801049a9 <sys_open+0x6d>
      iunlockput(ip);
80104a33:	89 34 24             	mov    %esi,(%esp)
80104a36:	e8 ed cd ff ff       	call   80101828 <iunlockput>
      end_op();
80104a3b:	e8 f0 de ff ff       	call   80102930 <end_op>
      return -1;
80104a40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a45:	eb b2                	jmp    801049f9 <sys_open+0xbd>
80104a47:	90                   	nop
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
    return -1;
80104a48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a4d:	eb aa                	jmp    801049f9 <sys_open+0xbd>
80104a4f:	90                   	nop
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
80104a50:	89 1c 24             	mov    %ebx,(%esp)
80104a53:	e8 c0 c2 ff ff       	call   80100d18 <fileclose>
    iunlockput(ip);
80104a58:	89 34 24             	mov    %esi,(%esp)
80104a5b:	e8 c8 cd ff ff       	call   80101828 <iunlockput>
80104a60:	eb ba                	jmp    80104a1c <sys_open+0xe0>
80104a62:	66 90                	xchg   %ax,%ax

80104a64 <sys_mkdir>:
  return fd;
}

int
sys_mkdir(void)
{
80104a64:	55                   	push   %ebp
80104a65:	89 e5                	mov    %esp,%ebp
80104a67:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104a6a:	e8 61 de ff ff       	call   801028d0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104a6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a72:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104a7d:	e8 3a f7 ff ff       	call   801041bc <argstr>
80104a82:	85 c0                	test   %eax,%eax
80104a84:	78 2e                	js     80104ab4 <sys_mkdir+0x50>
80104a86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104a8d:	31 c9                	xor    %ecx,%ecx
80104a8f:	ba 01 00 00 00       	mov    $0x1,%edx
80104a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a97:	e8 f4 f7 ff ff       	call   80104290 <create>
80104a9c:	85 c0                	test   %eax,%eax
80104a9e:	74 14                	je     80104ab4 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104aa0:	89 04 24             	mov    %eax,(%esp)
80104aa3:	e8 80 cd ff ff       	call   80101828 <iunlockput>
  end_op();
80104aa8:	e8 83 de ff ff       	call   80102930 <end_op>
  return 0;
80104aad:	31 c0                	xor    %eax,%eax
}
80104aaf:	c9                   	leave  
80104ab0:	c3                   	ret    
80104ab1:	8d 76 00             	lea    0x0(%esi),%esi
  char *path;
  struct inode *ip;

  begin_op();
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    end_op();
80104ab4:	e8 77 de ff ff       	call   80102930 <end_op>
    return -1;
80104ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  iunlockput(ip);
  end_op();
  return 0;
}
80104abe:	c9                   	leave  
80104abf:	c3                   	ret    

80104ac0 <sys_mknod>:

int
sys_mknod(void)
{
80104ac0:	55                   	push   %ebp
80104ac1:	89 e5                	mov    %esp,%ebp
80104ac3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104ac6:	e8 05 de ff ff       	call   801028d0 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104acb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ace:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ad2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104ad9:	e8 de f6 ff ff       	call   801041bc <argstr>
80104ade:	85 c0                	test   %eax,%eax
80104ae0:	78 5e                	js     80104b40 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80104ae2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ae9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104af0:	e8 47 f6 ff ff       	call   8010413c <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80104af5:	85 c0                	test   %eax,%eax
80104af7:	78 47                	js     80104b40 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80104af9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104afc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b00:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80104b07:	e8 30 f6 ff ff       	call   8010413c <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80104b0c:	85 c0                	test   %eax,%eax
80104b0e:	78 30                	js     80104b40 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80104b10:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
80104b14:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
80104b18:	89 04 24             	mov    %eax,(%esp)
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80104b1b:	ba 03 00 00 00       	mov    $0x3,%edx
80104b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b23:	e8 68 f7 ff ff       	call   80104290 <create>
80104b28:	85 c0                	test   %eax,%eax
80104b2a:	74 14                	je     80104b40 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
    return -1;
  }
  iunlockput(ip);
80104b2c:	89 04 24             	mov    %eax,(%esp)
80104b2f:	e8 f4 cc ff ff       	call   80101828 <iunlockput>
  end_op();
80104b34:	e8 f7 dd ff ff       	call   80102930 <end_op>
  return 0;
80104b39:	31 c0                	xor    %eax,%eax
}
80104b3b:	c9                   	leave  
80104b3c:	c3                   	ret    
80104b3d:	8d 76 00             	lea    0x0(%esi),%esi
  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80104b40:	e8 eb dd ff ff       	call   80102930 <end_op>
    return -1;
80104b45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  iunlockput(ip);
  end_op();
  return 0;
}
80104b4a:	c9                   	leave  
80104b4b:	c3                   	ret    

80104b4c <sys_chdir>:

int
sys_chdir(void)
{
80104b4c:	55                   	push   %ebp
80104b4d:	89 e5                	mov    %esp,%ebp
80104b4f:	56                   	push   %esi
80104b50:	53                   	push   %ebx
80104b51:	83 ec 20             	sub    $0x20,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104b54:	e8 5f e8 ff ff       	call   801033b8 <myproc>
80104b59:	89 c3                	mov    %eax,%ebx
  
  begin_op();
80104b5b:	e8 70 dd ff ff       	call   801028d0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104b60:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b63:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104b6e:	e8 49 f6 ff ff       	call   801041bc <argstr>
80104b73:	85 c0                	test   %eax,%eax
80104b75:	78 4a                	js     80104bc1 <sys_chdir+0x75>
80104b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7a:	89 04 24             	mov    %eax,(%esp)
80104b7d:	e8 86 d2 ff ff       	call   80101e08 <namei>
80104b82:	89 c6                	mov    %eax,%esi
80104b84:	85 c0                	test   %eax,%eax
80104b86:	74 39                	je     80104bc1 <sys_chdir+0x75>
    end_op();
    return -1;
  }
  ilock(ip);
80104b88:	89 04 24             	mov    %eax,(%esp)
80104b8b:	e8 48 ca ff ff       	call   801015d8 <ilock>
  if(ip->type != T_DIR){
80104b90:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
    iunlockput(ip);
80104b95:	89 34 24             	mov    %esi,(%esp)
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  ilock(ip);
  if(ip->type != T_DIR){
80104b98:	75 22                	jne    80104bbc <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b9a:	e8 09 cb ff ff       	call   801016a8 <iunlock>
  iput(curproc->cwd);
80104b9f:	8b 43 68             	mov    0x68(%ebx),%eax
80104ba2:	89 04 24             	mov    %eax,(%esp)
80104ba5:	e8 3e cb ff ff       	call   801016e8 <iput>
  end_op();
80104baa:	e8 81 dd ff ff       	call   80102930 <end_op>
  curproc->cwd = ip;
80104baf:	89 73 68             	mov    %esi,0x68(%ebx)
  return 0;
80104bb2:	31 c0                	xor    %eax,%eax
}
80104bb4:	83 c4 20             	add    $0x20,%esp
80104bb7:	5b                   	pop    %ebx
80104bb8:	5e                   	pop    %esi
80104bb9:	5d                   	pop    %ebp
80104bba:	c3                   	ret    
80104bbb:	90                   	nop
    end_op();
    return -1;
  }
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
80104bbc:	e8 67 cc ff ff       	call   80101828 <iunlockput>
    end_op();
80104bc1:	e8 6a dd ff ff       	call   80102930 <end_op>
    return -1;
80104bc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  iunlock(ip);
  iput(curproc->cwd);
  end_op();
  curproc->cwd = ip;
  return 0;
}
80104bcb:	83 c4 20             	add    $0x20,%esp
80104bce:	5b                   	pop    %ebx
80104bcf:	5e                   	pop    %esi
80104bd0:	5d                   	pop    %ebp
80104bd1:	c3                   	ret    
80104bd2:	66 90                	xchg   %ax,%ax

80104bd4 <sys_exec>:

int
sys_exec(void)
{
80104bd4:	55                   	push   %ebp
80104bd5:	89 e5                	mov    %esp,%ebp
80104bd7:	57                   	push   %edi
80104bd8:	56                   	push   %esi
80104bd9:	53                   	push   %ebx
80104bda:	81 ec ac 00 00 00    	sub    $0xac,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104be0:	8d 45 dc             	lea    -0x24(%ebp),%eax
80104be3:	89 44 24 04          	mov    %eax,0x4(%esp)
80104be7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104bee:	e8 c9 f5 ff ff       	call   801041bc <argstr>
80104bf3:	85 c0                	test   %eax,%eax
80104bf5:	78 78                	js     80104c6f <sys_exec+0x9b>
80104bf7:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bfe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104c05:	e8 32 f5 ff ff       	call   8010413c <argint>
80104c0a:	85 c0                	test   %eax,%eax
80104c0c:	78 61                	js     80104c6f <sys_exec+0x9b>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104c0e:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80104c15:	00 
80104c16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104c1d:	00 
80104c1e:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
80104c24:	89 3c 24             	mov    %edi,(%esp)
80104c27:	e8 ac f2 ff ff       	call   80103ed8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv))
80104c2c:	31 f6                	xor    %esi,%esi

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80104c2e:	31 db                	xor    %ebx,%ebx
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104c30:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  curproc->cwd = ip;
  return 0;
}

int
sys_exec(void)
80104c37:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104c3e:	03 45 e0             	add    -0x20(%ebp),%eax
80104c41:	89 04 24             	mov    %eax,(%esp)
80104c44:	e8 7b f4 ff ff       	call   801040c4 <fetchint>
80104c49:	85 c0                	test   %eax,%eax
80104c4b:	78 22                	js     80104c6f <sys_exec+0x9b>
      return -1;
    if(uarg == 0){
80104c4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104c50:	85 c0                	test   %eax,%eax
80104c52:	74 2c                	je     80104c80 <sys_exec+0xac>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104c54:	8d 14 b7             	lea    (%edi,%esi,4),%edx
80104c57:	89 54 24 04          	mov    %edx,0x4(%esp)
80104c5b:	89 04 24             	mov    %eax,(%esp)
80104c5e:	e8 91 f4 ff ff       	call   801040f4 <fetchstr>
80104c63:	85 c0                	test   %eax,%eax
80104c65:	78 08                	js     80104c6f <sys_exec+0x9b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80104c67:	43                   	inc    %ebx
    if(i >= NELEM(argv))
80104c68:	89 de                	mov    %ebx,%esi
80104c6a:	83 fb 20             	cmp    $0x20,%ebx
80104c6d:	75 c1                	jne    80104c30 <sys_exec+0x5c>
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
80104c6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return exec(path, argv);
}
80104c74:	81 c4 ac 00 00 00    	add    $0xac,%esp
80104c7a:	5b                   	pop    %ebx
80104c7b:	5e                   	pop    %esi
80104c7c:	5f                   	pop    %edi
80104c7d:	5d                   	pop    %ebp
80104c7e:	c3                   	ret    
80104c7f:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104c80:	c7 84 9d 5c ff ff ff 	movl   $0x0,-0xa4(%ebp,%ebx,4)
80104c87:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104c8b:	89 7c 24 04          	mov    %edi,0x4(%esp)
80104c8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104c92:	89 04 24             	mov    %eax,(%esp)
80104c95:	e8 3a bc ff ff       	call   801008d4 <exec>
}
80104c9a:	81 c4 ac 00 00 00    	add    $0xac,%esp
80104ca0:	5b                   	pop    %ebx
80104ca1:	5e                   	pop    %esi
80104ca2:	5f                   	pop    %edi
80104ca3:	5d                   	pop    %ebp
80104ca4:	c3                   	ret    
80104ca5:	8d 76 00             	lea    0x0(%esi),%esi

80104ca8 <sys_pipe>:

int
sys_pipe(void)
{
80104ca8:	55                   	push   %ebp
80104ca9:	89 e5                	mov    %esp,%ebp
80104cab:	53                   	push   %ebx
80104cac:	83 ec 24             	sub    $0x24,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104caf:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80104cb6:	00 
80104cb7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104cba:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104cc5:	e8 9a f4 ff ff       	call   80104164 <argptr>
80104cca:	85 c0                	test   %eax,%eax
80104ccc:	78 46                	js     80104d14 <sys_pipe+0x6c>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104cce:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cd5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cd8:	89 04 24             	mov    %eax,(%esp)
80104cdb:	e8 b4 e1 ff ff       	call   80102e94 <pipealloc>
80104ce0:	85 c0                	test   %eax,%eax
80104ce2:	78 30                	js     80104d14 <sys_pipe+0x6c>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ce7:	e8 6c f5 ff ff       	call   80104258 <fdalloc>
80104cec:	89 c3                	mov    %eax,%ebx
80104cee:	85 c0                	test   %eax,%eax
80104cf0:	78 37                	js     80104d29 <sys_pipe+0x81>
80104cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf5:	e8 5e f5 ff ff       	call   80104258 <fdalloc>
80104cfa:	85 c0                	test   %eax,%eax
80104cfc:	78 1e                	js     80104d1c <sys_pipe+0x74>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104cfe:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d01:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104d03:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d06:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104d09:	31 c0                	xor    %eax,%eax
}
80104d0b:	83 c4 24             	add    $0x24,%esp
80104d0e:	5b                   	pop    %ebx
80104d0f:	5d                   	pop    %ebp
80104d10:	c3                   	ret    
80104d11:	8d 76 00             	lea    0x0(%esi),%esi
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
    return -1;
80104d14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d19:	eb f0                	jmp    80104d0b <sys_pipe+0x63>
80104d1b:	90                   	nop
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
80104d1c:	e8 97 e6 ff ff       	call   801033b8 <myproc>
80104d21:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104d28:	00 
    fileclose(rf);
80104d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d2c:	89 04 24             	mov    %eax,(%esp)
80104d2f:	e8 e4 bf ff ff       	call   80100d18 <fileclose>
    fileclose(wf);
80104d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d37:	89 04 24             	mov    %eax,(%esp)
80104d3a:	e8 d9 bf ff ff       	call   80100d18 <fileclose>
    return -1;
80104d3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d44:	eb c5                	jmp    80104d0b <sys_pipe+0x63>
	...

80104d48 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104d48:	55                   	push   %ebp
80104d49:	89 e5                	mov    %esp,%ebp
  return fork();
}
80104d4b:	5d                   	pop    %ebp
#include "proc.h"

int
sys_fork(void)
{
  return fork();
80104d4c:	e9 ef e7 ff ff       	jmp    80103540 <fork>
80104d51:	8d 76 00             	lea    0x0(%esi),%esi

80104d54 <sys_exit>:
}

int
sys_exit(void)
{
80104d54:	55                   	push   %ebp
80104d55:	89 e5                	mov    %esp,%ebp
80104d57:	83 ec 08             	sub    $0x8,%esp
  exit();
80104d5a:	e8 29 ea ff ff       	call   80103788 <exit>
  return 0;  // not reached
}
80104d5f:	31 c0                	xor    %eax,%eax
80104d61:	c9                   	leave  
80104d62:	c3                   	ret    
80104d63:	90                   	nop

80104d64 <sys_wait>:

int
sys_wait(void)
{
80104d64:	55                   	push   %ebp
80104d65:	89 e5                	mov    %esp,%ebp
  return wait();
}
80104d67:	5d                   	pop    %ebp
}

int
sys_wait(void)
{
  return wait();
80104d68:	e9 0b ec ff ff       	jmp    80103978 <wait>
80104d6d:	8d 76 00             	lea    0x0(%esi),%esi

80104d70 <sys_kill>:
}

int
sys_kill(void)
{
80104d70:	55                   	push   %ebp
80104d71:	89 e5                	mov    %esp,%ebp
80104d73:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104d76:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d79:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104d84:	e8 b3 f3 ff ff       	call   8010413c <argint>
80104d89:	85 c0                	test   %eax,%eax
80104d8b:	78 0f                	js     80104d9c <sys_kill+0x2c>
    return -1;
  return kill(pid);
80104d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d90:	89 04 24             	mov    %eax,(%esp)
80104d93:	e8 1c ed ff ff       	call   80103ab4 <kill>
}
80104d98:	c9                   	leave  
80104d99:	c3                   	ret    
80104d9a:	66 90                	xchg   %ax,%ax
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
80104d9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return kill(pid);
}
80104da1:	c9                   	leave  
80104da2:	c3                   	ret    
80104da3:	90                   	nop

80104da4 <sys_getpid>:

int
sys_getpid(void)
{
80104da4:	55                   	push   %ebp
80104da5:	89 e5                	mov    %esp,%ebp
80104da7:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104daa:	e8 09 e6 ff ff       	call   801033b8 <myproc>
80104daf:	8b 40 10             	mov    0x10(%eax),%eax
}
80104db2:	c9                   	leave  
80104db3:	c3                   	ret    

80104db4 <sys_sbrk>:

int
sys_sbrk(void)
{
80104db4:	55                   	push   %ebp
80104db5:	89 e5                	mov    %esp,%ebp
80104db7:	53                   	push   %ebx
80104db8:	83 ec 24             	sub    $0x24,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104dbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104dc9:	e8 6e f3 ff ff       	call   8010413c <argint>
80104dce:	85 c0                	test   %eax,%eax
80104dd0:	78 1a                	js     80104dec <sys_sbrk+0x38>
    return -1;
  addr = myproc()->sz;
80104dd2:	e8 e1 e5 ff ff       	call   801033b8 <myproc>
80104dd7:	8b 18                	mov    (%eax),%ebx
  
/*  if(growproc(n) < 0)
    return -1;		*/
  myproc()->sz += n;  
80104dd9:	e8 da e5 ff ff       	call   801033b8 <myproc>
80104dde:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104de1:	01 10                	add    %edx,(%eax)
  return addr;
}
80104de3:	89 d8                	mov    %ebx,%eax
80104de5:	83 c4 24             	add    $0x24,%esp
80104de8:	5b                   	pop    %ebx
80104de9:	5d                   	pop    %ebp
80104dea:	c3                   	ret    
80104deb:	90                   	nop
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
80104dec:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104df1:	eb f0                	jmp    80104de3 <sys_sbrk+0x2f>
80104df3:	90                   	nop

80104df4 <sys_sleep>:
  return addr;
}

int
sys_sleep(void)
{
80104df4:	55                   	push   %ebp
80104df5:	89 e5                	mov    %esp,%ebp
80104df7:	53                   	push   %ebx
80104df8:	83 ec 24             	sub    $0x24,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104dfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104e09:	e8 2e f3 ff ff       	call   8010413c <argint>
80104e0e:	85 c0                	test   %eax,%eax
80104e10:	78 76                	js     80104e88 <sys_sleep+0x94>
    return -1;
  acquire(&tickslock);
80104e12:	c7 04 24 60 4f 11 80 	movl   $0x80114f60,(%esp)
80104e19:	e8 0e f0 ff ff       	call   80103e2c <acquire>
  ticks0 = ticks;
80104e1e:	8b 1d a0 57 11 80    	mov    0x801157a0,%ebx
  while(ticks - ticks0 < n){
80104e24:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e27:	85 d2                	test   %edx,%edx
80104e29:	75 25                	jne    80104e50 <sys_sleep+0x5c>
80104e2b:	eb 47                	jmp    80104e74 <sys_sleep+0x80>
80104e2d:	8d 76 00             	lea    0x0(%esi),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104e30:	c7 44 24 04 60 4f 11 	movl   $0x80114f60,0x4(%esp)
80104e37:	80 
80104e38:	c7 04 24 a0 57 11 80 	movl   $0x801157a0,(%esp)
80104e3f:	e8 90 ea ff ff       	call   801038d4 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80104e44:	a1 a0 57 11 80       	mov    0x801157a0,%eax
80104e49:	29 d8                	sub    %ebx,%eax
80104e4b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104e4e:	73 24                	jae    80104e74 <sys_sleep+0x80>
    if(myproc()->killed){
80104e50:	e8 63 e5 ff ff       	call   801033b8 <myproc>
80104e55:	8b 40 24             	mov    0x24(%eax),%eax
80104e58:	85 c0                	test   %eax,%eax
80104e5a:	74 d4                	je     80104e30 <sys_sleep+0x3c>
      release(&tickslock);
80104e5c:	c7 04 24 60 4f 11 80 	movl   $0x80114f60,(%esp)
80104e63:	e8 28 f0 ff ff       	call   80103e90 <release>
      return -1;
80104e68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}
80104e6d:	83 c4 24             	add    $0x24,%esp
80104e70:	5b                   	pop    %ebx
80104e71:	5d                   	pop    %ebp
80104e72:	c3                   	ret    
80104e73:	90                   	nop
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80104e74:	c7 04 24 60 4f 11 80 	movl   $0x80114f60,(%esp)
80104e7b:	e8 10 f0 ff ff       	call   80103e90 <release>
  return 0;
80104e80:	31 c0                	xor    %eax,%eax
}
80104e82:	83 c4 24             	add    $0x24,%esp
80104e85:	5b                   	pop    %ebx
80104e86:	5d                   	pop    %ebp
80104e87:	c3                   	ret    
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
80104e88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e8d:	eb de                	jmp    80104e6d <sys_sleep+0x79>
80104e8f:	90                   	nop

80104e90 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104e90:	55                   	push   %ebp
80104e91:	89 e5                	mov    %esp,%ebp
80104e93:	53                   	push   %ebx
80104e94:	83 ec 14             	sub    $0x14,%esp
  uint xticks;

  acquire(&tickslock);
80104e97:	c7 04 24 60 4f 11 80 	movl   $0x80114f60,(%esp)
80104e9e:	e8 89 ef ff ff       	call   80103e2c <acquire>
  xticks = ticks;
80104ea3:	8b 1d a0 57 11 80    	mov    0x801157a0,%ebx
  release(&tickslock);
80104ea9:	c7 04 24 60 4f 11 80 	movl   $0x80114f60,(%esp)
80104eb0:	e8 db ef ff ff       	call   80103e90 <release>
  return xticks;
}
80104eb5:	89 d8                	mov    %ebx,%eax
80104eb7:	83 c4 14             	add    $0x14,%esp
80104eba:	5b                   	pop    %ebx
80104ebb:	5d                   	pop    %ebp
80104ebc:	c3                   	ret    
80104ebd:	8d 76 00             	lea    0x0(%esi),%esi

80104ec0 <sys_date>:

// Date system call
int 
sys_date(struct rtcdate *r)
{
80104ec0:	55                   	push   %ebp
80104ec1:	89 e5                	mov    %esp,%ebp
80104ec3:	83 ec 18             	sub    $0x18,%esp
  if (argptr(0,(void *)&r, sizeof(*r)) <0)
80104ec6:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80104ecd:	00 
80104ece:	8d 45 08             	lea    0x8(%ebp),%eax
80104ed1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ed5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104edc:	e8 83 f2 ff ff       	call   80104164 <argptr>
80104ee1:	85 c0                	test   %eax,%eax
80104ee3:	78 0f                	js     80104ef4 <sys_date+0x34>
	return -1;
	cmostime(r);
80104ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee8:	89 04 24             	mov    %eax,(%esp)
80104eeb:	e8 a4 d6 ff ff       	call   80102594 <cmostime>
	return 0;
80104ef0:	31 c0                	xor    %eax,%eax
}
80104ef2:	c9                   	leave  
80104ef3:	c3                   	ret    
// Date system call
int 
sys_date(struct rtcdate *r)
{
  if (argptr(0,(void *)&r, sizeof(*r)) <0)
	return -1;
80104ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	cmostime(r);
	return 0;
}
80104ef9:	c9                   	leave  
80104efa:	c3                   	ret    
80104efb:	90                   	nop

80104efc <sys_alarm>:

//Homework: xv6 CPU alarm
int
sys_alarm(void)
{
80104efc:	55                   	push   %ebp
80104efd:	89 e5                	mov    %esp,%ebp
80104eff:	83 ec 28             	sub    $0x28,%esp
  int ticks;
  void (*handler)();

  if(argint(0, &ticks) < 0)
80104f02:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f05:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104f10:	e8 27 f2 ff ff       	call   8010413c <argint>
80104f15:	85 c0                	test   %eax,%eax
80104f17:	78 3f                	js     80104f58 <sys_alarm+0x5c>
    return -1;
  if(argptr(1, (char**)&handler, 1) < 0)
80104f19:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80104f20:	00 
80104f21:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f24:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f28:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104f2f:	e8 30 f2 ff ff       	call   80104164 <argptr>
80104f34:	85 c0                	test   %eax,%eax
80104f36:	78 20                	js     80104f58 <sys_alarm+0x5c>
    return -1;
  myproc()->alarmticks = ticks;
80104f38:	e8 7b e4 ff ff       	call   801033b8 <myproc>
80104f3d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f40:	89 50 7c             	mov    %edx,0x7c(%eax)
  myproc()->alarmhandler = handler;
80104f43:	e8 70 e4 ff ff       	call   801033b8 <myproc>
80104f48:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f4b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  return 0;
80104f51:	31 c0                	xor    %eax,%eax
}
80104f53:	c9                   	leave  
80104f54:	c3                   	ret    
80104f55:	8d 76 00             	lea    0x0(%esi),%esi
  void (*handler)();

  if(argint(0, &ticks) < 0)
    return -1;
  if(argptr(1, (char**)&handler, 1) < 0)
    return -1;
80104f58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  myproc()->alarmticks = ticks;
  myproc()->alarmhandler = handler;
  return 0;
}
80104f5d:	c9                   	leave  
80104f5e:	c3                   	ret    
	...

80104f60 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104f60:	1e                   	push   %ds
  pushl %es
80104f61:	06                   	push   %es
  pushl %fs
80104f62:	0f a0                	push   %fs
  pushl %gs
80104f64:	0f a8                	push   %gs
  pushal
80104f66:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104f67:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104f6b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104f6d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104f6f:	54                   	push   %esp
  call trap
80104f70:	e8 b7 00 00 00       	call   8010502c <trap>
  addl $4, %esp
80104f75:	83 c4 04             	add    $0x4,%esp

80104f78 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104f78:	61                   	popa   
  popl %gs
80104f79:	0f a9                	pop    %gs
  popl %fs
80104f7b:	0f a1                	pop    %fs
  popl %es
80104f7d:	07                   	pop    %es
  popl %ds
80104f7e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104f7f:	83 c4 08             	add    $0x8,%esp
  iret
80104f82:	cf                   	iret   
	...

80104f84 <tvinit>:
uint ticks;
int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm);

void
tvinit(void)
{
80104f84:	55                   	push   %ebp
80104f85:	89 e5                	mov    %esp,%ebp
80104f87:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80104f8a:	31 c0                	xor    %eax,%eax
80104f8c:	ba a0 4f 11 80       	mov    $0x80114fa0,%edx
80104f91:	8d 76 00             	lea    0x0(%esi),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104f94:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104f9b:	66 89 0c c5 a0 4f 11 	mov    %cx,-0x7feeb060(,%eax,8)
80104fa2:	80 
80104fa3:	66 c7 44 c2 02 08 00 	movw   $0x8,0x2(%edx,%eax,8)
80104faa:	c6 44 c2 04 00       	movb   $0x0,0x4(%edx,%eax,8)
80104faf:	c6 44 c2 05 8e       	movb   $0x8e,0x5(%edx,%eax,8)
80104fb4:	c1 e9 10             	shr    $0x10,%ecx
80104fb7:	66 89 4c c2 06       	mov    %cx,0x6(%edx,%eax,8)
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80104fbc:	40                   	inc    %eax
80104fbd:	3d 00 01 00 00       	cmp    $0x100,%eax
80104fc2:	75 d0                	jne    80104f94 <tvinit+0x10>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104fc4:	a1 08 a1 10 80       	mov    0x8010a108,%eax
80104fc9:	66 a3 a0 51 11 80    	mov    %ax,0x801151a0
80104fcf:	66 c7 05 a2 51 11 80 	movw   $0x8,0x801151a2
80104fd6:	08 00 
80104fd8:	c6 05 a4 51 11 80 00 	movb   $0x0,0x801151a4
80104fdf:	c6 05 a5 51 11 80 ef 	movb   $0xef,0x801151a5
80104fe6:	c1 e8 10             	shr    $0x10,%eax
80104fe9:	66 a3 a6 51 11 80    	mov    %ax,0x801151a6

  initlock(&tickslock, "time");
80104fef:	c7 44 24 04 81 6f 10 	movl   $0x80106f81,0x4(%esp)
80104ff6:	80 
80104ff7:	c7 04 24 60 4f 11 80 	movl   $0x80114f60,(%esp)
80104ffe:	e8 ed ec ff ff       	call   80103cf0 <initlock>
}
80105003:	c9                   	leave  
80105004:	c3                   	ret    
80105005:	8d 76 00             	lea    0x0(%esi),%esi

80105008 <idtinit>:

void
idtinit(void)
{
80105008:	55                   	push   %ebp
80105009:	89 e5                	mov    %esp,%ebp
8010500b:	83 ec 10             	sub    $0x10,%esp
static inline void
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
8010500e:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105014:	b8 a0 4f 11 80       	mov    $0x80114fa0,%eax
80105019:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010501d:	c1 e8 10             	shr    $0x10,%eax
80105020:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80105024:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105027:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
8010502a:	c9                   	leave  
8010502b:	c3                   	ret    

8010502c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010502c:	55                   	push   %ebp
8010502d:	89 e5                	mov    %esp,%ebp
8010502f:	57                   	push   %edi
80105030:	56                   	push   %esi
80105031:	53                   	push   %ebx
80105032:	83 ec 2c             	sub    $0x2c,%esp
80105035:	8b 7d 08             	mov    0x8(%ebp),%edi
  char *mem = kalloc();
80105038:	e8 8f d2 ff ff       	call   801022cc <kalloc>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010503d:	0f 20 d3             	mov    %cr2,%ebx
  uint addr = PGROUNDDOWN(rcr2());

  if(tf->trapno == T_SYSCALL){
80105040:	8b 47 30             	mov    0x30(%edi),%eax
80105043:	83 f8 40             	cmp    $0x40,%eax
80105046:	0f 84 00 02 00 00    	je     8010524c <trap+0x220>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
8010504c:	83 e8 20             	sub    $0x20,%eax
8010504f:	83 f8 1f             	cmp    $0x1f,%eax
80105052:	0f 86 f8 00 00 00    	jbe    80105150 <trap+0x124>
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80105058:	e8 5b e3 ff ff       	call   801033b8 <myproc>
8010505d:	85 c0                	test   %eax,%eax
8010505f:	0f 84 ee 02 00 00    	je     80105353 <trap+0x327>
80105065:	f6 47 3c 03          	testb  $0x3,0x3c(%edi)
80105069:	0f 84 e4 02 00 00    	je     80105353 <trap+0x327>
//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  char *mem = kalloc();
  uint addr = PGROUNDDOWN(rcr2());
8010506f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105075:	eb 64                	jmp    801050db <trap+0xaf>
80105077:	90                   	nop
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    //Page allocation and mapping
    for(; addr < myproc()->sz; addr += PGSIZE){
      mem = kalloc();
80105078:	e8 4f d2 ff ff       	call   801022cc <kalloc>
8010507d:	89 c6                	mov    %eax,%esi
      if(mem == 0){
8010507f:	85 c0                	test   %eax,%eax
80105081:	0f 84 01 02 00 00    	je     80105288 <trap+0x25c>
        cprintf("allocuvm out of memory\n");
        deallocuvm(myproc()->pgdir, myproc()->sz, myproc()->tf->eax);
        return ;
      }    
      memset(mem, 0, PGSIZE);
80105087:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010508e:	00 
8010508f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105096:	00 
80105097:	89 04 24             	mov    %eax,(%esp)
8010509a:	e8 39 ee ff ff       	call   80103ed8 <memset>
      if(mappages(myproc()->pgdir, (char *)addr, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010509f:	e8 14 e3 ff ff       	call   801033b8 <myproc>
801050a4:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801050ab:	00 
801050ac:	8d 96 00 00 00 80    	lea    -0x80000000(%esi),%edx
801050b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
801050b6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801050bd:	00 
801050be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801050c2:	8b 40 04             	mov    0x4(%eax),%eax
801050c5:	89 04 24             	mov    %eax,(%esp)
801050c8:	e8 9f 0f 00 00       	call   8010606c <mappages>
801050cd:	85 c0                	test   %eax,%eax
801050cf:	0f 88 ef 01 00 00    	js     801052c4 <trap+0x298>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    //Page allocation and mapping
    for(; addr < myproc()->sz; addr += PGSIZE){
801050d5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801050db:	e8 d8 e2 ff ff       	call   801033b8 <myproc>
801050e0:	3b 18                	cmp    (%eax),%ebx
801050e2:	72 94                	jb     80105078 <trap+0x4c>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801050e4:	e8 cf e2 ff ff       	call   801033b8 <myproc>
801050e9:	85 c0                	test   %eax,%eax
801050eb:	74 1c                	je     80105109 <trap+0xdd>
801050ed:	e8 c6 e2 ff ff       	call   801033b8 <myproc>
801050f2:	8b 50 24             	mov    0x24(%eax),%edx
801050f5:	85 d2                	test   %edx,%edx
801050f7:	74 10                	je     80105109 <trap+0xdd>
801050f9:	0f b7 47 3c          	movzwl 0x3c(%edi),%eax
801050fd:	83 e0 03             	and    $0x3,%eax
80105100:	83 f8 03             	cmp    $0x3,%eax
80105103:	0f 84 0f 02 00 00    	je     80105318 <trap+0x2ec>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105109:	e8 aa e2 ff ff       	call   801033b8 <myproc>
8010510e:	85 c0                	test   %eax,%eax
80105110:	74 0f                	je     80105121 <trap+0xf5>
80105112:	e8 a1 e2 ff ff       	call   801033b8 <myproc>
80105117:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
8010511b:	0f 84 17 01 00 00    	je     80105238 <trap+0x20c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105121:	e8 92 e2 ff ff       	call   801033b8 <myproc>
80105126:	85 c0                	test   %eax,%eax
80105128:	74 1c                	je     80105146 <trap+0x11a>
8010512a:	e8 89 e2 ff ff       	call   801033b8 <myproc>
8010512f:	8b 40 24             	mov    0x24(%eax),%eax
80105132:	85 c0                	test   %eax,%eax
80105134:	74 10                	je     80105146 <trap+0x11a>
80105136:	0f b7 47 3c          	movzwl 0x3c(%edi),%eax
8010513a:	83 e0 03             	and    $0x3,%eax
8010513d:	83 f8 03             	cmp    $0x3,%eax
80105140:	0f 84 33 01 00 00    	je     80105279 <trap+0x24d>
    exit();
}
80105146:	83 c4 2c             	add    $0x2c,%esp
80105149:	5b                   	pop    %ebx
8010514a:	5e                   	pop    %esi
8010514b:	5f                   	pop    %edi
8010514c:	5d                   	pop    %ebp
8010514d:	c3                   	ret    
8010514e:	66 90                	xchg   %ax,%ax
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105150:	ff 24 85 18 70 10 80 	jmp    *-0x7fef8fe8(,%eax,4)
80105157:	90                   	nop
    }

    break;
     
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80105158:	e8 f3 cd ff ff       	call   80101f50 <ideintr>
    lapiceoi();
8010515d:	e8 8a d3 ff ff       	call   801024ec <lapiceoi>
    break;
80105162:	eb 80                	jmp    801050e4 <trap+0xb8>
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105164:	8b 77 38             	mov    0x38(%edi),%esi
80105167:	0f b7 5f 3c          	movzwl 0x3c(%edi),%ebx
8010516b:	e8 14 e2 ff ff       	call   80103384 <cpuid>
80105170:	89 74 24 0c          	mov    %esi,0xc(%esp)
80105174:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80105178:	89 44 24 04          	mov    %eax,0x4(%esp)
8010517c:	c7 04 24 c0 6f 10 80 	movl   $0x80106fc0,(%esp)
80105183:	e8 34 b4 ff ff       	call   801005bc <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80105188:	e8 5f d3 ff ff       	call   801024ec <lapiceoi>
    break;
8010518d:	e9 52 ff ff ff       	jmp    801050e4 <trap+0xb8>
80105192:	66 90                	xchg   %ax,%ax
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80105194:	e8 f3 02 00 00       	call   8010548c <uartintr>
    lapiceoi();
80105199:	e8 4e d3 ff ff       	call   801024ec <lapiceoi>
    break;
8010519e:	e9 41 ff ff ff       	jmp    801050e4 <trap+0xb8>
801051a3:	90                   	nop
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801051a4:	e8 33 d2 ff ff       	call   801023dc <kbdintr>
    lapiceoi();
801051a9:	e8 3e d3 ff ff       	call   801024ec <lapiceoi>
    break;
801051ae:	e9 31 ff ff ff       	jmp    801050e4 <trap+0xb8>
801051b3:	90                   	nop
  }

  switch(tf->trapno){
    //xv6 CPU alarm
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801051b4:	e8 cb e1 ff ff       	call   80103384 <cpuid>
801051b9:	85 c0                	test   %eax,%eax
801051bb:	0f 84 63 01 00 00    	je     80105324 <trap+0x2f8>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }   
    lapiceoi(); 
801051c1:	e8 26 d3 ff ff       	call   801024ec <lapiceoi>
    //my code
    if(myproc() != 0 && (tf->cs&0x3) == 0x3){  
801051c6:	e8 ed e1 ff ff       	call   801033b8 <myproc>
801051cb:	85 c0                	test   %eax,%eax
801051cd:	0f 84 11 ff ff ff    	je     801050e4 <trap+0xb8>
801051d3:	0f b7 47 3c          	movzwl 0x3c(%edi),%eax
801051d7:	83 e0 03             	and    $0x3,%eax
801051da:	83 f8 03             	cmp    $0x3,%eax
801051dd:	0f 85 01 ff ff ff    	jne    801050e4 <trap+0xb8>
      myproc()->curalarmticks++;
801051e3:	e8 d0 e1 ff ff       	call   801033b8 <myproc>
801051e8:	ff 80 84 00 00 00    	incl   0x84(%eax)
      if(myproc()->curalarmticks == myproc()->alarmticks){
801051ee:	e8 c5 e1 ff ff       	call   801033b8 <myproc>
801051f3:	8b 98 84 00 00 00    	mov    0x84(%eax),%ebx
801051f9:	e8 ba e1 ff ff       	call   801033b8 <myproc>
801051fe:	3b 58 7c             	cmp    0x7c(%eax),%ebx
80105201:	0f 85 dd fe ff ff    	jne    801050e4 <trap+0xb8>
        myproc()->curalarmticks = 0;
80105207:	e8 ac e1 ff ff       	call   801033b8 <myproc>
8010520c:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80105213:	00 00 00 
	tf->esp -= 4;    
80105216:	8b 47 44             	mov    0x44(%edi),%eax
80105219:	8d 50 fc             	lea    -0x4(%eax),%edx
8010521c:	89 57 44             	mov    %edx,0x44(%edi)
        *((uint *)tf->esp) = tf->eip;
8010521f:	8b 57 38             	mov    0x38(%edi),%edx
80105222:	89 50 fc             	mov    %edx,-0x4(%eax)
        tf->eip =(uint) myproc()->alarmhandler;
80105225:	e8 8e e1 ff ff       	call   801033b8 <myproc>
8010522a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105230:	89 47 38             	mov    %eax,0x38(%edi)
80105233:	e9 ac fe ff ff       	jmp    801050e4 <trap+0xb8>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105238:	83 7f 30 20          	cmpl   $0x20,0x30(%edi)
8010523c:	0f 85 df fe ff ff    	jne    80105121 <trap+0xf5>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80105242:	e8 59 e6 ff ff       	call   801038a0 <yield>
80105247:	e9 d5 fe ff ff       	jmp    80105121 <trap+0xf5>
{
  char *mem = kalloc();
  uint addr = PGROUNDDOWN(rcr2());

  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
8010524c:	e8 67 e1 ff ff       	call   801033b8 <myproc>
80105251:	8b 58 24             	mov    0x24(%eax),%ebx
80105254:	85 db                	test   %ebx,%ebx
80105256:	0f 85 b0 00 00 00    	jne    8010530c <trap+0x2e0>
      exit();
    myproc()->tf = tf;
8010525c:	e8 57 e1 ff ff       	call   801033b8 <myproc>
80105261:	89 78 18             	mov    %edi,0x18(%eax)
    syscall();
80105264:	e8 8b ef ff ff       	call   801041f4 <syscall>
    if(myproc()->killed)
80105269:	e8 4a e1 ff ff       	call   801033b8 <myproc>
8010526e:	8b 48 24             	mov    0x24(%eax),%ecx
80105271:	85 c9                	test   %ecx,%ecx
80105273:	0f 84 cd fe ff ff    	je     80105146 <trap+0x11a>
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80105279:	83 c4 2c             	add    $0x2c,%esp
8010527c:	5b                   	pop    %ebx
8010527d:	5e                   	pop    %esi
8010527e:	5f                   	pop    %edi
8010527f:	5d                   	pop    %ebp
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
80105280:	e9 03 e5 ff ff       	jmp    80103788 <exit>
80105285:	8d 76 00             	lea    0x0(%esi),%esi
    }
    //Page allocation and mapping
    for(; addr < myproc()->sz; addr += PGSIZE){
      mem = kalloc();
      if(mem == 0){
        cprintf("allocuvm out of memory\n");
80105288:	c7 04 24 8b 6f 10 80 	movl   $0x80106f8b,(%esp)
8010528f:	e8 28 b3 ff ff       	call   801005bc <cprintf>
        deallocuvm(myproc()->pgdir, myproc()->sz, myproc()->tf->eax);
80105294:	e8 1f e1 ff ff       	call   801033b8 <myproc>
80105299:	8b 40 18             	mov    0x18(%eax),%eax
8010529c:	8b 70 1c             	mov    0x1c(%eax),%esi
8010529f:	e8 14 e1 ff ff       	call   801033b8 <myproc>
801052a4:	8b 18                	mov    (%eax),%ebx
801052a6:	e8 0d e1 ff ff       	call   801033b8 <myproc>
801052ab:	89 74 24 08          	mov    %esi,0x8(%esp)
801052af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801052b3:	8b 40 04             	mov    0x4(%eax),%eax
801052b6:	89 04 24             	mov    %eax,(%esp)
801052b9:	e8 8a 10 00 00       	call   80106348 <deallocuvm>
        return ;
801052be:	e9 83 fe ff ff       	jmp    80105146 <trap+0x11a>
801052c3:	90                   	nop
      }    
      memset(mem, 0, PGSIZE);
      if(mappages(myproc()->pgdir, (char *)addr, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
        cprintf("allocuvm out of memory (2)\n");
801052c4:	c7 04 24 a3 6f 10 80 	movl   $0x80106fa3,(%esp)
801052cb:	e8 ec b2 ff ff       	call   801005bc <cprintf>
        deallocuvm(myproc()->pgdir, myproc()->sz, myproc()->tf->eax);
801052d0:	e8 e3 e0 ff ff       	call   801033b8 <myproc>
801052d5:	8b 40 18             	mov    0x18(%eax),%eax
801052d8:	8b 78 1c             	mov    0x1c(%eax),%edi
801052db:	e8 d8 e0 ff ff       	call   801033b8 <myproc>
801052e0:	8b 18                	mov    (%eax),%ebx
801052e2:	e8 d1 e0 ff ff       	call   801033b8 <myproc>
801052e7:	89 7c 24 08          	mov    %edi,0x8(%esp)
801052eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801052ef:	8b 40 04             	mov    0x4(%eax),%eax
801052f2:	89 04 24             	mov    %eax,(%esp)
801052f5:	e8 4e 10 00 00       	call   80106348 <deallocuvm>
        kfree(mem);
801052fa:	89 75 08             	mov    %esi,0x8(%ebp)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801052fd:	83 c4 2c             	add    $0x2c,%esp
80105300:	5b                   	pop    %ebx
80105301:	5e                   	pop    %esi
80105302:	5f                   	pop    %edi
80105303:	5d                   	pop    %ebp
      }    
      memset(mem, 0, PGSIZE);
      if(mappages(myproc()->pgdir, (char *)addr, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
        cprintf("allocuvm out of memory (2)\n");
        deallocuvm(myproc()->pgdir, myproc()->sz, myproc()->tf->eax);
        kfree(mem);
80105304:	e9 7f ce ff ff       	jmp    80102188 <kfree>
80105309:	8d 76 00             	lea    0x0(%esi),%esi
  char *mem = kalloc();
  uint addr = PGROUNDDOWN(rcr2());

  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
8010530c:	e8 77 e4 ff ff       	call   80103788 <exit>
80105311:	e9 46 ff ff ff       	jmp    8010525c <trap+0x230>
80105316:	66 90                	xchg   %ax,%ax

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
80105318:	e8 6b e4 ff ff       	call   80103788 <exit>
8010531d:	e9 e7 fd ff ff       	jmp    80105109 <trap+0xdd>
80105322:	66 90                	xchg   %ax,%ax

  switch(tf->trapno){
    //xv6 CPU alarm
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
80105324:	c7 04 24 60 4f 11 80 	movl   $0x80114f60,(%esp)
8010532b:	e8 fc ea ff ff       	call   80103e2c <acquire>
      ticks++;
80105330:	ff 05 a0 57 11 80    	incl   0x801157a0
      wakeup(&ticks);
80105336:	c7 04 24 a0 57 11 80 	movl   $0x801157a0,(%esp)
8010533d:	e8 12 e7 ff ff       	call   80103a54 <wakeup>
      release(&tickslock);
80105342:	c7 04 24 60 4f 11 80 	movl   $0x80114f60,(%esp)
80105349:	e8 42 eb ff ff       	call   80103e90 <release>
8010534e:	e9 6e fe ff ff       	jmp    801051c1 <trap+0x195>
80105353:	0f 20 d6             	mov    %cr2,%esi

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105356:	8b 5f 38             	mov    0x38(%edi),%ebx
80105359:	e8 26 e0 ff ff       	call   80103384 <cpuid>
8010535e:	89 74 24 10          	mov    %esi,0x10(%esp)
80105362:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80105366:	89 44 24 08          	mov    %eax,0x8(%esp)
8010536a:	8b 47 30             	mov    0x30(%edi),%eax
8010536d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105371:	c7 04 24 e4 6f 10 80 	movl   $0x80106fe4,(%esp)
80105378:	e8 3f b2 ff ff       	call   801005bc <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010537d:	c7 04 24 86 6f 10 80 	movl   $0x80106f86,(%esp)
80105384:	e8 93 af ff ff       	call   8010031c <panic>
80105389:	00 00                	add    %al,(%eax)
	...

8010538c <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
8010538c:	55                   	push   %ebp
8010538d:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010538f:	a1 a4 a5 10 80       	mov    0x8010a5a4,%eax
80105394:	85 c0                	test   %eax,%eax
80105396:	74 14                	je     801053ac <uartgetc+0x20>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105398:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010539d:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010539e:	a8 01                	test   $0x1,%al
801053a0:	74 0a                	je     801053ac <uartgetc+0x20>
801053a2:	b2 f8                	mov    $0xf8,%dl
801053a4:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801053a5:	0f b6 c0             	movzbl %al,%eax
}
801053a8:	5d                   	pop    %ebp
801053a9:	c3                   	ret    
801053aa:	66 90                	xchg   %ax,%ax
uartgetc(void)
{
  if(!uart)
    return -1;
  if(!(inb(COM1+5) & 0x01))
    return -1;
801053ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return inb(COM1+0);
}
801053b1:	5d                   	pop    %ebp
801053b2:	c3                   	ret    
801053b3:	90                   	nop

801053b4 <uartputc>:
    uartputc(*p);
}

void
uartputc(int c)
{
801053b4:	55                   	push   %ebp
801053b5:	89 e5                	mov    %esp,%ebp
801053b7:	56                   	push   %esi
801053b8:	53                   	push   %ebx
801053b9:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(!uart)
801053bc:	8b 15 a4 a5 10 80    	mov    0x8010a5a4,%edx
801053c2:	85 d2                	test   %edx,%edx
801053c4:	74 2d                	je     801053f3 <uartputc+0x3f>
801053c6:	bb 80 00 00 00       	mov    $0x80,%ebx
801053cb:	be fd 03 00 00       	mov    $0x3fd,%esi
801053d0:	eb 11                	jmp    801053e3 <uartputc+0x2f>
801053d2:	66 90                	xchg   %ax,%ax
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
801053d4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801053db:	e8 28 d1 ff ff       	call   80102508 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801053e0:	4b                   	dec    %ebx
801053e1:	74 07                	je     801053ea <uartputc+0x36>
801053e3:	89 f2                	mov    %esi,%edx
801053e5:	ec                   	in     (%dx),%al
801053e6:	a8 20                	test   $0x20,%al
801053e8:	74 ea                	je     801053d4 <uartputc+0x20>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801053ea:	ba f8 03 00 00       	mov    $0x3f8,%edx
801053ef:	8b 45 08             	mov    0x8(%ebp),%eax
801053f2:	ee                   	out    %al,(%dx)
    microdelay(10);
  outb(COM1+0, c);
}
801053f3:	83 c4 10             	add    $0x10,%esp
801053f6:	5b                   	pop    %ebx
801053f7:	5e                   	pop    %esi
801053f8:	5d                   	pop    %ebp
801053f9:	c3                   	ret    
801053fa:	66 90                	xchg   %ax,%ax

801053fc <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801053fc:	55                   	push   %ebp
801053fd:	89 e5                	mov    %esp,%ebp
801053ff:	57                   	push   %edi
80105400:	56                   	push   %esi
80105401:	53                   	push   %ebx
80105402:	83 ec 1c             	sub    $0x1c,%esp
80105405:	be fa 03 00 00       	mov    $0x3fa,%esi
8010540a:	31 c0                	xor    %eax,%eax
8010540c:	89 f2                	mov    %esi,%edx
8010540e:	ee                   	out    %al,(%dx)
8010540f:	bb fb 03 00 00       	mov    $0x3fb,%ebx
80105414:	b0 80                	mov    $0x80,%al
80105416:	89 da                	mov    %ebx,%edx
80105418:	ee                   	out    %al,(%dx)
80105419:	bf f8 03 00 00       	mov    $0x3f8,%edi
8010541e:	b0 0c                	mov    $0xc,%al
80105420:	89 fa                	mov    %edi,%edx
80105422:	ee                   	out    %al,(%dx)
80105423:	b9 f9 03 00 00       	mov    $0x3f9,%ecx
80105428:	31 c0                	xor    %eax,%eax
8010542a:	89 ca                	mov    %ecx,%edx
8010542c:	ee                   	out    %al,(%dx)
8010542d:	b0 03                	mov    $0x3,%al
8010542f:	89 da                	mov    %ebx,%edx
80105431:	ee                   	out    %al,(%dx)
80105432:	b2 fc                	mov    $0xfc,%dl
80105434:	31 c0                	xor    %eax,%eax
80105436:	ee                   	out    %al,(%dx)
80105437:	b0 01                	mov    $0x1,%al
80105439:	89 ca                	mov    %ecx,%edx
8010543b:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010543c:	b2 fd                	mov    $0xfd,%dl
8010543e:	ec                   	in     (%dx),%al
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010543f:	fe c0                	inc    %al
80105441:	74 3f                	je     80105482 <uartinit+0x86>
    return;
  uart = 1;
80105443:	c7 05 a4 a5 10 80 01 	movl   $0x1,0x8010a5a4
8010544a:	00 00 00 
8010544d:	89 f2                	mov    %esi,%edx
8010544f:	ec                   	in     (%dx),%al
80105450:	89 fa                	mov    %edi,%edx
80105452:	ec                   	in     (%dx),%al

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);
80105453:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010545a:	00 
8010545b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80105462:	e8 ed cc ff ff       	call   80102154 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80105467:	b0 78                	mov    $0x78,%al
80105469:	bb 98 70 10 80       	mov    $0x80107098,%ebx
8010546e:	66 90                	xchg   %ax,%ax
    uartputc(*p);
80105470:	0f be c0             	movsbl %al,%eax
80105473:	89 04 24             	mov    %eax,(%esp)
80105476:	e8 39 ff ff ff       	call   801053b4 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010547b:	43                   	inc    %ebx
8010547c:	8a 03                	mov    (%ebx),%al
8010547e:	84 c0                	test   %al,%al
80105480:	75 ee                	jne    80105470 <uartinit+0x74>
    uartputc(*p);
}
80105482:	83 c4 1c             	add    $0x1c,%esp
80105485:	5b                   	pop    %ebx
80105486:	5e                   	pop    %esi
80105487:	5f                   	pop    %edi
80105488:	5d                   	pop    %ebp
80105489:	c3                   	ret    
8010548a:	66 90                	xchg   %ax,%ax

8010548c <uartintr>:
  return inb(COM1+0);
}

void
uartintr(void)
{
8010548c:	55                   	push   %ebp
8010548d:	89 e5                	mov    %esp,%ebp
8010548f:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80105492:	c7 04 24 8c 53 10 80 	movl   $0x8010538c,(%esp)
80105499:	e8 5e b2 ff ff       	call   801006fc <consoleintr>
}
8010549e:	c9                   	leave  
8010549f:	c3                   	ret    

801054a0 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801054a0:	6a 00                	push   $0x0
  pushl $0
801054a2:	6a 00                	push   $0x0
  jmp alltraps
801054a4:	e9 b7 fa ff ff       	jmp    80104f60 <alltraps>

801054a9 <vector1>:
.globl vector1
vector1:
  pushl $0
801054a9:	6a 00                	push   $0x0
  pushl $1
801054ab:	6a 01                	push   $0x1
  jmp alltraps
801054ad:	e9 ae fa ff ff       	jmp    80104f60 <alltraps>

801054b2 <vector2>:
.globl vector2
vector2:
  pushl $0
801054b2:	6a 00                	push   $0x0
  pushl $2
801054b4:	6a 02                	push   $0x2
  jmp alltraps
801054b6:	e9 a5 fa ff ff       	jmp    80104f60 <alltraps>

801054bb <vector3>:
.globl vector3
vector3:
  pushl $0
801054bb:	6a 00                	push   $0x0
  pushl $3
801054bd:	6a 03                	push   $0x3
  jmp alltraps
801054bf:	e9 9c fa ff ff       	jmp    80104f60 <alltraps>

801054c4 <vector4>:
.globl vector4
vector4:
  pushl $0
801054c4:	6a 00                	push   $0x0
  pushl $4
801054c6:	6a 04                	push   $0x4
  jmp alltraps
801054c8:	e9 93 fa ff ff       	jmp    80104f60 <alltraps>

801054cd <vector5>:
.globl vector5
vector5:
  pushl $0
801054cd:	6a 00                	push   $0x0
  pushl $5
801054cf:	6a 05                	push   $0x5
  jmp alltraps
801054d1:	e9 8a fa ff ff       	jmp    80104f60 <alltraps>

801054d6 <vector6>:
.globl vector6
vector6:
  pushl $0
801054d6:	6a 00                	push   $0x0
  pushl $6
801054d8:	6a 06                	push   $0x6
  jmp alltraps
801054da:	e9 81 fa ff ff       	jmp    80104f60 <alltraps>

801054df <vector7>:
.globl vector7
vector7:
  pushl $0
801054df:	6a 00                	push   $0x0
  pushl $7
801054e1:	6a 07                	push   $0x7
  jmp alltraps
801054e3:	e9 78 fa ff ff       	jmp    80104f60 <alltraps>

801054e8 <vector8>:
.globl vector8
vector8:
  pushl $8
801054e8:	6a 08                	push   $0x8
  jmp alltraps
801054ea:	e9 71 fa ff ff       	jmp    80104f60 <alltraps>

801054ef <vector9>:
.globl vector9
vector9:
  pushl $0
801054ef:	6a 00                	push   $0x0
  pushl $9
801054f1:	6a 09                	push   $0x9
  jmp alltraps
801054f3:	e9 68 fa ff ff       	jmp    80104f60 <alltraps>

801054f8 <vector10>:
.globl vector10
vector10:
  pushl $10
801054f8:	6a 0a                	push   $0xa
  jmp alltraps
801054fa:	e9 61 fa ff ff       	jmp    80104f60 <alltraps>

801054ff <vector11>:
.globl vector11
vector11:
  pushl $11
801054ff:	6a 0b                	push   $0xb
  jmp alltraps
80105501:	e9 5a fa ff ff       	jmp    80104f60 <alltraps>

80105506 <vector12>:
.globl vector12
vector12:
  pushl $12
80105506:	6a 0c                	push   $0xc
  jmp alltraps
80105508:	e9 53 fa ff ff       	jmp    80104f60 <alltraps>

8010550d <vector13>:
.globl vector13
vector13:
  pushl $13
8010550d:	6a 0d                	push   $0xd
  jmp alltraps
8010550f:	e9 4c fa ff ff       	jmp    80104f60 <alltraps>

80105514 <vector14>:
.globl vector14
vector14:
  pushl $14
80105514:	6a 0e                	push   $0xe
  jmp alltraps
80105516:	e9 45 fa ff ff       	jmp    80104f60 <alltraps>

8010551b <vector15>:
.globl vector15
vector15:
  pushl $0
8010551b:	6a 00                	push   $0x0
  pushl $15
8010551d:	6a 0f                	push   $0xf
  jmp alltraps
8010551f:	e9 3c fa ff ff       	jmp    80104f60 <alltraps>

80105524 <vector16>:
.globl vector16
vector16:
  pushl $0
80105524:	6a 00                	push   $0x0
  pushl $16
80105526:	6a 10                	push   $0x10
  jmp alltraps
80105528:	e9 33 fa ff ff       	jmp    80104f60 <alltraps>

8010552d <vector17>:
.globl vector17
vector17:
  pushl $17
8010552d:	6a 11                	push   $0x11
  jmp alltraps
8010552f:	e9 2c fa ff ff       	jmp    80104f60 <alltraps>

80105534 <vector18>:
.globl vector18
vector18:
  pushl $0
80105534:	6a 00                	push   $0x0
  pushl $18
80105536:	6a 12                	push   $0x12
  jmp alltraps
80105538:	e9 23 fa ff ff       	jmp    80104f60 <alltraps>

8010553d <vector19>:
.globl vector19
vector19:
  pushl $0
8010553d:	6a 00                	push   $0x0
  pushl $19
8010553f:	6a 13                	push   $0x13
  jmp alltraps
80105541:	e9 1a fa ff ff       	jmp    80104f60 <alltraps>

80105546 <vector20>:
.globl vector20
vector20:
  pushl $0
80105546:	6a 00                	push   $0x0
  pushl $20
80105548:	6a 14                	push   $0x14
  jmp alltraps
8010554a:	e9 11 fa ff ff       	jmp    80104f60 <alltraps>

8010554f <vector21>:
.globl vector21
vector21:
  pushl $0
8010554f:	6a 00                	push   $0x0
  pushl $21
80105551:	6a 15                	push   $0x15
  jmp alltraps
80105553:	e9 08 fa ff ff       	jmp    80104f60 <alltraps>

80105558 <vector22>:
.globl vector22
vector22:
  pushl $0
80105558:	6a 00                	push   $0x0
  pushl $22
8010555a:	6a 16                	push   $0x16
  jmp alltraps
8010555c:	e9 ff f9 ff ff       	jmp    80104f60 <alltraps>

80105561 <vector23>:
.globl vector23
vector23:
  pushl $0
80105561:	6a 00                	push   $0x0
  pushl $23
80105563:	6a 17                	push   $0x17
  jmp alltraps
80105565:	e9 f6 f9 ff ff       	jmp    80104f60 <alltraps>

8010556a <vector24>:
.globl vector24
vector24:
  pushl $0
8010556a:	6a 00                	push   $0x0
  pushl $24
8010556c:	6a 18                	push   $0x18
  jmp alltraps
8010556e:	e9 ed f9 ff ff       	jmp    80104f60 <alltraps>

80105573 <vector25>:
.globl vector25
vector25:
  pushl $0
80105573:	6a 00                	push   $0x0
  pushl $25
80105575:	6a 19                	push   $0x19
  jmp alltraps
80105577:	e9 e4 f9 ff ff       	jmp    80104f60 <alltraps>

8010557c <vector26>:
.globl vector26
vector26:
  pushl $0
8010557c:	6a 00                	push   $0x0
  pushl $26
8010557e:	6a 1a                	push   $0x1a
  jmp alltraps
80105580:	e9 db f9 ff ff       	jmp    80104f60 <alltraps>

80105585 <vector27>:
.globl vector27
vector27:
  pushl $0
80105585:	6a 00                	push   $0x0
  pushl $27
80105587:	6a 1b                	push   $0x1b
  jmp alltraps
80105589:	e9 d2 f9 ff ff       	jmp    80104f60 <alltraps>

8010558e <vector28>:
.globl vector28
vector28:
  pushl $0
8010558e:	6a 00                	push   $0x0
  pushl $28
80105590:	6a 1c                	push   $0x1c
  jmp alltraps
80105592:	e9 c9 f9 ff ff       	jmp    80104f60 <alltraps>

80105597 <vector29>:
.globl vector29
vector29:
  pushl $0
80105597:	6a 00                	push   $0x0
  pushl $29
80105599:	6a 1d                	push   $0x1d
  jmp alltraps
8010559b:	e9 c0 f9 ff ff       	jmp    80104f60 <alltraps>

801055a0 <vector30>:
.globl vector30
vector30:
  pushl $0
801055a0:	6a 00                	push   $0x0
  pushl $30
801055a2:	6a 1e                	push   $0x1e
  jmp alltraps
801055a4:	e9 b7 f9 ff ff       	jmp    80104f60 <alltraps>

801055a9 <vector31>:
.globl vector31
vector31:
  pushl $0
801055a9:	6a 00                	push   $0x0
  pushl $31
801055ab:	6a 1f                	push   $0x1f
  jmp alltraps
801055ad:	e9 ae f9 ff ff       	jmp    80104f60 <alltraps>

801055b2 <vector32>:
.globl vector32
vector32:
  pushl $0
801055b2:	6a 00                	push   $0x0
  pushl $32
801055b4:	6a 20                	push   $0x20
  jmp alltraps
801055b6:	e9 a5 f9 ff ff       	jmp    80104f60 <alltraps>

801055bb <vector33>:
.globl vector33
vector33:
  pushl $0
801055bb:	6a 00                	push   $0x0
  pushl $33
801055bd:	6a 21                	push   $0x21
  jmp alltraps
801055bf:	e9 9c f9 ff ff       	jmp    80104f60 <alltraps>

801055c4 <vector34>:
.globl vector34
vector34:
  pushl $0
801055c4:	6a 00                	push   $0x0
  pushl $34
801055c6:	6a 22                	push   $0x22
  jmp alltraps
801055c8:	e9 93 f9 ff ff       	jmp    80104f60 <alltraps>

801055cd <vector35>:
.globl vector35
vector35:
  pushl $0
801055cd:	6a 00                	push   $0x0
  pushl $35
801055cf:	6a 23                	push   $0x23
  jmp alltraps
801055d1:	e9 8a f9 ff ff       	jmp    80104f60 <alltraps>

801055d6 <vector36>:
.globl vector36
vector36:
  pushl $0
801055d6:	6a 00                	push   $0x0
  pushl $36
801055d8:	6a 24                	push   $0x24
  jmp alltraps
801055da:	e9 81 f9 ff ff       	jmp    80104f60 <alltraps>

801055df <vector37>:
.globl vector37
vector37:
  pushl $0
801055df:	6a 00                	push   $0x0
  pushl $37
801055e1:	6a 25                	push   $0x25
  jmp alltraps
801055e3:	e9 78 f9 ff ff       	jmp    80104f60 <alltraps>

801055e8 <vector38>:
.globl vector38
vector38:
  pushl $0
801055e8:	6a 00                	push   $0x0
  pushl $38
801055ea:	6a 26                	push   $0x26
  jmp alltraps
801055ec:	e9 6f f9 ff ff       	jmp    80104f60 <alltraps>

801055f1 <vector39>:
.globl vector39
vector39:
  pushl $0
801055f1:	6a 00                	push   $0x0
  pushl $39
801055f3:	6a 27                	push   $0x27
  jmp alltraps
801055f5:	e9 66 f9 ff ff       	jmp    80104f60 <alltraps>

801055fa <vector40>:
.globl vector40
vector40:
  pushl $0
801055fa:	6a 00                	push   $0x0
  pushl $40
801055fc:	6a 28                	push   $0x28
  jmp alltraps
801055fe:	e9 5d f9 ff ff       	jmp    80104f60 <alltraps>

80105603 <vector41>:
.globl vector41
vector41:
  pushl $0
80105603:	6a 00                	push   $0x0
  pushl $41
80105605:	6a 29                	push   $0x29
  jmp alltraps
80105607:	e9 54 f9 ff ff       	jmp    80104f60 <alltraps>

8010560c <vector42>:
.globl vector42
vector42:
  pushl $0
8010560c:	6a 00                	push   $0x0
  pushl $42
8010560e:	6a 2a                	push   $0x2a
  jmp alltraps
80105610:	e9 4b f9 ff ff       	jmp    80104f60 <alltraps>

80105615 <vector43>:
.globl vector43
vector43:
  pushl $0
80105615:	6a 00                	push   $0x0
  pushl $43
80105617:	6a 2b                	push   $0x2b
  jmp alltraps
80105619:	e9 42 f9 ff ff       	jmp    80104f60 <alltraps>

8010561e <vector44>:
.globl vector44
vector44:
  pushl $0
8010561e:	6a 00                	push   $0x0
  pushl $44
80105620:	6a 2c                	push   $0x2c
  jmp alltraps
80105622:	e9 39 f9 ff ff       	jmp    80104f60 <alltraps>

80105627 <vector45>:
.globl vector45
vector45:
  pushl $0
80105627:	6a 00                	push   $0x0
  pushl $45
80105629:	6a 2d                	push   $0x2d
  jmp alltraps
8010562b:	e9 30 f9 ff ff       	jmp    80104f60 <alltraps>

80105630 <vector46>:
.globl vector46
vector46:
  pushl $0
80105630:	6a 00                	push   $0x0
  pushl $46
80105632:	6a 2e                	push   $0x2e
  jmp alltraps
80105634:	e9 27 f9 ff ff       	jmp    80104f60 <alltraps>

80105639 <vector47>:
.globl vector47
vector47:
  pushl $0
80105639:	6a 00                	push   $0x0
  pushl $47
8010563b:	6a 2f                	push   $0x2f
  jmp alltraps
8010563d:	e9 1e f9 ff ff       	jmp    80104f60 <alltraps>

80105642 <vector48>:
.globl vector48
vector48:
  pushl $0
80105642:	6a 00                	push   $0x0
  pushl $48
80105644:	6a 30                	push   $0x30
  jmp alltraps
80105646:	e9 15 f9 ff ff       	jmp    80104f60 <alltraps>

8010564b <vector49>:
.globl vector49
vector49:
  pushl $0
8010564b:	6a 00                	push   $0x0
  pushl $49
8010564d:	6a 31                	push   $0x31
  jmp alltraps
8010564f:	e9 0c f9 ff ff       	jmp    80104f60 <alltraps>

80105654 <vector50>:
.globl vector50
vector50:
  pushl $0
80105654:	6a 00                	push   $0x0
  pushl $50
80105656:	6a 32                	push   $0x32
  jmp alltraps
80105658:	e9 03 f9 ff ff       	jmp    80104f60 <alltraps>

8010565d <vector51>:
.globl vector51
vector51:
  pushl $0
8010565d:	6a 00                	push   $0x0
  pushl $51
8010565f:	6a 33                	push   $0x33
  jmp alltraps
80105661:	e9 fa f8 ff ff       	jmp    80104f60 <alltraps>

80105666 <vector52>:
.globl vector52
vector52:
  pushl $0
80105666:	6a 00                	push   $0x0
  pushl $52
80105668:	6a 34                	push   $0x34
  jmp alltraps
8010566a:	e9 f1 f8 ff ff       	jmp    80104f60 <alltraps>

8010566f <vector53>:
.globl vector53
vector53:
  pushl $0
8010566f:	6a 00                	push   $0x0
  pushl $53
80105671:	6a 35                	push   $0x35
  jmp alltraps
80105673:	e9 e8 f8 ff ff       	jmp    80104f60 <alltraps>

80105678 <vector54>:
.globl vector54
vector54:
  pushl $0
80105678:	6a 00                	push   $0x0
  pushl $54
8010567a:	6a 36                	push   $0x36
  jmp alltraps
8010567c:	e9 df f8 ff ff       	jmp    80104f60 <alltraps>

80105681 <vector55>:
.globl vector55
vector55:
  pushl $0
80105681:	6a 00                	push   $0x0
  pushl $55
80105683:	6a 37                	push   $0x37
  jmp alltraps
80105685:	e9 d6 f8 ff ff       	jmp    80104f60 <alltraps>

8010568a <vector56>:
.globl vector56
vector56:
  pushl $0
8010568a:	6a 00                	push   $0x0
  pushl $56
8010568c:	6a 38                	push   $0x38
  jmp alltraps
8010568e:	e9 cd f8 ff ff       	jmp    80104f60 <alltraps>

80105693 <vector57>:
.globl vector57
vector57:
  pushl $0
80105693:	6a 00                	push   $0x0
  pushl $57
80105695:	6a 39                	push   $0x39
  jmp alltraps
80105697:	e9 c4 f8 ff ff       	jmp    80104f60 <alltraps>

8010569c <vector58>:
.globl vector58
vector58:
  pushl $0
8010569c:	6a 00                	push   $0x0
  pushl $58
8010569e:	6a 3a                	push   $0x3a
  jmp alltraps
801056a0:	e9 bb f8 ff ff       	jmp    80104f60 <alltraps>

801056a5 <vector59>:
.globl vector59
vector59:
  pushl $0
801056a5:	6a 00                	push   $0x0
  pushl $59
801056a7:	6a 3b                	push   $0x3b
  jmp alltraps
801056a9:	e9 b2 f8 ff ff       	jmp    80104f60 <alltraps>

801056ae <vector60>:
.globl vector60
vector60:
  pushl $0
801056ae:	6a 00                	push   $0x0
  pushl $60
801056b0:	6a 3c                	push   $0x3c
  jmp alltraps
801056b2:	e9 a9 f8 ff ff       	jmp    80104f60 <alltraps>

801056b7 <vector61>:
.globl vector61
vector61:
  pushl $0
801056b7:	6a 00                	push   $0x0
  pushl $61
801056b9:	6a 3d                	push   $0x3d
  jmp alltraps
801056bb:	e9 a0 f8 ff ff       	jmp    80104f60 <alltraps>

801056c0 <vector62>:
.globl vector62
vector62:
  pushl $0
801056c0:	6a 00                	push   $0x0
  pushl $62
801056c2:	6a 3e                	push   $0x3e
  jmp alltraps
801056c4:	e9 97 f8 ff ff       	jmp    80104f60 <alltraps>

801056c9 <vector63>:
.globl vector63
vector63:
  pushl $0
801056c9:	6a 00                	push   $0x0
  pushl $63
801056cb:	6a 3f                	push   $0x3f
  jmp alltraps
801056cd:	e9 8e f8 ff ff       	jmp    80104f60 <alltraps>

801056d2 <vector64>:
.globl vector64
vector64:
  pushl $0
801056d2:	6a 00                	push   $0x0
  pushl $64
801056d4:	6a 40                	push   $0x40
  jmp alltraps
801056d6:	e9 85 f8 ff ff       	jmp    80104f60 <alltraps>

801056db <vector65>:
.globl vector65
vector65:
  pushl $0
801056db:	6a 00                	push   $0x0
  pushl $65
801056dd:	6a 41                	push   $0x41
  jmp alltraps
801056df:	e9 7c f8 ff ff       	jmp    80104f60 <alltraps>

801056e4 <vector66>:
.globl vector66
vector66:
  pushl $0
801056e4:	6a 00                	push   $0x0
  pushl $66
801056e6:	6a 42                	push   $0x42
  jmp alltraps
801056e8:	e9 73 f8 ff ff       	jmp    80104f60 <alltraps>

801056ed <vector67>:
.globl vector67
vector67:
  pushl $0
801056ed:	6a 00                	push   $0x0
  pushl $67
801056ef:	6a 43                	push   $0x43
  jmp alltraps
801056f1:	e9 6a f8 ff ff       	jmp    80104f60 <alltraps>

801056f6 <vector68>:
.globl vector68
vector68:
  pushl $0
801056f6:	6a 00                	push   $0x0
  pushl $68
801056f8:	6a 44                	push   $0x44
  jmp alltraps
801056fa:	e9 61 f8 ff ff       	jmp    80104f60 <alltraps>

801056ff <vector69>:
.globl vector69
vector69:
  pushl $0
801056ff:	6a 00                	push   $0x0
  pushl $69
80105701:	6a 45                	push   $0x45
  jmp alltraps
80105703:	e9 58 f8 ff ff       	jmp    80104f60 <alltraps>

80105708 <vector70>:
.globl vector70
vector70:
  pushl $0
80105708:	6a 00                	push   $0x0
  pushl $70
8010570a:	6a 46                	push   $0x46
  jmp alltraps
8010570c:	e9 4f f8 ff ff       	jmp    80104f60 <alltraps>

80105711 <vector71>:
.globl vector71
vector71:
  pushl $0
80105711:	6a 00                	push   $0x0
  pushl $71
80105713:	6a 47                	push   $0x47
  jmp alltraps
80105715:	e9 46 f8 ff ff       	jmp    80104f60 <alltraps>

8010571a <vector72>:
.globl vector72
vector72:
  pushl $0
8010571a:	6a 00                	push   $0x0
  pushl $72
8010571c:	6a 48                	push   $0x48
  jmp alltraps
8010571e:	e9 3d f8 ff ff       	jmp    80104f60 <alltraps>

80105723 <vector73>:
.globl vector73
vector73:
  pushl $0
80105723:	6a 00                	push   $0x0
  pushl $73
80105725:	6a 49                	push   $0x49
  jmp alltraps
80105727:	e9 34 f8 ff ff       	jmp    80104f60 <alltraps>

8010572c <vector74>:
.globl vector74
vector74:
  pushl $0
8010572c:	6a 00                	push   $0x0
  pushl $74
8010572e:	6a 4a                	push   $0x4a
  jmp alltraps
80105730:	e9 2b f8 ff ff       	jmp    80104f60 <alltraps>

80105735 <vector75>:
.globl vector75
vector75:
  pushl $0
80105735:	6a 00                	push   $0x0
  pushl $75
80105737:	6a 4b                	push   $0x4b
  jmp alltraps
80105739:	e9 22 f8 ff ff       	jmp    80104f60 <alltraps>

8010573e <vector76>:
.globl vector76
vector76:
  pushl $0
8010573e:	6a 00                	push   $0x0
  pushl $76
80105740:	6a 4c                	push   $0x4c
  jmp alltraps
80105742:	e9 19 f8 ff ff       	jmp    80104f60 <alltraps>

80105747 <vector77>:
.globl vector77
vector77:
  pushl $0
80105747:	6a 00                	push   $0x0
  pushl $77
80105749:	6a 4d                	push   $0x4d
  jmp alltraps
8010574b:	e9 10 f8 ff ff       	jmp    80104f60 <alltraps>

80105750 <vector78>:
.globl vector78
vector78:
  pushl $0
80105750:	6a 00                	push   $0x0
  pushl $78
80105752:	6a 4e                	push   $0x4e
  jmp alltraps
80105754:	e9 07 f8 ff ff       	jmp    80104f60 <alltraps>

80105759 <vector79>:
.globl vector79
vector79:
  pushl $0
80105759:	6a 00                	push   $0x0
  pushl $79
8010575b:	6a 4f                	push   $0x4f
  jmp alltraps
8010575d:	e9 fe f7 ff ff       	jmp    80104f60 <alltraps>

80105762 <vector80>:
.globl vector80
vector80:
  pushl $0
80105762:	6a 00                	push   $0x0
  pushl $80
80105764:	6a 50                	push   $0x50
  jmp alltraps
80105766:	e9 f5 f7 ff ff       	jmp    80104f60 <alltraps>

8010576b <vector81>:
.globl vector81
vector81:
  pushl $0
8010576b:	6a 00                	push   $0x0
  pushl $81
8010576d:	6a 51                	push   $0x51
  jmp alltraps
8010576f:	e9 ec f7 ff ff       	jmp    80104f60 <alltraps>

80105774 <vector82>:
.globl vector82
vector82:
  pushl $0
80105774:	6a 00                	push   $0x0
  pushl $82
80105776:	6a 52                	push   $0x52
  jmp alltraps
80105778:	e9 e3 f7 ff ff       	jmp    80104f60 <alltraps>

8010577d <vector83>:
.globl vector83
vector83:
  pushl $0
8010577d:	6a 00                	push   $0x0
  pushl $83
8010577f:	6a 53                	push   $0x53
  jmp alltraps
80105781:	e9 da f7 ff ff       	jmp    80104f60 <alltraps>

80105786 <vector84>:
.globl vector84
vector84:
  pushl $0
80105786:	6a 00                	push   $0x0
  pushl $84
80105788:	6a 54                	push   $0x54
  jmp alltraps
8010578a:	e9 d1 f7 ff ff       	jmp    80104f60 <alltraps>

8010578f <vector85>:
.globl vector85
vector85:
  pushl $0
8010578f:	6a 00                	push   $0x0
  pushl $85
80105791:	6a 55                	push   $0x55
  jmp alltraps
80105793:	e9 c8 f7 ff ff       	jmp    80104f60 <alltraps>

80105798 <vector86>:
.globl vector86
vector86:
  pushl $0
80105798:	6a 00                	push   $0x0
  pushl $86
8010579a:	6a 56                	push   $0x56
  jmp alltraps
8010579c:	e9 bf f7 ff ff       	jmp    80104f60 <alltraps>

801057a1 <vector87>:
.globl vector87
vector87:
  pushl $0
801057a1:	6a 00                	push   $0x0
  pushl $87
801057a3:	6a 57                	push   $0x57
  jmp alltraps
801057a5:	e9 b6 f7 ff ff       	jmp    80104f60 <alltraps>

801057aa <vector88>:
.globl vector88
vector88:
  pushl $0
801057aa:	6a 00                	push   $0x0
  pushl $88
801057ac:	6a 58                	push   $0x58
  jmp alltraps
801057ae:	e9 ad f7 ff ff       	jmp    80104f60 <alltraps>

801057b3 <vector89>:
.globl vector89
vector89:
  pushl $0
801057b3:	6a 00                	push   $0x0
  pushl $89
801057b5:	6a 59                	push   $0x59
  jmp alltraps
801057b7:	e9 a4 f7 ff ff       	jmp    80104f60 <alltraps>

801057bc <vector90>:
.globl vector90
vector90:
  pushl $0
801057bc:	6a 00                	push   $0x0
  pushl $90
801057be:	6a 5a                	push   $0x5a
  jmp alltraps
801057c0:	e9 9b f7 ff ff       	jmp    80104f60 <alltraps>

801057c5 <vector91>:
.globl vector91
vector91:
  pushl $0
801057c5:	6a 00                	push   $0x0
  pushl $91
801057c7:	6a 5b                	push   $0x5b
  jmp alltraps
801057c9:	e9 92 f7 ff ff       	jmp    80104f60 <alltraps>

801057ce <vector92>:
.globl vector92
vector92:
  pushl $0
801057ce:	6a 00                	push   $0x0
  pushl $92
801057d0:	6a 5c                	push   $0x5c
  jmp alltraps
801057d2:	e9 89 f7 ff ff       	jmp    80104f60 <alltraps>

801057d7 <vector93>:
.globl vector93
vector93:
  pushl $0
801057d7:	6a 00                	push   $0x0
  pushl $93
801057d9:	6a 5d                	push   $0x5d
  jmp alltraps
801057db:	e9 80 f7 ff ff       	jmp    80104f60 <alltraps>

801057e0 <vector94>:
.globl vector94
vector94:
  pushl $0
801057e0:	6a 00                	push   $0x0
  pushl $94
801057e2:	6a 5e                	push   $0x5e
  jmp alltraps
801057e4:	e9 77 f7 ff ff       	jmp    80104f60 <alltraps>

801057e9 <vector95>:
.globl vector95
vector95:
  pushl $0
801057e9:	6a 00                	push   $0x0
  pushl $95
801057eb:	6a 5f                	push   $0x5f
  jmp alltraps
801057ed:	e9 6e f7 ff ff       	jmp    80104f60 <alltraps>

801057f2 <vector96>:
.globl vector96
vector96:
  pushl $0
801057f2:	6a 00                	push   $0x0
  pushl $96
801057f4:	6a 60                	push   $0x60
  jmp alltraps
801057f6:	e9 65 f7 ff ff       	jmp    80104f60 <alltraps>

801057fb <vector97>:
.globl vector97
vector97:
  pushl $0
801057fb:	6a 00                	push   $0x0
  pushl $97
801057fd:	6a 61                	push   $0x61
  jmp alltraps
801057ff:	e9 5c f7 ff ff       	jmp    80104f60 <alltraps>

80105804 <vector98>:
.globl vector98
vector98:
  pushl $0
80105804:	6a 00                	push   $0x0
  pushl $98
80105806:	6a 62                	push   $0x62
  jmp alltraps
80105808:	e9 53 f7 ff ff       	jmp    80104f60 <alltraps>

8010580d <vector99>:
.globl vector99
vector99:
  pushl $0
8010580d:	6a 00                	push   $0x0
  pushl $99
8010580f:	6a 63                	push   $0x63
  jmp alltraps
80105811:	e9 4a f7 ff ff       	jmp    80104f60 <alltraps>

80105816 <vector100>:
.globl vector100
vector100:
  pushl $0
80105816:	6a 00                	push   $0x0
  pushl $100
80105818:	6a 64                	push   $0x64
  jmp alltraps
8010581a:	e9 41 f7 ff ff       	jmp    80104f60 <alltraps>

8010581f <vector101>:
.globl vector101
vector101:
  pushl $0
8010581f:	6a 00                	push   $0x0
  pushl $101
80105821:	6a 65                	push   $0x65
  jmp alltraps
80105823:	e9 38 f7 ff ff       	jmp    80104f60 <alltraps>

80105828 <vector102>:
.globl vector102
vector102:
  pushl $0
80105828:	6a 00                	push   $0x0
  pushl $102
8010582a:	6a 66                	push   $0x66
  jmp alltraps
8010582c:	e9 2f f7 ff ff       	jmp    80104f60 <alltraps>

80105831 <vector103>:
.globl vector103
vector103:
  pushl $0
80105831:	6a 00                	push   $0x0
  pushl $103
80105833:	6a 67                	push   $0x67
  jmp alltraps
80105835:	e9 26 f7 ff ff       	jmp    80104f60 <alltraps>

8010583a <vector104>:
.globl vector104
vector104:
  pushl $0
8010583a:	6a 00                	push   $0x0
  pushl $104
8010583c:	6a 68                	push   $0x68
  jmp alltraps
8010583e:	e9 1d f7 ff ff       	jmp    80104f60 <alltraps>

80105843 <vector105>:
.globl vector105
vector105:
  pushl $0
80105843:	6a 00                	push   $0x0
  pushl $105
80105845:	6a 69                	push   $0x69
  jmp alltraps
80105847:	e9 14 f7 ff ff       	jmp    80104f60 <alltraps>

8010584c <vector106>:
.globl vector106
vector106:
  pushl $0
8010584c:	6a 00                	push   $0x0
  pushl $106
8010584e:	6a 6a                	push   $0x6a
  jmp alltraps
80105850:	e9 0b f7 ff ff       	jmp    80104f60 <alltraps>

80105855 <vector107>:
.globl vector107
vector107:
  pushl $0
80105855:	6a 00                	push   $0x0
  pushl $107
80105857:	6a 6b                	push   $0x6b
  jmp alltraps
80105859:	e9 02 f7 ff ff       	jmp    80104f60 <alltraps>

8010585e <vector108>:
.globl vector108
vector108:
  pushl $0
8010585e:	6a 00                	push   $0x0
  pushl $108
80105860:	6a 6c                	push   $0x6c
  jmp alltraps
80105862:	e9 f9 f6 ff ff       	jmp    80104f60 <alltraps>

80105867 <vector109>:
.globl vector109
vector109:
  pushl $0
80105867:	6a 00                	push   $0x0
  pushl $109
80105869:	6a 6d                	push   $0x6d
  jmp alltraps
8010586b:	e9 f0 f6 ff ff       	jmp    80104f60 <alltraps>

80105870 <vector110>:
.globl vector110
vector110:
  pushl $0
80105870:	6a 00                	push   $0x0
  pushl $110
80105872:	6a 6e                	push   $0x6e
  jmp alltraps
80105874:	e9 e7 f6 ff ff       	jmp    80104f60 <alltraps>

80105879 <vector111>:
.globl vector111
vector111:
  pushl $0
80105879:	6a 00                	push   $0x0
  pushl $111
8010587b:	6a 6f                	push   $0x6f
  jmp alltraps
8010587d:	e9 de f6 ff ff       	jmp    80104f60 <alltraps>

80105882 <vector112>:
.globl vector112
vector112:
  pushl $0
80105882:	6a 00                	push   $0x0
  pushl $112
80105884:	6a 70                	push   $0x70
  jmp alltraps
80105886:	e9 d5 f6 ff ff       	jmp    80104f60 <alltraps>

8010588b <vector113>:
.globl vector113
vector113:
  pushl $0
8010588b:	6a 00                	push   $0x0
  pushl $113
8010588d:	6a 71                	push   $0x71
  jmp alltraps
8010588f:	e9 cc f6 ff ff       	jmp    80104f60 <alltraps>

80105894 <vector114>:
.globl vector114
vector114:
  pushl $0
80105894:	6a 00                	push   $0x0
  pushl $114
80105896:	6a 72                	push   $0x72
  jmp alltraps
80105898:	e9 c3 f6 ff ff       	jmp    80104f60 <alltraps>

8010589d <vector115>:
.globl vector115
vector115:
  pushl $0
8010589d:	6a 00                	push   $0x0
  pushl $115
8010589f:	6a 73                	push   $0x73
  jmp alltraps
801058a1:	e9 ba f6 ff ff       	jmp    80104f60 <alltraps>

801058a6 <vector116>:
.globl vector116
vector116:
  pushl $0
801058a6:	6a 00                	push   $0x0
  pushl $116
801058a8:	6a 74                	push   $0x74
  jmp alltraps
801058aa:	e9 b1 f6 ff ff       	jmp    80104f60 <alltraps>

801058af <vector117>:
.globl vector117
vector117:
  pushl $0
801058af:	6a 00                	push   $0x0
  pushl $117
801058b1:	6a 75                	push   $0x75
  jmp alltraps
801058b3:	e9 a8 f6 ff ff       	jmp    80104f60 <alltraps>

801058b8 <vector118>:
.globl vector118
vector118:
  pushl $0
801058b8:	6a 00                	push   $0x0
  pushl $118
801058ba:	6a 76                	push   $0x76
  jmp alltraps
801058bc:	e9 9f f6 ff ff       	jmp    80104f60 <alltraps>

801058c1 <vector119>:
.globl vector119
vector119:
  pushl $0
801058c1:	6a 00                	push   $0x0
  pushl $119
801058c3:	6a 77                	push   $0x77
  jmp alltraps
801058c5:	e9 96 f6 ff ff       	jmp    80104f60 <alltraps>

801058ca <vector120>:
.globl vector120
vector120:
  pushl $0
801058ca:	6a 00                	push   $0x0
  pushl $120
801058cc:	6a 78                	push   $0x78
  jmp alltraps
801058ce:	e9 8d f6 ff ff       	jmp    80104f60 <alltraps>

801058d3 <vector121>:
.globl vector121
vector121:
  pushl $0
801058d3:	6a 00                	push   $0x0
  pushl $121
801058d5:	6a 79                	push   $0x79
  jmp alltraps
801058d7:	e9 84 f6 ff ff       	jmp    80104f60 <alltraps>

801058dc <vector122>:
.globl vector122
vector122:
  pushl $0
801058dc:	6a 00                	push   $0x0
  pushl $122
801058de:	6a 7a                	push   $0x7a
  jmp alltraps
801058e0:	e9 7b f6 ff ff       	jmp    80104f60 <alltraps>

801058e5 <vector123>:
.globl vector123
vector123:
  pushl $0
801058e5:	6a 00                	push   $0x0
  pushl $123
801058e7:	6a 7b                	push   $0x7b
  jmp alltraps
801058e9:	e9 72 f6 ff ff       	jmp    80104f60 <alltraps>

801058ee <vector124>:
.globl vector124
vector124:
  pushl $0
801058ee:	6a 00                	push   $0x0
  pushl $124
801058f0:	6a 7c                	push   $0x7c
  jmp alltraps
801058f2:	e9 69 f6 ff ff       	jmp    80104f60 <alltraps>

801058f7 <vector125>:
.globl vector125
vector125:
  pushl $0
801058f7:	6a 00                	push   $0x0
  pushl $125
801058f9:	6a 7d                	push   $0x7d
  jmp alltraps
801058fb:	e9 60 f6 ff ff       	jmp    80104f60 <alltraps>

80105900 <vector126>:
.globl vector126
vector126:
  pushl $0
80105900:	6a 00                	push   $0x0
  pushl $126
80105902:	6a 7e                	push   $0x7e
  jmp alltraps
80105904:	e9 57 f6 ff ff       	jmp    80104f60 <alltraps>

80105909 <vector127>:
.globl vector127
vector127:
  pushl $0
80105909:	6a 00                	push   $0x0
  pushl $127
8010590b:	6a 7f                	push   $0x7f
  jmp alltraps
8010590d:	e9 4e f6 ff ff       	jmp    80104f60 <alltraps>

80105912 <vector128>:
.globl vector128
vector128:
  pushl $0
80105912:	6a 00                	push   $0x0
  pushl $128
80105914:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105919:	e9 42 f6 ff ff       	jmp    80104f60 <alltraps>

8010591e <vector129>:
.globl vector129
vector129:
  pushl $0
8010591e:	6a 00                	push   $0x0
  pushl $129
80105920:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105925:	e9 36 f6 ff ff       	jmp    80104f60 <alltraps>

8010592a <vector130>:
.globl vector130
vector130:
  pushl $0
8010592a:	6a 00                	push   $0x0
  pushl $130
8010592c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105931:	e9 2a f6 ff ff       	jmp    80104f60 <alltraps>

80105936 <vector131>:
.globl vector131
vector131:
  pushl $0
80105936:	6a 00                	push   $0x0
  pushl $131
80105938:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010593d:	e9 1e f6 ff ff       	jmp    80104f60 <alltraps>

80105942 <vector132>:
.globl vector132
vector132:
  pushl $0
80105942:	6a 00                	push   $0x0
  pushl $132
80105944:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105949:	e9 12 f6 ff ff       	jmp    80104f60 <alltraps>

8010594e <vector133>:
.globl vector133
vector133:
  pushl $0
8010594e:	6a 00                	push   $0x0
  pushl $133
80105950:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105955:	e9 06 f6 ff ff       	jmp    80104f60 <alltraps>

8010595a <vector134>:
.globl vector134
vector134:
  pushl $0
8010595a:	6a 00                	push   $0x0
  pushl $134
8010595c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105961:	e9 fa f5 ff ff       	jmp    80104f60 <alltraps>

80105966 <vector135>:
.globl vector135
vector135:
  pushl $0
80105966:	6a 00                	push   $0x0
  pushl $135
80105968:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010596d:	e9 ee f5 ff ff       	jmp    80104f60 <alltraps>

80105972 <vector136>:
.globl vector136
vector136:
  pushl $0
80105972:	6a 00                	push   $0x0
  pushl $136
80105974:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105979:	e9 e2 f5 ff ff       	jmp    80104f60 <alltraps>

8010597e <vector137>:
.globl vector137
vector137:
  pushl $0
8010597e:	6a 00                	push   $0x0
  pushl $137
80105980:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105985:	e9 d6 f5 ff ff       	jmp    80104f60 <alltraps>

8010598a <vector138>:
.globl vector138
vector138:
  pushl $0
8010598a:	6a 00                	push   $0x0
  pushl $138
8010598c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105991:	e9 ca f5 ff ff       	jmp    80104f60 <alltraps>

80105996 <vector139>:
.globl vector139
vector139:
  pushl $0
80105996:	6a 00                	push   $0x0
  pushl $139
80105998:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010599d:	e9 be f5 ff ff       	jmp    80104f60 <alltraps>

801059a2 <vector140>:
.globl vector140
vector140:
  pushl $0
801059a2:	6a 00                	push   $0x0
  pushl $140
801059a4:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801059a9:	e9 b2 f5 ff ff       	jmp    80104f60 <alltraps>

801059ae <vector141>:
.globl vector141
vector141:
  pushl $0
801059ae:	6a 00                	push   $0x0
  pushl $141
801059b0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801059b5:	e9 a6 f5 ff ff       	jmp    80104f60 <alltraps>

801059ba <vector142>:
.globl vector142
vector142:
  pushl $0
801059ba:	6a 00                	push   $0x0
  pushl $142
801059bc:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801059c1:	e9 9a f5 ff ff       	jmp    80104f60 <alltraps>

801059c6 <vector143>:
.globl vector143
vector143:
  pushl $0
801059c6:	6a 00                	push   $0x0
  pushl $143
801059c8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801059cd:	e9 8e f5 ff ff       	jmp    80104f60 <alltraps>

801059d2 <vector144>:
.globl vector144
vector144:
  pushl $0
801059d2:	6a 00                	push   $0x0
  pushl $144
801059d4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801059d9:	e9 82 f5 ff ff       	jmp    80104f60 <alltraps>

801059de <vector145>:
.globl vector145
vector145:
  pushl $0
801059de:	6a 00                	push   $0x0
  pushl $145
801059e0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801059e5:	e9 76 f5 ff ff       	jmp    80104f60 <alltraps>

801059ea <vector146>:
.globl vector146
vector146:
  pushl $0
801059ea:	6a 00                	push   $0x0
  pushl $146
801059ec:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801059f1:	e9 6a f5 ff ff       	jmp    80104f60 <alltraps>

801059f6 <vector147>:
.globl vector147
vector147:
  pushl $0
801059f6:	6a 00                	push   $0x0
  pushl $147
801059f8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801059fd:	e9 5e f5 ff ff       	jmp    80104f60 <alltraps>

80105a02 <vector148>:
.globl vector148
vector148:
  pushl $0
80105a02:	6a 00                	push   $0x0
  pushl $148
80105a04:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105a09:	e9 52 f5 ff ff       	jmp    80104f60 <alltraps>

80105a0e <vector149>:
.globl vector149
vector149:
  pushl $0
80105a0e:	6a 00                	push   $0x0
  pushl $149
80105a10:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105a15:	e9 46 f5 ff ff       	jmp    80104f60 <alltraps>

80105a1a <vector150>:
.globl vector150
vector150:
  pushl $0
80105a1a:	6a 00                	push   $0x0
  pushl $150
80105a1c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105a21:	e9 3a f5 ff ff       	jmp    80104f60 <alltraps>

80105a26 <vector151>:
.globl vector151
vector151:
  pushl $0
80105a26:	6a 00                	push   $0x0
  pushl $151
80105a28:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105a2d:	e9 2e f5 ff ff       	jmp    80104f60 <alltraps>

80105a32 <vector152>:
.globl vector152
vector152:
  pushl $0
80105a32:	6a 00                	push   $0x0
  pushl $152
80105a34:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105a39:	e9 22 f5 ff ff       	jmp    80104f60 <alltraps>

80105a3e <vector153>:
.globl vector153
vector153:
  pushl $0
80105a3e:	6a 00                	push   $0x0
  pushl $153
80105a40:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105a45:	e9 16 f5 ff ff       	jmp    80104f60 <alltraps>

80105a4a <vector154>:
.globl vector154
vector154:
  pushl $0
80105a4a:	6a 00                	push   $0x0
  pushl $154
80105a4c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105a51:	e9 0a f5 ff ff       	jmp    80104f60 <alltraps>

80105a56 <vector155>:
.globl vector155
vector155:
  pushl $0
80105a56:	6a 00                	push   $0x0
  pushl $155
80105a58:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105a5d:	e9 fe f4 ff ff       	jmp    80104f60 <alltraps>

80105a62 <vector156>:
.globl vector156
vector156:
  pushl $0
80105a62:	6a 00                	push   $0x0
  pushl $156
80105a64:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105a69:	e9 f2 f4 ff ff       	jmp    80104f60 <alltraps>

80105a6e <vector157>:
.globl vector157
vector157:
  pushl $0
80105a6e:	6a 00                	push   $0x0
  pushl $157
80105a70:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105a75:	e9 e6 f4 ff ff       	jmp    80104f60 <alltraps>

80105a7a <vector158>:
.globl vector158
vector158:
  pushl $0
80105a7a:	6a 00                	push   $0x0
  pushl $158
80105a7c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105a81:	e9 da f4 ff ff       	jmp    80104f60 <alltraps>

80105a86 <vector159>:
.globl vector159
vector159:
  pushl $0
80105a86:	6a 00                	push   $0x0
  pushl $159
80105a88:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105a8d:	e9 ce f4 ff ff       	jmp    80104f60 <alltraps>

80105a92 <vector160>:
.globl vector160
vector160:
  pushl $0
80105a92:	6a 00                	push   $0x0
  pushl $160
80105a94:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105a99:	e9 c2 f4 ff ff       	jmp    80104f60 <alltraps>

80105a9e <vector161>:
.globl vector161
vector161:
  pushl $0
80105a9e:	6a 00                	push   $0x0
  pushl $161
80105aa0:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105aa5:	e9 b6 f4 ff ff       	jmp    80104f60 <alltraps>

80105aaa <vector162>:
.globl vector162
vector162:
  pushl $0
80105aaa:	6a 00                	push   $0x0
  pushl $162
80105aac:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105ab1:	e9 aa f4 ff ff       	jmp    80104f60 <alltraps>

80105ab6 <vector163>:
.globl vector163
vector163:
  pushl $0
80105ab6:	6a 00                	push   $0x0
  pushl $163
80105ab8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105abd:	e9 9e f4 ff ff       	jmp    80104f60 <alltraps>

80105ac2 <vector164>:
.globl vector164
vector164:
  pushl $0
80105ac2:	6a 00                	push   $0x0
  pushl $164
80105ac4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105ac9:	e9 92 f4 ff ff       	jmp    80104f60 <alltraps>

80105ace <vector165>:
.globl vector165
vector165:
  pushl $0
80105ace:	6a 00                	push   $0x0
  pushl $165
80105ad0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105ad5:	e9 86 f4 ff ff       	jmp    80104f60 <alltraps>

80105ada <vector166>:
.globl vector166
vector166:
  pushl $0
80105ada:	6a 00                	push   $0x0
  pushl $166
80105adc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105ae1:	e9 7a f4 ff ff       	jmp    80104f60 <alltraps>

80105ae6 <vector167>:
.globl vector167
vector167:
  pushl $0
80105ae6:	6a 00                	push   $0x0
  pushl $167
80105ae8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105aed:	e9 6e f4 ff ff       	jmp    80104f60 <alltraps>

80105af2 <vector168>:
.globl vector168
vector168:
  pushl $0
80105af2:	6a 00                	push   $0x0
  pushl $168
80105af4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105af9:	e9 62 f4 ff ff       	jmp    80104f60 <alltraps>

80105afe <vector169>:
.globl vector169
vector169:
  pushl $0
80105afe:	6a 00                	push   $0x0
  pushl $169
80105b00:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105b05:	e9 56 f4 ff ff       	jmp    80104f60 <alltraps>

80105b0a <vector170>:
.globl vector170
vector170:
  pushl $0
80105b0a:	6a 00                	push   $0x0
  pushl $170
80105b0c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105b11:	e9 4a f4 ff ff       	jmp    80104f60 <alltraps>

80105b16 <vector171>:
.globl vector171
vector171:
  pushl $0
80105b16:	6a 00                	push   $0x0
  pushl $171
80105b18:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105b1d:	e9 3e f4 ff ff       	jmp    80104f60 <alltraps>

80105b22 <vector172>:
.globl vector172
vector172:
  pushl $0
80105b22:	6a 00                	push   $0x0
  pushl $172
80105b24:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105b29:	e9 32 f4 ff ff       	jmp    80104f60 <alltraps>

80105b2e <vector173>:
.globl vector173
vector173:
  pushl $0
80105b2e:	6a 00                	push   $0x0
  pushl $173
80105b30:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105b35:	e9 26 f4 ff ff       	jmp    80104f60 <alltraps>

80105b3a <vector174>:
.globl vector174
vector174:
  pushl $0
80105b3a:	6a 00                	push   $0x0
  pushl $174
80105b3c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105b41:	e9 1a f4 ff ff       	jmp    80104f60 <alltraps>

80105b46 <vector175>:
.globl vector175
vector175:
  pushl $0
80105b46:	6a 00                	push   $0x0
  pushl $175
80105b48:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105b4d:	e9 0e f4 ff ff       	jmp    80104f60 <alltraps>

80105b52 <vector176>:
.globl vector176
vector176:
  pushl $0
80105b52:	6a 00                	push   $0x0
  pushl $176
80105b54:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105b59:	e9 02 f4 ff ff       	jmp    80104f60 <alltraps>

80105b5e <vector177>:
.globl vector177
vector177:
  pushl $0
80105b5e:	6a 00                	push   $0x0
  pushl $177
80105b60:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105b65:	e9 f6 f3 ff ff       	jmp    80104f60 <alltraps>

80105b6a <vector178>:
.globl vector178
vector178:
  pushl $0
80105b6a:	6a 00                	push   $0x0
  pushl $178
80105b6c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105b71:	e9 ea f3 ff ff       	jmp    80104f60 <alltraps>

80105b76 <vector179>:
.globl vector179
vector179:
  pushl $0
80105b76:	6a 00                	push   $0x0
  pushl $179
80105b78:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105b7d:	e9 de f3 ff ff       	jmp    80104f60 <alltraps>

80105b82 <vector180>:
.globl vector180
vector180:
  pushl $0
80105b82:	6a 00                	push   $0x0
  pushl $180
80105b84:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105b89:	e9 d2 f3 ff ff       	jmp    80104f60 <alltraps>

80105b8e <vector181>:
.globl vector181
vector181:
  pushl $0
80105b8e:	6a 00                	push   $0x0
  pushl $181
80105b90:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105b95:	e9 c6 f3 ff ff       	jmp    80104f60 <alltraps>

80105b9a <vector182>:
.globl vector182
vector182:
  pushl $0
80105b9a:	6a 00                	push   $0x0
  pushl $182
80105b9c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105ba1:	e9 ba f3 ff ff       	jmp    80104f60 <alltraps>

80105ba6 <vector183>:
.globl vector183
vector183:
  pushl $0
80105ba6:	6a 00                	push   $0x0
  pushl $183
80105ba8:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105bad:	e9 ae f3 ff ff       	jmp    80104f60 <alltraps>

80105bb2 <vector184>:
.globl vector184
vector184:
  pushl $0
80105bb2:	6a 00                	push   $0x0
  pushl $184
80105bb4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105bb9:	e9 a2 f3 ff ff       	jmp    80104f60 <alltraps>

80105bbe <vector185>:
.globl vector185
vector185:
  pushl $0
80105bbe:	6a 00                	push   $0x0
  pushl $185
80105bc0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105bc5:	e9 96 f3 ff ff       	jmp    80104f60 <alltraps>

80105bca <vector186>:
.globl vector186
vector186:
  pushl $0
80105bca:	6a 00                	push   $0x0
  pushl $186
80105bcc:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105bd1:	e9 8a f3 ff ff       	jmp    80104f60 <alltraps>

80105bd6 <vector187>:
.globl vector187
vector187:
  pushl $0
80105bd6:	6a 00                	push   $0x0
  pushl $187
80105bd8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105bdd:	e9 7e f3 ff ff       	jmp    80104f60 <alltraps>

80105be2 <vector188>:
.globl vector188
vector188:
  pushl $0
80105be2:	6a 00                	push   $0x0
  pushl $188
80105be4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105be9:	e9 72 f3 ff ff       	jmp    80104f60 <alltraps>

80105bee <vector189>:
.globl vector189
vector189:
  pushl $0
80105bee:	6a 00                	push   $0x0
  pushl $189
80105bf0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105bf5:	e9 66 f3 ff ff       	jmp    80104f60 <alltraps>

80105bfa <vector190>:
.globl vector190
vector190:
  pushl $0
80105bfa:	6a 00                	push   $0x0
  pushl $190
80105bfc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105c01:	e9 5a f3 ff ff       	jmp    80104f60 <alltraps>

80105c06 <vector191>:
.globl vector191
vector191:
  pushl $0
80105c06:	6a 00                	push   $0x0
  pushl $191
80105c08:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105c0d:	e9 4e f3 ff ff       	jmp    80104f60 <alltraps>

80105c12 <vector192>:
.globl vector192
vector192:
  pushl $0
80105c12:	6a 00                	push   $0x0
  pushl $192
80105c14:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105c19:	e9 42 f3 ff ff       	jmp    80104f60 <alltraps>

80105c1e <vector193>:
.globl vector193
vector193:
  pushl $0
80105c1e:	6a 00                	push   $0x0
  pushl $193
80105c20:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105c25:	e9 36 f3 ff ff       	jmp    80104f60 <alltraps>

80105c2a <vector194>:
.globl vector194
vector194:
  pushl $0
80105c2a:	6a 00                	push   $0x0
  pushl $194
80105c2c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105c31:	e9 2a f3 ff ff       	jmp    80104f60 <alltraps>

80105c36 <vector195>:
.globl vector195
vector195:
  pushl $0
80105c36:	6a 00                	push   $0x0
  pushl $195
80105c38:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105c3d:	e9 1e f3 ff ff       	jmp    80104f60 <alltraps>

80105c42 <vector196>:
.globl vector196
vector196:
  pushl $0
80105c42:	6a 00                	push   $0x0
  pushl $196
80105c44:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105c49:	e9 12 f3 ff ff       	jmp    80104f60 <alltraps>

80105c4e <vector197>:
.globl vector197
vector197:
  pushl $0
80105c4e:	6a 00                	push   $0x0
  pushl $197
80105c50:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105c55:	e9 06 f3 ff ff       	jmp    80104f60 <alltraps>

80105c5a <vector198>:
.globl vector198
vector198:
  pushl $0
80105c5a:	6a 00                	push   $0x0
  pushl $198
80105c5c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105c61:	e9 fa f2 ff ff       	jmp    80104f60 <alltraps>

80105c66 <vector199>:
.globl vector199
vector199:
  pushl $0
80105c66:	6a 00                	push   $0x0
  pushl $199
80105c68:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105c6d:	e9 ee f2 ff ff       	jmp    80104f60 <alltraps>

80105c72 <vector200>:
.globl vector200
vector200:
  pushl $0
80105c72:	6a 00                	push   $0x0
  pushl $200
80105c74:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105c79:	e9 e2 f2 ff ff       	jmp    80104f60 <alltraps>

80105c7e <vector201>:
.globl vector201
vector201:
  pushl $0
80105c7e:	6a 00                	push   $0x0
  pushl $201
80105c80:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105c85:	e9 d6 f2 ff ff       	jmp    80104f60 <alltraps>

80105c8a <vector202>:
.globl vector202
vector202:
  pushl $0
80105c8a:	6a 00                	push   $0x0
  pushl $202
80105c8c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105c91:	e9 ca f2 ff ff       	jmp    80104f60 <alltraps>

80105c96 <vector203>:
.globl vector203
vector203:
  pushl $0
80105c96:	6a 00                	push   $0x0
  pushl $203
80105c98:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105c9d:	e9 be f2 ff ff       	jmp    80104f60 <alltraps>

80105ca2 <vector204>:
.globl vector204
vector204:
  pushl $0
80105ca2:	6a 00                	push   $0x0
  pushl $204
80105ca4:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105ca9:	e9 b2 f2 ff ff       	jmp    80104f60 <alltraps>

80105cae <vector205>:
.globl vector205
vector205:
  pushl $0
80105cae:	6a 00                	push   $0x0
  pushl $205
80105cb0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105cb5:	e9 a6 f2 ff ff       	jmp    80104f60 <alltraps>

80105cba <vector206>:
.globl vector206
vector206:
  pushl $0
80105cba:	6a 00                	push   $0x0
  pushl $206
80105cbc:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105cc1:	e9 9a f2 ff ff       	jmp    80104f60 <alltraps>

80105cc6 <vector207>:
.globl vector207
vector207:
  pushl $0
80105cc6:	6a 00                	push   $0x0
  pushl $207
80105cc8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105ccd:	e9 8e f2 ff ff       	jmp    80104f60 <alltraps>

80105cd2 <vector208>:
.globl vector208
vector208:
  pushl $0
80105cd2:	6a 00                	push   $0x0
  pushl $208
80105cd4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105cd9:	e9 82 f2 ff ff       	jmp    80104f60 <alltraps>

80105cde <vector209>:
.globl vector209
vector209:
  pushl $0
80105cde:	6a 00                	push   $0x0
  pushl $209
80105ce0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105ce5:	e9 76 f2 ff ff       	jmp    80104f60 <alltraps>

80105cea <vector210>:
.globl vector210
vector210:
  pushl $0
80105cea:	6a 00                	push   $0x0
  pushl $210
80105cec:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105cf1:	e9 6a f2 ff ff       	jmp    80104f60 <alltraps>

80105cf6 <vector211>:
.globl vector211
vector211:
  pushl $0
80105cf6:	6a 00                	push   $0x0
  pushl $211
80105cf8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105cfd:	e9 5e f2 ff ff       	jmp    80104f60 <alltraps>

80105d02 <vector212>:
.globl vector212
vector212:
  pushl $0
80105d02:	6a 00                	push   $0x0
  pushl $212
80105d04:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105d09:	e9 52 f2 ff ff       	jmp    80104f60 <alltraps>

80105d0e <vector213>:
.globl vector213
vector213:
  pushl $0
80105d0e:	6a 00                	push   $0x0
  pushl $213
80105d10:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105d15:	e9 46 f2 ff ff       	jmp    80104f60 <alltraps>

80105d1a <vector214>:
.globl vector214
vector214:
  pushl $0
80105d1a:	6a 00                	push   $0x0
  pushl $214
80105d1c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105d21:	e9 3a f2 ff ff       	jmp    80104f60 <alltraps>

80105d26 <vector215>:
.globl vector215
vector215:
  pushl $0
80105d26:	6a 00                	push   $0x0
  pushl $215
80105d28:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105d2d:	e9 2e f2 ff ff       	jmp    80104f60 <alltraps>

80105d32 <vector216>:
.globl vector216
vector216:
  pushl $0
80105d32:	6a 00                	push   $0x0
  pushl $216
80105d34:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105d39:	e9 22 f2 ff ff       	jmp    80104f60 <alltraps>

80105d3e <vector217>:
.globl vector217
vector217:
  pushl $0
80105d3e:	6a 00                	push   $0x0
  pushl $217
80105d40:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105d45:	e9 16 f2 ff ff       	jmp    80104f60 <alltraps>

80105d4a <vector218>:
.globl vector218
vector218:
  pushl $0
80105d4a:	6a 00                	push   $0x0
  pushl $218
80105d4c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105d51:	e9 0a f2 ff ff       	jmp    80104f60 <alltraps>

80105d56 <vector219>:
.globl vector219
vector219:
  pushl $0
80105d56:	6a 00                	push   $0x0
  pushl $219
80105d58:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105d5d:	e9 fe f1 ff ff       	jmp    80104f60 <alltraps>

80105d62 <vector220>:
.globl vector220
vector220:
  pushl $0
80105d62:	6a 00                	push   $0x0
  pushl $220
80105d64:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105d69:	e9 f2 f1 ff ff       	jmp    80104f60 <alltraps>

80105d6e <vector221>:
.globl vector221
vector221:
  pushl $0
80105d6e:	6a 00                	push   $0x0
  pushl $221
80105d70:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105d75:	e9 e6 f1 ff ff       	jmp    80104f60 <alltraps>

80105d7a <vector222>:
.globl vector222
vector222:
  pushl $0
80105d7a:	6a 00                	push   $0x0
  pushl $222
80105d7c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105d81:	e9 da f1 ff ff       	jmp    80104f60 <alltraps>

80105d86 <vector223>:
.globl vector223
vector223:
  pushl $0
80105d86:	6a 00                	push   $0x0
  pushl $223
80105d88:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105d8d:	e9 ce f1 ff ff       	jmp    80104f60 <alltraps>

80105d92 <vector224>:
.globl vector224
vector224:
  pushl $0
80105d92:	6a 00                	push   $0x0
  pushl $224
80105d94:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105d99:	e9 c2 f1 ff ff       	jmp    80104f60 <alltraps>

80105d9e <vector225>:
.globl vector225
vector225:
  pushl $0
80105d9e:	6a 00                	push   $0x0
  pushl $225
80105da0:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105da5:	e9 b6 f1 ff ff       	jmp    80104f60 <alltraps>

80105daa <vector226>:
.globl vector226
vector226:
  pushl $0
80105daa:	6a 00                	push   $0x0
  pushl $226
80105dac:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105db1:	e9 aa f1 ff ff       	jmp    80104f60 <alltraps>

80105db6 <vector227>:
.globl vector227
vector227:
  pushl $0
80105db6:	6a 00                	push   $0x0
  pushl $227
80105db8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105dbd:	e9 9e f1 ff ff       	jmp    80104f60 <alltraps>

80105dc2 <vector228>:
.globl vector228
vector228:
  pushl $0
80105dc2:	6a 00                	push   $0x0
  pushl $228
80105dc4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105dc9:	e9 92 f1 ff ff       	jmp    80104f60 <alltraps>

80105dce <vector229>:
.globl vector229
vector229:
  pushl $0
80105dce:	6a 00                	push   $0x0
  pushl $229
80105dd0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105dd5:	e9 86 f1 ff ff       	jmp    80104f60 <alltraps>

80105dda <vector230>:
.globl vector230
vector230:
  pushl $0
80105dda:	6a 00                	push   $0x0
  pushl $230
80105ddc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105de1:	e9 7a f1 ff ff       	jmp    80104f60 <alltraps>

80105de6 <vector231>:
.globl vector231
vector231:
  pushl $0
80105de6:	6a 00                	push   $0x0
  pushl $231
80105de8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105ded:	e9 6e f1 ff ff       	jmp    80104f60 <alltraps>

80105df2 <vector232>:
.globl vector232
vector232:
  pushl $0
80105df2:	6a 00                	push   $0x0
  pushl $232
80105df4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105df9:	e9 62 f1 ff ff       	jmp    80104f60 <alltraps>

80105dfe <vector233>:
.globl vector233
vector233:
  pushl $0
80105dfe:	6a 00                	push   $0x0
  pushl $233
80105e00:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105e05:	e9 56 f1 ff ff       	jmp    80104f60 <alltraps>

80105e0a <vector234>:
.globl vector234
vector234:
  pushl $0
80105e0a:	6a 00                	push   $0x0
  pushl $234
80105e0c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105e11:	e9 4a f1 ff ff       	jmp    80104f60 <alltraps>

80105e16 <vector235>:
.globl vector235
vector235:
  pushl $0
80105e16:	6a 00                	push   $0x0
  pushl $235
80105e18:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105e1d:	e9 3e f1 ff ff       	jmp    80104f60 <alltraps>

80105e22 <vector236>:
.globl vector236
vector236:
  pushl $0
80105e22:	6a 00                	push   $0x0
  pushl $236
80105e24:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105e29:	e9 32 f1 ff ff       	jmp    80104f60 <alltraps>

80105e2e <vector237>:
.globl vector237
vector237:
  pushl $0
80105e2e:	6a 00                	push   $0x0
  pushl $237
80105e30:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105e35:	e9 26 f1 ff ff       	jmp    80104f60 <alltraps>

80105e3a <vector238>:
.globl vector238
vector238:
  pushl $0
80105e3a:	6a 00                	push   $0x0
  pushl $238
80105e3c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105e41:	e9 1a f1 ff ff       	jmp    80104f60 <alltraps>

80105e46 <vector239>:
.globl vector239
vector239:
  pushl $0
80105e46:	6a 00                	push   $0x0
  pushl $239
80105e48:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105e4d:	e9 0e f1 ff ff       	jmp    80104f60 <alltraps>

80105e52 <vector240>:
.globl vector240
vector240:
  pushl $0
80105e52:	6a 00                	push   $0x0
  pushl $240
80105e54:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105e59:	e9 02 f1 ff ff       	jmp    80104f60 <alltraps>

80105e5e <vector241>:
.globl vector241
vector241:
  pushl $0
80105e5e:	6a 00                	push   $0x0
  pushl $241
80105e60:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105e65:	e9 f6 f0 ff ff       	jmp    80104f60 <alltraps>

80105e6a <vector242>:
.globl vector242
vector242:
  pushl $0
80105e6a:	6a 00                	push   $0x0
  pushl $242
80105e6c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105e71:	e9 ea f0 ff ff       	jmp    80104f60 <alltraps>

80105e76 <vector243>:
.globl vector243
vector243:
  pushl $0
80105e76:	6a 00                	push   $0x0
  pushl $243
80105e78:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105e7d:	e9 de f0 ff ff       	jmp    80104f60 <alltraps>

80105e82 <vector244>:
.globl vector244
vector244:
  pushl $0
80105e82:	6a 00                	push   $0x0
  pushl $244
80105e84:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105e89:	e9 d2 f0 ff ff       	jmp    80104f60 <alltraps>

80105e8e <vector245>:
.globl vector245
vector245:
  pushl $0
80105e8e:	6a 00                	push   $0x0
  pushl $245
80105e90:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105e95:	e9 c6 f0 ff ff       	jmp    80104f60 <alltraps>

80105e9a <vector246>:
.globl vector246
vector246:
  pushl $0
80105e9a:	6a 00                	push   $0x0
  pushl $246
80105e9c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105ea1:	e9 ba f0 ff ff       	jmp    80104f60 <alltraps>

80105ea6 <vector247>:
.globl vector247
vector247:
  pushl $0
80105ea6:	6a 00                	push   $0x0
  pushl $247
80105ea8:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105ead:	e9 ae f0 ff ff       	jmp    80104f60 <alltraps>

80105eb2 <vector248>:
.globl vector248
vector248:
  pushl $0
80105eb2:	6a 00                	push   $0x0
  pushl $248
80105eb4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105eb9:	e9 a2 f0 ff ff       	jmp    80104f60 <alltraps>

80105ebe <vector249>:
.globl vector249
vector249:
  pushl $0
80105ebe:	6a 00                	push   $0x0
  pushl $249
80105ec0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105ec5:	e9 96 f0 ff ff       	jmp    80104f60 <alltraps>

80105eca <vector250>:
.globl vector250
vector250:
  pushl $0
80105eca:	6a 00                	push   $0x0
  pushl $250
80105ecc:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105ed1:	e9 8a f0 ff ff       	jmp    80104f60 <alltraps>

80105ed6 <vector251>:
.globl vector251
vector251:
  pushl $0
80105ed6:	6a 00                	push   $0x0
  pushl $251
80105ed8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105edd:	e9 7e f0 ff ff       	jmp    80104f60 <alltraps>

80105ee2 <vector252>:
.globl vector252
vector252:
  pushl $0
80105ee2:	6a 00                	push   $0x0
  pushl $252
80105ee4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105ee9:	e9 72 f0 ff ff       	jmp    80104f60 <alltraps>

80105eee <vector253>:
.globl vector253
vector253:
  pushl $0
80105eee:	6a 00                	push   $0x0
  pushl $253
80105ef0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105ef5:	e9 66 f0 ff ff       	jmp    80104f60 <alltraps>

80105efa <vector254>:
.globl vector254
vector254:
  pushl $0
80105efa:	6a 00                	push   $0x0
  pushl $254
80105efc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105f01:	e9 5a f0 ff ff       	jmp    80104f60 <alltraps>

80105f06 <vector255>:
.globl vector255
vector255:
  pushl $0
80105f06:	6a 00                	push   $0x0
  pushl $255
80105f08:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105f0d:	e9 4e f0 ff ff       	jmp    80104f60 <alltraps>
	...

80105f14 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105f14:	55                   	push   %ebp
80105f15:	89 e5                	mov    %esp,%ebp
80105f17:	57                   	push   %edi
80105f18:	56                   	push   %esi
80105f19:	53                   	push   %ebx
80105f1a:	83 ec 1c             	sub    $0x1c,%esp
80105f1d:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105f1f:	c1 ea 16             	shr    $0x16,%edx
80105f22:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105f25:	8b 37                	mov    (%edi),%esi
80105f27:	f7 c6 01 00 00 00    	test   $0x1,%esi
80105f2d:	74 21                	je     80105f50 <walkpgdir+0x3c>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105f2f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
80105f35:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105f3b:	c1 eb 0a             	shr    $0xa,%ebx
80105f3e:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
80105f44:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
}
80105f47:	83 c4 1c             	add    $0x1c,%esp
80105f4a:	5b                   	pop    %ebx
80105f4b:	5e                   	pop    %esi
80105f4c:	5f                   	pop    %edi
80105f4d:	5d                   	pop    %ebp
80105f4e:	c3                   	ret    
80105f4f:	90                   	nop

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105f50:	85 c9                	test   %ecx,%ecx
80105f52:	74 30                	je     80105f84 <walkpgdir+0x70>
80105f54:	e8 73 c3 ff ff       	call   801022cc <kalloc>
80105f59:	89 c6                	mov    %eax,%esi
80105f5b:	85 c0                	test   %eax,%eax
80105f5d:	74 25                	je     80105f84 <walkpgdir+0x70>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80105f5f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80105f66:	00 
80105f67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f6e:	00 
80105f6f:	89 04 24             	mov    %eax,(%esp)
80105f72:	e8 61 df ff ff       	call   80103ed8 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105f77:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80105f7d:	83 c8 07             	or     $0x7,%eax
80105f80:	89 07                	mov    %eax,(%edi)
80105f82:	eb b7                	jmp    80105f3b <walkpgdir+0x27>
  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
80105f84:	31 c0                	xor    %eax,%eax
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}
80105f86:	83 c4 1c             	add    $0x1c,%esp
80105f89:	5b                   	pop    %ebx
80105f8a:	5e                   	pop    %esi
80105f8b:	5f                   	pop    %edi
80105f8c:	5d                   	pop    %ebp
80105f8d:	c3                   	ret    
80105f8e:	66 90                	xchg   %ax,%ax

80105f90 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80105f90:	55                   	push   %ebp
80105f91:	89 e5                	mov    %esp,%ebp
80105f93:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80105f96:	e8 e9 d3 ff ff       	call   80103384 <cpuid>
80105f9b:	8d 14 80             	lea    (%eax,%eax,4),%edx
80105f9e:	8d 04 50             	lea    (%eax,%edx,2),%eax
80105fa1:	c1 e0 04             	shl    $0x4,%eax
80105fa4:	05 80 27 11 80       	add    $0x80112780,%eax
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105fa9:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80105faf:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80105fb5:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80105fb9:	c6 40 7d 9a          	movb   $0x9a,0x7d(%eax)
80105fbd:	c6 40 7e cf          	movb   $0xcf,0x7e(%eax)
80105fc1:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105fc5:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80105fcc:	ff ff 
80105fce:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80105fd5:	00 00 
80105fd7:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80105fde:	c6 80 85 00 00 00 92 	movb   $0x92,0x85(%eax)
80105fe5:	c6 80 86 00 00 00 cf 	movb   $0xcf,0x86(%eax)
80105fec:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105ff3:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80105ffa:	ff ff 
80105ffc:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80106003:	00 00 
80106005:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010600c:	c6 80 8d 00 00 00 fa 	movb   $0xfa,0x8d(%eax)
80106013:	c6 80 8e 00 00 00 cf 	movb   $0xcf,0x8e(%eax)
8010601a:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106021:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80106028:	ff ff 
8010602a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80106031:	00 00 
80106033:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010603a:	c6 80 95 00 00 00 f2 	movb   $0xf2,0x95(%eax)
80106041:	c6 80 96 00 00 00 cf 	movb   $0xcf,0x96(%eax)
80106048:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010604f:	83 c0 70             	add    $0x70,%eax
static inline void
lgdt(struct segdesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
80106052:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80106058:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
8010605c:	c1 e8 10             	shr    $0x10,%eax
8010605f:	66 89 45 f6          	mov    %ax,-0xa(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80106063:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106066:	0f 01 10             	lgdtl  (%eax)
}
80106069:	c9                   	leave  
8010606a:	c3                   	ret    
8010606b:	90                   	nop

8010606c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010606c:	55                   	push   %ebp
8010606d:	89 e5                	mov    %esp,%ebp
8010606f:	57                   	push   %edi
80106070:	56                   	push   %esi
80106071:	53                   	push   %ebx
80106072:	83 ec 1c             	sub    $0x1c,%esp
80106075:	8b 7d 0c             	mov    0xc(%ebp),%edi
80106078:	8b 75 14             	mov    0x14(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010607b:	89 fb                	mov    %edi,%ebx
8010607d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106083:	03 7d 10             	add    0x10(%ebp),%edi
80106086:	4f                   	dec    %edi
80106087:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
8010608d:	83 4d 18 01          	orl    $0x1,0x18(%ebp)
80106091:	eb 1d                	jmp    801060b0 <mappages+0x44>
80106093:	90                   	nop
  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
80106094:	f6 00 01             	testb  $0x1,(%eax)
80106097:	75 41                	jne    801060da <mappages+0x6e>
      panic("remap");
    *pte = pa | perm | PTE_P;
80106099:	8b 55 18             	mov    0x18(%ebp),%edx
8010609c:	09 f2                	or     %esi,%edx
8010609e:	89 10                	mov    %edx,(%eax)
    if(a == last)
801060a0:	39 fb                	cmp    %edi,%ebx
801060a2:	74 2c                	je     801060d0 <mappages+0x64>
      break;
    a += PGSIZE;
801060a4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
801060aa:	81 c6 00 10 00 00    	add    $0x1000,%esi
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801060b0:	b9 01 00 00 00       	mov    $0x1,%ecx
801060b5:	89 da                	mov    %ebx,%edx
801060b7:	8b 45 08             	mov    0x8(%ebp),%eax
801060ba:	e8 55 fe ff ff       	call   80105f14 <walkpgdir>
801060bf:	85 c0                	test   %eax,%eax
801060c1:	75 d1                	jne    80106094 <mappages+0x28>
      return -1;
801060c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
801060c8:	83 c4 1c             	add    $0x1c,%esp
801060cb:	5b                   	pop    %ebx
801060cc:	5e                   	pop    %esi
801060cd:	5f                   	pop    %edi
801060ce:	5d                   	pop    %ebp
801060cf:	c3                   	ret    
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801060d0:	31 c0                	xor    %eax,%eax
}
801060d2:	83 c4 1c             	add    $0x1c,%esp
801060d5:	5b                   	pop    %ebx
801060d6:	5e                   	pop    %esi
801060d7:	5f                   	pop    %edi
801060d8:	5d                   	pop    %ebp
801060d9:	c3                   	ret    
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
801060da:	c7 04 24 a0 70 10 80 	movl   $0x801070a0,(%esp)
801060e1:	e8 36 a2 ff ff       	call   8010031c <panic>
801060e6:	66 90                	xchg   %ax,%ax

801060e8 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801060e8:	55                   	push   %ebp
801060e9:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801060eb:	a1 a4 57 11 80       	mov    0x801157a4,%eax
801060f0:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060f5:	0f 22 d8             	mov    %eax,%cr3
}
801060f8:	5d                   	pop    %ebp
801060f9:	c3                   	ret    
801060fa:	66 90                	xchg   %ax,%ax

801060fc <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801060fc:	55                   	push   %ebp
801060fd:	89 e5                	mov    %esp,%ebp
801060ff:	57                   	push   %edi
80106100:	56                   	push   %esi
80106101:	53                   	push   %ebx
80106102:	83 ec 2c             	sub    $0x2c,%esp
80106105:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106108:	85 f6                	test   %esi,%esi
8010610a:	0f 84 c4 00 00 00    	je     801061d4 <switchuvm+0xd8>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106110:	8b 56 08             	mov    0x8(%esi),%edx
80106113:	85 d2                	test   %edx,%edx
80106115:	0f 84 d1 00 00 00    	je     801061ec <switchuvm+0xf0>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
8010611b:	8b 46 04             	mov    0x4(%esi),%eax
8010611e:	85 c0                	test   %eax,%eax
80106120:	0f 84 ba 00 00 00    	je     801061e0 <switchuvm+0xe4>
    panic("switchuvm: no pgdir");

  pushcli();
80106126:	e8 2d dc ff ff       	call   80103d58 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010612b:	e8 e0 d1 ff ff       	call   80103310 <mycpu>
80106130:	89 c3                	mov    %eax,%ebx
80106132:	e8 d9 d1 ff ff       	call   80103310 <mycpu>
80106137:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010613a:	e8 d1 d1 ff ff       	call   80103310 <mycpu>
8010613f:	89 c7                	mov    %eax,%edi
80106141:	e8 ca d1 ff ff       	call   80103310 <mycpu>
80106146:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010614d:	67 00 
8010614f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106152:	83 c2 08             	add    $0x8,%edx
80106155:	66 89 93 9a 00 00 00 	mov    %dx,0x9a(%ebx)
8010615c:	8d 57 08             	lea    0x8(%edi),%edx
8010615f:	c1 ea 10             	shr    $0x10,%edx
80106162:	88 93 9c 00 00 00    	mov    %dl,0x9c(%ebx)
80106168:	c6 83 9d 00 00 00 99 	movb   $0x99,0x9d(%ebx)
8010616f:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106176:	83 c0 08             	add    $0x8,%eax
80106179:	c1 e8 18             	shr    $0x18,%eax
8010617c:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106182:	e8 89 d1 ff ff       	call   80103310 <mycpu>
80106187:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010618e:	e8 7d d1 ff ff       	call   80103310 <mycpu>
80106193:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106199:	e8 72 d1 ff ff       	call   80103310 <mycpu>
8010619e:	8b 56 08             	mov    0x8(%esi),%edx
801061a1:	81 c2 00 10 00 00    	add    $0x1000,%edx
801061a7:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801061aa:	e8 61 d1 ff ff       	call   80103310 <mycpu>
801061af:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
}

static inline void
ltr(ushort sel)
{
  asm volatile("ltr %0" : : "r" (sel));
801061b5:	b8 28 00 00 00       	mov    $0x28,%eax
801061ba:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801061bd:	8b 46 04             	mov    0x4(%esi),%eax
801061c0:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801061c5:	0f 22 d8             	mov    %eax,%cr3
  popcli();
}
801061c8:	83 c4 2c             	add    $0x2c,%esp
801061cb:	5b                   	pop    %ebx
801061cc:	5e                   	pop    %esi
801061cd:	5f                   	pop    %edi
801061ce:	5d                   	pop    %ebp
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
  popcli();
801061cf:	e9 bc db ff ff       	jmp    80103d90 <popcli>
// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  if(p == 0)
    panic("switchuvm: no process");
801061d4:	c7 04 24 a6 70 10 80 	movl   $0x801070a6,(%esp)
801061db:	e8 3c a1 ff ff       	call   8010031c <panic>
  if(p->kstack == 0)
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
801061e0:	c7 04 24 d1 70 10 80 	movl   $0x801070d1,(%esp)
801061e7:	e8 30 a1 ff ff       	call   8010031c <panic>
switchuvm(struct proc *p)
{
  if(p == 0)
    panic("switchuvm: no process");
  if(p->kstack == 0)
    panic("switchuvm: no kstack");
801061ec:	c7 04 24 bc 70 10 80 	movl   $0x801070bc,(%esp)
801061f3:	e8 24 a1 ff ff       	call   8010031c <panic>

801061f8 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801061f8:	55                   	push   %ebp
801061f9:	89 e5                	mov    %esp,%ebp
801061fb:	57                   	push   %edi
801061fc:	56                   	push   %esi
801061fd:	53                   	push   %ebx
801061fe:	83 ec 3c             	sub    $0x3c,%esp
80106201:	8b 55 08             	mov    0x8(%ebp),%edx
80106204:	8b 7d 0c             	mov    0xc(%ebp),%edi
80106207:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
8010620a:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106210:	77 64                	ja     80106276 <inituvm+0x7e>
    panic("inituvm: more than a page");
  mem = kalloc();
80106212:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80106215:	e8 b2 c0 ff ff       	call   801022cc <kalloc>
8010621a:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010621c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106223:	00 
80106224:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010622b:	00 
8010622c:	89 04 24             	mov    %eax,(%esp)
8010622f:	e8 a4 dc ff ff       	call   80103ed8 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106234:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010623b:	00 
8010623c:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106242:	89 44 24 0c          	mov    %eax,0xc(%esp)
80106246:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010624d:	00 
8010624e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106255:	00 
80106256:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106259:	89 14 24             	mov    %edx,(%esp)
8010625c:	e8 0b fe ff ff       	call   8010606c <mappages>
  memmove(mem, init, sz);
80106261:	89 75 10             	mov    %esi,0x10(%ebp)
80106264:	89 7d 0c             	mov    %edi,0xc(%ebp)
80106267:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010626a:	83 c4 3c             	add    $0x3c,%esp
8010626d:	5b                   	pop    %ebx
8010626e:	5e                   	pop    %esi
8010626f:	5f                   	pop    %edi
80106270:	5d                   	pop    %ebp
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
80106271:	e9 f2 dc ff ff       	jmp    80103f68 <memmove>
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;

  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
80106276:	c7 04 24 e5 70 10 80 	movl   $0x801070e5,(%esp)
8010627d:	e8 9a a0 ff ff       	call   8010031c <panic>
80106282:	66 90                	xchg   %ax,%ax

80106284 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106284:	55                   	push   %ebp
80106285:	89 e5                	mov    %esp,%ebp
80106287:	57                   	push   %edi
80106288:	56                   	push   %esi
80106289:	53                   	push   %ebx
8010628a:	83 ec 2c             	sub    $0x2c,%esp
8010628d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106290:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
80106296:	0f 85 9d 00 00 00    	jne    80106339 <loaduvm+0xb5>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010629c:	8b 4d 18             	mov    0x18(%ebp),%ecx
8010629f:	85 c9                	test   %ecx,%ecx
801062a1:	74 71                	je     80106314 <loaduvm+0x90>
801062a3:	8b 75 18             	mov    0x18(%ebp),%esi
801062a6:	31 db                	xor    %ebx,%ebx
801062a8:	eb 40                	jmp    801062ea <loaduvm+0x66>
801062aa:	66 90                	xchg   %ax,%ax
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
801062ac:	89 f2                	mov    %esi,%edx
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801062ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
801062b2:	8b 4d 14             	mov    0x14(%ebp),%ecx
801062b5:	01 d9                	add    %ebx,%ecx
801062b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801062bb:	05 00 00 00 80       	add    $0x80000000,%eax
801062c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c4:	8b 45 10             	mov    0x10(%ebp),%eax
801062c7:	89 04 24             	mov    %eax,(%esp)
801062ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801062cd:	e8 a2 b5 ff ff       	call   80101874 <readi>
801062d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801062d5:	39 d0                	cmp    %edx,%eax
801062d7:	75 47                	jne    80106320 <loaduvm+0x9c>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801062d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062df:	81 ee 00 10 00 00    	sub    $0x1000,%esi
801062e5:	39 5d 18             	cmp    %ebx,0x18(%ebp)
801062e8:	76 2a                	jbe    80106314 <loaduvm+0x90>
}

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
801062ea:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801062ed:	31 c9                	xor    %ecx,%ecx
801062ef:	8b 45 08             	mov    0x8(%ebp),%eax
801062f2:	e8 1d fc ff ff       	call   80105f14 <walkpgdir>
801062f7:	85 c0                	test   %eax,%eax
801062f9:	74 32                	je     8010632d <loaduvm+0xa9>
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
801062fb:	8b 00                	mov    (%eax),%eax
801062fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106302:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106308:	76 a2                	jbe    801062ac <loaduvm+0x28>
      n = sz - i;
    else
      n = PGSIZE;
8010630a:	ba 00 10 00 00       	mov    $0x1000,%edx
8010630f:	eb 9d                	jmp    801062ae <loaduvm+0x2a>
80106311:	8d 76 00             	lea    0x0(%esi),%esi
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80106314:	31 c0                	xor    %eax,%eax
}
80106316:	83 c4 2c             	add    $0x2c,%esp
80106319:	5b                   	pop    %ebx
8010631a:	5e                   	pop    %esi
8010631b:	5f                   	pop    %edi
8010631c:	5d                   	pop    %ebp
8010631d:	c3                   	ret    
8010631e:	66 90                	xchg   %ax,%ax
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
80106320:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80106325:	83 c4 2c             	add    $0x2c,%esp
80106328:	5b                   	pop    %ebx
80106329:	5e                   	pop    %esi
8010632a:	5f                   	pop    %edi
8010632b:	5d                   	pop    %ebp
8010632c:	c3                   	ret    

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010632d:	c7 04 24 ff 70 10 80 	movl   $0x801070ff,(%esp)
80106334:	e8 e3 9f ff ff       	call   8010031c <panic>
{
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
80106339:	c7 04 24 6c 71 10 80 	movl   $0x8010716c,(%esp)
80106340:	e8 d7 9f ff ff       	call   8010031c <panic>
80106345:	8d 76 00             	lea    0x0(%esi),%esi

80106348 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106348:	55                   	push   %ebp
80106349:	89 e5                	mov    %esp,%ebp
8010634b:	57                   	push   %edi
8010634c:	56                   	push   %esi
8010634d:	53                   	push   %ebx
8010634e:	83 ec 2c             	sub    $0x2c,%esp
80106351:	8b 7d 08             	mov    0x8(%ebp),%edi
80106354:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106357:	39 75 10             	cmp    %esi,0x10(%ebp)
8010635a:	73 7c                	jae    801063d8 <deallocuvm+0x90>
    return oldsz;

  a = PGROUNDUP(newsz);
8010635c:	8b 5d 10             	mov    0x10(%ebp),%ebx
8010635f:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
80106365:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010636b:	39 de                	cmp    %ebx,%esi
8010636d:	77 38                	ja     801063a7 <deallocuvm+0x5f>
8010636f:	eb 5b                	jmp    801063cc <deallocuvm+0x84>
80106371:	8d 76 00             	lea    0x0(%esi),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
80106374:	8b 10                	mov    (%eax),%edx
80106376:	f6 c2 01             	test   $0x1,%dl
80106379:	74 22                	je     8010639d <deallocuvm+0x55>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010637b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80106381:	74 5f                	je     801063e2 <deallocuvm+0x9a>
        panic("kfree");
      char *v = P2V(pa);
80106383:	81 c2 00 00 00 80    	add    $0x80000000,%edx
      kfree(v);
80106389:	89 14 24             	mov    %edx,(%esp)
8010638c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010638f:	e8 f4 bd ff ff       	call   80102188 <kfree>
      *pte = 0;
80106394:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106397:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010639d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801063a3:	39 de                	cmp    %ebx,%esi
801063a5:	76 25                	jbe    801063cc <deallocuvm+0x84>
    pte = walkpgdir(pgdir, (char*)a, 0);
801063a7:	31 c9                	xor    %ecx,%ecx
801063a9:	89 da                	mov    %ebx,%edx
801063ab:	89 f8                	mov    %edi,%eax
801063ad:	e8 62 fb ff ff       	call   80105f14 <walkpgdir>
    if(!pte)
801063b2:	85 c0                	test   %eax,%eax
801063b4:	75 be                	jne    80106374 <deallocuvm+0x2c>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801063b6:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
801063bc:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801063c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801063c8:	39 de                	cmp    %ebx,%esi
801063ca:	77 db                	ja     801063a7 <deallocuvm+0x5f>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801063cc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801063cf:	83 c4 2c             	add    $0x2c,%esp
801063d2:	5b                   	pop    %ebx
801063d3:	5e                   	pop    %esi
801063d4:	5f                   	pop    %edi
801063d5:	5d                   	pop    %ebp
801063d6:	c3                   	ret    
801063d7:	90                   	nop
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;
801063d8:	89 f0                	mov    %esi,%eax
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
801063da:	83 c4 2c             	add    $0x2c,%esp
801063dd:	5b                   	pop    %ebx
801063de:	5e                   	pop    %esi
801063df:	5f                   	pop    %edi
801063e0:	5d                   	pop    %ebp
801063e1:	c3                   	ret    
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
801063e2:	c7 04 24 66 6a 10 80 	movl   $0x80106a66,(%esp)
801063e9:	e8 2e 9f ff ff       	call   8010031c <panic>
801063ee:	66 90                	xchg   %ax,%ax

801063f0 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801063f0:	55                   	push   %ebp
801063f1:	89 e5                	mov    %esp,%ebp
801063f3:	57                   	push   %edi
801063f4:	56                   	push   %esi
801063f5:	53                   	push   %ebx
801063f6:	83 ec 3c             	sub    $0x3c,%esp
801063f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801063fc:	8b 45 10             	mov    0x10(%ebp),%eax
801063ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106402:	85 c0                	test   %eax,%eax
80106404:	0f 88 c2 00 00 00    	js     801064cc <allocuvm+0xdc>
    return 0;
  if(newsz < oldsz)
8010640a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010640d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
80106410:	0f 82 a6 00 00 00    	jb     801064bc <allocuvm+0xcc>
    return oldsz;

  a = PGROUNDUP(oldsz);
80106416:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80106419:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
8010641f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
80106425:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80106428:	77 53                	ja     8010647d <allocuvm+0x8d>
8010642a:	e9 90 00 00 00       	jmp    801064bf <allocuvm+0xcf>
8010642f:	90                   	nop
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
80106430:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106437:	00 
80106438:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010643f:	00 
80106440:	89 04 24             	mov    %eax,(%esp)
80106443:	e8 90 da ff ff       	call   80103ed8 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106448:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010644f:	00 
80106450:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106456:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010645a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106461:	00 
80106462:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80106466:	89 3c 24             	mov    %edi,(%esp)
80106469:	e8 fe fb ff ff       	call   8010606c <mappages>
8010646e:	85 c0                	test   %eax,%eax
80106470:	78 6e                	js     801064e0 <allocuvm+0xf0>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80106472:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106478:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010647b:	76 42                	jbe    801064bf <allocuvm+0xcf>
    mem = kalloc();
8010647d:	e8 4a be ff ff       	call   801022cc <kalloc>
80106482:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80106484:	85 c0                	test   %eax,%eax
80106486:	75 a8                	jne    80106430 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
80106488:	c7 04 24 8b 6f 10 80 	movl   $0x80106f8b,(%esp)
8010648f:	e8 28 a1 ff ff       	call   801005bc <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106494:	8b 45 0c             	mov    0xc(%ebp),%eax
80106497:	89 44 24 08          	mov    %eax,0x8(%esp)
8010649b:	8b 45 10             	mov    0x10(%ebp),%eax
8010649e:	89 44 24 04          	mov    %eax,0x4(%esp)
801064a2:	89 3c 24             	mov    %edi,(%esp)
801064a5:	e8 9e fe ff ff       	call   80106348 <deallocuvm>
      return 0;
801064aa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}
801064b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064b4:	83 c4 3c             	add    $0x3c,%esp
801064b7:	5b                   	pop    %ebx
801064b8:	5e                   	pop    %esi
801064b9:	5f                   	pop    %edi
801064ba:	5d                   	pop    %ebp
801064bb:	c3                   	ret    
  uint a;

  if(newsz >= KERNBASE)
    return 0;
  if(newsz < oldsz)
    return oldsz;
801064bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}
801064bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064c2:	83 c4 3c             	add    $0x3c,%esp
801064c5:	5b                   	pop    %ebx
801064c6:	5e                   	pop    %esi
801064c7:	5f                   	pop    %edi
801064c8:	5d                   	pop    %ebp
801064c9:	c3                   	ret    
801064ca:	66 90                	xchg   %ax,%ax
{
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
    return 0;
801064cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}
801064d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064d6:	83 c4 3c             	add    $0x3c,%esp
801064d9:	5b                   	pop    %ebx
801064da:	5e                   	pop    %esi
801064db:	5f                   	pop    %edi
801064dc:	5d                   	pop    %ebp
801064dd:	c3                   	ret    
801064de:	66 90                	xchg   %ax,%ax
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
      cprintf("allocuvm out of memory (2)\n");
801064e0:	c7 04 24 a3 6f 10 80 	movl   $0x80106fa3,(%esp)
801064e7:	e8 d0 a0 ff ff       	call   801005bc <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801064ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801064ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801064f3:	8b 45 10             	mov    0x10(%ebp),%eax
801064f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801064fa:	89 3c 24             	mov    %edi,(%esp)
801064fd:	e8 46 fe ff ff       	call   80106348 <deallocuvm>
      kfree(mem);
80106502:	89 34 24             	mov    %esi,(%esp)
80106505:	e8 7e bc ff ff       	call   80102188 <kfree>
      return 0;
8010650a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }
  }
  return newsz;
}
80106511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106514:	83 c4 3c             	add    $0x3c,%esp
80106517:	5b                   	pop    %ebx
80106518:	5e                   	pop    %esi
80106519:	5f                   	pop    %edi
8010651a:	5d                   	pop    %ebp
8010651b:	c3                   	ret    

8010651c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010651c:	55                   	push   %ebp
8010651d:	89 e5                	mov    %esp,%ebp
8010651f:	56                   	push   %esi
80106520:	53                   	push   %ebx
80106521:	83 ec 10             	sub    $0x10,%esp
80106524:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint i;

  if(pgdir == 0)
80106527:	85 db                	test   %ebx,%ebx
80106529:	74 56                	je     80106581 <freevm+0x65>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010652b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106532:	00 
80106533:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010653a:	80 
8010653b:	89 1c 24             	mov    %ebx,(%esp)
8010653e:	e8 05 fe ff ff       	call   80106348 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106543:	31 f6                	xor    %esi,%esi
80106545:	eb 0a                	jmp    80106551 <freevm+0x35>
80106547:	90                   	nop
80106548:	46                   	inc    %esi
80106549:	81 fe 00 04 00 00    	cmp    $0x400,%esi
8010654f:	74 22                	je     80106573 <freevm+0x57>
    if(pgdir[i] & PTE_P){
80106551:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
80106554:	a8 01                	test   $0x1,%al
80106556:	74 f0                	je     80106548 <freevm+0x2c>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106558:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010655d:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106562:	89 04 24             	mov    %eax,(%esp)
80106565:	e8 1e bc ff ff       	call   80102188 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010656a:	46                   	inc    %esi
8010656b:	81 fe 00 04 00 00    	cmp    $0x400,%esi
80106571:	75 de                	jne    80106551 <freevm+0x35>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80106573:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80106576:	83 c4 10             	add    $0x10,%esp
80106579:	5b                   	pop    %ebx
8010657a:	5e                   	pop    %esi
8010657b:	5d                   	pop    %ebp
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010657c:	e9 07 bc ff ff       	jmp    80102188 <kfree>
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
80106581:	c7 04 24 1d 71 10 80 	movl   $0x8010711d,(%esp)
80106588:	e8 8f 9d ff ff       	call   8010031c <panic>
8010658d:	8d 76 00             	lea    0x0(%esi),%esi

80106590 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80106590:	55                   	push   %ebp
80106591:	89 e5                	mov    %esp,%ebp
80106593:	56                   	push   %esi
80106594:	53                   	push   %ebx
80106595:	83 ec 20             	sub    $0x20,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80106598:	e8 2f bd ff ff       	call   801022cc <kalloc>
8010659d:	89 c6                	mov    %eax,%esi
8010659f:	85 c0                	test   %eax,%eax
801065a1:	74 51                	je     801065f4 <setupkvm+0x64>
    return 0;
  memset(pgdir, 0, PGSIZE);
801065a3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801065aa:	00 
801065ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801065b2:	00 
801065b3:	89 04 24             	mov    %eax,(%esp)
801065b6:	e8 1d d9 ff ff       	call   80103ed8 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801065bb:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801065c0:	8b 53 04             	mov    0x4(%ebx),%edx
801065c3:	8b 43 0c             	mov    0xc(%ebx),%eax
801065c6:	89 44 24 10          	mov    %eax,0x10(%esp)
801065ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
801065ce:	8b 43 08             	mov    0x8(%ebx),%eax
801065d1:	29 d0                	sub    %edx,%eax
801065d3:	89 44 24 08          	mov    %eax,0x8(%esp)
801065d7:	8b 03                	mov    (%ebx),%eax
801065d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801065dd:	89 34 24             	mov    %esi,(%esp)
801065e0:	e8 87 fa ff ff       	call   8010606c <mappages>
801065e5:	85 c0                	test   %eax,%eax
801065e7:	78 17                	js     80106600 <setupkvm+0x70>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801065e9:	83 c3 10             	add    $0x10,%ebx
801065ec:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801065f2:	72 cc                	jb     801065c0 <setupkvm+0x30>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
}
801065f4:	89 f0                	mov    %esi,%eax
801065f6:	83 c4 20             	add    $0x20,%esp
801065f9:	5b                   	pop    %ebx
801065fa:	5e                   	pop    %esi
801065fb:	5d                   	pop    %ebp
801065fc:	c3                   	ret    
801065fd:	8d 76 00             	lea    0x0(%esi),%esi
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80106600:	89 34 24             	mov    %esi,(%esp)
80106603:	e8 14 ff ff ff       	call   8010651c <freevm>
      return 0;
80106608:	31 f6                	xor    %esi,%esi
    }
  return pgdir;
}
8010660a:	89 f0                	mov    %esi,%eax
8010660c:	83 c4 20             	add    $0x20,%esp
8010660f:	5b                   	pop    %ebx
80106610:	5e                   	pop    %esi
80106611:	5d                   	pop    %ebp
80106612:	c3                   	ret    
80106613:	90                   	nop

80106614 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80106614:	55                   	push   %ebp
80106615:	89 e5                	mov    %esp,%ebp
80106617:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010661a:	e8 71 ff ff ff       	call   80106590 <setupkvm>
8010661f:	a3 a4 57 11 80       	mov    %eax,0x801157a4
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106624:	05 00 00 00 80       	add    $0x80000000,%eax
80106629:	0f 22 d8             	mov    %eax,%cr3
void
kvmalloc(void)
{
  kpgdir = setupkvm();
  switchkvm();
}
8010662c:	c9                   	leave  
8010662d:	c3                   	ret    
8010662e:	66 90                	xchg   %ax,%ax

80106630 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106630:	55                   	push   %ebp
80106631:	89 e5                	mov    %esp,%ebp
80106633:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106636:	31 c9                	xor    %ecx,%ecx
80106638:	8b 55 0c             	mov    0xc(%ebp),%edx
8010663b:	8b 45 08             	mov    0x8(%ebp),%eax
8010663e:	e8 d1 f8 ff ff       	call   80105f14 <walkpgdir>
  if(pte == 0)
80106643:	85 c0                	test   %eax,%eax
80106645:	74 05                	je     8010664c <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106647:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010664a:	c9                   	leave  
8010664b:	c3                   	ret    
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
8010664c:	c7 04 24 2e 71 10 80 	movl   $0x8010712e,(%esp)
80106653:	e8 c4 9c ff ff       	call   8010031c <panic>

80106658 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106658:	55                   	push   %ebp
80106659:	89 e5                	mov    %esp,%ebp
8010665b:	57                   	push   %edi
8010665c:	56                   	push   %esi
8010665d:	53                   	push   %ebx
8010665e:	83 ec 3c             	sub    $0x3c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106661:	e8 2a ff ff ff       	call   80106590 <setupkvm>
80106666:	89 c6                	mov    %eax,%esi
80106668:	85 c0                	test   %eax,%eax
8010666a:	0f 84 98 00 00 00    	je     80106708 <copyuvm+0xb0>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106670:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80106673:	85 db                	test   %ebx,%ebx
80106675:	0f 84 8d 00 00 00    	je     80106708 <copyuvm+0xb0>
8010667b:	31 db                	xor    %ebx,%ebx
8010667d:	eb 5b                	jmp    801066da <copyuvm+0x82>
8010667f:	90                   	nop
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106680:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106687:	00 
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010668b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106690:	05 00 00 00 80       	add    $0x80000000,%eax
80106695:	89 44 24 04          	mov    %eax,0x4(%esp)
80106699:	89 3c 24             	mov    %edi,(%esp)
8010669c:	e8 c7 d8 ff ff       	call   80103f68 <memmove>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
801066a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066a4:	25 ff 0f 00 00       	and    $0xfff,%eax
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801066a9:	89 44 24 10          	mov    %eax,0x10(%esp)
801066ad:	8d 87 00 00 00 80    	lea    -0x80000000(%edi),%eax
801066b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
801066b7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801066be:	00 
801066bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801066c3:	89 34 24             	mov    %esi,(%esp)
801066c6:	e8 a1 f9 ff ff       	call   8010606c <mappages>
801066cb:	85 c0                	test   %eax,%eax
801066cd:	78 45                	js     80106714 <copyuvm+0xbc>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801066cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801066d5:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
801066d8:	76 2e                	jbe    80106708 <copyuvm+0xb0>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801066da:	31 c9                	xor    %ecx,%ecx
801066dc:	89 da                	mov    %ebx,%edx
801066de:	8b 45 08             	mov    0x8(%ebp),%eax
801066e1:	e8 2e f8 ff ff       	call   80105f14 <walkpgdir>
801066e6:	85 c0                	test   %eax,%eax
801066e8:	74 40                	je     8010672a <copyuvm+0xd2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801066ea:	8b 00                	mov    (%eax),%eax
801066ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801066ef:	a8 01                	test   $0x1,%al
801066f1:	74 2b                	je     8010671e <copyuvm+0xc6>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
801066f3:	e8 d4 bb ff ff       	call   801022cc <kalloc>
801066f8:	89 c7                	mov    %eax,%edi
801066fa:	85 c0                	test   %eax,%eax
801066fc:	75 82                	jne    80106680 <copyuvm+0x28>
    }
  }
  return d;

bad:
  freevm(d);
801066fe:	89 34 24             	mov    %esi,(%esp)
80106701:	e8 16 fe ff ff       	call   8010651c <freevm>
  return 0;
80106706:	31 f6                	xor    %esi,%esi
}
80106708:	89 f0                	mov    %esi,%eax
8010670a:	83 c4 3c             	add    $0x3c,%esp
8010670d:	5b                   	pop    %ebx
8010670e:	5e                   	pop    %esi
8010670f:	5f                   	pop    %edi
80106710:	5d                   	pop    %ebp
80106711:	c3                   	ret    
80106712:	66 90                	xchg   %ax,%ax
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
      kfree(mem);
80106714:	89 3c 24             	mov    %edi,(%esp)
80106717:	e8 6c ba ff ff       	call   80102188 <kfree>
      goto bad;
8010671c:	eb e0                	jmp    801066fe <copyuvm+0xa6>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
8010671e:	c7 04 24 52 71 10 80 	movl   $0x80107152,(%esp)
80106725:	e8 f2 9b ff ff       	call   8010031c <panic>

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
8010672a:	c7 04 24 38 71 10 80 	movl   $0x80107138,(%esp)
80106731:	e8 e6 9b ff ff       	call   8010031c <panic>
80106736:	66 90                	xchg   %ax,%ax

80106738 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106738:	55                   	push   %ebp
80106739:	89 e5                	mov    %esp,%ebp
8010673b:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010673e:	31 c9                	xor    %ecx,%ecx
80106740:	8b 55 0c             	mov    0xc(%ebp),%edx
80106743:	8b 45 08             	mov    0x8(%ebp),%eax
80106746:	e8 c9 f7 ff ff       	call   80105f14 <walkpgdir>
  if((*pte & PTE_P) == 0)
8010674b:	8b 00                	mov    (%eax),%eax
8010674d:	a8 01                	test   $0x1,%al
8010674f:	74 13                	je     80106764 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106751:	a8 04                	test   $0x4,%al
80106753:	74 0f                	je     80106764 <uva2ka+0x2c>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106755:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010675a:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010675f:	c9                   	leave  
80106760:	c3                   	ret    
80106761:	8d 76 00             	lea    0x0(%esi),%esi

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
80106764:	31 c0                	xor    %eax,%eax
  return (char*)P2V(PTE_ADDR(*pte));
}
80106766:	c9                   	leave  
80106767:	c3                   	ret    

80106768 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106768:	55                   	push   %ebp
80106769:	89 e5                	mov    %esp,%ebp
8010676b:	57                   	push   %edi
8010676c:	56                   	push   %esi
8010676d:	53                   	push   %ebx
8010676e:	83 ec 2c             	sub    $0x2c,%esp
80106771:	8b 7d 0c             	mov    0xc(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106774:	8b 75 14             	mov    0x14(%ebp),%esi
80106777:	85 f6                	test   %esi,%esi
80106779:	74 69                	je     801067e4 <copyout+0x7c>
8010677b:	8b 55 10             	mov    0x10(%ebp),%edx
8010677e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80106781:	eb 38                	jmp    801067bb <copyout+0x53>
80106783:	90                   	nop
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
80106784:	89 f3                	mov    %esi,%ebx
80106786:	29 fb                	sub    %edi,%ebx
80106788:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010678e:	3b 5d 14             	cmp    0x14(%ebp),%ebx
80106791:	76 03                	jbe    80106796 <copyout+0x2e>
80106793:	8b 5d 14             	mov    0x14(%ebp),%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106796:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010679a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010679d:	89 54 24 04          	mov    %edx,0x4(%esp)
801067a1:	29 f7                	sub    %esi,%edi
801067a3:	01 c7                	add    %eax,%edi
801067a5:	89 3c 24             	mov    %edi,(%esp)
801067a8:	e8 bb d7 ff ff       	call   80103f68 <memmove>
    len -= n;
    buf += n;
801067ad:	01 5d e4             	add    %ebx,-0x1c(%ebp)
    va = va0 + PGSIZE;
801067b0:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801067b6:	29 5d 14             	sub    %ebx,0x14(%ebp)
801067b9:	74 29                	je     801067e4 <copyout+0x7c>
    va0 = (uint)PGROUNDDOWN(va);
801067bb:	89 fe                	mov    %edi,%esi
801067bd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801067c3:	89 74 24 04          	mov    %esi,0x4(%esp)
801067c7:	8b 55 08             	mov    0x8(%ebp),%edx
801067ca:	89 14 24             	mov    %edx,(%esp)
801067cd:	e8 66 ff ff ff       	call   80106738 <uva2ka>
    if(pa0 == 0)
801067d2:	85 c0                	test   %eax,%eax
801067d4:	75 ae                	jne    80106784 <copyout+0x1c>
      return -1;
801067d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
801067db:	83 c4 2c             	add    $0x2c,%esp
801067de:	5b                   	pop    %ebx
801067df:	5e                   	pop    %esi
801067e0:	5f                   	pop    %edi
801067e1:	5d                   	pop    %ebp
801067e2:	c3                   	ret    
801067e3:	90                   	nop
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801067e4:	31 c0                	xor    %eax,%eax
}
801067e6:	83 c4 2c             	add    $0x2c,%esp
801067e9:	5b                   	pop    %ebx
801067ea:	5e                   	pop    %esi
801067eb:	5f                   	pop    %edi
801067ec:	5d                   	pop    %ebp
801067ed:	c3                   	ret    
