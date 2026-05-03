# 第20课：竞态条件 / Lesson 20: Race Conditions

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll finally tackle the subject of race conditions. Today you will learn what race conditions are, why they are dangerous, and how to avoid them.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这堂课我们终于要来聊一个重要的话题——**竞态条件（race condition）**。今天你会学到什么是竞态条件、为什么它很危险，以及怎么避免它。

To remind you quickly what happened so far: in the last lesson this course switched the development toolset to the Eclipse-based Code Composer Studio.

先快速回顾一下进展：上一课我们把开发工具切换到了基于 Eclipse 的 Code Composer Studio。

The project directory structure established in the last lesson 19 looks as follows:

上一课（第19课）建立的项目目录结构长这样：

The CCS sub-directory contains the Eclipse workspaces for the lessons of this video course. This directory was created by the Code Composer Studio Eclipse-based IDE.

CCS 子目录里放的是本课程各课的 Eclipse 工作空间，由 Code Composer Studio IDE 自动创建。

The CMSIS sub-directory contains the Cortex Microcontroller Software Interface Standard header files. If you have not done it yet, you need to create this directory by unzipping the CMSIS archive, which you can get from the project downloads for this video course.

CMSIS 子目录里是 **Cortex 微控制器软件接口标准（CMSIS）** 的头文件。如果你还没操作过，需要把 CMSIS 压缩包解压到这个目录——压缩包可以从本课程的项目下载页面获取。

Finally, you should have the lesson 19 directory with all the code and the CCS project files, which you also get from the project downloads for this video course.

最后，你还需要一个 lesson19 目录，里面有所有代码和 CCS 项目文件，同样从课程的项目下载页面获取。

Of course, you can have any other lessons in this directory as well, but for today you only need the three directories described so far.

当然，这个目录下你也可以放其他课的内容，不过今天只需要刚才说的这三个目录就够了。

To create a new project for this lesson, make a copy of the previous "lesson19" directory and rename it to "lesson20".

要为这节课创建新项目，把之前的 lesson19 目录复制一份，重命名为 lesson20。

With Eclipse-based IDEs, you typically cannot simply open the project by double clicking on it. Instead, you need to first launch the Eclipse IDE, and then import the new project, as I will show you in a minute.

基于 Eclipse 的 IDE 一般不能双击直接打开项目。你得先启动 Eclipse，然后把项目导进去——我马上演示。

While launching Code Composer Studio, make sure that the selected workspace is CCS that I described before.

启动 Code Composer Studio 的时候，确认选中的工作空间是之前说的那个 CCS 目录。

After Eclipse finally opens, it should contain one project called "lesson", which you created in the last lesson 19.

Eclipse 打开后，你应该能看到一个叫 lesson 的项目，这是上一课创建的。

Before importing the new project for lesson 20, you need to delete the old one from the workspace, because the new project will also have the same copied name "lesson" and Eclipse does not accept two projects with the same name.

在导入第20课的新项目之前，得先把旧项目从工作空间里删掉，因为复制过来的新项目也叫 lesson，而 Eclipse 不允许两个项目同名。

When you delete the project, do not check the box "delete project contents on disk".

删除项目的时候，不要勾选"delete project contents on disk"这个选项——否则磁盘上的文件也会被删掉。

Now you can finally import the copied project for lesson20.

好了，现在可以导入复制好的 lesson20 项目了。

Choose File - Import menu and select Existing Projects into Workspace. Click Next and browse for the lesson20 directory.

选择 File - Import 菜单，选 Existing Projects into Workspace，点 Next，然后浏览到 lesson20 目录。

You should see the "lesson" project in the lesson20 directory, click "Select All", and the Finish button.

你应该能在 lesson20 目录下看到 lesson 项目，点"Select All"，然后点 Finish。

At the end of all this, you should have the "lesson" project open in Eclipse, but this time this is the new one corresponding to lesson 20.

搞定之后，Eclipse 里应该已经打开了 lesson 项目——不过这次对应的是第20课的新项目。

Let's first open the two source modules you have here, which are main.c and bsp.c and put them conveniently side-by-side.

先把这里的两个源文件 main.c 和 bsp.c 打开，方便起见把它们并排放着。

The main code consists of the customary endless while(1) loop, in which the Green LED is turned on and off.

主代码就是那个常见的无限 while(1) 循环，在里面控制绿色 LED 的亮灭。

The BSP code contains the SysTick_Handler interrupt service routine, which is set up to fire twice a second to toggle the Blue LED.

BSP 代码里有一个 **SysTick_Handler 中断服务程序（ISR）**，设置为每秒触发两次，用来翻转蓝色 LED。

For this lesson, let's modify the main code by commenting out the two lines, which turn the green LED on and off by means of the special DATA_Bits array of GPIO registers that I have explained in Lesson 7.

这节课我们要修改主代码，把用 DATA_Bits GPIO 寄存器数组控制绿色 LED 亮灭的那两行注释掉——这个数组我在第7课讲过。

Instead of using the DATA_Bits array, today you will simply use the DATA register, which controls all 8 GPIO lines attached to the bits 0 through 7.

不用 DATA_Bits 数组了，今天我们直接用 **DATA 寄存器**——它控制着位 0 到 7 对应的全部 8 条 GPIO 线。

Specifically, to set a desired bit, you will read the DATA register, logically OR it with the LED_GREEN bit, and then write the result back to the DATA register. You are doing all this not to disturb the other 7 bits of the DATA register which control other things than your Green LED.

具体来说，要置位的话，先读 DATA 寄存器，跟 LED_GREEN 位做逻辑或，然后写回去。这么麻烦是为了不干扰 DATA 寄存器的其他 7 位——它们控制着绿色 LED 以外的其他功能。

By the way, if you don't remember how the bitwise operators work, please go back to lesson 6.

顺便说一句，如果你忘了**位运算符（bitwise operator）**怎么用，回去复习一下第6课。

To clear a desired bit, you will read the DATA register, logically AND it with the inverted LED_GREEN bit, and write the result back to the DATA register.

要清位的话，先读 DATA 寄存器，跟 LED_GREEN 的取反做逻辑与，然后写回去。

I specifically used the lengthy way of writing these expressions, to show you that a GPIO bit is set or cleared by a **read-modify-write** sequence of operations.

我特意用这么啰嗦的方式写这些表达式，是为了让你看清楚：GPIO 位的置位和清零都是通过**读-改-写（read-modify-write）**操作序列来完成的。

But these expressions can also be written more succinctly by means of the OR-equal and the AND-equal C operators. Please remember, though, that these short forms perform exactly the same read-modify-write sequence of operations.

当然，这些表达式也可以用 C 语言的 `|=` 和 `&=` 运算符写得更简洁。不过记住，这些简写形式底层执行的仍然是完全相同的读-改-写操作序列。

When you build and load your program to the TivaC LaunchPad board, you can see that it still blinks the LEDs as before.

编译好程序烧录到 TivaC LaunchPad 开发板上，可以看到 LED 还是跟以前一样闪烁。

When you break into the code and single step through the main loop, you can see that the Green LED is switched on and off, exactly as you programmed it.

在主循环里打个断点、单步执行，可以看到绿色 LED 按你的代码控制亮灭，完全正常。

Also, when you set a breakpoint in the SysTick_Handler, you can see that it is still toggles the Blue LED every time it is called.

同样，在 SysTick_Handler 里设个断点，可以看到它每次被调用都在翻转蓝色 LED，也没问题。

So, your program seems to work as before, and an inspection of individual elements doesn't show any problems. What's here not to like?

看起来一切正常，逐个检查每个部分都没问题。似乎没什么可挑剔的，对吧？

But, if you watch the board for a while, you can notice that the blinking of the Blue LED is no longer as regular as before. Specifically, sometimes the LED seems to pause for the whole second or even longer.

但是，如果你盯着开发板多看一会儿，就会发现蓝色 LED 的闪烁不像以前那么规律了——有时候好像会停顿整整一秒甚至更久。

To find out why it happens, let's set a breakpoint at the line that turns the Green LED off and open a few new debugger views, such as disassembly and registers.

要搞清楚为什么，我们在关闭绿色 LED 的那行设个断点，同时打开反汇编和寄存器等调试视图。

Now let's single step through the code in assembly.

现在我们在汇编层面单步执行。

First the address of the GPIO-F DATA register is loaded into r3 and r2, and then the value of the DATA register is loaded again into r2. Finally, the BIC instruction clears the Green LED bit (encoded as the immediate argument 8) in the r2 register as well. Please notice that all these machine instructions are generated from one short line of your C code.

先把 GPIO-F DATA 寄存器的地址加载到 r3 和 r2，然后再把 DATA 寄存器的值加载到 r2。接着 BIC 指令把 r2 里的绿色 LED 位清零（立即数参数 8）。注意，所有这些机器指令都是你那一行简短的 C 代码编译出来的。

But before you execute the BIC instruction, let's trigger the SysTick interrupt. I mean, an interrupt can happen at any time, so why not here?

但在执行 BIC 指令之前，我们先手动触发一下 SysTick 中断。毕竟中断随时可能发生，为什么不能刚好在这里呢？

To trigger SysTick, open the NVIC register set, scroll to NVIC_INT_CTRL, write one to the PENDSTSET field, and press return.

要触发 SysTick，打开 **NVIC（嵌套向量中断控制器）** 寄存器组，滚动到 NVIC_INT_CTRL，在 PENDSTSET 字段写入 1，然后按回车。

Before you run the code, restore the Core Registers view, and set some breakpoints. Place the first breakpoint immediately after the BIC instruction, and the second in the SysTick interrupt handler. That way you will know which piece of code executed first. You should be already familiar with this trick from the previous lessons about interrupts.

运行之前，先把 Core Registers 视图恢复出来，再设几个断点：第一个放在 BIC 指令后面紧挨着的位置，第二个放在 SysTick 中断处理程序里。这样你就能知道哪段代码先执行了——这个技巧在之前讲中断的课里你应该已经熟悉了。

Finally, you are ready to run the code by clicking the Resume button. You cannot single-step, because it will disable the interrupt.

好了，点 Resume 按钮让程序跑起来。不能单步，因为单步会禁用中断。

Well, as you can see, the first breakpoint hit is inside the SysTick handler, so it must have executed before your other breakpoint after the BIC instruction. This means that the SysTick handler has preempted the previous code at this exact point.

如你所见，第一个命中的断点在 SysTick 处理程序内部，说明它在 BIC 后面的那个断点之前就执行了。也就是说，SysTick 处理程序恰好在这个位置**抢占（preempt）**了之前的代码。

So now, when you step through the SysTick handler code, you can see that it turns the Blue LED on, as expected, and then it returns back to the BIC instruction.

现在单步执行 SysTick 处理程序的代码，可以看到它按预期打开了蓝色 LED，然后返回到 BIC 指令处。

Now the BIC instruction clears the Green LED bit in r2 and then stores the r2 in the GPIO DATA register.

BIC 指令把 r2 里的绿色 LED 位清掉，然后把 r2 写回 GPIO DATA 寄存器。

Ooops! This last store instruction extinguishes both the Green and the Blue LEDs. This is a problem, because the code was supposed to turn only the Green LED off and exactly not change any other GPIO bits.

糟糕！这最后一条存储指令把绿色和蓝色 LED 同时都关掉了。问题大了——代码本来只应该关绿色 LED，其他 GPIO 位绝对不应该变。

I hope you start to get a sense of what just happened here. The code that turns the Green LED off is a sequence of read, modify, write operations. But the sequence was interrupted after the read but before the write. The interrupt changed the state of the GPIO DATA register, by turning the Blue LED on. However, the interrupted code was unaware of this change and still used the previous value of the GPIO DATA register stored in r2.

希望你开始明白刚才发生了什么。关绿色 LED 的代码是一个读、改、写的操作序列，但这个序列在读取之后、写回之前被中断了。中断把蓝色 LED 打开了，改变了 GPIO DATA 寄存器的状态。而被打断的代码完全不知道这个变化，仍然用了 r2 里存的旧值。

The problem that you have just experienced is called a **RACE CONDITION**. It occurs when two or more pieces of code that can preempt each other access a shared resource in such a way that the result depends on the sequence of execution of these pieces of code.

你刚才遇到的问题就叫**竞态条件（race condition）**。当两个或多个可以互相抢占的代码片段访问**共享资源（shared resource）**，而结果取决于这些代码的执行顺序时，竞态条件就发生了。

Of course, in a toy Blinky example such a Race Condition is not a big deal, but it can be, in fact, a deadly bug.

当然，在这个玩具级的 Blinky 例子里，竞态条件不算什么大事。但在实际系统中，它可能是一个致命的 bug。

Imagine, for example, that instead of just toggling the Blue LED, the SysTick interrupt switches on a cooling system in a nuclear reactor to prevent the reactor from overheating. In this case, the SysTick interrupt has just turned on the cooling system, but the main loop turned it off again just a fraction of a microsecond later.

想象一下：假设 SysTick 中断不是翻转蓝色 LED，而是启动核反应堆的冷却系统来防止过热。中断刚刚启动了冷却系统，结果主循环不到一微秒就又把它关掉了。

The result is that the cooling system remains off, while the reactor melts down.

结果就是冷却系统一直关着，反应堆熔毁了。

With this in mind, I hope you start to see why Race Conditions can be a problem. But I'm not sure that you fully appreciate how nasty they can be.

说到这里，我希望你已经意识到竞态条件为什么是个问题了。不过你大概还没完全体会到它有多恶心。

The problem is that Race Conditions seem to defy logic in the sense that each individual piece of code works correctly. The problem only occurs when the pieces of code are executing together and preempt each other in various places, over which you have no control.

问题在于，竞态条件往往违背直觉——每个代码片段单独看都工作正常，问题只出现在这些代码同时运行、在你无法控制的各个位置互相抢占的时候。

This results in bugs that tend to be intermittent, hard to reproduce, and hard to isolate, as typically there are only narrow time windows when preemption leads to bugs. This means that you might be testing your system for hours or weeks, never noticing any problems. Still, some catastrophic Race Condition bugs might escape to the final product.

这导致的 bug 通常是间歇性的，难以重现，也难以定位，因为抢占导致出错的时间窗口往往非常窄。你可能测了几个小时甚至几周都没发现任何异常，但一些灾难性的竞态条件 bug 还是可能漏到最终产品里。

All this makes Race Conditions the worst possible kind of bugs you ever want to deal with. They are the direct consequence and a huge price of using interrupts. It seems that nothing good in life, not even interrupts, comes for free.

所有这些让竞态条件成为你最不想碰到、却又最棘手的 bug。它是使用中断的直接代价——看来世上没有免费的午餐，中断也不例外。

So now, that I sufficiently scared you, I hope, I'd like to discuss two main strategies of eliminating race conditions.

好了，希望我已经把你吓到了。接下来我们讨论消除竞态条件的两种主要策略。

The first strategy is based on the concept of **mutual exclusion**, which means that you make sure that only one piece of concurrent code can execute while accessing a shared resource.

第一种策略的核心概念是**互斥（mutual exclusion）**——确保在访问共享资源时，只有一个并发代码片段在执行。

In the case of your Blinky program, you can implement mutual exclusion by simply disabling interrupts around turning the Blue LED on and around turning it off. This will preclude preemption by the SysTick interrupt, and will eliminate the race condition.

在我们的 Blinky 程序里，实现互斥很简单：在开和关蓝色 LED 的操作前后各加上禁用和启用中断就行了。这样 SysTick 中断就没法抢占了，竞态条件也就消除了。

Let's quickly take a look at this modified version in the debugger.

我们到调试器里快速看一下修改后的版本。

First, the intrinsic function `__disable_irq()` generates just one machine instruction "CPSID i". There is no function call overhead here, which is the beauty of using intrinsic functions.

首先，**内建函数（intrinsic function）** `__disable_irq()` 只生成一条机器指令 "CPSID i"。没有函数调用开销——这就是用内建函数的好处。

Similarly, `__enable_irq()` generates also one instruction "CPSIE i".

类似地，`__enable_irq()` 也只生成一条指令 "CPSIE i"。

Both these instructions execute in just one clock cycle, so the additional overhead of disabling interrupts really small.

两条指令都只需一个时钟周期，所以禁用中断的额外开销其实非常小。

BTW, the section of code between interrupts disabling and enabling is called a **"Critical Section"**.

顺便提一下，禁用中断和启用中断之间的代码段有个专门的名字——**临界区（Critical Section）**。

So, now let's repeat exactly the previous test of triggering the SysTick interrupt and setting the breakpoints to find out the order of code execution.

好，现在我们完全重复之前的测试：触发 SysTick 中断，设好断点，看看代码的执行顺序。

Single step up to the BIC instruction.

单步执行到 BIC 指令。

Trigger the SysTick interrupt in the NVIC.

在 NVIC 里触发 SysTick 中断。

Set a breakpoint just after the BIC instruction.

在 BIC 指令后面紧挨着设一个断点。

And another one in the SysTick handler.

另一个断点设在 SysTick 处理程序里。

Run the application by clicking the Resume button.

点 Resume 按钮让程序跑起来。

As you can see, this time, the SysTick did not preempt the main code, but instead the breakpoint at the STR instruction was hit.

如你所见，这次 SysTick 没有抢占主代码，而是命中了 STR 指令处的断点。

However, the SysTick interrupt is not lost.

不过 SysTick 中断并没有丢。

It fires as soon as interrupts get enabled.

中断一启用，它马上就触发了。

When you single step through the interrupt code, you can see that it turns the Blue LED on.

单步执行中断代码，可以看到它把蓝色 LED 打开了。

The interrupt then returns back to the main code at the top of the loop.

然后中断返回到主代码循环的顶部。

In summary, the introduction of critical sections serialized the access to the shared resource, the GPIOF->DATA register in this case, and made it **atomic**, meaning indivisible.

总结一下：引入临界区之后，对共享资源（这里就是 GPIOF->DATA 寄存器）的访问被序列化了，变成了**原子操作（atomic）**——也就是说不可分割。

With critical sections in place, the three pieces of code: the SysTick interrupt and the two critical sections, can run either before or after each other, but not in the middle. This is what mutually exclusive access means.

有了临界区，三段代码——SysTick 中断和两个临界区——彼此之间要么在前要么在后执行，但绝不会在中间插入。这就是互斥访问的含义。

But even better than mutual exclusion is to avoid race conditions by not sharing any resources in the first place.

不过，比互斥更好的办法是一开始就不共享资源，从根本上避免竞态条件。

So, let me comment out today's code, to leave it there for you to experiment, and revert to the original code.

所以，我把今天的代码注释掉，留着给你实验，然后恢复到原始代码。

This original code does not use the DATA register, but instead it uses the DATA_Bits array of 255 GPIO registers.

原始代码不用 DATA 寄存器，而是用那 255 个 GPIO 寄存器组成的 DATA_Bits 数组。

I have devoted almost entire lesson 7 to explaining how this array of GPIO registers works, so I won't repeat it here. But the main point for today is that the array provides a separate register for every possible combination of the 8 GPIO bits, so the register DATA_Bits[LED_GREEN] is different than the register DATA_Bits[LED_BLUE], for example. This means that there is no sharing of the common DATA register, and, as you will see in a minute in disassembly, there is no need for the read-modify-write sequence either.

我几乎用了整个第7课来解释这个 GPIO 寄存器数组的工作原理，这里就不重复了。今天的要点是：这个数组为 8 个 GPIO 位的每种组合都提供了独立的寄存器。比如 DATA_Bits[LED_GREEN] 和 DATA_Bits[LED_BLUE] 是两个不同的寄存器。这意味着不存在共享 DATA 寄存器的问题，而且你马上会在反汇编中看到——读-改-写序列也不需要了。

Setting a given bit is accomplished by a simple **atomic** write to the dedicated DATA_Bits register and so is clearing of a given bit.

置位就是向专用的 DATA_Bits 寄存器做一次简单的**原子写入（atomic write）**，清位也一样。

So now you finally understand why the hardware engineers at Texas Instruments have designed the GPIO registers in this peculiar and complex way. They did it exactly to separate the various GPIO bits, to avoid the need of sharing them and thus eliminating potential race conditions in the software. Those folks did the heavy lifting in hardware, so that your life, as the software designer can be easier.

现在你终于明白了——德州仪器（TI）的硬件工程师为什么要把 GPIO 寄存器设计得这么特殊、这么复杂。他们就是为了把各个 GPIO 位隔离开，避免共享，从而在软件层面消除潜在的竞态条件。人家在硬件上做了重活，就是为了让咱们软件工程师的日子好过一些。

This concludes the lesson about race conditions. In the next lesson I will talk about prioritizing interrupts and about other ways of disabling interrupts on the ARM Cortex-M processor.

关于竞态条件的课就到这里。下一课我们来聊中断优先级，以及在 ARM Cortex-M 处理器上禁用中断的其他方法。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Race Condition | 竞态条件 | 两个或多个可互相抢占的代码片段访问共享资源时，结果取决于执行顺序的问题 |
| Shared Resource | 共享资源 | 被多个并发执行的代码片段共同访问的资源（如寄存器、变量等） |
| Read-Modify-Write | 读-改-写 | 一种操作序列：先读取值、修改其中某些位、再写回，是非原子操作的典型模式 |
| Mutual Exclusion | 互斥 | 确保同一时刻只有一个代码片段可以访问共享资源的机制 |
| Critical Section | 临界区 | 禁用中断和启用中断之间的代码段，用于实现对共享资源的互斥访问 |
| Atomic / Atomicity | 原子操作 / 原子性 | 不可分割的操作，要么完整执行，要么不执行，不会被中断打断 |
| Preemption | 抢占 | 高优先级代码（如中断）暂时挂起当前正在执行的低优先级代码 |
| Interrupt Service Routine (ISR) | 中断服务程序 | 响应中断请求而执行的处理函数 |
| NVIC (Nested Vectored Interrupt Controller) | 嵌套向量中断控制器 | ARM Cortex-M 处理器中管理中断的硬件模块 |
| SysTick | 系统节拍定时器 | ARM Cortex-M 内置的定时器，常用于产生周期性中断 |
| Intrinsic Function | 内建函数 | 编译器直接识别并替换为特定机器指令的特殊函数，无函数调用开销 |
| `__disable_irq()` / `__enable_irq()` | 禁用/启用中断函数 | ARM CMSIS 提供的内建函数，分别生成 CPSID i 和 CPSIE i 指令 |
| CPSID i / CPSIE i | 禁用/启用中断指令 | ARM Cortex-M 的处理器指令，用于控制中断屏蔽 |
| BIC instruction | BIC 指令（位清除） | ARM 指令集中用于清除寄存器中指定位的指令 |
| DATA_Bits array | DATA_Bits 寄存器数组 | TI TivaC GPIO 中为每位提供独立寄存器的特殊设计，共 255 个 |
| GPIO (General-Purpose Input/Output) | 通用输入/输出 | 微控制器上可编程的通用引脚，可用于输入或输出 |
| BSP (Board Support Package) | 板级支持包 | 硬件抽象层，封装了特定开发板的硬件操作细节 |
| CMSIS (Cortex Microcontroller Software Interface Standard) | Cortex 微控制器软件接口标准 | ARM 定义的软件接口标准，提供一致的硬件访问方法 |
| Code Composer Studio (CCS) | Code Composer Studio | TI 提供的基于 Eclipse 的集成开发环境 |
