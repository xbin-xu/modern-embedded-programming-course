# 第14课：嵌入式软件构建过程与替换向量表 / Lesson 14: Embedded Software Build Process and Replacing the Vector Table

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll continue the subject of the startup code. Today, you will learn about the embedded software build process so that you can replace the generic vector table from the IAR library with your own.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，这节课我们接着聊**启动代码（startup code）**的话题。今天你要学习的是**嵌入式软件构建过程（embedded software build process）**，学完之后你就能用自己的**向量表（vector table）**替换掉 IAR 库里的那个通用版本了。

As usual, let's get started with making a copy of the previous "lesson13" project and renaming it to "lesson14". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

老规矩，先把之前的"lesson13"项目复制一份，重命名为"lesson14"。如果你是刚开始跟这门课，可以去 state-machine.com/quickstart 下载之前的项目文件。

Get inside the new "lesson14" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

进入新的"lesson14"目录，双击工作区文件打开 IAR 工具集。如果你还没装 IAR，请先回到第 0 课。

To quickly summarize what happened so far: at the end of the last lesson you encountered an important data structure at address 0 in ROM. This turned out to be the "vector table" of your ARM Cortex-M processor.

简单回顾一下：上一课快结束时，你在 ROM 地址 0 的地方看到了一个重要的数据结构——它就是你 ARM Cortex-M 处理器的向量表。

The vector table you saw, however, turned out to be incomplete compared to the vector table described in the datasheet for your specific TM4C microcontroller.

不过，跟你用的 TM4C 微控制器数据手册里描述的向量表一比，你看到的这个是不完整的。

This was because you were using the default startup code from the IAR library. In this lesson, you will replace this generic vector table with your own.

原因是你用的还是 IAR 库里的默认启动代码。这节课，你要用自己的向量表把这个通用版本替换掉。

But to understand how the replacing would work, you need to step back and take a deeper look at the embedded software build process.

要搞明白替换的原理，我们得退一步，先深入了解一下嵌入式软件构建过程。

So, here is a diagram that shows the main steps of building your embedded project.

先看这张图，它展示了构建一个嵌入式项目的主要步骤。

First, I'd like to make sure, however, that you understand that all these steps are performed by tools such as the IAR Workbench on a desktop computer, called the **host machine**,

首先我要确认你理解一点：所有这些步骤都是由桌面电脑上的工具（比如 IAR Workbench）来完成的，这台桌面电脑叫做**宿主机（host machine）**，

even though the produced program is for a completely different computer, such as your LaunchPad board, called the **target machine**.

而生成的程序却要跑在一台完全不同的电脑上——比如你的 LaunchPad 开发板——它叫做**目标机（target machine）**。

This aspect, called **cross-development**, is very characteristic for embedded systems. It just doesn't make sense to run the compiler and linker on the small embedded target machine, such as the LaunchPad board.

这种模式叫做**交叉开发（cross-development）**，是嵌入式系统非常典型的特征。你想啊，在 LaunchPad 这种小型嵌入式目标机上跑编译器和链接器，根本说不通嘛。

This is also in stark contrast with software development for the desktop computers, where you typically both develop and run the software on the same machine (so the host is also the target). This type of software development is often called "native development".

这跟桌面软件开发截然不同——桌面开发通常是在同一台机器上既开发又运行（宿主机就是目标机）。这种开发方式通常叫做**本地开发（native development）**。

But going back to the embedded build process, the source files, such as main.c and delay.c are fed to the C-language compiler, which turns them into the so called **object files** main.o and delay.o.

回到嵌入式构建过程。源文件（比如 `main.c` 和 `delay.c`）被送进 C 语言编译器，编译器把它们转换成所谓的**目标文件（object file）**，比如 `main.o` 和 `delay.o`。

Next, all object files from the project, together with any standard and other libraries, as well as the linker script, are fed to the linker, which combines them into the final program.

接下来，项目里所有的目标文件，加上各种标准库和其他库，还有**链接脚本（linker script）**，一起送进**链接器（linker）**，由它把这些东西组合成最终的程序。

At this point, most textbooks would simply tell you that an object file contains "relocatable" machine code that is not directly executable, because it is not yet committed to any specific address in memory. It is the job of the linker to combine all the objects, resolve the cross-module references, and fix the addresses.

大多数教科书到这里就会告诉你：目标文件里放的是"可重定位"的机器代码，不能直接执行，因为还没有绑定到具体的内存地址。链接器的工作就是把所有目标文件合并、解析**跨模块引用（cross-module reference）**、确定地址。

I could also leave it at that, but this course is about looking under the hood, so I think it is worth while to see how object files are organized and what "relocatable code" really means.

我也可以就这么带过，但本课程的风格就是刨根问底。所以我觉得值得看看目标文件内部是怎么组织的，"可重定位代码"到底是什么意思。

In your project, object files are located in the sub-directory Debug\Obj. Here, among others, you can find delay.o and main.o.

在你的项目里，目标文件放在 `Debug\Obj` 子目录下。在那里你可以找到 `delay.o`、`main.o` 等文件。

If you open one of them in a text editor, you would see mostly garbage, because it is a binary file.

用文本编辑器打开其中一个，你基本看到的都是乱码——因为它是二进制文件。

However, even viewed as text, you should recognize that the file appears to contain distinct sections.

不过，即使是以文本方式看，你也应该能发现文件里似乎有不同的**段（section）**。

Also, the first few ASCII characters of the file spell out 'E', 'L', 'F'. This is the indicator of the **ELF file format**, which stands for "Executable and Linkable Format", also known as "Extensible Linking Format".

另外，文件开头几个 ASCII 字符拼出来是 'E'、'L'、'F'。这是 **ELF 文件格式**的标志——ELF 全称"Executable and Linkable Format"（可执行可链接格式），也叫"Extensible Linking Format"（可扩展链接格式）。

ELF is not the only format for object files, but it is one of the most popular formats used by modern development tools. So, I think it is a good idea for you to get somewhat familiar with ELF files and the tools that allow you to inspect them.

目标文件格式不止 ELF 一种，但它是现代开发工具中最流行的格式之一。所以我觉得你有必要稍微熟悉一下 ELF 文件，以及可以查看它们的工具。

For example, the IAR toolchain comes with the command-line tool called ielfdumparm.exe, which you can use to dump the contents of the binary ELF file in a human-readable text.

比如，IAR 工具链自带一个命令行工具叫 `ielfdumparm.exe`，你可以用它把二进制 ELF 文件的内容转储成人类可读的文本。

Another popular tool for this is the **objdump** utility from the GNU compiler collection, which you can also use on the ELF files generated by IAR, because ELF is a standard format.

另一个常用的工具是 GNU 编译器集里的 **objdump** 工具。因为 ELF 是标准格式，所以它也能用来查看 IAR 生成的 ELF 文件。

So, here for example I invoke the IAR ielfdumparm utility in the Windows command prompt. In most of such programs, to see a quick help, just launch the program without any parameters.

比如，我在 Windows 命令提示符里调用 IAR 的 `ielfdumparm` 工具。这类程序大多数都是这样——想看快速帮助，直接不带参数运行就行。

From the short help, you can see that the option --all allows you to dump all the sections of the ELF file.

从简短的帮助信息可以看到，`--all` 选项可以把 ELF 文件的所有段都转储出来。

Because the listing is quite long, I capture the output into a text file main.txt.

输出内容挺长的，所以我把它重定向到一个文本文件 `main.txt` 里。

Let's open the file in the IAR IDE.

在 IAR IDE 里打开这个文件。

As you can see, the ELF file indeed contains several sections, many of which you have encountered in the last lesson 13, such as .data, .bss, and .text, for initialized data, uninitialized data, and code, respectively.

可以看到，ELF 文件确实包含好几个段。其中很多你在上一课（第 13 课）已经见过了，比如 `.data`、`.bss` 和 `.text`，分别对应已初始化数据、未初始化数据和代码。

The remaining sections hold the symbolic information for the linker and a lot of sections contain debug information for the debugger.

剩下的段存放的是链接器需要的**符号信息（symbolic information）**，还有很多段放的是调试器需要的**调试信息（debug information）**。

At this point, it should become clear that you should never use the size of the object file to assess the code size generated from a given .c source code, because the actual machine code is only a small part among many other parts in an object file. The only reliable source of information about the code size of various modules is the **linker map file**, that you encountered in the previous lesson 13.

说到这里你应该明白了：千万别拿目标文件的大小来衡量某个 `.c` 源文件生成了多少代码。实际的机器代码只是目标文件里众多内容中的一小块。关于各模块代码大小的可靠信息来源，是你在第 13 课里见过的那个**链接映射文件（linker map file）**。

Now, let's take a look at the final image c.out produced by the linker.

现在来看看链接器生成的最终映像 `c.out`。

Again, if you quickly open it as text, you can see the 'ELF' signature at the top, so this is also an ELF file.

同样，用文本方式打开它，顶部能看到 'ELF' 签名——所以它也是一个 ELF 文件。

This means that you can also dump the content of the c.out file using the IAR ielfdumparm utility, like so.

也就是说，你同样可以用 IAR 的 `ielfdumparm` 工具来转储 `c.out` 的内容，像这样。

So now let's open the human-readable dump of the final image and compare it with the dump of the main.o object file by putting them side by side.

现在把最终映像的可读转储打开，跟 `main.o` 目标文件的转储并排放在一起对比一下。

Let me scroll the final image to the .text16 section, which contains the code of the main function.

把最终映像滚动到 `.text16` 段——这里放的是 `main` 函数的代码。

By the way, the ELF dump utility is one of the quickest ways to see the **disassembly** of the generated code, without necessarily loading the program into the target and inspecting the disassembly view. You can use either the dump of a specific object file or the final image.

顺便说一句，ELF 转储工具是查看生成代码**反汇编（disassembly）**的最快方法之一，不用把程序加载到目标机上看反汇编视图。你可以转储某个目标文件，也可以转储最终映像。

When you compare the ELF dumps, you can see that most instructions are exactly the same in main.o as they are in the final image c.out.

对比两份 ELF 转储，你会发现 `main.o` 里的大部分指令跟最终映像 `c.out` 里的一模一样。

However, interestingly, some instructions have a different encoding.

不过有趣的是，有些指令的编码不一样。

For example, the 32-bit BL instruction, by which main calls the delay function is encoded as 0xf7ff 0xfffe in the object file and 0xf000 0xf820 in the final image. What's going on here?

举个例子：`main` 调用 `delay` 函数用的那条 32 位 **BL 指令**，在目标文件里编码是 `0xf7ff 0xfffe`，到了最终映像里却变成了 `0xf000 0xf820`。怎么回事？

Well, BL is a **PC-relative instruction**, meaning that in order to branch to the delay function the Program Counter (PC) will be incremented by the signed immediate offset encoded in the instruction itself. The problem is that the object file does not know where the delay function will end up in memory, so the BL opcode in the object file contains a generic offset 0x7fffffe.

BL 是一条 **PC 相对指令（PC-relative instruction）**，意思是：要跳转到 `delay` 函数，**程序计数器（Program Counter，简称 PC）**会加上指令里编码的那个有符号立即数偏移量。问题是，目标文件不知道 `delay` 函数最终会被放在内存的哪个位置，所以目标文件里的 BL 操作码用的是个通用偏移量 `0x7fffffe`。

This offset is then fixed by the linker, after the linker decides where the delay function will be in memory with respect to main.

等链接器确定了 `delay` 函数相对于 `main` 在内存中的位置之后，就会修正这个偏移量。

But this does not end here. The linker needs to fix not just addresses of functions, but of variables as well.

但不止如此。链接器不光要修正函数地址，还得修正变量地址。

For example, the actual constant addresses of the variables p1, w, t, p2, and w2 are not known at compile time either. So, if you look in the **constant pool** in the section ??main_0 that follows immediately after the main function code, you can see that all these addresses are zero in the object file.

比如变量 `p1`、`w`、`t`、`p2`、`w2` 的实际地址，在编译时也是不知道的。你看一下紧跟在 `main` 函数代码后面的 `??main_0` 段里的**常量池（constant pool）**——在目标文件里，这些地址全是零。

So here again, when compared with the final ELF image, the linker had to fix this constant pool, after figuring out where to put the variables p1, w, t, and so on in the data section.

跟最终的 ELF 映像一比就知道了：链接器在确定了 `p1`、`w`、`t` 等变量在数据段里的位置之后，把这些地址全部修正了。

From all these examples, I hope you start to appreciate the job of the linker and see for yourself what "relocatable code" really means. You can also understand now that the linker must be specific to the target processor, because it must "know" the instructions and how to fix them at the binary opcode level. This means, for example, that a linker designed for the x86 processor of your PC cannot be used to link programs for the ARM processor, even though all these tools might be using the ELF file format. You need both a compiler and a linker for the same processor.

通过这些例子，希望你开始体会到链接器到底干了什么，也亲眼看到了"可重定位代码"的真正含义。你也能理解为什么链接器必须是针对特定**目标处理器（target processor）**的——因为它必须"认识"指令格式，知道怎么在二进制操作码级别去修正地址。也就是说，给你 PC 的 x86 处理器设计的链接器，没法用来链接 ARM 处理器的程序，哪怕大家都用 ELF 格式也不行。编译器和链接器必须是配套的，针对同一个处理器。

OK, so now that you understand what kind of code is generated into the object files by the compiler, and perhaps more importantly, in which ways the object files are still incomplete, let's talk a bit about how the linker resolves the cross-module references to functions and global variables.

好，现在你了解了编译器在目标文件里生成了什么样的代码，也许更重要的是，也知道了目标文件在哪些方面还不完整。接下来我们聊聊链接器是怎么解析对函数和**全局变量（global variable）**的跨模块引用的。

First, you need to realize that every object provides **symbols** that it exports, meaning that they are defined in the object and can be used by other objects. For example, main.o exports the symbols p1, w, t, p2, w1, w2, and main.

首先你要知道，每个目标文件都会**导出（export）**一些**符号（symbol）**——也就是说，这些符号在该目标文件里定义了，别的目标文件可以使用。比如 `main.o` 导出了符号 `p1`、`w`、`t`、`p2`、`w1`、`w2` 和 `main`。

An object might also have **imported symbols**, that is, symbols that it needs but does not define. For example, main.o imports the function delay, because it calls it, yet does not define it.

目标文件也可能有**导入的符号（imported symbol）**——就是它需要用但没有自己定义的符号。比如 `main.o` 导入了函数 `delay`，因为它调用了这个函数，但没有自己定义它。

Now, resolving inter-dependencies means that the linker must match all imported references to the exported references.

那解析依赖关系是什么意思呢？就是链接器必须把所有导入的引用跟导出的引用一一匹配上。

As the linker works on one object file at a time, it internally uses two lists: a list of **exported symbols**, and a list of **undefined symbols** in all the objects encountered so far.

链接器是一次处理一个目标文件的，它内部维护两个列表：一个**已导出符号列表（exported symbol list）**，一个**未定义符号列表（undefined symbol list）**——后者记录的是到目前为止遇到的所有还没找到定义的符号。

For example, at the very beginning of the linking process of your project, the exported list is empty and the undefined list contains only one symbol: __vector_table. This latter symbol is specific to the IAR toolset and might be different for other toolsets.

举个例子，你的项目刚开始链接的时候，已导出列表是空的，未定义列表里只有一个符号：`__vector_table`。这个符号是 IAR 工具集特有的，其他工具集可能不一样。

The general rule is that all object files directly included in the project, such as main.o and delay.o, are always linked into the final image. Because of this, the order of linking does not matter for those files, but let's assume that the first will be main.o.

一条通用规则是：所有直接包含在项目里的目标文件（比如 `main.o` 和 `delay.o`），总是会被链接进最终映像。正因为如此，这些文件的链接顺序无所谓，不过我们假设第一个是 `main.o`。

As the linker processes this object file, it adds all the exported symbols to the exported list and also takes every symbol imported by the object file, such as delay, and tries to find it in the exported list. If the symbol is not found, as in this case, the linker adds it to the undefined list. So after processing the main.o object, the undefined list contains __vector_table and delay.

链接器处理这个目标文件时，把它所有导出的符号加到已导出列表里。同时，对于这个目标文件导入的每个符号（比如 `delay`），去已导出列表里找。找不到的话——就像这里一样——就把它加到未定义列表里。所以处理完 `main.o` 之后，未定义列表里有 `__vector_table` 和 `delay`。

Next is the delay.o object file. This file exports delay, which is added to the exported list and at the same time removed from the undefined list, because it is now known and resolved. The delay.o file does not import anything else, so the undefined list contains only the __vector_table symbol.

接下来是 `delay.o`。这个文件导出了 `delay`——加到已导出列表，同时从未定义列表里移除，因为现在找到定义了。`delay.o` 不再导入其他东西，所以未定义列表里只剩 `__vector_table` 这一个符号。

At this point there are no more object files in your project, yet the undefined list is still not empty, so the linker proceeds to look through the standard libraries.

到这里，你项目里没有更多目标文件了，但未定义列表还没清空，所以链接器接下来去**标准库（standard library）**里找。

Libraries are simply bundled collections of object files. However, the linking rules are different for libraries than for objects included directly.

**库（library）**简单说就是一堆目标文件打了个包。但库的链接规则跟直接包含的目标文件不一样。

The critical difference is that objects from a library are added to the final image only if they contain symbols in the undefined list. Otherwise they are not added at all.

关键区别在于：库里的目标文件，只有当它包含未定义列表里需要的符号时，才会被加进最终映像。否则根本不会被链接进来。

It turns out that the __vector_table symbol is found to be exported by the object file vector_table_M.o in the IAR library rt7M_tl.a.

结果发现，`__vector_table` 这个符号是由 IAR 库 `rt7M_tl.a` 里的 `vector_table_M.o` 这个目标文件导出的。

How do I know this? Well, you can find it inside the linker map file, by searching for "__vector_table". You find that symbol in the Entry List section, where you can see that it comes from the vector_table_M.o object.

我怎么知道的？你去链接映射文件里搜 `__vector_table` 就能找到。在 Entry List（入口列表）段里能看到，这个符号来自 `vector_table_M.o` 这个目标文件。

Next, you search the map file for this object name, and you find it again in the Module Summary section, under the module rt7M_tl.a, which you recognize as a library by the extension .a (archive).

接着在映射文件里搜这个目标文件名，在 Module Summary（模块摘要）段又能找到它，属于 `rt7M_tl.a` 这个模块。看扩展名 `.a`（archive，归档）就知道这是个库。

However, it turns out that the object file vector_table_M.o has also its own imported symbols, such as __iar_program_start, BusFault_handler, and so on.

不过，`vector_table_M.o` 这个目标文件自己也有导入的符号，比如 `__iar_program_start`、`BusFault_handler` 等等。

So at this point, the linker applies another rule for linking libraries, which is to keep searching all object files in the current library for the undefined symbols.

所以这时候，链接器又用上了库链接的另一条规则：在当前库的所有目标文件里继续搜索未定义的符号。

So again, as you can find out from the map file, __iar_program_start is found in the cstartup_M.o object in the same library,

同样，从映射文件里可以看到，`__iar_program_start` 在同一个库的 `cstartup_M.o` 目标文件里找到了。

This object has some more imported symbols of its own, such as __iar_data_init3, __iar_zero_init3, __low_level_init, and some others.

这个目标文件自己又导入了一些符号，比如 `__iar_data_init3`、`__iar_zero_init3`、`__low_level_init` 等等。

Interestingly, __iar_program_start imports also the main function, which is resolved immediately, because it is in the exported list and in fact, it is defined in your own object file main.o.

有意思的是，`__iar_program_start` 还导入了 `main` 函数——这个引用立刻就被解析了，因为它就在已导出列表里，而且实际上就是你自己写的 `main.o` 里定义的。

The other undefined symbols are resolved by the library linking rule, because they are exported by the other objects in the standard library.

其他未定义的符号也通过库链接规则被解析了，因为它们都是由标准库里的其他目标文件导出的。

An interesting observation from linking libraries is that the object files in libraries typically contain only one function or one variable, as opposed to containing a whole bunch of them.

从库的链接过程中可以观察到一个有趣的现象：库里的目标文件通常只包含一个函数或一个变量，而不是一股脑塞一堆。

This fine granularity of objects ensures that only stuff actually needed is taken from the library. If, on the other hand, the objects would contain multiple functions and variables, all this would be linked in, and so you would bloat the final image unnecessarily.

这种**细粒度（fine granularity）**的目标文件保证了只从库里拿真正需要的东西。反过来想，如果一个目标文件里塞了好几个函数和变量，那它们全都会被链接进来，最终映像就白白变大了。

So, if you ever develop your own libraries, remember to make objects small and nimble. Ideally, you should define only one function or one global variable per module.

所以如果你以后要开发自己的库，记住让目标文件保持小巧精悍。理想情况下，每个模块只定义一个函数或一个全局变量。

But going back to your project, the linker eventually resolves all the references from the standard libraries, the undefined list becomes empty and the linking process ends.

回到你的项目——链接器最终从标准库里解析了所有引用，未定义列表清空了，链接过程结束。

Of course, another possible outcome is that the linker runs out of all objects and libraries, yet the undefined list still contains some symbols. In this case, you get the linker error and a dump of all the unresolved references still present in the undefined list.

当然，还有一种可能：链接器遍历了所有目标文件和库，未定义列表里还是有符号。这时候你就会得到**链接错误（linker error）**，同时会列出所有**未解析引用（unresolved reference）**。

Typically to fix such errors you need to add an object or a library. However, sometimes you might need to change the order of libraries.

通常要修这种错误，你只需要添加一个目标文件或库。不过有时候你可能需要调整库的顺序。

Occasionally, you might even have to specify some libraries more than once in the linking order, to resolve circular inter-dependencies among them.

偶尔，你甚至可能需要在链接顺序里重复指定某些库，以解决它们之间的**循环相互依赖（circular inter-dependency）**。

I don't have the time here to present you an example of circular dependencies among libraries, but in the class notes to this video, I provide a web link to a good article about linking programs with libraries.

这里没有时间演示库之间循环依赖的例子了，但本视频的课程笔记里，我给了一篇好文章的链接，讲的就是用库来链接程序。

Finally, in the last few minutes of this lesson let's try to apply the knowledge of the build process to the task at hand, which is to replace the generic vector table from the IAR library with your own.

最后几分钟，我们把构建过程的知识用到手头的任务上——用自己的向量表替换 IAR 库里的那个通用版本。

Well, how about you define the symbol __vector_table in your own object module linked directly into your project. This module then would be linked in BEFORE any standard IAR libraries, so the library-version of the vector table won't be used. This is exactly what you need.

思路是这样的：你在自己的目标模块里定义符号 `__vector_table`，然后直接链接到项目里。这个模块会在所有标准 IAR 库之前被链接，所以库版本的向量表就不会被用到了。正好就是你要的效果。

So, the plan is to add another C file to your project, which I will name startup_tm4c.c, because it will be specific to your TM4C microcontroller.

计划是给项目再加一个 C 文件。我给它起名叫 `startup_tm4c.c`，因为它是专门针对你的 TM4C 微控制器的。

But wait a minute, how a C module can accomplish anything at the startup time, where the machine is not ready yet for executing C. I mean, the stack pointer is not set up yet, the initialized data is not copied from ROM to RAM, and the .bss section is not cleared yet either.

等等，C 模块怎么能在启动阶段做事情呢？那时候机器还没准备好执行 C 代码啊——**栈指针（stack pointer）**还没设，已初始化的数据还没从 ROM 拷贝到 RAM，`.bss` 段也还没清零。

So, yes, you are absolutely right to raise such objections. And in fact, the startup code for most other processors can't be written in C and requires you to use assembly language.

所以你提出这些疑问是完全合理的。事实上，大多数其他处理器的启动代码没法用 C 来写，必须用**汇编语言（assembly language）**。

However, the ARM Cortex-M has been specifically designed to reduce the need for low-level assembly programming.

不过 ARM Cortex-M 的设计目标之一就是尽量减少底层汇编编程的需求。

But even for Cortex-M, the startup code will require some non-standard language extensions and of course you will have to be careful not to assume any initialization of the .data section or clearing the .bss section.

但即使是 Cortex-M，启动代码也需要一些**非标准的语言扩展（non-standard language extension）**，当然你还得注意，不能假设 `.data` 段已经初始化好了、或者 `.bss` 段已经清零了。

With these caveats, let's start coding the startup_tm4c.c file.

了解了这些注意事项，我们开始写 `startup_tm4c.c` 文件。

The main objective is to define the global array named __vector_table, with the layout you saw at the very beginning of this lesson in the disassembly view.

主要目标是定义一个叫 `__vector_table` 的**全局数组（global array）**，布局要跟这节课一开始你在反汇编视图里看到的一样。

So, the first attempt to provide your own vector table is to define it as an int array and initialize it explicitly at the point of definition, as you've learned in the previous lesson.

所以第一次尝试：把它定义成一个 `int` 数组，在定义的时候显式初始化——就像上一课学的那样。

For starters, let's skim over the initialization by just typing a couple of zeros to make the compiler happy, and instead let's focus first on the biggest challenge here, which is the proper placement of the vector table in memory.

先随便填几个零让编译器不报错，初始化的事后面再说。我们要先解决这里最大的难题——把向量表放到正确的内存位置。

To see exactly where the linker has put the original vector table from the library, open the linker map file.

要看链接器把库里原来的向量表放在了哪里，打开链接映射文件。

As you can see, the default vector table was in the .intvec section at address zero in ROM.

如你所见，默认向量表放在了 `.intvec` 段里，地址是 ROM 的 0。

To understand how this section is defined, you need to open the linker script file project.icf. I've mentioned the linker script already in Lesson 10, where you saw how to adjust the size of the stack.

要搞明白这个段是怎么定义的，得打开链接脚本文件 `project.icf`。我在第 10 课就提过链接脚本了，当时你还看到了怎么调整栈的大小。

Today, you also already saw the linker script in the diagram of the embedded build process. The purpose of the linker script is to tell the linker where to place the various merged program sections in the address space.

今天在嵌入式构建过程的图里你也看到链接脚本了。它的作用就是告诉链接器，各种合并后的程序段应该放在**地址空间（address space）**的哪个位置。

So, let's open the linker script file project.icf.

好，打开链接脚本文件 `project.icf`。

The part of the script delimited by the special comments is controlled by the Linker Configuration File editor.

用特殊注释括起来的那部分脚本，是由**链接配置文件编辑器（Linker Configuration File Editor）**控制的。

You can open this editor through the "project options" dialog box.

你可以通过"项目选项"对话框打开这个编辑器。

The location of the .intvec section is controlled in the first tab of this editor.

`.intvec` 段的位置由这个编辑器的第一个选项卡控制。

The second tab controls the start and end of ROM as well as the start and end of RAM.

第二个选项卡控制 ROM 的起止地址，还有 RAM 的起止地址。

Finally, the third tab controls the size of stack and heap.

第三个选项卡控制**栈（stack）**和**堆（heap）**的大小。

Let me slightly change the size of the stack to show you how it gets updated in the linker script file.

我稍微改一下栈的大小，给你看看链接脚本文件会怎么更新。

But going back to the .intvec section, it is defined in the "place" command at the bottom of the linker script. The section is read-only and is placed at the address specified by the variable ICFEDIT_intvec_start.

回到 `.intvec` 段——它在链接脚本底部的 `place` 命令里定义。这个段是只读的，被放在变量 `ICFEDIT_intvec_start` 指定的地址处。

All this has important implications for your startup file, because you need to make sure that your own vector table is placed in this special .intvec linker section.

这些对你的启动文件很重要，因为你得确保自己的向量表被放到这个特殊的 `.intvec` 链接器段里。

Unfortunately, there is no standard C syntax to place variables in specific sections. But IAR provides an extension, which looks as follows:

可惜标准 C 语法没法指定变量放到哪个段。不过 IAR 提供了一个扩展语法，长这样：

You can specify the section by an ampersand followed by the section name in double quotes.

用 `@` 符号后面跟双引号括起来的段名，就能指定段了。

Make sure that the map file is visible and press F7 to build the project.

确保映射文件可见，然后按 F7 构建项目。

As you can see, the compiler happily accepted your new startup file, but the linker map file looks strange.

可以看到，编译器高兴地接受了你的新启动文件，但链接映射文件看起来有点不对劲。

The .intvec section is not at address zero as before, but rather has been pushed down to the RAM region.

`.intvec` 段不在地址 0 了，而是被挤到了 RAM 区域。

I wonder if you can tell why?

你能看出原因吗？

Well, the problem is that your vector table is a variable that can change, so the compiler can't put into the read-only memory.

问题在于你的向量表是个可变的变量，编译器没法把它放进**只读存储器（read-only memory，ROM）**。

To force the vector table array into the ROM, you need to define the vector table as a constant. For this, the C language provides the keyword "const".

要强制把向量表数组放进 ROM，你得把它定义成常量。C 语言里用 `const` 关键字来做这件事。

The use of the "const" keyword in C deserves a whole separate lesson, but syntactically it is very similar to the "volatile" keyword that I explained in lesson 5.

`const` 关键字在 C 语言里的用法值得专门讲一整课，不过语法上它跟我第 5 课讲过的 `volatile` 关键字很像。

Similar to "volatile", the keyword "const" can be placed either before or after the type. Again, just like with "volatile", I recommend placing "const" after the type.

跟 `volatile` 一样，`const` 可以放在类型前面也可以放在类型后面。同样，我还是建议你把 `const` 放在类型后面。

When you build the project and check the linker map file now, the vector table is indeed placed in ROM and at the correct address 0.

再构建一次项目，检查链接映射文件——这次向量表确实被放到了 ROM 里，地址也是正确的 0。

Also, if you look at the object module that provides the vector table, it turns out to be your file startup_tm4c.o.

再看一下提供向量表的目标模块——正是你自己的文件 `startup_tm4c.o`。

So congratulations, you have achieved the objective of this lesson.

恭喜，这节课的目标达成了。

Please note, however, that at this point the vector table is not initialized correctly, so the code won't work. In fact, I just found out that the code might hang up your debugger and prevent you from programming your board.

不过要注意，这个时候向量表还没有正确初始化，代码是不能正常工作的。事实上我发现这段代码可能会导致调试器卡死，让你没法给开发板烧录程序。

Therefore, just in case, please initialize your vector table with the following safe values.

所以保险起见，请先用下面的安全值来初始化你的向量表。

This concludes the lesson about the embedded software build process and replacing the default vector table. In the next lesson, you will learn how to properly initialize the vector table with the correct stack pointer and all interrupts available in your microcontroller.

关于嵌入式软件构建过程和替换默认向量表的课就到这里。下一课，你将学习如何正确地初始化向量表——包括正确的栈指针，以及微控制器中所有可用的**中断（interrupt）**。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

Links used in this lesson:

Article "Library order in static linking":
http://eli.thegreenplace.net/2013/07/09/library-order-in-static-linking

Course web-page:
http://www.state-machine.com/quickstart

YouTube playlist of the course:
http://www.youtube.com/playlist?list=PLPW8O6W-1chwyTzI3BHwBLbGQoPFxPAPM

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---|---|---|
| Startup Code | 启动代码 | 处理器复位后、进入 main 函数前执行的初始化代码 |
| Vector Table | 向量表 | 存放异常/中断处理程序地址的表，位于地址 0 |
| Embedded Software Build Process | 嵌入式软件构建过程 | 包括编译、汇编、链接等步骤的完整流程 |
| Cross-Development | 交叉开发 | 在宿主机上开发、在目标机上运行的软件开发模式 |
| Host Machine | 宿主机 | 运行开发工具的桌面计算机 |
| Target Machine | 目标机 | 运行生成程序的嵌入式设备 |
| Native Development | 本地开发 | 在同一台机器上开发和运行软件的模式 |
| Object File | 目标文件 | 编译器输出的包含可重定位机器代码的文件 |
| Linker | 链接器 | 将目标文件和库组合成最终可执行程序的工具 |
| Linker Script | 链接脚本 | 指导链接器如何在地址空间中安排各段的配置文件 |
| Linker Map File | 链接映射文件 | 链接器生成的包含内存布局和符号地址的文件 |
| Relocatable Code | 可重定位代码 | 尚未绑定到具体内存地址的机器代码 |
| Cross-Module Reference | 跨模块引用 | 一个模块引用另一个模块中定义的符号 |
| ELF (Executable and Linkable Format) | ELF 文件格式 | 一种广泛使用的可执行和可链接文件标准格式 |
| Section | 段 | 目标文件或可执行文件中的逻辑分区（如 .text、.data、.bss） |
| Symbol | 符号 | 目标文件中定义的函数名或变量名 |
| Exported Symbol | 导出符号 | 在目标文件中定义并可供其他模块使用的符号 |
| Imported Symbol | 导入符号 | 目标文件中引用但在其他模块中定义的符号 |
| Undefined Symbol | 未定义符号 | 已被引用但尚未找到定义的符号 |
| Standard Library | 标准库 | 编译器/工具链提供的预编译函数集合 |
| Library | 库 | 打包的目标文件集合（扩展名通常为 .a 或 .lib） |
| PC-Relative Instruction | PC 相对指令 | 使用相对于程序计数器的偏移量进行跳转的指令 |
| Program Counter (PC) | 程序计数器 | 处理器中指向当前执行指令的寄存器 |
| Constant Pool | 常量池 | 紧跟在函数代码后的常量数据区 |
| Disassembly | 反汇编 | 将机器码转换为汇编指令的过程或结果 |
| Linker Error | 链接错误 | 链接过程中因未解析符号等问题产生的错误 |
| Unresolved Reference | 未解析引用 | 链接器无法找到定义的符号引用 |
| Circular Inter-Dependency | 循环相互依赖 | 两个或多个库互相引用对方符号的情况 |
| Non-Standard Language Extension | 非标准语言扩展 | 编译器提供的超出标准 C 语言规范的扩展功能 |
| Stack Pointer | 栈指针 | 指向当前栈顶的处理器寄存器 |
| Global Variable | 全局变量 | 在函数外定义的、作用域为整个程序的变量 |
| const | const 关键字 | C 语言关键字，用于定义常量，修饰的变量不可修改 |
| volatile | volatile 关键字 | C 语言关键字，防止编译器对变量访问进行优化 |
| Fine Granularity | 细粒度 | 将库中的目标文件拆分为小单元的策略 |
