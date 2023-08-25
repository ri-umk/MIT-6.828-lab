
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 04 04 80 	movl   $0x800404,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 eb 02 00 00       	call   800339 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	83 ec 10             	sub    $0x10,%esp
  800064:	8b 75 08             	mov    0x8(%ebp),%esi
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  80006a:	e8 ec 00 00 00       	call   80015b <sys_getenvid>
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007b:	c1 e0 07             	shl    $0x7,%eax
  80007e:	29 d0                	sub    %edx,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 f6                	test   %esi,%esi
  80008c:	7e 07                	jle    800095 <libmain+0x39>
		binaryname = argv[0];
  80008e:	8b 03                	mov    (%ebx),%eax
  800090:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800095:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800099:	89 34 24             	mov    %esi,(%esp)
  80009c:	e8 93 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 0a 00 00 00       	call   8000b0 <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b6:	e8 58 05 00 00       	call   800613 <close_all>
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 42 00 00 00       	call   800109 <sys_env_destroy>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000da:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dd:	89 c3                	mov    %eax,%ebx
  8000df:	89 c7                	mov    %eax,%edi
  8000e1:	89 c6                	mov    %eax,%esi
  8000e3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e5:	5b                   	pop    %ebx
  8000e6:	5e                   	pop    %esi
  8000e7:	5f                   	pop    %edi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fa:	89 d1                	mov    %edx,%ecx
  8000fc:	89 d3                	mov    %edx,%ebx
  8000fe:	89 d7                	mov    %edx,%edi
  800100:	89 d6                	mov    %edx,%esi
  800102:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    

00800109 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	57                   	push   %edi
  80010d:	56                   	push   %esi
  80010e:	53                   	push   %ebx
  80010f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800112:	b9 00 00 00 00       	mov    $0x0,%ecx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	89 cb                	mov    %ecx,%ebx
  800121:	89 cf                	mov    %ecx,%edi
  800123:	89 ce                	mov    %ecx,%esi
  800125:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800127:	85 c0                	test   %eax,%eax
  800129:	7e 28                	jle    800153 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800136:	00 
  800137:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80013e:	00 
  80013f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80014e:	e8 51 10 00 00       	call   8011a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800153:	83 c4 2c             	add    $0x2c,%esp
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 02 00 00 00       	mov    $0x2,%eax
  80016b:	89 d1                	mov    %edx,%ecx
  80016d:	89 d3                	mov    %edx,%ebx
  80016f:	89 d7                	mov    %edx,%edi
  800171:	89 d6                	mov    %edx,%esi
  800173:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <sys_yield>:

void
sys_yield(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 0b 00 00 00       	mov    $0xb,%eax
  80018a:	89 d1                	mov    %edx,%ecx
  80018c:	89 d3                	mov    %edx,%ebx
  80018e:	89 d7                	mov    %edx,%edi
  800190:	89 d6                	mov    %edx,%esi
  800192:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	be 00 00 00 00       	mov    $0x0,%esi
  8001a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	89 f7                	mov    %esi,%edi
  8001b7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	7e 28                	jle    8001e5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8001d0:	00 
  8001d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d8:	00 
  8001d9:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8001e0:	e8 bf 0f 00 00       	call   8011a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e5:	83 c4 2c             	add    $0x2c,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800201:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800207:	8b 55 08             	mov    0x8(%ebp),%edx
  80020a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 28                	jle    800238 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	89 44 24 10          	mov    %eax,0x10(%esp)
  800214:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80021b:	00 
  80021c:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800223:	00 
  800224:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800233:	e8 6c 0f 00 00       	call   8011a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800238:	83 c4 2c             	add    $0x2c,%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	b8 06 00 00 00       	mov    $0x6,%eax
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 28                	jle    80028b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800263:	89 44 24 10          	mov    %eax,0x10(%esp)
  800267:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80026e:	00 
  80026f:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800276:	00 
  800277:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027e:	00 
  80027f:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800286:	e8 19 0f 00 00       	call   8011a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80028b:	83 c4 2c             	add    $0x2c,%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5f                   	pop    %edi
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
  800299:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 df                	mov    %ebx,%edi
  8002ae:	89 de                	mov    %ebx,%esi
  8002b0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	7e 28                	jle    8002de <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8002c9:	00 
  8002ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d1:	00 
  8002d2:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8002d9:	e8 c6 0e 00 00       	call   8011a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002de:	83 c4 2c             	add    $0x2c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	57                   	push   %edi
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	89 df                	mov    %ebx,%edi
  800301:	89 de                	mov    %ebx,%esi
  800303:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800305:	85 c0                	test   %eax,%eax
  800307:	7e 28                	jle    800331 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800309:	89 44 24 10          	mov    %eax,0x10(%esp)
  80030d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800314:	00 
  800315:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80031c:	00 
  80031d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800324:	00 
  800325:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80032c:	e8 73 0e 00 00       	call   8011a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800331:	83 c4 2c             	add    $0x2c,%esp
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5f                   	pop    %edi
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	57                   	push   %edi
  80033d:	56                   	push   %esi
  80033e:	53                   	push   %ebx
  80033f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800342:	bb 00 00 00 00       	mov    $0x0,%ebx
  800347:	b8 0a 00 00 00       	mov    $0xa,%eax
  80034c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034f:	8b 55 08             	mov    0x8(%ebp),%edx
  800352:	89 df                	mov    %ebx,%edi
  800354:	89 de                	mov    %ebx,%esi
  800356:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800358:	85 c0                	test   %eax,%eax
  80035a:	7e 28                	jle    800384 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800360:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800367:	00 
  800368:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80036f:	00 
  800370:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800377:	00 
  800378:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80037f:	e8 20 0e 00 00       	call   8011a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800384:	83 c4 2c             	add    $0x2c,%esp
  800387:	5b                   	pop    %ebx
  800388:	5e                   	pop    %esi
  800389:	5f                   	pop    %edi
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800392:	be 00 00 00 00       	mov    $0x0,%esi
  800397:	b8 0c 00 00 00       	mov    $0xc,%eax
  80039c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80039f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	57                   	push   %edi
  8003b3:	56                   	push   %esi
  8003b4:	53                   	push   %ebx
  8003b5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	89 cb                	mov    %ecx,%ebx
  8003c7:	89 cf                	mov    %ecx,%edi
  8003c9:	89 ce                	mov    %ecx,%esi
  8003cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	7e 28                	jle    8003f9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003d5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8003e4:	00 
  8003e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003ec:	00 
  8003ed:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8003f4:	e8 ab 0d 00 00       	call   8011a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f9:	83 c4 2c             	add    $0x2c,%esp
  8003fc:	5b                   	pop    %ebx
  8003fd:	5e                   	pop    %esi
  8003fe:	5f                   	pop    %edi
  8003ff:	5d                   	pop    %ebp
  800400:	c3                   	ret    
  800401:	00 00                	add    %al,(%eax)
	...

00800404 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800404:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800405:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80040a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80040c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  80040f:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  800413:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  800416:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  80041b:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  80041f:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  800422:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  800423:	83 c4 04             	add    $0x4,%esp
	popfl
  800426:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  800427:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  800428:	c3                   	ret    
  800429:	00 00                	add    %al,(%eax)
	...

0080042c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80042f:	8b 45 08             	mov    0x8(%ebp),%eax
  800432:	05 00 00 00 30       	add    $0x30000000,%eax
  800437:	c1 e8 0c             	shr    $0xc,%eax
}
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	89 04 24             	mov    %eax,(%esp)
  800448:	e8 df ff ff ff       	call   80042c <fd2num>
  80044d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800452:	c1 e0 0c             	shl    $0xc,%eax
}
  800455:	c9                   	leave  
  800456:	c3                   	ret    

00800457 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	53                   	push   %ebx
  80045b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80045e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800463:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800465:	89 c2                	mov    %eax,%edx
  800467:	c1 ea 16             	shr    $0x16,%edx
  80046a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800471:	f6 c2 01             	test   $0x1,%dl
  800474:	74 11                	je     800487 <fd_alloc+0x30>
  800476:	89 c2                	mov    %eax,%edx
  800478:	c1 ea 0c             	shr    $0xc,%edx
  80047b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800482:	f6 c2 01             	test   $0x1,%dl
  800485:	75 09                	jne    800490 <fd_alloc+0x39>
			*fd_store = fd;
  800487:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800489:	b8 00 00 00 00       	mov    $0x0,%eax
  80048e:	eb 17                	jmp    8004a7 <fd_alloc+0x50>
  800490:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800495:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80049a:	75 c7                	jne    800463 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80049c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8004a2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004a7:	5b                   	pop    %ebx
  8004a8:	5d                   	pop    %ebp
  8004a9:	c3                   	ret    

008004aa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004b0:	83 f8 1f             	cmp    $0x1f,%eax
  8004b3:	77 36                	ja     8004eb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004b5:	05 00 00 0d 00       	add    $0xd0000,%eax
  8004ba:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004bd:	89 c2                	mov    %eax,%edx
  8004bf:	c1 ea 16             	shr    $0x16,%edx
  8004c2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004c9:	f6 c2 01             	test   $0x1,%dl
  8004cc:	74 24                	je     8004f2 <fd_lookup+0x48>
  8004ce:	89 c2                	mov    %eax,%edx
  8004d0:	c1 ea 0c             	shr    $0xc,%edx
  8004d3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004da:	f6 c2 01             	test   $0x1,%dl
  8004dd:	74 1a                	je     8004f9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e2:	89 02                	mov    %eax,(%edx)
	return 0;
  8004e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e9:	eb 13                	jmp    8004fe <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004f0:	eb 0c                	jmp    8004fe <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004f7:	eb 05                	jmp    8004fe <fd_lookup+0x54>
  8004f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	53                   	push   %ebx
  800504:	83 ec 14             	sub    $0x14,%esp
  800507:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80050a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80050d:	ba 00 00 00 00       	mov    $0x0,%edx
  800512:	eb 0e                	jmp    800522 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800514:	39 08                	cmp    %ecx,(%eax)
  800516:	75 09                	jne    800521 <dev_lookup+0x21>
			*dev = devtab[i];
  800518:	89 03                	mov    %eax,(%ebx)
			return 0;
  80051a:	b8 00 00 00 00       	mov    $0x0,%eax
  80051f:	eb 33                	jmp    800554 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800521:	42                   	inc    %edx
  800522:	8b 04 95 34 20 80 00 	mov    0x802034(,%edx,4),%eax
  800529:	85 c0                	test   %eax,%eax
  80052b:	75 e7                	jne    800514 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80052d:	a1 04 40 80 00       	mov    0x804004,%eax
  800532:	8b 40 48             	mov    0x48(%eax),%eax
  800535:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800539:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053d:	c7 04 24 b8 1f 80 00 	movl   $0x801fb8,(%esp)
  800544:	e8 53 0d 00 00       	call   80129c <cprintf>
	*dev = 0;
  800549:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80054f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800554:	83 c4 14             	add    $0x14,%esp
  800557:	5b                   	pop    %ebx
  800558:	5d                   	pop    %ebp
  800559:	c3                   	ret    

0080055a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	56                   	push   %esi
  80055e:	53                   	push   %ebx
  80055f:	83 ec 30             	sub    $0x30,%esp
  800562:	8b 75 08             	mov    0x8(%ebp),%esi
  800565:	8a 45 0c             	mov    0xc(%ebp),%al
  800568:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80056b:	89 34 24             	mov    %esi,(%esp)
  80056e:	e8 b9 fe ff ff       	call   80042c <fd2num>
  800573:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800576:	89 54 24 04          	mov    %edx,0x4(%esp)
  80057a:	89 04 24             	mov    %eax,(%esp)
  80057d:	e8 28 ff ff ff       	call   8004aa <fd_lookup>
  800582:	89 c3                	mov    %eax,%ebx
  800584:	85 c0                	test   %eax,%eax
  800586:	78 05                	js     80058d <fd_close+0x33>
	    || fd != fd2)
  800588:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80058b:	74 0d                	je     80059a <fd_close+0x40>
		return (must_exist ? r : 0);
  80058d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800591:	75 46                	jne    8005d9 <fd_close+0x7f>
  800593:	bb 00 00 00 00       	mov    $0x0,%ebx
  800598:	eb 3f                	jmp    8005d9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80059a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80059d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a1:	8b 06                	mov    (%esi),%eax
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	e8 55 ff ff ff       	call   800500 <dev_lookup>
  8005ab:	89 c3                	mov    %eax,%ebx
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	78 18                	js     8005c9 <fd_close+0x6f>
		if (dev->dev_close)
  8005b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b4:	8b 40 10             	mov    0x10(%eax),%eax
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	74 09                	je     8005c4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005bb:	89 34 24             	mov    %esi,(%esp)
  8005be:	ff d0                	call   *%eax
  8005c0:	89 c3                	mov    %eax,%ebx
  8005c2:	eb 05                	jmp    8005c9 <fd_close+0x6f>
		else
			r = 0;
  8005c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005d4:	e8 67 fc ff ff       	call   800240 <sys_page_unmap>
	return r;
}
  8005d9:	89 d8                	mov    %ebx,%eax
  8005db:	83 c4 30             	add    $0x30,%esp
  8005de:	5b                   	pop    %ebx
  8005df:	5e                   	pop    %esi
  8005e0:	5d                   	pop    %ebp
  8005e1:	c3                   	ret    

008005e2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  8005e5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f2:	89 04 24             	mov    %eax,(%esp)
  8005f5:	e8 b0 fe ff ff       	call   8004aa <fd_lookup>
  8005fa:	85 c0                	test   %eax,%eax
  8005fc:	78 13                	js     800611 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800605:	00 
  800606:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800609:	89 04 24             	mov    %eax,(%esp)
  80060c:	e8 49 ff ff ff       	call   80055a <fd_close>
}
  800611:	c9                   	leave  
  800612:	c3                   	ret    

00800613 <close_all>:

void
close_all(void)
{
  800613:	55                   	push   %ebp
  800614:	89 e5                	mov    %esp,%ebp
  800616:	53                   	push   %ebx
  800617:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80061a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80061f:	89 1c 24             	mov    %ebx,(%esp)
  800622:	e8 bb ff ff ff       	call   8005e2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800627:	43                   	inc    %ebx
  800628:	83 fb 20             	cmp    $0x20,%ebx
  80062b:	75 f2                	jne    80061f <close_all+0xc>
		close(i);
}
  80062d:	83 c4 14             	add    $0x14,%esp
  800630:	5b                   	pop    %ebx
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	57                   	push   %edi
  800637:	56                   	push   %esi
  800638:	53                   	push   %ebx
  800639:	83 ec 4c             	sub    $0x4c,%esp
  80063c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80063f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800642:	89 44 24 04          	mov    %eax,0x4(%esp)
  800646:	8b 45 08             	mov    0x8(%ebp),%eax
  800649:	89 04 24             	mov    %eax,(%esp)
  80064c:	e8 59 fe ff ff       	call   8004aa <fd_lookup>
  800651:	89 c3                	mov    %eax,%ebx
  800653:	85 c0                	test   %eax,%eax
  800655:	0f 88 e1 00 00 00    	js     80073c <dup+0x109>
		return r;
	close(newfdnum);
  80065b:	89 3c 24             	mov    %edi,(%esp)
  80065e:	e8 7f ff ff ff       	call   8005e2 <close>

	newfd = INDEX2FD(newfdnum);
  800663:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800669:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80066c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80066f:	89 04 24             	mov    %eax,(%esp)
  800672:	e8 c5 fd ff ff       	call   80043c <fd2data>
  800677:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800679:	89 34 24             	mov    %esi,(%esp)
  80067c:	e8 bb fd ff ff       	call   80043c <fd2data>
  800681:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800684:	89 d8                	mov    %ebx,%eax
  800686:	c1 e8 16             	shr    $0x16,%eax
  800689:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800690:	a8 01                	test   $0x1,%al
  800692:	74 46                	je     8006da <dup+0xa7>
  800694:	89 d8                	mov    %ebx,%eax
  800696:	c1 e8 0c             	shr    $0xc,%eax
  800699:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8006a0:	f6 c2 01             	test   $0x1,%dl
  8006a3:	74 35                	je     8006da <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8006b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006c3:	00 
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006cf:	e8 19 fb ff ff       	call   8001ed <sys_page_map>
  8006d4:	89 c3                	mov    %eax,%ebx
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	78 3b                	js     800715 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006dd:	89 c2                	mov    %eax,%edx
  8006df:	c1 ea 0c             	shr    $0xc,%edx
  8006e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006e9:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006ef:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006fe:	00 
  8006ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800703:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80070a:	e8 de fa ff ff       	call   8001ed <sys_page_map>
  80070f:	89 c3                	mov    %eax,%ebx
  800711:	85 c0                	test   %eax,%eax
  800713:	79 25                	jns    80073a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800715:	89 74 24 04          	mov    %esi,0x4(%esp)
  800719:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800720:	e8 1b fb ff ff       	call   800240 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800725:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800733:	e8 08 fb ff ff       	call   800240 <sys_page_unmap>
	return r;
  800738:	eb 02                	jmp    80073c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80073a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80073c:	89 d8                	mov    %ebx,%eax
  80073e:	83 c4 4c             	add    $0x4c,%esp
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5f                   	pop    %edi
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	53                   	push   %ebx
  80074a:	83 ec 24             	sub    $0x24,%esp
  80074d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800753:	89 44 24 04          	mov    %eax,0x4(%esp)
  800757:	89 1c 24             	mov    %ebx,(%esp)
  80075a:	e8 4b fd ff ff       	call   8004aa <fd_lookup>
  80075f:	85 c0                	test   %eax,%eax
  800761:	78 6d                	js     8007d0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800763:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800766:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076d:	8b 00                	mov    (%eax),%eax
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	e8 89 fd ff ff       	call   800500 <dev_lookup>
  800777:	85 c0                	test   %eax,%eax
  800779:	78 55                	js     8007d0 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80077b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077e:	8b 50 08             	mov    0x8(%eax),%edx
  800781:	83 e2 03             	and    $0x3,%edx
  800784:	83 fa 01             	cmp    $0x1,%edx
  800787:	75 23                	jne    8007ac <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800789:	a1 04 40 80 00       	mov    0x804004,%eax
  80078e:	8b 40 48             	mov    0x48(%eax),%eax
  800791:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800795:	89 44 24 04          	mov    %eax,0x4(%esp)
  800799:	c7 04 24 f9 1f 80 00 	movl   $0x801ff9,(%esp)
  8007a0:	e8 f7 0a 00 00       	call   80129c <cprintf>
		return -E_INVAL;
  8007a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007aa:	eb 24                	jmp    8007d0 <read+0x8a>
	}
	if (!dev->dev_read)
  8007ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007af:	8b 52 08             	mov    0x8(%edx),%edx
  8007b2:	85 d2                	test   %edx,%edx
  8007b4:	74 15                	je     8007cb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007c4:	89 04 24             	mov    %eax,(%esp)
  8007c7:	ff d2                	call   *%edx
  8007c9:	eb 05                	jmp    8007d0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007d0:	83 c4 24             	add    $0x24,%esp
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	57                   	push   %edi
  8007da:	56                   	push   %esi
  8007db:	53                   	push   %ebx
  8007dc:	83 ec 1c             	sub    $0x1c,%esp
  8007df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ea:	eb 23                	jmp    80080f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	29 d8                	sub    %ebx,%eax
  8007f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f7:	01 d8                	add    %ebx,%eax
  8007f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fd:	89 3c 24             	mov    %edi,(%esp)
  800800:	e8 41 ff ff ff       	call   800746 <read>
		if (m < 0)
  800805:	85 c0                	test   %eax,%eax
  800807:	78 10                	js     800819 <readn+0x43>
			return m;
		if (m == 0)
  800809:	85 c0                	test   %eax,%eax
  80080b:	74 0a                	je     800817 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80080d:	01 c3                	add    %eax,%ebx
  80080f:	39 f3                	cmp    %esi,%ebx
  800811:	72 d9                	jb     8007ec <readn+0x16>
  800813:	89 d8                	mov    %ebx,%eax
  800815:	eb 02                	jmp    800819 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800817:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800819:	83 c4 1c             	add    $0x1c,%esp
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5f                   	pop    %edi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	53                   	push   %ebx
  800825:	83 ec 24             	sub    $0x24,%esp
  800828:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800832:	89 1c 24             	mov    %ebx,(%esp)
  800835:	e8 70 fc ff ff       	call   8004aa <fd_lookup>
  80083a:	85 c0                	test   %eax,%eax
  80083c:	78 68                	js     8008a6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800841:	89 44 24 04          	mov    %eax,0x4(%esp)
  800845:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800848:	8b 00                	mov    (%eax),%eax
  80084a:	89 04 24             	mov    %eax,(%esp)
  80084d:	e8 ae fc ff ff       	call   800500 <dev_lookup>
  800852:	85 c0                	test   %eax,%eax
  800854:	78 50                	js     8008a6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800856:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800859:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80085d:	75 23                	jne    800882 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80085f:	a1 04 40 80 00       	mov    0x804004,%eax
  800864:	8b 40 48             	mov    0x48(%eax),%eax
  800867:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80086b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086f:	c7 04 24 15 20 80 00 	movl   $0x802015,(%esp)
  800876:	e8 21 0a 00 00       	call   80129c <cprintf>
		return -E_INVAL;
  80087b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800880:	eb 24                	jmp    8008a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800882:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800885:	8b 52 0c             	mov    0xc(%edx),%edx
  800888:	85 d2                	test   %edx,%edx
  80088a:	74 15                	je     8008a1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80088c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800893:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800896:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80089a:	89 04 24             	mov    %eax,(%esp)
  80089d:	ff d2                	call   *%edx
  80089f:	eb 05                	jmp    8008a6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8008a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008a6:	83 c4 24             	add    $0x24,%esp
  8008a9:	5b                   	pop    %ebx
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <seek>:

int
seek(int fdnum, off_t offset)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008b2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	89 04 24             	mov    %eax,(%esp)
  8008bf:	e8 e6 fb ff ff       	call   8004aa <fd_lookup>
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	78 0e                	js     8008d6 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	83 ec 24             	sub    $0x24,%esp
  8008df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e9:	89 1c 24             	mov    %ebx,(%esp)
  8008ec:	e8 b9 fb ff ff       	call   8004aa <fd_lookup>
  8008f1:	85 c0                	test   %eax,%eax
  8008f3:	78 61                	js     800956 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ff:	8b 00                	mov    (%eax),%eax
  800901:	89 04 24             	mov    %eax,(%esp)
  800904:	e8 f7 fb ff ff       	call   800500 <dev_lookup>
  800909:	85 c0                	test   %eax,%eax
  80090b:	78 49                	js     800956 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80090d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800910:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800914:	75 23                	jne    800939 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800916:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80091b:	8b 40 48             	mov    0x48(%eax),%eax
  80091e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800922:	89 44 24 04          	mov    %eax,0x4(%esp)
  800926:	c7 04 24 d8 1f 80 00 	movl   $0x801fd8,(%esp)
  80092d:	e8 6a 09 00 00       	call   80129c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800932:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800937:	eb 1d                	jmp    800956 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800939:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80093c:	8b 52 18             	mov    0x18(%edx),%edx
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 0e                	je     800951 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800946:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80094a:	89 04 24             	mov    %eax,(%esp)
  80094d:	ff d2                	call   *%edx
  80094f:	eb 05                	jmp    800956 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800951:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800956:	83 c4 24             	add    $0x24,%esp
  800959:	5b                   	pop    %ebx
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	53                   	push   %ebx
  800960:	83 ec 24             	sub    $0x24,%esp
  800963:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800966:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	89 04 24             	mov    %eax,(%esp)
  800973:	e8 32 fb ff ff       	call   8004aa <fd_lookup>
  800978:	85 c0                	test   %eax,%eax
  80097a:	78 52                	js     8009ce <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80097c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80097f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800983:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800986:	8b 00                	mov    (%eax),%eax
  800988:	89 04 24             	mov    %eax,(%esp)
  80098b:	e8 70 fb ff ff       	call   800500 <dev_lookup>
  800990:	85 c0                	test   %eax,%eax
  800992:	78 3a                	js     8009ce <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80099b:	74 2c                	je     8009c9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80099d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009a0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009a7:	00 00 00 
	stat->st_isdir = 0;
  8009aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009b1:	00 00 00 
	stat->st_dev = dev;
  8009b4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009c1:	89 14 24             	mov    %edx,(%esp)
  8009c4:	ff 50 14             	call   *0x14(%eax)
  8009c7:	eb 05                	jmp    8009ce <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009ce:	83 c4 24             	add    $0x24,%esp
  8009d1:	5b                   	pop    %ebx
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009e3:	00 
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	89 04 24             	mov    %eax,(%esp)
  8009ea:	e8 fe 01 00 00       	call   800bed <open>
  8009ef:	89 c3                	mov    %eax,%ebx
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	78 1b                	js     800a10 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fc:	89 1c 24             	mov    %ebx,(%esp)
  8009ff:	e8 58 ff ff ff       	call   80095c <fstat>
  800a04:	89 c6                	mov    %eax,%esi
	close(fd);
  800a06:	89 1c 24             	mov    %ebx,(%esp)
  800a09:	e8 d4 fb ff ff       	call   8005e2 <close>
	return r;
  800a0e:	89 f3                	mov    %esi,%ebx
}
  800a10:	89 d8                	mov    %ebx,%eax
  800a12:	83 c4 10             	add    $0x10,%esp
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    
  800a19:	00 00                	add    %al,(%eax)
	...

00800a1c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	83 ec 10             	sub    $0x10,%esp
  800a24:	89 c3                	mov    %eax,%ebx
  800a26:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a28:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a2f:	75 11                	jne    800a42 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a38:	e8 4e 12 00 00       	call   801c8b <ipc_find_env>
  800a3d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a42:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a49:	00 
  800a4a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a51:	00 
  800a52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a56:	a1 00 40 80 00       	mov    0x804000,%eax
  800a5b:	89 04 24             	mov    %eax,(%esp)
  800a5e:	e8 be 11 00 00       	call   801c21 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a6a:	00 
  800a6b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a76:	e8 3d 11 00 00       	call   801bb8 <ipc_recv>
}
  800a7b:	83 c4 10             	add    $0x10,%esp
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a96:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa5:	e8 72 ff ff ff       	call   800a1c <fsipc>
}
  800aaa:	c9                   	leave  
  800aab:	c3                   	ret    

00800aac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800abd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ac7:	e8 50 ff ff ff       	call   800a1c <fsipc>
}
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    

00800ace <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	53                   	push   %ebx
  800ad2:	83 ec 14             	sub    $0x14,%esp
  800ad5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 40 0c             	mov    0xc(%eax),%eax
  800ade:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae8:	b8 05 00 00 00       	mov    $0x5,%eax
  800aed:	e8 2a ff ff ff       	call   800a1c <fsipc>
  800af2:	85 c0                	test   %eax,%eax
  800af4:	78 2b                	js     800b21 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800af6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800afd:	00 
  800afe:	89 1c 24             	mov    %ebx,(%esp)
  800b01:	e8 41 0d 00 00       	call   801847 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b06:	a1 80 50 80 00       	mov    0x805080,%eax
  800b0b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b11:	a1 84 50 80 00       	mov    0x805084,%eax
  800b16:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b21:	83 c4 14             	add    $0x14,%esp
  800b24:	5b                   	pop    %ebx
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800b2d:	c7 44 24 08 44 20 80 	movl   $0x802044,0x8(%esp)
  800b34:	00 
  800b35:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800b3c:	00 
  800b3d:	c7 04 24 62 20 80 00 	movl   $0x802062,(%esp)
  800b44:	e8 5b 06 00 00       	call   8011a4 <_panic>

00800b49 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 10             	sub    $0x10,%esp
  800b51:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 40 0c             	mov    0xc(%eax),%eax
  800b5a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b5f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6f:	e8 a8 fe ff ff       	call   800a1c <fsipc>
  800b74:	89 c3                	mov    %eax,%ebx
  800b76:	85 c0                	test   %eax,%eax
  800b78:	78 6a                	js     800be4 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800b7a:	39 c6                	cmp    %eax,%esi
  800b7c:	73 24                	jae    800ba2 <devfile_read+0x59>
  800b7e:	c7 44 24 0c 6d 20 80 	movl   $0x80206d,0xc(%esp)
  800b85:	00 
  800b86:	c7 44 24 08 74 20 80 	movl   $0x802074,0x8(%esp)
  800b8d:	00 
  800b8e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b95:	00 
  800b96:	c7 04 24 62 20 80 00 	movl   $0x802062,(%esp)
  800b9d:	e8 02 06 00 00       	call   8011a4 <_panic>
	assert(r <= PGSIZE);
  800ba2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ba7:	7e 24                	jle    800bcd <devfile_read+0x84>
  800ba9:	c7 44 24 0c 89 20 80 	movl   $0x802089,0xc(%esp)
  800bb0:	00 
  800bb1:	c7 44 24 08 74 20 80 	movl   $0x802074,0x8(%esp)
  800bb8:	00 
  800bb9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800bc0:	00 
  800bc1:	c7 04 24 62 20 80 00 	movl   $0x802062,(%esp)
  800bc8:	e8 d7 05 00 00       	call   8011a4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800bcd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd1:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800bd8:	00 
  800bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdc:	89 04 24             	mov    %eax,(%esp)
  800bdf:	e8 dc 0d 00 00       	call   8019c0 <memmove>
	return r;
}
  800be4:	89 d8                	mov    %ebx,%eax
  800be6:	83 c4 10             	add    $0x10,%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 20             	sub    $0x20,%esp
  800bf5:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bf8:	89 34 24             	mov    %esi,(%esp)
  800bfb:	e8 14 0c 00 00       	call   801814 <strlen>
  800c00:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c05:	7f 60                	jg     800c67 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c0a:	89 04 24             	mov    %eax,(%esp)
  800c0d:	e8 45 f8 ff ff       	call   800457 <fd_alloc>
  800c12:	89 c3                	mov    %eax,%ebx
  800c14:	85 c0                	test   %eax,%eax
  800c16:	78 54                	js     800c6c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c18:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c1c:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c23:	e8 1f 0c 00 00       	call   801847 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c33:	b8 01 00 00 00       	mov    $0x1,%eax
  800c38:	e8 df fd ff ff       	call   800a1c <fsipc>
  800c3d:	89 c3                	mov    %eax,%ebx
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	79 15                	jns    800c58 <open+0x6b>
		fd_close(fd, 0);
  800c43:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c4a:	00 
  800c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4e:	89 04 24             	mov    %eax,(%esp)
  800c51:	e8 04 f9 ff ff       	call   80055a <fd_close>
		return r;
  800c56:	eb 14                	jmp    800c6c <open+0x7f>
	}

	return fd2num(fd);
  800c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5b:	89 04 24             	mov    %eax,(%esp)
  800c5e:	e8 c9 f7 ff ff       	call   80042c <fd2num>
  800c63:	89 c3                	mov    %eax,%ebx
  800c65:	eb 05                	jmp    800c6c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c67:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c6c:	89 d8                	mov    %ebx,%eax
  800c6e:	83 c4 20             	add    $0x20,%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 08 00 00 00       	mov    $0x8,%eax
  800c85:	e8 92 fd ff ff       	call   800a1c <fsipc>
}
  800c8a:	c9                   	leave  
  800c8b:	c3                   	ret    

00800c8c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 10             	sub    $0x10,%esp
  800c94:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	89 04 24             	mov    %eax,(%esp)
  800c9d:	e8 9a f7 ff ff       	call   80043c <fd2data>
  800ca2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800ca4:	c7 44 24 04 95 20 80 	movl   $0x802095,0x4(%esp)
  800cab:	00 
  800cac:	89 34 24             	mov    %esi,(%esp)
  800caf:	e8 93 0b 00 00       	call   801847 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800cb4:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb7:	2b 03                	sub    (%ebx),%eax
  800cb9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800cbf:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800cc6:	00 00 00 
	stat->st_dev = &devpipe;
  800cc9:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800cd0:	30 80 00 
	return 0;
}
  800cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 14             	sub    $0x14,%esp
  800ce6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ce9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ced:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cf4:	e8 47 f5 ff ff       	call   800240 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800cf9:	89 1c 24             	mov    %ebx,(%esp)
  800cfc:	e8 3b f7 ff ff       	call   80043c <fd2data>
  800d01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d0c:	e8 2f f5 ff ff       	call   800240 <sys_page_unmap>
}
  800d11:	83 c4 14             	add    $0x14,%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 2c             	sub    $0x2c,%esp
  800d20:	89 c7                	mov    %eax,%edi
  800d22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800d25:	a1 04 40 80 00       	mov    0x804004,%eax
  800d2a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800d2d:	89 3c 24             	mov    %edi,(%esp)
  800d30:	e8 9b 0f 00 00       	call   801cd0 <pageref>
  800d35:	89 c6                	mov    %eax,%esi
  800d37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d3a:	89 04 24             	mov    %eax,(%esp)
  800d3d:	e8 8e 0f 00 00       	call   801cd0 <pageref>
  800d42:	39 c6                	cmp    %eax,%esi
  800d44:	0f 94 c0             	sete   %al
  800d47:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800d4a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d50:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800d53:	39 cb                	cmp    %ecx,%ebx
  800d55:	75 08                	jne    800d5f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800d57:	83 c4 2c             	add    $0x2c,%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800d5f:	83 f8 01             	cmp    $0x1,%eax
  800d62:	75 c1                	jne    800d25 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d64:	8b 42 58             	mov    0x58(%edx),%eax
  800d67:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800d6e:	00 
  800d6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d73:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d77:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  800d7e:	e8 19 05 00 00       	call   80129c <cprintf>
  800d83:	eb a0                	jmp    800d25 <_pipeisclosed+0xe>

00800d85 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 1c             	sub    $0x1c,%esp
  800d8e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800d91:	89 34 24             	mov    %esi,(%esp)
  800d94:	e8 a3 f6 ff ff       	call   80043c <fd2data>
  800d99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800da0:	eb 3c                	jmp    800dde <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800da2:	89 da                	mov    %ebx,%edx
  800da4:	89 f0                	mov    %esi,%eax
  800da6:	e8 6c ff ff ff       	call   800d17 <_pipeisclosed>
  800dab:	85 c0                	test   %eax,%eax
  800dad:	75 38                	jne    800de7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800daf:	e8 c6 f3 ff ff       	call   80017a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800db4:	8b 43 04             	mov    0x4(%ebx),%eax
  800db7:	8b 13                	mov    (%ebx),%edx
  800db9:	83 c2 20             	add    $0x20,%edx
  800dbc:	39 d0                	cmp    %edx,%eax
  800dbe:	73 e2                	jae    800da2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800dc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800dc6:	89 c2                	mov    %eax,%edx
  800dc8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800dce:	79 05                	jns    800dd5 <devpipe_write+0x50>
  800dd0:	4a                   	dec    %edx
  800dd1:	83 ca e0             	or     $0xffffffe0,%edx
  800dd4:	42                   	inc    %edx
  800dd5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800dd9:	40                   	inc    %eax
  800dda:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ddd:	47                   	inc    %edi
  800dde:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800de1:	75 d1                	jne    800db4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800de3:	89 f8                	mov    %edi,%eax
  800de5:	eb 05                	jmp    800dec <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800de7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800dec:	83 c4 1c             	add    $0x1c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
  800dfa:	83 ec 1c             	sub    $0x1c,%esp
  800dfd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800e00:	89 3c 24             	mov    %edi,(%esp)
  800e03:	e8 34 f6 ff ff       	call   80043c <fd2data>
  800e08:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e0a:	be 00 00 00 00       	mov    $0x0,%esi
  800e0f:	eb 3a                	jmp    800e4b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800e11:	85 f6                	test   %esi,%esi
  800e13:	74 04                	je     800e19 <devpipe_read+0x25>
				return i;
  800e15:	89 f0                	mov    %esi,%eax
  800e17:	eb 40                	jmp    800e59 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800e19:	89 da                	mov    %ebx,%edx
  800e1b:	89 f8                	mov    %edi,%eax
  800e1d:	e8 f5 fe ff ff       	call   800d17 <_pipeisclosed>
  800e22:	85 c0                	test   %eax,%eax
  800e24:	75 2e                	jne    800e54 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800e26:	e8 4f f3 ff ff       	call   80017a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800e2b:	8b 03                	mov    (%ebx),%eax
  800e2d:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e30:	74 df                	je     800e11 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e32:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800e37:	79 05                	jns    800e3e <devpipe_read+0x4a>
  800e39:	48                   	dec    %eax
  800e3a:	83 c8 e0             	or     $0xffffffe0,%eax
  800e3d:	40                   	inc    %eax
  800e3e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800e42:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e45:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800e48:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e4a:	46                   	inc    %esi
  800e4b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e4e:	75 db                	jne    800e2b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800e50:	89 f0                	mov    %esi,%eax
  800e52:	eb 05                	jmp    800e59 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e54:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800e59:	83 c4 1c             	add    $0x1c,%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 3c             	sub    $0x3c,%esp
  800e6a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800e6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e70:	89 04 24             	mov    %eax,(%esp)
  800e73:	e8 df f5 ff ff       	call   800457 <fd_alloc>
  800e78:	89 c3                	mov    %eax,%ebx
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	0f 88 45 01 00 00    	js     800fc7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e89:	00 
  800e8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e98:	e8 fc f2 ff ff       	call   800199 <sys_page_alloc>
  800e9d:	89 c3                	mov    %eax,%ebx
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	0f 88 20 01 00 00    	js     800fc7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800ea7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800eaa:	89 04 24             	mov    %eax,(%esp)
  800ead:	e8 a5 f5 ff ff       	call   800457 <fd_alloc>
  800eb2:	89 c3                	mov    %eax,%ebx
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	0f 88 f8 00 00 00    	js     800fb4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ebc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ec3:	00 
  800ec4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ecb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ed2:	e8 c2 f2 ff ff       	call   800199 <sys_page_alloc>
  800ed7:	89 c3                	mov    %eax,%ebx
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	0f 88 d3 00 00 00    	js     800fb4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ee1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ee4:	89 04 24             	mov    %eax,(%esp)
  800ee7:	e8 50 f5 ff ff       	call   80043c <fd2data>
  800eec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ef5:	00 
  800ef6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800efa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f01:	e8 93 f2 ff ff       	call   800199 <sys_page_alloc>
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	0f 88 91 00 00 00    	js     800fa1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f13:	89 04 24             	mov    %eax,(%esp)
  800f16:	e8 21 f5 ff ff       	call   80043c <fd2data>
  800f1b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800f22:	00 
  800f23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f2e:	00 
  800f2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f3a:	e8 ae f2 ff ff       	call   8001ed <sys_page_map>
  800f3f:	89 c3                	mov    %eax,%ebx
  800f41:	85 c0                	test   %eax,%eax
  800f43:	78 4c                	js     800f91 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800f45:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f4e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800f5a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f60:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f63:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f68:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800f6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f72:	89 04 24             	mov    %eax,(%esp)
  800f75:	e8 b2 f4 ff ff       	call   80042c <fd2num>
  800f7a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800f7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f7f:	89 04 24             	mov    %eax,(%esp)
  800f82:	e8 a5 f4 ff ff       	call   80042c <fd2num>
  800f87:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800f8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8f:	eb 36                	jmp    800fc7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800f91:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f9c:	e8 9f f2 ff ff       	call   800240 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800faf:	e8 8c f2 ff ff       	call   800240 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  800fb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc2:	e8 79 f2 ff ff       	call   800240 <sys_page_unmap>
    err:
	return r;
}
  800fc7:	89 d8                	mov    %ebx,%eax
  800fc9:	83 c4 3c             	add    $0x3c,%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fda:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	89 04 24             	mov    %eax,(%esp)
  800fe4:	e8 c1 f4 ff ff       	call   8004aa <fd_lookup>
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 15                	js     801002 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff0:	89 04 24             	mov    %eax,(%esp)
  800ff3:	e8 44 f4 ff ff       	call   80043c <fd2data>
	return _pipeisclosed(fd, p);
  800ff8:	89 c2                	mov    %eax,%edx
  800ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffd:	e8 15 fd ff ff       	call   800d17 <_pipeisclosed>
}
  801002:	c9                   	leave  
  801003:	c3                   	ret    

00801004 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801007:	b8 00 00 00 00       	mov    $0x0,%eax
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801014:	c7 44 24 04 b4 20 80 	movl   $0x8020b4,0x4(%esp)
  80101b:	00 
  80101c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101f:	89 04 24             	mov    %eax,(%esp)
  801022:	e8 20 08 00 00       	call   801847 <strcpy>
	return 0;
}
  801027:	b8 00 00 00 00       	mov    $0x0,%eax
  80102c:	c9                   	leave  
  80102d:	c3                   	ret    

0080102e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80103a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80103f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801045:	eb 30                	jmp    801077 <devcons_write+0x49>
		m = n - tot;
  801047:	8b 75 10             	mov    0x10(%ebp),%esi
  80104a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80104c:	83 fe 7f             	cmp    $0x7f,%esi
  80104f:	76 05                	jbe    801056 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801051:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801056:	89 74 24 08          	mov    %esi,0x8(%esp)
  80105a:	03 45 0c             	add    0xc(%ebp),%eax
  80105d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801061:	89 3c 24             	mov    %edi,(%esp)
  801064:	e8 57 09 00 00       	call   8019c0 <memmove>
		sys_cputs(buf, m);
  801069:	89 74 24 04          	mov    %esi,0x4(%esp)
  80106d:	89 3c 24             	mov    %edi,(%esp)
  801070:	e8 57 f0 ff ff       	call   8000cc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801075:	01 f3                	add    %esi,%ebx
  801077:	89 d8                	mov    %ebx,%eax
  801079:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80107c:	72 c9                	jb     801047 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80107e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5f                   	pop    %edi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80108f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801093:	75 07                	jne    80109c <devcons_read+0x13>
  801095:	eb 25                	jmp    8010bc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801097:	e8 de f0 ff ff       	call   80017a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80109c:	e8 49 f0 ff ff       	call   8000ea <sys_cgetc>
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	74 f2                	je     801097 <devcons_read+0xe>
  8010a5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 1d                	js     8010c8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8010ab:	83 f8 04             	cmp    $0x4,%eax
  8010ae:	74 13                	je     8010c3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8010b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b3:	88 10                	mov    %dl,(%eax)
	return 1;
  8010b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ba:	eb 0c                	jmp    8010c8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8010bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c1:	eb 05                	jmp    8010c8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8010c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    

008010ca <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8010d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010dd:	00 
  8010de:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010e1:	89 04 24             	mov    %eax,(%esp)
  8010e4:	e8 e3 ef ff ff       	call   8000cc <sys_cputs>
}
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <getchar>:

int
getchar(void)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8010f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010f8:	00 
  8010f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801100:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801107:	e8 3a f6 ff ff       	call   800746 <read>
	if (r < 0)
  80110c:	85 c0                	test   %eax,%eax
  80110e:	78 0f                	js     80111f <getchar+0x34>
		return r;
	if (r < 1)
  801110:	85 c0                	test   %eax,%eax
  801112:	7e 06                	jle    80111a <getchar+0x2f>
		return -E_EOF;
	return c;
  801114:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801118:	eb 05                	jmp    80111f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80111a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80111f:	c9                   	leave  
  801120:	c3                   	ret    

00801121 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801127:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	89 04 24             	mov    %eax,(%esp)
  801134:	e8 71 f3 ff ff       	call   8004aa <fd_lookup>
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 11                	js     80114e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801140:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801146:	39 10                	cmp    %edx,(%eax)
  801148:	0f 94 c0             	sete   %al
  80114b:	0f b6 c0             	movzbl %al,%eax
}
  80114e:	c9                   	leave  
  80114f:	c3                   	ret    

00801150 <opencons>:

int
opencons(void)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801156:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801159:	89 04 24             	mov    %eax,(%esp)
  80115c:	e8 f6 f2 ff ff       	call   800457 <fd_alloc>
  801161:	85 c0                	test   %eax,%eax
  801163:	78 3c                	js     8011a1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801165:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80116c:	00 
  80116d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801170:	89 44 24 04          	mov    %eax,0x4(%esp)
  801174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80117b:	e8 19 f0 ff ff       	call   800199 <sys_page_alloc>
  801180:	85 c0                	test   %eax,%eax
  801182:	78 1d                	js     8011a1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801184:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80118a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80118f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801192:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801199:	89 04 24             	mov    %eax,(%esp)
  80119c:	e8 8b f2 ff ff       	call   80042c <fd2num>
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    
	...

008011a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8011ac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011af:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8011b5:	e8 a1 ef ff ff       	call   80015b <sys_getenvid>
  8011ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d0:	c7 04 24 c0 20 80 00 	movl   $0x8020c0,(%esp)
  8011d7:	e8 c0 00 00 00       	call   80129c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e3:	89 04 24             	mov    %eax,(%esp)
  8011e6:	e8 50 00 00 00       	call   80123b <vcprintf>
	cprintf("\n");
  8011eb:	c7 04 24 ad 20 80 00 	movl   $0x8020ad,(%esp)
  8011f2:	e8 a5 00 00 00       	call   80129c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011f7:	cc                   	int3   
  8011f8:	eb fd                	jmp    8011f7 <_panic+0x53>
	...

008011fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	53                   	push   %ebx
  801200:	83 ec 14             	sub    $0x14,%esp
  801203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801206:	8b 03                	mov    (%ebx),%eax
  801208:	8b 55 08             	mov    0x8(%ebp),%edx
  80120b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80120f:	40                   	inc    %eax
  801210:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801212:	3d ff 00 00 00       	cmp    $0xff,%eax
  801217:	75 19                	jne    801232 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801219:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801220:	00 
  801221:	8d 43 08             	lea    0x8(%ebx),%eax
  801224:	89 04 24             	mov    %eax,(%esp)
  801227:	e8 a0 ee ff ff       	call   8000cc <sys_cputs>
		b->idx = 0;
  80122c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801232:	ff 43 04             	incl   0x4(%ebx)
}
  801235:	83 c4 14             	add    $0x14,%esp
  801238:	5b                   	pop    %ebx
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80124b:	00 00 00 
	b.cnt = 0;
  80124e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801258:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125f:	8b 45 08             	mov    0x8(%ebp),%eax
  801262:	89 44 24 08          	mov    %eax,0x8(%esp)
  801266:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80126c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801270:	c7 04 24 fc 11 80 00 	movl   $0x8011fc,(%esp)
  801277:	e8 82 01 00 00       	call   8013fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80127c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801282:	89 44 24 04          	mov    %eax,0x4(%esp)
  801286:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80128c:	89 04 24             	mov    %eax,(%esp)
  80128f:	e8 38 ee ff ff       	call   8000cc <sys_cputs>

	return b.cnt;
}
  801294:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8012a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8012a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ac:	89 04 24             	mov    %eax,(%esp)
  8012af:	e8 87 ff ff ff       	call   80123b <vcprintf>
	va_end(ap);

	return cnt;
}
  8012b4:	c9                   	leave  
  8012b5:	c3                   	ret    
	...

008012b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	57                   	push   %edi
  8012bc:	56                   	push   %esi
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 3c             	sub    $0x3c,%esp
  8012c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c4:	89 d7                	mov    %edx,%edi
  8012c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8012cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8012d5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	75 08                	jne    8012e4 <printnum+0x2c>
  8012dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8012e2:	77 57                	ja     80133b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012e4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012e8:	4b                   	dec    %ebx
  8012e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8012f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8012f8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801303:	00 
  801304:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801307:	89 04 24             	mov    %eax,(%esp)
  80130a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80130d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801311:	e8 fe 09 00 00       	call   801d14 <__udivdi3>
  801316:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80131e:	89 04 24             	mov    %eax,(%esp)
  801321:	89 54 24 04          	mov    %edx,0x4(%esp)
  801325:	89 fa                	mov    %edi,%edx
  801327:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80132a:	e8 89 ff ff ff       	call   8012b8 <printnum>
  80132f:	eb 0f                	jmp    801340 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801335:	89 34 24             	mov    %esi,(%esp)
  801338:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80133b:	4b                   	dec    %ebx
  80133c:	85 db                	test   %ebx,%ebx
  80133e:	7f f1                	jg     801331 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801340:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801344:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801348:	8b 45 10             	mov    0x10(%ebp),%eax
  80134b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80134f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801356:	00 
  801357:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80135a:	89 04 24             	mov    %eax,(%esp)
  80135d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801360:	89 44 24 04          	mov    %eax,0x4(%esp)
  801364:	e8 cb 0a 00 00       	call   801e34 <__umoddi3>
  801369:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80136d:	0f be 80 e3 20 80 00 	movsbl 0x8020e3(%eax),%eax
  801374:	89 04 24             	mov    %eax,(%esp)
  801377:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80137a:	83 c4 3c             	add    $0x3c,%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5f                   	pop    %edi
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801385:	83 fa 01             	cmp    $0x1,%edx
  801388:	7e 0e                	jle    801398 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80138a:	8b 10                	mov    (%eax),%edx
  80138c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80138f:	89 08                	mov    %ecx,(%eax)
  801391:	8b 02                	mov    (%edx),%eax
  801393:	8b 52 04             	mov    0x4(%edx),%edx
  801396:	eb 22                	jmp    8013ba <getuint+0x38>
	else if (lflag)
  801398:	85 d2                	test   %edx,%edx
  80139a:	74 10                	je     8013ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80139c:	8b 10                	mov    (%eax),%edx
  80139e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013a1:	89 08                	mov    %ecx,(%eax)
  8013a3:	8b 02                	mov    (%edx),%eax
  8013a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013aa:	eb 0e                	jmp    8013ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8013ac:	8b 10                	mov    (%eax),%edx
  8013ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013b1:	89 08                	mov    %ecx,(%eax)
  8013b3:	8b 02                	mov    (%edx),%eax
  8013b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8013c2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8013c5:	8b 10                	mov    (%eax),%edx
  8013c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8013ca:	73 08                	jae    8013d4 <sprintputch+0x18>
		*b->buf++ = ch;
  8013cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013cf:	88 0a                	mov    %cl,(%edx)
  8013d1:	42                   	inc    %edx
  8013d2:	89 10                	mov    %edx,(%eax)
}
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8013dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8013e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f4:	89 04 24             	mov    %eax,(%esp)
  8013f7:	e8 02 00 00 00       	call   8013fe <vprintfmt>
	va_end(ap);
}
  8013fc:	c9                   	leave  
  8013fd:	c3                   	ret    

008013fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013fe:	55                   	push   %ebp
  8013ff:	89 e5                	mov    %esp,%ebp
  801401:	57                   	push   %edi
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
  801404:	83 ec 4c             	sub    $0x4c,%esp
  801407:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80140a:	8b 75 10             	mov    0x10(%ebp),%esi
  80140d:	eb 12                	jmp    801421 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80140f:	85 c0                	test   %eax,%eax
  801411:	0f 84 6b 03 00 00    	je     801782 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  801417:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80141b:	89 04 24             	mov    %eax,(%esp)
  80141e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801421:	0f b6 06             	movzbl (%esi),%eax
  801424:	46                   	inc    %esi
  801425:	83 f8 25             	cmp    $0x25,%eax
  801428:	75 e5                	jne    80140f <vprintfmt+0x11>
  80142a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80142e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801435:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80143a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801441:	b9 00 00 00 00       	mov    $0x0,%ecx
  801446:	eb 26                	jmp    80146e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801448:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80144b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80144f:	eb 1d                	jmp    80146e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801451:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801454:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801458:	eb 14                	jmp    80146e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80145a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80145d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801464:	eb 08                	jmp    80146e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801466:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801469:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80146e:	0f b6 06             	movzbl (%esi),%eax
  801471:	8d 56 01             	lea    0x1(%esi),%edx
  801474:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801477:	8a 16                	mov    (%esi),%dl
  801479:	83 ea 23             	sub    $0x23,%edx
  80147c:	80 fa 55             	cmp    $0x55,%dl
  80147f:	0f 87 e1 02 00 00    	ja     801766 <vprintfmt+0x368>
  801485:	0f b6 d2             	movzbl %dl,%edx
  801488:	ff 24 95 20 22 80 00 	jmp    *0x802220(,%edx,4)
  80148f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801492:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801497:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80149a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80149e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8014a1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8014a4:	83 fa 09             	cmp    $0x9,%edx
  8014a7:	77 2a                	ja     8014d3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8014a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8014aa:	eb eb                	jmp    801497 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8014ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8014af:	8d 50 04             	lea    0x4(%eax),%edx
  8014b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8014ba:	eb 17                	jmp    8014d3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8014bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014c0:	78 98                	js     80145a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8014c5:	eb a7                	jmp    80146e <vprintfmt+0x70>
  8014c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8014ca:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8014d1:	eb 9b                	jmp    80146e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8014d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014d7:	79 95                	jns    80146e <vprintfmt+0x70>
  8014d9:	eb 8b                	jmp    801466 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8014db:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8014df:	eb 8d                	jmp    80146e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8014e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e4:	8d 50 04             	lea    0x4(%eax),%edx
  8014e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ee:	8b 00                	mov    (%eax),%eax
  8014f0:	89 04 24             	mov    %eax,(%esp)
  8014f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8014f9:	e9 23 ff ff ff       	jmp    801421 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8014fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801501:	8d 50 04             	lea    0x4(%eax),%edx
  801504:	89 55 14             	mov    %edx,0x14(%ebp)
  801507:	8b 00                	mov    (%eax),%eax
  801509:	85 c0                	test   %eax,%eax
  80150b:	79 02                	jns    80150f <vprintfmt+0x111>
  80150d:	f7 d8                	neg    %eax
  80150f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801511:	83 f8 0f             	cmp    $0xf,%eax
  801514:	7f 0b                	jg     801521 <vprintfmt+0x123>
  801516:	8b 04 85 80 23 80 00 	mov    0x802380(,%eax,4),%eax
  80151d:	85 c0                	test   %eax,%eax
  80151f:	75 23                	jne    801544 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801521:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801525:	c7 44 24 08 fb 20 80 	movl   $0x8020fb,0x8(%esp)
  80152c:	00 
  80152d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801531:	8b 45 08             	mov    0x8(%ebp),%eax
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	e8 9a fe ff ff       	call   8013d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80153c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80153f:	e9 dd fe ff ff       	jmp    801421 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801544:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801548:	c7 44 24 08 86 20 80 	movl   $0x802086,0x8(%esp)
  80154f:	00 
  801550:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801554:	8b 55 08             	mov    0x8(%ebp),%edx
  801557:	89 14 24             	mov    %edx,(%esp)
  80155a:	e8 77 fe ff ff       	call   8013d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80155f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801562:	e9 ba fe ff ff       	jmp    801421 <vprintfmt+0x23>
  801567:	89 f9                	mov    %edi,%ecx
  801569:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80156c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80156f:	8b 45 14             	mov    0x14(%ebp),%eax
  801572:	8d 50 04             	lea    0x4(%eax),%edx
  801575:	89 55 14             	mov    %edx,0x14(%ebp)
  801578:	8b 30                	mov    (%eax),%esi
  80157a:	85 f6                	test   %esi,%esi
  80157c:	75 05                	jne    801583 <vprintfmt+0x185>
				p = "(null)";
  80157e:	be f4 20 80 00       	mov    $0x8020f4,%esi
			if (width > 0 && padc != '-')
  801583:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801587:	0f 8e 84 00 00 00    	jle    801611 <vprintfmt+0x213>
  80158d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801591:	74 7e                	je     801611 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801593:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801597:	89 34 24             	mov    %esi,(%esp)
  80159a:	e8 8b 02 00 00       	call   80182a <strnlen>
  80159f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8015a2:	29 c2                	sub    %eax,%edx
  8015a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8015a7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8015ab:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8015ae:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8015b1:	89 de                	mov    %ebx,%esi
  8015b3:	89 d3                	mov    %edx,%ebx
  8015b5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8015b7:	eb 0b                	jmp    8015c4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8015b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015bd:	89 3c 24             	mov    %edi,(%esp)
  8015c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8015c3:	4b                   	dec    %ebx
  8015c4:	85 db                	test   %ebx,%ebx
  8015c6:	7f f1                	jg     8015b9 <vprintfmt+0x1bb>
  8015c8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8015cb:	89 f3                	mov    %esi,%ebx
  8015cd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8015d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	79 05                	jns    8015dc <vprintfmt+0x1de>
  8015d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015df:	29 c2                	sub    %eax,%edx
  8015e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015e4:	eb 2b                	jmp    801611 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8015e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015ea:	74 18                	je     801604 <vprintfmt+0x206>
  8015ec:	8d 50 e0             	lea    -0x20(%eax),%edx
  8015ef:	83 fa 5e             	cmp    $0x5e,%edx
  8015f2:	76 10                	jbe    801604 <vprintfmt+0x206>
					putch('?', putdat);
  8015f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015f8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015ff:	ff 55 08             	call   *0x8(%ebp)
  801602:	eb 0a                	jmp    80160e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801608:	89 04 24             	mov    %eax,(%esp)
  80160b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80160e:	ff 4d e4             	decl   -0x1c(%ebp)
  801611:	0f be 06             	movsbl (%esi),%eax
  801614:	46                   	inc    %esi
  801615:	85 c0                	test   %eax,%eax
  801617:	74 21                	je     80163a <vprintfmt+0x23c>
  801619:	85 ff                	test   %edi,%edi
  80161b:	78 c9                	js     8015e6 <vprintfmt+0x1e8>
  80161d:	4f                   	dec    %edi
  80161e:	79 c6                	jns    8015e6 <vprintfmt+0x1e8>
  801620:	8b 7d 08             	mov    0x8(%ebp),%edi
  801623:	89 de                	mov    %ebx,%esi
  801625:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801628:	eb 18                	jmp    801642 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80162a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80162e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801635:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801637:	4b                   	dec    %ebx
  801638:	eb 08                	jmp    801642 <vprintfmt+0x244>
  80163a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80163d:	89 de                	mov    %ebx,%esi
  80163f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801642:	85 db                	test   %ebx,%ebx
  801644:	7f e4                	jg     80162a <vprintfmt+0x22c>
  801646:	89 7d 08             	mov    %edi,0x8(%ebp)
  801649:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80164e:	e9 ce fd ff ff       	jmp    801421 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801653:	83 f9 01             	cmp    $0x1,%ecx
  801656:	7e 10                	jle    801668 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801658:	8b 45 14             	mov    0x14(%ebp),%eax
  80165b:	8d 50 08             	lea    0x8(%eax),%edx
  80165e:	89 55 14             	mov    %edx,0x14(%ebp)
  801661:	8b 30                	mov    (%eax),%esi
  801663:	8b 78 04             	mov    0x4(%eax),%edi
  801666:	eb 26                	jmp    80168e <vprintfmt+0x290>
	else if (lflag)
  801668:	85 c9                	test   %ecx,%ecx
  80166a:	74 12                	je     80167e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80166c:	8b 45 14             	mov    0x14(%ebp),%eax
  80166f:	8d 50 04             	lea    0x4(%eax),%edx
  801672:	89 55 14             	mov    %edx,0x14(%ebp)
  801675:	8b 30                	mov    (%eax),%esi
  801677:	89 f7                	mov    %esi,%edi
  801679:	c1 ff 1f             	sar    $0x1f,%edi
  80167c:	eb 10                	jmp    80168e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80167e:	8b 45 14             	mov    0x14(%ebp),%eax
  801681:	8d 50 04             	lea    0x4(%eax),%edx
  801684:	89 55 14             	mov    %edx,0x14(%ebp)
  801687:	8b 30                	mov    (%eax),%esi
  801689:	89 f7                	mov    %esi,%edi
  80168b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80168e:	85 ff                	test   %edi,%edi
  801690:	78 0a                	js     80169c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801692:	b8 0a 00 00 00       	mov    $0xa,%eax
  801697:	e9 8c 00 00 00       	jmp    801728 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80169c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016a7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8016aa:	f7 de                	neg    %esi
  8016ac:	83 d7 00             	adc    $0x0,%edi
  8016af:	f7 df                	neg    %edi
			}
			base = 10;
  8016b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016b6:	eb 70                	jmp    801728 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8016b8:	89 ca                	mov    %ecx,%edx
  8016ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8016bd:	e8 c0 fc ff ff       	call   801382 <getuint>
  8016c2:	89 c6                	mov    %eax,%esi
  8016c4:	89 d7                	mov    %edx,%edi
			base = 10;
  8016c6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8016cb:	eb 5b                	jmp    801728 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8016cd:	89 ca                	mov    %ecx,%edx
  8016cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8016d2:	e8 ab fc ff ff       	call   801382 <getuint>
  8016d7:	89 c6                	mov    %eax,%esi
  8016d9:	89 d7                	mov    %edx,%edi
			base = 8;
  8016db:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8016e0:	eb 46                	jmp    801728 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8016e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8016ed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8016f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8016fb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8016fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801701:	8d 50 04             	lea    0x4(%eax),%edx
  801704:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801707:	8b 30                	mov    (%eax),%esi
  801709:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80170e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801713:	eb 13                	jmp    801728 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801715:	89 ca                	mov    %ecx,%edx
  801717:	8d 45 14             	lea    0x14(%ebp),%eax
  80171a:	e8 63 fc ff ff       	call   801382 <getuint>
  80171f:	89 c6                	mov    %eax,%esi
  801721:	89 d7                	mov    %edx,%edi
			base = 16;
  801723:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801728:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80172c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801730:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801733:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801737:	89 44 24 08          	mov    %eax,0x8(%esp)
  80173b:	89 34 24             	mov    %esi,(%esp)
  80173e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801742:	89 da                	mov    %ebx,%edx
  801744:	8b 45 08             	mov    0x8(%ebp),%eax
  801747:	e8 6c fb ff ff       	call   8012b8 <printnum>
			break;
  80174c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80174f:	e9 cd fc ff ff       	jmp    801421 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801754:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801758:	89 04 24             	mov    %eax,(%esp)
  80175b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801761:	e9 bb fc ff ff       	jmp    801421 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801766:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80176a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801771:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801774:	eb 01                	jmp    801777 <vprintfmt+0x379>
  801776:	4e                   	dec    %esi
  801777:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80177b:	75 f9                	jne    801776 <vprintfmt+0x378>
  80177d:	e9 9f fc ff ff       	jmp    801421 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801782:	83 c4 4c             	add    $0x4c,%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5f                   	pop    %edi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	83 ec 28             	sub    $0x28,%esp
  801790:	8b 45 08             	mov    0x8(%ebp),%eax
  801793:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801796:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801799:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80179d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	74 30                	je     8017db <vsnprintf+0x51>
  8017ab:	85 d2                	test   %edx,%edx
  8017ad:	7e 33                	jle    8017e2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017af:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c4:	c7 04 24 bc 13 80 00 	movl   $0x8013bc,(%esp)
  8017cb:	e8 2e fc ff ff       	call   8013fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8017d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8017d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d9:	eb 0c                	jmp    8017e7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8017db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017e0:	eb 05                	jmp    8017e7 <vsnprintf+0x5d>
  8017e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8017ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8017f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801800:	89 44 24 04          	mov    %eax,0x4(%esp)
  801804:	8b 45 08             	mov    0x8(%ebp),%eax
  801807:	89 04 24             	mov    %eax,(%esp)
  80180a:	e8 7b ff ff ff       	call   80178a <vsnprintf>
	va_end(ap);

	return rc;
}
  80180f:	c9                   	leave  
  801810:	c3                   	ret    
  801811:	00 00                	add    %al,(%eax)
	...

00801814 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80181a:	b8 00 00 00 00       	mov    $0x0,%eax
  80181f:	eb 01                	jmp    801822 <strlen+0xe>
		n++;
  801821:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801822:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801826:	75 f9                	jne    801821 <strlen+0xd>
		n++;
	return n;
}
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801830:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801833:	b8 00 00 00 00       	mov    $0x0,%eax
  801838:	eb 01                	jmp    80183b <strnlen+0x11>
		n++;
  80183a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80183b:	39 d0                	cmp    %edx,%eax
  80183d:	74 06                	je     801845 <strnlen+0x1b>
  80183f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801843:	75 f5                	jne    80183a <strnlen+0x10>
		n++;
	return n;
}
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	53                   	push   %ebx
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801851:	ba 00 00 00 00       	mov    $0x0,%edx
  801856:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801859:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80185c:	42                   	inc    %edx
  80185d:	84 c9                	test   %cl,%cl
  80185f:	75 f5                	jne    801856 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801861:	5b                   	pop    %ebx
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	53                   	push   %ebx
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80186e:	89 1c 24             	mov    %ebx,(%esp)
  801871:	e8 9e ff ff ff       	call   801814 <strlen>
	strcpy(dst + len, src);
  801876:	8b 55 0c             	mov    0xc(%ebp),%edx
  801879:	89 54 24 04          	mov    %edx,0x4(%esp)
  80187d:	01 d8                	add    %ebx,%eax
  80187f:	89 04 24             	mov    %eax,(%esp)
  801882:	e8 c0 ff ff ff       	call   801847 <strcpy>
	return dst;
}
  801887:	89 d8                	mov    %ebx,%eax
  801889:	83 c4 08             	add    $0x8,%esp
  80188c:	5b                   	pop    %ebx
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	56                   	push   %esi
  801893:	53                   	push   %ebx
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
  801897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80189d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018a2:	eb 0c                	jmp    8018b0 <strncpy+0x21>
		*dst++ = *src;
  8018a4:	8a 1a                	mov    (%edx),%bl
  8018a6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8018a9:	80 3a 01             	cmpb   $0x1,(%edx)
  8018ac:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8018af:	41                   	inc    %ecx
  8018b0:	39 f1                	cmp    %esi,%ecx
  8018b2:	75 f0                	jne    8018a4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8018b4:	5b                   	pop    %ebx
  8018b5:	5e                   	pop    %esi
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    

008018b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	56                   	push   %esi
  8018bc:	53                   	push   %ebx
  8018bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8018c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018c3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018c6:	85 d2                	test   %edx,%edx
  8018c8:	75 0a                	jne    8018d4 <strlcpy+0x1c>
  8018ca:	89 f0                	mov    %esi,%eax
  8018cc:	eb 1a                	jmp    8018e8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8018ce:	88 18                	mov    %bl,(%eax)
  8018d0:	40                   	inc    %eax
  8018d1:	41                   	inc    %ecx
  8018d2:	eb 02                	jmp    8018d6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018d4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8018d6:	4a                   	dec    %edx
  8018d7:	74 0a                	je     8018e3 <strlcpy+0x2b>
  8018d9:	8a 19                	mov    (%ecx),%bl
  8018db:	84 db                	test   %bl,%bl
  8018dd:	75 ef                	jne    8018ce <strlcpy+0x16>
  8018df:	89 c2                	mov    %eax,%edx
  8018e1:	eb 02                	jmp    8018e5 <strlcpy+0x2d>
  8018e3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8018e5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8018e8:	29 f0                	sub    %esi,%eax
}
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    

008018ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018f7:	eb 02                	jmp    8018fb <strcmp+0xd>
		p++, q++;
  8018f9:	41                   	inc    %ecx
  8018fa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8018fb:	8a 01                	mov    (%ecx),%al
  8018fd:	84 c0                	test   %al,%al
  8018ff:	74 04                	je     801905 <strcmp+0x17>
  801901:	3a 02                	cmp    (%edx),%al
  801903:	74 f4                	je     8018f9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801905:	0f b6 c0             	movzbl %al,%eax
  801908:	0f b6 12             	movzbl (%edx),%edx
  80190b:	29 d0                	sub    %edx,%eax
}
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	53                   	push   %ebx
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801919:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80191c:	eb 03                	jmp    801921 <strncmp+0x12>
		n--, p++, q++;
  80191e:	4a                   	dec    %edx
  80191f:	40                   	inc    %eax
  801920:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801921:	85 d2                	test   %edx,%edx
  801923:	74 14                	je     801939 <strncmp+0x2a>
  801925:	8a 18                	mov    (%eax),%bl
  801927:	84 db                	test   %bl,%bl
  801929:	74 04                	je     80192f <strncmp+0x20>
  80192b:	3a 19                	cmp    (%ecx),%bl
  80192d:	74 ef                	je     80191e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80192f:	0f b6 00             	movzbl (%eax),%eax
  801932:	0f b6 11             	movzbl (%ecx),%edx
  801935:	29 d0                	sub    %edx,%eax
  801937:	eb 05                	jmp    80193e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801939:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80193e:	5b                   	pop    %ebx
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	8b 45 08             	mov    0x8(%ebp),%eax
  801947:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80194a:	eb 05                	jmp    801951 <strchr+0x10>
		if (*s == c)
  80194c:	38 ca                	cmp    %cl,%dl
  80194e:	74 0c                	je     80195c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801950:	40                   	inc    %eax
  801951:	8a 10                	mov    (%eax),%dl
  801953:	84 d2                	test   %dl,%dl
  801955:	75 f5                	jne    80194c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	8b 45 08             	mov    0x8(%ebp),%eax
  801964:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801967:	eb 05                	jmp    80196e <strfind+0x10>
		if (*s == c)
  801969:	38 ca                	cmp    %cl,%dl
  80196b:	74 07                	je     801974 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80196d:	40                   	inc    %eax
  80196e:	8a 10                	mov    (%eax),%dl
  801970:	84 d2                	test   %dl,%dl
  801972:	75 f5                	jne    801969 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801974:	5d                   	pop    %ebp
  801975:	c3                   	ret    

00801976 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	57                   	push   %edi
  80197a:	56                   	push   %esi
  80197b:	53                   	push   %ebx
  80197c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80197f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801985:	85 c9                	test   %ecx,%ecx
  801987:	74 30                	je     8019b9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801989:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80198f:	75 25                	jne    8019b6 <memset+0x40>
  801991:	f6 c1 03             	test   $0x3,%cl
  801994:	75 20                	jne    8019b6 <memset+0x40>
		c &= 0xFF;
  801996:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801999:	89 d3                	mov    %edx,%ebx
  80199b:	c1 e3 08             	shl    $0x8,%ebx
  80199e:	89 d6                	mov    %edx,%esi
  8019a0:	c1 e6 18             	shl    $0x18,%esi
  8019a3:	89 d0                	mov    %edx,%eax
  8019a5:	c1 e0 10             	shl    $0x10,%eax
  8019a8:	09 f0                	or     %esi,%eax
  8019aa:	09 d0                	or     %edx,%eax
  8019ac:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8019ae:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8019b1:	fc                   	cld    
  8019b2:	f3 ab                	rep stos %eax,%es:(%edi)
  8019b4:	eb 03                	jmp    8019b9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8019b6:	fc                   	cld    
  8019b7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8019b9:	89 f8                	mov    %edi,%eax
  8019bb:	5b                   	pop    %ebx
  8019bc:	5e                   	pop    %esi
  8019bd:	5f                   	pop    %edi
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	57                   	push   %edi
  8019c4:	56                   	push   %esi
  8019c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019ce:	39 c6                	cmp    %eax,%esi
  8019d0:	73 34                	jae    801a06 <memmove+0x46>
  8019d2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019d5:	39 d0                	cmp    %edx,%eax
  8019d7:	73 2d                	jae    801a06 <memmove+0x46>
		s += n;
		d += n;
  8019d9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019dc:	f6 c2 03             	test   $0x3,%dl
  8019df:	75 1b                	jne    8019fc <memmove+0x3c>
  8019e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019e7:	75 13                	jne    8019fc <memmove+0x3c>
  8019e9:	f6 c1 03             	test   $0x3,%cl
  8019ec:	75 0e                	jne    8019fc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019ee:	83 ef 04             	sub    $0x4,%edi
  8019f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019f4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8019f7:	fd                   	std    
  8019f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019fa:	eb 07                	jmp    801a03 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019fc:	4f                   	dec    %edi
  8019fd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801a00:	fd                   	std    
  801a01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a03:	fc                   	cld    
  801a04:	eb 20                	jmp    801a26 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a0c:	75 13                	jne    801a21 <memmove+0x61>
  801a0e:	a8 03                	test   $0x3,%al
  801a10:	75 0f                	jne    801a21 <memmove+0x61>
  801a12:	f6 c1 03             	test   $0x3,%cl
  801a15:	75 0a                	jne    801a21 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a17:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a1a:	89 c7                	mov    %eax,%edi
  801a1c:	fc                   	cld    
  801a1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a1f:	eb 05                	jmp    801a26 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a21:	89 c7                	mov    %eax,%edi
  801a23:	fc                   	cld    
  801a24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a26:	5e                   	pop    %esi
  801a27:	5f                   	pop    %edi
  801a28:	5d                   	pop    %ebp
  801a29:	c3                   	ret    

00801a2a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a30:	8b 45 10             	mov    0x10(%ebp),%eax
  801a33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	89 04 24             	mov    %eax,(%esp)
  801a44:	e8 77 ff ff ff       	call   8019c0 <memmove>
}
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	57                   	push   %edi
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5f:	eb 16                	jmp    801a77 <memcmp+0x2c>
		if (*s1 != *s2)
  801a61:	8a 04 17             	mov    (%edi,%edx,1),%al
  801a64:	42                   	inc    %edx
  801a65:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801a69:	38 c8                	cmp    %cl,%al
  801a6b:	74 0a                	je     801a77 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801a6d:	0f b6 c0             	movzbl %al,%eax
  801a70:	0f b6 c9             	movzbl %cl,%ecx
  801a73:	29 c8                	sub    %ecx,%eax
  801a75:	eb 09                	jmp    801a80 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a77:	39 da                	cmp    %ebx,%edx
  801a79:	75 e6                	jne    801a61 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5f                   	pop    %edi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    

00801a85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a8e:	89 c2                	mov    %eax,%edx
  801a90:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a93:	eb 05                	jmp    801a9a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a95:	38 08                	cmp    %cl,(%eax)
  801a97:	74 05                	je     801a9e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a99:	40                   	inc    %eax
  801a9a:	39 d0                	cmp    %edx,%eax
  801a9c:	72 f7                	jb     801a95 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    

00801aa0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	57                   	push   %edi
  801aa4:	56                   	push   %esi
  801aa5:	53                   	push   %ebx
  801aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  801aa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801aac:	eb 01                	jmp    801aaf <strtol+0xf>
		s++;
  801aae:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801aaf:	8a 02                	mov    (%edx),%al
  801ab1:	3c 20                	cmp    $0x20,%al
  801ab3:	74 f9                	je     801aae <strtol+0xe>
  801ab5:	3c 09                	cmp    $0x9,%al
  801ab7:	74 f5                	je     801aae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ab9:	3c 2b                	cmp    $0x2b,%al
  801abb:	75 08                	jne    801ac5 <strtol+0x25>
		s++;
  801abd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801abe:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac3:	eb 13                	jmp    801ad8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ac5:	3c 2d                	cmp    $0x2d,%al
  801ac7:	75 0a                	jne    801ad3 <strtol+0x33>
		s++, neg = 1;
  801ac9:	8d 52 01             	lea    0x1(%edx),%edx
  801acc:	bf 01 00 00 00       	mov    $0x1,%edi
  801ad1:	eb 05                	jmp    801ad8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ad3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ad8:	85 db                	test   %ebx,%ebx
  801ada:	74 05                	je     801ae1 <strtol+0x41>
  801adc:	83 fb 10             	cmp    $0x10,%ebx
  801adf:	75 28                	jne    801b09 <strtol+0x69>
  801ae1:	8a 02                	mov    (%edx),%al
  801ae3:	3c 30                	cmp    $0x30,%al
  801ae5:	75 10                	jne    801af7 <strtol+0x57>
  801ae7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801aeb:	75 0a                	jne    801af7 <strtol+0x57>
		s += 2, base = 16;
  801aed:	83 c2 02             	add    $0x2,%edx
  801af0:	bb 10 00 00 00       	mov    $0x10,%ebx
  801af5:	eb 12                	jmp    801b09 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801af7:	85 db                	test   %ebx,%ebx
  801af9:	75 0e                	jne    801b09 <strtol+0x69>
  801afb:	3c 30                	cmp    $0x30,%al
  801afd:	75 05                	jne    801b04 <strtol+0x64>
		s++, base = 8;
  801aff:	42                   	inc    %edx
  801b00:	b3 08                	mov    $0x8,%bl
  801b02:	eb 05                	jmp    801b09 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801b04:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801b09:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b10:	8a 0a                	mov    (%edx),%cl
  801b12:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b15:	80 fb 09             	cmp    $0x9,%bl
  801b18:	77 08                	ja     801b22 <strtol+0x82>
			dig = *s - '0';
  801b1a:	0f be c9             	movsbl %cl,%ecx
  801b1d:	83 e9 30             	sub    $0x30,%ecx
  801b20:	eb 1e                	jmp    801b40 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b22:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b25:	80 fb 19             	cmp    $0x19,%bl
  801b28:	77 08                	ja     801b32 <strtol+0x92>
			dig = *s - 'a' + 10;
  801b2a:	0f be c9             	movsbl %cl,%ecx
  801b2d:	83 e9 57             	sub    $0x57,%ecx
  801b30:	eb 0e                	jmp    801b40 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b32:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b35:	80 fb 19             	cmp    $0x19,%bl
  801b38:	77 12                	ja     801b4c <strtol+0xac>
			dig = *s - 'A' + 10;
  801b3a:	0f be c9             	movsbl %cl,%ecx
  801b3d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b40:	39 f1                	cmp    %esi,%ecx
  801b42:	7d 0c                	jge    801b50 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b44:	42                   	inc    %edx
  801b45:	0f af c6             	imul   %esi,%eax
  801b48:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801b4a:	eb c4                	jmp    801b10 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801b4c:	89 c1                	mov    %eax,%ecx
  801b4e:	eb 02                	jmp    801b52 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b50:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801b52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b56:	74 05                	je     801b5d <strtol+0xbd>
		*endptr = (char *) s;
  801b58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b5b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801b5d:	85 ff                	test   %edi,%edi
  801b5f:	74 04                	je     801b65 <strtol+0xc5>
  801b61:	89 c8                	mov    %ecx,%eax
  801b63:	f7 d8                	neg    %eax
}
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    
	...

00801b6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801b72:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801b79:	75 32                	jne    801bad <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801b7b:	e8 db e5 ff ff       	call   80015b <sys_getenvid>
  801b80:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  801b87:	00 
  801b88:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801b8f:	ee 
  801b90:	89 04 24             	mov    %eax,(%esp)
  801b93:	e8 01 e6 ff ff       	call   800199 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  801b98:	e8 be e5 ff ff       	call   80015b <sys_getenvid>
  801b9d:	c7 44 24 04 04 04 80 	movl   $0x800404,0x4(%esp)
  801ba4:	00 
  801ba5:	89 04 24             	mov    %eax,(%esp)
  801ba8:	e8 8c e7 ff ff       	call   800339 <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801bad:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb0:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    
	...

00801bb8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	57                   	push   %edi
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 1c             	sub    $0x1c,%esp
  801bc1:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bc7:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801bca:	85 db                	test   %ebx,%ebx
  801bcc:	75 05                	jne    801bd3 <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801bce:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801bd3:	89 1c 24             	mov    %ebx,(%esp)
  801bd6:	e8 d4 e7 ff ff       	call   8003af <sys_ipc_recv>
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	79 16                	jns    801bf5 <ipc_recv+0x3d>
		*from_env_store = 0;
  801bdf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801be5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801beb:	89 1c 24             	mov    %ebx,(%esp)
  801bee:	e8 bc e7 ff ff       	call   8003af <sys_ipc_recv>
  801bf3:	eb 24                	jmp    801c19 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801bf5:	85 f6                	test   %esi,%esi
  801bf7:	74 0a                	je     801c03 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801bf9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bfe:	8b 40 74             	mov    0x74(%eax),%eax
  801c01:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801c03:	85 ff                	test   %edi,%edi
  801c05:	74 0a                	je     801c11 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801c07:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0c:	8b 40 78             	mov    0x78(%eax),%eax
  801c0f:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801c11:	a1 04 40 80 00       	mov    0x804004,%eax
  801c16:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c19:	83 c4 1c             	add    $0x1c,%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5f                   	pop    %edi
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	57                   	push   %edi
  801c25:	56                   	push   %esi
  801c26:	53                   	push   %ebx
  801c27:	83 ec 1c             	sub    $0x1c,%esp
  801c2a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c30:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801c33:	85 db                	test   %ebx,%ebx
  801c35:	75 05                	jne    801c3c <ipc_send+0x1b>
		pg = (void *)-1;
  801c37:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801c3c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c40:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c44:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	89 04 24             	mov    %eax,(%esp)
  801c4e:	e8 39 e7 ff ff       	call   80038c <sys_ipc_try_send>
		if (r == 0) {		
  801c53:	85 c0                	test   %eax,%eax
  801c55:	74 2c                	je     801c83 <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801c57:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c5a:	75 07                	jne    801c63 <ipc_send+0x42>
			sys_yield();
  801c5c:	e8 19 e5 ff ff       	call   80017a <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801c61:	eb d9                	jmp    801c3c <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801c63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c67:	c7 44 24 08 e0 23 80 	movl   $0x8023e0,0x8(%esp)
  801c6e:	00 
  801c6f:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c76:	00 
  801c77:	c7 04 24 ee 23 80 00 	movl   $0x8023ee,(%esp)
  801c7e:	e8 21 f5 ff ff       	call   8011a4 <_panic>
		}
	}
}
  801c83:	83 c4 1c             	add    $0x1c,%esp
  801c86:	5b                   	pop    %ebx
  801c87:	5e                   	pop    %esi
  801c88:	5f                   	pop    %edi
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	53                   	push   %ebx
  801c8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c92:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c97:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c9e:	89 c2                	mov    %eax,%edx
  801ca0:	c1 e2 07             	shl    $0x7,%edx
  801ca3:	29 ca                	sub    %ecx,%edx
  801ca5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cab:	8b 52 50             	mov    0x50(%edx),%edx
  801cae:	39 da                	cmp    %ebx,%edx
  801cb0:	75 0f                	jne    801cc1 <ipc_find_env+0x36>
			return envs[i].env_id;
  801cb2:	c1 e0 07             	shl    $0x7,%eax
  801cb5:	29 c8                	sub    %ecx,%eax
  801cb7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cbc:	8b 40 40             	mov    0x40(%eax),%eax
  801cbf:	eb 0c                	jmp    801ccd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cc1:	40                   	inc    %eax
  801cc2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cc7:	75 ce                	jne    801c97 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cc9:	66 b8 00 00          	mov    $0x0,%ax
}
  801ccd:	5b                   	pop    %ebx
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cd6:	89 c2                	mov    %eax,%edx
  801cd8:	c1 ea 16             	shr    $0x16,%edx
  801cdb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ce2:	f6 c2 01             	test   $0x1,%dl
  801ce5:	74 1e                	je     801d05 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ce7:	c1 e8 0c             	shr    $0xc,%eax
  801cea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cf1:	a8 01                	test   $0x1,%al
  801cf3:	74 17                	je     801d0c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cf5:	c1 e8 0c             	shr    $0xc,%eax
  801cf8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801cff:	ef 
  801d00:	0f b7 c0             	movzwl %ax,%eax
  801d03:	eb 0c                	jmp    801d11 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d05:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0a:	eb 05                	jmp    801d11 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d0c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    
	...

00801d14 <__udivdi3>:
  801d14:	55                   	push   %ebp
  801d15:	57                   	push   %edi
  801d16:	56                   	push   %esi
  801d17:	83 ec 10             	sub    $0x10,%esp
  801d1a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d1e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801d22:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d26:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801d2a:	89 cd                	mov    %ecx,%ebp
  801d2c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801d30:	85 c0                	test   %eax,%eax
  801d32:	75 2c                	jne    801d60 <__udivdi3+0x4c>
  801d34:	39 f9                	cmp    %edi,%ecx
  801d36:	77 68                	ja     801da0 <__udivdi3+0x8c>
  801d38:	85 c9                	test   %ecx,%ecx
  801d3a:	75 0b                	jne    801d47 <__udivdi3+0x33>
  801d3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d41:	31 d2                	xor    %edx,%edx
  801d43:	f7 f1                	div    %ecx
  801d45:	89 c1                	mov    %eax,%ecx
  801d47:	31 d2                	xor    %edx,%edx
  801d49:	89 f8                	mov    %edi,%eax
  801d4b:	f7 f1                	div    %ecx
  801d4d:	89 c7                	mov    %eax,%edi
  801d4f:	89 f0                	mov    %esi,%eax
  801d51:	f7 f1                	div    %ecx
  801d53:	89 c6                	mov    %eax,%esi
  801d55:	89 f0                	mov    %esi,%eax
  801d57:	89 fa                	mov    %edi,%edx
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	5e                   	pop    %esi
  801d5d:	5f                   	pop    %edi
  801d5e:	5d                   	pop    %ebp
  801d5f:	c3                   	ret    
  801d60:	39 f8                	cmp    %edi,%eax
  801d62:	77 2c                	ja     801d90 <__udivdi3+0x7c>
  801d64:	0f bd f0             	bsr    %eax,%esi
  801d67:	83 f6 1f             	xor    $0x1f,%esi
  801d6a:	75 4c                	jne    801db8 <__udivdi3+0xa4>
  801d6c:	39 f8                	cmp    %edi,%eax
  801d6e:	bf 00 00 00 00       	mov    $0x0,%edi
  801d73:	72 0a                	jb     801d7f <__udivdi3+0x6b>
  801d75:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d79:	0f 87 ad 00 00 00    	ja     801e2c <__udivdi3+0x118>
  801d7f:	be 01 00 00 00       	mov    $0x1,%esi
  801d84:	89 f0                	mov    %esi,%eax
  801d86:	89 fa                	mov    %edi,%edx
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	5e                   	pop    %esi
  801d8c:	5f                   	pop    %edi
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    
  801d8f:	90                   	nop
  801d90:	31 ff                	xor    %edi,%edi
  801d92:	31 f6                	xor    %esi,%esi
  801d94:	89 f0                	mov    %esi,%eax
  801d96:	89 fa                	mov    %edi,%edx
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	5e                   	pop    %esi
  801d9c:	5f                   	pop    %edi
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    
  801d9f:	90                   	nop
  801da0:	89 fa                	mov    %edi,%edx
  801da2:	89 f0                	mov    %esi,%eax
  801da4:	f7 f1                	div    %ecx
  801da6:	89 c6                	mov    %eax,%esi
  801da8:	31 ff                	xor    %edi,%edi
  801daa:	89 f0                	mov    %esi,%eax
  801dac:	89 fa                	mov    %edi,%edx
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
  801db8:	89 f1                	mov    %esi,%ecx
  801dba:	d3 e0                	shl    %cl,%eax
  801dbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dc0:	b8 20 00 00 00       	mov    $0x20,%eax
  801dc5:	29 f0                	sub    %esi,%eax
  801dc7:	89 ea                	mov    %ebp,%edx
  801dc9:	88 c1                	mov    %al,%cl
  801dcb:	d3 ea                	shr    %cl,%edx
  801dcd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801dd1:	09 ca                	or     %ecx,%edx
  801dd3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dd7:	89 f1                	mov    %esi,%ecx
  801dd9:	d3 e5                	shl    %cl,%ebp
  801ddb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801ddf:	89 fd                	mov    %edi,%ebp
  801de1:	88 c1                	mov    %al,%cl
  801de3:	d3 ed                	shr    %cl,%ebp
  801de5:	89 fa                	mov    %edi,%edx
  801de7:	89 f1                	mov    %esi,%ecx
  801de9:	d3 e2                	shl    %cl,%edx
  801deb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801def:	88 c1                	mov    %al,%cl
  801df1:	d3 ef                	shr    %cl,%edi
  801df3:	09 d7                	or     %edx,%edi
  801df5:	89 f8                	mov    %edi,%eax
  801df7:	89 ea                	mov    %ebp,%edx
  801df9:	f7 74 24 08          	divl   0x8(%esp)
  801dfd:	89 d1                	mov    %edx,%ecx
  801dff:	89 c7                	mov    %eax,%edi
  801e01:	f7 64 24 0c          	mull   0xc(%esp)
  801e05:	39 d1                	cmp    %edx,%ecx
  801e07:	72 17                	jb     801e20 <__udivdi3+0x10c>
  801e09:	74 09                	je     801e14 <__udivdi3+0x100>
  801e0b:	89 fe                	mov    %edi,%esi
  801e0d:	31 ff                	xor    %edi,%edi
  801e0f:	e9 41 ff ff ff       	jmp    801d55 <__udivdi3+0x41>
  801e14:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e18:	89 f1                	mov    %esi,%ecx
  801e1a:	d3 e2                	shl    %cl,%edx
  801e1c:	39 c2                	cmp    %eax,%edx
  801e1e:	73 eb                	jae    801e0b <__udivdi3+0xf7>
  801e20:	8d 77 ff             	lea    -0x1(%edi),%esi
  801e23:	31 ff                	xor    %edi,%edi
  801e25:	e9 2b ff ff ff       	jmp    801d55 <__udivdi3+0x41>
  801e2a:	66 90                	xchg   %ax,%ax
  801e2c:	31 f6                	xor    %esi,%esi
  801e2e:	e9 22 ff ff ff       	jmp    801d55 <__udivdi3+0x41>
	...

00801e34 <__umoddi3>:
  801e34:	55                   	push   %ebp
  801e35:	57                   	push   %edi
  801e36:	56                   	push   %esi
  801e37:	83 ec 20             	sub    $0x20,%esp
  801e3a:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e3e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801e42:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e46:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e4a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e4e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801e52:	89 c7                	mov    %eax,%edi
  801e54:	89 f2                	mov    %esi,%edx
  801e56:	85 ed                	test   %ebp,%ebp
  801e58:	75 16                	jne    801e70 <__umoddi3+0x3c>
  801e5a:	39 f1                	cmp    %esi,%ecx
  801e5c:	0f 86 a6 00 00 00    	jbe    801f08 <__umoddi3+0xd4>
  801e62:	f7 f1                	div    %ecx
  801e64:	89 d0                	mov    %edx,%eax
  801e66:	31 d2                	xor    %edx,%edx
  801e68:	83 c4 20             	add    $0x20,%esp
  801e6b:	5e                   	pop    %esi
  801e6c:	5f                   	pop    %edi
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    
  801e6f:	90                   	nop
  801e70:	39 f5                	cmp    %esi,%ebp
  801e72:	0f 87 ac 00 00 00    	ja     801f24 <__umoddi3+0xf0>
  801e78:	0f bd c5             	bsr    %ebp,%eax
  801e7b:	83 f0 1f             	xor    $0x1f,%eax
  801e7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e82:	0f 84 a8 00 00 00    	je     801f30 <__umoddi3+0xfc>
  801e88:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e8c:	d3 e5                	shl    %cl,%ebp
  801e8e:	bf 20 00 00 00       	mov    $0x20,%edi
  801e93:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e97:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e9b:	89 f9                	mov    %edi,%ecx
  801e9d:	d3 e8                	shr    %cl,%eax
  801e9f:	09 e8                	or     %ebp,%eax
  801ea1:	89 44 24 18          	mov    %eax,0x18(%esp)
  801ea5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ea9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ead:	d3 e0                	shl    %cl,%eax
  801eaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eb3:	89 f2                	mov    %esi,%edx
  801eb5:	d3 e2                	shl    %cl,%edx
  801eb7:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ebb:	d3 e0                	shl    %cl,%eax
  801ebd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801ec1:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ec5:	89 f9                	mov    %edi,%ecx
  801ec7:	d3 e8                	shr    %cl,%eax
  801ec9:	09 d0                	or     %edx,%eax
  801ecb:	d3 ee                	shr    %cl,%esi
  801ecd:	89 f2                	mov    %esi,%edx
  801ecf:	f7 74 24 18          	divl   0x18(%esp)
  801ed3:	89 d6                	mov    %edx,%esi
  801ed5:	f7 64 24 0c          	mull   0xc(%esp)
  801ed9:	89 c5                	mov    %eax,%ebp
  801edb:	89 d1                	mov    %edx,%ecx
  801edd:	39 d6                	cmp    %edx,%esi
  801edf:	72 67                	jb     801f48 <__umoddi3+0x114>
  801ee1:	74 75                	je     801f58 <__umoddi3+0x124>
  801ee3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801ee7:	29 e8                	sub    %ebp,%eax
  801ee9:	19 ce                	sbb    %ecx,%esi
  801eeb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eef:	d3 e8                	shr    %cl,%eax
  801ef1:	89 f2                	mov    %esi,%edx
  801ef3:	89 f9                	mov    %edi,%ecx
  801ef5:	d3 e2                	shl    %cl,%edx
  801ef7:	09 d0                	or     %edx,%eax
  801ef9:	89 f2                	mov    %esi,%edx
  801efb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eff:	d3 ea                	shr    %cl,%edx
  801f01:	83 c4 20             	add    $0x20,%esp
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    
  801f08:	85 c9                	test   %ecx,%ecx
  801f0a:	75 0b                	jne    801f17 <__umoddi3+0xe3>
  801f0c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f11:	31 d2                	xor    %edx,%edx
  801f13:	f7 f1                	div    %ecx
  801f15:	89 c1                	mov    %eax,%ecx
  801f17:	89 f0                	mov    %esi,%eax
  801f19:	31 d2                	xor    %edx,%edx
  801f1b:	f7 f1                	div    %ecx
  801f1d:	89 f8                	mov    %edi,%eax
  801f1f:	e9 3e ff ff ff       	jmp    801e62 <__umoddi3+0x2e>
  801f24:	89 f2                	mov    %esi,%edx
  801f26:	83 c4 20             	add    $0x20,%esp
  801f29:	5e                   	pop    %esi
  801f2a:	5f                   	pop    %edi
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    
  801f2d:	8d 76 00             	lea    0x0(%esi),%esi
  801f30:	39 f5                	cmp    %esi,%ebp
  801f32:	72 04                	jb     801f38 <__umoddi3+0x104>
  801f34:	39 f9                	cmp    %edi,%ecx
  801f36:	77 06                	ja     801f3e <__umoddi3+0x10a>
  801f38:	89 f2                	mov    %esi,%edx
  801f3a:	29 cf                	sub    %ecx,%edi
  801f3c:	19 ea                	sbb    %ebp,%edx
  801f3e:	89 f8                	mov    %edi,%eax
  801f40:	83 c4 20             	add    $0x20,%esp
  801f43:	5e                   	pop    %esi
  801f44:	5f                   	pop    %edi
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    
  801f47:	90                   	nop
  801f48:	89 d1                	mov    %edx,%ecx
  801f4a:	89 c5                	mov    %eax,%ebp
  801f4c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f50:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f54:	eb 8d                	jmp    801ee3 <__umoddi3+0xaf>
  801f56:	66 90                	xchg   %ax,%ax
  801f58:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f5c:	72 ea                	jb     801f48 <__umoddi3+0x114>
  801f5e:	89 f1                	mov    %esi,%ecx
  801f60:	eb 81                	jmp    801ee3 <__umoddi3+0xaf>
