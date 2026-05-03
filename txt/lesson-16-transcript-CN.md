# 第16课：中断入门 / Lesson 16: Introduction to Interrupts

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll finally tackle the subject of interrupts. Today, you will learn what interrupts are, and how they work.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，这节课终于要讲**中断**（interrupts）了。今天你会学到什么是中断，以及它是怎么工作的。

As usual, let's get started with making a copy of the previous "lesson15" project and renaming it to "lesson16". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

跟之前一样，先把上节课的"lesson15"项目复制一份，重命名为"lesson16"。如果你是新加入的，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson16" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

进入新的"lesson16"目录，双击工作区文件，用 IAR 工具集打开。如果你还没有安装 IAR，回到"lesson0"去看看。

To quickly summarize what happened so far: in the couple of last lessons you were laying the groundwork for adding interrupts to your program. Today you are finally ready to actually start using interrupts to learn what they are and how they work.

快速回顾一下：前面几节课你一直在为程序加入中断功能做准备。今天终于可以真正开始用中断了，来看看它到底是什么、怎么运作。

Let's start today with cleaning up the code from all the little experiments you've performed, so that you get your blinky program back to its basic form.

今天先把之前实验加的那些代码清理掉，让 blinky 程序恢复到最基本的形式。

To remind you how the blinky program works, your main() function starts off with initializing the hardware. Next it lights up the blue LED.

回顾一下 blinky 程序的工作方式：`main()` 函数先初始化硬件，然后点亮蓝色 LED。

And finally it enters the endless while (1) loop.

最后进入无限的 `while(1)` 循环。

In this loop, your code turns the red LED on, and then calls the delay() function that busy-waits for half a million iterations, which happens to take about half a second. Next the program turns the red LED off, and again it busy-waits for half a million of iterations.

在这个循环里，代码先打开红色 LED，然后调用 `delay()` 函数进行**忙等待**（busy-wait），循环五十万次，大约耗时半秒。接着关掉红色 LED，再忙等待五十万次。

When I say that the program busy-waits, I mean that the CPU is doing nothing else, but constantly checking whether the iteration counter has dropped all the way to zero. In programming this is called **polling** and is an approach, in which the program keeps checking a for a certain condition to occur in order to do something in response.

所谓忙等待，就是 CPU 什么都不干，就死盯着迭代计数器，不停检查它有没有减到零。编程中这叫**轮询**（polling）——程序反复检查某个条件是否出现，然后做出响应。

There are many kinds of polling, some more clever than the others. But the busy-wait polling for longer periods of time, like the delay() function, is one of the most brain-dead ones, because it ties up the CPU completely and renders it unavailable for any other work.

轮询有很多种，有些比其他的聪明一些。但像 `delay()` 函数那样长时间的忙等待轮询，是最糟糕的做法之一——它把 CPU 完全绑死了，别的什么事都干不了。

This is like you would spend all night counting every clock tick so that you won't oversleep in the morning. I mean, most people would set up an alarm clock to go off at the right time. That way they would be able to do something else than constantly watching the clock.

这就像你整晚不睡觉，在那儿一个一个数时钟节拍，生怕早上睡过头。正常人都会设个闹钟嘛，到点就响。这样你就可以去做别的事，不用一直盯着表看。

It turns out that microprocessors also have a mechanism of setting up alarms, which are called interrupts. These interrupts are not just for timeouts, but for many other conditions, such as when a user presses a button, when data arrives through a communication interface, when analog-to-digital conversion completes, etc.

其实微处理器也有类似的"设闹钟"机制，叫做中断。中断不仅仅用于超时，还适用于很多其他场景——比如用户按下了按钮、通信接口收到了数据、**模数转换**（analog-to-digital conversion）完成了等等。

The name "interrupt" is actually quite suitable, because just like in real life, interrupt disrupts an ongoing activity and forces you to start doing something else in response to the interrupt.

"中断"这个名字很贴切。就像现实生活中一样，中断会打断你正在做的事，逼你去处理这个突发事件。

So, let's stretch the analogy between alarms in real life and interrupts in a processor a bit further and consider what's necessary for a person to use an alarm clock.

好，我们再把这个类比往前推一步——一个人要用闹钟，需要些什么条件。

Well first, you need a special clock with an alarm hardware to make noise at the right time.

首先，你得有个带闹钟功能的钟，能在对的时间响起来。

And you also need a person to be able to hear the alarm. We take it obviously for granted, but a person needs a special hardware (ears, auditory nerves, etc.) to "listen to" the alarms.

其次，人得能听到闹钟响才行。我们觉得这是理所当然的，但人其实也需要专门的"硬件"（耳朵、听觉神经等）来接收闹钟信号。

With this picture in mind, I hope you begin to see that a microprocessor too needs special hardware to handle interrupts. Software alone, although also necessary, is not enough to do the job.

有了这幅图景，我希望你开始意识到：微处理器同样需要专门的硬件来处理中断。光有软件是不够的——虽然软件也必不可少。

So, back your blinky program, you first need to find an appropriate alarm clock for your microcontroller. As it turns out TivaC MCU has many choices, one of them being the System Timer. You can find it in the TivaC Datasheet by searching for SysTick.

回到 blinky 程序——你首先要给微控制器找一个合适的"闹钟"。TivaC MCU 上有很多选择，其中之一就是**系统定时器**（System Timer）。在 TivaC 数据手册里搜 SysTick 就能找到。

The SysTick is a hardware peripheral meaning that it is a separate hardware block on the MCU silicon. It is clocked by the CPU clock and consists of three registers.

SysTick 是一个**硬件外设**（hardware peripheral），也就是说它是 MCU 芯片上一个独立的硬件模块。它由 CPU 时钟驱动，内部有三个寄存器。

The STCURRENT register, which in software will be called SysTick->VAL, is a simple, 24-bit down-counter that decrements by one at every CPU clock cycle.

STCURRENT 寄存器（软件里叫 `SysTick->VAL`）是一个简单的 24 位**递减计数器**（down-counter），每个 CPU 时钟周期减一。

When the counter reaches zero, it can generate an alarm (i.e., an interrupt) to the CPU.

当计数器减到零的时候，它就能向 CPU 发出一个"闹钟"——也就是中断。

At this point, the counter automatically reloads from the STRELOAD register, which in software will be called SysTick->LOAD, and starts decrementing again.

这时候，计数器会自动从 STRELOAD 寄存器（软件里叫 `SysTick->LOAD`）重新加载，然后继续递减。

By writing a different value into the SysTick->LOAD register, you can set up a different time between the interrupts.

往 `SysTick->LOAD` 寄存器写入不同的值，就能设置不同的中断间隔。

The second piece of the puzzle is your CPU, and specifically, how it "listens" to the interrupts coming in through the interrupt line.

第二个关键部分是你的 CPU——具体来说，它怎么"听"从**中断线**（interrupt line）传过来的中断信号。

Well, the CPU has a special built-in hardware that samples the status of the interrupt line after every instruction. As long as the interrupt line is low, the CPU fetches the next instruction in the pipeline.

CPU 内部有专门的硬件，每执行完一条指令就去采一次中断线的状态。只要中断线是低电平，CPU 就继续取**流水线**（pipeline）里的下一条指令。

However, when the interrupt line is high, the special CPU hardware forces the CPU to execute the Interrupt Entry instruction. This is called **PREEMPTION**.

但如果中断线变成了高电平，CPU 内部的特殊硬件就会强制 CPU 执行中断入口指令。这就叫**抢占**（preemption）。

Please note that while all the instructions are strictly synchronized to the CPU clock, the interrupt line is generally not.

注意，所有指令都严格跟 CPU 时钟同步，但中断线通常不是。

The interrupt line can change its status at any time and typically in the middle of an instruction, completely **ASYNCHRONOUSLY** to the instruction execution. That's why it is often said that interrupts are **ASYNCHRONOUS** to the executing program.

中断线可以在任何时候改变状态——通常还是在一条指令执行到一半的时候——跟指令执行完全**异步**（asynchronous）。所以人们常说中断相对于正在执行的程序是异步的。

Another interesting observation is that the CPU has a special Interrupt Entry instruction, which is often one of the longest in the instruction set. For example, the ARM Cortex-M Interrupt Entry takes at least 12 cycles, whereas other simpler instructions, such as MOV or ADD, can execute in just 1 clock cycle.

还有一个有意思的点：CPU 的中断入口指令通常是**指令集**（instruction set）中最长的指令之一。比如 ARM Cortex-M 的中断入口至少需要 12 个周期，而 MOV、ADD 这些简单指令只要 1 个时钟周期就能执行完。

With all this new information, you are almost ready to get back to the code and use the SysTick interrupt instead of the brain-dead polling.

了解了这些，你基本准备好回到代码里，用 SysTick 中断替换掉那个糟糕的忙等待了。

But before you set up the interrupt, let's modify the polling code so that you have only one delay in the loop. This one delay would then directly correspond to the interval between the SysTick interrupts, so the body of the loop, except the delay obviously, would be the exact code for the interrupt handler. This will become much clearer in a minute, but the point is to test this still with the old polling approach, before venturing into something new like using interrupts.

不过在设置中断之前，先改造一下轮询代码，让循环里只有一个延迟。这个延迟就对应 SysTick 中断之间的间隔，循环体（延迟除外）就是中断处理程序要执行的代码。等一下你就明白了——关键是在用中断这种新东西之前，先用旧的轮询方式验证逻辑是对的。

So, instead of relying on the sequence LED-on - delay -- LED-off - delay, you can observe that before each delay the state of the LED needs to toggle. If the LED was OFF, it needs to go ON and vice versa.

所以，与其用"LED 亮—延迟—LED 灭—延迟"这样的序列，不如换个思路：每次延迟之前，LED 的状态需要翻转。原来是灭的就要变亮，原来是亮的就要变灭。

It turns out that the C language has a nice coding idiom for toggling a bit, and that is the bitwise exclusive-OR operator. For example, to toggle the LED_RED bit, you use XOR-Equals operator, like this.

C 语言有一个很优雅的惯用法来翻转单个位——**按位异或**（bitwise exclusive-OR）运算符。比如要翻转 LED_RED 位，可以这样用异或赋值运算符：

```c
GPIOF->DATA_Bits[LED_RED] ^= LED_RED;
```

From the truth table of the exclusive-OR operator you can see that if the LED_RED bit was zero, it will become 1, and if it was 1 it will become zero.

看异或运算符的真值表就知道了：如果 LED_RED 位是 0，异或 1 之后变成 1；如果是 1，异或 1 之后变成 0。

Finally, let me also comment out the code for lighting up of the blue LED, so that the red LED will be the only one used.

最后，把点亮蓝色 LED 的代码也注释掉，只保留红色 LED。

When I press F7, the code compiles and builds error free.

按 F7，代码编译构建，没有错误。

The last logical thing to do is obviously to check if the code still runs.

接下来当然要验证代码还能正常运行。

As you can see, when I set a breakpoint at the exclusive-OR operator, the LED toggles every time I hit the breakpoint. When the program is run free, the LED blinks about once a second.

你看，在异或运算符那行设一个**断点**（breakpoint），每次命中断点 LED 就翻转一次。让程序自由运行，LED 大约每秒闪一次。

All right, so finally you are ready to configure the SysTick to generate interrupts every half a second, instead of using the brain-dead delay() function.

好，现在终于可以配置 SysTick，让它每半秒产生一次中断，把那个糟糕的 `delay()` 函数扔掉。

For this, you need to write the correct values into the three registers comprising the SysTick.

为此，需要往 SysTick 的三个寄存器写入正确的值。

As all other registers in your MCU, the SysTick registers are already mapped for you in the "tm4c_cmsis.h" header file. Specifically, the SysTick is specified the Cortex-Microcontroller Software Interface Standard (CMSIS) header file "core_cm4.h", which is included in the "tm4c_cmsis.h" header file.

跟 MCU 里的其他寄存器一样，SysTick 寄存器已经在 `tm4c_cmsis.h` 头文件中映射好了。具体来说，SysTick 的定义在 **CMSIS**（Cortex-Microcontroller Software Interface Standard，Cortex 微控制器软件接口标准）头文件 `core_cm4.h` 里，这个文件被 `tm4c_cmsis.h` 包含进来。

It's a little bit annoying that CMSIS uses different register names than the datasheet in this case, but with just three registers it's pretty easy to figure out how they match.

有点烦人的是，CMSIS 用的寄存器名跟数据手册不一样。不过只有三个寄存器，对应关系很容易搞清楚。

Actually, the only register that you really need to look up in the datasheet is the STCTRL register, where you configure the SysTick timer.

实际上，你真正需要查数据手册的只有 STCTRL 寄存器——这是配置 SysTick 定时器的地方。

In this register you would need to set bits 2, 1, and zero, for Clock-Source, Interrupt-Enable, and Counter enable, respectively.

在这个寄存器里，你需要设置第 2 位、第 1 位和第 0 位，分别对应**时钟源**（Clock Source）、**中断使能**（Interrupt Enable）和**计数器使能**（Counter Enable）。

The SysTick counter value register is simple. The datasheet says that it is a clear-on-write register, which means that it will be cleared no matter what you write to it, so let's write a zero.

SysTick 计数器值寄存器很简单。数据手册说它是一个**写即清零**（clear-on-write）寄存器——不管你写什么值进去，它都会被清零。所以我们就写个零进去。

The LOAD register is the most interesting one, because this is where you determine the interval between the interrupts.

LOAD 寄存器最有意思，因为中断间隔就是在这里设定的。

To set this interval to half a second, you need to know the speed of the CPU clock in terms of cycles per second.

要把间隔设成半秒，你得知道 CPU 时钟的频率——也就是每秒多少个周期。

As it turns out, the default speed of your TivaC is 16MHz out of the on-board crystal oscillator. If you have good eyesight, you can see it written on the crystal Y2.

你的 TivaC 默认时钟频率是 16MHz，来自板载的**晶振**（crystal oscillator）。如果你眼神好，可以在板子上的 Y2 晶振上看到标注。

By the way, you can make your Tiva MCU run much faster, by configuring the clock differently, but for now let's just leave it at 16MHz.

顺便说一下，通过不同的时钟配置可以让 Tiva MCU 跑得更快，但现在先保持 16MHz 不动。

The CPU clock frequency in Hertz is an important constant in your program, so let's define it at the top of the file. 16MHz is 16 million cycles per second.

CPU 时钟频率（赫兹）是程序里的一个重要常量，我们在文件顶部定义它。16MHz 就是每秒 1600 万个周期。

```c
#define CPU_CLOCK_HZ 16000000U
```

Finally you can set the SysTick LOAD register to half of the clock cycles per second minus 1. This minus one accounts for the fact that SysTick counts through zero, so if you didn't subtract one, you would count one clock too many.

最后，把 SysTick LOAD 寄存器设为每秒时钟周期数的一半减 1。为什么要减 1？因为 SysTick 计数时会经过零，不减 1 的话会多数一个时钟周期。

```c
SysTick->LOAD = (CPU_CLOCK_HZ / 2U) - 1U;
```

One word of caution here is that for such a long timeout of half a second you need to check that you don't overflow the dynamic range of the counter, which is only 24-bits. You should check it with a calculator. When you convert the value to hex, you can see that it just fits in three bytes (24-bits), so you are OK.

提醒一下：半秒的超时比较长，你得确认没有超出计数器的动态范围——它只有 24 位。用计算器验证一下，把这个值转成十六进制，可以看到刚好能放进三个字节（24 位），没问题。

At this point, you have the SysTick interrupt configured and enabled. It will interrupt the CPU every half a second.

到这里，SysTick 中断就配置好并启用了。它会每半秒中断一次 CPU。

This interrupt, in turn, will cause calling the SysTick interrupt handler that you have installed in the vector table in the last lesson.

这个中断会去调用你在上一课安装到**向量表**（vector table）里的 SysTick 中断处理程序。

In fact, you already have an empty body of this handler in your bsp.c module. Today, the big question is, what should you put inside?

事实上，`bsp.c` 模块里已经有了这个处理程序的空函数体。今天的关键问题是：里面该放什么？

Well, just like your polling loop, your interrupt handler needs to toggle the red LED. And that's all it needs to do, because the delay between the interrupts happens outside the CPU, handled autonomously by the SysTick peripheral.

跟轮询循环一样，中断处理程序只需要翻转红色 LED。只做这一件事就够了，因为中断之间的计时是在 CPU 外面完成的——由 SysTick 外设自主处理。

A slight problem at this point is that the code fails to compile, because the LED_RED bit is defined only in main.c and is not known in bsp.c.

这时候遇到一个小问题：编译不过，因为 `LED_RED` 只在 `main.c` 里定义了，`bsp.c` 看不到它。

The right way to fix it is to put all such board-specific definitions, like LED pin numbers and CPU clock frequency into the bsp.h header file.

正确的做法是把这类**板级特定定义**（board-specific definitions）——比如 LED 引脚号、CPU 时钟频率——都放到 `bsp.h` 头文件里。

I am going to adapt the delay.h file for this, because the busy-wait delay function becomes obsolete at this point.

我把 `delay.h` 改造成 `bsp.h`——反正忙等待延迟函数已经没用了。

After the edits I save the file as bsp.h...

编辑完之后，把文件保存为 `bsp.h`……

And I include bsp.h in main.c and in bsp.c.

然后在 `main.c` 和 `bsp.c` 里都 `#include "bsp.h"`。

At this point I can remove delay.c from the project.

这时候就可以从项目里移除 `delay.c` 了。

When I build now, I get an error that the delay() function is not available. This is fine, because I don't need it anymore, so I just delete it.

再次构建，报错说 `delay()` 函数找不到了。没关系，反正不再需要了，直接删掉。

But note that I can't delete the whole while(1) loop, even though it is no longer doing anything. This is because the CPU must spend its time somewhere between servicing the interrupts.

但注意，不能把整个 `while(1)` 循环都删了，即使它已经什么都不做。因为 CPU 在两次中断服务之间总得有个地方待着。

In the future, you can use this loop to do something useful, or to put the CPU to sleep, but for now just keep it empty.

将来你可以用这个循环做些有用的事，或者让 CPU 进入**休眠**（sleep）状态，但现在先让它空着。

The code is almost ready to test, but you need to add one more thing, which is enabling interrupts to the CPU.

代码差不多可以测试了，但还差最后一件事——让 CPU 开启中断。

In the previous discussion I showed you that the peripherals, like SysTick, connect directly to the CPU's interrupt line. This is a bit oversimplified, because there is a bit more happening in between.

前面我说过，SysTick 这样的外设直接连到 CPU 的中断线上。这话有点过于简化了，中间其实还有一些环节。

For starters, all CPUs have a way to block the interrupt line in software. ARM Cortex-M CPUs have a special bit called PRIMASK that must be cleared in software for interrupts to reach the CPU.

首先，所有 CPU 都有办法在软件层面屏蔽中断线。ARM Cortex-M 有一个叫 **PRIMASK** 的特殊位，必须在软件中把它清零，中断信号才能到达 CPU。

So, as the last touch in your code, you need to add a call to the IAR intrinsic function `__enable_interrupt()`. This function will clear the PRIMASK bit.

所以，代码最后再加一步——调用 IAR 的**内建函数**（intrinsic function）`__enable_interrupt()`。这个函数会清零 PRIMASK 位。

The code compiles and links cleanly, and I'm sure that you are hanging by the edge of your seat to see how the code performs on the LaunchPad board.

代码编译链接一切正常。我猜你已经迫不及待想看它在 LaunchPad 板子上的效果了。

As you can see the red LED blinks every second.

看，红色 LED 每秒闪烁一次。

When you break into the code, you find it spinning inside the empty while(1) loop.

暂停程序，你会发现它在空的 `while(1)` 循环里空转。

And when you set a breakpoint inside the SysTick_Handler, you can see that the LED gets toggled every time the breakpoint is hit.

在 `SysTick_Handler` 里设个断点，每次命中断点时 LED 就会翻转一次。

This concludes this very gentle introduction to interrupts. In the next lesson, I will step into the code and explain exactly the magic of preemption. I will also show you how interrupts work in the MSP430 processor, which will help you understand how ARM Cortex-M differs from all other processors.

这次对中断的入门介绍就到这里。下一课我会单步进入代码，详细解释抢占的神奇之处。还会给你展示中断在 MSP430 处理器上是怎么工作的，帮你理解 ARM Cortex-M 跟其他处理器有什么不同。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文 / English | 中文 / Chinese | 说明 / Notes |
|---|---|---|
| Interrupt | 中断 | 硬件或软件事件，打断 CPU 当前执行流程 |
| Polling | 轮询 | 程序反复检查某个条件是否发生 |
| Busy-wait | 忙等待 | CPU 空转等待，什么都干不了 |
| Preemption | 抢占 | 中断打断当前执行流，强制切换到中断处理程序 |
| Asynchronous | 异步 | 中断相对于程序执行是不同步的 |
| SysTick | 系统节拍定时器 | ARM Cortex-M 内置的 24 位递减计数器 |
| Down-counter | 递减计数器 | 从某个值递减到零的计数器 |
| Hardware Peripheral | 硬件外设 | MCU 芯片上独立的硬件模块 |
| Interrupt Line | 中断线 | 外设与 CPU 之间传递中断信号的物理连线 |
| Interrupt Handler | 中断处理程序 | 响应中断而执行的函数 |
| Vector Table | 向量表 | 存放中断处理程序入口地址的表 |
| Pipeline | 流水线 | CPU 中指令执行的流水线机制 |
| Breakpoint | 断点 | 调试时暂停程序执行的标记点 |
| Crystal Oscillator | 晶振 | 提供时钟信号的石英晶体振荡器 |
| CMSIS (Cortex-Microcontroller Software Interface Standard) | CMSIS，Cortex 微控制器软件接口标准 | ARM 提供的 Cortex-M 软件接口标准 |
| PRIMASK | PRIMASK，中断屏蔽位 | ARM Cortex-M 中用于屏蔽中断的特殊寄存器位 |
| Intrinsic Function | 内建函数 | 编译器提供的特殊函数，直接映射到 CPU 指令 |
| Clear-on-write | 写即清零 | 不管写入何值寄存器都被清零的特性 |
| Board-specific Definitions | 板级特定定义 | 与具体硬件开发板相关的宏定义和常量 |
| Instruction Set | 指令集 | CPU 支持的所有指令的集合 |
| Bitwise Exclusive-OR (XOR) | 按位异或 | 用于翻转单个位的运算符（^） |
