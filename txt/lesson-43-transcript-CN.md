# 第43课：活动对象与实时调度 / Lesson 43: Active Objects and Real-Time Scheduling

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'd like to go back to event-driven programming and Active Objects in particular. You've been using event-driven Active Objects since lesson #34, but perhaps it's not quite clear to you what advantages they provide in real-time programming. So, this lesson ties together the concepts of event-driven programming, active objects, state machines and real-time operating system (RTOS). I talked about all these concepts in this video course before.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这节课我们回到事件驱动编程，特别是**活动对象**（Active Objects）这个话题。从第 34 课开始，你一直在用事件驱动的活动对象，但也许你还不太清楚它在实时编程中到底有什么优势。所以这节课要把事件驱动编程、活动对象、状态机和**实时操作系统**（RTOS）这几个概念串起来。这些概念我在之前的课程里都讲过。

In fact, let's go back today to the project for lesson #27 about the RTOS. Copy the lesson-27 directory and rename it to lesson-43. Get inside the new lesson-43 directory and click on the project "lesson" to open it in the Micro-Vision IDE.

说起来，今天我们要回到第 27 课的 RTOS 项目。先把 lesson-27 目录复制一份，重命名为 lesson-43。进入这个新目录，点击项目文件"lesson"就能在 Micro-Vision IDE 中打开它。

To remind you quickly what happened back in lesson-27, you experimented with a preemptive, priority-based RTOS kernel called QXK, which is a part of the QP/C framework. This RTOS kernel managed two traditional threads: blinky-1 and blinky-2. Thread blinky-3 was not started and not used, so let's just clean it up.

快速回顾一下第 27 课的内容。当时你试了一个叫 QXK 的**抢占式、基于优先级的 RTOS 内核**，它是 QP/C 框架的一部分。这个内核管理着两个传统线程：blinky-1 和 blinky-2。blinky-3 线程没有启动也没用到，所以我们先把它清理掉。

To understand what the threads were doing, let's just build and load the code to the TivaC LaunchPad board and then watch how it works using a logic analyzer.

要了解这些线程到底在干什么，我们先构建代码、加载到 TivaC LaunchPad 板上，然后用**逻辑分析仪**（Logic Analyzer）观察它的运行情况。

The logic analyzer trace labeled Blinky-1 corresponds to the blinky-1 thread, while the trace labeled Idle corresponds to the idle thread of the QXK kernel. When you zoom in, you can see that both threads rapidly toggle the LED lines: Green-LED in case of Blinky-1 and Red-LED in case of the Idle thread.

逻辑分析仪上标记为 Blinky-1 的那条迹线对应 blinky-1 线程，标记为 Idle 的迹线对应 QXK 内核的空闲线程。放大来看，你会发现两个线程都在快速翻转 LED 线——Blinky-1 控制 Green-LED，空闲线程控制 Red-LED。

Blinky-1 runs for about 1200 microseconds, after which it delays its execution till the next clock tick. The result is that Blinky-1 runs periodically every 2 milliseconds. The idle thread of the QXK kernel runs when no other threads are running.

Blinky-1 大约运行 1200 微秒，然后把自己的执行延迟到下一个**时钟节拍**（clock tick）。结果就是 Blinky-1 每 2 毫秒周期性地运行一次。QXK 内核的空闲线程嘛，就是没有其他线程运行的时候它才跑。

Now, there is also the blinky-2 thread, started with lower priority than blinky-1. However, blinky-2 waits on a semaphore, which is signaled when the switch SW1 is pressed. So let's set the trigger in your logic analyzer on the falling edge of the SW1 trace, because the switch is active low. Now, when you start the trace, you don't see anything until the SW1 switch is pressed.

另外还有 blinky-2 线程，它的启动优先级比 blinky-1 低。不过 blinky-2 在一个**信号量**（Semaphore）上等待，当 SW1 开关被按下时信号量才会触发。所以我们把逻辑分析仪的触发器设在 SW1 迹线的下降沿——因为开关是低电平有效的。现在开始采集，在按下 SW1 之前什么都看不到。

By the way, I received quite a few inquiries about inexpensive logic analyzers. So, today, I'm using a very cheap logic analyzer, that you can get for about $10 dollars on Amazon.com and perhaps other online retailers. This logic analyzer works with the open-source PulseView software that I'm using in this video. I've put some resources about this tool in the video description below.

顺便说一下，有不少人问我便宜的逻辑分析仪的事。所以今天我用的是一款非常便宜的逻辑分析仪，在 Amazon 和其他电商平台上大约 10 美元就能买到。它配合开源的 PulseView 软件使用——就是我在视频里用的这款。我在视频简介里放了一些相关资源链接。

But going back to your real-time project, it has been specifically designed to showcase the principles of Rate Monotonic Scheduling (RMS), also known as Rate Monotonic Analysis (RMA), that I've introduced back in lesson #26. You can see here RMS in action. The Blinky-1 thread with the highest rate runs at the highest priority. And because of this, it always meets its hard real-time deadline of 2 milliseconds, even if other threads are ready to run, like Blinky-2 or the idle thread.

回到咱们的实时项目。这个项目是专门设计来展示**速率单调调度**（Rate Monotonic Scheduling, RMS）原理的——也叫速率单调分析（RMA），我在第 26 课介绍过。你现在看到的就是 RMS 的实际效果。Blinky-1 线程运行频率最高，所以优先级也最高。正因如此，它总能满足 2 毫秒的**硬实时截止时间**，哪怕 Blinky-2 或空闲线程已经就绪等着运行也不受影响。

Now, these were traditional blocking threads managed by a traditional preemptive, priority-based RTOS kernel. The main question for today is: can Active Objects also do this? In other words, can Active Objects be compatible with the RMA/RMS method to deliver provably hard real-time behavior.

好了，这些是传统的阻塞线程，由传统的抢占式、基于优先级的 RTOS 内核来管理。今天要回答的核心问题是：活动对象也能做到吗？换句话说，活动对象能不能与 RMA/RMS 方法兼容，给出可证明的硬实时行为？

Well, the purpose of this lesson is to find it out as well as to explore other properties of active objects related to concurrency and real-time deadlines.

没错，本课的目的就是找出答案，同时探索活动对象在并发和实时截止时间方面的其他特性。

The first step is to convert the blinky-1 and blinky-2 threads to active objects. You've seen such conversion before, in the second half of lesson 34, so I'll go over this quickly. I will do the coding still manually today, although I will use the QM modeling tool for illustration. The QM model will be included in the project download for this lesson, so you will be able to try automatic code generation if you like.

第一步，把 blinky-1 和 blinky-2 线程转换成活动对象。你在第 34 课后半段已经见过这种转换了，所以我快速过一遍。今天代码还是手写，不过我会用 QM 建模工具来做演示。QM 模型会包含在本课的项目下载里，想尝试自动代码生成的话可以试试。

So, starting with blinky-1, you need to create the Blinky1 active object class that inherits the QActive base class from the QP/C active object framework. In C, you do this by declaring a Blinky1 struct with the first member "super" of type QActive.

先从 blinky-1 开始。你需要创建一个 Blinky1 活动对象类，让它继承 QP/C 活动对象框架里的 QActive 基类。在 C 语言中，做法是声明一个 Blinky1 结构体，第一个成员是 QActive 类型的"super"。

Blinky1 active object will need a time event, to replace the blocking time delay from the corresponding blinky-1 thread. The Blinky1 class needs a constructor function as well as a very simple state machine consisting of the top-most initial pseudostate and just one state "active".

Blinky1 活动对象需要一个**时间事件**（Time Event），用来替代原来 blinky-1 线程里的阻塞式延迟。Blinky1 类需要一个构造函数，加上一个非常简单的状态机——只有一个最顶层的初始伪状态和一个"active"状态。

The constructor must initialize the superclass QActive. The top-most initial pseudostate arms the time event to fire in 2 clock ticks and then periodically every 2 clock ticks. With system clock tick occurring every millisecond, this will make Blinky1 periodic with the period of 2 milliseconds. The top-most initial transition goes to the state "active".

构造函数里必须初始化父类 QActive。最顶层的初始伪状态把时间事件设置为 2 个时钟节拍后触发，然后每 2 个时钟节拍周期性触发。系统时钟节拍是每毫秒一次，所以 Blinky1 就会以 2 毫秒为周期运行。最顶层的初始转换进入"active"状态。

The state "active" has only one internal transition triggered by TIMEOUT_SIG, so here is the skeleton code according to the "optimal" state machine implementation that I've introduced back in lesson #39. The action executed in the TIMEOUT internal transition is the exact body of the original blinky-1 thread, minus the blocking delay, of course.

"active"状态只有一个由 TIMEOUT_SIG 触发的内部转换，所以这里的骨架代码是按照我在第 39 课介绍的"最优"状态机实现方式来写的。TIMEOUT 内部转换里执行的动作跟原来 blinky-1 线程的函数体一模一样——当然，阻塞延迟去掉了。

At this point, you can delete the original code for the blinky-1 thread and move on to blinky-2. The Blinky-2 active object has quite similar structure to Blinky-1, so I copy, paste, and replace Blinky1 with Blinky2 in the selected code.

到这里，就可以把 blinky-1 线程的原始代码删掉了，然后转向 blinky-2。Blinky-2 活动对象跟 Blinky-1 结构很像，所以我复制、粘贴，把选中的代码中的 Blinky1 替换成 Blinky2。

Blinky2 does not need the time event. And also, it handles the BUTTON_PRESS event instead of TIMEOUT. The action executed in the BUTTON_PRESS internal transition is the exact body of the original blinky-2 thread, minus the blocking semaphore, of course. Now, you can delete the blinky-2 thread code.

Blinky2 不需要时间事件。它处理的是 BUTTON_PRESS 事件而不是 TIMEOUT。BUTTON_PRESS 内部转换里执行的动作跟原来 blinky-2 线程的函数体一模一样——当然，阻塞信号量去掉了。好了，现在可以把 blinky-2 线程代码也删掉。

But before deleting the blinky-2 thread instance and the blinky-2 private stack, let's think for a minute what you need for the Blinky2 active object as the replacement. Well, you need the Blinky2 instance and you need an event queue buffer. The length of the queue must be adequate for the worst-case scenario, but 10 events is typically a safe initial guess.

不过在删掉 blinky-2 线程实例和私有栈之前，先想想替代它的 Blinky2 活动对象需要什么。你需要 Blinky2 实例，还需要一个**事件队列缓冲区**（Event Queue Buffer）。队列长度要能应对最坏情况，不过 10 个事件通常是个安全的初始估算。

On the other hand, and most interestingly, you no longer need the private stack for the Blinky2 active object. This is because the underlying QXK RTOS kernel takes advantage of the non-blocking nature of active objects, and executes them as so called "basic threads". Basic threads are run-to-completion activations as opposed to endless loops of traditional, blocking threads that are then called "extended threads". This allows all "basic threads" to use the same stack. In a minute you will see in the logic analyzer trace that these basic threads can still preempt each other.

另一方面——这也是最有趣的地方——你不再需要 Blinky2 活动对象的私有栈了。为什么？因为底层的 QXK RTOS 内核利用了活动对象的非阻塞特性，把它们当作所谓的"**基本线程**"（Basic Threads）来执行。基本线程是运行到完成的激活，跟传统阻塞线程那种无限循环（称为"**扩展线程**"，Extended Threads）完全不同。这就使得所有基本线程可以共享同一个栈。一会儿你会在逻辑分析仪迹线中看到，这些基本线程照样能互相抢占。

Of course, you also need to create the event queue buffer and the instance for the Blinky1 active object, but again, you don't need the private stack for it. So, the net result is that you save a lot of precious RAM, because stacks are typically much bigger than event queues.

当然，Blinky1 活动对象也需要创建事件队列缓冲区和实例，同样不需要私有栈。最终结果就是你省下了大量宝贵的 RAM——因为栈通常比事件队列大得多。

Moving on, you can delete the blocking semaphore. And instead of the extended blinky-1 thread, you need to call the constructor of your Blinky1 active object. Now you need to tell the framework that you're starting an active object, as opposed to an extended thread. For this you use the QACTIVE_START() API.

继续，把阻塞信号量删掉。然后用调用 Blinky1 活动对象构造函数来替代原来的扩展 blinky-1 线程。接下来要告诉框架：你启动的是一个活动对象，不是扩展线程。为此要使用 QACTIVE_START() 这个 API。

The signature of the parameters remains the same, so you leave the same priority, but you need to provide the event queue buffer and its length, and you don't provide the stack. You apply analogous changes to start the Blinky2 active object.

参数签名不变，所以优先级照旧，但你要提供事件队列缓冲区及其长度，不需要提供栈。Blinky2 活动对象的启动也做类似的修改。

So, this would be all for main.c, but you still need to adjust a few things in the Board Support Package (BSP). For example, you still need to define the newly introduced event signals like BUTTON_PRESS_SIG and TIMEOUT_SIG.

好了，main.c 就改这么多。但**板级支持包**（Board Support Package, BSP）里还需要调整一些东西。比如，你还得定义新引入的事件信号，像 BUTTON_PRESS_SIG 和 TIMEOUT_SIG。

For this, open bsp.h, and declare an enumeration for the signals. Remember that in QP the signals cannot start with zero but must be offset by the Q_USER_SIG constant. Also, instead of the semaphore, you will be posting events to your active objects, and for that you'll need global pointers to them.

为此，打开 bsp.h，为信号声明一个枚举。记住，在 QP 中信号不能从零开始，必须用 Q_USER_SIG 常量做偏移。另外，你不再用信号量了，而是向活动对象投递事件，所以你需要指向它们的全局指针。

You still need to add the definitions and initializations of the global active object pointers in main.c. And also you replace the signaling on the semaphore with posting an immutable BUTTON_PRESS event to the Blinky2 active object, just as you did for the TimeBomb project in the previous lessons.

你还需要在 main.c 中添加全局活动对象指针的定义和初始化。同时，把信号量上的信号发送替换为向 Blinky2 活动对象投递一个不可变的 BUTTON_PRESS 事件——跟之前课程中 TimeBomb 项目的做法一样。

This should finally be all, so let's try to build the code. Ah, OK, the problem is the missing definition of the loop index, that was dropped during copy-and-paste. Alright, the code builds cleanly, so let's load it to your TivaC LaunchPad board and see how it works!

这回应该全部改完了。来试试构建。啊，问题是复制粘贴时漏掉了循环索引的定义。好了，代码构建成功，加载到 TivaC LaunchPad 板上看看效果！

Well, it works exactly as before with the traditional threads. Specifically, pressing the button causes Blinky2 to run as before, but Blinky1 keeps running completely undisturbed and meets its hard real-time deadlines every time.

结果跟传统线程完全一样。具体来说，按下按钮后 Blinky2 跟以前一样运行，而 Blinky1 完全不受干扰，每次都能满足硬实时截止时间。

This is because Blinky1, having higher priority, freely preempts Blinky2. So, even though Blinky2 does all its processing in run-to-completion steps, still, it is preempted by Blinky1 -- multiple times. But this is entirely fine, because Blinky2 eventually completes its run-to-completion step before handling another BUTTON_PRESS event in the future.

这是因为 Blinky1 优先级更高，可以随时抢占 Blinky2。所以即使 Blinky2 的处理是以运行到完成的步骤进行的，它仍然会被 Blinky1 多次抢占。但这完全没问题——Blinky2 最终会在下次 BUTTON_PRESS 事件到来之前完成它的运行到完成步骤。

This illustrates the most important point of this lesson: The run-to-completion execution semantics of active objects and state machines does NOT mean that a state machine needs to monopolize the CPU for the whole duration of the run-to-completion step.

这恰恰说明了本课最关键的要点：活动对象和状态机的**运行到完成**（Run-to-Completion）执行语义，并不意味着状态机在运行到完成步骤的整个过程中需要独占 CPU。

Under a preemptive kernel, such as QXK, run-to-completion steps in active objects can and will be interleaved in time. This is handled entirely by the underlying real-time kernel. So, if this kernel is preemptive, active objects can preempt each other and can meet hard real-time deadlines, just as the traditional threads did.

在抢占式内核（比如 QXK）下，活动对象的运行到完成步骤是可以、也确实会在时间上交错执行的。这完全由底层实时内核来处理。所以只要内核是抢占式的，活动对象之间就能互相抢占，也能像传统线程那样满足硬实时截止时间。

What that means is that active objects with state machines, when combined with a preemptive, priority-based real-time kernel, are as suitable for the Rate-Monotonic Scheduling (RMS) as the traditional extended threads.

也就是说，带状态机的活动对象，配合抢占式、基于优先级的实时内核，跟传统扩展线程一样适合做速率单调调度（RMS）。

Actually, active objects are even more suitable for hard real-time and for the RMS method in particular, because they don't share resources and instead use asynchronous events. But this is such a critically important aspect of active objects that it deserves its own lesson, and this is exactly what I will explain next time.

实际上，活动对象在硬实时——尤其是 RMS 方法方面——比传统线程更合适，因为它们不共享资源，而是用**异步事件**来通信。但这个特性太重要了，值得单独用一节课来讲，下节课我就专门说这个。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads. Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course". Thanks for watching!

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/video-course 下载。所有项目也都在 GitHub 上的 Quantum Leaps 仓库"modern embedded programming course"里。感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Active Object | 活动对象 | 事件驱动并发编程模型的核心概念，封装了执行线程、事件队列和状态机 |
| State Machine | 状态机 | 描述系统行为的形式化模型，由状态和转换组成 |
| RTOS (Real-Time Operating System) | 实时操作系统 | 专为实时应用设计的操作系统，保证确定性的响应时间 |
| Rate Monotonic Scheduling (RMS) | 速率单调调度 | 固定优先级调度策略，运行频率越高的任务优先级越高 |
| Rate Monotonic Analysis (RMA) | 速率单调分析 | 基于 RMS 的实时系统可调度性分析方法 |
| Hard Real-Time Deadline | 硬实时截止时间 | 必须在严格时间内完成，否则视为系统失败 |
| Preemptive Kernel | 抢占式内核 | 允许高优先级任务中断低优先级任务执行的内核 |
| Run-to-Completion | 运行到完成 | 一种执行语义，处理步骤在完成前不会被自身中断 |
| Basic Thread | 基本线程 | QXK 中用于执行活动对象的线程，运行到完成方式，共享同一栈 |
| Extended Thread | 扩展线程 | QXK 中传统的阻塞式线程，包含无限循环，需要独立栈 |
| Time Event | 时间事件 | QP 框架中用于定时触发的事件类型，替代传统的阻塞延迟 |
| Event Queue Buffer | 事件队列缓冲区 | 活动对象用于存储待处理事件的队列内存区域 |
| Semaphore | 信号量 | 用于线程同步和互斥的 RTOS 原语 |
| BSP (Board Support Package) | 板级支持包 | 针对特定硬件板的底层驱动和配置代码 |
| Logic Analyzer | 逻辑分析仪 | 用于捕获和显示数字信号时序的调试工具 |
| QXK | QXK 内核 | QP/C 框架中的抢占式、基于优先级的 RTOS 内核 |
| QP/C | QP/C 框架 | Quantum Platform 的 C 语言实现，提供活动对象和状态机框架 |
| QM | QM 建模工具 | 用于设计和自动生成状态机代码的图形化建模工具 |
| Clock Tick | 时钟节拍 | RTOS 中系统时钟的基本时间单位 |
| Signal | 信号 | QP 框架中事件的标识符，用于触发状态转换 |
