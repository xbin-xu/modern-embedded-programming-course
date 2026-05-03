# 第52课：前后台架构中的低功耗睡眠模式 / Lesson 52: Low-Power Sleep in the Superloop

Hello and welcome to the Modern Embedded Systems Programming course. I'm Miro Samek, and in this lesson, I go back to the foreground background architecture, also known as the "superloop." This time, I focus on combining it with the low-power sleep modes of the CPU.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这节课我们回到前后台架构（foreground/background architecture），也就是常说的"超级循环"（superloop）。这次的重点是：怎么把它跟 CPU 的**低功耗睡眠模式**（low-power sleep mode）结合起来。

If you're new to the Quantum Leaps channel and the Modern Embedded Systems Programming course, I introduced the foreground/background architecture in lesson #21. However, I still need to explain the use of low-power sleep modes in the "superloop" because it is tricky, and many developers, including myself in the past, get it wrong. The need to explain these aspects came up while I planned future lessons about the various ways of executing event-driven Active Objects, so this lesson lays some groundwork for the next one.

如果你刚接触 Quantum Leaps 频道和这个课程，前后台架构我在第 21 课已经介绍过了。但超级循环里怎么用低功耗睡眠模式，这个还没讲过——因为这里面有不少坑，很多开发者（包括过去的我自己）都踩过。之所以现在要讲这些，是因为后面几课要讲事件驱动主动对象（Active Objects）的不同执行方式时会用到，所以这节课算是为下一课打个基础。

However, the subject of today's lesson is important in its own right, especially because the "superloop," also known as the "bare metal" firmware structure, is applied in such a wide range of products, many of them battery-operated.

不过，今天这个话题本身就很重要。超级循环也叫**裸机**（bare metal）固件结构，用得非常广泛，而且很多产品都是电池供电的，低功耗设计尤其关键。

So, let's begin today with the basic principles of low-power design.

好，我们先从低功耗设计的基本原理说起。

The power dissipated by general-purpose digital electronics consists of static dissipation due to current leakage and dynamic dissipation due to switching. Dynamic dissipation typically dominates and is caused by charging and discharging internal parasitic capacitances as the circuit switches from zero to one and one to zero.

通用数字电路的功耗分两部分：漏电流造成的**静态功耗**和开关切换造成的**动态功耗**。动态功耗通常占大头——电路在 0 和 1 之间切换时，要对内部的寄生电容不断充放电，这就是动态功耗的来源。

Perhaps a useful mental model of the process is that switching from zero to one is like filling a bucket (capacitance) with water (electric charge), and switching from one to zero is like tossing the water out (discharging the capacitor). This happens at every clock tick, meaning at megahertz frequencies. The amount of wasted power is proportional to how many such buckets are filled and how frequently that happens.

打个比方可能更容易理解：从 0 变到 1，就像用水（电荷）灌满一个水桶（电容）；从 1 变到 0，就像把水倒掉（放电）。这个过程每个时钟节拍都在发生，频率是兆赫兹级别的。浪费的功率跟"有多少个这样的水桶"以及"多久灌一次"成正比。

That's why modern microcontrollers allow the software to turn the clock signal on and off for various peripherals. However, to achieve really low power consumption, the clock signal must be turned off for the CPU itself, which is called a low-power sleep mode. This poses an interesting problem because the CPU stops executing instructions, so the software is no longer in control. The CPU must thus be woken up by external means, typically an interrupt.

所以现代微控制器允许软件单独开关各个外设的时钟。但想要真正实现低功耗，还得把 CPU 自身的时钟关掉——这就是低功耗睡眠模式。这带来一个有意思的问题：CPU 停止执行指令了，软件就失去了控制权。必须靠外部手段来唤醒 CPU，通常就是靠**中断**（interrupt）。

Which brings us to the foreground/background software architecture, where the foreground consists of interrupts, and the background consists of the endless loop inside the main function. As usual, the interrupts should be short and fast, and the bulk of the work should be performed in the background loop. But now, the background loop must also enter the CPU sleep mode.

这就引出了前后台软件架构——前台是中断，后台是 main 函数里的无限循环。照惯例，中断要短小精悍，主要工作在后台循环里完成。但现在，后台循环还得负责让 CPU 进入睡眠模式。

The critical design decision is how exactly the background loop should detect that the CPU can be safely stopped in a low-power sleep mode.

关键的设计问题是：后台循环到底该怎么判断"现在可以安全地让 CPU 进入睡眠了"？

Well, many people ask this question. Here, for example, is a post on the STM32 community forum: "How to work with interrupts and low power modes when using the HAL?" HAL means "Hardware Abstraction Layer," and in the context of STM32, it implies the "superloop" architecture.

很多人都在问这个问题。比如 STM32 社区论坛上就有这样一个帖子："使用 HAL 时如何处理中断和低功耗模式？"HAL 就是**硬件抽象层**（Hardware Abstraction Layer），在 STM32 的语境下，它暗含的就是超级循环架构。

The person asking this question provides his sample code, which is based on the global bitmask of flags, where each bit is associated with a task to be performed in the background loop. The flags are set in the foreground, like here in the callback functions invoked from the interrupt service routines.

提问者附上了他的示例代码，核心思路是用一个全局的**位掩码**（bitmask）来管理标志位——每个位对应后台循环中的一个任务。标志位在前台设置，比如在中断服务程序（ISR）调用的回调函数里。

The advantage of having all the task flags grouped together in a single bitmask is that the background loop can quickly check whether all the flags are cleared, meaning there are no tasks to perform. In that case, the background loop suspends some peripherals and enters sleep mode. This stops the code execution until an interrupt occurs.

把所有任务标志集中在同一个位掩码里的好处是：后台循环可以快速检查是否所有标志都清零了——也就是没有待办任务。如果是的话，就挂起一些外设，进入睡眠模式。CPU 停下来等中断唤醒。

When the CPU wakes up, the background loop resumes and checks which individual flags are set. For all set bits, the loop calls the associated handler functions and also clears the bits to indicate that the tasks are done.

CPU 被唤醒后，后台循环恢复运行，逐个检查哪些标志位被置位了。对每个置位的位，调用对应的处理函数，然后把位清掉，表示这个任务完成了。

This looks like a reasonable starting point, so let's actually implement this design and run it on your TivaC LauchPad.

这个思路看起来挺合理，那我们就实际动手实现一下，在你的 TivaC LaunchPad 上跑跑看。

For this, you can copy the original project for lesson #21 about the "superloop" and rename it to lesson #52. Here, let me quickly explain the new structure of the companion code downloads, which now are self-contained and include all the dependencies and projects for various boards, not just the TivaC LaunchPad. For example, many code downloads come with projects for the STM32 NUCLEO-C031C6 board. The work to support this Cortex-M0+ board and perhaps others as well is ongoing, but the downloads are gradually updated and maintained.

首先，你可以把第 21 课超级循环的原始项目复制一份，重命名为第 52 课。顺便说一下，配套代码下载的结构最近改了——现在是自包含的，所有依赖项和各种开发板的项目都打包在一起，不再只是 TivaC LaunchPad 了。比如很多代码包里都有 STM32 NUCLEO-C031C6 的项目。对这块 Cortex-M0+ 以及其他开发板的支持还在持续进行中，下载内容会不断更新维护。

But going back to the code for this lesson, let's get into the tm4c-keil directory and double-click on the micro-vision project lesson.

回到本课的代码，进入 tm4c-keil 目录，双击打开 micro-vision 项目文件。

Now, let's copy the low-power "superloop" pseudocode from the ST discussion forum and paste it into the main.c file in your micro-vision project. Since this is just pseudocode, I need to make it more specific and improve its formatting in the process. The initialization is board-specific, so it'll be a call BSP_init(). Now, inside the "superloop", all steps related to entering the sleep mode will be accomplished in the BSP_goToSleep() function. In the task activation section, the first task will, for example, deploy an airbag. The second task will, for example, engage an Anti-Lock Braking System.

好，现在把 ST 论坛上那段低功耗超级循环的伪代码复制过来，粘贴到你项目的 main.c 里。既然是伪代码，我得让它更具体一些，顺便整理下格式。初始化部分是跟开发板相关的，所以封装成 BSP_init()。在超级循环内部，所有进入睡眠模式的操作都放在 BSP_goToSleep() 函数里。任务激活部分，第一个任务比如是部署安全气囊（airbag），第二个任务比如是启动防抱死制动系统（ABS）。

Once I know what BSP facilities will be needed, I must declare them in bsp.h header file.

确定好需要哪些 BSP 功能后，就要在 bsp.h 头文件里声明它们。

Now, in the bsp.c source file, I must provide the board-specific implementation of all these facilities plus the Interrupt Service Routines (ISRs).

然后在 bsp.c 源文件中，给出这些功能的开发板具体实现，再加上中断服务程序（ISR）。

The interrupts will be triggered by the onboard buttons, which are connected to the GPIOF port. Specifically, pressing SW1 will activate task-1 and pressing SW2 will activate task-2.

中断由板上的按钮触发，这些按钮连在 GPIOF 端口上。具体来说，按 SW1 激活 task-1，按 SW2 激活 task-2。

I should not forget to provide the definitions of the button pins and, most importantly, the global bitmask of task flags.

别忘了定义按钮引脚，最重要的是定义那个全局的任务标志位掩码。

The BSP_init() function needs to be extended to initialize the GPIOF pins for the buttons, and it also needs to configure and enable the GPIOF interrupt.

BSP_init() 函数要扩展一下，初始化按钮对应的 GPIOF 引脚，还要配置并启用 GPIOF 中断。

The BSP_deployAirbag() function will turn the onboard red LED to emulate airbag deployment.

BSP_deployAirbag() 函数会点亮板载红色 LED 来模拟安全气囊的部署。

Similarly, the BSP_engageABS() function will turn the onboard blue LED to emulate the ABS engagement.

类似地，BSP_engageABS() 函数点亮板载蓝色 LED 来模拟 ABS 的启动。

Finally, the most interesting for today BSP_goToSleep() function will put the CPU to sleep by means of the ARM Cortex-M WFI instruction: Wait-for-Interrupt. This is equivalent to the original function HAL_PWR_EnterSLEEPMode() with the PWR_SLEEPENTRY_WFI argument. Additionally, the go-to-sleep function will count the number of its invocations using a global counter, which will be helpful for debugging.

最后，今天最关键的部分——BSP_goToSleep() 函数，它通过 ARM Cortex-M 的 **WFI 指令**（Wait-For-Interrupt，等待中断）让 CPU 进入睡眠。这相当于 STM32 HAL 库里的 HAL_PWR_EnterSLEEPMode() 函数传入 PWR_SLEEPENTRY_WFI 参数的效果。另外，这个函数还用了一个全局计数器来记录被调用了多少次，方便调试。

This would be all for now, so let's try to build the project...

先到这，让我们构建一下项目看看……

Alright, so let's run it!

好，运行一下！

So here is my arrangement of the various debugger views. I have CPU registers, source code, disassembly window, the call stack, and watch view with two critical variables: the global isr_flags bitmask and the goToSleep counter.

这是我安排的调试器视图布局：CPU 寄存器、源代码、反汇编窗口、调用栈，还有监视窗口——里面有两个关键变量：全局的 isr_flags 位掩码和 goToSleep 计数器。

My first test is to just run the code free.

第一步，让代码自由运行。

You can see that the goToSleep counter has immediately incremented, but only once.

可以看到 goToSleep 计数器立刻加了一，但只加了这一次。

When I break into the code, I find it inside the BSP_goToSleep() function called from main(). This, plus the value of the goToSleep counter, means that the CPU was indeed stopped at the Wait-For-Interrupt instruction. If the CPU was not stopped, the goToSleep counter would be in the millions.

暂停代码，发现它停在 main() 调用的 BSP_goToSleep() 函数里。再加上 goToSleep 计数器的值，说明 CPU 确实停在了 Wait-For-Interrupt 指令上。如果 CPU 没停下来，这个计数器早就跑到几百万了。

I can repeat it, but every time I find the code stopped at WFI inside the BSP_goToSleep().

再试几次，每次都一样——代码停在 BSP_goToSleep() 内部的 WFI 指令处。

Now, I add a breakpoint in the GPIOF interrupt handler and let the code run.

现在在 GPIOF 中断处理程序里加个断点，让代码继续跑。

Next, I press the SW1 button on the board.

然后按一下板上的 SW1 按钮。

My breakpoint is immediately hit, so I step through the code to verify that the task-1 flag is set in the global isr_flags bitmask.

断点立刻命中。单步执行，确认 task-1 标志位已经在全局 isr_flags 位掩码中被置位了。

I keep stepping to find out where the interrupt returns and what happens inside the background "superloop."

继续单步，看看中断返回到哪里，以及后台超级循环里发生了什么。

Indeed, the loop continues from goToSleep to checking the global bitmask. It finds the task-1 flag, clears it, and calls the deployAirbag function.

确实，循环从 goToSleep 之后继续，去检查全局位掩码。发现 task-1 标志位被置位了，清掉它，然后调用 deployAirbag 函数。

That function turns on the red LED and returns. The test-2 flag is not set, so the loop wraps up and goes back to sleeping.

这个函数点亮红色 LED 然后返回。task-2 标志位没有置位，循环结束，回去继续睡眠。

I can repeat it, and it works as before.

再试一次，效果一样。

Now, I remove the breakpoint and run the code free.

去掉断点，让代码自由运行。

Pressing the SW1 button increments the goToSleep counter, but sometimes by more than once, which is expected due to the bouncing of the mechanical switch.

按 SW1，goToSleep 计数器会递增，但有时候不止加一——这是正常的，因为机械开关有**抖动**（bouncing）。

Now, I break into the code and reset the target to start over.

暂停代码，复位目标板，从头来。

Pressing SW1 turns the red LED, and pressing SW2 turns the blue LED, which verifies that my second task engageABS(), also works as expected.

按 SW1 亮红色 LED，按 SW2 亮蓝色 LED。说明第二个任务 engageABS() 也工作正常。

So far, so good. What's not to like?

到目前为止一切顺利。有什么问题吗？

Well, for starters, if you watched lesson #20 about race conditions, you should immediately realize that this code is chock full of them. Specifically, the isr_flags bitmask is shared between the background loop and interrupts, so every time it is accessed, you have a potential race condition.

嗯，首先，如果你看过第 20 课关于竞态条件（race condition）的内容，你应该立刻意识到——这段代码里到处都是竞态条件。具体来说，isr_flags 位掩码在后台循环和中断之间共享，每次访问它都有竞态条件的隐患。

But in lesson #20, you also learned that you can avoid such race conditions by making sure that every access to the shared variable occurs within a critical section, that is, with interrupts disabled.

但在第 20 课里你也学过，解决办法是：确保每次访问共享变量都在**临界区**（critical section）内进行，也就是说要关中断。

So, let's try to apply this to the background loop, whereas the functions for interrupt disabling and enabling will be defined in the BSP.

那我们就把这个方案应用到后台循环中。中断的开关函数定义在 BSP 里。

Starting from the top of the loop, you disable interrupts right before testing the shared isr_flags bitmask. Now, it seems obvious that you must enable interrupts before going to sleep because only interrupts can wake the CPU up. You will see why this is problematic in a minute, but I've done something like that in the early days of my career, and I keep seeing this published in books, so it must be popular in the field and therefore requires explanation.

从循环顶部开始，先关中断，然后检查共享的 isr_flags 位掩码。接下来，显然需要在进入睡眠之前重新开中断——因为只有中断才能唤醒 CPU。你马上就会看到这样做有什么问题。但我早年也这么干过，而且不断在书上看到这种写法，说明它在业界确实很流行，所以值得专门讲讲。

But for now, let's press on with your immediate goal of eliminating race conditions.

不过先不管这些，继续推进目标——消除竞态条件。

So, after goToSleep() returns, you disable interrupts to proceed to the testing of the shared variable in the next step. Please note that in case the if-branch wasn't taken, interrupts remain disabled, so all possible execution paths are covered.

goToSleep() 返回后，关中断，继续下一步检查共享变量。注意，如果 if 分支没进去，中断本来就是关着的，所以所有执行路径都覆盖到了。

You repeat the same pattern of enabling interrupts before calling the task function and disabling them after it returns to proceed to the next task. Of course, you keep clearing the task bit inside the critical section.

同样的模式重复下去：调用任务函数之前开中断，调用完之后关中断，继续下一个任务。当然，清标志位要在临界区内完成。

After the last task, you enable interrupts so that they can be serviced before looping back to the top of your "superloop."

最后一个任务处理完后，开中断，让挂起的中断有机会被服务，然后循环回到超级循环的顶部。

Now, you still need to add the new BSP function prototypes to the bsp.h header file.

好，还要把新的 BSP 函数原型加到 bsp.h 头文件里。

And for the implementation, in bsp.c, you define the interrupt disabling and enabling functions by means of the intrinsic functions __disable_irq() and __enable_irq(), respectively.

实现上，在 bsp.c 里用内联函数（intrinsic function）__disable_irq() 和 __enable_irq() 分别定义关中断和开中断函数。

The project builds cleanly, so let's see how this works.

项目编译通过，来看看效果。

The first order of business is to check that this version works at least as well as the previous. So, you run the code free and press the SW1 button. Red LED means that the first deployAirbag() task was called. Now, you press SW2, and the blue LED lights up, proving that the second engageABS() task was also called.

先确认这个版本至少跟之前一样正常。自由运行，按 SW1——红色 LED 亮，说明 deployAirbag() 被调用了。按 SW2——蓝色 LED 亮，说明 engageABS() 也被调用了。

When you break into the code, you can see that it sits inside goToSleep, and the isr_flags bitmask is cleared, which means that no tasks are ready. So far, so good.

暂停代码，看到它停在 goToSleep 里面，isr_flags 位掩码已经清零——没有待办任务。目前为止一切正常。

But now, let's investigate deeper. Reset the target to start from scratch and set a breakpoint at the first test of the shared isr_flags variable. When you run the code and stop at the breakpoint, verify that the PRIMASK register is 1, which means that interrupts are disabled. Now, set a second breakpoint at the beginning of the GPIOF interrupt handler and move the first breakpoint to the intDisable function just after goToSleep().

但接下来，我们深入看看。复位目标板从头开始，在第一次检查 isr_flags 的地方设断点。运行到断点，确认 PRIMASK 寄存器是 1——说明中断关着。然后在中断处理程序入口设第二个断点，把第一个断点移到 goToSleep() 之后的 intDisable 函数处。

Press the SW1 button. This emulates interrupt occurring at this precise point in the code. I mean, the button press can occur at any time, so why not here. When you run the code, the first breakpoint hit is inside the interrupt. This makes sense because the interrupt was serviced immediately after interrupts got enabled in the superloop. Step inside the ISR to see that it sets the task-1 flag and continue to see what happens next.

按一下 SW1。这模拟了在代码恰好执行到这个位置时发生了中断。按钮按下随时可能发生，为什么不能是这时候呢？继续运行，第一个命中的是中断处理程序里的断点。这说得通，因为超级循环一开中断，挂起的中断立刻就被服务了。单步进入 ISR，确认它设置了 task-1 标志位，然后继续看接下来怎样。

And... nothing else happens. In particular, the breakpoint downstream from sleeping is NOT hit.

然后……什么也没发生。特别是，睡眠之后那个断点始终没有被命中。

Indeed, when you break into the code, you find it sleeping in the goToSleep function, but the isr_flags bitmask is still 1, which means that task-1 is ready to run.

确实，暂停代码一看，CPU 停在 goToSleep 函数里睡大觉，但 isr_flags 位掩码还是 1——task-1 明明已经就绪了。

Only now, when you continue, you hit the first breakpoint, and when you continue again, you see the red LED light up.

直到你继续执行，才命中第一个断点；再继续，红色 LED 才亮起来。

All this is really bad because it literally means that the CPU fell asleep at the switch. Specifically, the airbag was not deployed on time, and instead, the CPU was put to sleep until some other completely unrelated interrupt would wake it up.

这真是太糟糕了——CPU 在关键时刻睡着了。安全气囊没有及时弹出，CPU 反而进了睡眠，要等到某个完全不相关的中断来把它唤醒。

The mechanism of this failure is quite simple. If the interrupt occurs during the first critical section, it will be serviced immediately after interrupts are re-enabled. However, due to its simplistic, non-preemptive nature, the "superloop" is committed to going to sleep no matter what, and so it does.

这个 bug 的机制很简单：如果中断在第一个临界区期间发生了，开中断后会立刻被服务。但由于超级循环是简单的非抢占式结构，它已经铁了心要进入睡眠——不管有没有待办任务，它都会睡过去。

So, let's now discuss the ways you can fix the problem.

那接下来，我们讨论怎么修复这个问题。

It turns out that on the Cortex-M CPUs this "superloop" structure can be salvaged by replacing the Wait-for-Interrupt instruction with Wait-for-Event. As described in the "Definitive Guide to ARM Cortex-M3/M4 Processors" by Joseph Yiu, WFE is conditional and relies on some internal flags maintained by the Cortex-M CPU. To work around some hardware defects in early Cortex-M3s, Joseph Yiu recommends applying WFE in a more elaborate sequence. That's why you see this sequence in the STM32 implementation of the HAL_PWR_EnterSLEEPMode() function referenced earlier in this video.

在 Cortex-M 上，这个问题其实有个补救办法：把 Wait-for-Interrupt 换成 **Wait-for-Event（WFE）**。Joseph Yiu 在《ARM Cortex-M3/M4 处理器权威指南》中解释过，WFE 是有条件的，它依赖 Cortex-M CPU 内部维护的一些标志。为了规避早期 Cortex-M3 的某些硬件缺陷，Joseph Yiu 建议用一套更精细的指令序列来实现 WFE。视频前面提到的 STM32 HAL_PWR_EnterSLEEPMode() 函数中就能看到这套序列。

However, I will not investigate this solution any further because it only applies to ARM Cortex-M. In most other CPUs, enabling interrupts before entering low-power sleep mode can't be made to work safely in a "superloop" architecture.

但我不会深入展开这个方案，因为它只适用于 ARM Cortex-M。在大多数其他 CPU 上，先开中断再进睡眠这种做法在超级循环架构里没法安全工作。

On the other hand, virtually all CPUs, including ARM Cortex-M, support entering low-power sleep modes atomically with interrupts still DISABLED. Indeed, several years ago, in 2007, I surveyed various embedded microcontrollers, many outdated by now, in my article "Use an MCU's low-power modes in foreground/background systems." The motivation for that article was precisely to avoid the problem caused by disabling interrupts before going to sleep.

另一方面，几乎所有 CPU——包括 ARM Cortex-M——都支持在中断仍然**关闭**的情况下原子地进入低功耗睡眠模式。其实早在 2007 年，我就在一篇文章里调研过各种嵌入式微控制器（很多现在已经过时了），题目叫"Use an MCU's low-power modes in foreground/background systems"。写那篇文章的动机正是为了解决关中断再进睡眠带来的问题。

My old article is not alone, of course, as the various microcontroller vendors also publish techniques for entering sleep mode with interrupts still disabled. One notable example is the MSP430 microcontroller family from Texas Instruments, one of the industry's lowest-power designs. The application notes and code examples for MSP430 always enter the sleep mode with interrupts disabled and re-enable interrupts atomically when going to sleep.

当然不只我那篇文章，各家芯片厂商也都推荐关着中断进睡眠的做法。德州仪器（TI）的 MSP430 系列就是个典型例子——这是业界最低功耗的设计之一。MSP430 的应用笔记和代码示例，无一例外都是关着中断进睡眠，然后在进入睡眠的那一刻原子地重新开启中断。

This way of implementing low-power modes in the "superloop" is also recommended for Cortex-M. Indeed, let's go back to the STM32 support forum and find the original question I used at the beginning of this video. The question has an answer, where an ST expert provides the recommended code structure for a low-power "superloop." The expert-recommended architecture differs in some essential aspects from what you have at this point, so let's copy, paste, and adapt it for your project.

这种在超级循环里实现低功耗的方式，在 Cortex-M 上也是推荐的。回到视频开头提到的那个 STM32 论坛帖子，下面有个回答——一位 ST 专家给出了推荐的低功耗超级循环代码结构。这个推荐的架构跟你目前写的有几个关键区别，我们来复制、粘贴、改编到你的项目中。

The recommeded top of the "superloop" is essentially the same, whereas your version just hides the sleep transition in the BSP_goToSleep() function entered with interrupts disabled and re-enabling interrupts after the Wait-For-Interrupt instruction.

推荐的超级循环顶部基本一样。区别在于：BSP_goToSleep() 函数是在中断关闭的状态下调用的，而在 WFI 指令执行之后才重新开启中断——睡眠转换就封装在这个函数里。

However, the recommended task-processing code does not follow directly, but rather is executed in the else-branch. It also differs in other aspects, so let's adapt it.

但推荐的任务处理代码不是直接跟在后面，而是放在 else 分支里执行的。其他方面也有区别，我们来调整一下。

The main difference here is that there is only one critical section, where you are supposed to select only the task to execute and clear the task bit in the bitmask.

最关键的区别是：只有一个临界区，在里面选择要执行的任务，然后把对应的位清掉。

Regarding the selection of the task to execute, this is an ideal use case for a pointer to function, which I will name 'task'. If you don't remember what pointers-to-function are, they were used extensively in lesson #39 about the optimal state machine implementation.

说到怎么选择任务，这是**函数指针**（pointer to function）的理想用例。我把这个变量命名为 `task`。如果你忘了函数指针是什么，第 39 课讲最优状态机实现的时候大量用过。

Since you're supposed to choose only one task, you need to put the other selection in the else-branch.

因为每次只选一个任务，所以另一个选择要放在 else 分支里。

Now, regarding the task execution, I use the explicit syntax with pointer de-referencing to make it absolutely clear that this is a call via the pointer named "task."

关于任务执行，我用了显式的指针解引用语法，让大家一眼就能看出这是通过 `task` 指针间接调用的。

But I still need to define the "task" variable and the typedef for its task_handler type.

不过还得定义 `task` 变量，以及它的 task_handler 类型的 typedef。

Finally, I need to do something in case none of the if branches are taken because this will leave the "task" pointer-to-function uninitialized, so the subsequent task execution will certainly cause a crash.

最后还得处理一个问题：如果所有 if 分支都没进去，`task` 函数指针就没被初始化，接下来调用它肯定会崩溃。

This should never happen in a correctly running scheduler that you've just built, so that is an ideal place to use an assertion. If you are unfamiliar with embedded assertions, they were covered in lessons #47 and #48. Here, I just call the assertion handler already defined in the BSP.

在你刚构建的这个调度器正常运行时，这种情况不应该发生。所以这里正好用**断言**（assertion）来防护。如果不熟悉嵌入式断言，第 47、48 课讲过。这里直接调用 BSP 里已经定义好的断言处理函数。

This should be all, so let's try to build the project.

应该差不多了，构建一下项目。

All right, I still need to provide the assertion handler prototype in bsp.h.

哦，还需要在 bsp.h 里加上断言处理函数的原型。

And I have to delete the superfluous for-ever directive.

还有删掉多余的 for-ever 指令。

No errors and no warnings. So, let's test this...

零错误零警告。来测试一下……

As usual for today, the first order of business is to verify that it works in a nominal case. I just run the code free and press SW1 button: red LED and SW2 button: additional blue LED. So far, so good.

跟今天之前的做法一样，先验证正常情况。自由运行，按 SW1——红色 LED 亮；按 SW2——蓝色 LED 也亮。一切正常。

Now, let's look deeper. Reset the target to start over and set a breakpoint inside the critical section at the top of the "superloop." Run the code free and when it hits the breakpoint verify that PRIMASK is set, meaning interrupts are disabled.

接下来深入看看。复位目标板，在超级循环顶部的临界区里设个断点。自由运行，命中断点后确认 PRIMASK 已设置——中断是关着的。

Set a breakpoint in the GPIOF interrupt handler and at the WFI instruction in BSP_goToSleep().

在 GPIOF 中断处理程序和 BSP_goToSleep() 的 WFI 指令处各设一个断点。

Only now, press the SW1 button and run the code free.

现在按一下 SW1，让代码自由运行。

This time, the first breakpoint hit at the WFI instruction and, quite specifically, NOT in the interrupt handler because interrupts are still disabled. Move the breakpoint from WFI to the next instruction downstream.

这次，第一个命中的是 WFI 指令处的断点——注意，不是中断处理程序，因为中断还关着。把断点从 WFI 移到下一条指令。

When you run the code free, your new breakpoint is hit, and the interrupt is still not called because interrupts are ony now just about to be enabled.

继续自由运行，新断点命中了，但中断还是没被调用——因为中断此刻才刚要开启。

When you run the code free, you finally hit the breakpoint in the interrupt handler. Step through to verify that it sets the task-1 flag and watch where it returns.

再运行，终于命中中断处理程序的断点。单步执行，确认它设置了 task-1 标志位，然后看它返回到哪里。

Eventually, you end up at the top of your "superloop," with interrupts disabled. The isr_flags bitmask is not zero, meaning some of your tasks are ready to run. You skip going to sleep, find that the task-1 flag is set, clear it, and select BSP_deployAirbag() task function to execute.

最终回到超级循环顶部，中断关着。isr_flags 位掩码不为零——有任务就绪了。跳过睡眠，发现 task-1 标志位置位了，清掉它，选择 BSP_deployAirbag() 作为要执行的任务。

Finally, you enable interrupts and call the task function.

最后开中断，调用任务函数。

Alright, so this is the generally recommended "superloop" structure that incorporates low power sleep modes. It took a while to build, but, as the ST expert mentioned in his post, what you have just built is quite a powerful cooperative scheduler.

好，这就是融合了低功耗睡眠模式的通用超级循环结构。虽然花了不少时间构建，但正如那位 ST 专家所说，你刚才搭建的其实是一个相当强大的**协作式调度器**（cooperative scheduler）。

The task functions can be activated (by setting the corresponding bit in the global bitmask) not just from interrupts, but also from other tasks. Therefore, the name "isr_flags" is a bit of a misnomer. A better name would be "task_flags" or perhaps "ready_set" because this bitmask represents the set of all tasks that are ready to run. In fact, let me just refactor the code by globally replacing the name.

任务函数不仅可以从中断中激活（在全局位掩码中置位），也可以从其他任务中激活。所以 `isr_flags` 这个名字有点误导。叫 `task_flags` 或者 `ready_set` 更合适——因为它是所有就绪任务的集合。我来重构一下代码，全局替换这个名字。

Alright, so this is all regarding the general "superloop" structure. However, in the remaining few minutes of this lesson, I still need to address the Cortex-M-specific issue of disabling interrupts selectively with the BASEPRI register rather than indiscriminately with PRIMASK. BASEPRI is only available in ARMv7-M and higher architectures, such as M3 and higher, and is not available in Cortex-M0/M0+.

好，关于通用超级循环结构就讲到这。不过课程还剩几分钟，还有一个 Cortex-M 特有的问题要讲：用 BASEPRI 寄存器选择性地关中断，而不是用 PRIMASK 一刀切地全关。BASEPRI 只在 ARMv7-M 及以上架构中可用，也就是 M3 及以上，Cortex-M0/M0+ 没有。

Here, I must defer again to Joseph Yiu's "Definitive Guide," but basically, BASEPRI disables interrupts only up to the specified priority level and does not affect higher-priority interrupts, which run with the so-called "zero latency." Please note, however, that the high-priority interrupts are not allowed to access any resources used by your "superloop" or the lower-priority interrupts.

这里还是要参考 Joseph Yiu 的《权威指南》。简单说，BASEPRI 只禁用指定优先级及以下的中断，更高优先级的中断不受影响，能以所谓的**零延迟**（zero latency）运行。不过要注意，高优先级中断不能访问超级循环或低优先级中断所使用的任何资源。

So, let's apply the BASEPRI interrupt-disabling strategy to today's code. Fortunately, all necessary changes will be confined to the BSP, as it should be.

好，把 BASEPRI 中断禁用策略应用到今天的代码中。幸运的是，所有改动都局限在 BSP 里——本来就该这样。

First, you define the BASEPRI priority cutoff level. The level 0x3F should work for any ARMv7-M CPU with 3 or more bits of interrupt priority. At this point, it is also convenient to define the CMSIS priority cutoff, useful for setting the interrupt priorities with CMSIS functions.

首先，定义 BASEPRI 的优先级截止值。0x3F 适用于任何有 3 位或更多中断优先级位的 ARMv7-M CPU。顺便也定义一下 CMSIS 优先级截止值，之后用 CMSIS 函数设置中断优先级时会用到。

Now, you re-implement interrupt-disable by setting the BASEPRI register to the previously defined cutoff value. Interrupt-enable becomes now setting BASEPRI back to zero.

然后重新实现：关中断就是把 BASEPRI 设成刚才定义的截止值，开中断就是把 BASEPRI 设回零。

Now, most interestingly for today, the transition to sleep mode will need to combine the use of PRIMASK and BASEPRI registers to take advantage of the special properties of PRIMASK described by Joseph Yiu. Specifically, the goToSleep() function is now entered with BASEPRI set, but PRIMASK clear. So, before the WFI instruction, you must set PRIMASK and clear BASEPRI. After the WFI you clear PRIMASK, as before.

今天最有意思的部分来了：进入睡眠模式时需要同时用到 PRIMASK 和 BASEPRI 两个寄存器，来利用 Joseph Yiu 描述的 PRIMASK 的特殊属性。具体来说，goToSleep() 函数进入时 BASEPRI 已设置、PRIMASK 已清零。所以在 WFI 指令之前，要先设置 PRIMASK、清零 BASEPRI。WFI 之后，像之前一样清零 PRIMASK。

The last set of changes involves the interrupts because once you apply the BASEPRI critical section policy, it is crucial to explicitly set the priority of the interrupts that interact with your scheduler to the cutoff level or numerically higher. If you don't do this, the interrupts will not respect your critical sections, and you'll have race conditions. Also, now that your interrupts can have different priorities, they can preempt each other, so you need to protect the shared "task_set" with a critical section as well.

最后一组改动跟中断有关。一旦用了 BASEPRI 临界区策略，就必须把与调度器交互的中断的优先级显式设成截止值或更高。否则中断不会遵守你的临界区，竞态条件又会出现。而且现在不同中断有不同优先级，它们之间可以互相抢占，所以也要用临界区保护共享的 `task_set`。

And this concludes this lesson about using low-power sleep modes in the ubiquitous "superloop" architecture SAFELY. It turns out that adding sleep modes required creating a small cooperative scheduler, which will be useful in the next lesson.

好了，这就是如何在超级循环架构中**安全地**使用低功耗睡眠模式的全部内容。说起来，加了睡眠模式之后，我们不知不觉就搭出了一个小型协作式调度器——下一课正好用得上。

Finally, please note that the requirement for entering the sleep mode atomically applies only to the simple "superloop" and does not apply when you use a more advanced architecture, such as a preemptive kernel or a preemptive RTOS.

最后注意一点：原子地进入睡眠模式这个要求，只适用于简单的超级循环。如果你用的是更高级的架构，比如**抢占式内核**或抢占式 RTOS，就不需要这么做。

The main difference between a preemptive kernel and a "superloop" is that the kernel enters the low-power sleep mode from the lowest-priority idle thread. This idle thread is not committed to entering sleep mode because it gets immediately preempted by any threads that might become ready to run.

抢占式内核跟超级循环的关键区别在于：内核是从最低优先级的空闲线程进入睡眠的。空闲线程不会"铁了心要睡"，因为任何就绪的线程都能立刻抢占它。

If you like this channel and would like to see more lessons like that, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads. Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course." Thanks for watching!

如果你喜欢这个频道，想看更多类似课程，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/video-course 下载。所有项目也在 GitHub 上，仓库叫 "modern embedded programming course"。感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| superloop | 超级循环 | 前后台架构中的后台无限循环 |
| foreground/background architecture | 前后台架构 | 前台为中断，后台为主循环的软件架构 |
| low-power sleep mode | 低功耗睡眠模式 | 关闭CPU时钟以降低功耗的模式 |
| WFI (Wait-for-Interrupt) | 等待中断指令 | ARM Cortex-M 使CPU进入睡眠的指令 |
| WFE (Wait-for-Event) | 等待事件指令 | ARM Cortex-M 条件性睡眠指令 |
| race condition | 竞态条件 | 共享资源并发访问时的不确定行为 |
| critical section | 临界区 | 禁用中断以保护共享变量访问的代码段 |
| bitmask | 位掩码 | 用位来表示多个标志的数据结构 |
| ISR (Interrupt Service Routine) | 中断服务程序 | 响应中断请求的处理函数 |
| cooperative scheduler | 协作式调度器 | 任务自愿让出CPU控制权的调度方式 |
| preemptive kernel | 抢占式内核 | 可中断当前任务切换到更高优先级任务的内核 |
| dynamic dissipation | 动态功耗 | 由于电路开关切换产生的功耗 |
| static dissipation | 静态功耗 | 由于漏电流产生的功耗 |
| assertion | 断言 | 用于检测程序逻辑错误的运行时检查机制 |
| PRIMASK | PRIMASK 寄存器 | ARM Cortex-M 中用于全局禁用/启用中断的寄存器 |
| BASEPRI | BASEPRI 寄存器 | ARM Cortex-M 中用于选择性地禁用特定优先级以下中断的寄存器 |
| bare metal | 裸机 | 没有操作系统直接在硬件上运行的固件 |
| HAL (Hardware Abstraction Layer) | 硬件抽象层 | 屏蔽硬件细节的软件层 |
| zero latency | 零延迟 | 高优先级中断不受临界区影响的特性 |
| pointer to function | 函数指针 | 指向函数的指针，用于动态调用不同函数 |
| parasitic capacitance | 寄生电容 | 电路中固有的、非设计意图的电容 |
| bouncing | 抖动 | 机械开关在闭合/断开时的接触不稳定现象 |
