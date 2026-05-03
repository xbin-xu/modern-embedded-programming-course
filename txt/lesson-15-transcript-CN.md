# 第15课：启动代码（三）——向量表初始化 / Lesson 15: Startup Code (Part 3) — Vector Table Initialization

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll finish the subject of the startup code. Today, you will learn how to properly initialize the vector table with the correct stack pointer and all interrupts available in your Tiva-C microcontroller. You will also see how to write and test the exception handlers, so that they actually do what they are supposed to.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。今天我们来把启动代码（Startup Code）这个话题收尾。你将学会如何正确初始化**向量表**（Vector Table），包括设置正确的栈指针以及 Tiva-C 微控制器中所有可用的中断。另外，你还会看到如何编写和测试**异常处理程序**（Exception Handler），让它们真正派上用场。

As usual, let's get started with making a copy of the previous "lesson14" project and renaming it to "lesson15". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

老规矩，先把上一课的 "lesson14" 项目复制一份，改名为 "lesson15"。如果你是刚加入课程的，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson15" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

进入新的 "lesson15" 目录，双击工作区文件打开 IAR 工具集。如果你还没装 IAR，回到第 0 课看看怎么弄。

To quickly summarize what happened so far: at the end of the last lesson you have added a new file, named startup_tm4c.c to your project, in which you have defined the vector table as a constant array of integers. The focus of the previous lesson was to make sure that this new vector table from startup_tm4c.o was linked instead the generic one from the IAR library, and that it was located in the section ".intvec" at address zero.

快速回顾一下之前的进展：上一课结束时，你往项目里加了一个新文件 `startup_tm4c.c`，在里面把向量表定义成了一个整型常量数组。上一课的重点是确保链接器链接的是 `startup_tm4c.o` 里的新向量表，而不是 IAR 库里的那个通用版本，并且确保它被放在地址零处的 `.intvec` 段中。

But, the new vector table was not initialized properly yet. So the first order of business today will be to provide the right initialization.

不过，这个新向量表还没有正确初始化。所以今天第一件事，就是把它初始化好。

To remind you quickly how the vector table should look like, let me open the relevant Section in the TM4C Datasheet.

先帮你回忆一下向量表应该长什么样——打开 TM4C 数据手册里的相关章节。

Please remember that most pictures showing memory layouts in datasheets are drawn with low addresses at the bottom and high at the top, which is upside down compared to how you initialize variables in C or how you view them in the debugger.

注意，数据手册里画内存布局的时候，一般是低地址在下、高地址在上，跟你平时在 C 语言里初始化变量或者在调试器里看内存的方式正好是反过来的。

So, with this in mind, you can see that the very first value in the vector table should be the initial value of the Stack Pointer at address 0, and the next is the address of the Reset handler at address 4.

记住这一点之后你就看到了：向量表的第一个值应该是地址 0 处的**栈指针**（Stack Pointer）初始值，紧接着地址 4 处是**复位处理程序**（Reset Handler）的地址。

So, going back to your startup file, your first task will be to initialize the stack pointer correctly. The challenge here is not to break the compatibility with the standard IAR linker-script editor, where, as you might remember from the last lesson, you can set the CSTACK size.

好，回到你的启动文件。第一个任务是正确初始化栈指针。这里的难点在于——不能破坏跟 IAR 链接器脚本编辑器的兼容性。还记得上一课吗？你可以在那里设置 **CSTACK** 的大小。

To get an idea how to initialize the stack pointer in a way that's compatible with the IAR toolset, let's step back and load the workspace from lesson 13, which still used the default startup code from the IAR library.

要想知道怎么以兼容 IAR 工具集的方式初始化栈指针，我们退一步，先加载第 13 课的工作区——那个项目还在用 IAR 库里的默认启动代码。

When you load that older code to the LaunchPad board and look at address zero in disassembly, you can see that the first entry of the vector table is CSTACK$$Limit.

把旧代码加载到 LaunchPad 板上，在反汇编视图里看地址零，你会发现向量表的第一个条目是 **CSTACK$$Limit**。

This is an interesting observation, because it indicates that the symbol CSTACK$$Limit is known to the linker.

这个发现很有意思，说明 CSTACK$$Limit 这个符号是**链接器**（Linker）认识的。

So, let's reload our most recent workspace and try to use the symbol CSTACK$$Limit to initialize the stack pointer.

好，重新加载最新的工作区，试试用 CSTACK$$Limit 这个符号来初始化栈指针。

But before hacking the code, let's read some IAR Help. Click on Help/Contents menu and choose the "IAR C language extensions" section.

不过改代码之前，先看看 IAR 的帮助文档。点击 Help/Contents 菜单，选择 "IAR C language extensions" 章节。

When you read it, you will find out that the IAR linker generates symbols section-name$$Base and section-name$$Limit for every section defined in the program. The linker places the symbols at addresses corresponding to the base and limit of the section, respectively.

读完你会发现，IAR 链接器会为程序中定义的每个段生成 `section-name$$Base` 和 `section-name$$Limit` 这两个符号，分别放在段的起始地址和末尾地址处。

The way it works for the CSTACK section is shown in the following picture. The linker creates symbols CSTACK$$Base at the beginning of CSTACK and CSTACK$$Limit at the end of the CSTACK section in memory.

CSTACK 段的情况如下图所示。链接器在 CSTACK 的起始处创建 CSTACK$$Base 符号，在 CSTACK 段的末尾处创建 CSTACK$$Limit 符号。

Please note that on the ARM processor the stack grows from high RAM to low RAM, so the initial Stack Pointer needs to be set to the address of CSTACK$$Limit

注意，在 ARM 处理器上，**栈是从高地址往低地址增长的**，所以初始栈指针要设成 CSTACK$$Limit 的地址。

So, finally, back to the code, let's just try to initialize the stack pointer entry in the vector table to the address of the CSTACK$$Limit symbol.

好了，终于可以回到代码了。试试把向量表里的栈指针条目初始化为 CSTACK$$Limit 符号的地址。

When you compile the code by pressing F7, you get a compiler error that the symbol CSTACK$$Limit is undefined.

按 F7 编译，会报错说 CSTACK$$Limit 这个符号未定义。

This error should actually make sense, because the section symbols are created by the linker after the compilation, so the C compiler upstream the build process does not know about them.

这个报错其实完全说得通——段符号是编译之后由链接器创建的，所以编译阶段的 C 编译器根本不知道它们的存在。

So, you need to somehow inform the compiler about the existing CSATCK$$Limit symbol. In C, you do this by a declaration of the symbol as a variable.

所以你得想办法告诉编译器：CSTACK$$Limit 这个符号是存在的。在 C 语言里，做法就是把符号**声明**（declare）为一个变量。

So far in this video course, you have only used variable declarations that were definitions at the same time, like so:

到目前为止在这个课程里，你用过的变量声明都同时是**定义**（definition），就像这样：

```c
int CSTACK$$Limit;
```

But, this won't do in this case, because a variable definition introduces a new variable, which will cover the symbol defined by the linker.

但在这里不行，因为变量定义会引入一个全新的变量，把链接器定义的那个符号给盖掉。

Instead, all you want is to simply introduce the symbol to the compiler, without creating it and allocating storage for it.

你真正想要做的，只是让编译器知道有这个符号，而不是去创建它、给它分配存储空间。

In C, this can be achieved by means of a variable declaration that is not a definition. C provides the special keyword "extern", which you place in front of the variable definition.

在 C 语言中，可以用一种"只声明、不定义"的方式来做到。C 语言提供了特殊的关键字 **`extern`**，放在变量定义前面就行。

Note that a declaration still needs to specify the type of the variable, such "int" here, but in this particular case the type does not matter, as you are only interested in the address of the variable.

注意，声明还是要指定变量类型，比如这里的 `int`，不过在这种情况下类型无所谓，因为你关心的只是这个变量的地址。

When you try to compile now, you see that the symbol is recognized, but the compiler now complains that a pointer to int can't be used to initialize entity of type int, which is the type of the __vector_table.

再编译试试，符号认出来了，但编译器又抱怨说 `int` 指针不能用来初始化 `int` 类型的实体——也就是 `__vector_table` 的类型。

The simple solution is to apply an explicit cast to int, after which the compiler is happy, and also the program links correctly, meaning that the linker could also successfully resolve the CSTACK$$Limit symbol.

解决办法很简单，做一个到 `int` 的**显式类型转换**（explicit cast）就行了。这样编译器就满意了，程序也能正确链接，说明链接器成功解析了 CSTACK$$Limit 符号。

I'm sure you are curious whether your stack pointer initialization really worked. So, let's load the code into the LauchPad board.

你肯定好奇栈指针初始化到底有没有生效。把代码加载到 LaunchPad 板上看看。

Well, as you can see, the disassembly view shows CSTACK$$Limit at address zero, as expected, and the value in the SP register is 0x20000410, which looks like the top of stack.

如你所见，反汇编视图在地址零处显示的是 CSTACK$$Limit，跟预期一致。SP 寄存器里的值是 0x20000410，看起来就是**栈顶**（Top of Stack）。

Indeed, when you inspect the linker map file, you can see that the linker created symbol CSTACK$$Limit is allocated at the address 0x20000410, which is exactly what you saw in the SP register.

没错，打开链接器的映射文件（map file）看看，CSTACK$$Limit 被分配在地址 0x20000410，跟你 SP 寄存器里看到的值一模一样。

To prove beyond any doubt that you have not broken the compatibility with the linker script editor, let's change the stack size through the IDE.

为了彻底证明你没有破坏跟链接器脚本编辑器的兼容性，我们通过 IDE 改一下栈的大小。

As you close the dialog box, the stack size changes in the linker script as well.

关掉对话框后，链接器脚本里的栈大小也跟着变了。

Now, rebuild the project and verify that the address of CSTACK$$Limit has increased to 0x20000428.

重新构建项目，确认 CSTACK$$Limit 的地址确实变成了 0x20000428。

Finally, load the code again to the LaunchPad board and check that the new value in the SP register is exactly 0x20000428.

再加载到 LaunchPad 板上，SP 寄存器里的新值正好是 0x20000428。

OK, you are done with the sack now, so let's move on to initialization of the exception and interrupt handlers that follow in the vector table, according the to TivaC datasheet.

好了，栈的部分搞定了。接下来按照 TivaC 数据手册，初始化向量表中后面的异常和**中断处理程序**（Interrupt Handler）。

The first handler to initialize is Reset, which is located immediately after the stack.

第一个要初始化的处理程序是复位（Reset），紧跟在栈指针后面。

The meaning of the Reset handler is that it is the initial value copied to the PC register when the microcontroller comes out of reset, so this is the address in ROM where the ARM Cortex-M processor starts executing code.

复位处理程序的意思是：微控制器退出复位时，它会被加载到 **PC 寄存器**（程序计数器）里，作为初始值。也就是说，ARM Cortex-M 处理器从 ROM 中的这个地址开始执行代码。

Just like with the stack pointer, let's first look at the default initialization of the Reset handler from the standard IAR library.

跟栈指针一样，先看看标准 IAR 库里复位处理程序是怎么默认初始化的。

So, here is the disassembly view of the standard vector table, which you used back in lesson 13. As you can see, the reset handler was set to __iar_program_start, which is the startup code you learned about in lesson 13. This startup code provided everything you needed, so let's reuse it in your custom vector table as well.

这是第 13 课用过的标准向量表的反汇编视图。可以看到，复位处理程序被设成了 `__iar_program_start`，就是你在第 13 课学过的那段启动代码。那段启动代码已经提供了你需要的一切，所以在自定义向量表里直接复用它。

But how can you obtain an address of a function, such as __iar_program_start in C? I mean, so far you've only learned how to call functions, but you have never had a need to access the address of a function before.

那在 C 语言里怎么获取一个函数的地址呢，比如 `__iar_program_start`？我是说，到目前为止你只学过怎么调用函数，从来没需要过获取函数的地址。

It turns out that C allows you to take an address of a function, just like it allows you to take an address of a variable. For example, you can take an address of __iar_program_start and use it to initialize your vector table, like this:

其实 C 语言允许你取函数的地址，跟取变量地址一样。比如，你可以取 `__iar_program_start` 的地址，用它来初始化向量表，像这样：

Again, similarly as with the CSTACK$$Limit symbol, you need to declare the symbol __iar_program_start as a function, by providing its prototype.

同样，跟 CSTACK$$Limit 符号类似，你需要通过提供**函数原型**（prototype）来把 `__iar_program_start` 声明为一个函数。

When you attempt to compile the code now, you get an error that the funny looking type (void (*)(void) can't be used to initialize an int. This is again similar to what happened with the CSTACK$$Limit symbol, except now the pointer type is more complex, because it is a pointer to a function that takes void arguments and returns a void rather than a simple pointer to an int.

试着编译，又报错了——说那个看起来有点奇怪的类型 `void (*)(void)` 不能用来初始化 `int`。跟 CSTACK$$Limit 的情况类似，只不过这次的指针类型更复杂，因为它是一个**函数指针**（pointer to function），指向一个无参数、无返回值的函数，而不是简单的指向 `int` 的指针。

I don't want to go into details how you can declare such pointers to functions as independent variables, because it is not needed to understand the code at hand. I will leave pointers to functions for another lesson.

我不打算详细讲怎么把这种函数指针声明成独立变量，因为理解当前代码不需要。函数指针这个话题留到以后的课再讲。

For now, to get rid of the error, I will apply an explicit cast to int, just as I did with CSTACK$$Limit.

现在先把错误消除掉，做法跟 CSTACK$$Limit 一样——做一个到 `int` 的显式类型转换。

By the way, an address of a function can be obtained in C even whey you don't use the ampersand in front of the function name.

顺便说一下，C 语言中取函数地址时，即使不在函数名前面加 `&`（ampersand），也能拿到地址。

This is allowed, because a function name not followed by parentheses can't be misconstrued as a call to the function.

这是允许的，因为一个后面没跟括号的函数名，不可能被误解成函数调用。

As you can see the code without the ampersand compiles just fine, but I personally don't like this style and would not recommend it. Unfortunately, a lot of code out there, including vector tables from various silicon vendors, dont use ampersands, so you definitely need to know about such possibility.

可以看到不加 `&` 也能正常编译，但我个人不喜欢这种写法，也不推荐。不过很遗憾，外面的很多代码——包括各家芯片厂商提供的向量表——都不加 `&`，所以你一定要知道还有这种写法。

I simply consider the notation with ampersand superior, because it is very clear that you mean an address of a function. Needless to say, I will use ampersands in the rest of the vector table.

我就是觉得加 `&` 的写法更好，因为一眼就能看出你取的是函数的地址。不用说，向量表剩下的部分我都会用 `&`。

But before moving on, I'm sure you are curious whether the Reset handler initialization actually worked.

在继续之前，你肯定好奇复位处理程序的初始化到底有没有生效。

So, when you load the code to your board, you can see that the program is stopped at __iar_program_start at address 0x1b8, which is the value in the PC.

把代码加载到板上，可以看到程序停在了地址 0x1b8 处的 `__iar_program_start`，这就是 PC 里的值。

Also, in the vector table at address zero, you can see both CSTACK$$LImit and __iar_program_start.

同时在地址零的向量表里，可以看到 CSTACK$$Limit 和 `__iar_program_start` 都在。

Finally, when you run the code the LED blinks, so the code still works.

运行代码，LED 在闪，说明一切正常。

OK, let's now move on the the other entries that follow Reset in the vector table. Specifically, I mean here entries with negative IRQ numbers, such as NMI, Hard Fault, Memory Management Fault, Bus Fault, Usage Fault, SVCall, PendSV and SysTick.

好，接下来看向量表里复位之后的其他条目。具体来说，就是那些带有负 **IRQ 编号**的条目，比如 NMI、Hard Fault（硬错误）、Memory Management Fault（内存管理错误）、Bus Fault（总线错误）、Usage Fault（使用错误）、SVCall、PendSV 和 SysTick。

These entries in the vector table are common to all ARM Cortex-M processors and are for handling exceptions.

这些条目是所有 ARM Cortex-M 处理器共用的，专门用来处理**异常**（Exception）。

For example, in lesson 10 you encountered a stack overflow. When the SP register dropped below the start of RAM, the processor entered the HardFault exception, which you could see this in the debugger.

举个例子，第 10 课你遇到过**栈溢出**（Stack Overflow）。当时 SP 寄存器降到了 RAM 起始地址以下，处理器就进入了 HardFault 异常——你在调试器里看到了这个现象。

You can read more about the exceptions and which errors they handle later in the datasheet in the section "Fault Handling".

想了解更多关于各种异常以及它们分别处理什么错误，可以去看数据手册后面的 "Fault Handling" 章节。

Please note that the standard exceptions are arranged in the vector table not contiguously, but rather there are gaps in the table marked as "Reserved". This is very important, because you need to preserve this exact layout in your custom vector table.

注意，标准异常在向量表里并不是连续排列的，中间有一些标记为 "Reserved"（保留）的空位。这点非常重要——你的自定义向量表必须保持完全一致的布局。

Back to code, you initialize the standard exceptions in exactly the same way as the Reset exception, but you pay attention to all the reserved slots, which are typically initialized to zero.

回到代码，标准异常的初始化方式跟复位异常完全一样，但要特别注意那些保留槽位，一般初始化为零。

As far as the prototypes of the exception handlers are concerned, you don't need to declare them yourself, because they are all provided for you in the tm4c CMSIS header file.

至于异常处理程序的原型，你不用自己声明，tm4c 的 **CMSIS** 头文件里全都帮你定义好了。

The names of exception and interrupt handlers are not arbitrary, but rather they are part of the the CMSIS standard. Using standard names is important when you want to use the startup code together with other components, such as Real-Time Operating Systems or other 3rd party software.

异常和中断处理程序的名称不是随便起的，而是 **CMSIS 标准**规定的。当你想把启动代码跟其他组件一起用——比如**实时操作系统**（RTOS）或者第三方软件——标准名称就很重要了。

OK, so, include the tm4c CMSIS header in your startup code.

好，在你的启动代码里包含 tm4c CMSIS 头文件。

Now, unlike the __iar_program_start Reset handler, which was taken from the standard IAR library, you actually need to write the code for the other exception handlers, such as HardFault_Handler.

现在，跟从 IAR 标准库拿来的 `__iar_program_start` 复位处理程序不同，其他异常处理程序需要你自己写代码，比如 `HardFault_Handler`。

The standard way to code an exception handler is to use an endless loop that ties up the CPU when the corresponding exception, such as HardFault, is taken. This is convenient for debugging, because when you break into such code, you find it spinning inside the endless loop.

编写异常处理程序的标准做法是写一个**无限循环**（endless loop），当相应的异常（比如 HardFault）发生时把 CPU 卡住。调试的时候方便——你一暂停，就看到程序在那个死循环里转。

Unfortunately, most people leave such code in the final product. I'm sure you have experienced devices that seemed to "freeze" and could not be used, not even turned off, until the battery has been pulled out and inserted back in. This is a classic example of "denial of service" due to incorrectly coded exception handlers.

可惜大多数人把这样的代码直接留在了最终产品里。你肯定遇到过那种设备突然"死机"、什么操作都没反应、连关机都关不了，非得拔电池再插回去才行。这就是异常处理程序写得不合理导致的经典**拒绝服务**（Denial of Service）问题。

So, instead of an endless loop, I typically call a function named assert_failed() that provides a common handler for all sorts of errors, including assertions that I hope to talk about in the future lessons. I use assert_failed, because it is also used in many code libraries for ARM and it is already prototyped in the tm4c_cmsis header file.

所以，我通常不写死循环，而是调用一个叫 `assert_failed()` 的函数。它给各种错误提供了一个统一的处理入口，包括以后会讲的**断言**（assertion）。我选 `assert_failed` 这个名字，是因为很多 ARM 代码库也在用，而且 `tm4c_cmsis` 头文件里已经有它的原型声明了。

Please note that assert_failed is only suitable for situations when you encounter an unrecoverable error and you don't want to continue. In that case the purpose of assert_failed is to perform some damage control and, most commonly, to reset the machine.

注意，`assert_failed` 只适用于遇到**不可恢复错误**（unrecoverable error）、不想继续往下跑的情况。这时候 `assert_failed` 的作用就是做一些**损害控制**（damage control），最常见的做法是直接复位系统。

The other purpose of assert_failed is to report the error location and to record it in an error log, if possible. For this purpose the function takes two arguments: a pointer to a constant file-name string,

`assert_failed` 的另一个作用是报告出错的位置，条件允许的话还要记到错误日志里。为此，这个函数接受两个参数：一个指向常量文件名字符串的指针，

and the line number at which the call occurred within the file.

以及调用发生在文件中的哪一行。

This information will allow you to easily locate the error in the code.

有了这些信息，你在代码里定位错误就方便多了。

Inside the HardFault handler, the function is called with the fault name,

在 HardFault 处理程序里，用错误名称作为参数来调用这个函数，

and the __LINE__ symbol, which is the standard preprocessor macro that resolves to the line number in which it appears.

第二个参数用 `__LINE__`——这是标准的**预处理器宏**（preprocessor macro），会展开成它所在的行号。

You can code all other fault handlers the same way.

其他错误处理程序都可以用同样的方式来写。

However, the vector table contains also exceptions that are not faults, such as SVC_Handler, DebugMon_Hanlder, PendSV_Handler, and SysTick_Handler.

不过，向量表里还有一些不属于"错误"的异常，比如 SVC_Handler、DebugMon_Handler、PendSV_Handler 和 SysTick_Handler。

Instead of treated them as faults, what you ideally want is to provide an option for these handlers to be defined somewhere else in your program, but only if needed.

与其把它们当作错误处理，更理想的做法是：允许这些处理程序在程序的其他地方定义，但只在需要的时候才定义。

If not used, you would like to provide a default implementation, which will indicate a fault of using an undefined handler.

如果没用到，就提供一个默认实现，用来报告"使用了未定义处理程序"这个错误。

It might seem like you can't have a cake and eat it too, but the IAR compiler provides a very convenient way of providing the so called weak alias for a function.

看起来似乎鱼和熊掌不可兼得，但 IAR 编译器提供了一个很方便的特性——给函数指定所谓的**弱别名**（weak alias）。

For example, here are the weak aliases for the non-fault exception handlers from your vector table.

比如，这里就是向量表中非错误异常处理程序的弱别名。

The weak alias means that if a symbol remains undefined till the end of the linking process, the provided alias will be used. For instance, if SVC_Handler is not used, it will be replaced with Unused_Handler. However, if the symbol is defined in the project, the weak alias is ignored and the linker does not report multiply defined symbols.

弱别名的意思是：如果一个符号到链接结束时还是没有定义，就用提供的别名来顶替。比如 SVC_Handler 如果没定义，就会被替换成 Unused_Handler。但如果这个符号在项目里定义了，弱别名就被忽略，链接器也不会报符号重复定义。

Of course, the alias itself must be defined, so here is the definition of the Unused_Handler.

当然，别名本身也得有定义，这就是 Unused_Handler 的定义。

And finally, you also need the prototype of the Unused_Handler at the top of the file.

最后别忘了，文件顶部还要加上 Unused_Handler 的原型声明。

When you try to build now, you can see that the startup_tm4c actually compiles cleanly, but the linker reports that assert_failed is undefined.

试着构建一下，`startup_tm4c` 编译通过了，但链接器报 `assert_failed` 未定义。

This is to be expected, because you obviously need to add that function to your project, but the question is in which file.

这很正常，因为你显然需要把这个函数加到项目里，但放在哪个文件呢？

I propose that you create a new file for the so called Board Support Package, that you save it as bsp.c, and you add it to the project.

我建议你创建一个新文件，专门放所谓的**板级支持包**（Board Support Package, BSP），保存为 `bsp.c`，加到项目里。

As the file is specific to you board, it needs to include the tm4c_cmsis header file.

这个文件是针对你这块板子的，所以要包含 `tm4c_cmsis` 头文件。

You will put here the board-specific stuff, like your error and assertion handling policy. You will also put here your specific interrupt handlers, so the file will come in really handy in the future.

你会把板级相关的代码放在这里，比如错误和断言的处理策略。以后中断处理程序也会放在这里，所以这个文件后面会非常实用。

Regarding the definition of the assert_failed function, any damage control will really depend on your project, so you need to revisit this function after you carefully design your error recovery strategy.

至于 `assert_failed` 函数的具体实现，损害控制怎么做取决于你的项目，所以你需要在仔细设计好**错误恢复策略**（error recovery strategy）之后再来完善它。

In the end, however, you will typically need to reset the system, for which the CMSIS standard provides a useful function called NVIC_SystemReset.

但不管怎样，最终通常都要复位系统。CMSIS 标准为此提供了一个好用的函数：`NVIC_SystemReset`。

As you can see, the project build succeeds with no errors and no warnings.

可以看到，项目构建成功，零错误零警告。

As usual after every incremental step, you need to check how the code performs on the target.

跟往常一样，每走一步都要看看代码在目标板上的表现。

As you can see in the disassembly view, the vector table at address zero matches the initialization in your startup_tm4c. Specifically, the fault handlers and the reserved vectors match exactly.

反汇编视图里可以看到，地址零处的向量表跟你 `startup_tm4c` 里的初始化完全一致。具体来说，错误处理程序和保留向量都对得上。

The non-fault handlers, all shown as DebugMon_Handler in the disassembly, because they are all aliased to the same address of Unused_Handler, and the IAR debugger displays all of them using the first name in the alphabetical order, which happens to be DebugMon.

非错误处理程序在反汇编里全部显示为 DebugMon_Handler，因为它们都指向 Unused_Handler 的同一个地址，而 IAR 调试器按字母顺序排列，排在最前面的恰好是 DebugMon。

And finally, you want of course to run the code to see if the LED still blinks. And so it does.

最后当然要运行一下，看 LED 还闪不闪。确实在闪。

The next interesting test is to check the aliasing. You can do this by providing your own implementation of one of the non-fault handlers, for example SysTick_Handler, which you expect to be used instead of the alias.

接下来一个有意思的测试是验证别名机制。你可以给某个非错误处理程序写一个自己的实现，比如 SysTick_Handler，预期它会替代别名生效。

The code builds cleanly.

代码编译通过。

And when you look in the disassebly, you see your SysTick_Handler instead of the DebugMon_Handler alias.

在反汇编里看，你看到的是自己的 SysTick_Handler，而不是 DebugMon_Handler 别名了。

Again, when you run the code, the LED still blinks.

运行代码，LED 还是正常闪烁。

I'm afraid that at this point, you might think that you have tested your new stuff and you can move on to adding all other interrupt vectors.

恐怕这时候你可能觉得新加的代码都测试过了，可以继续把其他中断向量加上了。

But not so fast. You have tested neither any of the fault handlers nor your assert_fault function implementation. So, let's try to exercise these parts of your code.

别急。错误处理程序你一个都没测，`assert_failed` 函数的实现也没测。我们来试着触发一下这些代码。

But this seems easier said than done. I mean faults simply don't happen in your primitive Blinky program, so you would have to wait forever for something very unlikely, such as a cosmic ray hitting just the right part of the silicon.

但这事说起来容易做起来难。在你这个简单的 Blinky 程序里，错误根本不会发生。你要等它自己出错，可能得等到天荒地老——除非碰巧有颗宇宙射线击中了芯片上刚好那个位置。

The answer is that you need to make it happen at your will. Scientifically, this is called "fault injection".

答案是：你可以主动让它发生。在科学上这叫**"故障注入"**（fault injection）。

So here is what you could do: set a breakpoint at the beginning of the delay function and run the code.

具体这么做：在 `delay` 函数的开头设一个**断点**（breakpoint），然后运行代码。

When the breakpoint is hit, just before the stack push instruction, change the SP register to 0x2 followed by all zeros, which is the start of your RAM.

断点命中时，在栈压栈指令执行之前，把 SP 寄存器改成 0x2 后面全零——这就是 RAM 的起始地址。

Now very carefully single step through the code.

然后非常小心地**单步执行**。

Oops, as the SP drops below the start of RAM, the program jumps to HardFault_Handler. So far, this is exactly what you would expect.

哎呀，SP 一降到 RAM 起始地址以下，程序就跳到了 HardFault_Handler。到目前为止，完全符合预期。

But wait a minute. The first instruction of HardFault_Hanler is another push to the stack, so when you step again, you don't move forward.

等等。HardFault_Handler 的第一条指令又是一次压栈操作，你再单步一步，程序并没有往前走。

Even if you run the program at full speed and break into it, you find it at the beginning of HardFault_Handler. Well, I really hope that you know why.

即使全速运行再暂停，你也会发现程序卡在 HardFault_Handler 的开头。我真的希望你知道原因。

Yes, you are right. The PUSH instruction at the beginning of HardFault causes another fault, which re-enters HardFault. This is obviously not good, because your assert_failed function is not even called.

没错。HardFault 开头的 PUSH 指令又触发了一次错误，于是再次进入 HardFault。这就不好了——你的 `assert_failed` 函数根本没被调用到。

Instead, you have an implicit endless loop and denial of service--something that you precisely wanted to avoid.

结果就是隐式的死循环加拒绝服务——恰好是你想避免的情况。

How do you fix it? Well, you obviously don't want to access the stack in your fault handlers or in assert_failed, because the stack might be corrupted.

怎么修？很明显，在错误处理程序或者 `assert_failed` 里你不应该访问栈，因为栈可能已经坏了。

As described in the IAR help, IAR provides a C language extension called __stackless, which tells the compiler not to use the stack for a given function.

IAR 帮助文档里说了，IAR 提供了一个 C 语言扩展 **`__stackless`**，告诉编译器不要为指定函数使用栈。

A function designated as stackless violates the calling convention such that it is impossible to return from it.

标记为 stackless 的函数违反了**调用约定**（calling convention），所以没办法从它返回。

But remember that you don't want to return from your fault handlers or from assert_failed anyway. Instead, all you want to do is to perform some damage control, record the error, and reset.

但别忘了，你本来就不打算从错误处理程序或 `assert_failed` 返回。你要做的就是做损害控制、记录错误、然后复位。

So, the __stackless keyword is exactly right for all the fault handlers and the assert_failed function.

所以 `__stackless` 这个关键字用在所有错误处理程序和 `assert_failed` 函数上正好合适。

With this change, let's build and run the code again.

改好之后，重新构建并运行。

First, check that the LED is still blinking and then stop the program.

先确认 LED 还在闪，然后暂停程序。

As before set a breakpoint at the beginning of the delay function and run the code.

跟之前一样，在 `delay` 函数开头设断点，运行代码。

After the breakpoint is hit, change the SP register to 0x2 followed by all zeros, which is the start of your RAM.

断点命中后，把 SP 改成 0x2 后面全零，也就是 RAM 的起始地址。

Now very carefully single step through the code.

然后非常小心地单步执行。

As the last time, the stack overflow that you have just created caused the HardFault exception.

跟上次一样，你制造的这个栈溢出触发了 HardFault 异常。

But this time around, there is no stack push instruction and the code proceeds to calling the assert_failed function.

但这次不一样了——没有压栈指令，代码顺利地调用了 `assert_failed` 函数。

Finally, assert_failed does not access the stack either, so it also successfully calls the NVIC_SystemReset, which succeeds because you find yourself at __iar_program_start that is your Reset handler.

最后，`assert_failed` 也不访问栈，所以它成功调用了 `NVIC_SystemReset`。复位生效——你发现自己又回到了 `__iar_program_start`，也就是你的复位处理程序。

All right, so your code works and no longer seems to suffer from the "denial of service" problem. Unfortunately, you can't say that of the most startup code examples distributed by the various silicon vendors. That startup code is perhaps sufficient for debugging but is inadequate for deployment in products.

好了，代码工作正常，不再有"拒绝服务"的问题了。不过大多数芯片厂商提供的启动代码示例就没这么靠谱了。那些代码拿来调试可能够用，但放到实际产品里是不够格的。

So, while my goal here is to give you startup code that you can take all the way to production, I'd like to make a larger point as well.

所以，虽然我的目标是给你一份能直接用到产品中的启动代码，但我想借这个机会强调一个更重要的观点。

I want you to develop a habit of exercising all parts of your code, especially parts that are executed infrequently, like your fault handlers.

我希望你养成一个习惯：把代码的每个部分都跑一遍，尤其是那些不常执行的部分，比如错误处理程序。

To test infrequent events, you don't need to wait until they occur naturally. Instead, use the "fault injection" method to intentionally cause errors at will.

测试那些不常发生的事件，不用等它们自己出现。用"故障注入"的方法，主动制造错误就行。

And lastly, I hope you start to see the benefits of having a single common error handler like assert_failed. One obvious advantage is that a single breakpoint at this function will catch all faults, errors, and assertions during debugging. I'm running out of time for this lesson, but perhaps in the future I will show you how to hard-code a breakpoint in ARM Cortex-M. For now I highly recommend that you always set a regular breakpoint in assert_failed.

最后，希望你开始体会到用 `assert_failed` 这样一个统一错误处理程序的好处。最明显的一个好处是：只要在这个函数上设一个断点，调试时就能捕获所有的错误、故障和断言。这节课时间不多了，以后有机会我教你如何在 ARM Cortex-M 里硬编码断点。现在，强烈建议你每次都在 `assert_failed` 上设一个普通断点。

But back to your custom vector table, it has all the standard exceptions, but you still need to add all the interrupt handlers that your processor supports. I'm talking here about the entries marked as IRQ (interrupt request) in the datasheet.

回到你的自定义向量表——标准异常都有了，但还需要加上处理器支持的所有中断处理程序。我说的是数据手册里标记为 **IRQ**（中断请求，Interrupt Request）的那些条目。

When you go a couple of pages up, you will see the complete list of these interrupts. Please note that this list also contains some Reserved entries, which you mustn't forget to preserve the exact layout of the table.

往前翻几页，你会看到这些中断的完整列表。注意，列表里也有一些保留条目，别忘了保留它们以维持表格的精确布局。

Adding the actual interrupt handlers to the vector table is tedious, but does not introduce any new tricks that you should know about, so I simply copy the list that I prepared in advance.

往向量表里加实际的中断处理程序挺枯燥的，但没有需要你学的新技巧，所以我直接复制了预先准备好的列表。

Please note that all the prototypes are provided int the tm4c_cmsis header file.

注意，所有的函数原型都在 `tm4c_cmsis` 头文件里提供好了。

The final touch is to alias all the interrupt handlers to the Unused_Handler.

最后的收尾工作：把所有中断处理程序都设成 Unused_Handler 的弱别名。

Finally, one last system build shows that the code compiles and links cleanly.

最后再做一次完整构建，编译和链接都没问题。

This concludes this third and last lesson about the startup code. In the next lesson, I will introduce interrupts.

关于启动代码的三节课到此全部结束。下一课我们开始介绍**中断**（Interrupt）。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅保持关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Startup Code | 启动代码 | 微控制器复位后执行的第一段代码，负责初始化系统并跳转到主程序 |
| Vector Table | 向量表 | 位于内存起始地址的表格，包含异常和中断处理程序的地址 |
| Stack Pointer (SP) | 栈指针 | 指向当前栈顶的寄存器，ARM Cortex-M 中栈从高地址向低地址增长 |
| Reset Handler | 复位处理程序 | 微控制器退出复位时 PC 被加载的地址处执行的代码 |
| Exception Handler | 异常处理程序 | 处理处理器异常（如 HardFault）的函数 |
| Interrupt Handler / ISR | 中断处理程序 / 中断服务例程 | 响应硬件中断请求（IRQ）而执行的函数 |
| CSTACK | C 栈 | IAR 工具链中用于 C 程序栈空间的段名 |
| CSTACK$$Limit | CSTACK 段末尾符号 | IAR 链接器生成的符号，表示 CSTACK 段的结束地址，即栈的初始位置 |
| `extern` keyword | `extern` 关键字 | C 语言关键字，声明一个变量或函数在其他地方定义，不在当前编译单元中分配存储 |
| Function Pointer | 函数指针 | 指向函数的指针，类型如 `void (*)(void)` |
| CMSIS | Cortex 微控制器软件接口标准 | ARM 定义的 Cortex-M 处理器软件接口标准，提供统一的硬件抽象 |
| Fault | 错误/异常 | ARM Cortex-M 中的异常类型，如 HardFault、BusFault 等 |
| HardFault | 硬错误 | ARM Cortex-M 中最严重的错误异常，通常由栈溢出、非法访问等引起 |
| Weak Alias | 弱别名 | 链接器特性，允许符号有默认实现但可被用户代码覆盖 |
| `__stackless` | 无栈函数 | IAR C 语言扩展，指示编译器不为函数生成栈操作指令 |
| Calling Convention | 调用约定 | 定义函数调用时参数传递、栈管理、返回值处理等规则的协议 |
| Denial of Service | 拒绝服务 | 系统因异常处理不当而陷入死循环，无法继续正常运行的状态 |
| Fault Injection | 故障注入 | 一种测试方法，有意地向系统中引入错误以验证错误处理机制 |
| `assert_failed()` | 断言失败处理函数 | 通用错误处理函数，用于不可恢复错误的报告和系统复位 |
| NVIC_SystemReset | NVIC 系统复位 | CMSIS 提供的函数，通过 NVIC 执行系统复位 |
| Board Support Package (BSP) | 板级支持包 | 封装特定开发板硬件操作细节的软件层 |
| IRQ (Interrupt Request) | 中断请求 | 外设发出的硬件中断信号，对应向量表中正编号的条目 |
| Breakpoint | 断点 | 调试器中设置的标记，使程序执行到该处时暂停 |
| Section | 段 | 链接器中内存分配的基本单位，如 `.intvec`、`CSTACK` 等 |
| `__iar_program_start` | IAR 程序入口 | IAR 工具链提供的启动函数，执行 C 运行时初始化后调用 `main()` |
| Preprocessor Macro | 预处理器宏 | 由预处理器在编译前展开的符号，如 `__LINE__` 展开为当前行号 |
| Prototype | 函数原型 | 函数的声明，包含返回类型、名称和参数类型，用于告知编译器函数接口 |
