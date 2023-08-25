
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 5f 01 00 00       	call   8001b5 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800056:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005d:	f0 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 eb 02 00 00       	call   800355 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 10             	sub    $0x10,%esp
  800080:	8b 75 08             	mov    0x8(%ebp),%esi
  800083:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800086:	e8 ec 00 00 00       	call   800177 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800097:	c1 e0 07             	shl    $0x7,%eax
  80009a:	29 d0                	sub    %edx,%eax
  80009c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a6:	85 f6                	test   %esi,%esi
  8000a8:	7e 07                	jle    8000b1 <libmain+0x39>
		binaryname = argv[0];
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b5:	89 34 24             	mov    %esi,(%esp)
  8000b8:	e8 77 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bd:	e8 0a 00 00 00       	call   8000cc <exit>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000d2:	e8 30 05 00 00       	call   800607 <close_all>
	sys_env_destroy(0);
  8000d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000de:	e8 42 00 00 00       	call   800125 <sys_env_destroy>
}
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    
  8000e5:	00 00                	add    %al,(%eax)
	...

008000e8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	89 c3                	mov    %eax,%ebx
  8000fb:	89 c7                	mov    %eax,%edi
  8000fd:	89 c6                	mov    %eax,%esi
  8000ff:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <sys_cgetc>:

int
sys_cgetc(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	57                   	push   %edi
  80010a:	56                   	push   %esi
  80010b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010c:	ba 00 00 00 00       	mov    $0x0,%edx
  800111:	b8 01 00 00 00       	mov    $0x1,%eax
  800116:	89 d1                	mov    %edx,%ecx
  800118:	89 d3                	mov    %edx,%ebx
  80011a:	89 d7                	mov    %edx,%edi
  80011c:	89 d6                	mov    %edx,%esi
  80011e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
  80012b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800133:	b8 03 00 00 00       	mov    $0x3,%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	89 cb                	mov    %ecx,%ebx
  80013d:	89 cf                	mov    %ecx,%edi
  80013f:	89 ce                	mov    %ecx,%esi
  800141:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800143:	85 c0                	test   %eax,%eax
  800145:	7e 28                	jle    80016f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800147:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800152:	00 
  800153:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  80016a:	e8 29 10 00 00       	call   801198 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80016f:	83 c4 2c             	add    $0x2c,%esp
  800172:	5b                   	pop    %ebx
  800173:	5e                   	pop    %esi
  800174:	5f                   	pop    %edi
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	57                   	push   %edi
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017d:	ba 00 00 00 00       	mov    $0x0,%edx
  800182:	b8 02 00 00 00       	mov    $0x2,%eax
  800187:	89 d1                	mov    %edx,%ecx
  800189:	89 d3                	mov    %edx,%ebx
  80018b:	89 d7                	mov    %edx,%edi
  80018d:	89 d6                	mov    %edx,%esi
  80018f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800191:	5b                   	pop    %ebx
  800192:	5e                   	pop    %esi
  800193:	5f                   	pop    %edi
  800194:	5d                   	pop    %ebp
  800195:	c3                   	ret    

00800196 <sys_yield>:

void
sys_yield(void)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	57                   	push   %edi
  80019a:	56                   	push   %esi
  80019b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019c:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001a6:	89 d1                	mov    %edx,%ecx
  8001a8:	89 d3                	mov    %edx,%ebx
  8001aa:	89 d7                	mov    %edx,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001b0:	5b                   	pop    %ebx
  8001b1:	5e                   	pop    %esi
  8001b2:	5f                   	pop    %edi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    

008001b5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	57                   	push   %edi
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001be:	be 00 00 00 00       	mov    $0x0,%esi
  8001c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d1:	89 f7                	mov    %esi,%edi
  8001d3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 28                	jle    800201 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001e4:	00 
  8001e5:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  8001ec:	00 
  8001ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f4:	00 
  8001f5:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  8001fc:	e8 97 0f 00 00       	call   801198 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800201:	83 c4 2c             	add    $0x2c,%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800212:	b8 05 00 00 00       	mov    $0x5,%eax
  800217:	8b 75 18             	mov    0x18(%ebp),%esi
  80021a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80021d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800223:	8b 55 08             	mov    0x8(%ebp),%edx
  800226:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7e 28                	jle    800254 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800230:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800237:	00 
  800238:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  80023f:	00 
  800240:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800247:	00 
  800248:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  80024f:	e8 44 0f 00 00       	call   801198 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800254:	83 c4 2c             	add    $0x2c,%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    

0080025c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026a:	b8 06 00 00 00       	mov    $0x6,%eax
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	8b 55 08             	mov    0x8(%ebp),%edx
  800275:	89 df                	mov    %ebx,%edi
  800277:	89 de                	mov    %ebx,%esi
  800279:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027b:	85 c0                	test   %eax,%eax
  80027d:	7e 28                	jle    8002a7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800283:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80028a:	00 
  80028b:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  800292:	00 
  800293:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029a:	00 
  80029b:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  8002a2:	e8 f1 0e 00 00       	call   801198 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002a7:	83 c4 2c             	add    $0x2c,%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	89 df                	mov    %ebx,%edi
  8002ca:	89 de                	mov    %ebx,%esi
  8002cc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7e 28                	jle    8002fa <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002dd:	00 
  8002de:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  8002e5:	00 
  8002e6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ed:	00 
  8002ee:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  8002f5:	e8 9e 0e 00 00       	call   801198 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002fa:	83 c4 2c             	add    $0x2c,%esp
  8002fd:	5b                   	pop    %ebx
  8002fe:	5e                   	pop    %esi
  8002ff:	5f                   	pop    %edi
  800300:	5d                   	pop    %ebp
  800301:	c3                   	ret    

00800302 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800310:	b8 09 00 00 00       	mov    $0x9,%eax
  800315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 df                	mov    %ebx,%edi
  80031d:	89 de                	mov    %ebx,%esi
  80031f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800321:	85 c0                	test   %eax,%eax
  800323:	7e 28                	jle    80034d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800325:	89 44 24 10          	mov    %eax,0x10(%esp)
  800329:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800330:	00 
  800331:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  800338:	00 
  800339:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800340:	00 
  800341:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  800348:	e8 4b 0e 00 00       	call   801198 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80034d:	83 c4 2c             	add    $0x2c,%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	57                   	push   %edi
  800359:	56                   	push   %esi
  80035a:	53                   	push   %ebx
  80035b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800363:	b8 0a 00 00 00       	mov    $0xa,%eax
  800368:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036b:	8b 55 08             	mov    0x8(%ebp),%edx
  80036e:	89 df                	mov    %ebx,%edi
  800370:	89 de                	mov    %ebx,%esi
  800372:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	7e 28                	jle    8003a0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800378:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800383:	00 
  800384:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  80038b:	00 
  80038c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800393:	00 
  800394:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  80039b:	e8 f8 0d 00 00       	call   801198 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003a0:	83 c4 2c             	add    $0x2c,%esp
  8003a3:	5b                   	pop    %ebx
  8003a4:	5e                   	pop    %esi
  8003a5:	5f                   	pop    %edi
  8003a6:	5d                   	pop    %ebp
  8003a7:	c3                   	ret    

008003a8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	57                   	push   %edi
  8003ac:	56                   	push   %esi
  8003ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ae:	be 00 00 00 00       	mov    $0x0,%esi
  8003b3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003c6:	5b                   	pop    %ebx
  8003c7:	5e                   	pop    %esi
  8003c8:	5f                   	pop    %edi
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	57                   	push   %edi
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003de:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e1:	89 cb                	mov    %ecx,%ebx
  8003e3:	89 cf                	mov    %ecx,%edi
  8003e5:	89 ce                	mov    %ecx,%esi
  8003e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	7e 28                	jle    800415 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003f1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003f8:	00 
  8003f9:	c7 44 24 08 2a 1f 80 	movl   $0x801f2a,0x8(%esp)
  800400:	00 
  800401:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800408:	00 
  800409:	c7 04 24 47 1f 80 00 	movl   $0x801f47,(%esp)
  800410:	e8 83 0d 00 00       	call   801198 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800415:	83 c4 2c             	add    $0x2c,%esp
  800418:	5b                   	pop    %ebx
  800419:	5e                   	pop    %esi
  80041a:	5f                   	pop    %edi
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    
  80041d:	00 00                	add    %al,(%eax)
	...

00800420 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800423:	8b 45 08             	mov    0x8(%ebp),%eax
  800426:	05 00 00 00 30       	add    $0x30000000,%eax
  80042b:	c1 e8 0c             	shr    $0xc,%eax
}
  80042e:	5d                   	pop    %ebp
  80042f:	c3                   	ret    

00800430 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800436:	8b 45 08             	mov    0x8(%ebp),%eax
  800439:	89 04 24             	mov    %eax,(%esp)
  80043c:	e8 df ff ff ff       	call   800420 <fd2num>
  800441:	05 20 00 0d 00       	add    $0xd0020,%eax
  800446:	c1 e0 0c             	shl    $0xc,%eax
}
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	53                   	push   %ebx
  80044f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800452:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800457:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800459:	89 c2                	mov    %eax,%edx
  80045b:	c1 ea 16             	shr    $0x16,%edx
  80045e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800465:	f6 c2 01             	test   $0x1,%dl
  800468:	74 11                	je     80047b <fd_alloc+0x30>
  80046a:	89 c2                	mov    %eax,%edx
  80046c:	c1 ea 0c             	shr    $0xc,%edx
  80046f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800476:	f6 c2 01             	test   $0x1,%dl
  800479:	75 09                	jne    800484 <fd_alloc+0x39>
			*fd_store = fd;
  80047b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	eb 17                	jmp    80049b <fd_alloc+0x50>
  800484:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800489:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80048e:	75 c7                	jne    800457 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800490:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800496:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80049b:	5b                   	pop    %ebx
  80049c:	5d                   	pop    %ebp
  80049d:	c3                   	ret    

0080049e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80049e:	55                   	push   %ebp
  80049f:	89 e5                	mov    %esp,%ebp
  8004a1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004a4:	83 f8 1f             	cmp    $0x1f,%eax
  8004a7:	77 36                	ja     8004df <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004a9:	05 00 00 0d 00       	add    $0xd0000,%eax
  8004ae:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004b1:	89 c2                	mov    %eax,%edx
  8004b3:	c1 ea 16             	shr    $0x16,%edx
  8004b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004bd:	f6 c2 01             	test   $0x1,%dl
  8004c0:	74 24                	je     8004e6 <fd_lookup+0x48>
  8004c2:	89 c2                	mov    %eax,%edx
  8004c4:	c1 ea 0c             	shr    $0xc,%edx
  8004c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004ce:	f6 c2 01             	test   $0x1,%dl
  8004d1:	74 1a                	je     8004ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d6:	89 02                	mov    %eax,(%edx)
	return 0;
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	eb 13                	jmp    8004f2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004e4:	eb 0c                	jmp    8004f2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004eb:	eb 05                	jmp    8004f2 <fd_lookup+0x54>
  8004ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	53                   	push   %ebx
  8004f8:	83 ec 14             	sub    $0x14,%esp
  8004fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800501:	ba 00 00 00 00       	mov    $0x0,%edx
  800506:	eb 0e                	jmp    800516 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800508:	39 08                	cmp    %ecx,(%eax)
  80050a:	75 09                	jne    800515 <dev_lookup+0x21>
			*dev = devtab[i];
  80050c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80050e:	b8 00 00 00 00       	mov    $0x0,%eax
  800513:	eb 33                	jmp    800548 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800515:	42                   	inc    %edx
  800516:	8b 04 95 d4 1f 80 00 	mov    0x801fd4(,%edx,4),%eax
  80051d:	85 c0                	test   %eax,%eax
  80051f:	75 e7                	jne    800508 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800521:	a1 04 40 80 00       	mov    0x804004,%eax
  800526:	8b 40 48             	mov    0x48(%eax),%eax
  800529:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	c7 04 24 58 1f 80 00 	movl   $0x801f58,(%esp)
  800538:	e8 53 0d 00 00       	call   801290 <cprintf>
	*dev = 0;
  80053d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800543:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800548:	83 c4 14             	add    $0x14,%esp
  80054b:	5b                   	pop    %ebx
  80054c:	5d                   	pop    %ebp
  80054d:	c3                   	ret    

0080054e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80054e:	55                   	push   %ebp
  80054f:	89 e5                	mov    %esp,%ebp
  800551:	56                   	push   %esi
  800552:	53                   	push   %ebx
  800553:	83 ec 30             	sub    $0x30,%esp
  800556:	8b 75 08             	mov    0x8(%ebp),%esi
  800559:	8a 45 0c             	mov    0xc(%ebp),%al
  80055c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80055f:	89 34 24             	mov    %esi,(%esp)
  800562:	e8 b9 fe ff ff       	call   800420 <fd2num>
  800567:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80056a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	e8 28 ff ff ff       	call   80049e <fd_lookup>
  800576:	89 c3                	mov    %eax,%ebx
  800578:	85 c0                	test   %eax,%eax
  80057a:	78 05                	js     800581 <fd_close+0x33>
	    || fd != fd2)
  80057c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80057f:	74 0d                	je     80058e <fd_close+0x40>
		return (must_exist ? r : 0);
  800581:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800585:	75 46                	jne    8005cd <fd_close+0x7f>
  800587:	bb 00 00 00 00       	mov    $0x0,%ebx
  80058c:	eb 3f                	jmp    8005cd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80058e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800591:	89 44 24 04          	mov    %eax,0x4(%esp)
  800595:	8b 06                	mov    (%esi),%eax
  800597:	89 04 24             	mov    %eax,(%esp)
  80059a:	e8 55 ff ff ff       	call   8004f4 <dev_lookup>
  80059f:	89 c3                	mov    %eax,%ebx
  8005a1:	85 c0                	test   %eax,%eax
  8005a3:	78 18                	js     8005bd <fd_close+0x6f>
		if (dev->dev_close)
  8005a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a8:	8b 40 10             	mov    0x10(%eax),%eax
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	74 09                	je     8005b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005af:	89 34 24             	mov    %esi,(%esp)
  8005b2:	ff d0                	call   *%eax
  8005b4:	89 c3                	mov    %eax,%ebx
  8005b6:	eb 05                	jmp    8005bd <fd_close+0x6f>
		else
			r = 0;
  8005b8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005c8:	e8 8f fc ff ff       	call   80025c <sys_page_unmap>
	return r;
}
  8005cd:	89 d8                	mov    %ebx,%eax
  8005cf:	83 c4 30             	add    $0x30,%esp
  8005d2:	5b                   	pop    %ebx
  8005d3:	5e                   	pop    %esi
  8005d4:	5d                   	pop    %ebp
  8005d5:	c3                   	ret    

008005d6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005d6:	55                   	push   %ebp
  8005d7:	89 e5                	mov    %esp,%ebp
  8005d9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e6:	89 04 24             	mov    %eax,(%esp)
  8005e9:	e8 b0 fe ff ff       	call   80049e <fd_lookup>
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	78 13                	js     800605 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005f9:	00 
  8005fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005fd:	89 04 24             	mov    %eax,(%esp)
  800600:	e8 49 ff ff ff       	call   80054e <fd_close>
}
  800605:	c9                   	leave  
  800606:	c3                   	ret    

00800607 <close_all>:

void
close_all(void)
{
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	53                   	push   %ebx
  80060b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80060e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800613:	89 1c 24             	mov    %ebx,(%esp)
  800616:	e8 bb ff ff ff       	call   8005d6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80061b:	43                   	inc    %ebx
  80061c:	83 fb 20             	cmp    $0x20,%ebx
  80061f:	75 f2                	jne    800613 <close_all+0xc>
		close(i);
}
  800621:	83 c4 14             	add    $0x14,%esp
  800624:	5b                   	pop    %ebx
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	57                   	push   %edi
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	83 ec 4c             	sub    $0x4c,%esp
  800630:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800633:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063a:	8b 45 08             	mov    0x8(%ebp),%eax
  80063d:	89 04 24             	mov    %eax,(%esp)
  800640:	e8 59 fe ff ff       	call   80049e <fd_lookup>
  800645:	89 c3                	mov    %eax,%ebx
  800647:	85 c0                	test   %eax,%eax
  800649:	0f 88 e1 00 00 00    	js     800730 <dup+0x109>
		return r;
	close(newfdnum);
  80064f:	89 3c 24             	mov    %edi,(%esp)
  800652:	e8 7f ff ff ff       	call   8005d6 <close>

	newfd = INDEX2FD(newfdnum);
  800657:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80065d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800663:	89 04 24             	mov    %eax,(%esp)
  800666:	e8 c5 fd ff ff       	call   800430 <fd2data>
  80066b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80066d:	89 34 24             	mov    %esi,(%esp)
  800670:	e8 bb fd ff ff       	call   800430 <fd2data>
  800675:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800678:	89 d8                	mov    %ebx,%eax
  80067a:	c1 e8 16             	shr    $0x16,%eax
  80067d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800684:	a8 01                	test   $0x1,%al
  800686:	74 46                	je     8006ce <dup+0xa7>
  800688:	89 d8                	mov    %ebx,%eax
  80068a:	c1 e8 0c             	shr    $0xc,%eax
  80068d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800694:	f6 c2 01             	test   $0x1,%dl
  800697:	74 35                	je     8006ce <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800699:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8006a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006b7:	00 
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c3:	e8 41 fb ff ff       	call   800209 <sys_page_map>
  8006c8:	89 c3                	mov    %eax,%ebx
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	78 3b                	js     800709 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d1:	89 c2                	mov    %eax,%edx
  8006d3:	c1 ea 0c             	shr    $0xc,%edx
  8006d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006dd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006e3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006f2:	00 
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006fe:	e8 06 fb ff ff       	call   800209 <sys_page_map>
  800703:	89 c3                	mov    %eax,%ebx
  800705:	85 c0                	test   %eax,%eax
  800707:	79 25                	jns    80072e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800709:	89 74 24 04          	mov    %esi,0x4(%esp)
  80070d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800714:	e8 43 fb ff ff       	call   80025c <sys_page_unmap>
	sys_page_unmap(0, nva);
  800719:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80071c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800720:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800727:	e8 30 fb ff ff       	call   80025c <sys_page_unmap>
	return r;
  80072c:	eb 02                	jmp    800730 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80072e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800730:	89 d8                	mov    %ebx,%eax
  800732:	83 c4 4c             	add    $0x4c,%esp
  800735:	5b                   	pop    %ebx
  800736:	5e                   	pop    %esi
  800737:	5f                   	pop    %edi
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	53                   	push   %ebx
  80073e:	83 ec 24             	sub    $0x24,%esp
  800741:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800744:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074b:	89 1c 24             	mov    %ebx,(%esp)
  80074e:	e8 4b fd ff ff       	call   80049e <fd_lookup>
  800753:	85 c0                	test   %eax,%eax
  800755:	78 6d                	js     8007c4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800757:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800761:	8b 00                	mov    (%eax),%eax
  800763:	89 04 24             	mov    %eax,(%esp)
  800766:	e8 89 fd ff ff       	call   8004f4 <dev_lookup>
  80076b:	85 c0                	test   %eax,%eax
  80076d:	78 55                	js     8007c4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80076f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800772:	8b 50 08             	mov    0x8(%eax),%edx
  800775:	83 e2 03             	and    $0x3,%edx
  800778:	83 fa 01             	cmp    $0x1,%edx
  80077b:	75 23                	jne    8007a0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80077d:	a1 04 40 80 00       	mov    0x804004,%eax
  800782:	8b 40 48             	mov    0x48(%eax),%eax
  800785:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078d:	c7 04 24 99 1f 80 00 	movl   $0x801f99,(%esp)
  800794:	e8 f7 0a 00 00       	call   801290 <cprintf>
		return -E_INVAL;
  800799:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079e:	eb 24                	jmp    8007c4 <read+0x8a>
	}
	if (!dev->dev_read)
  8007a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a3:	8b 52 08             	mov    0x8(%edx),%edx
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	74 15                	je     8007bf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007b8:	89 04 24             	mov    %eax,(%esp)
  8007bb:	ff d2                	call   *%edx
  8007bd:	eb 05                	jmp    8007c4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007c4:	83 c4 24             	add    $0x24,%esp
  8007c7:	5b                   	pop    %ebx
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	57                   	push   %edi
  8007ce:	56                   	push   %esi
  8007cf:	53                   	push   %ebx
  8007d0:	83 ec 1c             	sub    $0x1c,%esp
  8007d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007de:	eb 23                	jmp    800803 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	29 d8                	sub    %ebx,%eax
  8007e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007eb:	01 d8                	add    %ebx,%eax
  8007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f1:	89 3c 24             	mov    %edi,(%esp)
  8007f4:	e8 41 ff ff ff       	call   80073a <read>
		if (m < 0)
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	78 10                	js     80080d <readn+0x43>
			return m;
		if (m == 0)
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	74 0a                	je     80080b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800801:	01 c3                	add    %eax,%ebx
  800803:	39 f3                	cmp    %esi,%ebx
  800805:	72 d9                	jb     8007e0 <readn+0x16>
  800807:	89 d8                	mov    %ebx,%eax
  800809:	eb 02                	jmp    80080d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80080b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80080d:	83 c4 1c             	add    $0x1c,%esp
  800810:	5b                   	pop    %ebx
  800811:	5e                   	pop    %esi
  800812:	5f                   	pop    %edi
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	83 ec 24             	sub    $0x24,%esp
  80081c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800822:	89 44 24 04          	mov    %eax,0x4(%esp)
  800826:	89 1c 24             	mov    %ebx,(%esp)
  800829:	e8 70 fc ff ff       	call   80049e <fd_lookup>
  80082e:	85 c0                	test   %eax,%eax
  800830:	78 68                	js     80089a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800835:	89 44 24 04          	mov    %eax,0x4(%esp)
  800839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083c:	8b 00                	mov    (%eax),%eax
  80083e:	89 04 24             	mov    %eax,(%esp)
  800841:	e8 ae fc ff ff       	call   8004f4 <dev_lookup>
  800846:	85 c0                	test   %eax,%eax
  800848:	78 50                	js     80089a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80084a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800851:	75 23                	jne    800876 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800853:	a1 04 40 80 00       	mov    0x804004,%eax
  800858:	8b 40 48             	mov    0x48(%eax),%eax
  80085b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80085f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800863:	c7 04 24 b5 1f 80 00 	movl   $0x801fb5,(%esp)
  80086a:	e8 21 0a 00 00       	call   801290 <cprintf>
		return -E_INVAL;
  80086f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800874:	eb 24                	jmp    80089a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800876:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800879:	8b 52 0c             	mov    0xc(%edx),%edx
  80087c:	85 d2                	test   %edx,%edx
  80087e:	74 15                	je     800895 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800880:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800883:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80088e:	89 04 24             	mov    %eax,(%esp)
  800891:	ff d2                	call   *%edx
  800893:	eb 05                	jmp    80089a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800895:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80089a:	83 c4 24             	add    $0x24,%esp
  80089d:	5b                   	pop    %ebx
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008a6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	89 04 24             	mov    %eax,(%esp)
  8008b3:	e8 e6 fb ff ff       	call   80049e <fd_lookup>
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	78 0e                	js     8008ca <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	53                   	push   %ebx
  8008d0:	83 ec 24             	sub    $0x24,%esp
  8008d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dd:	89 1c 24             	mov    %ebx,(%esp)
  8008e0:	e8 b9 fb ff ff       	call   80049e <fd_lookup>
  8008e5:	85 c0                	test   %eax,%eax
  8008e7:	78 61                	js     80094a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f3:	8b 00                	mov    (%eax),%eax
  8008f5:	89 04 24             	mov    %eax,(%esp)
  8008f8:	e8 f7 fb ff ff       	call   8004f4 <dev_lookup>
  8008fd:	85 c0                	test   %eax,%eax
  8008ff:	78 49                	js     80094a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800901:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800904:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800908:	75 23                	jne    80092d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80090a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80090f:	8b 40 48             	mov    0x48(%eax),%eax
  800912:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091a:	c7 04 24 78 1f 80 00 	movl   $0x801f78,(%esp)
  800921:	e8 6a 09 00 00       	call   801290 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800926:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80092b:	eb 1d                	jmp    80094a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80092d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800930:	8b 52 18             	mov    0x18(%edx),%edx
  800933:	85 d2                	test   %edx,%edx
  800935:	74 0e                	je     800945 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800937:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80093e:	89 04 24             	mov    %eax,(%esp)
  800941:	ff d2                	call   *%edx
  800943:	eb 05                	jmp    80094a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800945:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80094a:	83 c4 24             	add    $0x24,%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	53                   	push   %ebx
  800954:	83 ec 24             	sub    $0x24,%esp
  800957:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80095a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80095d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	89 04 24             	mov    %eax,(%esp)
  800967:	e8 32 fb ff ff       	call   80049e <fd_lookup>
  80096c:	85 c0                	test   %eax,%eax
  80096e:	78 52                	js     8009c2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800970:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800973:	89 44 24 04          	mov    %eax,0x4(%esp)
  800977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80097a:	8b 00                	mov    (%eax),%eax
  80097c:	89 04 24             	mov    %eax,(%esp)
  80097f:	e8 70 fb ff ff       	call   8004f4 <dev_lookup>
  800984:	85 c0                	test   %eax,%eax
  800986:	78 3a                	js     8009c2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800988:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80098f:	74 2c                	je     8009bd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800991:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800994:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80099b:	00 00 00 
	stat->st_isdir = 0;
  80099e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009a5:	00 00 00 
	stat->st_dev = dev;
  8009a8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009b5:	89 14 24             	mov    %edx,(%esp)
  8009b8:	ff 50 14             	call   *0x14(%eax)
  8009bb:	eb 05                	jmp    8009c2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009c2:	83 c4 24             	add    $0x24,%esp
  8009c5:	5b                   	pop    %ebx
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009d7:	00 
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	89 04 24             	mov    %eax,(%esp)
  8009de:	e8 fe 01 00 00       	call   800be1 <open>
  8009e3:	89 c3                	mov    %eax,%ebx
  8009e5:	85 c0                	test   %eax,%eax
  8009e7:	78 1b                	js     800a04 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f0:	89 1c 24             	mov    %ebx,(%esp)
  8009f3:	e8 58 ff ff ff       	call   800950 <fstat>
  8009f8:	89 c6                	mov    %eax,%esi
	close(fd);
  8009fa:	89 1c 24             	mov    %ebx,(%esp)
  8009fd:	e8 d4 fb ff ff       	call   8005d6 <close>
	return r;
  800a02:	89 f3                	mov    %esi,%ebx
}
  800a04:	89 d8                	mov    %ebx,%eax
  800a06:	83 c4 10             	add    $0x10,%esp
  800a09:	5b                   	pop    %ebx
  800a0a:	5e                   	pop    %esi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    
  800a0d:	00 00                	add    %al,(%eax)
	...

00800a10 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	83 ec 10             	sub    $0x10,%esp
  800a18:	89 c3                	mov    %eax,%ebx
  800a1a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a1c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a23:	75 11                	jne    800a36 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a25:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a2c:	e8 02 12 00 00       	call   801c33 <ipc_find_env>
  800a31:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a36:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a3d:	00 
  800a3e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a45:	00 
  800a46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a4a:	a1 00 40 80 00       	mov    0x804000,%eax
  800a4f:	89 04 24             	mov    %eax,(%esp)
  800a52:	e8 72 11 00 00       	call   801bc9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a5e:	00 
  800a5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a6a:	e8 f1 10 00 00       	call   801b60 <ipc_recv>
}
  800a6f:	83 c4 10             	add    $0x10,%esp
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a82:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a94:	b8 02 00 00 00       	mov    $0x2,%eax
  800a99:	e8 72 ff ff ff       	call   800a10 <fsipc>
}
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 40 0c             	mov    0xc(%eax),%eax
  800aac:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab6:	b8 06 00 00 00       	mov    $0x6,%eax
  800abb:	e8 50 ff ff ff       	call   800a10 <fsipc>
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 14             	sub    $0x14,%esp
  800ac9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	8b 40 0c             	mov    0xc(%eax),%eax
  800ad2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  800adc:	b8 05 00 00 00       	mov    $0x5,%eax
  800ae1:	e8 2a ff ff ff       	call   800a10 <fsipc>
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	78 2b                	js     800b15 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aea:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800af1:	00 
  800af2:	89 1c 24             	mov    %ebx,(%esp)
  800af5:	e8 41 0d 00 00       	call   80183b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800afa:	a1 80 50 80 00       	mov    0x805080,%eax
  800aff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b05:	a1 84 50 80 00       	mov    0x805084,%eax
  800b0a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b15:	83 c4 14             	add    $0x14,%esp
  800b18:	5b                   	pop    %ebx
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800b21:	c7 44 24 08 e4 1f 80 	movl   $0x801fe4,0x8(%esp)
  800b28:	00 
  800b29:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800b30:	00 
  800b31:	c7 04 24 02 20 80 00 	movl   $0x802002,(%esp)
  800b38:	e8 5b 06 00 00       	call   801198 <_panic>

00800b3d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 10             	sub    $0x10,%esp
  800b45:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 40 0c             	mov    0xc(%eax),%eax
  800b4e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b53:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b63:	e8 a8 fe ff ff       	call   800a10 <fsipc>
  800b68:	89 c3                	mov    %eax,%ebx
  800b6a:	85 c0                	test   %eax,%eax
  800b6c:	78 6a                	js     800bd8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800b6e:	39 c6                	cmp    %eax,%esi
  800b70:	73 24                	jae    800b96 <devfile_read+0x59>
  800b72:	c7 44 24 0c 0d 20 80 	movl   $0x80200d,0xc(%esp)
  800b79:	00 
  800b7a:	c7 44 24 08 14 20 80 	movl   $0x802014,0x8(%esp)
  800b81:	00 
  800b82:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b89:	00 
  800b8a:	c7 04 24 02 20 80 00 	movl   $0x802002,(%esp)
  800b91:	e8 02 06 00 00       	call   801198 <_panic>
	assert(r <= PGSIZE);
  800b96:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b9b:	7e 24                	jle    800bc1 <devfile_read+0x84>
  800b9d:	c7 44 24 0c 29 20 80 	movl   $0x802029,0xc(%esp)
  800ba4:	00 
  800ba5:	c7 44 24 08 14 20 80 	movl   $0x802014,0x8(%esp)
  800bac:	00 
  800bad:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800bb4:	00 
  800bb5:	c7 04 24 02 20 80 00 	movl   $0x802002,(%esp)
  800bbc:	e8 d7 05 00 00       	call   801198 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800bc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800bcc:	00 
  800bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd0:	89 04 24             	mov    %eax,(%esp)
  800bd3:	e8 dc 0d 00 00       	call   8019b4 <memmove>
	return r;
}
  800bd8:	89 d8                	mov    %ebx,%eax
  800bda:	83 c4 10             	add    $0x10,%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 20             	sub    $0x20,%esp
  800be9:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bec:	89 34 24             	mov    %esi,(%esp)
  800bef:	e8 14 0c 00 00       	call   801808 <strlen>
  800bf4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bf9:	7f 60                	jg     800c5b <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bfe:	89 04 24             	mov    %eax,(%esp)
  800c01:	e8 45 f8 ff ff       	call   80044b <fd_alloc>
  800c06:	89 c3                	mov    %eax,%ebx
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	78 54                	js     800c60 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c10:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c17:	e8 1f 0c 00 00       	call   80183b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c27:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2c:	e8 df fd ff ff       	call   800a10 <fsipc>
  800c31:	89 c3                	mov    %eax,%ebx
  800c33:	85 c0                	test   %eax,%eax
  800c35:	79 15                	jns    800c4c <open+0x6b>
		fd_close(fd, 0);
  800c37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c3e:	00 
  800c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c42:	89 04 24             	mov    %eax,(%esp)
  800c45:	e8 04 f9 ff ff       	call   80054e <fd_close>
		return r;
  800c4a:	eb 14                	jmp    800c60 <open+0x7f>
	}

	return fd2num(fd);
  800c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4f:	89 04 24             	mov    %eax,(%esp)
  800c52:	e8 c9 f7 ff ff       	call   800420 <fd2num>
  800c57:	89 c3                	mov    %eax,%ebx
  800c59:	eb 05                	jmp    800c60 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c5b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c60:	89 d8                	mov    %ebx,%eax
  800c62:	83 c4 20             	add    $0x20,%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c74:	b8 08 00 00 00       	mov    $0x8,%eax
  800c79:	e8 92 fd ff ff       	call   800a10 <fsipc>
}
  800c7e:	c9                   	leave  
  800c7f:	c3                   	ret    

00800c80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 10             	sub    $0x10,%esp
  800c88:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	89 04 24             	mov    %eax,(%esp)
  800c91:	e8 9a f7 ff ff       	call   800430 <fd2data>
  800c96:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800c98:	c7 44 24 04 35 20 80 	movl   $0x802035,0x4(%esp)
  800c9f:	00 
  800ca0:	89 34 24             	mov    %esi,(%esp)
  800ca3:	e8 93 0b 00 00       	call   80183b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ca8:	8b 43 04             	mov    0x4(%ebx),%eax
  800cab:	2b 03                	sub    (%ebx),%eax
  800cad:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800cb3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800cba:	00 00 00 
	stat->st_dev = &devpipe;
  800cbd:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800cc4:	30 80 00 
	return 0;
}
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccc:	83 c4 10             	add    $0x10,%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 14             	sub    $0x14,%esp
  800cda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800cdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ce1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ce8:	e8 6f f5 ff ff       	call   80025c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800ced:	89 1c 24             	mov    %ebx,(%esp)
  800cf0:	e8 3b f7 ff ff       	call   800430 <fd2data>
  800cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d00:	e8 57 f5 ff ff       	call   80025c <sys_page_unmap>
}
  800d05:	83 c4 14             	add    $0x14,%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 2c             	sub    $0x2c,%esp
  800d14:	89 c7                	mov    %eax,%edi
  800d16:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800d19:	a1 04 40 80 00       	mov    0x804004,%eax
  800d1e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800d21:	89 3c 24             	mov    %edi,(%esp)
  800d24:	e8 4f 0f 00 00       	call   801c78 <pageref>
  800d29:	89 c6                	mov    %eax,%esi
  800d2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d2e:	89 04 24             	mov    %eax,(%esp)
  800d31:	e8 42 0f 00 00       	call   801c78 <pageref>
  800d36:	39 c6                	cmp    %eax,%esi
  800d38:	0f 94 c0             	sete   %al
  800d3b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800d3e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d44:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800d47:	39 cb                	cmp    %ecx,%ebx
  800d49:	75 08                	jne    800d53 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800d4b:	83 c4 2c             	add    $0x2c,%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800d53:	83 f8 01             	cmp    $0x1,%eax
  800d56:	75 c1                	jne    800d19 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d58:	8b 42 58             	mov    0x58(%edx),%eax
  800d5b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800d62:	00 
  800d63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d6b:	c7 04 24 3c 20 80 00 	movl   $0x80203c,(%esp)
  800d72:	e8 19 05 00 00       	call   801290 <cprintf>
  800d77:	eb a0                	jmp    800d19 <_pipeisclosed+0xe>

00800d79 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
  800d7f:	83 ec 1c             	sub    $0x1c,%esp
  800d82:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800d85:	89 34 24             	mov    %esi,(%esp)
  800d88:	e8 a3 f6 ff ff       	call   800430 <fd2data>
  800d8d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d94:	eb 3c                	jmp    800dd2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800d96:	89 da                	mov    %ebx,%edx
  800d98:	89 f0                	mov    %esi,%eax
  800d9a:	e8 6c ff ff ff       	call   800d0b <_pipeisclosed>
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	75 38                	jne    800ddb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800da3:	e8 ee f3 ff ff       	call   800196 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800da8:	8b 43 04             	mov    0x4(%ebx),%eax
  800dab:	8b 13                	mov    (%ebx),%edx
  800dad:	83 c2 20             	add    $0x20,%edx
  800db0:	39 d0                	cmp    %edx,%eax
  800db2:	73 e2                	jae    800d96 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800db4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800dba:	89 c2                	mov    %eax,%edx
  800dbc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800dc2:	79 05                	jns    800dc9 <devpipe_write+0x50>
  800dc4:	4a                   	dec    %edx
  800dc5:	83 ca e0             	or     $0xffffffe0,%edx
  800dc8:	42                   	inc    %edx
  800dc9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800dcd:	40                   	inc    %eax
  800dce:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dd1:	47                   	inc    %edi
  800dd2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800dd5:	75 d1                	jne    800da8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800dd7:	89 f8                	mov    %edi,%eax
  800dd9:	eb 05                	jmp    800de0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800de0:	83 c4 1c             	add    $0x1c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 1c             	sub    $0x1c,%esp
  800df1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800df4:	89 3c 24             	mov    %edi,(%esp)
  800df7:	e8 34 f6 ff ff       	call   800430 <fd2data>
  800dfc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dfe:	be 00 00 00 00       	mov    $0x0,%esi
  800e03:	eb 3a                	jmp    800e3f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800e05:	85 f6                	test   %esi,%esi
  800e07:	74 04                	je     800e0d <devpipe_read+0x25>
				return i;
  800e09:	89 f0                	mov    %esi,%eax
  800e0b:	eb 40                	jmp    800e4d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800e0d:	89 da                	mov    %ebx,%edx
  800e0f:	89 f8                	mov    %edi,%eax
  800e11:	e8 f5 fe ff ff       	call   800d0b <_pipeisclosed>
  800e16:	85 c0                	test   %eax,%eax
  800e18:	75 2e                	jne    800e48 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800e1a:	e8 77 f3 ff ff       	call   800196 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800e1f:	8b 03                	mov    (%ebx),%eax
  800e21:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e24:	74 df                	je     800e05 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e26:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800e2b:	79 05                	jns    800e32 <devpipe_read+0x4a>
  800e2d:	48                   	dec    %eax
  800e2e:	83 c8 e0             	or     $0xffffffe0,%eax
  800e31:	40                   	inc    %eax
  800e32:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800e36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e39:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800e3c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e3e:	46                   	inc    %esi
  800e3f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e42:	75 db                	jne    800e1f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800e44:	89 f0                	mov    %esi,%eax
  800e46:	eb 05                	jmp    800e4d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e48:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800e4d:	83 c4 1c             	add    $0x1c,%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 3c             	sub    $0x3c,%esp
  800e5e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800e61:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e64:	89 04 24             	mov    %eax,(%esp)
  800e67:	e8 df f5 ff ff       	call   80044b <fd_alloc>
  800e6c:	89 c3                	mov    %eax,%ebx
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	0f 88 45 01 00 00    	js     800fbb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e76:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e7d:	00 
  800e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8c:	e8 24 f3 ff ff       	call   8001b5 <sys_page_alloc>
  800e91:	89 c3                	mov    %eax,%ebx
  800e93:	85 c0                	test   %eax,%eax
  800e95:	0f 88 20 01 00 00    	js     800fbb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800e9b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e9e:	89 04 24             	mov    %eax,(%esp)
  800ea1:	e8 a5 f5 ff ff       	call   80044b <fd_alloc>
  800ea6:	89 c3                	mov    %eax,%ebx
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	0f 88 f8 00 00 00    	js     800fa8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eb0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800eb7:	00 
  800eb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ebb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ebf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec6:	e8 ea f2 ff ff       	call   8001b5 <sys_page_alloc>
  800ecb:	89 c3                	mov    %eax,%ebx
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	0f 88 d3 00 00 00    	js     800fa8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ed8:	89 04 24             	mov    %eax,(%esp)
  800edb:	e8 50 f5 ff ff       	call   800430 <fd2data>
  800ee0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ee2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ee9:	00 
  800eea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef5:	e8 bb f2 ff ff       	call   8001b5 <sys_page_alloc>
  800efa:	89 c3                	mov    %eax,%ebx
  800efc:	85 c0                	test   %eax,%eax
  800efe:	0f 88 91 00 00 00    	js     800f95 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f04:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f07:	89 04 24             	mov    %eax,(%esp)
  800f0a:	e8 21 f5 ff ff       	call   800430 <fd2data>
  800f0f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800f16:	00 
  800f17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f22:	00 
  800f23:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f2e:	e8 d6 f2 ff ff       	call   800209 <sys_page_map>
  800f33:	89 c3                	mov    %eax,%ebx
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 4c                	js     800f85 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800f39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f42:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f47:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800f4e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f57:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f5c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800f63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f66:	89 04 24             	mov    %eax,(%esp)
  800f69:	e8 b2 f4 ff ff       	call   800420 <fd2num>
  800f6e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800f70:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f73:	89 04 24             	mov    %eax,(%esp)
  800f76:	e8 a5 f4 ff ff       	call   800420 <fd2num>
  800f7b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800f7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f83:	eb 36                	jmp    800fbb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800f85:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f90:	e8 c7 f2 ff ff       	call   80025c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800f95:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa3:	e8 b4 f2 ff ff       	call   80025c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  800fa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800faf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fb6:	e8 a1 f2 ff ff       	call   80025c <sys_page_unmap>
    err:
	return r;
}
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	83 c4 3c             	add    $0x3c,%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	89 04 24             	mov    %eax,(%esp)
  800fd8:	e8 c1 f4 ff ff       	call   80049e <fd_lookup>
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 15                	js     800ff6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe4:	89 04 24             	mov    %eax,(%esp)
  800fe7:	e8 44 f4 ff ff       	call   800430 <fd2data>
	return _pipeisclosed(fd, p);
  800fec:	89 c2                	mov    %eax,%edx
  800fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff1:	e8 15 fd ff ff       	call   800d0b <_pipeisclosed>
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ffb:	b8 00 00 00 00       	mov    $0x0,%eax
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801008:	c7 44 24 04 54 20 80 	movl   $0x802054,0x4(%esp)
  80100f:	00 
  801010:	8b 45 0c             	mov    0xc(%ebp),%eax
  801013:	89 04 24             	mov    %eax,(%esp)
  801016:	e8 20 08 00 00       	call   80183b <strcpy>
	return 0;
}
  80101b:	b8 00 00 00 00       	mov    $0x0,%eax
  801020:	c9                   	leave  
  801021:	c3                   	ret    

00801022 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
  801028:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80102e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801033:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801039:	eb 30                	jmp    80106b <devcons_write+0x49>
		m = n - tot;
  80103b:	8b 75 10             	mov    0x10(%ebp),%esi
  80103e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801040:	83 fe 7f             	cmp    $0x7f,%esi
  801043:	76 05                	jbe    80104a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801045:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80104a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80104e:	03 45 0c             	add    0xc(%ebp),%eax
  801051:	89 44 24 04          	mov    %eax,0x4(%esp)
  801055:	89 3c 24             	mov    %edi,(%esp)
  801058:	e8 57 09 00 00       	call   8019b4 <memmove>
		sys_cputs(buf, m);
  80105d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801061:	89 3c 24             	mov    %edi,(%esp)
  801064:	e8 7f f0 ff ff       	call   8000e8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801069:	01 f3                	add    %esi,%ebx
  80106b:	89 d8                	mov    %ebx,%eax
  80106d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801070:	72 c9                	jb     80103b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801072:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801083:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801087:	75 07                	jne    801090 <devcons_read+0x13>
  801089:	eb 25                	jmp    8010b0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80108b:	e8 06 f1 ff ff       	call   800196 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801090:	e8 71 f0 ff ff       	call   800106 <sys_cgetc>
  801095:	85 c0                	test   %eax,%eax
  801097:	74 f2                	je     80108b <devcons_read+0xe>
  801099:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80109b:	85 c0                	test   %eax,%eax
  80109d:	78 1d                	js     8010bc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80109f:	83 f8 04             	cmp    $0x4,%eax
  8010a2:	74 13                	je     8010b7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8010a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a7:	88 10                	mov    %dl,(%eax)
	return 1;
  8010a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ae:	eb 0c                	jmp    8010bc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8010b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b5:	eb 05                	jmp    8010bc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8010b7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8010ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d1:	00 
  8010d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010d5:	89 04 24             	mov    %eax,(%esp)
  8010d8:	e8 0b f0 ff ff       	call   8000e8 <sys_cputs>
}
  8010dd:	c9                   	leave  
  8010de:	c3                   	ret    

008010df <getchar>:

int
getchar(void)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8010e5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010ec:	00 
  8010ed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010fb:	e8 3a f6 ff ff       	call   80073a <read>
	if (r < 0)
  801100:	85 c0                	test   %eax,%eax
  801102:	78 0f                	js     801113 <getchar+0x34>
		return r;
	if (r < 1)
  801104:	85 c0                	test   %eax,%eax
  801106:	7e 06                	jle    80110e <getchar+0x2f>
		return -E_EOF;
	return c;
  801108:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80110c:	eb 05                	jmp    801113 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80110e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801113:	c9                   	leave  
  801114:	c3                   	ret    

00801115 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80111b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80111e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801122:	8b 45 08             	mov    0x8(%ebp),%eax
  801125:	89 04 24             	mov    %eax,(%esp)
  801128:	e8 71 f3 ff ff       	call   80049e <fd_lookup>
  80112d:	85 c0                	test   %eax,%eax
  80112f:	78 11                	js     801142 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801131:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801134:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80113a:	39 10                	cmp    %edx,(%eax)
  80113c:	0f 94 c0             	sete   %al
  80113f:	0f b6 c0             	movzbl %al,%eax
}
  801142:	c9                   	leave  
  801143:	c3                   	ret    

00801144 <opencons>:

int
opencons(void)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80114a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114d:	89 04 24             	mov    %eax,(%esp)
  801150:	e8 f6 f2 ff ff       	call   80044b <fd_alloc>
  801155:	85 c0                	test   %eax,%eax
  801157:	78 3c                	js     801195 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801159:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801160:	00 
  801161:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801164:	89 44 24 04          	mov    %eax,0x4(%esp)
  801168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116f:	e8 41 f0 ff ff       	call   8001b5 <sys_page_alloc>
  801174:	85 c0                	test   %eax,%eax
  801176:	78 1d                	js     801195 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801178:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801181:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801183:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801186:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80118d:	89 04 24             	mov    %eax,(%esp)
  801190:	e8 8b f2 ff ff       	call   800420 <fd2num>
}
  801195:	c9                   	leave  
  801196:	c3                   	ret    
	...

00801198 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8011a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011a3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8011a9:	e8 c9 ef ff ff       	call   800177 <sys_getenvid>
  8011ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c4:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  8011cb:	e8 c0 00 00 00       	call   801290 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d7:	89 04 24             	mov    %eax,(%esp)
  8011da:	e8 50 00 00 00       	call   80122f <vcprintf>
	cprintf("\n");
  8011df:	c7 04 24 4d 20 80 00 	movl   $0x80204d,(%esp)
  8011e6:	e8 a5 00 00 00       	call   801290 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011eb:	cc                   	int3   
  8011ec:	eb fd                	jmp    8011eb <_panic+0x53>
	...

008011f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 14             	sub    $0x14,%esp
  8011f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011fa:	8b 03                	mov    (%ebx),%eax
  8011fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801203:	40                   	inc    %eax
  801204:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801206:	3d ff 00 00 00       	cmp    $0xff,%eax
  80120b:	75 19                	jne    801226 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80120d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801214:	00 
  801215:	8d 43 08             	lea    0x8(%ebx),%eax
  801218:	89 04 24             	mov    %eax,(%esp)
  80121b:	e8 c8 ee ff ff       	call   8000e8 <sys_cputs>
		b->idx = 0;
  801220:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801226:	ff 43 04             	incl   0x4(%ebx)
}
  801229:	83 c4 14             	add    $0x14,%esp
  80122c:	5b                   	pop    %ebx
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    

0080122f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801238:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80123f:	00 00 00 
	b.cnt = 0;
  801242:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801249:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80124c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	89 44 24 08          	mov    %eax,0x8(%esp)
  80125a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801260:	89 44 24 04          	mov    %eax,0x4(%esp)
  801264:	c7 04 24 f0 11 80 00 	movl   $0x8011f0,(%esp)
  80126b:	e8 82 01 00 00       	call   8013f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801270:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801276:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801280:	89 04 24             	mov    %eax,(%esp)
  801283:	e8 60 ee ff ff       	call   8000e8 <sys_cputs>

	return b.cnt;
}
  801288:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80128e:	c9                   	leave  
  80128f:	c3                   	ret    

00801290 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801296:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129d:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a0:	89 04 24             	mov    %eax,(%esp)
  8012a3:	e8 87 ff ff ff       	call   80122f <vcprintf>
	va_end(ap);

	return cnt;
}
  8012a8:	c9                   	leave  
  8012a9:	c3                   	ret    
	...

008012ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 3c             	sub    $0x3c,%esp
  8012b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012b8:	89 d7                	mov    %edx,%edi
  8012ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8012c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8012c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	75 08                	jne    8012d8 <printnum+0x2c>
  8012d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8012d6:	77 57                	ja     80132f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012dc:	4b                   	dec    %ebx
  8012dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8012e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8012ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012f7:	00 
  8012f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012fb:	89 04 24             	mov    %eax,(%esp)
  8012fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801301:	89 44 24 04          	mov    %eax,0x4(%esp)
  801305:	e8 b2 09 00 00       	call   801cbc <__udivdi3>
  80130a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80130e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	89 54 24 04          	mov    %edx,0x4(%esp)
  801319:	89 fa                	mov    %edi,%edx
  80131b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80131e:	e8 89 ff ff ff       	call   8012ac <printnum>
  801323:	eb 0f                	jmp    801334 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801325:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801329:	89 34 24             	mov    %esi,(%esp)
  80132c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80132f:	4b                   	dec    %ebx
  801330:	85 db                	test   %ebx,%ebx
  801332:	7f f1                	jg     801325 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801338:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80133c:	8b 45 10             	mov    0x10(%ebp),%eax
  80133f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801343:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80134a:	00 
  80134b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80134e:	89 04 24             	mov    %eax,(%esp)
  801351:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	e8 7f 0a 00 00       	call   801ddc <__umoddi3>
  80135d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801361:	0f be 80 83 20 80 00 	movsbl 0x802083(%eax),%eax
  801368:	89 04 24             	mov    %eax,(%esp)
  80136b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80136e:	83 c4 3c             	add    $0x3c,%esp
  801371:	5b                   	pop    %ebx
  801372:	5e                   	pop    %esi
  801373:	5f                   	pop    %edi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    

00801376 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801379:	83 fa 01             	cmp    $0x1,%edx
  80137c:	7e 0e                	jle    80138c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80137e:	8b 10                	mov    (%eax),%edx
  801380:	8d 4a 08             	lea    0x8(%edx),%ecx
  801383:	89 08                	mov    %ecx,(%eax)
  801385:	8b 02                	mov    (%edx),%eax
  801387:	8b 52 04             	mov    0x4(%edx),%edx
  80138a:	eb 22                	jmp    8013ae <getuint+0x38>
	else if (lflag)
  80138c:	85 d2                	test   %edx,%edx
  80138e:	74 10                	je     8013a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801390:	8b 10                	mov    (%eax),%edx
  801392:	8d 4a 04             	lea    0x4(%edx),%ecx
  801395:	89 08                	mov    %ecx,(%eax)
  801397:	8b 02                	mov    (%edx),%eax
  801399:	ba 00 00 00 00       	mov    $0x0,%edx
  80139e:	eb 0e                	jmp    8013ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8013a0:	8b 10                	mov    (%eax),%edx
  8013a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013a5:	89 08                	mov    %ecx,(%eax)
  8013a7:	8b 02                	mov    (%edx),%eax
  8013a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8013b6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8013b9:	8b 10                	mov    (%eax),%edx
  8013bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8013be:	73 08                	jae    8013c8 <sprintputch+0x18>
		*b->buf++ = ch;
  8013c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c3:	88 0a                	mov    %cl,(%edx)
  8013c5:	42                   	inc    %edx
  8013c6:	89 10                	mov    %edx,(%eax)
}
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8013d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8013da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e8:	89 04 24             	mov    %eax,(%esp)
  8013eb:	e8 02 00 00 00       	call   8013f2 <vprintfmt>
	va_end(ap);
}
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    

008013f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	57                   	push   %edi
  8013f6:	56                   	push   %esi
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 4c             	sub    $0x4c,%esp
  8013fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013fe:	8b 75 10             	mov    0x10(%ebp),%esi
  801401:	eb 12                	jmp    801415 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801403:	85 c0                	test   %eax,%eax
  801405:	0f 84 6b 03 00 00    	je     801776 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80140b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80140f:	89 04 24             	mov    %eax,(%esp)
  801412:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801415:	0f b6 06             	movzbl (%esi),%eax
  801418:	46                   	inc    %esi
  801419:	83 f8 25             	cmp    $0x25,%eax
  80141c:	75 e5                	jne    801403 <vprintfmt+0x11>
  80141e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801422:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801429:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80142e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801435:	b9 00 00 00 00       	mov    $0x0,%ecx
  80143a:	eb 26                	jmp    801462 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80143c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80143f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801443:	eb 1d                	jmp    801462 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801445:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801448:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80144c:	eb 14                	jmp    801462 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80144e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801451:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801458:	eb 08                	jmp    801462 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80145a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80145d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801462:	0f b6 06             	movzbl (%esi),%eax
  801465:	8d 56 01             	lea    0x1(%esi),%edx
  801468:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80146b:	8a 16                	mov    (%esi),%dl
  80146d:	83 ea 23             	sub    $0x23,%edx
  801470:	80 fa 55             	cmp    $0x55,%dl
  801473:	0f 87 e1 02 00 00    	ja     80175a <vprintfmt+0x368>
  801479:	0f b6 d2             	movzbl %dl,%edx
  80147c:	ff 24 95 c0 21 80 00 	jmp    *0x8021c0(,%edx,4)
  801483:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801486:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80148b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80148e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801492:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801495:	8d 50 d0             	lea    -0x30(%eax),%edx
  801498:	83 fa 09             	cmp    $0x9,%edx
  80149b:	77 2a                	ja     8014c7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80149d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80149e:	eb eb                	jmp    80148b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8014a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a3:	8d 50 04             	lea    0x4(%eax),%edx
  8014a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8014a9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8014ae:	eb 17                	jmp    8014c7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8014b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014b4:	78 98                	js     80144e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8014b9:	eb a7                	jmp    801462 <vprintfmt+0x70>
  8014bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8014be:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8014c5:	eb 9b                	jmp    801462 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8014c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8014cb:	79 95                	jns    801462 <vprintfmt+0x70>
  8014cd:	eb 8b                	jmp    80145a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8014cf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8014d3:	eb 8d                	jmp    801462 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8014d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d8:	8d 50 04             	lea    0x4(%eax),%edx
  8014db:	89 55 14             	mov    %edx,0x14(%ebp)
  8014de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014e2:	8b 00                	mov    (%eax),%eax
  8014e4:	89 04 24             	mov    %eax,(%esp)
  8014e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8014ed:	e9 23 ff ff ff       	jmp    801415 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8014f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f5:	8d 50 04             	lea    0x4(%eax),%edx
  8014f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8014fb:	8b 00                	mov    (%eax),%eax
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	79 02                	jns    801503 <vprintfmt+0x111>
  801501:	f7 d8                	neg    %eax
  801503:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801505:	83 f8 0f             	cmp    $0xf,%eax
  801508:	7f 0b                	jg     801515 <vprintfmt+0x123>
  80150a:	8b 04 85 20 23 80 00 	mov    0x802320(,%eax,4),%eax
  801511:	85 c0                	test   %eax,%eax
  801513:	75 23                	jne    801538 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801515:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801519:	c7 44 24 08 9b 20 80 	movl   $0x80209b,0x8(%esp)
  801520:	00 
  801521:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801525:	8b 45 08             	mov    0x8(%ebp),%eax
  801528:	89 04 24             	mov    %eax,(%esp)
  80152b:	e8 9a fe ff ff       	call   8013ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801530:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801533:	e9 dd fe ff ff       	jmp    801415 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801538:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80153c:	c7 44 24 08 26 20 80 	movl   $0x802026,0x8(%esp)
  801543:	00 
  801544:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801548:	8b 55 08             	mov    0x8(%ebp),%edx
  80154b:	89 14 24             	mov    %edx,(%esp)
  80154e:	e8 77 fe ff ff       	call   8013ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801553:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801556:	e9 ba fe ff ff       	jmp    801415 <vprintfmt+0x23>
  80155b:	89 f9                	mov    %edi,%ecx
  80155d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801560:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801563:	8b 45 14             	mov    0x14(%ebp),%eax
  801566:	8d 50 04             	lea    0x4(%eax),%edx
  801569:	89 55 14             	mov    %edx,0x14(%ebp)
  80156c:	8b 30                	mov    (%eax),%esi
  80156e:	85 f6                	test   %esi,%esi
  801570:	75 05                	jne    801577 <vprintfmt+0x185>
				p = "(null)";
  801572:	be 94 20 80 00       	mov    $0x802094,%esi
			if (width > 0 && padc != '-')
  801577:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80157b:	0f 8e 84 00 00 00    	jle    801605 <vprintfmt+0x213>
  801581:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801585:	74 7e                	je     801605 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801587:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80158b:	89 34 24             	mov    %esi,(%esp)
  80158e:	e8 8b 02 00 00       	call   80181e <strnlen>
  801593:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801596:	29 c2                	sub    %eax,%edx
  801598:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80159b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80159f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8015a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8015a5:	89 de                	mov    %ebx,%esi
  8015a7:	89 d3                	mov    %edx,%ebx
  8015a9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8015ab:	eb 0b                	jmp    8015b8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8015ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b1:	89 3c 24             	mov    %edi,(%esp)
  8015b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8015b7:	4b                   	dec    %ebx
  8015b8:	85 db                	test   %ebx,%ebx
  8015ba:	7f f1                	jg     8015ad <vprintfmt+0x1bb>
  8015bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8015bf:	89 f3                	mov    %esi,%ebx
  8015c1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8015c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	79 05                	jns    8015d0 <vprintfmt+0x1de>
  8015cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015d3:	29 c2                	sub    %eax,%edx
  8015d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015d8:	eb 2b                	jmp    801605 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8015da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015de:	74 18                	je     8015f8 <vprintfmt+0x206>
  8015e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8015e3:	83 fa 5e             	cmp    $0x5e,%edx
  8015e6:	76 10                	jbe    8015f8 <vprintfmt+0x206>
					putch('?', putdat);
  8015e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015f3:	ff 55 08             	call   *0x8(%ebp)
  8015f6:	eb 0a                	jmp    801602 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8015f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015fc:	89 04 24             	mov    %eax,(%esp)
  8015ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801602:	ff 4d e4             	decl   -0x1c(%ebp)
  801605:	0f be 06             	movsbl (%esi),%eax
  801608:	46                   	inc    %esi
  801609:	85 c0                	test   %eax,%eax
  80160b:	74 21                	je     80162e <vprintfmt+0x23c>
  80160d:	85 ff                	test   %edi,%edi
  80160f:	78 c9                	js     8015da <vprintfmt+0x1e8>
  801611:	4f                   	dec    %edi
  801612:	79 c6                	jns    8015da <vprintfmt+0x1e8>
  801614:	8b 7d 08             	mov    0x8(%ebp),%edi
  801617:	89 de                	mov    %ebx,%esi
  801619:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80161c:	eb 18                	jmp    801636 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80161e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801622:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801629:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80162b:	4b                   	dec    %ebx
  80162c:	eb 08                	jmp    801636 <vprintfmt+0x244>
  80162e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801631:	89 de                	mov    %ebx,%esi
  801633:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801636:	85 db                	test   %ebx,%ebx
  801638:	7f e4                	jg     80161e <vprintfmt+0x22c>
  80163a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80163d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80163f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801642:	e9 ce fd ff ff       	jmp    801415 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801647:	83 f9 01             	cmp    $0x1,%ecx
  80164a:	7e 10                	jle    80165c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80164c:	8b 45 14             	mov    0x14(%ebp),%eax
  80164f:	8d 50 08             	lea    0x8(%eax),%edx
  801652:	89 55 14             	mov    %edx,0x14(%ebp)
  801655:	8b 30                	mov    (%eax),%esi
  801657:	8b 78 04             	mov    0x4(%eax),%edi
  80165a:	eb 26                	jmp    801682 <vprintfmt+0x290>
	else if (lflag)
  80165c:	85 c9                	test   %ecx,%ecx
  80165e:	74 12                	je     801672 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801660:	8b 45 14             	mov    0x14(%ebp),%eax
  801663:	8d 50 04             	lea    0x4(%eax),%edx
  801666:	89 55 14             	mov    %edx,0x14(%ebp)
  801669:	8b 30                	mov    (%eax),%esi
  80166b:	89 f7                	mov    %esi,%edi
  80166d:	c1 ff 1f             	sar    $0x1f,%edi
  801670:	eb 10                	jmp    801682 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801672:	8b 45 14             	mov    0x14(%ebp),%eax
  801675:	8d 50 04             	lea    0x4(%eax),%edx
  801678:	89 55 14             	mov    %edx,0x14(%ebp)
  80167b:	8b 30                	mov    (%eax),%esi
  80167d:	89 f7                	mov    %esi,%edi
  80167f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801682:	85 ff                	test   %edi,%edi
  801684:	78 0a                	js     801690 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801686:	b8 0a 00 00 00       	mov    $0xa,%eax
  80168b:	e9 8c 00 00 00       	jmp    80171c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801694:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80169b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80169e:	f7 de                	neg    %esi
  8016a0:	83 d7 00             	adc    $0x0,%edi
  8016a3:	f7 df                	neg    %edi
			}
			base = 10;
  8016a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016aa:	eb 70                	jmp    80171c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8016ac:	89 ca                	mov    %ecx,%edx
  8016ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8016b1:	e8 c0 fc ff ff       	call   801376 <getuint>
  8016b6:	89 c6                	mov    %eax,%esi
  8016b8:	89 d7                	mov    %edx,%edi
			base = 10;
  8016ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8016bf:	eb 5b                	jmp    80171c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8016c1:	89 ca                	mov    %ecx,%edx
  8016c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8016c6:	e8 ab fc ff ff       	call   801376 <getuint>
  8016cb:	89 c6                	mov    %eax,%esi
  8016cd:	89 d7                	mov    %edx,%edi
			base = 8;
  8016cf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8016d4:	eb 46                	jmp    80171c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8016d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016da:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8016e1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8016e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8016ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8016f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f5:	8d 50 04             	lea    0x4(%eax),%edx
  8016f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8016fb:	8b 30                	mov    (%eax),%esi
  8016fd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801702:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801707:	eb 13                	jmp    80171c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801709:	89 ca                	mov    %ecx,%edx
  80170b:	8d 45 14             	lea    0x14(%ebp),%eax
  80170e:	e8 63 fc ff ff       	call   801376 <getuint>
  801713:	89 c6                	mov    %eax,%esi
  801715:	89 d7                	mov    %edx,%edi
			base = 16;
  801717:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80171c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801720:	89 54 24 10          	mov    %edx,0x10(%esp)
  801724:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801727:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80172b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80172f:	89 34 24             	mov    %esi,(%esp)
  801732:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801736:	89 da                	mov    %ebx,%edx
  801738:	8b 45 08             	mov    0x8(%ebp),%eax
  80173b:	e8 6c fb ff ff       	call   8012ac <printnum>
			break;
  801740:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801743:	e9 cd fc ff ff       	jmp    801415 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801748:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174c:	89 04 24             	mov    %eax,(%esp)
  80174f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801752:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801755:	e9 bb fc ff ff       	jmp    801415 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80175a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80175e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801765:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801768:	eb 01                	jmp    80176b <vprintfmt+0x379>
  80176a:	4e                   	dec    %esi
  80176b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80176f:	75 f9                	jne    80176a <vprintfmt+0x378>
  801771:	e9 9f fc ff ff       	jmp    801415 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801776:	83 c4 4c             	add    $0x4c,%esp
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5f                   	pop    %edi
  80177c:	5d                   	pop    %ebp
  80177d:	c3                   	ret    

0080177e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	83 ec 28             	sub    $0x28,%esp
  801784:	8b 45 08             	mov    0x8(%ebp),%eax
  801787:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80178a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80178d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801791:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801794:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80179b:	85 c0                	test   %eax,%eax
  80179d:	74 30                	je     8017cf <vsnprintf+0x51>
  80179f:	85 d2                	test   %edx,%edx
  8017a1:	7e 33                	jle    8017d6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8017a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b8:	c7 04 24 b0 13 80 00 	movl   $0x8013b0,(%esp)
  8017bf:	e8 2e fc ff ff       	call   8013f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8017c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8017ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017cd:	eb 0c                	jmp    8017db <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8017cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d4:	eb 05                	jmp    8017db <vsnprintf+0x5d>
  8017d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    

008017dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8017e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8017e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	89 04 24             	mov    %eax,(%esp)
  8017fe:	e8 7b ff ff ff       	call   80177e <vsnprintf>
	va_end(ap);

	return rc;
}
  801803:	c9                   	leave  
  801804:	c3                   	ret    
  801805:	00 00                	add    %al,(%eax)
	...

00801808 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80180e:	b8 00 00 00 00       	mov    $0x0,%eax
  801813:	eb 01                	jmp    801816 <strlen+0xe>
		n++;
  801815:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801816:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80181a:	75 f9                	jne    801815 <strlen+0xd>
		n++;
	return n;
}
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801824:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
  80182c:	eb 01                	jmp    80182f <strnlen+0x11>
		n++;
  80182e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80182f:	39 d0                	cmp    %edx,%eax
  801831:	74 06                	je     801839 <strnlen+0x1b>
  801833:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801837:	75 f5                	jne    80182e <strnlen+0x10>
		n++;
	return n;
}
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    

0080183b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	53                   	push   %ebx
  80183f:	8b 45 08             	mov    0x8(%ebp),%eax
  801842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801845:	ba 00 00 00 00       	mov    $0x0,%edx
  80184a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80184d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801850:	42                   	inc    %edx
  801851:	84 c9                	test   %cl,%cl
  801853:	75 f5                	jne    80184a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801855:	5b                   	pop    %ebx
  801856:	5d                   	pop    %ebp
  801857:	c3                   	ret    

00801858 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	53                   	push   %ebx
  80185c:	83 ec 08             	sub    $0x8,%esp
  80185f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801862:	89 1c 24             	mov    %ebx,(%esp)
  801865:	e8 9e ff ff ff       	call   801808 <strlen>
	strcpy(dst + len, src);
  80186a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80186d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801871:	01 d8                	add    %ebx,%eax
  801873:	89 04 24             	mov    %eax,(%esp)
  801876:	e8 c0 ff ff ff       	call   80183b <strcpy>
	return dst;
}
  80187b:	89 d8                	mov    %ebx,%eax
  80187d:	83 c4 08             	add    $0x8,%esp
  801880:	5b                   	pop    %ebx
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	56                   	push   %esi
  801887:	53                   	push   %ebx
  801888:	8b 45 08             	mov    0x8(%ebp),%eax
  80188b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801891:	b9 00 00 00 00       	mov    $0x0,%ecx
  801896:	eb 0c                	jmp    8018a4 <strncpy+0x21>
		*dst++ = *src;
  801898:	8a 1a                	mov    (%edx),%bl
  80189a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80189d:	80 3a 01             	cmpb   $0x1,(%edx)
  8018a0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8018a3:	41                   	inc    %ecx
  8018a4:	39 f1                	cmp    %esi,%ecx
  8018a6:	75 f0                	jne    801898 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8018a8:	5b                   	pop    %ebx
  8018a9:	5e                   	pop    %esi
  8018aa:	5d                   	pop    %ebp
  8018ab:	c3                   	ret    

008018ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8018b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018ba:	85 d2                	test   %edx,%edx
  8018bc:	75 0a                	jne    8018c8 <strlcpy+0x1c>
  8018be:	89 f0                	mov    %esi,%eax
  8018c0:	eb 1a                	jmp    8018dc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8018c2:	88 18                	mov    %bl,(%eax)
  8018c4:	40                   	inc    %eax
  8018c5:	41                   	inc    %ecx
  8018c6:	eb 02                	jmp    8018ca <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018c8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8018ca:	4a                   	dec    %edx
  8018cb:	74 0a                	je     8018d7 <strlcpy+0x2b>
  8018cd:	8a 19                	mov    (%ecx),%bl
  8018cf:	84 db                	test   %bl,%bl
  8018d1:	75 ef                	jne    8018c2 <strlcpy+0x16>
  8018d3:	89 c2                	mov    %eax,%edx
  8018d5:	eb 02                	jmp    8018d9 <strlcpy+0x2d>
  8018d7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8018d9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8018dc:	29 f0                	sub    %esi,%eax
}
  8018de:	5b                   	pop    %ebx
  8018df:	5e                   	pop    %esi
  8018e0:	5d                   	pop    %ebp
  8018e1:	c3                   	ret    

008018e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018eb:	eb 02                	jmp    8018ef <strcmp+0xd>
		p++, q++;
  8018ed:	41                   	inc    %ecx
  8018ee:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8018ef:	8a 01                	mov    (%ecx),%al
  8018f1:	84 c0                	test   %al,%al
  8018f3:	74 04                	je     8018f9 <strcmp+0x17>
  8018f5:	3a 02                	cmp    (%edx),%al
  8018f7:	74 f4                	je     8018ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018f9:	0f b6 c0             	movzbl %al,%eax
  8018fc:	0f b6 12             	movzbl (%edx),%edx
  8018ff:	29 d0                	sub    %edx,%eax
}
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	8b 45 08             	mov    0x8(%ebp),%eax
  80190a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80190d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801910:	eb 03                	jmp    801915 <strncmp+0x12>
		n--, p++, q++;
  801912:	4a                   	dec    %edx
  801913:	40                   	inc    %eax
  801914:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801915:	85 d2                	test   %edx,%edx
  801917:	74 14                	je     80192d <strncmp+0x2a>
  801919:	8a 18                	mov    (%eax),%bl
  80191b:	84 db                	test   %bl,%bl
  80191d:	74 04                	je     801923 <strncmp+0x20>
  80191f:	3a 19                	cmp    (%ecx),%bl
  801921:	74 ef                	je     801912 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801923:	0f b6 00             	movzbl (%eax),%eax
  801926:	0f b6 11             	movzbl (%ecx),%edx
  801929:	29 d0                	sub    %edx,%eax
  80192b:	eb 05                	jmp    801932 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801932:	5b                   	pop    %ebx
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	8b 45 08             	mov    0x8(%ebp),%eax
  80193b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80193e:	eb 05                	jmp    801945 <strchr+0x10>
		if (*s == c)
  801940:	38 ca                	cmp    %cl,%dl
  801942:	74 0c                	je     801950 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801944:	40                   	inc    %eax
  801945:	8a 10                	mov    (%eax),%dl
  801947:	84 d2                	test   %dl,%dl
  801949:	75 f5                	jne    801940 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	8b 45 08             	mov    0x8(%ebp),%eax
  801958:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80195b:	eb 05                	jmp    801962 <strfind+0x10>
		if (*s == c)
  80195d:	38 ca                	cmp    %cl,%dl
  80195f:	74 07                	je     801968 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801961:	40                   	inc    %eax
  801962:	8a 10                	mov    (%eax),%dl
  801964:	84 d2                	test   %dl,%dl
  801966:	75 f5                	jne    80195d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801968:	5d                   	pop    %ebp
  801969:	c3                   	ret    

0080196a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	57                   	push   %edi
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	8b 7d 08             	mov    0x8(%ebp),%edi
  801973:	8b 45 0c             	mov    0xc(%ebp),%eax
  801976:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801979:	85 c9                	test   %ecx,%ecx
  80197b:	74 30                	je     8019ad <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80197d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801983:	75 25                	jne    8019aa <memset+0x40>
  801985:	f6 c1 03             	test   $0x3,%cl
  801988:	75 20                	jne    8019aa <memset+0x40>
		c &= 0xFF;
  80198a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80198d:	89 d3                	mov    %edx,%ebx
  80198f:	c1 e3 08             	shl    $0x8,%ebx
  801992:	89 d6                	mov    %edx,%esi
  801994:	c1 e6 18             	shl    $0x18,%esi
  801997:	89 d0                	mov    %edx,%eax
  801999:	c1 e0 10             	shl    $0x10,%eax
  80199c:	09 f0                	or     %esi,%eax
  80199e:	09 d0                	or     %edx,%eax
  8019a0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8019a2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8019a5:	fc                   	cld    
  8019a6:	f3 ab                	rep stos %eax,%es:(%edi)
  8019a8:	eb 03                	jmp    8019ad <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8019aa:	fc                   	cld    
  8019ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8019ad:	89 f8                	mov    %edi,%eax
  8019af:	5b                   	pop    %ebx
  8019b0:	5e                   	pop    %esi
  8019b1:	5f                   	pop    %edi
  8019b2:	5d                   	pop    %ebp
  8019b3:	c3                   	ret    

008019b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	57                   	push   %edi
  8019b8:	56                   	push   %esi
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019c2:	39 c6                	cmp    %eax,%esi
  8019c4:	73 34                	jae    8019fa <memmove+0x46>
  8019c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019c9:	39 d0                	cmp    %edx,%eax
  8019cb:	73 2d                	jae    8019fa <memmove+0x46>
		s += n;
		d += n;
  8019cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019d0:	f6 c2 03             	test   $0x3,%dl
  8019d3:	75 1b                	jne    8019f0 <memmove+0x3c>
  8019d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019db:	75 13                	jne    8019f0 <memmove+0x3c>
  8019dd:	f6 c1 03             	test   $0x3,%cl
  8019e0:	75 0e                	jne    8019f0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019e2:	83 ef 04             	sub    $0x4,%edi
  8019e5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019e8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8019eb:	fd                   	std    
  8019ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019ee:	eb 07                	jmp    8019f7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019f0:	4f                   	dec    %edi
  8019f1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8019f4:	fd                   	std    
  8019f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019f7:	fc                   	cld    
  8019f8:	eb 20                	jmp    801a1a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019fa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a00:	75 13                	jne    801a15 <memmove+0x61>
  801a02:	a8 03                	test   $0x3,%al
  801a04:	75 0f                	jne    801a15 <memmove+0x61>
  801a06:	f6 c1 03             	test   $0x3,%cl
  801a09:	75 0a                	jne    801a15 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a0b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a0e:	89 c7                	mov    %eax,%edi
  801a10:	fc                   	cld    
  801a11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a13:	eb 05                	jmp    801a1a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a15:	89 c7                	mov    %eax,%edi
  801a17:	fc                   	cld    
  801a18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a1a:	5e                   	pop    %esi
  801a1b:	5f                   	pop    %edi
  801a1c:	5d                   	pop    %ebp
  801a1d:	c3                   	ret    

00801a1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a24:	8b 45 10             	mov    0x10(%ebp),%eax
  801a27:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a32:	8b 45 08             	mov    0x8(%ebp),%eax
  801a35:	89 04 24             	mov    %eax,(%esp)
  801a38:	e8 77 ff ff ff       	call   8019b4 <memmove>
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	57                   	push   %edi
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a48:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a53:	eb 16                	jmp    801a6b <memcmp+0x2c>
		if (*s1 != *s2)
  801a55:	8a 04 17             	mov    (%edi,%edx,1),%al
  801a58:	42                   	inc    %edx
  801a59:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801a5d:	38 c8                	cmp    %cl,%al
  801a5f:	74 0a                	je     801a6b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801a61:	0f b6 c0             	movzbl %al,%eax
  801a64:	0f b6 c9             	movzbl %cl,%ecx
  801a67:	29 c8                	sub    %ecx,%eax
  801a69:	eb 09                	jmp    801a74 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a6b:	39 da                	cmp    %ebx,%edx
  801a6d:	75 e6                	jne    801a55 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801a6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5f                   	pop    %edi
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a82:	89 c2                	mov    %eax,%edx
  801a84:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a87:	eb 05                	jmp    801a8e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a89:	38 08                	cmp    %cl,(%eax)
  801a8b:	74 05                	je     801a92 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a8d:	40                   	inc    %eax
  801a8e:	39 d0                	cmp    %edx,%eax
  801a90:	72 f7                	jb     801a89 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    

00801a94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	57                   	push   %edi
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  801a9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801aa0:	eb 01                	jmp    801aa3 <strtol+0xf>
		s++;
  801aa2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801aa3:	8a 02                	mov    (%edx),%al
  801aa5:	3c 20                	cmp    $0x20,%al
  801aa7:	74 f9                	je     801aa2 <strtol+0xe>
  801aa9:	3c 09                	cmp    $0x9,%al
  801aab:	74 f5                	je     801aa2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801aad:	3c 2b                	cmp    $0x2b,%al
  801aaf:	75 08                	jne    801ab9 <strtol+0x25>
		s++;
  801ab1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ab2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab7:	eb 13                	jmp    801acc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ab9:	3c 2d                	cmp    $0x2d,%al
  801abb:	75 0a                	jne    801ac7 <strtol+0x33>
		s++, neg = 1;
  801abd:	8d 52 01             	lea    0x1(%edx),%edx
  801ac0:	bf 01 00 00 00       	mov    $0x1,%edi
  801ac5:	eb 05                	jmp    801acc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ac7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801acc:	85 db                	test   %ebx,%ebx
  801ace:	74 05                	je     801ad5 <strtol+0x41>
  801ad0:	83 fb 10             	cmp    $0x10,%ebx
  801ad3:	75 28                	jne    801afd <strtol+0x69>
  801ad5:	8a 02                	mov    (%edx),%al
  801ad7:	3c 30                	cmp    $0x30,%al
  801ad9:	75 10                	jne    801aeb <strtol+0x57>
  801adb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801adf:	75 0a                	jne    801aeb <strtol+0x57>
		s += 2, base = 16;
  801ae1:	83 c2 02             	add    $0x2,%edx
  801ae4:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ae9:	eb 12                	jmp    801afd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801aeb:	85 db                	test   %ebx,%ebx
  801aed:	75 0e                	jne    801afd <strtol+0x69>
  801aef:	3c 30                	cmp    $0x30,%al
  801af1:	75 05                	jne    801af8 <strtol+0x64>
		s++, base = 8;
  801af3:	42                   	inc    %edx
  801af4:	b3 08                	mov    $0x8,%bl
  801af6:	eb 05                	jmp    801afd <strtol+0x69>
	else if (base == 0)
		base = 10;
  801af8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801afd:	b8 00 00 00 00       	mov    $0x0,%eax
  801b02:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b04:	8a 0a                	mov    (%edx),%cl
  801b06:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b09:	80 fb 09             	cmp    $0x9,%bl
  801b0c:	77 08                	ja     801b16 <strtol+0x82>
			dig = *s - '0';
  801b0e:	0f be c9             	movsbl %cl,%ecx
  801b11:	83 e9 30             	sub    $0x30,%ecx
  801b14:	eb 1e                	jmp    801b34 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b16:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b19:	80 fb 19             	cmp    $0x19,%bl
  801b1c:	77 08                	ja     801b26 <strtol+0x92>
			dig = *s - 'a' + 10;
  801b1e:	0f be c9             	movsbl %cl,%ecx
  801b21:	83 e9 57             	sub    $0x57,%ecx
  801b24:	eb 0e                	jmp    801b34 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b26:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b29:	80 fb 19             	cmp    $0x19,%bl
  801b2c:	77 12                	ja     801b40 <strtol+0xac>
			dig = *s - 'A' + 10;
  801b2e:	0f be c9             	movsbl %cl,%ecx
  801b31:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b34:	39 f1                	cmp    %esi,%ecx
  801b36:	7d 0c                	jge    801b44 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b38:	42                   	inc    %edx
  801b39:	0f af c6             	imul   %esi,%eax
  801b3c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801b3e:	eb c4                	jmp    801b04 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801b40:	89 c1                	mov    %eax,%ecx
  801b42:	eb 02                	jmp    801b46 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b44:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801b46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b4a:	74 05                	je     801b51 <strtol+0xbd>
		*endptr = (char *) s;
  801b4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b4f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801b51:	85 ff                	test   %edi,%edi
  801b53:	74 04                	je     801b59 <strtol+0xc5>
  801b55:	89 c8                	mov    %ecx,%eax
  801b57:	f7 d8                	neg    %eax
}
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    
	...

00801b60 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	57                   	push   %edi
  801b64:	56                   	push   %esi
  801b65:	53                   	push   %ebx
  801b66:	83 ec 1c             	sub    $0x1c,%esp
  801b69:	8b 75 08             	mov    0x8(%ebp),%esi
  801b6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b6f:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  801b72:	85 db                	test   %ebx,%ebx
  801b74:	75 05                	jne    801b7b <ipc_recv+0x1b>
		pg = (void *)UTOP;
  801b76:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  801b7b:	89 1c 24             	mov    %ebx,(%esp)
  801b7e:	e8 48 e8 ff ff       	call   8003cb <sys_ipc_recv>
  801b83:	85 c0                	test   %eax,%eax
  801b85:	79 16                	jns    801b9d <ipc_recv+0x3d>
		*from_env_store = 0;
  801b87:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  801b8d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  801b93:	89 1c 24             	mov    %ebx,(%esp)
  801b96:	e8 30 e8 ff ff       	call   8003cb <sys_ipc_recv>
  801b9b:	eb 24                	jmp    801bc1 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  801b9d:	85 f6                	test   %esi,%esi
  801b9f:	74 0a                	je     801bab <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801ba1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba6:	8b 40 74             	mov    0x74(%eax),%eax
  801ba9:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801bab:	85 ff                	test   %edi,%edi
  801bad:	74 0a                	je     801bb9 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801baf:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb4:	8b 40 78             	mov    0x78(%eax),%eax
  801bb7:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  801bb9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bbe:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bc1:	83 c4 1c             	add    $0x1c,%esp
  801bc4:	5b                   	pop    %ebx
  801bc5:	5e                   	pop    %esi
  801bc6:	5f                   	pop    %edi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	57                   	push   %edi
  801bcd:	56                   	push   %esi
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 1c             	sub    $0x1c,%esp
  801bd2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bd8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801bdb:	85 db                	test   %ebx,%ebx
  801bdd:	75 05                	jne    801be4 <ipc_send+0x1b>
		pg = (void *)-1;
  801bdf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801be4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801be8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	89 04 24             	mov    %eax,(%esp)
  801bf6:	e8 ad e7 ff ff       	call   8003a8 <sys_ipc_try_send>
		if (r == 0) {		
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	74 2c                	je     801c2b <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801bff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c02:	75 07                	jne    801c0b <ipc_send+0x42>
			sys_yield();
  801c04:	e8 8d e5 ff ff       	call   800196 <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  801c09:	eb d9                	jmp    801be4 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  801c0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0f:	c7 44 24 08 80 23 80 	movl   $0x802380,0x8(%esp)
  801c16:	00 
  801c17:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801c1e:	00 
  801c1f:	c7 04 24 8e 23 80 00 	movl   $0x80238e,(%esp)
  801c26:	e8 6d f5 ff ff       	call   801198 <_panic>
		}
	}
}
  801c2b:	83 c4 1c             	add    $0x1c,%esp
  801c2e:	5b                   	pop    %ebx
  801c2f:	5e                   	pop    %esi
  801c30:	5f                   	pop    %edi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	53                   	push   %ebx
  801c37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c3f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c46:	89 c2                	mov    %eax,%edx
  801c48:	c1 e2 07             	shl    $0x7,%edx
  801c4b:	29 ca                	sub    %ecx,%edx
  801c4d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c53:	8b 52 50             	mov    0x50(%edx),%edx
  801c56:	39 da                	cmp    %ebx,%edx
  801c58:	75 0f                	jne    801c69 <ipc_find_env+0x36>
			return envs[i].env_id;
  801c5a:	c1 e0 07             	shl    $0x7,%eax
  801c5d:	29 c8                	sub    %ecx,%eax
  801c5f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c64:	8b 40 40             	mov    0x40(%eax),%eax
  801c67:	eb 0c                	jmp    801c75 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c69:	40                   	inc    %eax
  801c6a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c6f:	75 ce                	jne    801c3f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c71:	66 b8 00 00          	mov    $0x0,%ax
}
  801c75:	5b                   	pop    %ebx
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    

00801c78 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c7e:	89 c2                	mov    %eax,%edx
  801c80:	c1 ea 16             	shr    $0x16,%edx
  801c83:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c8a:	f6 c2 01             	test   $0x1,%dl
  801c8d:	74 1e                	je     801cad <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c8f:	c1 e8 0c             	shr    $0xc,%eax
  801c92:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c99:	a8 01                	test   $0x1,%al
  801c9b:	74 17                	je     801cb4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c9d:	c1 e8 0c             	shr    $0xc,%eax
  801ca0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ca7:	ef 
  801ca8:	0f b7 c0             	movzwl %ax,%eax
  801cab:	eb 0c                	jmp    801cb9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801cad:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb2:	eb 05                	jmp    801cb9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801cb4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    
	...

00801cbc <__udivdi3>:
  801cbc:	55                   	push   %ebp
  801cbd:	57                   	push   %edi
  801cbe:	56                   	push   %esi
  801cbf:	83 ec 10             	sub    $0x10,%esp
  801cc2:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cc6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cca:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cce:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cd2:	89 cd                	mov    %ecx,%ebp
  801cd4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	75 2c                	jne    801d08 <__udivdi3+0x4c>
  801cdc:	39 f9                	cmp    %edi,%ecx
  801cde:	77 68                	ja     801d48 <__udivdi3+0x8c>
  801ce0:	85 c9                	test   %ecx,%ecx
  801ce2:	75 0b                	jne    801cef <__udivdi3+0x33>
  801ce4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce9:	31 d2                	xor    %edx,%edx
  801ceb:	f7 f1                	div    %ecx
  801ced:	89 c1                	mov    %eax,%ecx
  801cef:	31 d2                	xor    %edx,%edx
  801cf1:	89 f8                	mov    %edi,%eax
  801cf3:	f7 f1                	div    %ecx
  801cf5:	89 c7                	mov    %eax,%edi
  801cf7:	89 f0                	mov    %esi,%eax
  801cf9:	f7 f1                	div    %ecx
  801cfb:	89 c6                	mov    %eax,%esi
  801cfd:	89 f0                	mov    %esi,%eax
  801cff:	89 fa                	mov    %edi,%edx
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    
  801d08:	39 f8                	cmp    %edi,%eax
  801d0a:	77 2c                	ja     801d38 <__udivdi3+0x7c>
  801d0c:	0f bd f0             	bsr    %eax,%esi
  801d0f:	83 f6 1f             	xor    $0x1f,%esi
  801d12:	75 4c                	jne    801d60 <__udivdi3+0xa4>
  801d14:	39 f8                	cmp    %edi,%eax
  801d16:	bf 00 00 00 00       	mov    $0x0,%edi
  801d1b:	72 0a                	jb     801d27 <__udivdi3+0x6b>
  801d1d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d21:	0f 87 ad 00 00 00    	ja     801dd4 <__udivdi3+0x118>
  801d27:	be 01 00 00 00       	mov    $0x1,%esi
  801d2c:	89 f0                	mov    %esi,%eax
  801d2e:	89 fa                	mov    %edi,%edx
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	5e                   	pop    %esi
  801d34:	5f                   	pop    %edi
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    
  801d37:	90                   	nop
  801d38:	31 ff                	xor    %edi,%edi
  801d3a:	31 f6                	xor    %esi,%esi
  801d3c:	89 f0                	mov    %esi,%eax
  801d3e:	89 fa                	mov    %edi,%edx
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	5e                   	pop    %esi
  801d44:	5f                   	pop    %edi
  801d45:	5d                   	pop    %ebp
  801d46:	c3                   	ret    
  801d47:	90                   	nop
  801d48:	89 fa                	mov    %edi,%edx
  801d4a:	89 f0                	mov    %esi,%eax
  801d4c:	f7 f1                	div    %ecx
  801d4e:	89 c6                	mov    %eax,%esi
  801d50:	31 ff                	xor    %edi,%edi
  801d52:	89 f0                	mov    %esi,%eax
  801d54:	89 fa                	mov    %edi,%edx
  801d56:	83 c4 10             	add    $0x10,%esp
  801d59:	5e                   	pop    %esi
  801d5a:	5f                   	pop    %edi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    
  801d5d:	8d 76 00             	lea    0x0(%esi),%esi
  801d60:	89 f1                	mov    %esi,%ecx
  801d62:	d3 e0                	shl    %cl,%eax
  801d64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d68:	b8 20 00 00 00       	mov    $0x20,%eax
  801d6d:	29 f0                	sub    %esi,%eax
  801d6f:	89 ea                	mov    %ebp,%edx
  801d71:	88 c1                	mov    %al,%cl
  801d73:	d3 ea                	shr    %cl,%edx
  801d75:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d79:	09 ca                	or     %ecx,%edx
  801d7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d7f:	89 f1                	mov    %esi,%ecx
  801d81:	d3 e5                	shl    %cl,%ebp
  801d83:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d87:	89 fd                	mov    %edi,%ebp
  801d89:	88 c1                	mov    %al,%cl
  801d8b:	d3 ed                	shr    %cl,%ebp
  801d8d:	89 fa                	mov    %edi,%edx
  801d8f:	89 f1                	mov    %esi,%ecx
  801d91:	d3 e2                	shl    %cl,%edx
  801d93:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d97:	88 c1                	mov    %al,%cl
  801d99:	d3 ef                	shr    %cl,%edi
  801d9b:	09 d7                	or     %edx,%edi
  801d9d:	89 f8                	mov    %edi,%eax
  801d9f:	89 ea                	mov    %ebp,%edx
  801da1:	f7 74 24 08          	divl   0x8(%esp)
  801da5:	89 d1                	mov    %edx,%ecx
  801da7:	89 c7                	mov    %eax,%edi
  801da9:	f7 64 24 0c          	mull   0xc(%esp)
  801dad:	39 d1                	cmp    %edx,%ecx
  801daf:	72 17                	jb     801dc8 <__udivdi3+0x10c>
  801db1:	74 09                	je     801dbc <__udivdi3+0x100>
  801db3:	89 fe                	mov    %edi,%esi
  801db5:	31 ff                	xor    %edi,%edi
  801db7:	e9 41 ff ff ff       	jmp    801cfd <__udivdi3+0x41>
  801dbc:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dc0:	89 f1                	mov    %esi,%ecx
  801dc2:	d3 e2                	shl    %cl,%edx
  801dc4:	39 c2                	cmp    %eax,%edx
  801dc6:	73 eb                	jae    801db3 <__udivdi3+0xf7>
  801dc8:	8d 77 ff             	lea    -0x1(%edi),%esi
  801dcb:	31 ff                	xor    %edi,%edi
  801dcd:	e9 2b ff ff ff       	jmp    801cfd <__udivdi3+0x41>
  801dd2:	66 90                	xchg   %ax,%ax
  801dd4:	31 f6                	xor    %esi,%esi
  801dd6:	e9 22 ff ff ff       	jmp    801cfd <__udivdi3+0x41>
	...

00801ddc <__umoddi3>:
  801ddc:	55                   	push   %ebp
  801ddd:	57                   	push   %edi
  801dde:	56                   	push   %esi
  801ddf:	83 ec 20             	sub    $0x20,%esp
  801de2:	8b 44 24 30          	mov    0x30(%esp),%eax
  801de6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801dea:	89 44 24 14          	mov    %eax,0x14(%esp)
  801dee:	8b 74 24 34          	mov    0x34(%esp),%esi
  801df2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801df6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801dfa:	89 c7                	mov    %eax,%edi
  801dfc:	89 f2                	mov    %esi,%edx
  801dfe:	85 ed                	test   %ebp,%ebp
  801e00:	75 16                	jne    801e18 <__umoddi3+0x3c>
  801e02:	39 f1                	cmp    %esi,%ecx
  801e04:	0f 86 a6 00 00 00    	jbe    801eb0 <__umoddi3+0xd4>
  801e0a:	f7 f1                	div    %ecx
  801e0c:	89 d0                	mov    %edx,%eax
  801e0e:	31 d2                	xor    %edx,%edx
  801e10:	83 c4 20             	add    $0x20,%esp
  801e13:	5e                   	pop    %esi
  801e14:	5f                   	pop    %edi
  801e15:	5d                   	pop    %ebp
  801e16:	c3                   	ret    
  801e17:	90                   	nop
  801e18:	39 f5                	cmp    %esi,%ebp
  801e1a:	0f 87 ac 00 00 00    	ja     801ecc <__umoddi3+0xf0>
  801e20:	0f bd c5             	bsr    %ebp,%eax
  801e23:	83 f0 1f             	xor    $0x1f,%eax
  801e26:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e2a:	0f 84 a8 00 00 00    	je     801ed8 <__umoddi3+0xfc>
  801e30:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e34:	d3 e5                	shl    %cl,%ebp
  801e36:	bf 20 00 00 00       	mov    $0x20,%edi
  801e3b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e3f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	d3 e8                	shr    %cl,%eax
  801e47:	09 e8                	or     %ebp,%eax
  801e49:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e4d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e51:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e55:	d3 e0                	shl    %cl,%eax
  801e57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e5b:	89 f2                	mov    %esi,%edx
  801e5d:	d3 e2                	shl    %cl,%edx
  801e5f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e63:	d3 e0                	shl    %cl,%eax
  801e65:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e69:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e6d:	89 f9                	mov    %edi,%ecx
  801e6f:	d3 e8                	shr    %cl,%eax
  801e71:	09 d0                	or     %edx,%eax
  801e73:	d3 ee                	shr    %cl,%esi
  801e75:	89 f2                	mov    %esi,%edx
  801e77:	f7 74 24 18          	divl   0x18(%esp)
  801e7b:	89 d6                	mov    %edx,%esi
  801e7d:	f7 64 24 0c          	mull   0xc(%esp)
  801e81:	89 c5                	mov    %eax,%ebp
  801e83:	89 d1                	mov    %edx,%ecx
  801e85:	39 d6                	cmp    %edx,%esi
  801e87:	72 67                	jb     801ef0 <__umoddi3+0x114>
  801e89:	74 75                	je     801f00 <__umoddi3+0x124>
  801e8b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e8f:	29 e8                	sub    %ebp,%eax
  801e91:	19 ce                	sbb    %ecx,%esi
  801e93:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e97:	d3 e8                	shr    %cl,%eax
  801e99:	89 f2                	mov    %esi,%edx
  801e9b:	89 f9                	mov    %edi,%ecx
  801e9d:	d3 e2                	shl    %cl,%edx
  801e9f:	09 d0                	or     %edx,%eax
  801ea1:	89 f2                	mov    %esi,%edx
  801ea3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ea7:	d3 ea                	shr    %cl,%edx
  801ea9:	83 c4 20             	add    $0x20,%esp
  801eac:	5e                   	pop    %esi
  801ead:	5f                   	pop    %edi
  801eae:	5d                   	pop    %ebp
  801eaf:	c3                   	ret    
  801eb0:	85 c9                	test   %ecx,%ecx
  801eb2:	75 0b                	jne    801ebf <__umoddi3+0xe3>
  801eb4:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb9:	31 d2                	xor    %edx,%edx
  801ebb:	f7 f1                	div    %ecx
  801ebd:	89 c1                	mov    %eax,%ecx
  801ebf:	89 f0                	mov    %esi,%eax
  801ec1:	31 d2                	xor    %edx,%edx
  801ec3:	f7 f1                	div    %ecx
  801ec5:	89 f8                	mov    %edi,%eax
  801ec7:	e9 3e ff ff ff       	jmp    801e0a <__umoddi3+0x2e>
  801ecc:	89 f2                	mov    %esi,%edx
  801ece:	83 c4 20             	add    $0x20,%esp
  801ed1:	5e                   	pop    %esi
  801ed2:	5f                   	pop    %edi
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    
  801ed5:	8d 76 00             	lea    0x0(%esi),%esi
  801ed8:	39 f5                	cmp    %esi,%ebp
  801eda:	72 04                	jb     801ee0 <__umoddi3+0x104>
  801edc:	39 f9                	cmp    %edi,%ecx
  801ede:	77 06                	ja     801ee6 <__umoddi3+0x10a>
  801ee0:	89 f2                	mov    %esi,%edx
  801ee2:	29 cf                	sub    %ecx,%edi
  801ee4:	19 ea                	sbb    %ebp,%edx
  801ee6:	89 f8                	mov    %edi,%eax
  801ee8:	83 c4 20             	add    $0x20,%esp
  801eeb:	5e                   	pop    %esi
  801eec:	5f                   	pop    %edi
  801eed:	5d                   	pop    %ebp
  801eee:	c3                   	ret    
  801eef:	90                   	nop
  801ef0:	89 d1                	mov    %edx,%ecx
  801ef2:	89 c5                	mov    %eax,%ebp
  801ef4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801ef8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801efc:	eb 8d                	jmp    801e8b <__umoddi3+0xaf>
  801efe:	66 90                	xchg   %ax,%ax
  801f00:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f04:	72 ea                	jb     801ef0 <__umoddi3+0x114>
  801f06:	89 f1                	mov    %esi,%ecx
  801f08:	eb 81                	jmp    801e8b <__umoddi3+0xaf>
