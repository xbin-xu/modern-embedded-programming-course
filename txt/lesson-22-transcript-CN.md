# 第22课：RTOS 概念与上下文切换 / Lesson 22: RTOS Concept and Context Switching

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll finally introduce the concept of a Real-Time Operating System (RTOS). At this point let me clarify right away that when I say RTOS, I mean here a Real-Time Kernel component of the RTOS, which is responsible for multitasking. I specifically don't mean: hardware abstraction layers, device drivers, file systems, networking software, or other such components sometimes attributed to the RTOS. In this first lesson on RTOS you will see how to extend the foreground/background architecture from the previous lesson, so that you can have multiple background loops running seemingly simultaneously.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这节课终于要聊到**实时操作系统**（Real-Time Operating System, RTOS）了。先说清楚，我说的 RTOS 指的是其中负责多任务调度的**实时内核**（Real-Time Kernel），而不是硬件抽象层、设备驱动、文件系统、网络协议栈这些有时候也被归到 RTOS 名下的东西。这是关于 RTOS 的第一课，你会看到怎么把上一课的前台/后台架构扩展一下，让多个后台循环看起来在同时运行。

To follow along today's lesson, I highly recommend that you watch again lesson#18 about interrupts so that you have it fresh in your memory.

为了跟上这节课，我强烈建议你先回去重温一下第 18 课的**中断**（interrupt）内容，确保记忆还新鲜。

In terms of the software, you need the previous lesson21 directory with the ARM-KEIL uVision project and the qpc framework directory, which contains among others, the Cortex Microcontroller Interface Standard (CMSIS) and the startup code for your TivaC Launchpad board. The previous lesson21 explains how to download and install all this software, including the ARM-KEIL uVision development toolchain.

软件方面，你需要上一课第 21 课的目录（里面有 ARM-KEIL uVision 工程），以及 qpc 框架目录——里面有 **CMSIS**（Cortex 微控制器接口标准）和 TivaC LaunchPad 板子的启动代码。第 21 课讲过怎么下载安装这些软件，包括 ARM-KEIL uVision 开发工具链。

With these prerequisites in place, make a copy of the lesson21 directory and rename it to lesson22. Get inside the new lesson22 directory and double-click on the uVision project "lesson" to open it.

准备好之后，复制 lesson21 目录，改名为 lesson22。进到新目录里，双击 uVision 工程"lesson"打开它。

To remind you quickly what happened so far, in the last lesson you've learned the basic foreground/background architecture and you saw that it can be implemented with sequential blocking code and with event-driven non-blocking code.

快速回顾一下：上一课你学了基本的**前台/后台架构**（foreground/background architecture），也看到它既可以用**顺序阻塞代码**（sequential blocking code）来实现，也可以用**事件驱动非阻塞代码**（event-driven non-blocking code）来实现。

For this lesson, you revert to the sequential code and delete the event-driven alternative, because for this and a couple of next lessons you are going to focus on the sequential architectures, such as the RTOS. I promise to go back to the event-driven architectures in the future lessons.

这节课我们先回到顺序代码，把事件驱动的方案删掉。因为接下来好几课都要聚焦在顺序架构上，比如 RTOS。放心，后面我一定会再回到事件驱动架构的。

The sequential code from last time simply blinks the Green-LED on your LauchPad board. Today's challenge is to extend this basic architecture to also blink the Blue-LED available on your board, but to do it *independently* and simultaneously with blinking the Green-LED.

上次的顺序代码就是简单地让 LaunchPad 板子上的绿色 LED 闪烁。今天的挑战是：在这个基本架构的基础上，让板子上的蓝色 LED 也闪起来——而且要跟绿色 LED *独立*、同时地闪。

The first, naive attempt could be to just copy and paste the code for the Green-LED and replace the LED color and perhaps also change the on and off delays.

最直观（也最天真）的想法：把绿色 LED 的代码复制粘贴一份，改一下颜色，也许再改改延时。

When you compile and load this code to the board, you find out that it blinks both LEDs, but not simultaneously. Instead the LEDs are turned on and off in sequence, first the Green-LED and then the Blue-LED.

编译烧录到板子上之后你会发现：两个 LED 确实都闪了，但不是同时闪。它们是按顺序来的——先闪绿色，再闪蓝色。

Of course, this is exactly the nature of the sequential code you created. All you did just now was to extend the hardcoded sequence of events to include also switching the Blue-LED on and off.

当然了，这恰恰是你写的顺序代码的本性。你刚才做的事情，不过是在硬编码的事件序列里多加了蓝色 LED 的开关而已。

To blink the LEDs truly independently, while preserving the simple sequential structure of the code, you would need not one but TWO background loops running somehow simultaneously.

要让两个 LED 真正独立地闪烁，同时保持代码简单的顺序结构，你需要的不只是一个后台循环——而是两个后台循环，而且要同时运行。

To explore this possibility, let's create TWO main functions called main_blinky1 and main_blinky2. Each of these functions having the usual structure of the while(1) endless background loop.

来试试看。我们创建两个 main 函数，分别叫 `main_blinky1` 和 `main_blinky2`，每个都有常见的 `while(1)` 无限循环结构。

Now, in the original main program you need to call these functions so that the compiler won't eliminate the two main functions as unused code.

然后在原来的 main 程序里调用这两个函数，否则编译器会认为它们没被用到，直接优化掉。

However, it turns out that you cannot simply call the functions one after another, because the compiler is so smart that it will still eliminate the second call as unreachable, because it knows that the first call never returns.

不过，你不能简单地把它们一个接一个地调用——编译器比你想的聪明，它知道第一个调用永远不会返回，所以第二个调用会被当成不可达代码直接干掉。

To prevent this, you can add an if statement controlled by a volatile variable, like this.

要阻止编译器这么干，你可以加一个由 `volatile` 变量控制的 `if` 语句，像这样。

Before you run this code, however, please open the project options dialog box and turn off the use of the Floating Point Hardware, similarly as you did in lesson 18. This is to simplify the way CPU handles interrupts, which will turn out to be important for the following discussion.

运行代码之前，先打开工程选项对话框，把**浮点硬件**（Floating Point Hardware）关掉——跟第 18 课做的一样。这是为了简化 CPU 处理中断的方式，接下来的讨论会用到。

Also, as you are at it, please make sure that you have a non-zero heap size. Again, it turns out that the Keil debugger likes to have some heap space for the so called "semihosting" feature.

顺便也确认一下堆大小（heap size）不是零。Keil 调试器需要一些堆空间来支持所谓的"**半主机**"（semihosting）功能。

With these changes, let's open the code in the debugger.

改好之后，我们在调试器里打开代码。

When you run the code free, you can see that it only blinks the Blue-LED from the main_blinky2() function.

让程序自由运行，你会发现只有蓝色 LED 在闪——来自 `main_blinky2()` 函数。

But let's place a breakpoint at the end of the SysTick interrupt handler in bsp.c. As you remember from the previous lesson, you have configured this interrupt to fire 100 times per second.

现在，我们在 `bsp.c` 里 `SysTick` 中断处理函数的末尾放一个**断点**（breakpoint）。还记得上一课吗，你把这个中断配成了每秒触发 100 次。

When you hit the breakpoint, open the Memory1 view and and dock it along the right side of your screen. Scroll the memory to the address of the stack pointer register SP.

断点命中后，打开 Memory1 视图，停靠在屏幕右侧。把内存滚动到**栈指针寄存器**（Stack Pointer, SP）的地址。

Now, in lesson#18 about interrupts you learned about the very specific stack frame generated by the ARM Cortex-M exceptions, such as interrupts. To quickly refresh your memory I will grab the layout of the interrupt stack frame from the TivaC datasheet.

第 18 课讲中断的时候，你学过 ARM Cortex-M 异常（比如中断）会产生一种非常特定的**栈帧**（stack frame）。为了帮你快速回忆，我从 TivaC 数据手册里把中断栈帧的布局拿过来。

I will then align the interrupt stack frame with your stack memory view, remembering to flip it upside down, because the ARM stack grows toward the low memory addresses.

然后我把这个栈帧布局跟你的栈内存视图对齐。注意要上下翻转一下，因为 ARM 的栈是往低地址方向增长的。

As you can see, the 7th stack entry from the top contains the program counter PC. This value will be loaded to the PC register upon the return from the interrupt.

你看，从顶部往下第 7 个栈条目存放的是**程序计数器**（Program Counter, PC）。中断返回时，这个值会被加载到 PC 寄存器。

So, for example, here the PC will be loaded with 0x40E, which you can easily test experimentally by simply stepping through the BX lr instruction and watching where the interrupt returns to.

比如这里，PC 会被加载为 `0x40E`。你可以单步执行 `BX lr` 指令，看看中断到底返回到哪里，很容易就能验证。

And indeed, it does return to the address 0x40E.

确实，它返回到了地址 `0x40E`。

This is a regular interrupt return to exactly the point of preemption.

这就是一次正常的中断返回，回到了被抢占的那个精确位置——也就是**抢占点**（point of preemption）。

Bun now, when your breakpoint in SysTick_Handler is hit again, let's *cheat* and change the stack entry corresponding to the PC to the address of your main_blinky1 function, which happens to be... 0x7C6.

但现在，当 `SysTick_Handler` 的断点再次命中时，我们"作弊"一下——把栈上对应 PC 的那个条目改成 `main_blinky1` 函数的地址，恰好是 `0x7C6`。

When you execute the return from interrupt instruction BX lr this time, you can see that you indeed return to main_blinky1.

这次执行中断返回指令 `BX lr`，你确实回到了 `main_blinky1`。

This means that you are returning to a *different* point than the original point of preemption.

也就是说，你返回到了跟原始抢占点*不同的*位置。

When you remove the breakpoint in SysTick interrupt and let the code run free, you can see that you are now blinking the Green LED.

把 SysTick 里的断点删掉，让程序自由运行，你会看到绿色 LED 开始闪了。

Of course, you can repeat the process again, but this time go back to executing main_blinky2.

当然，你可以再来一遍，这次切换回 `main_blinky2`。

And indeed you now blink the Blue-LED.

没错，蓝色 LED 开始闪了。

So, in the end, you have found out a way to switch back and forth between executing main_blinky1 and main_blinky2 by using an interrupt and manually modifying the return address on the interrupt stack frame.

总结一下：你发现了一种方法——利用中断，手动修改中断栈帧上的返回地址，就能在 `main_blinky1` 和 `main_blinky2` 之间来回切换。

Here I need to warn you, however, that what you've just done is not quite legal and will NOT really work with a more complex code as I will explain in a minute.

不过我得提醒你：你刚才做的其实不太"合法"。代码稍微复杂一点就会出问题，我一会儿解释。

But already at this point, the exercise allows you to make a couple of interesting observations:

但即使到这一步，这个练习已经让你得出了几个有意思的结论：

First of all, you can see that such switching the CPU between executing multiple background loops should be possible.

第一，在多个后台循环之间切换 CPU 的执行，看起来是可行的。

Second, the exercise points you to the general mechanism for such CPU context switching, which is to exploit the interrupt processing hardware already available in your processor.

第二，这种 CPU **上下文切换**（context switching）的通用机制已经有了——就是利用处理器里现成的中断处理硬件。

And third, the exercise illustrates the general idea of multitasking on a single CPU, which is to switch the CPU between executing different background loops, like your main_blinky1 and main_blinky2 here.

第三，它说明了单 CPU 上实现**多任务**（multitasking）的基本思路——在不同的后台循环之间切换 CPU，就像你这里的 `main_blinky1` 和 `main_blinky2` 一样。

So far in this lesson you've been doing the switching manually, but the process can be automated in special software called the Real-Time Operating System Kernel or RTOS-Kernel for short.

到目前为止，你都是手动做切换的。但这个过程完全可以自动化——用一种叫**实时操作系统内核**（Real-Time Operating System Kernel，简称 RTOS-Kernel）的专用软件。

A simple definition of an RTOS Kernel is that it is:

RTOS 内核的一个简单定义是：

Software that extends the basic foreground/background architecture by allowing you to run multiple background loops (called Threads or Tasks) on a single CPU.

一种软件，它扩展了基本的前台/后台架构，让你可以在单个 CPU 上运行多个后台循环——这些循环叫做**线程**（thread）或**任务**（task）。

Another term that you should learn is Multithreading or Multitasking, which is:

还有一个术语你应该了解——**多线程**（multithreading）或**多任务**（multitasking），意思是：

Switching the CPU context frequently from one Thread to another to create an illusion that each such Thread has the whole CPU all to itself.

频繁地从一个线程切换 CPU 上下文到另一个线程，让每个线程都以为自己独占了整个 CPU。

Both these definitions use the term "Thread", but I want you to remember that these threads are essentially the background loops from the foreground/background architecture.

这两个定义都提到了"线程"这个词，但我希望你记住：这些线程本质上就是前台/后台架构里的后台循环。

Now in the remaining part of this lesson let me go back and explain why changing the PC register value on the stack was illegal and what you really need to do to switch context cleanly from one thread to another.

接下来，让我回过头来解释：为什么在栈上改 PC 寄存器的值是"非法"的？要干净地从一个线程切换到另一个线程，你到底需要做什么？

To illustrate the problem, let me use colors for the registers that are saved and restored by an interrupt. Here, for example, I use green for the registers of blinky1, because it blinks the Green-LED.

为了说明这个问题，我用颜色来区分中断保存和恢复的寄存器。比如，这里我用绿色表示 blinky1 的寄存器——因为它闪的是绿色 LED。

As you can see in the case of the regular interrupt preemption, you save registers for the blinky1 thread and restore the registers for the same blinky1 thread. As long as you actually return to the blinky1 thread, everything is OK.

可以看到，在正常的中断抢占中，你保存的是 blinky1 的寄存器，恢复的也是 blinky1 的寄存器。只要你确实返回到 blinky1 线程，一切都没问题。

However, when you manually modify the return address, you are returning to the blinky2 thread, but you still restore the registers saved originally for the blinky1 thread, which is exactly the illegal part.

但当你手动改了返回地址，你就回到了 blinky2 线程，却把原来给 blinky1 保存的寄存器恢复了——这正是"非法"的地方。

It happens to just work for the dead-simple blinky threads, but it can and will break down for more complex threads that use more registers.

碰巧 blinky 线程太简单了，所以能跑。但如果线程更复杂、用到更多寄存器，迟早会出问题。

So, now you might have a better idea how to fix it.

所以，你现在大概有思路了吧。

Well, you need to keep the register sets for different threads separate. In other words, the registers saved for blinky1 cannot be restored for blinky2 and vice-versa.

没错——你需要让不同线程的寄存器集合保持独立。换句话说，给 blinky1 保存的寄存器不能恢复给 blinky2，反过来也一样。

What that means is that you need to use a separate, private stack for each thread. Again, it might sound complicated at first, but really isn't, as you will see in the following experiment.

这意味着你需要给每个线程分配一个独立的**私有栈**（private stack）。听起来好像挺复杂，其实并不难，接下来的实验你就知道了。

You can quite easily add a stack to a thread, because it is really nothing more than an area in RAM and a pointer that points to the current top of that stack.

给线程加一个栈其实很简单——栈说白了就是 RAM 里的一块区域，加上一个指向当前栈顶的指针。

In C, such a memory area can be represented as an array of uint32_t words (corresponding to the 32-bit registers of the CPU) plus a stack pointer.

在 C 语言里，这样的内存区域可以用一个 `uint32_t` 类型的数组来表示（对应 CPU 的 32 位寄存器），再加一个栈指针。

Let's initialize the stack pointer to point one word beyond the end of the stack array, because on the ARM CPU the stack grows down, that is from the end of your stack array to its beginning.

我们把栈指针初始化到数组末尾之后一个字的位置。因为 ARM CPU 的栈是**向下增长**的——从数组末尾往开头方向生长。

You need to provide a similar stack for the blinky2 thread as well.

blinky2 线程也需要一个类似的栈。

Now, in the main program, you no longer need to call the thread functions. Instead, you need to pre-fill each thread's stack with a fabricated Cortex-M interrupt stack frame. The goal is to make the stack look as if it was preempted by an interrupt just before calling the thread function. Therefore you can use again the ARM exception frame layout from the datasheet as your template.

现在在 main 程序里，你不再需要调用线程函数了。取而代之的是，你要用伪造的 Cortex-M 中断栈帧来预填充每个线程的栈。目标是让这个栈看起来就像——线程函数刚好被中断抢占了。所以你可以再次拿数据手册里的 ARM 异常帧布局当模板。

You start from the high-memory end of the stack, because the ARM stack grows from high to low memory.

从栈的高地址端开始填，因为 ARM 栈是从高地址往低地址增长的。

Also, the ARM CPU requires that the ISR stack frame be aligned at the 8-byte boundary. This is the case here, because the stack array was sized at 40 32-bit words, which aligns the end at 8-byte boundary. This means that the "aligner" stack entry is not necessary.

另外，ARM CPU 要求 ISR 栈帧在 **8 字节边界**（8-byte boundary）上对齐。这里恰好满足条件——栈数组大小是 40 个 32 位字，末尾自然对齐在 8 字节边界上。所以那个"对齐填充"条目就不需要了。

Finally the ARM CPU uses a "full stack", which means that the stack pointer points to the last used stack entry as opposed to the first free entry.

最后一点：ARM CPU 使用的是"**满栈**"（full stack）模式——栈指针指向的是最后使用的那个栈条目，而不是第一个空闲位置。

Therefore to add a new stack entry, you first decrement the stack pointer to get to the first free location, and then you de-reference it to write a value to this location.

所以，要往栈里压入一个新条目，你得先把栈指针递减到第一个空闲位置，然后解引用写入值。

The first value you write is the fabricated Program Status Register, in which you need to set just the bit number 24. This bit corresponds to the THUMB state of the processor. The Cortex-M processor cannot be really in any other state (such as the ARM state), but for historic reasons the xPSR register must have the THUMB bit set.

你写入的第一个值是伪造的**程序状态寄存器**（Program Status Register, xPSR），只需要把第 24 位置 1 就行。这一位对应处理器的 **THUMB 状态**。Cortex-M 处理器其实不可能处于其他状态（比如 ARM 状态），但因为历史原因，xPSR 寄存器里的 THUMB 位必须设为 1。

The next value on the stack is the PC. This is the return address from the interrupt, and as you saw from your earlier experiments, it needs to be set to the address of the thread function.

栈上的下一个值是 PC，也就是中断的返回地址。从之前的实验你已经看到了，它需要设为线程函数的地址。

I have not explained yet in this course, that the C language allows you to take an address of a function using exactly the same ampersand operator as taking an address of a variable. The address-of operator applied to a function produces a pointer-to-function, which I will explain in more detail in a future lesson about state machines. For now, you need only to understand that such a pointer can be created, but must be cast on uint32_t to fit on your stack.

本课程还没讲过这一点：C 语言里你可以用取地址运算符（`&`）来获取函数的地址，跟取变量地址一模一样。对函数取地址得到的是一个**函数指针**（pointer-to-function），这个我以后讲状态机的时候再详细说。现在你只需要知道这种指针可以创建，但必须强制转换成 `uint32_t` 才能放进栈里。

The other registers in the ISR stack frame do not really matter for the proper calling of the thread function, because a thread does not return. But, for testing purposes you can initialize the stack with numbers corresponding to the register number. This will help you to easily recognize the stack frame in the debugger.

ISR 栈帧里的其他寄存器对线程函数的正确调用来说并不重要——因为线程不会返回。但为了方便调试，你可以用对应寄存器编号的数字来初始化，这样在调试器里一眼就能认出栈帧。

You initialize the stack for the blinky2 thread in exactly the same way, except you use the address of the blinky2 thread function for the PC register value.

blinky2 线程的栈用完全一样的方式初始化，只是 PC 寄存器的值要设成 blinky2 线程函数的地址。

And finally, you need to prevent the main program from terminating, so you add an empty while(1) loop, which will wait for you to start switching the threads around.

最后，别让 main 程序跑完了——加一个空的 `while(1)` 循环，等你来切换线程。

So now, you can open the debugger and run the program free to first verify that it doesn't blink any LEDs, because it executes the empty while(1) loop in main.

好，现在打开调试器，让程序自由运行。首先确认一下：没有任何 LED 闪烁——因为现在执行的是 main 里的空 `while(1)` 循环。

But the code should have initialized the stacks, which you can see in the Memory1 view. Here is blinky1 stack... and here blinky2 stack.

但代码应该已经把栈初始化好了，你可以在 Memory1 视图里看到。这是 blinky1 的栈……这是 blinky2 的栈。

You can also open the Watch1 window and set it up to watch the initialized sp_blinky1 and sp_blinky2 stack pointer variables.

你还可以打开 Watch1 窗口，监视 `sp_blinky1` 和 `sp_blinky2` 这两个已初始化的栈指针变量。

Now, comes the most interesting part and I can only imagine that you must be hanging by the edge of your seat for what's about to happen...

好了，最精彩的部分来了。我猜你已经迫不及待了……

Set your usual breakpoint at the end of SysTick and when it is hit, you switch the CPU stack from the original main-C stack to one of the private blinky stacks, say blinky1.

照老办法在 `SysTick` 末尾设个断点。断点命中后，把 CPU 的栈从原来的 main 栈切换到某个 blinky 私有栈——比如 blinky1。

To do this, you simply manually change the SP CPU register to the value of the sp_blinky1 variable.

做法很简单：手动把 CPU 的 SP 寄存器改成 `sp_blinky1` 变量的值。

Now, when you step through the BX lr return-from-interrupt instruction, you can see that you end up in the blinky1 thread, and when you remove the breakpoint from SysTick, you blink the Green-LED.

现在单步执行 `BX lr` 中断返回指令，你会发现进入了 blinky1 线程。删掉 SysTick 里的断点，绿色 LED 开始闪了。

To change the context to the blinky2 thread, set the breakpoint at the end of SysTick again, and this time you will switch the stack to blinky2.

要切换到 blinky2 线程，再次在 `SysTick` 末尾设断点，这次切换到 blinky2 的栈。

But before changing the SP register in the CPU, copy the current value of the SP from the CPU into the sp_blinky1 stack pointer variable, because this really is the current top of stack for the blinky1 thread and so you need to update the stack pointer before switching away from this thread. Only now you can overwrite the SP register with the top of stack of the next blinky2 thread to execute.

但改 CPU 的 SP 之前，先把当前 SP 值保存到 `sp_blinky1` 变量里——因为这确实是 blinky1 线程当前的栈顶，切换走之前得先保存好。然后才能用下一个要执行的 blinky2 线程的栈顶去覆盖 SP 寄存器。

When you step through the BX lr instruction, you can see that now you return to the blinky2 thread.

单步执行 `BX lr` 指令，你会看到这次回到了 blinky2 线程。

When you remove the breakpoint and run the code again, you can see that the Blue-LED starts blinking, so you are indeed running the blinky2 thread.

删掉断点，继续运行，蓝色 LED 开始闪了——你确实在运行 blinky2 线程。

So, now I hope you are getting the hang of it. Your manual procedure of switching the CPU context is to break at the end of the SysTick interrupt, copy the current value from SP CPU register into the stack-pointer variable corresponding to the currently executing thread, and to copy the other thread's stack pointer to the SP CPU register.

好，现在你应该摸到门道了。手动切换 CPU 上下文的步骤是：在 `SysTick` 中断末尾断下来，把当前 SP 寄存器的值存到当前线程对应的栈指针变量里，然后把另一个线程的栈指针写到 SP 寄存器。

Please note, however, that you no longer need to mess with the stack content in memory.

但注意：你不再需要去动内存中的栈内容了。

Please also note that when you switch to the blinky1 thread now, you resume it at precisely the point of preemption by the SysTick interrupt and not at the beginning of its thread function. For example, here you return to a specific location in the BSP_tickCtr() function, which was called from a specific location in the BSP_delay() function, which was called from main_blinky1() thread. All this information is preserved on the private blinky1 stack.

还有一点要注意：当你切换回 blinky1 线程时，你会精确地从 `SysTick` 中断抢占的位置恢复——而不是回到线程函数的开头。比如这里，你返回到 `BSP_tickCtr()` 函数里的某个位置，而它又是从 `BSP_delay()` 函数里的某个位置调用的，`BSP_delay()` 则是从 `main_blinky1()` 线程调用的。所有这些调用信息都保存在 blinky1 的私有栈上。

When you run the code free, you can see that the two threads execute now independently. For example here, the blinky1 thread runs, while blinky2 is preempted with the Blue-LED turned on.

让程序自由运行，你会看到两个线程现在独立地执行了。比如在这里，blinky1 在跑，而 blinky2 被抢占着，蓝色 LED 亮着。

The timing diagram illustrates the new way of context switching using a separate, private stack for each thread. As you can see, now you no longer mix registers. Instead, the registers for blinky1 thread are stored on blinky1 stack and subsequently restored from the same blinky1 stack. The same goes for blinky2, or any other thread that you might add to the system.

时序图展示了用私有栈做上下文切换的新方法。可以看到，寄存器不再混在一起了。blinky1 的寄存器存在 blinky1 的栈上，恢复时也从 blinky1 的栈取。blinky2 也一样——以后你要加更多线程，也是如此。

All of this looks very promising as the way to implement the context switch, but you are not quite out of the woods yet.

看起来用这个方法实现上下文切换很有希望。但你还没完全走出困境。

The remaining problem is that your context switch can still clobber some CPU registers, so the CPU state is not quite correctly restored before resuming a given thread.

还有一个问题：你的上下文切换仍然可能破坏某些 CPU 寄存器，导致恢复线程时 CPU 状态不完全正确。

To understand why, recall from lesson 18 that the Cortex-M exception stack frame corresponds to the ARM Application Procedure Call Standard (AAPCS) in that it stores only the registers that are allowed to be clobbered by a function call, but does not store registers R4 through R11, which must be preserved by a function call.

要理解为什么，回想一下第 18 课：Cortex-M 异常栈帧符合 **AAPCS**（ARM 应用过程调用标准）——它只保存那些允许被函数调用破坏的寄存器，而不保存 R4 到 R11 这些函数调用必须保留的寄存器。

This works for interrupts service routines (ISRs), because an ISR must necessarily run to completion before returning to the preempted code.

这对**中断服务程序**（Interrupt Service Routine, ISR）没问题，因为 ISR 必须在返回被抢占代码之前运行完毕。

For example, suppose the blinky1 thread code uses the R7 register, which as you can see is not saved in the Cortex-M ISR stack frame. The ISR might be also using R7, but it must save it and restore before returning. This works just fine, but only when the ISR is the only code executed while a thread is preempted.

举例来说，假设 blinky1 线程用到了 R7 寄存器——你看，Cortex-M ISR 栈帧里并不保存它。ISR 自己可能也用 R7，但它必须在返回前保存并恢复。这本来没问题——前提是 ISR 是线程被抢占期间执行的唯一代码。

But in your case, the ISR does NOT return to the preempted code, but rather to another thread: blinky2. This other thread can also use the R7 register and as any function is also obligated by the AAPCS to restore the R7 upon its return. But you are not executing the whole thread function but rather just a piece of it. This piece of code doesn't need to comply with the AAPCS and it can change the value in R7. The result is that by the time blinky1 resumes execution the R7 register might be clobbered, which is a problem. Of course the same arguments can be made about any of the registers R4 through R11.

但在你的情况里，ISR 不是返回被抢占的代码，而是返回到另一个线程 blinky2。blinky2 也会用 R7，而且按照 AAPCS 的要求，函数返回时必须恢复 R7。但你不是在执行完整的线程函数，只是其中一小段。这段代码不需要遵守 AAPCS，完全可以改变 R7 的值。结果就是，blinky1 恢复执行时 R7 可能已经被破坏了——这就是问题。当然，R4 到 R11 里的任何一个寄存器都有同样的问题。

The solution is to save the remaining 8 registers R4 through R11 on the thread's stack at the end of the ISR, right before switching the context away from the thread. These registers must then be restored from the thread's stack right before returning to this thread from the ISR.

解决方案是：在 ISR 末尾、切换上下文离开当前线程之前，把剩余的 8 个寄存器 R4-R11 也保存到线程的栈上。然后，在从 ISR 返回该线程之前，从栈上把这些寄存器恢复回来。

Unfortunately, these additional 8-registers add a lot of tedious labor to the manual context switch you've been doing so far.

不幸的是，多出来的 8 个寄存器让手动上下文切换变得更加繁琐了。

First, you need to append the additional registers to the fabricated stack frame for all your threads.

首先，你需要把额外的寄存器追加到所有线程的伪造栈帧里。

Second, when saving the current thread context, you need to save the additional 8 CPU registers R11 down to R4 on top of the current ISR stack frame.

其次，保存当前线程上下文时，要把额外的 8 个 CPU 寄存器（R11 到 R4）压到当前 ISR 栈帧之上。

And also you need to adjust the value of SP CPU register by subtracting 0x20 from the SP before saving it in the thread's stack pointer.

同时，把 SP 保存到线程的栈指针变量之前，要先从 SP 里减去 `0x20`。

Second, when restoring the next thread, you need to restore the additional registers R11 down to R4 from the thread's stack to the CPU registers.

恢复下一个线程时，要从线程的栈上把额外的寄存器（R11 到 R4）恢复到 CPU 寄存器。

And finally, you need to add 0x20 to the thread's stack pointer before writing it to the CPU SP register.

最后，把线程的栈指针写入 CPU 的 SP 寄存器之前，要先加上 `0x20`。

A tedious manual procedure is of course not a problem when you automate it in software. And this is exactly the subject of the next lesson, where you will begin building your own RTOS kernel.

手动做确实很繁琐，但一旦用软件自动化了，就完全不是问题。这正是下一课的主题——你将开始构建自己的 RTOS 内核。

The most important takeaway from today's lesson is that you now gained an understanding of RTOS threads and the mechanism an RTOS kernel uses for switching the CPU from one thread to another.

这节课最重要的收获是：你现在理解了 RTOS 线程是什么，也理解了 RTOS 内核用什么机制把 CPU 从一个线程切换到另一个线程。

Not only that, you have also worked out a precise algorithm for context switching so you are ready to implement your own RTOS kernel. I hope you will join me for this fun in the next lesson.

不仅如此，你还推导出了一套精确的上下文切换算法——实现自己的 RTOS 内核，你已经准备好了。希望下一课你能继续跟着我一起玩。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅保持关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Real-Time Operating System (RTOS) | 实时操作系统 | 专门用于实时应用的操作系统 |
| Real-Time Kernel | 实时内核 | RTOS 中负责多任务调度的核心组件 |
| Multitasking / Multithreading | 多任务 / 多线程 | 在单个 CPU 上交替执行多个线程的技术 |
| Thread / Task | 线程 / 任务 | RTOS 中独立执行的基本调度单元，本质上是后台循环 |
| Foreground/Background Architecture | 前台/后台架构 | 中断服务程序为前台、主循环为后台的基本嵌入式架构 |
| Context Switching | 上下文切换 | 保存当前线程状态并恢复另一个线程状态的过程 |
| Stack Frame | 栈帧 | 函数调用或异常处理时在栈上保存的数据结构 |
| Interrupt Service Routine (ISR) | 中断服务程序 | 响应中断请求而执行的处理函数 |
| Point of Preemption | 抢占点 | 线程被中断抢占时的执行位置 |
| Private Stack | 私有栈 | 每个线程独立的栈空间 |
| Full Stack | 满栈 | 栈指针指向最后使用的栈条目的栈管理方式 |
| ARM AAPCS | ARM 应用过程调用标准 | ARM 架构定义的函数调用约定，规定哪些寄存器需要保存/恢复 |
| xPSR (Program Status Register) | 程序状态寄存器 | 包含处理器状态信息的寄存器 |
| THUMB state | THUMB 状态 | ARM Cortex-M 处理器使用的指令集状态 |
| Semihosting | 半主机 | 通过调试器与主机通信的机制 |
| CMSIS | Cortex 微控制器接口标准 | ARM 定义的 Cortex-M 处理器软件接口标准 |
| Floating Point Hardware | 浮点硬件 | CPU 中的浮点运算单元 |
| Pointer-to-Function | 函数指针 | 指向函数入口地址的指针 |
| 8-Byte Boundary | 8 字节边界 | 栈帧需要对齐的内存边界要求 |
