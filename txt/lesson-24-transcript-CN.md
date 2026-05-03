# 第24课：RTOS 轮转调度 / Lesson 24: RTOS Round-Robin Scheduling

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this third lesson on Real-Time Operating System (RTOS) I'll show you how to automate the scheduling process. Specifically, in this lesson you will implement the simple round robin scheduler that runs threads in a circular order. Along the way, you will add several improvements to the MiROS RTOS and you will see how fast it runs.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这是关于**实时操作系统**（RTOS）的第三节课，我来给你展示如何把调度过程自动化。具体来说，本课你会实现一个简单的**轮转调度器**（round-robin scheduler），让线程以循环的方式轮流运行。过程中你还会对 MiROS RTOS 做几项改进，并看看它跑得有多快。

As usual, let's get started by making a copy of the previous lesson 23 directory and renaming it to lesson 24. Get inside the new lesson 24 directory and double-click on the uVision project "lesson" to open it.

跟之前一样，先把上一课的 lesson-23 目录复制一份，改名为 lesson-24。进到新目录里，双击 uVision 工程"lesson"打开它。

To remind you quickly what happened so far, in the last lesson you started building a Minimal Real-time Operating System (abbreviated to MiROS).

快速回顾一下进展：上一课你开始搭建**最小实时操作系统**（Minimal Real-time Operating System，简称 MiROS）。

At this point, your MiROS RTOS can represent threads, can start threads, and can switch context from one thread to another.

到目前为止，你的 MiROS RTOS 已经能够表示线程、启动线程，还能在两个线程之间做**上下文切换**（context switch）。

But the scheduling of the next thread to run inside the OS_sched() function is still manual. Today, you will automate this as well, so that MiROS will be able to actually run your threads at full speed.

不过，`OS_sched()` 函数里调度下一个运行线程的逻辑还是手动的。今天就来把它也自动化掉，让 MiROS 能真正全速跑起你的线程。

For the specific situation of just two threads: blinky1 and blinky2, you can simply hard-code the thread scheduling with an IF statement, as follows:

对于只有 blinky1 和 blinky2 两个线程的情况，最简单的办法就是用 IF 语句**硬编码**线程调度，像这样：

If the current thread is blinky1 then set OS_next to the address of blinky2, otherwise set it to the address of blinky1.

如果当前线程是 blinky1，就把 `OS_next` 设为 blinky2 的地址；否则设为 blinky1 的地址。

When you try to compile, it fails, because the blinky1 and blinky2 identifiers are not known to the compiler. You can fix it by providing extern declarations. Of course, typically you place such declarations in a header file, but at this point you just want to test the general idea of automatic scheduling.

一编译就报错了——编译器不认识 blinky1 和 blinky2 这两个标识符。加上 `extern` 声明就能修复。当然，正常情况下这类声明会放到头文件里，但现在你只是想验证自动调度的基本思路。

The code builds correctly, so let's just load and run it on your LaunchPad board.

代码编译通过了，把它烧到 LaunchPad 板子上跑起来。

As you can see, both the green LED from the blinky1 thread and the blue LED from the blinky2 thread keep blinking simultaneously and independently from each other. So, at least you know how the end-result should look like and that automatic scheduling is workable.

可以看到，blinky1 的绿色 LED 和 blinky2 的蓝色 LED 都在持续闪烁，互不影响。所以，至少现在你知道了最终效果应该是什么样，也验证了自动调度是行得通的。

Now, let's try to actually design it, so that you don't hard-code the specific threads in the scheduler. Please note that at this point you don't want to change the behavior of the code, it already behaves according to your requirements. Instead, you want to improve the internal design, which is called "**Refactoring**".

好，接下来我们来好好设计一下，去掉调度器里硬编码的线程。注意，这时候你并不想改变代码的行为——它已经按你的要求工作了。你想改进的是内部设计，这就叫**重构**（Refactoring）。

Now, there are of course many ways to do such "Refactoring".

当然，"重构"有很多种做法。

The central element is how you choose to organize the threads that are started in the OSThread_start() function. Some RTOSes out there organize the threads into a linked-list, which is then traversed by the scheduler.

核心问题在于：你用什么方式来组织 `OSThread_start()` 里启动的线程。市面上有些 RTOS 把线程组织成**链表**（linked-list），调度器再去遍历它。

But in view of the future direction for the MiROS RTOS, I suggest a simple brute-force solution, which is to store the thread pointers in a pre-allocated array OS_thread[]. Once the array is populated by the consecutive calls to OSThread_start(), the scheduler will then select the next thread to run in a circular fashion.

不过考虑到 MiROS RTOS 后续的发展方向，我建议一个简单粗暴的方案：把线程指针存到一个**预分配数组**（pre-allocated array）`OS_thread[]` 里。数组通过连续调用 `OSThread_start()` 填充好之后，调度器就以循环方式选取下一个要运行的线程。

So, the first thing you need is the OS_thread[] array, which will be sized for 32+1 threads. The maximum number of threads will become more clear in the future lessons, but for now just remember that the MiROS RTOS can handle up to 32 threads.

所以，首先要有一个 `OS_thread[]` 数组，容量设为 32+1 个线程。32 个线程的上限在后面的课程里会解释清楚，现在只要记住 MiROS RTOS 最多支持 32 个线程就行了。

The RTOS also needs to remember how many threads have been started so far, which it will keep in the variable OS_threadNum.

RTOS 还得记住目前已经启动了多少个线程，这个数保存在变量 `OS_threadNum` 里。

And finally, the scheduler needs to remember the current index into the OS_thread[] array, which it will increment and wrap-around in the circular fashion.

最后，调度器要记住 `OS_thread[]` 数组的当前索引，每次递增，到了末尾就回绕到开头，循环往复。

So, now, every time a new thread is started in OSThread_start(), the "me" pointer to the thread is stored in the OS_thread[] array and the OS_threadNum counter is incremented for the next thread.

这样一来，每次在 `OSThread_start()` 里启动新线程时，指向线程的 `me` 指针就存入 `OS_thread[]` 数组，同时 `OS_threadNum` 计数器加一，为下一个线程做准备。

At this point, you are making an implicit assumption that you are not overflowing the thread array. Such assumptions should be enforced somehow. The typical way is to check the index and return an error code to the caller when it overflows. But then the caller can simply ignore the problem.

这里有个隐含假设：线程数组不会溢出。这种假设得想办法强制检查。常见做法是检查索引，溢出时向调用者返回错误码。但调用者完全可以无视这个错误。

A better way for such situations, is to use assertions. The C language provides a standard assert() facility, which evaluates the expression and when it turns out to be false, the assert() macro prints a message to the screen and exits the application. Neither of these actions make sense in a deeply embedded programming, where you have no screen to print to and you cannot really exit either.

更好的办法是用**断言**（assertion）。C 语言标准库提供了 `assert()` 宏，它会检查表达式，如果为假就往屏幕打印一条消息然后退出程序。但在深度嵌入式环境下，这两个动作都没意义——没有屏幕可打印，也没地方可退出。

So instead, I use here an embedded systems-friendly assertion Q_ASSERT() that simply checks the expression, and if it turns out to be false, it calls the special callback function Q_onAssert().

所以这里我用的是一种对嵌入式系统友好的断言——`Q_ASSERT()`。它检查表达式，如果为假，就调用一个特殊的**回调函数**（callback function）`Q_onAssert()`。

You have this function already defined in the bsp.c file, because the startup代码 is already using assertions. This function can and should be carefully customized to your specific project. This is your last line of defense after the code already failed. When this happens, you should try to do damage control and log or somehow output the location of the assertion, which is provided in the module and loc parameters. After this, you typically should reset the system, to avoid the denial of service failure. I hope to talk more about assertions and the philosophy called **Design by Contract** in the future lessons.

这个函数你已经在 `bsp.c` 里定义过了，因为启动代码本身就在用断言。这个函数可以也应该根据你的具体项目仔细定制。它是代码出错后的**最后一道防线**。一旦断言失败，你应该做损害控制——记录或输出断言发生的位置（由 `module` 和 `loc` 参数提供）。之后通常应该**复位系统**，避免陷入**拒绝服务**（denial of service）的状态。关于断言和**按契约设计**（Design by Contract）这套理念，我希望后面的课程再细讲。

But going back to the MiROS implementation, to use the embedded systems-friendly assertions, you need to include the "qassert.h" header file.

回到 MiROS 的实现。要用这种嵌入式友好的断言，需要包含 `qassert.h` 头文件。

This file is located in qpc\include directory, so you need to make sure that this directory is in your include search path.

这个文件在 `qpc\include` 目录下，所以你要确保这个目录在你的**头文件搜索路径**（include search path）里。

Speaking of the qpc directory, please make sure that you download and unzip qpc from the state-machine.com/quickstart web-page.

说到 qpc 目录，请确保你已经从 state-machine.com/quickstart 页面下载并解压了 qpc。

Back to the implementation, to use assertions in a given file you also need to define the name string for the file, which you do by placing the macro Q_DEFINE_THIS_FILE at the top.

回到实现上来。要在某个源文件里使用断言，还得定义一个表示文件名的字符串——在文件顶部放上 `Q_DEFINE_THIS_FILE` 宏就行。

Finally, instead of introducing the symbolic name for the number of elements in the array, such as MAX_THREAD here, you can use the Q_DIM() macro defined in the "qassert.h" header file, which provides the array dimension without the need to introduce any additional symbolic names.

最后，与其为数组元素个数单独定义一个符号常量（比如这里的 `MAX_THREAD`），你可以直接用 `qassert.h` 里定义的 `Q_DIM()` 宏。它直接给出**数组维度**，省得再引入额外的名字。

With this preparation in the OSThread_start() function you can get to the most interesting part, which is the actual scheduling inside the OS_sched() function.

`OSThread_start()` 的准备工作做完了，接下来进入最有意思的部分——`OS_sched()` 函数里的实际调度逻辑。

Here you need to increment the index of the currently running thread, which you store in the OS_currIdx variable, and wrap it around to zero when the index reaches the number of threads.

这里需要递增当前运行线程的索引（存在 `OS_currIdx` 变量里），到头了就回绕到零。

You finish the round-robin scheduling by setting the OS_next pointer to the thread at OS_currIdx index. That's all there is to it. You can now build and run the code.

然后把 `OS_next` 指针指向 `OS_currIdx` 索引处的线程——轮转调度就完成了。就这么简单。现在可以编译运行了。

The advantage of this design is that you no longer need to hard-code the threads from the application, because the MiROS RTOS "registers" every newly started thread and automatically includes it in the round-robin scheduling. In fact, to see how easy it is to add a new thread to the system, let's create another blinky-type thread. The new blinky3 thread will blink the red LED, and will use a bit different delays of on and off timeouts to produce some interesting color patterns when combined with the other two blinky threads.

这个设计的好处是：你再也不用从应用程序那边硬编码线程了——MiROS RTOS 会"注册"每个新启动的线程，自动把它纳入轮转调度。为了演示加一个新线程有多简单，我们再来创建一个 blinky 类的线程。新的 blinky3 闪烁红色 LED，开和关的延时稍有不同，这样三个 blinky 线程组合起来会产生有趣的色彩效果。

As you can see, the addition of a new thread is confined to the main file and does not require changing any of the existing threads or the RTOS code.

如你所见，加新线程只涉及 main 文件，不需要改任何已有的线程代码或 RTOS 代码。

This property of threads is called composability. Please note that threads became composable only after adding the RTOS, because without it you could not easily combine them to run seemingly simultaneously and independently from each other.

线程的这个特性叫做**可组合性**（composability）。注意，只有在加了 RTOS 之后线程才变得可组合——没有 RTOS，你很难让它们看起来同时、独立地运行。

OK, so now let's talk about the next aspect of the MiROS RTOS that needs improvement, and that is the initialization timeline and specifically the configuring and enabling of interrupts.

好，接下来聊聊 MiROS RTOS 需要改进的第二个方面——**初始化时序**（initialization timeline），特别是中断的配置和使能。

Currently, your code starts and enables interrupts already in the BSP_init() function.

目前，你的代码在 `BSP_init()` 函数里就已经启动和使能了**中断**（interrupt）。

This is too early,

这太早了。

because if an interrupt were to fire before you reach the end of main, such an interrupt might trigger a context switch which takes the control away from main and never really returns. This means that some important initialization code might not get executed and some of your threads might not get started.

因为如果中断在 `main` 函数结束之前就触发了，它可能引发上下文切换，把控制权从 `main` 抢走，再也回不来。这就意味着一些重要的初始化代码可能不会执行，某些线程可能根本启动不了。

The correct timeline of RTOS initialization is for the system to configure and start interrupts only after all threads have been started. This means that the right place to do this is at the end of main.

RTOS 初始化的正确时序应该是：所有线程都启动完毕之后，再去配置和开启中断。也就是说，正确的位置是在 `main` 函数末尾。

Here is also the place where you have the ugly while(1) loop. So, let's replace it with a new RTOS API OS_run(). As the name suggests, the OS_run() function is where you will transfer control to the RTOS and ask it to please run your threads. At this point you are done with all initialization and you are ready to receive interrupts. The implementation of OS_run() will begin with calling the OS_onStartup() callback function. Callback means here that the function will not be defined in the RTOS itself, but rather you will need to define it in the application. The OS_onStartup() function is where you will configure and enable interrupts.

这里还有那个不太好看的 `while(1)` 循环。我们用一个新的 RTOS API——`OS_run()` 来替代它。顾名思义，`OS_run()` 是你把控制权交给 RTOS、让它去跑线程的地方。到这一步，所有初始化工作都做完了，可以接收中断了。`OS_run()` 的实现首先调用 `OS_onStartup()` 回调函数。所谓回调，就是说这个函数不是在 RTOS 内部定义的，而是需要你在应用程序里定义。`OS_onStartup()` 就是你配置和使能中断的地方。

Next, the OS_run() will call the scheduler to run the first thread. This call will be identical as in your SysTick_Handler(), but this time you call the scheduler outside the interrupt context.

接下来，`OS_run()` 调用调度器运行第一个线程。这个调用跟 `SysTick_Handler()` 里的完全一样，只不过这次你是在**中断上下文**（interrupt context）之外调用的。

I hope you remember from the previous lessons on RTOS that the context switch can only happen immediately after an interrupt, because the whole stack layout assumes that the thread is switched as a return from an exception. But this is okay here, because the scheduler is not performing the context switch directly, but instead it triggers the PendSV exception, which then correctly returns to the next thread to run.

希望你还记得前面 RTOS 课程里讲过的：上下文切换只能发生在一个中断之后，因为整个**栈布局**（stack layout）假设线程是作为异常返回来切换的。但这里没问题——调度器不是直接做上下文切换，而是触发 **PendSV 异常**（PendSV exception），由它正确地返回到下一个要运行的线程。

The PendSV exception will run immediately after the interrupts are re-enabled, so the control will really never return back to OS_run() and consequently any code after that should never execute.

PendSV 异常会在中断重新使能后立即执行，所以控制权实际上永远不会再回到 `OS_run()`。因此 `OS_run()` 后面的代码永远不应该执行到。

If this is so, then you can use an assertion that always fails. You could code it as Q_ASSERT(0), but the "qassert.h" header file provides a more descriptive assertion for such occasions called Q_ERROR().

既然如此，你就可以放一个永远失败的断言。可以写成 `Q_ASSERT(0)`，但 `qassert.h` 提供了一个更直观的宏——`Q_ERROR()`，就是专门干这个的。

To finish off, you still need to declare the prototypes of the new RTOS APIs in the miros.h header file.

最后，别忘了在 `miros.h` 头文件里声明新 RTOS API 的函数原型。

When you try to build now, you fail, because the OS_onStartup() callback function is missing. This is a very good reminder that you still need to define this application-specific function in your bsp.c file. To get the body of the OS_onStartup() function, you simply cut and paste the portion of the BSP_init() that deals with configuring and enabling interrupts.

编译一下，果然失败了——缺少 `OS_onStartup()` 回调函数。这是一个很好的提醒：你还需要在 `bsp.c` 里定义这个与应用相关的函数。函数体很简单，把 `BSP_init()` 里配置和使能中断的那部分代码剪切粘贴过来就行。

The last instruction to enable interrupts is redundant, because the OS_run() function disables and re-enables interrupts anyway.

最后那条使能中断的指令是多余的，因为 `OS_run()` 函数内部会先关中断再开中断。

This time, the code compiles and links without errors or warnings.

这一次，编译和链接都通过了，没有错误也没有警告。

Let's quickly step through the main parts of the code in the debugger.

让我们在调试器里快速过一遍代码的主要部分。

Place a breakpoint in OS_run() and watch how it disables interrupts and calls the scheduler. The scheduler increments the OS_currIdx index, checks for the wrap-around and sets OS_next to the address of blinky2 thread.

在 `OS_run()` 里设一个**断点**（breakpoint），观察它如何关中断、调用调度器。调度器递增 `OS_currIdx` 索引，检查是否需要回绕，然后把 `OS_next` 设为 blinky2 线程的地址。

The next interesting breakpoint is inside PendSV_Handler, where you can see how it returns to the next thread, which is blinky2 in this case.

下一个值得关注的断点在 `PendSV_Handler` 里面——你可以看到它如何返回到下一个线程，这里是 blinky2。

Finally, when you remove the breakpoints, you can watch the LEDs of all three colors blink as the three blinky threads run simultaneously.

最后去掉断点，就能看到三种颜色的 LED 同时闪烁——三个 blinky 线程在并发运行。

As the MiROS RTOS finally runs truly autonomously, I thought that in the last couple of minutes of this lesson you might be interested to find out how fast it is.

MiROS RTOS 终于能够真正自主运行了。本课最后几分钟，我想你可能会好奇它跑得有多快。

For these measurements, I will use a mixed signal oscilloscope with a logic analyzer connected to the following pins of the TivaC LaunchPad board: the Red LED, the Blue LED, the Green LED, a couple of Ground Pins, and

为了做这些测量，我会用一台**混合信号示波器**（mixed signal oscilloscope），配合**逻辑分析仪**（logic analyzer），连接到 TivaC LaunchPad 板的以下引脚：红色 LED、蓝色 LED、绿色 LED、几个接地引脚，还有——

I'll also use the PF4 as a test pin.

我还会用 PF4 作为测试引脚。

The first view shows the signals D1 through D4, which correspond to PF1 through PF4 and the line colors match to the colors of attached LEDs. As you can see the signals change as the LEDs blink, but the changes are so slow that it's difficult to measure the context switch time. What you need is a much faster ongoing activity on each pin, such as toggling the pin up and down but without delays in between.

第一个视图显示的是 D1 到 D4 四路信号，对应 PF1 到 PF4，线条颜色跟 LED 颜色对应。可以看到信号随 LED 闪烁在变化，但变化太慢了，没法测量上下文切换的时间。你需要的是每个引脚上更快的持续活动——比如让引脚不停地**翻转**（toggle），中间不要加延时。

This is simple enough to achieve by simply commenting out the BSP_delay() function calls in the thread handlers.

这很容易做到——把线程处理函数里的 `BSP_delay()` 调用注释掉就行。

But you would also need a trigger to know when a context switch occurs. For this you will need yet another test pin, like the PF4, which is still unused.

但你还需要一个**触发信号**（trigger）来标记上下文切换发生的时刻。为此你需要另一个测试引脚，比如 PF4——它还没被用到。

To provide the trigger for context switch, you can use the SysTick_Handler to drive the TEST_PIN up and down. Since the TEST_PIN is an output pin, you need to configure it as such in the BSP_init() function.

要产生上下文切换的触发信号，可以在 `SysTick_Handler` 里驱动 TEST_PIN 上下翻转。TEST_PIN 是输出引脚，所以要在 `BSP_init()` 里把它配置为输出。

When you load this code to the board, you get a very different picture. The LEDs all glow with varying intensity, as they switch far too fast for the human eye to see the individual flashes of light.

把代码烧到板子上后，画面完全不一样了。LED 以不同的亮度发光——切换速度太快，人眼根本分辨不出单独的闪烁。

In the logic analyzer, you can see the pins rapidly toggling up and down, but you can also clearly see that the activities are mutually exclusive meaning that only one pin at a time keeps switching while others stay the same either up or down.

逻辑分析仪上能看到引脚在快速上下翻转，但也能清楚看到这些活动是**互斥的**（mutually exclusive）——同一时刻只有一个引脚在翻转，其他引脚保持高或低不变。

You can also see that the switching of activities occurs only when the line D4 corresponding to your TEST_PIN is activated. So, let's set the trigger to the raising edge of D4.

还能看到，活动切换只发生在 TEST_PIN 对应的 D4 线被激活的时候。所以把触发条件设为 D4 的**上升沿**（rising edge）。

Now, the context switch is always centered on the screen, and we can conveniently zoom in to see the details.

现在上下文切换时刻总是居中显示在屏幕上，方便我们放大看细节。

So, let's perform a couple of measurements. First, let's measure the time between the last activity of a thread and the trigger, which is at the beginning of the SysTick interrupt.

来做几项测量。首先，测量线程最后一次活动到触发信号之间的时间——触发信号在 **SysTick 中断**（SysTick interrupt）的开始处。

To see the measured value, I need to activate the analog view.

要看到测量值，我得切换到模拟视图。

And the value turns out to be around 400 ns.

结果大约是 **400 纳秒**。

To convert this value into the CPU clock ticks, you need to multiply the delay by the clock frequency. The basic rule of thumb is that every megahertz in clock frequency corresponds to one clock tick per microsecond. Your TivaC LaunchPad runs at 50 MHz, so you have 50 clock ticks per microsecond.

把这个值换算成 **CPU 时钟周期**（CPU clock ticks），需要把延时乘以时钟频率。一个简单的经验法则：每 1 MHz 时钟频率对应每微秒 1 个时钟周期。你的 TivaC LaunchPad 跑在 50 MHz，所以每微秒 50 个时钟周期。

You multiply this by 400 nanoseconds, which converts to 0.4 microseconds. And the result is 20 clock cycles.

400 纳秒就是 0.4 微秒，乘以 50，结果是 **20 个时钟周期**。

Similarly, you can measure the time spent inside the SysTick_Handler, which turns out to be about 1.6 microseconds. This corresponds to 80 clock cycles.

类似地，可以测量 `SysTick_Handler` 内部花了多少时间——大约 1.6 微秒，对应 **80 个时钟周期**。

And finally, perhaps the most interesting measurement is the context switching time after the SysTick exits but before the next thread starts toggling a pin. This time turns out to be about 1.5 microseconds, which represents 75 clock cycles.

最后，也许最有趣的测量是：SysTick 退出之后、下一个线程开始翻转引脚之前，这段上下文切换的时间。大约 1.5 微秒，也就是 **75 个时钟周期**。

The overall time between suspending one thread and resuming another is about 3.5 microseconds, which represents 175 clock cycles.

从挂起一个线程到恢复另一个线程，总耗时约 **3.5 微秒**，也就是 **175 个时钟周期**。

This last measurement could be used to estimate the overhead of your RTOS, which is the ratio of the CPU time spent inside the RTOS for things like scheduling and context switching to the total CPU time. This ratio is 3.5 microseconds multiplied by 100 clocks per second and divided by one million microseconds in a second. This turns out to be only 0.00035 which is not even one tenth of a percent. Even if you increased the system clock tick to 1000 times per second, that is 1kHz, the RTOS overhead would be still only 0.3 percent, so as you can see the overhead of the RTOS is quite small.

最后一项测量可以用来估算 RTOS 的**开销**（overhead）——就是 RTOS 用于调度和上下文切换等操作所占的 CPU 时间比例。按 3.5 微秒乘以每秒 100 次节拍，再除以一秒（100 万微秒）来算，结果是 0.00035，连千分之一都不到。即使把系统时钟节拍提高到每秒 1000 次（即 1kHz），RTOS 的开销也只有 0.3%。所以你看，RTOS 的开销是相当小的。

This concludes this lesson on round-robin scheduling. The MiROS RTOS is getting better, but there are still huge opportunities for improvement. The main such opportunity is to do something about the horrible waste of CPU cycles inside the BSP_delay() function.

本课关于轮转调度就到这里。MiROS RTOS 越来越完善了，但还有很大的改进空间。最大的改进机会就是处理 `BSP_delay()` 函数里对 CPU 周期的严重浪费。

With the context switch magic under your control, you could use it to switch the context away from a delayed thread and switch it back only when the delay has elapsed. Such efficient waiting is called **blocking** and it will be the subject of the next lesson on RTOS.

有了上下文切换这个法宝，你可以把延迟中的线程切换出去，等延迟到期了再切回来。这种高效的等待方式叫做**阻塞**（blocking），就是下一课 RTOS 的主题。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅保持关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Round-Robin Scheduling | 轮转调度 | 以循环顺序依次运行各线程的调度算法 |
| Context Switch | 上下文切换 | 从一个线程切换到另一个线程，包括保存和恢复寄存器状态 |
| Scheduler | 调度器 | RTOS 中负责决定下一个运行哪个线程的组件 |
| Refactoring | 重构 | 改进代码内部设计而不改变其外部行为 |
| Composability | 可组合性 | 软件组件能够自由组合而不需修改各组件内部代码的特性 |
| Assertion | 断言 | 运行时检查假设条件的机制，条件为假时报告错误 |
| `Q_ASSERT()` | 嵌入式断言宏 | Quantum Platform 提供的适合嵌入式系统的断言宏 |
| `Q_ERROR()` | 错误断言宏 | 永远失败的断言，用于标记不应执行的代码路径 |
| Design by Contract | 按契约设计 | 通过前置条件、后置条件和不变式来验证程序正确性的软件设计理念 |
| Callback Function | 回调函数 | 由应用程序定义但由框架或 RTOS 调用的函数 |
| `OS_run()` | RTOS 运行函数 | 将控制权转交给 RTOS 的 API，通常永远不会返回 |
| `OS_onStartup()` | 启动回调 | 应用程序定义的回调函数，用于在 RTOS 开始运行前配置和使能中断 |
| PendSV Exception | PendSV 异常 | ARM Cortex-M 中用于实现上下文切换的可挂起系统服务异常 |
| SysTick Interrupt | SysTick 中断 | ARM Cortex-M 中提供周期性系统时钟节拍的定时器中断 |
| Interrupt Context | 中断上下文 | CPU 在处理中断服务例程时所处的特殊执行模式 |
| Stack Layout | 栈布局 | 线程或异常栈帧中寄存器和数据的排列方式 |
| Linked-List | 链表 | 元素通过指针相互链接的动态数据结构 |
| Pre-allocated Array | 预分配数组 | 编译时或初始化时固定大小的数组，避免动态内存分配 |
| Trigger | 触发信号 | 示波器或逻辑分析仪中用于确定何时开始采集数据的信号条件 |
| Rising Edge | 上升沿 | 数字信号从低电平跳变到高电平的瞬间 |
| Toggle | 翻转 | 将数字信号从高变低或从低变高的操作 |
| Mutually Exclusive | 互斥的 | 同一时间只能有一个活动发生的状态 |
| CPU Clock Ticks | CPU 时钟周期 | CPU 执行指令的基本时间单位，与时钟频率相关 |
| Overhead | 开销 | RTOS 用于管理和调度所占用的额外 CPU 时间 |
| Blocking | 阻塞 | 线程主动放弃 CPU 并等待某个条件满足的机制 |
| `Q_DEFINE_THIS_FILE` | 文件定义宏 | 用于断言中标识源文件名的宏 |
| `Q_DIM()` | 数组维度宏 | Quantum Platform 提供的获取数组元素数量的宏 |
| Mixed Signal Oscilloscope | 混合信号示波器 | 能同时显示模拟和数字信号的测试仪器 |
| Logic Analyzer | 逻辑分析仪 | 捕获和显示多个数字信号时序关系的测试仪器 |
| Initialization Timeline | 初始化时序 | 系统启动过程中各初始化步骤的先后顺序 |
| Denial of Service | 拒绝服务 | 系统因故障无法提供正常服务的状态 |
