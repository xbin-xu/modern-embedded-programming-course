# 第46课：实时软件追踪——QP/Spy追踪系统 / Lesson 46: Real-Time Software Tracing — QP/Spy

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek, and in this lesson, I'll continue the subject of software tracing. Today, you'll see a mature software tracing system called QP/Spy, which is much more suitable for real-time embedded software than the primitive printf-debugging from last time.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，今天我们继续聊**软件追踪**（software tracing）的话题。这次你会看到一个成熟的软件追踪系统——**QP/Spy**，比起上节课那种原始的 printf 调试方式，它才真正适合实时嵌入式软件。

As usual, let's get started today by copying the previous lesson 45 to lesson 46. Get inside the lesson 46 directory and double-click on the project lesson to open it in the uVision IDE.

照例，先把上一课的 lesson-45 复制一份变成 lesson-46。进入 lesson-46 目录，双击项目文件，在 uVision IDE 中打开。

To remind you quickly what has happened so far, in the last lesson, you added the MY_PRINTF() instrumentation to your code to generate some real-time information about the code execution.

快速回顾一下上节课做了什么：你在代码里加了 `MY_PRINTF()` **探针**（instrumentation），用来生成一些代码执行的实时信息。

The printf software tracing seems to do the job, and everybody uses it.

printf 软件追踪看起来确实能用，大家也都这么干。

But the approach is very intrusive. For example, this simple printout took almost 800 microseconds, and the overhead occurred in the interrupt context.

但这种方法**侵入性**太强了。比如这么简单的一行输出就花了将近 800 微秒，而且开销还发生在中断上下文里。

These three simple printouts produced in quick succession took over 3 milliseconds, and again they occurred in the time-critical path through the code.

这三个连续的简单输出加起来超过 3 毫秒，而且同样出现在代码的**时间关键路径**（time-critical path）上。

So, while software tracing is immensely useful and indeed indispensable, printf-style tracing is NOT the smartest way to go about it. The main problem is that this approach combines the production of the tracing data and sending it out (over UART, the ITM, or some other mechanism), which is very time-consuming.

所以，软件追踪确实非常有用，甚至可以说是不可或缺的，但用 printf 来做追踪并不是最聪明的办法。**核心问题是：它把"产生追踪数据"和"把数据发出去"（通过 UART、ITM 或其他机制）这两件事搅在一起了**，而发送数据非常耗时。

To help you realize what's happening here, imagine a fire truck racing to an emergency. This would correspond to your time-critical path through the code.

打个比方，帮你理解这是怎么回事：想象一辆消防车正赶往火灾现场——这就对应你代码中的时间关键路径。

But instead of fighting the blaze and rescuing the victims, the fireman starts... filing a situation report to his boss, which takes him an hour. This is what software tracing is and how a millisecond feels to a modern CPU.

但消防员到了之后没有去灭火救人，而是开始……写情况报告交给领导，一写就是一个小时。用 printf 做追踪就跟这差不多，一毫秒对现代 CPU 来说就是这种感觉。

To make it even more ridiculous, the report that the fireman is producing is not in his native language, like, say, English. No, the report is in a foreign language, such as Chinese, so the poor fireman must painstakingly translate every word.

更荒谬的是，消防员写报告还不是用自己的母语（比如英语），而是用一门外语（比如中文），所以可怜的消防员还得费劲地把每个词都翻译一遍。

This is how it is for the CPU to produce a foreign, human-readable printf-output formatted into ASCII characters, as opposed to the native, binary format.

这就是 CPU 用 printf 生成人类可读的 ASCII 文本输出时的感受——明明可以直接用原生的二进制格式，非得翻译成"外语"。

All this seems ridiculous, but this is precisely what happens in the printf-method.

听起来很荒唐对吧？但这正是 printf 方法的真实写照。

Please note that the report itself is not the absurd part. We all understand that a report is useful, just like software tracing is. But it is foolish to do this when something much more urgent needs attention.

注意，报告本身并不是荒谬的部分——我们都知道报告有用，就像软件追踪有用一样。荒谬的是在还有更紧急的事情要处理时，却在那写报告。

A better solution would be for a firefighter to wear body cameras to capture the details with minimal distraction. Then, later, after the emergency, the fireman could inspect the recorded footage and submit his report.

更好的方案是什么？让消防员戴上随身摄像头，用最小的干扰把现场情况录下来。等紧急情况处理完了，再慢慢看录像、写报告。

And, of course, the report should be in the native language of the fireman so that he won't waste his time on translation.

当然，报告应该用消防员的母语来写，别再浪费时间翻译了。

This analogy lays out the general structure of a more reasonable software tracing strategy:

这个比喻其实就勾勒出了一个更合理的软件追踪策略的总体思路：

The tracing information should be recorded quickly in native binary into a memory buffer inside the microcontroller. This takes only microseconds, which is important because it happens in the time-critical path through the code.

追踪信息应该以原生二进制格式快速记录到微控制器内部的内存缓冲区里。这只需要几微秒——非常关键，因为它发生在代码的时间关键路径上。

On the other hand, the slow process of sending the tracing information to the host, which takes milliseconds, must be decoupled from recording the tracing data and occur when the CPU has nothing else to do.

另一方面，把追踪信息发送到主机是个慢活儿，要花毫秒级的时间。这个过程必须跟数据记录**解耦**（decouple），等 CPU 没别的事可做时再执行。

To this end, most real-time kernels have a notion of an "idle thread," which you first saw in lesson #25 about the RTOS. The scheduler performs a context switch to the idle thread when all application threads have done their job and are waiting for more work. This is the ideal place to send the tracing data to the host.

为此，大多数实时内核都有一个"**空闲线程**"（idle thread）的概念——你最早在第 25 课讲 RTOS 的时候见过。当所有应用线程都干完活了、在等新任务时，调度器就会切换到空闲线程。这正是发送追踪数据给主机的理想时机。

The scheduler used in your current project is much simpler than a full-blown RTOS, and I will talk about such event-driven schedulers in future lessons. But for now, the important thing is that this simple scheduler, called QV, can also detect when the system becomes idle. In that case, it calls the QV_onIdle() callback function, precisely what you need to send the tracing data.

你当前项目用的调度器比完整的 RTOS 简单得多，以后我会专门讲这种事件驱动调度器。现在你只需要知道，这个叫 **QV** 的简单调度器同样能检测到系统空闲。空闲时它会调用 `QV_onIdle()` 回调函数——这正是你用来发送追踪数据的地方。

Alright, with this introduction, let me show you a real-time software tracing system called QP/Spy that works as I've just described. I will start by replacing MY_PRINTF with QP/Spy and then demonstrate how the whole system works. After this, I'll peek under the hood to explain the main elements.

好，介绍完了背景，现在让我给你展示一个叫做 **QP/Spy** 的实时软件追踪系统——它的工作方式就是刚才说的那样。我会先用 QP/Spy 替换掉 `MY_PRINTF`，然后演示整个系统怎么运作。之后再深入底层，讲解它的主要组成部分。

The QP/Spy tracing is already built into the QP/C framework you've been using for several lessons, so you don't need to include any additional header files.

QP/Spy 追踪已经内置在你用了好几课的 QP/C 框架里了，不需要额外包含任何头文件。

But, just like in the simple tracing system from last time, the QP/Spy instrumentation is normally inactive. You typically activate it only in the Spy build configuration introduced in the previous lesson. Similarly to last time, you need to define a preprocessor macro to activate the instrumentation. In this case, the macro is Q_SPY.

不过跟上节课的简单追踪系统一样，QP/Spy 的探针默认是不启用的。通常你只在上节课引入的 **Spy 构建配置**里才激活它。跟上次类似，你需要定义一个预处理宏来启用探针——这次的宏是 `Q_SPY`。

Now, you need to replace the MY_PRINTF() macros with the Q-Spy equivalents. Here, you no longer use the format string because you insert the raw binary data directly into the internal memory buffer by calling the appropriate macros.

接下来，把 `MY_PRINTF()` 宏替换成 Q-Spy 的对应版本。这里不再用格式字符串了，而是通过调用相应的宏，把原始二进制数据直接塞进内部内存缓冲区。

For example, to output a string, you use the macro QS_str(), and to output a uint8_t value, the macro QS_u8(). Other macros of this type are available for other data types.

比如，输出字符串用 `QS_str()` 宏，输出 `uint8_t` 值用 `QS_u8()` 宏。其他数据类型也各有对应的宏。

The whole trace record, as it is called in QS, is surrounded by the macros QS_BEGIN_ID() and QS_END(). The parameters in the QS_BEGIN_ID macro are used for run-time filtering, which I'll explain later.

在 QS 里，一整条**追踪记录**（trace record）由 `QS_BEGIN_ID()` 和 `QS_END()` 两个宏包裹起来。`QS_BEGIN_ID` 宏的参数用于运行时过滤，后面再细说。

Alright, so now I just replace all the other MY_PRINTF() instances with the equivalent QS trace records.

好，现在把其余所有 `MY_PRINTF()` 都替换成对应的 QS 追踪记录。

The next step is the board-specific code for software tracing initialization and sending the data to the host. This is equivalent to the last lesson's board-specific my_printf_init() and fputc() implementations.

下一步是板级相关的代码：软件追踪初始化和向主机发送数据。这部分对应上节课的 `my_printf_init()` 和 `fputc()` 实现。

Here, I delete the PRTINF code and paste the new Q-Spy code.

我把旧的 PRINTF 代码删掉，贴上新的 Q-Spy 代码。

The most significant difference in the code for Q-Spy is that you must provide a tracing buffer in RAM, which you then pass to the Q-Spy function QS_initBuf().

Q-Spy 代码最大的不同是：你必须在 RAM 中提供一个**追踪缓冲区**（tracing buffer），然后把它传给 Q-Spy 的 `QS_initBuf()` 函数。

Also, compared to the simple PRITNF() from last time, Q-Spy provides more functionality. For example, Q-SPY implements data input for receiving commands from the host. This also requires a small buffer in RAM, a UART interrupt to timely handle the received data, and the callback functions to handle the target reset and various commands.

另外，跟上节课那个简单的 `PRINTF()` 相比，Q-Spy 功能更丰富。比如它支持数据输入，可以接收主机发来的命令。这也需要在 RAM 里准备一个小缓冲区、一个 UART 中断来及时处理接收到的数据，再加上处理目标复位和各种命令的回调函数。

Additionally, Q-SPY provides a precise time-stamp based on a hardware timer, which you need to initialize and read in the QS callback function.

此外，Q-Spy 还提供基于硬件定时器的精确**时间戳**（time-stamp），你需要在 QS 回调函数里完成定时器的初始化和读取。

As I explained before, the most time-consuming job of sending the tracing data to the host should be done in the idle thread of the underlying real-time kernel. In this case, you are using one of the built-in kernels in the QP framework, called QV. I will explain this and other kernels in future lessons. But for now, it's only important that QV also supports the idle callback.

前面说过，发送追踪数据这个最耗时的活儿应该在底层实时内核的空闲线程里完成。你现在用的是 QP 框架内置的内核之一——**QV**。其他内核以后再讲，现在你只需要知道 QV 也支持空闲回调就行了。

So, you place there code similar to what you used for sending bytes over the UART in the last lesson. The critical difference is that now you only send the bytes when the UART is ready and you no longer busy-wait for the UART to become ready.

所以在那里放上跟上次通过 UART 发送字节类似的代码。关键区别是：现在只在 UART 就绪时才发送字节，不再**忙等**（busy-wait）UART 变成就绪状态。

Because you now access the UART registers in the idle callback, you need to move the definitions of the registers and data bits to the top of the file.

因为现在要在空闲回调里访问 UART 寄存器，所以得把寄存器和数据位的定义挪到文件顶部。

Finally, you need to replace the MY_PRINTF_INIT() macro with QS_INIT(), and to actually see your user-defined trace records, you need to enable them in the QS global filter.

最后，把 `MY_PRINTF_INIT()` 宏替换成 `QS_INIT()`。要真正看到你自定义的追踪记录，还需要在 QS 的**全局过滤器**（global filter）里启用它们。

So, this is about it for the BSP-dot-c file, so let's try to build the project.

BSP.c 文件就改到这里，来试着构建一下项目吧。

The compilation error is about the old my_printf tracing that was still inserted in the main-dot-c file. But this file has been automatically generated by the QM modeling tool, so let's make the changes in the model and re-generate the code.

编译报错，说 main.c 里还残留着旧的 `my_printf` 追踪代码。但这个文件是 **QM 建模工具**自动生成的，所以得回到模型里改，再重新生成代码。

For that, you can go to today's lesson-46 folder and double-click on the TimeBomb-dot-qm model file to open it in QM.

打开今天的 lesson-46 文件夹，双击 `TimeBomb.qm` 模型文件，在 QM 里打开。

Next, you double-click on the TimeBomb class and open the state diagram. Once there, you click on the "boom" state and add the QS trace record to the entry action.

双击 TimeBomb 类打开状态图，点击"boom"状态，把 QS 追踪记录加到**入口动作**（entry action）里。

Finally, you re-generate the code, close QM, and re-load the changed main-dot-c file in the uVision editor.

然后重新生成代码，关掉 QM，回到 uVision 编辑器刷新 main.c。

When you try to build the project now, you still get errors but these are linker errors about missing Q-Spy facilities.

再试一次构建，还是有错——不过这次是链接错误，说找不到 Q-Spy 的组件。

To fix that, you need to add Q-Spy source code to your project.

要解决这个问题，得把 Q-Spy 的源代码加到项目里。

The simplest way is to create a new group, name it QS, and add existing files to it. The files are located in the qpc framework, src folder, qs sub-directory. You need to select all the files there.

最简单的办法：新建一个分组，取名叫 QS，然后把已有文件加进去。文件在 qpc 框架的 src 目录下的 qs 子目录里，全选即可。

As you are at it, the QS group is only needed in the Spy build configuration and should NOT be included in the Debug build configuration.

顺手说一下，QS 分组只在 Spy 构建配置里才需要，Debug 构建配置里不应该包含它。

Here is how you can do this in the uVision IDE: You need to switch to a given configuration, like dbg in this case, right-click on the group and open the Options for Group pop-up menu, and uncheck the box "Include in Target Build".

在 uVision IDE 里怎么操作呢：先切换到对应的配置（比如这里的 dbg），右键点击分组，弹出"Options for Group"菜单，取消勾选"Include in Target Build"。

Notice that the QS group icon and all files in it have a red adornment to show that they are excluded from the dbg build configuration.

你会看到 QS 分组图标和里面所有文件都多了一个红色标记，表示它们被排除在 dbg 构建配置之外了。

But that embellishment disappears when you switch back to the Spy configuration.

切回 Spy 配置后，红色标记就消失了。

Alright then, try to build again. And... what do you know, the project builds cleanly.

好，再构建一次。这次干干净净，编译通过了。

Let's download this on your TivaC LaunchPad board and first see how the tracing output looks in the generic serial terminal, the same one you used in the last lesson with MY_PRINTF.

把程序下载到 TivaC LaunchPad 板子上，先用上次用 `MY_PRINTF` 时那个通用串口终端看看追踪输出长什么样。

Well, there is clearly some output produced, but it looks like garbage in the standard serial terminal. Actually, you should have expected that because the Q-Spy output is in binary, not in a human-readable format.

确实有输出，但在标准串口终端里看起来就是一堆乱码。其实你应该能想到——Q-Spy 输出的是二进制数据，不是人能直接读的格式。

To correctly parse the binary Q-Spy data and display it in human-readable format, you need a special program called QSPY, which is similar to a standard serial terminal, like Termite.

要正确解析二进制 Q-Spy 数据并以人类可读的格式显示出来，需要一个专门的程序叫 **QSPY**——它跟 Termite 那种标准串口终端类似。

You can get it from Quantum Leaps GitHub, the QTools repository containing QSPY and other useful software tools. The pre-built executables are available in the Releases section, where you can download QTools for your host operating system.

去 Quantum Leaps 的 GitHub 上找 QTools 仓库，里面就有 QSPY 和其他好用的工具。Releases 页面提供预编译好的可执行文件，下载适合你操作系统的版本就行。

Assuming that you've downloaded release for Windows, go to the directory where you've unzipped QTools, step into the bin sub-directory and copy the path to the clipboard.

假设你下载了 Windows 版，进入解压后的 QTools 目录，进到 bin 子目录，把路径复制到剪贴板。

Now, close the standard Termite terminal and open a command-prompt, type cd and paste the QTools-bin directory.

关掉 Termite 终端，打开命令提示符，输入 `cd` 粘贴 QTools 的 bin 目录路径。

Finally, type qspy -c COM-port number of the virtual COM port of your TivaC board. To find out which COM port that is, you can open Windows Device Menager.

最后输入 `qspy -c` 加上 TivaC 板子的虚拟 COM 端口号。不确定是哪个端口的话，打开 Windows 设备管理器看一下。

Now, reset the board and watch the output produced in QSPY.

好了，复位开发板，看 QSPY 里的输出。

Press the SW1 switch and watch the TimeBomb count down and finally "explode".

按下 SW1 开关，看 TimeBomb 倒计时，最后"爆炸"。

As you can see, the Q-Spy tracing output is equivalent to that produced before with MY-PRINTF, except now you have additionally a precise time-stamp of each Q-Spy trace record.

如你所见，Q-Spy 的追踪输出跟上节课用 `MY_PRINTF` 的输出是等价的，不过现在每条追踪记录还多了一个精确的时间戳。

But the true advantage is in the real-time performance of the Q-Spy tracing. To illustrate that, let's use the logic analyzer. But to get more information, let's add toggling of a test pin to the code.

但真正的优势在于 Q-Spy 追踪的实时性能。为了直观展示这一点，上逻辑分析仪。不过为了获取更多信息，先在代码里加一个测试引脚的翻转。

Specifically, inside the SysTick_Handler ISR, turn the test-pin-1 high right before the Q-Spy trace record and turn it back low right after. Please note that test-pin-0 is already turned high upon the entry to the ISR and turned low upon the exit.

具体来说，在 `SysTick_Handler` 中断服务程序里，在 Q-Spy 追踪记录之前把 test-pin-1 拉高，记录完立刻拉低。注意 test-pin-0 已经在进入 ISR 时拉高、退出时拉低了。

Re-build the code and re-load the board.

重新编译，重新下载到板子上。

Reset the board and watch again the QSPY output.

复位开发板，再看 QSPY 的输出。

Press the SW1 button and watch the output.

按下 SW1 按钮，观察输出。

In the logic analyzer view, zoom out and find the clock tick that produced the SW1 trace record. You can recognize it by the spike on test-pin-1.

在逻辑分析仪视图中缩小画面，找到产生 SW1 追踪记录的那个时钟节拍——通过 test-pin-1 上的尖峰来辨认。

Now, I zoom in and measure the total SysTick_ISR execution time on test-pin-0, which is... 13.2 microseconds. Out of this, the generation of the Q-Spy trace record took 8.8 microseconds.

放大，测量 test-pin-0 上整个 `SysTick_ISR` 的执行时间……13.2 微秒。其中生成 Q-Spy 追踪记录花了 8.8 微秒。

This needs to be compared to the same SW1 button change output produced by PRINTF, which took 0.799 milliseconds, which is 799 microseconds -- almost 100 times longer.

对比一下，同样一条 SW1 按钮变化的输出，用 PRINTF 要花 0.799 毫秒，也就是 799 微秒——**慢了将近 100 倍**。

Alright, so the microsecond-level real-time performance of the Q-Spy tracing means that the approach is indeed much less intrusive on your system than PRINTF.

所以，Q-Spy 追踪的微秒级实时性能说明，它对系统的侵入性确实比 PRINTF 小得多。

But this is just the tip of the iceberg of the Q-Spy capabilities because, thus far, you have only seen your own tracing instrumentation added in the form of application-specific trace records.

但这只是 Q-Spy 能力的冰山一角。到目前为止，你看到的只是自己手动加的应用级追踪记录。

However, the QP framework also has its own internal instrumentation that produces the "predefined trace records", which are even more efficient than the application-specific records.

而 QP 框架本身也内置了探针，会产生"**预定义追踪记录**"（predefined trace records）——比应用级的记录效率更高。

You see, software tracing is particularly powerful in combination with the event-driven paradigm because of the inherent inversion of control. Just think about it, an event-driven infrastructure, such as the QP framework, controls the application, not the other way around. This means that almost all interesting interactions in the system must go through the framework.

你看，软件追踪跟事件驱动范式搭配起来特别强大，因为事件驱动天生就有**控制反转**（inversion of control）。想想看：像 QP 框架这样的事件驱动基础设施，是它在控制应用程序，而不是反过来。这意味着系统中几乎所有有意义的交互都必须经过框架。

The framework is then like a funnel providing an obvious opportunity to be instrumented to output detailed tracing information about the application's behavior. This is all without any tracing instrumentation of your application code.

框架就像一个漏斗——在那里加探针，就能输出应用程序行为的详细追踪信息。而且完全不需要在你的应用代码里加任何追踪语句。

Of course, this is not entirely new, and traditional RTOSes have been instrumented for tracing applications as well. But an RTOS does not work on the principle of control inversion so it can only provide information about tasks, semaphores, and other such blocking mechanisms.

当然这也不是什么全新的概念，传统 RTOS 也做过类似的追踪插桩。但 RTOS 不基于控制反转原则工作，所以它只能提供任务、信号量之类的阻塞机制的信息。

In contrast, an event-driven framework "knows" about event-driven elements, such as every state machine in your application. This is something that an RTOS doesn't know.

相比之下，事件驱动框架"知道"事件驱动的元素——比如你应用中的每一个**状态机**（state machine）。这是 RTOS 根本不了解的。

In fact, let me just demonstrate the tracing of state machines by enabling the pertaining pre-defined trace records inside QP.

来，让我演示一下——在 QP 里启用状态机相关的预定义追踪记录。

Re-build the project and load it onto the board.

重新编译，下载到板子上。

Open qspy as before, and press reset on the board.

像之前一样打开 qspy，复位开发板。

Next, press SW1.

按下 SW1。

As you can see, the tracing output still contains the application-specific user records, but now it also includes the new trace records, such Dispatch, St-Exit, St-Entry, Tran, etc.

可以看到，追踪输出里还是有你的应用级记录，但现在多了不少新记录——Dispatch、St-Exit、St-Entry、Tran 等等。

These are apparently state-machine activities, but the associated data is rather cryptic, although you should recognize the RAM and ROM memory addresses.

这些显然是状态机的活动，但附带的原始数据看起来很晦涩——虽然你应该能认出其中的 RAM 和 ROM 地址。

Well, this is the native binary information sent from the embedded board. To present the data more user-friendly, the Q-Spy software system needs symbolic information, just like a traditional single-step debugger.

没错，这就是从板子上发出来的原生二进制信息。要让人能看懂，Q-Spy 软件系统需要**符号信息**（symbolic information）——就像传统的单步调试器一样。

Obviously, this problem is not specific to Q-Spy, and most software tracing systems have to solve it one way or another. A few approaches that I found are based on extracting format-strings from the tracing instrumentation in the source code.

这个问题当然不是 Q-Spy 独有的，大部分软件追踪系统都得想办法解决。我见过的一些做法是从源代码的追踪语句里提取格式字符串。

For example, the software tracing system called "Trice" uses a special pre-compile tool written in the Go language to modify the tracing macros in the source code and to extract the format-strings. That information is subsequently used in the trice host utility, which then pefroms printf-like formatting on the host machine.

比如有个叫"Trice"的追踪系统，用 Go 语言写了一个专门的预编译工具，修改源代码里的追踪宏，把格式字符串提取出来。这些信息随后在 trice 主机端工具中使用，在主机上做类似 printf 的格式化。

Another real-time tracing approach presented at the recent CppNow conference also extracts format-strings from the tracing instrumentation but applies modern C++ with templates and tools written in Python to extract the strings and replace them with hash-values.

还有一个在最近的 CppNow 会议上展示的实时追踪方案，也是从追踪语句里提取格式字符串，不过用的是现代 C++ 模板加 Python 工具，把字符串提取出来替换成哈希值。

The main problem of such approaches is that the external symbolic information must be generated and then preserved from each and every software build. The need to match the symbolic information to the exact version of code executing on the target is a big logistic problem in itself.

这类方法的主要问题是：外部符号信息必须在每次构建时生成并保存好。要把符号信息跟目标板上运行的确切代码版本对上号，这本身就是个大麻烦。

Therefore, Q-Spy takes a different approach, in which the symbolic information is generated by the target, so it does not need to be generated externally by some pre-compile tool and can never go out of synch.

所以 Q-Spy 换了个思路：**符号信息由目标板自己生成**。不需要外部预编译工具来产生，也永远不会跟代码不同步。

The Q-Spy approach becomes clear when you take a bit closer look at the QSPY output. You should recognize two types of addresses. First are addresses starting with hex-2. These are RAM addresses of objects, like your TimeBomb active object. Second are addresses starting with hex-0. These are ROM addresses of code, such as your state-handler functions. Finally, you also see event signals as smaller integer numbers.

仔细看 QSPY 的输出，这个方法就很清楚了。你应该能辨认出两类地址：一类以 0x2 开头——这是对象的 RAM 地址，比如你的 TimeBomb **活动对象**（active object）；另一类以 0x0 开头——这是代码的 ROM 地址，比如你的状态处理函数。另外你还能看到事件信号，以较小的整数显示。

All that means that if you can provide the mapping between the addresses and symbolic names in your code, the QSPY host application should be able to display the symbolic information instead of the raw binary addresses.

也就是说，只要你能在代码里提供地址到符号名的映射，QSPY 主机程序就能把原始的二进制地址显示成可读的符号名。

And this is exactly what Q-Spy allows you to do by providing the so-called dictionary trace records.

而这正是 Q-Spy 通过所谓的**字典追踪记录**（dictionary trace records）帮你做到的。

First are "object-dictionaries" that produce symbolic information about the addresses of objects. For example, here is the object dictionary for your AO_TimeBomb active object. Please note that AO_TimeBomb is a pointer already, so you don't need to use the address-of operator to obtain the address of the object.

首先是"**对象字典**"（object dictionary），用来产生对象地址的符号信息。比如这里是你的 `AO_TimeBomb` 活动对象的对象字典。注意 `AO_TimeBomb` 本身已经是指针了，不需要再用取地址运算符。

Second, are "signal dictionaries" that produce symbolic information about the event signals. They take two parameters, the signal enumeration and the address of the associated state-machine because signals can be in principle state-machine specific. The latter pointer can be zero for global signals.

其次是"**信号字典**"（signal dictionary），产生事件信号的符号信息。它接受两个参数：信号枚举值和关联的状态机地址——因为信号原则上可以是某个状态机专属的。如果是全局信号，第二个参数传 NULL 就行。

And finally, "function dictionaries" provide symbolic information about your state-handler functions. You can type them manually, like the other dictionaries, but they can be generated automatically by the QM modeling tool, when you check the QS_FUN_DICTIONARY box in the state machine Property Editor.

最后是"**函数字典**"（function dictionary），提供状态处理函数的符号信息。你可以像其他字典一样手写，也可以让 QM 建模工具自动生成——在状态机属性编辑器里勾选 `QS_FUN_DICTIONARY` 就行。

After re-generating the code and updating it in the uVision editor, you can see that QM added the function dictionaries in the top-most initial transition of your state machine.

重新生成代码并在 uVision 编辑器里刷新后，你会看到 QM 在状态机的最顶层初始转移中自动添加了函数字典。

So this is about it as far as the most essential "dictionaries" are concerned. And it wasn't that difficult, was it?

核心的"字典"就这些了。不难吧？

Alright, so now, let's re-build the code and load it onto the board.

好，重新编译，下载到板子上。

When you reset the board now, you can see the dictionary trace records produced. And you can also see that most of the raw hex-values are now replaced by the symbolic names from the dictionaries.

复位开发板，你会看到字典追踪记录产生了，而且大部分原始十六进制值已经被字典中的符号名替换掉了。

This is all useful information, but these are still not all the pre-defined trace records in the QP framework. So, let's enable all of them.

这些信息都很有用，但这还不是 QP 框架全部的预定义追踪记录。来，把它们全启用。

As usual, re-build and download the code onto the board.

照例，重新编译，下载到板子上。

Reset the board and... now that all trace records are enabled you see the high-frequency tick. But that is a bit too much.

复位开发板……所有追踪记录都启用后，你会看到高频的时钟节拍记录刷屏了。有点太多了。

To disable just that one specific trace record, you need to first find out which pre-defined record that is.

要单独禁用那条记录，得先弄清楚它是哪条预定义记录。

Once you know that, you can use the same QS_GLB_FILTER() API, except for disabling a record, you use a negative value like so.

知道了之后，还是用 `QS_GLB_FILTER()` API，只不过禁用记录时传负值，像这样。

Now, re-build, reload, and reset the board.

重新编译、下载、复位。

After the reset, you no longer see the tick trace records because they have been filtered out.

复位后，时钟节拍追踪记录就不见了，因为已经被过滤掉了。

But, the trace now contains more information, although evidently, some object dictionaries are still missing. These are the trace records related to the internal time-event inside the TimeBomb active object. By now you should be able to provide that missing object-dictionary, so I leave as an exercise.

不过现在追踪里信息更丰富了，虽然明显还缺一些对象字典——那些是 TimeBomb 活动对象内部的**时间事件**（time-event）相关的记录。到这儿你应该能自己补上缺失的对象字典了，留作练习。

Instead, in the last segment of this lesson, I'd like to explain what really makes the Q-Spy software tracing tick, and that is the internal binary data protocol.

本课最后一部分，我想讲讲 Q-Spy 软件追踪真正运转的核心——也就是它内部的**二进制数据协议**（binary data protocol）。

Let's start with harvesting the raw binary data precisely as they are sent from the embedded board. For that it is convenient to start the qspy utility in a directory where you wish to store the data, for example, a temporary directory on your disk.

先来采集嵌入式板子发出的原始二进制数据。方便起见，在你想要保存数据的目录里启动 qspy——比如磁盘上的某个临时目录。

Now, after re-launching qspy, you can type h on your keyboard to see the quick help of the keyboard shortcuts. We'll use two commands: 's' for saving the binary data and 'o' for saving the screen output.

重启 qspy 后，按 `h` 键可以查看快捷键帮助。我们会用到两个命令：`s` 保存二进制数据，`o` 保存屏幕输出。

At that point, qspy opens two files in the working directory, whereas the base names are generated automatically from the current date-and-time.

这时 qspy 会在工作目录下创建两个文件，文件名自动根据当前日期和时间生成。

Now, you can reset the board and press SW1 button to collect the trace.

好了，复位开发板，按下 SW1 按钮来采集追踪数据。

After that's done, you type o and s again to toggle the collection of screen output and binary data, respectively.

采集完毕，再按一次 `o` 和 `s` 分别关闭屏幕输出和二进制数据的保存。

So, here is the raw binary data, and here the corresponding human-readable screen output.

这就是原始二进制数据，这是对应的人类可读屏幕输出。

It's interesting to note the sizes of these files of 3 and 10 KB, respectively. This means that the binary data represents a natural compression of the tracing output by a non-trivial factor of over 3. In other words, compared to the formatted ASCII data, like in the PRINTF() method, you can send 3 times more trace information in binary.

注意看这两个文件的大小——分别是 3 KB 和 10 KB。这意味着二进制数据天然就实现了超过 3 倍的压缩。换句话说，跟格式化的 ASCII 数据（比如 `PRINTF()` 方法）相比，同样带宽下二进制能多传 3 倍以上的追踪信息。

But that's not the only advantage of the binary format. In addition, the binary protocol can detect errors and gaps in the data.

而且二进制格式的好处不止于此。二进制协议还能检测数据中的错误和间隙。

To simulate an error, I'll delete a byte somewhere in the captured binary file. This corresponds to dropping a byte in transmission.

来模拟一个错误——在捕获的二进制文件里删掉一个字节，模拟传输中丢了一个字节的情况。

Now, I exit qspy by pressing x and re-launch it with the -f command-line option with the file-name of the binary data. This means that qspy will read the input from the file instead of the COM port.

按 `x` 退出 qspy，然后用 `-f` 选项加上二进制数据文件名重新启动。这样 qspy 就从文件读取输入，而不是从 COM 端口。

When I run qspy in this playback mode, it reports "bad-checksum" error and data discontinuity from sequence 60 to 62, which means one missing trace record with sequence number 61.

在这种**回放模式**（playback mode）下运行 qspy，它报了"bad-checksum"校验和错误，还检测到序列号从 60 跳到了 62——说明序列号 61 的那条追踪记录丢了。

If you'd like to learn more about the Q-Spy data protocol, it's described in the online documentation I keep referring to in this video. A link to that documentation will be included in the video description.

想深入了解 Q-Spy 数据协议的话，我在视频里反复提到的在线文档里有详细说明，链接会放在视频描述里。

But to summarize here quickly, this is an HDLC-type protocol that allows instantaneous re-synchronization after any error to minimize the loss of useful data. You just saw this in the example where only one damaged record has been dropped, and the receiving qspy was able to immediately find the next, correct record.

简单总结一下：这是一种 **HDLC 类型协议**，任何错误发生后都能立即重新同步，把有用数据的损失降到最低。刚才的例子你已经看到了——只有一条损坏的记录被丢弃，接收端的 qspy 马上就能找到下一条正确的记录。

As far as the embedded side of the tracing implementation is concerned, the crucial property of the Q-Spy binary protocol is that it allows the data to be removed from the internal buffer in any chunks, entirely independently from the record boundaries. Still, the receiver is able to immediately find the individual records and parse them correctly.

在追踪实现的嵌入式端，Q-Spy 二进制协议最关键的特性是：数据可以从内部缓冲区以任意大小取出，完全不受记录边界的约束。而接收端仍然能立刻找到每条记录并正确解析。

That concludes this lesson about software tracing suitable for real-time applications. The subject is vital because embedded systems are very opaque by nature and it's difficult to know what's going on inside.

关于适用于实时应用的软件追踪就讲到这里。这个话题非常重要——嵌入式系统天生就是不透明的，很难搞清楚内部到底在发生什么。

Of course, I could only show the most basic features of the tracing system, as it can do much more. For example, software tracing can be a cornerstone of testing embedded code. Also, you can use it for monitoring your embedded devices via a remote, host-based user interface.

当然，我这里只展示了追踪系统最基本的功能，它能做的远不止于此。比如，软件追踪可以成为嵌入式代码测试的基石；你还可以通过远程主机端界面来监控嵌入式设备。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/video-course 下载。

Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course." Thanks for watching!

所有项目也可以在 GitHub 上的 Quantum Leaps 仓库"modern embedded programming course"中找到。感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Software Tracing | 软件追踪 | 在运行时记录软件行为的技术，用于调试和分析嵌入式系统 |
| QP/Spy / Q-Spy | QP/Spy / Q-Spy | QP 框架内置的实时软件追踪系统，使用二进制协议 |
| printf-debugging | printf 调试 | 使用 printf 输出进行调试的原始方法，开销大 |
| Instrumentation | 探针 / 埋点 | 在代码中插入的追踪语句，用于产生运行时信息 |
| Trace Record | 追踪记录 | 一次追踪操作产生的数据记录 |
| Time-critical path | 时间关键路径 | 代码中对执行时间有严格要求的执行路径 |
| Idle Thread | 空闲线程 | 系统没有其他工作可做时调度器切换到的线程 |
| QV | QV | QP 框架中的一种内置协作式内核/调度器 |
| QV_onIdle() | QV_onIdle() | QV 内核在系统空闲时调用的回调函数 |
| Global Filter | 全局过滤器 | Q-Spy 中用于启用/禁用追踪记录的过滤机制 |
| Predefined Trace Record | 预定义追踪记录 | QP 框架内部自动产生的追踪记录，无需用户手动添加 |
| Inversion of Control | 控制反转 | 框架控制应用程序流程的设计原则（IoC） |
| Active Object | 活动对象 | 事件驱动编程中具有自己线程和消息队列的对象 |
| State Machine | 状态机 | 用于建模系统行为的计算模型 |
| Dictionary Trace Record | 字典追踪记录 | Q-Spy 中用于传递符号信息的特殊追踪记录 |
| Object Dictionary | 对象字典 | 将对象地址映射为符号名的字典记录 |
| Signal Dictionary | 信号字典 | 将事件信号枚举值映射为符号名的字典记录 |
| Function Dictionary | 函数字典 | 将函数地址映射为符号名的字典记录 |
| Binary Data Protocol | 二进制数据协议 | 使用二进制格式而非 ASCII 文本进行数据通信的协议 |
| HDLC-type Protocol | HDLC 类型协议 | 基于高级数据链路控制标准的通信协议，支持错误检测和重新同步 |
| QSPY Host Utility | QSPY 主机工具 | 在主机上运行的 Q-Spy 数据解析和显示工具 |
| Time-stamp | 时间戳 | 精确标记事件发生时间的信息 |
| Time-event | 时间事件 | QP 框架中与时间相关的事件类型 |
| Busy-wait | 忙等 | CPU 不断轮询等待某个条件的低效等待方式 |
| Build Configuration | 构建配置 | IDE 中用于不同编译目标（如 Debug、Spy）的配置 |
| Context Switch | 上下文切换 | RTOS 中从一个线程切换到另一个线程的操作 |
| Entry Action | 入口动作 | 状态机中进入某个状态时执行的动作 |
| Symbolic Information | 符号信息 | 将二进制地址映射为可读名称的调试信息 |
