
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 10             	sub    $0x10,%esp
   c:	8b 75 08             	mov    0x8(%ebp),%esi
   f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  for(i = 1; i < argc; i++)
  12:	83 fe 01             	cmp    $0x1,%esi
  15:	7e 5a                	jle    71 <main+0x71>
  17:	bb 01 00 00 00       	mov    $0x1,%ebx
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  1c:	43                   	inc    %ebx
  1d:	39 f3                	cmp    %esi,%ebx
  1f:	74 2c                	je     4d <main+0x4d>
  21:	8d 76 00             	lea    0x0(%esi),%esi
  24:	c7 44 24 0c 0e 06 00 	movl   $0x60e,0xc(%esp)
  2b:	00 
  2c:	8b 44 9f fc          	mov    -0x4(%edi,%ebx,4),%eax
  30:	89 44 24 08          	mov    %eax,0x8(%esp)
  34:	c7 44 24 04 10 06 00 	movl   $0x610,0x4(%esp)
  3b:	00 
  3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  43:	e8 34 03 00 00       	call   37c <printf>
  48:	43                   	inc    %ebx
  49:	39 f3                	cmp    %esi,%ebx
  4b:	75 d7                	jne    24 <main+0x24>
  4d:	c7 44 24 0c 15 06 00 	movl   $0x615,0xc(%esp)
  54:	00 
  55:	8b 44 9f fc          	mov    -0x4(%edi,%ebx,4),%eax
  59:	89 44 24 08          	mov    %eax,0x8(%esp)
  5d:	c7 44 24 04 10 06 00 	movl   $0x610,0x4(%esp)
  64:	00 
  65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6c:	e8 0b 03 00 00       	call   37c <printf>
  exit();
  71:	e8 c6 01 00 00       	call   23c <exit>
  76:	90                   	nop
  77:	90                   	nop

00000078 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  78:	55                   	push   %ebp
  79:	89 e5                	mov    %esp,%ebp
  7b:	53                   	push   %ebx
  7c:	8b 45 08             	mov    0x8(%ebp),%eax
  7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  82:	31 d2                	xor    %edx,%edx
  84:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  87:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8a:	42                   	inc    %edx
  8b:	84 c9                	test   %cl,%cl
  8d:	75 f5                	jne    84 <strcpy+0xc>
    ;
  return os;
}
  8f:	5b                   	pop    %ebx
  90:	5d                   	pop    %ebp
  91:	c3                   	ret    
  92:	66 90                	xchg   %ax,%ax

00000094 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  94:	55                   	push   %ebp
  95:	89 e5                	mov    %esp,%ebp
  97:	56                   	push   %esi
  98:	53                   	push   %ebx
  99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  9f:	8a 01                	mov    (%ecx),%al
  a1:	8a 1a                	mov    (%edx),%bl
  a3:	84 c0                	test   %al,%al
  a5:	74 1d                	je     c4 <strcmp+0x30>
  a7:	38 d8                	cmp    %bl,%al
  a9:	74 0c                	je     b7 <strcmp+0x23>
  ab:	eb 23                	jmp    d0 <strcmp+0x3c>
  ad:	8d 76 00             	lea    0x0(%esi),%esi
  b0:	41                   	inc    %ecx
  b1:	38 d8                	cmp    %bl,%al
  b3:	75 1b                	jne    d0 <strcmp+0x3c>
    p++, q++;
  b5:	89 f2                	mov    %esi,%edx
  b7:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ba:	8a 41 01             	mov    0x1(%ecx),%al
  bd:	8a 5a 01             	mov    0x1(%edx),%bl
  c0:	84 c0                	test   %al,%al
  c2:	75 ec                	jne    b0 <strcmp+0x1c>
  c4:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  c6:	0f b6 db             	movzbl %bl,%ebx
  c9:	29 d8                	sub    %ebx,%eax
}
  cb:	5b                   	pop    %ebx
  cc:	5e                   	pop    %esi
  cd:	5d                   	pop    %ebp
  ce:	c3                   	ret    
  cf:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  d0:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  d3:	0f b6 db             	movzbl %bl,%ebx
  d6:	29 d8                	sub    %ebx,%eax
}
  d8:	5b                   	pop    %ebx
  d9:	5e                   	pop    %esi
  da:	5d                   	pop    %ebp
  db:	c3                   	ret    

000000dc <strlen>:

uint
strlen(const char *s)
{
  dc:	55                   	push   %ebp
  dd:	89 e5                	mov    %esp,%ebp
  df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  e2:	80 39 00             	cmpb   $0x0,(%ecx)
  e5:	74 10                	je     f7 <strlen+0x1b>
  e7:	31 d2                	xor    %edx,%edx
  e9:	8d 76 00             	lea    0x0(%esi),%esi
  ec:	42                   	inc    %edx
  ed:	89 d0                	mov    %edx,%eax
  ef:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  f3:	75 f7                	jne    ec <strlen+0x10>
    ;
  return n;
}
  f5:	5d                   	pop    %ebp
  f6:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
  f7:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
  f9:	5d                   	pop    %ebp
  fa:	c3                   	ret    
  fb:	90                   	nop

000000fc <memset>:

void*
memset(void *dst, int c, uint n)
{
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  ff:	57                   	push   %edi
 100:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 103:	89 d7                	mov    %edx,%edi
 105:	8b 4d 10             	mov    0x10(%ebp),%ecx
 108:	8b 45 0c             	mov    0xc(%ebp),%eax
 10b:	fc                   	cld    
 10c:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 10e:	89 d0                	mov    %edx,%eax
 110:	5f                   	pop    %edi
 111:	5d                   	pop    %ebp
 112:	c3                   	ret    
 113:	90                   	nop

00000114 <strchr>:

char*
strchr(const char *s, char c)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	8b 45 08             	mov    0x8(%ebp),%eax
 11a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 11d:	8a 10                	mov    (%eax),%dl
 11f:	84 d2                	test   %dl,%dl
 121:	75 0d                	jne    130 <strchr+0x1c>
 123:	eb 13                	jmp    138 <strchr+0x24>
 125:	8d 76 00             	lea    0x0(%esi),%esi
 128:	8a 50 01             	mov    0x1(%eax),%dl
 12b:	84 d2                	test   %dl,%dl
 12d:	74 09                	je     138 <strchr+0x24>
 12f:	40                   	inc    %eax
    if(*s == c)
 130:	38 ca                	cmp    %cl,%dl
 132:	75 f4                	jne    128 <strchr+0x14>
      return (char*)s;
  return 0;
}
 134:	5d                   	pop    %ebp
 135:	c3                   	ret    
 136:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 138:	31 c0                	xor    %eax,%eax
}
 13a:	5d                   	pop    %ebp
 13b:	c3                   	ret    

0000013c <gets>:

char*
gets(char *buf, int max)
{
 13c:	55                   	push   %ebp
 13d:	89 e5                	mov    %esp,%ebp
 13f:	57                   	push   %edi
 140:	56                   	push   %esi
 141:	53                   	push   %ebx
 142:	83 ec 2c             	sub    $0x2c,%esp
 145:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 148:	31 f6                	xor    %esi,%esi
 14a:	eb 30                	jmp    17c <gets+0x40>
    cc = read(0, &c, 1);
 14c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 153:	00 
 154:	8d 45 e7             	lea    -0x19(%ebp),%eax
 157:	89 44 24 04          	mov    %eax,0x4(%esp)
 15b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 162:	e8 ed 00 00 00       	call   254 <read>
    if(cc < 1)
 167:	85 c0                	test   %eax,%eax
 169:	7e 19                	jle    184 <gets+0x48>
      break;
    buf[i++] = c;
 16b:	8a 45 e7             	mov    -0x19(%ebp),%al
 16e:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 172:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 174:	3c 0a                	cmp    $0xa,%al
 176:	74 0c                	je     184 <gets+0x48>
 178:	3c 0d                	cmp    $0xd,%al
 17a:	74 08                	je     184 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17c:	8d 5e 01             	lea    0x1(%esi),%ebx
 17f:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 182:	7c c8                	jl     14c <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 184:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 188:	89 f8                	mov    %edi,%eax
 18a:	83 c4 2c             	add    $0x2c,%esp
 18d:	5b                   	pop    %ebx
 18e:	5e                   	pop    %esi
 18f:	5f                   	pop    %edi
 190:	5d                   	pop    %ebp
 191:	c3                   	ret    
 192:	66 90                	xchg   %ax,%ax

00000194 <stat>:

int
stat(const char *n, struct stat *st)
{
 194:	55                   	push   %ebp
 195:	89 e5                	mov    %esp,%ebp
 197:	56                   	push   %esi
 198:	53                   	push   %ebx
 199:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1a3:	00 
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
 1a7:	89 04 24             	mov    %eax,(%esp)
 1aa:	e8 cd 00 00 00       	call   27c <open>
 1af:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 1b1:	85 c0                	test   %eax,%eax
 1b3:	78 23                	js     1d8 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 1b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1bc:	89 1c 24             	mov    %ebx,(%esp)
 1bf:	e8 d0 00 00 00       	call   294 <fstat>
 1c4:	89 c6                	mov    %eax,%esi
  close(fd);
 1c6:	89 1c 24             	mov    %ebx,(%esp)
 1c9:	e8 96 00 00 00       	call   264 <close>
  return r;
}
 1ce:	89 f0                	mov    %esi,%eax
 1d0:	83 c4 10             	add    $0x10,%esp
 1d3:	5b                   	pop    %ebx
 1d4:	5e                   	pop    %esi
 1d5:	5d                   	pop    %ebp
 1d6:	c3                   	ret    
 1d7:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 1d8:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1dd:	eb ef                	jmp    1ce <stat+0x3a>
 1df:	90                   	nop

000001e0 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	53                   	push   %ebx
 1e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1e7:	8a 11                	mov    (%ecx),%dl
 1e9:	8d 42 d0             	lea    -0x30(%edx),%eax
 1ec:	3c 09                	cmp    $0x9,%al
 1ee:	b8 00 00 00 00       	mov    $0x0,%eax
 1f3:	77 18                	ja     20d <atoi+0x2d>
 1f5:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 1f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
 1fb:	0f be d2             	movsbl %dl,%edx
 1fe:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 202:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 203:	8a 11                	mov    (%ecx),%dl
 205:	8d 5a d0             	lea    -0x30(%edx),%ebx
 208:	80 fb 09             	cmp    $0x9,%bl
 20b:	76 eb                	jbe    1f8 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 20d:	5b                   	pop    %ebx
 20e:	5d                   	pop    %ebp
 20f:	c3                   	ret    

00000210 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	56                   	push   %esi
 214:	53                   	push   %ebx
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	8b 75 0c             	mov    0xc(%ebp),%esi
 21b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 21e:	85 db                	test   %ebx,%ebx
 220:	7e 0d                	jle    22f <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 222:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 224:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 227:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 22a:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 22b:	39 da                	cmp    %ebx,%edx
 22d:	75 f5                	jne    224 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 22f:	5b                   	pop    %ebx
 230:	5e                   	pop    %esi
 231:	5d                   	pop    %ebp
 232:	c3                   	ret    
 233:	90                   	nop

00000234 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 234:	b8 01 00 00 00       	mov    $0x1,%eax
 239:	cd 40                	int    $0x40
 23b:	c3                   	ret    

0000023c <exit>:
SYSCALL(exit)
 23c:	b8 02 00 00 00       	mov    $0x2,%eax
 241:	cd 40                	int    $0x40
 243:	c3                   	ret    

00000244 <wait>:
SYSCALL(wait)
 244:	b8 03 00 00 00       	mov    $0x3,%eax
 249:	cd 40                	int    $0x40
 24b:	c3                   	ret    

0000024c <pipe>:
SYSCALL(pipe)
 24c:	b8 04 00 00 00       	mov    $0x4,%eax
 251:	cd 40                	int    $0x40
 253:	c3                   	ret    

00000254 <read>:
SYSCALL(read)
 254:	b8 05 00 00 00       	mov    $0x5,%eax
 259:	cd 40                	int    $0x40
 25b:	c3                   	ret    

0000025c <write>:
SYSCALL(write)
 25c:	b8 10 00 00 00       	mov    $0x10,%eax
 261:	cd 40                	int    $0x40
 263:	c3                   	ret    

00000264 <close>:
SYSCALL(close)
 264:	b8 15 00 00 00       	mov    $0x15,%eax
 269:	cd 40                	int    $0x40
 26b:	c3                   	ret    

0000026c <kill>:
SYSCALL(kill)
 26c:	b8 06 00 00 00       	mov    $0x6,%eax
 271:	cd 40                	int    $0x40
 273:	c3                   	ret    

00000274 <exec>:
SYSCALL(exec)
 274:	b8 07 00 00 00       	mov    $0x7,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <open>:
SYSCALL(open)
 27c:	b8 0f 00 00 00       	mov    $0xf,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <mknod>:
SYSCALL(mknod)
 284:	b8 11 00 00 00       	mov    $0x11,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <unlink>:
SYSCALL(unlink)
 28c:	b8 12 00 00 00       	mov    $0x12,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <fstat>:
SYSCALL(fstat)
 294:	b8 08 00 00 00       	mov    $0x8,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <link>:
SYSCALL(link)
 29c:	b8 13 00 00 00       	mov    $0x13,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <mkdir>:
SYSCALL(mkdir)
 2a4:	b8 14 00 00 00       	mov    $0x14,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <chdir>:
SYSCALL(chdir)
 2ac:	b8 09 00 00 00       	mov    $0x9,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <dup>:
SYSCALL(dup)
 2b4:	b8 0a 00 00 00       	mov    $0xa,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <getpid>:
SYSCALL(getpid)
 2bc:	b8 0b 00 00 00       	mov    $0xb,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <sbrk>:
SYSCALL(sbrk)
 2c4:	b8 0c 00 00 00       	mov    $0xc,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <sleep>:
SYSCALL(sleep)
 2cc:	b8 0d 00 00 00       	mov    $0xd,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <uptime>:
SYSCALL(uptime)
 2d4:	b8 0e 00 00 00       	mov    $0xe,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <date>:
SYSCALL(date)
 2dc:	b8 16 00 00 00       	mov    $0x16,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <alarm>:
SYSCALL(alarm)
 2e4:	b8 17 00 00 00       	mov    $0x17,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2ec:	55                   	push   %ebp
 2ed:	89 e5                	mov    %esp,%ebp
 2ef:	83 ec 28             	sub    $0x28,%esp
 2f2:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2f5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2fc:	00 
 2fd:	8d 55 f4             	lea    -0xc(%ebp),%edx
 300:	89 54 24 04          	mov    %edx,0x4(%esp)
 304:	89 04 24             	mov    %eax,(%esp)
 307:	e8 50 ff ff ff       	call   25c <write>
}
 30c:	c9                   	leave  
 30d:	c3                   	ret    
 30e:	66 90                	xchg   %ax,%ax

00000310 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 310:	55                   	push   %ebp
 311:	89 e5                	mov    %esp,%ebp
 313:	57                   	push   %edi
 314:	56                   	push   %esi
 315:	53                   	push   %ebx
 316:	83 ec 1c             	sub    $0x1c,%esp
 319:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 31b:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 31d:	8b 5d 08             	mov    0x8(%ebp),%ebx
 320:	85 db                	test   %ebx,%ebx
 322:	74 04                	je     328 <printint+0x18>
 324:	85 d2                	test   %edx,%edx
 326:	78 4a                	js     372 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 328:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 32a:	31 db                	xor    %ebx,%ebx
 32c:	eb 04                	jmp    332 <printint+0x22>
 32e:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 330:	89 d3                	mov    %edx,%ebx
 332:	31 d2                	xor    %edx,%edx
 334:	f7 f1                	div    %ecx
 336:	8a 92 1e 06 00 00    	mov    0x61e(%edx),%dl
 33c:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 340:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 343:	85 c0                	test   %eax,%eax
 345:	75 e9                	jne    330 <printint+0x20>
  if(neg)
 347:	85 ff                	test   %edi,%edi
 349:	74 08                	je     353 <printint+0x43>
    buf[i++] = '-';
 34b:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 350:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 353:	8d 5a ff             	lea    -0x1(%edx),%ebx
 356:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 358:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 35d:	89 f0                	mov    %esi,%eax
 35f:	e8 88 ff ff ff       	call   2ec <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 364:	4b                   	dec    %ebx
 365:	83 fb ff             	cmp    $0xffffffff,%ebx
 368:	75 ee                	jne    358 <printint+0x48>
    putc(fd, buf[i]);
}
 36a:	83 c4 1c             	add    $0x1c,%esp
 36d:	5b                   	pop    %ebx
 36e:	5e                   	pop    %esi
 36f:	5f                   	pop    %edi
 370:	5d                   	pop    %ebp
 371:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 372:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 374:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 379:	eb af                	jmp    32a <printint+0x1a>
 37b:	90                   	nop

0000037c <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 37c:	55                   	push   %ebp
 37d:	89 e5                	mov    %esp,%ebp
 37f:	57                   	push   %edi
 380:	56                   	push   %esi
 381:	53                   	push   %ebx
 382:	83 ec 2c             	sub    $0x2c,%esp
 385:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 38b:	8a 0b                	mov    (%ebx),%cl
 38d:	84 c9                	test   %cl,%cl
 38f:	74 7b                	je     40c <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 391:	8d 45 10             	lea    0x10(%ebp),%eax
 394:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 397:	31 f6                	xor    %esi,%esi
 399:	eb 17                	jmp    3b2 <printf+0x36>
 39b:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 39c:	83 f9 25             	cmp    $0x25,%ecx
 39f:	74 73                	je     414 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 3a1:	0f be d1             	movsbl %cl,%edx
 3a4:	89 f8                	mov    %edi,%eax
 3a6:	e8 41 ff ff ff       	call   2ec <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3ab:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3ac:	8a 0b                	mov    (%ebx),%cl
 3ae:	84 c9                	test   %cl,%cl
 3b0:	74 5a                	je     40c <printf+0x90>
    c = fmt[i] & 0xff;
 3b2:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 3b5:	85 f6                	test   %esi,%esi
 3b7:	74 e3                	je     39c <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3b9:	83 fe 25             	cmp    $0x25,%esi
 3bc:	75 ed                	jne    3ab <printf+0x2f>
      if(c == 'd'){
 3be:	83 f9 64             	cmp    $0x64,%ecx
 3c1:	0f 84 c1 00 00 00    	je     488 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3c7:	83 f9 78             	cmp    $0x78,%ecx
 3ca:	74 50                	je     41c <printf+0xa0>
 3cc:	83 f9 70             	cmp    $0x70,%ecx
 3cf:	74 4b                	je     41c <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3d1:	83 f9 73             	cmp    $0x73,%ecx
 3d4:	74 6a                	je     440 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3d6:	83 f9 63             	cmp    $0x63,%ecx
 3d9:	0f 84 91 00 00 00    	je     470 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 3df:	ba 25 00 00 00       	mov    $0x25,%edx
 3e4:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3e6:	83 f9 25             	cmp    $0x25,%ecx
 3e9:	74 10                	je     3fb <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3eb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 3ee:	e8 f9 fe ff ff       	call   2ec <putc>
        putc(fd, c);
 3f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 3f6:	0f be d1             	movsbl %cl,%edx
 3f9:	89 f8                	mov    %edi,%eax
 3fb:	e8 ec fe ff ff       	call   2ec <putc>
      }
      state = 0;
 400:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 402:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 403:	8a 0b                	mov    (%ebx),%cl
 405:	84 c9                	test   %cl,%cl
 407:	75 a9                	jne    3b2 <printf+0x36>
 409:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 40c:	83 c4 2c             	add    $0x2c,%esp
 40f:	5b                   	pop    %ebx
 410:	5e                   	pop    %esi
 411:	5f                   	pop    %edi
 412:	5d                   	pop    %ebp
 413:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 414:	be 25 00 00 00       	mov    $0x25,%esi
 419:	eb 90                	jmp    3ab <printf+0x2f>
 41b:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 41c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 423:	b9 10 00 00 00       	mov    $0x10,%ecx
 428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 42b:	8b 10                	mov    (%eax),%edx
 42d:	89 f8                	mov    %edi,%eax
 42f:	e8 dc fe ff ff       	call   310 <printint>
        ap++;
 434:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 438:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 43a:	e9 6c ff ff ff       	jmp    3ab <printf+0x2f>
 43f:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 440:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 443:	8b 30                	mov    (%eax),%esi
        ap++;
 445:	83 c0 04             	add    $0x4,%eax
 448:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 44b:	85 f6                	test   %esi,%esi
 44d:	74 5a                	je     4a9 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 44f:	8a 16                	mov    (%esi),%dl
 451:	84 d2                	test   %dl,%dl
 453:	74 14                	je     469 <printf+0xed>
 455:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 458:	0f be d2             	movsbl %dl,%edx
 45b:	89 f8                	mov    %edi,%eax
 45d:	e8 8a fe ff ff       	call   2ec <putc>
          s++;
 462:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 463:	8a 16                	mov    (%esi),%dl
 465:	84 d2                	test   %dl,%dl
 467:	75 ef                	jne    458 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 469:	31 f6                	xor    %esi,%esi
 46b:	e9 3b ff ff ff       	jmp    3ab <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 470:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 473:	0f be 10             	movsbl (%eax),%edx
 476:	89 f8                	mov    %edi,%eax
 478:	e8 6f fe ff ff       	call   2ec <putc>
        ap++;
 47d:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 481:	31 f6                	xor    %esi,%esi
 483:	e9 23 ff ff ff       	jmp    3ab <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 488:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 48f:	b1 0a                	mov    $0xa,%cl
 491:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 494:	8b 10                	mov    (%eax),%edx
 496:	89 f8                	mov    %edi,%eax
 498:	e8 73 fe ff ff       	call   310 <printint>
        ap++;
 49d:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4a1:	66 31 f6             	xor    %si,%si
 4a4:	e9 02 ff ff ff       	jmp    3ab <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 4a9:	be 17 06 00 00       	mov    $0x617,%esi
 4ae:	eb 9f                	jmp    44f <printf+0xd3>

000004b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	57                   	push   %edi
 4b4:	56                   	push   %esi
 4b5:	53                   	push   %ebx
 4b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4b9:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4bc:	a1 d4 08 00 00       	mov    0x8d4,%eax
 4c1:	8d 76 00             	lea    0x0(%esi),%esi
 4c4:	8b 10                	mov    (%eax),%edx
 4c6:	39 c8                	cmp    %ecx,%eax
 4c8:	73 04                	jae    4ce <free+0x1e>
 4ca:	39 d1                	cmp    %edx,%ecx
 4cc:	72 12                	jb     4e0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4ce:	39 d0                	cmp    %edx,%eax
 4d0:	72 08                	jb     4da <free+0x2a>
 4d2:	39 c8                	cmp    %ecx,%eax
 4d4:	72 0a                	jb     4e0 <free+0x30>
 4d6:	39 d1                	cmp    %edx,%ecx
 4d8:	72 06                	jb     4e0 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 4da:	89 d0                	mov    %edx,%eax
 4dc:	eb e6                	jmp    4c4 <free+0x14>
 4de:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 4e0:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4e3:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4e6:	39 d7                	cmp    %edx,%edi
 4e8:	74 19                	je     503 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4ea:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4ed:	8b 50 04             	mov    0x4(%eax),%edx
 4f0:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4f3:	39 f1                	cmp    %esi,%ecx
 4f5:	74 23                	je     51a <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4f7:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4f9:	a3 d4 08 00 00       	mov    %eax,0x8d4
}
 4fe:	5b                   	pop    %ebx
 4ff:	5e                   	pop    %esi
 500:	5f                   	pop    %edi
 501:	5d                   	pop    %ebp
 502:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 503:	03 72 04             	add    0x4(%edx),%esi
 506:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 509:	8b 10                	mov    (%eax),%edx
 50b:	8b 12                	mov    (%edx),%edx
 50d:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 510:	8b 50 04             	mov    0x4(%eax),%edx
 513:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 516:	39 f1                	cmp    %esi,%ecx
 518:	75 dd                	jne    4f7 <free+0x47>
    p->s.size += bp->s.size;
 51a:	03 53 fc             	add    -0x4(%ebx),%edx
 51d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 520:	8b 53 f8             	mov    -0x8(%ebx),%edx
 523:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 525:	a3 d4 08 00 00       	mov    %eax,0x8d4
}
 52a:	5b                   	pop    %ebx
 52b:	5e                   	pop    %esi
 52c:	5f                   	pop    %edi
 52d:	5d                   	pop    %ebp
 52e:	c3                   	ret    
 52f:	90                   	nop

00000530 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 530:	55                   	push   %ebp
 531:	89 e5                	mov    %esp,%ebp
 533:	57                   	push   %edi
 534:	56                   	push   %esi
 535:	53                   	push   %ebx
 536:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 539:	8b 5d 08             	mov    0x8(%ebp),%ebx
 53c:	83 c3 07             	add    $0x7,%ebx
 53f:	c1 eb 03             	shr    $0x3,%ebx
 542:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 543:	8b 0d d4 08 00 00    	mov    0x8d4,%ecx
 549:	85 c9                	test   %ecx,%ecx
 54b:	0f 84 95 00 00 00    	je     5e6 <malloc+0xb6>
 551:	8b 01                	mov    (%ecx),%eax
 553:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 556:	39 da                	cmp    %ebx,%edx
 558:	73 66                	jae    5c0 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 55a:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 561:	eb 0c                	jmp    56f <malloc+0x3f>
 563:	90                   	nop
    }
    if(p == freep)
 564:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 566:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 568:	8b 50 04             	mov    0x4(%eax),%edx
 56b:	39 d3                	cmp    %edx,%ebx
 56d:	76 51                	jbe    5c0 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 56f:	3b 05 d4 08 00 00    	cmp    0x8d4,%eax
 575:	75 ed                	jne    564 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 577:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 57d:	76 35                	jbe    5b4 <malloc+0x84>
 57f:	89 f8                	mov    %edi,%eax
 581:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 583:	89 04 24             	mov    %eax,(%esp)
 586:	e8 39 fd ff ff       	call   2c4 <sbrk>
  if(p == (char*)-1)
 58b:	83 f8 ff             	cmp    $0xffffffff,%eax
 58e:	74 18                	je     5a8 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 590:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 593:	83 c0 08             	add    $0x8,%eax
 596:	89 04 24             	mov    %eax,(%esp)
 599:	e8 12 ff ff ff       	call   4b0 <free>
  return freep;
 59e:	8b 0d d4 08 00 00    	mov    0x8d4,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 5a4:	85 c9                	test   %ecx,%ecx
 5a6:	75 be                	jne    566 <malloc+0x36>
        return 0;
 5a8:	31 c0                	xor    %eax,%eax
  }
}
 5aa:	83 c4 1c             	add    $0x1c,%esp
 5ad:	5b                   	pop    %ebx
 5ae:	5e                   	pop    %esi
 5af:	5f                   	pop    %edi
 5b0:	5d                   	pop    %ebp
 5b1:	c3                   	ret    
 5b2:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 5b4:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 5b9:	be 00 10 00 00       	mov    $0x1000,%esi
 5be:	eb c3                	jmp    583 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5c0:	39 d3                	cmp    %edx,%ebx
 5c2:	74 1c                	je     5e0 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5c4:	29 da                	sub    %ebx,%edx
 5c6:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5c9:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5cc:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5cf:	89 0d d4 08 00 00    	mov    %ecx,0x8d4
      return (void*)(p + 1);
 5d5:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5d8:	83 c4 1c             	add    $0x1c,%esp
 5db:	5b                   	pop    %ebx
 5dc:	5e                   	pop    %esi
 5dd:	5f                   	pop    %edi
 5de:	5d                   	pop    %ebp
 5df:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 5e0:	8b 10                	mov    (%eax),%edx
 5e2:	89 11                	mov    %edx,(%ecx)
 5e4:	eb e9                	jmp    5cf <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 5e6:	c7 05 d4 08 00 00 d8 	movl   $0x8d8,0x8d4
 5ed:	08 00 00 
 5f0:	c7 05 d8 08 00 00 d8 	movl   $0x8d8,0x8d8
 5f7:	08 00 00 
    base.s.size = 0;
 5fa:	c7 05 dc 08 00 00 00 	movl   $0x0,0x8dc
 601:	00 00 00 
 604:	b8 d8 08 00 00       	mov    $0x8d8,%eax
 609:	e9 4c ff ff ff       	jmp    55a <malloc+0x2a>
