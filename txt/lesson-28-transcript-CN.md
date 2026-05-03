# 第28课：RTOS 互斥机制 / Lesson 28: RTOS Mutual Exclusion

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this seventh lesson on RTOS I'll take a look at sharing resources among concurrent threads, and about the RTOS mechanisms for protecting such shared resources.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。在这第七堂 RTOS 课程中，我们来聊聊并发线程之间的资源共享问题，以及 RTOS 中用来保护共享资源的各种机制。

As usual, let's get started by making a copy of the previous lesson 27 directory and renaming it to lesson 28.

跟以前一样，先把上一课的 lesson 27 目录复制一份，重命名为 lesson 28。

Get inside the new lesson 28 directory and double-click on the uVision project "lesson" to open it.

进入新的 lesson 28 目录，双击 uVision 项目文件 "lesson" 打开它。

To remind you quickly what happened so far, in the last lesson you ported your blinky threads to the professional-grade QP/C real-time framework with the QXK RTOS kernel, which provides a whole assortment of inter-thread communication mechanisms.

快速回顾一下：上一课你把 blinky 线程移植到了专业级的 QP/C 实时框架上，搭配的是 QXK RTOS 内核——它提供了整套的线程间通信机制。

The first such RTOS mechanism you learned about was the semaphore that you applied to synchronize your blinky-2 thread with pressing of the SW1 switch on your TivaC LauchPad board.

你学到的第一个 RTOS 机制是**信号量**（semaphore），你用它来同步 blinky-2 线程和 TivaC LaunchPad 板上 SW1 按键的按下事件。

But, still the threads in your application don't yet interact with each other, whereas in any real-life program the threads need to communicate, coordinate, and otherwise collaborate.

不过目前你的线程之间还没有任何交互。而在实际项目中，线程之间总是需要通信、协调、协作的。

The simplest, and most often used way for threads to interact with each other is to SHARE: variables, functions, and other resources like the various peripheral devices.

线程之间最简单、也最常用的交互方式就是**共享**——共享变量、共享函数、共享各种外设之类的资源。

Please note that such sharing of variables and hardware registers among RTOS threads is allowed in the RTOS in the sense that the RTOS does nothing to prevent it.

注意，在 RTOS 中，线程之间共享变量和硬件寄存器是完全允许的——RTOS 不会做任何事情来阻止你这样做。

This is unlike in the big desktop or server-style operating systems, such as Windows or Linux, where different processes cannot easily share variables and memory-mapped registers, because they run in SEPARATE address spaces.

这跟 Windows、Linux 那些大型桌面或服务器操作系统很不一样。在那些系统里，不同的进程跑在各自**独立的地址空间**中，所以不能随便共享变量和内存映射寄存器。

In contrast, concurrent threads within an RTOS are very lightweight and all run in the SAME address space.

而 RTOS 中的并发线程非常轻量，全都跑在**同一个地址空间**里。

In fact, the C compiler is completely unaware of the context-switch magic and the changes to the stack pointer that happen under the covers. Therefore, the compiler treats the thread-functions the same way as all other functions in the program, so they CAN access any variables and all other memory and hardware registers that are visible to them.

事实上，C 编译器根本不知道背后发生的上下文切换和栈指针变化的那些"魔法"。所以在编译器眼里，线程函数跟程序中其他函数没什么区别——它们可以访问所有对它们可见的变量、内存和硬件寄存器。

However, every instance of sharing of anything among concurrent threads is equivalent to threads crossing their paths in various ways.

不过，并发线程之间只要存在共享，就相当于它们的执行路径产生了交叉。

Therefore, as in real-life, sharing always poses a threat of conflicts and collisions, which now you have to avert by introducing some mechanisms and rules to make sure that only one thread uses the shared resource at any given time.

就像现实生活中一样，共享总会带来冲突和碰撞的风险。你必须引入一些机制和规则来避免这些问题，确保同一时刻只有一个线程在使用共享资源。

In programming these mechanisms are collectively called "mutual exclusion mechanisms", because their goal is to ensure mutually exclusive access to shared resources.

在编程中，这些机制统称为**互斥机制**（mutual exclusion mechanisms），因为它们的目标就是确保对共享资源的互斥访问。

In today's lesson you will learn about the most important "mutual exclusion mechanisms" commonly offered by modern RTOSes.

今天的课程里，你会学到现代 RTOS 中最常用的几种互斥机制。

So, let's start today by introducing some sharing of resources among your blinky threads to first see the problems such sharing might cause.

好，我们先在 blinky 线程之间引入一些资源共享，看看这种共享会带来什么问题。

Actually, let's use today exactly the same form of sharing of the GPIO registers that you already saw in lesson 20 about race conditions. In that lesson you used the GPIOF DATA register, which combines all 8 GPIO bits in one register that becomes then a SHARED resource.

实际上，我们今天就沿用第 20 课讲竞态条件时用过的 GPIO 寄存器共享方式。那堂课里你用的是 GPIOF DATA 寄存器——它把所有 8 个 GPIO 位打包在一个寄存器里，这个寄存器就成了一个**共享资源**。

For example, to implement the LED toggle operation, you can read the GPIOF DATA register, exclusively-OR it with the desired bit, like LED_BLUE in this case, and write it back to GPIOF DATA register.

比如，要实现 LED 翻转操作，你可以先读取 GPIOF DATA 寄存器，跟目标位做异或运算（这里就是 LED_BLUE），然后再写回 GPIOF DATA 寄存器。

This operation can be written more succinctly with the XOR-equals operator as follows.

用异或赋值运算符可以写得更简洁，像这样。

You can now repeat the same operation for the GreenLED as well.

绿色 LED 也可以用同样的方式翻转。

The critical difference between the ledOn/ledOff and ledToggle operations is that the On/Off operations use different registers, while the toggle operations use the **same** GPIOF DATA register. This introduces **sharing** of the DATA register between any threads that would call the toggle operations.

ledOn/ledOff 和 ledToggle 之间有一个关键区别：开/关操作用的是不同的寄存器，而翻转操作用的是**同一个** GPIOF DATA 寄存器。这意味着所有调用翻转操作的线程之间就产生了 DATA 寄存器的**共享**。

So, now after adding the prototypes of the LED toggle operations to the BSP header file, let's use them instead of the LED-On/Off operations inside your blinky threads.

好，现在把 LED 翻转操作的函数原型加到 BSP 头文件里，然后在 blinky 线程中用翻转操作替换掉原来的开/关操作。

Note, however, that now there is only one change of the LED state in the for-loop, which is a bit faster than two changes (on and off) previously. Therefore, to achieve similar CPU utilization as before, you need to increase the number of the loop iterations.

不过要注意，现在 for 循环里只改一次 LED 状态，比之前改两次（开和关）要快一些。所以为了保持差不多的 CPU 利用率，你需要增加循环迭代的次数。

My testing that I did ahead of time shows that 1900 iterations is about right.

我提前测试过了，1900 次迭代差不多。

But speaking of the number of iterations, if you consider the state of the LED after the whole for-loop, it will remain the same after an even number of toggles and will switch after an odd number of toggles.

说到迭代次数——想一下整个 for 循环结束后 LED 的状态：翻转偶数次，LED 状态不变；翻转奇数次，LED 状态改变。

For what you want to observe in this lesson it is better to switch the state of the LED after each for-loop, so let's use explicitly an odd number of toggles.

为了方便这堂课观察现象，最好每次 for 循环之后 LED 状态都变一下，所以我们明确用一个奇数次翻转。

By the way, an expression like this is evaluated at compile-time and is equivalent to writing the sum together as 1901. But the explicit plus 1 better documents the intent of using an odd number.

顺便说一下，这样的表达式在编译时就能算出来，跟直接写 1901 是一样的。但写成加 1 更能表达"用奇数"这个意图。

So, let's build the software...

好，构建软件……

...load it into your board,

……加载到板子上，

...and open the logic analyzer.

……打开逻辑分析仪。

The monitored traces are as follows, starting from the highest priority at the top:

监控的信号如下，从上到下优先级从高到低：

- The state of the SW1 switch, which triggers the GPIOF interrupt when the switch is depressed. This interrupt, in turn, signals the semaphore inside the blinky2 thread.

- SW1 开关的状态：按下时触发 GPIOF 中断，这个中断随后通知 blinky2 线程中的信号量。

- The highest-priority blinky1 thread that toggles the Green-LED

- 最高优先级的 blinky1 线程，翻转绿色 LED

- The lower-priority blinky2 thread that toggles the Blue-LED

- 较低优先级的 blinky2 线程，翻转蓝色 LED

- The lowest-priority idle thread that switches the Red-LED on and off.

- 最低优先级的空闲线程，开关红色 LED。

The logic analyzer trigger is set to the falling edge of the SW1 signal, because the switch is active low.

逻辑分析仪的触发设置在 SW1 信号的下降沿，因为这个开关是低电平有效的。

With this trigger, when I start collecting data nothing happens, until I press the SW1 switch.

设好触发之后，开始采集数据时什么都不会发生——直到我按下 SW1 开关。

When the switch is pressed, the blinky2 thread starts running, but because blinky1 has higher priority, blinky2 gets preempted every two milliseconds for blinky1 to run.

按下开关后，blinky2 线程开始运行。但因为 blinky1 优先级更高，所以每隔 2 毫秒 blinky2 就会被抢占，让 blinky1 跑一轮。

Now, lets examine a bit closer the blinky1 thread. As you can see, indeed it changes the state of the Green-LED after every period of activity.

现在来仔细看看 blinky1 线程。可以看到，它确实在每次活跃期之后都改变了绿色 LED 的状态。

But sometimes, not always, and only when blinky2 is running as well, the state of Green-LED does NOT change.

但有时候——不是每次，只有 blinky2 也在跑的时候——绿色 LED 的状态却没有改变。

For instance here, you would expect the Green-LED to toggle from off to on, but it apparently isn't.

比如这里，你会期望绿色 LED 从灭变亮，但显然没有变。

Well, let's examine the trace closer at this exact point.

让我们把这个位置放大仔细看看。

So, when you zoom in, you can see that actually the blinky1 thread HAS changed the state of the Green-LED as expected, but when the blinky2 thread resumed after being preempted by blinky1, the state of the Green-LED changed AGAIN.

放大后你能看到，blinky1 线程确实按预期改变了绿色 LED 的状态。但当 blinky2 线程（被 blinky1 抢占后）恢复运行时，绿色 LED 的状态又被改回去了。

Moreover, if you keep zooming-in all the way to the nanosecond level, you can see that the change of the Green-LED and the Blue-LED are always simultaneous.

而且，如果你一直放大到纳秒级别，会发现绿色 LED 和蓝色 LED 的变化总是同时发生的。

This is a telltale sign of both LEDs being changed in the *same* CPU instruction, which was explained in detail in lesson 20 about race conditions.

这是一个明显的特征——两个 LED 是在*同一条* CPU 指令里被改变的。这个现象在第 20 课讲**竞态条件**（race condition）的时候已经详细解释过了。

More specifically, the low-priority blinky2 thread must have been preempted by the SysTick interrupt after it read the GPIOF->DATA register, but before it could write it back. In the meantime, the SysTick scheduled blinky1, which ran and toggled the Green-LED. When the blinky2 resumed, it finally wrote the value into the DATA register, but this was an outdated value, so it inadvertently switched BOTH its own Blue-LED and the blinky1's Green-LED.

具体来说是这样的：低优先级的 blinky2 线程读取了 GPIOF->DATA 寄存器之后、还没来得及写回去的时候，被 SysTick 中断抢占了。这期间 SysTick 调度了 blinky1，blinky1 跑起来并翻转了绿色 LED。等 blinky2 恢复运行后，它把值写回了 DATA 寄存器——但这是个过时的值，结果它无意中同时翻转了自己的蓝色 LED 和 blinky1 的绿色 LED。

The relevance of all this for today is that race conditions can happen not only between the main code and interrupts, as it was the case in lesson 20, but also and actually even more so, between any two concurrent threads in a preemptive RTOS kernel.

这些都跟今天的课程有关。关键点是：竞态条件不仅可能发生在主代码和中断之间（像第 20 课那样），在抢占式 RTOS 内核中，任意两个并发线程之间更容易出现。

The first mechanism for avoiding such race conditions is simply disabling interrupts around the code that touches the shared resource, as already explained in lesson 20. This works in RTOS as well, because disabling interrupts cuts off the CPU completely from the external world, so preemption cannot happen.

避免这种竞态条件的第一种机制，就是在操作共享资源的代码周围禁用中断——第 20 课已经讲过了。这在 RTOS 中同样管用，因为禁用中断就把 CPU 跟外部世界完全隔离开了，抢占就不可能发生。

But the simplistic unconditional interrupt disabling and enabling around the critical section of code, like you did in lesson 20, has at least two drawbacks.

但是，像第 20 课那样简单粗暴地在临界区前后开关中断，至少有两个缺点。

First, it is inconsistent with the interrupt disabling policy of the RTOS. As explained in the last lesson 27, the QXK RTOS kernel implements the "zero-latency" policy by disabling interrupts selectively, only up to a certain level of interrupt priority. The simplistic critical section disables all interrupts indiscriminately, and thus introduces additional latency for interrupts that should never be disabled.

第一，它跟 RTOS 的中断禁用策略不一致。上一课讲过，QXK RTOS 内核实现的是"零延迟"策略——只选择性地禁用到某个优先级级别的中断。简单的临界区却不加区分地禁用所有中断，给那些本来不应该被禁用的中断增加了额外的延迟。

And second, sometimes you might need to nest critical sections. For example, if you hide a critical section inside a function call, and then call this function also from a critical section established already.

第二，有时候你可能需要嵌套临界区。比如，你在一个函数内部用了临界区，然后又在一个已经建立的临界区里调用了这个函数。

If your critical is not designed to nest, you will re-enable interrupts prematurely, and you might create a race condition in the piece of code that should be protected by a critical section, but isn't.

如果你的临界区不支持嵌套，中断就会被提前重新打开，那些本来应该受临界区保护、实际上却没有的代码就会出现竞态条件。

The QXK kernel provides a critical section mechanism that is both consistent with the "zero-latency" interrupt disabling policy and that allows critical sections to nest.

QXK 内核提供了一种**临界区**（critical section）机制，既跟"零延迟"中断禁用策略一致，又支持临界区嵌套。

The QXK critical section is implemented as follows:

QXK 临界区的用法是这样的：

First, you need to define an automatic variable, which will remember the interrupt disable status.

首先，定义一个自动变量，用来保存中断禁用状态。

Next, you call the QF_CRIT_ENTRY() macro, that takes this variable as a parameter. This macro will first read the current interrupt disable status and save it into the provided variable and only after that, it will disable interrupts.

然后调用 `QF_CRIT_ENTRY()` 宏，把这个变量传进去。这个宏会先读取当前的中断禁用状态并保存到变量里，然后才禁用中断。

At the end of the critical section, you call the QF_CRIT_EXIT() macro, which will restore the saved interrupt disable status from the provided istatus parameter.

临界区结束时，调用 `QF_CRIT_EXIT()` 宏，从 `istatus` 参数中恢复之前保存的中断禁用状态。

This critical section can nest, because it saves and re-stores the original interrupt disable status.

这种临界区支持嵌套，因为它保存并恢复了原始的中断禁用状态。

But for now, I simply delete the redundant simplistic critical section from the blinky thread.

现在我把 blinky 线程里那个多余的简单临界区删掉。

and I also add the critical section to the other toggle function for the Blue LED.

同时给蓝色 LED 的翻转函数也加上临界区。

As you can see, the code builds without errors or warnings.

可以看到，编译没有错误也没有警告。

So, let's load it to the board and open the logic analyzer.

好，加载到板子上，打开逻辑分析仪。

The first obvious difference you see from the previous run is that the blinky1 thread utilizes more CPU, which is due to the additional overhead of the critical section inside the LED toggle functions.

跟上次运行相比，第一个明显的区别是 blinky1 线程占用了更多 CPU——这是因为 LED 翻转函数里加了临界区的额外开销。

But now, the blinky1 thread always switches the state of the Green LED, as expected.

但现在，blinky1 线程每次都能正确翻转绿色 LED 的状态了。

No matter how many times you try, now you cannot find the Green LED being toggled incorrectly.

不管你试多少次，绿色 LED 都不会再被错误翻转了。

Of course, testing like this cannot prove that there are no more bugs, but the race condition seems to be eliminated.

当然，这种测试不能证明所有 bug 都没了，但竞态条件看起来已经被消除了。

In summary, critical section is a very powerful mutual exclusion mechanism that the RTOS itself uses to protect its own internal variables from race conditions.

总结一下：临界区是一种非常强大的互斥机制，RTOS 自己也用它来保护内部变量不被竞态条件破坏。

You can use it as well, but exactly because the mechanism is so powerful, it is applicable only to very short sections of code. Anything that takes more than a few microseconds, meaning only a handful of machine instructions, is just too long and can increase the interrupt latency in your system.

你也可以用，但正因为这个机制威力太大，它只适用于非常短的代码段。任何超过几微秒的操作——也就是超过少数几条机器指令的——都太长了，会增加系统的中断延迟。

So, let's move on to a situation where sharing of a resource would last hundreds of microseconds, which is way too long to use the critical section mutual exclusion mechanism.

好，接下来我们看一种资源共享持续几百微秒的情况——用临界区就太长了。

As an example, imagine that you need to send messages in Morse code by means of blinking the Green LED.

举个例子：假设你需要通过闪烁绿色 LED 来发送摩尔斯电码（Morse code）消息。

The Morse code consists of dots and dashes, whereas the duration of a dot is a fundamental unit of time, and needs to be about 40 microseconds to make it interesting for today. A dash is three dot-times. The space between parts of the same letter is a dot-time. The space between letters are three dot-times. And finally, the space between words is seven dot-times.

摩尔斯电码由点（dot）和划（dash）组成。一个点的持续时间是基本时间单位，为了今天的演示效果，设成大约 40 微秒。一个划是三个点的时间，同一字母各部分之间的间隔是一个点的时间，字母之间的间隔是三个点的时间，单词之间的间隔是七个点的时间。

Your software will be sending two types of messages. An urgent "SOS" distress code, which needs to come out at least once in every 2 millisecond interval and a low-priority "TEST" message that needs to come out twice about every 5 milliseconds when the system has nothing else to do.

你的软件需要发送两种消息：一种是紧急的"SOS"求救信号，至少每 2 毫秒要发出一次；另一种是低优先级的"TEST"消息，在系统没事干的时候大约每 5 毫秒发两次。

The picture suggests also the implementation. A message to send will be encoded in a bitmask, where each bit represents one dot-time unit. Here are the examples of encoding the "SOS" word and the "TEST" words with the right pauses within the letters and between the letters.

图上也给出了实现思路。要发送的消息会被编码成一个**位掩码**（bitmask），每一位代表一个点的时间单位。这里展示了"SOS"和"TEST"的编码示例，包括字母内部和字母之间的正确间隔。

As you remember from lesson 1, each group of 4 bits is called a nibble and can be encoded as one hexadecimal digit, so the whole bitmasks can be written like this.

回忆一下第 1 课的内容：每 4 位一组叫做**半字节**（nibble），可以用一个十六进制数字表示，所以整个位掩码可以这样写。

The function for modulating the Green LED according to the provided Morse code, called BSP_sendMorseCode is implemented as follows:

根据摩尔斯电码调制绿色 LED 的函数叫 `BSP_sendMorseCode`，实现如下：

It takes the message bitmask and examines its most-significant bit. If the bit is one, the Green LED is turned on, otherwise it is turned off. After this, the function busy-waits for the dot-time to hold the LED state.

它接收消息位掩码，检查最高有效位。如果是 1，就打开绿色 LED；否则关闭。然后忙等待一个点的时间来保持 LED 状态。

Please note that the dot-time delay of only about 40 microseconds is way too short to use the efficient, blocking RTOS delay function, which can delay only for multiples of the System Clock tick interval. The only option for microsecond time delays is a busy-waiting loop.

注意，40 微秒左右的点时间延迟太短了，没法用高效的阻塞式 RTOS 延迟函数——那个函数只能延迟系统时钟节拍间隔的整数倍。微秒级的延迟只能用忙等待循环。

After processing the bit, the bitmask is shifted to the left by one bit, and the cycle repeats, until the bitmask becomes zero, which means that there are no letters in the message.

处理完一位后，位掩码左移一位，循环继续，直到位掩码变成零——说明消息中没有更多字母了。

Finally, after sending all the letters, the function turns the Green LED off and generates the 7-dot pause required after the Morse-code word.

最后，发完所有字母后，函数关闭绿色 LED，并生成摩尔斯电码单词之后需要的 7 个点时间的间隔。

With this implementation in place, and remembering to add the prototype of the Morse code function to the bsp.h header file, you can use the function in your threads.

实现好了之后，别忘了把摩尔斯电码函数的原型加到 `bsp.h` 头文件里，然后就可以在线程中使用了。

The highest-priority blinky1 thread will send the urgent "SOS" message, after which it will delay itself for 1 clock tick.

最高优先级的 blinky1 线程负责发送紧急的"SOS"消息，发完后把自己延迟 1 个时钟节拍。

The low-urgency "TEST" messages will be send by the blinky3 thread, which was not used until now. This thread will send two TEST messages one after another and will delay itself for 5 clock ticks.

低紧急度的"TEST"消息由 blinky3 线程发送——这个线程之前一直没用过。它会连续发两条 TEST 消息，然后把自己延迟 5 个时钟节拍。

The main point of this exercise is that the BSP_sendMorseCode() function is now SHARED between two concurrent threads: blinky1 and blinky3. Please also note, that at this point the shared function has no protection from concurrent access, because first you need to see what happens without such a protection.

这个练习的核心在于：`BSP_sendMorseCode()` 函数现在被两个并发线程——blinky1 和 blinky3——共享了。注意，此时这个共享函数没有任何并发访问的保护，因为你得先看看没有保护会发生什么。

By the way, you obviously still need to start the blinky3 thread at some low priority. For this exercise you will use priority 1, which is lower than blinky1 and blinky2.

顺便说一下，你还需要以某个低优先级启动 blinky3 线程。这个练习中用优先级 1，比 blinky1 和 blinky2 都低。

So, let's rebuild the code and load it to your TivaC LaunchPad board.

好，重新编译代码，加载到 TivaC LaunchPad 板上。

In the logic analyzer view, the trigger is still setup for pressing the SW1 button, so nothing gets captured until you press the switch.

逻辑分析仪的触发还是设在按下 SW1 按钮，所以不按键就不会采集数据。

When you zoom in and watch the Green LED trace, you can recognize the three-dots, three-dashes, three-dots SOS message.

放大看绿色 LED 的波形，你能辨认出三点、三划、三点的 SOS 消息。

The message comes every 2 milliseconds.

消息每 2 毫秒出现一次。

But you can also see places where the Green LED blinks with a different pattern.

但你也能看到有些地方绿色 LED 的闪烁模式不对。

For instance here, you can recognize the one-dash-T,

比如这里，能辨认出一划的 T，

one-dot-E,

一点的 E，

three-dots-S,

三点的 S，

But instead of the final one-dash-T from the "TEST" message, you can see dash-dot-dot, which happens to make the letter D.

但"TEST"消息最后应该是一划的 T，你看到的却是划-点-点——恰好构成字母 D。

This is followed by three-dashes-O, three-dots-S, and finally the 7-dot pause.

接着是三划的 O、三点的 S，最后是 7 个点的间隔。

All this makes the scrambled message TESDOS, which is neither TEST nor SOS.

合在一起就是 TESDOS——既不是 TEST 也不是 SOS，完全乱套了。

The blink patterns that follow are even more scrambled than that.

后面的闪烁模式更乱。

The bottom line is that the messages TEST and SOS collide and both get damaged in the process. As a result, the urgent message SOS does not come on time, so it misses its hard real-time deadline.

结论就是：TEST 和 SOS 消息互相碰撞，两边的消息都被破坏了。结果紧急的 SOS 没能按时发出，错过了它的**硬实时截止时间**（hard real-time deadline）。

The problem here is obviously that two concurrent threads, blinky1 and blinky3, share the Green LED without any protection against the conflicts.

问题很明显：两个并发线程 blinky1 和 blinky3 共享绿色 LED，却没有任何冲突保护。

However, because the sharing of the Green LED now lasts almost a millisecond, which is a thousand microseconds, you need to use some other protection mechanism than a critical section.

但问题是，现在共享绿色 LED 的时间将近一毫秒——一千微秒——用临界区来保护就太长了。

But from the last lesson 27 you already know and use a semaphore,

上一课你已经学过信号量了，

which has been invented in the 1960s for both thread synchronization and for mutual exclusion.

信号量是 1960 年代发明的，既可以做线程同步，也可以做互斥。

So, now, instead of the tick-counter that you no longer use, you need a new semaphore for protecting the Morse code function, which you can name Morse_sema and which can also be static, because it will be only used inside the bsp.c file scope.

好，现在你不再需要节拍计数器了，而是要创建一个新的信号量来保护摩尔斯电码函数。可以叫它 `Morse_sema`，声明为 static 就行，因为它只在 `bsp.c` 文件范围内使用。

You need to initialize the semaphore similarly as the signaling SW1-semaphore, except now you will start with the count 1, meaning that the resource is initially available.

初始化方式跟之前 SW1 信号量类似，只不过这次初始计数设为 1，表示资源一开始就是可用的。

Next, before accessing the shared Green LED resource you wait for the semaphore to become available. This is similar to cars waiting for the green light at an intersection.

接下来，在访问共享的绿色 LED 资源之前，先等待信号量变为可用。就像汽车在十字路口等绿灯一样。

After you are done accessing the shared resource, you signal the semaphore to make it available for the next time.

用完共享资源后，释放信号量，让它下次又能被获取。

Note that because the semaphore is binary, meaning that it can hold only one token at a time, only one thread at a time can be allowed past the Semaphore_wait() function call, which is exactly the mutual exclusion you need.

注意，因为这是一个**二值信号量**——一次只能持有一个令牌——所以同一时刻只有一个线程能通过 `Semaphore_wait()` 调用，这正是你需要的互斥效果。

Alright, I bet that must be curious how this will work and what kind of a difference the semaphore will make, so let's build the code and load it to the board.

好了，我猜你一定很好奇效果会怎样，信号量能带来什么改变。来，编译代码，加载到板子上。

The logic analyzer is still setup to trigger on the falling edge of the SW1 signal, so nothing happens until I press the button.

逻辑分析仪还是设在 SW1 信号的下降沿触发，不按键就什么也不会发生。

Once the trace is collected, and I zoom in on the Green LED signal, you can clearly recognize the three-dots, three-dashes, three-dots SOS messages.

采集到数据后，放大绿色 LED 信号，你能清楚地辨认出三点、三划、三点的 SOS 消息。

You can also recognize dash-dot-three-dots-dash TEST message, which is clearly intact and no longer scrambled.

也能辨认出划-点-三点-划的 TEST 消息——完好无损，不再混乱了。

When the TEST message sneaks in, the next SOS message gets delayed, but still it manages to come out before its deadline.

当 TEST 消息插进来的时候，下一条 SOS 会被延迟，但还是能赶在截止时间之前发出来。

So, it seems that you have successfully prevented the conflicts around the Green LED shared between the blinky1 and blinky3 threads.

看起来你已经成功解决了 blinky1 和 blinky3 之间共享绿色 LED 的冲突问题。

And indeed, you can try many times and each time everything looks just fine.

确实，你可以试很多次，每次看起来都很好。

Until it doesn't!

直到——出问题了！

Here, for example, the Green LED stops blinking whatsoever, apparently for as long as blinky2 keeps running for over 6 milliseconds.

比如这里，绿色 LED 完全不闪了，持续时间跟 blinky2 运行的时间一样长——超过 6 毫秒。

This means that somehow the highest-priority blinky1 thread is prevented from running by the lower priority blinky2 thread, which runs completely undisturbed.

也就是说，最高优先级的 blinky1 线程竟然被低优先级的 blinky2 线程挡住了，blinky2 反而在那里畅通无阻地跑。

When you examine more closely what happened, you can see that the button press happened while the Green LED was sending the TEST message, which means that the low-priority blinky3 was in control.

仔细看看发生了什么：按键按下的时候，绿色 LED 正在发送 TEST 消息——也就是说，低优先级的 blinky3 正占着资源。

Because blinky2 has higher priority than blinky3, it preempted blinky3 and started running.

因为 blinky2 优先级比 blinky3 高，它抢占了 blinky3 开始运行。

This is all fine, but when the next system clock tick unblocked the highest-priority blinky1, it blocked immediately on the Morse semaphore, because the semaphore was already taken by the low-priority blinky3.

这倒没问题。但当下一个系统时钟节拍唤醒了最高优先级的 blinky1 时，它立刻在摩尔斯信号量上阻塞了——因为信号量已经被低优先级的 blinky3 占着。

This allowed blinky2 to run for as long as it wanted to, while blinky1 missed its hard real-time deadline.

这就让 blinky2 爱跑多久跑多久，而 blinky1 错过了它的硬实时截止时间。

The problem you just witnessed is called "unbounded priority inversion" and is a catastrophic failure in a hard real time system.

你刚才看到的这个问题叫做**无界优先级反转**（unbounded priority inversion），在硬实时系统中这是灾难性的故障。

The fundamental issue here is that the semaphore is just unaware of the priorities of threads that it blocks, so nothing is done to prevent priority inversion from happening.

根本原因在于：信号量根本不知道它阻塞的线程各自的优先级是什么，所以没有任何措施来防止优先级反转。

This should be actually not that surprising, because semaphores have been invented in the era of timesharing systems, where the notion of thread priority was simply not used.

其实这也不奇怪——信号量是分时系统时代发明的，那时候压根没有线程优先级这个概念。

Without the concept of priority, priority inversion cannot happen, so it was a non-issue, until, that is, semaphores were forced to work with priority-based RTOS kernels.

没有优先级概念，优先级反转自然不会发生，所以当年不是问题。直到后来信号量被拿去跟基于优先级的 RTOS 内核搭配使用，问题才暴露出来。

It turns out that the classic semaphore, while still applicable to synchronizing threads as you saw in the last lesson, is NOT a good mechanism for mutual exclusion in priority-based systems.

事实证明，经典信号量虽然能用来做线程同步（上一课你看到的），但在基于优先级的系统中做互斥，它不是个好选择。

Which brings us to the two modern mutual exclusion mechanisms that I'd still like to cover in this lesson. Both of them prevent priority inversion as well as many other tricky problems, such as deadlock.

这就引出了本课还要介绍的两种现代互斥机制。它们都能防止优先级反转，也能避免死锁等很多棘手的问题。

The first such mechanism is selective scheduler locking up to the specified priority ceiling.

第一种机制是**选择性调度器锁定**（selective scheduler locking），可以锁定到指定的优先级上限。

Let's first see how you use it in your application, and then I'll explain how it works in a the logic analyzer view and in a timing diagram.

先看看怎么用，然后我再用逻辑分析仪和时序图来解释它的工作原理。

So, here you no longer need the Morse semaphore, but instead of deleting the previous code, I'll simply comment it out adding a note about the mechanism being used, so that you can later experiment with all the options discussed in this lesson.

现在不再需要摩尔斯信号量了。但我不直接删掉之前的代码，而是注释掉，并加个注释说明正在使用哪种机制——方便你之后尝试本课讨论的所有方案。

The semaphore no longer needs to be initialized.

信号量不再需要初始化了。

And finally, instead of the semaphore-wait, you call QXK_schedLock() function.

然后，用 `QXK_schedLock()` 函数替代信号量等待。

The function takes a parameter, which is the priority ceiling. This ceiling denotes the level up to which you lock the scheduler, meaning that all threads below or equal to the ceiling won't be scheduled, but any threads above the ceiling are scheduled as usual. Of course, the ISRs, that run above all threads, are not affected at all, so there is no impact on the interrupt latency.

这个函数接受一个参数——**优先级上限**（priority ceiling）。这个上限表示你把调度器锁到哪个级别：低于或等于这个上限的线程都不会被调度，而高于上限的线程照常调度。当然，优先级在所有线程之上的中断服务程序（ISR）完全不受影响，所以中断延迟没有影响。

From this explanation, it should be clear that the ceiling priority must be at least as high as the priority of the highest-priority thread that uses the shared resource. In your case, the highest-priority thread is blinky1, with priority of 5.

根据这个解释就很清楚了：优先级上限必须至少等于使用共享资源的最高优先级线程的优先级。在你的例子中，最高优先级线程是 blinky1，优先级为 5。

The QXK_schedLock() API can be only invoked from a thread that now takes ownership of the scheduler lock.

`QXK_schedLock()` API 只能从线程中调用——调用它的线程就成为调度器锁的拥有者。

The function returns the previous status of the scheduler lock, just like the critical section mechanism returned the previous status of interrupts.

这个函数返回调度器锁之前的状态，跟临界区机制返回之前的中断状态是一个道理。

Just as before with critical section, this trick allows the scheduler locks to nest, if need be.

跟临界区一样，这个技巧让调度器锁也支持嵌套。

And finally, instead of semaphore signal, the thread owning the lock unlocks the scheduler with the QXK_schedUnlock() API. By calling this function the thread restores the previous scheduler lock state from the parameter sstat.

最后，拥有锁的线程用 `QXK_schedUnlock()` API 来解锁调度器，而不是释放信号量。调用这个函数时，线程从 `sstat` 参数恢复之前的调度器锁状态。

Please note that selective scheduler locking is a NON-BLOCKING mutual exclusion mechanism, similar as critical section was non-blocking. Except now, you will only prevent scheduling of threads up to the specified priority ceiling, while higher-priority threads and all interrupts will continue running undisturbed.

注意，选择性调度器锁定是一种**非阻塞的**互斥机制，跟临界区一样是非阻塞的。区别在于，现在你只会阻止到指定优先级上限为止的线程被调度，而更高优先级的线程和所有中断完全不受干扰。

So, now let's see how this works using a logic analyzer.

好，现在用逻辑分析仪看看效果。

First, let's check whether the selective scheduler locking prevents collisions between the "SOS" and "TEST" messages.

首先检查选择性调度器锁定是否防止了"SOS"和"TEST"消息之间的冲突。

The messages look intact and don't run into each other, so the mutual exclusion definitely works.

消息看起来完好无损，互相之间没有干扰，互斥确实生效了。

But now, you also need to check whether the unbounded priority inversion still occurs.

接下来还要确认无界优先级反转是否还会发生。

For that you need to catch the special case, where the button press comes during the "TEST" message.

为此要抓一个特殊情况：按键按下的时候恰好 TEST 消息正在发送。

Luckily, this scenario comes up quite quickly.

幸运的是，这个场景很快就出现了。

As you can see, even though the button has been pressed, the blinky2 thread, which has higher priority than blinky3 sending the "TEST" message, does NOT preempt blinky3, because now it is below the priority ceiling and so it is apparently not scheduled.

可以看到，虽然按钮被按下了，优先级高于 blinky3 的 blinky2 线程却没有抢占 blinky3——因为它的优先级低于锁定的上限，所以没有被调度。

Instead, blinky3 sends the "TEST" message undisturbed and then blinky1 sends the "SOS" message. Only after this, blinky2 has a chance to run, until it is preempted by blinky1 again.

blinky3 不受干扰地发完 TEST 消息，然后 blinky1 发送 SOS 消息。这之后 blinky2 才有机会运行，直到又被 blinky1 抢占。

The bottom line is that unbounded priority inversion has been prevented.

结论就是：无界优先级反转被成功防止了。

The timing diagram shows the same scenario again for the semaphore and selective scheduler locking.

时序图再次对比了信号量和选择性调度器锁定在同样场景下的表现。

In the case of the classic semaphore, the button press at time A caused scheduling the blinky2 thread, because its priority was higher than the currently running blinky3.

用经典信号量的情况下，时间 A 的按键导致 blinky2 线程被调度——因为它的优先级比正在运行的 blinky3 高。

At some later time B, the highest-priority blinky1 was scheduled, but it was immediately blocked on the semaphore, because the semaphore was already taken by blinky3. This allowed blinky2 to run for as long as it wanted, creating the unbounded priority inversion problem.

到后面的时间 B，最高优先级的 blinky1 被调度了，但它立刻在信号量上阻塞——因为信号量已经被 blinky3 占了。这就让 blinky2 想跑多久跑多久，造成了无界优先级反转。

In contrast, in the case of scheduler locking, the blinky2 thread was NOT scheduled at time A, because the priority of blinky2 was below the priority ceiling.

相比之下，用调度器锁定时，blinky2 在时间 A 没有被调度——因为它的优先级低于锁定的上限。

At the later time B, the blinky1 thread wasn't scheduled either, because it too was not above the ceiling. Only after blinky3 finished, it released the lock and the scheduler picked the highest priority thread ready to run, which happened to be blinky1.

到时间 B，blinky1 也没有被调度——因为它也不高于上限。只有 blinky3 完成后释放了锁，调度器才选择优先级最高的就绪线程来运行——恰好就是 blinky1。

In summary, selective scheduler locking is a very effective, non-blocking mutual exclusion mechanism, which prevents unbounded priority inversion.

总结一下：选择性调度器锁定是一种非常有效的非阻塞互斥机制，能防止无界优先级反转。

It is simple to implement inside the RTOS and therefore is very efficient, but many RTOSes provide only crude scheduler locking of all threads, which is unfortunately too pervasive.

它在 RTOS 内部实现简单，所以效率很高。但很多 RTOS 只提供粗粒度的全局调度器锁定——把所有线程都锁住——这就太过粗暴了。

Modern RTOS kernels, including QXK, provide the SELECTIVE scheduler locking only up to the specified priority ceiling. This allows higher-priority threads, which don't participate in the sharing of a given resource, to run completely undisturbed.

现代 RTOS 内核（包括 QXK）提供的是**选择性**的调度器锁定——只锁到指定的优先级上限。这样，不参与共享资源的高优先级线程就能完全不受干扰地运行。

The only limitation of the selective scheduler locking is that the thread cannot block while holding the lock.

选择性调度器锁定唯一的限制是：线程在持有锁的时候不能阻塞。

Blocking while accessing a shared resource, such as calling the blocking-delay or the semaphore-wait APIs, is considered a bad practice and should be avoided. But still it occasionally happens in real-life projects, and in that case the QXK will assert if the thread would attempt to block while owning a scheduler lock.

在访问共享资源时阻塞（比如调用阻塞延迟或信号量等待 API）本身就是不好的做法，应该尽量避免。但在实际项目中偶尔还是会发生。如果线程在持有调度器锁的时候尝试阻塞，QXK 会触发断言报错。

Your only option in that case is the last mutual exclusion mechanism that I want to discuss in this lesson, called the MUTEX.

这种情况下，你唯一的选择就是本课要讲的最后一种互斥机制——**互斥锁**（mutex）。

The term "mutex" is an abbreviation of MUTual-EXclusion and sometimes is also called mutual-exclusion semaphore. But I don't want you to think of a mutex as a kind of a semaphore.

"mutex" 是 MUTual-EXclusion（互斥）的缩写，有时也叫"互斥信号量"。但我希望你不要把互斥锁当成信号量的一种。

Instead, think of a mutex as an RTOS object specifically designed for protecting resources shared among concurrent threads in the most generic case, where threads might block while accessing the shared resource.

你应该把它看作一个专门为保护并发线程共享资源而设计的 RTOS 对象——适用于最通用的情况，包括线程在访问共享资源时可能需要阻塞的场景。

To demonstrate the use of a mutex, while keeping things simple, I will just replace the scheduler lock with a mutex, even though there is no blocking in the protected code.

为了演示互斥锁的用法，同时保持简单，我直接用互斥锁替换掉调度器锁——虽然受保护的代码中并没有阻塞操作。

First, you need to define a mutex object.

首先，定义一个互斥锁对象。

Next, the mutex object needs to be initialized before it can be used.

然后，互斥锁对象在使用前需要初始化。

The QXK kernel provides the so called priority-ceiling mutex, which needs to be initialized with the priority ceiling associated with the resource to be protected by this mutex.

QXK 内核提供的是所谓的**优先级上限互斥锁**，初始化时需要指定与被保护资源相关联的优先级上限。

Similarly as with the scheduler lock, this priority ceiling must be at least as high as the highest-priority thread that accesses the shared resource.

跟调度器锁一样，这个优先级上限必须至少等于访问共享资源的最高优先级线程的优先级。

However, in QXK the ceiling priority must be unique and cannot be the same as priority already used by a thread, therefore here it will be one level higher than blinky1, that is priority 6.

不过，在 QXK 中上限优先级必须是唯一的，不能跟已有线程的优先级相同。所以这里要比 blinky1 高一级，也就是优先级 6。

This makes a priority-ceiling mutex a bit similar to a thread and therefore it must be initialized AFTER the call to the QF_init() function.

这使得优先级上限互斥锁有点像线程，所以它必须在 `QF_init()` 函数调用之后才能初始化。

Since the initialization of the mutex happens in BSP_init(), you need to make sure that it is called after QF_init().

因为互斥锁的初始化在 `BSP_init()` 中进行，所以你要确保它在 `QF_init()` 之后被调用。

This means that you need to reverse the order of calls in the main() function.

也就是说，你需要把 `main()` 函数里的调用顺序反过来。

Alright, so with this setup, you can now apply the mutex to protect the Morse code generation.

好，设置完毕，现在用互斥锁来保护摩尔斯电码的生成。

The protected section of the code starts with the QXMutex_lock() API, at which point the thread becomes the owner of the mutex.

受保护的代码段以 `QXMutex_lock()` API 开始，调用后线程就成为了互斥锁的拥有者。

The protection ends with the QXMutex_unlock() call, at which point the thread relinquishes the ownership of the mutex.

保护以 `QXMutex_unlock()` 调用结束，调用后线程放弃互斥锁的所有权。

The lock()/unlock() names in the API for mutexes have been specifically chosen to be similar to scheduler locking and different from the wait()/signal() names in the API for semaphores.

互斥锁 API 故意用了 `lock()/unlock()` 这样的命名，跟调度器锁定保持一致，同时跟信号量的 `wait()/signal()` 区分开来。

As before with scheduler lock, let's first build and run the code in the logic analyzer, and then explain the details with a timing diagram.

跟之前调度器锁一样，先编译运行、在逻辑分析仪中看效果，然后用时序图解释细节。

The first order of business is to verify that mutex does its job of preventing collisions between the "SOS" and "TEST" messages.

首先要验证互斥锁能不能防止"SOS"和"TEST"消息之间的冲突。

... and so it apparently does.

……看来确实做到了。

Next, you need to verify that unbounded priority inversion does not happen, for which you need to catch the special case, where the button press comes during the "TEST" message.

接下来验证无界优先级反转是否不会发生——还是那个特殊情况：按键在 TEST 消息发送期间按下。

And so, luckily it happens right away.

幸运的是，马上就出现了这个场景。

As you can see, even in this case the "TEST" message comes out intact and the blinky2 thread does not preempt the low-priority blinky3.

可以看到，即使在这种情况下，TEST 消息也完好地发出去了，blinky2 线程没有抢占低优先级的 blinky3。

Now, let's take a look at the corresponding timing diagrams.

现在来看看对应的时序图。

First, let's compare selective scheduler locking to the priority-ceiling mutex.

先对比一下选择性调度器锁定和优先级上限互斥锁。

The main difference is that at time A the low-priority blinky3 thread is promoted to the ceiling priority of the mutex.

主要区别在于：在时间 A，低优先级的 blinky3 线程被**提升**到了互斥锁的上限优先级。

From that time on, blinky3 runs at the ceiling priority, which protects it from preemption by blinky2 and even blinky1.

从这时起，blinky3 就以上限优先级运行，不会被 blinky2 甚至 blinky1 抢占。

Only after calling QXMutex_unlock(), the priority of blinky3 drops back to the original low-priority, at which point the scheduler picks the next highest-priority thread ready-to-run, which happens to be blinky1.

直到调用 `QXMutex_unlock()` 之后，blinky3 的优先级才降回原来的低优先级。这时调度器选择下一个最高优先级的就绪线程——恰好是 blinky1。

At the end of the day, however, just looking at the thread execution, because there is no blocking in the protected code, the timing diagrams for scheduler locking and priority-ceiling mutex are identical.

不过归根结底，仅看线程执行情况的话，因为受保护的代码中没有阻塞，调度器锁定和优先级上限互斥锁的时序图是完全一样的。

The QXK priority-ceiling mutex that you just saw in action implements the so called "Priority-Ceiling Protocol".

你刚才看到的 QXK 优先级上限互斥锁，实现的是所谓的**优先级上限协议**（Priority-Ceiling Protocol）。

But this is not the only way of preventing unbounded priority inversion. In fact, most RTOSes implement mutexes with a different strategy called "Priority-Inheritance Protocol".

但这不是防止无界优先级反转的唯一方法。事实上，大多数 RTOS 用的是另一种策略——**优先级继承协议**（Priority-Inheritance Protocol）。

So, even though I can't show you a working example, because QXK does not support priority-inheritance, I'd like to briefly explain the difference between the two strategies and point out their respective strengths and weaknesses.

虽然我没法给你演示可运行的例子——因为 QXK 不支持优先级继承——但我还是想简单解释一下两种策略的区别，以及各自的优缺点。

The first difference that you don't see in the timing diagram is that priority inheritance mutex does not need to be initialized with any particular priority, like the ceiling priority, because it will adjust thread priorities fully automatically.

第一个区别在时序图上看不到：优先级继承互斥锁不需要用任何特定优先级来初始化（比如上限优先级），因为它会完全自动地调整线程优先级。

This leads to the first difference at time-A in the diagram, where priority-ceiling protocol immediately promotes the thread to the ceiling priority, but priority-inheritance does not change the thread priority at this point yet.

这导致了时序图中时间 A 处的第一个区别：优先级上限协议会立即把线程提升到上限优先级，而优先级继承此时还不会改变线程优先级。

Because of that the medium-priority blinky2 thread preempts blinky3 immediately after the button press.

因此，中等优先级的 blinky2 线程在按键后立刻就抢占了 blinky3。

The low-priority thread is promoted only after the high-priority thread starts running and tries to lock the priority-inheritance mutex. Specifically, the low-priority thread INHERITS the priority of the high-priority contender for the resource.

低优先级线程要等到高优先级线程开始运行并尝试锁定互斥锁之后才会被提升。具体来说，低优先级线程**继承**了资源的高优先级竞争者的优先级。

From that point the timing diagrams are very similar, but because of the initial preemption by the medium-priority thread, the high-priority thread runs and finishes later under priority-inheritance and so it runs a higher risk of missing its deadline.

从那之后时序图就很相似了。但由于一开始被中等优先级线程抢占，高优先级线程在优先级继承下完成得更晚，错过截止时间的风险也更高。

Another big disadvantage of priority-inheritance is that it typically leads to many more expensive context switches than priority ceiling. For example, in the scenario just discussed, priority ceiling leads to only 2 context switches, while priority-inheritance uses 4 of them.

优先级继承的另一个大缺点是：它通常会导致更多代价高昂的上下文切换。比如在刚才讨论的场景中，优先级上限只产生 2 次上下文切换，而优先级继承要 4 次。

And finally, priority inheritance is much more complex to implement correctly inside the RTOS.

最后，优先级继承在 RTOS 内部的正确实现要复杂得多。

For all these reasons, as well as much simpler timing analysis for hard-real time systems, priority-ceiling protocol is the preferred strategy, and that's why it is the only one supported in QXK.

综合这些原因，再加上硬实时系统的时序分析也简单得多，优先级上限协议是首选策略。这就是 QXK 只支持这一种的原因。

In summary, in this lesson you learned about sharing of resources and the mutual exclusion mechanisms commonly available inside RTOS kernels. The subject is complex and this lesson barely scratched the surface of the problems you might run into. If you wish to learn more, the description below this video provides a couple of links to good articles on the subject.

总结一下：这堂课你学习了资源共享和 RTOS 内核中常用的互斥机制。这个话题很复杂，本课只是浅尝辄止。如果你想深入了解，视频下方提供了几篇相关好文章的链接。

The "Shared-State Concurrency" programming model based on a traditional preemptive RTOS has been the dominating approach since the 1980's, but it has several negative implications.

基于传统抢占式 RTOS 的**"共享状态并发"**（Shared-State Concurrency）编程模型，从 1980 年代起一直占主导地位，但它有一些负面影响。

The first-order ripple effects of resource sharing are race conditions and collisions in the time domain or data space. If left unprotected, these consequences lead directly to a system failure.

资源共享最直接的后患就是时间域或数据空间中的竞态条件和冲突。如果不加保护，这些后果会直接导致系统故障。

To avoid such failures, traditional RTOSes provide an assortment of mutual exclusion mechanisms to protect the shared resources, but each of them lead to their own negative implications.

为了避免这些故障，传统 RTOS 提供了各种互斥机制来保护共享资源，但每种机制又各有各的副作用。

Most of these second-order implications have negative impact on the real-time performance of the system and can lead to missed deadlines, which again means failure in hard real-time systems.

这些副作用大部分会对系统的实时性能产生负面影响，可能导致错过截止时间——在硬实时系统中，这又意味着故障。

But the "shared-state concurrency" model is no longer the only option on the market. The 1990's brought alternative real-time software architectures that avoid sharing of resources, and thus eliminate the need for complex mutual-exclusion mechanisms. I will talk about these more modern approaches in the future lessons.

不过，"共享状态并发"模型已经不是唯一的选择了。1990 年代出现了避免资源共享的替代实时软件架构，从根本上消除了对复杂互斥机制的需求。以后的课程中我会聊到这些更现代的方法。

But before jumping into that subject, in the next lesson I still need to talk about the very important development that happened during the 1980's, which is: object-oriented programming.

但在进入那个话题之前，下一课还要先聊聊 1980 年代的一个重要发展——**面向对象编程**（object-oriented programming）。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| mutual exclusion | 互斥 | 确保同一时刻只有一个线程访问共享资源 |
| mutual exclusion mechanism | 互斥机制 | 实现互斥访问的各种机制的总称 |
| race condition | 竞态条件 | 多个线程并发访问共享资源导致的不确定行为 |
| critical section | 临界区 | 通过禁用中断实现的互斥保护代码段 |
| semaphore | 信号量 | 用于线程同步和互斥的 RTOS 原语 |
| binary semaphore | 二值信号量 | 只能取 0 或 1 的信号量 |
| priority inversion | 优先级反转 | 低优先级线程阻塞高优先级线程的现象 |
| unbounded priority inversion | 无界优先级反转 | 持续时间不可控的优先级反转，硬实时系统中的灾难性故障 |
| selective scheduler locking | 选择性调度器锁定 | 只锁定到指定优先级上限的调度器锁 |
| priority ceiling | 优先级上限 | 调度器锁定或互斥锁设定的上限优先级 |
| mutex (MUTual-EXclusion) | 互斥锁 | 专门用于互斥保护的 RTOS 对象 |
| Priority-Ceiling Protocol | 优先级上限协议 | 立即将持有锁的线程提升到上限优先级的策略 |
| Priority-Inheritance Protocol | 优先级继承协议 | 当高优先级线程竞争资源时才提升低优先级线程的策略 |
| bitmask | 位掩码 | 用位序列编码信息的数据结构 |
| nibble | 半字节 | 4 位二进制数据 |
| Morse code | 摩尔斯电码 | 用点和划编码字符的通信方式 |
| hard real-time deadline | 硬实时截止时间 | 必须严格遵守的时间限制 |
| context switch | 上下文切换 | 从一个线程切换到另一个线程的开销 |
| deadlock | 死锁 | 多个线程互相等待对方释放资源的状态 |
| Shared-State Concurrency | 共享状态并发 | 基于共享资源的多线程编程模型 |
| object-oriented programming | 面向对象编程 | 以对象为核心的组织代码的方式 |
