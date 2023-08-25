
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 10             	sub    $0x10,%esp
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800052:	e8 ec 00 00 00       	call   800143 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	29 d0                	sub    %edx,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 f6                	test   %esi,%esi
  800074:	7e 07                	jle    80007d <libmain+0x39>
		binaryname = argv[0];
  800076:	8b 03                	mov    (%ebx),%eax
  800078:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800081:	89 34 24             	mov    %esi,(%esp)
  800084:	e8 ab ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800089:	e8 0a 00 00 00       	call   800098 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009e:	e8 30 05 00 00       	call   8005d3 <close_all>
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    
  8000b1:	00 00                	add    %al,(%eax)
	...

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 28                	jle    80013b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	89 44 24 10          	mov    %eax,0x10(%esp)
  800117:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011e:	00 
  80011f:	c7 44 24 08 ea 1e 80 	movl   $0x801eea,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 07 1f 80 00 	movl   $0x801f07,(%esp)
  800136:	e8 29 10 00 00       	call   801164 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	83 c4 2c             	add    $0x2c,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 28                	jle    8001cd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 08 ea 1e 80 	movl   $0x801eea,0x8(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c0:	00 
  8001c1:	c7 04 24 07 1f 80 00 	movl   $0x801f07,(%esp)
  8001c8:	e8 97 0f 00 00       	call   801164 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001cd:	83 c4 2c             	add    $0x2c,%esp
  8001d0:	5b                   	pop    %ebx
  8001d1:	5e                   	pop    %esi
  8001d2:	5f                   	pop    %edi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	57                   	push   %edi
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001de:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f4:	85 c0                	test   %eax,%eax
  8001f6:	7e 28                	jle    800220 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800203:	00 
  800204:	c7 44 24 08 ea 1e 80 	movl   $0x801eea,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 07 1f 80 00 	movl   $0x801f07,(%esp)
  80021b:	e8 44 0f 00 00       	call   801164 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800220:	83 c4 2c             	add    $0x2c,%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800231:	bb 00 00 00 00       	mov    $0x0,%ebx
  800236:	b8 06 00 00 00       	mov    $0x6,%eax
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	8b 55 08             	mov    0x8(%ebp),%edx
  800241:	89 df                	mov    %ebx,%edi
  800243:	89 de                	mov    %ebx,%esi
  800245:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800247:	85 c0                	test   %eax,%eax
  800249:	7e 28                	jle    800273 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800256:	00 
  800257:	c7 44 24 08 ea 1e 80 	movl   $0x801eea,0x8(%esp)
  80025e:	00 
  80025f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800266:	00 
  800267:	c7 04 24 07 1f 80 00 	movl   $0x801f07,(%esp)
  80026e:	e8 f1 0e 00 00       	call   801164 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800273:	83 c4 2c             	add    $0x2c,%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800284:	bb 00 00 00 00       	mov    $0x0,%ebx
  800289:	b8 08 00 00 00       	mov    $0x8,%eax
  80028e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800291:	8b 55 08             	mov    0x8(%ebp),%edx
  800294:	89 df                	mov    %ebx,%edi
  800296:	89 de                	mov    %ebx,%esi
  800298:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7e 28                	jle    8002c6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 08 ea 1e 80 	movl   $0x801eea,0x8(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b9:	00 
  8002ba:	c7 04 24 07 1f 80 00 	movl   $0x801f07,(%esp)
  8002c1:	e8 9e 0e 00 00       	call   801164 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c6:	83 c4 2c             	add    $0x2c,%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	89 df                	mov    %ebx,%edi
  8002e9:	89 de                	mov    %ebx,%esi
  8002eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ed:	85 c0                	test   %eax,%eax
  8002ef:	7e 28                	jle    800319 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 08 ea 1e 80 	movl   $0x801eea,0x8(%esp)
  800304:	00 
  800305:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030c:	00 
  80030d:	c7 04 24 07 1f 80 00 	movl   $0x801f07,(%esp)
  800314:	e8 4b 0e 00 00       	call   801164 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800319:	83 c4 2c             	add    $0x2c,%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800337:	8b 55 08             	mov    0x8(%ebp),%edx
  80033a:	89 df                	mov    %ebx,%edi
  80033c:	89 de                	mov    %ebx,%esi
  80033e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800340:	85 c0                	test   %eax,%eax
  800342:	7e 28                	jle    80036c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	89 44 24 10          	mov    %eax,0x10(%esp)
  800348:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034f:	00 
  800350:	c7 44 24 08 ea 1e 80 	movl   $0x801eea,0x8(%esp)
  800357:	00 
  800358:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035f:	00 
  800360:	c7 04 24 07 1f 80 00 	movl   $0x801f07,(%esp)
  800367:	e8 f8 0d 00 00       	call   801164 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80036c:	83 c4 2c             	add    $0x2c,%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	57                   	push   %edi
  800378:	56                   	push   %esi
  800379:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037a:	be 00 00 00 00       	mov    $0x0,%esi
  80037f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800384:	8b 7d 14             	mov    0x14(%ebp),%edi
  800387:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ad:	89 cb                	mov    %ecx,%ebx
  8003af:	89 cf                	mov    %ecx,%edi
  8003b1:	89 ce                	mov    %ecx,%esi
  8003b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003b5:	85 c0                	test   %eax,%eax
  8003b7:	7e 28                	jle    8003e1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003bd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c4:	00 
  8003c5:	c7 44 24 08 ea 1e 80 	movl   $0x801eea,0x8(%esp)
  8003cc:	00 
  8003cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d4:	00 
  8003d5:	c7 04 24 07 1f 80 00 	movl   $0x801f07,(%esp)
  8003dc:	e8 83 0d 00 00       	call   801164 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e1:	83 c4 2c             	add    $0x2c,%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5f                   	pop    %edi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    
  8003e9:	00 00                	add    %al,(%eax)
	...

008003ec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f7:	c1 e8 0c             	shr    $0xc,%eax
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800402:	8b 45 08             	mov    0x8(%ebp),%eax
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	e8 df ff ff ff       	call   8003ec <fd2num>
  80040d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800412:	c1 e0 0c             	shl    $0xc,%eax
}
  800415:	c9                   	leave  
  800416:	c3                   	ret    

00800417 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	53                   	push   %ebx
  80041b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80041e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800423:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800425:	89 c2                	mov    %eax,%edx
  800427:	c1 ea 16             	shr    $0x16,%edx
  80042a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800431:	f6 c2 01             	test   $0x1,%dl
  800434:	74 11                	je     800447 <fd_alloc+0x30>
  800436:	89 c2                	mov    %eax,%edx
  800438:	c1 ea 0c             	shr    $0xc,%edx
  80043b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800442:	f6 c2 01             	test   $0x1,%dl
  800445:	75 09                	jne    800450 <fd_alloc+0x39>
			*fd_store = fd;
  800447:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	eb 17                	jmp    800467 <fd_alloc+0x50>
  800450:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800455:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80045a:	75 c7                	jne    800423 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80045c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800462:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800467:	5b                   	pop    %ebx
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    

0080046a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800470:	83 f8 1f             	cmp    $0x1f,%eax
  800473:	77 36                	ja     8004ab <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800475:	05 00 00 0d 00       	add    $0xd0000,%eax
  80047a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80047d:	89 c2                	mov    %eax,%edx
  80047f:	c1 ea 16             	shr    $0x16,%edx
  800482:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800489:	f6 c2 01             	test   $0x1,%dl
  80048c:	74 24                	je     8004b2 <fd_lookup+0x48>
  80048e:	89 c2                	mov    %eax,%edx
  800490:	c1 ea 0c             	shr    $0xc,%edx
  800493:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80049a:	f6 c2 01             	test   $0x1,%dl
  80049d:	74 1a                	je     8004b9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80049f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a2:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a9:	eb 13                	jmp    8004be <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b0:	eb 0c                	jmp    8004be <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b7:	eb 05                	jmp    8004be <fd_lookup+0x54>
  8004b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	53                   	push   %ebx
  8004c4:	83 ec 14             	sub    $0x14,%esp
  8004c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d2:	eb 0e                	jmp    8004e2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004d4:	39 08                	cmp    %ecx,(%eax)
  8004d6:	75 09                	jne    8004e1 <dev_lookup+0x21>
			*dev = devtab[i];
  8004d8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	eb 33                	jmp    800514 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004e1:	42                   	inc    %edx
  8004e2:	8b 04 95 94 1f 80 00 	mov    0x801f94(,%edx,4),%eax
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	75 e7                	jne    8004d4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8004f2:	8b 40 48             	mov    0x48(%eax),%eax
  8004f5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fd:	c7 04 24 18 1f 80 00 	movl   $0x801f18,(%esp)
  800504:	e8 53 0d 00 00       	call   80125c <cprintf>
	*dev = 0;
  800509:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80050f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800514:	83 c4 14             	add    $0x14,%esp
  800517:	5b                   	pop    %ebx
  800518:	5d                   	pop    %ebp
  800519:	c3                   	ret    

0080051a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	56                   	push   %esi
  80051e:	53                   	push   %ebx
  80051f:	83 ec 30             	sub    $0x30,%esp
  800522:	8b 75 08             	mov    0x8(%ebp),%esi
  800525:	8a 45 0c             	mov    0xc(%ebp),%al
  800528:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80052b:	89 34 24             	mov    %esi,(%esp)
  80052e:	e8 b9 fe ff ff       	call   8003ec <fd2num>
  800533:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800536:	89 54 24 04          	mov    %edx,0x4(%esp)
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	e8 28 ff ff ff       	call   80046a <fd_lookup>
  800542:	89 c3                	mov    %eax,%ebx
  800544:	85 c0                	test   %eax,%eax
  800546:	78 05                	js     80054d <fd_close+0x33>
	    || fd != fd2)
  800548:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80054b:	74 0d                	je     80055a <fd_close+0x40>
		return (must_exist ? r : 0);
  80054d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800551:	75 46                	jne    800599 <fd_close+0x7f>
  800553:	bb 00 00 00 00       	mov    $0x0,%ebx
  800558:	eb 3f                	jmp    800599 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80055a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80055d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800561:	8b 06                	mov    (%esi),%eax
  800563:	89 04 24             	mov    %eax,(%esp)
  800566:	e8 55 ff ff ff       	call   8004c0 <dev_lookup>
  80056b:	89 c3                	mov    %eax,%ebx
  80056d:	85 c0                	test   %eax,%eax
  80056f:	78 18                	js     800589 <fd_close+0x6f>
		if (dev->dev_close)
  800571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800574:	8b 40 10             	mov    0x10(%eax),%eax
  800577:	85 c0                	test   %eax,%eax
  800579:	74 09                	je     800584 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80057b:	89 34 24             	mov    %esi,(%esp)
  80057e:	ff d0                	call   *%eax
  800580:	89 c3                	mov    %eax,%ebx
  800582:	eb 05                	jmp    800589 <fd_close+0x6f>
		else
			r = 0;
  800584:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800589:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800594:	e8 8f fc ff ff       	call   800228 <sys_page_unmap>
	return r;
}
  800599:	89 d8                	mov    %ebx,%eax
  80059b:	83 c4 30             	add    $0x30,%esp
  80059e:	5b                   	pop    %ebx
  80059f:	5e                   	pop    %esi
  8005a0:	5d                   	pop    %ebp
  8005a1:	c3                   	ret    

008005a2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005a2:	55                   	push   %ebp
  8005a3:	89 e5                	mov    %esp,%ebp
  8005a5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005af:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b2:	89 04 24             	mov    %eax,(%esp)
  8005b5:	e8 b0 fe ff ff       	call   80046a <fd_lookup>
  8005ba:	85 c0                	test   %eax,%eax
  8005bc:	78 13                	js     8005d1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005c5:	00 
  8005c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005c9:	89 04 24             	mov    %eax,(%esp)
  8005cc:	e8 49 ff ff ff       	call   80051a <fd_close>
}
  8005d1:	c9                   	leave  
  8005d2:	c3                   	ret    

008005d3 <close_all>:

void
close_all(void)
{
  8005d3:	55                   	push   %ebp
  8005d4:	89 e5                	mov    %esp,%ebp
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005da:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005df:	89 1c 24             	mov    %ebx,(%esp)
  8005e2:	e8 bb ff ff ff       	call   8005a2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005e7:	43                   	inc    %ebx
  8005e8:	83 fb 20             	cmp    $0x20,%ebx
  8005eb:	75 f2                	jne    8005df <close_all+0xc>
		close(i);
}
  8005ed:	83 c4 14             	add    $0x14,%esp
  8005f0:	5b                   	pop    %ebx
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    

008005f3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005f3:	55                   	push   %ebp
  8005f4:	89 e5                	mov    %esp,%ebp
  8005f6:	57                   	push   %edi
  8005f7:	56                   	push   %esi
  8005f8:	53                   	push   %ebx
  8005f9:	83 ec 4c             	sub    $0x4c,%esp
  8005fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800602:	89 44 24 04          	mov    %eax,0x4(%esp)
  800606:	8b 45 08             	mov    0x8(%ebp),%eax
  800609:	89 04 24             	mov    %eax,(%esp)
  80060c:	e8 59 fe ff ff       	call   80046a <fd_lookup>
  800611:	89 c3                	mov    %eax,%ebx
  800613:	85 c0                	test   %eax,%eax
  800615:	0f 88 e1 00 00 00    	js     8006fc <dup+0x109>
		return r;
	close(newfdnum);
  80061b:	89 3c 24             	mov    %edi,(%esp)
  80061e:	e8 7f ff ff ff       	call   8005a2 <close>

	newfd = INDEX2FD(newfdnum);
  800623:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800629:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80062c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	e8 c5 fd ff ff       	call   8003fc <fd2data>
  800637:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800639:	89 34 24             	mov    %esi,(%esp)
  80063c:	e8 bb fd ff ff       	call   8003fc <fd2data>
  800641:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800644:	89 d8                	mov    %ebx,%eax
  800646:	c1 e8 16             	shr    $0x16,%eax
  800649:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800650:	a8 01                	test   $0x1,%al
  800652:	74 46                	je     80069a <dup+0xa7>
  800654:	89 d8                	mov    %ebx,%eax
  800656:	c1 e8 0c             	shr    $0xc,%eax
  800659:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800660:	f6 c2 01             	test   $0x1,%dl
  800663:	74 35                	je     80069a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800665:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80066c:	25 07 0e 00 00       	and    $0xe07,%eax
  800671:	89 44 24 10          	mov    %eax,0x10(%esp)
  800675:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800678:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800683:	00 
  800684:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800688:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80068f:	e8 41 fb ff ff       	call   8001d5 <sys_page_map>
  800694:	89 c3                	mov    %eax,%ebx
  800696:	85 c0                	test   %eax,%eax
  800698:	78 3b                	js     8006d5 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80069a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80069d:	89 c2                	mov    %eax,%edx
  80069f:	c1 ea 0c             	shr    $0xc,%edx
  8006a2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006a9:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006af:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006b3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006be:	00 
  8006bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ca:	e8 06 fb ff ff       	call   8001d5 <sys_page_map>
  8006cf:	89 c3                	mov    %eax,%ebx
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	79 25                	jns    8006fa <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006e0:	e8 43 fb ff ff       	call   800228 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f3:	e8 30 fb ff ff       	call   800228 <sys_page_unmap>
	return r;
  8006f8:	eb 02                	jmp    8006fc <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8006fa:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	83 c4 4c             	add    $0x4c,%esp
  800701:	5b                   	pop    %ebx
  800702:	5e                   	pop    %esi
  800703:	5f                   	pop    %edi
  800704:	5d                   	pop    %ebp
  800705:	c3                   	ret    

00800706 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	53                   	push   %ebx
  80070a:	83 ec 24             	sub    $0x24,%esp
  80070d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800710:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800713:	89 44 24 04          	mov    %eax,0x4(%esp)
  800717:	89 1c 24             	mov    %ebx,(%esp)
  80071a:	e8 4b fd ff ff       	call   80046a <fd_lookup>
  80071f:	85 c0                	test   %eax,%eax
  800721:	78 6d                	js     800790 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800723:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800726:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	89 04 24             	mov    %eax,(%esp)
  800732:	e8 89 fd ff ff       	call   8004c0 <dev_lookup>
  800737:	85 c0                	test   %eax,%eax
  800739:	78 55                	js     800790 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80073b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073e:	8b 50 08             	mov    0x8(%eax),%edx
  800741:	83 e2 03             	and    $0x3,%edx
  800744:	83 fa 01             	cmp    $0x1,%edx
  800747:	75 23                	jne    80076c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800749:	a1 04 40 80 00       	mov    0x804004,%eax
  80074e:	8b 40 48             	mov    0x48(%eax),%eax
  800751:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800755:	89 44 24 04          	mov    %eax,0x4(%esp)
  800759:	c7 04 24 59 1f 80 00 	movl   $0x801f59,(%esp)
  800760:	e8 f7 0a 00 00       	call   80125c <cprintf>
		return -E_INVAL;
  800765:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076a:	eb 24                	jmp    800790 <read+0x8a>
	}
	if (!dev->dev_read)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 08             	mov    0x8(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 15                	je     80078b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800776:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800779:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80077d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800780:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	ff d2                	call   *%edx
  800789:	eb 05                	jmp    800790 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80078b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800790:	83 c4 24             	add    $0x24,%esp
  800793:	5b                   	pop    %ebx
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	57                   	push   %edi
  80079a:	56                   	push   %esi
  80079b:	53                   	push   %ebx
  80079c:	83 ec 1c             	sub    $0x1c,%esp
  80079f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007aa:	eb 23                	jmp    8007cf <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	29 d8                	sub    %ebx,%eax
  8007b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b7:	01 d8                	add    %ebx,%eax
  8007b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bd:	89 3c 24             	mov    %edi,(%esp)
  8007c0:	e8 41 ff ff ff       	call   800706 <read>
		if (m < 0)
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	78 10                	js     8007d9 <readn+0x43>
			return m;
		if (m == 0)
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	74 0a                	je     8007d7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007cd:	01 c3                	add    %eax,%ebx
  8007cf:	39 f3                	cmp    %esi,%ebx
  8007d1:	72 d9                	jb     8007ac <readn+0x16>
  8007d3:	89 d8                	mov    %ebx,%eax
  8007d5:	eb 02                	jmp    8007d9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007d7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007d9:	83 c4 1c             	add    $0x1c,%esp
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5f                   	pop    %edi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 24             	sub    $0x24,%esp
  8007e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f2:	89 1c 24             	mov    %ebx,(%esp)
  8007f5:	e8 70 fc ff ff       	call   80046a <fd_lookup>
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	78 68                	js     800866 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800801:	89 44 24 04          	mov    %eax,0x4(%esp)
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	8b 00                	mov    (%eax),%eax
  80080a:	89 04 24             	mov    %eax,(%esp)
  80080d:	e8 ae fc ff ff       	call   8004c0 <dev_lookup>
  800812:	85 c0                	test   %eax,%eax
  800814:	78 50                	js     800866 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081d:	75 23                	jne    800842 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80081f:	a1 04 40 80 00       	mov    0x804004,%eax
  800824:	8b 40 48             	mov    0x48(%eax),%eax
  800827:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80082b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082f:	c7 04 24 75 1f 80 00 	movl   $0x801f75,(%esp)
  800836:	e8 21 0a 00 00       	call   80125c <cprintf>
		return -E_INVAL;
  80083b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800840:	eb 24                	jmp    800866 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800842:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800845:	8b 52 0c             	mov    0xc(%edx),%edx
  800848:	85 d2                	test   %edx,%edx
  80084a:	74 15                	je     800861 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80084c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80084f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800853:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800856:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80085a:	89 04 24             	mov    %eax,(%esp)
  80085d:	ff d2                	call   *%edx
  80085f:	eb 05                	jmp    800866 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800861:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800866:	83 c4 24             	add    $0x24,%esp
  800869:	5b                   	pop    %ebx
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <seek>:

int
seek(int fdnum, off_t offset)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800872:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800875:	89 44 24 04          	mov    %eax,0x4(%esp)
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	89 04 24             	mov    %eax,(%esp)
  80087f:	e8 e6 fb ff ff       	call   80046a <fd_lookup>
  800884:	85 c0                	test   %eax,%eax
  800886:	78 0e                	js     800896 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800888:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	83 ec 24             	sub    $0x24,%esp
  80089f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a9:	89 1c 24             	mov    %ebx,(%esp)
  8008ac:	e8 b9 fb ff ff       	call   80046a <fd_lookup>
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	78 61                	js     800916 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008bf:	8b 00                	mov    (%eax),%eax
  8008c1:	89 04 24             	mov    %eax,(%esp)
  8008c4:	e8 f7 fb ff ff       	call   8004c0 <dev_lookup>
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	78 49                	js     800916 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008d4:	75 23                	jne    8008f9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008d6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008db:	8b 40 48             	mov    0x48(%eax),%eax
  8008de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e6:	c7 04 24 38 1f 80 00 	movl   $0x801f38,(%esp)
  8008ed:	e8 6a 09 00 00       	call   80125c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f7:	eb 1d                	jmp    800916 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8008f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008fc:	8b 52 18             	mov    0x18(%edx),%edx
  8008ff:	85 d2                	test   %edx,%edx
  800901:	74 0e                	je     800911 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800903:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800906:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80090a:	89 04 24             	mov    %eax,(%esp)
  80090d:	ff d2                	call   *%edx
  80090f:	eb 05                	jmp    800916 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800911:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800916:	83 c4 24             	add    $0x24,%esp
  800919:	5b                   	pop    %ebx
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	53                   	push   %ebx
  800920:	83 ec 24             	sub    $0x24,%esp
  800923:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800926:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800929:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	89 04 24             	mov    %eax,(%esp)
  800933:	e8 32 fb ff ff       	call   80046a <fd_lookup>
  800938:	85 c0                	test   %eax,%eax
  80093a:	78 52                	js     80098e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80093c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80093f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800943:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800946:	8b 00                	mov    (%eax),%eax
  800948:	89 04 24             	mov    %eax,(%esp)
  80094b:	e8 70 fb ff ff       	call   8004c0 <dev_lookup>
  800950:	85 c0                	test   %eax,%eax
  800952:	78 3a                	js     80098e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800954:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800957:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80095b:	74 2c                	je     800989 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80095d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800960:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800967:	00 00 00 
	stat->st_isdir = 0;
  80096a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800971:	00 00 00 
	stat->st_dev = dev;
  800974:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80097a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800981:	89 14 24             	mov    %edx,(%esp)
  800984:	ff 50 14             	call   *0x14(%eax)
  800987:	eb 05                	jmp    80098e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800989:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80098e:	83 c4 24             	add    $0x24,%esp
  800991:	5b                   	pop    %ebx
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80099c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009a3:	00 
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	89 04 24             	mov    %eax,(%esp)
  8009aa:	e8 fe 01 00 00       	call   800bad <open>
  8009af:	89 c3                	mov    %eax,%ebx
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 1b                	js     8009d0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bc:	89 1c 24             	mov    %ebx,(%esp)
  8009bf:	e8 58 ff ff ff       	call   80091c <fstat>
  8009c4:	89 c6                	mov    %eax,%esi
	close(fd);
  8009c6:	89 1c 24             	mov    %ebx,(%esp)
  8009c9:	e8 d4 fb ff ff       	call   8005a2 <close>
	return r;
  8009ce:	89 f3                	mov    %esi,%ebx
}
  8009d0:	89 d8                	mov    %ebx,%eax
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    
  8009d9:	00 00                	add    %al,(%eax)
	...

008009dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	83 ec 10             	sub    $0x10,%esp
  8009e4:	89 c3                	mov    %eax,%ebx
  8009e6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8009e8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009ef:	75 11                	jne    800a02 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009f8:	e8 02 12 00 00       	call   801bff <ipc_find_env>
  8009fd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a02:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a09:	00 
  800a0a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a11:	00 
  800a12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a16:	a1 00 40 80 00       	mov    0x804000,%eax
  800a1b:	89 04 24             	mov    %eax,(%esp)
  800a1e:	e8 72 11 00 00       	call   801b95 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a23:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a2a:	00 
  800a2b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a36:	e8 f1 10 00 00       	call   801b2c <ipc_recv>
}
  800a3b:	83 c4 10             	add    $0x10,%esp
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a56:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a60:	b8 02 00 00 00       	mov    $0x2,%eax
  800a65:	e8 72 ff ff ff       	call   8009dc <fsipc>
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	8b 40 0c             	mov    0xc(%eax),%eax
  800a78:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	b8 06 00 00 00       	mov    $0x6,%eax
  800a87:	e8 50 ff ff ff       	call   8009dc <fsipc>
}
  800a8c:	c9                   	leave  
  800a8d:	c3                   	ret    

00800a8e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	53                   	push   %ebx
  800a92:	83 ec 14             	sub    $0x14,%esp
  800a95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800aa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa8:	b8 05 00 00 00       	mov    $0x5,%eax
  800aad:	e8 2a ff ff ff       	call   8009dc <fsipc>
  800ab2:	85 c0                	test   %eax,%eax
  800ab4:	78 2b                	js     800ae1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ab6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800abd:	00 
  800abe:	89 1c 24             	mov    %ebx,(%esp)
  800ac1:	e8 41 0d 00 00       	call   801807 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ac6:	a1 80 50 80 00       	mov    0x805080,%eax
  800acb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ad1:	a1 84 50 80 00       	mov    0x805084,%eax
  800ad6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae1:	83 c4 14             	add    $0x14,%esp
  800ae4:	5b                   	pop    %ebx
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800aed:	c7 44 24 08 a4 1f 80 	movl   $0x801fa4,0x8(%esp)
  800af4:	00 
  800af5:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800afc:	00 
  800afd:	c7 04 24 c2 1f 80 00 	movl   $0x801fc2,(%esp)
  800b04:	e8 5b 06 00 00       	call   801164 <_panic>

00800b09 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 10             	sub    $0x10,%esp
  800b11:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 40 0c             	mov    0xc(%eax),%eax
  800b1a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b1f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2f:	e8 a8 fe ff ff       	call   8009dc <fsipc>
  800b34:	89 c3                	mov    %eax,%ebx
  800b36:	85 c0                	test   %eax,%eax
  800b38:	78 6a                	js     800ba4 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800b3a:	39 c6                	cmp    %eax,%esi
  800b3c:	73 24                	jae    800b62 <devfile_read+0x59>
  800b3e:	c7 44 24 0c cd 1f 80 	movl   $0x801fcd,0xc(%esp)
  800b45:	00 
  800b46:	c7 44 24 08 d4 1f 80 	movl   $0x801fd4,0x8(%esp)
  800b4d:	00 
  800b4e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b55:	00 
  800b56:	c7 04 24 c2 1f 80 00 	movl   $0x801fc2,(%esp)
  800b5d:	e8 02 06 00 00       	call   801164 <_panic>
	assert(r <= PGSIZE);
  800b62:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b67:	7e 24                	jle    800b8d <devfile_read+0x84>
  800b69:	c7 44 24 0c e9 1f 80 	movl   $0x801fe9,0xc(%esp)
  800b70:	00 
  800b71:	c7 44 24 08 d4 1f 80 	movl   $0x801fd4,0x8(%esp)
  800b78:	00 
  800b79:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800b80:	00 
  800b81:	c7 04 24 c2 1f 80 00 	movl   $0x801fc2,(%esp)
  800b88:	e8 d7 05 00 00       	call   801164 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b91:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b98:	00 
  800b99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9c:	89 04 24             	mov    %eax,(%esp)
  800b9f:	e8 dc 0d 00 00       	call   801980 <memmove>
	return r;
}
  800ba4:	89 d8                	mov    %ebx,%eax
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 20             	sub    $0x20,%esp
  800bb5:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bb8:	89 34 24             	mov    %esi,(%esp)
  800bbb:	e8 14 0c 00 00       	call   8017d4 <strlen>
  800bc0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bc5:	7f 60                	jg     800c27 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bca:	89 04 24             	mov    %eax,(%esp)
  800bcd:	e8 45 f8 ff ff       	call   800417 <fd_alloc>
  800bd2:	89 c3                	mov    %eax,%ebx
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	78 54                	js     800c2c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bd8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bdc:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800be3:	e8 1f 0c 00 00       	call   801807 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800be8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800beb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bf0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bf3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf8:	e8 df fd ff ff       	call   8009dc <fsipc>
  800bfd:	89 c3                	mov    %eax,%ebx
  800bff:	85 c0                	test   %eax,%eax
  800c01:	79 15                	jns    800c18 <open+0x6b>
		fd_close(fd, 0);
  800c03:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c0a:	00 
  800c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0e:	89 04 24             	mov    %eax,(%esp)
  800c11:	e8 04 f9 ff ff       	call   80051a <fd_close>
		return r;
  800c16:	eb 14                	jmp    800c2c <open+0x7f>
	}

	return fd2num(fd);
  800c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1b:	89 04 24             	mov    %eax,(%esp)
  800c1e:	e8 c9 f7 ff ff       	call   8003ec <fd2num>
  800c23:	89 c3                	mov    %eax,%ebx
  800c25:	eb 05                	jmp    800c2c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c27:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c2c:	89 d8                	mov    %ebx,%eax
  800c2e:	83 c4 20             	add    $0x20,%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 08 00 00 00       	mov    $0x8,%eax
  800c45:	e8 92 fd ff ff       	call   8009dc <fsipc>
}
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 10             	sub    $0x10,%esp
  800c54:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c57:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5a:	89 04 24             	mov    %eax,(%esp)
  800c5d:	e8 9a f7 ff ff       	call   8003fc <fd2data>
  800c62:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800c64:	c7 44 24 04 f5 1f 80 	movl   $0x801ff5,0x4(%esp)
  800c6b:	00 
  800c6c:	89 34 24             	mov    %esi,(%esp)
  800c6f:	e8 93 0b 00 00       	call   801807 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c74:	8b 43 04             	mov    0x4(%ebx),%eax
  800c77:	2b 03                	sub    (%ebx),%eax
  800c79:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800c7f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800c86:	00 00 00 
	stat->st_dev = &devpipe;
  800c89:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800c90:	30 80 00 
	return 0;
}
  800c93:	b8 00 00 00 00       	mov    $0x0,%eax
  800c98:	83 c4 10             	add    $0x10,%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 14             	sub    $0x14,%esp
  800ca6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ca9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cb4:	e8 6f f5 ff ff       	call   800228 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800cb9:	89 1c 24             	mov    %ebx,(%esp)
  800cbc:	e8 3b f7 ff ff       	call   8003fc <fd2data>
  800cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ccc:	e8 57 f5 ff ff       	call   800228 <sys_page_unmap>
}
  800cd1:	83 c4 14             	add    $0x14,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 2c             	sub    $0x2c,%esp
  800ce0:	89 c7                	mov    %eax,%edi
  800ce2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800ce5:	a1 04 40 80 00       	mov    0x804004,%eax
  800cea:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800ced:	89 3c 24             	mov    %edi,(%esp)
  800cf0:	e8 4f 0f 00 00       	call   801c44 <pageref>
  800cf5:	89 c6                	mov    %eax,%esi
  800cf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cfa:	89 04 24             	mov    %eax,(%esp)
  800cfd:	e8 42 0f 00 00       	call   801c44 <pageref>
  800d02:	39 c6                	cmp    %eax,%esi
  800d04:	0f 94 c0             	sete   %al
  800d07:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800d0a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d10:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800d13:	39 cb                	cmp    %ecx,%ebx
  800d15:	75 08                	jne    800d1f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800d17:	83 c4 2c             	add    $0x2c,%esp
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800d1f:	83 f8 01             	cmp    $0x1,%eax
  800d22:	75 c1                	jne    800ce5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d24:	8b 42 58             	mov    0x58(%edx),%eax
  800d27:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800d2e:	00 
  800d2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d33:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d37:	c7 04 24 fc 1f 80 00 	movl   $0x801ffc,(%esp)
  800d3e:	e8 19 05 00 00       	call   80125c <cprintf>
  800d43:	eb a0                	jmp    800ce5 <_pipeisclosed+0xe>

00800d45 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 1c             	sub    $0x1c,%esp
  800d4e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800d51:	89 34 24             	mov    %esi,(%esp)
  800d54:	e8 a3 f6 ff ff       	call   8003fc <fd2data>
  800d59:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800d60:	eb 3c                	jmp    800d9e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800d62:	89 da                	mov    %ebx,%edx
  800d64:	89 f0                	mov    %esi,%eax
  800d66:	e8 6c ff ff ff       	call   800cd7 <_pipeisclosed>
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	75 38                	jne    800da7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800d6f:	e8 ee f3 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d74:	8b 43 04             	mov    0x4(%ebx),%eax
  800d77:	8b 13                	mov    (%ebx),%edx
  800d79:	83 c2 20             	add    $0x20,%edx
  800d7c:	39 d0                	cmp    %edx,%eax
  800d7e:	73 e2                	jae    800d62 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d83:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800d86:	89 c2                	mov    %eax,%edx
  800d88:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800d8e:	79 05                	jns    800d95 <devpipe_write+0x50>
  800d90:	4a                   	dec    %edx
  800d91:	83 ca e0             	or     $0xffffffe0,%edx
  800d94:	42                   	inc    %edx
  800d95:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d99:	40                   	inc    %eax
  800d9a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d9d:	47                   	inc    %edi
  800d9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800da1:	75 d1                	jne    800d74 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800da3:	89 f8                	mov    %edi,%eax
  800da5:	eb 05                	jmp    800dac <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800da7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800dac:	83 c4 1c             	add    $0x1c,%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	83 ec 1c             	sub    $0x1c,%esp
  800dbd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800dc0:	89 3c 24             	mov    %edi,(%esp)
  800dc3:	e8 34 f6 ff ff       	call   8003fc <fd2data>
  800dc8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dca:	be 00 00 00 00       	mov    $0x0,%esi
  800dcf:	eb 3a                	jmp    800e0b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800dd1:	85 f6                	test   %esi,%esi
  800dd3:	74 04                	je     800dd9 <devpipe_read+0x25>
				return i;
  800dd5:	89 f0                	mov    %esi,%eax
  800dd7:	eb 40                	jmp    800e19 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800dd9:	89 da                	mov    %ebx,%edx
  800ddb:	89 f8                	mov    %edi,%eax
  800ddd:	e8 f5 fe ff ff       	call   800cd7 <_pipeisclosed>
  800de2:	85 c0                	test   %eax,%eax
  800de4:	75 2e                	jne    800e14 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800de6:	e8 77 f3 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800deb:	8b 03                	mov    (%ebx),%eax
  800ded:	3b 43 04             	cmp    0x4(%ebx),%eax
  800df0:	74 df                	je     800dd1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800df2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800df7:	79 05                	jns    800dfe <devpipe_read+0x4a>
  800df9:	48                   	dec    %eax
  800dfa:	83 c8 e0             	or     $0xffffffe0,%eax
  800dfd:	40                   	inc    %eax
  800dfe:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800e02:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e05:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800e08:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e0a:	46                   	inc    %esi
  800e0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e0e:	75 db                	jne    800deb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800e10:	89 f0                	mov    %esi,%eax
  800e12:	eb 05                	jmp    800e19 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800e19:	83 c4 1c             	add    $0x1c,%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 3c             	sub    $0x3c,%esp
  800e2a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800e2d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e30:	89 04 24             	mov    %eax,(%esp)
  800e33:	e8 df f5 ff ff       	call   800417 <fd_alloc>
  800e38:	89 c3                	mov    %eax,%ebx
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	0f 88 45 01 00 00    	js     800f87 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e42:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e49:	00 
  800e4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e58:	e8 24 f3 ff ff       	call   800181 <sys_page_alloc>
  800e5d:	89 c3                	mov    %eax,%ebx
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	0f 88 20 01 00 00    	js     800f87 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800e67:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e6a:	89 04 24             	mov    %eax,(%esp)
  800e6d:	e8 a5 f5 ff ff       	call   800417 <fd_alloc>
  800e72:	89 c3                	mov    %eax,%ebx
  800e74:	85 c0                	test   %eax,%eax
  800e76:	0f 88 f8 00 00 00    	js     800f74 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e7c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e83:	00 
  800e84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e92:	e8 ea f2 ff ff       	call   800181 <sys_page_alloc>
  800e97:	89 c3                	mov    %eax,%ebx
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	0f 88 d3 00 00 00    	js     800f74 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ea4:	89 04 24             	mov    %eax,(%esp)
  800ea7:	e8 50 f5 ff ff       	call   8003fc <fd2data>
  800eac:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eae:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800eb5:	00 
  800eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec1:	e8 bb f2 ff ff       	call   800181 <sys_page_alloc>
  800ec6:	89 c3                	mov    %eax,%ebx
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	0f 88 91 00 00 00    	js     800f61 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ed0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ed3:	89 04 24             	mov    %eax,(%esp)
  800ed6:	e8 21 f5 ff ff       	call   8003fc <fd2data>
  800edb:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800ee2:	00 
  800ee3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ee7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eee:	00 
  800eef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ef3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800efa:	e8 d6 f2 ff ff       	call   8001d5 <sys_page_map>
  800eff:	89 c3                	mov    %eax,%ebx
  800f01:	85 c0                	test   %eax,%eax
  800f03:	78 4c                	js     800f51 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800f05:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f0e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f13:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800f1a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f20:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f23:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f25:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800f2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f32:	89 04 24             	mov    %eax,(%esp)
  800f35:	e8 b2 f4 ff ff       	call   8003ec <fd2num>
  800f3a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800f3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f3f:	89 04 24             	mov    %eax,(%esp)
  800f42:	e8 a5 f4 ff ff       	call   8003ec <fd2num>
  800f47:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800f4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4f:	eb 36                	jmp    800f87 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800f51:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5c:	e8 c7 f2 ff ff       	call   800228 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800f61:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6f:	e8 b4 f2 ff ff       	call   800228 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  800f74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f82:	e8 a1 f2 ff ff       	call   800228 <sys_page_unmap>
    err:
	return r;
}
  800f87:	89 d8                	mov    %ebx,%eax
  800f89:	83 c4 3c             	add    $0x3c,%esp
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    

00800f91 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa1:	89 04 24             	mov    %eax,(%esp)
  800fa4:	e8 c1 f4 ff ff       	call   80046a <fd_lookup>
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 15                	js     800fc2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb0:	89 04 24             	mov    %eax,(%esp)
  800fb3:	e8 44 f4 ff ff       	call   8003fc <fd2data>
	return _pipeisclosed(fd, p);
  800fb8:	89 c2                	mov    %eax,%edx
  800fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbd:	e8 15 fd ff ff       	call   800cd7 <_pipeisclosed>
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fd4:	c7 44 24 04 14 20 80 	movl   $0x802014,0x4(%esp)
  800fdb:	00 
  800fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdf:	89 04 24             	mov    %eax,(%esp)
  800fe2:	e8 20 08 00 00       	call   801807 <strcpy>
	return 0;
}
  800fe7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fec:	c9                   	leave  
  800fed:	c3                   	ret    

00800fee <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ffa:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800fff:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801005:	eb 30                	jmp    801037 <devcons_write+0x49>
		m = n - tot;
  801007:	8b 75 10             	mov    0x10(%ebp),%esi
  80100a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80100c:	83 fe 7f             	cmp    $0x7f,%esi
  80100f:	76 05                	jbe    801016 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801011:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801016:	89 74 24 08          	mov    %esi,0x8(%esp)
  80101a:	03 45 0c             	add    0xc(%ebp),%eax
  80101d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801021:	89 3c 24             	mov    %edi,(%esp)
  801024:	e8 57 09 00 00       	call   801980 <memmove>
		sys_cputs(buf, m);
  801029:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102d:	89 3c 24             	mov    %edi,(%esp)
  801030:	e8 7f f0 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801035:	01 f3                	add    %esi,%ebx
  801037:	89 d8                	mov    %ebx,%eax
  801039:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80103c:	72 c9                	jb     801007 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80103e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80104f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801053:	75 07                	jne    80105c <devcons_read+0x13>
  801055:	eb 25                	jmp    80107c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801057:	e8 06 f1 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80105c:	e8 71 f0 ff ff       	call   8000d2 <sys_cgetc>
  801061:	85 c0                	test   %eax,%eax
  801063:	74 f2                	je     801057 <devcons_read+0xe>
  801065:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801067:	85 c0                	test   %eax,%eax
  801069:	78 1d                	js     801088 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80106b:	83 f8 04             	cmp    $0x4,%eax
  80106e:	74 13                	je     801083 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801070:	8b 45 0c             	mov    0xc(%ebp),%eax
  801073:	88 10                	mov    %dl,(%eax)
	return 1;
  801075:	b8 01 00 00 00       	mov    $0x1,%eax
  80107a:	eb 0c                	jmp    801088 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
  801081:	eb 05                	jmp    801088 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801083:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801088:	c9                   	leave  
  801089:	c3                   	ret    

0080108a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801090:	8b 45 08             	mov    0x8(%ebp),%eax
  801093:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801096:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80109d:	00 
  80109e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010a1:	89 04 24             	mov    %eax,(%esp)
  8010a4:	e8 0b f0 ff ff       	call   8000b4 <sys_cputs>
}
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    

008010ab <getchar>:

int
getchar(void)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8010b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010b8:	00 
  8010b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c7:	e8 3a f6 ff ff       	call   800706 <read>
	if (r < 0)
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	78 0f                	js     8010df <getchar+0x34>
		return r;
	if (r < 1)
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	7e 06                	jle    8010da <getchar+0x2f>
		return -E_EOF;
	return c;
  8010d4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010d8:	eb 05                	jmp    8010df <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8010da:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8010df:	c9                   	leave  
  8010e0:	c3                   	ret    

008010e1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f1:	89 04 24             	mov    %eax,(%esp)
  8010f4:	e8 71 f3 ff ff       	call   80046a <fd_lookup>
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 11                	js     80110e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8010fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801100:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801106:	39 10                	cmp    %edx,(%eax)
  801108:	0f 94 c0             	sete   %al
  80110b:	0f b6 c0             	movzbl %al,%eax
}
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <opencons>:

int
opencons(void)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801116:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801119:	89 04 24             	mov    %eax,(%esp)
  80111c:	e8 f6 f2 ff ff       	call   800417 <fd_alloc>
  801121:	85 c0                	test   %eax,%eax
  801123:	78 3c                	js     801161 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801125:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80112c:	00 
  80112d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801130:	89 44 24 04          	mov    %eax,0x4(%esp)
  801134:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80113b:	e8 41 f0 ff ff       	call   800181 <sys_page_alloc>
  801140:	85 c0                	test   %eax,%eax
  801142:	78 1d                	js     801161 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801144:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80114a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80114f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801152:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801159:	89 04 24             	mov    %eax,(%esp)
  80115c:	e8 8b f2 ff ff       	call   8003ec <fd2num>
}
  801161:	c9                   	leave  
  801162:	c3                   	ret    
	...

00801164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	56                   	push   %esi
  801168:	53                   	push   %ebx
  801169:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80116c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80116f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801175:	e8 c9 ef ff ff       	call   800143 <sys_getenvid>
  80117a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801181:	8b 55 08             	mov    0x8(%ebp),%edx
  801184:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801188:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80118c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801190:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  801197:	e8 c0 00 00 00       	call   80125c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80119c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a3:	89 04 24             	mov    %eax,(%esp)
  8011a6:	e8 50 00 00 00       	call   8011fb <vcprintf>
	cprintf("\n");
  8011ab:	c7 04 24 0d 20 80 00 	movl   $0x80200d,(%esp)
  8011b2:	e8 a5 00 00 00       	call   80125c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011b7:	cc                   	int3   
  8011b8:	eb fd                	jmp    8011b7 <_panic+0x53>
	...

008011bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 14             	sub    $0x14,%esp
  8011c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011c6:	8b 03                	mov    (%ebx),%eax
  8011c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8011cf:	40                   	inc    %eax
  8011d0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8011d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011d7:	75 19                	jne    8011f2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8011d9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011e0:	00 
  8011e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8011e4:	89 04 24             	mov    %eax,(%esp)
  8011e7:	e8 c8 ee ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8011ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8011f2:	ff 43 04             	incl   0x4(%ebx)
}
  8011f5:	83 c4 14             	add    $0x14,%esp
  8011f8:	5b                   	pop    %ebx
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801204:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80120b:	00 00 00 
	b.cnt = 0;
  80120e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801215:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801218:	8b 45 0c             	mov    0xc(%ebp),%eax
  80121b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121f:	8b 45 08             	mov    0x8(%ebp),%eax
  801222:	89 44 24 08          	mov    %eax,0x8(%esp)
  801226:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80122c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801230:	c7 04 24 bc 11 80 00 	movl   $0x8011bc,(%esp)
  801237:	e8 82 01 00 00       	call   8013be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80123c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801242:	89 44 24 04          	mov    %eax,0x4(%esp)
  801246:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80124c:	89 04 24             	mov    %eax,(%esp)
  80124f:	e8 60 ee ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801254:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80125a:	c9                   	leave  
  80125b:	c3                   	ret    

0080125c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801262:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801265:	89 44 24 04          	mov    %eax,0x4(%esp)
  801269:	8b 45 08             	mov    0x8(%ebp),%eax
  80126c:	89 04 24             	mov    %eax,(%esp)
  80126f:	e8 87 ff ff ff       	call   8011fb <vcprintf>
	va_end(ap);

	return cnt;
}
  801274:	c9                   	leave  
  801275:	c3                   	ret    
	...

00801278 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	57                   	push   %edi
  80127c:	56                   	push   %esi
  80127d:	53                   	push   %ebx
  80127e:	83 ec 3c             	sub    $0x3c,%esp
  801281:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801284:	89 d7                	mov    %edx,%edi
  801286:	8b 45 08             	mov    0x8(%ebp),%eax
  801289:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80128c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801292:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801295:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801298:	85 c0                	test   %eax,%eax
  80129a:	75 08                	jne    8012a4 <printnum+0x2c>
  80129c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80129f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8012a2:	77 57                	ja     8012fb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012a8:	4b                   	dec    %ebx
  8012a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8012b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8012b8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012c3:	00 
  8012c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012c7:	89 04 24             	mov    %eax,(%esp)
  8012ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d1:	e8 b2 09 00 00       	call   801c88 <__udivdi3>
  8012d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012de:	89 04 24             	mov    %eax,(%esp)
  8012e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012e5:	89 fa                	mov    %edi,%edx
  8012e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ea:	e8 89 ff ff ff       	call   801278 <printnum>
  8012ef:	eb 0f                	jmp    801300 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8012f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f5:	89 34 24             	mov    %esi,(%esp)
  8012f8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8012fb:	4b                   	dec    %ebx
  8012fc:	85 db                	test   %ebx,%ebx
  8012fe:	7f f1                	jg     8012f1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801300:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801304:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801308:	8b 45 10             	mov    0x10(%ebp),%eax
  80130b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801316:	00 
  801317:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80131a:	89 04 24             	mov    %eax,(%esp)
  80131d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801320:	89 44 24 04          	mov    %eax,0x4(%esp)
  801324:	e8 7f 0a 00 00       	call   801da8 <__umoddi3>
  801329:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80132d:	0f be 80 43 20 80 00 	movsbl 0x802043(%eax),%eax
  801334:	89 04 24             	mov    %eax,(%esp)
  801337:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80133a:	83 c4 3c             	add    $0x3c,%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5f                   	pop    %edi
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    

00801342 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801345:	83 fa 01             	cmp    $0x1,%edx
  801348:	7e 0e                	jle    801358 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80134a:	8b 10                	mov    (%eax),%edx
  80134c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80134f:	89 08                	mov    %ecx,(%eax)
  801351:	8b 02                	mov    (%edx),%eax
  801353:	8b 52 04             	mov    0x4(%edx),%edx
  801356:	eb 22                	jmp    80137a <getuint+0x38>
	else if (lflag)
  801358:	85 d2                	test   %edx,%edx
  80135a:	74 10                	je     80136c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80135c:	8b 10                	mov    (%eax),%edx
  80135e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801361:	89 08                	mov    %ecx,(%eax)
  801363:	8b 02                	mov    (%edx),%eax
  801365:	ba 00 00 00 00       	mov    $0x0,%edx
  80136a:	eb 0e                	jmp    80137a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80136c:	8b 10                	mov    (%eax),%edx
  80136e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801371:	89 08                	mov    %ecx,(%eax)
  801373:	8b 02                	mov    (%edx),%eax
  801375:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    

0080137c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801382:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801385:	8b 10                	mov    (%eax),%edx
  801387:	3b 50 04             	cmp    0x4(%eax),%edx
  80138a:	73 08                	jae    801394 <sprintputch+0x18>
		*b->buf++ = ch;
  80138c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138f:	88 0a                	mov    %cl,(%edx)
  801391:	42                   	inc    %edx
  801392:	89 10                	mov    %edx,(%eax)
}
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80139c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80139f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b4:	89 04 24             	mov    %eax,(%esp)
  8013b7:	e8 02 00 00 00       	call   8013be <vprintfmt>
	va_end(ap);
}
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	57                   	push   %edi
  8013c2:	56                   	push   %esi
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 4c             	sub    $0x4c,%esp
  8013c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013ca:	8b 75 10             	mov    0x10(%ebp),%esi
  8013cd:	eb 12                	jmp    8013e1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	0f 84 6b 03 00 00    	je     801742 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8013d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013db:	89 04 24             	mov    %eax,(%esp)
  8013de:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8013e1:	0f b6 06             	movzbl (%esi),%eax
  8013e4:	46                   	inc    %esi
  8013e5:	83 f8 25             	cmp    $0x25,%eax
  8013e8:	75 e5                	jne    8013cf <vprintfmt+0x11>
  8013ea:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8013ee:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8013f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8013fa:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801401:	b9 00 00 00 00       	mov    $0x0,%ecx
  801406:	eb 26                	jmp    80142e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801408:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80140b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80140f:	eb 1d                	jmp    80142e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801411:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801414:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801418:	eb 14                	jmp    80142e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80141a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80141d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801424:	eb 08                	jmp    80142e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801426:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801429:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80142e:	0f b6 06             	movzbl (%esi),%eax
  801431:	8d 56 01             	lea    0x1(%esi),%edx
  801434:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801437:	8a 16                	mov    (%esi),%dl
  801439:	83 ea 23             	sub    $0x23,%edx
  80143c:	80 fa 55             	cmp    $0x55,%dl
  80143f:	0f 87 e1 02 00 00    	ja     801726 <vprintfmt+0x368>
  801445:	0f b6 d2             	movzbl %dl,%edx
  801448:	ff 24 95 80 21 80 00 	jmp    *0x802180(,%edx,4)
  80144f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801452:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801457:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80145a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80145e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801461:	8d 50 d0             	lea    -0x30(%eax),%edx
  801464:	83 fa 09             	cmp    $0x9,%edx
  801467:	77 2a                	ja     801493 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801469:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80146a:	eb eb                	jmp    801457 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80146c:	8b 45 14             	mov    0x14(%ebp),%eax
  80146f:	8d 50 04             	lea    0x4(%eax),%edx
  801472:	89 55 14             	mov    %edx,0x14(%ebp)
  801475:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801477:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80147a:	eb 17                	jmp    801493 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80147c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801480:	78 98                	js     80141a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801482:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801485:	eb a7                	jmp    80142e <vprintfmt+0x70>
  801487:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80148a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801491:	eb 9b                	jmp    80142e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801493:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801497:	79 95                	jns    80142e <vprintfmt+0x70>
  801499:	eb 8b                	jmp    801426 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80149b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80149c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80149f:	eb 8d                	jmp    80142e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8014a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a4:	8d 50 04             	lea    0x4(%eax),%edx
  8014a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ae:	8b 00                	mov    (%eax),%eax
  8014b0:	89 04 24             	mov    %eax,(%esp)
  8014b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8014b9:	e9 23 ff ff ff       	jmp    8013e1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8014be:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c1:	8d 50 04             	lea    0x4(%eax),%edx
  8014c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c7:	8b 00                	mov    (%eax),%eax
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	79 02                	jns    8014cf <vprintfmt+0x111>
  8014cd:	f7 d8                	neg    %eax
  8014cf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014d1:	83 f8 0f             	cmp    $0xf,%eax
  8014d4:	7f 0b                	jg     8014e1 <vprintfmt+0x123>
  8014d6:	8b 04 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%eax
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	75 23                	jne    801504 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8014e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014e5:	c7 44 24 08 5b 20 80 	movl   $0x80205b,0x8(%esp)
  8014ec:	00 
  8014ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f4:	89 04 24             	mov    %eax,(%esp)
  8014f7:	e8 9a fe ff ff       	call   801396 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8014ff:	e9 dd fe ff ff       	jmp    8013e1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801504:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801508:	c7 44 24 08 e6 1f 80 	movl   $0x801fe6,0x8(%esp)
  80150f:	00 
  801510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801514:	8b 55 08             	mov    0x8(%ebp),%edx
  801517:	89 14 24             	mov    %edx,(%esp)
  80151a:	e8 77 fe ff ff       	call   801396 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80151f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801522:	e9 ba fe ff ff       	jmp    8013e1 <vprintfmt+0x23>
  801527:	89 f9                	mov    %edi,%ecx
  801529:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80152c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80152f:	8b 45 14             	mov    0x14(%ebp),%eax
  801532:	8d 50 04             	lea    0x4(%eax),%edx
  801535:	89 55 14             	mov    %edx,0x14(%ebp)
  801538:	8b 30                	mov    (%eax),%esi
  80153a:	85 f6                	test   %esi,%esi
  80153c:	75 05                	jne    801543 <vprintfmt+0x185>
				p = "(null)";
  80153e:	be 54 20 80 00       	mov    $0x802054,%esi
			if (width > 0 && padc != '-')
  801543:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801547:	0f 8e 84 00 00 00    	jle    8015d1 <vprintfmt+0x213>
  80154d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801551:	74 7e                	je     8015d1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801553:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801557:	89 34 24             	mov    %esi,(%esp)
  80155a:	e8 8b 02 00 00       	call   8017ea <strnlen>
  80155f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801562:	29 c2                	sub    %eax,%edx
  801564:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801567:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80156b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80156e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801571:	89 de                	mov    %ebx,%esi
  801573:	89 d3                	mov    %edx,%ebx
  801575:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801577:	eb 0b                	jmp    801584 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801579:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157d:	89 3c 24             	mov    %edi,(%esp)
  801580:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801583:	4b                   	dec    %ebx
  801584:	85 db                	test   %ebx,%ebx
  801586:	7f f1                	jg     801579 <vprintfmt+0x1bb>
  801588:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80158b:	89 f3                	mov    %esi,%ebx
  80158d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801590:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801593:	85 c0                	test   %eax,%eax
  801595:	79 05                	jns    80159c <vprintfmt+0x1de>
  801597:	b8 00 00 00 00       	mov    $0x0,%eax
  80159c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80159f:	29 c2                	sub    %eax,%edx
  8015a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015a4:	eb 2b                	jmp    8015d1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8015a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015aa:	74 18                	je     8015c4 <vprintfmt+0x206>
  8015ac:	8d 50 e0             	lea    -0x20(%eax),%edx
  8015af:	83 fa 5e             	cmp    $0x5e,%edx
  8015b2:	76 10                	jbe    8015c4 <vprintfmt+0x206>
					putch('?', putdat);
  8015b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015bf:	ff 55 08             	call   *0x8(%ebp)
  8015c2:	eb 0a                	jmp    8015ce <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8015c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c8:	89 04 24             	mov    %eax,(%esp)
  8015cb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015ce:	ff 4d e4             	decl   -0x1c(%ebp)
  8015d1:	0f be 06             	movsbl (%esi),%eax
  8015d4:	46                   	inc    %esi
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	74 21                	je     8015fa <vprintfmt+0x23c>
  8015d9:	85 ff                	test   %edi,%edi
  8015db:	78 c9                	js     8015a6 <vprintfmt+0x1e8>
  8015dd:	4f                   	dec    %edi
  8015de:	79 c6                	jns    8015a6 <vprintfmt+0x1e8>
  8015e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e3:	89 de                	mov    %ebx,%esi
  8015e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8015e8:	eb 18                	jmp    801602 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8015f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015f7:	4b                   	dec    %ebx
  8015f8:	eb 08                	jmp    801602 <vprintfmt+0x244>
  8015fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015fd:	89 de                	mov    %ebx,%esi
  8015ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801602:	85 db                	test   %ebx,%ebx
  801604:	7f e4                	jg     8015ea <vprintfmt+0x22c>
  801606:	89 7d 08             	mov    %edi,0x8(%ebp)
  801609:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80160e:	e9 ce fd ff ff       	jmp    8013e1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801613:	83 f9 01             	cmp    $0x1,%ecx
  801616:	7e 10                	jle    801628 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801618:	8b 45 14             	mov    0x14(%ebp),%eax
  80161b:	8d 50 08             	lea    0x8(%eax),%edx
  80161e:	89 55 14             	mov    %edx,0x14(%ebp)
  801621:	8b 30                	mov    (%eax),%esi
  801623:	8b 78 04             	mov    0x4(%eax),%edi
  801626:	eb 26                	jmp    80164e <vprintfmt+0x290>
	else if (lflag)
  801628:	85 c9                	test   %ecx,%ecx
  80162a:	74 12                	je     80163e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80162c:	8b 45 14             	mov    0x14(%ebp),%eax
  80162f:	8d 50 04             	lea    0x4(%eax),%edx
  801632:	89 55 14             	mov    %edx,0x14(%ebp)
  801635:	8b 30                	mov    (%eax),%esi
  801637:	89 f7                	mov    %esi,%edi
  801639:	c1 ff 1f             	sar    $0x1f,%edi
  80163c:	eb 10                	jmp    80164e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80163e:	8b 45 14             	mov    0x14(%ebp),%eax
  801641:	8d 50 04             	lea    0x4(%eax),%edx
  801644:	89 55 14             	mov    %edx,0x14(%ebp)
  801647:	8b 30                	mov    (%eax),%esi
  801649:	89 f7                	mov    %esi,%edi
  80164b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80164e:	85 ff                	test   %edi,%edi
  801650:	78 0a                	js     80165c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801652:	b8 0a 00 00 00       	mov    $0xa,%eax
  801657:	e9 8c 00 00 00       	jmp    8016e8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80165c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801660:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801667:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80166a:	f7 de                	neg    %esi
  80166c:	83 d7 00             	adc    $0x0,%edi
  80166f:	f7 df                	neg    %edi
			}
			base = 10;
  801671:	b8 0a 00 00 00       	mov    $0xa,%eax
  801676:	eb 70                	jmp    8016e8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801678:	89 ca                	mov    %ecx,%edx
  80167a:	8d 45 14             	lea    0x14(%ebp),%eax
  80167d:	e8 c0 fc ff ff       	call   801342 <getuint>
  801682:	89 c6                	mov    %eax,%esi
  801684:	89 d7                	mov    %edx,%edi
			base = 10;
  801686:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80168b:	eb 5b                	jmp    8016e8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80168d:	89 ca                	mov    %ecx,%edx
  80168f:	8d 45 14             	lea    0x14(%ebp),%eax
  801692:	e8 ab fc ff ff       	call   801342 <getuint>
  801697:	89 c6                	mov    %eax,%esi
  801699:	89 d7                	mov    %edx,%edi
			base = 8;
  80169b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8016a0:	eb 46                	jmp    8016e8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8016a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8016ad:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8016b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8016bb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8016be:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c1:	8d 50 04             	lea    0x4(%eax),%edx
  8016c4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8016c7:	8b 30                	mov    (%eax),%esi
  8016c9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8016ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8016d3:	eb 13                	jmp    8016e8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8016d5:	89 ca                	mov    %ecx,%edx
  8016d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8016da:	e8 63 fc ff ff       	call   801342 <getuint>
  8016df:	89 c6                	mov    %eax,%esi
  8016e1:	89 d7                	mov    %edx,%edi
			base = 16;
  8016e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8016e8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8016ec:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016fb:	89 34 24             	mov    %esi,(%esp)
  8016fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801702:	89 da                	mov    %ebx,%edx
  801704:	8b 45 08             	mov    0x8(%ebp),%eax
  801707:	e8 6c fb ff ff       	call   801278 <printnum>
			break;
  80170c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80170f:	e9 cd fc ff ff       	jmp    8013e1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801714:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801718:	89 04 24             	mov    %eax,(%esp)
  80171b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801721:	e9 bb fc ff ff       	jmp    8013e1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801726:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80172a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801731:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801734:	eb 01                	jmp    801737 <vprintfmt+0x379>
  801736:	4e                   	dec    %esi
  801737:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80173b:	75 f9                	jne    801736 <vprintfmt+0x378>
  80173d:	e9 9f fc ff ff       	jmp    8013e1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801742:	83 c4 4c             	add    $0x4c,%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5f                   	pop    %edi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	83 ec 28             	sub    $0x28,%esp
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
  801753:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801756:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801759:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80175d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801760:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801767:	85 c0                	test   %eax,%eax
  801769:	74 30                	je     80179b <vsnprintf+0x51>
  80176b:	85 d2                	test   %edx,%edx
  80176d:	7e 33                	jle    8017a2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80176f:	8b 45 14             	mov    0x14(%ebp),%eax
  801772:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801776:	8b 45 10             	mov    0x10(%ebp),%eax
  801779:	89 44 24 08          	mov    %eax,0x8(%esp)
  80177d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801780:	89 44 24 04          	mov    %eax,0x4(%esp)
  801784:	c7 04 24 7c 13 80 00 	movl   $0x80137c,(%esp)
  80178b:	e8 2e fc ff ff       	call   8013be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801790:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801793:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801799:	eb 0c                	jmp    8017a7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80179b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a0:	eb 05                	jmp    8017a7 <vsnprintf+0x5d>
  8017a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8017af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8017b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c7:	89 04 24             	mov    %eax,(%esp)
  8017ca:	e8 7b ff ff ff       	call   80174a <vsnprintf>
	va_end(ap);

	return rc;
}
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    
  8017d1:	00 00                	add    %al,(%eax)
	...

008017d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8017da:	b8 00 00 00 00       	mov    $0x0,%eax
  8017df:	eb 01                	jmp    8017e2 <strlen+0xe>
		n++;
  8017e1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8017e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8017e6:	75 f9                	jne    8017e1 <strlen+0xd>
		n++;
	return n;
}
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8017f0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f8:	eb 01                	jmp    8017fb <strnlen+0x11>
		n++;
  8017fa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017fb:	39 d0                	cmp    %edx,%eax
  8017fd:	74 06                	je     801805 <strnlen+0x1b>
  8017ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801803:	75 f5                	jne    8017fa <strnlen+0x10>
		n++;
	return n;
}
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	53                   	push   %ebx
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801811:	ba 00 00 00 00       	mov    $0x0,%edx
  801816:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801819:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80181c:	42                   	inc    %edx
  80181d:	84 c9                	test   %cl,%cl
  80181f:	75 f5                	jne    801816 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801821:	5b                   	pop    %ebx
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	53                   	push   %ebx
  801828:	83 ec 08             	sub    $0x8,%esp
  80182b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80182e:	89 1c 24             	mov    %ebx,(%esp)
  801831:	e8 9e ff ff ff       	call   8017d4 <strlen>
	strcpy(dst + len, src);
  801836:	8b 55 0c             	mov    0xc(%ebp),%edx
  801839:	89 54 24 04          	mov    %edx,0x4(%esp)
  80183d:	01 d8                	add    %ebx,%eax
  80183f:	89 04 24             	mov    %eax,(%esp)
  801842:	e8 c0 ff ff ff       	call   801807 <strcpy>
	return dst;
}
  801847:	89 d8                	mov    %ebx,%eax
  801849:	83 c4 08             	add    $0x8,%esp
  80184c:	5b                   	pop    %ebx
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80185a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80185d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801862:	eb 0c                	jmp    801870 <strncpy+0x21>
		*dst++ = *src;
  801864:	8a 1a                	mov    (%edx),%bl
  801866:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801869:	80 3a 01             	cmpb   $0x1,(%edx)
  80186c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80186f:	41                   	inc    %ecx
  801870:	39 f1                	cmp    %esi,%ecx
  801872:	75 f0                	jne    801864 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	8b 75 08             	mov    0x8(%ebp),%esi
  801880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801883:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801886:	85 d2                	test   %edx,%edx
  801888:	75 0a                	jne    801894 <strlcpy+0x1c>
  80188a:	89 f0                	mov    %esi,%eax
  80188c:	eb 1a                	jmp    8018a8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80188e:	88 18                	mov    %bl,(%eax)
  801890:	40                   	inc    %eax
  801891:	41                   	inc    %ecx
  801892:	eb 02                	jmp    801896 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801894:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801896:	4a                   	dec    %edx
  801897:	74 0a                	je     8018a3 <strlcpy+0x2b>
  801899:	8a 19                	mov    (%ecx),%bl
  80189b:	84 db                	test   %bl,%bl
  80189d:	75 ef                	jne    80188e <strlcpy+0x16>
  80189f:	89 c2                	mov    %eax,%edx
  8018a1:	eb 02                	jmp    8018a5 <strlcpy+0x2d>
  8018a3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8018a5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8018a8:	29 f0                	sub    %esi,%eax
}
  8018aa:	5b                   	pop    %ebx
  8018ab:	5e                   	pop    %esi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018b7:	eb 02                	jmp    8018bb <strcmp+0xd>
		p++, q++;
  8018b9:	41                   	inc    %ecx
  8018ba:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8018bb:	8a 01                	mov    (%ecx),%al
  8018bd:	84 c0                	test   %al,%al
  8018bf:	74 04                	je     8018c5 <strcmp+0x17>
  8018c1:	3a 02                	cmp    (%edx),%al
  8018c3:	74 f4                	je     8018b9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018c5:	0f b6 c0             	movzbl %al,%eax
  8018c8:	0f b6 12             	movzbl (%edx),%edx
  8018cb:	29 d0                	sub    %edx,%eax
}
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	53                   	push   %ebx
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8018dc:	eb 03                	jmp    8018e1 <strncmp+0x12>
		n--, p++, q++;
  8018de:	4a                   	dec    %edx
  8018df:	40                   	inc    %eax
  8018e0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8018e1:	85 d2                	test   %edx,%edx
  8018e3:	74 14                	je     8018f9 <strncmp+0x2a>
  8018e5:	8a 18                	mov    (%eax),%bl
  8018e7:	84 db                	test   %bl,%bl
  8018e9:	74 04                	je     8018ef <strncmp+0x20>
  8018eb:	3a 19                	cmp    (%ecx),%bl
  8018ed:	74 ef                	je     8018de <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018ef:	0f b6 00             	movzbl (%eax),%eax
  8018f2:	0f b6 11             	movzbl (%ecx),%edx
  8018f5:	29 d0                	sub    %edx,%eax
  8018f7:	eb 05                	jmp    8018fe <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8018f9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8018fe:	5b                   	pop    %ebx
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80190a:	eb 05                	jmp    801911 <strchr+0x10>
		if (*s == c)
  80190c:	38 ca                	cmp    %cl,%dl
  80190e:	74 0c                	je     80191c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801910:	40                   	inc    %eax
  801911:	8a 10                	mov    (%eax),%dl
  801913:	84 d2                	test   %dl,%dl
  801915:	75 f5                	jne    80190c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
  801924:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801927:	eb 05                	jmp    80192e <strfind+0x10>
		if (*s == c)
  801929:	38 ca                	cmp    %cl,%dl
  80192b:	74 07                	je     801934 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80192d:	40                   	inc    %eax
  80192e:	8a 10                	mov    (%eax),%dl
  801930:	84 d2                	test   %dl,%dl
  801932:	75 f5                	jne    801929 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    

00801936 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	57                   	push   %edi
  80193a:	56                   	push   %esi
  80193b:	53                   	push   %ebx
  80193c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80193f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801942:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801945:	85 c9                	test   %ecx,%ecx
  801947:	74 30                	je     801979 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801949:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80194f:	75 25                	jne    801976 <memset+0x40>
  801951:	f6 c1 03             	test   $0x3,%cl
  801954:	75 20                	jne    801976 <memset+0x40>
		c &= 0xFF;
  801956:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801959:	89 d3                	mov    %edx,%ebx
  80195b:	c1 e3 08             	shl    $0x8,%ebx
  80195e:	89 d6                	mov    %edx,%esi
  801960:	c1 e6 18             	shl    $0x18,%esi
  801963:	89 d0                	mov    %edx,%eax
  801965:	c1 e0 10             	shl    $0x10,%eax
  801968:	09 f0                	or     %esi,%eax
  80196a:	09 d0                	or     %edx,%eax
  80196c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80196e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801971:	fc                   	cld    
  801972:	f3 ab                	rep stos %eax,%es:(%edi)
  801974:	eb 03                	jmp    801979 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801976:	fc                   	cld    
  801977:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801979:	89 f8                	mov    %edi,%eax
  80197b:	5b                   	pop    %ebx
  80197c:	5e                   	pop    %esi
  80197d:	5f                   	pop    %edi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	57                   	push   %edi
  801984:	56                   	push   %esi
  801985:	8b 45 08             	mov    0x8(%ebp),%eax
  801988:	8b 75 0c             	mov    0xc(%ebp),%esi
  80198b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80198e:	39 c6                	cmp    %eax,%esi
  801990:	73 34                	jae    8019c6 <memmove+0x46>
  801992:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801995:	39 d0                	cmp    %edx,%eax
  801997:	73 2d                	jae    8019c6 <memmove+0x46>
		s += n;
		d += n;
  801999:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80199c:	f6 c2 03             	test   $0x3,%dl
  80199f:	75 1b                	jne    8019bc <memmove+0x3c>
  8019a1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019a7:	75 13                	jne    8019bc <memmove+0x3c>
  8019a9:	f6 c1 03             	test   $0x3,%cl
  8019ac:	75 0e                	jne    8019bc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019ae:	83 ef 04             	sub    $0x4,%edi
  8019b1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019b4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8019b7:	fd                   	std    
  8019b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019ba:	eb 07                	jmp    8019c3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019bc:	4f                   	dec    %edi
  8019bd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8019c0:	fd                   	std    
  8019c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019c3:	fc                   	cld    
  8019c4:	eb 20                	jmp    8019e6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019cc:	75 13                	jne    8019e1 <memmove+0x61>
  8019ce:	a8 03                	test   $0x3,%al
  8019d0:	75 0f                	jne    8019e1 <memmove+0x61>
  8019d2:	f6 c1 03             	test   $0x3,%cl
  8019d5:	75 0a                	jne    8019e1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019d7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8019da:	89 c7                	mov    %eax,%edi
  8019dc:	fc                   	cld    
  8019dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019df:	eb 05                	jmp    8019e6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8019e1:	89 c7                	mov    %eax,%edi
  8019e3:	fc                   	cld    
  8019e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019e6:	5e                   	pop    %esi
  8019e7:	5f                   	pop    %edi
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    

008019ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	89 04 24             	mov    %eax,(%esp)
  801a04:	e8 77 ff ff ff       	call   801980 <memmove>
}
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	57                   	push   %edi
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a14:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1f:	eb 16                	jmp    801a37 <memcmp+0x2c>
		if (*s1 != *s2)
  801a21:	8a 04 17             	mov    (%edi,%edx,1),%al
  801a24:	42                   	inc    %edx
  801a25:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801a29:	38 c8                	cmp    %cl,%al
  801a2b:	74 0a                	je     801a37 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801a2d:	0f b6 c0             	movzbl %al,%eax
  801a30:	0f b6 c9             	movzbl %cl,%ecx
  801a33:	29 c8                	sub    %ecx,%eax
  801a35:	eb 09                	jmp    801a40 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a37:	39 da                	cmp    %ebx,%edx
  801a39:	75 e6                	jne    801a21 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801a3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a40:	5b                   	pop    %ebx
  801a41:	5e                   	pop    %esi
  801a42:	5f                   	pop    %edi
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a4e:	89 c2                	mov    %eax,%edx
  801a50:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a53:	eb 05                	jmp    801a5a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a55:	38 08                	cmp    %cl,(%eax)
  801a57:	74 05                	je     801a5e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a59:	40                   	inc    %eax
  801a5a:	39 d0                	cmp    %edx,%eax
  801a5c:	72 f7                	jb     801a55 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    

00801a60 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	57                   	push   %edi
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	8b 55 08             	mov    0x8(%ebp),%edx
  801a69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a6c:	eb 01                	jmp    801a6f <strtol+0xf>
		s++;
  801a6e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a6f:	8a 02                	mov    (%edx),%al
  801a71:	3c 20                	cmp    $0x20,%al
  801a73:	74 f9                	je     801a6e <strtol+0xe>
  801a75:	3c 09                	cmp    $0x9,%al
  801a77:	74 f5                	je     801a6e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a79:	3c 2b                	cmp    $0x2b,%al
  801a7b:	75 08                	jne    801a85 <strtol+0x25>
		s++;
  801a7d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  801a83:	eb 13                	jmp    801a98 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801a85:	3c 2d                	cmp    $0x2d,%al
  801a87:	75 0a                	jne    801a93 <strtol+0x33>
		s++, neg = 1;
  801a89:	8d 52 01             	lea    0x1(%edx),%edx
  801a8c:	bf 01 00 00 00       	mov    $0x1,%edi
  801a91:	eb 05                	jmp    801a98 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a98:	85 db                	test   %ebx,%ebx
  801a9a:	74 05                	je     801aa1 <strtol+0x41>
  801a9c:	83 fb 10             	cmp    $0x10,%ebx
  801a9f:	75 28                	jne    801ac9 <strtol+0x69>
  801aa1:	8a 02                	mov    (%edx),%al
  801aa3:	3c 30                	cmp    $0x30,%al
  801aa5:	75 10                	jne    801ab7 <strtol+0x57>
  801aa7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801aab:	75 0a                	jne    801ab7 <strtol+0x57>
		s += 2, base = 16;
  801aad:	83 c2 02             	add    $0x2,%edx
  801ab0:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ab5:	eb 12                	jmp    801ac9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801ab7:	85 db                	test   %ebx,%ebx
  801ab9:	75 0e                	jne    801ac9 <strtol+0x69>
  801abb:	3c 30                	cmp    $0x30,%al
  801abd:	75 05                	jne    801ac4 <strtol+0x64>
		s++, base = 8;
  801abf:	42                   	inc    %edx
  801ac0:	b3 08                	mov    $0x8,%bl
  801ac2:	eb 05                	jmp    801ac9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801ac4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ace:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ad0:	8a 0a                	mov    (%edx),%cl
  801ad2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801ad5:	80 fb 09             	cmp    $0x9,%bl
  801ad8:	77 08                	ja     801ae2 <strtol+0x82>
			dig = *s - '0';
  801ada:	0f be c9             	movsbl %cl,%ecx
  801add:	83 e9 30             	sub    $0x30,%ecx
  801ae0:	eb 1e                	jmp    801b00 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801ae2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801ae5:	80 fb 19             	cmp    $0x19,%bl
  801ae8:	77 08                	ja     801af2 <strtol+0x92>
			dig = *s - 'a' + 10;
  801aea:	0f be c9             	movsbl %cl,%ecx
  801aed:	83 e9 57             	sub    $0x57,%ecx
  801af0:	eb 0e                	jmp    801b00 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801af2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801af5:	80 fb 19             	cmp    $0x19,%bl
  801af8:	77 12                	ja     801b0c <strtol+0xac>
			dig = *s - 'A' + 10;
  801afa:	0f be c9             	movsbl %cl,%ecx
  801afd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b00:	39 f1                	cmp    %esi,%ecx
  801b02:	7d 0c                	jge    801b10 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b04:	42                   	inc    %edx
  801b05:	0f af c6             	imul   %esi,%eax
  801b08:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801b0a:	eb c4                	jmp    801ad0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801b0c:	89 c1                	mov    %eax,%ecx
  801b0e:	eb 02                	jmp    801b12 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b10:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801b12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b16:	74 05                	je     801b1d <strtol+0xbd>
		*endptr = (char *) s;
  801b18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b1b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801b1d:	85 ff                	test   %edi,%edi
  801b1f:	74 04                	je     801b25 <strtol+0xc5>
  801b21:	89 c8                	mov    %ecx,%eax
  801b23:	f7 d8                	neg    %eax
}
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5f                   	pop    %edi
  801b28:	5d                   	pop    %ebp
  801b29:	c3                   	ret    
	...

00801b2c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	57                   	push   %edi
  801b30:	56                   	push   %esi
  801b31:	53                   	push   %ebx
  801b32:	83 ec 1c             	sub    $0x1c,%esp
  801b35:	8b 75 08             	mov    0x8(%ebp),%esi
  801b38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b3b:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801b3e:	85 db                	test   %ebx,%ebx
  801b40:	75 05                	jne    801b47 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801b42:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801b47:	89 1c 24             	mov    %ebx,(%esp)
  801b4a:	e8 48 e8 ff ff       	call   800397 <sys_ipc_recv>
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	79 16                	jns    801b69 <ipc_recv+0x3d>
		*from_env_store = 0;
  801b53:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801b59:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801b5f:	89 1c 24             	mov    %ebx,(%esp)
  801b62:	e8 30 e8 ff ff       	call   800397 <sys_ipc_recv>
  801b67:	eb 24                	jmp    801b8d <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801b69:	85 f6                	test   %esi,%esi
  801b6b:	74 0a                	je     801b77 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801b6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b72:	8b 40 74             	mov    0x74(%eax),%eax
  801b75:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801b77:	85 ff                	test   %edi,%edi
  801b79:	74 0a                	je     801b85 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801b7b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b80:	8b 40 78             	mov    0x78(%eax),%eax
  801b83:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801b85:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b8d:	83 c4 1c             	add    $0x1c,%esp
  801b90:	5b                   	pop    %ebx
  801b91:	5e                   	pop    %esi
  801b92:	5f                   	pop    %edi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	57                   	push   %edi
  801b99:	56                   	push   %esi
  801b9a:	53                   	push   %ebx
  801b9b:	83 ec 1c             	sub    $0x1c,%esp
  801b9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ba4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801ba7:	85 db                	test   %ebx,%ebx
  801ba9:	75 05                	jne    801bb0 <ipc_send+0x1b>
		pg = (void *)-1;
  801bab:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bb0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bb4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bb8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbf:	89 04 24             	mov    %eax,(%esp)
  801bc2:	e8 ad e7 ff ff       	call   800374 <sys_ipc_try_send>
		if (r == 0) {		
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	74 2c                	je     801bf7 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801bcb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bce:	75 07                	jne    801bd7 <ipc_send+0x42>
			sys_yield();
  801bd0:	e8 8d e5 ff ff       	call   800162 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801bd5:	eb d9                	jmp    801bb0 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801bd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdb:	c7 44 24 08 40 23 80 	movl   $0x802340,0x8(%esp)
  801be2:	00 
  801be3:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801bea:	00 
  801beb:	c7 04 24 4e 23 80 00 	movl   $0x80234e,(%esp)
  801bf2:	e8 6d f5 ff ff       	call   801164 <_panic>
		}
	}
}
  801bf7:	83 c4 1c             	add    $0x1c,%esp
  801bfa:	5b                   	pop    %ebx
  801bfb:	5e                   	pop    %esi
  801bfc:	5f                   	pop    %edi
  801bfd:	5d                   	pop    %ebp
  801bfe:	c3                   	ret    

00801bff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	53                   	push   %ebx
  801c03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c0b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c12:	89 c2                	mov    %eax,%edx
  801c14:	c1 e2 07             	shl    $0x7,%edx
  801c17:	29 ca                	sub    %ecx,%edx
  801c19:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c1f:	8b 52 50             	mov    0x50(%edx),%edx
  801c22:	39 da                	cmp    %ebx,%edx
  801c24:	75 0f                	jne    801c35 <ipc_find_env+0x36>
			return envs[i].env_id;
  801c26:	c1 e0 07             	shl    $0x7,%eax
  801c29:	29 c8                	sub    %ecx,%eax
  801c2b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c30:	8b 40 40             	mov    0x40(%eax),%eax
  801c33:	eb 0c                	jmp    801c41 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c35:	40                   	inc    %eax
  801c36:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c3b:	75 ce                	jne    801c0b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c3d:	66 b8 00 00          	mov    $0x0,%ax
}
  801c41:	5b                   	pop    %ebx
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c4a:	89 c2                	mov    %eax,%edx
  801c4c:	c1 ea 16             	shr    $0x16,%edx
  801c4f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c56:	f6 c2 01             	test   $0x1,%dl
  801c59:	74 1e                	je     801c79 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c5b:	c1 e8 0c             	shr    $0xc,%eax
  801c5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c65:	a8 01                	test   $0x1,%al
  801c67:	74 17                	je     801c80 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c69:	c1 e8 0c             	shr    $0xc,%eax
  801c6c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c73:	ef 
  801c74:	0f b7 c0             	movzwl %ax,%eax
  801c77:	eb 0c                	jmp    801c85 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c79:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7e:	eb 05                	jmp    801c85 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c80:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    
	...

00801c88 <__udivdi3>:
  801c88:	55                   	push   %ebp
  801c89:	57                   	push   %edi
  801c8a:	56                   	push   %esi
  801c8b:	83 ec 10             	sub    $0x10,%esp
  801c8e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801c92:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801c9e:	89 cd                	mov    %ecx,%ebp
  801ca0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	75 2c                	jne    801cd4 <__udivdi3+0x4c>
  801ca8:	39 f9                	cmp    %edi,%ecx
  801caa:	77 68                	ja     801d14 <__udivdi3+0x8c>
  801cac:	85 c9                	test   %ecx,%ecx
  801cae:	75 0b                	jne    801cbb <__udivdi3+0x33>
  801cb0:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb5:	31 d2                	xor    %edx,%edx
  801cb7:	f7 f1                	div    %ecx
  801cb9:	89 c1                	mov    %eax,%ecx
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	89 f8                	mov    %edi,%eax
  801cbf:	f7 f1                	div    %ecx
  801cc1:	89 c7                	mov    %eax,%edi
  801cc3:	89 f0                	mov    %esi,%eax
  801cc5:	f7 f1                	div    %ecx
  801cc7:	89 c6                	mov    %eax,%esi
  801cc9:	89 f0                	mov    %esi,%eax
  801ccb:	89 fa                	mov    %edi,%edx
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
  801cd4:	39 f8                	cmp    %edi,%eax
  801cd6:	77 2c                	ja     801d04 <__udivdi3+0x7c>
  801cd8:	0f bd f0             	bsr    %eax,%esi
  801cdb:	83 f6 1f             	xor    $0x1f,%esi
  801cde:	75 4c                	jne    801d2c <__udivdi3+0xa4>
  801ce0:	39 f8                	cmp    %edi,%eax
  801ce2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce7:	72 0a                	jb     801cf3 <__udivdi3+0x6b>
  801ce9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ced:	0f 87 ad 00 00 00    	ja     801da0 <__udivdi3+0x118>
  801cf3:	be 01 00 00 00       	mov    $0x1,%esi
  801cf8:	89 f0                	mov    %esi,%eax
  801cfa:	89 fa                	mov    %edi,%edx
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    
  801d03:	90                   	nop
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	31 f6                	xor    %esi,%esi
  801d08:	89 f0                	mov    %esi,%eax
  801d0a:	89 fa                	mov    %edi,%edx
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	5e                   	pop    %esi
  801d10:	5f                   	pop    %edi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    
  801d13:	90                   	nop
  801d14:	89 fa                	mov    %edi,%edx
  801d16:	89 f0                	mov    %esi,%eax
  801d18:	f7 f1                	div    %ecx
  801d1a:	89 c6                	mov    %eax,%esi
  801d1c:	31 ff                	xor    %edi,%edi
  801d1e:	89 f0                	mov    %esi,%eax
  801d20:	89 fa                	mov    %edi,%edx
  801d22:	83 c4 10             	add    $0x10,%esp
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d 76 00             	lea    0x0(%esi),%esi
  801d2c:	89 f1                	mov    %esi,%ecx
  801d2e:	d3 e0                	shl    %cl,%eax
  801d30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d34:	b8 20 00 00 00       	mov    $0x20,%eax
  801d39:	29 f0                	sub    %esi,%eax
  801d3b:	89 ea                	mov    %ebp,%edx
  801d3d:	88 c1                	mov    %al,%cl
  801d3f:	d3 ea                	shr    %cl,%edx
  801d41:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d45:	09 ca                	or     %ecx,%edx
  801d47:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d4b:	89 f1                	mov    %esi,%ecx
  801d4d:	d3 e5                	shl    %cl,%ebp
  801d4f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d53:	89 fd                	mov    %edi,%ebp
  801d55:	88 c1                	mov    %al,%cl
  801d57:	d3 ed                	shr    %cl,%ebp
  801d59:	89 fa                	mov    %edi,%edx
  801d5b:	89 f1                	mov    %esi,%ecx
  801d5d:	d3 e2                	shl    %cl,%edx
  801d5f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d63:	88 c1                	mov    %al,%cl
  801d65:	d3 ef                	shr    %cl,%edi
  801d67:	09 d7                	or     %edx,%edi
  801d69:	89 f8                	mov    %edi,%eax
  801d6b:	89 ea                	mov    %ebp,%edx
  801d6d:	f7 74 24 08          	divl   0x8(%esp)
  801d71:	89 d1                	mov    %edx,%ecx
  801d73:	89 c7                	mov    %eax,%edi
  801d75:	f7 64 24 0c          	mull   0xc(%esp)
  801d79:	39 d1                	cmp    %edx,%ecx
  801d7b:	72 17                	jb     801d94 <__udivdi3+0x10c>
  801d7d:	74 09                	je     801d88 <__udivdi3+0x100>
  801d7f:	89 fe                	mov    %edi,%esi
  801d81:	31 ff                	xor    %edi,%edi
  801d83:	e9 41 ff ff ff       	jmp    801cc9 <__udivdi3+0x41>
  801d88:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d8c:	89 f1                	mov    %esi,%ecx
  801d8e:	d3 e2                	shl    %cl,%edx
  801d90:	39 c2                	cmp    %eax,%edx
  801d92:	73 eb                	jae    801d7f <__udivdi3+0xf7>
  801d94:	8d 77 ff             	lea    -0x1(%edi),%esi
  801d97:	31 ff                	xor    %edi,%edi
  801d99:	e9 2b ff ff ff       	jmp    801cc9 <__udivdi3+0x41>
  801d9e:	66 90                	xchg   %ax,%ax
  801da0:	31 f6                	xor    %esi,%esi
  801da2:	e9 22 ff ff ff       	jmp    801cc9 <__udivdi3+0x41>
	...

00801da8 <__umoddi3>:
  801da8:	55                   	push   %ebp
  801da9:	57                   	push   %edi
  801daa:	56                   	push   %esi
  801dab:	83 ec 20             	sub    $0x20,%esp
  801dae:	8b 44 24 30          	mov    0x30(%esp),%eax
  801db2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801db6:	89 44 24 14          	mov    %eax,0x14(%esp)
  801dba:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dbe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dc2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801dc6:	89 c7                	mov    %eax,%edi
  801dc8:	89 f2                	mov    %esi,%edx
  801dca:	85 ed                	test   %ebp,%ebp
  801dcc:	75 16                	jne    801de4 <__umoddi3+0x3c>
  801dce:	39 f1                	cmp    %esi,%ecx
  801dd0:	0f 86 a6 00 00 00    	jbe    801e7c <__umoddi3+0xd4>
  801dd6:	f7 f1                	div    %ecx
  801dd8:	89 d0                	mov    %edx,%eax
  801dda:	31 d2                	xor    %edx,%edx
  801ddc:	83 c4 20             	add    $0x20,%esp
  801ddf:	5e                   	pop    %esi
  801de0:	5f                   	pop    %edi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    
  801de3:	90                   	nop
  801de4:	39 f5                	cmp    %esi,%ebp
  801de6:	0f 87 ac 00 00 00    	ja     801e98 <__umoddi3+0xf0>
  801dec:	0f bd c5             	bsr    %ebp,%eax
  801def:	83 f0 1f             	xor    $0x1f,%eax
  801df2:	89 44 24 10          	mov    %eax,0x10(%esp)
  801df6:	0f 84 a8 00 00 00    	je     801ea4 <__umoddi3+0xfc>
  801dfc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e00:	d3 e5                	shl    %cl,%ebp
  801e02:	bf 20 00 00 00       	mov    $0x20,%edi
  801e07:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e0f:	89 f9                	mov    %edi,%ecx
  801e11:	d3 e8                	shr    %cl,%eax
  801e13:	09 e8                	or     %ebp,%eax
  801e15:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e19:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e1d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e21:	d3 e0                	shl    %cl,%eax
  801e23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e27:	89 f2                	mov    %esi,%edx
  801e29:	d3 e2                	shl    %cl,%edx
  801e2b:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e2f:	d3 e0                	shl    %cl,%eax
  801e31:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e35:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e39:	89 f9                	mov    %edi,%ecx
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	09 d0                	or     %edx,%eax
  801e3f:	d3 ee                	shr    %cl,%esi
  801e41:	89 f2                	mov    %esi,%edx
  801e43:	f7 74 24 18          	divl   0x18(%esp)
  801e47:	89 d6                	mov    %edx,%esi
  801e49:	f7 64 24 0c          	mull   0xc(%esp)
  801e4d:	89 c5                	mov    %eax,%ebp
  801e4f:	89 d1                	mov    %edx,%ecx
  801e51:	39 d6                	cmp    %edx,%esi
  801e53:	72 67                	jb     801ebc <__umoddi3+0x114>
  801e55:	74 75                	je     801ecc <__umoddi3+0x124>
  801e57:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e5b:	29 e8                	sub    %ebp,%eax
  801e5d:	19 ce                	sbb    %ecx,%esi
  801e5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e63:	d3 e8                	shr    %cl,%eax
  801e65:	89 f2                	mov    %esi,%edx
  801e67:	89 f9                	mov    %edi,%ecx
  801e69:	d3 e2                	shl    %cl,%edx
  801e6b:	09 d0                	or     %edx,%eax
  801e6d:	89 f2                	mov    %esi,%edx
  801e6f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e73:	d3 ea                	shr    %cl,%edx
  801e75:	83 c4 20             	add    $0x20,%esp
  801e78:	5e                   	pop    %esi
  801e79:	5f                   	pop    %edi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    
  801e7c:	85 c9                	test   %ecx,%ecx
  801e7e:	75 0b                	jne    801e8b <__umoddi3+0xe3>
  801e80:	b8 01 00 00 00       	mov    $0x1,%eax
  801e85:	31 d2                	xor    %edx,%edx
  801e87:	f7 f1                	div    %ecx
  801e89:	89 c1                	mov    %eax,%ecx
  801e8b:	89 f0                	mov    %esi,%eax
  801e8d:	31 d2                	xor    %edx,%edx
  801e8f:	f7 f1                	div    %ecx
  801e91:	89 f8                	mov    %edi,%eax
  801e93:	e9 3e ff ff ff       	jmp    801dd6 <__umoddi3+0x2e>
  801e98:	89 f2                	mov    %esi,%edx
  801e9a:	83 c4 20             	add    $0x20,%esp
  801e9d:	5e                   	pop    %esi
  801e9e:	5f                   	pop    %edi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    
  801ea1:	8d 76 00             	lea    0x0(%esi),%esi
  801ea4:	39 f5                	cmp    %esi,%ebp
  801ea6:	72 04                	jb     801eac <__umoddi3+0x104>
  801ea8:	39 f9                	cmp    %edi,%ecx
  801eaa:	77 06                	ja     801eb2 <__umoddi3+0x10a>
  801eac:	89 f2                	mov    %esi,%edx
  801eae:	29 cf                	sub    %ecx,%edi
  801eb0:	19 ea                	sbb    %ebp,%edx
  801eb2:	89 f8                	mov    %edi,%eax
  801eb4:	83 c4 20             	add    $0x20,%esp
  801eb7:	5e                   	pop    %esi
  801eb8:	5f                   	pop    %edi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    
  801ebb:	90                   	nop
  801ebc:	89 d1                	mov    %edx,%ecx
  801ebe:	89 c5                	mov    %eax,%ebp
  801ec0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801ec4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ec8:	eb 8d                	jmp    801e57 <__umoddi3+0xaf>
  801eca:	66 90                	xchg   %ax,%ax
  801ecc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801ed0:	72 ea                	jb     801ebc <__umoddi3+0x114>
  801ed2:	89 f1                	mov    %esi,%ecx
  801ed4:	eb 81                	jmp    801e57 <__umoddi3+0xaf>
