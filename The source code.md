​                                         



# The source code

参考资料：

```
https://blog.csdn.net/xiaocainiaos com/joe-w/p/12554360.html
```

## lab1

### boot.s

boot.S的功能是将CPU工作模式从实模式切换到保护模式，关闭了系统中断，并且在最后调用main.c中的bootmain函数（作用是从硬盘读取内核）

#### 备注 （1）

```assembly
/*
启动CPU，切换到32位保护模式，跳转到C代码.
BIOS从硬盘的第一个扇区加载这个代码到物理内存地址为0x7c00的地方
cs=0,ip=7c00
*/
```

**地址7c00**

0x7c00这个地址，它不属于Intel x86平台规范的，而是属于BIOS规范中定义的内容。0x7C00第一次出现在IBM PC 5150的BIOS处理int 19（19号中断）的时候，IBM PC 5150是x86（32位）IBM PC/AT系列的祖先，这款PC于1981年发布，使用了intel 8088（16位）的处理器和16KB的RAM内存，BIOS和微软的基本指令均放在该内存中。

在操作系统被加载后，内存布局如下
/*内存分布（32KB）
+——————— 0×0
| Interrupts vectors（中断向量表）
+——————— 0×400
| BIOS data area（BIOS的数据区域）
+——————— 0×5??
| OS load area（操作系统加载区域）
+——————— 0x7C00
| Boot sector（引导区域）
+——————— 0x7E00
| Boot data/stack（引导数据/堆栈）
+——————— 0x7FFF
| (not used)					*/

由该表可见8088芯片需要占用0x0000到0x03ff打空间用来保存工作出来终端程序的存储位置。所以内存只有0x0400~0x7FFF可以使用。

为了把尽量多的连续内存留给操作系统，主引导记录就被放到了内存地址的尾部。由于一个扇区是512字节，主引导记录本身也会产生数据，需要另外留出512字节保存。所以，它的预留位置就变成了：0x7FFF - 512 -512 + 1 = 0x7c00。

**GDT表**

**GDT(Global Descriptor Table, 全局描述表)**，在实模式和保护模式下，对内存的访问仍采用短地址加偏移地址的方式。其内存的管理方式有两种，**段模式**和**页模式**。在保护模式下，对于一个段的描述包括：**Base Address（基址），Limit（段的最大长度），Access（权限）**，这三个数据加在一起被放在一个 64 bit 的数据结构中，被称为**段描述符**。

初始化GDT表：1. GDT中的第一项描述符设置为空。2. GDT中的第二项描述符为**代码段**使用，设置属性为可读写可执行。3. GDT中的第三项描述符为**数据段**使用，设置属性为可读写。

#### 3 个宏定义

```assembly
下面的3条.set指令类似于宏定义
内核代码段选择子
.set PROT_MODE_CSEG, 0x8         # kernel code segment selector
内核数据段选择子
.set PROT_MODE_DSEG, 0x10        # kernel data segment selector
保护模式启用标志
.set CR0_PE_ON,      0x1         # protected mode enable flag
```

通过赋值便于使用，3个地址。

含义解析：

```c
//PROT_MODE_CSEG
//PROT protect 保护; MODE mode 模式; CSEG SEGMENT 代码段
//PROT_MODE_DSEG
//PROT protect 保护; MODE mode 模式; DSEG SEGMENT 数据段
//CR0_PE_ON
//CR0 控制寄存器; PE PE位用于启用保护模式; ON 开启
```

CR0寄存器的位定义：

PE（Protection Enable）：用于启用保护模式。

MP（Monitor Coprocessor）：用于控制协处理器的监视器功能。

EM（Emulation）：用于控制处理器的工作模式。

TS（Task Switched）：用于指示处理器是否在任务切换中。

ET（Extension Type）：用于指示处理器支持的指令集扩展类型。

NE（Numeric Error）：用于启用浮点数错误的处理。

WP（Write Protect）：用于启用只读内存页的保护。

AM（Alignment Mask）：用于控制内存对齐检查。

NW（Not Write-through）：用于控制缓存的写入策略。

CD（Cache Disable）：用于禁用处理器的缓存。

PG（Paging）：用于启用分页机制。

#### 全局符号 start

```assembly
.globl start
start:
CPU刚启动为16位模式
  .code16                     # Assemble for 16-bit mode
清除CPU的中断允许标志IF
  cli                         # Disable interrupts
清除方向标志位DF
  cld                         # String operations increment
 
  # Set up the important data segment registers (DS, ES, SS).
设置重要的数据段寄存器
ax清零
  xorw    %ax,%ax             # Segment number zero
ds清零
  movw    %ax,%ds             # -> Data Segment
es清零
  movw    %ax,%es             # -> Extra Segment
ss清零
  movw    %ax,%ss             # -> Stack Segment
```

前三行解析：

```assembly
.code16
# 用于指定汇编程序使用16位指令集。告诉编译器使用16位指令集来生成可执行文件，以便在16位处理器上运行。
cli
# CPU不会响应任何中断请求
cld
# 清除方向标志位DF
# DF = 1, 从高地址到低地址; DF = 0, 从低地址到高地址.
```

后4行代码解析：

```assembly
ax清零
  xorw    %ax,%ax             # Segment number zero
ds清零
  movw    %ax,%ds             # -> Data Segment
es清零
  movw    %ax,%es             # -> Extra Segment
ss清零
  movw    %ax,%ss             # -> Stack Segment
# 通过xor(异或),使得ax清零; 后续将3个寄存器清零。
# 经历了 BIOS 后，这三个寄存器存放的内容不确定，需要重置，为进入保护模式做准备。
```

#### 备注 （2）

```assembly
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
```

解析：

```assembly
# 打开A20地址线
# 为了兼容早期的PC机，第20根地址线在实模式下不能使用
# 所以超过1MB的地址，默认就会返回到地址0，重新从0循环计数，
# 下面的代码打开A20地址线
# 0xd1 指令将下一条写到0x60端口的指令写到键盘控制器 804x 的输出端口
# 0xdf 指令使能 A20 线，代表可以进入保护模式。
```

不超过1MB，1MB正好是2^20，所以第20根地址线在实模式下不能使用。

#### 打开A20地址线 

**打开第一个端口**

```assembly
seta20.1:
#从0x64端口读入一个字节的数据到al中
  inb     $0x64, %al               # Wait for not busy
#test指令可以当作and指令，只不过它不会影响操作数
  testb   $0x2, %al
#如果上面的测试中发现al的第2位为0，就不执行该指令
#否则就循环检查
  jnz     seta20.1
  
#将0xd1写入到al中
  movb    $0xd1, %al               # 0xd1 -> port 0x64
#将al中的数据写入到端口0x64中
  outb    %al, $0x64
```

解析：

```assembly
# inb     $0x64, %al
# 将0x64端口中的数据读取到寄存器AL中。

# testb   $0x2, %al
# test是用于测试一个字节中的某个位,因此可以当作and指令，用于下一条指令的判断。

# jnz     seta20.1
# 这个指令的跳转条件是不为零则跳转。如果上面的测试中发现al的第2位为0，就不执行该指令。否则就循环检查。

# movb    $0xd1, %al
# 将0xd1写入到al中

# outb    %al, $0x64
# 将al中的数据写入到端口0x64中，即0xd1，打开端口0x64.
```

**地址？**

1. 0x2是用来判断第2个字节的

2. 0xd1不明白，第209个字节有什么啊？找见的结果是：8042有两个IO端口：0x60和0x64，于是将数据写入8042的P2端口。

   激活流程位： 发送0xd1命令到0x64端口 --> 发送0xdf到0x60，done！

**0x64端口**

0x64端口是PC架构中的**键盘控制器端口**，也称为键盘控制器状态寄存器端口。这个端口是一个8位I/O端口，用于读取键盘控制器的状态信息。

在PC系统中，键盘控制器是一个硬件设备，用于接收来自键盘的输入信号，并将其转换成计算机可以理解的数据格式。键盘控制器还可以控制键盘的LED指示灯，如Num Lock、Caps Lock和Scroll Lock等。

0x64端口中的状态信息包括键盘控制器的状态、是否有键盘输入数据等。通过读取0x64端口，操作系统可以了解键盘控制器的状态，从而进行相应的处理。例如，在键盘输入数据时，操作系统可以通过读取0x64端口来检测是否有新的键盘输入数据，然后使用相应的输入指令从键盘控制器的数据缓冲区中读取数据。

**0x60端口**

其中 0x60 是**数据端口**，可以读出键盘数据，而 0x64 是控制端口，用来发出控制信号。 也就是说，从 0x60 号端口可以读此键盘的按键信息。

在8086汇编语言中，可以使用IN指令将端口0x60中的数据读取到AL寄存器中，例如：

```
IN AL, 0x60 ; 将端口0x60中的数据读取到AL寄存器中
```

需要注意的是，键盘发送的扫描码是按照一定的协议进行编码的，需要进行解码才能得到用户实际按下的键。

**为什么要8042键盘控制器来打开A20地址线**

在早期的PC机中，A20地址线的控制是由8042键盘控制器来实现的。当按下Ctrl+Alt+Del组合键时，8042键盘控制器会发送一个复位信号给CPU，并同时将A20地址线禁用。当CPU重新启动时，A20地址线仍然处于禁用状态。此时，操作系统需要将A20地址线启用，以便能够访问超过1MB的内存空间。

**A20机制**

等待8042 Input buffer为空，8042键盘控制器闲置；
发送Write 8042 Output Port （P2）命令到8042 Input buffer；
等待8042 Input buffer为空；
将8042 Output Port（P2）得到字节的第2位置1，然后写入8042 Input buffer；

**打开第二个端口**

```assembly
seta20.2:
从0x64端口读取一个字节的数据到al中
  inb     $0x64,%al               # Wait for not busy
测试al的第2位是否为0
  testb   $0x2,%al
如果上面的测试中发现al的第2位为0，就不执行该指令
否则就循环检查
  jnz     seta20.2
 
将0xdf写入到al中
  movb    $0xdf,%al               # 0xdf -> port 0x60
将al中的数据写入到0x60端口中
  outb    %al,$0x60
```

解析：

```assembly
# inb     $0x64, %al
# 将0x64端口中的数据读取到寄存器AL中。

# testb   $0x2, %al
# test是用于测试一个字节中的某个位,因此可以当作and指令，用于下一条指令的判断。

# jnz     seta20.2
# 这个指令的跳转条件是不为零则跳转。如果上面的测试中发现al的第2位为0，就不执行该指令。否则就循环检查。

# movb    $0xdf, %al
# 将0xd1写入到al中

# outb    %al, $0x60
# 将al中的数据写入到端口0x64中，即0xdf，打开端口0x60.
```

#### 备注（3）

```assembly
  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
```

解析：

```assembly
# 从实模式切换到保护模式，使用引导GDT和段转换，使虚拟地址与其物理地址相同，以便在切换期间有效内存映射不会改变。
```

#### 进入32位

```assembly
将全局描述符表描述符加载到全局描述符表寄存器
  lgdt    gdtdesc
 
cr0中的第0位为1,表示处于保护模式
cr0中的第0位为0,表示处于实模式
把控制寄存器cr0加载到eax中
  movl    %cr0, %eax
将eax中的第0位设置为1
  orl     $CR0_PE_ON, %eax
将eax中的值装入cr0中
  movl    %eax, %cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
跳转到32位模式中的下一条指令,将处理器切换为32位工作模式
下面这条指令执行的结果会将$PROT_MODE_CSEG(0x8)加载到cs中,cs对应的高速缓冲存储器会加载代码段描述符。同样将$protcseg加载到ip中
  ljmp    $PROT_MODE_CSEG, $protcseg
```

解析：

```assembly
# lgdt    gdtdesc
# 将gdtdesc指向的GDT描述符中的地址和长度信息加载到GDTR寄存器中，从而使得处理器能够正确地访问GDT中的描述符。
# movl    %cr0, %eax
# orl     $CR0_PE_ON, %eax
# movl    %eax, %cr0
# 将cr0调为1，保证进入保护模式。跳转到32位模式中的下一条指令,将处理器切换为32位工作模式。
# ljmp    $PROT_MODE_CSEG, $protcseg
# 通过一个长跳转进入保护模式，CS = $PROT_MODE_CSEG(0x8); IP = $protcseg(若为0x1000)。
# 从实模式跳转到保护模式，并且跳转到代码段中的0x1000处执行代码。
```

**CR0寄存器**

CR0寄存器是x86处理器中的一个控制寄存器，用于控制处理器的运行模式和一些系统级特性。CR0寄存器的名称是Control Register 0，它是一个32位寄存器，包含了多个控制标志位，每个标志位用于控制不同的功能或特性。

- 0 位是保护允许位PE(Protedted Enable)，用于启动保护模式，如果PE位置1，则保护模式启动，如果PE=0，则在实模式下运行。
- 1 位是监控协处理位MP(Moniter coprocessor)，它与第3位一起决定：当TS=1时操作码WAIT是否产生一个“协处理器不能使用”的出错信号。第3位是任务转换位(Task Switch)，当一个任务转换完成之后，自动将它置1。随着TS=1，就不能使用协处理器。
- CR0的第2位是模拟协处理器位 EM (Emulate coprocessor)，如果EM=1，则不能使用协处理器，如果EM=0，则允许使用协处理器。
- 第4位是微处理器的扩展类型位 ET(Processor Extension Type)，其内保存着处理器扩展类型的信息，如果ET=0，则标识系统使用的是287协处理器，如果 ET=1，则表示系统使用的是387浮点协处理器。
- CR0的第31位是分页允许位(Paging Enable)，它表示芯片上的分页部件是否允许工作。
- CR0的第16位是写保护未即WP位(486系列之后)，只要将这一位置0就可以禁用写保护，置1则可将其恢复。

**0x8的翻译**

```assembly
INDEX　　　　　　　　 TI     CPL
0000 0000 1        00      0
#INDEX代表GDT中的索引，TI代表使用GDTR中的GDT， CPL代表处于特权级。
```

PROT_MODE_CSEG选择子选择了GDT中的第1个段描述符。

#### 32位保护模式

```assembly
 .code32                     # Assemble for 32-bit mode    
protcseg:
  # Set up the protected-mode data segment registers
设置保护模式下的数据寄存器
将数据段选择子装入到ax中
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
将ax装入到其他数据段寄存器中，在装入的同时，
数据段描述符会自动的加入到这些段寄存器对应的高速缓冲寄存器中
  movw    %ax, %ds                # -> DS: Data Segment
  movw    %ax, %es                # -> ES: Extra Segment
  movw    %ax, %fs                # -> FS
  movw    %ax, %gs                # -> GS
  movw    %ax, %ss                # -> SS: Stack Segment
  
  # Set up the stack pointer and call into C.
设置栈指针，并且调用c函数
  movl    $start, %esp
调用main.c中的bootmain函数
  call bootmain
```

解析：

```assembly
# .code32
# 将汇编器切换到32位模式。
# protcseg:
# 设置保护模式数据段寄存器
# movw    $PROT_MODE_DSEG, %ax
# 将数据段选择子(0x10)装入到ax中
#  movw    %ax, %ds                # -> DS: Data Segment
#  movw    %ax, %es                # -> ES: Extra Segment
#  movw    %ax, %fs                # -> FS
#  movw    %ax, %gs                # -> GS
#  movw    %ax, %ss                # -> SS: Stack Segment
# 将ax装入到其他数据段寄存器中
# Set up the stack pointer and call into C
# 设置堆栈指针并调用到C中
# movl    $start, %esp
# 栈顶设定在start处,也就是地址0x7c00处.
# call bootmain
# 调用main.c中的bootmain函数.
```

#### 全局描述符表

```assembly
spin:
  jmp spin
 
# Bootstrap GDT
强制4字节对齐
.p2align 2                                # force 4 byte alignment
全局描述符表
gdt:
  SEG_NULL				# null seg
代码段描述符
  SEG(STA_X|STA_R, 0x0, 0xffffffff)	# code seg
数据段描述符
  SEG(STA_W, 0x0, 0xffffffff)	        # data seg
 
全局描述符表对应的描述符
gdtdesc:
  .word   0x17                            # sizeof(gdt) - 1
  .long   gdt                             # address gdt
```

**解析：**

```assembly
# If bootmain returns (it shouldn't), loop.
# 如果bootmain返回(它不应该),循环。
# spin:
# 	jmp spin
# Bootstrap GDT
# 引导GDT
# .p2align 2            	# force 4 byte alignment
# 强制4字节对齐
# gdt:
# 全局描述符表
#  SEG_NULL				# null seg
# 代码段描述符
#  SEG(STA_X|STA_R, 0x0, 0xffffffff)	# code seg
# 数据段描述符
#  SEG(STA_W, 0x0, 0xffffffff)	        # data seg
# gdtdesc:
# 全局描述符表对应的描述符
#  .word   0x17             # sizeof(gdt) - 1
#  .long   gdt              # address gdt
```

**来自于mmu.h头文件的信息**

```assembly
# STA_X 0x8
# STA_R 0x2
# STA_W 0x0

# SEG(type, base, lim, dpl)的解析:
# define SEG(type, base, lim, dpl) 									\
# { ((lim) >> 12) & 0xffff, (base) & 0xffff, ((base) >> 16) & 0xff,	\
#  type, 1, dpl, 1, (unsigned) (lim) >> 28, 0, 0, 1, 1,				\
#   (unsigned) (base) >> 24 }
# 由于 xv6 其实并没有使用分段机制，也就是说数据段和代码段的位置没有区分，所以数据段和代码段的起始地址都是0x0，大小都是0xffffffff。

#Null segment:
#define SEG_NULL{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
```

**SEG(type, base, lim, dpl)**

在这个宏定义中，它接受四个参数：type、base、lim和dpl。这些参数分别表示段的类型、基地址、限制长度和特权级别。它的作用是生成一段汇编代码，用于定义一个新的段描述符（Segment Descriptor）。

#### 待解决

```assembly
# $strat的值是多少？
# 强制4字节对齐的目的是什么？
# 看不明白，SEG。
```

### main.c

main.c的功能引导加载程序通过 x86 的特殊 I/O 指令直接访问 IDE 磁盘设备寄存器，从而从硬盘读取内核。

```c
/**********************************************************************
 * This a dirt simple boot loader, whose sole job is to boot
 * an ELF kernel image from the first IDE hard disk.
 *
 * DISK LAYOUT
 *  * This program(boot.S and main.c) is the bootloader.  It should
 *    be stored in the first sector of the disk.
 *
 *  * The 2nd sector onward holds the kernel image.
 *
 *  * The kernel image must be in ELF format.
 *
 * BOOT UP STEPS
 *  * when the CPU boots it loads the BIOS into memory and executes it
 *
 *  * the BIOS intializes devices, sets of the interrupt routines, and
 *    reads the first sector of the boot device(e.g., hard-drive)
 *    into memory and jumps to it.
 *
 *  * Assuming this boot loader is stored in the first sector of the
 *    hard-drive, this code takes over...
 *
 *  * control starts in boot.S -- which sets up protected mode,
 *    and a stack so C code then run, then calls bootmain()
 *
 *  * bootmain() in this file takes over, reads in the kernel and jumps to it.
 **********************************************************************/
```

翻译：

```
这是一个非常简单的引导加载程序，它的唯一工作是从第一个IDE硬盘引导一个ELF内核映像。

磁盘布局
这个程序(boot.s和main.c)是引导加载程序。它应该存储在磁盘的第一个扇区中。第二个扇区保存内核映像。内核映像必须是ELF格式。

启动步骤
当CPU启动时，它将BIOS加载到内存中并执行它。BIOS初始化设备，中断例程集，并读取引导设备的第一个扇区(例如:(硬盘驱动器)进入内存并跳转到它。假设此引导加载程序存储在硬盘驱动器的第一个扇区中，则此代码接管…。控制从boot.s开始——它设置了保护模式和堆栈，因此C代码然后运行，然后调用bootmain()。bootmain()在这个文件中接管，读取内核并跳转到它。
```

读一个硬盘扇区流程:

1. 等待磁盘准备好
2. 发出读取扇区的命令
3. 等待磁盘准备好
4. 把磁盘扇区数据读到指定内存

#### 全局

```c
#define SECTSIZE	512
#define ELFHDR		((struct Elf *) 0x10000) // scratch space 

void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);
```

解析：

```c
#define SECTSIZE	512
#define ELFHDR		((struct Elf *) 0x10000) // scratch space
//SECTSIZE定义了磁盘扇区的大小，为512字节。
//ELFHDR定义了一个指向0x10000地址处的struct Elf结构体指针。
void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);
//readsect()函数用于从磁盘的指定扇区读取数据。
//readseg()函数用于从磁盘的指定偏移地址读取指定长度的数据，并将数据存储到指定的内存地址中。
```

#### readseg函数

**函数的作用**

```c
// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// 从内核读取'offset'处的'count'字节到物理地址'pa'。
// 后续这段是逐一读取每个扇区的代码,从pa到end_pa。然后，将物理地址pa读取到内存中。
```

**readseg函数**

```c
void readseg(uint32_t pa, uint32_t count, uint32_t offset){
    uint32_t end_pa;
// 物理地址:physical address -> pa。
// end_pa设置为从pa开始, 连续count个字节后的地址。
// 内存区间的结束地址。
	end_pa = pa + count;

// SECTSIZE代表一个扇区（sector）的大小, 通常是512字节。
// 将pa变量对应的物理地址按照页的大小进行对齐。
	pa &= ~(SECTSIZE - 1);

// 字节偏移量转换为相应的扇区号,内核从扇区1开始。
	offset = (offset / SECTSIZE) + 1;

/*
当前代码读取磁盘扇区的方式。为了提高读取速度，可以一次读取多个扇区。虽然当前代码写入了比要求的更多的内存，但是这并不会造成问题，因为内存是按照递增顺序加载的，不会造成内存重叠的情况。
*/
	while (pa < end_pa) {
/*
由于还没有启用分页功能，因此使用了一个标识段映射来访问内存。这种方式可以直接使用物理地址来访问内存，因为没有进行虚拟地址到物理地址的转换。但是，一旦启用了MMU，虚拟地址将会被转换为物理地址，因此不能再直接使用物理地址来访问内存，而需要使用虚拟地址。
*//*
读取一个扇区的数据，并将其存储在物理地址pa指向的内存中。然后，将物理地址pa增加一个扇区大小，以指向下一个扇区的地址。最后，将偏移量offset增加1，以指向下一个扇区的偏移量。这样就可以连续读取多个扇区的数据。
*/
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
		offset++;
	}
}
```

#### readsect函数

**函数的作用**

```c
//用于从磁盘的指定扇区读取数据。
//dst是指向存储数据的缓冲区的指针，offset是要读取的扇区在磁盘上的偏移量。
```

**readsect函数**

```c
void readsect(void *dst, uint32_t offset)
{
// 等待磁盘准备好
	waitdisk();

// outb将data的值输出到指定的I/O端口中。
// outb(ushort port, uchar data)
	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

// 等待磁盘准备好
	waitdisk();

// 读取扇区
/*
从0x1F0端口读取数据。并将数据存储到指定的内存地址dst中。insl指令每次可以读取4个字节的数据。
*/
	insl(0x1F0, dst, SECTSIZE/4);
}
```

#### waitdisk函数

**函数的作用**

```c
// 等待磁盘准备好
// 函数会不断地检测磁盘状态寄存器（0x1F7端口）的值，直到磁盘准备就绪为止。
```

**waitdisk函数**

```c
void waitdisk(void){
/*
不断地检测磁盘状态寄存器（0x1F7端口）的值，直到磁盘准备就绪为止。
*/
	while ((inb(0x1F7) & 0xC0) != 0x40)
}
// 判断方法：将该值与0xC0进行按位与运算，以判断磁盘是否忙碌或出错。如果磁盘忙碌或出错，则继续等待；否则，表示磁盘已经准备就绪，跳出循环。
```

#### bootmain函数

**函数的作用**

```c
// 这个函数的main.c,串联起来所有函数。
// 引导加载程序通过 x86 的特殊 I/O 指令直接访问 IDE 磁盘设备寄存器，从而从硬盘读取内核。
```

**bootmain函数**

```c
void bootmain(void){
// ph起始位置,eph结束位置。
	struct Proghdr *ph, *eph;

// 从磁盘读取第一页
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);

// ELF是否合法的判断
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

// 加载每个程序段(忽略ph标志)
// 开始赋值起始位置ph和结束位置eph。
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
// for循环,调用readseg函数将每个段从磁盘中读取到内存中。
	for (; ph < eph; ph++)
// p_pa是该段的加载地址(以及物理地址),p_memsz是该段在内存中的大小,p_offset是该段在磁盘上的偏移量。
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

// 从ELF头调用入口点注意:不返回!
// 将ELF文件头中的e_entry字段所指向的地址转换为一个无参数、无返回值的函数指针类型，并通过调用该函数指针开始执行程序的入口点。
// 入口为e_entry字段所指向的地址。
	((void (*)(void)) (ELFHDR->e_entry))();

// 出错后,发出错误信号,死循环直到手动中断
bad:
	outw(0x8A00, 0x8A00);
	outw(0x8A00, 0x8E00);
	while (1)
		/* do nothing */;
}
```



#### 相关补充

**1.内存重叠**

内存重叠是指在内存中有两个或多个区域的地址范围部分或全部重叠。这种情况下，读取或写入内存时可能会发生意想不到的结果，因为不同的内存区域会相互影响。例如，如果在一个内存区域中写入数据时，同时也覆盖了另一个内存区域的一部分，那么后者的数据就会被破坏。因此，在编写程序时应该避免内存重叠，确保每个内存区域都有唯一的地址范围。

**2.e_entry**

在 ELF 头中还有一个对我们很重要的域，它叫做 `e_entry`。这个域保留着程序入口的链接地址：程序的 `.text` 节中的内存地址就是将要被执行的程序的地址。



### entry.s

#### 部分内容（抄袭）

进入这里的断点是16位的0x7d63

```assembly
# _start 指定了ELF入口点。由于在引导加载程序进入此代码时我们还没有设置虚拟内存，因此我们需要引导加载程序跳转到入口点的 *物理* 地址。
# RELOC将虚拟地址转为物理地址。

.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
# 我们还没有设置虚拟内存，所以我们从启动加载程序加载内核的物理地址运行:1MB(加上一些字节)。但是，C代码被链接到在KERNBASE+1MB下运行。因此，我们设置了一个简单的页面目录，将虚拟地址[KERNBASE, KERNBASE+4MB)转换为物理地址[0,4mb)。在实验2的mem_init中建立真正的页表之前，这个4MB的区域已经足够了。
# 将 entry_pgdir 的物理地址给 cr3寄存器，entry_pgdir中定义了VA到PA的映射
# cr3 寄存器使得处理器可以翻译线性地址为物理地址
	movl	$(RELOC(entry_pgdir)), %eax
	movl	%eax, %cr3
# 保护模式、分页、写保护
	movl	%cr0, %eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
	movl	%eax, %cr0

# 进入高地址
	mov	$relocated, %eax
	jmp	*%eax
relocated:

	movl	$0x0,%ebp			# nuke frame pointer

	movl	$(bootstacktop),%esp

	# 跳转到 c 代码
	call	i386_init
```

### console.c——cputchar

console.c 描述了控制台的基本功能，这个代码数量有些抽象啊。400+。下面只简单说明。这段程序存在I/O延迟程序，开头那段代码，因为历史上的PC设计缺陷，需要延迟函数以确保某些设备或操作完成。

总共5段代码，用来描述控制台的基本功能。

1. 串行I/O代码

   通过串行通信接口进行数据传输的方法。

2. 并口输出代码

   通过并行接口（也称为并口）将数据从计算机发送到外部设备。

3. 文本模式CGA/VGA显示输出代码

4. 键盘输入代码

5. 通用的设备无关控制台代码

   这里我们管理控制台输入缓冲区，

   存储从键盘或串口接收到的字符

   当对应的中断发生时。

**具体是，通过控制台输入和输出。输入来自键盘或串行端口。输出被写入屏幕和串行端口。**

**printf.c相关代码**

```c
void cputchar(int c){
	cons_putc(c);
}

/*输出一个字符到控制台,分别表示将字符c输出到串口、并口和CGA显示器上。为了实现多种输出方式和兼容性。*/
static void
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
```

### printfmt.c

这里只节选和printf相关部分

#### 注释

```c
// Stripped-down primitive printf-style formatting routines,
// used in common by printf, sprintf, fprintf, etc.
// This code is also used by both the kernel and user programs.
```

**翻译**

```c
//精简后的原始printf风格格式化例程，
// printf、sprintf、fprintf等常用
//该代码也被内核和用户程序使用
```

#### 具体代码

```c
//格式化和打印字符的主函数,有printfmt, vprintfmt, sprintbuf, sprintputch, vsnprintf, snprintf.这里我们只讨论vprintfmt。

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
    //register修饰符暗示编译程序相应的变量将被频繁地使用，
    //如果可能的话，应将其保存在CPU的寄存器中，以加快其存储速度
	register const char *p;
	register int ch, err;
    //unsigned的作用就是将数字类型无符号化。
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	
    //遍历输入的第一个参数，即格式化字符串
    //先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，
    //所以它们就是要直接显示在屏幕上的
    //中间如果遇到'\0'，代表这个字符串的访问结束
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
        }
    //通过putch函数调用，可以将字符输出到指定的输出设备上。这个具体根据函数需求来设置，你可以去看看printf.c中设置的.
			putch(ch, putdat);
		}

		// Process a %-escape sequence
        // 处理完%前面的数据了，开始处理%后面的转义序列，后续全部内容都是除了它们。
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
    /*
    padc = ' ';将填充字符padc设置为默认值空格。
	width = -1;将字段宽度width设置为默认值-1，表示没有指定宽度。
	precision = -1;将精度precision设置为默认值-1，表示没有指定精度。
	lflag = 0;将lflag标志位设置为0，表示没有使用l长度修饰符。
	altflag = 0;将altflag标志位设置为0，表示没有使用其他特殊标志。
    */
    
    //后续就是%后的逐个字符进行输出处理，各种判断条件。
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
        // 右置pad标志
		case '-':
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
        // 用0代替空格填充的标志
		case '0':
			padc = '0';
			goto reswitch;

		// width field	宽度（位数），如%.2d
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)	长修饰符
		case 'l':
			lflag++;
			goto reswitch;

		// character	字符
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;

		// error message	错误信息
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
			break;

		// string	字符串
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
			break;

		// (signed) decimal	整型输出
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
			goto number;

		// unsigned decimal	无符号十进制整数
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
			goto number;

		// (unsigned) octal	无符号八进制整数
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;

		// pointer	指针
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;

		// (unsigned) hexadecimal	十六进制整数
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
			break;

		// escaped '%' character	转义的'%'字符
		case '%':
			putch(ch, putdat);
			break;

		// unrecognized escape sequence - just print it literally
        // 无法识别的转义序列-直接打印它
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
```

### printf.c

```c
// Simple implementation of cprintf console output for the kernel,
// based on printfmt() and the kernel console's cputchar().
//内核的cprintf控制台输出的简单实现，
//基于printfmt()和内核控制台的cputchar()。

#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

//这个函数是将获取的字符输出，输出到console.c设置的位置
static void
putch(int ch, int *cnt)
{
	cputchar(ch);
	*cnt++;
}

//这个函数是将字符按照固定规则输出，规则由printfmt.c决定
int
vcprintf(const char *fmt, va_list ap)
{
	int cnt = 0;

	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

// 整体用来上述第二个函数输出，va_list,va_start,va_end设置在#include<inc/stdarg.h>头文件中。
int
cprintf(const char *fmt, ...)
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
	va_end(ap);

	return cnt;
}

//整体是3号函数调用2号函数，2号调用1号函数。
/*
参数说明:
(void*)putch：这是一个指向函数的指针，用于指定输出字符的函数。在这里，putch 函数将被调用以输出格式化后的字符。
&cnt：这是一个指向整数变量 cnt 的指针。在 vprintfmt 函数中，将使用该指针来记录输出字符的数量。
fmt：这是一个字符串，表示格式化字符串，即包含格式化指令的字符串。
ap：这是一个 va_list 类型的变量，用于访问可变参数列表中的参数。
*/
```

**stdarg.h** 头文件定义了一个变量类型 **va_list** 和三个宏，这三个宏可用于在参数个数未知（即参数个数可变）时获取函数中的参数。

可变参数的函数通在参数列表的末尾是使用省略号(,...)定义的。

[ void va_start(va_list ap, last_arg)](https://www.runoob.com/cprogramming/c-macro-va_start.html) 这个宏初始化 **ap** 变量，它与 **va_arg** 和 **va_end** 宏是一起使用的。**last_arg** 是最后一个传递给函数的已知的固定参数，即省略号之前的参数。

[void va_end(va_list ap)](https://www.runoob.com/cprogramming/c-macro-va_end.html)这个宏允许使用了 **va_start** 宏的带有可变参数的函数返回。如果在从函数返回之前没有调用 **va_end**，则结果为未定义。





**补充演示**

```c
#include<stdarg.h>
#include<stdio.h>

int sum(int, ...);

int main(void)
{
   printf("10、20 和 30 的和 = %d\n",  sum(3, 10, 20, 30) );
   printf("4、20、25 和 30 的和 = %d\n",  sum(4, 4, 20, 25, 30) );

   return 0;
}

int sum(int num_args, ...)
{
   int val = 0;
   va_list ap;
   int i;

   va_start(ap, num_args);
   for(i = 0; i < num_args; i++)
   {
      val += va_arg(ap, int);
   }
   va_end(ap);
 
   return val;
}
```

让我们编译并运行上面的程序，这将产生以下结果：

```
10、20 和 30 的和 = 60
4、20、25 和 30 的和 = 79
```

使用可变参数的模式非常固定，如下：

```c
 va_list args;               // 准备接受参数的列表对象
 va_start(args, fmt);        // 从`...`中取出参数到args中，并指定...之前的参数
 vprintf(fmt, args);         // 将取出的参数列表传给真正的实现函数
 va_end(args);               // 释放参数列表
```



### kdebug.c

```c
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right, int type, uintptr_t addr){
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		//搜索最早的类型正确的stab
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
			continue;
		}

		// 实际的二分查找
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
			*region_right = m - 1;
			r = m - 1;
		} else {
			// 完全匹配` addr `，但继续循环查找
			// *region_right
			*region_left = m;
			l = m;
			addr++;
		}
	}

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		//查找包含` addr `的最右区域
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
```

这段代码实现了一个二分查找算法，用于在给定的 `stabs` 数组中查找符合条件的元素。下面是对代码的逐行解释：

1. `stab_binsearch` 是一个静态函数，用于执行二分查找算法。它接受以下参数：
   - `stabs`：指向 `struct Stab` 结构体数组的指针。
   - `region_left` 和 `region_right`：指向表示查找范围的两个整数的指针。
   - `type`：要查找的元素类型。
   - `addr`：要查找的地址。
2. `int l = *region_left, r = *region_right, any_matches = 0;` 定义了三个局部变量 `l`、`r` 和 `any_matches`，并初始化为 `region_left`、`region_right` 和 `0`。
3. `while (l <= r) {` 开始一个循环，循环条件是 `l` 小于等于 `r`。
4. `int true_m = (l + r) / 2, m = true_m;` 定义了两个局部变量 `true_m` 和 `m`，并将 `(l + r) / 2` 的值赋给它们。
5. `while (m >= l && stabs[m].n_type != type)` 开始一个循环，循环条件是 `m` 大于等于 `l` 并且 `stabs[m].n_type` 不等于 `type`。
6. `if (m < l) {` 判断条件，如果 `m` 小于 `l`，表示在区间 `[l, m]` 中没有找到符合条件的元素。
7. `l = true_m + 1;` 更新 `l` 的值为 `true_m + 1`，继续下一次循环。
8. `any_matches = 1;` 将 `any_matches` 的值设置为 `1`，表示在区间 `[l, m]` 中找到了符合条件的元素。
9. `if (stabs[m].n_value < addr) {` 判断条件，如果 `stabs[m].n_value` 小于 `addr`。
10. `*region_left = m;` 更新 `region_left` 的值为 `m`。
11. `l = true_m + 1;` 更新 `l` 的值为 `true_m + 1`。
12. `else if (stabs[m].n_value > addr) {` 判断条件，如果 `stabs[m].n_value` 大于 `addr`。
13. `*region_right = m - 1;` 更新 `region_right` 的值为 `m - 1`。
14. `r = m - 1;` 更新 `r` 的值为 `m - 1`。
15. `else {` 如果以上条件都不满足，表示找到了与 `addr` 相等的元素。
16. `*region_left = m;` 更新 `region_left` 的值为 `m`。
17. `l = m;` 更新 `l` 的值为 `m`。
18. `addr++;` 将 `addr` 的值加一。
19. `if (!any_matches)` 判断条件，如果 `any_matches` 的值为假（即没有找到符合条件的元素）。
20. `*region_right = *region_left - 1;` 更新 `region_right` 的值为 `region_left - 1`。
21. `else {` 如果以上条件都不满足，表示找到了符合条件的元素。
22. `for (l = *region_right; l > *region_left && stabs[l].n_type != type; l--)` 开始一个循环，循环条件是 `l` 大于 `region_left` 并且 `stabs[l].n_type` 不等于 `type`。
23. `*region_left = l;` 更新 `region_left` 的值为 `l`。

代码通过二分查找算法在 `stabs` 数组中查找符合条件的元素，并根据查找结果更新 `region_left` 和 `region_right` 的值。



## lab2

### pmap.c

### `tlb_invalidate` 

`tlb_invalidate` 函数的作用是使 TLB 中某个虚拟地址的映射失效

```
void
tlb_invalidate(pde_t *pgdir, void *va)
{
	invlpg(va);
}
```



### `page_decref`

`page_decref` 函数的作用是对 `struct PageInfo` 结构体中的引用计数进行递减操作，并在引用计数变为0时释放该页的内存。

```
void
page_decref(struct PageInfo* pp)
{
	if (--pp->pp_ref == 0)
		page_free(pp);
}
```



### `check_kern_pgdir`

ChatGPT摸鱼版本

```c
static void
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;

	// 函数检查了页表中的pages数组。
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// 函数检查了物理内存的映射。
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// 函数检查了内核栈的映射。
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// 函数通过检查PDE的权限来验证页表的正确性。
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
				assert(pgdir[i] & PTE_P);
				assert(pgdir[i] & PTE_W);
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
}
```

更加详尽的请看这里

```
首先，函数检查了页表中的pages数组。它通过使用check_va2pa函数，将虚拟地址UPAGES + i映射到物理地址，并与PADDR(pages) + i进行比较。如果二者相等，说明页表正确地映射了pages数组。


接下来，函数检查了物理内存的映射。它通过使用check_va2pa函数，将虚拟地址KERNBASE + i映射到物理地址i，并进行比较。这个部分的目的是确保内核虚拟地址空间中的每个页面都正确地映射到物理内存中的相应页面。


然后，函数检查了内核栈的映射。它通过使用check_va2pa函数，将虚拟地址KSTACKTOP - KSTKSIZE + i映射到物理地址PADDR(bootstack) + i，并进行比较。这个部分的目的是确保内核栈在虚拟地址空间中的映射正确。


接下来，函数通过检查PDE的权限来验证页表的正确性。根据给定的索引i，它根据特定的规则验证PDE的权限设置。对于一些特定的索引，如PDX(UVPT)、PDX(KSTACKTOP-1)和PDX(UPAGES)，函数验证相应的PDE应该设置了PTE_P位。对于其他索引，如果索引大于等于PDX(KERNBASE)，则验证PDE应该设置了PTE_P和PTE_W位。对于其他情况，函数验证PDE应该为0。
```



`check_page_installed_pgdir`

ChatGPT摸鱼版

```c
static void
check_page_installed_pgdir(void)
{
	struct PageInfo *pp, *pp0, *pp1, *pp2;
	struct PageInfo *fl;
	pte_t *ptep, *ptep1;
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	//首先，函数分配了三个页面(pp0, pp1, pp2)，然后释放了pp0页面。接着，函数使用memset函数将pp1和pp2页面的内容分别设置为1和2。
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
	assert((pp1 = page_alloc(0)));
	assert((pp2 = page_alloc(0)));
	page_free(pp0);
	memset(page2kva(pp1), 1, PGSIZE);
	memset(page2kva(pp2), 2, PGSIZE);
	//函数使用page_insert函数将pp1页面插入到虚拟地址PGSIZE处，并设置PTE_W权限。然后，函数通过访问PGSIZE处的内存来验证页面是否正确地插入到了页表中，并且可以读写。如果读取的内容为0x01010101U，说明插入成功。
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
	assert(pp1->pp_ref == 1);
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
	//函数使用page_insert函数将pp2页面插入到虚拟地址PGSIZE处，并设置PTE_W权限。然后，函数再次访问PGSIZE处的内存来验证页面是否正确地插入到了页表中，并且可以读写。如果读取的内容为0x02020202U，说明插入成功。
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
	assert(pp2->pp_ref == 1);
	assert(pp1->pp_ref == 0);
	//函数通过修改PGSIZE处的内存来验证页面是否可以写入。函数将PGSIZE处的内存内容设置为0x03030303U，并通过访问pp2页面的内存来验证修改是否成功。如果读取的内容为0x03030303U，说明修改成功。
	*(uint32_t *)PGSIZE = 0x03030303U;
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
	//函数使用page_remove函数将虚拟地址PGSIZE处的页面从页表中移除，并验证pp2页面的引用计数是否正确地减少为0。
	page_remove(kern_pgdir, (void*) PGSIZE);
	assert(pp2->pp_ref == 0);

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	//通过修改kern_pgdir[0]来强制获取pp0页面，并验证pp0页面的引用计数是否正确地增加为1。然后，函数将kern_pgdir[0]设置为0，以释放对pp0页面的引用。
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
	pp0->pp_ref = 0;

	// free the pages we took
	//函数释放了pp0页面，并输出一条成功的消息。
	page_free(pp0);

	cprintf("check_page_installed_pgdir() succeeded!\n");
}
```



## homework:xv6 system calls

### syscall.c

作用：实现了系统调用的处理逻辑，包括参数获取、越界检查和函数调用。

```
#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "syscall.h"

// User code makes a system call with INT T_SYSCALL.
// System call number in %eax.
// Arguments on the stack, from the user call to the C
// library system call function. The saved user %esp points
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
  struct proc *curproc = myproc();

  if(addr >= curproc->sz || addr+4 > curproc->sz)
    return -1;
  *ip = *(int*)(addr);
  return 0;
}

// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
  char *s, *ep;
  struct proc *curproc = myproc();

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
    if(*s == 0)
      return s - *pp;
  }
  return -1;
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
}

// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
  int i;
  struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
    return -1;
  *pp = (char*)i;
  return 0;
}

// Fetch the nth word-sized system call argument as a string pointer.
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}

extern int sys_chdir(void);
extern int sys_close(void);
extern int sys_dup(void);
extern int sys_exec(void);
extern int sys_exit(void);
extern int sys_fork(void);
extern int sys_fstat(void);
extern int sys_getpid(void);
extern int sys_kill(void);
extern int sys_link(void);
extern int sys_mkdir(void);
extern int sys_mknod(void);
extern int sys_open(void);
extern int sys_pipe(void);
extern int sys_read(void);
extern int sys_sbrk(void);
extern int sys_sleep(void);
extern int sys_unlink(void);
extern int sys_wait(void);
extern int sys_write(void);
extern int sys_uptime(void);

static int (*syscalls[])(void) = {
[SYS_fork]    sys_fork,
[SYS_exit]    sys_exit,
[SYS_wait]    sys_wait,
[SYS_pipe]    sys_pipe,
[SYS_read]    sys_read,
[SYS_kill]    sys_kill,
[SYS_exec]    sys_exec,
[SYS_fstat]   sys_fstat,
[SYS_chdir]   sys_chdir,
[SYS_dup]     sys_dup,
[SYS_getpid]  sys_getpid,
[SYS_sbrk]    sys_sbrk,
[SYS_sleep]   sys_sleep,
[SYS_uptime]  sys_uptime,
[SYS_open]    sys_open,
[SYS_write]   sys_write,
[SYS_mknod]   sys_mknod,
[SYS_unlink]  sys_unlink,
[SYS_link]    sys_link,
[SYS_mkdir]   sys_mkdir,
[SYS_close]   sys_close,
};

void
syscall(void)
{
  int num;
  struct proc *curproc = myproc();

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
```

函数给上面了这里只说一下作用

```
fetchint函数：这个函数用于从当前进程中获取地址为addr的整数值，并将其存储在ip指针指向的位置。在获取之前，会检查地址是否越界，即addr是否在当前进程的地址空间范围内。

fetchstr函数：这个函数用于从当前进程中获取地址为addr的以空字符结尾的字符串，并将指针pp指向该字符串的起始位置。在获取之前，会检查地址是否越界，即addr是否在当前进程的地址空间范围内。该函数会返回字符串的长度，不包括空字符。

argint函数：这个函数用于获取系统调用的第n个32位参数，并将其存储在ip指针指向的位置。它通过计算栈中参数的地址来获取参数的值。

argptr函数：这个函数用于获取系统调用的第n个指针参数，并将其存储在pp指针指向的位置。在获取之前，会检查指针是否合法，即指针是否指向当前进程的地址空间内，并且指针指向的内存块大小为size。

argstr函数：这个函数用于获取系统调用的第n个字符串参数，并将指针指向该字符串的起始位置。在获取之前，会检查地址是否越界，并且检查字符串是否以空字符结尾。

syscalls数组：这个数组存储了系统调用的函数指针，每个系统调用对应一个函数。数组的索引对应系统调用的编号。

syscall函数：这个函数是系统调用的处理函数。它首先获取当前进程的系统调用编号，然后根据编号在syscalls数组中找到对应的系统调用函数，并执行该函数。如果系统调用编号无效，会打印错误信息并将返回值设置为-1。

总的来说，这段代码实现了系统调用的处理逻辑，包括参数获取、越界检查和函数调用。它将用户代码的系统调用转发给对应的系统调用函数，并将返回值返回给用户代码。
```



### lapic.c——cmostime

从CMOS芯片中读取实时时钟的日期和时间信息，并将其存储到`struct rtcdate`类型的变量`r`中。

```
// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
  struct rtcdate t1, t2;
  int sb, bcd;
  
  //sb变量存储从CMOS芯片的状态寄存器中读取的值。
  sb = cmos_read(CMOS_STATB);

  //通过对sb变量进行位运算，判断BCD编码是否被使用
  bcd = (sb & (1 << 2)) == 0;

  //无限循环来确保在读取时间信息的过程中，CMOS芯片不会修改时间。
  for(;;) {
  //在每次循环中，首先调用fill_rtcdate函数将当前时间信息存储到t1变量中。然后，通过读取CMOS芯片的状态寄存器来判断是否正在更新时间信息。如果正在更新，继续下一次循环；
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
  //否则，再次调用fill_rtcdate函数将当前时间信息存储到t2变量中。
    fill_rtcdate(&t2);
    
  //如果相等，表示成功读取到时间信息，退出循环。
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
```



## Homework: xv6 lazy page allocation

### sysproc.c——sys_sbrk

调整的堆空间的大小。

```
int
sys_sbrk(void)
{
  int addr;
  int n;

  //argint函数来获取用户传递的整数参数n的值。argint函数用于从用户空间中获取指定地址的整数值，并将其存储到指定的变量中。
  if(argint(0, &n) < 0)
    return -1;
    
  //使用myproc函数获取当前进程的指针，并通过该指针获取当前进程的堆空间的结束地址sz。
  addr = myproc()->sz;
  
  //使用growproc函数来调整进程的堆空间大小。
  if(growproc(n) < 0)
    return -1;
    
  //返回调整前的堆空间的结束地址addr
  return addr;
}
```

### vm.c——allocuvm

在用户地址空间中分配新页面的函数`allocuvm`。

```c
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
  char *mem;
  uint a;

  //检查newsz是否大于等于内核基址KERNBASE
  if(newsz >= KERNBASE)
  //如果是，则返回0，表示分配失败。这是因为内核基址以下的地址空间是保留给内核使用的，不能分配给用户进程。
    return 0;
  //函数检查newsz是否小于oldsz，如果是，则返回oldsz，表示不需要进行新的分配。
  if(newsz < oldsz)
    return oldsz;
  
  //函数使用PGROUNDUP函数将oldsz向上舍入到最近的页面边界，得到起始地址a。
  a = PGROUNDUP(oldsz);
  //函数进入一个循环，从a开始，每次增加一个页面大小（PGSIZE）。
  for(; a < newsz; a += PGSIZE){
    mem = kalloc();
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    //函数使用memset函数将该内存区域清零。
    memset(mem, 0, PGSIZE);
    //映射。如果映射失败（返回值小于0），则输出错误信息并调用deallocuvm函数释放已分配的页面，并释放刚刚分配的内存，最后返回0，表示分配失败。
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
      cprintf("allocuvm out of memory (2)\n");
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  //函数返回newsz，表示成功分配了新的地址空间大小。
  return newsz;
}
```

### trap.c——trap

```c
void
trap(struct trapframe *tf)
{
//函数首先检查trapno字段是否等于T_SYSCALL，如果是，则表示发生了系统调用中断。
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
    myproc()->tf = tf;
    syscall();
    if(myproc()->killed)
      exit();
    return;
  }

//如果trapno字段不等于T_SYSCALL，则进入switch语句，根据不同的中断类型进行处理。
//时钟中断（T_IRQ0 + IRQ_TIMER）
// IDE 中断（T_IRQ0 + IRQ_IDE）
//键盘中断（T_IRQ0 + IRQ_KBD）
//串口中断（T_IRQ0 + IRQ_COM1）
//其他中断（T_IRQ0 + 7和T_IRQ0 + IRQ_SPURIOUS）
  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
    break;

  //函数检查当前进程是否为空，或者当前进程的特权级（cs 寄存器的低两位）是否为 0。如果是，则表示在内核中发生了意外的中断，函数输出错误信息并调用panic函数终止系统。
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    //如果当前进程不为空，并且当前进程的特权级为用户态（DPL_USER），则表示用户进程出现了错误。
    cprintf("pid %d %s: trap %d err %d on cpu %d "
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
  }

  //函数检查当前进程是否被标记为killed，并且当前进程的特权级为用户态。
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  //函数检查当前进程是否处于运行状态，并且当前中断是时钟中断。
  if(myproc() && myproc()->state == RUNNING &&
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  //函数再次检查当前进程是否被标记为killed，并且当前进程的特权级为用户态。
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
```



### sysproc.c——sys_alarm

这段代码的作用是设置当前进程的警报间隔和警报处理程序。

```
int
    sys_alarm(void)
    {
      int ticks;
      void (*handler)();

//通过 argint 函数从用户空间获取 ticks 的值，并将其保存在当前进程的 alarmticks 变量中。然后，通过 argptr 函数从用户空间获取 handler 的值，并将其保存在当前进程的 alarmhandler 变量中。
      if(argint(0, &ticks) < 0)
        return -1;
      if(argptr(1, (char**)&handler, 1) < 0)
        return -1;
      myproc()->alarmticks = ticks;
      myproc()->alarmhandler = handler;
      return 0;
    }

```



## lab3

### trap.h(kern)

```c
/* See COPYRIGHT for copyright information. */

#ifndef JOS_KERN_TRAP_H
#define JOS_KERN_TRAP_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

#include <inc/trap.h>
#include <inc/mmu.h>

/* The kernel's interrupt descriptor table */
//声明了一个全局变量idt，表示内核的中断描述符表。
extern struct Gatedesc idt[];
//声明了一个全局变量idt_pd，表示中断描述符表的伪描述符。
extern struct Pseudodesc idt_pd;

//初始化中断描述符表，并注册中断处理函数。
void trap_init(void);
//为每个处理器核心初始化中断处理。
void trap_init_percpu(void);
//打印寄存器的值。
void print_regs(struct PushRegs *regs);
//打印陷阱帧的信息。
void print_trapframe(struct Trapframe *tf);
//处理页面错误异常。
void page_fault_handler(struct Trapframe *);
//打印函数调用链的回溯信息。
void backtrace(struct Trapframe *);

#endif /* JOS_KERN_TRAP_H */
```

**伪描述符**

伪描述符（Pseudodescriptor）是一种数据结构，用于加载和管理段描述符表（Descriptor Table）。在x86架构中，段描述符表包含了用于管理内存段的描述符。

伪描述符由以下字段组成：

- `limit`：表示段描述符表的大小（以字节为单位）。
- `base`：表示段描述符表的起始地址。

**通过加载伪描述符，处理器可以将段描述符表的信息加载到相应的寄存器中，以便在访问内存段时能够正确地解析和使用段描述符。**

在操作系统中，伪描述符通常用于加载中断描述符表（Interrupt Descriptor Table，IDT）。IDT是用于管理中断和异常处理的数据结构，包含了与每个中断和异常相关的处理程序的地址和特权级等信息。

通过加载伪描述符，处理器可以将IDT的信息加载到中断描述符表寄存器（IDTR）中，使得处理器能够正确地响应和处理中断和异常。

需要注意的是，伪描述符只是一个用于加载和管理段描述符表的数据结构，并不表示实际的段描述符表。段描述符表是由一系列段描述符组成的数据结构，每个段描述符包含了有关内存段的信息，如段的起始地址、大小、访问权限等。



### trap.h(inc)

简述：

- 异常和中断的编号：定义了一系列异常和中断的编号，如除法错误、调试异常、非屏蔽中断等。
- IRQ_OFFSET：定义了硬件中断的偏移量，用于计算实际的硬件中断号。
- 硬件中断号：定义了一些硬件中断的编号，如定时器中断、键盘中断、串口中断等。
- 结构体PushRegs：保存了在异常发生时由pusha指令压入栈中的寄存器值。
- 结构体Trapframe：保存了在异常发生时的上下文信息，包括寄存器值、段选择子、中断号、错误码、指令指针等。

```
#ifndef JOS_INC_TRAP_H
#define JOS_INC_TRAP_H

// Trap numbers
// These are processor defined:
#define T_DIVIDE	0 	//除法错误
#define T_DEBUG 	1 	//调试异常
#define T_NMI 		2 	//不可屏蔽中断
#define T_BRKPT 	3 	//断点
#define T_OFLOW 	4 	//溢出
#define T_BOUND 	5 	//边界检查
#define T_ILLOP 	6 	//非法操作码
#define T_DEVICE 	7 	//设备不可用
#define T_DBLFLT 	8 	//双精度浮点数
/* #define T_COPROC 9 *///保留(不是由最近的处理器生成的)
#define T_TSS 		10 	//无效的进程切换段
#define T_SEGNP 	11 	//段不存在
#define T_STACK 	12 	//栈异常
#define T_GPFLT 	13 	//一般保护故障
#define T_PGFLT 	14 	//缺页异常
/* #define T_RES 	15 *///保留
#define T_FPERR 	16 	//浮点数错误
#define T_ALIGN 	17 	//对齐检查
#define T_MCHK 		18 	//机器检查
#define T_SIMDERR 	19 	// SIMD浮点错误

// These are arbitrarily chosen, but with care not to overlap
// processor defined exceptions or interrupt vectors.
#define T_SYSCALL   48		// system call
#define T_DEFAULT   500		// catchall

#define IRQ_OFFSET	32	// IRQ 0 corresponds to int IRQ_OFFSET

// Hardware IRQ numbers. We receive these as (IRQ_OFFSET+IRQ_WHATEVER)
#define IRQ_TIMER        0
#define IRQ_KBD          1
#define IRQ_SERIAL       4
#define IRQ_SPURIOUS     7
#define IRQ_IDE         14
#define IRQ_ERROR       19

#ifndef __ASSEMBLER__

#include <inc/types.h>

struct PushRegs {
	/*由pusha推送的寄存器*/
	uint32_t reg_edi;
	uint32_t reg_esi;
	uint32_t reg_ebp;
	uint32_t reg_oesp;		/* Useless */
	uint32_t reg_ebx;
	uint32_t reg_edx;
	uint32_t reg_ecx;
	uint32_t reg_eax;
} __attribute__((packed));

struct Trapframe {
	struct PushRegs tf_regs;
	uint16_t tf_es;
	uint16_t tf_padding1;
	uint16_t tf_ds;
	uint16_t tf_padding2;
	uint32_t tf_trapno;
	/* below here defined by x86 hardware */
	uint32_t tf_err;
	uintptr_t tf_eip;
	uint16_t tf_cs;
	uint16_t tf_padding3;
	uint32_t tf_eflags;
	/* below here only when crossing rings, such as from user to kernel */
	uintptr_t tf_esp;
	uint16_t tf_ss;
	uint16_t tf_padding4;
} __attribute__((packed));


#endif /* !__ASSEMBLER__ */

#endif /* !JOS_INC_TRAP_H */
```

```
Trapframe结构体的成员包括：
    struct PushRegs tf_regs：一个名为tf_regs的PushRegs结构体，用于保存异常发生时由pusha指令压入栈中的寄存器值。
    uint16_t tf_es和uint16_t tf_ds：段选择子，用于保存异常发生时的附加段选择子。
    uint16_t tf_padding1和uint16_t tf_padding2：填充字段，用于对齐。
    uint32_t tf_trapno：保存异常号，表示引发异常的具体类型。
    uint32_t tf_err：保存错误码，用于某些异常类型的附加错误信息。
    uintptr_t tf_eip：保存异常发生时的指令指针，即下一条要执行的指令的地址。
    uint16_t tf_cs：保存异常发生时的代码段选择子。
    uint16_t tf_padding3：填充字段，用于对齐。
    uint32_t tf_eflags：保存异常发生时的标志寄存器的值，包括状态标志和控制标志等。
    uintptr_t tf_esp：保存异常发生时的栈指针，即当前栈的顶部地址。
    uint16_t tf_ss：保存异常发生时的栈段选择子。
    uint16_t tf_padding4：填充字段，用于对齐。
```



### mmu.h(inc)——SETGATE宏

注释

```c
//建立一个正常的中断/陷阱描述符。
// - isstrap: 1表示陷阱(= exception)门，0表示中断门。
//参见i386参考文档的9.6.1.3节:“中断门和陷门之间的区别在于对IF(中断使能标志)的影响。一个通过中断门引导的中断会重置，从而防止其他中断干扰当前的中断处理程序。随后的IRET指令将IF恢复为栈上的EFLAGS图像中的值。通过陷阱门的中断不会改变。”
// - sel:中断/陷阱处理程序的代码段选择器
// - off:中断/陷阱处理程序代码段中的偏移量
// - dpl:描述符权限级别-
//软件显式使用int指令调用该中断/陷阱门所需的特权级别
#define SETGATE(gate, istrap, sel, off, dpl)			\
{								\
	(gate).gd_off_15_0 = (uint32_t) (off) & 0xffff;		\
	(gate).gd_sel = (sel);					\
	(gate).gd_args = 0;					\
	(gate).gd_rsv1 = 0;					\
	(gate).gd_type = (istrap) ? STS_TG32 : STS_IG32;	\
	(gate).gd_s = 0;					\
	(gate).gd_dpl = (dpl);					\
	(gate).gd_p = 1;					\
	(gate).gd_off_31_16 = (uint32_t) (off) >> 16;		\
}
```



### syscall.c——syscall

这段代码的作用是将系统调用号和参数传递给操作系统内核，并获取返回值。

```
//参数:系统调用号（num），一个检查参数（check），以及五个参数（a1、a2、a3、a4、a5）。
static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;

	// Generic system call: pass system call number in AX,
	// up to five parameters in DX, CX, BX, DI, SI.
	// Interrupt kernel with T_SYSCALL.
	//
	// The "volatile" tells the assembler not to optimize
	// this instruction away just because we don't use the
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
	
//在int指令后面的冒号后，: "=a" (ret)表示将返回值存储在变量ret中。冒号后的部分: "i" (T_SYSCALL), "a" (num), "d" (a1), "c" (a2), "b" (a3), "D" (a4), "S" (a5)表示将系统调用号和参数传递给相应的寄存器。
	asm volatile("int %1\n"
		     : "=a" (ret)
		     : "i" (T_SYSCALL),
		       "a" (num),
		       "d" (a1),
		       "c" (a2),
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
//最后的: "cc", "memory"表示这个指令可能会改变条件码和任意内存位置。

//在系统调用执行后，代码会根据检查参数和返回值进行相应的处理。如果检查参数为真且返回值大于0，那么会调用panic函数触发内核崩溃。
	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
```



```c
//它接受一个字符串指针s和一个长度len作为参数。在这个函数中，首先需要检查用户是否有权限读取内存区域[s, s+len)。如果没有权限，则会销毁当前的环境（进程）。具体的权限检查和销毁环境的操作需要在LAB 3中实现。然后，通过调用cprintf函数打印用户提供的字符串。
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
//它从系统控制台读取一个字符，并返回该字符的ASCII码。这个函数内部调用了cons_getc函数来实现从控制台读取字符的功能。
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
//它返回当前环境（进程）的envid（环境ID）。这个函数直接返回了curenv->env_id，即当前环境的env_id成员变量。
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//它接受一个envid作为参数，用于销毁指定的环境。首先通过envid2env函数将envid转换为对应的环境指针，并进行权限检查。如果指定的环境不存在或者调用者没有权限改变该环境，则返回对应的错误码。否则，根据当前环境和指定环境的关系，打印相应的提示信息，并调用env_destroy函数销毁指定的环境。
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}
```



### inc/env.h

```c
/* See COPYRIGHT for copyright information. */

#ifndef JOS_INC_ENV_H
#define JOS_INC_ENV_H

#include <inc/types.h>
#include <inc/trap.h>
#include <inc/memlayout.h>

typedef int32_t envid_t;

// 定义了环境ID envid_t 的三个部分：
    1.最高位是0，用于表示这是一个有效的环境ID。
    2.中间的21位是一个唯一标识符（uniqueifier），用于区分在不同时间创建的具有相同环境索引的环境。
    3.最低的10位是环境索引（environment index），用于表示环境在envs[]数组中的索引。
// An environment ID 'envid_t' has three parts:
//
// +1+---------------21-----------------+--------10--------+
// |0|          Uniqueifier             |   Environment    |
// | |                                  |      Index       |
// +------------------------------------+------------------+
//                                       \--- ENVX(eid) --/
//
// The environment index ENVX(eid) equals the environment's index in the
// 'envs[]' array.  The uniqueifier distinguishes environments that were
// created at different times, but share the same environment index.
//
// All real environments are greater than 0 (so the sign bit is zero).
// envid_ts less than 0 signify errors.  The envid_t == 0 is special, and
// stands for the current environment.

//定义了一些与环境相关的常量：
    1.LOG2NENV表示环境的数量的对数，即环境数组的大小为2的LOG2NENV次方。
    2.NENV表示环境的数量，等于1左移LOG2NENV位。
    3.ENVX(envid)是一个宏，用于从环境ID中提取环境索引。
    
#define LOG2NENV		10
#define NENV			(1 << LOG2NENV)
#define ENVX(envid)		((envid) & (NENV - 1))

// 定义了enum类型env_status，表示环境的状态。包括：
    1.ENV_FREE：空闲状态，表示该环境未被使用。
    2.ENV_DYING：正在退出状态，表示该环境正在退出。
    3.ENV_RUNNABLE：可运行状态，表示该环境可以被调度运行。
    4.ENV_RUNNING：运行状态，表示该环境正在运行。
    5.ENV_NOT_RUNNABLE：不可运行状态，表示该环境不能被调度运行。
    
// Values of env_status in struct Env
enum {
	ENV_FREE = 0,
	ENV_DYING,
	ENV_RUNNABLE,
	ENV_RUNNING,
	ENV_NOT_RUNNABLE
};

// EnvType,表示特殊的环境类型。ENV_TYPE_USER，表示用户环境。
// Special environment types
enum EnvType {
	ENV_TYPE_USER = 0,
};

// 定义了struct Env，表示一个环境的数据结构。partA
	1.保存寄存器的env_tf
	2.指向下一个空闲Env的指针env_link
    3.环境的唯一标识符env_id
    4.父环境的唯一标识符env_parent_id
    5.环境类型env_type
    5.环境的状态env_status
    6.环境运行的次数env_runs
    7.地址空间相关的信息env_pgdir。

        
        
struct Env {
	struct Trapframe env_tf;	// Saved registers
	struct Env *env_link;		// Next free Env
	envid_t env_id;			// Unique environment identifier
	envid_t env_parent_id;		// env_id of this env's parent
	enum EnvType env_type;		// Indicates special system environments
	unsigned env_status;		// Status of the environment
	uint32_t env_runs;		// Number of times environment has run

	// Address space
	pde_t *env_pgdir;		// Kernel virtual address of page dir


#endif // !JOS_INC_ENV_H
```





## lab4

### init.c

**boot_aps**

```c
// 启动非引导(AP)处理器。
static void
boot_aps(void)
{
    // mpentry_start 和 mpentry_end，它们指向 AP 入口代码的起始地址和结束地址。
	extern unsigned char mpentry_start[], mpentry_end[];
    // code存储内存区域。
	void *code;
    // 循环变量 c 是 struct CpuInfo 类型的指针，表示每个 CPU 的信息。
	struct CpuInfo *c;

    
    // 将 AP 入口代码复制到未使用的内存地址 MPENTRY_PADDR 处。
    // 使用 memmove() 函数将 mpentry_start 到 mpentry_end 之间的代码复制到 code 指向的内存区域。
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

    
    // 通过一个循环逐个启动每个 AP。循环变量 c 是 struct CpuInfo 类型的指针，表示每个 CPU 的信息。
	for (c = cpus; c < cpus + ncpu; c++) {
        // 跳过该处理器，因为它已经启动了。
		if (c == cpus + cpunum())  
			continue;

        
		// 设置 mpentry_kstack 变量，告诉 mpentry.S 使用哪个栈。
        // mpentry_kstack 是每个 CPU 的内核栈地址加上 KSTKSIZE 的结果。
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
        
        
		// 在mpentry_Start启动CPU
        // 调用 lapic_startap() 函数，向相应的 AP 的 LAPIC 发送中断请求（IPI），指示 AP 从 code 指向的地址开始执行。
		lapic_startap(c->cpu_id, PADDR(code));
        
        
		//在mp_main()中等待CPU完成一些基本设置。
        //使用一个循环等待，直到 AP 在其 cpu_status 字段中发出 CPU_STARTED 标志，表示它已经启动完成。
		while(c->cpu_status != CPU_STARTED)
			;
	}
}
```

**mp_main**

```c
// 用于非引导处理器（AP）的设置代码。
void
mp_main(void)
{
	// 我们现在处于高EIP，可以安全地切换到kern_pgdir 
	// 通过 lcr3(PADDR(kern_pgdir)) 将页表切换到内核页表，确保在高特权级下运行。
	// 然后使用 cprintf 打印当前启动的处理器的编号。
	lcr3(PADDR(kern_pgdir));
	cprintf("SMP: CPU %d starting\n", cpunum());

    // 初始化本地高级可编程中断控制器（Local APIC）,用于处理中断。
    // 初始化当前处理器的运行环境，包括设置段描述符、设置栈等。
    // 初始化当前处理器的中断处理函数。
    // 用于告知 boot_aps() 函数当前处理器已经启动。
	lapic_init();
	env_init_percpu();
	trap_init_percpu();
	xchg(&thiscpu->cpu_status, CPU_STARTED); 

	// 现在我们已经完成了一些基本设置，调用sched_yield()在该CPU上开始运行进程。
	// 但要确保一次只有一个CPU可以进入调度器
	// Your code here:

	// 在你完成练习6后把它去掉
	for (;;);
}
```

**高EIP，可以安全地切换到`kern_pgdir`？**

在x86架构中，EIP（指令指针寄存器）存储了下一条将要执行的指令的地址。在引导处理器（BSP）启动时，EIP指向引导加载程序（bootloader）的代码。当引导加载程序完成其任务并将控制权交给操作系统内核时，EIP会被设置为内核的入口点，即内核代码的起始地址。

在引导加载程序执行期间，操作系统内核的页表（页目录和页表）还没有被初始化。因此，如果在引导加载程序的代码中直接切换到内核的页表（kern_pgdir），会导致无法正确访问内核的地址空间。

为了解决这个问题，操作系统设计者采取了一个两步骤的切换过程。首先，引导加载程序会将内核的页表的物理地址存储在一个特定的位置，例如在一个全局变量中。然后，在引导加载程序将控制权转移到内核之前，它会使用 `lcr3` 指令将EIP切换到一个安全的页表，这个页表只映射引导加载程序和内核所需的最小地址空间。

一旦内核接管控制权，它会初始化完整的页表，并将内核的页表的物理地址存储在一个全局变量中。此后，内核就可以使用 `lcr3` 指令将EIP切换到完整的内核页表（kern_pgdir），从而可以安全地访问完整的内核地址空间。

因此，在 `mp_main` 函数中，通过将EIP切换到 `kern_pgdir`，可以安全地切换到完整的内核页表，使得非引导处理器能够正确访问内核的地址空间。



### trap.c

```c
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	// 将 TSS 的内核栈指针设置为 KSTACKTOP，即内核堆栈的顶部。
	// 将 TSS 的内核栈段选择子设置为 GD_KD，表示使用内核数据段。
	// 将 TSS 的 I/O 位图偏移量设置为 sizeof(struct Taskstate)，用于防止未授权的环境进行 I/O 操作。
	ts.ts_esp0 = KSTACKTOP;
	ts.ts_ss0 = GD_KD;
	ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	// 初始化 GDT（全局描述符表）中 TSS 描述符的内容。使用 SEG16 宏来创建一个 32 位 TSS 描述符，其中 STS_T32A 表示 TSS 的类型为可用的 32 位 TSS。
	// 将 TSS 描述符的 sd_s 字段设置为 0，表示该段是一个系统段。
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;

	// 加载 TSS 选择器，将 TSS 描述符的索引加载到任务寄存器（Task Register，TR）中，以便在任务切换时使用正确的 TSS。
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// 加载 IDT，将 IDT 描述符表的地址加载到 IDTR（IDT Register）寄存器中，以便在发生中断时能够正确地处理中断。
	lidt(&idt_pd);
```



### kern/env.h (宏)

```c
#define ENV_CREATE(x, type)										\
	do {														\
		extern uint8_t ENV_PASTE3(_binary_obj_, x, _start)[];	\
		env_create(ENV_PASTE3(_binary_obj_, x, _start),			\
			   type);											\
	} while (0)

#endif // !JOS_KERN_ENV_H
```

在宏定义中，使用了`ENV_PASTE3`宏来拼接字符串，它会将`_binary_obj_`、`x`和`_start`连接起来，形成一个新的标识符。这个标识符通常用于访问二进制对象文件的起始地址。

然后，调用了`env_create`函数，传入了通过`ENV_PASTE3`拼接得到的标识符作为参数，以及`type`参数。

其中，`obj_file`是二进制对象文件的名称，`env_type`是环境的类型。宏定义会根据提供的参数自动生成相应的代码来创建环境。



### inc/env.h (lab4新增)

```
    // Exception handling
	void *env_pgfault_upcall;	// Page fault upcall entry point

	// Lab 4 IPC
	bool env_ipc_recving;		// Env is blocked receiving
	void *env_ipc_dstva;		// VA at which to map received page
	uint32_t env_ipc_value;		// Data value sent to us
	envid_t env_ipc_from;		// envid of the sender
	int env_ipc_perm;			// Perm of page mapping received
};
// 定义了struct Env，表示一个环境的数据结构。partB        
    1.env_pgfault_upcall：指向一个函数的指针，该函数用于处理页面错误（page fault）异常。
    2.env_ipc_recving：表示该环境是否正在等待接收消息。
    3.env_ipc_dstva：接收到的页面映射的虚拟地址。
    4.env_ipc_value：发送给该环境的数据值。
    5.env_ipc_from：发送者的环境标识符。
    6.env_ipc_perm：接收到的页面映射的权限。
```



### inc/trap.h (lab4新增)

```c
struct UTrapframe {
	/* information about the fault */
	uint32_t utf_fault_va;	/* va for T_PGFLT, 0 otherwise */
	uint32_t utf_err;
	/* trap-time return state */
	struct PushRegs utf_regs;
	uintptr_t utf_eip;
	uint32_t utf_eflags;
	/* the trap-time stack to return to */
	uintptr_t utf_esp;
} __attribute__((packed));

保存用户态陷入异常时的上下文信息。

utf_fault_va：表示发生页面错误（Page Fault）时的虚拟地址。如果异常不是页面错误，则该值为 0。
utf_err：表示发生异常时的错误码。
utf_regs：一个名为 PushRegs 的结构体，用于保存通用寄存器的值。
utf_eip：表示发生异常时的指令指针（EIP）的值。
utf_eflags：表示发生异常时的标志寄存器（EFLAGS）的值。
utf_esp：表示发生异常时的栈指针（ESP）的值。

__attribute__((packed)) 是一个编译器指令，用于告诉编译器按照紧凑的方式对齐结构体的成员变量，以减小结构体的大小。
```



### inc/mmu.h

#### 1.分页数据结构和常量

##### 1. 线性地址

```c
// PDX、PTX、PGOFF和PGNUM宏如下所示分解线性地址。
//要从PDX(la)、PTX(la)和PGOFF(la)构造线性地址la，
//使用PGADDR(PDX(la)， PTX(la)， PGOFF(la))。
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |      Index     |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \---------- PGNUM(la) ----------/
//

1.PGNUM(la): 该宏用于从虚拟地址中提取出页面号（page number）。
2.PDX(la): 该宏用于从虚拟地址中提取出页目录索引（page directory index）。
3.PTX(la): 该宏用于从虚拟地址中提取出页表索引（page table index）。
4.PGOFF(la): 该宏用于从虚拟地址中提取出页内偏移（offset within a page）。
5.PGADDR(d, t, o): 该宏用于根据给定的页目录索引（d）、页表索引（t）和页内偏移（o）构建线性地址（linear address）。
```



##### 2. 页目录和页表常量

```c
#define NPDENTRIES	1024		//每个页目录对应的页目录项
#define NPTENTRIES	1024		//每个页表项

#define PGSIZE		4096		//页面映射的字节数
#define PGSHIFT		12		 	// log2(PGSIZE)

#define PTSIZE		(PGSIZE*NPTENTRIES) //由页目录项映射的字节数
#define PTSHIFT		22		// log2(PTSIZE)

#define PTXSHIFT	12		// PTX在线性地址中的偏移量
#define PDXSHIFT	22		// PDX在线性地址中的偏移量
```



##### 3. 页表/目录项标志

```c
#define PTE_P		0x001	// 存在
#define PTE_W		0x002	// 可写
#define PTE_U		0x004	// 用户
#define PTE_PWT		0x008	// Write-Through
#define PTE_PCD		0x010	// 禁用Cache
#define PTE_A		0x020	// 访问
#define PTE_D		0x040	// 脏
#define PTE_PS		0x080	// 页大小
#define PTE_G		0x100	// 全局
```



##### 4. 其他

```c
//内核不会使用PTE_AVAIL位，硬件也不会解释，因此用户进程可以任意设置它们。
#define PTE_AVAIL	0xE00	//供软件使用

// PTE_SYSCALL中的标志可用于系统调用。(其他人可能不行)
#define PTE_SYSCALL	(PTE_AVAIL | PTE_P | PTE_W | PTE_U)

//页表或页目录项中的地址
#define PTE_ADDR(pte)	((physaddr_t) (pte) & ~0xFFF)
```



##### 5. 控制寄存器标志

```c
#define CR0_PE		0x00000001	// 启用保护
#define CR0_MP		0x00000002	// 监控协处理器
#define CR0_EM		0x00000004	// 仿真
#define CR0_TS		0x00000008	// 进程切换
#define CR0_ET		0x00000010	// 扩展类型
#define CR0_NE		0x00000020	// 数值错误
#define CR0_WP		0x00010000	// 写保护
#define CR0_AM		0x00040000	// 对齐掩码
#define CR0_NW		0x20000000	// 不透写
#define CR0_CD		0x40000000	// 禁用缓存
#define CR0_PG		0x80000000	// 分页

#define CR4_PCE		0x00000100	// 启用性能计数器
#define CR4_MCE		0x00000040	// 启用机器检查
#define CR4_PSE		0x00000010	// 扩展页面大小
#define CR4_DE		0x00000008	// 调试扩展
#define CR4_TSD		0x00000004	// 禁用时间戳
#define CR4_PVI		0x00000002	// 受保护模式虚拟中断
#define CR4_VME		0x00000001	// V86模式扩展
```



##### 6. Eflags寄存器

```c
// Eflags register
#define FL_CF		0x00000001	// 进位标志
#define FL_PF		0x00000004	// 校验标志
#define FL_AF		0x00000010	// 辅助进位标志
#define FL_ZF		0x00000040	// 零标志
#define FL_SF		0x00000080	// 标志标志
#define FL_TF		0x00000100	// Trap标志
#define FL_IF		0x00000200	// 中断标志
#define FL_DF		0x00000400	// 方向标志
#define FL_OF		0x00000800	// 溢出标志
#define FL_IOPL_MASK	0x00003000	// I/O 特权级别位掩码
#define FL_IOPL_0	0x00000000	//   IOPL == 0
#define FL_IOPL_1	0x00001000	//   IOPL == 1
#define FL_IOPL_2	0x00002000	//   IOPL == 2
#define FL_IOPL_3	0x00003000	//   IOPL == 3
#define FL_NT		0x00004000	// 嵌套任务
#define FL_RF		0x00010000	// 恢复标志
#define FL_VM		0x00020000	// 虚拟 8086 模式
#define FL_AC		0x00040000	// 对齐检查
#define FL_VIF		0x00080000	// 虚拟中断标志
#define FL_VIP		0x00100000	// 等待虚拟中断
#define FL_ID		0x00200000	// ID 标志
```



##### 7. 页面错误代码

```
#define FEC_PR		0x1	// 违反保护机制导致缺页异常
#define FEC_WR		0x2	// 写操作导致缺页异常
#define FEC_U		0x4	// 用户态发生缺页异常
```



#### 2.划分数据结构和常量

##### 1. 用于在汇编中构建GDT项的宏。

**填充GDT中未使用的条目，指定段的类型、基址和限制。**

```
//定义全局描述符表（Global Descriptor Table，GDT）的段描述符。
#define SEG_NULL						\
	.word 0, 0;						\
	.byte 0, 0, 0, 0
#define SEG(type,base,lim)					\
	.word (((lim) >> 12) & 0xffff), ((base) & 0xffff);	\
	.byte (((base) >> 16) & 0xff), (0x90 | (type)),		\
		(0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)
```

##### 2. 段描述符

```
struct Segdesc {
	unsigned sd_lim_15_0 : 16;  // 段限制的低位
	unsigned sd_base_15_0 : 16; // 段基地址的低位
	unsigned sd_base_23_16 : 8; // 段基地址的中位
	unsigned sd_type : 4;       // 段类型(参见STS_constants)
	unsigned sd_s : 1;          // 0 = 系统 1 = 应用程序
	unsigned sd_dpl : 2;        // 描述符权限等级
	unsigned sd_p : 1;          // Present
	unsigned sd_lim_19_16 : 4;  // 段限制的高位
	unsigned sd_avl : 1;        // 未使用(供软件使用)
	unsigned sd_rsv1 : 1;       // 保留
	unsigned sd_db : 1;         // 0 = 16位段，1 = 32位段
	unsigned sd_g : 1;          // 粒度:设置时限制缩放4K
	unsigned sd_base_31_24 : 8; // 段基地址的高位
};
```



**段**

```
// Null segment
#define SEG_NULL	{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
// Segment that is loadable but faults when used
#define SEG_FAULT	{ 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0 }
// Normal segment
#define SEG(type, base, lim, dpl) 
```



##### 3. 段类型bit

```c
// Application segment type bits
#define STA_X		0x8	    // 可执行段
#define STA_E		0x4	    // 向下扩展（非可执行段）
#define STA_C		0x4	    // 符合标准的代码段(仅可执行)
#define STA_W		0x2	    // 可写(非可执行段)
#define STA_R		0x2	    // 可读(可执行段)
#define STA_A		0x1	    // 可访问

// System segment type bits
#define STS_T16A	0x1	    // 可用的16位TSS
#define STS_LDT		0x2	    // 本地描述符表
#define STS_T16B	0x3	    // 繁忙的16位TSS
#define STS_CG16	0x4	    // 16位呼叫门
#define STS_TG		0x5	    // 任务门/ Coum传输
#define STS_IG16	0x6	    // 16位中断门
#define STS_TG16	0x7	    // 16位陷阱门
#define STS_T32A	0x9	    // 可用的32位TSS
#define STS_T32B	0xB	    // 繁忙的32位TSS
#define STS_CG32	0xC	    // 32位呼叫门
#define STS_IG32	0xE	    // 32位中断门
#define STS_TG32	0xF	    // 32位陷阱门
```



#### 3.陷阱

##### 1. 任务状态段格式(如Pentium体系结构书所述)

```
struct Taskstate {
	uint32_t ts_link;	// 旧的ts选择器
	uintptr_t ts_esp0;	// 栈指针和段选择器
	uint16_t ts_ss0;	// 在特权级别增加之后
	uint16_t ts_padding1;
	uintptr_t ts_esp1;
	uint16_t ts_ss1;
	uint16_t ts_padding2;
	uintptr_t ts_esp2;
	uint16_t ts_ss2;
	uint16_t ts_padding3;
	physaddr_t ts_cr3;	// 页面目录基础
	uintptr_t ts_eip;	// 上一次任务切换时保存的状态
	uint32_t ts_eflags;
	uint32_t ts_eax;	// 保存的更多状态(寄存器)
	uint32_t ts_ecx;
	uint32_t ts_edx;
	uint32_t ts_ebx;
	uintptr_t ts_esp;
	uintptr_t ts_ebp;
	uint32_t ts_esi;
	uint32_t ts_edi;
	uint16_t ts_es;		// 保存更多的状态(段选择器)
	uint16_t ts_padding4;
	uint16_t ts_cs;
	uint16_t ts_padding5;
	uint16_t ts_ss;
	uint16_t ts_padding6;
	uint16_t ts_ds;
	uint16_t ts_padding7;
	uint16_t ts_fs;
	uint16_t ts_padding8;
	uint16_t ts_gs;
	uint16_t ts_padding9;
	uint16_t ts_ldt;
	uint16_t ts_padding10;
	uint16_t ts_t;		// 触发任务开关
	uint16_t ts_iomb;	// I/O映射基地地址
};
```



##### 2.用于中断和陷阱的门描述符

```
struct Gatedesc {
	unsigned gd_off_15_0 : 16;   // 段中低16位的偏移量
	unsigned gd_sel : 16;        // 段选择器
	unsigned gd_args : 5;        // # args, 0表示中断/陷阱门
	unsigned gd_rsv1 : 3;        // 保留(我猜应该是0)
	unsigned gd_type : 4;        // 类型(STS_ {TG、IG32 TG32})
	unsigned gd_s : 1;           // 必须为0(系统)
	unsigned gd_dpl : 2;         // 描述符(表示新的)特权级别
	unsigned gd_p : 1;           // Present
	unsigned gd_off_31_16 : 16;  // 段偏移量的高位
};
```



```
// Set up a normal interrupt/trap gate descriptor.
#define SETGATE(gate, istrap, sel, off, dpl)			\
{														\
	(gate).gd_off_15_0 = (uint32_t) (off) & 0xffff;		\
	(gate).gd_sel = (sel);								\
	(gate).gd_args = 0;									\
	(gate).gd_rsv1 = 0;									\
	(gate).gd_type = (istrap) ? STS_TG32 : STS_IG32;	\
	(gate).gd_s = 0;									\
	(gate).gd_dpl = (dpl);								\
	(gate).gd_p = 1;									\
	(gate).gd_off_31_16 = (uint32_t) (off) >> 16;		\
}

// Set up a call gate descriptor.
#define SETCALLGATE(gate, sel, off, dpl)           	    \
{														\
	(gate).gd_off_15_0 = (uint32_t) (off) & 0xffff;		\
	(gate).gd_sel = (sel);								\
	(gate).gd_args = 0;									\
	(gate).gd_rsv1 = 0;									\
	(gate).gd_type = STS_CG32;							\
	(gate).gd_s = 0;									\
	(gate).gd_dpl = (dpl);								\
	(gate).gd_p = 1;									\
	(gate).gd_off_31_16 = (uint32_t) (off) >> 16;		\
}
```



##### 3.用于LGDT、LLDT和LIDT指令的伪描述符。

```
struct Pseudodesc {
	uint16_t pd_lim;		// 限制
	uint32_t pd_base;		// 基地址
} __attribute__ ((packed));
```



## lab5

### fs.c

```c
void
check_super(void)
//该函数的主要目的是检查文件系统的超级块是否有效。
bool
block_is_free(uint32_t blockno)
//检查块位图是否表明块'blockno'是空闲的。
//如果内存块是空闲的，返回1，否则返回0
void
free_block(uint32_t blockno)    
//在位图中标记一个空闲块
int
alloc_block(void)
//搜索位图并分配空闲块当您分配一个块时，立即将更改后的位图块刷新到磁盘。
void
check_bitmap(void)
//验证文件系统位图。
void
fs_init(void)
//初始化文件系统
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
//根据文件结构、文件块号和分配标志查找或分配磁盘块号。 
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
//将blk设置为文件f的第一个块将映射到的内存地址。
static int
dir_lookup(struct File *dir, const char *name, struct File **file)   
//尝试在dir中找到一个名为"name"的文件。如果是，将*file设置为它。    
static int
dir_alloc_file(struct File *dir, struct File **file)   //设置*file指向dir中的一个空闲文件结构。调用者负责填写文件字段。
static const char*
skip_slash(const char *p)    
//跳过斜杠。
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)    
//用于在文件系统中寻找给定路径的文件。    
int
file_create(const char *path, struct File **pf)    
//用于在指定路径下创建一个新文件。  
int
file_open(const char *path, struct File **pf)    
//用于打开指定路径的文件。    
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)    
//用于从给定文件中读取数据到缓冲区中。    
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
//用于将数据从缓冲区写入到给定文件中。    
static int
file_free_block(struct File *f, uint32_t filebno)    
//用于释放文件中的一个数据块。
static void
file_truncate_blocks(struct File *f, off_t newsize)   //用于在截断文件时释放多余的数据块和相应的资源。
int
file_set_size(struct File *f, off_t newsize)    
//用于设置文件的大小并在必要时截断文件。    
void
file_flush(struct File *f)    
//用于将文件相关的数据块以及文件结构体本身的变更刷新到磁盘中。\
void
fs_sync(void) 
//用于将整个文件系统的数据块刷新到磁盘上，以确保文件系统中的数据得到持久化。   
```



### fs.h

```c
struct File {
	char f_name[MAXNAMELEN];	// filename
	off_t f_size;			// file size in bytes
	uint32_t f_type;		// file type

	// Block pointers.
	// A block is allocated iff its value is != 0.
	uint32_t f_direct[NDIRECT];	// direct blocks
	uint32_t f_indirect;		// indirect block

	// Pad out to 256 bytes; must do arithmetic in case we're compiling
	// fsformat on a 64-bit machine.
	uint8_t f_pad[256 - MAXNAMELEN - 8 - 4*NDIRECT - 4];
} __attribute__((packed));	// required only on some 64-bit machines

//f_name: 文件名，以 null 终止的字符串。
//f_size: 文件大小（以字节为单位）。
//f_type: 文件类型，可以是 FTYPE_REG（普通文件）或 FTYPE_DIR（目录）。
//f_direct: 直接块指针数组，用于直接索引数据块。包含 NDIRECT 个指针。
//f_indirect: 间接块指针，用于索引间接块，间接块包含更多的数据块指针。
//f_pad: 用于填充，以确保整个结构的大小为256字节。

struct Super {
	uint32_t s_magic;		// Magic number: FS_MAGIC
	uint32_t s_nblocks;		// Total number of blocks on disk
	struct File s_root;		// Root directory node
};

//s_magic: 文件系统的魔术数字，用于识别文件系统。
//s_nblocks: 磁盘上的总块数。
//s_root: 根目录节点。

//常量
BLKSIZE: 文件系统块的大小，与页面大小相同。
BLKBITSIZE: 块的位大小，即块大小乘以8。
MAXNAMELEN: 最大文件名长度，包括 null 终止符，必须是4的倍数。
MAXPATHLEN: 最大完整路径名长度，包括 null 终止符。
NDIRECT: 文件描述符中的直接块指针数量。
NINDIRECT: 一个间接块中的直接块指针数量。
MAXFILESIZE: 文件的最大大小，包括直接块和间接块。
    
enum {
	FSREQ_OPEN = 1,
	FSREQ_SET_SIZE,
	// Read returns a Fsret_read on the request page
	FSREQ_READ,
	FSREQ_WRITE,
	// Stat returns a Fsret_stat on the request page
	FSREQ_STAT,
	FSREQ_FLUSH,
	FSREQ_REMOVE,
	FSREQ_SYNC
};
union Fsipc {
	struct Fsreq_open {
		char req_path[MAXPATHLEN];
		int req_omode;
	} open;
	struct Fsreq_set_size {
		int req_fileid;
		off_t req_size;
	} set_size;
	struct Fsreq_read {
		int req_fileid;
		size_t req_n;
	} read;
	struct Fsret_read {
		char ret_buf[PGSIZE];
	} readRet;
	struct Fsreq_write {
		int req_fileid;
		size_t req_n;
		char req_buf[PGSIZE - (sizeof(int) + sizeof(size_t))];
	} write;
	struct Fsreq_stat {
		int req_fileid;
	} stat;
	struct Fsret_stat {
		char ret_name[MAXNAMELEN];
		off_t ret_size;
		int ret_isdir;
	} statRet;
	struct Fsreq_flush {
		int req_fileid;
	} flush;
	struct Fsreq_remove {
		char req_path[MAXPATHLEN];
	} remove;

	// Ensure Fsipc is one page
	char _pad[PGSIZE];
};
struct Fsreq_open 定义了打开文件的请求，包括文件路径和打开模式。
struct Fsret_read 定义了读取文件的回复，包括读取的数据。
struct Fsreq_write 定义了写入文件的请求，包括文件标识符和写入数据。
等等...
    
```



### serv.c

```c
//设置req->req_fileid的大小为req->req_size字节，根据需要截断或扩展文件。
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
	struct OpenFile *o;
	int r;
	//使用了一个条件语句，检查是否启用了调试模式
	if (debug)
		cprintf("serve_set_size %08x %08x %08x\n", envid, req->req_fileid, req->req_size);

	//每个文件系统IPC调用都具有相同的通用结构，接下来的代码部分即是这种通用结构。
	// Here's how it goes.
	//首先，使用openfile_lookup查找相关的打开文件。
	//失败时，使用ipc_send将错误码返回给客户端。
    //通过调用 openfile_lookup 函数，查找与给定文件标识符 req->req_fileid 相关联的打开文件对象 o。
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;
    
	//调用 file_set_size 函数，将打开文件对象 o 中的底层文件（o->o_file）的大小设置为 req->req_size。
	//其次，调用相关的文件系统函数(来自fs/fs.c)。
	//失败时，将错误代码返回给客户端。
	return file_set_size(o->o_file, req->req_size);
}
```

















































# Temporary records or Data retention

## 实现过的函数保存(部分)

```
lab 1
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
打印函数调用栈的信息。包括每个函数的 ebp、 eip 和参数的值，并按照调用顺序从当前函数一直回溯到最外层函数。

lab 2

A:物理页面管理
boot_alloc(uint32_t n)
在内核中分配一块足够大的内存空间，以供后续的操作系统代码使用。
mem_init(void)
初始化操作系统的内存管理系统，包括设置页目录、初始化页数据结构、设置虚拟内存等。
page_init(void)
初始化页数据结构和空闲页链表。这块得先区分那些是空闲的，确定需要初始化的，然后再初始化。
page_alloc(int alloc_flags)
分配物理页。根据指定的标志分配一个物理页，并返回该页的信息。
page_free(struct PageInfo *pp)
释放一个页。也就是将一个struct PageInfo结构，重新挂回page_free_list。注意不能释放一个引用值不为0的页，或者链接值不为空的页。

B:页表管理:插入和删除线性到物理的映射，以及在需要时创建页表页。
pgdir_walk(pde_t *pgdir, const void *va, int create)
在给定的页目录 pgdir 中查找并返回虚拟地址 va 对应的页表项。
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
启动阶段进行内存映射（将虚拟地址和物理地址进行映射）,将虚拟地址范围映射到物理地址上，并设置相应的权限。也就是填充页表的值。
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
查找一个虚拟地址对应的页。
page_remove(pde_t *pgdir, void *va)
取消一个映射关系。
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
将一个物理页 pp 映射到给定的虚拟地址 va 上，并设置相应的权限 perm。

lab3

A:创建和运行用户环境。在缺乏文件系统的情况下，将静态二进制映像嵌入到内核中。
env_init(void)
初始化数组中的所有结构。调用：它将分段硬件配置为特权级别0(内核)和特权级别3(用户)的单独段。
env_setup_vm(struct Env *e)
为新环境分配一个页目录，并初始化新环境地址空间的内核部分。
env_alloc(struct Env **newenv_store, envid_t parent_id)
分配并初始化一个新环境。
region_alloc(struct Env *e, void *va, size_t len)
为环境分配和映射物理内存
load_icode(struct Env *e, uint8_t *binary)
解析ELF二进制映像，就像启动加载程序已经做的那样，并将其内容加载到新环境的用户地址空间中。
env_create(uint8_t *binary, enum EnvType type)
分配一个环境，并调用该函数将ELF二进制文件加载到环境中
env_run(struct Env *e)
启动在用户模式下运行的给定环境。
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
将一个物理页 pp 映射到给定的虚拟地址 va 上，并设置相应的权限 perm。
page_alloc(int alloc_flags)
分配物理页。根据指定的标志分配一个物理页，并返回该页的信息。

B:缺页异常、断点异常和系统调用。
trap_dispatch(struct Trapframe *tf)
根据中断或异常的类型，将控制权传递给相应的处理函数。
libmain(int argc, char **argv)
设置用户环境的上下文，并调用用户程序的主要逻辑函数。它是用户程序的入口点，用户程序的执行从这里开始。
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
检查环境是否允许访问该内存范围。
page_fault_handler(struct Trapframe *tf)
当发生页错误时，操作系统会调用这个函数来处理错误。
sys_cputs(const char *s, size_t len)
在系统控制台打印一个字符串。

lab4
A:大家还将实现协作式轮询调度，允许内核在当前环境主动放弃CPU(或退出)时从一个环境切换到另一个环境。
mmio_map_region(physaddr_t pa, size_t size)
为设备分配一块内存区域，并将设备的寄存器映射到这个区域。
page_init(void)
初始化页数据结构和空闲页链表。这块得先区分那些是空闲的，确定需要初始化的，然后再初始化。
mem_init_mp()
映射从`KSTACKTOP`开始的各cpu栈
trap_init_percpu
初始化BSP的TSS和TSS描述符。
sched_yield()
实现简单的轮询调度
sys_exofork(void)
系统调用创建了一个几乎是空白的新环境:没有任何东西映射到其地址空间的用户部分，环境是不可运行的。
sys_env_set_status(envid_t envid, int status)
用于标记一个新环境，在其地址空间和寄存器状态完全初始化之后，该环境就可以运行了。
sys_page_alloc(envid_t envid, void *va, int perm)
分配一页物理内存，并将其映射到给定环境的地址空间中的给定虚拟地址。
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
将页映射(而不是页的内容)从一个环境的地址空间复制到另一个环境的地址空间，保持内存共享，使得新映射和旧映射都指向物理内存的同一页。
sys_page_unmap(envid_t envid, void *va)
解除映射到给定环境中给定虚拟地址的页。

B:写时复制
sys_env_set_pgfault_upcall(envid_t envid, void *func)
设置指定环境（`envid`）的页面错误处理函数（`pgfault_upcall`）
page_fault_handler(struct Trapframe *tf)
用于将缺页异常分派给用户态处理程序。
pgfault(struct UTrapframe *utf)
保存了页面故障的内容，其他进程用旧页面，引发页面故障的进程用临时页面。
duppage(envid_t envid, unsigned pn)
在子进程的地址空间中创建一个新的虚拟地址映射，与父进程中的指定页面共享同一物理页面。
fork(void)
实现进程（或环境）复制（fork）的函数。

C:抢占式多任务和进程间通信(IPC)
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
向指定的目标环境（进程）发送一个 IPC（Inter-Process Communication）消息。
sys_ipc_recv(void *dstva)
使当前环境（进程）等待接收来自其他进程的 IPC（Inter-Process Communication）消息。
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
实现了一个用户级函数 ipc_recv，用于从其他进程接收 IPC 消息。
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
实现了一个用户级函数 ipc_send，用于从其他进程发送 IPC 消息。
```



## temp



```c
/*
 * File system server main loop -
 * serves IPC requests from other environments.
 */

#include <inc/x86.h>
#include <inc/string.h>

#include "fs.h"


#define debug 0

// The file system server maintains three structures
// for each open file.
//
// 1. The on-disk 'struct File' is mapped into the part of memory
//    that maps the disk.  This memory is kept private to the file
//    server.
// 2. Each open file has a 'struct Fd' as well, which sort of
//    corresponds to a Unix file descriptor.  This 'struct Fd' is kept
//    on *its own page* in memory, and it is shared with any
//    environments that have the file open.
// 3. 'struct OpenFile' links these other two structures, and is kept
//    private to the file server.  The server maintains an array of
//    all open files, indexed by "file ID".  (There can be at most
//    MAXOPEN files open concurrently.)  The client uses file IDs to
//    communicate with the server.  File IDs are a lot like
//    environment IDs in the kernel.  Use openfile_lookup to translate
//    file IDs to struct OpenFile.

struct OpenFile {
	uint32_t o_fileid;	// file id
	struct File *o_file;	// mapped descriptor for open file
	int o_mode;		// open mode
	struct Fd *o_fd;	// Fd page
};

// Max number of open files in the file system at once
#define MAXOPEN		1024
#define FILEVA		0xD0000000

// initialize to force into data section
struct OpenFile opentab[MAXOPEN] = {
	{ 0, 0, 1, 0 }
};

// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
}

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
	*po = o;
	return 0;
}

// Open req->req_path in mode req->req_omode, storing the Fd page and
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
	char path[MAXPATHLEN];
	struct File *f;
	int fileid;
	int r;
	struct OpenFile *o;

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
	path[MAXPATHLEN-1] = 0;

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
		if (debug)
			cprintf("openfile_alloc failed: %e", r);
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
		if ((r = file_create(path, &f)) < 0) {
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
				goto try_open;
			if (debug)
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
			if (debug)
				cprintf("file_open failed: %e", r);
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
		if ((r = file_set_size(f, 0)) < 0) {
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
		if (debug)
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
	o->o_fd->fd_dev_id = devfile.dev_id;
	o->o_mode = req->req_omode;

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;

	return 0;
}

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_set_size %08x %08x %08x\n", envid, req->req_fileid, req->req_size);

	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
}

// Read at most ipc->read.req_n bytes from the current seek position
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
	struct Fsreq_read *req = &ipc->read;
	struct Fsret_read *ret = &ipc->readRet;

	int r;

	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:

	struct OpenFile *of;
	if ( (r = openfile_lookup(envid, req->req_fileid, &of) )< 0)
		return r;

	if ( (r = file_read(of->o_file, ret->ret_buf, req->req_n, of->o_fd->fd_offset))< 0)
		return r;
	
	// then update the seek position.
	of->o_fd->fd_offset += r;
	return r;

}


// Write req->req_n bytes from req->req_buf to req_fileid, starting at
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	int r;
	struct OpenFile *of;
	int reqn;
	if ( (r = openfile_lookup(envid, req->req_fileid, &of)) < 0)
		return r;
	reqn = req->req_n > PGSIZE? PGSIZE:req->req_n;
	
	if ( (r = file_write(of->o_file, req->req_buf, reqn, of->o_fd->fd_offset)) < 0)
		return r;

	of->o_fd->fd_offset += r;
	return r;
	// LAB 5: Your code here.
	// panic("serve_write not implemented");

}

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
	struct Fsreq_stat *req = &ipc->stat;
	struct Fsret_stat *ret = &ipc->statRet;
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
	ret->ret_size = o->o_file->f_size;
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
	return 0;
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
	struct OpenFile *o;
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
		return r;
	file_flush(o->o_file);
	return 0;
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
	fs_sync();
	return 0;
}

typedef int (*fshandler)(envid_t envid, union Fsipc *req);

fshandler handlers[] = {
	// Open is handled specially because it passes pages
	/* [FSREQ_OPEN] =	(fshandler)serve_open, */
	[FSREQ_READ] =		serve_read,
	[FSREQ_STAT] =		serve_stat,
	[FSREQ_FLUSH] =		(fshandler)serve_flush,
	[FSREQ_WRITE] =		(fshandler)serve_write,
	[FSREQ_SET_SIZE] =	(fshandler)serve_set_size,
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
			cprintf("Invalid request from %08x: no argument page\n",
				whom);
			continue; // just leave it hanging...
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
			r = handlers[req](whom, fsreq);
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
			r = -E_INVAL;
		}
		ipc_send(whom, r, pg, perm);
		sys_page_unmap(0, fsreq);
	}
}

void
umain(int argc, char **argv)
{
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
	cprintf("FS is running\n");

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");

	serve_init();
	fs_init();
	serve();
}
```





















































































































































