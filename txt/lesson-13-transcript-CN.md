# 第13课：启动代码——在main之前的世界 / Lesson 13: The Startup Code — The World Before main

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll talk about the startup code that is, the code that runs even before the main function. Today, you will learn about the standard startup code that gets linked with your application from the IAR library. You will see how the startup code initializes the varius data sections and you will see these sections in the linker map file. Finally, you'll go back all the way to the beginning of the reset sequence, where you will encounter the vector table.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这一课我们来聊聊**启动代码**（startup code）——也就是在 `main` 函数之前运行的那些代码。今天你会看到 IAR 库里提供的标准启动代码是怎么链接到你的程序中的，启动代码又是如何初始化各个数据段的，还会在链接器映射文件里看到这些段。最后，我们会一路追溯到**复位序列**（reset sequence）的最开始，在那里你会遇到**向量表**（vector table）。

As usual, let's get started with making a copy of the previous "lesson12" project and renaming it to "lesson13". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

跟之前一样，先把"lesson12"项目复制一份，改名为"lesson13"。如果你是刚加入这个课程的，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson13" directory and double-click on the workspace file to open the IAR toolset.

进入新的"lesson13"目录，双击工作区文件打开 IAR 工具链。

If you don't have the IAR toolset, go back to "lesson0". The latest version published by IAR is 7.10, which I'm using in this lesson.

如果你还没有 IAR 工具链，回到第 0 课去看安装方法。IAR 目前发布的最新版本是 7.10，本课用的就是这个。

So far in this course, you have been always starting your debugging with the main function. Today, you will explore the world before main.

到目前为止，你每次调试都是从 `main` 函数开始的。今天，我们要探索的是 `main` 之前的世界。

To do this, open the project Options dialog box and in the debugger section un-check the "Run to main" option.

做法是这样的：打开项目选项对话框，在调试器那一栏里取消勾选"Run to main"。

Also make sure that the TI Stellaris debug driver is selected, because for this lesson you will need use the real LaunchPad board, as opposed to the simulator.

同时确认选中的是 TI Stellaris 调试驱动，因为本课需要用真实的 LaunchPad 开发板，不能用仿真器。

While you are here, make sure that the "Use flash loaders" option is selected.

趁你还在这个对话框里，顺便确认一下"Use flash loaders"选项也勾上了。

Finally, in the General Options revert from the Cortex-M0 experiment to the TM4C device actually used on your Tiva-C LaunchPad board. Please note that this device uses the hardware Floating Point Unit FVPv4.

最后，在 General Options 里把 Cortex-M0 的实验配置改回 Tiva-C LaunchPad 开发板上实际使用的 TM4C 设备。注意，这个设备带有硬件**浮点单元**（Floating Point Unit, FPU），型号是 FVPv4。

When you download your code to the board now, you can see that indeed you are not starting with main. Instead the fist label in the code you hit is `__iar_program_start`.

现在把代码下载到板子上，你会发现确实不是从 `main` 开始的。你碰到的第一个代码标签是 `__iar_program_start`。

Please also note that most registers are initialized to zero, except the stack pointer SP, which seems to be initialized to a reasonable value inside the RAM. You will need to understand how that happened later in the lesson, but for now, let's just quickly step through the code to get a sense what is going on.

还要注意，大部分寄存器都被初始化为零，唯独**栈指针**（Stack Pointer, SP）不是——它看起来已经被设成了 RAM 中一个合理的地址。为什么会这样，后面会解释。现在先快速单步走一遍代码，感受一下整体流程。

The first interesting instruction you should recognize is BL (branch with link) which is a function call. Here, the function being called is `__iar_init_vfp`, which initializes the hardware floating point unit (FPU). I don't want to go into the details of the FPU here, but let me only say that FPU needs to be initialized early in case any code downstream, such as main, wants to use it.

你应该能认出来的第一条有意思的指令是 **BL**（Branch with Link，带链接的跳转）——它就是函数调用。这里调用的是 `__iar_init_vfp`，用来初始化硬件浮点单元（FPU）。FPU 的细节先不展开，你只需要知道：FPU 必须尽早初始化，因为后面的代码（比如 `main`）可能会用到浮点运算。

The second interesting function call is to `?main`. This is an illegal name for a C function, but I just want to remind you that we are here in the strange world before the C language, so the C rules for naming functions don't apply. This is an IAR specific startup code and they have chosen to call it `?main`. Let's step inside this time.

第二个值得注意的函数调用是 `?main`。这个名字对 C 函数来说是非法的，但别忘了，我们现在处于 C 语言之前的"蛮荒世界"，C 的命名规则在这里不管用。这是 IAR 自己的启动代码，他们就是选了 `?main` 这个名字。这次我们走进去看看。

So, here you have another function call to `__low_level_init`. This function is intended to perform a customized initialization of your hardware that either must occur very early on, or can speed up the startup process. For example, if you plan to increase the CPU clock speed, it's better to do it sooner so that the rest of the startup code will execute faster.

在里面又看到一个函数调用——`__low_level_init`。这个函数用来做**底层自定义初始化**，适合放那些必须非常早执行、或者能加速启动过程的硬件初始化。比如，如果你打算提高 CPU 时钟频率，趁早做了，后面启动代码跑得就更快。

If you don't define your own `__low_level_init`, as you certainly don't at this point, an empty, library version is used.

如果你没有自己定义 `__low_level_init`——现在你肯定没定义——就会用库里的空函数版本。

As you can see by the test of the R0 register, `__low_level_init` returns a value which determines whether to go straight to calling main or to perform a data initialization.

从对 R0 寄存器的测试可以看出，`__low_level_init` 的返回值决定了接下来是直接调 `main`，还是先做数据初始化。

The library version returns a non-zero value, so the function `__iar_data_init3` is called.

库版本返回的是非零值，所以接下来会调用 `__iar_data_init3`。

I skip over this function right now, because at this point your program does not have all the interesting data sections yet. I will step through the data initialization in the next debug session, after you modify the code such that all data sections will be present.

这个函数我先跳过，因为目前你的程序还没有那些有意思的数据段。等你修改代码、把各种数据段都加上之后，我会在下一次调试中带你单步走完数据初始化过程。

Here I just want to finish this run by showing you that finally the startup code ends up calling the main function.

这次运行我想展示的就是这些——最终启动代码会调用 `main` 函数。

OK, so let's modify the code such that it has all the data sections. But first, I need to clarify the term "data section" for you.

好，现在来修改代码，让它包含所有类型的数据段。不过先得把"数据段"这个概念给你解释清楚。

Well, perhaps the best way to explain it is to simply show you the various program sections. For this, you need to enable generation of the so called map file by the linker.

最好的解释方法就是直接让你看各种**程序段**（program sections）。为此，需要让链接器生成所谓的**映射文件**（map file）。

Please open the project options dialog box, go to the linker section, and the list tab. Here, please check the "generate linker map file" option.

打开项目选项对话框，进入 Linker 下面的 List 标签页，勾选"generate linker map file"。

Re-build the code by pressing F7.

按 F7 重新编译。

So, let's take a look at the generated linker map file. You can find it conveniently in the Output folder of your project.

来看看生成的链接器映射文件，它在项目的 Output 文件夹里。

At first glance you might think that a linker map file is a cryptic, illegible, machine-level gibberish, and it certainly is. But for an embedded programmer this is also a real treasure trove of invaluable information and I highly recommend that you not only generate the map file for all your projects, but also that you learn how to read and use the information.

乍一看，映射文件像是天书一样——晦涩的机器级乱码。确实如此。但对嵌入式程序员来说，这可是真正的宝藏，里面有大量有价值的信息。我强烈建议你：不仅每个项目都要生成映射文件，而且要学会读懂它、利用它。

For example, you should always know how big your program is in terms of code space in ROM and data space in ROM and RAM. To find out, you scroll to the "Module Summary" section.

比如，你应该时刻清楚自己的程序有多大——ROM 里的代码空间有多大，RAM 里的数据空间有多大。往下翻到"Module Summary"部分就能看到。

Here you have all this information broken down by type of data, such as read-only code, read-only data, and read-write data, as well as the object module, such as delay.o and main.o.

这里把信息按数据类型做了分类——只读代码、**只读数据**（read-only data）、**读写数据**（read-write data）——也按目标模块做了分类，比如 `delay.o`、`main.o`。

At the bottom, you find the totals, which are currently 470 bytes of read-only code, 18 bytes of read-only data and 1060 bytes of read-write data.

最下面是合计：目前是 470 字节只读代码、18 字节只读数据、1060 字节读写数据。

The largest contributor to the read-write data is the 1024 bytes generated by the linker for the stack.

读写数据里最大的那一块，是链接器为**栈**（stack）分配的 1024 字节。

However, for now, the most interesting part of the map file is "Placement Summary", which lists all the program sections.

不过目前最值得看的是"Placement Summary"部分，它列出了所有程序段。

For the linker, a program section is simply a contiguous chunk of memory that has a symbolic name.

对链接器来说，一个程序段就是一段**连续的内存区域**，带一个符号名。

For example, the area between addresses 0 and 0x40 is named .intvec section.

比如，地址 0 到 0x40 之间的区域叫 `.intvec` 段。

The following sections are all named .text and are for the code.

接下来全是 `.text` 段，用来存放代码。

Finally the .rodata section is for read-only data.

最后 `.rodata` 段存放只读数据。

All of these sections are in the ROM address range.

这些段全部位于 ROM 地址范围内。

Below that, you find several .bss sections, which hold uninitialized data that need to be set to zero during the system startup.

再往下看，有几个 `.bss` 段，存放的是**未初始化数据**——启动的时候需要把它们清零。

And finally, at the very bottom, you find the CSTACK section, which holds the stack and is left uninitialized during the startup.

最底下是 CSTACK 段，也就是栈空间，启动过程中不会对它做初始化。

If you wonder about the names, such as .text or .bss, for code and uninitialized data, respectively, these are all historical names coming from some ancient assembly language. For example, BSS used to mean Block Started by Symbol or some such, which today has a completely different meaning.

你可能好奇这些名字——`.text` 放代码，`.bss` 放未初始化数据——都挺奇怪的。这些其实都是从很早的汇编语言时代流传下来的历史名称。比如 BSS 原来意思是"Block Started by Symbol"之类的，今天的含义早就不是那个了。

But anyway, the point is that your program doesn't have the initialized data section yet, that is, a data section that requires a specific initialization to hard-coded values during the startup.

但不管怎样，关键点是：你的程序目前还没有**已初始化数据段**（initialized data section）——也就是启动时需要把特定值写进去的那种段。

So, in the next step of this lesson, you will add some data initialization and then check again how this will change your map file.

所以下一步，你给程序加上一些带初始值的变量，然后再看映射文件会发生什么变化。

In the previous lessons of this course you have already seen that it is possible to give an initial value to a variable in its definition. The syntax is to follow the variable name by an equals sign and an expression, followed by a semicolon.

在前面的课程里你已经见过了，定义变量的时候可以直接给它一个初始值。语法就是变量名后面跟等号和表达式，再加分号。

For example, signed 16-bit integer x is initialized to -1,

比如，有符号 16 位整数 x 初始化为 -1：

```c
int16_t x = -1;
```

while unsigned 32-bit integer y is initialized to a binary or of #-defined constants LED_RED and LED_GREEN.

无符号 32 位整数 y 初始化为 `#define` 常量 `LED_RED` 和 `LED_GREEN` 的按位或：

```c
uint32_t y = LED_RED | LED_GREEN;
```

You can also initialize more complex variables, such as whole arrays, in which case you need to enclose the initial values in braces and separate by commas.

更复杂的变量也能初始化，比如整个**数组**（array）——初始值用花括号括起来，逗号分隔。

For example, here is an initialization of a signed 16-bit array sqr of four elements.

比如下面这个，4 个元素的有符号 16 位数组 `sqr` 的初始化：

```c
int16_t sqr[] = { 1, 4, 9, 16 };
```

When you provide an array initializer, you might omit the size, and the C compiler will infer the size from the initializer.

给了初始化器之后，数组大小可以省略，编译器会根据初始化器自动推断。

Also, the initializer might have fewer elements than the specified array size, in which case the missing elements will be initialized to zero.

初始化器的元素也可以比数组大小少，缺的元素会被自动初始化为零。

However, the initializer cannot have more elements than the array size and you get a compilation error when you try.

但初始化器的元素不能比数组大小多，多了编译器会报错。

Initialization of structures is similar to initialization of arrays. Again, you enclose the initial values for the members in braces and separate them by commas.

**结构体**（structure）的初始化跟数组类似，也是把各成员的初始值用花括号括起来，逗号分隔。

For example, here is an initialization of the p1 Point structure.

比如这里是 `Point` 结构体 `p1` 的初始化。

For a structure of structures, such as Window, you simply nest the initializers of member structures.

如果是嵌套结构体，比如 `Window`，直接把内层结构体的初始化器嵌套进去就行。

For instance here is an initialization of the Window instance w that contains two Point instances;

例如这里是 `Window` 实例 `w` 的初始化，它里面包含两个 `Point` 实例。

Now, going back to the map file, perhaps you have noticed that it has changed.

回到映射文件，你可能已经注意到它变了。

First, a new "Initializer bytes" section has been added in the ROM address range.

第一，ROM 地址范围内多了一个"Initializer bytes"段。

Second, two new .data sections have been created in the RAM address range at the same time as two .bss sections have disappeared.

第二，RAM 地址范围内多了两个 `.data` 段，同时两个 `.bss` 段消失了。

And third, the combined size of the two new .data sections is 0xC bytes, which is exactly the same as the size of the new "Initializer bytes" section in ROM.

第三，这两个新 `.data` 段的总大小是 0xC 字节，跟 ROM 里那个新加的"Initializer bytes"段大小完全一样。

Shown graphically, the fact of your adding some initialization of variables caused the following changes.

画成图来看，你加了变量初始化之后，变化是这样的。

The linker has inserted a new .data section in RAM for the initialized data,

链接器在 RAM 里插入了新的 `.data` 段来存放已初始化数据，

and at the same time, the linker has created a matching "Initializer bytes" section in ROM of exactly the same size as the .data sections.

同时在 ROM 里创建了一个匹配的"Initializer bytes"段，大小跟 `.data` 段一模一样。

The implication for the startup code is that it needs to copy the "Initializer bytes" section from ROM to the .data sections in RAM.

这意味着启动代码需要把"Initializer bytes"段从 ROM **复制**到 RAM 里的 `.data` 段。

Please note that the startup code does not initialize the data in the way you have specified it in the code, so it does not copy two bytes here and four bytes there to individual variables.

注意，启动代码不是按照你代码里写的那样逐个变量去初始化的——不是这边拷两个字节、那边拷四个字节。

Instead, the linker has specifically reordered the variables so that all initialized data can be initialized in a single block copy from "Initializer bytes" section to the .data sections.

链接器特意把变量重新排列了，这样所有已初始化数据可以用一次**块复制**（block copy）从"Initializer bytes"段整体搬到 `.data` 段。

So, let's have another look at the startup code, now that you have both initialized data in the .data section and the uninitialized data in the .bss section.

好，现在你有了 `.data` 段里的已初始化数据、`.bss` 段里的未初始化数据，我们再来看启动代码。

First, I set the memory view to the RAM region and I fill the memory with 0xFFs so that you can clearly see when the bytes are changed to zero or some other values.

先把内存视图切到 RAM 区域，用 0xFF 填满，这样等字节被改成零或其他值的时候，你一眼就能看出来。

Next, quickly step through the startup code until you reach the `__iar_data_init3` call. This time, you will step into this function to see how it initializes the data.

快速单步走过启动代码，一直到 `__iar_data_init3` 的调用。这次我们走进去，看看数据初始化是怎么做的。

This label indicates that the first step is to zero-initialize the data.

这个标签说明第一步是**零初始化**（zero-initialize）——把数据清零。

This STR instruction is the core of the data clearing algorithm. The instruction stores the value in R3 to the address in R2.

这条 **STR 指令**（Store Register）是数据清零算法的核心。它把 R3 里的值写到 R2 指向的地址。

As you can see R3 is zero and R2 is exactly the address of the first .bss section in RAM.

可以看到，R3 的值是零，R2 正好指向 RAM 中第一个 `.bss` 段的起始地址。

As you can see in the memory view, the STR instruction writes zeros to a 4-byte word at the beginning of the first .bss section in RAM.

从内存视图可以看到，STR 指令往 RAM 里第一个 `.bss` 段开头写了一个 4 字节的**字**（word），值全是零。

But I'd also like to take this opportunity to explain a new addressing mode used in this STR instruction. Please note the #4 constant after the square bracket. This offset caused incrementing the base register R2 by 4 bytes, as you can see in the register view. You should not confuse this addressing mode with an STR instruction that has a constant inside the bracket, as that one is for adding offset to the base temporarily before storing the data. The new addressing mode with incrementing the base is specifically suitable for tight loops.

不过我想顺便解释一下这条 STR 指令用到的新的**寻址模式**（addressing mode）。注意方括号后面的 `#4` 常量。这个偏移量让基址寄存器 R2 自动加 4 字节——你在寄存器视图里能看到。别把它跟方括号里面写常量的 STR 搞混了，那个只是在存储数据时临时加偏移，不改变基址。这种自动递增基址的寻址模式特别适合**紧凑循环**（tight loop）。

So, as you step through the code, you can see how the code loops around the STR instruction and each pass clears the next word in .bss section.

继续单步走就能看到，代码围着 STR 指令转圈，每轮清零 `.bss` 段里的下一个字。

After clearing .bss, the startup code proceeds to copying the data into the .data section.

`.bss` 清零完成后，启动代码接着把数据复制到 `.data` 段。

The actual copying is done by the LDR/STR instruction pair that use the addressing mode I've just explained for the .bss section.

实际复制由 **LDR/STR 指令对**完成，用的就是刚才讲的那个寻址模式。

The R2 base register of the LDR instruction points to the source of the data, which is the beginning of the "Initializer bytes" section in ROM.

LDR 指令的基址寄存器 R2 指向数据源——ROM 中"Initializer bytes"段的起始位置。

The R3 base register of the STR instruction points to the target of the data, which is the beginning of the .data section in RAM.

STR 指令的基址寄存器 R3 指向数据目标——RAM 中 `.data` 段的起始位置。

As you can see, again the code loops around and initializes the whole .data section.

跟之前一样，代码循环执行，把整个 `.data` 段都初始化完。

Eventually, the startup completes and the main function is called.

最终启动完成，`main` 函数被调用。

In summary, what you've just seen is a standard-compliant startup code provided in the IAR library. By the time main() is called, the C standard requires all initialized variables to have their initial values and all uninitialized variables to be set to zero.

总结一下，你刚才看到的是 IAR 库里提供的符合 C 标准的启动代码。按照 C 标准的要求，`main()` 被调用的时候，所有已初始化变量必须有初始值，所有未初始化变量必须被清零。

However, startup code from other vendors might not comply with the C standard. Specifically, you might encounter startup code that does not clear your uninitialized variables in the .bss section. For example, the startup for Texas Instruments DSPs routinely does not comply in this respect.

不过，其他厂商提供的启动代码未必遵守 C 标准。具体来说，你可能会遇到不清零 `.bss` 段的启动代码。比如 TI 的 DSP 启动代码在这方面就经常不合规。

The point is that I highly recommend that you test your startup code, by methods I've just shown you. If you find out that your .bss sections are not cleared, you might need to explicitly initialize all previously uninitialized variables to zero.

所以关键在于：我强烈建议你用刚才演示的方法测试一下你的启动代码。如果发现 `.bss` 段没有被清零，你就得把那些未初始化变量**显式初始化**为零。

But this is not optimal, because you essentially convert the .bss sections to .data sections, which require a matching "Initializer bytes" section in ROM. In other words, you take space in ROM for a bunch of zeros.

但这不是最优解——你本质上把 `.bss` 段变成了 `.data` 段，而 `.data` 段需要在 ROM 中有匹配的"Initializer bytes"段。换句话说，你为一大堆零白白占用了 ROM 空间。

All right, so now that you have a fairly good overview of the standard C initialization sequence, it's time to go all the way to the beginning of the reset process.

好了，标准 C 初始化序列你已经有了不错的了解，现在我们一路追到**复位过程**（reset process）的最开始。

This part of the startup sequence is processor-specific, so what will follow will be specific for the ARM Cortex-M processor on your Tiva LaunchPad board.

这部分启动序列是跟具体处理器相关的，所以接下来讲的内容专门针对你 Tiva LaunchPad 板子上的 ARM Cortex-M 处理器。

Let's start another debug session to answer two basic questions.

再开一个调试会话，回答两个基本问题。

First, you want to find out how the stack pointer SP got its initial value and second,

第一，栈指针 SP 的初始值是怎么来的；

how the program counter PC ended up at the function `__iar_program_start`.

第二，**程序计数器**（Program Counter, PC）是怎么跑到 `__iar_program_start` 函数去的。

The clues to answer these two question are at the address 0, which is the start of ROM.

答案的线索就在地址 0 处——也就是 ROM 的起始位置。

When you look at this address in the disassembly window, you can see the CSTACK$$LIMIT at address zero,

在反汇编窗口看这个地址，地址 0 处放的是 `CSTACK$$LIMIT`，

and `__iar_program_start` at address 0x4.

地址 0x4 处放的是 `__iar_program_start`。

Please note that these are not machine instructions. These are simply words in memory. The code instructions start later, with the main function.

注意，这些不是机器指令，只是内存中的字。真正的代码指令在更后面的位置。

So, here is the answer to your questions. The ARM Cortex-M processor is hardwired such that after reset it copies the bits from address 0 to the SP register,

所以答案是这样的：ARM Cortex-M 处理器是**硬连线**（hardwired）的——复位之后，它会自动把地址 0 处的内容加载到 SP 寄存器，

and the all bits except the least-significant-bit from address 0x4 to the PC.

把地址 0x4 处的内容（除**最低有效位**（Least Significant Bit, LSB）外）加载到 PC。

The least-significant-bit of any value loaded to the PC must be one, because this bit indicates the **Thumb mode** of the processor, which is the only one supported by Cortex-M. This explains why PC is 0x218, while the value at address 0x4 is 0x219. I talked about it already in previous lessons.

加载到 PC 的任何值，最低有效位必须是 1，因为这个位表示处理器的 **Thumb 模式**——Cortex-M 只支持这一种指令集模式。这就解释了为什么 PC 是 0x218，而地址 0x4 处的值是 0x219。之前的课里我已经讲过了。

But I'd like to point out something even more significant. What you have just discovered at address zero is the so called Vector Table.

不过我想指出一个更重要的发现——你刚才在地址 0 处看到的，就是所谓的**向量表**（vector table）。

The Vector Table is described in the Datasheet of your microcontroller,

向量表在你的微控制器**数据手册**（datasheet）里有描述，

where you can read what you already know,

里面确认了你已经知道的内容：

that it contains the reset value of the stack pointer SP and the start address of the PC.

它包含了栈指针 SP 的复位值和 PC 的起始地址。

But the Vector Table contains more than that. It contains all the **exception** and **interrupt vectors** that your processor can handle. Of course, I need to explain what these are in the upcoming lessons, but I hope that you are excited about getting so close to the fascinating subject of interrupts.

但向量表包含的远不止这些。它包含了你的处理器能处理的所有**异常**（exception）和**中断向量**（interrupt vector）。当然，这些概念我会在接下来的课程中详细讲解。不过我希望你已经兴奋起来了——我们马上就要触及中断这个精彩的主题了。

The actual layout of the Vector Table is shown on the next page. This picture is drawn in a traditional way, that is, with the address zero at the bottom and high addresses at top.

向量表的实际布局在下一页。这张图是按传统方式画的——地址 0 在底部，高地址在顶部。

This happens to be upside-down compared to the vector table in your disassembly view.

跟你在反汇编窗口里看到的向量表刚好是上下颠倒的。

So let me flip the Vector Table layout and try to match it with the view in your debugger.

所以我把向量表布局翻转一下，尽量跟调试器里的视图对上。

As you can see, the Vector Table from the datasheet now matches your view in the debugger quite nicely. All the exception vectors defined in the datasheet are initialized to BusFault_Handler, and the vectors marked as "reserved" are zero.

可以看到，数据手册里的向量表现跟调试器里的视图对得挺好了。数据手册中定义的所有异常向量都被初始化为 `BusFault_Handler`，标记为"reserved"的向量则是零。

However, the Vector Table from the datasheet is evidently much longer than the one in your disassembly view. Specifically, the vectors labeled IRQ0, IRQ1, etc. are not present in the disassembly view.

但是，数据手册里的向量表明显比你反汇编窗口里看到的要长得多。具体来说，IRQ0、IRQ1 等标记的**中断请求**（Interrupt Request, IRQ）向量在反汇编视图里根本没有。

This is because the vector table provided by the IAR library is generic. It contains only the standard exception vectors that are defined at the beginning of the table and are common to all Cortex-M microcontrollers. But the IAR table does not contain interrupt vectors that are specific to a given microcontroller, such as IRQ0, IRQ1, etc., so it cannot really handle any interrupts.

这是因为 IAR 库提供的向量表是通用的。它只包含定义在表头部、所有 Cortex-M 微控制器都有的那些标准异常向量。至于特定微控制器的中断向量（IRQ0、IRQ1 等），IAR 的向量表里没有，所以它实际上处理不了任何中断。

For that, you need to replace the generic IAR Vector Table with the specific one that will match exactly the layout defined in the Datasheet of your specific microcontroller.

要做到这一点，你需要把通用的 IAR 向量表替换成专用的——精确匹配你的微控制器数据手册里定义的布局。

Before you leave this debug session, though, let's examine the BusFault_Handler code, which from the vector table should be at the address 0x1db.

离开这次调试会话之前，我们再看看 `BusFault_Handler` 的代码——从向量表看，它应该在地址 0x1db。

The actual location of this code is 0x1da, but by now you should know why the address must be an odd number, while the actual code is at an even address.

代码的实际位置是 0x1da。但到现在你应该明白了——地址必须是奇数，而实际代码在偶数地址上。

So here you have also the answer why all exception vectors in the IAR vector table appear to be set to BusFault_Handler.

所以这也回答了另一个问题：为什么 IAR 向量表里所有异常向量看起来都指向 `BusFault_Handler`。

Apparently, the IAR startup code defines all exception handlers, such as Bus-Fault, Debug-Monitor, Hard-Fault, Memory-Manager, and Non-Maskable Interrupt, but they all point to the same piece of code. Knowing only this common address, the disassembler could not distinguish among the various exception handlers, and chose to show only the BusFault_Handler, because this one is the first in the alphabetical order.

原来 IAR 的启动代码确实定义了所有的异常处理程序——Bus-Fault、Debug-Monitor、Hard-Fault、Memory-Manager、以及**不可屏蔽中断**（Non-Maskable Interrupt, NMI）——但它们全都指向同一段代码。反汇编器只知道这个公共地址，没法区分各个异常处理程序，就选了按字母顺序排第一的 `BusFault_Handler` 来显示。

Finally, the IAR code associated with all these exception handlers turns out to be a single branch instruction, which jumps to itself. This means that an occurrence of any of the exceptions ends up tying the CPU in a tight endless loop. This is good for debugging, because when you break into such code, you will find it looping inside an exception handler.

最后，跟这些异常处理程序对应的 IAR 代码其实就一条跳转指令——跳到自己。这意味着一旦发生任何异常，CPU 就会卡在一个**死循环**里。这倒是有利于调试——你中断执行的时候，会发现程序停在某个异常处理程序里面转圈。

However, such a primitive policy is unacceptable for a production code, because the device will appear completely locked and unresponsive. This is known as denial of service.

但这种简陋的做法对**生产代码**（production code）来说是不可接受的——设备会完全锁死、毫无响应。这就是所谓的**拒绝服务**（denial of service）。

This concludes the lesson about the standard startup code. In the next lesson, you will learn how to replace the generic vector table with a real one that can handle all interrupts available in your microcontroller. You will also write the exception handlers that can be used in a production-quality code. And finally, you will start building the board support package for your LaunchPad board. All of this will set the stage for learning about interrupts.

关于标准启动代码的课就到这里。下一课你会学到如何用真正的向量表替换通用向量表，让你的微控制器能够处理所有中断。你还会编写可用于生产级代码的异常处理程序。最后，开始为 LaunchPad 板子构建**板级支持包**（Board Support Package, BSP）。这些都是在为学习中断打基础。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

Course web-page:
http://www.state-machine.com/quickstart

YouTube playlist of the course:
http://www.youtube.com/playlist?list=PLPW8O6W-1chwyTzI3BHwBLbGQoPFxPAPM

---

## 术语说明 / Terminology Notes

| 英文 / English | 中文 / Chinese | 说明 / Notes |
|---|---|---|
| Startup Code | 启动代码 | 在 `main` 函数之前运行的初始化代码 |
| Data Section | 数据段 | 程序中具有特定属性的连续内存区域 |
| Linker Map File | 链接器映射文件 | 链接器生成的包含内存布局信息的文件 |
| Reset Sequence | 复位序列 | 处理器复位后执行的初始操作序列 |
| Vector Table | 向量表 | 位于地址 0 处，包含异常和中断向量的表 |
| Stack Pointer (SP) | 栈指针 | 指向当前栈顶的寄存器 |
| Program Counter (PC) | 程序计数器 | 指向下一条要执行指令的寄存器 |
| Floating Point Unit (FPU) | 浮点单元 | 硬件浮点运算协处理器 |
| .text Section | .text 段 | 存放程序代码的段 |
| .rodata Section | .rodata 段 | 存放只读数据的段 |
| .data Section | .data 段 | 存放已初始化的可读写数据的段 |
| .bss Section | .bss 段 | 存放未初始化数据的段，启动时需清零 |
| BSS | BSS | Block Started by Symbol，历史名称 |
| Initializer Bytes | 初始化字节 | ROM 中存放变量初始值的段 |
| Block Copy | 块复制 | 将一段内存整块复制到另一区域 |
| Exception | 异常 | 处理器在运行中检测到的不正常事件 |
| Exception Handler | 异常处理程序 | 处理特定异常的函数 |
| Interrupt Vector | 中断向量 | 中断服务程序的入口地址 |
| Interrupt Request (IRQ) | 中断请求 | 外设发出的中断信号 |
| Non-Maskable Interrupt (NMI) | 不可屏蔽中断 | 无法被软件屏蔽的高优先级中断 |
| Thumb Mode | Thumb 模式 | ARM Cortex-M 唯一支持的指令集模式 |
| Addressing Mode | 寻址模式 | 指令访问操作数的方式 |
| Hardwired | 硬连线 | 处理器硬件固化的行为，不可软件修改 |
| Least Significant Bit (LSB) | 最低有效位 | 二进制数中最右边的一位 |
| Board Support Package (BSP) | 板级支持包 | 针对特定硬件板的底层驱动软件包 |
| Zero-Initialize | 零初始化 | 将内存区域全部设置为零 |
| Denial of Service | 拒绝服务 | 设备因异常处理不当而无响应的状态 |
| Production Code | 生产代码 | 用于最终产品的正式代码 |
| Disassembly View | 反汇编视图 | 显示机器码对应汇编指令的调试窗口 |
| Datasheet | 数据手册 | 微控制器的技术参考文档 |
| Contiguous Memory | 连续内存 | 地址连续的内存区域 |
| Tight Loop | 紧凑循环 | 执行少量指令的高效循环 |
| LDR / STR | 加载/存储指令 | ARM 中读写内存的指令 |
| BL (Branch with Link) | 带链接的跳转 | ARM 中的函数调用指令 |
| CSTACK | C 栈 | C 程序使用的栈空间段名 |
| BusFault_Handler | 总线故障处理程序 | 处理总线错误的异常处理程序 |
