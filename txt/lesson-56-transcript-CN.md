# 第56课：将活动对象扩展到传统 RTOS / Lesson 56: Extending Active Objects to Conventional RTOS

Hello and welcome to the Modern Embedded Systems Programming course. I'm Miro Samek, and in this lesson, I continue exploring the different ways to execute event-driven Active Objects. Today's focus is on extending modern event-driven programming--with Active Objects and hierarchical state machines--to conventional real-time operating systems. Specifically, you'll see how to integrate the QP Active Object framework with the Zephyr RTOS.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，本课我们继续探索执行事件驱动**活动对象**（Active Object）的不同方式。今天的重点是：把现代事件驱动编程——包括活动对象和**层次状态机**（Hierarchical State Machine）——扩展到传统的实时操作系统上。具体来说，你会看到如何把 QP **活动对象框架**集成到 Zephyr RTOS 中。

---

In many ways, this lesson ties together the major modern embedded programming themes of this course: event-driven programming, object-oriented programming, and the Active Object model of computation, along with the various execution strategies for event-driven Active Objects covered in lessons 52 through 55.

从很多方面来说，本课把这门课程的几个核心主题串联起来了：事件驱动编程、面向对象编程、**活动对象计算模型**，以及第 52 到 55 课中讲过的事件驱动活动对象的各种执行策略。

---

However, a particularly important reference for today is lesson 34, where the Active Object design pattern was introduced as a collection of best practices for concurrent programming. In that lesson, you also saw how to implement Active Objects using a rudimentary application framework called MicroC/AO, built on the conventional MicroC/OS-II RTOS.

不过，今天特别重要的一节参考是第 34 课。在那节课里，**活动对象设计模式**作为并发编程最佳实践的集合被引入。你还看到了如何用一个叫 MicroC/AO 的基础应用框架来实现活动对象，这个框架就构建在传统的 MicroC/OS-II RTOS 之上。

---

If you haven't watched lesson 34 yet, I recommend doing that first. I won't repeat the fundamentals of what an event-driven framework is, why it necessarily relies on inversion of control, or how it differs from a conventional RTOS.

如果你还没看过第 34 课，建议你先去看一下。关于事件驱动框架的基本概念、为什么它必须依赖**控制反转**（inversion of control）、以及它跟传统 RTOS 有什么区别，这些我不再重复了。

---

I will, however, revisit the goals of lesson 34--and even more so, the objectives of this lesson--which are to dispel several deeply rooted misconceptions about event-driven programming, state machines, and Active Objects.

但我会重新回顾第 34 课的目标——更重要的是本课的目标——那就是消除关于事件驱动编程、状态机和活动对象的一些根深蒂固的**误解**。

---

The first misconception is the belief that state machines are only for bare-metal programming, serving as a low-level alternative to a full RTOS. That perception may hold for "input-driven," or "polled," state machines, which were discussed in lesson 37.

第一个误解是：很多人觉得状态机只能用在裸机编程上，是完整 RTOS 的一种"低级替代品"。这种看法对于"输入驱动"或"轮询式"状态机可能还说得过去——这些在第 37 课中讨论过。

---

But *event-driven* state machines, introduced in lesson 35, not only can work, but actually require a real-time kernel of some sort. This complementary relationship between event-driven programming and an RTOS was already demonstrated in the MicroC/AO event framework used in lessons 34 and 35.

但是，第 35 课引入的**事件驱动**状态机就完全不同了——它不但可以配合 RTOS 工作，而且实际上**需要**某种实时内核的支持。事件驱动编程与 RTOS 之间的这种互补关系，在第 34、35 课使用的 MicroC/AO 事件框架中已经演示过了。

---

Today's lesson takes that idea much further by explaining that it takes more than RTOS message queues, threads structured as event loops, and switch statements for state machines to apply event-driven programming in practice.

今天的课程把这个思路又推进了一大步。我们会看到：光靠 RTOS 的消息队列、以事件循环方式组织的线程、再加上状态机的 switch 语句，是远远不够的——要真正在实践中用好事件驱动编程，需要更多的东西。

---

In particular, you'll see how the mature and battle-tested QP real-time event framework integrates with a mainstream, conventional RTOS such as Zephyr.

特别地，你会看到成熟且经过实战检验的 **QP 实时事件框架**是如何跟 Zephyr 这样的主流传统 RTOS 集成的。

---

The second misconception about Active Objects and state machines is that the run-to-completion (RTC) event-processing semantics somehow prevent Active Objects from being truly real-time, because "real" real-time is supposedly possible only with a real RTOS.

关于活动对象和状态机的第二个误解是：有人认为**运行至完成**（Run-to-Completion, RTC）的事件处理语义会妨碍活动对象实现真正的实时性，因为据说"真正的"实时只能靠"真正的"RTOS 才行。

---

This misunderstanding comes from the notion that an RTC step must necessarily monopolize the CPU for its entire duration, which is the case only for the simplest "superloop"-like schedulers discussed in lessons 53 and 54.

这种误解源于一个错误认知：RTC 步骤必须在整个执行过程中独占 CPU。实际上，这种情况只出现在第 53、54 课中讨论的那种最简单的"超级循环"式调度器中。

---

However, Active Objects can also run on top of preemptive kernels, as you saw in lesson 55. In that case, RTC steps of Active Objects at different priority levels *can* preempt one another. This means the hard real-time assumptions behind methods such as Rate-Monotonic Scheduling (RMS) are not violated.

但是，正如你在第 55 课中看到的，活动对象也可以跑在**抢占式内核**之上。在这种情况下，不同优先级的活动对象的 RTC 步骤是可以互相抢占的。这意味着**速率单调调度**（Rate-Monotonic Scheduling, RMS）等方法背后的硬实时假设并不会被违反。

---

You will see this behavior of Active Objects again today because most conventional RTOS kernels, including Zephyr, are preemptive and compatible with RMS.

今天你会再次看到活动对象的这种抢占行为，因为大多数传统 RTOS 内核（包括 Zephyr）都是抢占式的，而且与 RMS 兼容。

---

The third major misconception concerns the non-blocking requirement for Active Objects, which seems at odds with the way conventional RTOS kernels operate. As explained in lesson 25 on efficient thread blocking, every RTOS thread must block somewhere in its endless loop; otherwise, it consumes all CPU cycles and starves lower-priority threads.

第三个主要误解涉及活动对象的**非阻塞要求**。乍一看，这似乎跟传统 RTOS 内核的运行方式相矛盾。正如第 25 课"高效线程阻塞"中所解释的，每个 RTOS 线程都必须在它的无限循环中某个地方阻塞，否则就会吃掉所有 CPU 周期，把低优先级线程饿死。

---

The key to resolving this apparent contradiction is the event-loop structure of Active Object threads. They do block--but only at the top of the loop when the event queue is empty. The rest of the thread code, the part that executes the Active Objects state machine, must *not* block. You saw this event-loop structure in lesson 34, and you'll see it again today.

解决这个表面矛盾的关键，在于活动对象线程的**事件循环结构**。它们确实会阻塞——但只在循环顶部、事件队列为空时才阻塞。线程代码的其余部分，也就是执行活动对象状态机的那部分，绝对不能阻塞。你在第 34 课见过这种事件循环结构，今天还会再看到。

---

And the final confusion I'll try to clarify by the end of this lesson concerns mixing non-blocking event-driven programming with traditional sequential programming based on blocking. This issue becomes critical when an Active Object framework is built on top of a conventional, blocking RTOS.

最后，本课结束前我要澄清的一个困惑是：能不能把非阻塞的事件驱动编程跟基于阻塞的传统顺序编程混在一起用？当活动对象框架构建在传统的阻塞式 RTOS 之上时，这个问题就变得非常关键了。

---

With this preamble, the plan for today is to first demonstrate how to build and run the Zephyr examples included in the QP/C Active Object framework. Then we'll look at the integration between the QP framework and Zephyr.

开场白就到这里。今天的计划是这样的：先演示如何构建和运行 QP/C 活动对象框架中自带的 Zephyr 示例，然后再看看 QP 框架跟 Zephyr 之间是怎么集成的。

---

Since all code examples for today are already included in the QP/C framework, the download for this lesson 56, which will be posted in the usual companion webpage, will contain QP/C 8.1.2, the latest version at the time of this recording. To avoid bloating the download, the framework has been stripped down, in that parts irrelevant to today's lesson have been deleted.

由于今天的所有代码示例都已经包含在 QP/C 框架里了，第 56 课的下载包（会发布在通常的配套网页上）里包含的是 QP/C 8.1.2，也就是录制时的最新版本。为了避免下载包太臃肿，框架做了精简，跟本课无关的部分都被删掉了。

---

Now, to quickly explain the code organization for Zephyr inside the qpc folder, first, you see the Zephyr sub-directory. This is the QP/C port to Zephyr. All other QP ports are inside the ports sub-directory, but for the QPC framework to be considered also a Zephyr module, the directory structure must follow the particular Zephyr module requirements.

来快速看一下 qpc 文件夹中 Zephyr 相关的代码组织方式。首先你会看到一个 Zephyr 子目录，这是 QP/C 到 Zephyr 的**移植层**（port）。其他所有 QP 移植层都在 ports 子目录里，但为了让 QP/C 框架也能被当作一个 Zephyr 模块来使用，目录结构必须遵循 Zephyr 模块的特定要求。

---

We'll take a closer look at the zephyr port directory later because right now, I'd like to show you the examples for Zephyr that are provided, as usual, in the examples directory. Here, in the zephyr sub-directory, you can find 3 examples, the simplest being the blinky example, which blinks an LED on the board. This example is designed generically according to the Zephyr principles and should work unchanged with most boards supported by Zephyr.

zephyr 移植目录我们稍后再细看，因为现在我想先带你看看 Zephyr 的示例——跟以前一样，在 examples 目录里。在 zephyr 子目录下你可以找到 3 个示例，最简单的是 blinky 示例，功能就是让板子上的 LED 闪烁。这个示例按照 Zephyr 的通用原则设计，大多数 Zephyr 支持的开发板都能直接运行，不需要改代码。

---

Now, usually the examples for this course try to be self-contained, and most of the 3rd-party software is included, typically in the 3rd_party directory. However, the Zephyr project, together with the Zephyr SDK, is humongous, almost 20 Gigabytes, so it is assumed that you've installed all this separately, following the instructions on the Zephyr getting-started web page.

通常，本课程的示例都尽量做到自包含，大多数第三方软件都已包含在内，一般在 3rd_party 目录里。但 Zephyr 项目加上 Zephyr SDK 非常庞大，差不多 20 个 GB，所以这里假设你已经按照 Zephyr 入门网页上的说明，自己单独安装好了这些东西。

---

Also, regarding the development host computer, Zephyr, being a Linux Foundation project, is predominantly intended for Linux hosts. And the supplied examples will build on Linux. But the Zephyr getting-started guide also shows how to install Zephyr on Windows, and I will use that installation.

另外说一下开发主机。Zephyr 是 Linux 基金会的项目，主要面向 Linux 主机，提供的示例也是在 Linux 上构建的。不过 Zephyr 入门指南也展示了如何在 Windows 上安装，我用的就是 Windows 安装方式。

---

Speaking of the Zephyr development process, you must have noticed that I don't use the usual KEIL uVision development environment, but rather just an editor (VS Code in this case) and a simple terminal. This is because Zephyr tooling is command-line oriented and uses a special tool called 'west', which is a meta-tool on top of the CMake meta-tool on top of make.

说到 Zephyr 的开发流程，你可能注意到了，我没有用通常的 KEIL uVision 开发环境，而只是用一个编辑器（这里是 VS Code）和一个简单的终端。这是因为 Zephyr 的工具链是面向命令行的，使用一个叫 **west** 的特殊工具——它是 CMake 之上的元工具，而 CMake 又是 make 之上的元工具，层层叠叠。

---

In order for all this to work, you need to prepare the terminal by executing special scripts. The commands for Linux and Windows hosts are provided in the blinky example README file, so you just need to copy and paste them into your terminal.

要让这一切正常工作，你需要先执行一些特殊的脚本来准备终端环境。Linux 和 Windows 主机的命令都在 blinky 示例的 README 文件里，你只需要复制粘贴到终端中就行。

---

The first script activates the virtual Python environment for west, and the second configures the environment variables for Zephyr.

第一个脚本激活 west 所需的 Python 虚拟环境，第二个脚本配置 Zephyr 的环境变量。

---

Once this is done, you change directory to: lesson-56, qpc, examples, zephyr, blinky.

这些都搞定之后，切换到目录：lesson-56、qpc、examples、zephyr、blinky。

---

And next, you initiate the Zephyr build by invoking west with the board parameter specified in the -b option. As I mentioned, this example should work with most Zephyr-supported boards. For this lesson, I use the NUCLEO-C031C6.

然后，调用 west 发起 Zephyr 构建，用 -b 选项指定开发板参数。前面说了，这个示例在大多数 Zephyr 支持的板子上都能跑。本课中我用的是 NUCLEO-C031C6。

---

Zephyr builds take a while, especially the first one, so in the meantime, let's take a look at the blinky source code--by the Zephyr convention located in the src sub-directory.

Zephyr 构建需要花点时间，尤其是第一次。趁它在构建，我们来看看 blinky 的源代码——按 Zephyr 的惯例，放在 src 子目录里。

---

The main function is identical to all other QP applications. So is the blinky active object and its internal state machine. This would work with any real-time kernel.

main 函数跟所有其他 QP 应用程序一模一样。blinky 活动对象及其内部状态机也是。这些代码跟任何实时内核都能配合使用。

---

The Zephyr-specifics are limited to the Zephyr configuration in prj.conf file and the board-support package (bsp.c). Here, the noteworthy detail is the implementation of the QP time event processing, which is called from the Zephyr timer callback, started to tick every hardware clock tick.

Zephyr 特定的部分只有 `prj.conf` 文件中的 Zephyr 配置和**板级支持包**（Board Support Package, BSP）`bsp.c`。这里值得注意的细节是 QP **时间事件处理**的实现——它从 Zephyr 的定时器回调中调用，每个硬件时钟节拍触发一次。

---

Additionally, you can see that the BSP functions for turning the LED on and off also call the Zephyr print instrumentation, which you will see in a minute.

此外你可以看到，开关 LED 的 BSP 函数里还调用了 Zephyr 的打印插桩功能，稍后你会看到效果。

---

When the build finally finishes, you can plug in the NUCLEO board and flash the binary. You can try doing this with the west flash command, but this invokes a board-specific flash programming utility, which I haven't configured for Zephyr yet.

构建终于完成之后，你就可以插上 NUCLEO 板子烧录二进制文件了。你可以试试 `west flash` 命令，但它会调用特定板子的烧录工具，我还没为 Zephyr 配置这个。

---

But this is a NUCLEO board that enumerates as a USB drive, to which you can copy the binary. You just need to know that the binary is located in build\zephyr\zephyr.bin. Also, on my machine NUCLEO enumerates as drive f:, but of course you need to adjust that to your machine.

不过 NUCLEO 板子会枚举成一个 USB 驱动器，你可以直接把二进制文件复制过去。你只需要知道二进制文件在 `build\zephyr\zephyr.bin`。另外，我的机器上 NUCLEO 枚举为 F 盘，你当然要根据自己的机器调整盘符。

---

After the board is programmed, it should start to blink the LED once per second. You can also open a serial terminal and watch the printouts from the instrumented BSP on and off functions.

板子烧录好之后，LED 应该每秒闪烁一次。你还可以打开串口终端，观察插桩后的 BSP 开关函数打印的输出。

---

The next example for Zephyr is the Dining Philosopher Problem (DPP), which you build identically to Blinky before.

下一个 Zephyr 示例是**哲学家就餐问题**（Dining Philosopher Problem, DPP），构建方式跟之前的 Blinky 一模一样。

---

This example demonstrates multiple communicating Active Objects. It consists of 5 active objects emulating the philosophers and 1 active object called Table that manages the forks for hungry philosophers.

这个示例演示了多个活动对象之间的通信。它包含 5 个模拟哲学家的活动对象，加上 1 个叫 Table 的活动对象，负责管理那些饥饿的哲学家的餐叉。

---

As before, the main function and the active object code are generic and independent on any real-time kernel.

跟之前一样，main 函数和活动对象代码都是通用的，不依赖于任何特定的实时内核。

---

You program the board as before, by copying the binary.

烧录板子的方式跟之前一样，直接复制二进制文件就行。

---

This time, the LED should also blink, but less regularly, and you can also watch the printouts from the changing Philosopher status on the serial terminal.

这次 LED 也会闪，但没那么规律。你还可以在串口终端上看到哲学家状态变化的打印输出。

---

The DPP example demonstrates one more QP feature, which is the software tracing instrumentation. To enable that feature, you must rebuild the DPP example with the option provided in the README file.

DPP 示例还演示了 QP 的另一个功能——**软件追踪插桩**（software tracing）。要启用这个功能，你需要用 README 文件里提供的选项重新构建 DPP 示例。

---

You saw the concept of minimally intrusive software tracing in lesson 46.

**最小侵入式软件追踪**的概念，你在第 46 课中已经见过了。

---

When you flash the board now, the ASCII serial terminal shows garbage because the tracing protocol is binary.

现在烧录板子后，ASCII 串口终端上会显示乱码，因为追踪协议是二进制的。

---

To really see the output, you need to launch the special QSPY host utility, which is provided in the QP-bundle. Assuming that you have it installed, you launch QSPY and attach it to the COM port of the NUCLEO board, which you can find from the PC Device Manager.

要真正看到输出，你需要启动专门的 **QSPY 主机工具**，这个工具包含在 QP-bundle 里。假设你已经安装好了，启动 QSPY 并连接到 NUCLEO 板的 COM 端口——端口号可以从 PC 的设备管理器里找到。

---

If QSPY reports errors connecting to the board, check if you have the ASCII serial terminal still running because it uses the same serial port as QSPY.

如果 QSPY 报告连接板子时出错，检查一下是不是 ASCII 串口终端还在运行——因为它跟 QSPY 用的是同一个串口。

---

Now, you can also test the bi-directional connection to the board, for example, by pressing the 'r' key to send the reset command.

好了，你还可以测试到板子的双向连接，比如按 'r' 键发送复位命令。

---

The QP/Spy software tracing is implemented in the bsp.c Board Support Package by means of the generic Zephyr serial port driver, and therefore it should work on any board supported by Zephyr.

QP/Spy 软件追踪是在 `bsp.c` 板级支持包中通过 Zephyr 的通用串口驱动实现的，所以 Zephyr 支持的任何板子都能用。

---

The last provided example for Zephyr is the real-time testing application used already in lessons 54 and 55.

最后一个提供的 Zephyr 示例是**实时测试应用程序**，在第 54、55 课中已经用过了。

---

You build it with the additional option to enable the lowest-priority idle thread, which is added in the QP port to Zephyr, but needs to be enabled.

你需要加一个额外的选项来构建它，以启用最低优先级的空闲线程。这个线程是在 QP 移植到 Zephyr 时添加的，但需要手动启用。

---

This application is specific only to the NUCLEO-C031C6 board in that its Board Support Package uses the CMSIS-based register-level access to the hardware, bypassing the Zephyr high-level device tree and generic drivers. This might be frowned upon by the Zephyr purists, but it is much simpler and more efficient, especially when real-time performance is of interest.

这个应用程序只针对 NUCLEO-C031C6 板，因为它的板级支持包用的是基于 CMSIS 的寄存器级硬件访问，绕过了 Zephyr 的高层设备树和通用驱动。Zephyr 纯粹主义者可能会不以为然，但这样做的确更简单、更高效——尤其是当你关注实时性能的时候。

---

You can flash this example to the board as before, but to really see what it does, you need a logic analyzer. This is all explained in the previous lesson 55, so I won't repeat that, but just for context, this application has 4 active objects that post each other events, which leads to interesting preemption scenarios, especially after you press the user button on the NUCLEO board.

你可以像之前一样把这个示例烧录到板子上，但要真正看清楚它的行为，你需要一个**逻辑分析仪**。这些在第 55 课中已经详细解释过了，我就不再重复。简单提供一下背景：这个应用程序有 4 个活动对象，它们互相发送事件，会产生有趣的抢占场景——特别是当你按下 NUCLEO 板上的用户按钮之后。

---

The system tick occurs in this example every 200 microseconds, which corresponds to a very high ticking rate of 5kHz, with the 48MHz CPU clock. This high interrupt rate is set up to cause more interesting preemptions. And indeed, you can see many thread preemptions in this logic analyzer trace.

这个示例中，系统节拍每 200 微秒触发一次，对应 5kHz 的超高速节拍率——CPU 时钟是 48MHz。设置这么高的中断率是为了制造更有趣的抢占场景。确实，你可以在这条逻辑分析仪追踪中看到大量的线程抢占。

---

We'll return to this trace again to compare the performance of Zephyr to FreeRTOS and the preemptive QK kernel presented in lesson 55.

稍后我们会回到这条追踪，把 Zephyr 的性能跟 FreeRTOS 以及第 55 课中介绍的抢占式 QK 内核做一个对比。

---

After you've seen the examples, let's talk about the adaptation of the QP framework necessary to run it on top of the Zephyr RTOS. Such adaptation is called a *port*.

示例看完了，接下来我们聊聊要把 QP 框架跑在 Zephyr RTOS 之上需要做哪些适配工作。这种适配叫做**移植**（port）。

---

Portability of the QP framework is one of its non-functional requirements and is reflected in the layered architecture of the framework. This means that the QP framework defines the interface to the underlying kernel, called the Operating System Abstraction Layer (OSAL).

可移植性是 QP 框架的非功能性需求之一，体现在框架的**分层架构**中。也就是说，QP 框架定义了与底层内核的接口，叫做**操作系统抽象层**（Operating System Abstraction Layer, OSAL）。

---

On one side, the OSAL defines an interface between QP and an abstract kernel. On the other side, the OSAL interfaces with the kernel through its specific API. The big benefit of all this is that once the OSAL layer is ported to the RTOS, it can work without any changes with any CPU or board supported by the RTOS.

一方面，OSAL 定义了 QP 跟一个抽象内核之间的接口。另一方面，OSAL 通过具体 RTOS 的 API 跟实际内核对接。这样做最大的好处是：一旦 OSAL 层移植到了某个 RTOS 上，它就可以在该 RTOS 支持的任何 CPU 或板子上原封不动地运行。

---

The QP OSAL layer is implemented in two files located in the port directory, qpc/zephyr, in this case.

QP OSAL 层实现在移植目录下的两个文件中，本例中就是 `qpc/zephyr`。

---

First, the header file qp_port.h provides specific definitions of the kernel-dependent elements and services required by QP.

首先是头文件 `qp_port.h`，它提供了 QP 所需的、跟内核相关的元素和服务的具体定义。

---

For example, the QP active object class, QActive, needs an event queue and a thread of execution. The types of these members of the QActive class can't be hard-coded in the framework. Rather, they are OSAL macros, whose definition depends on the specific kernel. For Zephyr, the event queue is defined as struct k_msgq and the thread as struct k_thread. The best way to choose the right representation is to study the application examples accompanying a given kernel.

举个例子，QP 的活动对象类 QActive 需要一个事件队列和一个执行线程。QActive 类中这些成员的类型不能在框架里硬编码，它们是 OSAL 宏，定义取决于具体的内核。对于 Zephyr 来说，事件队列定义为 `struct k_msgq`，线程定义为 `struct k_thread`。选择正确的表示方式的最好办法，就是研究给定内核附带的应用示例。

---

Next, an important choice is the critical section for the QP framework to protect its internal integrity against race conditions. Ideally, this should be the same mechanism as used internally by the RTOS to protect its own integrity.

接下来一个重要选择是**临界区**（critical section）机制——QP 框架用它来保护内部完整性，防止竞态条件。理想情况下，应该跟 RTOS 内部保护自身完整性用的是同一套机制。

---

So, when you study the RTOS source code, you find that Zephyr uses the k_spin_lock() and k_spin_unlock() services for this. Additionally, Zephyr saves the previous status of the lock in a stack variable and then restores the status upon the critical section exit. The QP OSAL critical section abstraction is flexible and can accommodate such behavior.

所以，你去研究 RTOS 源代码就会发现，Zephyr 用的是 `k_spin_lock()` 和 `k_spin_unlock()` 服务来实现这一点。此外，Zephyr 会把锁的先前状态保存在栈变量里，退出临界区时再恢复。QP OSAL 的临界区抽象很灵活，能适应这种行为。

---

Please also note that QP critical sections don't nest, so you can use just one spinlock object QF_spinlock for all critical sections in QP.

还要注意，QP 的临界区不支持嵌套，所以整个 QP 中的所有临界区可以共用一个自旋锁对象 `QF_spinlock` 就够了。

---

The next service required by QP is scheduler locking during event publishing to multiple subscribers. Ideally, the mechanism should allow selective scheduler locking only to the priority ceiling of the highest-priority subscriber. However, Zephyr provides only a crude global scheduler lock.

QP 需要的下一个服务是在向多个订阅者发布事件时锁定调度器。理想情况下，这个机制应该只把调度器锁定到最高优先级订阅者的优先级上限就行了。但 Zephyr 只提供了一个粗粒度的全局调度器锁。

---

Since the event publishing can also occur in the ISR context, the scheduler locking mechanism must also properly work inside ISRs. In the case of Zephyr, the protection is implemented by explicitly checking the ISR context.

由于事件发布也可能发生在**中断服务程序**（Interrupt Service Routine, ISR）上下文中，所以调度器锁定机制也必须在 ISR 内正常工作。在 Zephyr 的情况下，保护是通过显式检查 ISR 上下文来实现的。

---

And finally, the QP framework needs deterministic memory management to implement the event pools for mutable events. Some RTOSes provide fixed-size heaps, also known as memory pools, which could be adequate. However, most QP ports, including this port to Zephyr, apply the QP-native QMPool class for event pools. Here you can see the OSAL abstract event-pool operations defined in terms of the QMPool functions.

最后，QP 框架还需要**确定性内存管理**来实现可变事件的事件池。有些 RTOS 提供固定大小堆（也叫内存池），可能够用了。但大多数 QP 移植层——包括这个 Zephyr 移植——用的是 QP 原生的 **QMPool 类**来实现事件池。这里你可以看到 OSAL 抽象的事件池操作是用 QMPool 函数来定义的。

---

The next Operating System Abstraction Layer file, qf_port.c, provides the implementation of the kernel-dependent behavior in the QP framework.

操作系统抽象层的下一个文件是 `qf_port.c`，它提供了 QP 框架中跟内核相关的行为的实现。

---

At the top of the file, you see the thread function structured as an event-loop, which I mentioned at the beginning of this lesson, and here you can see a concrete example for Zephyr.

在文件顶部，你会看到组织为事件循环的线程函数——就是本课开头我提到过的那个结构，这里是 Zephyr 的具体实现。

---

Since this is a critical aspect of executing Active Objects with a conventional RTOS, let me reiterate the main points:

由于这是用传统 RTOS 执行活动对象的关键所在，让我再强调一下要点：

---

First: *all* Active Object threads run exactly this *same* event-loop function defined inside the framework and even made static, to hide it completely in this module. This is a drastic departure from the traditional way of creating RTOS applications, where each thread runs its own *custom* thread function defined in the application-level code, outside the RTOS.

第一，所有活动对象线程运行的都**完全是同一个**事件循环函数。这个函数定义在框架内部，甚至被声明为 static，完全隐藏在这个模块里。这跟传统的 RTOS 应用开发方式截然不同——传统方式中，每个线程跑的是自己**自定义**的线程函数，定义在 RTOS 之外的应用层代码中。

---

This means that the control over the thread function resides in the Active Object framework rather than the application. I hope you remember from lessons 33 and 34 that such *inversion of control* is one of the main characteristics of event-driven programming.

也就是说，线程函数的控制权在活动对象框架手里，而不是在应用程序手里。希望你还记得第 33、34 课中讲过的——这种**控制反转**正是事件驱动编程的主要特征之一。

---

However, while all Active Objects run this exact same thread function, each such function operates on a *different* Active Object instance, which is passed as the 'p1' void pointer parameter, and immediately cast to the QActive pointer 'act'.

不过，虽然所有活动对象都运行同一个线程函数，但每个函数操作的是**不同的**活动对象实例。这个实例通过 `p1` 这个 void 指针参数传进来，然后立即转换为 QActive 指针 `act`。

---

Now, the body of the event-loop in QP always consists of the following three steps:

好，QP 中事件循环的主体始终由以下三个步骤组成：

---

Step one: receiving an event from the active object's event queue. In an RTOS port like this one, this call blocks when the event queue is empty, but this is the only blocking call in the whole loop.

第一步：从活动对象的事件队列中接收事件。在像这样的 RTOS 移植中，当事件队列为空时这个调用会阻塞——但这是整个循环中唯一的阻塞调用。

---

Step two: dispatching the event to the Active Object's hierarchical state machine. This is the run-to-completion (RTC) processing and can be complex. However, this code should never internally block or poll for events because it would clog the event-loop and make it unresponsive to events delivered through the event queue. In QP/C, event dispatching is a "virtual" call, emulated in C as explained in lesson 32 about Object-Oriented Programming and polymorphism. In QP/C++, this is obviously a native virtual call.

第二步：把事件分派到活动对象的层次状态机。这就是运行至完成处理，可能会比较复杂。但是，这段代码绝不能在内部阻塞或轮询事件，否则会堵死事件循环，让它对通过事件队列传来的事件无响应。在 QP/C 中，事件分派是一个"虚"调用，用 C 语言模拟的——第 32 课讲面向对象编程和多态时解释过。在 QP/C++ 中，这就是一个原生的虚调用了。

---

And step three: the processed event is passed to the QF garbage collector for recycling. This is part of the automatic event management feature provided in QP, which takes advantage of the inherent control inversion. Dynamically allocated, mutable events in QP are reference-counted and *automatically* recycled when no longer referenced.

第三步：处理完毕的事件被传给 QF 垃圾回收器进行回收。这是 QP 提供的**自动事件管理**功能的一部分，它利用了固有的控制反转。QP 中动态分配的可变事件采用**引用计数**，当不再被引用时会自动回收。

---

The reference counting of mutable events is visible in the next function QActive_post_(), which must be customized for Zephyr because it ultimately relies on the Zephyr k_msgq_put() facility.

可变事件的引用计数在下一个函数 `QActive_post_()` 中可以看到。这个函数必须为 Zephyr 定制，因为它最终依赖的是 Zephyr 的 `k_msgq_put()` 设施。

---

Before that, however, the event is checked for being mutable, and if so, its reference count is incremented.

在此之前，首先会检查事件是否为可变的，如果是的话，就增加它的引用计数。

---

You can also see here the software tracing instrumentation, which is active only when software tracing is enabled.

你还可以在这里看到软件追踪插桩——只有在启用软件追踪时才会激活。

---

Also, at the end of the function, in the case of posting being unsuccessful, the event is recycled to avoid an event leak.

另外，在函数末尾，如果投递不成功，事件会被回收，以避免事件泄漏。

---

I'll skip the other QActive operations related to the event queue because they are similar to QActive_post().

跟事件队列相关的其他 QActive 操作我就跳过了，因为跟 `QActive_post()` 类似。

---

However, I will explain starting Active Objects, which involves initializing the event queue, assigning the Active Object priority, and creating the execution thread.

不过我要讲一下启动活动对象的过程，这涉及初始化事件队列、分配活动对象优先级、以及创建执行线程。

---

Regarding the priority, the problem is that QP framework uses a direct priority numbering scheme, where the lowest priority is 1, and the highest is QF_MAX_ACTIVE. Zephyr uses the reverse scheme, where priority 0 is the highest-priority and larger numbers correspond to the lower-priority threads.

关于优先级，问题在于 QP 框架用的是**直接优先级编号方案**——最低优先级是 1，最高是 `QF_MAX_ACTIVE`。而 Zephyr 用的是反过来的方案——优先级 0 是最高，数字越大优先级越低。

---

The solution implemented in this QP port to Zephyr supports two ways of assigning the Active Object priority.

这个 QP 到 Zephyr 的移植方案支持两种分配活动对象优先级的方式。

---

First, the user can specify a separate QP priority and a separate Zephyr priority, as illustrated in the bsp.c file for the real-time application example. Please note that it is the developer's responsibility to specify the priorities consistently; that is, a higher QP priority should correspond to the higher-priority Zephyr thread.

第一种，用户可以分别指定 QP 优先级和 Zephyr 优先级，就像实时测试示例的 `bsp.c` 文件中演示的那样。请注意，开发者有责任保证优先级设置的一致性——也就是说，较高的 QP 优先级应该对应较高优先级的 Zephyr 线程。

---

Second, the user can specify only the QP priority and leave the Zephyr priority at zero. In that case, the priority for the Zephyr thread is calculated as the reversal of the QP priority according to the shown formula.

第二种，用户可以只指定 QP 优先级，把 Zephyr 优先级留为零。这种情况下，Zephyr 线程的优先级会根据屏幕上显示的公式，从 QP 优先级反转计算出来。

---

And the last function in this QP port I'd like to explain is QF_run(), which transfers the control to the framework to run the Active Objects.

这个 QP 移植中我想解释的最后一个函数是 `QF_run()`，它把控制权交给框架，让框架开始运行活动对象。

---

An interesting aspect here is the optional implementation of the lowest-priority idle thread because Zephyr does not provide any access, such as a callback, to its own idle loop.

这里一个有意思的地方是最低优先级空闲线程的可选实现。因为 Zephyr 不提供任何方式（比如回调）让你访问它自己的空闲循环。

---

When the idle feature is configured, QF_run() lowers the priority of the main thread and enters an endless loop that continuously calls idle processing. Otherwise, QF_run() simply returns. The idle processing is useful for implementing software tracing output or other idle behavior.

当空闲功能被配置时，`QF_run()` 会降低主线程的优先级，然后进入一个无限循环，不停地调用空闲处理。否则，`QF_run()` 就是简单地返回。空闲处理对于实现软件追踪输出或其他空闲行为很有用。

---

Alright, so at this point, I hope you have a general idea of how a conventional, *blocking* RTOS, like Zephyr, can be used to execute event-driven, *non-blocking* state machines encapsulated inside Active Objects.

好，到这里，希望你大致明白了：一个传统的**阻塞式** RTOS，比如 Zephyr，是怎么用来执行封装在活动对象中的事件驱动**非阻塞**状态机的。

---

The key to resolving the apparent contradiction between the blocking and non-blocking paradigms is the event-loop, which blocks only at the top and then executes a non-blocking run-to-completion code segment.

解决阻塞与非阻塞范式之间表面矛盾的关键，就是事件循环——它只在顶部阻塞，然后执行一段非阻塞的运行至完成代码。

---

But using a conventional RTOS for running event loops is wasteful. I mean, an RTOS is a complex machinery capable of blocking at any number of points inside a thread function, including blocking inside deeply nested function calls. But this comes at a hefty price of a separate stack for each thread and complex context switching.

但用传统 RTOS 来跑事件循环，其实有点浪费。怎么说呢？RTOS 是一套复杂的机制，它能在线程函数内部的任意多个点阻塞，包括在深层嵌套的函数调用中阻塞。但这是有代价的——每个线程需要独立的栈空间，上下文切换也更复杂。

---

So, while a conventional RTOS can definitely do it, it is just not the most efficient tool for the job--like rolling out a cannon to kill a fly.

所以，传统 RTOS 确实能干这件事，但它不是最趁手的工具——就好比杀鸡用牛刀。

---

But, as you saw in the previous lesson 55, there are other types of lightweight kernels, such as the preemptive, non-blocking QK built into the QP framework, which do away with the wasteful event-loop and execute only the run-to-completion code segment as a one-shot task.

但是，正如你在第 55 课中看到的，还有其他类型的轻量级内核，比如 QP 框架内置的抢占式、非阻塞 **QK 内核**。它干脆去掉了浪费的事件循环，只把运行至完成代码段作为一次性任务来执行。

---

Please note that such a task is called only when the kernel knows that the event queue has some events, so the queue get-operation does not block.

请注意，这种任务只在内核知道事件队列里有事件时才会被调用，所以队列的获取操作不会阻塞。

---

The result is the same, preemptive real-time behavior, but at a much lower cost of just a single stack and simpler context switch.

结果是同样的抢占式实时行为，但代价低得多——只需要一个栈，上下文切换也更简单。

---

A Kernel of this type is a more suitable tool for the job of executing non-blocking event-driven systems in real-time.

这种类型的内核，才是实时执行非阻塞事件驱动系统的更合适工具。

---

To illustrate the point, let me compare the logic analyzer traces from the real-time example with Zephyr discussed today with the same real-time example with the QK kernel from the last lesson 55.

为了说明这一点，让我把今天讨论的 Zephyr 实时示例的逻辑分析仪追踪，跟上一课第 55 课中 QK 内核的同一个实时示例做个对比。

---

As you can see, both traces show the same preemptions, but in Zephyr, everything is slower because of its higher overhead.

可以看到，两条追踪中的抢占模式是一样的，但在 Zephyr 中所有操作都更慢，因为它的开销更大。

---

Also, on the right, you can see a comparison of ROM and RAM footprints of the same real-time application with Zephyr and QK.

另外，右边可以看到同一个实时应用程序在 Zephyr 和 QK 下的 ROM 和 RAM 占用对比。

---

Which all leads to the question: why should you use a conventional RTOS for event-driven systems?

这一切自然引出了一个问题：为什么要用传统 RTOS 来跑事件驱动系统呢？

---

Well, you don't need to use it to achieve preemptive multitasking and hard-real time performance. In fact, a conventional Real-Time Operating System kernel is *less* suitable for hard real-time than the lightweight non-blocking kernel, because an RTOS causes more overhead and blocking calls scattered inside the threads are more difficult to analyze.

实际上，你并不需要用它来实现抢占式多任务和硬实时性能。说句实话，传统实时操作系统内核在硬实时方面反而不如轻量级非阻塞内核来得合适——因为 RTOS 的开销更大，而且分散在线程内部的阻塞调用也更难分析。

---

But there are reasons when you might need a conventional RTOS:

但在某些情况下，你确实可能需要传统 RTOS：

---

First, you might be using a CPU type that the non-blocking kernel does not yet support, but your RTOS does. Such use is possible for properly layered QP ports, where all CPU dependencies are handled by the RTOS.

第一，你用的 CPU 类型可能非阻塞内核还不支持，但你的 RTOS 支持。对于正确分层的 QP 移植层来说，这种用法是可行的——因为所有 CPU 依赖都由 RTOS 来处理了。

---

Second, your software libraries, such as TCP/IP and USB communication stacks, file systems, and various device drivers, require blocking, for example, inside APIs, such as sockets.

第二，你的软件库（比如 TCP/IP 和 USB 通信栈、文件系统、各种设备驱动）需要阻塞操作，比如在套接字之类的 API 内部。

---

Third, a lot of in-house legacy code relies on blocking, which mandates the use of a conventional RTOS capable of blocking.

第三，公司内部有大量遗留代码依赖阻塞操作，这逼着你必须用一个支持阻塞的传统 RTOS。

---

Fourth, the development team is familiar with the sequential blocking paradigm and uncomfortable with the event-driven non-blocking paradigm.

第四，开发团队习惯了顺序阻塞的编程范式，对事件驱动非阻塞范式还不太适应。

---

So, if you must use a conventional RTOS for any of the reasons, here are a couple of the most important guidelines:

所以，如果你因为以上任何原因必须使用传统 RTOS，这里有几条最重要的指导原则：

---

You should never mix the blocking and non-blocking paradigms within a single thread. In other words, you should never block inside Active Objects' state machines. If you need to block, create a dedicated "naked" RTOS thread for it.

绝对不要在同一个线程内混用阻塞和非阻塞范式。换句话说，绝对不要在活动对象的状态机内部阻塞。如果确实需要阻塞，就为它创建一个专门的"裸"RTOS 线程。

---

Please remember that you *can* post or publish an event to Active Objects from any code, including from your blocking threads.

请记住，你完全可以从任何代码向活动对象投递或发布事件——包括从你的阻塞线程中。

---

To communicate in the opposite direction: from Active Objects to the blocking threads, you can also use the same mailbox mechanism as your QP port (k_msgq in case of the Zephyr port).

反方向的通信——从活动对象到阻塞线程——你也可以用跟 QP 移植层相同的邮箱机制（Zephyr 移植中就是 `k_msgq`）。

---

However, after you receive a QP event, you must remember to explicitly recycle the event after processing in your blocking thread (by calling the QF_gc() function).

不过要注意，收到 QP 事件后，你必须记得在阻塞线程中处理完毕后手动回收事件——调用 `QF_gc()` 函数。

---

This concludes this lesson about extending the modern event-driven paradigm to conventional RTOS.

关于把现代事件驱动范式扩展到传统 RTOS 的内容，就讲到这里。

---

As always, the project for this lesson is available for download from the companion webpage to this video course and from the GitHub repository.

像往常一样，本课的项目可以从视频课程的配套网页和 GitHub 仓库下载。

---

If you enjoy this channel, please consider subscribing to help support the ongoing production of new videos. Thank you for watching!

如果你喜欢这个频道，请考虑订阅，支持我们持续制作新的视频。感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Active Object | 活动对象 | 一种并发编程模型，封装了状态机和事件队列 |
| Hierarchical State Machine (HSM) | 层次状态机 | 支持状态嵌套的有限状态机 |
| Event-Driven Programming | 事件驱动编程 | 以事件为驱动的编程范式 |
| Inversion of Control | 控制反转 | 框架控制程序流，而非应用程序 |
| Run-to-Completion (RTC) | 运行至完成 | 事件处理语义，每个事件处理必须完整执行后才处理下一个 |
| Rate-Monotonic Scheduling (RMS) | 速率单调调度 | 固定优先级实时调度算法，速率越高优先级越高 |
| Preemptive Kernel | 抢占式内核 | 高优先级线程可以抢占低优先级线程的内核 |
| Non-Blocking | 非阻塞 | 操作不会导致线程挂起等待 |
| Event Loop | 事件循环 | 循环等待并处理事件的程序结构 |
| Superloop | 超级循环 | 裸机系统中常见的无限主循环结构 |
| Operating System Abstraction Layer (OSAL) | 操作系统抽象层 | 屏蔽底层 RTOS 差异的抽象接口层 |
| Port / Porting | 移植 | 将软件框架适配到特定平台的过程 |
| Critical Section | 临界区 | 需要互斥访问的代码段 |
| Spinlock | 自旋锁 | 忙等待方式的锁机制 |
| Scheduler Lock | 调度器锁 | 锁定调度器以防止线程切换 |
| Event Pool | 事件池 | 用于动态事件分配的固定大小内存池 |
| Reference Counting | 引用计数 | 跟踪对象被引用次数的内存管理技术 |
| Garbage Collector | 垃圾回收器 | 自动回收不再使用的事件/对象的机制 |
| Software Tracing | 软件追踪 | 记录程序运行时行为的低开销插桩技术 |
| Dining Philosopher Problem (DPP) | 哲学家就餐问题 | 经典的并发同步问题示例 |
| Board Support Package (BSP) | 板级支持包 | 针对特定硬件板的底层驱动代码 |
| QSPY | QSPY 工具 | QP 框架的主机端软件追踪查看工具 |
| West | West 元工具 | Zephyr 的命令行构建元工具 |
| QK Kernel | QK 内核 | QP 框架内置的抢占式非阻塞内核 |
| QMPool | QMPool 类 | QP 框架原生的固定大小内存池实现 |
| ISR (Interrupt Service Routine) | 中断服务程序 | 处理硬件中断的程序 |
| Context Switch | 上下文切换 | RTOS 在线程间切换时保存/恢复处理器状态的过程 |
| Mutable Event | 可变事件 | 内容可在传递过程中被修改的事件 |
| One-Shot Task | 一次性任务 | 每次触发只执行一次 RTC 步骤的任务 |
