# 第45课：使用 printf 进行软件追踪 / Lesson 45: Software Tracing with printf

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek, and in this lesson, you'll learn about "debugging by printf" as the most common software tracing technique. Today you'll see how to implement software tracing with printf on your TivaC LaunchPad board, and you'll also explore some shortcomings of this primitive technique.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这节课我们要学的是 **"用 printf 调试"（debugging by printf）**——最常见的**软件追踪（Software Tracing）**技术。今天你会在 TivaC LaunchPad 开发板上亲手用 printf 实现软件追踪，同时也会看到这种原始方法的一些短板。

---

In any real-life project, getting the code written, compiled, and successfully linked is only the first step. The system still needs to be debugged, tested, and optimized.

在任何实际项目中，代码写完、编译通过、链接成功，这些都只是第一步。系统还需要**调试（debugging）**、**测试（testing）**和**优化（optimization）**。

---

So far in this course, the primary tool for that was the single-step debugger, where you set breakpoints and, after a breakpoint is hit, you inspect registers, variables, and memory. In case of any problem, the biggest question is always: "How did I get there?"

到目前为止，课程中用得最多的调试工具就是**单步调试器（single-step debugger）**——设个**断点（breakpoint）**，命中的时候去检查寄存器、变量和内存。可一旦出了问题，你总会问一个大问题："程序是怎么跑到这一步的？"

---

The call stack might provide some help as to which functions were called in which order, but the information is minimal. In event-driven systems, specifically, the call stack is of less value because event handlers return after each event, thus removing any trace of their execution from the call stack.

**调用栈（call stack）**也许能帮你看看哪些函数按什么顺序被调用了，但信息非常有限。尤其是在**事件驱动系统（event-driven system）**里，调用栈几乎帮不上忙——因为事件处理函数处理完一个事件就返回了，调用栈上根本留不下任何执行痕迹。

---

In the end, the biggest problem with a single-step debugger is that it stops the running system and completely changes its real-time behavior. It's like trying to study a living organism by first killing it.

归根结底，单步调试器最大的问题在于它会停掉正在运行的系统，彻底改变程序的实时行为。这就像为了研究一个活体生物，先把它弄死——完全不是一回事了。

---

What you really need is a method to observe the live interactions within the software running at full speed or close to full speed. For that, most software developers turn to the tried and true printf debugging technique.

你真正需要的是一种方法，能在程序全速或接近全速运行的时候，观察软件内部的实时交互。为此，大多数开发者会想到那个经过时间检验的老办法——**printf 调试**。

---

In that method, printf statements are placed throughout the code, which is called "instrumentation," so that the code itself reports what it is doing.

具体做法就是在代码各处插入 printf 语句，这个过程叫做**"插桩"（instrumentation）**——让代码自己告诉你它在干什么。

---

Such "Debugging by printf" (or sprintf, snprintf, and similar functions) is the most primitive of a class of techniques collectively called "Software Tracing."

这种"用 printf 调试"（或者 sprintf、snprintf 等类似函数），是一类统称为**"软件追踪"（Software Tracing）**的技术中最原始的一种。

---

You saw an example of this technique in lesson #42, where the hierarchical state machine produced a trace of all actions it has executed.

你在第 42 课已经见过这种技术的例子了——那个**层次状态机（hierarchical state machine）**输出了它执行过的所有操作的追踪记录。

---

But that was done on a host computer. Today, I'd like to show you how to do it on your embedded board.

不过那次是在主机上做的。今天，我想演示一下怎么在你的嵌入式开发板上实现。

---

For that, let's go back a few lessons to lesson-41. Copy that directory and rename it to lesson-45. Get inside the lesson-45 directory and double-click on the project "lesson" to open it in the uVision IDE.

为此，我们先回到第 41 课。把那个目录复制一份，改名为 lesson-45。进去之后双击 "lesson" 项目文件，在 uVision IDE 里打开它。

---

To remind you quickly what happened back in lesson 41, you have created a hierarchical state machine for a TimeBomb active object.

快速回顾一下第 41 课的内容：你为一个 **TimeBomb 活动对象（active object）**创建了一个层次状态机。

---

The state machine was triggered by the button presses and time events. It turned the LEDs on and off to emulate various actions.

这个状态机由按键和时间事件触发，通过控制 LED 的亮灭来模拟各种操作。

---

Your job for today is to instrument the code such that it will also produce a trace output in real-time about the performed actions.

今天的任务是对代码进行插桩，让它能够实时输出所执行操作的追踪信息。

---

Given this problem statement, any C programmer would typically turn to the standard C library function "printf".

面对这个需求，任何 C 程序员第一反应都是标准 C 库函数——`printf`。

---

This function requires the `<stdio.h>` header file.

这个函数需要包含 `<stdio.h>` 头文件。

---

`printf()` takes a format string as the first parameter, which it copies to the output, but also performs percent-substitutions.

`printf()` 的第一个参数是**格式字符串（format string）**，它会把这个字符串复制到输出中，同时对其中的 `%` 占位符进行替换。

---

For example, format string `printf("LED-%s is %d\n", "red", 1);` will produce the output "LED-red is 1" new-line, in which all % signs are substituted with the values of parameters following the format.

比如，`printf("LED-%s is %d\n", "red", 1);` 会输出 "LED-red is 1" 加一个换行——所有的 `%` 标记都被替换成了后面的参数值。

---

OK, so let's put such `printf()` instrumentation in all functions for the LEDs.

好，那我们就把这样的 `printf()` 插桩放到所有 LED 相关的函数里。

---

And also, in the `SysTick_Handler` ISR, to trace the button presses.

同时也在 `SysTick_Handler` **中断服务程序（ISR）**里加上插桩，用来追踪按键操作。

---

All right, so let's just try to build the project.

好了，来试试构建项目。

---

Well, what do you know! All this compiles and links error- and warning-free!

你猜怎么着？编译链接全部通过，零错误零警告！

---

But when you try to run it... it gets stuck at a hardcoded breakpoint somewhere inside `sys_open`, before even reaching the `main` function.

可是当你试着运行的时候……程序还没跑到 `main` 函数，就卡在了 `sys_open` 内部某个硬编码的断点上。

---

Well, it turns out that the `printf()` facility requires a more elaborate configuration.

原来，`printf()` 这套机制需要更复杂的配置才行。

---

Since `printf()` is a C-library function, the first step is to enable **MicroLIB**, which is a very lightweight version of the standard C library specifically designed for embedded microcontrollers.

既然 `printf()` 是 C 库函数，第一步就是启用 **MicroLIB**——它是专门为嵌入式微控制器设计的标准 C 库超轻量版本。

---

So, let's see if that helps.

来看看有没有用。

---

This time around, you reach the `main()` function, which is significant progress.

这次你成功进入了 `main()` 函数，算是很大的进步了。

---

But when you attempt to run the code, you still hit a hardcoded breakpoint, but this time in `fputc()`, which is another C library function called from `printf`.

可当你继续运行代码时，又碰到了一个硬编码断点——不过这次是在 `fputc()` 里，这是 `printf` 内部调用的另一个 C 库函数。

---

So, what's going on with these hardcoded breakpoints, anyway?

那这些硬编码断点到底是怎么回事？

---

Well, it seems that the MicroLIB library provided with the Keil uVision toolset implements all standard functions. But the library cannot fully define hardware-specific functions. So instead of not defining such functions like `fputc()` at all, the library apparently provides dummy implementations with hard-coded breakpoints.

原来是这样的：Keil uVision 工具集自带的 MicroLIB 实现了所有标准函数，但那些跟硬件相关的函数它没法完整定义。所以它并没有完全不提供 `fputc()` 之类的函数，而是给了一个带硬编码断点的**桩实现（dummy implementation）**。

---

The solution is to provide the definitions of such functions in your application code. Then, due to the linking rules for libraries, which you've learned in lesson 14 about the startup code, the linker will take your functions instead of the versions from the library.

解决办法就是在你自己的应用代码里提供这些函数的定义。这样，根据你在第 14 课**启动代码（startup code）**中学过的库链接规则，链接器会优先使用你写的函数，而不是库里的版本。

---

Alright, so let's just provide an empty definition of `fputc()`. Per the C documentation, the `fputc()` function takes the character to send and a FILE pointer. Upon success, it returns the character it sends. You'll still need to decide where to send the character, but let's ignore it for now.

好，那我们先提供一个空的 `fputc()` 定义。根据 C 文档，`fputc()` 接收两个参数：要发送的字符和一个 FILE 指针。成功时返回发送的字符。字符具体往哪发，等会儿再决定，先不管它。

---

When you build and load the code now, set a breakpoint inside your new `fputc()` function.

构建并下载代码后，在你新写的 `fputc()` 函数里设一个断点。

---

Run the code, and after hitting the breakpoint, you can see on the call stack that `fputc()` is called from the `printf_core()`, which is called from your `TimeBomb_wait4button` and ultimately from `main()`.

运行代码，命中断点后，从调用栈可以看到：`fputc()` 被 `printf_core()` 调用，`printf_core()` 又被你的 `TimeBomb_wait4button` 调用，最顶上是 `main()`。

---

Also, when you keep running the code and hitting the breakpoint, you can see that your `fputc()` function receives different characters. All this looks very reasonable.

继续运行、反复命中断点，你会发现 `fputc()` 每次收到的字符都不一样。看起来一切都很合理。

---

Finally, when you remove the breakpoint and run the code free, you can see that your TimeBomb works as before, although it still does not produce any trace output.

最后，把断点去掉让程序自由运行，你会发现 TimeBomb 功能跟以前一样正常——只不过还是没有任何追踪输出。

---

So, now, you need to finish the job with `fputc()` and finally send the characters somewhere where you can see the output. For that, you have a few options:

所以现在，你得把 `fputc()` 补完整，把字符真正发到一个你能看到的地方。有几种方案：

---

Your first option is to send the output to the debugger. Specifically, the Cortex-M processor has a built-in **ITM module**, which stands for **Instrumentation Trace Macrocell**. The ITM is specifically designed for supporting the "printf-style debugging".

第一种方案是输出到调试器。具体来说，Cortex-M 处理器内置了 **ITM 模块**，全称是**指令追踪宏单元（Instrumentation Trace Macrocell）**。ITM 就是为"printf 风格调试"量身定做的。

---

Unfortunately, ITM requires a more advanced hardware debugger probe than the Stellaris ICDI installed on your TivaC LaunchPad board.

不幸的是，要用 ITM，需要比 TivaC LaunchPad 板子上自带的 Stellaris ICDI 更高级的**硬件调试探针（hardware debugger probe）**。

---

The hardware debugger doesn't need to be expensive, just a little more modern. For example, the ST-Link debugger provides tracing capability based on the ITM.

硬件调试器不用很贵，稍微新一点就行。比如 ST-Link 调试器就支持基于 ITM 的追踪功能。

---

In fact, I've adapted the TimeBomb example for the very inexpensive STM32 NUCLEO-L152RE board equipped with the ST-Link hardware debugger.

事实上，我已经把 TimeBomb 的例子移植到了非常便宜的 STM32 NUCLEO-L152RE 开发板上——这块板子自带 ST-Link 硬件调试器。

---

Let me quickly demonstrate the ITM option with the NUCLEO project, which will be included in the project downloads for this lesson. After this, I'll go back to TivaC to explore other options for sending the tracing output.

让我用 NUCLEO 项目快速演示一下 ITM 方案，这个项目会包含在本课的下载包里。演示完之后，我会回到 TivaC，看看发送追踪输出还有什么别的办法。

---

The NUCLEO project uses exactly the same `main.c` with the TimeBomb hierarchical state machine, but obviously a bit different `bsp.c` implementation than TivaC.

NUCLEO 项目用的是完全一样的 `main.c` 和 TimeBomb 层次状态机，不过 `bsp.c` 的实现跟 TivaC 自然有些不同。

---

However, the BSP for NUCLEO has the same tracing instrumentation with printfs.

但 NUCLEO 的 BSP 里也做了同样的 printf 追踪插桩。

---

The essential difference is that the `fputc()` implementation calls `ITM_SendChar()` to output the character to the Instrumentation Trace Macrocell.

关键区别在于，`fputc()` 的实现调用了 `ITM_SendChar()`，把字符输出到指令追踪宏单元。

---

The other difference is the ST-Link hardware debugger setup, where you need to enable tracing and correctly set the core clock because leaving it at the default value won't work.

另一个区别是 ST-Link 硬件调试器的设置——你需要启用追踪功能，并且正确配置**内核时钟（core clock）**，用默认值是不行的。

---

For that, you could set a breakpoint at `QF_onStartup()` and run the debugger. Once the breakpoint is hit, you point to the `SystemCoreClock` CMSIS variable and read its value.

具体怎么做呢？你可以在 `QF_onStartup()` 处设个断点，启动调试器。命中断点后，把鼠标指向 `SystemCoreClock` 这个 CMSIS 变量，读取它的值。

---

Now, go back to the trace setup and convert the `SystemCoreClock` value to Megahertz.

然后回到追踪设置界面，把 `SystemCoreClock` 的值换算成兆赫兹。

---

You need to copy the result into the Core Clock field in the trace setup.

把结果填到追踪设置的 Core Clock 字段里就行了。

---

Also, as you are at it, make sure that "Ignore packets with no SYNC" is unchecked.

顺便确保 "Ignore packets with no SYNC" 这个选项没有勾选。

---

Alright, so finally, you can start the debugger again and open the view: Serial Windows-Debug (printf) Viewer.

好，最后再次启动调试器，打开 Serial Windows → Debug (printf) Viewer 窗口。

---

Now, when you continue, the window shows the first printout from the top-most initial transition.

继续运行，窗口里就显示了来自最顶层**初始转移（initial transition）**的第一条输出。

---

When you press the button on the NUCLEO board, you get the real-time trace of the TimeBomb activity.

按下 NUCLEO 板子上的按钮，你就能看到 TimeBomb 活动的实时追踪了。

---

Alright, so that was a quick demonstration of the printf debugging with the ITM. While the programming was relatively simple, the method requires an appropriate hardware debugger probe, such as ST-Link, which is external hardware to the microcontroller. Also, you must run the code under a software debugger, which then displays the output.

好，以上就是用 ITM 做 printf 调试的快速演示。编程部分虽然不算复杂，但这个方案需要合适的硬件调试探针（比如 ST-Link），这是微控制器之外的外部硬件。而且你必须在软件调试器下运行代码，才能看到输出。

---

For these reasons, often a better solution is to make the microcontroller produce the tracing output by itself, without any external hardware, which leads us back to the TivaC LaunchPad project.

正因为如此，通常更好的方案是让微控制器自己产生追踪输出，不需要任何外部硬件。所以我们回到 TivaC LaunchPad 项目。

---

Here, specifically, you need to implement `fputc()` using a piece of communication hardware already present in your microcontroller. This peripheral is called **UART**, which stands for **Universal Asynchronous Receiver and Transmitter**.

具体来说，你要利用微控制器上已有的通信硬件来实现 `fputc()`。这个外设叫做 **UART**，全称是**通用异步收发器（Universal Asynchronous Receiver and Transmitter）**。

---

I don't want to go into too much detail about how UART works, but it uses just one Tx pin to transmit data. The transmission happens by modulating the voltage level on the Tx pin. The speed of the transmission, called the **baud rate**, is determined upfront and must match the rate expected by the receiver within 1% or so. For example, if the transmitter uses baud rate 115,200 bits per second, the serial receiver must also be configured to 115,200 bits per second.

UART 的工作原理我就不展开讲了，你只需要知道它用一根 **Tx 引脚**来发送数据。发送的方式是调制 Tx 引脚上的电平。传输速度叫做**波特率（baud rate）**，得提前约定好，发送端和接收端必须匹配到 1% 以内。比如发送端用 115,200 位/秒的波特率，接收端也得配成 115,200 位/秒。

---

Your TivaC has eight such independent UART peripherals, but UART0 is special because it is already connected to the USB cable and shows as a **virtual COM port** on the host PC. This means that you won't need any additional wiring to access the serial data transmitted through UART0. The presence of the virtual COM port is, actually, one of the main reasons why I selected the TivaC LaunchPad board for this video course some years ago.

你的 TivaC 有八个独立的 UART 外设，其中 UART0 比较特别——它已经连到了 USB 线上，在主机 PC 上会显示为一个**虚拟串口（virtual COM port）**。这意味着你不需要额外接线就能读到 UART0 发出的数据。其实，正是因为板子上有虚拟串口，几年前我才选了 TivaC LaunchPad 作为这门视频课程的教学板。

---

So, here is the code for your `fputc()` to send a character to the UART0:

好，下面是把字符发送到 UART0 的 `fputc()` 代码：

---

First, you must wait as long as the UART0 is busy by polling the BUSY bit in the UART FR register.

首先，你要轮询 UART FR 寄存器中的 BUSY 位，等 UART0 空闲下来。

---

And next, you need to write the byte into the UART0 Data Register.

然后把字节写入 UART0 的数据寄存器就行了。

---

But while sending bytes is easy, the UART requires some non-trivial initialization.

发送字节本身不难，但 UART 的初始化可没那么简单。

---

Here is the code. As the comments explain, first you need to enable the **clock gating** for the UART0 peripheral and the GPIO-A, which controls the TX pin of the UART.

代码如下。注释说得很清楚：首先要为 UART0 外设和控制 UART TX 引脚的 GPIO-A 启用**时钟门控（clock gating）**。

---

Next, you need to properly configure the UART0 Tx and Rx pins.

接下来要正确配置 UART0 的 Tx 和 Rx 引脚。

---

And finally, you configure the UART for the desired baud rate and **8-N-1 operation**, which means 8-bit data, no-parity, and one stop bit.

最后，配置 UART 的波特率和 **8-N-1 模式**——也就是 8 位数据、无校验位、1 个停止位。

---

The baud rate as well as other constants, need to be defined before they are used.

波特率和其他常量要在使用前定义好。

---

You still need to actually call `uart_init()` from `BSP_init()`.

别忘了在 `BSP_init()` 里实际调用 `uart_init()`。

---

And you need to provide the prototype of the function at the top of the file.

还要在文件顶部加上函数的原型声明。

---

Alright, let's check how this works...

好了，来看看效果……

---

Now, I will specifically NOT go into debugger, but only upload the code to the board because the UART does not need the debugger support as ITM did previously.

注意，这次我特意不进调试器，而是直接把代码下载到板子上。因为 UART 不像之前的 ITM 那样需要调试器支持。

---

But instead, you need to receive the printf output via the virtual Serial port. To see that, you can open the Windows Device Manager, where in the section Port (COM & LPT), you should see Stellaris Virtual Serial Port. On my machine, the COM port number is 3, but it might be different on your PC.

取而代之的是，你需要通过虚拟串口来接收 printf 输出。打开 Windows 的设备管理器，在"端口 (COM 和 LPT)"下面，你应该能看到 Stellaris Virtual Serial Port。我机器上显示的是 COM3，你的可能不一样。

---

Now, you will need a **serial terminal utility** to actually show the printf output. Many such terminals are available for download. I happen to have here a simple and freeware terminal called **Termite** from CompuPhase. A link to the download will be provided in the video description.

接下来你需要一个**串口终端工具（serial terminal utility）**来显示 printf 的输出。这类工具很多，我手边正好有一个 CompuPhase 出品的免费小工具叫 **Termite**。下载链接我会放在视频简介里。

---

Termite typically detects the virtual serial port and connects to it, but you can also adjust the settings. Here, the important value is the baud rate, which as you remember, was configured to 115200 in your TivaC.

Termite 一般会自动检测到虚拟串口并连接上去，你也可以手动调整设置。这里关键是波特率——记得吗？TivaC 上配的是 115200。

---

Now, when you press the reset button on the board, you can see the first printout from the top-most initial transition. This is awesome!

现在按下板子上的复位按钮，你会看到最顶层初始转移的第一条输出。太棒了！

---

Now, when you press the SW1 button on the board, you can see the sequence of blinks and then boom!

按下板子上的 SW1 按钮，你能看到一连串的闪烁——然后，砰！

---

Hey, it works!

嘿，成功了！

---

Let's compare it to the trace produced by the ITM on the NUCLEO board. As you can see, they are... identical!

来跟 NUCLEO 板子上 ITM 输出的追踪对比一下。可以看到……完全一样！

---

So, here you have it: software tracing with printf for your TivaC LaunchPad board.

这就是在 TivaC LaunchPad 上用 printf 做软件追踪的完整实现。

---

But this is just a first cut because, for real-life use, you can still significantly improve the design. For starters, you should be able to deactivate and activate the tracing in your code easily.

不过这只是初版。实际使用中你还可以大幅改进设计。首先，你应该能方便地在代码中开关追踪功能。

---

In a minute, I will explain the reasons why you might NOT want to have instrumentation like that in your code permanently, but now let's just see what I mean by deactivating the instrumentation.

等一下我会解释为什么你可能不想让插桩一直留在代码里，但先看看我说的"关闭插桩"是什么意思。

---

Because I don't mean deleting the instrumentation once you are done debugging since really, you are never quite done, are you. Chances are that you might need the instrumentation for the future maintenance of the code.

我说的可不是调试完了就把插桩删掉——说实话，调试哪有真正"完了"的时候，对吧？将来做代码维护的时候，你八成还需要这些插桩。

---

Therefore, I mean keeping the instrumentation but activating and deactivating it easily.

所以我的意思是：插桩要保留，但要能轻松地开关。

---

A rather naive approach is to surround all snippets of code pertaining to the instrumentation with `#ifdef SPY / #endif` conditionals.

一种比较朴素的做法是用 `#ifdef SPY / #endif` 把所有插桩代码包起来。

---

Then you can activate all these parts of the code simultaneously just by defining the macro SPY or deactivate all of them by commenting out the macro definition.

这样你只要定义 `SPY` 这个宏就能一次性启用所有插桩代码，注释掉宏定义就能全部禁用。

---

This would even work, but it is tedious because you must not forget to surround *every* call to the `printf()` instrumentation with the `#ifdef / #endif` pair.

这办法倒也行，就是太繁琐了——你绝不能漏掉任何一个 `printf()` 调用，每个都得用 `#ifdef / #endif` 包住。

---

But a far better and much more maintainable design is to define the tracing instrumentation itself as **preprocessor macros**, and make the macro definitions conditional.

更好的、也更易维护的做法是：把追踪插桩本身定义为**预处理器宏（preprocessor macro）**，然后让宏的定义变成条件化的。

---

Here is how it works: As before, you start with `#ifdef SPY`, but now you define the `MY_PRINTF()` macro to call `printf()`. A little tricky part here is that `printf()` takes a variable number of parameters or no parameters at all. Luckily, the C preprocessor supports the so-called **variadic macros** defined with the ellipsis, and then the special `##__VA_ARGS__` construct is used to pass the variadic parameters to `printf()`.

原理是这样的：跟之前一样，从 `#ifdef SPY` 开始，但这次你把 `MY_PRINTF()` 定义成调用 `printf()` 的宏。有个小坑是 `printf()` 的参数个数可变，甚至可以没有参数。好在 C 预处理器支持所谓的**可变参数宏（variadic macro）**——用省略号定义，然后用 `##__VA_ARGS__` 把可变参数转发给 `printf()`。

---

In case the tracing should be disabled, the macro `MY_PRINTF()` is defined as zero to emulate the return value from `printf()`. This typically generates no code. Similarly, `MY_PRINTF_INIT()` is defined as `(void)0`, which also generates no code.

如果要禁用追踪，就把 `MY_PRINTF()` 定义成 0，模拟 `printf()` 的返回值，这样基本不产生任何代码。类似地，`MY_PRINTF_INIT()` 定义成 `(void)0`，同样不产生代码。

---

With these definitions, you can now replace all instances of `printf()` function call with the `MY_PRINTF()` macro.

有了这些定义，你就可以把代码里所有 `printf()` 调用替换成 `MY_PRINTF()` 宏了。

---

The code supporting the `printf()` directly needs to be also conditionally compiled.

直接支撑 `printf()` 的那些代码也要做条件编译。

---

And finally, the UART initialization needs to be replaced with the `MY_PRINTF_INIT()` macro.

最后，UART 初始化也要替换成 `MY_PRINTF_INIT()` 宏。

---

The first compilation, after the changes, builds the code with the printf instrumentation disabled because the macro SPY is not defined.

改完之后第一次编译，构建出来的是禁用 printf 插桩的版本，因为 `SPY` 宏没定义。

---

But when the macro SPY is defined, the code is built with the printf instrumentation enabled.

但如果定义了 `SPY` 宏，构建出来的就是启用 printf 插桩的版本。

---

Interestingly, now you can improve and generalize the code even further. For example, in case you wanted to add instrumentation in other files, such as your `main.c` with the TimeBomb state machine, you wouldn't want to repeat the same definitions of the instrumentation macros there.

有意思的是，代码还可以进一步改进和泛化。比如，你想在其他文件里也加插桩——像 `main.c` 里的 TimeBomb 状态机——你肯定不想在每个文件里重复写一遍宏定义。

---

But you don't have to if you put the snippet of code into a separate header file. Before you do, however, let's refactor the function name `uart0_init()` into `printf_init()` because in other embedded boards, the initialization might involve some other peripheral than UART0.

不用重复——只要把这段代码放进一个单独的头文件就行了。不过在此之前，先把函数名 `uart0_init()` 改成 `printf_init()`，因为换了别的开发板，初始化可能用的就不是 UART0 了。

---

OK, so now you can put the printf-related stuff in the `my_printf.h` header file not forgetting the usual inclusion guards.

好，现在把 printf 相关的东西放到 `my_printf.h` 头文件里，别忘了加上**包含保护（inclusion guard）**。

---

With that done, you can include the new header file in all modules that you wish to instrument.

搞定之后，在所有需要插桩的模块里包含这个新头文件就行了。

---

But wait a minute! The SPY macro is now defined only in the `bsp.c` file, and is not defined in `main.c`, which is inconsistent. The remedy is to move the SPY macro definition to the compiler options, where it will be applied consistently to all compilation units.

等等！现在 `SPY` 宏只在 `bsp.c` 里定义了，`main.c` 里没有——这不一致。解决办法是把 `SPY` 宏定义移到**编译器选项（compiler option）**里，这样所有**编译单元（compilation unit）**都能统一生效。

---

However, all this is still not the ultimate solution. The most professional way of incorporating software tracing into your project is through the concept of a **Build Configuration**.

不过，这些还算不上最终方案。把软件追踪集成到项目中最专业的做法，是通过**构建配置（Build Configuration）**来实现。

---

A Build Configuration is a collection of settings and source code packaged together and having a distinct name. For example, so far you've been building your code for ease of debugging, and so you've been using the **dbg** build configuration. But maybe the settings for debugging would not be optimal for the final release of the software, so you could define a separate **release** configuration.

构建配置就是把一组编译设置和源代码打包在一起，给它一个名字。比如，到目前为止你一直在用 **dbg** 构建配置，方便调试。但调试用的设置未必适合最终发布，所以你可以单独定义一个 **release** 配置。

---

Most professional tools, including Keil uVision, support separate build configurations, so today I will quickly show you how to create a "spy" build configuration optimized for software tracing.

大多数专业工具——包括 Keil uVision——都支持多个构建配置。今天我快速演示一下怎么创建一个专为软件追踪优化的 "spy" 构建配置。

---

You start from the top-menu Project | Manage | Project Items. Alternatively, you can click on the "Manage Project Item" button in the toolbar.

从顶部菜单选 Project → Manage → Project Items，或者直接点工具栏上的 "Manage Project Item" 按钮。

---

In the Project Targets column, you click on the New item and type the name "spy" for the build configuration. Click "Set as Current Target" and close the dialog box.

在 Project Targets 那一列，点 New，输入 "spy" 作为配置名称。点 "Set as Current Target"，然后关掉对话框。

---

Now, you can adjust the settings for the "spy" configuration.

现在来调整 "spy" 配置的各项设置。

---

In the Output tab, you still have the "dbg" folder inherited from the dbg configuration. You need to change it to the "spy" folder, which you create on disk.

在 Output 选项卡里，还是从 dbg 配置继承来的 "dbg" 文件夹。你需要改成 "spy" 文件夹——先在磁盘上创建这个文件夹。

---

A similar situation occurs in the Listing tab, but this time you just use the already created "spy" folder.

Listing 选项卡也类似，不过这次直接用刚才创建的 "spy" 文件夹就行了。

---

In the compiler settings, you obviously keep the SPY macro definition because it enables the tracing instrumentation in the code.

编译器设置里，`SPY` 宏定义肯定要保留——它负责启用代码里的追踪插桩。

---

Now you can finally build your spy configuration.

好了，现在可以构建 spy 配置了。

---

You can also adjust the other debug build configuration where you don't want the tracing instrumentation. You disable the tracing by removing the SPY macro definition.

你也可以调整另一个不想加追踪插桩的调试配置——把 `SPY` 宏定义去掉就行。

---

Again, you can rebuild your debug configuration completely separately from the spy configuration.

同样，调试配置和 spy 配置是完全独立构建的，互不影响。

---

Which leads us to the last segment of this lesson, where I'd like to discuss the benefits and costs of printf-style debugging.

这就到了本课的最后一部分——来聊聊 printf 风格调试的优缺点。

---

The technique is immensely popular, and almost everybody uses it. For example, this is essentially the only way of debugging in the Arduino world.

这种技术极其流行，几乎人人都在用。比如在 Arduino 的世界里，这基本就是唯一的调试手段。

---

Printf-style tracing is convenient and requires relatively little code in the application. For example, to get printf working on a different board with a different communication mechanism, you only need to modify these two simple functions. It was even less code for the ITM debugging.

printf 风格追踪用起来方便，应用代码也写得不多。比如换一块通信方式不同的板子，你只需要改这两个简单的函数就行。用 ITM 的话代码量就更少了。

---

But at the same time, printf is about the most expensive software tracing technique you can possibly come up with.

但与此同时，printf 大概也是你能想到的**最昂贵**的软件追踪技术了。

---

Not many developers even realize how much codespace printf adds to the final binary image, so let's take a quick look.

很多开发者甚至没意识到 printf 给最终的**二进制映像（binary image）**增加了多少代码空间。来看一组数据。

---

Here I compare the map file from the debug build configuration... against the map file from the spy build configuration.

这里我对比了两个 **map 文件**——一个是 debug 配置的，一个是 spy 配置的。

---

If you forgot what a map file is, I introduced it back in lesson #14, where you learned about the embedded build process.

忘了 map 文件是什么的话，我在第 14 课介绍过，那是讲嵌入式构建过程的一课。

---

So, here in the map files, the most interesting is the "Image component sizes" section, where you can see that the library contribution increased from 124 bytes in the debug configuration to 676 bytes in the spy configuration. This means that printf adds some 552 bytes of code. And this is only for the simplest string and integer format specifications.

在 map 文件里，最值得关注的是 "Image component sizes" 部分。可以看到库的贡献从 debug 配置的 124 字节涨到了 spy 配置的 676 字节——也就是说，printf 增加了大约 552 字节的代码。而且这还只是用了最简单的字符串和整数格式。

---

If you used floating point format anywhere in the code, like here for example... the size of printf code would balloon to over 3,700 bytes, which means that printf would contribute over 3.5 KB to the total image.

如果你在代码里用到了浮点格式，比如这里……printf 的代码量会一下子膨胀到超过 3,700 字节——光 printf 一个函数就要占掉 3.5 KB 多。

---

To put it in perspective, the whole QP/C framework contributes only about 2.5 KB of code and read-only data.

做个对比：整个 QP/C 框架才贡献大约 2.5 KB 的代码和只读数据。

---

If you remember from the previous lessons, the QP framework provides hierarchical state machines, active objects, time events, and an RTOS kernel. Still, all of this is dwarfed by the complexity of printf.

还记得前面的课程吗？QP 框架提供了层次状态机、活动对象、时间事件、还有 RTOS 内核。这么多东西加在一起，跟 printf 的复杂度比起来都相形见绌。

---

But the big code footprint is not the only cost of printf.

但代码量大还不是 printf 唯一的代价。

---

A much bigger problem is the overhead in the execution time. I mean, all software tracing techniques are intrusive to some degree, but printf is particularly bad.

更大的问题在于**执行时间的开销**。说白了，所有软件追踪技术都有一定侵入性，但 printf 尤其严重。

---

To see just how bad, I'll use the 5-dollar logic analyzer that I've introduced in lesson #43.

到底有多严重？我会用第 43 课介绍过的那个 5 美元**逻辑分析仪（logic analyzer）**来量一量。

---

To better observe the timing, I've added two more GPIO test pins to the code.

为了更清楚地观察时序，我在代码里又加了两个 GPIO 测试引脚。

---

The first GPIO-D pin 0 is used in the SysTick ISR, where it is turned on upon the entry and turned off upon the exit from the ISR.

第一个是 GPIO-D 的 pin 0，用在 SysTick ISR 里——进入 ISR 时拉高，退出时拉低。

---

The second GPIO-D pin 1 is used in a similar way to time the execution of the `fputc()` function.

第二个是 GPIO-D 的 pin 1，用同样的方式来测量 `fputc()` 函数的执行时间。

---

So now let's load this code to the board use everything you've got: the logic analyzer and the serial terminal for printf tracing.

好，把代码下载到板子上，逻辑分析仪和串口终端都准备好——所有工具一起上。

---

Set the analyzer to trigger when you press the SW1 button and start the trace.

把逻辑分析仪设成在按下 SW1 按钮时触发，然后开始追踪。

---

Reset the board and watch the first printout on the terminal.

复位板子，看终端上的第一条输出。

---

Now, press the SW1 button. You can see the printouts on the terminal and the several milliseconds of captured logic analyzer trace.

按下 SW1 按钮。终端上出现了打印输出，逻辑分析仪也捕获了几毫秒的波形。

---

Interestingly, notice the new Boom! trace added in the TimeBomb state machine.

注意看，TimeBomb 状态机里新增了一条 "Boom!" 的追踪输出。

---

Regarding the logic analyzer, trace D4 shows the activity of the SysTick ISR, which fires periodically, but one execution time is much longer. This is when the printf trace is produced, and it takes 0.78 milliseconds.

看逻辑分析仪的波形：D4 通道显示的是 SysTick ISR 的活动，它周期性地触发，但其中有一次执行时间明显长了很多——那就是在产生 printf 追踪的时候，耗时 0.78 毫秒。

---

That needs to be compared to the normal case of only... 2 microseconds for the whole ISR. This means that printf extends the time by almost 400 times.

跟正常情况对比一下——整个 ISR 正常只要 2 微秒。也就是说，printf 把执行时间拉长了将近 **400 倍**。

---

Trace D5 shows the activity inside the `fputc()` function, which is even worse. This is because it shows all 3 printf messages produced. All of this takes some 3.2 milliseconds.

D5 通道显示的是 `fputc()` 内部的活动，情况更严重——因为它包含了所有 3 条 printf 消息的输出。总共花了大约 3.2 毫秒。

---

Actually, here you can count the individual bytes transmitted, whereas each byte takes 87 microseconds to send.

实际上，你可以数出每个单独的字节——每个字节的传输时间是 87 微秒。

---

Overall, this is pretty bad. The printf formatting to ASCII characters is expensive and produces a lot of bytes, which takes a lot of time to send out. But worse of all is that all that formatting and transmitting clogs the time-critical paths through the code.

总的来说，情况相当糟糕。printf 把数据格式化成 ASCII 字符本身就开销很大，还会产生大量字节要发送。但最要命的是，所有这些格式化和发送操作会**堵死代码中的时间关键路径（time-critical path）**。

---

In the next lesson, you'll see a much smarter software tracing approach, far less intrusive, by orders of magnitude compared to the printf-debugging. Stay tuned!

下一课，我会展示一种聪明得多的软件追踪方案——比 printf 调试的侵入性低好几个数量级。敬请期待！

---

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/video-course 下载。

---

Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course." Thanks for watching!

最后，所有项目也可以在 GitHub 上的 Quantum Leaps 仓库 "modern embedded programming course" 里找到。感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Software Tracing | 软件追踪 | 通过在代码中插入追踪语句来观察程序运行行为的技术 |
| instrumentation | 插桩 | 在代码中插入额外的追踪或监控语句的过程 |
| debugging by printf | 用 printf 调试 | 使用 printf 函数输出调试信息的最常见追踪技术 |
| single-step debugger | 单步调试器 | 通过断点和单步执行来调试程序的工具 |
| breakpoint | 断点 | 程序执行中暂停的位置标记 |
| call stack | 调用栈 | 记录函数调用层次关系的运行时数据结构 |
| event-driven system | 事件驱动系统 | 由事件触发处理器执行的系统架构 |
| active object | 活动对象 | 具有自己的执行线程和事件队列的对象 |
| hierarchical state machine | 层次状态机 | 支持状态嵌套的有限状态机 |
| MicroLIB | MicroLIB | Keil 提供的针对嵌入式微控制器的轻量级 C 库 |
| ITM (Instrumentation Trace Macrocell) | 指令追踪宏单元 | Cortex-M 处理器内置的用于 printf 风格调试的硬件模块 |
| UART (Universal Asynchronous Receiver and Transmitter) | 通用异步收发器 | 一种常用的异步串行通信外设 |
| baud rate | 波特率 | 串行通信中的数据传输速率，单位为位/秒 |
| virtual COM port | 虚拟串口 | 通过 USB 模拟的串行通信端口 |
| clock gating | 时钟门控 | 通过控制时钟信号来启用或禁用外设以节省功耗的技术 |
| 8-N-1 | 8-N-1 | 串口通信配置：8位数据、无校验位、1个停止位 |
| variadic macro | 可变参数宏 | C 预处理器中支持可变数量参数的宏定义 |
| preprocessor macro | 预处理器宏 | 编译前由预处理器进行文本替换的宏定义 |
| Build Configuration | 构建配置 | 将编译设置和源代码打包在一起的命名集合 |
| compilation unit | 编译单元 | 单个源文件及其包含的头文件组成的编译输入 |
| inclusion guard | 包含保护 | 防止头文件被重复包含的预处理指令 |
| binary image | 二进制映像 | 编译链接后生成的可执行二进制文件 |
| map file | map 文件 | 链接器生成的包含内存布局和符号地址的文件 |
| time-critical path | 时间关键路径 | 对执行时间有严格要求的代码路径 |
| logic analyzer | 逻辑分析仪 | 用于捕获和显示数字信号时序的测试仪器 |
| hardware debugger probe | 硬件调试探针 | 连接调试器和目标硬件的接口设备，如 ST-Link |
| dummy implementation | 桩实现 | 不含实际功能的占位函数实现 |
| initial transition | 初始转移 | 状态机启动时从初始伪状态到第一个状态的转移 |
| format string | 格式字符串 | printf 中第一个参数，包含文本和 % 占位符的字符串 |
| ISR (Interrupt Service Routine) | 中断服务程序 | 响应中断请求而执行的处理函数 |
