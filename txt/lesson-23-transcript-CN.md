# 第23课：RTOS 自动化上下文切换 / Lesson 23: Automating the Context Switch

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this second lesson on RTOS (that is: Real-Time Operating System) I'll show you how to automate the context switch process. Specifically, in this lesson you will start building your own minimal RTOS that will implement the manual context switch procedure that you worked out in the previous lesson 22.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这是关于 **RTOS（实时操作系统，Real-Time Operating System）** 的第二课，我来带你看看怎么把上下文切换（context switch）自动化。具体来说，今天你要开始构建自己的最小 RTOS，把上一课第 22 课里手动完成的上下文切换流程用代码实现出来。

As usual, let's get started by making a copy of the previous lesson 22 directory and renaming it to lesson 23. Get inside the new lesson 23 directory and double-click on the uVision project "lesson" to open it.

照老规矩，先把第 22 课的目录复制一份，改名为 lesson-23。进到新目录里，双击 uVision 工程"lesson"打开。

To remind you quickly what happened so far, in the last lesson you've been posed a challenge to blink both green and blue LEDs on your LaunchPad board, but do it independently. After finding out that you cannot easily do this in a single loop, you've explored the idea of running two background loops simultaneously. Specifically, you've created two such loops, called main_blinky1 and main_blinky2 and then you tried to figure out how to switch the CPU between executing one to executing the other.

快速回顾一下：上一课给你出了个挑战——让 LaunchPad 上的绿色和蓝色 LED 独立地同时闪烁。你发现单个循环搞不定，于是探索了同时跑两个后台循环的思路。你创建了两个循环，分别叫 `main_blinky1` 和 `main_blinky2`，然后研究怎么让 CPU 在两者之间切换执行。

This turned out to be the central idea behind a Real-Time Operating System -- RTOS, whose main job is exactly to extend the foreground/background architecture by allowing you to run multiple background loops on a single CPU and to create an illusion of concurrent execution by frequently switching the CPU among all these loops.

这就是**实时操作系统**的核心思想——它的主要职责就是在**前台/后台架构**（foreground/background architecture）基础上，让你在一个 CPU 上跑多个后台循环，通过在这些循环之间频繁切换 CPU，营造出并发执行的假象。

You also learned the new terminology, in which the background loops managed by the RTOS are called "threads" or "tasks" and the switching from one such thread to another is called "context-switch".

你也学了新术语：RTOS 管理的后台循环叫做**线程**（thread）或**任务**（task），从一个线程切换到另一个线程就叫**上下文切换**（context-switch）。

Finally, in the last lesson 22, you've worked out an algorithm to performed the context-switch manually. In this lesson, you will write the actual code to *automate* it. Specifically, today you will start building your own "MInimal Real-time Operating System, which I abbreviated to MIROS.

最后，在第 22 课你设计了一个手动执行上下文切换的算法。今天，你要写真正的代码把它**自动化**。具体来说，你要开始构建自己的"最小实时操作系统"（Minimal Real-time Operating System），我把它简称为 **MIROS**。

As I am a strong believer in learning by doing, I think that that the process of building a minimal, but functional RTOS kernel from scratch, will offer you a deeper learning experience than trying to learn by reverse-engineering an existing product, such as FreeRTOS. This is because any real-life kernel is necessarily much more complex with features that will only make sense to you later, so it is just too easy to lose the big picture for the minutia.

我坚信"动手做"是最好的学习方式。从零开始构建一个最小但能用的 RTOS 内核，比逆向分析 FreeRTOS 这样的现成产品能让你学得更透彻。因为任何实际生产中的内核都必然复杂得多，很多功能你现在还用不上，很容易一头扎进细节里反而迷失了全局。

So, let's get started by adding a new project group called MiROS, in which you create just two files. First is the header file that will contain the Application Programming Interface (API) of your RTOS and second is the C file that will contain the complete implementation of the RTOS.

好，开始吧。先添加一个叫 MiROS 的新项目组，里面只创建两个文件。一个是头文件，包含 RTOS 的 **API（应用程序编程接口，Application Programming Interface）**；另一个是 C 文件，包含 RTOS 的完整实现。

In the header file, you place the usual inclusion guards.

头文件里先放上常见的包含保护（inclusion guards）。

But also, as this piece of code has a potential of being used more widely, it is a good idea to provide a comment with a brief description, copyright, and licensing terms.

另外，这段代码有可能会被更广泛地使用，所以最好加一段注释，写上简要说明、版权信息和许可条款。

I say here that this code is intended as a teaching aid and is not recommended for commercial applications. I decided to use the GPL open source license and include the standard language from the GPL that declines any warranties.

我在这里注明：这段代码仅用于教学，不推荐用于商业应用。我选用了 GPL 开源许可证，并附上了 GPL 标准的免责声明。

Finally, the comment contains the contact information. The first thing you need in the header file is a way to represent your threads.

最后，注释里还有联系方式。头文件中你首先需要的是一种表示线程的方式。

For this, you can look in your main.c file, where you see that each thread requires a private stack pointer SP, and perhaps some other information.

为此可以看看 main.c 文件——你会发现每个线程都需要一个私有栈指针（SP），可能还需要一些其他信息。

You can capture this, by providing a struct OSThread, that contains the SP pointer and can be extended in the future, as your RTOS grows. In the standard RTOS implementations, the data structure associated with a thread is traditionally called a Thread Control Block (TCB).

你可以定义一个 `OSThread` 结构体来容纳这些信息，里面包含 SP 指针，以后随着 RTOS 功能增加还可以扩展。在标准 RTOS 实现中，跟线程关联的这种数据结构传统上叫做**线程控制块**（Thread Control Block, TCB）。

As far as the prefix "OS" is concerned, similar prefixes are used in many RTOSes, where they serve two purposes.

至于"OS"这个前缀，很多 RTOS 里都有类似的命名方式，主要有两个用途。

First, is to clearly indicate which elements are parts of the operating system--OS. And the second purpose is that such prefix reduces the possibility of name collisions in larger projects, where someone might also choose the same name "Thread", but for something entirely different.

第一，清楚标明哪些元素属于操作系统（OS）。第二，减少大型项目中的名称冲突——别人也可能用"Thread"这个名字，但指的完全是另一回事。

With the OSThread typedef provided, you can now use it in main.c. You need to include "miros.h" header file, and replace the stack pointers with the OSThread type.

有了 `OSThread` 类型定义之后，你就可以在 main.c 里用了。需要包含 `miros.h` 头文件，然后把原来的栈指针替换成 `OSThread` 类型。

The next RTOS API you need is a function to fabricate the register context on each thread's stack. Traditionally such an RTOS service is called thread-create or thread-start.

接下来你需要一个 RTOS API：一个用来在每个线程栈上构造寄存器上下文的函数。传统上这种 RTOS 服务叫 thread-create 或 thread-start。

Here I will use the name OSThread_start. The function needs to take the following parameters: a pointer to the TCB. I will call this pointer "me", which is a coding convention that I will explain in a future lesson about object-oriented programming in C. a pointer-to-function to the thread handler, which is a bit tricky to define in C and the best way is to provide a typedef for it. For now, let's call this type OSThreadHandler.

这里我用 `OSThread_start` 这个名字。函数需要以下参数：一个指向 TCB 的指针，我把它叫做 `me`——这是一种编码约定，以后讲 C 语言面向对象编程时会解释。还需要一个指向线程处理函数的函数指针，在 C 里定义它有点麻烦，最好的办法是先给个 typedef，暂时叫 `OSThreadHandler`。

And finally, the thread-start function needs the memory for the private stack and the size of that stack. This signature will be augmented with additional parameters, as your MiROS RTOS grows, but this is all for now.

最后，thread-start 函数还需要私有栈的内存和栈的大小。以后 MiROS 功能增加时，这个函数签名还会追加更多参数，但目前这些就够了。

Regarding the pointer to the thread-function, you need to typedef it obviously before the thread-start signature as follows:

关于线程函数指针，你需要在 thread-start 的函数签名之前给它做 typedef，像这样：

It is a pointer to a function taking no arguments (for now) and returning void.

它是一个函数指针——指向没有参数（目前）、返回 void 的函数。

As far as the implementation is concerned, you start your miros.c file with the same comment as in miros.h and you include both stdint.h and miros.h header files.

至于实现部分，miros.c 文件开头也用和 miros.h 一样的注释，然后包含 `stdint.h` 和 `miros.h` 头文件。

You copy the OSThread_start() signature from miros.h and the body from main.c.

从 miros.h 复制 `OSThread_start()` 的函数签名，从 main.c 复制函数体。

To stitch the two pieces together, you need to establish the initial stack pointer, from which to build the stack frame.

要把这两部分拼接起来，你需要确定初始栈指针，从这里开始构建栈帧（stack frame）。

As I mentioned in lesson 22, on ARM Cortex-M the stack grows from hi- to low-memory, so you need to start from the end of the provided stack memory.

正如第 22 课提到的，ARM Cortex-M 上栈从高地址向低地址增长，所以你要从所提供的栈内存的末尾开始。

As I also mentioned, the Cortex-M stack needs to be aligned at the 8-byte boundary. But obviously the user of the function might not be aware of these requirements, so it is unwise to assume that the end of the provided stack memory will be properly aligned.

我也说过，Cortex-M 的栈需要**8 字节对齐**。但显然调用者未必知道这个要求，所以不能假设栈内存的末尾一定是对齐的。

But, you can ensure the proper alignment by rounding-down the end-address. One way to achieve it is to apply integer division by 8 followed by integer multiplication by 8.

不过，你可以对末地址做向下取整来保证对齐。一种办法就是先除以 8 再乘以 8。

Next, you simply replace the sp_blinky1 identifier with sp.

接下来，把 `sp_blinky1` 标识符替换成 `sp` 就行了。

You also change the main_blink1 thread-handler with the threadHandler parameter of your OSThread_start() function. And finally, after the stack frame is built, you save the top of the stack frame into the sp member of your OSThread structure.

再把 `main_blinky1` 线程处理函数换成 `OSThread_start()` 的 `threadHandler` 参数。最后，栈帧建好之后，把栈帧顶部的位置保存到 OSThread 结构体的 `sp` 成员里。

At this point, you can add some extra features, such as pre-filling the remaining stack with a known bit pattern, like 0xDEADBEEF here. This will make it easier for you to see the stack in memory, and will help you to determine the worst-case stack use. You will see this later in the debugger view.

这时候你可以加一些额外功能，比如把剩余的栈空间用已知的位模式预先填充——像这里的 `0xDEADBEEF`。这样在内存中查看栈会方便很多，也有助于确定最坏情况下的栈使用量。稍后在调试器视图中你会看到效果。

Your OSThread_start() function is ready now, so you can call right away inside main.c.

`OSThread_start()` 函数已经准备好了，可以直接在 main.c 里调用。

You first call it for the blinky1 thread.

先为 blinky1 线程调用它。

And then simply replicate the code for the blinky2 thread.

然后把代码复制一份，给 blinky2 线程也调用一次。

As you can see, the code still builds error-free. The next feature is the actual code for the context-switch algorithm.

可以看到，代码编译没有错误。下一个功能是上下文切换算法的实际代码。

As you saw in the last lesson, the context switch must happen during the return from an interrupt, such as SysTick, and in principle you could code it right there. But the main drawback would be that the context-switch code would need to be added to every interrupt service routine (ISR) in the system. This would not only be repetitious, but it would defeat one of the main benefits of ARM Cortex-M, which is that ISRs can be pure C functions. I hope you realize from the last lesson that the context switch cannot be coded in standard C, but rather will require some CPU-specific assembly code to build the very specific stack frames as well as to manipulate the CPU stack pointer register.

上一课你看到了，上下文切换必须在中断（比如 SysTick）返回的时候发生，原则上你可以直接把代码写在那里面。但主要的问题是，上下文切换的代码就得加到系统里每个**中断服务例程**（ISR）中去。这不但重复，而且会破坏 ARM Cortex-M 的一个重要优势——ISR 可以写成纯 C 函数。你应该也从上一课意识到了，上下文切换没法用标准 C 来写，必须用针对特定 CPU 的汇编代码，来构建专门的栈帧以及操作 CPU 的栈指针寄存器。

However, it turns out that ARM Cortex-M offers a solution that allows you to code the context-switch in only one interrupt, which will be then efficiently triggered from other interrupts or even from the thread-level code, if need be.

不过，ARM Cortex-M 提供了一种方案，让你只需要在一个中断里写上下文切换的代码，然后从其他中断甚至线程级代码中高效地触发它就行。

The trick of triggering an interrupt has been already introduced back in lesson 18, where you triggered SysTick by setting a bit in a special register inside the System Control Block module.

触发中断这个技巧在第 18 课就介绍过了——当时你通过设置**系统控制块**（System Control Block, SCB）模块里一个特殊寄存器中的某一位来触发 SysTick。

Today, you will use the same exact trick again, but with respect to a different exception called PendSV, which exists for this specific purpose and virtually all RTOSes for Cortex-M use it for context-switching. I'd like you to remember, however, that PendSV is not that special and in principle you could use any other asynchronous exception or interrupt for the purpose of context-switching.

今天你要用同样的技巧，不过这次针对的是一个叫 **PendSV** 的异常。它就是专门为这个目的设计的，几乎所有 Cortex-M 上的 RTOS 都用它来做上下文切换。不过我希望你记住：PendSV 并没有那么特别，原则上任何异步异常或中断都可以用来做上下文切换。

To see how it will work, let's add an empty PendSV_Handler() implementation at the end of miros.c file, build, and open the debugger.

要看看它是怎么工作的，先在 miros.c 文件末尾加一个空的 `PendSV_Handler()` 实现，编译，然后打开调试器。

First, let's check that your OSThread_start() function calls fabricate the expected stack content in the memory view.

先确认一下 `OSThread_start()` 函数调用是不是在内存视图中生成了预期的栈内容。

And indeed you can easily see the stack for blinky1 and the stack for blinky2. Next, set a breakpoint in your SysTick_Handler and run the program.

确实可以清楚地看到 blinky1 和 blinky2 各自的栈。接下来，在 `SysTick_Handler` 中设个断点，运行程序。

When the breakpoint is hit, scroll your memory view to the address 0xE000ED04, which is the Interrupt Control and State Register in the System Control Block. As you can check in the datasheet, the PendSV exception is triggered by setting the bit number 28, which is 0x1 followed by seven zeroes, you write this value into the ICSR register to trigger PendSV.

命中断点后，把内存视图滚动到地址 `0xE000ED04`——这是 SCB 中的**中断控制和状态寄存器**（ICSR）。查数据手册可知，PendSV 异常通过设置第 28 位来触发，也就是 `0x1` 后面跟七个零。把这个值写入 ICSR 寄存器就能触发 PendSV。

Before running the program, move the original breakpoint in SysTick to the next instruction and set another breakpoint in your empty PendSV_Handler(). This setup has been already used in lesson 18, because it allows you to determine precisely the order of preemption.

运行之前，先把 SysTick 里原来的断点移到下一条指令，再在空的 `PendSV_Handler()` 里设一个断点。这个套路第 18 课就用过了，它可以让你精确判断抢占（preemption）的顺序。

When you run the program now, it turns out that the first breakpoint hit is inside PendSV. This confirms that you have successfully triggered the PendSV exception.

运行程序后，发现第一个命中的断点在 PendSV 里。这说明你已经成功触发了 PendSV 异常。

But this is also interesting, because apparently the PendSV exception has preempted the still active SysTick exception. Indeed, when you continue, you hit the breakpoint in SysTick, and only when you continue again you end up in the main function.

但也值得注意：PendSV 显然抢占了还在活动中的 SysTick 异常。继续执行，你会命中 SysTick 的断点，再继续才能回到 main 函数。

Unfortunately, this order of preemption is not what you want.

但这种抢占顺序并不是你想要的。

Instead, you want the SysTick_Handler to complete, and only after it's done, you want the PendSV_Handler to run and switch the context. Luckily, the ARM Cortex-M core lets you control how exceptions and interrupts preempt each other by means of the adjustable interrupt priority associated with each exception.

你希望的是 `SysTick_Handler` 先执行完，然后 `PendSV_Handler` 再来切换上下文。好在 ARM Cortex-M 内核允许你通过调节每个异常关联的**中断优先级**来控制它们之间的抢占关系。

Specifically, priorities of SysTick and PendSV are controlled by the SYSPRI3 register at address 0xE000ED20. You can actually view this register in memory, where you can see that the SysTick priority is 0xE0 and PendSV priority is 0. These priorities work "backwards" meaning that a higher priority number means really lower priority for preemption. That's why the PendSV with priority zero preempts SysTick with priority E0.

具体来说，SysTick 和 PendSV 的优先级由地址 `0xE000ED20` 处的 SYSPRI3 寄存器控制。你可以在内存中查看这个寄存器，能看到 SysTick 的优先级是 `0xE0`，PendSV 的优先级是 `0`。这里的优先级是"反着来"的——数字越大，实际抢占优先级越低。所以优先级为 0 的 PendSV 抢占了优先级为 `0xE0` 的 SysTick。

If you flip it, that is you give SysTick priority 0 and PendSV the lowest priority E0, you will revert the order of preemption.

反过来——给 SysTick 优先级 0，给 PendSV 最低优先级 `0xE0`——抢占顺序就反过来了。

To prove it, lets setup the breakpoints exactly as before and manually trigger PendSV again. When you run the code now, you can see that the first breakpoint hit is inside SysTick, which means that SysTick has not been preempted by PendSV. But PendSV still was triggered and runs just as you wanted it and it finally returns to main. Please also note that you even if you write FF into the priority byte associated with PendSV, the value reads back as E0.

来验证一下：按之前的方式设置断点，再次手动触发 PendSV。这次运行后，第一个命中的断点在 SysTick 里——说明 SysTick 没有被 PendSV 抢占。PendSV 仍然被触发了，按你期望的方式运行，最后返回 main。还要注意一点：即使你把 PendSV 的优先级字节写成 `FF`，读回来仍然是 `0xE0`。

This is because ARM Cortex-M cores implement interrupt priority only in the highest-order bits of the priority byte. TivaC MCU implements only three interrupt priority bits. Other Cortex-M MCUs might implement more bits, for example STM32 implements 4 priority bits, so if you wrote FF to an ST chip, it would read back as F0.

这是因为 ARM Cortex-M 内核只用优先级字节的最高几位来实现中断优先级。TivaC MCU 只实现了 3 个优先级位。其他 Cortex-M MCU 可能更多，比如 STM32 实现了 4 个优先级位，所以往 ST 芯片写 `FF`，读回来会是 `F0`。

If you think that ARM Cortex-M interrupt priority numbering scheme is a bit complicated, you are not alone. To get it all clarified, in the notes for this video I provide a link to my ARM Community blog post "Cutting Through the Confusion with Arm Cortex-M Interrupt Priorities".

如果你觉得 ARM Cortex-M 的中断优先级编号方案有点绕，你不是一个人。为了帮你理清，我在视频备注里提供了我写的 ARM 社区博客文章链接："Cutting Through the Confusion with Arm Cortex-M Interrupt Priorities"。

For today, however, you only need to remember that PendSV needs to have the lowest interrupt priority of all exceptions and interrupts, which you can set by writing FF into the priority byte for PendSV. This would cover all possible versions of the ARM Cortex-M cores.

不过今天你只需要记住一点：PendSV 必须是所有异常和中断中优先级最低的。把 PendSV 的优先级字节写成 `FF` 就行——这样能覆盖所有版本的 ARM Cortex-M 内核。

The PendSV priority setting needs to happen during the system initialization, so let's put it in the OS_init() function.

PendSV 优先级的设置要在系统初始化时完成，所以我们把它放在 `OS_init()` 函数里。

Please note that inside the RTOS implementation, I decided use raw memory address of the SYSPRI3 register instead of the CMSIS interface, because I don't want to commit to any specific ARM Cortex-M core, such as Cortex-M0, M3, M4, or M7. The PendSV priority is at the same address in all of them, so this code will be more universal.

注意，在 RTOS 实现内部，我选择用 SYSPRI3 寄存器的原始内存地址，而不是 CMSIS 接口。因为我不想绑定到特定的 ARM Cortex-M 内核——不管是 M0、M3、M4 还是 M7。PendSV 优先级在所有这些内核中的地址都一样，这样代码更通用。

Of course, you need to put the OS_init() prototype in the miros.h header file, and you need to call OS_init() from main.

当然，你需要把 `OS_init()` 的原型声明放进 miros.h 头文件，并且在 main 里调用它。

Inside the application-level code, you should generally avoid interrupts with the lowest priority, because the lowest level should be reserved for PendSV. Therefore, in bsp.c, you need to raise the priority of SysTick from the lowest level, to zero, for example.

在应用层代码中，一般不要使用最低优先级的中断，因为最低级别要留给 PendSV。所以在 bsp.c 里，你需要把 SysTick 的优先级从最低调高，比如调到 0。

Here, you commit to a specific TivaC MCU anyway, so you can use the CMIS function NVIC_SetPriority() to set the priority of the SysTick exception.

这里你反正已经绑定了 TivaC MCU，所以可以用 CMSIS 函数 `NVIC_SetPriority()` 来设置 SysTick 异常的优先级。

With the interrupt priorities in place, you now need a function to trigger PendSV. As it will become clearer later in this lesson, the triggering of a context-switch will be closely related to the decision about which thread to schedule next. Therefore, the name of this function will be OS_sched().

中断优先级设置好了，接下来你需要一个函数来触发 PendSV。本课后面会越来越清楚：触发上下文切换和决定下一个调度哪个线程是紧密关联的。所以这个函数就叫 `OS_sched()`。

To implement this scheduling service, you first need to decide how to keep track of the current thread and the next thread to execute. This you can simply codify as two pointers to OSThread objects. The OS_curr pointer, will point to the current thread and OS_next will point to the next thread to run.

要实现这个调度服务，首先得决定怎么跟踪当前线程和下一个要执行的线程。最简单的办法就是用两个指向 `OSThread` 的指针：`OS_curr` 指向当前线程，`OS_next` 指向下一个要运行的线程。

As these pointers will be used inside interrupts, you should make them volatile. Please note that you need to place the "volatile" keyword after the asterisk, because you want your pointer to be volatile. If you placed "volatile" before the asterisk, you will get a non-volatile pointer pointing to volatile OSThread struct, which is not what you want.

因为这些指针会在中断里使用，所以要加 volatile。注意，`volatile` 关键字要放在星号后面，因为你要的是指针本身是 volatile 的。如果放在星号前面，就变成指向 volatile OSThread 结构体的非 volatile 指针了——那可不是你想要的。

Going back to the implementation of the OS_sched() function, it needs to decide how to set the OS_next pointer, but let's initially skip this step. You will see a couple of popular scheduling strategies in the upcoming lessons.

回到 `OS_sched()` 的实现，它需要决定怎么设置 `OS_next` 指针，不过这一步先跳过。后面几课你会看到几种常用的调度策略。

For now, let's simply codify how to trigger the PendSV exception, but only when the next thread is actually different from the current thread.

现在先把触发 PendSV 异常的逻辑写出来——但仅当下一个线程确实跟当前线程不同时才触发。

At this point, as with all RTOS services, you should be very carefully about race conditions, which I introduced back in lesson 20. This is actually the most difficult aspect of building an RTOS in the first place. With OS_sched() you have of course plenty of opportunities for race conditions around the current and next pointers, so you need to prevent them by disabling interrupts. You have two options: either disable interrupts inside the function, like this.

这时候要注意了——跟所有 RTOS 服务一样，你必须非常小心**竞态条件**（race condition），这个概念在第 20 课就介绍过。构建 RTOS 最难的其实就是这个。在 `OS_sched()` 里，围绕当前和下一个指针，竞态条件的机会太多了，所以必须通过禁用中断来防范。你有两个选择：一是在函数内部禁用中断，像这样。

Or, you can demand that the whole function must be always called from within an already established critical section.

二是在接口上做要求——这个函数必须在已经建立的**临界区**（critical section）内调用。

I prefer the second option, because it turns out that the scheduler often needs to be called when you already have disabled interrupts, so disabling and re-enabling them again inside OS_sched() could be problematic.

我倾向于第二种。因为实践中调度器经常需要在你已经禁用中断的情况下调用，如果在 `OS_sched()` 内部再禁用再启用，可能会出问题。

With this, you can now call the scheduler at the end of your SysTick_Hanlder, but you need to surround the with a critical section, like this.

这样，你就可以在 `SysTick_Handler` 末尾调用调度器了，但要把它包在临界区里，像这样。

So now, finally, you have everything in place to implement the context switch inside the PendSV_Handler.

好了，万事俱备，可以在 `PendSV_Handler` 里实现上下文切换了。

As I mentioned earlier, PendSV will necessarily need to be coded in assembly, but you can get a big help from the compiler by writing some code in C and then copying the compiler-generated code from the disassembly view as a convenient starting point for your actual implementation.

前面说过，PendSV 必须用汇编来写。不过有个窍门：可以先写 C 代码，然后从反汇编视图把编译器生成的代码复制出来，作为实际汇编实现的起点，这样省事很多。

The first thing you need in PendSV is to disable interrupts.

PendSV 里要做的第一件事是禁用中断。

Next, you need to save the stack context of the current thread. But you need to be careful, because the first time around there will be no threads running, and the OS_curr pointer will be zero out of reset. Therefore you need to check for it in the if statement.

接下来要保存当前线程的栈上下文。但要小心——第一次执行的时候还没有线程在跑，`OS_curr` 指针复位后是零。所以要用 if 语句检查一下。

Inside the if, you want to push the registers r4 through r11 onto the current stack, but you cannot code it in C, so you just leave a comment.

在 if 里面，你要把 r4 到 r11 这些寄存器压入当前栈，但这没法用 C 写，所以先留个注释。

After pushing the registers, you need to save the SP register into the private sp data member of the current thread. Again, you cannot easily access the real SP register, but you can at least fake it by introducing a local variable sp that the compiler will allocate in a some register. You will be able then to replace that register with the real SP in the actual code.

寄存器压栈之后，要把 SP 寄存器保存到当前线程的私有 `sp` 成员里。同样，你不太容易直接访问真正的 SP 寄存器，但可以折中一下——引入一个局部变量 `sp`，编译器会把它分配到某个寄存器中。到时候在实际代码里把这个寄存器替换成真正的 SP 就行了。

After saving the context of the current thread, you need to restore the context of the next thread to run. So, you set the SP register to the value of the private sp from the OS_next thread.

保存完当前线程的上下文后，就该恢复下一个要运行的线程的上下文了。把 SP 寄存器设为 `OS_next` 线程的私有 `sp` 值。

As you are now changing the current thread, you set the OS_curr pointer to OS_next.

既然当前线程要换了，就把 `OS_curr` 指针指向 `OS_next`。

And finally, you pop the registers r4 through r11 from the new stack, you re-enable interrupts and you happily return to the next thread.

最后，从新栈中弹出 r4 到 r11，重新启用中断，然后高高兴兴地返回到下一个线程。

So, let's build and test all this.

好，编译测试一下。

First, step over BSP_init() and OS_init() and verify that the priorities of SysTick and PendSV are 0 - the highest level and E0 -- the lowest level, respectively.

先单步跳过 `BSP_init()` 和 `OS_init()`，确认 SysTick 和 PendSV 的优先级分别是 0（最高）和 `0xE0`（最低）。

Next, set a breakpoint in your SysTick_Handler and run the code.

然后在 `SysTick_Handler` 里设断点，运行代码。

When the breakpoint is hit, verify that interrupts are being disabled with the "CPSID I" instruction.

命中断点后，确认中断确实被 `CPSID I` 指令禁用了。

Keep stepping through the code into OS_sched(). And once inside OS_sched, update the watch1 view to see the OS_curr and OS_next pointers, which are both zero at this point.

继续单步进入 `OS_sched()`。进去之后，更新 Watch1 视图查看 `OS_curr` 和 `OS_next` 指针，此时它们都是零。

Manually set the OS_next pointer to the address of your blinky1 object from main.c. This simulates scheduling the blinky1 thread to run next.

手动把 `OS_next` 指针设成 main.c 中 blinky1 对象的地址。这相当于模拟调度 blinky1 线程接下来运行。

In the call stack view, verify that OS_sched is called from SysTick, which is preempting main.

在调用栈视图中确认：`OS_sched` 是从 SysTick 调用的，而 SysTick 正在抢占 main。

Step out of OS_sched back to SysTick and verify that interrupts are getting re-enabled with the "CPSIE I" instruction.

单步跳出 `OS_sched` 回到 SysTick，确认中断被 `CPSIE I` 指令重新启用了。

Next, set a breakpoint in your PendSV_Handler and run the code.

接下来在 `PendSV_Handler` 里设断点，继续运行。

The breakpoint is hit, which means that OS_sched has triggered PendSV. Also, verify that PendSV is now directly preempting main, so your mechanism is working.

断点命中了，说明 `OS_sched` 确实触发了 PendSV。再确认一下 PendSV 现在是直接抢占 main——整个机制在工作。

At this point, you might be concerned about the combined overhead of exiting one interrupt (SysTick in this case) and entering another (the PendSV exception here). After all, typically an interrupt-exit involves popping the 8 registers from the stack, and an interrupt-entry typically involves pushing 8 registers on the stack.

这时候你可能担心：退出一个中断（这里是 SysTick）再进入另一个中断（PendSV），这前后的开销加起来不小吧？毕竟中断退出通常要弹出 8 个寄存器，中断进入要压入 8 个寄存器。

But in this case of back-to-back interrupt processing, the ARM Cortex-M core skips the popping and pushing registers in the hardware optimization called "tail-chaining". So, the overhead is comparable to a simple function call.

但在这种背靠背中断处理的情况下，ARM Cortex-M 内核通过一种叫**尾链**（tail-chaining）的硬件优化，跳过了不必要的出栈入栈操作。所以开销跟一次简单的函数调用差不多。

So, finally you reach PendSV with your temporary code ready for stealing from the disassembly view.

终于，你到了 PendSV，临时代码已经准备好，可以从反汇编视图中"借用"了。

You select all the machine code for PendSV, exit the debugger, and paste the code into your PendSV_Handler.

选中 PendSV 的全部机器码，退出调试器，把代码粘贴到 `PendSV_Handler` 里。

This is the starting point for your final code in assembly.

这就是你最终汇编代码的起点。

The first thing you need to change is to tell the compiler that the code inside your PendSV_Handler function will be in assembly rather than in C. The Keil compiler version 5 supports the __asm extended keyword applied to a function.

首先要改的是告诉编译器：`PendSV_Handler` 函数里写的是汇编而不是 C。Keil 编译器版本 5 支持在函数上使用 `__asm` 扩展关键字。

Obviously, this is a non-standard extension to the C language and you would need to do this differently in other embedded C compilers, but many will actually allow you to write the whole function in assembly.

显然，这是 C 语言的非标准扩展。在其他嵌入式 C 编译器中写法会不同，不过很多编译器其实都支持用汇编写整个函数。

Next, you delete the C code and you turn the mixed C statements from the disassembly into comments.

然后把 C 代码删掉，把反汇编里混杂的 C 语句变成注释。

Now, let's go through the code one instruction at a time.

现在逐条指令过一遍代码。

First, let me quickly explain the disassembly. The first hex number is the address in the code memory.

先快速说一下反汇编怎么看。第一个十六进制数是代码内存中的地址。

The next number is the actual machine instruction opcode, also in hexadecimal.

第二个数是实际的机器指令操作码（opcode），也是十六进制。

This is followed by a human-readable mnemonic of the instruction, followed by its parameters.

接下来是人类可读的指令助记符（mnemonic），后面跟着参数。

In the assembly language, you only need the mnemonic and parameters, so you need to delete the address and the opcode, as I do for the disabling interrupts instruction.

汇编语言里只需要助记符和参数，所以要把地址和操作码删掉——就像我对禁用中断那条指令做的那样。

The comment about pushing the registers is misaligned, because the disassembler had apparently no idea that the comment represents an instruction. You skip it for now, because first you need to code the if statement, which checks the OS_curr pointer against zero.

关于压入寄存器的注释没对齐，因为反汇编器显然不知道注释其实代表一条指令。先跳过它，因为首先要把检查 `OS_curr` 指针是否为零的 if 语句写出来。

Here, you can see that r1 is loaded with a PC-relative constant from the code memory. According to the C code, this must be the address of the OS_curr variable, for which the assembly language provides a special idiom: equals-variable-name.

这里可以看到 r1 从代码内存加载了一个 PC 相对常量。根据 C 代码，这一定是 `OS_curr` 变量的地址。汇编语言对此有个特殊写法：直接写等于变量名。

You might want to remember the address of the OS_curr constant, which is hex-5E8, because it will repeat a couple of times later in the code.

你可以记一下 `OS_curr` 常量的地址——`0x5E8`，后面代码里还会重复出现几次。

Next, r1 is loaded again, but this time with the value of OS_curr, and the CBZ branch instruction branches to the given code address if r1 is zero.

接下来 r1 再次被加载，这次加载的是 `OS_curr` 的值。CBZ 分支指令在 r1 为零时跳转到指定的代码地址。

You can search for the destination address of the branch, and sure enough you find it downstream.

搜索这个分支的目标地址，果然在下游找到了。

You need to place there an assembly label. I chose the name PendSV_restore, because that's the place in the code where you will start restoring the context of the next thread. You copy and paste the label into the CBZ instruction.

在那里放一个汇编标签。我选了 `PendSV_restore` 这个名字，因为那是代码中开始恢复下一个线程上下文的位置。把标签复制粘贴到 CBZ 指令里。

So now you have a better understanding of the code structure. Specifically, if the OS_curr pointer is not zero, the CBZ instruction will not branch, so here is the place for the body of the if statement.

现在你对代码结构更清楚了。具体来说，如果 `OS_curr` 指针不为零，CBZ 就不会跳转——所以 if 语句的正文就从这里开始。

The first thing here is to push the registers r4 through r11 onto the stack. Cortex-M actually provides an instruction for it, which is simply PUSH {r4-r11} in curly braces. This wasn't that difficult, was it?

第一件事就是把 r4 到 r11 压栈。Cortex-M 正好有一条指令干这个，就是用花括号写 `PUSH {r4-r11}`。没那么难，对吧？

Next, you need to store the stack pointer into the private sp member of the OS_curr structure. This is accomplished in these three instructions, except instead the fake sp that the compiler apparently allocated in r0, you use the real SP register.

接下来要把栈指针存到 `OS_curr` 结构体的私有 `sp` 成员里。这是通过这三条指令完成的，只不过要把编译器分配在 r0 中的那个假 sp 替换成真正的 SP 寄存器。

Here, you restore the context of the next thread. You load the address of OS_next into r1. And you load again the value of OS_next into r1. Finally, you load the value of the private sp member from OS_next structure into r0, which you replace again with the real SP.

这里开始恢复下一个线程的上下文。先把 `OS_next` 的地址加载到 r1，再把 `OS_next` 的值加载到 r1，最后把 `OS_next` 结构体中私有 `sp` 成员的值加载到 r0——同样要替换成真正的 SP。

Again, the comment about popping the registers is misaligned, so you move it to the right place. These four instructions, assign OS_next to OS_curr. You load the addresses and values again and finally, you store the value of OS_next at the address of OS_curr.

关于弹出寄存器的注释又没对齐，把它移到正确的位置。这四条指令把 `OS_next` 赋值给 `OS_curr`——再次加载地址和值，最后把 `OS_next` 的值存到 `OS_curr` 的地址上。

Now is the time to pop the registers r4 through r11 from the next-thread's stack, which you code similarly as the push instruction earlier.

现在该从下一个线程的栈中弹出 r4 到 r11 了，写法跟前面的 push 指令类似。

The re-enabling of interrupts can be left as-is. And the return from the PendSV_Handler function can be left as-is.

重新启用中断的部分保持原样就行。`PendSV_Handler` 函数的返回也保持原样。

This is the end of the function, so let's try to build it. Oops, the code does not compile, because the assembler apparently does not recognize the OS_curr and OS_next symbols.

函数到这里就结束了。编译试试——哎呀，编译不过，汇编器不认识 `OS_curr` 和 `OS_next` 这两个符号。

You can fix it by providing the explicit IMPORT assembly directives, like this.

加上显式的 IMPORT 汇编指令就能修好，像这样。

Now the code compiles and links cleanly, but before running it, I still like to improve the comments and overall readability of the code.

现在代码编译链接都没问题了。不过运行之前，我还想改进一下注释和整体可读性。

Of course, as you go over this version, you can see a lot of repetitions and opportunities for improvement. Such optimization would make a lot of sense, because the context-switch code executes quite frequently. But let's leave this to the next lesson and finish today by testing the code in the debugger.

当然，你看这个版本会发现很多重复和可以优化的地方。这些优化很有意义，因为上下文切换代码执行得非常频繁。不过这些留到下一课，今天先把代码在调试器里测试跑通。

Make sure that you have a breakpoint in your SysTick_Handler and run the program.

确认 `SysTick_Handler` 里设了断点，然后运行程序。

Once you hit the breakpoint, step inside the OS scheduler.

命中断点后，单步进入 OS 调度器。

Leave a breakpoint here and perform manual scheduling by setting the OS_next pointer to the address of the blinky1 thread.

在这里留一个断点，手动把 `OS_next` 指针设成 blinky1 线程的地址来模拟调度。

Make sure that you have a breakpoint in PendSV_Handler assembler code and continue running.

确认 `PendSV_Handler` 汇编代码里设了断点，然后继续运行。

Let's step through your assembler code one instruction at a time to admire your creation.

让我们逐条指令单步执行你的汇编代码，好好欣赏一下自己的作品。

The first time through the value of OS_curr in R1 is zero so the CBZ branch is taken. Perfect.

第一次执行时，R1 里 `OS_curr` 的值是零，所以 CBZ 分支被触发了。完美。

The SP register loaded from the OS_next pointer seems reasonable, so let's scroll the memory view to that SP. The stack content seems correct.

从 `OS_next` 指针加载的 SP 寄存器看起来合理，把内存视图滚动到那个 SP 地址看看——栈内容看起来正确。

Here, you set OS_curr to OS_next, and as you can see in the Watch1 view OS_curr gets updated.

这里把 `OS_curr` 设成 `OS_next`，Watch1 视图中可以看到 `OS_curr` 确实更新了。

Now, you pop the registers, and the registers R4 through R11 look exactly as you prepared them in the OSThread_start function.

现在弹出寄存器——R4 到 R11 的值跟你当初在 `OSThread_start` 函数中准备的一模一样。

The pop instruction has obviously changed the SP, so you scroll your memory view to the new top of stack.

pop 指令显然改变了 SP，把内存视图滚动到新的栈顶。

And finally, you re-enable interrupts and you're about to return from PendSV.

最后，重新启用中断，准备从 PendSV 返回。

You step into the BX lr instruction and... Oops, instead of returning to the blinky1 thread, you end up in the HardFault_Handler. This is not good. We have a bug.

单步进入 `BX lr` 指令……糟糕！没有返回到 blinky1 线程，而是跑到了 `HardFault_Handler` 里。不妙，有 bug。

But don't panic and keep your cool! It's time for some real debugging...

别慌，冷静！该真正调试了……

It seems that everything was going just fine, up to the return from the PendSV_Handler, so let's just reset the CPU and quickly repeat the steps up to that point.

看起来一切都挺顺利，直到从 `PendSV_Handler` 返回才出问题。那就重置 CPU，快速重复前面的步骤到那个位置。

So, here you are again at the BX lr instruction.

好，又回到了 `BX lr` 指令这里。

Now let's think how this return instruction can fail. Well, the first reason could be the incorrect value in the LR register. But it is 0xFFFFFFF9, which is fine. I explained this peculiar value back in lesson 18 "interrupts part-3".

想想这条返回指令为什么会失败。第一个可能的原因是 LR 寄存器的值不对。但它是 `0xFFFFFFF9`，没问题。这个奇怪的值我在第 18 课"中断第三部分"里解释过。

So, the next reason for a failed return can only be an incorrect value for the PC register on the stack. So, let's have a look...

那返回失败的第二个原因，只能是栈上 PC 寄存器的值不对。来看看……

Indeed, the value to be restored into the PC starts with hex-2. This is obviously a RAM address and not an address of any code in ROM. This is very suspect.

果然，要恢复到 PC 的值以十六进制 2 开头。这显然是 RAM 地址，不是 ROM 里的代码地址。非常可疑。

So, let's check the code that has generated this stack content, which is your OSThread_start() function. Specifically, the value for the PC is prepared in this line of code.

来看看生成这些栈内容的代码——也就是 `OSThread_start()` 函数。具体来说，PC 的值是在这行代码里准备的。

I wonder if you can see the bug... Yes, the threadHandler parameter already is a pointer-to-function, so taking an address of it with the ampersand operator is wrong. So, THIS is the bug!

不知道你能不能看出这个 bug……对了，`threadHandler` 参数本身就已经是函数指针了，再用 `&` 取地址就错了。**这就是 bug！**

Let's fix it, exit the debugger, and re-build the code.

修好它，退出调试器，重新编译。

Obviously, now you need to re-test the whole thing again... Run the code to OS_sched and manually schedule blinky1 thread to run next.

当然，整个流程得重新测一遍……运行代码到 `OS_sched`，手动调度 blinky1 线程接下来运行。

Continue, until the BX lr return from PendSV.

继续执行，直到从 PendSV 通过 `BX lr` 返回。

Check the stack content, and specifically the value to be restored into the PC register.

检查栈内容，特别是要恢复到 PC 寄存器中的那个值。

This is definitely an address in ROM, so it makes much more sense now.

这确实是 ROM 里的地址，这就合理多了。

OK, so let's take the plunge and execute the BX lr instruction.

好，放手一搏，执行 `BX lr` 指令。

And... what do you know. You end up inside the main_blinky1 function, so you are starting the blinky1 thread! When you continue, you obviously hit the breakpoint inside the scheduler again, but notice that the green LED has turned on on your LaunchPad board!

你猜怎么着——进入了 `main_blinky1` 函数，blinky1 线程启动了！继续执行，肯定又会在调度器里命中断点，但注意看——LaunchPad 板上的绿色 LED 已经亮了！

Let's remove the breakpoint from OS_sched and let the code run free for a while.

把 `OS_sched` 里的断点去掉，让代码自由跑一会儿。

As you can see, the green LED is blinking, which means that your blinky1 thread is now running. Restore the breakpoint in OS_sched, and manually schedule you blinky2 thread.

看，绿色 LED 在闪烁——说明 blinky1 线程正在运行。恢复 `OS_sched` 里的断点，手动调度 blinky2 线程。

Run the code to the end of PendSV and quickly verify the stack content of the blinky2 thread now. Step over the BX lr instruction and verify that switched the context to blinky2. When you stop inside the scheduler, notice that now the blue LED is on.

运行代码到 PendSV 末尾，快速验证 blinky2 线程的栈内容。单步跳过 `BX lr` 指令，确认上下文已经切换到 blinky2。停在调度器里时注意看——蓝色 LED 亮了。

Let the program run free for a while and watch the blue LED blink, which means that your blinky2 thread is now active. Of course, you can repeat the context switch between blinky1 and blinky2 as many times as you like.

让程序自由跑一会儿，看蓝色 LED 闪烁——blinky2 线程活跃了。当然，你可以在 blinky1 和 blinky2 之间来回切换，想试多少次都行。

This concludes this lesson about automating the context switch. The scheduling is still performed manually, but the next lesson will automate the scheduling as well. Specifically you will extend the MIROS RTOS with the simplest scheduling policy called round-robin. That way you will implement a time-sharing system on your LaunchPad.

关于自动化上下文切换这课就到这里。调度目前还是手动的，但下一课会把调度也自动化。具体来说，你要给 MIROS 加上最简单的调度策略——**轮转调度**（round-robin），这样就能在 LaunchPad 上实现一个时间共享（time-sharing）系统了。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Real-Time Operating System (RTOS) | 实时操作系统 | 专门为实时应用设计的操作系统，核心职责是管理多线程调度和上下文切换 |
| Context Switch | 上下文切换 | 从一个线程切换到另一个线程的过程，涉及保存和恢复 CPU 寄存器状态 |
| Thread / Task | 线程 / 任务 | RTOS 管理的后台循环，是调度的基本单位 |
| Thread Control Block (TCB) | 线程控制块 | 与线程关联的数据结构，包含栈指针及其他线程管理信息 |
| Foreground/Background Architecture | 前台/后台架构 | 嵌入式系统的基本架构，前台为中断服务，后台为主循环 |
| Stack Pointer (SP) | 栈指针 | 指向当前栈顶的 CPU 寄存器，用于跟踪栈空间使用 |
| Stack Frame | 栈帧 | 在栈上为保存寄存器上下文而构建的数据结构 |
| PendSV | 可挂起系统服务 | ARM Cortex-M 中专门用于上下文切换的异常，可被软件触发 |
| Preemption | 抢占 | 高优先级中断或线程中断低优先级执行的机制 |
| Interrupt Priority | 中断优先级 | 决定中断抢占顺序的数值，ARM Cortex-M 中数值越大优先级越低 |
| ICSR (Interrupt Control and State Register) | 中断控制和状态寄存器 | SCB 中的寄存器，用于控制和查看中断/异常状态 |
| Tail-chaining | 尾链 | ARM Cortex-M 的硬件优化，背靠背中断处理时跳过不必要的栈操作 |
| Race Condition | 竞态条件 | 多个执行流并发访问共享资源时可能导致的不确定行为 |
| Critical Section | 临界区 | 禁用中断的代码段，用于防止竞态条件 |
| Scheduling / Scheduler | 调度 / 调度器 | 决定下一个运行哪个线程的机制/函数 |
| Round-robin Scheduling | 轮转调度 | 最简单的调度策略，各线程轮流获得 CPU 时间 |
| Time-sharing | 时间共享 | 通过频繁切换 CPU 在多个任务之间分配执行时间的系统 |
| Volatile | volatile 关键字 | C 语言关键字，告知编译器变量可能被异步修改，禁止优化 |
| ISR (Interrupt Service Routine) | 中断服务例程 | 中断发生时执行的处理函数 |
| Disassembly | 反汇编 | 将机器码转换为汇编语言的过程/视图 |
| Mnemonic | 助记符 | 汇编语言中指令的人类可读表示 |
| Opcode | 操作码 | 机器指令的二进制/十六进制编码 |
| HardFault | 硬件故障 | ARM Cortex-M 中因非法操作（如访问无效地址）触发的异常 |
| CMSIS | Cortex 微控制器软件接口标准 | ARM 提供的 Cortex-M 处理器独立于供应商的硬件抽象层 |
| NVIC (Nested Vectored Interrupt Controller) | 嵌套向量中断控制器 | ARM Cortex-M 中管理中断优先级和嵌套的硬件模块 |
| System Control Block (SCB) | 系统控制块 | ARM Cortex-M 中包含系统控制和状态寄存器的模块 |
| IMPORT directive | IMPORT 汇编指令 | 告知汇编器某个符号在其他模块中定义的汇编伪指令 |
| SYSPRI3 register | SYSPRI3 寄存器 | ARM Cortex-M 中控制 SysTick、PendSV 等异常优先级的寄存器 |
| 8-byte alignment | 8 字节对齐 | ARM Cortex-M 对栈指针的要求，确保 SP 是 8 的整数倍 |
| MIROS | MIROS | 本课中从零构建的最小实时操作系统（Minimal Real-time Operating System） |
