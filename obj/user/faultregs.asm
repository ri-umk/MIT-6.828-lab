
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 37 05 00 00       	call   800568 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c3                	mov    %eax,%ebx
  80003f:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 b1 24 80 	movl   $0x8024b1,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 80 24 80 00 	movl   $0x802480,(%esp)
  80005b:	e8 70 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 90 24 80 	movl   $0x802490,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  80007b:	e8 50 06 00 00       	call   8006d0 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  80008d:	e8 3e 06 00 00       	call   8006d0 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  8000a0:	e8 2b 06 00 00       	call   8006d0 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 b2 24 80 	movl   $0x8024b2,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  8000c7:	e8 04 06 00 00       	call   8006d0 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  8000db:	e8 f0 05 00 00       	call   8006d0 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  8000e9:	e8 e2 05 00 00       	call   8006d0 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 b6 24 80 	movl   $0x8024b6,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  800110:	e8 bb 05 00 00       	call   8006d0 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  800124:	e8 a7 05 00 00       	call   8006d0 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  800132:	e8 99 05 00 00       	call   8006d0 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 ba 24 80 	movl   $0x8024ba,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  800159:	e8 72 05 00 00       	call   8006d0 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  80016d:	e8 5e 05 00 00       	call   8006d0 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  80017b:	e8 50 05 00 00       	call   8006d0 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 be 24 80 	movl   $0x8024be,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  8001a2:	e8 29 05 00 00       	call   8006d0 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  8001b6:	e8 15 05 00 00       	call   8006d0 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  8001c4:	e8 07 05 00 00       	call   8006d0 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 c2 24 80 	movl   $0x8024c2,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  8001eb:	e8 e0 04 00 00       	call   8006d0 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  8001ff:	e8 cc 04 00 00       	call   8006d0 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  80020d:	e8 be 04 00 00       	call   8006d0 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 c6 24 80 	movl   $0x8024c6,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  800234:	e8 97 04 00 00       	call   8006d0 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  800248:	e8 83 04 00 00       	call   8006d0 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  800256:	e8 75 04 00 00       	call   8006d0 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 ca 24 80 	movl   $0x8024ca,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  80027d:	e8 4e 04 00 00       	call   8006d0 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  800291:	e8 3a 04 00 00       	call   8006d0 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  80029f:	e8 2c 04 00 00       	call   8006d0 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 ce 24 80 	movl   $0x8024ce,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  8002c6:	e8 05 04 00 00       	call   8006d0 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  8002da:	e8 f1 03 00 00       	call   8006d0 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  8002e8:	e8 e3 03 00 00       	call   8006d0 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 d5 24 80 	movl   $0x8024d5,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 94 24 80 00 	movl   $0x802494,(%esp)
  80030f:	e8 bc 03 00 00       	call   8006d0 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  800323:	e8 a8 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 d9 24 80 00 	movl   $0x8024d9,(%esp)
  800336:	e8 95 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 d9 24 80 00 	movl   $0x8024d9,(%esp)
  80035b:	e8 70 03 00 00       	call   8006d0 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 a4 24 80 00 	movl   $0x8024a4,(%esp)
  800369:	e8 62 03 00 00       	call   8006d0 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 a8 24 80 00 	movl   $0x8024a8,(%esp)
  800377:	e8 54 03 00 00       	call   8006d0 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	83 ec 20             	sub    $0x20,%esp
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800397:	74 27                	je     8003c0 <pgfault+0x3c>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800399:	8b 40 28             	mov    0x28(%eax),%eax
  80039c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a4:	c7 44 24 08 40 25 80 	movl   $0x802540,0x8(%esp)
  8003ab:	00 
  8003ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b3:	00 
  8003b4:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  8003bb:	e8 18 02 00 00       	call   8005d8 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003c0:	bf 80 40 80 00       	mov    $0x804080,%edi
  8003c5:	8d 70 08             	lea    0x8(%eax),%esi
  8003c8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8003cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8003cf:	8b 50 28             	mov    0x28(%eax),%edx
  8003d2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags & ~FL_RF;
  8003d4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003d7:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  8003dd:	89 15 a4 40 80 00    	mov    %edx,0x8040a4
	during.esp = utf->utf_esp;
  8003e3:	8b 40 30             	mov    0x30(%eax),%eax
  8003e6:	a3 a8 40 80 00       	mov    %eax,0x8040a8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003eb:	c7 44 24 04 ff 24 80 	movl   $0x8024ff,0x4(%esp)
  8003f2:	00 
  8003f3:	c7 04 24 0d 25 80 00 	movl   $0x80250d,(%esp)
  8003fa:	b9 80 40 80 00       	mov    $0x804080,%ecx
  8003ff:	ba f8 24 80 00       	mov    $0x8024f8,%edx
  800404:	b8 00 40 80 00       	mov    $0x804000,%eax
  800409:	e8 26 fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80040e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800415:	00 
  800416:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80041d:	00 
  80041e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800425:	e8 43 0c 00 00       	call   80106d <sys_page_alloc>
  80042a:	85 c0                	test   %eax,%eax
  80042c:	79 20                	jns    80044e <pgfault+0xca>
		panic("sys_page_alloc: %e", r);
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	c7 44 24 08 14 25 80 	movl   $0x802514,0x8(%esp)
  800439:	00 
  80043a:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800441:	00 
  800442:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  800449:	e8 8a 01 00 00       	call   8005d8 <_panic>
}
  80044e:	83 c4 20             	add    $0x20,%esp
  800451:	5e                   	pop    %esi
  800452:	5f                   	pop    %edi
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    

00800455 <umain>:

void
umain(int argc, char **argv)
{
  800455:	55                   	push   %ebp
  800456:	89 e5                	mov    %esp,%ebp
  800458:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80045b:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800462:	e8 71 0e 00 00       	call   8012d8 <set_pgfault_handler>

	asm volatile(
  800467:	50                   	push   %eax
  800468:	9c                   	pushf  
  800469:	58                   	pop    %eax
  80046a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80046f:	50                   	push   %eax
  800470:	9d                   	popf   
  800471:	a3 24 40 80 00       	mov    %eax,0x804024
  800476:	8d 05 b1 04 80 00    	lea    0x8004b1,%eax
  80047c:	a3 20 40 80 00       	mov    %eax,0x804020
  800481:	58                   	pop    %eax
  800482:	89 3d 00 40 80 00    	mov    %edi,0x804000
  800488:	89 35 04 40 80 00    	mov    %esi,0x804004
  80048e:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  800494:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  80049a:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004a0:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  8004a6:	a3 1c 40 80 00       	mov    %eax,0x80401c
  8004ab:	89 25 28 40 80 00    	mov    %esp,0x804028
  8004b1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004b8:	00 00 00 
  8004bb:	89 3d 40 40 80 00    	mov    %edi,0x804040
  8004c1:	89 35 44 40 80 00    	mov    %esi,0x804044
  8004c7:	89 2d 48 40 80 00    	mov    %ebp,0x804048
  8004cd:	89 1d 50 40 80 00    	mov    %ebx,0x804050
  8004d3:	89 15 54 40 80 00    	mov    %edx,0x804054
  8004d9:	89 0d 58 40 80 00    	mov    %ecx,0x804058
  8004df:	a3 5c 40 80 00       	mov    %eax,0x80405c
  8004e4:	89 25 68 40 80 00    	mov    %esp,0x804068
  8004ea:	8b 3d 00 40 80 00    	mov    0x804000,%edi
  8004f0:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8004f6:	8b 2d 08 40 80 00    	mov    0x804008,%ebp
  8004fc:	8b 1d 10 40 80 00    	mov    0x804010,%ebx
  800502:	8b 15 14 40 80 00    	mov    0x804014,%edx
  800508:	8b 0d 18 40 80 00    	mov    0x804018,%ecx
  80050e:	a1 1c 40 80 00       	mov    0x80401c,%eax
  800513:	8b 25 28 40 80 00    	mov    0x804028,%esp
  800519:	50                   	push   %eax
  80051a:	9c                   	pushf  
  80051b:	58                   	pop    %eax
  80051c:	a3 64 40 80 00       	mov    %eax,0x804064
  800521:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800522:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800529:	74 0c                	je     800537 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80052b:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  800532:	e8 99 01 00 00       	call   8006d0 <cprintf>
	after.eip = before.eip;
  800537:	a1 20 40 80 00       	mov    0x804020,%eax
  80053c:	a3 60 40 80 00       	mov    %eax,0x804060

	check_regs(&before, "before", &after, "after", "after page-fault");
  800541:	c7 44 24 04 27 25 80 	movl   $0x802527,0x4(%esp)
  800548:	00 
  800549:	c7 04 24 38 25 80 00 	movl   $0x802538,(%esp)
  800550:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800555:	ba f8 24 80 00       	mov    $0x8024f8,%edx
  80055a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80055f:	e8 d0 fa ff ff       	call   800034 <check_regs>
}
  800564:	c9                   	leave  
  800565:	c3                   	ret    
	...

00800568 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	56                   	push   %esi
  80056c:	53                   	push   %ebx
  80056d:	83 ec 10             	sub    $0x10,%esp
  800570:	8b 75 08             	mov    0x8(%ebp),%esi
  800573:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = ENVX(sys_getenvid()) + envs;
  800576:	e8 b4 0a 00 00       	call   80102f <sys_getenvid>
  80057b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800580:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800587:	c1 e0 07             	shl    $0x7,%eax
  80058a:	29 d0                	sub    %edx,%eax
  80058c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800591:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800596:	85 f6                	test   %esi,%esi
  800598:	7e 07                	jle    8005a1 <libmain+0x39>
		binaryname = argv[0];
  80059a:	8b 03                	mov    (%ebx),%eax
  80059c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a5:	89 34 24             	mov    %esi,(%esp)
  8005a8:	e8 a8 fe ff ff       	call   800455 <umain>

	// exit gracefully
	exit();
  8005ad:	e8 0a 00 00 00       	call   8005bc <exit>
}
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	5b                   	pop    %ebx
  8005b6:	5e                   	pop    %esi
  8005b7:	5d                   	pop    %ebp
  8005b8:	c3                   	ret    
  8005b9:	00 00                	add    %al,(%eax)
	...

008005bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005c2:	e8 6c 0f 00 00       	call   801533 <close_all>
	sys_env_destroy(0);
  8005c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005ce:	e8 0a 0a 00 00       	call   800fdd <sys_env_destroy>
}
  8005d3:	c9                   	leave  
  8005d4:	c3                   	ret    
  8005d5:	00 00                	add    %al,(%eax)
	...

008005d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	56                   	push   %esi
  8005dc:	53                   	push   %ebx
  8005dd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005e0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005e3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8005e9:	e8 41 0a 00 00       	call   80102f <sys_getenvid>
  8005ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800600:	89 44 24 04          	mov    %eax,0x4(%esp)
  800604:	c7 04 24 a0 25 80 00 	movl   $0x8025a0,(%esp)
  80060b:	e8 c0 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800610:	89 74 24 04          	mov    %esi,0x4(%esp)
  800614:	8b 45 10             	mov    0x10(%ebp),%eax
  800617:	89 04 24             	mov    %eax,(%esp)
  80061a:	e8 50 00 00 00       	call   80066f <vcprintf>
	cprintf("\n");
  80061f:	c7 04 24 b0 24 80 00 	movl   $0x8024b0,(%esp)
  800626:	e8 a5 00 00 00       	call   8006d0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80062b:	cc                   	int3   
  80062c:	eb fd                	jmp    80062b <_panic+0x53>
	...

00800630 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80063a:	8b 03                	mov    (%ebx),%eax
  80063c:	8b 55 08             	mov    0x8(%ebp),%edx
  80063f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800643:	40                   	inc    %eax
  800644:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800646:	3d ff 00 00 00       	cmp    $0xff,%eax
  80064b:	75 19                	jne    800666 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80064d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800654:	00 
  800655:	8d 43 08             	lea    0x8(%ebx),%eax
  800658:	89 04 24             	mov    %eax,(%esp)
  80065b:	e8 40 09 00 00       	call   800fa0 <sys_cputs>
		b->idx = 0;
  800660:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800666:	ff 43 04             	incl   0x4(%ebx)
}
  800669:	83 c4 14             	add    $0x14,%esp
  80066c:	5b                   	pop    %ebx
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800678:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80067f:	00 00 00 
	b.cnt = 0;
  800682:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800689:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80068c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a4:	c7 04 24 30 06 80 00 	movl   $0x800630,(%esp)
  8006ab:	e8 82 01 00 00       	call   800832 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ba:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	e8 d8 08 00 00       	call   800fa0 <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e0:	89 04 24             	mov    %eax,(%esp)
  8006e3:	e8 87 ff ff ff       	call   80066f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    
	...

008006ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	57                   	push   %edi
  8006f0:	56                   	push   %esi
  8006f1:	53                   	push   %ebx
  8006f2:	83 ec 3c             	sub    $0x3c,%esp
  8006f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f8:	89 d7                	mov    %edx,%edi
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800700:	8b 45 0c             	mov    0xc(%ebp),%eax
  800703:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800706:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800709:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80070c:	85 c0                	test   %eax,%eax
  80070e:	75 08                	jne    800718 <printnum+0x2c>
  800710:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800713:	39 45 10             	cmp    %eax,0x10(%ebp)
  800716:	77 57                	ja     80076f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800718:	89 74 24 10          	mov    %esi,0x10(%esp)
  80071c:	4b                   	dec    %ebx
  80071d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800721:	8b 45 10             	mov    0x10(%ebp),%eax
  800724:	89 44 24 08          	mov    %eax,0x8(%esp)
  800728:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80072c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800730:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800737:	00 
  800738:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80073b:	89 04 24             	mov    %eax,(%esp)
  80073e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800741:	89 44 24 04          	mov    %eax,0x4(%esp)
  800745:	e8 d6 1a 00 00       	call   802220 <__udivdi3>
  80074a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80074e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800752:	89 04 24             	mov    %eax,(%esp)
  800755:	89 54 24 04          	mov    %edx,0x4(%esp)
  800759:	89 fa                	mov    %edi,%edx
  80075b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075e:	e8 89 ff ff ff       	call   8006ec <printnum>
  800763:	eb 0f                	jmp    800774 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800765:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800769:	89 34 24             	mov    %esi,(%esp)
  80076c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80076f:	4b                   	dec    %ebx
  800770:	85 db                	test   %ebx,%ebx
  800772:	7f f1                	jg     800765 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800774:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800778:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80077c:	8b 45 10             	mov    0x10(%ebp),%eax
  80077f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800783:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80078a:	00 
  80078b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	e8 a3 1b 00 00       	call   802340 <__umoddi3>
  80079d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a1:	0f be 80 c3 25 80 00 	movsbl 0x8025c3(%eax),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007ae:	83 c4 3c             	add    $0x3c,%esp
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	5f                   	pop    %edi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007b9:	83 fa 01             	cmp    $0x1,%edx
  8007bc:	7e 0e                	jle    8007cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007be:	8b 10                	mov    (%eax),%edx
  8007c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007c3:	89 08                	mov    %ecx,(%eax)
  8007c5:	8b 02                	mov    (%edx),%eax
  8007c7:	8b 52 04             	mov    0x4(%edx),%edx
  8007ca:	eb 22                	jmp    8007ee <getuint+0x38>
	else if (lflag)
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 10                	je     8007e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007d0:	8b 10                	mov    (%eax),%edx
  8007d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007d5:	89 08                	mov    %ecx,(%eax)
  8007d7:	8b 02                	mov    (%edx),%eax
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007de:	eb 0e                	jmp    8007ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007e5:	89 08                	mov    %ecx,(%eax)
  8007e7:	8b 02                	mov    (%edx),%eax
  8007e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007f6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007f9:	8b 10                	mov    (%eax),%edx
  8007fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8007fe:	73 08                	jae    800808 <sprintputch+0x18>
		*b->buf++ = ch;
  800800:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800803:	88 0a                	mov    %cl,(%edx)
  800805:	42                   	inc    %edx
  800806:	89 10                	mov    %edx,(%eax)
}
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	89 04 24             	mov    %eax,(%esp)
  80082b:	e8 02 00 00 00       	call   800832 <vprintfmt>
	va_end(ap);
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	57                   	push   %edi
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	83 ec 4c             	sub    $0x4c,%esp
  80083b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083e:	8b 75 10             	mov    0x10(%ebp),%esi
  800841:	eb 12                	jmp    800855 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800843:	85 c0                	test   %eax,%eax
  800845:	0f 84 6b 03 00 00    	je     800bb6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80084b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800855:	0f b6 06             	movzbl (%esi),%eax
  800858:	46                   	inc    %esi
  800859:	83 f8 25             	cmp    $0x25,%eax
  80085c:	75 e5                	jne    800843 <vprintfmt+0x11>
  80085e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800862:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800869:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80086e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800875:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087a:	eb 26                	jmp    8008a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80087f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800883:	eb 1d                	jmp    8008a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800885:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800888:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80088c:	eb 14                	jmp    8008a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800891:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800898:	eb 08                	jmp    8008a2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80089a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80089d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a2:	0f b6 06             	movzbl (%esi),%eax
  8008a5:	8d 56 01             	lea    0x1(%esi),%edx
  8008a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008ab:	8a 16                	mov    (%esi),%dl
  8008ad:	83 ea 23             	sub    $0x23,%edx
  8008b0:	80 fa 55             	cmp    $0x55,%dl
  8008b3:	0f 87 e1 02 00 00    	ja     800b9a <vprintfmt+0x368>
  8008b9:	0f b6 d2             	movzbl %dl,%edx
  8008bc:	ff 24 95 00 27 80 00 	jmp    *0x802700(,%edx,4)
  8008c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008cb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8008ce:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8008d2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008d5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008d8:	83 fa 09             	cmp    $0x9,%edx
  8008db:	77 2a                	ja     800907 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008dd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008de:	eb eb                	jmp    8008cb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8d 50 04             	lea    0x4(%eax),%edx
  8008e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008ee:	eb 17                	jmp    800907 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008f4:	78 98                	js     80088e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008f9:	eb a7                	jmp    8008a2 <vprintfmt+0x70>
  8008fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008fe:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800905:	eb 9b                	jmp    8008a2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800907:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80090b:	79 95                	jns    8008a2 <vprintfmt+0x70>
  80090d:	eb 8b                	jmp    80089a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80090f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800910:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800913:	eb 8d                	jmp    8008a2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8d 50 04             	lea    0x4(%eax),%edx
  80091b:	89 55 14             	mov    %edx,0x14(%ebp)
  80091e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800922:	8b 00                	mov    (%eax),%eax
  800924:	89 04 24             	mov    %eax,(%esp)
  800927:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80092d:	e9 23 ff ff ff       	jmp    800855 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	8d 50 04             	lea    0x4(%eax),%edx
  800938:	89 55 14             	mov    %edx,0x14(%ebp)
  80093b:	8b 00                	mov    (%eax),%eax
  80093d:	85 c0                	test   %eax,%eax
  80093f:	79 02                	jns    800943 <vprintfmt+0x111>
  800941:	f7 d8                	neg    %eax
  800943:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800945:	83 f8 0f             	cmp    $0xf,%eax
  800948:	7f 0b                	jg     800955 <vprintfmt+0x123>
  80094a:	8b 04 85 60 28 80 00 	mov    0x802860(,%eax,4),%eax
  800951:	85 c0                	test   %eax,%eax
  800953:	75 23                	jne    800978 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800955:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800959:	c7 44 24 08 db 25 80 	movl   $0x8025db,0x8(%esp)
  800960:	00 
  800961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	89 04 24             	mov    %eax,(%esp)
  80096b:	e8 9a fe ff ff       	call   80080a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800973:	e9 dd fe ff ff       	jmp    800855 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800978:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097c:	c7 44 24 08 be 29 80 	movl   $0x8029be,0x8(%esp)
  800983:	00 
  800984:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800988:	8b 55 08             	mov    0x8(%ebp),%edx
  80098b:	89 14 24             	mov    %edx,(%esp)
  80098e:	e8 77 fe ff ff       	call   80080a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800993:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800996:	e9 ba fe ff ff       	jmp    800855 <vprintfmt+0x23>
  80099b:	89 f9                	mov    %edi,%ecx
  80099d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a6:	8d 50 04             	lea    0x4(%eax),%edx
  8009a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ac:	8b 30                	mov    (%eax),%esi
  8009ae:	85 f6                	test   %esi,%esi
  8009b0:	75 05                	jne    8009b7 <vprintfmt+0x185>
				p = "(null)";
  8009b2:	be d4 25 80 00       	mov    $0x8025d4,%esi
			if (width > 0 && padc != '-')
  8009b7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009bb:	0f 8e 84 00 00 00    	jle    800a45 <vprintfmt+0x213>
  8009c1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009c5:	74 7e                	je     800a45 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009cb:	89 34 24             	mov    %esi,(%esp)
  8009ce:	e8 8b 02 00 00       	call   800c5e <strnlen>
  8009d3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009d6:	29 c2                	sub    %eax,%edx
  8009d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009db:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009df:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009e2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009e5:	89 de                	mov    %ebx,%esi
  8009e7:	89 d3                	mov    %edx,%ebx
  8009e9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009eb:	eb 0b                	jmp    8009f8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f1:	89 3c 24             	mov    %edi,(%esp)
  8009f4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f7:	4b                   	dec    %ebx
  8009f8:	85 db                	test   %ebx,%ebx
  8009fa:	7f f1                	jg     8009ed <vprintfmt+0x1bb>
  8009fc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800a04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a07:	85 c0                	test   %eax,%eax
  800a09:	79 05                	jns    800a10 <vprintfmt+0x1de>
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a13:	29 c2                	sub    %eax,%edx
  800a15:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a18:	eb 2b                	jmp    800a45 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a1a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a1e:	74 18                	je     800a38 <vprintfmt+0x206>
  800a20:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a23:	83 fa 5e             	cmp    $0x5e,%edx
  800a26:	76 10                	jbe    800a38 <vprintfmt+0x206>
					putch('?', putdat);
  800a28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a33:	ff 55 08             	call   *0x8(%ebp)
  800a36:	eb 0a                	jmp    800a42 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3c:	89 04 24             	mov    %eax,(%esp)
  800a3f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a42:	ff 4d e4             	decl   -0x1c(%ebp)
  800a45:	0f be 06             	movsbl (%esi),%eax
  800a48:	46                   	inc    %esi
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	74 21                	je     800a6e <vprintfmt+0x23c>
  800a4d:	85 ff                	test   %edi,%edi
  800a4f:	78 c9                	js     800a1a <vprintfmt+0x1e8>
  800a51:	4f                   	dec    %edi
  800a52:	79 c6                	jns    800a1a <vprintfmt+0x1e8>
  800a54:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a57:	89 de                	mov    %ebx,%esi
  800a59:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a5c:	eb 18                	jmp    800a76 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a5e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a62:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a69:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6b:	4b                   	dec    %ebx
  800a6c:	eb 08                	jmp    800a76 <vprintfmt+0x244>
  800a6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a71:	89 de                	mov    %ebx,%esi
  800a73:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	7f e4                	jg     800a5e <vprintfmt+0x22c>
  800a7a:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a7d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a82:	e9 ce fd ff ff       	jmp    800855 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a87:	83 f9 01             	cmp    $0x1,%ecx
  800a8a:	7e 10                	jle    800a9c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8f:	8d 50 08             	lea    0x8(%eax),%edx
  800a92:	89 55 14             	mov    %edx,0x14(%ebp)
  800a95:	8b 30                	mov    (%eax),%esi
  800a97:	8b 78 04             	mov    0x4(%eax),%edi
  800a9a:	eb 26                	jmp    800ac2 <vprintfmt+0x290>
	else if (lflag)
  800a9c:	85 c9                	test   %ecx,%ecx
  800a9e:	74 12                	je     800ab2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa3:	8d 50 04             	lea    0x4(%eax),%edx
  800aa6:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa9:	8b 30                	mov    (%eax),%esi
  800aab:	89 f7                	mov    %esi,%edi
  800aad:	c1 ff 1f             	sar    $0x1f,%edi
  800ab0:	eb 10                	jmp    800ac2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800ab2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab5:	8d 50 04             	lea    0x4(%eax),%edx
  800ab8:	89 55 14             	mov    %edx,0x14(%ebp)
  800abb:	8b 30                	mov    (%eax),%esi
  800abd:	89 f7                	mov    %esi,%edi
  800abf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ac2:	85 ff                	test   %edi,%edi
  800ac4:	78 0a                	js     800ad0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ac6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800acb:	e9 8c 00 00 00       	jmp    800b5c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ad0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800adb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ade:	f7 de                	neg    %esi
  800ae0:	83 d7 00             	adc    $0x0,%edi
  800ae3:	f7 df                	neg    %edi
			}
			base = 10;
  800ae5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aea:	eb 70                	jmp    800b5c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800aec:	89 ca                	mov    %ecx,%edx
  800aee:	8d 45 14             	lea    0x14(%ebp),%eax
  800af1:	e8 c0 fc ff ff       	call   8007b6 <getuint>
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	89 d7                	mov    %edx,%edi
			base = 10;
  800afa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800aff:	eb 5b                	jmp    800b5c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b01:	89 ca                	mov    %ecx,%edx
  800b03:	8d 45 14             	lea    0x14(%ebp),%eax
  800b06:	e8 ab fc ff ff       	call   8007b6 <getuint>
  800b0b:	89 c6                	mov    %eax,%esi
  800b0d:	89 d7                	mov    %edx,%edi
			base = 8;
  800b0f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b14:	eb 46                	jmp    800b5c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800b16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b1a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b21:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b28:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b2f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b32:	8b 45 14             	mov    0x14(%ebp),%eax
  800b35:	8d 50 04             	lea    0x4(%eax),%edx
  800b38:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b3b:	8b 30                	mov    (%eax),%esi
  800b3d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b42:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b47:	eb 13                	jmp    800b5c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b49:	89 ca                	mov    %ecx,%edx
  800b4b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4e:	e8 63 fc ff ff       	call   8007b6 <getuint>
  800b53:	89 c6                	mov    %eax,%esi
  800b55:	89 d7                	mov    %edx,%edi
			base = 16;
  800b57:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b5c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b60:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b67:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6f:	89 34 24             	mov    %esi,(%esp)
  800b72:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b76:	89 da                	mov    %ebx,%edx
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7b:	e8 6c fb ff ff       	call   8006ec <printnum>
			break;
  800b80:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b83:	e9 cd fc ff ff       	jmp    800855 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b8c:	89 04 24             	mov    %eax,(%esp)
  800b8f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b92:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b95:	e9 bb fc ff ff       	jmp    800855 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b9e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ba5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ba8:	eb 01                	jmp    800bab <vprintfmt+0x379>
  800baa:	4e                   	dec    %esi
  800bab:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800baf:	75 f9                	jne    800baa <vprintfmt+0x378>
  800bb1:	e9 9f fc ff ff       	jmp    800855 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bb6:	83 c4 4c             	add    $0x4c,%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	83 ec 28             	sub    $0x28,%esp
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bcd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bd1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	74 30                	je     800c0f <vsnprintf+0x51>
  800bdf:	85 d2                	test   %edx,%edx
  800be1:	7e 33                	jle    800c16 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800be3:	8b 45 14             	mov    0x14(%ebp),%eax
  800be6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bea:	8b 45 10             	mov    0x10(%ebp),%eax
  800bed:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf8:	c7 04 24 f0 07 80 00 	movl   $0x8007f0,(%esp)
  800bff:	e8 2e fc ff ff       	call   800832 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c07:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0d:	eb 0c                	jmp    800c1b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c14:	eb 05                	jmp    800c1b <vsnprintf+0x5d>
  800c16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c23:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3b:	89 04 24             	mov    %eax,(%esp)
  800c3e:	e8 7b ff ff ff       	call   800bbe <vsnprintf>
	va_end(ap);

	return rc;
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    
  800c45:	00 00                	add    %al,(%eax)
	...

00800c48 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c53:	eb 01                	jmp    800c56 <strlen+0xe>
		n++;
  800c55:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c56:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c5a:	75 f9                	jne    800c55 <strlen+0xd>
		n++;
	return n;
}
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c64:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6c:	eb 01                	jmp    800c6f <strnlen+0x11>
		n++;
  800c6e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6f:	39 d0                	cmp    %edx,%eax
  800c71:	74 06                	je     800c79 <strnlen+0x1b>
  800c73:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c77:	75 f5                	jne    800c6e <strnlen+0x10>
		n++;
	return n;
}
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c85:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c8d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c90:	42                   	inc    %edx
  800c91:	84 c9                	test   %cl,%cl
  800c93:	75 f5                	jne    800c8a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c95:	5b                   	pop    %ebx
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 08             	sub    $0x8,%esp
  800c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ca2:	89 1c 24             	mov    %ebx,(%esp)
  800ca5:	e8 9e ff ff ff       	call   800c48 <strlen>
	strcpy(dst + len, src);
  800caa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cad:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cb1:	01 d8                	add    %ebx,%eax
  800cb3:	89 04 24             	mov    %eax,(%esp)
  800cb6:	e8 c0 ff ff ff       	call   800c7b <strcpy>
	return dst;
}
  800cbb:	89 d8                	mov    %ebx,%eax
  800cbd:	83 c4 08             	add    $0x8,%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cce:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd6:	eb 0c                	jmp    800ce4 <strncpy+0x21>
		*dst++ = *src;
  800cd8:	8a 1a                	mov    (%edx),%bl
  800cda:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cdd:	80 3a 01             	cmpb   $0x1,(%edx)
  800ce0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce3:	41                   	inc    %ecx
  800ce4:	39 f1                	cmp    %esi,%ecx
  800ce6:	75 f0                	jne    800cd8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	8b 75 08             	mov    0x8(%ebp),%esi
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cfa:	85 d2                	test   %edx,%edx
  800cfc:	75 0a                	jne    800d08 <strlcpy+0x1c>
  800cfe:	89 f0                	mov    %esi,%eax
  800d00:	eb 1a                	jmp    800d1c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d02:	88 18                	mov    %bl,(%eax)
  800d04:	40                   	inc    %eax
  800d05:	41                   	inc    %ecx
  800d06:	eb 02                	jmp    800d0a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d08:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800d0a:	4a                   	dec    %edx
  800d0b:	74 0a                	je     800d17 <strlcpy+0x2b>
  800d0d:	8a 19                	mov    (%ecx),%bl
  800d0f:	84 db                	test   %bl,%bl
  800d11:	75 ef                	jne    800d02 <strlcpy+0x16>
  800d13:	89 c2                	mov    %eax,%edx
  800d15:	eb 02                	jmp    800d19 <strlcpy+0x2d>
  800d17:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d19:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d1c:	29 f0                	sub    %esi,%eax
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d28:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d2b:	eb 02                	jmp    800d2f <strcmp+0xd>
		p++, q++;
  800d2d:	41                   	inc    %ecx
  800d2e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d2f:	8a 01                	mov    (%ecx),%al
  800d31:	84 c0                	test   %al,%al
  800d33:	74 04                	je     800d39 <strcmp+0x17>
  800d35:	3a 02                	cmp    (%edx),%al
  800d37:	74 f4                	je     800d2d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d39:	0f b6 c0             	movzbl %al,%eax
  800d3c:	0f b6 12             	movzbl (%edx),%edx
  800d3f:	29 d0                	sub    %edx,%eax
}
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	53                   	push   %ebx
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d50:	eb 03                	jmp    800d55 <strncmp+0x12>
		n--, p++, q++;
  800d52:	4a                   	dec    %edx
  800d53:	40                   	inc    %eax
  800d54:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d55:	85 d2                	test   %edx,%edx
  800d57:	74 14                	je     800d6d <strncmp+0x2a>
  800d59:	8a 18                	mov    (%eax),%bl
  800d5b:	84 db                	test   %bl,%bl
  800d5d:	74 04                	je     800d63 <strncmp+0x20>
  800d5f:	3a 19                	cmp    (%ecx),%bl
  800d61:	74 ef                	je     800d52 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	0f b6 11             	movzbl (%ecx),%edx
  800d69:	29 d0                	sub    %edx,%eax
  800d6b:	eb 05                	jmp    800d72 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d6d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d72:	5b                   	pop    %ebx
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d7e:	eb 05                	jmp    800d85 <strchr+0x10>
		if (*s == c)
  800d80:	38 ca                	cmp    %cl,%dl
  800d82:	74 0c                	je     800d90 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d84:	40                   	inc    %eax
  800d85:	8a 10                	mov    (%eax),%dl
  800d87:	84 d2                	test   %dl,%dl
  800d89:	75 f5                	jne    800d80 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	8b 45 08             	mov    0x8(%ebp),%eax
  800d98:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d9b:	eb 05                	jmp    800da2 <strfind+0x10>
		if (*s == c)
  800d9d:	38 ca                	cmp    %cl,%dl
  800d9f:	74 07                	je     800da8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800da1:	40                   	inc    %eax
  800da2:	8a 10                	mov    (%eax),%dl
  800da4:	84 d2                	test   %dl,%dl
  800da6:	75 f5                	jne    800d9d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800db3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800db9:	85 c9                	test   %ecx,%ecx
  800dbb:	74 30                	je     800ded <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dbd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dc3:	75 25                	jne    800dea <memset+0x40>
  800dc5:	f6 c1 03             	test   $0x3,%cl
  800dc8:	75 20                	jne    800dea <memset+0x40>
		c &= 0xFF;
  800dca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dcd:	89 d3                	mov    %edx,%ebx
  800dcf:	c1 e3 08             	shl    $0x8,%ebx
  800dd2:	89 d6                	mov    %edx,%esi
  800dd4:	c1 e6 18             	shl    $0x18,%esi
  800dd7:	89 d0                	mov    %edx,%eax
  800dd9:	c1 e0 10             	shl    $0x10,%eax
  800ddc:	09 f0                	or     %esi,%eax
  800dde:	09 d0                	or     %edx,%eax
  800de0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800de2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800de5:	fc                   	cld    
  800de6:	f3 ab                	rep stos %eax,%es:(%edi)
  800de8:	eb 03                	jmp    800ded <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dea:	fc                   	cld    
  800deb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ded:	89 f8                	mov    %edi,%eax
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e02:	39 c6                	cmp    %eax,%esi
  800e04:	73 34                	jae    800e3a <memmove+0x46>
  800e06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e09:	39 d0                	cmp    %edx,%eax
  800e0b:	73 2d                	jae    800e3a <memmove+0x46>
		s += n;
		d += n;
  800e0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e10:	f6 c2 03             	test   $0x3,%dl
  800e13:	75 1b                	jne    800e30 <memmove+0x3c>
  800e15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e1b:	75 13                	jne    800e30 <memmove+0x3c>
  800e1d:	f6 c1 03             	test   $0x3,%cl
  800e20:	75 0e                	jne    800e30 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e22:	83 ef 04             	sub    $0x4,%edi
  800e25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e28:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e2b:	fd                   	std    
  800e2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e2e:	eb 07                	jmp    800e37 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e30:	4f                   	dec    %edi
  800e31:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e34:	fd                   	std    
  800e35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e37:	fc                   	cld    
  800e38:	eb 20                	jmp    800e5a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e40:	75 13                	jne    800e55 <memmove+0x61>
  800e42:	a8 03                	test   $0x3,%al
  800e44:	75 0f                	jne    800e55 <memmove+0x61>
  800e46:	f6 c1 03             	test   $0x3,%cl
  800e49:	75 0a                	jne    800e55 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e4b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e4e:	89 c7                	mov    %eax,%edi
  800e50:	fc                   	cld    
  800e51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e53:	eb 05                	jmp    800e5a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e55:	89 c7                	mov    %eax,%edi
  800e57:	fc                   	cld    
  800e58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e64:	8b 45 10             	mov    0x10(%ebp),%eax
  800e67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	89 04 24             	mov    %eax,(%esp)
  800e78:	e8 77 ff ff ff       	call   800df4 <memmove>
}
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    

00800e7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	57                   	push   %edi
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
  800e85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e93:	eb 16                	jmp    800eab <memcmp+0x2c>
		if (*s1 != *s2)
  800e95:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e98:	42                   	inc    %edx
  800e99:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e9d:	38 c8                	cmp    %cl,%al
  800e9f:	74 0a                	je     800eab <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ea1:	0f b6 c0             	movzbl %al,%eax
  800ea4:	0f b6 c9             	movzbl %cl,%ecx
  800ea7:	29 c8                	sub    %ecx,%eax
  800ea9:	eb 09                	jmp    800eb4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eab:	39 da                	cmp    %ebx,%edx
  800ead:	75 e6                	jne    800e95 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ec2:	89 c2                	mov    %eax,%edx
  800ec4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ec7:	eb 05                	jmp    800ece <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ec9:	38 08                	cmp    %cl,(%eax)
  800ecb:	74 05                	je     800ed2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ecd:	40                   	inc    %eax
  800ece:	39 d0                	cmp    %edx,%eax
  800ed0:	72 f7                	jb     800ec9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee0:	eb 01                	jmp    800ee3 <strtol+0xf>
		s++;
  800ee2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee3:	8a 02                	mov    (%edx),%al
  800ee5:	3c 20                	cmp    $0x20,%al
  800ee7:	74 f9                	je     800ee2 <strtol+0xe>
  800ee9:	3c 09                	cmp    $0x9,%al
  800eeb:	74 f5                	je     800ee2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eed:	3c 2b                	cmp    $0x2b,%al
  800eef:	75 08                	jne    800ef9 <strtol+0x25>
		s++;
  800ef1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ef2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ef7:	eb 13                	jmp    800f0c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ef9:	3c 2d                	cmp    $0x2d,%al
  800efb:	75 0a                	jne    800f07 <strtol+0x33>
		s++, neg = 1;
  800efd:	8d 52 01             	lea    0x1(%edx),%edx
  800f00:	bf 01 00 00 00       	mov    $0x1,%edi
  800f05:	eb 05                	jmp    800f0c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f0c:	85 db                	test   %ebx,%ebx
  800f0e:	74 05                	je     800f15 <strtol+0x41>
  800f10:	83 fb 10             	cmp    $0x10,%ebx
  800f13:	75 28                	jne    800f3d <strtol+0x69>
  800f15:	8a 02                	mov    (%edx),%al
  800f17:	3c 30                	cmp    $0x30,%al
  800f19:	75 10                	jne    800f2b <strtol+0x57>
  800f1b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f1f:	75 0a                	jne    800f2b <strtol+0x57>
		s += 2, base = 16;
  800f21:	83 c2 02             	add    $0x2,%edx
  800f24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f29:	eb 12                	jmp    800f3d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f2b:	85 db                	test   %ebx,%ebx
  800f2d:	75 0e                	jne    800f3d <strtol+0x69>
  800f2f:	3c 30                	cmp    $0x30,%al
  800f31:	75 05                	jne    800f38 <strtol+0x64>
		s++, base = 8;
  800f33:	42                   	inc    %edx
  800f34:	b3 08                	mov    $0x8,%bl
  800f36:	eb 05                	jmp    800f3d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f38:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f44:	8a 0a                	mov    (%edx),%cl
  800f46:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f49:	80 fb 09             	cmp    $0x9,%bl
  800f4c:	77 08                	ja     800f56 <strtol+0x82>
			dig = *s - '0';
  800f4e:	0f be c9             	movsbl %cl,%ecx
  800f51:	83 e9 30             	sub    $0x30,%ecx
  800f54:	eb 1e                	jmp    800f74 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f56:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f59:	80 fb 19             	cmp    $0x19,%bl
  800f5c:	77 08                	ja     800f66 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f5e:	0f be c9             	movsbl %cl,%ecx
  800f61:	83 e9 57             	sub    $0x57,%ecx
  800f64:	eb 0e                	jmp    800f74 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f66:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f69:	80 fb 19             	cmp    $0x19,%bl
  800f6c:	77 12                	ja     800f80 <strtol+0xac>
			dig = *s - 'A' + 10;
  800f6e:	0f be c9             	movsbl %cl,%ecx
  800f71:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f74:	39 f1                	cmp    %esi,%ecx
  800f76:	7d 0c                	jge    800f84 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f78:	42                   	inc    %edx
  800f79:	0f af c6             	imul   %esi,%eax
  800f7c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f7e:	eb c4                	jmp    800f44 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f80:	89 c1                	mov    %eax,%ecx
  800f82:	eb 02                	jmp    800f86 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f84:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f8a:	74 05                	je     800f91 <strtol+0xbd>
		*endptr = (char *) s;
  800f8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f8f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f91:	85 ff                	test   %edi,%edi
  800f93:	74 04                	je     800f99 <strtol+0xc5>
  800f95:	89 c8                	mov    %ecx,%eax
  800f97:	f7 d8                	neg    %eax
}
  800f99:	5b                   	pop    %ebx
  800f9a:	5e                   	pop    %esi
  800f9b:	5f                   	pop    %edi
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    
	...

00800fa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fae:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb1:	89 c3                	mov    %eax,%ebx
  800fb3:	89 c7                	mov    %eax,%edi
  800fb5:	89 c6                	mov    %eax,%esi
  800fb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fb9:	5b                   	pop    %ebx
  800fba:	5e                   	pop    %esi
  800fbb:	5f                   	pop    %edi
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fce:	89 d1                	mov    %edx,%ecx
  800fd0:	89 d3                	mov    %edx,%ebx
  800fd2:	89 d7                	mov    %edx,%edi
  800fd4:	89 d6                	mov    %edx,%esi
  800fd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800feb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ff0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff3:	89 cb                	mov    %ecx,%ebx
  800ff5:	89 cf                	mov    %ecx,%edi
  800ff7:	89 ce                	mov    %ecx,%esi
  800ff9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	7e 28                	jle    801027 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fff:	89 44 24 10          	mov    %eax,0x10(%esp)
  801003:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80100a:	00 
  80100b:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  801012:	00 
  801013:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80101a:	00 
  80101b:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  801022:	e8 b1 f5 ff ff       	call   8005d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801027:	83 c4 2c             	add    $0x2c,%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801035:	ba 00 00 00 00       	mov    $0x0,%edx
  80103a:	b8 02 00 00 00       	mov    $0x2,%eax
  80103f:	89 d1                	mov    %edx,%ecx
  801041:	89 d3                	mov    %edx,%ebx
  801043:	89 d7                	mov    %edx,%edi
  801045:	89 d6                	mov    %edx,%esi
  801047:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_yield>:

void
sys_yield(void)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801054:	ba 00 00 00 00       	mov    $0x0,%edx
  801059:	b8 0b 00 00 00       	mov    $0xb,%eax
  80105e:	89 d1                	mov    %edx,%ecx
  801060:	89 d3                	mov    %edx,%ebx
  801062:	89 d7                	mov    %edx,%edi
  801064:	89 d6                	mov    %edx,%esi
  801066:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	57                   	push   %edi
  801071:	56                   	push   %esi
  801072:	53                   	push   %ebx
  801073:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801076:	be 00 00 00 00       	mov    $0x0,%esi
  80107b:	b8 04 00 00 00       	mov    $0x4,%eax
  801080:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801083:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	89 f7                	mov    %esi,%edi
  80108b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108d:	85 c0                	test   %eax,%eax
  80108f:	7e 28                	jle    8010b9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801091:	89 44 24 10          	mov    %eax,0x10(%esp)
  801095:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80109c:	00 
  80109d:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ac:	00 
  8010ad:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  8010b4:	e8 1f f5 ff ff       	call   8005d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010b9:	83 c4 2c             	add    $0x2c,%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	57                   	push   %edi
  8010c5:	56                   	push   %esi
  8010c6:	53                   	push   %ebx
  8010c7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8010cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8010d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010db:	8b 55 08             	mov    0x8(%ebp),%edx
  8010de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	7e 28                	jle    80110c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010ef:	00 
  8010f0:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  8010f7:	00 
  8010f8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ff:	00 
  801100:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  801107:	e8 cc f4 ff ff       	call   8005d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80110c:	83 c4 2c             	add    $0x2c,%esp
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801122:	b8 06 00 00 00       	mov    $0x6,%eax
  801127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112a:	8b 55 08             	mov    0x8(%ebp),%edx
  80112d:	89 df                	mov    %ebx,%edi
  80112f:	89 de                	mov    %ebx,%esi
  801131:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801133:	85 c0                	test   %eax,%eax
  801135:	7e 28                	jle    80115f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801137:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801142:	00 
  801143:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  80114a:	00 
  80114b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801152:	00 
  801153:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  80115a:	e8 79 f4 ff ff       	call   8005d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80115f:	83 c4 2c             	add    $0x2c,%esp
  801162:	5b                   	pop    %ebx
  801163:	5e                   	pop    %esi
  801164:	5f                   	pop    %edi
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801170:	bb 00 00 00 00       	mov    $0x0,%ebx
  801175:	b8 08 00 00 00       	mov    $0x8,%eax
  80117a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117d:	8b 55 08             	mov    0x8(%ebp),%edx
  801180:	89 df                	mov    %ebx,%edi
  801182:	89 de                	mov    %ebx,%esi
  801184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801186:	85 c0                	test   %eax,%eax
  801188:	7e 28                	jle    8011b2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801195:	00 
  801196:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  80119d:	00 
  80119e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a5:	00 
  8011a6:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  8011ad:	e8 26 f4 ff ff       	call   8005d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011b2:	83 c4 2c             	add    $0x2c,%esp
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c8:	b8 09 00 00 00       	mov    $0x9,%eax
  8011cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d3:	89 df                	mov    %ebx,%edi
  8011d5:	89 de                	mov    %ebx,%esi
  8011d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	7e 28                	jle    801205 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011e8:	00 
  8011e9:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  8011f0:	00 
  8011f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011f8:	00 
  8011f9:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  801200:	e8 d3 f3 ff ff       	call   8005d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801205:	83 c4 2c             	add    $0x2c,%esp
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801223:	8b 55 08             	mov    0x8(%ebp),%edx
  801226:	89 df                	mov    %ebx,%edi
  801228:	89 de                	mov    %ebx,%esi
  80122a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80122c:	85 c0                	test   %eax,%eax
  80122e:	7e 28                	jle    801258 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801230:	89 44 24 10          	mov    %eax,0x10(%esp)
  801234:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80123b:	00 
  80123c:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  801243:	00 
  801244:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80124b:	00 
  80124c:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  801253:	e8 80 f3 ff ff       	call   8005d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801258:	83 c4 2c             	add    $0x2c,%esp
  80125b:	5b                   	pop    %ebx
  80125c:	5e                   	pop    %esi
  80125d:	5f                   	pop    %edi
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801266:	be 00 00 00 00       	mov    $0x0,%esi
  80126b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801270:	8b 7d 14             	mov    0x14(%ebp),%edi
  801273:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801279:	8b 55 08             	mov    0x8(%ebp),%edx
  80127c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	57                   	push   %edi
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80128c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801291:	b8 0d 00 00 00       	mov    $0xd,%eax
  801296:	8b 55 08             	mov    0x8(%ebp),%edx
  801299:	89 cb                	mov    %ecx,%ebx
  80129b:	89 cf                	mov    %ecx,%edi
  80129d:	89 ce                	mov    %ecx,%esi
  80129f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	7e 28                	jle    8012cd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8012b0:	00 
  8012b1:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  8012b8:	00 
  8012b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012c0:	00 
  8012c1:	c7 04 24 dc 28 80 00 	movl   $0x8028dc,(%esp)
  8012c8:	e8 0b f3 ff ff       	call   8005d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012cd:	83 c4 2c             	add    $0x2c,%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    
  8012d5:	00 00                	add    %al,(%eax)
	...

008012d8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012de:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012e5:	75 32                	jne    801319 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8012e7:	e8 43 fd ff ff       	call   80102f <sys_getenvid>
  8012ec:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  8012f3:	00 
  8012f4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012fb:	ee 
  8012fc:	89 04 24             	mov    %eax,(%esp)
  8012ff:	e8 69 fd ff ff       	call   80106d <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);		
  801304:	e8 26 fd ff ff       	call   80102f <sys_getenvid>
  801309:	c7 44 24 04 24 13 80 	movl   $0x801324,0x4(%esp)
  801310:	00 
  801311:	89 04 24             	mov    %eax,(%esp)
  801314:	e8 f4 fe ff ff       	call   80120d <sys_env_set_pgfault_upcall>

	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801319:	8b 45 08             	mov    0x8(%ebp),%eax
  80131c:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801321:	c9                   	leave  
  801322:	c3                   	ret    
	...

00801324 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801324:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801325:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80132a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80132c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %eax	//uft_eip
  80132f:	8b 44 24 28          	mov    0x28(%esp),%eax
	addl $8, %esp
  801333:	83 c4 08             	add    $0x8,%esp
	subl $4, 0x28(%esp)
  801336:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
	movl 0x28(%esp), %ebp	//utf_esp - 4
  80133b:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl %eax, (%ebp)
  80133f:	89 45 00             	mov    %eax,0x0(%ebp)
	// %ebp = utf_eip(addr) -> utf_esp-4(value)

	popal 
  801342:	61                   	popa   
	// pop PushRegs and utf_eip

	addl $4, %esp
  801343:	83 c4 04             	add    $0x4,%esp
	popfl
  801346:	9d                   	popf   
	// pop uft_eflags

	popl %esp
  801347:	5c                   	pop    %esp
	// The stack pointer switches back to the adjusted exception stack.

	ret
  801348:	c3                   	ret    
  801349:	00 00                	add    %al,(%eax)
	...

0080134c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134f:	8b 45 08             	mov    0x8(%ebp),%eax
  801352:	05 00 00 00 30       	add    $0x30000000,%eax
  801357:	c1 e8 0c             	shr    $0xc,%eax
}
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801362:	8b 45 08             	mov    0x8(%ebp),%eax
  801365:	89 04 24             	mov    %eax,(%esp)
  801368:	e8 df ff ff ff       	call   80134c <fd2num>
  80136d:	05 20 00 0d 00       	add    $0xd0020,%eax
  801372:	c1 e0 0c             	shl    $0xc,%eax
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80137e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801383:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801385:	89 c2                	mov    %eax,%edx
  801387:	c1 ea 16             	shr    $0x16,%edx
  80138a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801391:	f6 c2 01             	test   $0x1,%dl
  801394:	74 11                	je     8013a7 <fd_alloc+0x30>
  801396:	89 c2                	mov    %eax,%edx
  801398:	c1 ea 0c             	shr    $0xc,%edx
  80139b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a2:	f6 c2 01             	test   $0x1,%dl
  8013a5:	75 09                	jne    8013b0 <fd_alloc+0x39>
			*fd_store = fd;
  8013a7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ae:	eb 17                	jmp    8013c7 <fd_alloc+0x50>
  8013b0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013b5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013ba:	75 c7                	jne    801383 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013c2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013c7:	5b                   	pop    %ebx
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013d0:	83 f8 1f             	cmp    $0x1f,%eax
  8013d3:	77 36                	ja     80140b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013d5:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013da:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	c1 ea 16             	shr    $0x16,%edx
  8013e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e9:	f6 c2 01             	test   $0x1,%dl
  8013ec:	74 24                	je     801412 <fd_lookup+0x48>
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	c1 ea 0c             	shr    $0xc,%edx
  8013f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fa:	f6 c2 01             	test   $0x1,%dl
  8013fd:	74 1a                	je     801419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801402:	89 02                	mov    %eax,(%edx)
	return 0;
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
  801409:	eb 13                	jmp    80141e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80140b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801410:	eb 0c                	jmp    80141e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801417:	eb 05                	jmp    80141e <fd_lookup+0x54>
  801419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	53                   	push   %ebx
  801424:	83 ec 14             	sub    $0x14,%esp
  801427:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80142d:	ba 00 00 00 00       	mov    $0x0,%edx
  801432:	eb 0e                	jmp    801442 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801434:	39 08                	cmp    %ecx,(%eax)
  801436:	75 09                	jne    801441 <dev_lookup+0x21>
			*dev = devtab[i];
  801438:	89 03                	mov    %eax,(%ebx)
			return 0;
  80143a:	b8 00 00 00 00       	mov    $0x0,%eax
  80143f:	eb 33                	jmp    801474 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801441:	42                   	inc    %edx
  801442:	8b 04 95 6c 29 80 00 	mov    0x80296c(,%edx,4),%eax
  801449:	85 c0                	test   %eax,%eax
  80144b:	75 e7                	jne    801434 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80144d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801452:	8b 40 48             	mov    0x48(%eax),%eax
  801455:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145d:	c7 04 24 ec 28 80 00 	movl   $0x8028ec,(%esp)
  801464:	e8 67 f2 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  801469:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80146f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801474:	83 c4 14             	add    $0x14,%esp
  801477:	5b                   	pop    %ebx
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    

0080147a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	56                   	push   %esi
  80147e:	53                   	push   %ebx
  80147f:	83 ec 30             	sub    $0x30,%esp
  801482:	8b 75 08             	mov    0x8(%ebp),%esi
  801485:	8a 45 0c             	mov    0xc(%ebp),%al
  801488:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80148b:	89 34 24             	mov    %esi,(%esp)
  80148e:	e8 b9 fe ff ff       	call   80134c <fd2num>
  801493:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801496:	89 54 24 04          	mov    %edx,0x4(%esp)
  80149a:	89 04 24             	mov    %eax,(%esp)
  80149d:	e8 28 ff ff ff       	call   8013ca <fd_lookup>
  8014a2:	89 c3                	mov    %eax,%ebx
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 05                	js     8014ad <fd_close+0x33>
	    || fd != fd2)
  8014a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014ab:	74 0d                	je     8014ba <fd_close+0x40>
		return (must_exist ? r : 0);
  8014ad:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014b1:	75 46                	jne    8014f9 <fd_close+0x7f>
  8014b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b8:	eb 3f                	jmp    8014f9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c1:	8b 06                	mov    (%esi),%eax
  8014c3:	89 04 24             	mov    %eax,(%esp)
  8014c6:	e8 55 ff ff ff       	call   801420 <dev_lookup>
  8014cb:	89 c3                	mov    %eax,%ebx
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 18                	js     8014e9 <fd_close+0x6f>
		if (dev->dev_close)
  8014d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d4:	8b 40 10             	mov    0x10(%eax),%eax
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	74 09                	je     8014e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014db:	89 34 24             	mov    %esi,(%esp)
  8014de:	ff d0                	call   *%eax
  8014e0:	89 c3                	mov    %eax,%ebx
  8014e2:	eb 05                	jmp    8014e9 <fd_close+0x6f>
		else
			r = 0;
  8014e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f4:	e8 1b fc ff ff       	call   801114 <sys_page_unmap>
	return r;
}
  8014f9:	89 d8                	mov    %ebx,%eax
  8014fb:	83 c4 30             	add    $0x30,%esp
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5d                   	pop    %ebp
  801501:	c3                   	ret    

00801502 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801508:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150f:	8b 45 08             	mov    0x8(%ebp),%eax
  801512:	89 04 24             	mov    %eax,(%esp)
  801515:	e8 b0 fe ff ff       	call   8013ca <fd_lookup>
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 13                	js     801531 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80151e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801525:	00 
  801526:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801529:	89 04 24             	mov    %eax,(%esp)
  80152c:	e8 49 ff ff ff       	call   80147a <fd_close>
}
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <close_all>:

void
close_all(void)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80153a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80153f:	89 1c 24             	mov    %ebx,(%esp)
  801542:	e8 bb ff ff ff       	call   801502 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801547:	43                   	inc    %ebx
  801548:	83 fb 20             	cmp    $0x20,%ebx
  80154b:	75 f2                	jne    80153f <close_all+0xc>
		close(i);
}
  80154d:	83 c4 14             	add    $0x14,%esp
  801550:	5b                   	pop    %ebx
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    

00801553 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	57                   	push   %edi
  801557:	56                   	push   %esi
  801558:	53                   	push   %ebx
  801559:	83 ec 4c             	sub    $0x4c,%esp
  80155c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80155f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801562:	89 44 24 04          	mov    %eax,0x4(%esp)
  801566:	8b 45 08             	mov    0x8(%ebp),%eax
  801569:	89 04 24             	mov    %eax,(%esp)
  80156c:	e8 59 fe ff ff       	call   8013ca <fd_lookup>
  801571:	89 c3                	mov    %eax,%ebx
  801573:	85 c0                	test   %eax,%eax
  801575:	0f 88 e1 00 00 00    	js     80165c <dup+0x109>
		return r;
	close(newfdnum);
  80157b:	89 3c 24             	mov    %edi,(%esp)
  80157e:	e8 7f ff ff ff       	call   801502 <close>

	newfd = INDEX2FD(newfdnum);
  801583:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801589:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80158c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80158f:	89 04 24             	mov    %eax,(%esp)
  801592:	e8 c5 fd ff ff       	call   80135c <fd2data>
  801597:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801599:	89 34 24             	mov    %esi,(%esp)
  80159c:	e8 bb fd ff ff       	call   80135c <fd2data>
  8015a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015a4:	89 d8                	mov    %ebx,%eax
  8015a6:	c1 e8 16             	shr    $0x16,%eax
  8015a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b0:	a8 01                	test   $0x1,%al
  8015b2:	74 46                	je     8015fa <dup+0xa7>
  8015b4:	89 d8                	mov    %ebx,%eax
  8015b6:	c1 e8 0c             	shr    $0xc,%eax
  8015b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c0:	f6 c2 01             	test   $0x1,%dl
  8015c3:	74 35                	je     8015fa <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015e3:	00 
  8015e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ef:	e8 cd fa ff ff       	call   8010c1 <sys_page_map>
  8015f4:	89 c3                	mov    %eax,%ebx
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 3b                	js     801635 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	c1 ea 0c             	shr    $0xc,%edx
  801602:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801609:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80160f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801613:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801617:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80161e:	00 
  80161f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801623:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80162a:	e8 92 fa ff ff       	call   8010c1 <sys_page_map>
  80162f:	89 c3                	mov    %eax,%ebx
  801631:	85 c0                	test   %eax,%eax
  801633:	79 25                	jns    80165a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801635:	89 74 24 04          	mov    %esi,0x4(%esp)
  801639:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801640:	e8 cf fa ff ff       	call   801114 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801645:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801653:	e8 bc fa ff ff       	call   801114 <sys_page_unmap>
	return r;
  801658:	eb 02                	jmp    80165c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80165a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80165c:	89 d8                	mov    %ebx,%eax
  80165e:	83 c4 4c             	add    $0x4c,%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 24             	sub    $0x24,%esp
  80166d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801670:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801673:	89 44 24 04          	mov    %eax,0x4(%esp)
  801677:	89 1c 24             	mov    %ebx,(%esp)
  80167a:	e8 4b fd ff ff       	call   8013ca <fd_lookup>
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 6d                	js     8016f0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168d:	8b 00                	mov    (%eax),%eax
  80168f:	89 04 24             	mov    %eax,(%esp)
  801692:	e8 89 fd ff ff       	call   801420 <dev_lookup>
  801697:	85 c0                	test   %eax,%eax
  801699:	78 55                	js     8016f0 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80169b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169e:	8b 50 08             	mov    0x8(%eax),%edx
  8016a1:	83 e2 03             	and    $0x3,%edx
  8016a4:	83 fa 01             	cmp    $0x1,%edx
  8016a7:	75 23                	jne    8016cc <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016a9:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016ae:	8b 40 48             	mov    0x48(%eax),%eax
  8016b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b9:	c7 04 24 30 29 80 00 	movl   $0x802930,(%esp)
  8016c0:	e8 0b f0 ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  8016c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ca:	eb 24                	jmp    8016f0 <read+0x8a>
	}
	if (!dev->dev_read)
  8016cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cf:	8b 52 08             	mov    0x8(%edx),%edx
  8016d2:	85 d2                	test   %edx,%edx
  8016d4:	74 15                	je     8016eb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016e4:	89 04 24             	mov    %eax,(%esp)
  8016e7:	ff d2                	call   *%edx
  8016e9:	eb 05                	jmp    8016f0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016f0:	83 c4 24             	add    $0x24,%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 1c             	sub    $0x1c,%esp
  8016ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801702:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801705:	bb 00 00 00 00       	mov    $0x0,%ebx
  80170a:	eb 23                	jmp    80172f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80170c:	89 f0                	mov    %esi,%eax
  80170e:	29 d8                	sub    %ebx,%eax
  801710:	89 44 24 08          	mov    %eax,0x8(%esp)
  801714:	8b 45 0c             	mov    0xc(%ebp),%eax
  801717:	01 d8                	add    %ebx,%eax
  801719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171d:	89 3c 24             	mov    %edi,(%esp)
  801720:	e8 41 ff ff ff       	call   801666 <read>
		if (m < 0)
  801725:	85 c0                	test   %eax,%eax
  801727:	78 10                	js     801739 <readn+0x43>
			return m;
		if (m == 0)
  801729:	85 c0                	test   %eax,%eax
  80172b:	74 0a                	je     801737 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80172d:	01 c3                	add    %eax,%ebx
  80172f:	39 f3                	cmp    %esi,%ebx
  801731:	72 d9                	jb     80170c <readn+0x16>
  801733:	89 d8                	mov    %ebx,%eax
  801735:	eb 02                	jmp    801739 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801737:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801739:	83 c4 1c             	add    $0x1c,%esp
  80173c:	5b                   	pop    %ebx
  80173d:	5e                   	pop    %esi
  80173e:	5f                   	pop    %edi
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    

00801741 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	53                   	push   %ebx
  801745:	83 ec 24             	sub    $0x24,%esp
  801748:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801752:	89 1c 24             	mov    %ebx,(%esp)
  801755:	e8 70 fc ff ff       	call   8013ca <fd_lookup>
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 68                	js     8017c6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801761:	89 44 24 04          	mov    %eax,0x4(%esp)
  801765:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801768:	8b 00                	mov    (%eax),%eax
  80176a:	89 04 24             	mov    %eax,(%esp)
  80176d:	e8 ae fc ff ff       	call   801420 <dev_lookup>
  801772:	85 c0                	test   %eax,%eax
  801774:	78 50                	js     8017c6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801776:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801779:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177d:	75 23                	jne    8017a2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80177f:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801784:	8b 40 48             	mov    0x48(%eax),%eax
  801787:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80178b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178f:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  801796:	e8 35 ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  80179b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a0:	eb 24                	jmp    8017c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a8:	85 d2                	test   %edx,%edx
  8017aa:	74 15                	je     8017c1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017ba:	89 04 24             	mov    %eax,(%esp)
  8017bd:	ff d2                	call   *%edx
  8017bf:	eb 05                	jmp    8017c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017c6:	83 c4 24             	add    $0x24,%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <seek>:

int
seek(int fdnum, off_t offset)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dc:	89 04 24             	mov    %eax,(%esp)
  8017df:	e8 e6 fb ff ff       	call   8013ca <fd_lookup>
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 0e                	js     8017f6 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 24             	sub    $0x24,%esp
  8017ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801802:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801805:	89 44 24 04          	mov    %eax,0x4(%esp)
  801809:	89 1c 24             	mov    %ebx,(%esp)
  80180c:	e8 b9 fb ff ff       	call   8013ca <fd_lookup>
  801811:	85 c0                	test   %eax,%eax
  801813:	78 61                	js     801876 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801815:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181f:	8b 00                	mov    (%eax),%eax
  801821:	89 04 24             	mov    %eax,(%esp)
  801824:	e8 f7 fb ff ff       	call   801420 <dev_lookup>
  801829:	85 c0                	test   %eax,%eax
  80182b:	78 49                	js     801876 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80182d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801830:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801834:	75 23                	jne    801859 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801836:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80183b:	8b 40 48             	mov    0x48(%eax),%eax
  80183e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801842:	89 44 24 04          	mov    %eax,0x4(%esp)
  801846:	c7 04 24 0c 29 80 00 	movl   $0x80290c,(%esp)
  80184d:	e8 7e ee ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801852:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801857:	eb 1d                	jmp    801876 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801859:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185c:	8b 52 18             	mov    0x18(%edx),%edx
  80185f:	85 d2                	test   %edx,%edx
  801861:	74 0e                	je     801871 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801863:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801866:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80186a:	89 04 24             	mov    %eax,(%esp)
  80186d:	ff d2                	call   *%edx
  80186f:	eb 05                	jmp    801876 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801871:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801876:	83 c4 24             	add    $0x24,%esp
  801879:	5b                   	pop    %ebx
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	53                   	push   %ebx
  801880:	83 ec 24             	sub    $0x24,%esp
  801883:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801886:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188d:	8b 45 08             	mov    0x8(%ebp),%eax
  801890:	89 04 24             	mov    %eax,(%esp)
  801893:	e8 32 fb ff ff       	call   8013ca <fd_lookup>
  801898:	85 c0                	test   %eax,%eax
  80189a:	78 52                	js     8018ee <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a6:	8b 00                	mov    (%eax),%eax
  8018a8:	89 04 24             	mov    %eax,(%esp)
  8018ab:	e8 70 fb ff ff       	call   801420 <dev_lookup>
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	78 3a                	js     8018ee <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018bb:	74 2c                	je     8018e9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018c7:	00 00 00 
	stat->st_isdir = 0;
  8018ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d1:	00 00 00 
	stat->st_dev = dev;
  8018d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018e1:	89 14 24             	mov    %edx,(%esp)
  8018e4:	ff 50 14             	call   *0x14(%eax)
  8018e7:	eb 05                	jmp    8018ee <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018ee:	83 c4 24             	add    $0x24,%esp
  8018f1:	5b                   	pop    %ebx
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801903:	00 
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	89 04 24             	mov    %eax,(%esp)
  80190a:	e8 fe 01 00 00       	call   801b0d <open>
  80190f:	89 c3                	mov    %eax,%ebx
  801911:	85 c0                	test   %eax,%eax
  801913:	78 1b                	js     801930 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801915:	8b 45 0c             	mov    0xc(%ebp),%eax
  801918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191c:	89 1c 24             	mov    %ebx,(%esp)
  80191f:	e8 58 ff ff ff       	call   80187c <fstat>
  801924:	89 c6                	mov    %eax,%esi
	close(fd);
  801926:	89 1c 24             	mov    %ebx,(%esp)
  801929:	e8 d4 fb ff ff       	call   801502 <close>
	return r;
  80192e:	89 f3                	mov    %esi,%ebx
}
  801930:	89 d8                	mov    %ebx,%eax
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	5b                   	pop    %ebx
  801936:	5e                   	pop    %esi
  801937:	5d                   	pop    %ebp
  801938:	c3                   	ret    
  801939:	00 00                	add    %al,(%eax)
	...

0080193c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	83 ec 10             	sub    $0x10,%esp
  801944:	89 c3                	mov    %eax,%ebx
  801946:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801948:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  80194f:	75 11                	jne    801962 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801951:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801958:	e8 3a 08 00 00       	call   802197 <ipc_find_env>
  80195d:	a3 ac 40 80 00       	mov    %eax,0x8040ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801962:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801969:	00 
  80196a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801971:	00 
  801972:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801976:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  80197b:	89 04 24             	mov    %eax,(%esp)
  80197e:	e8 aa 07 00 00       	call   80212d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801983:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80198a:	00 
  80198b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80198f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801996:	e8 29 07 00 00       	call   8020c4 <ipc_recv>
}
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    

008019a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8019c5:	e8 72 ff ff ff       	call   80193c <fsipc>
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8019e7:	e8 50 ff ff ff       	call   80193c <fsipc>
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 14             	sub    $0x14,%esp
  8019f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a03:	ba 00 00 00 00       	mov    $0x0,%edx
  801a08:	b8 05 00 00 00       	mov    $0x5,%eax
  801a0d:	e8 2a ff ff ff       	call   80193c <fsipc>
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 2b                	js     801a41 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a16:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a1d:	00 
  801a1e:	89 1c 24             	mov    %ebx,(%esp)
  801a21:	e8 55 f2 ff ff       	call   800c7b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a26:	a1 80 50 80 00       	mov    0x805080,%eax
  801a2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a31:	a1 84 50 80 00       	mov    0x805084,%eax
  801a36:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a41:	83 c4 14             	add    $0x14,%esp
  801a44:	5b                   	pop    %ebx
  801a45:	5d                   	pop    %ebp
  801a46:	c3                   	ret    

00801a47 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801a4d:	c7 44 24 08 7c 29 80 	movl   $0x80297c,0x8(%esp)
  801a54:	00 
  801a55:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801a5c:	00 
  801a5d:	c7 04 24 9a 29 80 00 	movl   $0x80299a,(%esp)
  801a64:	e8 6f eb ff ff       	call   8005d8 <_panic>

00801a69 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 10             	sub    $0x10,%esp
  801a71:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a7f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a85:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  801a8f:	e8 a8 fe ff ff       	call   80193c <fsipc>
  801a94:	89 c3                	mov    %eax,%ebx
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 6a                	js     801b04 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a9a:	39 c6                	cmp    %eax,%esi
  801a9c:	73 24                	jae    801ac2 <devfile_read+0x59>
  801a9e:	c7 44 24 0c a5 29 80 	movl   $0x8029a5,0xc(%esp)
  801aa5:	00 
  801aa6:	c7 44 24 08 ac 29 80 	movl   $0x8029ac,0x8(%esp)
  801aad:	00 
  801aae:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ab5:	00 
  801ab6:	c7 04 24 9a 29 80 00 	movl   $0x80299a,(%esp)
  801abd:	e8 16 eb ff ff       	call   8005d8 <_panic>
	assert(r <= PGSIZE);
  801ac2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ac7:	7e 24                	jle    801aed <devfile_read+0x84>
  801ac9:	c7 44 24 0c c1 29 80 	movl   $0x8029c1,0xc(%esp)
  801ad0:	00 
  801ad1:	c7 44 24 08 ac 29 80 	movl   $0x8029ac,0x8(%esp)
  801ad8:	00 
  801ad9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ae0:	00 
  801ae1:	c7 04 24 9a 29 80 00 	movl   $0x80299a,(%esp)
  801ae8:	e8 eb ea ff ff       	call   8005d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aed:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af1:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801af8:	00 
  801af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afc:	89 04 24             	mov    %eax,(%esp)
  801aff:	e8 f0 f2 ff ff       	call   800df4 <memmove>
	return r;
}
  801b04:	89 d8                	mov    %ebx,%eax
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5e                   	pop    %esi
  801b0b:	5d                   	pop    %ebp
  801b0c:	c3                   	ret    

00801b0d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	56                   	push   %esi
  801b11:	53                   	push   %ebx
  801b12:	83 ec 20             	sub    $0x20,%esp
  801b15:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b18:	89 34 24             	mov    %esi,(%esp)
  801b1b:	e8 28 f1 ff ff       	call   800c48 <strlen>
  801b20:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b25:	7f 60                	jg     801b87 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2a:	89 04 24             	mov    %eax,(%esp)
  801b2d:	e8 45 f8 ff ff       	call   801377 <fd_alloc>
  801b32:	89 c3                	mov    %eax,%ebx
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 54                	js     801b8c <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b38:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b3c:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b43:	e8 33 f1 ff ff       	call   800c7b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b53:	b8 01 00 00 00       	mov    $0x1,%eax
  801b58:	e8 df fd ff ff       	call   80193c <fsipc>
  801b5d:	89 c3                	mov    %eax,%ebx
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	79 15                	jns    801b78 <open+0x6b>
		fd_close(fd, 0);
  801b63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b6a:	00 
  801b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6e:	89 04 24             	mov    %eax,(%esp)
  801b71:	e8 04 f9 ff ff       	call   80147a <fd_close>
		return r;
  801b76:	eb 14                	jmp    801b8c <open+0x7f>
	}

	return fd2num(fd);
  801b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7b:	89 04 24             	mov    %eax,(%esp)
  801b7e:	e8 c9 f7 ff ff       	call   80134c <fd2num>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	eb 05                	jmp    801b8c <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b87:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	83 c4 20             	add    $0x20,%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ba5:	e8 92 fd ff ff       	call   80193c <fsipc>
}
  801baa:	c9                   	leave  
  801bab:	c3                   	ret    

00801bac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 10             	sub    $0x10,%esp
  801bb4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bba:	89 04 24             	mov    %eax,(%esp)
  801bbd:	e8 9a f7 ff ff       	call   80135c <fd2data>
  801bc2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bc4:	c7 44 24 04 cd 29 80 	movl   $0x8029cd,0x4(%esp)
  801bcb:	00 
  801bcc:	89 34 24             	mov    %esi,(%esp)
  801bcf:	e8 a7 f0 ff ff       	call   800c7b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bd4:	8b 43 04             	mov    0x4(%ebx),%eax
  801bd7:	2b 03                	sub    (%ebx),%eax
  801bd9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801bdf:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801be6:	00 00 00 
	stat->st_dev = &devpipe;
  801be9:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801bf0:	30 80 00 
	return 0;
}
  801bf3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	5b                   	pop    %ebx
  801bfc:	5e                   	pop    %esi
  801bfd:	5d                   	pop    %ebp
  801bfe:	c3                   	ret    

00801bff <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	53                   	push   %ebx
  801c03:	83 ec 14             	sub    $0x14,%esp
  801c06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c09:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c14:	e8 fb f4 ff ff       	call   801114 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c19:	89 1c 24             	mov    %ebx,(%esp)
  801c1c:	e8 3b f7 ff ff       	call   80135c <fd2data>
  801c21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c2c:	e8 e3 f4 ff ff       	call   801114 <sys_page_unmap>
}
  801c31:	83 c4 14             	add    $0x14,%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	57                   	push   %edi
  801c3b:	56                   	push   %esi
  801c3c:	53                   	push   %ebx
  801c3d:	83 ec 2c             	sub    $0x2c,%esp
  801c40:	89 c7                	mov    %eax,%edi
  801c42:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c45:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801c4a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c4d:	89 3c 24             	mov    %edi,(%esp)
  801c50:	e8 87 05 00 00       	call   8021dc <pageref>
  801c55:	89 c6                	mov    %eax,%esi
  801c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c5a:	89 04 24             	mov    %eax,(%esp)
  801c5d:	e8 7a 05 00 00       	call   8021dc <pageref>
  801c62:	39 c6                	cmp    %eax,%esi
  801c64:	0f 94 c0             	sete   %al
  801c67:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c6a:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801c70:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c73:	39 cb                	cmp    %ecx,%ebx
  801c75:	75 08                	jne    801c7f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c77:	83 c4 2c             	add    $0x2c,%esp
  801c7a:	5b                   	pop    %ebx
  801c7b:	5e                   	pop    %esi
  801c7c:	5f                   	pop    %edi
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c7f:	83 f8 01             	cmp    $0x1,%eax
  801c82:	75 c1                	jne    801c45 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c84:	8b 42 58             	mov    0x58(%edx),%eax
  801c87:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801c8e:	00 
  801c8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c97:	c7 04 24 d4 29 80 00 	movl   $0x8029d4,(%esp)
  801c9e:	e8 2d ea ff ff       	call   8006d0 <cprintf>
  801ca3:	eb a0                	jmp    801c45 <_pipeisclosed+0xe>

00801ca5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	57                   	push   %edi
  801ca9:	56                   	push   %esi
  801caa:	53                   	push   %ebx
  801cab:	83 ec 1c             	sub    $0x1c,%esp
  801cae:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cb1:	89 34 24             	mov    %esi,(%esp)
  801cb4:	e8 a3 f6 ff ff       	call   80135c <fd2data>
  801cb9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cbb:	bf 00 00 00 00       	mov    $0x0,%edi
  801cc0:	eb 3c                	jmp    801cfe <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cc2:	89 da                	mov    %ebx,%edx
  801cc4:	89 f0                	mov    %esi,%eax
  801cc6:	e8 6c ff ff ff       	call   801c37 <_pipeisclosed>
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	75 38                	jne    801d07 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ccf:	e8 7a f3 ff ff       	call   80104e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cd4:	8b 43 04             	mov    0x4(%ebx),%eax
  801cd7:	8b 13                	mov    (%ebx),%edx
  801cd9:	83 c2 20             	add    $0x20,%edx
  801cdc:	39 d0                	cmp    %edx,%eax
  801cde:	73 e2                	jae    801cc2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ce0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801ce6:	89 c2                	mov    %eax,%edx
  801ce8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801cee:	79 05                	jns    801cf5 <devpipe_write+0x50>
  801cf0:	4a                   	dec    %edx
  801cf1:	83 ca e0             	or     $0xffffffe0,%edx
  801cf4:	42                   	inc    %edx
  801cf5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cf9:	40                   	inc    %eax
  801cfa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfd:	47                   	inc    %edi
  801cfe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d01:	75 d1                	jne    801cd4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d03:	89 f8                	mov    %edi,%eax
  801d05:	eb 05                	jmp    801d0c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d07:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d0c:	83 c4 1c             	add    $0x1c,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	57                   	push   %edi
  801d18:	56                   	push   %esi
  801d19:	53                   	push   %ebx
  801d1a:	83 ec 1c             	sub    $0x1c,%esp
  801d1d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d20:	89 3c 24             	mov    %edi,(%esp)
  801d23:	e8 34 f6 ff ff       	call   80135c <fd2data>
  801d28:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2a:	be 00 00 00 00       	mov    $0x0,%esi
  801d2f:	eb 3a                	jmp    801d6b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d31:	85 f6                	test   %esi,%esi
  801d33:	74 04                	je     801d39 <devpipe_read+0x25>
				return i;
  801d35:	89 f0                	mov    %esi,%eax
  801d37:	eb 40                	jmp    801d79 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d39:	89 da                	mov    %ebx,%edx
  801d3b:	89 f8                	mov    %edi,%eax
  801d3d:	e8 f5 fe ff ff       	call   801c37 <_pipeisclosed>
  801d42:	85 c0                	test   %eax,%eax
  801d44:	75 2e                	jne    801d74 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d46:	e8 03 f3 ff ff       	call   80104e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d4b:	8b 03                	mov    (%ebx),%eax
  801d4d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d50:	74 df                	je     801d31 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d52:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d57:	79 05                	jns    801d5e <devpipe_read+0x4a>
  801d59:	48                   	dec    %eax
  801d5a:	83 c8 e0             	or     $0xffffffe0,%eax
  801d5d:	40                   	inc    %eax
  801d5e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d65:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d68:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6a:	46                   	inc    %esi
  801d6b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d6e:	75 db                	jne    801d4b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d70:	89 f0                	mov    %esi,%eax
  801d72:	eb 05                	jmp    801d79 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d74:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d79:	83 c4 1c             	add    $0x1c,%esp
  801d7c:	5b                   	pop    %ebx
  801d7d:	5e                   	pop    %esi
  801d7e:	5f                   	pop    %edi
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    

00801d81 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	57                   	push   %edi
  801d85:	56                   	push   %esi
  801d86:	53                   	push   %ebx
  801d87:	83 ec 3c             	sub    $0x3c,%esp
  801d8a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d8d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d90:	89 04 24             	mov    %eax,(%esp)
  801d93:	e8 df f5 ff ff       	call   801377 <fd_alloc>
  801d98:	89 c3                	mov    %eax,%ebx
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	0f 88 45 01 00 00    	js     801ee7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801da9:	00 
  801daa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801db8:	e8 b0 f2 ff ff       	call   80106d <sys_page_alloc>
  801dbd:	89 c3                	mov    %eax,%ebx
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	0f 88 20 01 00 00    	js     801ee7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dc7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801dca:	89 04 24             	mov    %eax,(%esp)
  801dcd:	e8 a5 f5 ff ff       	call   801377 <fd_alloc>
  801dd2:	89 c3                	mov    %eax,%ebx
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	0f 88 f8 00 00 00    	js     801ed4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ddc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801de3:	00 
  801de4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801de7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801deb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df2:	e8 76 f2 ff ff       	call   80106d <sys_page_alloc>
  801df7:	89 c3                	mov    %eax,%ebx
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	0f 88 d3 00 00 00    	js     801ed4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e04:	89 04 24             	mov    %eax,(%esp)
  801e07:	e8 50 f5 ff ff       	call   80135c <fd2data>
  801e0c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e15:	00 
  801e16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e21:	e8 47 f2 ff ff       	call   80106d <sys_page_alloc>
  801e26:	89 c3                	mov    %eax,%ebx
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	0f 88 91 00 00 00    	js     801ec1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e33:	89 04 24             	mov    %eax,(%esp)
  801e36:	e8 21 f5 ff ff       	call   80135c <fd2data>
  801e3b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e42:	00 
  801e43:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e4e:	00 
  801e4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5a:	e8 62 f2 ff ff       	call   8010c1 <sys_page_map>
  801e5f:	89 c3                	mov    %eax,%ebx
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 4c                	js     801eb1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e65:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e6e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e73:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e7a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e80:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e83:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e85:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e88:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e92:	89 04 24             	mov    %eax,(%esp)
  801e95:	e8 b2 f4 ff ff       	call   80134c <fd2num>
  801e9a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e9f:	89 04 24             	mov    %eax,(%esp)
  801ea2:	e8 a5 f4 ff ff       	call   80134c <fd2num>
  801ea7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801eaa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eaf:	eb 36                	jmp    801ee7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801eb1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ebc:	e8 53 f2 ff ff       	call   801114 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ec1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ecf:	e8 40 f2 ff ff       	call   801114 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ed4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801edb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee2:	e8 2d f2 ff ff       	call   801114 <sys_page_unmap>
    err:
	return r;
}
  801ee7:	89 d8                	mov    %ebx,%eax
  801ee9:	83 c4 3c             	add    $0x3c,%esp
  801eec:	5b                   	pop    %ebx
  801eed:	5e                   	pop    %esi
  801eee:	5f                   	pop    %edi
  801eef:	5d                   	pop    %ebp
  801ef0:	c3                   	ret    

00801ef1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801efa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efe:	8b 45 08             	mov    0x8(%ebp),%eax
  801f01:	89 04 24             	mov    %eax,(%esp)
  801f04:	e8 c1 f4 ff ff       	call   8013ca <fd_lookup>
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	78 15                	js     801f22 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f10:	89 04 24             	mov    %eax,(%esp)
  801f13:	e8 44 f4 ff ff       	call   80135c <fd2data>
	return _pipeisclosed(fd, p);
  801f18:	89 c2                	mov    %eax,%edx
  801f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1d:	e8 15 fd ff ff       	call   801c37 <_pipeisclosed>
}
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    

00801f24 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f27:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    

00801f2e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f34:	c7 44 24 04 ec 29 80 	movl   $0x8029ec,0x4(%esp)
  801f3b:	00 
  801f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3f:	89 04 24             	mov    %eax,(%esp)
  801f42:	e8 34 ed ff ff       	call   800c7b <strcpy>
	return 0;
}
  801f47:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    

00801f4e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f5f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f65:	eb 30                	jmp    801f97 <devcons_write+0x49>
		m = n - tot;
  801f67:	8b 75 10             	mov    0x10(%ebp),%esi
  801f6a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f6c:	83 fe 7f             	cmp    $0x7f,%esi
  801f6f:	76 05                	jbe    801f76 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801f71:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f76:	89 74 24 08          	mov    %esi,0x8(%esp)
  801f7a:	03 45 0c             	add    0xc(%ebp),%eax
  801f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f81:	89 3c 24             	mov    %edi,(%esp)
  801f84:	e8 6b ee ff ff       	call   800df4 <memmove>
		sys_cputs(buf, m);
  801f89:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f8d:	89 3c 24             	mov    %edi,(%esp)
  801f90:	e8 0b f0 ff ff       	call   800fa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f95:	01 f3                	add    %esi,%ebx
  801f97:	89 d8                	mov    %ebx,%eax
  801f99:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f9c:	72 c9                	jb     801f67 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f9e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801fa4:	5b                   	pop    %ebx
  801fa5:	5e                   	pop    %esi
  801fa6:	5f                   	pop    %edi
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    

00801fa9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801faf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb3:	75 07                	jne    801fbc <devcons_read+0x13>
  801fb5:	eb 25                	jmp    801fdc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fb7:	e8 92 f0 ff ff       	call   80104e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fbc:	e8 fd ef ff ff       	call   800fbe <sys_cgetc>
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	74 f2                	je     801fb7 <devcons_read+0xe>
  801fc5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	78 1d                	js     801fe8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fcb:	83 f8 04             	cmp    $0x4,%eax
  801fce:	74 13                	je     801fe3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd3:	88 10                	mov    %dl,(%eax)
	return 1;
  801fd5:	b8 01 00 00 00       	mov    $0x1,%eax
  801fda:	eb 0c                	jmp    801fe8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe1:	eb 05                	jmp    801fe8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fe3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    

00801fea <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ff6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ffd:	00 
  801ffe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802001:	89 04 24             	mov    %eax,(%esp)
  802004:	e8 97 ef ff ff       	call   800fa0 <sys_cputs>
}
  802009:	c9                   	leave  
  80200a:	c3                   	ret    

0080200b <getchar>:

int
getchar(void)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802011:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802018:	00 
  802019:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80201c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802020:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802027:	e8 3a f6 ff ff       	call   801666 <read>
	if (r < 0)
  80202c:	85 c0                	test   %eax,%eax
  80202e:	78 0f                	js     80203f <getchar+0x34>
		return r;
	if (r < 1)
  802030:	85 c0                	test   %eax,%eax
  802032:	7e 06                	jle    80203a <getchar+0x2f>
		return -E_EOF;
	return c;
  802034:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802038:	eb 05                	jmp    80203f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80203a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80203f:	c9                   	leave  
  802040:	c3                   	ret    

00802041 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
  802044:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802047:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80204e:	8b 45 08             	mov    0x8(%ebp),%eax
  802051:	89 04 24             	mov    %eax,(%esp)
  802054:	e8 71 f3 ff ff       	call   8013ca <fd_lookup>
  802059:	85 c0                	test   %eax,%eax
  80205b:	78 11                	js     80206e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80205d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802060:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802066:	39 10                	cmp    %edx,(%eax)
  802068:	0f 94 c0             	sete   %al
  80206b:	0f b6 c0             	movzbl %al,%eax
}
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <opencons>:

int
opencons(void)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802076:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802079:	89 04 24             	mov    %eax,(%esp)
  80207c:	e8 f6 f2 ff ff       	call   801377 <fd_alloc>
  802081:	85 c0                	test   %eax,%eax
  802083:	78 3c                	js     8020c1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802085:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80208c:	00 
  80208d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802090:	89 44 24 04          	mov    %eax,0x4(%esp)
  802094:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209b:	e8 cd ef ff ff       	call   80106d <sys_page_alloc>
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	78 1d                	js     8020c1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020a4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ad:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020b9:	89 04 24             	mov    %eax,(%esp)
  8020bc:	e8 8b f2 ff ff       	call   80134c <fd2num>
}
  8020c1:	c9                   	leave  
  8020c2:	c3                   	ret    
	...

008020c4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	57                   	push   %edi
  8020c8:	56                   	push   %esi
  8020c9:	53                   	push   %ebx
  8020ca:	83 ec 1c             	sub    $0x1c,%esp
  8020cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8020d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020d3:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	if(!pg)
  8020d6:	85 db                	test   %ebx,%ebx
  8020d8:	75 05                	jne    8020df <ipc_recv+0x1b>
		pg = (void *)UTOP;
  8020da:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	if(sys_ipc_recv(pg) < 0){
  8020df:	89 1c 24             	mov    %ebx,(%esp)
  8020e2:	e8 9c f1 ff ff       	call   801283 <sys_ipc_recv>
  8020e7:	85 c0                	test   %eax,%eax
  8020e9:	79 16                	jns    802101 <ipc_recv+0x3d>
		*from_env_store = 0;
  8020eb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;			
  8020f1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		return sys_ipc_recv(pg);
  8020f7:	89 1c 24             	mov    %ebx,(%esp)
  8020fa:	e8 84 f1 ff ff       	call   801283 <sys_ipc_recv>
  8020ff:	eb 24                	jmp    802125 <ipc_recv+0x61>
	}		
	
	if(from_env_store)
  802101:	85 f6                	test   %esi,%esi
  802103:	74 0a                	je     80210f <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802105:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80210a:	8b 40 74             	mov    0x74(%eax),%eax
  80210d:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80210f:	85 ff                	test   %edi,%edi
  802111:	74 0a                	je     80211d <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802113:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802118:	8b 40 78             	mov    0x78(%eax),%eax
  80211b:	89 07                	mov    %eax,(%edi)
	return thisenv->env_ipc_value;	
  80211d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802122:	8b 40 70             	mov    0x70(%eax),%eax
}
  802125:	83 c4 1c             	add    $0x1c,%esp
  802128:	5b                   	pop    %ebx
  802129:	5e                   	pop    %esi
  80212a:	5f                   	pop    %edi
  80212b:	5d                   	pop    %ebp
  80212c:	c3                   	ret    

0080212d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80212d:	55                   	push   %ebp
  80212e:	89 e5                	mov    %esp,%ebp
  802130:	57                   	push   %edi
  802131:	56                   	push   %esi
  802132:	53                   	push   %ebx
  802133:	83 ec 1c             	sub    $0x1c,%esp
  802136:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802139:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80213c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  80213f:	85 db                	test   %ebx,%ebx
  802141:	75 05                	jne    802148 <ipc_send+0x1b>
		pg = (void *)-1;
  802143:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802148:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80214c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802150:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802154:	8b 45 08             	mov    0x8(%ebp),%eax
  802157:	89 04 24             	mov    %eax,(%esp)
  80215a:	e8 01 f1 ff ff       	call   801260 <sys_ipc_try_send>
		if (r == 0) {		
  80215f:	85 c0                	test   %eax,%eax
  802161:	74 2c                	je     80218f <ipc_send+0x62>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  802163:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802166:	75 07                	jne    80216f <ipc_send+0x42>
			sys_yield();
  802168:	e8 e1 ee ff ff       	call   80104e <sys_yield>
		} else {			
			panic("ipc_send():%e", r);
		}
	}
  80216d:	eb d9                	jmp    802148 <ipc_send+0x1b>
		if (r == 0) {		
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
			sys_yield();
		} else {			
			panic("ipc_send():%e", r);
  80216f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802173:	c7 44 24 08 f8 29 80 	movl   $0x8029f8,0x8(%esp)
  80217a:	00 
  80217b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  802182:	00 
  802183:	c7 04 24 06 2a 80 00 	movl   $0x802a06,(%esp)
  80218a:	e8 49 e4 ff ff       	call   8005d8 <_panic>
		}
	}
}
  80218f:	83 c4 1c             	add    $0x1c,%esp
  802192:	5b                   	pop    %ebx
  802193:	5e                   	pop    %esi
  802194:	5f                   	pop    %edi
  802195:	5d                   	pop    %ebp
  802196:	c3                   	ret    

00802197 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802197:	55                   	push   %ebp
  802198:	89 e5                	mov    %esp,%ebp
  80219a:	53                   	push   %ebx
  80219b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80219e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021a3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021aa:	89 c2                	mov    %eax,%edx
  8021ac:	c1 e2 07             	shl    $0x7,%edx
  8021af:	29 ca                	sub    %ecx,%edx
  8021b1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021b7:	8b 52 50             	mov    0x50(%edx),%edx
  8021ba:	39 da                	cmp    %ebx,%edx
  8021bc:	75 0f                	jne    8021cd <ipc_find_env+0x36>
			return envs[i].env_id;
  8021be:	c1 e0 07             	shl    $0x7,%eax
  8021c1:	29 c8                	sub    %ecx,%eax
  8021c3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021c8:	8b 40 40             	mov    0x40(%eax),%eax
  8021cb:	eb 0c                	jmp    8021d9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021cd:	40                   	inc    %eax
  8021ce:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021d3:	75 ce                	jne    8021a3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021d5:	66 b8 00 00          	mov    $0x0,%ax
}
  8021d9:	5b                   	pop    %ebx
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    

008021dc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e2:	89 c2                	mov    %eax,%edx
  8021e4:	c1 ea 16             	shr    $0x16,%edx
  8021e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021ee:	f6 c2 01             	test   $0x1,%dl
  8021f1:	74 1e                	je     802211 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021f3:	c1 e8 0c             	shr    $0xc,%eax
  8021f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021fd:	a8 01                	test   $0x1,%al
  8021ff:	74 17                	je     802218 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802201:	c1 e8 0c             	shr    $0xc,%eax
  802204:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80220b:	ef 
  80220c:	0f b7 c0             	movzwl %ax,%eax
  80220f:	eb 0c                	jmp    80221d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802211:	b8 00 00 00 00       	mov    $0x0,%eax
  802216:	eb 05                	jmp    80221d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802218:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80221d:	5d                   	pop    %ebp
  80221e:	c3                   	ret    
	...

00802220 <__udivdi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	83 ec 10             	sub    $0x10,%esp
  802226:	8b 74 24 20          	mov    0x20(%esp),%esi
  80222a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80222e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802232:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802236:	89 cd                	mov    %ecx,%ebp
  802238:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80223c:	85 c0                	test   %eax,%eax
  80223e:	75 2c                	jne    80226c <__udivdi3+0x4c>
  802240:	39 f9                	cmp    %edi,%ecx
  802242:	77 68                	ja     8022ac <__udivdi3+0x8c>
  802244:	85 c9                	test   %ecx,%ecx
  802246:	75 0b                	jne    802253 <__udivdi3+0x33>
  802248:	b8 01 00 00 00       	mov    $0x1,%eax
  80224d:	31 d2                	xor    %edx,%edx
  80224f:	f7 f1                	div    %ecx
  802251:	89 c1                	mov    %eax,%ecx
  802253:	31 d2                	xor    %edx,%edx
  802255:	89 f8                	mov    %edi,%eax
  802257:	f7 f1                	div    %ecx
  802259:	89 c7                	mov    %eax,%edi
  80225b:	89 f0                	mov    %esi,%eax
  80225d:	f7 f1                	div    %ecx
  80225f:	89 c6                	mov    %eax,%esi
  802261:	89 f0                	mov    %esi,%eax
  802263:	89 fa                	mov    %edi,%edx
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    
  80226c:	39 f8                	cmp    %edi,%eax
  80226e:	77 2c                	ja     80229c <__udivdi3+0x7c>
  802270:	0f bd f0             	bsr    %eax,%esi
  802273:	83 f6 1f             	xor    $0x1f,%esi
  802276:	75 4c                	jne    8022c4 <__udivdi3+0xa4>
  802278:	39 f8                	cmp    %edi,%eax
  80227a:	bf 00 00 00 00       	mov    $0x0,%edi
  80227f:	72 0a                	jb     80228b <__udivdi3+0x6b>
  802281:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802285:	0f 87 ad 00 00 00    	ja     802338 <__udivdi3+0x118>
  80228b:	be 01 00 00 00       	mov    $0x1,%esi
  802290:	89 f0                	mov    %esi,%eax
  802292:	89 fa                	mov    %edi,%edx
  802294:	83 c4 10             	add    $0x10,%esp
  802297:	5e                   	pop    %esi
  802298:	5f                   	pop    %edi
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    
  80229b:	90                   	nop
  80229c:	31 ff                	xor    %edi,%edi
  80229e:	31 f6                	xor    %esi,%esi
  8022a0:	89 f0                	mov    %esi,%eax
  8022a2:	89 fa                	mov    %edi,%edx
  8022a4:	83 c4 10             	add    $0x10,%esp
  8022a7:	5e                   	pop    %esi
  8022a8:	5f                   	pop    %edi
  8022a9:	5d                   	pop    %ebp
  8022aa:	c3                   	ret    
  8022ab:	90                   	nop
  8022ac:	89 fa                	mov    %edi,%edx
  8022ae:	89 f0                	mov    %esi,%eax
  8022b0:	f7 f1                	div    %ecx
  8022b2:	89 c6                	mov    %eax,%esi
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 f0                	mov    %esi,%eax
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	83 c4 10             	add    $0x10,%esp
  8022bd:	5e                   	pop    %esi
  8022be:	5f                   	pop    %edi
  8022bf:	5d                   	pop    %ebp
  8022c0:	c3                   	ret    
  8022c1:	8d 76 00             	lea    0x0(%esi),%esi
  8022c4:	89 f1                	mov    %esi,%ecx
  8022c6:	d3 e0                	shl    %cl,%eax
  8022c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022cc:	b8 20 00 00 00       	mov    $0x20,%eax
  8022d1:	29 f0                	sub    %esi,%eax
  8022d3:	89 ea                	mov    %ebp,%edx
  8022d5:	88 c1                	mov    %al,%cl
  8022d7:	d3 ea                	shr    %cl,%edx
  8022d9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022dd:	09 ca                	or     %ecx,%edx
  8022df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022e3:	89 f1                	mov    %esi,%ecx
  8022e5:	d3 e5                	shl    %cl,%ebp
  8022e7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8022eb:	89 fd                	mov    %edi,%ebp
  8022ed:	88 c1                	mov    %al,%cl
  8022ef:	d3 ed                	shr    %cl,%ebp
  8022f1:	89 fa                	mov    %edi,%edx
  8022f3:	89 f1                	mov    %esi,%ecx
  8022f5:	d3 e2                	shl    %cl,%edx
  8022f7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8022fb:	88 c1                	mov    %al,%cl
  8022fd:	d3 ef                	shr    %cl,%edi
  8022ff:	09 d7                	or     %edx,%edi
  802301:	89 f8                	mov    %edi,%eax
  802303:	89 ea                	mov    %ebp,%edx
  802305:	f7 74 24 08          	divl   0x8(%esp)
  802309:	89 d1                	mov    %edx,%ecx
  80230b:	89 c7                	mov    %eax,%edi
  80230d:	f7 64 24 0c          	mull   0xc(%esp)
  802311:	39 d1                	cmp    %edx,%ecx
  802313:	72 17                	jb     80232c <__udivdi3+0x10c>
  802315:	74 09                	je     802320 <__udivdi3+0x100>
  802317:	89 fe                	mov    %edi,%esi
  802319:	31 ff                	xor    %edi,%edi
  80231b:	e9 41 ff ff ff       	jmp    802261 <__udivdi3+0x41>
  802320:	8b 54 24 04          	mov    0x4(%esp),%edx
  802324:	89 f1                	mov    %esi,%ecx
  802326:	d3 e2                	shl    %cl,%edx
  802328:	39 c2                	cmp    %eax,%edx
  80232a:	73 eb                	jae    802317 <__udivdi3+0xf7>
  80232c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80232f:	31 ff                	xor    %edi,%edi
  802331:	e9 2b ff ff ff       	jmp    802261 <__udivdi3+0x41>
  802336:	66 90                	xchg   %ax,%ax
  802338:	31 f6                	xor    %esi,%esi
  80233a:	e9 22 ff ff ff       	jmp    802261 <__udivdi3+0x41>
	...

00802340 <__umoddi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	83 ec 20             	sub    $0x20,%esp
  802346:	8b 44 24 30          	mov    0x30(%esp),%eax
  80234a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80234e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802352:	8b 74 24 34          	mov    0x34(%esp),%esi
  802356:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80235a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80235e:	89 c7                	mov    %eax,%edi
  802360:	89 f2                	mov    %esi,%edx
  802362:	85 ed                	test   %ebp,%ebp
  802364:	75 16                	jne    80237c <__umoddi3+0x3c>
  802366:	39 f1                	cmp    %esi,%ecx
  802368:	0f 86 a6 00 00 00    	jbe    802414 <__umoddi3+0xd4>
  80236e:	f7 f1                	div    %ecx
  802370:	89 d0                	mov    %edx,%eax
  802372:	31 d2                	xor    %edx,%edx
  802374:	83 c4 20             	add    $0x20,%esp
  802377:	5e                   	pop    %esi
  802378:	5f                   	pop    %edi
  802379:	5d                   	pop    %ebp
  80237a:	c3                   	ret    
  80237b:	90                   	nop
  80237c:	39 f5                	cmp    %esi,%ebp
  80237e:	0f 87 ac 00 00 00    	ja     802430 <__umoddi3+0xf0>
  802384:	0f bd c5             	bsr    %ebp,%eax
  802387:	83 f0 1f             	xor    $0x1f,%eax
  80238a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80238e:	0f 84 a8 00 00 00    	je     80243c <__umoddi3+0xfc>
  802394:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802398:	d3 e5                	shl    %cl,%ebp
  80239a:	bf 20 00 00 00       	mov    $0x20,%edi
  80239f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8023a3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023a7:	89 f9                	mov    %edi,%ecx
  8023a9:	d3 e8                	shr    %cl,%eax
  8023ab:	09 e8                	or     %ebp,%eax
  8023ad:	89 44 24 18          	mov    %eax,0x18(%esp)
  8023b1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023b5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023b9:	d3 e0                	shl    %cl,%eax
  8023bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bf:	89 f2                	mov    %esi,%edx
  8023c1:	d3 e2                	shl    %cl,%edx
  8023c3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023c7:	d3 e0                	shl    %cl,%eax
  8023c9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8023cd:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023d1:	89 f9                	mov    %edi,%ecx
  8023d3:	d3 e8                	shr    %cl,%eax
  8023d5:	09 d0                	or     %edx,%eax
  8023d7:	d3 ee                	shr    %cl,%esi
  8023d9:	89 f2                	mov    %esi,%edx
  8023db:	f7 74 24 18          	divl   0x18(%esp)
  8023df:	89 d6                	mov    %edx,%esi
  8023e1:	f7 64 24 0c          	mull   0xc(%esp)
  8023e5:	89 c5                	mov    %eax,%ebp
  8023e7:	89 d1                	mov    %edx,%ecx
  8023e9:	39 d6                	cmp    %edx,%esi
  8023eb:	72 67                	jb     802454 <__umoddi3+0x114>
  8023ed:	74 75                	je     802464 <__umoddi3+0x124>
  8023ef:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8023f3:	29 e8                	sub    %ebp,%eax
  8023f5:	19 ce                	sbb    %ecx,%esi
  8023f7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023fb:	d3 e8                	shr    %cl,%eax
  8023fd:	89 f2                	mov    %esi,%edx
  8023ff:	89 f9                	mov    %edi,%ecx
  802401:	d3 e2                	shl    %cl,%edx
  802403:	09 d0                	or     %edx,%eax
  802405:	89 f2                	mov    %esi,%edx
  802407:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80240b:	d3 ea                	shr    %cl,%edx
  80240d:	83 c4 20             	add    $0x20,%esp
  802410:	5e                   	pop    %esi
  802411:	5f                   	pop    %edi
  802412:	5d                   	pop    %ebp
  802413:	c3                   	ret    
  802414:	85 c9                	test   %ecx,%ecx
  802416:	75 0b                	jne    802423 <__umoddi3+0xe3>
  802418:	b8 01 00 00 00       	mov    $0x1,%eax
  80241d:	31 d2                	xor    %edx,%edx
  80241f:	f7 f1                	div    %ecx
  802421:	89 c1                	mov    %eax,%ecx
  802423:	89 f0                	mov    %esi,%eax
  802425:	31 d2                	xor    %edx,%edx
  802427:	f7 f1                	div    %ecx
  802429:	89 f8                	mov    %edi,%eax
  80242b:	e9 3e ff ff ff       	jmp    80236e <__umoddi3+0x2e>
  802430:	89 f2                	mov    %esi,%edx
  802432:	83 c4 20             	add    $0x20,%esp
  802435:	5e                   	pop    %esi
  802436:	5f                   	pop    %edi
  802437:	5d                   	pop    %ebp
  802438:	c3                   	ret    
  802439:	8d 76 00             	lea    0x0(%esi),%esi
  80243c:	39 f5                	cmp    %esi,%ebp
  80243e:	72 04                	jb     802444 <__umoddi3+0x104>
  802440:	39 f9                	cmp    %edi,%ecx
  802442:	77 06                	ja     80244a <__umoddi3+0x10a>
  802444:	89 f2                	mov    %esi,%edx
  802446:	29 cf                	sub    %ecx,%edi
  802448:	19 ea                	sbb    %ebp,%edx
  80244a:	89 f8                	mov    %edi,%eax
  80244c:	83 c4 20             	add    $0x20,%esp
  80244f:	5e                   	pop    %esi
  802450:	5f                   	pop    %edi
  802451:	5d                   	pop    %ebp
  802452:	c3                   	ret    
  802453:	90                   	nop
  802454:	89 d1                	mov    %edx,%ecx
  802456:	89 c5                	mov    %eax,%ebp
  802458:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80245c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802460:	eb 8d                	jmp    8023ef <__umoddi3+0xaf>
  802462:	66 90                	xchg   %ax,%ax
  802464:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802468:	72 ea                	jb     802454 <__umoddi3+0x114>
  80246a:	89 f1                	mov    %esi,%ecx
  80246c:	eb 81                	jmp    8023ef <__umoddi3+0xaf>
