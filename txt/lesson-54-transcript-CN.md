# 第54课：非抢占式 QV 内核与 QP/C 框架 / Lesson 54: Non-Preemptive QV Kernel and QP/C Framework

Hello and welcome to the Modern Embedded Systems Programming course. I'm Miro Samek, and in this lesson, I will bring the non-preemptive scheduler for the "superloop" introduced in the last two lessons to the logical conclusion. Specifically, today, I'll demonstrate and explain the professional version of such a scheduler called QV, which is available as one of the built-in kernels in the QP/C active object framework. Also, today, I will present QV and QP/C on the STM32 NUCLEO board using the popular STM32Cube development environment.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这节课我会把前两课讲的"超级循环"（superloop）非抢占式调度器推进到它的最终形态。具体来说，今天我会演示并讲解这种调度器的专业版本——**QV 内核**，它是 QP/C **活动对象**（Active Object）框架中内置的内核之一。另外，今天我还会在 STM32 NUCLEO 开发板上，用流行的 STM32Cube 开发环境来展示 QV 和 QP/C。

Let's start today by reviewing what happened so far. In the last two lessons, #52 and #53, you've built a non-preemptive scheduler for the "superloop" with interrupts. The scheduler managed up to 32 prioritized tasks and supported a *safe* entry to the CPU low-power sleep mode.

先来回顾一下之前的进展。前两课（第 52、53 课）中，你搭建了一个带中断的超级循环非抢占式调度器。这个调度器最多能管理 32 个优先级任务，还支持安全地进入 CPU 低功耗睡眠模式。

The central element of the design was the ready_set bitmask, where each bit corresponded to a task in the system. A 1-bit represented a task ready to run, while a 0-bit represented a task not ready to run.

设计的核心是 **ready_set 位掩码**（bitmask），每一位对应系统中的一个任务。1 表示任务已就绪可以运行，0 表示还没就绪。

The scheduler was engaged in every pass through the "superloop." If the ready_set bitmask was 0, the scheduler called the go-to-sleep function, which entered the sleep mode atomically, that is, with interrupts still disabled, and had to enable interrupts internally. If ready_set was not zero, the scheduler quickly and deterministically found the highest-order 1-bit, cleared the bit, and called the corresponding task.

调度器在每一轮超级循环中都会被调用。如果 ready_set 为 0，调度器就调用休眠函数，以原子方式进入睡眠——也就是说，进去的时候中断是关着的，函数内部再打开中断。如果 ready_set 不为零，调度器会快速、确定性地找到最高位的那个 1，把它清零，然后调用对应的任务。

The tasks were one-shot, run-to-completion functions that performed some work and returned to the "superloop" without blocking or polling. This was in contrast to the traditional real-time operating system (RTOS), where tasks were "mini-superloops" that did not return and had to block internally to wait for events. This video course has a whole segment of lessons covering the traditional RTOS.

这些任务都是一次性的**运行到完成**（run-to-completion）函数——干完活就返回超级循环，不阻塞、不轮询。这跟传统 RTOS 不一样，RTOS 里的任务是"迷你超级循环"，不会返回，只能靠内部阻塞来等事件。本课程有整整一个系列专门讲传统 RTOS。

In the end, the little scheduler for the "superloop" is quite powerful for its tiny size and low complexity, but it still has shortcomings.

总的来说，这个为超级循环设计的小调度器，以它那么小的体积和那么低的复杂度来说，已经相当能打了。不过它还是有一些不足。

First, the events are signaled to the tasks by just one bit in the ready_set bitmask, so if the task hasn't had a chance to run yet, any subsequent events for that task are lost.

第一，事件只靠 ready_set 里的一bit来通知任务。如果任务还没来得及运行，后续再来事件就被丢了——之前的那个 1 还在，新事件等于白来。

Second, the bits in the ready_set bitmask don't carry any additional data, so interrupt service routines and tasks must communicate via global variables that you must adequately protect against race conditions. Also, there is no obvious way to tell which data belongs to which event.

第二，ready_set 里的 bit 不携带任何附加数据。所以中断服务程序和任务只能通过全局变量来通信，而这些全局变量你必须做好保护，防止**竞态条件**（race conditions）。而且，你也说不清楚哪份数据属于哪个事件。

And third, the tasks must run to completion and return to the "superloop" after every event, so they must somehow remember where the last event left off to pick up in the proper context for the next event. Such code quickly turns into "spaghetti" of tangled conditional logic.

第三，任务必须运行到完成，处理完一个事件就返回超级循环。所以它们得自己记住上次处理到哪了，下次接着来。这种代码写着写着就变成了纠缠不清的条件逻辑"面条代码"。

These problems are addressed in the non-preemptive QV kernel that is available in the QP/C active object framework. QV works similarly to the "superloop" scheduler but replaces the task functions with event-driven Active Objects.

这些问题在 QP/C 活动对象框架提供的非抢占式 **QV 内核**里都解决了。QV 的工作方式跟超级循环调度器类似，但它用事件驱动的**活动对象**替代了原来的任务函数。

This video course introduced the concepts of event-driven programming and Active Objects in the dedicated segments of lessons.

本课程之前有专门的系列已经介绍过事件驱动编程和活动对象的概念。

But to quickly refresh your memory, an Active Object encapsulates an event queue and a state machine. It processes the events from its queue, one at a time and to completion without blocking, which precisely matches the execution profile of the "superloop" scheduler.

简单复习一下：一个活动对象内部封装了一个**事件队列**（event queue）和一个**状态机**（state machine）。它从队列里逐个取出事件，每个事件都处理到完成，中间不阻塞——这正好就是超级循环调度器的执行特征。

The Active Object's event queue addresses the problem of losing events because the queue stores all events in the order they occurred.

活动对象的事件队列解决了事件丢失的问题——队列会按发生顺序把所有事件都存下来。

Using events instead of global variables also addresses the problem of associating data with specific events because events can carry event parameters.

用事件代替全局变量，也解决了数据跟事件关联的问题——因为事件本身就可以携带**事件参数**（event parameters）。

Finally, Active Objects in the QP frameworks have internal hierarchical state machines--the best-known "spaghetti reducers." This video course discussed state machines in the dedicated segment of lessons.

最后，QP 框架中的活动对象内部有**层次状态机**（hierarchical state machines）——号称"面条代码终结者"。本课程有专门的系列讨论过状态机。

The QV kernel still uses the ready_set bitmask, but now a ready-bit is set when an event is posted to the corresponding Active Object's event queue and cleared only after the last event is removed from the queue.

QV 内核仍然使用 ready_set 位掩码，但逻辑变了：当事件被**投递**（post）到某个活动对象的队列时，对应的就绪位置 1；只有队列里最后一个事件被取走后，这个位才清零。

So, this is the theory behind the non-preemptive QV kernel. But now, I'd like to show you how to use it in practice. For that, I'll use the STM32 NUCLEO-C031C6 board, which is one of the boards supported by this video course along with the original TivaC LaunchPad.

以上是非抢占式 QV 内核的理论部分。现在我来演示怎么实际使用它。我会用 STM32 NUCLEO-C031C6 开发板——这是本课程支持的开发板之一，跟最初的 TivaC LaunchPad 并列。

STM32 boards are typically used with the popular STM32Cube IDE, and consequently, I'll also use that IDE and demonstrate how to integrate the QP framework with the code generated by STM32CubeMX.

STM32 开发板一般都搭配流行的 STM32Cube IDE 来用，所以我也会用这个 IDE，演示如何把 QP 框架和 STM32CubeMX 生成的代码集成在一起。

In the following discussion, I assume that you already have the STM32Cube and CubeMX installed on your host computer. If not, please go to the ST.com website and get that software.

接下来的内容，我假设你已经在电脑上装好了 STM32Cube 和 CubeMX。如果还没装，去 ST.com 网站下载安装一下。

The plan for today is to start with a blank STM32Cube IDE and create an STM32 project from scratch, showing you all the steps necessary to make it into a working QP application.

今天的计划是：从一个空白的 STM32Cube IDE 开始，从零创建一个 STM32 项目，手把手带你走完把它变成一个可运行的 QP 应用所需的每一步。

However, please remember that the complete project is also available for download from the companion web page to this video course. As always, this link is provided in the video description below.

不过别忘了，完整项目也可以从本课程的配套网页下载。跟往常一样，链接在视频下方描述里。

To start, in the STM32Cube IDE click on 'Create a new STM32 project'. You'll be prompted to specify either just the microcontroller or the whole board. For this tutorial, I've chosen the NUCLEO-C031C6 board with the Cortex-M0+ CPU. Once you've selected the board, click 'Next' to proceed.

首先，在 STM32Cube IDE 里点击"Create a new STM32 project"。系统会问你选微控制器还是选整块开发板。本教程我选了搭载 Cortex-M0+ CPU 的 NUCLEO-C031C6 开发板。选好之后点"Next"。

Now, let's not use the default location but put the project in the directory lesson-54 and sub-directory stm32c031-cube.

接下来不要用默认路径，把项目放到 lesson-54 目录下的 stm32c031-cube 子目录里。

Also, let's name this project generically as "project."

项目名就随便叫"project"。

Now, you can just generate the code from these settings by clicking the "Generate Code" button in the top toolbar.

现在直接点顶部工具栏的"Generate Code"按钮，就能从这些设置生成代码。

As usual with Eclipse-based tools like the STM32Cube, it's a good idea to monitor what's happening on the disk because the project includes everything that is present in the project directory, whether you want it or not.

跟所有基于 Eclipse 的工具一样，STM32Cube 有个特点：项目目录里有什么它就全包含进来，不管你需不需要。所以盯着点磁盘上的变化是个好习惯。

Now, you can build the code by pressing the "hammer" tool in the top toolbar. The build should succeed and should create the Debug directory on the disk.

现在点顶部工具栏里的"锤子"图标来构建代码。构建应该能成功，磁盘上会多出一个 Debug 目录。

Alright. Time to connect the NUCLEO-C031C6 board to your computer and debug the code. If you're running the debugger for the first time, you might need to make sure that the Eclipse "Debug Configuration" is available.

好，接下来把 NUCLEO-C031C6 开发板连到电脑上，准备调试。如果是第一次跑调试器，可能需要先确认 Eclipse 的"Debug Configuration"已经配好。

Once the debugger launches and connects to the target, you can step through the code up to the obligatory while(1) superloop. However, the superloop is empty, so nothing visible happens even though the code runs correctly. So far, so good.

调试器启动并连上目标板之后，你可以单步走，一直到那个必不可少的 while(1) 超级循环。不过超级循环是空的，代码虽然在跑，但什么都看不到。到目前为止，一切正常。

Now, let's bring in the QP framework with the non-preemptive QV kernel, which is the subject of this video.

现在，我们把带非抢占式 QV 内核的 QP 框架引进来——这也是本视频的主题。

The Cube IDE offers multiple options to incorporate such software components into your project. For example, popular RTOSes and middleware are provided as so-called "Software Packs." The QP/C framework is also available as a "Software Pack," and the two Quantum Leaps videos demonstrate how to apply it.

Cube IDE 有好几种方式把这种软件组件集成到项目里。比如，常用的 RTOS 和中间件以"Software Pack"的形式提供。QP/C 框架也有 Software Pack 版本，Quantum Leaps 的两个视频演示了怎么用。

Another option is to symbolically link external directories to the STM32 project without copying. This option is illustrated in stm32-cube examples in the QP framework.

另一种方式是把外部目录符号链接到 STM32 项目里，不用复制文件。这种方式在 QP 框架的 stm32-cube 示例里有演示。

However, the simplest way for Eclipse projects is to literally copy all the software to the project directory, so I will show you this method.

不过对 Eclipse 项目来说，最简单粗暴的办法就是把所有文件直接复制到项目目录里。我就演示这种方式。

To get the QP/C software, you can either download the QP bundle from state-machine.com or get it from the Quantum Leaps GitHub.

要获取 QP/C 软件，你可以从 state-machine.com 下载 QP 套件，也可以去 Quantum Leaps 的 GitHub 下载。

Once on GitHub, click on the qpc repo and go to releases. From there, choose the most recent release and download the qpc ZIP archive.

进了 GitHub 之后，点 qpc 仓库，进 releases 页面。选最新版本，下载 qpc 的 ZIP 压缩包。

Now, open the archive and unzip the qpc directory into your STM32Cube project directory like this.

然后打开压缩包，把 qpc 目录解压到你的 STM32Cube 项目目录里，就像这样。

As I already mentioned, Eclipse projects automatically pick up everything present in the project directory, but to see the new qpc directory in your project you must execute the build.

前面说了，Eclipse 项目会自动把项目目录里的东西全都收进来。不过要看到新加的 qpc 目录，你得先执行一次构建。

Interestingly, the build does not compile any files from the qpc folder because this new directory is "Excluded from the build."

有意思的是，这次构建并不会编译 qpc 文件夹里的任何文件——因为这个新目录被标记为"排除在构建之外"。

So now, you need to include the specific parts of the qpc framework in your build. For today's project, you include the following qpc sub-directories, being careful to apply it for all build configurations:

所以接下来，你需要把 qpc 框架里需要的部分加入构建。对于今天的项目，要包含以下 qpc 子目录，注意要对所有构建配置都生效：

src/qf - which contains the platform-independent source code for the active object framework and hierarchical state machines;

src/qf——包含活动对象框架和层次状态机的平台无关源代码；

src/qv - which contains the platform-independent source code for the non-preemptive QV kernel;

src/qv——包含非抢占式 QV 内核的平台无关源代码；

and ports/arm-cm/qv/gnu - which contains the platform-specific code for ARM Cortex-M, QV kernel, with the GNU compiler that is used in STM32Cube.

还有 ports/arm-cm/qv/gnu——包含 ARM Cortex-M 平台上 QV 内核的平台相关代码，用的是 STM32Cube 中的 GNU 编译器。

When you try to build now, the selected qpc code is compiled, but you get errors about missing include files. That means you must add the qpc-related include paths to the compiler options.

再试构建，选中的 qpc 代码开始编译了，但会报找不到头文件的错误。这说明你还得把 qpc 相关的头文件搜索路径加到编译器选项里。

For this, go to the main project properties, C/C++ Build tab, Settings category. Here, again select "all build configurations" and choose the MCU GCC compiler tab, include-paths sub-category. Now, similarly to the existing directories in your project folder, add the following include paths: qpc/include and qpc/ports/arm-cm/qv/gnu.

做法是：打开项目属性，进 C/C++ Build 选项卡，选 Settings 类别。这里再次选"all build configurations"，然后找到 MCU GCC compiler 下面的 include-paths 子项。参照项目里已有的目录格式，添加以下两条路径：qpc/include 和 qpc/ports/arm-cm/qv/gnu。

When you trigger the build now, you can still see errors, but this time, only one qp_config.h file is reported missing. This file is not part of the QP framework but rather the QP application you have yet to add.

再触发构建，还是有错误，但这次只剩一个：找不到 qp_config.h 文件。这个文件不属于 QP 框架本身，而是你的 QP 应用程序还没加进来。

The application for today will be one of the standard examples provided in the qpc framework that you just downloaded and copied to the project. Specifically, the example is located in qpc/examples/arm-cm/real-time_nucleo-c031c6/qv.

今天用的应用程序是 qpc 框架自带的标准示例之一，就在你刚下载复制到项目里的那个 qpc 里。具体位置是 qpc/examples/arm-cm/real-time_nucleo-c031c6/qv。

Select all the files for that example, copy them to the clipboard, and paste into the Core folder in your project.

选中这个示例的所有文件，复制，然后粘贴到项目的 Core 文件夹里。

Next, adjust the file locations according to the structure established by CubeMX. Specifically, move the header files into the Inc folder and source files into the Src folder.

接下来按 CubeMX 的目录结构调整文件位置：头文件移到 Inc 文件夹，源文件移到 Src 文件夹。

For now, you just skip the new main.c file because the project already has the original main.c generated by CubeMX.

先跳过新的 main.c 文件，因为项目里已经有了 CubeMX 生成的原始 main.c。

Now, you need to merge the two main.c files. The application file consists of just a few function calls, which you copy and paste to the CubeMX main.c in the USER CODE right before the while(1) superloop.

现在你需要合并这两个 main.c。应用程序那个文件里就几个函数调用，把它们复制粘贴到 CubeMX 生成的 main.c 中 while(1) 超级循环之前的 USER CODE 区域。

This is really all needed to initialize the framework and transfer control to it because QF_run() never returns to the original superloop.

这也就是初始化框架并把控制权交给它所需的全部操作了——因为 `QF_run()` 不会再返回到原来的超级循环。

To complete the merge you still need to copy the include files into the right USER CODE section in the CubeMX main.c.

要完成合并，你还需要把 include 语句复制到 CubeMX main.c 中对应的 USER CODE 区域。

And finally, you can delete the merged main.c.

最后把已经合并过的那个 main.c 删掉就行。

Now, all files compile correctly, but the linking stage fails due to the multiple definitions of the SysTick_Handler ISR. Indeed, the QP application uses SysTick, and CubeMX has generated it, too, for internal timekeeping.

现在所有文件都能编译通过了，但链接阶段报错——SysTick_Handler ISR 有重复定义。确实，QP 应用程序要用 SysTick，而 CubeMX 也生成了一个用于内部计时。

You can reconcile this conflict by simply disabling the CubeMX code generation for the SysTick. To do this, open the project.ioc file, expand the System Core section and the NVIC sub-section. Once there, click on the Code Generation tab and uncheck the box next to Time Base System Tick Timer. As always, after making the changes, you must re-generate the CubeMX code.

解决这个冲突很简单——禁掉 CubeMX 对 SysTick 的代码生成就行。打开 project.ioc 文件，展开 System Core 部分和 NVIC 子部分，点 Code Generation 选项卡，把 Time Base System Tick Timer 旁边的勾去掉。改完之后照例要重新生成 CubeMX 代码。

I'm really not sure why the CubeMX code generator has opened all main.c files located in the qpc/examples folder because they are excluded from the build. But you can just close them all via the File menu.

我也不知道为什么 CubeMX 代码生成器会把 qpc/examples 文件夹里所有的 main.c 都打开——明明它们都被排除在构建之外了。不过没关系，直接从 File 菜单把它们关掉就行。

More importantly, your project build finally works, so you have successfully integrated a non-trivial QP application with the STM32Cube project.

更重要的是，项目终于构建成功了！你已经成功地把一个不简单的 QP 应用集成到了 STM32Cube 项目中。

I will explain this real-time application in the rest of this video, but one software development aspect I'd like to explain now is state machine modeling. Specifically, the state machine code for all active objects in this application has been generated by the QM modeling tool. You can edit this code manually and just ignore the modeling. However, if you'd like to use QM, you can adjust the code generation to the CubeMX code structure.

这个实时应用程序的具体功能我会在视频后半部分解释，但有一个软件开发方面的事想先说一下——**状态机建模**（state machine modeling）。具体来说，这个应用中所有活动对象的状态机代码都是由 QM 建模工具生成的。你完全可以手动编辑这些代码，不理会建模。但如果你想用 QM，可以调整它的代码生成方式来适配 CubeMX 的目录结构。

As you can see, currently, all files for this model are generated in the same directory (denoted as dot) as the model file, which happens to be the Src directory. However, the app.h header file should go to the Inc directory, not the Src directory.

如你所见，目前模型的所有文件都生成在与模型文件相同的目录（用点号表示）里，也就是 Src 目录。但 app.h 头文件应该放到 Inc 目录才对。

You can easily adapt the QM code generation by adding a new directory and naming it ../Inc relative to the model file. Now, you can drag-and-drop the app.h header file there. And you can also change the order of the directories.

调整很简单：添加一个新目录，名字设为相对于模型文件的 ../Inc，然后把 app.h 头文件拖过去就行了。目录的顺序也可以调。

Now you just generate code, and see that the app.h file has been re-generated. The other .c files have been all processed but were found to be unchanged, so they were not re-generated.

现在生成一下代码，就会看到 app.h 被重新生成了。其他 .c 文件也都被处理过，但发现没有变化，所以没重新生成。

But going back to the just finished successful build of the QP application, I can finally load it to the NUCLEO-C031C6 board and explain how it works.

回到刚才构建成功的 QP 应用，终于可以把它加载到 NUCLEO-C031C6 开发板上，讲解它的工作原理了。

However, I'd like to note right away that this QP application is non-trivial because it consists of multiple interacting active objects. Consequently, my explanations might seem complicated. Still, please pay attention to the details and nuances because this is the only way to truly understand any real-time scheduler at a deeper level.

不过我 upfront 先说一下：这个 QP 应用并不简单，因为它由多个相互配合的活动对象组成。所以我的讲解可能看起来有点复杂。但请耐着性子关注细节和微妙之处——要真正深入理解任何实时调度器，这是唯一的办法。

One of the main tools I'll use is the cheap USB logic analyzer and the open-source pulse-view software described on the companion web page of this video course.

我会用到的主要工具之一是便宜的 USB 逻辑分析仪和开源的 PulseView 软件，配套网页上有介绍。

If you'd like to follow along, here is how the logic analyzer is connected to the NUCLEO-C031C6 board. The numbers in the drawing are the pin numbers of the logic analyzer connector.

如果你想跟着做，这是逻辑分析仪连接 NUCLEO-C031C6 开发板的方式。图中的数字是逻辑分析仪接头的引脚编号。

So now, I reset the board and capture a free trace to see the basic behavior of this application.

现在我复位开发板，抓一段自由运行的追踪信号，看看这个应用的基本行为。

The top trace, labeled D1-SysTick shows the activity of the SysTick ISR, which turns the D1 line on upon the entry and off upon the exit.

最上面标记为 D1-SysTick 的通道显示的是 SysTick 中断服务程序的活动——进入时把 D1 线拉高，退出时拉低。

This creates a square wave that you can observe with the logic analyzer.

这就产生了一个方波，用逻辑分析仪可以看到。

The square wave repeats every 400 microseconds, which means that the SysTick ISR runs at a quite high rate of 2500 times per second.

方波每 400 微秒重复一次，也就是说 SysTick ISR 的运行频率高达每秒 2500 次。

The trace right below the SysTick labeled D3-Periodic4 corresponds to the highest-priority active object called Periodic4. As the name suggests, this AO runs periodically based on the periodic time event, which in turn is triggered from the SysTick ISR. The current period is 2 system clock ticks, but it's adjustable, as you will see later.

SysTick 下面标记为 D3-Periodic4 的通道，对应的是最高优先级的活动对象 Periodic4。顾名思义，它基于周期性**时间事件**（time event）定期运行，时间事件由 SysTick ISR 触发。当前周期是 2 个系统时钟节拍，不过可以调整，后面你会看到。

Each time the Periodic4 state machine receives the TIMEOUT event, it executes a for loop that drives the GPIO D3 line on and off for an adjustable number of toggles. This activity emulates CPU load, which you can observe as an oscillating square wave in the logic analyzer, but in real life, this could be some CPU-bound computation.

每次 Periodic4 的状态机收到 TIMEOUT 事件，就跑一个 for 循环，把 GPIO D3 线来回翻转若干次。这个动作模拟的是 CPU 负载——在逻辑分析仪上看起来就是一段振荡的方波。实际应用中，这可能就是一段 CPU 密集型的计算。

The traces labeled D4-Sporadic3 and D5-Sporadic2 correspond to the lower-priority active objects that run sporadically and have not been active in this scenario. I will explain their role later.

标记为 D4-Sporadic3 和 D5-Sporadic2 的通道对应的是优先级较低的活动对象，它们是偶发性运行的，在这个场景中还没被激活。稍后我会解释它们的作用。

The trace labeled D6-Periodic1 corresponds to the lowest-priority active object called Periodic1. It is similar to Periodic4, but toggles the GPIO D6 line and runs at a longer period of 5 system clock ticks.

标记为 D6-Periodic1 的通道对应的是最低优先级的活动对象 Periodic1。它跟 Periodic4 类似，不过翻转的是 GPIO D6 线，周期也更长，是 5 个系统时钟节拍。

Finally, the bottom trace labeled D7-idle corresponds to the idle processing of the QV kernel, which runs at the absolute lowest priority 0. As I explained in the previous lessons 52 and 53, the idle processing is entered with interrupts still disabled and must enable interrupts before returning. In the Debug build configuration the function does not enter the low-power sleep mode, but it will do it in the Release configuration, which I will demonstrate later.

最底下标记为 D7-idle 的通道对应的是 QV 内核的**空闲处理**（idle processing），运行在绝对的最低优先级 0 上。正如前两课讲的，空闲处理进入时中断还是关着的，必须在返回前打开中断。在 Debug 构建配置下，这个函数不会进入低功耗睡眠模式；Release 配置下才会，稍后我会演示。

The QV_onIdle function drives the GPIO D7 line high upon the entry and low right before the exit, so each spike in the logic analyzer view represents one call to the function.

`QV_onIdle` 函数进入时把 GPIO D7 线拉高，退出前拉低。所以逻辑分析仪上看到的每一个尖峰，就是一次函数调用。

Now, let's trigger a more interesting behavior of this application. For that, set the trigger to the falling edge on the D0-Button line and start the logic analyzer. This time, the trace will be triggered only when you press the blue user button.

现在来触发一个更有意思的场景。把触发条件设为 D0-Button 线的下降沿，然后启动逻辑分析仪。这次只有按下蓝色用户按钮才会触发采集。

Alright, so let me explain what's going on now. Again, the details of this are important to understand how the kernel works and also how active objects handle events.

好，来解释一下现在发生了什么。再说一遍，这些细节对于理解内核的工作方式以及活动对象怎么处理事件非常重要。

This scenario begins with detecting the button press in the SysTick ISR, which includes a switch debouncing code. That algorithm detects a reliable switch closure after seeing the changed GPIO input for two samples in a row.

场景从 SysTick ISR 检测到按钮按下开始。ISR 里包含了**开关消抖**（switch debouncing）代码——这个算法要连续两次采样都检测到 GPIO 输入变化，才确认是一次可靠的开关闭合。

Upon detecting a button press, the code posts the two immutable SPORADIC events to the Sporadic2 active object.

确认按键后，代码向 Sporadic2 活动对象投递两个不可变的 SPORADIC 事件。

After the SysTick ISR completes, it returns to the idle callback, which returns to the superloop. At this point, the QV scheduler is engaged and finds out that Sporadic2 active object has events in its queue, so it dispatches the first event from the queue to the Sporadic2 state machine.

SysTick ISR 结束后返回到空闲回调，空闲回调再返回到超级循环。这时 QV 调度器开始工作，发现 Sporadic2 活动对象的队列里有事件，于是把队列中的第一个事件**分派**（dispatch）给 Sporadic2 的状态机。

That state machine handles the event by re-posting it to the higher-priority Sporadic3.

那个状态机处理这个事件的方式是：把它重新投递给更高优先级的 Sporadic3。

The QV scheduler is engaged again and finds out that both Sporadic2 and Sporadic3 have events, but Sporadic3 is higher-priority, so the scheduler dispatches the event to the Sporadic3 state machine.

QV 调度器再次工作，发现 Sporadic2 和 Sporadic3 都有事件，但 Sporadic3 优先级更高，于是把事件分派给 Sporadic3 的状态机。

That state machine handles the SPORADIC_A event by first posting a special PERIODIC event to the Periodic4 active object, and then emulating some CPU load in form of a for-loop toggling the GPIO D4 line.

Sporadic3 的状态机处理 SPORADIC_A 事件：先向 Periodic4 活动对象投递一个特殊的 PERIODIC 事件，然后跑一个 for 循环翻转 GPIO D4 线来模拟 CPU 负载。

The logic analyzer trace illustrates an important property of this scheduler, which is technically called priority inversion. Specifically, event posting to the high-priority Periodic4 active object makes it ready to run at this instance, but due to the simplistic non-preemptive nature of the scheduler, the lower-priority Sporadic3 keeps running until it finishes its run-to-completion step.

逻辑分析仪的波形展示了这个调度器的一个重要特性，技术上叫**优先级反转**（priority inversion）。具体来说，给高优先级的 Periodic4 投递事件意味着它此刻已经就绪了，但由于调度器是非抢占式的，低优先级的 Sporadic3 会一直运行到完成，不会被打断。

Only after that, the scheduler is engaged again and the high-priority Periodic4 processes the enqueued event.

只有 Sporadic3 跑完之后，调度器才再次被调用，高优先级的 Periodic4 才能去处理队列里的事件。

The processing consists here of changing the period of the time event and also the number of toggles emulating the CPU load incurred by the Periodic4 active object.

这里的处理内容是：更改时间事件的周期，以及 Periodic4 用来模拟 CPU 负载的翻转次数。

Indeed, after that event, Periodic4 receives the time event every tick, while before, it received it only every other tick.

效果很明显：这个事件之后，Periodic4 每个节拍就收到一次时间事件，而之前是隔一个节拍才收到一次。

However, this is not the end yet because Sporadic2 has still an event waiting in its queue.

不过还没完——Sporadic2 的队列里还有一个事件在等着。

So now, the scheduler dispatches this event to the Sporadic2 state machine.

调度器把这个事件分派给 Sporadic2 的状态机。

This is SPORADIC type B event, so its processing consists of posting a special PERIODIC event to the lowest-priority Periodic1 active object and then some CPU load in form of the usual for-loop.

这次是 SPORADIC B 类型事件，处理方式是：向最低优先级的 Periodic1 活动对象投递一个特殊的 PERIODIC 事件，然后用老办法跑个 for 循环产生 CPU 负载。

This lengthy processing in Sporadic2 is interrupted by SysTick, which posts two time events to Periodic4 and Periodic1. But in this non-preemptive scheduler, the interrupt always returns to the originally interrupted task, so Sporadic2 continues.

Sporadic2 这段较长的处理被 SysTick 中断了，SysTick 向 Periodic4 和 Periodic1 各投递了一个时间事件。但在这个非抢占式调度器里，中断总是返回到被打断的那个任务，所以 Sporadic2 继续。

This is another example of priority inversion because the high-priority Periodic4 is ready to run but must wait for the completion of the lower-priority Sporadic2.

这又是一个优先级反转的例子——高优先级的 Periodic4 已经就绪，但必须等低优先级的 Sporadic2 跑完。

So, only after Sporadic2 is done the high-priority Periodic4 is scheduled.

所以只有 Sporadic2 做完之后，高优先级的 Periodic4 才能被调度。

Finally, the lowest-priority Periodic1 is scheduled twice in a row to process the two remaining events.

最后，最低优先级的 Periodic1 被连续调度两次，处理剩下的两个事件。

When all events are processed, the scheduler goes back to calling the QV_onIdle callback.

所有事件都处理完毕后，调度器回到调用 `QV_onIdle` 回调函数。

But speaking of the idle processing, I still promised to demonstrate the low-power sleep mode.

说到空闲处理，我之前还承诺过要演示**低功耗睡眠模式**（low-power sleep mode）。

For this, you must define the NDEBUG macro to enable the CPU-SLEEP code in the QV_onIdle callback. Let's do it only in the Release build configuration and thus leave the Debug configuration unchanged.

为此你需要定义 NDEBUG 宏，启用 `QV_onIdle` 回调里的 CPU-SLEEP 代码。我们只在 Release 构建配置里这么做，Debug 配置保持不变。

Now, let's build the Release configuration.

现在来构建 Release 配置。

Before uploading this code to the NUCLEO board, you need to make sure that you use the Release build.

上传到开发板之前，先确认你用的是 Release 构建。

If you do this the first time, the Release debug configuration is missing, and you must create it.

第一次做的话，Release 的调试配置可能还没有，你得手动创建一个。

Now, you can finally upload the board.

现在终于可以上传到开发板了。

Reset the board... and start the logic analyzer.

复位开发板……启动逻辑分析仪。

As you can see, the idle trace is not toggling anymore, meaning that the QV_onIdle function is called much less frequently, thus not wasting as many CPU cycles.

可以看到，空闲通道不再频繁翻转了——这意味着 `QV_onIdle` 被调用的次数大大减少，不再浪费那么多 CPU 周期。

Moreover, most of the time the line is high, meaning that the system is inside the QV_onIdle function.

而且大部分时间信号线都保持高电平，说明系统大部分时间都待在 `QV_onIdle` 函数里。

Also, the interrupts preempt the "superloop" inside the QV_onIdle function, and the function returns only *after* the interrupt. Then the system processes the posted event and calls QV_onIdle() again.

中断仍然会抢占 `QV_onIdle` 函数内部的超级循环，函数要等中断处理完才返回。然后系统处理投递的事件，再重新调用 `QV_onIdle()`。

However, even though the idle behavior of the system is completely different, the active objects behave exactly the same.

不过，虽然系统的空闲行为完全变了，活动对象的行为却跟之前一模一样。

For example, here is the button press scenario again.

比如，这里是按钮按下场景的重现。

The only difference is that the code runs now a bit faster because the Release build configuration uses higher compiler optimization than the Debug configuration before.

唯一的区别是代码跑得更快了——因为 Release 配置的编译器优化级别比之前的 Debug 配置更高。

This concludes this lesson about the non-preemptive QV kernel, which is the second example of a real-time kernel suitable for Active Objects. The first was the traditional real-time operating system (RTOS), presented in lesson 34, where you saw a rudimentary Active Object framework called uC/AO, built around uC/OS RTOS tasks structured as event loops. You can also check out another version of such a framework, built around FreeRTOS, called FreeACT.

关于非抢占式 QV 内核的课就到这里。QV 是适合活动对象的第二种实时内核。第一种是第 34 课讲的传统 RTOS，在那节课里你看到了一个基础的活动对象框架叫 uC/AO，它基于 uC/OS RTOS 任务，以事件循环的方式组织。另外还有一个基于 FreeRTOS 的类似框架叫 FreeACT，你也可以去看看。

However, the options for executing Active Objects don't end here. In the following lessons, I will present yet another real-time kernel type for Active Objects, which is preemptive and fully compatible with Rate-Monotonic Scheduling/Analysis (RMA/RMS) methods introduced in lesson 26.

不过，执行活动对象的选择不止这些。接下来的课程中，我会介绍第三种实时内核——它是抢占式的，而且完全兼容第 26 课讲过的**速率单调调度/分析**（Rate-Monotonic Scheduling/Analysis, RMA/RMS）方法。

If you like this video, please subscribe to stay tuned. This channel is getting really close to the very round number of 2-to-16th subscribers, so please help to break the 16-bit barrier!

如果你喜欢这个视频，请订阅关注。这个频道的订阅数马上就要到 2 的 16 次方这个整数了——请大家帮忙冲破这个 16 位壁垒！

Finally, as always, all discussed projects are available for download from the companion web page and the dedicated GitHub repo.

最后照例提醒一下，所有讨论的项目都可以从配套网页和专门的 GitHub 仓库下载。

Thanks for watching!

感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Non-preemptive scheduler | 非抢占式调度器 | 当前运行的任务不会被更高优先级的任务打断，必须运行到完成 |
| Superloop | 超级循环 | 嵌入式系统中常见的 while(1) 无限循环主程序结构 |
| ready_set bitmask | ready_set 位掩码 | 用位图表示各任务就绪状态，每一位对应一个任务 |
| Run-to-completion | 运行到完成 | 从开始执行到完成，中间不被抢占也不阻塞 |
| Active Object | 活动对象 | 封装了事件队列和状态机的并发模型，通过事件驱动执行 |
| QV kernel | QV 内核 | QP/C 框架中的非抢占式内核，专为活动对象设计 |
| QP/C framework | QP/C 框架 | Quantum Platform 的 C 语言实现，专业的活动对象框架 |
| Event queue | 事件队列 | 活动对象中存储待处理事件的数据结构 |
| Event parameters | 事件参数 | 事件携带的附加数据 |
| Hierarchical state machine | 层次状态机 | 支持状态嵌套的状态机，能有效减少代码复杂度 |
| State machine modeling | 状态机建模 | 用图形化工具（如 QM）设计和生成状态机代码 |
| Priority inversion | 优先级反转 | 高优先级任务因等待低优先级任务完成而被延迟的现象 |
| Low-power sleep mode | 低功耗睡眠模式 | CPU 空闲时进入的低功耗状态 |
| Switch debouncing | 开关消抖 | 消除机械开关抖动导致的多次触发 |
| Time event | 时间事件 | 由系统定时器触发的周期性或一次性事件 |
| Dispatch | 分派 | 调度器将事件从队列取出交给状态机处理 |
| Post (event) | 投递（事件） | 将事件放入目标活动对象的事件队列 |
| Rate-Monotonic Scheduling (RMS) | 速率单调调度 | 固定优先级调度策略，周期短的任务优先级高 |
| Race condition | 竞态条件 | 多个执行流并发访问共享资源导致的不确定行为 |
| ISR (Interrupt Service Routine) | 中断服务程序 | 响应硬件中断而执行的函数 |
| STM32CubeMX | STM32CubeMX | ST 公司的图形化配置工具，用于初始化 STM32 项目 |
| Software Pack | 软件包 | STM32Cube IDE 中集成第三方组件的机制 |
| QM modeling tool | QM 建模工具 | Quantum Leaps 提供的图形化状态机建模和代码生成工具 |
