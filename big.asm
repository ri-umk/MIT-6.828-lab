
_big:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	81 ec 20 02 00 00    	sub    $0x220,%esp
  char buf[512];
  int fd, i, sectors;

  fd = open("big.file", O_CREATE | O_WRONLY);
   f:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  16:	00 
  17:	c7 04 24 08 07 00 00 	movl   $0x708,(%esp)
  1e:	e8 51 03 00 00       	call   374 <open>
  23:	89 c7                	mov    %eax,%edi
  if(fd < 0){
  25:	85 c0                	test   %eax,%eax
  27:	0f 88 11 01 00 00    	js     13e <main+0x13e>
  2d:	31 db                	xor    %ebx,%ebx
  2f:	8d 74 24 20          	lea    0x20(%esp),%esi
  33:	90                   	nop
    exit();
  }

  sectors = 0;
  while(1){
    *(int*)buf = sectors;
  34:	89 5c 24 20          	mov    %ebx,0x20(%esp)
    int cc = write(fd, buf, sizeof(buf));
  38:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  3f:	00 
  40:	89 74 24 04          	mov    %esi,0x4(%esp)
  44:	89 3c 24             	mov    %edi,(%esp)
  47:	e8 08 03 00 00       	call   354 <write>
    if(cc <= 0)
  4c:	85 c0                	test   %eax,%eax
  4e:	7e 28                	jle    78 <main+0x78>
      break;
    sectors++;
  50:	43                   	inc    %ebx
	if (sectors % 100 == 0)
  51:	89 d8                	mov    %ebx,%eax
  53:	b9 64 00 00 00       	mov    $0x64,%ecx
  58:	99                   	cltd   
  59:	f7 f9                	idiv   %ecx
  5b:	85 d2                	test   %edx,%edx
  5d:	75 d5                	jne    34 <main+0x34>
		printf(2, ".");
  5f:	c7 44 24 04 11 07 00 	movl   $0x711,0x4(%esp)
  66:	00 
  67:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  6e:	e8 01 04 00 00       	call   474 <printf>
  73:	eb bf                	jmp    34 <main+0x34>
  75:	8d 76 00             	lea    0x0(%esi),%esi
  }

  printf(1, "\nwrote %d sectors\n", sectors);
  78:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  7c:	c7 44 24 04 13 07 00 	movl   $0x713,0x4(%esp)
  83:	00 
  84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8b:	e8 e4 03 00 00       	call   474 <printf>

  close(fd);
  90:	89 3c 24             	mov    %edi,(%esp)
  93:	e8 c4 02 00 00       	call   35c <close>
  fd = open("big.file", O_RDONLY);
  98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  9f:	00 
  a0:	c7 04 24 08 07 00 00 	movl   $0x708,(%esp)
  a7:	e8 c8 02 00 00       	call   374 <open>
  ac:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  if(fd < 0){
  b0:	85 c0                	test   %eax,%eax
  b2:	0f 88 9f 00 00 00    	js     157 <main+0x157>
    printf(2, "big: cannot re-open big.file for reading\n");
    exit();
  }
  for(i = 0; i < sectors; i++){
  b8:	85 db                	test   %ebx,%ebx
  ba:	74 48                	je     104 <main+0x104>
  bc:	31 ff                	xor    %edi,%edi
  be:	eb 0b                	jmp    cb <main+0xcb>
    int cc = read(fd, buf, sizeof(buf));
    if(cc <= 0){
      printf(2, "big: read error at sector %d\n", i);
      exit();
    }
    if(*(int*)buf != i){
  c0:	8b 06                	mov    (%esi),%eax
  c2:	39 f8                	cmp    %edi,%eax
  c4:	75 57                	jne    11d <main+0x11d>
  fd = open("big.file", O_RDONLY);
  if(fd < 0){
    printf(2, "big: cannot re-open big.file for reading\n");
    exit();
  }
  for(i = 0; i < sectors; i++){
  c6:	47                   	inc    %edi
  c7:	39 df                	cmp    %ebx,%edi
  c9:	74 39                	je     104 <main+0x104>
    int cc = read(fd, buf, sizeof(buf));
  cb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  d2:	00 
  d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  d7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  db:	89 04 24             	mov    %eax,(%esp)
  de:	e8 69 02 00 00       	call   34c <read>
    if(cc <= 0){
  e3:	85 c0                	test   %eax,%eax
  e5:	7f d9                	jg     c0 <main+0xc0>
      printf(2, "big: read error at sector %d\n", i);
  e7:	89 7c 24 08          	mov    %edi,0x8(%esp)
  eb:	c7 44 24 04 26 07 00 	movl   $0x726,0x4(%esp)
  f2:	00 
  f3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  fa:	e8 75 03 00 00       	call   474 <printf>
      exit();
  ff:	e8 30 02 00 00       	call   334 <exit>
             *(int*)buf, i);
      exit();
    }
  }

  printf(1, "done; ok\n"); 
 104:	c7 44 24 04 44 07 00 	movl   $0x744,0x4(%esp)
 10b:	00 
 10c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 113:	e8 5c 03 00 00       	call   474 <printf>

  exit();
 118:	e8 17 02 00 00       	call   334 <exit>
    if(cc <= 0){
      printf(2, "big: read error at sector %d\n", i);
      exit();
    }
    if(*(int*)buf != i){
      printf(2, "big: read the wrong data (%d) for sector %d\n",
 11d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
 121:	89 44 24 08          	mov    %eax,0x8(%esp)
 125:	c7 44 24 04 a4 07 00 	movl   $0x7a4,0x4(%esp)
 12c:	00 
 12d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 134:	e8 3b 03 00 00       	call   474 <printf>
             *(int*)buf, i);
      exit();
 139:	e8 f6 01 00 00       	call   334 <exit>
  char buf[512];
  int fd, i, sectors;

  fd = open("big.file", O_CREATE | O_WRONLY);
  if(fd < 0){
    printf(2, "big: cannot open big.file for writing\n");
 13e:	c7 44 24 04 50 07 00 	movl   $0x750,0x4(%esp)
 145:	00 
 146:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 14d:	e8 22 03 00 00       	call   474 <printf>
    exit();
 152:	e8 dd 01 00 00       	call   334 <exit>
  printf(1, "\nwrote %d sectors\n", sectors);

  close(fd);
  fd = open("big.file", O_RDONLY);
  if(fd < 0){
    printf(2, "big: cannot re-open big.file for reading\n");
 157:	c7 44 24 04 78 07 00 	movl   $0x778,0x4(%esp)
 15e:	00 
 15f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 166:	e8 09 03 00 00       	call   474 <printf>
    exit();
 16b:	e8 c4 01 00 00       	call   334 <exit>

00000170 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	53                   	push   %ebx
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 17a:	31 d2                	xor    %edx,%edx
 17c:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
 17f:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 182:	42                   	inc    %edx
 183:	84 c9                	test   %cl,%cl
 185:	75 f5                	jne    17c <strcpy+0xc>
    ;
  return os;
}
 187:	5b                   	pop    %ebx
 188:	5d                   	pop    %ebp
 189:	c3                   	ret    
 18a:	66 90                	xchg   %ax,%ax

0000018c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
 18f:	56                   	push   %esi
 190:	53                   	push   %ebx
 191:	8b 4d 08             	mov    0x8(%ebp),%ecx
 194:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 197:	8a 01                	mov    (%ecx),%al
 199:	8a 1a                	mov    (%edx),%bl
 19b:	84 c0                	test   %al,%al
 19d:	74 1d                	je     1bc <strcmp+0x30>
 19f:	38 d8                	cmp    %bl,%al
 1a1:	74 0c                	je     1af <strcmp+0x23>
 1a3:	eb 23                	jmp    1c8 <strcmp+0x3c>
 1a5:	8d 76 00             	lea    0x0(%esi),%esi
 1a8:	41                   	inc    %ecx
 1a9:	38 d8                	cmp    %bl,%al
 1ab:	75 1b                	jne    1c8 <strcmp+0x3c>
    p++, q++;
 1ad:	89 f2                	mov    %esi,%edx
 1af:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1b2:	8a 41 01             	mov    0x1(%ecx),%al
 1b5:	8a 5a 01             	mov    0x1(%edx),%bl
 1b8:	84 c0                	test   %al,%al
 1ba:	75 ec                	jne    1a8 <strcmp+0x1c>
 1bc:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1be:	0f b6 db             	movzbl %bl,%ebx
 1c1:	29 d8                	sub    %ebx,%eax
}
 1c3:	5b                   	pop    %ebx
 1c4:	5e                   	pop    %esi
 1c5:	5d                   	pop    %ebp
 1c6:	c3                   	ret    
 1c7:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1c8:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1cb:	0f b6 db             	movzbl %bl,%ebx
 1ce:	29 d8                	sub    %ebx,%eax
}
 1d0:	5b                   	pop    %ebx
 1d1:	5e                   	pop    %esi
 1d2:	5d                   	pop    %ebp
 1d3:	c3                   	ret    

000001d4 <strlen>:

uint
strlen(const char *s)
{
 1d4:	55                   	push   %ebp
 1d5:	89 e5                	mov    %esp,%ebp
 1d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1da:	80 39 00             	cmpb   $0x0,(%ecx)
 1dd:	74 10                	je     1ef <strlen+0x1b>
 1df:	31 d2                	xor    %edx,%edx
 1e1:	8d 76 00             	lea    0x0(%esi),%esi
 1e4:	42                   	inc    %edx
 1e5:	89 d0                	mov    %edx,%eax
 1e7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1eb:	75 f7                	jne    1e4 <strlen+0x10>
    ;
  return n;
}
 1ed:	5d                   	pop    %ebp
 1ee:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
 1ef:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
 1f1:	5d                   	pop    %ebp
 1f2:	c3                   	ret    
 1f3:	90                   	nop

000001f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f4:	55                   	push   %ebp
 1f5:	89 e5                	mov    %esp,%ebp
 1f7:	57                   	push   %edi
 1f8:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1fb:	89 d7                	mov    %edx,%edi
 1fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 200:	8b 45 0c             	mov    0xc(%ebp),%eax
 203:	fc                   	cld    
 204:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 206:	89 d0                	mov    %edx,%eax
 208:	5f                   	pop    %edi
 209:	5d                   	pop    %ebp
 20a:	c3                   	ret    
 20b:	90                   	nop

0000020c <strchr>:

char*
strchr(const char *s, char c)
{
 20c:	55                   	push   %ebp
 20d:	89 e5                	mov    %esp,%ebp
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 215:	8a 10                	mov    (%eax),%dl
 217:	84 d2                	test   %dl,%dl
 219:	75 0d                	jne    228 <strchr+0x1c>
 21b:	eb 13                	jmp    230 <strchr+0x24>
 21d:	8d 76 00             	lea    0x0(%esi),%esi
 220:	8a 50 01             	mov    0x1(%eax),%dl
 223:	84 d2                	test   %dl,%dl
 225:	74 09                	je     230 <strchr+0x24>
 227:	40                   	inc    %eax
    if(*s == c)
 228:	38 ca                	cmp    %cl,%dl
 22a:	75 f4                	jne    220 <strchr+0x14>
      return (char*)s;
  return 0;
}
 22c:	5d                   	pop    %ebp
 22d:	c3                   	ret    
 22e:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 230:	31 c0                	xor    %eax,%eax
}
 232:	5d                   	pop    %ebp
 233:	c3                   	ret    

00000234 <gets>:

char*
gets(char *buf, int max)
{
 234:	55                   	push   %ebp
 235:	89 e5                	mov    %esp,%ebp
 237:	57                   	push   %edi
 238:	56                   	push   %esi
 239:	53                   	push   %ebx
 23a:	83 ec 2c             	sub    $0x2c,%esp
 23d:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 240:	31 f6                	xor    %esi,%esi
 242:	eb 30                	jmp    274 <gets+0x40>
    cc = read(0, &c, 1);
 244:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 24b:	00 
 24c:	8d 45 e7             	lea    -0x19(%ebp),%eax
 24f:	89 44 24 04          	mov    %eax,0x4(%esp)
 253:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 25a:	e8 ed 00 00 00       	call   34c <read>
    if(cc < 1)
 25f:	85 c0                	test   %eax,%eax
 261:	7e 19                	jle    27c <gets+0x48>
      break;
    buf[i++] = c;
 263:	8a 45 e7             	mov    -0x19(%ebp),%al
 266:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26a:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 26c:	3c 0a                	cmp    $0xa,%al
 26e:	74 0c                	je     27c <gets+0x48>
 270:	3c 0d                	cmp    $0xd,%al
 272:	74 08                	je     27c <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 274:	8d 5e 01             	lea    0x1(%esi),%ebx
 277:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 27a:	7c c8                	jl     244 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 27c:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 280:	89 f8                	mov    %edi,%eax
 282:	83 c4 2c             	add    $0x2c,%esp
 285:	5b                   	pop    %ebx
 286:	5e                   	pop    %esi
 287:	5f                   	pop    %edi
 288:	5d                   	pop    %ebp
 289:	c3                   	ret    
 28a:	66 90                	xchg   %ax,%ax

0000028c <stat>:

int
stat(const char *n, struct stat *st)
{
 28c:	55                   	push   %ebp
 28d:	89 e5                	mov    %esp,%ebp
 28f:	56                   	push   %esi
 290:	53                   	push   %ebx
 291:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 294:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 29b:	00 
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	89 04 24             	mov    %eax,(%esp)
 2a2:	e8 cd 00 00 00       	call   374 <open>
 2a7:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 2a9:	85 c0                	test   %eax,%eax
 2ab:	78 23                	js     2d0 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 2ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b0:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b4:	89 1c 24             	mov    %ebx,(%esp)
 2b7:	e8 d0 00 00 00       	call   38c <fstat>
 2bc:	89 c6                	mov    %eax,%esi
  close(fd);
 2be:	89 1c 24             	mov    %ebx,(%esp)
 2c1:	e8 96 00 00 00       	call   35c <close>
  return r;
}
 2c6:	89 f0                	mov    %esi,%eax
 2c8:	83 c4 10             	add    $0x10,%esp
 2cb:	5b                   	pop    %ebx
 2cc:	5e                   	pop    %esi
 2cd:	5d                   	pop    %ebp
 2ce:	c3                   	ret    
 2cf:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 2d0:	be ff ff ff ff       	mov    $0xffffffff,%esi
 2d5:	eb ef                	jmp    2c6 <stat+0x3a>
 2d7:	90                   	nop

000002d8 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 2d8:	55                   	push   %ebp
 2d9:	89 e5                	mov    %esp,%ebp
 2db:	53                   	push   %ebx
 2dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2df:	8a 11                	mov    (%ecx),%dl
 2e1:	8d 42 d0             	lea    -0x30(%edx),%eax
 2e4:	3c 09                	cmp    $0x9,%al
 2e6:	b8 00 00 00 00       	mov    $0x0,%eax
 2eb:	77 18                	ja     305 <atoi+0x2d>
 2ed:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 2f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
 2f3:	0f be d2             	movsbl %dl,%edx
 2f6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 2fa:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fb:	8a 11                	mov    (%ecx),%dl
 2fd:	8d 5a d0             	lea    -0x30(%edx),%ebx
 300:	80 fb 09             	cmp    $0x9,%bl
 303:	76 eb                	jbe    2f0 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 305:	5b                   	pop    %ebx
 306:	5d                   	pop    %ebp
 307:	c3                   	ret    

00000308 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 308:	55                   	push   %ebp
 309:	89 e5                	mov    %esp,%ebp
 30b:	56                   	push   %esi
 30c:	53                   	push   %ebx
 30d:	8b 45 08             	mov    0x8(%ebp),%eax
 310:	8b 75 0c             	mov    0xc(%ebp),%esi
 313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 316:	85 db                	test   %ebx,%ebx
 318:	7e 0d                	jle    327 <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 31a:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 31c:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 31f:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 322:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 323:	39 da                	cmp    %ebx,%edx
 325:	75 f5                	jne    31c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 327:	5b                   	pop    %ebx
 328:	5e                   	pop    %esi
 329:	5d                   	pop    %ebp
 32a:	c3                   	ret    
 32b:	90                   	nop

0000032c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 32c:	b8 01 00 00 00       	mov    $0x1,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <exit>:
SYSCALL(exit)
 334:	b8 02 00 00 00       	mov    $0x2,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <wait>:
SYSCALL(wait)
 33c:	b8 03 00 00 00       	mov    $0x3,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <pipe>:
SYSCALL(pipe)
 344:	b8 04 00 00 00       	mov    $0x4,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <read>:
SYSCALL(read)
 34c:	b8 05 00 00 00       	mov    $0x5,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <write>:
SYSCALL(write)
 354:	b8 10 00 00 00       	mov    $0x10,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <close>:
SYSCALL(close)
 35c:	b8 15 00 00 00       	mov    $0x15,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <kill>:
SYSCALL(kill)
 364:	b8 06 00 00 00       	mov    $0x6,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <exec>:
SYSCALL(exec)
 36c:	b8 07 00 00 00       	mov    $0x7,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <open>:
SYSCALL(open)
 374:	b8 0f 00 00 00       	mov    $0xf,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <mknod>:
SYSCALL(mknod)
 37c:	b8 11 00 00 00       	mov    $0x11,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <unlink>:
SYSCALL(unlink)
 384:	b8 12 00 00 00       	mov    $0x12,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <fstat>:
SYSCALL(fstat)
 38c:	b8 08 00 00 00       	mov    $0x8,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <link>:
SYSCALL(link)
 394:	b8 13 00 00 00       	mov    $0x13,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <mkdir>:
SYSCALL(mkdir)
 39c:	b8 14 00 00 00       	mov    $0x14,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <chdir>:
SYSCALL(chdir)
 3a4:	b8 09 00 00 00       	mov    $0x9,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <dup>:
SYSCALL(dup)
 3ac:	b8 0a 00 00 00       	mov    $0xa,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <getpid>:
SYSCALL(getpid)
 3b4:	b8 0b 00 00 00       	mov    $0xb,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <sbrk>:
SYSCALL(sbrk)
 3bc:	b8 0c 00 00 00       	mov    $0xc,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <sleep>:
SYSCALL(sleep)
 3c4:	b8 0d 00 00 00       	mov    $0xd,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <uptime>:
SYSCALL(uptime)
 3cc:	b8 0e 00 00 00       	mov    $0xe,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <date>:
SYSCALL(date)
 3d4:	b8 16 00 00 00       	mov    $0x16,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <alarm>:
SYSCALL(alarm)
 3dc:	b8 17 00 00 00       	mov    $0x17,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3e4:	55                   	push   %ebp
 3e5:	89 e5                	mov    %esp,%ebp
 3e7:	83 ec 28             	sub    $0x28,%esp
 3ea:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3f4:	00 
 3f5:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3f8:	89 54 24 04          	mov    %edx,0x4(%esp)
 3fc:	89 04 24             	mov    %eax,(%esp)
 3ff:	e8 50 ff ff ff       	call   354 <write>
}
 404:	c9                   	leave  
 405:	c3                   	ret    
 406:	66 90                	xchg   %ax,%ax

00000408 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 408:	55                   	push   %ebp
 409:	89 e5                	mov    %esp,%ebp
 40b:	57                   	push   %edi
 40c:	56                   	push   %esi
 40d:	53                   	push   %ebx
 40e:	83 ec 1c             	sub    $0x1c,%esp
 411:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 413:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 415:	8b 5d 08             	mov    0x8(%ebp),%ebx
 418:	85 db                	test   %ebx,%ebx
 41a:	74 04                	je     420 <printint+0x18>
 41c:	85 d2                	test   %edx,%edx
 41e:	78 4a                	js     46a <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 420:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 422:	31 db                	xor    %ebx,%ebx
 424:	eb 04                	jmp    42a <printint+0x22>
 426:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 428:	89 d3                	mov    %edx,%ebx
 42a:	31 d2                	xor    %edx,%edx
 42c:	f7 f1                	div    %ecx
 42e:	8a 92 db 07 00 00    	mov    0x7db(%edx),%dl
 434:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 438:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 43b:	85 c0                	test   %eax,%eax
 43d:	75 e9                	jne    428 <printint+0x20>
  if(neg)
 43f:	85 ff                	test   %edi,%edi
 441:	74 08                	je     44b <printint+0x43>
    buf[i++] = '-';
 443:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 448:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 44b:	8d 5a ff             	lea    -0x1(%edx),%ebx
 44e:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 450:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 455:	89 f0                	mov    %esi,%eax
 457:	e8 88 ff ff ff       	call   3e4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 45c:	4b                   	dec    %ebx
 45d:	83 fb ff             	cmp    $0xffffffff,%ebx
 460:	75 ee                	jne    450 <printint+0x48>
    putc(fd, buf[i]);
}
 462:	83 c4 1c             	add    $0x1c,%esp
 465:	5b                   	pop    %ebx
 466:	5e                   	pop    %esi
 467:	5f                   	pop    %edi
 468:	5d                   	pop    %ebp
 469:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 46a:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 46c:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 471:	eb af                	jmp    422 <printint+0x1a>
 473:	90                   	nop

00000474 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 474:	55                   	push   %ebp
 475:	89 e5                	mov    %esp,%ebp
 477:	57                   	push   %edi
 478:	56                   	push   %esi
 479:	53                   	push   %ebx
 47a:	83 ec 2c             	sub    $0x2c,%esp
 47d:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 480:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 483:	8a 0b                	mov    (%ebx),%cl
 485:	84 c9                	test   %cl,%cl
 487:	74 7b                	je     504 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 489:	8d 45 10             	lea    0x10(%ebp),%eax
 48c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 48f:	31 f6                	xor    %esi,%esi
 491:	eb 17                	jmp    4aa <printf+0x36>
 493:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 494:	83 f9 25             	cmp    $0x25,%ecx
 497:	74 73                	je     50c <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 499:	0f be d1             	movsbl %cl,%edx
 49c:	89 f8                	mov    %edi,%eax
 49e:	e8 41 ff ff ff       	call   3e4 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 4a3:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4a4:	8a 0b                	mov    (%ebx),%cl
 4a6:	84 c9                	test   %cl,%cl
 4a8:	74 5a                	je     504 <printf+0x90>
    c = fmt[i] & 0xff;
 4aa:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 4ad:	85 f6                	test   %esi,%esi
 4af:	74 e3                	je     494 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4b1:	83 fe 25             	cmp    $0x25,%esi
 4b4:	75 ed                	jne    4a3 <printf+0x2f>
      if(c == 'd'){
 4b6:	83 f9 64             	cmp    $0x64,%ecx
 4b9:	0f 84 c1 00 00 00    	je     580 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 4bf:	83 f9 78             	cmp    $0x78,%ecx
 4c2:	74 50                	je     514 <printf+0xa0>
 4c4:	83 f9 70             	cmp    $0x70,%ecx
 4c7:	74 4b                	je     514 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 4c9:	83 f9 73             	cmp    $0x73,%ecx
 4cc:	74 6a                	je     538 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4ce:	83 f9 63             	cmp    $0x63,%ecx
 4d1:	0f 84 91 00 00 00    	je     568 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 4d7:	ba 25 00 00 00       	mov    $0x25,%edx
 4dc:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4de:	83 f9 25             	cmp    $0x25,%ecx
 4e1:	74 10                	je     4f3 <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4e3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 4e6:	e8 f9 fe ff ff       	call   3e4 <putc>
        putc(fd, c);
 4eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 4ee:	0f be d1             	movsbl %cl,%edx
 4f1:	89 f8                	mov    %edi,%eax
 4f3:	e8 ec fe ff ff       	call   3e4 <putc>
      }
      state = 0;
 4f8:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 4fa:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 4fb:	8a 0b                	mov    (%ebx),%cl
 4fd:	84 c9                	test   %cl,%cl
 4ff:	75 a9                	jne    4aa <printf+0x36>
 501:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 504:	83 c4 2c             	add    $0x2c,%esp
 507:	5b                   	pop    %ebx
 508:	5e                   	pop    %esi
 509:	5f                   	pop    %edi
 50a:	5d                   	pop    %ebp
 50b:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 50c:	be 25 00 00 00       	mov    $0x25,%esi
 511:	eb 90                	jmp    4a3 <printf+0x2f>
 513:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 514:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 51b:	b9 10 00 00 00       	mov    $0x10,%ecx
 520:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 523:	8b 10                	mov    (%eax),%edx
 525:	89 f8                	mov    %edi,%eax
 527:	e8 dc fe ff ff       	call   408 <printint>
        ap++;
 52c:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 530:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 532:	e9 6c ff ff ff       	jmp    4a3 <printf+0x2f>
 537:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 538:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 53b:	8b 30                	mov    (%eax),%esi
        ap++;
 53d:	83 c0 04             	add    $0x4,%eax
 540:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 543:	85 f6                	test   %esi,%esi
 545:	74 5a                	je     5a1 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 547:	8a 16                	mov    (%esi),%dl
 549:	84 d2                	test   %dl,%dl
 54b:	74 14                	je     561 <printf+0xed>
 54d:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 550:	0f be d2             	movsbl %dl,%edx
 553:	89 f8                	mov    %edi,%eax
 555:	e8 8a fe ff ff       	call   3e4 <putc>
          s++;
 55a:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 55b:	8a 16                	mov    (%esi),%dl
 55d:	84 d2                	test   %dl,%dl
 55f:	75 ef                	jne    550 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 561:	31 f6                	xor    %esi,%esi
 563:	e9 3b ff ff ff       	jmp    4a3 <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 568:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 56b:	0f be 10             	movsbl (%eax),%edx
 56e:	89 f8                	mov    %edi,%eax
 570:	e8 6f fe ff ff       	call   3e4 <putc>
        ap++;
 575:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 579:	31 f6                	xor    %esi,%esi
 57b:	e9 23 ff ff ff       	jmp    4a3 <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 580:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 587:	b1 0a                	mov    $0xa,%cl
 589:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 58c:	8b 10                	mov    (%eax),%edx
 58e:	89 f8                	mov    %edi,%eax
 590:	e8 73 fe ff ff       	call   408 <printint>
        ap++;
 595:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 599:	66 31 f6             	xor    %si,%si
 59c:	e9 02 ff ff ff       	jmp    4a3 <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 5a1:	be d4 07 00 00       	mov    $0x7d4,%esi
 5a6:	eb 9f                	jmp    547 <printf+0xd3>

000005a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5a8:	55                   	push   %ebp
 5a9:	89 e5                	mov    %esp,%ebp
 5ab:	57                   	push   %edi
 5ac:	56                   	push   %esi
 5ad:	53                   	push   %ebx
 5ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5b1:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5b4:	a1 90 0a 00 00       	mov    0xa90,%eax
 5b9:	8d 76 00             	lea    0x0(%esi),%esi
 5bc:	8b 10                	mov    (%eax),%edx
 5be:	39 c8                	cmp    %ecx,%eax
 5c0:	73 04                	jae    5c6 <free+0x1e>
 5c2:	39 d1                	cmp    %edx,%ecx
 5c4:	72 12                	jb     5d8 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5c6:	39 d0                	cmp    %edx,%eax
 5c8:	72 08                	jb     5d2 <free+0x2a>
 5ca:	39 c8                	cmp    %ecx,%eax
 5cc:	72 0a                	jb     5d8 <free+0x30>
 5ce:	39 d1                	cmp    %edx,%ecx
 5d0:	72 06                	jb     5d8 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 5d2:	89 d0                	mov    %edx,%eax
 5d4:	eb e6                	jmp    5bc <free+0x14>
 5d6:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5d8:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5db:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5de:	39 d7                	cmp    %edx,%edi
 5e0:	74 19                	je     5fb <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5e2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5e5:	8b 50 04             	mov    0x4(%eax),%edx
 5e8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5eb:	39 f1                	cmp    %esi,%ecx
 5ed:	74 23                	je     612 <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5ef:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5f1:	a3 90 0a 00 00       	mov    %eax,0xa90
}
 5f6:	5b                   	pop    %ebx
 5f7:	5e                   	pop    %esi
 5f8:	5f                   	pop    %edi
 5f9:	5d                   	pop    %ebp
 5fa:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 5fb:	03 72 04             	add    0x4(%edx),%esi
 5fe:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 601:	8b 10                	mov    (%eax),%edx
 603:	8b 12                	mov    (%edx),%edx
 605:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 608:	8b 50 04             	mov    0x4(%eax),%edx
 60b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 60e:	39 f1                	cmp    %esi,%ecx
 610:	75 dd                	jne    5ef <free+0x47>
    p->s.size += bp->s.size;
 612:	03 53 fc             	add    -0x4(%ebx),%edx
 615:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 618:	8b 53 f8             	mov    -0x8(%ebx),%edx
 61b:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 61d:	a3 90 0a 00 00       	mov    %eax,0xa90
}
 622:	5b                   	pop    %ebx
 623:	5e                   	pop    %esi
 624:	5f                   	pop    %edi
 625:	5d                   	pop    %ebp
 626:	c3                   	ret    
 627:	90                   	nop

00000628 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 628:	55                   	push   %ebp
 629:	89 e5                	mov    %esp,%ebp
 62b:	57                   	push   %edi
 62c:	56                   	push   %esi
 62d:	53                   	push   %ebx
 62e:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 631:	8b 5d 08             	mov    0x8(%ebp),%ebx
 634:	83 c3 07             	add    $0x7,%ebx
 637:	c1 eb 03             	shr    $0x3,%ebx
 63a:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 63b:	8b 0d 90 0a 00 00    	mov    0xa90,%ecx
 641:	85 c9                	test   %ecx,%ecx
 643:	0f 84 95 00 00 00    	je     6de <malloc+0xb6>
 649:	8b 01                	mov    (%ecx),%eax
 64b:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 64e:	39 da                	cmp    %ebx,%edx
 650:	73 66                	jae    6b8 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 652:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 659:	eb 0c                	jmp    667 <malloc+0x3f>
 65b:	90                   	nop
    }
    if(p == freep)
 65c:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 65e:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 660:	8b 50 04             	mov    0x4(%eax),%edx
 663:	39 d3                	cmp    %edx,%ebx
 665:	76 51                	jbe    6b8 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 667:	3b 05 90 0a 00 00    	cmp    0xa90,%eax
 66d:	75 ed                	jne    65c <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 66f:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 675:	76 35                	jbe    6ac <malloc+0x84>
 677:	89 f8                	mov    %edi,%eax
 679:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 67b:	89 04 24             	mov    %eax,(%esp)
 67e:	e8 39 fd ff ff       	call   3bc <sbrk>
  if(p == (char*)-1)
 683:	83 f8 ff             	cmp    $0xffffffff,%eax
 686:	74 18                	je     6a0 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 688:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 68b:	83 c0 08             	add    $0x8,%eax
 68e:	89 04 24             	mov    %eax,(%esp)
 691:	e8 12 ff ff ff       	call   5a8 <free>
  return freep;
 696:	8b 0d 90 0a 00 00    	mov    0xa90,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 69c:	85 c9                	test   %ecx,%ecx
 69e:	75 be                	jne    65e <malloc+0x36>
        return 0;
 6a0:	31 c0                	xor    %eax,%eax
  }
}
 6a2:	83 c4 1c             	add    $0x1c,%esp
 6a5:	5b                   	pop    %ebx
 6a6:	5e                   	pop    %esi
 6a7:	5f                   	pop    %edi
 6a8:	5d                   	pop    %ebp
 6a9:	c3                   	ret    
 6aa:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 6ac:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 6b1:	be 00 10 00 00       	mov    $0x1000,%esi
 6b6:	eb c3                	jmp    67b <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 6b8:	39 d3                	cmp    %edx,%ebx
 6ba:	74 1c                	je     6d8 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 6bc:	29 da                	sub    %ebx,%edx
 6be:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 6c1:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6c4:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6c7:	89 0d 90 0a 00 00    	mov    %ecx,0xa90
      return (void*)(p + 1);
 6cd:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6d0:	83 c4 1c             	add    $0x1c,%esp
 6d3:	5b                   	pop    %ebx
 6d4:	5e                   	pop    %esi
 6d5:	5f                   	pop    %edi
 6d6:	5d                   	pop    %ebp
 6d7:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 6d8:	8b 10                	mov    (%eax),%edx
 6da:	89 11                	mov    %edx,(%ecx)
 6dc:	eb e9                	jmp    6c7 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 6de:	c7 05 90 0a 00 00 94 	movl   $0xa94,0xa90
 6e5:	0a 00 00 
 6e8:	c7 05 94 0a 00 00 94 	movl   $0xa94,0xa94
 6ef:	0a 00 00 
    base.s.size = 0;
 6f2:	c7 05 98 0a 00 00 00 	movl   $0x0,0xa98
 6f9:	00 00 00 
 6fc:	b8 94 0a 00 00       	mov    $0xa94,%eax
 701:	e9 4c ff ff ff       	jmp    652 <malloc+0x2a>
