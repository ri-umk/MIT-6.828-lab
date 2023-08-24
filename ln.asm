
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	83 ec 10             	sub    $0x10,%esp
   a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  if(argc != 3){
   d:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
  11:	74 19                	je     2c <main+0x2c>
    printf(2, "Usage: ln old new\n");
  13:	c7 44 24 04 02 06 00 	movl   $0x602,0x4(%esp)
  1a:	00 
  1b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  22:	e8 49 03 00 00       	call   370 <printf>
    exit();
  27:	e8 04 02 00 00       	call   230 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2c:	8b 43 08             	mov    0x8(%ebx),%eax
  2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  33:	8b 43 04             	mov    0x4(%ebx),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 52 02 00 00       	call   290 <link>
  3e:	85 c0                	test   %eax,%eax
  40:	78 05                	js     47 <main+0x47>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit();
  42:	e8 e9 01 00 00       	call   230 <exit>
  if(argc != 3){
    printf(2, "Usage: ln old new\n");
    exit();
  }
  if(link(argv[1], argv[2]) < 0)
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  47:	8b 43 08             	mov    0x8(%ebx),%eax
  4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  4e:	8b 43 04             	mov    0x4(%ebx),%eax
  51:	89 44 24 08          	mov    %eax,0x8(%esp)
  55:	c7 44 24 04 15 06 00 	movl   $0x615,0x4(%esp)
  5c:	00 
  5d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  64:	e8 07 03 00 00       	call   370 <printf>
  69:	eb d7                	jmp    42 <main+0x42>
  6b:	90                   	nop

0000006c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  6c:	55                   	push   %ebp
  6d:	89 e5                	mov    %esp,%ebp
  6f:	53                   	push   %ebx
  70:	8b 45 08             	mov    0x8(%ebp),%eax
  73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  76:	31 d2                	xor    %edx,%edx
  78:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  7b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  7e:	42                   	inc    %edx
  7f:	84 c9                	test   %cl,%cl
  81:	75 f5                	jne    78 <strcpy+0xc>
    ;
  return os;
}
  83:	5b                   	pop    %ebx
  84:	5d                   	pop    %ebp
  85:	c3                   	ret    
  86:	66 90                	xchg   %ax,%ax

00000088 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  88:	55                   	push   %ebp
  89:	89 e5                	mov    %esp,%ebp
  8b:	56                   	push   %esi
  8c:	53                   	push   %ebx
  8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  90:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  93:	8a 01                	mov    (%ecx),%al
  95:	8a 1a                	mov    (%edx),%bl
  97:	84 c0                	test   %al,%al
  99:	74 1d                	je     b8 <strcmp+0x30>
  9b:	38 d8                	cmp    %bl,%al
  9d:	74 0c                	je     ab <strcmp+0x23>
  9f:	eb 23                	jmp    c4 <strcmp+0x3c>
  a1:	8d 76 00             	lea    0x0(%esi),%esi
  a4:	41                   	inc    %ecx
  a5:	38 d8                	cmp    %bl,%al
  a7:	75 1b                	jne    c4 <strcmp+0x3c>
    p++, q++;
  a9:	89 f2                	mov    %esi,%edx
  ab:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ae:	8a 41 01             	mov    0x1(%ecx),%al
  b1:	8a 5a 01             	mov    0x1(%edx),%bl
  b4:	84 c0                	test   %al,%al
  b6:	75 ec                	jne    a4 <strcmp+0x1c>
  b8:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  ba:	0f b6 db             	movzbl %bl,%ebx
  bd:	29 d8                	sub    %ebx,%eax
}
  bf:	5b                   	pop    %ebx
  c0:	5e                   	pop    %esi
  c1:	5d                   	pop    %ebp
  c2:	c3                   	ret    
  c3:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  c4:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
  c7:	0f b6 db             	movzbl %bl,%ebx
  ca:	29 d8                	sub    %ebx,%eax
}
  cc:	5b                   	pop    %ebx
  cd:	5e                   	pop    %esi
  ce:	5d                   	pop    %ebp
  cf:	c3                   	ret    

000000d0 <strlen>:

uint
strlen(const char *s)
{
  d0:	55                   	push   %ebp
  d1:	89 e5                	mov    %esp,%ebp
  d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  d6:	80 39 00             	cmpb   $0x0,(%ecx)
  d9:	74 10                	je     eb <strlen+0x1b>
  db:	31 d2                	xor    %edx,%edx
  dd:	8d 76 00             	lea    0x0(%esi),%esi
  e0:	42                   	inc    %edx
  e1:	89 d0                	mov    %edx,%eax
  e3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  e7:	75 f7                	jne    e0 <strlen+0x10>
    ;
  return n;
}
  e9:	5d                   	pop    %ebp
  ea:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
  eb:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
  ed:	5d                   	pop    %ebp
  ee:	c3                   	ret    
  ef:	90                   	nop

000000f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f0:	55                   	push   %ebp
  f1:	89 e5                	mov    %esp,%ebp
  f3:	57                   	push   %edi
  f4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  f7:	89 d7                	mov    %edx,%edi
  f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  ff:	fc                   	cld    
 100:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 102:	89 d0                	mov    %edx,%eax
 104:	5f                   	pop    %edi
 105:	5d                   	pop    %ebp
 106:	c3                   	ret    
 107:	90                   	nop

00000108 <strchr>:

char*
strchr(const char *s, char c)
{
 108:	55                   	push   %ebp
 109:	89 e5                	mov    %esp,%ebp
 10b:	8b 45 08             	mov    0x8(%ebp),%eax
 10e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 111:	8a 10                	mov    (%eax),%dl
 113:	84 d2                	test   %dl,%dl
 115:	75 0d                	jne    124 <strchr+0x1c>
 117:	eb 13                	jmp    12c <strchr+0x24>
 119:	8d 76 00             	lea    0x0(%esi),%esi
 11c:	8a 50 01             	mov    0x1(%eax),%dl
 11f:	84 d2                	test   %dl,%dl
 121:	74 09                	je     12c <strchr+0x24>
 123:	40                   	inc    %eax
    if(*s == c)
 124:	38 ca                	cmp    %cl,%dl
 126:	75 f4                	jne    11c <strchr+0x14>
      return (char*)s;
  return 0;
}
 128:	5d                   	pop    %ebp
 129:	c3                   	ret    
 12a:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 12c:	31 c0                	xor    %eax,%eax
}
 12e:	5d                   	pop    %ebp
 12f:	c3                   	ret    

00000130 <gets>:

char*
gets(char *buf, int max)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
 133:	57                   	push   %edi
 134:	56                   	push   %esi
 135:	53                   	push   %ebx
 136:	83 ec 2c             	sub    $0x2c,%esp
 139:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13c:	31 f6                	xor    %esi,%esi
 13e:	eb 30                	jmp    170 <gets+0x40>
    cc = read(0, &c, 1);
 140:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 147:	00 
 148:	8d 45 e7             	lea    -0x19(%ebp),%eax
 14b:	89 44 24 04          	mov    %eax,0x4(%esp)
 14f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 156:	e8 ed 00 00 00       	call   248 <read>
    if(cc < 1)
 15b:	85 c0                	test   %eax,%eax
 15d:	7e 19                	jle    178 <gets+0x48>
      break;
    buf[i++] = c;
 15f:	8a 45 e7             	mov    -0x19(%ebp),%al
 162:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 166:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 168:	3c 0a                	cmp    $0xa,%al
 16a:	74 0c                	je     178 <gets+0x48>
 16c:	3c 0d                	cmp    $0xd,%al
 16e:	74 08                	je     178 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 170:	8d 5e 01             	lea    0x1(%esi),%ebx
 173:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 176:	7c c8                	jl     140 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 178:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 17c:	89 f8                	mov    %edi,%eax
 17e:	83 c4 2c             	add    $0x2c,%esp
 181:	5b                   	pop    %ebx
 182:	5e                   	pop    %esi
 183:	5f                   	pop    %edi
 184:	5d                   	pop    %ebp
 185:	c3                   	ret    
 186:	66 90                	xchg   %ax,%ax

00000188 <stat>:

int
stat(const char *n, struct stat *st)
{
 188:	55                   	push   %ebp
 189:	89 e5                	mov    %esp,%ebp
 18b:	56                   	push   %esi
 18c:	53                   	push   %ebx
 18d:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 190:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 197:	00 
 198:	8b 45 08             	mov    0x8(%ebp),%eax
 19b:	89 04 24             	mov    %eax,(%esp)
 19e:	e8 cd 00 00 00       	call   270 <open>
 1a3:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 1a5:	85 c0                	test   %eax,%eax
 1a7:	78 23                	js     1cc <stat+0x44>
    return -1;
  r = fstat(fd, st);
 1a9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ac:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b0:	89 1c 24             	mov    %ebx,(%esp)
 1b3:	e8 d0 00 00 00       	call   288 <fstat>
 1b8:	89 c6                	mov    %eax,%esi
  close(fd);
 1ba:	89 1c 24             	mov    %ebx,(%esp)
 1bd:	e8 96 00 00 00       	call   258 <close>
  return r;
}
 1c2:	89 f0                	mov    %esi,%eax
 1c4:	83 c4 10             	add    $0x10,%esp
 1c7:	5b                   	pop    %ebx
 1c8:	5e                   	pop    %esi
 1c9:	5d                   	pop    %ebp
 1ca:	c3                   	ret    
 1cb:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 1cc:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1d1:	eb ef                	jmp    1c2 <stat+0x3a>
 1d3:	90                   	nop

000001d4 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1d4:	55                   	push   %ebp
 1d5:	89 e5                	mov    %esp,%ebp
 1d7:	53                   	push   %ebx
 1d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1db:	8a 11                	mov    (%ecx),%dl
 1dd:	8d 42 d0             	lea    -0x30(%edx),%eax
 1e0:	3c 09                	cmp    $0x9,%al
 1e2:	b8 00 00 00 00       	mov    $0x0,%eax
 1e7:	77 18                	ja     201 <atoi+0x2d>
 1e9:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 1ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
 1ef:	0f be d2             	movsbl %dl,%edx
 1f2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 1f6:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f7:	8a 11                	mov    (%ecx),%dl
 1f9:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1fc:	80 fb 09             	cmp    $0x9,%bl
 1ff:	76 eb                	jbe    1ec <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 201:	5b                   	pop    %ebx
 202:	5d                   	pop    %ebp
 203:	c3                   	ret    

00000204 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 204:	55                   	push   %ebp
 205:	89 e5                	mov    %esp,%ebp
 207:	56                   	push   %esi
 208:	53                   	push   %ebx
 209:	8b 45 08             	mov    0x8(%ebp),%eax
 20c:	8b 75 0c             	mov    0xc(%ebp),%esi
 20f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 212:	85 db                	test   %ebx,%ebx
 214:	7e 0d                	jle    223 <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 216:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 218:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 21b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 21e:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 21f:	39 da                	cmp    %ebx,%edx
 221:	75 f5                	jne    218 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 223:	5b                   	pop    %ebx
 224:	5e                   	pop    %esi
 225:	5d                   	pop    %ebp
 226:	c3                   	ret    
 227:	90                   	nop

00000228 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 228:	b8 01 00 00 00       	mov    $0x1,%eax
 22d:	cd 40                	int    $0x40
 22f:	c3                   	ret    

00000230 <exit>:
SYSCALL(exit)
 230:	b8 02 00 00 00       	mov    $0x2,%eax
 235:	cd 40                	int    $0x40
 237:	c3                   	ret    

00000238 <wait>:
SYSCALL(wait)
 238:	b8 03 00 00 00       	mov    $0x3,%eax
 23d:	cd 40                	int    $0x40
 23f:	c3                   	ret    

00000240 <pipe>:
SYSCALL(pipe)
 240:	b8 04 00 00 00       	mov    $0x4,%eax
 245:	cd 40                	int    $0x40
 247:	c3                   	ret    

00000248 <read>:
SYSCALL(read)
 248:	b8 05 00 00 00       	mov    $0x5,%eax
 24d:	cd 40                	int    $0x40
 24f:	c3                   	ret    

00000250 <write>:
SYSCALL(write)
 250:	b8 10 00 00 00       	mov    $0x10,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <close>:
SYSCALL(close)
 258:	b8 15 00 00 00       	mov    $0x15,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <kill>:
SYSCALL(kill)
 260:	b8 06 00 00 00       	mov    $0x6,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <exec>:
SYSCALL(exec)
 268:	b8 07 00 00 00       	mov    $0x7,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <open>:
SYSCALL(open)
 270:	b8 0f 00 00 00       	mov    $0xf,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <mknod>:
SYSCALL(mknod)
 278:	b8 11 00 00 00       	mov    $0x11,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <unlink>:
SYSCALL(unlink)
 280:	b8 12 00 00 00       	mov    $0x12,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <fstat>:
SYSCALL(fstat)
 288:	b8 08 00 00 00       	mov    $0x8,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <link>:
SYSCALL(link)
 290:	b8 13 00 00 00       	mov    $0x13,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <mkdir>:
SYSCALL(mkdir)
 298:	b8 14 00 00 00       	mov    $0x14,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <chdir>:
SYSCALL(chdir)
 2a0:	b8 09 00 00 00       	mov    $0x9,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <dup>:
SYSCALL(dup)
 2a8:	b8 0a 00 00 00       	mov    $0xa,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <getpid>:
SYSCALL(getpid)
 2b0:	b8 0b 00 00 00       	mov    $0xb,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <sbrk>:
SYSCALL(sbrk)
 2b8:	b8 0c 00 00 00       	mov    $0xc,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <sleep>:
SYSCALL(sleep)
 2c0:	b8 0d 00 00 00       	mov    $0xd,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <uptime>:
SYSCALL(uptime)
 2c8:	b8 0e 00 00 00       	mov    $0xe,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <date>:
SYSCALL(date)
 2d0:	b8 16 00 00 00       	mov    $0x16,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <alarm>:
SYSCALL(alarm)
 2d8:	b8 17 00 00 00       	mov    $0x17,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2e0:	55                   	push   %ebp
 2e1:	89 e5                	mov    %esp,%ebp
 2e3:	83 ec 28             	sub    $0x28,%esp
 2e6:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2f0:	00 
 2f1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2f4:	89 54 24 04          	mov    %edx,0x4(%esp)
 2f8:	89 04 24             	mov    %eax,(%esp)
 2fb:	e8 50 ff ff ff       	call   250 <write>
}
 300:	c9                   	leave  
 301:	c3                   	ret    
 302:	66 90                	xchg   %ax,%ax

00000304 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 304:	55                   	push   %ebp
 305:	89 e5                	mov    %esp,%ebp
 307:	57                   	push   %edi
 308:	56                   	push   %esi
 309:	53                   	push   %ebx
 30a:	83 ec 1c             	sub    $0x1c,%esp
 30d:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 30f:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 311:	8b 5d 08             	mov    0x8(%ebp),%ebx
 314:	85 db                	test   %ebx,%ebx
 316:	74 04                	je     31c <printint+0x18>
 318:	85 d2                	test   %edx,%edx
 31a:	78 4a                	js     366 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 31c:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 31e:	31 db                	xor    %ebx,%ebx
 320:	eb 04                	jmp    326 <printint+0x22>
 322:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 324:	89 d3                	mov    %edx,%ebx
 326:	31 d2                	xor    %edx,%edx
 328:	f7 f1                	div    %ecx
 32a:	8a 92 30 06 00 00    	mov    0x630(%edx),%dl
 330:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 334:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 337:	85 c0                	test   %eax,%eax
 339:	75 e9                	jne    324 <printint+0x20>
  if(neg)
 33b:	85 ff                	test   %edi,%edi
 33d:	74 08                	je     347 <printint+0x43>
    buf[i++] = '-';
 33f:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 344:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 347:	8d 5a ff             	lea    -0x1(%edx),%ebx
 34a:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 34c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 351:	89 f0                	mov    %esi,%eax
 353:	e8 88 ff ff ff       	call   2e0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 358:	4b                   	dec    %ebx
 359:	83 fb ff             	cmp    $0xffffffff,%ebx
 35c:	75 ee                	jne    34c <printint+0x48>
    putc(fd, buf[i]);
}
 35e:	83 c4 1c             	add    $0x1c,%esp
 361:	5b                   	pop    %ebx
 362:	5e                   	pop    %esi
 363:	5f                   	pop    %edi
 364:	5d                   	pop    %ebp
 365:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 366:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 368:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 36d:	eb af                	jmp    31e <printint+0x1a>
 36f:	90                   	nop

00000370 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	57                   	push   %edi
 374:	56                   	push   %esi
 375:	53                   	push   %ebx
 376:	83 ec 2c             	sub    $0x2c,%esp
 379:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 37c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 37f:	8a 0b                	mov    (%ebx),%cl
 381:	84 c9                	test   %cl,%cl
 383:	74 7b                	je     400 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 385:	8d 45 10             	lea    0x10(%ebp),%eax
 388:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 38b:	31 f6                	xor    %esi,%esi
 38d:	eb 17                	jmp    3a6 <printf+0x36>
 38f:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 390:	83 f9 25             	cmp    $0x25,%ecx
 393:	74 73                	je     408 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 395:	0f be d1             	movsbl %cl,%edx
 398:	89 f8                	mov    %edi,%eax
 39a:	e8 41 ff ff ff       	call   2e0 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 39f:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3a0:	8a 0b                	mov    (%ebx),%cl
 3a2:	84 c9                	test   %cl,%cl
 3a4:	74 5a                	je     400 <printf+0x90>
    c = fmt[i] & 0xff;
 3a6:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 3a9:	85 f6                	test   %esi,%esi
 3ab:	74 e3                	je     390 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3ad:	83 fe 25             	cmp    $0x25,%esi
 3b0:	75 ed                	jne    39f <printf+0x2f>
      if(c == 'd'){
 3b2:	83 f9 64             	cmp    $0x64,%ecx
 3b5:	0f 84 c1 00 00 00    	je     47c <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3bb:	83 f9 78             	cmp    $0x78,%ecx
 3be:	74 50                	je     410 <printf+0xa0>
 3c0:	83 f9 70             	cmp    $0x70,%ecx
 3c3:	74 4b                	je     410 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3c5:	83 f9 73             	cmp    $0x73,%ecx
 3c8:	74 6a                	je     434 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3ca:	83 f9 63             	cmp    $0x63,%ecx
 3cd:	0f 84 91 00 00 00    	je     464 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 3d3:	ba 25 00 00 00       	mov    $0x25,%edx
 3d8:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3da:	83 f9 25             	cmp    $0x25,%ecx
 3dd:	74 10                	je     3ef <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 3e2:	e8 f9 fe ff ff       	call   2e0 <putc>
        putc(fd, c);
 3e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 3ea:	0f be d1             	movsbl %cl,%edx
 3ed:	89 f8                	mov    %edi,%eax
 3ef:	e8 ec fe ff ff       	call   2e0 <putc>
      }
      state = 0;
 3f4:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 3f6:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3f7:	8a 0b                	mov    (%ebx),%cl
 3f9:	84 c9                	test   %cl,%cl
 3fb:	75 a9                	jne    3a6 <printf+0x36>
 3fd:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 400:	83 c4 2c             	add    $0x2c,%esp
 403:	5b                   	pop    %ebx
 404:	5e                   	pop    %esi
 405:	5f                   	pop    %edi
 406:	5d                   	pop    %ebp
 407:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 408:	be 25 00 00 00       	mov    $0x25,%esi
 40d:	eb 90                	jmp    39f <printf+0x2f>
 40f:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 410:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 417:	b9 10 00 00 00       	mov    $0x10,%ecx
 41c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 41f:	8b 10                	mov    (%eax),%edx
 421:	89 f8                	mov    %edi,%eax
 423:	e8 dc fe ff ff       	call   304 <printint>
        ap++;
 428:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 42c:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 42e:	e9 6c ff ff ff       	jmp    39f <printf+0x2f>
 433:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 434:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 437:	8b 30                	mov    (%eax),%esi
        ap++;
 439:	83 c0 04             	add    $0x4,%eax
 43c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 43f:	85 f6                	test   %esi,%esi
 441:	74 5a                	je     49d <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 443:	8a 16                	mov    (%esi),%dl
 445:	84 d2                	test   %dl,%dl
 447:	74 14                	je     45d <printf+0xed>
 449:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 44c:	0f be d2             	movsbl %dl,%edx
 44f:	89 f8                	mov    %edi,%eax
 451:	e8 8a fe ff ff       	call   2e0 <putc>
          s++;
 456:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 457:	8a 16                	mov    (%esi),%dl
 459:	84 d2                	test   %dl,%dl
 45b:	75 ef                	jne    44c <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 45d:	31 f6                	xor    %esi,%esi
 45f:	e9 3b ff ff ff       	jmp    39f <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 467:	0f be 10             	movsbl (%eax),%edx
 46a:	89 f8                	mov    %edi,%eax
 46c:	e8 6f fe ff ff       	call   2e0 <putc>
        ap++;
 471:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 475:	31 f6                	xor    %esi,%esi
 477:	e9 23 ff ff ff       	jmp    39f <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 47c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 483:	b1 0a                	mov    $0xa,%cl
 485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 488:	8b 10                	mov    (%eax),%edx
 48a:	89 f8                	mov    %edi,%eax
 48c:	e8 73 fe ff ff       	call   304 <printint>
        ap++;
 491:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 495:	66 31 f6             	xor    %si,%si
 498:	e9 02 ff ff ff       	jmp    39f <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 49d:	be 29 06 00 00       	mov    $0x629,%esi
 4a2:	eb 9f                	jmp    443 <printf+0xd3>

000004a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4a4:	55                   	push   %ebp
 4a5:	89 e5                	mov    %esp,%ebp
 4a7:	57                   	push   %edi
 4a8:	56                   	push   %esi
 4a9:	53                   	push   %ebx
 4aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4ad:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4b0:	a1 e4 08 00 00       	mov    0x8e4,%eax
 4b5:	8d 76 00             	lea    0x0(%esi),%esi
 4b8:	8b 10                	mov    (%eax),%edx
 4ba:	39 c8                	cmp    %ecx,%eax
 4bc:	73 04                	jae    4c2 <free+0x1e>
 4be:	39 d1                	cmp    %edx,%ecx
 4c0:	72 12                	jb     4d4 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4c2:	39 d0                	cmp    %edx,%eax
 4c4:	72 08                	jb     4ce <free+0x2a>
 4c6:	39 c8                	cmp    %ecx,%eax
 4c8:	72 0a                	jb     4d4 <free+0x30>
 4ca:	39 d1                	cmp    %edx,%ecx
 4cc:	72 06                	jb     4d4 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 4ce:	89 d0                	mov    %edx,%eax
 4d0:	eb e6                	jmp    4b8 <free+0x14>
 4d2:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 4d4:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4d7:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4da:	39 d7                	cmp    %edx,%edi
 4dc:	74 19                	je     4f7 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4de:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4e1:	8b 50 04             	mov    0x4(%eax),%edx
 4e4:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4e7:	39 f1                	cmp    %esi,%ecx
 4e9:	74 23                	je     50e <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4eb:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4ed:	a3 e4 08 00 00       	mov    %eax,0x8e4
}
 4f2:	5b                   	pop    %ebx
 4f3:	5e                   	pop    %esi
 4f4:	5f                   	pop    %edi
 4f5:	5d                   	pop    %ebp
 4f6:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 4f7:	03 72 04             	add    0x4(%edx),%esi
 4fa:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4fd:	8b 10                	mov    (%eax),%edx
 4ff:	8b 12                	mov    (%edx),%edx
 501:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 504:	8b 50 04             	mov    0x4(%eax),%edx
 507:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 50a:	39 f1                	cmp    %esi,%ecx
 50c:	75 dd                	jne    4eb <free+0x47>
    p->s.size += bp->s.size;
 50e:	03 53 fc             	add    -0x4(%ebx),%edx
 511:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 514:	8b 53 f8             	mov    -0x8(%ebx),%edx
 517:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 519:	a3 e4 08 00 00       	mov    %eax,0x8e4
}
 51e:	5b                   	pop    %ebx
 51f:	5e                   	pop    %esi
 520:	5f                   	pop    %edi
 521:	5d                   	pop    %ebp
 522:	c3                   	ret    
 523:	90                   	nop

00000524 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 524:	55                   	push   %ebp
 525:	89 e5                	mov    %esp,%ebp
 527:	57                   	push   %edi
 528:	56                   	push   %esi
 529:	53                   	push   %ebx
 52a:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 52d:	8b 5d 08             	mov    0x8(%ebp),%ebx
 530:	83 c3 07             	add    $0x7,%ebx
 533:	c1 eb 03             	shr    $0x3,%ebx
 536:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 537:	8b 0d e4 08 00 00    	mov    0x8e4,%ecx
 53d:	85 c9                	test   %ecx,%ecx
 53f:	0f 84 95 00 00 00    	je     5da <malloc+0xb6>
 545:	8b 01                	mov    (%ecx),%eax
 547:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 54a:	39 da                	cmp    %ebx,%edx
 54c:	73 66                	jae    5b4 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 54e:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 555:	eb 0c                	jmp    563 <malloc+0x3f>
 557:	90                   	nop
    }
    if(p == freep)
 558:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 55a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 55c:	8b 50 04             	mov    0x4(%eax),%edx
 55f:	39 d3                	cmp    %edx,%ebx
 561:	76 51                	jbe    5b4 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 563:	3b 05 e4 08 00 00    	cmp    0x8e4,%eax
 569:	75 ed                	jne    558 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 56b:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 571:	76 35                	jbe    5a8 <malloc+0x84>
 573:	89 f8                	mov    %edi,%eax
 575:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 577:	89 04 24             	mov    %eax,(%esp)
 57a:	e8 39 fd ff ff       	call   2b8 <sbrk>
  if(p == (char*)-1)
 57f:	83 f8 ff             	cmp    $0xffffffff,%eax
 582:	74 18                	je     59c <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 584:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 587:	83 c0 08             	add    $0x8,%eax
 58a:	89 04 24             	mov    %eax,(%esp)
 58d:	e8 12 ff ff ff       	call   4a4 <free>
  return freep;
 592:	8b 0d e4 08 00 00    	mov    0x8e4,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 598:	85 c9                	test   %ecx,%ecx
 59a:	75 be                	jne    55a <malloc+0x36>
        return 0;
 59c:	31 c0                	xor    %eax,%eax
  }
}
 59e:	83 c4 1c             	add    $0x1c,%esp
 5a1:	5b                   	pop    %ebx
 5a2:	5e                   	pop    %esi
 5a3:	5f                   	pop    %edi
 5a4:	5d                   	pop    %ebp
 5a5:	c3                   	ret    
 5a6:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 5a8:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 5ad:	be 00 10 00 00       	mov    $0x1000,%esi
 5b2:	eb c3                	jmp    577 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5b4:	39 d3                	cmp    %edx,%ebx
 5b6:	74 1c                	je     5d4 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5b8:	29 da                	sub    %ebx,%edx
 5ba:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5bd:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5c0:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5c3:	89 0d e4 08 00 00    	mov    %ecx,0x8e4
      return (void*)(p + 1);
 5c9:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5cc:	83 c4 1c             	add    $0x1c,%esp
 5cf:	5b                   	pop    %ebx
 5d0:	5e                   	pop    %esi
 5d1:	5f                   	pop    %edi
 5d2:	5d                   	pop    %ebp
 5d3:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 5d4:	8b 10                	mov    (%eax),%edx
 5d6:	89 11                	mov    %edx,(%ecx)
 5d8:	eb e9                	jmp    5c3 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 5da:	c7 05 e4 08 00 00 e8 	movl   $0x8e8,0x8e4
 5e1:	08 00 00 
 5e4:	c7 05 e8 08 00 00 e8 	movl   $0x8e8,0x8e8
 5eb:	08 00 00 
    base.s.size = 0;
 5ee:	c7 05 ec 08 00 00 00 	movl   $0x0,0x8ec
 5f5:	00 00 00 
 5f8:	b8 e8 08 00 00       	mov    $0x8e8,%eax
 5fd:	e9 4c ff ff ff       	jmp    54e <malloc+0x2a>
