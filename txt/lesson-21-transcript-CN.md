# 第21课：前后台架构 / Lesson 21: Foreground/Background Architecture

Welcome to the Modern Embedded Systems Programming course. I'm sorry for my long absence since posting lesson 20, but I'd like to make it up to you by announcing a new group of lessons about the architecture and design of embedded software.

欢迎来到现代嵌入式系统编程课程。很抱歉第20课之后消失了这么久，不过好消息是——接下来我会推出一组全新的课程，专门讲嵌入式软件的**架构与设计（architecture and design）**。

Today I am going to introduce the ubiquitous foreground-background architecture, also known as the super-loop or main+interrupts. Apart from being interesting in its own right, foreground/background is the starting point for all embedded software architectures and, among others, is an important stepping stone to understanding a Real-Time Operating System (RTOS), which was perhaps the most requested subject for me to explain. So, you can view this lesson as a prerequisite for the upcoming lessons about the RTOS as well as other architectures.

今天我们来聊聊无处不在的**前后台架构（foreground-background architecture）**，也叫**超级循环（super-loop）**或者 **main+中断**。前后台架构本身就很有意思，更重要的是，它是所有嵌入式软件架构的起点，也是理解**实时操作系统（RTOS）**的重要阶梯——RTOS 可能是大家呼声最高、最想让我讲的主题了。所以，你可以把本课当作后续 RTOS 课程和其他架构课程的前置准备。

To follow along today's lesson you need to download two pieces of code from the companion website to this course at state-machine.com/quickstart. The first is the lesson21 project that I prepared in advance, and the second piece is the 'qpc' framework, which you will use in most of the upcoming lessons in this group.

要跟着做今天的课程，你需要从本课程的配套网站 state-machine.com/quickstart 下载两份代码。一份是我预先准备好的 lesson21 项目，另一份是 **qpc 框架**，接下来这组课程的大部分内容都会用到它。

You need to unzip these two downloads into the embedded-programming directory on your disk.

把这两份下载解压到你磁盘上的 embedded-programming 目录里就行了。

This lesson also uses the ARM-Keil MDK toolset from the ARM company instead the Eclipse-based Code Composer Studio from Texas Instruments. The reason for this change is that I ran into problems with the latest CCS 7.3, which was simply blocked by my anti-virus software. I made all sorts of attempts to reconcile the CCS with my anti-virus, but I ultimately failed. This is, among others, one reason why this group of lessons took longer to prepare.

本课还有一个变化——我们不再用德州仪器基于 Eclipse 的 Code Composer Studio，改用 ARM 公司的 **ARM-Keil MDK** 工具集。原因是我用最新的 CCS 7.3 时遇到了问题：它被杀毒软件直接拦截了。我试了各种办法想让 CCS 跟杀毒软件和平共处，但最后都没搞定。这也是这组课程准备时间比预期长的一个原因。

In the end, I decided to treat this setback as an opportunity to introduce you to the third, very popular and excellent ARM-Keil MDK toolset, which is just as good as the IAR toolset, and in my option easier to use than Eclipse.

不过换个角度想，我索性把这个挫折变成一个机会——正好向大家介绍第三个非常流行、非常优秀的工具集：ARM-Keil MDK。它跟 IAR 工具集一样出色，而且在我看来比 Eclipse 更好用。

To get Keil MDK, you can start from ARM.com and choose the "Development Tools -> Microcontroller and Embedded Development" menu. Alternatively, you can simply google for "Keil MDK". Either way, you will land on this main MDK page.

要获取 Keil MDK，你可以去 ARM.com，选 "Development Tools -> Microcontroller and Embedded Development" 菜单。或者直接搜 "Keil MDK" 也行。两种方式最后都会到 MDK 的主页面。

As you can see in the comparison of available MDK editions, there is a free, code-size limited Lite version, which will be perfectly adequate for all projects in this video course.

在 MDK 版本对比中可以看到，有一个免费的、代码大小受限的 Lite 版本。别担心，对于我们这个视频课程里的所有项目来说，Lite 版完全够用。

Click on the Download button and fill out the usual download form. Click the Submit button.

点击 Download 按钮，填一下常规的下载表单，然后点 Submit。

While you install the Keil MDK toolset, you might want to familiarize yourself with the documentation. The toolset comes with the Getting Started videos and a guide in PDF.

安装 Keil MDK 的过程中，你可以顺便看看它的文档。工具集附带了入门视频和 PDF 格式的使用指南。

So, assuming that you have successfully installed ARM Keil MDK toolset, you can go to the lesson21 directory you have just downloaded and click on the provided uVision project file.

好，假设你已经成功安装了 ARM Keil MDK，接下来进入刚下载的 lesson21 目录，双击里面的 **uVision 项目文件**就行。

When you run the Keil uVision IDE for the first time, you might need to register the license, which in my case is MDK-Lite Evaluation Version. You can get this license online by clicking on "Get LIC via Internet".

第一次打开 Keil uVision IDE 时，可能需要注册许可证，我这里用的是 MDK-Lite Evaluation Version。点击 "Get LIC via Internet" 就可以在线获取。

Also, the first time you open a project for the TivaC LaunchPad board, you might need to install the so called "Software Pack". You open the Pack Installer and select the Texas Instruments, TivaC Series, TM4C123x Series pack, which includes your specific microcontroller.

另外，第一次给 TivaC LaunchPad 开发板打开项目时，你可能需要安装所谓的**软件包（Software Pack）**。打开 Pack Installer，选择 Texas Instruments、TivaC Series、TM4C123x Series 这个包，里面包含了你使用的具体微控制器。

OK, so finally you can get to the code for today's lesson that is actually very similar to what you had back in lesson 8 in that it simply blinks the green LED on your TivaC LauchPad board.

好了，终于可以看今天课程的代码了。这段代码其实跟第8课的很像——就是在 TivaC LaunchPad 开发板上闪烁绿色 LED。

The only difference from the previous version is the delay() function, now called BSP_delay(), because it is defined in the Board Support Package (BSP), which you first encountered in lesson-15. In this lesson you will see how to take the concept of the Board Support Package to the next level.

跟之前版本唯一的区别是 delay() 函数，现在改名叫 **BSP_delay()** 了，因为它定义在**板级支持包（BSP）**里——你第一次接触 BSP 是在第15课。本课中你会看到怎么把板级支持包的概念用到更高的水平。

Before you go any further, let's just build this version of the Blinky program and check that it still works by opening it in the micro-Vision debugger.

在继续之前，我们先构建一下这个版本的 Blinky 程序，然后在 uVision 调试器中打开它，确认一切正常。

When you run the program, you can see that the Green LED blinks by staying on for about a quarter of a second and off for about three quarters of a second. Now, going back to the editing mode, let me explain a few things about the BSP_delay() function.

运行程序后可以看到，绿色 LED 闪烁——亮大约四分之一秒，灭大约四分之三秒。现在回到编辑模式，我来解释一下 BSP_delay() 函数的几个要点。

Unlike the previous crude delay() implementation from lesson-8, BSP_delay() is based on the SysTick interrupt, which delivers more precise timing, because it does not depend on the speed of the compiler-generated code.

跟第8课那个粗糙的 delay() 实现不同，BSP_delay() 基于 **SysTick 中断**，定时精度更高，因为它不依赖编译器生成代码的执行速度。

In this new implementation, the SysTick interrupt is programmed to fire at a rate of BSP_TICKS_PER_SEC, which is defined as a hundred times per second in the bsp.h header file. This BSP_TICKS_PER_SEC constant is subsequently used to configure the SysTick interrupt.

在这个新实现中，SysTick 中断被配置为以 **BSP_TICKS_PER_SEC** 的频率触发，这个常量在 bsp.h 头文件中定义为每秒 100 次。随后就用这个 BSP_TICKS_PER_SEC 常量来配置 SysTick 中断。

The SysTick interrupt handler simply increments the local l_tickCtr variable, which is declared both static and volatile.

SysTick 中断处理程序做的事情很简单——递增局部变量 l_tickCtr，这个变量同时声明为 **static** 和 **volatile**。

The 'volatile' qualifier has been introduced back in lesson-5, but here let me quickly remind you that when you declare a variable to be "volatile", you are telling the compiler that the variable might change unexpectedly even though no currently performed program instructions change it, which is exactly what can happen when a variable is modified in an interrupt.

**volatile** 限定符早在第5课就介绍过了。这里快速复习一下：当你把一个变量声明为 volatile，就是在告诉编译器——这个变量可能会"莫名其妙"地改变，即使当前执行的代码并没有修改它。变量在中断里被修改就属于这种情况。

The BSP_tickCtr() function simply reads and returns the current value of l_tickCtr variable. But as you surely remember from the last lesson-20, to avoid any race conditions between the SysTick interrupt and the code that calls BSP_tickCtr(), the access to such a variable must occur in a critical section, that is, with interrupts disabled.

**BSP_tickCtr()** 函数做的事很简单——读取并返回 l_tickCtr 的当前值。但正如你在第20课中学到的，为了避免 SysTick 中断和调用 BSP_tickCtr() 的代码之间出现**竞态条件（race condition）**，对这类变量的访问必须在**临界区（critical section）**里进行——也就是说，要先把中断关掉。

Finally, the BSP_delay() function first reads the tick counter and stores it in the automatic variable 'start'. Next, it enters a polling while-loop, which constantly reads the tick counter value and computes the difference from the start. The loop continues as long as the difference is smaller than the specified number of clock ticks.

最后，BSP_delay() 函数先读取节拍计数器的值，存到自动变量 `start` 里。然后进入一个**轮询 while 循环**，不断读取节拍计数器的值，算出跟起始值的差。只要差值还小于你指定的节拍数，循环就继续。

Please note that the 2's complement arithmetic, which I discussed in lesson 2, handles properly the discontinuity when the tick counter rolls over from all-Fs to 0.

顺便说一下，第2课讲过的**二进制补码运算（2's complement arithmetic）**在这里帮了大忙——它能正确处理节拍计数器从全 F 翻转到 0 时不连续的问题。

At the end of the day, however, the BSP_delay() implementation, just like the previous, crude delay() function, is based on the same primitive idea of polling, so it ends up wasting all the CPU cycles until the specified number of clock ticks elapse.

不过说到底，BSP_delay() 的实现跟之前那个粗糙的 delay() 本质上是一样的——都是基于原始的**轮询（polling）**思路，所以在指定的节拍数耗尽之前，CPU 周期全都被浪费掉了。

However, for this lesson, the most important point is that the software structure of the Blinky program has all the characteristics of the so called *foreground/background architecture* also known as "main+ISRs", which is very common in smaller embedded systems.

但这节课最关键的一点是：Blinky 程序的软件结构具备所谓**前后台架构**（也叫 "main+ISRs"）的全部特征，这种架构在小型嵌入式系统中非常常见。

As the name suggests, the architecture consists of two main parts: the endless *background* loop inside the main() function and the interrupt handlers, like your SysTick_Handler() and possibly others, comprising the *foreground*. The interrupts running in the foreground preempt the background loop, but they always return to the point of preemption.

顾名思义，这个架构由两大部分组成：main() 函数里那个永不退出的**后台（background）**循环，以及像 SysTick_Handler() 这样可能还有其他的中断处理程序——它们组成了**前台（foreground）**。前台的中断会**抢占（preempt）**后台循环，但处理完后总是回到被抢占的位置继续执行。

The two parts of the system communicate with each other by means of shared variables, like l_tickCtr. To avoid race conditions due to preemption of the background loop by the foreground interrupts, these shared variables should be defined as volatile and must be protected by briefly disabling interrupts around any access to them from the background.

这两部分之间通过**共享变量**（比如 l_tickCtr）来通信。为了避免前台中断抢占后台循环时出现竞态条件，这些共享变量必须定义为 volatile，并且在后台访问它们的时候，要通过短暂关中断来保护。

The timing of the execution of the various functions called from the background loop is not well defined, because it depends on the time spent inside the loop that typically varies from one pass through the loop to another due to conditional branching in the code and interrupt activity.

从后台循环调用的各个函数，执行**时序（timing）**是不确定的，因为每次循环花费的时间都不一样——代码里有条件分支，中断也不定时地来打扰一下，都会影响时间。

For these reasons, any operations with strict time constraints cannot be reliably performed from the background loop and must be pushed to the interrupt level running in the foreground. However, this tends to make the interrupts longer and they might start to interfere with the background loop and with each other.

正因如此，有严格时间约束的操作不能指望后台循环来做，必须推到前台的中断级别去处理。但这样一来中断就会变长，可能开始干扰后台循环，甚至中断之间互相干扰。

Still, due to its simplicity, the foreground/background architecture is very popular in high-volume embedded applications, such as consumer electronics, home appliances, toys, remote controllers, and countless others.

尽管如此，前后台架构因为简单直接，在大批量嵌入式产品中非常受欢迎——消费电子、家电、玩具、遥控器，数不胜数。

Foreground/background is also exactly the architecture used in various maker platforms, such as Arduino. Here, for example is the Arduino version of the Blinky program.

各种创客平台用的也是前后台架构，比如 **Arduino**。这里展示的就是 Arduino 版本的 Blinky 程序。

At the first glance, you might not recognize it as a foreground/background, because Arduino hides it inside its library. But if you take a look at the main function inside the Arduino library, you should immediately recognize the familiar background architecture consisting of initialization, the setup() function, and the endless loop, repetitively, calling the loop() function.

乍一看你可能认不出这是前后台架构，因为 Arduino 把它藏在库里面了。但如果你去看 Arduino 库内部的 main 函数，应该马上就能认出那个熟悉的后台结构——先是初始化（setup() 函数），然后就是一个反复调用 loop() 的无限循环。

Note that the for-loop with empty control is equivalent to the while(1) loop and is a C-language idiom that means for-ever.

注意，那个空控制条件的 for 循环跟 while(1) 是等价的，这是 C 语言中表示"永远循环"的习惯写法。

Arduino has, of course, also the foreground level consisting of interrupt handlers. Here, for example, is the system clock tick Interrupt Service Routine (ISR), which increments some counters, just like your SysTick handler. There is also, of course, the matching polling delay(), which is perhaps the most frequently used function in Arduino programs.

Arduino 当然也有前台层，由各种中断处理程序组成。比如这个系统时钟节拍**中断服务程序（ISR）**，它递增一些计数器——跟你的 SysTick 处理程序一样。当然还有配套的轮询 delay() 函数，这大概是 Arduino 程序里用得最多的函数了。

Now, let's go back to your Blinky background code and notice that you can still organize it a bit better. For example, the initialization part is board-specific, so it logically belongs to the Board Support Package (BSP).

现在回到你的 Blinky 后台代码，看看还能怎么改进。比如，初始化部分是跟具体开发板相关的，逻辑上应该放到**板级支持包（BSP）**里。

So, let's make a BSP_init() function inside the BSP module, place all the initialization code there, and call it from main.

那我们就在 BSP 模块里建一个 BSP_init() 函数，把所有初始化代码放进去，然后从 main 里调用它。

Next, notice that switching the LEDs on and off is also board-specific, meaning that the code will need to change if you used a different board with LEDs attached to different pins. Therefore, you should move this code to the BSP as well.

再看，开关 LED 也是跟具体开发板相关的——换一块 LED 接在不同引脚的板子，代码就得改。所以这部分也应该移到 BSP 里。

Specifically, inside the BSP module you can create BSP functions to turn LEDs of various colors on and off.

具体来说，在 BSP 模块里创建一组函数，分别用来开关各种颜色的 LED。

Once the functions are defined, you can simply call them from the background loop. Of course, you need to add the prototypes of all the new BSP functions to the BSP header file.

函数定义好了之后，直接从后台循环里调用就行。当然，别忘了把所有新 BSP 函数的**原型（prototype）**加到 BSP 头文件里。

And finally, notice that now you can remove all board-specific stuff from the main code, such as the MCU header file, the LEDs pin numbers, etc. You can move all this stuff into bsp.c, because your background loop no longer depends on any of these details.

最后你会发现，现在可以从主代码里把所有板级相关的东西都删掉了——MCU 头文件、LED 引脚号等等。这些东西全都可以移到 bsp.c 里，因为你的后台循环已经不再依赖这些细节了。

As you can see the code compiles and links error-free. The end effect is that your main code is completely insulated from the board. The background code only specifies WHAT needs to be done, while the BSP code specifies HOW to do it.

可以看到，代码编译链接都没有错误。最终的效果是：你的主代码跟具体开发板完全隔离开了。后台代码只负责描述**做什么（WHAT）**，而 BSP 代码负责**怎么做（HOW）**。

This way of separating concerns (the WHAT from the HOW) has many advantages. First, your main code is smaller and self-explanatory. You really don't need comments to understand what's going on.

这种**关注点分离（separation of concerns）**——把"做什么"和"怎么做"分开——好处很多。首先，主代码变得简短且一目了然，真的不需要注释就能看懂。

The second advantage is that you could run this main code on a different board or you could use a different development toolchain. Of course, you would need to provide a different BSP implementation in the bsp.c file, but you don't need to change a single line of your main application code. It is even possible to run your main application on a desktop PC, which is not an embedded board at all.

第二个好处是可移植性——你可以把这段主代码拿到别的开发板上跑，或者换一套开发工具链。当然，bsp.c 文件里需要提供不同的 BSP 实现，但主应用程序代码一行都不用改。甚至可以在桌面 PC 上跑你的主程序——而 PC 根本不是嵌入式开发板。

Now, let's check experimentally where your Blinky program spends the most of its time by simply breaking into the running code. As you can see, the program stops in BSP_tickCtr() function.

现在来做个实验——在程序运行时直接暂停，看看它大部分时间都在干什么。可以看到，程序停在了 BSP_tickCtr() 函数里。

When you inspect the call stack view, you can see that BSP_tickCtr() is called from BSP_delay(), which in turn is called from main at the shown location. In fact, you have almost no chance at all to find this program doing anything else than delaying its execution.

查看**调用栈（call stack）**可以发现，BSP_tickCtr() 被 BSP_delay() 调用，而 BSP_delay() 又是从 main 里调过来的。实际上，你几乎不可能看到这个程序在干延迟以外的事情。

When you draw a flowchart of this background code you can see arrows going *backwards* the flow of control. These are the polling loops where the code spends the most of its time, and therefore they are shown with thick lines.

如果你画出这段后台代码的**流程图（flowchart）**，会发现有些箭头是**往回指**的——这些就是轮询循环，代码的大部分时间都耗在这里，所以用粗线标注。

I will call this type of code both *blocking* and *sequential*.

我把这种代码称为**阻塞的（blocking）**和**顺序的（sequential）**。

The code is *blocking*, because it waits for events (such as a timeout event after expiration of a delay) in-line and does not progress until the expected event arrives. Once the event arrives, however, the code naturally progresses directly to handling the event because the code downstream the blocking call provides the right context for the expected event.

说它是**阻塞的**，是因为它会原地等待事件（比如延迟到期后的超时事件），不等到就不往下走。不过一旦事件来了，代码自然就能接着处理——因为阻塞调用后面的代码刚好提供了处理这个事件所需的上下文。

The code is *sequential*, because the sequence of expected events is hard-coded in the sequence of instructions. For example, the Blinky program expects a timeout event of a duration of 1/4 second after turning the Green LED on, and another timeout event of duration 3/4 of a second after turning the Green LED off. But it is also possible to arrange the background code differently in a non-blocking fashion, without the polling loops that busy-wait for specific events.

说它是**顺序的**，是因为预期事件的顺序直接硬编码在指令序列里。比如 Blinky 程序在开绿灯后期望等 1/4 秒超时，关绿灯后期望等 3/4 秒超时。不过后台代码也可以换一种写法——用**非阻塞（non-blocking）**的方式组织，去掉那些忙等特定事件的轮询循环。

To show this alternative, I make the sequential implementation inactive by surrounding it with `#if 0 ... #endif`.

为了演示这种替代方案，我先用 `#if 0 ... #endif` 把顺序实现屏蔽掉。

Now, I add the new non-blocking version of the background loop. When you build and debug this version, you can see that it blinks exactly as before.

然后加上新的非阻塞版本的后台循环。构建并调试这个版本，你会发现闪烁效果跟之前完全一样。

But when you break into the code, you can see that it always stops inside the main loop rather than inside some other function.

但当你暂停程序时，会发现它总是停在主循环里，而不是某个别的函数里。

When you look at the flowchart of the non-blocking background code, you can see that no arrows in the flowchart go backwards. Instead, all arrows point forwards without blocking the main background loop, so the program spends the most of its time right in the main loop, as indicated by the heavy lines.

看非阻塞后台代码的流程图，你会发现没有箭头往回指。所有箭头都朝前走，不会阻塞主后台循环，所以程序大部分时间都花在主循环里——粗线标的就是。

Compared to the sequential and blocking version, the non-blocking main loop spins hundreds of thousand times per second instead of only once per second in the sequential code. This means that the main loop can handle events as soon as they arrive in the order in which they arrive. In other words, the non-blocking code is driven by events, and therefore I will call it *event-driven*.

跟顺序阻塞版本比，非阻塞的主循环每秒能转几十万次，而顺序代码每秒才转一次。这意味着主循环可以在事件到达时立刻处理，按到达的顺序来。换句话说，非阻塞代码是由**事件驱动的（event-driven）**，所以我叫它**事件驱动的**代码。

Of course, there is a price to pay for this increased flexibility and timeliness of such non-blocking code, and that is the apparent higher complexity. The event-driven code is more complex, because the sequence of events this code can accept is no longer hard-coded in the sequence of instructions.

当然，灵活性和时效性的提升是有代价的——代码明显变复杂了。事件驱动代码之所以更复杂，是因为它能接受的事件序列不再硬编码在指令序列里了。

By the way, the non-blocking code is structured here as a polling state machine. This is unfortunately not the norm. In the majority of real-life projects, you will see rather convoluted and deeply nested IF-THEN-ELSE branching based on the value of many global variables, also known as the "spaghetti code" or a "big ball of mud".

顺便说一下，这里的非阻塞代码被组织成了一个**轮询状态机（polling state machine）**。遗憾的是，实际项目中很少这么整洁。大多数情况下你会看到相当复杂、层层嵌套的 IF-THEN-ELSE 分支，根据一堆全局变量的值来判断——这就是所谓的**面条代码（spaghetti code）**或者**大泥球（big ball of mud）**。

I cannot go into details of state machine in this lesson about foreground/background systems. But I promise to come back to state machines, in several upcoming lessons, actually, as they are fundamentally important in embedded systems programming.

在这堂关于前后台系统的课里，我没法深入讲状态机。但我保证，接下来的好几节课都会回到**状态机（state machine）**这个话题——毕竟它在嵌入式编程中太重要了。

This concludes this lesson about the foreground/background architecture, which is fundamental to understanding all other architectures used in embedded software. You saw that foreground/background can be implemented either using the sequential paradigm with blocking, or with the event-driven and non-blocking paradigm. In the upcoming lessons I will explore all these options, starting with the introduction to Real-Time Operating Systems in the very next lesson!

关于前后台架构的课程就到这里。它是理解嵌入式软件中所有其他架构的基础。你看到了前后台架构既可以用带阻塞的**顺序范式（sequential paradigm）**来实现，也可以用**事件驱动的非阻塞范式（event-driven non-blocking paradigm）**来实现。接下来的课程我会继续探索这些方向，下一课就直接开始介绍**实时操作系统（RTOS）**！

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Foreground/Background Architecture | 前后台架构 | 嵌入式系统中常见的软件架构，由后台无限循环和前台中断处理程序组成 |
| Super-loop | 超级循环 | 前后台架构的别称，指 main() 函数中的无限循环 |
| Main+ISRs | main+中断 | 前后台架构的别称，强调主循环加中断服务程序的结构 |
| RTOS (Real-Time Operating System) | 实时操作系统 | 能在确定时间内响应外部事件的操作系统 |
| Board Support Package (BSP) | 板级支持包 | 硬件抽象层，封装特定开发板的硬件操作细节 |
| SysTick | 系统节拍定时器 | ARM Cortex-M 内置的定时器，常用于产生周期性中断 |
| volatile | volatile 限定符 | 告知编译器变量可能被意外修改的关键字，防止编译器优化 |
| Race Condition | 竞态条件 | 多个并发代码片段访问共享资源时，结果取决于执行顺序的问题 |
| Critical Section | 临界区 | 禁用中断和启用中断之间的代码段，用于保护共享资源的访问 |
| Polling | 轮询 | 通过反复检查条件来等待事件的方式，会浪费 CPU 周期 |
| Preemption | 抢占 | 高优先级代码（如中断）暂时挂起当前正在执行的低优先级代码 |
| Blocking | 阻塞 | 代码原地等待事件，直到事件到达才继续执行的行为 |
| Sequential | 顺序的 | 事件序列硬编码在指令序列中的编程范式 |
| Non-blocking | 非阻塞 | 不原地等待事件，主循环持续运行的处理方式 |
| Event-driven | 事件驱动的 | 代码由事件驱动执行，响应到达的事件而非硬编码序列 |
| State Machine | 状态机 | 一种基于状态和转换的编程模型，用于管理复杂的行为逻辑 |
| Separation of Concerns | 关注点分离 | 将"做什么"与"怎么做"分离的软件设计原则 |
| 2's Complement Arithmetic | 二进制补码运算 | 计算机中表示有符号整数的标准方法，能正确处理计数器翻转 |
| Call Stack | 调用栈 | 程序运行时函数调用的层级关系记录 |
| Spaghetti Code | 面条代码 | 结构混乱、控制流复杂的代码，通常由过度使用全局变量和深层嵌套造成 |
| Big Ball of Mud | 大泥球 | 缺乏清晰架构的软件系统比喻，代码纠缠不清难以维护 |
| Software Pack | 软件包 | Keil MDK 中针对特定微控制器的支持包 |
| ARM-Keil MDK | ARM Keil MDK | ARM 公司提供的微控制器开发工具集 |
| uVision | uVision IDE | Keil MDK 中的集成开发环境 |
