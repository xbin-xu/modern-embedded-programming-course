# 第27课：RTOS 信号量 / Lesson 27: RTOS Semaphores

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this sixth lesson on RTOS I'll talk about the RTOS mechanisms for synchronization and communication among concurrent threads. Such mechanisms are the most complex elements of any RTOS, and are generally really tricky to develop by yourself. For that reason, today I will replace the toy MiROS RTOS with the professional-grade QXK RTOS included in the QP/C framework, parts of which you have been using since lesson 21. You will see the process of porting your existing application to a different RTOS, and once this is done, you will learn about semaphores and see how they work in practice.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，这是 RTOS 系列的第六课。今天我们聊聊 RTOS 中用于并发线程之间**同步**（synchronization）与**通信**（communication）的机制。这类机制是任何 RTOS 中最复杂的部分，自己从头实现确实非常棘手。所以，今天我会把玩具级的 MiROS RTOS 换成 QP/C 框架中自带的专业级 QXK RTOS——QP/C 的部分功能你从第 21 课就开始用了。接下来你会看到如何把现有应用移植到另一个 RTOS 上，完成之后，再来学习**信号量**（semaphore）以及它的实际用法。

As usual, let's get started by making a copy of the previous lesson 26 directory and renaming it to lesson 27. Get inside the new lesson 27 directory and double-click on the uVision project "lesson" to open it.

跟之前一样，先把第 26 课的目录复制一份，重命名为 lesson 27。进入新目录，双击 uVision 项目文件 "lesson" 打开项目。

To remind you quickly what happened so far, in the last lesson you implemented preemptive priority-based scheduler and you learned about the Rate Monotonic Scheduling technique, which allows you to assign priorities to threads such that they all can meet their hard real-time deadlines.

快速回顾一下：上一课你实现了**抢占式优先级调度器**（preemptive priority-based scheduler），还学了**速率单调调度**（Rate Monotonic Scheduling, RMS）技术——它可以帮你给线程分配优先级，让所有线程都能满足各自的**硬实时截止时间**（hard real-time deadline）。

But your "blinky" threads still aren't very realistic in that they run completely independently of each other. You can compare this situation to trains running on completely independent circular tracks analogous to the endless while(1) loops of your threads.

不过你那些 "blinky" 线程还不够真实——它们彼此完全独立运行。打个比方，这就像火车各自在独立的圆形轨道上跑，跟线程里那没完没了的 `while(1)` 循环一个道理。

In real-life, neither threads nor trains run completely independently, but rather their tracks cross in various ways, which requires synchronization and communication to provide timely service and to avoid collisions.

现实中，不管是线程还是火车，都不会完全独立运行。它们的"轨道"会以各种方式交汇，需要**同步**和**通信**来保证及时响应、避免冲突。

Trains have solved this problem with the railroad semaphore, which can be either open or closed. If the semaphore is closed, any approaching train must stop and wait until the semaphore opens. If the semaphore is already open, any approaching train can simply pass through.

铁路系统用信号机（railroad semaphore）来解决这个问题。信号机有两种状态：开放和关闭。关闭时，驶来的火车必须停下等待；已经开放的话，火车直接通过就行。

The concept of a semaphore has been adapted for software already in the 1960's by the Dutch computer scientist Edsger Dijkstra. Dijkstra invented a software semaphore for a time sharing system he was designing at the time. The semaphore has been later extended to the priority-based schedulers and real-time operating systems--RTOSes, which went mainstream in the early 1980s.

信号量的概念早在 1960 年代就由荷兰计算机科学家 Edsger Dijkstra 引入到软件领域了。当时他在设计一个**分时系统**（time sharing system），为此发明了软件信号量。后来信号量被扩展到基于优先级的调度器和**实时操作系统**——也就是 RTOS——在 1980 年代初成为主流。

Today, you will see how a software semaphore works and how to use it for thread signaling.

今天你会看到软件信号量是怎么工作的，以及如何用它做**线程信号传递**（thread signaling）。

But at this point you are really reaching the limits of your home-grown MiROS RTOS, because it turns out that implementing semaphores, as well as all the other inter-thread communication mechanisms, is really complex and tricky to get right.

但到了这一步，自研的 MiROS RTOS 差不多到极限了。因为事实证明，信号量和所有其他**线程间通信机制**实现起来确实非常复杂，稍不留神就会出错。

So today, instead of implementing semaphores from scratch in the toy MiROS RTOS, I will show you how to move on to a professional-grade QXK RTOS included in the QP/C framework, parts of which you have been using since lesson 21.

所以今天，我不会在玩具级的 MiROS 里从头造信号量，而是带你切换到 QP/C 框架中自带的专业级 QXK RTOS——QP/C 你从第 21 课就在用了。

I use QP/C in this course, because it supports many different programming paradigms, the conventional priority-based preemptive RTOS being just one of them of interest for today's lesson. In the future lessons, you will learn about other, more modern paradigms that QP/C also supports, such as: object-oriented programming, event-driven programming, state machines, and component-based programming with active objects.

我在课程中选用 QP/C，是因为它支持好几种不同的**编程范式**（programming paradigm）。传统的基于优先级的抢占式 RTOS 只是其中一种，正好是今天要讲的。后面的课程中，你还会学到 QP/C 支持的其他更现代的范式，比如：**面向对象编程**（OOP）、**事件驱动编程**（event-driven programming）、**状态机**（state machine），以及基于**活动对象**（active object）的组件化编程。

The process of moving an application from one RTOS to another is called porting an application and is a valuable exercise in its own right. Porting an application is like replacing the foundation from under a house with minimal disturbance to the house itself.

把应用从一个 RTOS 迁移到另一个 RTOS，这个过程叫**应用程序移植**（application porting），这本身就是一个很有价值的练习。移植就像在不影响房屋的前提下，把地基给换了。

So, to start the porting, let's remove the MIROS files from the project and rename the group to QPC.

好，开始移植。先把项目中的 MiROS 文件移除，把分组名改成 QPC。

Also, to make sure that none of the MIROS stuff is being used, let's go to the current lesson 27 project on disk and delete the files miros.h and miros.c.

同时，为了确保不会再用到任何 MiROS 的东西，到磁盘上 lesson 27 的项目目录里，把 `miros.h` 和 `miros.c` 这两个文件删掉。

Next, you need to add the QPC source code to the QPC group. But first, let's make sure that you have QPC installed on your machine. You should have it in the "qpc" folder at the same level as the folders for the lessons.

接下来要把 QPC 源码加到 QPC 分组里。不过先确认一下你机器上装了 QPC——它应该在和课程文件夹同级的 "qpc" 目录下。

If you don't have QPC yet, please go back to lesson 21, where I showed how to get QPC from the companion web page to this video course state-machine.com/quickstart.

如果你还没装 QPC，回到第 21 课看看，那里我演示了如何从课程配套网页 state-machine.com/quickstart 获取 QPC。

Once you make sure that you have QPC installed, in the uVision IDE you right-click on the QPC group and choose "Add existing files to QPC group" pop-up menu.

确认 QPC 已经装好后，在 uVision IDE 里右键点击 QPC 分组，选择弹出菜单中的 "Add existing files to QPC group"。

From there, you go one level up and go into qpc/src/qf sub-directory.

然后往上一级，进入 `qpc/src/qf` 子目录。

You need to select all the files in the qf sub-directory, which contain the code for state machines, event-driven programming, and component-based programming. I will explain them in the future lessons.

选中 `qf` 子目录下的所有文件——这些文件包含了状态机、事件驱动编程和组件化编程的代码。后面的课程我会逐一讲解。

On top of this, you will need the specific RTOS kernel, which is the QXK preemptive blocking RTOS in this case. To select it, go to the qxk folder and select all the files.

除此之外，你还需要具体的 RTOS 内核，这里用的是 QXK **抢占式阻塞 RTOS**。进入 `qxk` 文件夹，选中所有文件。

And finally, you will need the specific port of QXK for the ARM Cortex-M processor and the ARM-KEIL uVision toolchain you are using. For this, you go up to the ports directory and down to arm-cm, and inside there to qxk sub-directory for your specific QXK kernel.

最后，还需要 QXK 针对 ARM Cortex-M 处理器和 ARM-KEIL uVision 工具链的移植版本。回到上级的 `ports` 目录，进入 `arm-cm`，再找到对应 QXK 内核的 `qxk` 子目录。

Inside the kernel directory, you see sub-directories for all supported toolchains, such as ARM-KEIL, ARM with CLANG, GNU, and IAR toolchains.

内核目录里面有各种支持的工具链子目录，比如 ARM-KEIL、ARM with CLANG、GNU 和 IAR。

As you can see, the ports directory is a bit complex, but this is typical for most professional RTOSes, which have been ported to many CPU types and toolchains. On the flip side, if you wish use a different CPU or toolchain, most likely you will find it here.

可以看到，ports 目录确实有点复杂。不过大多数专业 RTOS 都这样——它们要适配各种 CPU 和工具链。好处是，如果你换个 CPU 或工具链，大概率在这里就能找到。

So for today, you need to go inside the arm directory for the ARM-KEIL toolset you are using, and select the qxk_port.c file.

所以今天，进入你正在用的 ARM-KEIL 工具链的 `arm` 目录，选择 `qxk_port.c` 文件就行。

The next step is to adapt your application to the new QPC RTOS, which is like adjusting a house to the new foundation.

下一步是让你的应用适配新的 QPC RTOS——就像房子换了地基之后要做些调整一样。

For that, you can use the compiler to show you exactly what needs to be adjusted.

怎么做呢？让编译器来告诉你哪些地方需要调整。

First, you obviously need to replace the nonexistent "miros.h" header file with "qpc.h".

首先，把已经不存在的 `miros.h` 头文件换成 `qpc.h`，这是显而易见的。

The next problem is that the compiler cannot find the "qf_port.h" header file. This header file is included from "qpc.h" and it needs to be taken from the same port directory, from which you took qxk_port.c.

下一个问题：编译器找不到 `qf_port.h` 头文件。这个头文件是从 `qpc.h` 里包含进来的，需要从你之前取 `qxk_port.c` 的那个移植目录中获取。

You provide this information to the compiler, by adding the ports directory to the compiler include search path, as follows:

把这个 ports 目录加到编译器的头文件搜索路径里就行了，操作如下：

When you build the code now, you still have errors, but notice that all the files comprising the qpc source code compile correctly.

再次构建，还是有错误。不过注意，所有 qpc 源码文件都编译通过了。

The remaining errors are getting more interesting, because they are caused by the mismatch between the previous MiROS RTOS Application Programming Interface (API) and the new QXK RTOS API.

剩下的错误就更有意思了——它们是因为旧版 MiROS RTOS 的**应用程序编程接口**（API）和新的 QXK RTOS API 不匹配造成的。

The first such mismatch is the name of the thread control block OSThread. This data type still exists in QXK, but it is called QXThread instead. So, let's replace OSThread with QXThread and rebuild.

第一个不匹配的是线程控制块的名字 `OSThread`。这个数据类型在 QXK 里还有，不过改名叫 `QXThread` 了。把 `OSThread` 替换成 `QXThread`，重新构建。

The next mismatch is the OS_delay function. This function also exists in QXK, but it is called QXThread_delay. Again, let's replace the name and rebuild.

下一个是 `OS_delay` 函数。QXK 里也有这个功能，不过叫 `QXThread_delay`。同样，替换名字，重新构建。

Now, the compiler does not recognize the OS_init() function. The equivalent in QXK is QF_init, but QXK no longer needs the extra stack for the idle task, because it re-uses the main C stack for that purpose. This more clever design means that the idle stack space can be recovered.

现在编译器不认识 `OS_init()` 了。QXK 里的对应函数是 `QF_init`。不过 QXK 不再需要为空闲任务额外分配栈空间，因为它直接复用了 main 的 C 栈。这个设计更巧妙，空闲栈的空间就省下来了。

The next problem is the thread start functionality, which is implemented slightly differently in QXK.

接下来是线程启动的问题，QXK 里的实现方式稍有不同。

For reasons that will become clearer when I talk about emulating object-oriented programming in C in one of the future lessons, a thread can be started only after the QXThread object has been initialized.

这个原因后面讲 C 语言模拟面向对象编程时会讲清楚。简单来说，线程必须在 `QXThread` 对象初始化之后才能启动。

This initialization is accomplished by a special function called the "constructor".

初始化通过一个叫**构造函数**（constructor）的特殊函数来完成。

In this constructor, the QXThread object is associated with the thread function, and also with the specific system clock tick rate, here represented as zero.

在构造函数里，`QXThread` 对象跟线程函数关联起来，同时也绑定了特定的**系统时钟节拍速率**（system clock tick rate），这里用的是 0。

A QXK thread is started by means of the QXTHREAD_START macro (notice the all capital letters). The reason for using a macro at this point will also be explained in the lesson about object-oriented programming in C, but for now it is important only that QXTHREAD_START takes more parameters.

QXK 的线程通过 `QXTHREAD_START` 宏来启动（注意全是大写字母）。为什么用宏，后面 C 语言 OOP 那节课会解释。现在你只需要知道 `QXTHREAD_START` 的参数更多就行了。

The first two parameters are, as before, the thread object, and the thread priority.

前两个参数跟以前一样：线程对象和线程优先级。

The next two parameters are the message queue buffer and size. The blinky1 thread does not use a queue at this point, but QXThreads in general can have dedicated queues.

接下来两个参数是**消息队列**（message queue）的缓冲区和大小。blinky1 线程目前不用队列，但 QXThread 一般都可以配备专用队列。

The next two parameters are the stack buffer and size, as before.

再往下两个参数是栈缓冲区和大小，跟以前一样。

And finally, the last parameter is a pointer argument passed to the thread. It will also be ignored at this point.

最后一个参数是传给线程的指针参数，目前也用不上。

When you build now, the compiler complains about the incompatibility of the thread function pointer passed into the QXThread constructor. This is because in QXK, a thread function has slightly different signature. It takes one parameter, called "me" by convention, which allows you to access the associated thread object inside the thread function.

再次构建，编译器报错说传入 `QXThread` 构造函数的线程函数指针不兼容。这是因为 QXK 里线程函数的签名略有不同——它接受一个参数，按惯例叫 `me`，让你在线程函数里能访问关联的线程对象。

Of course, you need to adjust all your thread function signatures the same way.

当然，所有线程函数的签名都要做同样的修改。

Now the compiler finally likes the initialization and starting of your first blinky1 thread, so you simply need to repeat these adjustments for all the remaining threads.

现在编译器终于对 blinky1 线程的初始化和启动满意了。剩下的线程照着改就行。

The last warning in main is that the OS_run() function is not recognized. The equivalent function in QXK is QF_run(). Please note that QF_run() also never actually returns back to main.

main 里最后一个警告是 `OS_run()` 不认识。QXK 对应的函数是 `QF_run()`。注意，`QF_run()` 同样永远不会返回到 main。

The build diagnostics now change from compilation to linking errors about functions called from bsp.c. So, let's go there and adjust it for QXK as well.

构建错误从编译错误变成了**链接错误**（linking error），说的是 `bsp.c` 中调用的函数找不到。那就去看看，给 QXK 做相应调整。

The first modification needs to be done inside the SysTick interrupt handler. Here, the undefined call to the scheduler needs to be replaced with the QXK macro QXK_ISR_EXIT, which also performs preemptive scheduling inside a critical section.

首先要改的是 SysTick **中断处理程序**。里面那个未定义的调度器调用要换成 QXK 的 `QXK_ISR_EXIT` 宏——它也会在**临界区**（critical section）内执行抢占式调度。

Additionally, QXK provides a matching QXK_ISR_ENTRY macro to be called upon the entry to the ISR, before any other QXK API call.

此外，QXK 还提供了一个配套的 `QXK_ISR_ENTRY` 宏，在进入 ISR 时、调用其他任何 QXK API 之前要先调用它。

The next undefined call to OS_tick needs to be replaced with the macro QF_TICK_X(), which services the timeouts at the specific clock tick rate, here specified as zero. This is the same clock tick rate as the one set in the thread constructors.

接下来，`OS_tick` 调用要换成 `QF_TICK_X()` 宏。它在指定的时钟节拍速率下处理**超时**（timeout），这里指定为 0——跟线程构造函数里设的一样。

The next category of undefined symbols originate from the QXK kernel, which means that these are callback functions defined in QXK, but not implemented there.

下一类未定义符号来自 QXK 内核。这些是 QXK 中声明但没实现的**回调函数**（callback function）——需要你自己来实现。

The first of these callback function is QF_onCleanup(), which is only provided for the situation when an application exits. Deeply embedded applications like your blinky never really exit, so this callback function can be defined as empty.

第一个是 `QF_onCleanup()`。这个回调只在程序退出时才用到。像 blinky 这种**深度嵌入式应用**根本不会退出，所以定义为空函数就行。

On the other hand, the undefined symbol QF_onStartup() must be defined as the replacement for OS_onStartup().

另一个未定义符号 `QF_onStartup()` 则必须实现，用来替代 `OS_onStartup()`。

Here, the most important difference is that you cannot set the SysTick interrupt priority to zero, because this highest interrupt priority in ARM Cortex-M is never disabled in QXK.

这里最关键的区别是：不能把 SysTick 的**中断优先级**设为 0。因为在 QXK 中，ARM Cortex-M 的这个最高中断优先级是永远不会被禁用的。

At this point I need to digress and explain the concept of interrupt latency and the more advanced interrupt disabling policy used in QPC compared to the simplistic MiROS RTOS.

这里需要岔开一下，解释一下**中断延迟**（interrupt latency）的概念，以及 QPC 比 MiRTOS 更高级的**中断禁用策略**（interrupt disabling policy）。

As I explained already in lesson 17 about interrupts, the interrupt requests are ASYNCHRONOUS, meaning that in general they are not correlated with the execution of the code.

正如第 17 课讲中断时提到的，中断请求是**异步的**（asynchronous）——也就是说它们跟代码的执行通常没有关联。

I also explained that the CPU can recognize an interrupt only at the instruction boundaries, after which the CPU still needs to perform interrupt entry. All this obviously takes some time.

我也讲过，CPU 只能在**指令边界**（instruction boundary）处才能识别中断，之后还要执行中断入口操作。这些都需要时间。

This time delay from the interrupt request to the first instruction of the interrupt service routine (ISR) is called the INTERRUPT LATENCY.

从中断请求发出，到**中断服务例程**（ISR）的第一条指令开始执行，这中间的时间延迟就叫**中断延迟**（interrupt latency）。

But this picture still does not show all the delays contributing to the interrupt latency.

不过这张图还没有展示所有影响中断延迟的因素。

As I explained in lesson 20 about race conditions, and lesson 23 about RTOS, an RTOS needs to occasionally DISABLE interrupts to prevent race conditions around its own variables. These critical sections of code, shown here as black boxes, obviously also contribute to the interrupt latency.

第 20 课讲**竞态条件**（race condition）、第 23 课讲 RTOS 时我都提到过：RTOS 偶尔需要**禁用中断**，防止它的内部变量出现竞态条件。这些代码的**临界区**（图中的黑色方块）显然也会增加中断延迟。

So, at the end of the day, and as usual for REAL-TIME performance, the most interesting and important measure is the worst-case, MAXIMUM INTERRUPT LATENCY, which consists of the longest critical section, plus the interrupt entry time.

所以归根结底，跟所有**实时性能**指标一样，最值得关注的是最坏情况下的**最大中断延迟**（maximum interrupt latency）——等于最长临界区加上中断入口时间。

But such maximum interrupt latency might be just too long for certain ISRs. If these ISRs do not make any RTOS API calls, they don't run the risk of interfering with the RTOS, so they really don't need to be penalized by the critical sections of the RTOS.

但对某些 ISR 来说，这个最大中断延迟可能太长了。如果这些 ISR 不调用任何 RTOS API，就不会干扰 RTOS，也就不应该被 RTOS 的临界区拖累。

This leads to the concept of "kernel unaware" interrupts, which are never disabled by the kernel, but also can never interact with the kernel. The interrupt latency of such kernel-unaware interrupts is sometimes promoted as "zero interrupt latency", which does NOT mean that such interrupts are handled instantaneously. This is impossible. It only means that the presence of the RTOS has zero-impact on the interrupt latency.

这就引出了**"内核无关"中断**（kernel-unaware interrupt）的概念。这类中断永远不会被内核禁用，但也绝不能调用内核的任何功能。有人把这种中断延迟宣传为"零中断延迟"——并不是说中断被瞬间处理了，那是不可能的。它只是说 RTOS 的存在对中断延迟没有影响。

In contrast, "kernel aware" interrupts can call RTOS API, but in exchange they have longer maximum interrupt latency.

而**"内核感知"中断**（kernel-aware interrupt）可以调用 RTOS API，代价是最大中断延迟更长。

Of course, all this discussion is relevant only for processors that can disable interrupts selectively, so that some of the interrupts can remain enabled, while others are disabled.

当然，以上讨论只适用于那些能**选择性禁用中断**的处理器——也就是能让一部分中断保持启用、另一部分被禁用。

As it turns out, the ARM Cortex-M3, M4 and M7 CPUs, but not the Cortex-M0 or M0+, allow you to disable interrupts selectively. Specifically, instead of globally disabling all interrupts with the PRIMASK register, Cortex-M3 and higher provide also the BASEPRI register, which allows you to mask interrupts selectively only up to the specified interrupt priority level. This means that interrupts above the level set in the BASEPRI register are never disabled.

ARM Cortex-M3、M4 和 M7（不包括 M0 和 M0+）就支持选择性禁用中断。具体来说，除了用 **PRIMASK 寄存器**全局禁用所有中断之外，Cortex-M3 及以上型号还提供了 **BASEPRI 寄存器**。它可以把中断屏蔽在指定的优先级级别——高于这个级别的中断永远不会被禁用。

The QPC port to ARM Cortex-M3 and higher CPUs, employs this more selective interrupt disabling method.

QPC 对 Cortex-M3 及以上的移植就采用了这种更精细的中断禁用方式。

As described in the Application Note "Setting ARM Cortex-M Interrupt Priorities in QP" the QP port provides a constant QF_AWARE_ISR_CMSIS_PRI, which separates kernel-aware interrupts from kernel-unaware interrupts.

应用笔记 "Setting ARM Cortex-M Interrupt Priorities in QP" 中有说明：QP 的移植提供了一个常量 `QF_AWARE_ISR_CMSIS_PRI`，用来划分内核感知中断和内核无关中断的界限。

Here is how the two interrupt groups look for NVIC with 3-bits of interrupt priority, and here for NVIC with 4-bits of interrupt priority.

这是 **NVIC** 用 3 位中断优先级时两组中断的样子，这是 4 位时的情况。

So now, coming finally back to your code, you can see that leaving the SysTick priority at zero would make it to a kernel-unaware interrupt.

好了，回到你的代码。把 SysTick 优先级保持为 0，会让它变成内核无关中断。

This would be incorrect, since SysTick apparently calls QPC APIs. Therefore, SysTick must be a kernel-aware interrupt with priority QF_AWARE_ISR_CMSIS_PRI or a bigger number, which would correspond to the lower interrupt priority in Cortex-M.

这就不对了，因为 SysTick 显然调用了 QPC API。所以 SysTick 必须设为内核感知中断，优先级为 `QF_AWARE_ISR_CMSIS_PRI` 或更大的数字——在 Cortex-M 里数字越大优先级越低。

Please note that I also adjust the comment to explain the situation.

注意我也更新了注释来说明这个情况。

One more build shows that the compiler accepts all our changes, but the linker still complains about the undefined OS_onIdle() symbol.

再构建一次，编译器通过了所有改动，但链接器还报 `OS_onIdle()` 符号未定义。

This callback function in the MiROS RTOS is called QXK_onIdle() in QXK and has exactly the same semantics, so nothing except the name needs to change.

MiROS 里这个回调在 QXK 里叫 `QXK_onIdle()`，语义完全一样，所以只改名字就行。

The code finally builds with zero errors and zero warnings, so I'm sure you are curious if this whole thing still works.

代码终于以零错误零警告构建成功了。我相信你一定好奇——这东西还能正常跑吗？

After you load the program to the debugger, the interesting question is how to best verify that your RTOS application works.

把程序加载到调试器之后，一个有意思的问题是：怎么验证 RTOS 应用确实正常工作？

Well, I typically focus on the threads, interrupts, and the idle callback.

嗯，我一般会关注线程、中断和空闲回调。

When you run the program, the first breakpoint hit is inside the blinky1 thread. This seems very reasonable, since blinky1 is your highest priority thread.

运行程序，第一个命中的**断点**（breakpoint）在 blinky1 线程里。这很合理——blinky1 是优先级最高的线程。

The next breakpoint hit is inside the SysTick_Handler, which confirms that the interrupts are serviced.

下一个断点命中在 `SysTick_Handler` 里，说明中断确实在被服务。

Another interesting aspect is to watch how the interrupt returns. Here in the disassembly view you can see that the interrupt returns via the POP to PC instruction, which returns to a BSP function, called from the blinky1 thread.

还有一个有趣的点：观察中断是怎么返回的。在**反汇编视图**里你可以看到，中断通过 `POP` 到 `PC` 指令返回到了 blinky1 线程调用的 BSP 函数。

Next, you hit the breakpoint in blinky2 thread, which proves that this lower-priority thread also starts executing.

接着命中 blinky2 线程的断点——说明低优先级线程也开始执行了。

But the question now is how to look into the QXK RTOS variables, since the MiROS RTOS variables are no longer valid, so you should delete them from the view.

但现在的问题是：怎么看 QXK 的内部变量？MiROS 的变量已经没用了，先从监视窗口里删掉。

To find out which variables to watch in QXK, open the qpc source code, include directory, qxk.h header file where at the top you can find the structure defining the global attributes of the QXK kernel.

要找 QXK 有哪些变量可以看，打开 qpc 源码 `include` 目录下的 `qxk.h` 头文件。顶部有个结构体定义了 QXK 内核的全局属性。

Copy the QXK_attr_ variable name to the clipboard and paste into the Watch1 window.

把 `QXK_attr_` 这个变量名复制到剪贴板，粘贴到 Watch1 窗口里。

When you expand the structure, you can see that the curr data member points to the blinky2 thread, which makes perfect sense.

展开这个结构体，可以看到 `curr` 成员指向 blinky2 线程——完全符合预期。

Finally, you reach your last breakpoint inside the idle callback. Here you can verify that the red LED on your LaunchPad board is turned on and off.

最后到达空闲回调里的最后一个断点。在这里可以确认 LaunchPad 板上的红色 LED 在正常开关。

When you exit the debugger and let the application run free, you can see some activity of the LEDs, but to verify that nothing really changed compared to MiROS RTOS, I will use the logic analyzer view.

退出调试器，让程序自由运行，能看到 LED 有活动。但要确认跟 MiRTOS 相比真的没有任何变化，我要用**逻辑分析仪**（logic analyzer）视图来对比。

So, here is the same setup as in the previous lesson 26. The top trace labeled ISR shows the activity of SysTick, which fires every millisecond and toggles the TEST pin.

这是跟第 26 课一样的设置。标着 ISR 的顶部**迹线**（trace）是 SysTick 的活动——每毫秒触发一次，翻转 TEST 引脚。

The trace below, labeled T1, shows the activity of the blinky1 thread, which runs for about 1.2 milliseconds and toggles the Green LED. As you can see blinky1 always meets its deadline of 2 time ticks.

下面标着 T1 的迹线是 blinky1 线程。它运行大约 1.2 毫秒，翻转绿色 LED。可以看到，blinky1 总是满足 2 个时间节拍的截止时间。

The trace below, labeled T2, corresponds to blinky2, which toggles the Blue LED. This thread also meets its deadline of 54 time ticks.

再下面标着 T2 的迹线是 blinky2，翻转蓝色 LED。它也满足了 54 个时间节拍的截止时间。

And finally, the bottom trace labeled IDL corresponds to the idle thread that toggles the Red LED in the QXK_onIdle callback. It runs only when no other thread or ISR are active.

最底部标着 IDL 的迹线是空闲线程，在 `QXK_onIdle` 回调里翻转红色 LED。它只在没有其他线程或 ISR 活动时才运行。

In summary, the QXK RTOS executes your application and behaves exactly as the last version of the MiROS RTOS in the previous lesson.

总结一下：QXK RTOS 运行你的应用，行为跟上一课 MiROS 的最后版本完全一致。

So, now that you have verified your port to QXK, let's see what kind of problems this RTOS will allow you to solve.

好，既然 QXK 的移植已经验证通过了，接下来看看这个 RTOS 能帮你解决什么问题。

For example, up till now, the blinky2 thread has been based on the blocking delay() function.

比如，到目前为止 blinky2 线程一直用的是阻塞式的 `delay()` 函数。

But suppose that you would like to base the blinking of the Blue LED on the button press instead. Specifically, the Blue LED should start toggling only after you press the SW1 switch on your LaunchPad board.

但如果想让蓝色 LED 的闪烁由按钮来触发呢？具体来说，只有按下 LaunchPad 板上的 SW1 开关后，蓝色 LED 才开始闪烁。

In the train analogy, this problem would be solved by applying a railroad semaphore. Such a semaphore would be initially in the closed state, so any approaching train would need to wait.

用火车的类比来说，这个问题可以用铁路信号机来解决。信号机一开始是关闭状态，驶来的火车必须等待。

Pressing the button would signal the semaphore, which would release the train from waiting and let it continue around the track.

按下按钮就相当于给信号机发信号（signal），火车被放行，继续沿轨道行驶。

The QXK RTOS kernel supports such a semaphore concept in software. In particular, to add a semaphore for signaling of switch SW1, first you need to define a semaphore object, which I will name SW1_sema, of the type QXSemaphore.

QXK RTOS 内核用软件实现了信号量的概念。具体来说，要给 SW1 开关加一个信号量，首先得定义一个信号量对象，我把它命名为 `SW1_sema`，类型是 `QXSemaphore`。

To find out what QXSemaphore is, you can open the online documentation.

想了解 `QXSemaphore` 是什么，可以打开在线文档看看。

Starting from the companion web-page to this video course, use the top menu: Products, QP/C framework.

从课程配套网页开始，点顶部菜单：Products -> QP/C framework。

You can start typing QXSema into the search box and click on QXSemaphore.

在搜索框里输入 QXSema，然后点击 QXSemaphore。

As you can see, QXSemaphore is a kernel object that consists of the QXSemaphore structure plus functions starting with QXSemaphore_underscore prefix that operate on this structure.

可以看到，`QXSemaphore` 是一个**内核对象**（kernel object），由 `QXSemaphore` 结构体加上以 `QXSemaphore_` 为前缀的一组操作函数组成。

The most important element of a semaphore is the count data member, which is an up/down-counter that keeps track of the number of times the semaphore has been signaled and waited on.

信号量最核心的元素是 `count` 成员——一个**上下计数器**（up/down counter），记录信号量被 signal 和 wait 的次数。

The semaphore stores also the maximum count value as well as the waitSet that remembers which threads are waiting on this semaphore.

信号量还保存了最大计数值，以及一个 `waitSet`——记录哪些线程正在等待这个信号量。

The waitSet data member is similar to the ready-set bitmask introduced in the MiROS RTOS, except that in QXK it can hold up to 64 priority levels.

`waitSet` 跟 MiROS 里引入的**就绪集位掩码**（ready-set bitmask）类似，不过 QXK 最多能支持 64 个优先级。

Before a semaphore can be used, it needs to be initialized with the QXSemaphore_init() function.

信号量使用前需要用 `QXSemaphore_init()` 函数初始化。

As shown in the usage example, a good place to perform the initialization is the top of the main function. In fact, let's just copy the usage example and paste it into your main function.

使用示例里写得很清楚，初始化放在 main 函数开头最合适。干脆直接把示例代码复制粘贴到你的 main 函数里。

QXSemaphore_init() takes the pointer to the semaphore you wish to initialize as well as the initial semaphore count and the maximum semaphore count.

`QXSemaphore_init()` 接收三个参数：要初始化的信号量指针、初始计数和最大计数。

Most often, for signaling you would set the maximum count of one, meaning that the semaphore count would be allowed to take only two values: zero, meaning that the semaphore is not signaled, and one, meaning that it is signaled. Such a semaphore is called the binary semaphore.

做信号传递的话，通常把最大计数设为 1。这样信号量的计数只有两个取值：0 表示没有信号，1 表示有信号。这种信号量就叫**二进制信号量**（binary semaphore）。

Also, initially your SW1 semaphore is not signaled, so you set the initial count to zero.

另外，SW1 信号量一开始没有信号，所以初始计数设为 0。

Once the semaphore is initialized, you can use it to synchronize your thread. You do this with the QXSemaphore_wait() function.

信号量初始化好之后，就可以用它来同步线程了。调 `QXSemaphore_wait()` 就行。

Again, let's just copy the usage example and paste it into your blinky2 thread function.

同样，直接把使用示例复制粘贴到 blinky2 线程函数里。

The wait function takes the pointer to your semaphore object, and also allows you to specify a timeout for how long you wish to wait on the semaphore. If you are willing to wait indefinitely, you use a special timeout value QXTHREAD_NO_TIMEOUT.

wait 函数接收信号量对象的指针，还可以指定**超时时间**（timeout）——你愿意等多久。如果要无限期等待，用 `QXTHREAD_NO_TIMEOUT` 这个特殊值。

Also now, that you have the semaphore as the blocking mechanism, you don't need the blocking delay anymore, so you can delete it.

现在有了信号量作为阻塞机制，原来的阻塞延迟就不需要了，删掉即可。

At this point, you are done with the waiting part of the problem and you can check whether your code compiles. But you still need to implement the signaling of the semaphore when the SW1 button is pressed.

到这里，等待的部分就搞定了。可以先编译看看有没有问题。不过信号量的 signal 部分还没写——按下 SW1 按钮时要发信号。

Let's start with taking a look at how this SW1 button is connected to your TivaC microcontroller.

先看看 SW1 按钮是怎么接到 TivaC 微控制器上的。

For this, you can go to the companion web-page to this course, and click on the Tiva LaunchPad User Manual.

去课程配套网页，点 Tiva LaunchPad 用户手册。

In the Table of Contents, scroll down to the Schematics section, where on the second page you can find the SW1 switch, and trace its connection to the PF4 pin, which stands for Pin-4 in the GPIO-F group.

在目录里翻到原理图部分，第二页能找到 SW1 开关。顺藤摸瓜，它连的是 PF4 引脚——就是 GPIO-F 组的第 4 号引脚。

With this information, you can now go to the board support package bsp.c, which is the logical place for any code specific to the board.

知道了引脚编号，接下来打开**板级支持包**（BSP）`bsp.c`——板子相关的代码放这里最合理。

You define here the BTN_SW1 pin as bit-4, similar as you did for the LEDs.

在这里把 `BTN_SW1` 引脚定义为第 4 位，跟之前定义 LED 引脚一样。

Notice, however, that pin-4 in the GPIO-F group is already used as the TEST_PIN, that the SysTick handler toggles for the logic analyzer view.

不过要注意，GPIO-F 的第 4 引脚已经被 `TEST_PIN` 占用了——之前 SysTick 处理程序为了逻辑分析仪视图在翻转它。

This is obviously a conflict, so let's just remove all uses of the TEST_PIN from the code.

显然有冲突。那就把代码里所有 `TEST_PIN` 的使用都去掉。

Instead, let's configure the BTN_SW1 pin similarly as you did for the LEDs.

改成配置 `BTN_SW1` 引脚，跟 LED 引脚的配置方式类似。

The pin direction should be input.

引脚方向设为输入。

And the pin should be configured as digital.

配置为数字模式。

Additionally, since this is an input pin, it needs to be configured with the pull-up resistor enabled.

另外，因为是输入引脚，需要启用**上拉电阻**（pull-up resistor）。

Pull-up resistor enabled means that the pin will be normally at the high-level, while pressing of the SW1 switch will bring it down to the low-level.

启用上拉电阻意味着引脚平时处于**高电平**（high level），按下 SW1 开关时会被拉低到**低电平**（low level）。

The final part of the GPIO pin configuration is setting it up to generate interrupts to the CPU. Here I simply copy and paste the code and let you read the comments and possibly also consult the TivaC Datasheet.

GPIO 引脚配置的最后一步是设置它产生中断给 CPU。这里我直接复制粘贴代码，注释写得很清楚，你也可以翻翻 TivaC 数据手册。

The only thing I'd like to note is that to sense the pressing of the SW1 button, the MCU needs to detect the falling edge in the voltage supplied to the pin.

唯一要提的是：要检测 SW1 按钮的按下，MCU 需要检测引脚电压的**下降沿**（falling edge）。

Now you are finally ready to write the GPIO interrupt handler for the SW1 switch. This would be your first ISR unrelated to the clock tick, because so far you've been only re-using the SysTick interrupt introduced already back in lesson 16.

好了，终于可以给 SW1 开关写 **GPIO 中断处理程序**了。这是你第一个跟时钟节拍无关的 ISR——之前一直在用第 16 课引入的 SysTick 中断。

But actually, let's begin with copying and pasting SysTick as your starting point.

实际上，先把 SysTick 的处理程序复制过来当模板。

The first thing you need to change is the name, which you can look up in the startup code, inside the interrupt vector table.

首先要改的是函数名。在启动代码的**中断向量表**（interrupt vector table）里能找到。

Inside the ISR body, you leave the QXK_ISR_ENTRY and QXK_ISR_EXIT macros, because this will definitely be a "kernel aware" interrupt.

ISR 主体里保留 `QXK_ISR_ENTRY` 和 `QXK_ISR_EXIT` 宏——因为这肯定是一个内核感知中断。

But you need to delete the QF_TICK call and replace it with the signaling on the semaphore.

不过要删掉 `QF_TICK` 调用，换成信号量的 signal 操作。

However, before you can signal the semaphore, you need to make sure that the interrupt is coming from the specific SW1 pin, because this ISR will also fire for other pins of GPIO-F, if they are configured to trigger this interrupt.

在 signal 之前，先确认中断确实来自 SW1 引脚。因为 GPIO-F 的其他引脚如果配置了中断，也会触发这个 ISR。

Also, after detecting the source of the interrupt, this GPIO peripheral needs to be explicitly cleared in software, so that it is ready for the next interrupt.

确认了中断源之后，还要在软件中显式清除这个 GPIO 外设的中断标志，为下一次中断做好准备。

So, finally, inside the if-statement, you can signal the semaphore by means of the QXSemaphore_signal() function. The only parameter you need to supply here is the pointer to the semaphore object.

最后，在 if 语句里面，调用 `QXSemaphore_signal()` 来发送信号量信号。唯一需要传的参数就是信号量对象的指针。

But you are not quite done with this interrupt yet. As I explained earlier for SysTick, the very important step for any "kernel aware" interrupt is to explicitly set its priority to be below the "kernel aware" level.

不过中断还没完全搞定。前面讲 SysTick 时说过，内核感知中断非常重要的一步是：显式设置优先级，确保不低于"内核感知"的级别。

You configure the interrupt priority in the QF_onStartup() callback. The GPIOF priority can be the same as SysTick, or perhaps one level lower, which means bigger priority number in Cortex-M.

在 `QF_onStartup()` 回调里配置中断优先级。GPIOF 的优先级可以跟 SysTick 一样，或者再低一级——Cortex-M 里数字越大优先级越低。

And one last step for the GPIO interrupt is to explicitly enable it in the NVIC, as follows.

最后一步，在 **NVIC** 中显式启用这个 GPIO 中断，操作如下。

When you try to build the code, the compiler complains that the SW1_sema object is undefined.

构建代码，编译器报 `SW1_sema` 对象未定义。

Well, indeed, the semaphore object is defined only in main.c, and so bsp.c does not know about it.

没错，信号量对象只在 `main.c` 里定义了，`bsp.c` 当然看不到它。

You can easily fix it by placing the declaration of the semaphore object into bsp.h header file, which is included in both main.c and bsp.c.

解决办法很简单：把信号量对象的声明放到 `bsp.h` 头文件里——`main.c` 和 `bsp.c` 都包含了它。

However, when you build the code again, the compiler still complains, but this time about the QXSemaphore type being undefined.

再次构建，编译器还是报错，不过这次是 `QXSemaphore` 类型未定义。

This type is defined in the qpc.h header file, so you can fix this problem by making sure that bsp.h is included after qpc.h.

这个类型定义在 `qpc.h` 里。确保 `bsp.h` 在 `qpc.h` 之后被包含就行。

While you are at it, you can also remove the stdint.h header file, because it also is already included from qpc.h.

顺便把 `stdint.h` 也删了，它已经从 `qpc.h` 里包含进来了。

One more build, and... Hallelujah! The code finally builds with zero errors and zero warnings!

再构建一次……终于！零错误零警告！

I'm not sure about you, but I'm really curious how the code will work.

不知道你怎么想，我反正是迫不及待想看看效果了。

So, let's load the code into the board and open the debugger to perform the basic sanity checks.

把代码烧录到板子上，打开调试器，做基本的功能验证。

To do this, I set breakpoints at the most important junctures, that is, at semaphore wait inside blinky2 and semaphore signal inside the GPIO ISR.

我在最关键的位置设了断点：blinky2 里的信号量等待，还有 GPIO ISR 里的信号量 signal。

When I run the code, the first breakpoint hit is at the semaphore wait. This makes sense, because the blinky2 thread should be blocked on the semaphore.

运行代码，第一个命中的是信号量等待处的断点。合理——blinky2 线程应该在信号量上**阻塞**（blocked）。

To verify that the thread is indeed blocked I move the breakpoint to the first instruction AFTER the semaphore wait.

为了确认线程确实被阻塞了，我把断点移到信号量等待之后的第一条指令处。

When I continue now, the program runs without hitting any breakpoints. This makes sense again, because the semaphore has blocked the thread so the breakpoint past the wait call cannot be reached.

继续运行，程序不再命中任何断点。也合理——信号量阻塞了线程，wait 调用后面的断点根本到不了。

Now, I press the SW1 button and...

现在按下 SW1 按钮……

As you can see, the code hits the breakpoint at semaphore signal inside the GPIO ISR.

看到了，代码命中了 GPIO ISR 里信号量 signal 处的断点。

This is excellent, because it means that the GPIO interrupt has been configured correctly.

非常好！说明 GPIO 中断配置正确。

When you continue from signaling the semaphore, you immediately hit the breakpoint inside blinky2. This means that the semaphore wait has been unblocked and the code past it started to run.

从 signal 处继续执行，立刻就命中了 blinky2 里的断点。说明信号量等待已经被**解除阻塞**（unblocked），后面的代码开始运行了。

When you run the program from here, again no breakpoint is hit... until SW1 is pressed again.

从这里继续运行，又没有断点命中了……直到再次按下 SW1。

At which point the breakpoint at semaphore signal is hit.

这时信号量 signal 处的断点被命中。

When you continue, again you immediately hit the breakpoint past semaphore wait. This proves that indeed the execution of the blinky2 thread is synchronized with signaling the semaphore and, by this mechanism, to the pressing of the SW1 button.

继续执行，又立刻命中 wait 之后的断点。这证明了 blinky2 线程的执行确实跟信号量的 signal 同步了，而通过这种机制，也就跟 SW1 按钮的按下同步了。

OK, so let's run the code free and leave the debugger to inspect the timing of this code in more detail using the logic analyzer.

好，现在退出调试器让程序自由运行，用逻辑分析仪仔细看看时序。

When you open the logic analyzer with the identical setup as before... at first you don't see any activity.

用跟之前一样的设置打开逻辑分析仪……一开始什么都看不到。

But, let's change the trigger to AUTO.

把触发模式改成 AUTO。

And now, as you can see, the Green-LED is toggled from your blinky-1 thread as before, and so is the Red-LED toggled from the idle callback.

现在看到了：绿色 LED 跟以前一样由 blinky1 线程在翻转，红色 LED 也是跟以前一样由空闲回调在翻转。

On the other hand, the ISR pin is not toggling, but rather is stuck high. And also the Blue-LED is not active at all.

但 ISR 引脚没有在翻转，而是一直保持高电平。蓝色 LED 也完全没动静。

But this is exactly what you changed. In particular, the previous trigger was setup to use the rising edge of Pin-4, which was toggled from the SysTick interrupt.

不过这正是你改动的地方。之前的触发条件设的是引脚 4 的上升沿——那是 SysTick 中断翻转的。

Now this pin is used for the SW1 switch, which, as you can see, is normally high and should go low only when you press the switch. Therefore, let's adjust the trigger to the falling edge of pin-4, which as you recall, is also the trigger for your GPIO-F interrupt.

现在这个引脚给了 SW1 开关，平时是高电平，只有按下开关时才变低。所以把触发信号改成引脚 4 的下降沿——你应该记得，引脚 4 的下降沿也是 GPIO-F 中断的触发条件。

So, let's run with these adjustments while repeatedly pressing the SW1 button.

好，用这个设置来跑，同时反复按 SW1 按钮。

As you go through the collected traces, you can see that most of the time, pressing of the button caused the ISR line to go low and the Blue-LED started to toggle for about 8.5 milliseconds, give or take a few milliseconds for preemption.

翻看采集到的波形，大多数情况下：按下按钮后 ISR 线变低，蓝色 LED 开始闪烁，持续大约 8.5 毫秒——因为**抢占**（preemption）的关系，会上下浮动几毫秒。

When the button press came while the blinky-1 thread was not running, the blinky-2 thread started to toggle the Blue-LED immediately.

如果按钮按下时 blinky1 线程没在运行，blinky2 会立刻开始翻转蓝色 LED。

However, when the button press happened while blinky-1 was running, the blinky-2 thread had to wait until blinky-1 voluntarily blocked. This is because QXK is a preemptive, priority-based kernel, fully compliant with Rate Monotonic Scheduling (RMS), and so it always executed the higher-priority blinky-1 thread as long as it wanted to run, before executing the lower-priority blinky-2 thread.

但如果按钮按下时 blinky1 正在运行，blinky2 就得等 blinky1 主动阻塞之后才能跑。因为 QXK 是抢占式、基于优先级的内核，完全遵循**速率单调调度**（RMS）——只要高优先级的 blinky1 想运行，就一定先执行它，然后才轮到低优先级的 blinky2。

For today's lesson, which is about understanding semaphores, I'd like you to remember that unblocking of a semaphore that is waiting inside a lower-priority thread might be delayed by all higher-priority threads.

今天的重点是理解信号量。希望你记住一点：低优先级线程里等待的信号量被解除阻塞后，可能会被所有高优先级线程延迟。

Now, when I was pressing the SW1 switch and collecting the traces, you might have noticed some anomalies.

刚才按 SW1 开关采集波形的时候，你可能注意到一些异常。

For example, in trace 12, you can see that the blinky-2 thread is running twice as long as usual. I'm sure you want to know why.

比如第 12 条迹线，blinky2 线程运行时间是平时的两倍。你肯定想知道为什么。

Well, when you zoom in, you can see that the falling edge of the ISR line is not clean, but rather shows some strange spikes.

放大看看：ISR 线的下降沿并不干净，有一些奇怪的毛刺。

These spikes are even better visible in the analog waveform of the same signal in the upper part of the plot, which I specifically provided for today by probing the PF-4 pin from the bottom of the board.

在图上方的模拟波形里看得更清楚——这是我今天特意从板子底部探测 PF4 引脚得到的。

Well, it turns out that this is a well known property of all mechanical switches, which sometimes momentarily bounce before establishing a permanent contact. The problem is that to the fast CPU, these bounces look like multiple presses and releases of the switch, instead of the expected single press or single release.

原来，这是所有**机械开关**（mechanical switch）的通病。触点闭合之前会短暂地**抖动**（bounce）几下。问题在于，对高速 CPU 来说，这些抖动看起来像是多次按下和释放开关，而不是预期的一次按下或释放。

The subject of filtering out the noise created by mechanical switches is quite interesting, and you can read about it by searching the web for "debouncing".

滤除机械开关噪声这个话题很有意思，可以搜索**"消抖"**（debouncing）了解更多。

Let me only mention here that you should definitely NOT release any production-quality software with the current implementation, and instead you should properly "debounce" all your switches in software.

但要强调：绝对不能带着当前的实现发布正式产品。必须在软件中做好消抖处理。

However, for this lesson, I chose exactly to use the noisy signal, because it provides more extreme stress test for your semaphore, and in doing so, it will allow you to gain a deeper understanding of how a semaphore works.

不过今天这节课，我特意用了有噪声的信号，因为它能对信号量做更极端的**压力测试**（stress test），帮你更深入地理解信号量的工作机制。

Specifically, in this particular situation you see three falling edges in the ISR line, which means that the semaphore was signalled three times from the GPIO-F interrupt. However, the blinky-2 thread went only 2 times around its while(1) loop. So, let's find out why.

具体来说，这个场景中 ISR 线出现了三个下降沿，意味着信号量被 GPIO-F 中断触发了三次。但 blinky2 的 `while(1)` 循环只跑了两次。来分析一下原因。

A good way of thinking about a semaphore is that it is a protocol of exchanging tokens according to the following rules:

理解信号量的一个好办法：把它看成一种交换**令牌**（token）的协议，规则如下：

The signal operation adds a token to the semaphore, but only up to the maximum configured count number.

**signal 操作**给信号量加一个令牌，但最多加到配置的最大计数为止。

The wait operation removes a token from a semaphore if any tokens are available, or it blocks, if no tokens are available.

**wait 操作**从信号量取走一个令牌（如果有的话）；没有令牌就阻塞。

So, let's see how this works in this particular case.

来看看这个具体场景中发生了什么。

Before the switch was pressed, the semaphore had no tokens, so the blinky-2 thread blocked on the semaphore-wait operation.

按下开关之前，信号量没有令牌，blinky2 阻塞在 wait 操作上。

The first falling edge caused the GPIO-F interrupt to signal the semaphore, which added one token.

第一个下降沿触发 GPIO-F 中断，signal 操作给信号量加了一个令牌。

This has immediately unblocked the blinky-2 thread, which still inside the wait-operation took the token out of the semaphore.

blinky2 立刻被解除阻塞，在 wait 操作中就把令牌取走了。

The next bounce, caused the GPIO-F ISR to signal the semaphore, which again added one token to the empty semaphore.

开关第二次抖动又触发了一次中断，signal 操作给空了的信号量又加了一个令牌。

But this time, the blinky-2 thread was already running and didn't yet execute the semaphore wait-operation to remove the token. So, the token stayed in the semaphore.

但这次 blinky2 线程已经在运行了，还没执行到 wait 操作来取走令牌。所以令牌留在了信号量里。

The third bounce, caused the GPIO-F ISR to signal the semaphore again, but this time the semaphore already had one token and could not accept another, because it was configured as a binary semaphore -- with the capacity to hold at most one token.

第三次抖动又触发了一次 signal，但这次信号量里已经有一个令牌了，不能再加——因为它是**二进制信号量**，最多只能容纳一个令牌。

The blinky-2 thread kept running and looped back to the top of its while(1) loop and called the semaphore wait operation.

blinky2 继续运行，回到 `while(1)` 循环开头，调用 wait 操作。

This time the token was immediately available in the semaphore, so the wait-operation just removed the token, but didn't block. Blinky-2 continued through the loop the second time.

这次信号量里正好有令牌，wait 直接取走令牌，没有阻塞。blinky2 开始第二轮循环。

Eventually, blinky-2 looped back to the top of its while(1) loop and called semaphore-wait operation for the third time.

最后 blinky2 又回到 `while(1)` 开头，第三次调用 wait。

This time, however, the semaphore was empty and so blinky-2 blocked.

这次信号量是空的，blinky2 被阻塞了。

But this is only one way the scenario can play out.

但这只是其中一种可能的执行顺序。

It turns out that due to thread preemption, essentially the same three bounces of the switch can lead to quite a different outcome of blinky-2 going just once through its while(1) loop instead of twice. An example of such a scenario is trace number 6.

由于线程抢占的关系，同样的三次开关抖动，完全可能导致不同的结果——blinky2 只跑一次 `while(1)` 循环，而不是两次。第 6 条迹线就是这种情况。

Here the switch bounced while it was released, as opposed to being depressed, but still it produced three falling edges and, consequently the semaphore was signaled three times.

这次抖动发生在开关释放时，而不是按下时。但结果一样：三个下降沿，信号量被 signal 了三次。

But, let's analyze this trace in detail.

来仔细分析这条迹线。

As in the previous case, initially the semaphore had no tokens, so the blinky-2 thread blocked on the semaphore-wait operation.

跟前面一样，信号量一开始没有令牌，blinky2 阻塞在 wait 上。

The first falling edge caused the GPIO-F interrupt to signal the semaphore, which added one token.

第一个下降沿触发中断，signal 加了一个令牌。

But this time, the blinky-2 thread could not run immediately, because it could not preempt the higher-priority blinky-1, which happened to be running. Therefore, the wait operation was NOT performed, and the token was NOT removed from the semaphore.

但这次 blinky2 没法立刻运行——因为它没法抢占正在运行的、优先级更高的 blinky1。所以 wait 操作没执行，令牌也没被取走。

The next falling edge caused the GPIO-F interrupt to signal the semaphore, but this time the semaphore already had one token and could not accept another.

第二个下降沿又触发 signal，但信号量里已经有一个令牌了，加不进去。

The same exact thing happened by the third bounce of the switch as well.

第三次抖动也是一样——加不进去。

The high-priority blinky-1 thread kept running, but finally blocked on the delay() operation. Only at this point the preemptive QXK kernel scheduled blinky-2, which unblocked and removed the token from the semaphore.

高优先级的 blinky1 一直在跑，最终阻塞在 `delay()` 上。直到这时，抢占式 QXK 内核才调度 blinky2——它解除阻塞，取走了令牌。

Finally, blinky-2 looped back to the top of its while(1) loop and called the semaphore-wait operation. This time, the semaphore was empty and so blinky-2 blocked.

最后 blinky2 回到 `while(1)` 开头再次调用 wait。这次信号量是空的，blinky2 被阻塞了。

This concludes this lesson on semaphores as the first of the many inter-thread synchronization mechanisms you need to learn.

信号量这节课就到这里。它是你需要学习的众多**线程间同步机制**中的第一个。

In the next lesson, I'm going to talk about sharing of resources among threads, and about the RTOS mechanisms for guaranteeing the mutually exclusive access to such shared resources.

下一课我们会讨论线程间的资源共享，以及 RTOS 中保证**互斥访问**（mutually exclusive access）的机制。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅保持关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---|---|---|
| Semaphore | 信号量 | 用于线程同步的内核对象，基于令牌计数机制 |
| Binary Semaphore | 二进制信号量 | 最大计数为 1 的信号量，只能容纳零个或一个令牌 |
| Synchronization | 同步 | 协调多个线程执行顺序的机制 |
| Inter-Thread Communication | 线程间通信 | 并发线程之间交换信息的方式 |
| Application Porting | 应用程序移植 | 将应用从一个 RTOS 迁移到另一个 RTOS |
| API (Application Programming Interface) | 应用程序编程接口 | 软件组件之间交互的接口 |
| Constructor | 构造函数 | 初始化对象的特殊函数 |
| Message Queue | 消息队列 | 线程间传递消息的缓冲区 |
| Critical Section | 临界区 | 需要独占访问的代码段 |
| Interrupt Latency | 中断延迟 | 从中断请求到 ISR 第一条指令的时间延迟 |
| Maximum Interrupt Latency | 最大中断延迟 | 最坏情况下的中断延迟 |
| Kernel-Unaware Interrupt | 内核无关中断 | 从不被内核禁用的中断，不能调用 RTOS API |
| Kernel-Aware Interrupt | 内核感知中断 | 可以调用 RTOS API 但可能被内核禁用的中断 |
| Zero Interrupt Latency | 零中断延迟 | RTOS 存在对中断延迟无影响的宣传术语 |
| PRIMASK | 中断屏蔽寄存器 | ARM Cortex-M 中全局禁用所有中断的寄存器 |
| BASEPRI | 基础优先级寄存器 | ARM Cortex-M3+ 中选择性屏蔽中断的寄存器 |
| NVIC (Nested Vectored Interrupt Controller) | 嵌套向量中断控制器 | ARM Cortex-M 中的中断控制器 |
| QF_AWARE_ISR_CMSIS_PRI | 内核感知中断优先级阈值 | QP 中区分内核感知与内核无关中断的常量 |
| Rate Monotonic Scheduling (RMS) | 速率单调调度 | 基于周期的线程优先级分配策略 |
| Hard Real-Time Deadline | 硬实时截止时间 | 必须严格满足的时间约束 |
| Thread Signaling | 线程信号传递 | 通过信号量在线程间传递事件通知 |
| Blocking | 阻塞 | 线程因等待资源而暂停执行 |
| Unblocking | 解除阻塞 | 线程等待的条件满足后恢复执行 |
| Token | 令牌 | 信号量中用于同步的抽象计数单位 |
| Callback Function | 回调函数 | 由框架或内核调用、由用户实现的函数 |
| Preemption | 抢占 | 高优先级线程中断低优先级线程的执行 |
| Falling Edge | 下降沿 | 信号从高电平跳变到低电平的瞬间 |
| Pull-Up Resistor | 上拉电阻 | 将引脚默认保持在高电平的电阻 |
| Mechanical Switch Bouncing | 机械开关抖动 | 机械触点闭合/断开时的短暂不稳定现象 |
| Debouncing | 消抖 | 消除机械开关抖动噪声的技术 |
| Stress Test | 压力测试 | 在极端条件下测试系统行为 |
| Board Support Package (BSP) | 板级支持包 | 与具体硬件板相关的底层软件 |
| Logic Analyzer | 逻辑分析仪 | 用于捕获和显示数字信号时序的调试工具 |
| Trace | 迹线 | 逻辑分析仪中显示的信号活动记录 |
| Programming Paradigm | 编程范式 | 编程的风格和方法论 |
| Object-Oriented Programming (OOP) | 面向对象编程 | 基于对象和类的编程范式 |
| Event-Driven Programming | 事件驱动编程 | 由事件触发执行的编程范式 |
| State Machine | 状态机 | 基于状态转换的行为建模方法 |
| Active Object | 活动对象 | 结合状态机和消息传递的并发模型 |
