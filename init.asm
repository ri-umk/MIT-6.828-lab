
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	83 ec 10             	sub    $0x10,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  11:	00 
  12:	c7 04 24 9a 06 00 00 	movl   $0x69a,(%esp)
  19:	e8 ea 02 00 00       	call   308 <open>
  1e:	85 c0                	test   %eax,%eax
  20:	0f 88 a7 00 00 00    	js     cd <main+0xcd>
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  2d:	e8 0e 03 00 00       	call   340 <dup>
  dup(0);  // stderr
  32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  39:	e8 02 03 00 00       	call   340 <dup>
  3e:	66 90                	xchg   %ax,%ax

  for(;;){
    printf(1, "init: starting sh\n");
  40:	c7 44 24 04 a2 06 00 	movl   $0x6a2,0x4(%esp)
  47:	00 
  48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  4f:	e8 b4 03 00 00       	call   408 <printf>
    pid = fork();
  54:	e8 67 02 00 00       	call   2c0 <fork>
  59:	89 c3                	mov    %eax,%ebx
    if(pid < 0){
  5b:	83 f8 00             	cmp    $0x0,%eax
  5e:	7c 27                	jl     87 <main+0x87>
      printf(1, "init: fork failed\n");
      exit();
    }
    if(pid == 0){
  60:	74 3e                	je     a0 <main+0xa0>
  62:	66 90                	xchg   %ax,%ax
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  64:	e8 67 02 00 00       	call   2d0 <wait>
  69:	85 c0                	test   %eax,%eax
  6b:	78 d3                	js     40 <main+0x40>
  6d:	39 d8                	cmp    %ebx,%eax
  6f:	74 cf                	je     40 <main+0x40>
      printf(1, "zombie!\n");
  71:	c7 44 24 04 e1 06 00 	movl   $0x6e1,0x4(%esp)
  78:	00 
  79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80:	e8 83 03 00 00       	call   408 <printf>
  85:	eb dd                	jmp    64 <main+0x64>

  for(;;){
    printf(1, "init: starting sh\n");
    pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
  87:	c7 44 24 04 b5 06 00 	movl   $0x6b5,0x4(%esp)
  8e:	00 
  8f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  96:	e8 6d 03 00 00       	call   408 <printf>
      exit();
  9b:	e8 28 02 00 00       	call   2c8 <exit>
    }
    if(pid == 0){
      exec("sh", argv);
  a0:	c7 44 24 04 a4 09 00 	movl   $0x9a4,0x4(%esp)
  a7:	00 
  a8:	c7 04 24 c8 06 00 00 	movl   $0x6c8,(%esp)
  af:	e8 4c 02 00 00       	call   300 <exec>
      printf(1, "init: exec sh failed\n");
  b4:	c7 44 24 04 cb 06 00 	movl   $0x6cb,0x4(%esp)
  bb:	00 
  bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c3:	e8 40 03 00 00       	call   408 <printf>
      exit();
  c8:	e8 fb 01 00 00       	call   2c8 <exit>
main(void)
{
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
    mknod("console", 1, 1);
  cd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  d4:	00 
  d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  dc:	00 
  dd:	c7 04 24 9a 06 00 00 	movl   $0x69a,(%esp)
  e4:	e8 27 02 00 00       	call   310 <mknod>
    open("console", O_RDWR);
  e9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  f0:	00 
  f1:	c7 04 24 9a 06 00 00 	movl   $0x69a,(%esp)
  f8:	e8 0b 02 00 00       	call   308 <open>
  fd:	e9 24 ff ff ff       	jmp    26 <main+0x26>
 102:	90                   	nop
 103:	90                   	nop

00000104 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	53                   	push   %ebx
 108:	8b 45 08             	mov    0x8(%ebp),%eax
 10b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 10e:	31 d2                	xor    %edx,%edx
 110:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
 113:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 116:	42                   	inc    %edx
 117:	84 c9                	test   %cl,%cl
 119:	75 f5                	jne    110 <strcpy+0xc>
    ;
  return os;
}
 11b:	5b                   	pop    %ebx
 11c:	5d                   	pop    %ebp
 11d:	c3                   	ret    
 11e:	66 90                	xchg   %ax,%ax

00000120 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	56                   	push   %esi
 124:	53                   	push   %ebx
 125:	8b 4d 08             	mov    0x8(%ebp),%ecx
 128:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 12b:	8a 01                	mov    (%ecx),%al
 12d:	8a 1a                	mov    (%edx),%bl
 12f:	84 c0                	test   %al,%al
 131:	74 1d                	je     150 <strcmp+0x30>
 133:	38 d8                	cmp    %bl,%al
 135:	74 0c                	je     143 <strcmp+0x23>
 137:	eb 23                	jmp    15c <strcmp+0x3c>
 139:	8d 76 00             	lea    0x0(%esi),%esi
 13c:	41                   	inc    %ecx
 13d:	38 d8                	cmp    %bl,%al
 13f:	75 1b                	jne    15c <strcmp+0x3c>
    p++, q++;
 141:	89 f2                	mov    %esi,%edx
 143:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 146:	8a 41 01             	mov    0x1(%ecx),%al
 149:	8a 5a 01             	mov    0x1(%edx),%bl
 14c:	84 c0                	test   %al,%al
 14e:	75 ec                	jne    13c <strcmp+0x1c>
 150:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 152:	0f b6 db             	movzbl %bl,%ebx
 155:	29 d8                	sub    %ebx,%eax
}
 157:	5b                   	pop    %ebx
 158:	5e                   	pop    %esi
 159:	5d                   	pop    %ebp
 15a:	c3                   	ret    
 15b:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 15c:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 15f:	0f b6 db             	movzbl %bl,%ebx
 162:	29 d8                	sub    %ebx,%eax
}
 164:	5b                   	pop    %ebx
 165:	5e                   	pop    %esi
 166:	5d                   	pop    %ebp
 167:	c3                   	ret    

00000168 <strlen>:

uint
strlen(const char *s)
{
 168:	55                   	push   %ebp
 169:	89 e5                	mov    %esp,%ebp
 16b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 16e:	80 39 00             	cmpb   $0x0,(%ecx)
 171:	74 10                	je     183 <strlen+0x1b>
 173:	31 d2                	xor    %edx,%edx
 175:	8d 76 00             	lea    0x0(%esi),%esi
 178:	42                   	inc    %edx
 179:	89 d0                	mov    %edx,%eax
 17b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 17f:	75 f7                	jne    178 <strlen+0x10>
    ;
  return n;
}
 181:	5d                   	pop    %ebp
 182:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
 183:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
 185:	5d                   	pop    %ebp
 186:	c3                   	ret    
 187:	90                   	nop

00000188 <memset>:

void*
memset(void *dst, int c, uint n)
{
 188:	55                   	push   %ebp
 189:	89 e5                	mov    %esp,%ebp
 18b:	57                   	push   %edi
 18c:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 18f:	89 d7                	mov    %edx,%edi
 191:	8b 4d 10             	mov    0x10(%ebp),%ecx
 194:	8b 45 0c             	mov    0xc(%ebp),%eax
 197:	fc                   	cld    
 198:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 19a:	89 d0                	mov    %edx,%eax
 19c:	5f                   	pop    %edi
 19d:	5d                   	pop    %ebp
 19e:	c3                   	ret    
 19f:	90                   	nop

000001a0 <strchr>:

char*
strchr(const char *s, char c)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	8b 45 08             	mov    0x8(%ebp),%eax
 1a6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 1a9:	8a 10                	mov    (%eax),%dl
 1ab:	84 d2                	test   %dl,%dl
 1ad:	75 0d                	jne    1bc <strchr+0x1c>
 1af:	eb 13                	jmp    1c4 <strchr+0x24>
 1b1:	8d 76 00             	lea    0x0(%esi),%esi
 1b4:	8a 50 01             	mov    0x1(%eax),%dl
 1b7:	84 d2                	test   %dl,%dl
 1b9:	74 09                	je     1c4 <strchr+0x24>
 1bb:	40                   	inc    %eax
    if(*s == c)
 1bc:	38 ca                	cmp    %cl,%dl
 1be:	75 f4                	jne    1b4 <strchr+0x14>
      return (char*)s;
  return 0;
}
 1c0:	5d                   	pop    %ebp
 1c1:	c3                   	ret    
 1c2:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 1c4:	31 c0                	xor    %eax,%eax
}
 1c6:	5d                   	pop    %ebp
 1c7:	c3                   	ret    

000001c8 <gets>:

char*
gets(char *buf, int max)
{
 1c8:	55                   	push   %ebp
 1c9:	89 e5                	mov    %esp,%ebp
 1cb:	57                   	push   %edi
 1cc:	56                   	push   %esi
 1cd:	53                   	push   %ebx
 1ce:	83 ec 2c             	sub    $0x2c,%esp
 1d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d4:	31 f6                	xor    %esi,%esi
 1d6:	eb 30                	jmp    208 <gets+0x40>
    cc = read(0, &c, 1);
 1d8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1df:	00 
 1e0:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1ee:	e8 ed 00 00 00       	call   2e0 <read>
    if(cc < 1)
 1f3:	85 c0                	test   %eax,%eax
 1f5:	7e 19                	jle    210 <gets+0x48>
      break;
    buf[i++] = c;
 1f7:	8a 45 e7             	mov    -0x19(%ebp),%al
 1fa:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fe:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 200:	3c 0a                	cmp    $0xa,%al
 202:	74 0c                	je     210 <gets+0x48>
 204:	3c 0d                	cmp    $0xd,%al
 206:	74 08                	je     210 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 208:	8d 5e 01             	lea    0x1(%esi),%ebx
 20b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 20e:	7c c8                	jl     1d8 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 210:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 214:	89 f8                	mov    %edi,%eax
 216:	83 c4 2c             	add    $0x2c,%esp
 219:	5b                   	pop    %ebx
 21a:	5e                   	pop    %esi
 21b:	5f                   	pop    %edi
 21c:	5d                   	pop    %ebp
 21d:	c3                   	ret    
 21e:	66 90                	xchg   %ax,%ax

00000220 <stat>:

int
stat(const char *n, struct stat *st)
{
 220:	55                   	push   %ebp
 221:	89 e5                	mov    %esp,%ebp
 223:	56                   	push   %esi
 224:	53                   	push   %ebx
 225:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 228:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 22f:	00 
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	89 04 24             	mov    %eax,(%esp)
 236:	e8 cd 00 00 00       	call   308 <open>
 23b:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 23d:	85 c0                	test   %eax,%eax
 23f:	78 23                	js     264 <stat+0x44>
    return -1;
  r = fstat(fd, st);
 241:	8b 45 0c             	mov    0xc(%ebp),%eax
 244:	89 44 24 04          	mov    %eax,0x4(%esp)
 248:	89 1c 24             	mov    %ebx,(%esp)
 24b:	e8 d0 00 00 00       	call   320 <fstat>
 250:	89 c6                	mov    %eax,%esi
  close(fd);
 252:	89 1c 24             	mov    %ebx,(%esp)
 255:	e8 96 00 00 00       	call   2f0 <close>
  return r;
}
 25a:	89 f0                	mov    %esi,%eax
 25c:	83 c4 10             	add    $0x10,%esp
 25f:	5b                   	pop    %ebx
 260:	5e                   	pop    %esi
 261:	5d                   	pop    %ebp
 262:	c3                   	ret    
 263:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 264:	be ff ff ff ff       	mov    $0xffffffff,%esi
 269:	eb ef                	jmp    25a <stat+0x3a>
 26b:	90                   	nop

0000026c <atoi>:
  return r;
}

int
atoi(const char *s)
{
 26c:	55                   	push   %ebp
 26d:	89 e5                	mov    %esp,%ebp
 26f:	53                   	push   %ebx
 270:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 273:	8a 11                	mov    (%ecx),%dl
 275:	8d 42 d0             	lea    -0x30(%edx),%eax
 278:	3c 09                	cmp    $0x9,%al
 27a:	b8 00 00 00 00       	mov    $0x0,%eax
 27f:	77 18                	ja     299 <atoi+0x2d>
 281:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 284:	8d 04 80             	lea    (%eax,%eax,4),%eax
 287:	0f be d2             	movsbl %dl,%edx
 28a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 28e:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28f:	8a 11                	mov    (%ecx),%dl
 291:	8d 5a d0             	lea    -0x30(%edx),%ebx
 294:	80 fb 09             	cmp    $0x9,%bl
 297:	76 eb                	jbe    284 <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 299:	5b                   	pop    %ebx
 29a:	5d                   	pop    %ebp
 29b:	c3                   	ret    

0000029c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 29c:	55                   	push   %ebp
 29d:	89 e5                	mov    %esp,%ebp
 29f:	56                   	push   %esi
 2a0:	53                   	push   %ebx
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	8b 75 0c             	mov    0xc(%ebp),%esi
 2a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2aa:	85 db                	test   %ebx,%ebx
 2ac:	7e 0d                	jle    2bb <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 2ae:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 2b0:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 2b3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 2b6:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b7:	39 da                	cmp    %ebx,%edx
 2b9:	75 f5                	jne    2b0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 2bb:	5b                   	pop    %ebx
 2bc:	5e                   	pop    %esi
 2bd:	5d                   	pop    %ebp
 2be:	c3                   	ret    
 2bf:	90                   	nop

000002c0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c0:	b8 01 00 00 00       	mov    $0x1,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <exit>:
SYSCALL(exit)
 2c8:	b8 02 00 00 00       	mov    $0x2,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <wait>:
SYSCALL(wait)
 2d0:	b8 03 00 00 00       	mov    $0x3,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <pipe>:
SYSCALL(pipe)
 2d8:	b8 04 00 00 00       	mov    $0x4,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <read>:
SYSCALL(read)
 2e0:	b8 05 00 00 00       	mov    $0x5,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <write>:
SYSCALL(write)
 2e8:	b8 10 00 00 00       	mov    $0x10,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <close>:
SYSCALL(close)
 2f0:	b8 15 00 00 00       	mov    $0x15,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <kill>:
SYSCALL(kill)
 2f8:	b8 06 00 00 00       	mov    $0x6,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <exec>:
SYSCALL(exec)
 300:	b8 07 00 00 00       	mov    $0x7,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <open>:
SYSCALL(open)
 308:	b8 0f 00 00 00       	mov    $0xf,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <mknod>:
SYSCALL(mknod)
 310:	b8 11 00 00 00       	mov    $0x11,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <unlink>:
SYSCALL(unlink)
 318:	b8 12 00 00 00       	mov    $0x12,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <fstat>:
SYSCALL(fstat)
 320:	b8 08 00 00 00       	mov    $0x8,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <link>:
SYSCALL(link)
 328:	b8 13 00 00 00       	mov    $0x13,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <mkdir>:
SYSCALL(mkdir)
 330:	b8 14 00 00 00       	mov    $0x14,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <chdir>:
SYSCALL(chdir)
 338:	b8 09 00 00 00       	mov    $0x9,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <dup>:
SYSCALL(dup)
 340:	b8 0a 00 00 00       	mov    $0xa,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <getpid>:
SYSCALL(getpid)
 348:	b8 0b 00 00 00       	mov    $0xb,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <sbrk>:
SYSCALL(sbrk)
 350:	b8 0c 00 00 00       	mov    $0xc,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <sleep>:
SYSCALL(sleep)
 358:	b8 0d 00 00 00       	mov    $0xd,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <uptime>:
SYSCALL(uptime)
 360:	b8 0e 00 00 00       	mov    $0xe,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <date>:
SYSCALL(date)
 368:	b8 16 00 00 00       	mov    $0x16,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <alarm>:
SYSCALL(alarm)
 370:	b8 17 00 00 00       	mov    $0x17,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 378:	55                   	push   %ebp
 379:	89 e5                	mov    %esp,%ebp
 37b:	83 ec 28             	sub    $0x28,%esp
 37e:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 381:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 388:	00 
 389:	8d 55 f4             	lea    -0xc(%ebp),%edx
 38c:	89 54 24 04          	mov    %edx,0x4(%esp)
 390:	89 04 24             	mov    %eax,(%esp)
 393:	e8 50 ff ff ff       	call   2e8 <write>
}
 398:	c9                   	leave  
 399:	c3                   	ret    
 39a:	66 90                	xchg   %ax,%ax

0000039c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 39c:	55                   	push   %ebp
 39d:	89 e5                	mov    %esp,%ebp
 39f:	57                   	push   %edi
 3a0:	56                   	push   %esi
 3a1:	53                   	push   %ebx
 3a2:	83 ec 1c             	sub    $0x1c,%esp
 3a5:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 3a7:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
 3ac:	85 db                	test   %ebx,%ebx
 3ae:	74 04                	je     3b4 <printint+0x18>
 3b0:	85 d2                	test   %edx,%edx
 3b2:	78 4a                	js     3fe <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3b4:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3b6:	31 db                	xor    %ebx,%ebx
 3b8:	eb 04                	jmp    3be <printint+0x22>
 3ba:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 3bc:	89 d3                	mov    %edx,%ebx
 3be:	31 d2                	xor    %edx,%edx
 3c0:	f7 f1                	div    %ecx
 3c2:	8a 92 f1 06 00 00    	mov    0x6f1(%edx),%dl
 3c8:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 3cc:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 3cf:	85 c0                	test   %eax,%eax
 3d1:	75 e9                	jne    3bc <printint+0x20>
  if(neg)
 3d3:	85 ff                	test   %edi,%edi
 3d5:	74 08                	je     3df <printint+0x43>
    buf[i++] = '-';
 3d7:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 3dc:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 3df:	8d 5a ff             	lea    -0x1(%edx),%ebx
 3e2:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 3e4:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3e9:	89 f0                	mov    %esi,%eax
 3eb:	e8 88 ff ff ff       	call   378 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3f0:	4b                   	dec    %ebx
 3f1:	83 fb ff             	cmp    $0xffffffff,%ebx
 3f4:	75 ee                	jne    3e4 <printint+0x48>
    putc(fd, buf[i]);
}
 3f6:	83 c4 1c             	add    $0x1c,%esp
 3f9:	5b                   	pop    %ebx
 3fa:	5e                   	pop    %esi
 3fb:	5f                   	pop    %edi
 3fc:	5d                   	pop    %ebp
 3fd:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 3fe:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 400:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 405:	eb af                	jmp    3b6 <printint+0x1a>
 407:	90                   	nop

00000408 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 408:	55                   	push   %ebp
 409:	89 e5                	mov    %esp,%ebp
 40b:	57                   	push   %edi
 40c:	56                   	push   %esi
 40d:	53                   	push   %ebx
 40e:	83 ec 2c             	sub    $0x2c,%esp
 411:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 414:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 417:	8a 0b                	mov    (%ebx),%cl
 419:	84 c9                	test   %cl,%cl
 41b:	74 7b                	je     498 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 41d:	8d 45 10             	lea    0x10(%ebp),%eax
 420:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 423:	31 f6                	xor    %esi,%esi
 425:	eb 17                	jmp    43e <printf+0x36>
 427:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 428:	83 f9 25             	cmp    $0x25,%ecx
 42b:	74 73                	je     4a0 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 42d:	0f be d1             	movsbl %cl,%edx
 430:	89 f8                	mov    %edi,%eax
 432:	e8 41 ff ff ff       	call   378 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 437:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 438:	8a 0b                	mov    (%ebx),%cl
 43a:	84 c9                	test   %cl,%cl
 43c:	74 5a                	je     498 <printf+0x90>
    c = fmt[i] & 0xff;
 43e:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 441:	85 f6                	test   %esi,%esi
 443:	74 e3                	je     428 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 445:	83 fe 25             	cmp    $0x25,%esi
 448:	75 ed                	jne    437 <printf+0x2f>
      if(c == 'd'){
 44a:	83 f9 64             	cmp    $0x64,%ecx
 44d:	0f 84 c1 00 00 00    	je     514 <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 453:	83 f9 78             	cmp    $0x78,%ecx
 456:	74 50                	je     4a8 <printf+0xa0>
 458:	83 f9 70             	cmp    $0x70,%ecx
 45b:	74 4b                	je     4a8 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 45d:	83 f9 73             	cmp    $0x73,%ecx
 460:	74 6a                	je     4cc <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 462:	83 f9 63             	cmp    $0x63,%ecx
 465:	0f 84 91 00 00 00    	je     4fc <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 46b:	ba 25 00 00 00       	mov    $0x25,%edx
 470:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 472:	83 f9 25             	cmp    $0x25,%ecx
 475:	74 10                	je     487 <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 477:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 47a:	e8 f9 fe ff ff       	call   378 <putc>
        putc(fd, c);
 47f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 482:	0f be d1             	movsbl %cl,%edx
 485:	89 f8                	mov    %edi,%eax
 487:	e8 ec fe ff ff       	call   378 <putc>
      }
      state = 0;
 48c:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 48e:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 48f:	8a 0b                	mov    (%ebx),%cl
 491:	84 c9                	test   %cl,%cl
 493:	75 a9                	jne    43e <printf+0x36>
 495:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 498:	83 c4 2c             	add    $0x2c,%esp
 49b:	5b                   	pop    %ebx
 49c:	5e                   	pop    %esi
 49d:	5f                   	pop    %edi
 49e:	5d                   	pop    %ebp
 49f:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 4a0:	be 25 00 00 00       	mov    $0x25,%esi
 4a5:	eb 90                	jmp    437 <printf+0x2f>
 4a7:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 4a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 4af:	b9 10 00 00 00       	mov    $0x10,%ecx
 4b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4b7:	8b 10                	mov    (%eax),%edx
 4b9:	89 f8                	mov    %edi,%eax
 4bb:	e8 dc fe ff ff       	call   39c <printint>
        ap++;
 4c0:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4c4:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 4c6:	e9 6c ff ff ff       	jmp    437 <printf+0x2f>
 4cb:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 4cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4cf:	8b 30                	mov    (%eax),%esi
        ap++;
 4d1:	83 c0 04             	add    $0x4,%eax
 4d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4d7:	85 f6                	test   %esi,%esi
 4d9:	74 5a                	je     535 <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 4db:	8a 16                	mov    (%esi),%dl
 4dd:	84 d2                	test   %dl,%dl
 4df:	74 14                	je     4f5 <printf+0xed>
 4e1:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 4e4:	0f be d2             	movsbl %dl,%edx
 4e7:	89 f8                	mov    %edi,%eax
 4e9:	e8 8a fe ff ff       	call   378 <putc>
          s++;
 4ee:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 4ef:	8a 16                	mov    (%esi),%dl
 4f1:	84 d2                	test   %dl,%dl
 4f3:	75 ef                	jne    4e4 <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4f5:	31 f6                	xor    %esi,%esi
 4f7:	e9 3b ff ff ff       	jmp    437 <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 4fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4ff:	0f be 10             	movsbl (%eax),%edx
 502:	89 f8                	mov    %edi,%eax
 504:	e8 6f fe ff ff       	call   378 <putc>
        ap++;
 509:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 50d:	31 f6                	xor    %esi,%esi
 50f:	e9 23 ff ff ff       	jmp    437 <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 514:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 51b:	b1 0a                	mov    $0xa,%cl
 51d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 520:	8b 10                	mov    (%eax),%edx
 522:	89 f8                	mov    %edi,%eax
 524:	e8 73 fe ff ff       	call   39c <printint>
        ap++;
 529:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 52d:	66 31 f6             	xor    %si,%si
 530:	e9 02 ff ff ff       	jmp    437 <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 535:	be ea 06 00 00       	mov    $0x6ea,%esi
 53a:	eb 9f                	jmp    4db <printf+0xd3>

0000053c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 53c:	55                   	push   %ebp
 53d:	89 e5                	mov    %esp,%ebp
 53f:	57                   	push   %edi
 540:	56                   	push   %esi
 541:	53                   	push   %ebx
 542:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 545:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 548:	a1 ac 09 00 00       	mov    0x9ac,%eax
 54d:	8d 76 00             	lea    0x0(%esi),%esi
 550:	8b 10                	mov    (%eax),%edx
 552:	39 c8                	cmp    %ecx,%eax
 554:	73 04                	jae    55a <free+0x1e>
 556:	39 d1                	cmp    %edx,%ecx
 558:	72 12                	jb     56c <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 55a:	39 d0                	cmp    %edx,%eax
 55c:	72 08                	jb     566 <free+0x2a>
 55e:	39 c8                	cmp    %ecx,%eax
 560:	72 0a                	jb     56c <free+0x30>
 562:	39 d1                	cmp    %edx,%ecx
 564:	72 06                	jb     56c <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 566:	89 d0                	mov    %edx,%eax
 568:	eb e6                	jmp    550 <free+0x14>
 56a:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 56c:	8b 73 fc             	mov    -0x4(%ebx),%esi
 56f:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 572:	39 d7                	cmp    %edx,%edi
 574:	74 19                	je     58f <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 576:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 579:	8b 50 04             	mov    0x4(%eax),%edx
 57c:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 57f:	39 f1                	cmp    %esi,%ecx
 581:	74 23                	je     5a6 <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 583:	89 08                	mov    %ecx,(%eax)
  freep = p;
 585:	a3 ac 09 00 00       	mov    %eax,0x9ac
}
 58a:	5b                   	pop    %ebx
 58b:	5e                   	pop    %esi
 58c:	5f                   	pop    %edi
 58d:	5d                   	pop    %ebp
 58e:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 58f:	03 72 04             	add    0x4(%edx),%esi
 592:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 595:	8b 10                	mov    (%eax),%edx
 597:	8b 12                	mov    (%edx),%edx
 599:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 59c:	8b 50 04             	mov    0x4(%eax),%edx
 59f:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5a2:	39 f1                	cmp    %esi,%ecx
 5a4:	75 dd                	jne    583 <free+0x47>
    p->s.size += bp->s.size;
 5a6:	03 53 fc             	add    -0x4(%ebx),%edx
 5a9:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5ac:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5af:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 5b1:	a3 ac 09 00 00       	mov    %eax,0x9ac
}
 5b6:	5b                   	pop    %ebx
 5b7:	5e                   	pop    %esi
 5b8:	5f                   	pop    %edi
 5b9:	5d                   	pop    %ebp
 5ba:	c3                   	ret    
 5bb:	90                   	nop

000005bc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 5bc:	55                   	push   %ebp
 5bd:	89 e5                	mov    %esp,%ebp
 5bf:	57                   	push   %edi
 5c0:	56                   	push   %esi
 5c1:	53                   	push   %ebx
 5c2:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5c8:	83 c3 07             	add    $0x7,%ebx
 5cb:	c1 eb 03             	shr    $0x3,%ebx
 5ce:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 5cf:	8b 0d ac 09 00 00    	mov    0x9ac,%ecx
 5d5:	85 c9                	test   %ecx,%ecx
 5d7:	0f 84 95 00 00 00    	je     672 <malloc+0xb6>
 5dd:	8b 01                	mov    (%ecx),%eax
 5df:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 5e2:	39 da                	cmp    %ebx,%edx
 5e4:	73 66                	jae    64c <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 5e6:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 5ed:	eb 0c                	jmp    5fb <malloc+0x3f>
 5ef:	90                   	nop
    }
    if(p == freep)
 5f0:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5f2:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 5f4:	8b 50 04             	mov    0x4(%eax),%edx
 5f7:	39 d3                	cmp    %edx,%ebx
 5f9:	76 51                	jbe    64c <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 5fb:	3b 05 ac 09 00 00    	cmp    0x9ac,%eax
 601:	75 ed                	jne    5f0 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 603:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 609:	76 35                	jbe    640 <malloc+0x84>
 60b:	89 f8                	mov    %edi,%eax
 60d:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 60f:	89 04 24             	mov    %eax,(%esp)
 612:	e8 39 fd ff ff       	call   350 <sbrk>
  if(p == (char*)-1)
 617:	83 f8 ff             	cmp    $0xffffffff,%eax
 61a:	74 18                	je     634 <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 61c:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 61f:	83 c0 08             	add    $0x8,%eax
 622:	89 04 24             	mov    %eax,(%esp)
 625:	e8 12 ff ff ff       	call   53c <free>
  return freep;
 62a:	8b 0d ac 09 00 00    	mov    0x9ac,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 630:	85 c9                	test   %ecx,%ecx
 632:	75 be                	jne    5f2 <malloc+0x36>
        return 0;
 634:	31 c0                	xor    %eax,%eax
  }
}
 636:	83 c4 1c             	add    $0x1c,%esp
 639:	5b                   	pop    %ebx
 63a:	5e                   	pop    %esi
 63b:	5f                   	pop    %edi
 63c:	5d                   	pop    %ebp
 63d:	c3                   	ret    
 63e:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 640:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 645:	be 00 10 00 00       	mov    $0x1000,%esi
 64a:	eb c3                	jmp    60f <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 64c:	39 d3                	cmp    %edx,%ebx
 64e:	74 1c                	je     66c <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 650:	29 da                	sub    %ebx,%edx
 652:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 655:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 658:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 65b:	89 0d ac 09 00 00    	mov    %ecx,0x9ac
      return (void*)(p + 1);
 661:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 664:	83 c4 1c             	add    $0x1c,%esp
 667:	5b                   	pop    %ebx
 668:	5e                   	pop    %esi
 669:	5f                   	pop    %edi
 66a:	5d                   	pop    %ebp
 66b:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 66c:	8b 10                	mov    (%eax),%edx
 66e:	89 11                	mov    %edx,(%ecx)
 670:	eb e9                	jmp    65b <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 672:	c7 05 ac 09 00 00 b0 	movl   $0x9b0,0x9ac
 679:	09 00 00 
 67c:	c7 05 b0 09 00 00 b0 	movl   $0x9b0,0x9b0
 683:	09 00 00 
    base.s.size = 0;
 686:	c7 05 b4 09 00 00 00 	movl   $0x0,0x9b4
 68d:	00 00 00 
 690:	b8 b0 09 00 00       	mov    $0x9b0,%eax
 695:	e9 4c ff ff ff       	jmp    5e6 <malloc+0x2a>
