# 第17课：深入理解中断——MSP430处理器中断机制 / Lesson 17: Interrupts In-Depth — MSP430 Interrupt Mechanics

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll delve deeper into interrupts. Today you will see how interrupts work in the MSP430 processor, which will help you to understand how ARM Cortex-M differs from other processors. Specifically, will see exactly how an interrupt service routine is entered and how it returns.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这节课我们来深入聊聊**中断**（interrupt）。今天你会看到中断在 MSP430 处理器上是怎么工作的，这能帮你理解 ARM Cortex-M 跟其他处理器到底有什么不同。具体来说，我们会看到**中断服务程序**（ISR，Interrupt Service Routine）是怎么进入的、又是怎么返回的。

Today, I will start with the lesson17 project that I have prepared in advance instead of copying the previous lesson16.

今天我会直接从预先准备好的 lesson17 项目开始，而不是复制上一课的 lesson16 项目。

The reason is that I've used a different header file for the TivaC MCU, which is more compatible with the latest Cortex Microcontroller Software Interface Standard (CMSIS).

原因是我给 TivaC MCU 换了一个头文件，跟最新的 **Cortex 微控制器软件接口标准**（CMSIS）兼容性更好。

The lesson-17 project is available for download from the usual URL: state-machine.com/quickstart.

lesson-17 项目可以从老地方下载：state-machine.com/quickstart。

After downloading the project, get inside the "lesson17" directory and open the provided workspace in the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

下载好之后，进入 "lesson17" 目录，用 IAR 工具链打开里面提供的工作空间。如果你还没有 IAR 工具链，先回到 "lesson0" 去安装。

Other than the replacement of the header file, the project is identical to what you had by the end of the last lesson 16 or lesson 0x10, as I called it in the video.

除了头文件换了一下，项目内容跟你在上一课 lesson 16（我在视频里叫它 lesson 0x10）结束时是一模一样的。

To quickly summarize what happened so far: in the last lesson you have completely changed the structure of your blinky program to use the SysTick interrupt instead of the brain-dead busy-polling to wait between toggling the LED.

快速回顾一下之前的进展：上一课你彻底改了 blinky 程序的结构，用 SysTick 中断替代了那种笨拙的**忙等待轮询**（busy-polling）来在 LED 切换之间做延时。

You probably didn't appreciate it at the time, but the SysTick interrupt handler turned out to be a regular, completely ordinary C function, which you could call directly, not just through the vector table in the magic process of preemption.

你当时可能没注意到一个细节：SysTick 中断处理程序其实就是个普普通通的 C 函数，你可以直接调用它，不一定要通过**向量表**（vector table）在神奇的**抢占**（preemption）过程中才能调用。

In fact, let's start today with modifying your code to call SysTick directly from main().

实际上，今天我们就从修改代码开始——直接从 main() 里调用 SysTick。

Let's also put some code into the empty while(1) loop, because for studying interrupts it's more educational to have a piece of linear code for interrupts to preempt rather than just a single branch-to-self instruction.

另外，空的 while(1) 循环里我们也放点代码进去。学习中断的时候，有一段线性代码让中断去抢占，比只有一条"跳转到自身"指令要有意义得多。

So, let's turn the green LED on and then immediately off in the while loop. This will add a few instructions to the body of the loop and cause a visual effect of green LED glowing at about half of its maximum intensity, because it will blink too fast to be noticeable by the human eye.

我们在 while 循环里先把绿色 LED 打开，然后马上关掉。这样循环体就多了几条指令，绿色 LED 看起来就像是以大约一半亮度在发光——因为它闪烁得太快了，人眼根本分辨不出来。

The code compiles error free, so let's set a breakpoint at the function call and another one at the beginning of the SysTick_Handler.

代码编译没有错误。接下来我们在函数调用处设一个**断点**（breakpoint），再在 SysTick_Handler 开头设一个。

When you run this program, you can see that the call happens in a very standard way by means of the BL (branch-with-link instruction).

运行程序你会发现，调用是通过非常标准的方式发生的——用的是 **BL 指令**（branch-with-link，带链接的跳转）。

The SysTick handler called as a regular function also works correctly and toggles the red LED.

SysTick 处理程序作为普通函数调用也完全正常，正确地切换了红色 LED。

And finally, the function returns to the caller flawlessly by means of the standard BX-lr instruction.

最后，函数通过标准的 BX LR 指令完美地返回到调用者。

When you continue, the program hits the breakpoint at the beginning of SysTick, but this time, it is called through a completely different process of interrupt preemption.

继续运行，程序又在 SysTick 开头命中了断点——但这一次，它是通过完全不同的**中断抢占**过程被调用的。

And this is actually quite unusual. In fact, the ability to call interrupt handlers as regular C functions is a unique feature of the ARM Cortex-M processor, because no other processor allows interrupt handlers to be regular C functions.

这其实是非常不寻常的。能把中断处理程序当成普通 C 函数来调用，这是 ARM Cortex-M 处理器独有的特性——没有别的处理器允许你这么做。

In most other processors, the interrupt handlers require a special entry code and they return through a special return-from-interrupt instruction, so they can't be regular C functions. Also, interrupt handlers typically must save and restore more CPU registers than regular functions.

在大多数其他处理器上，中断处理程序需要特殊的入口代码，返回时也要用专门的**中断返回指令**（return-from-interrupt）。所以它们不可能是什么普通 C 函数。而且，中断处理程序通常需要保存和恢复比普通函数更多的 CPU **寄存器**（register）。

To understand why interrupt handlers must do this, you really need to see how they work on other processors than ARM Cortex-M.

想要理解为什么中断处理程序必须这么做，你真的得去看看 ARM Cortex-M 以外的处理器上中断是怎么工作的。

For that, I have here the MSP-EXP430G2 LaunchPad board right next to the TivaC LauchPad. I had already used that board back in lesson 11. The MSP430 LauchPad is quite similar to the Tiva LauchPad, except it has the MSP430 microcontroller instead of the ARM Cortex-M.

为此，我在 TivaC LaunchPad 旁边准备了 MSP-EXP430G2 LaunchPad 开发板。第 11 课的时候我已经用过这块板子了。MSP430 LaunchPad 跟 Tiva LaunchPad 长得很像，只不过上面装的是 MSP430 **微控制器**（MCU），而不是 ARM Cortex-M。

I have also prepared an interrupt-driven version of the blinky program for the MSP430 LauchPad, which is analogous to the blinky for TivaC.

我还为 MSP430 LaunchPad 准备了一个**中断驱动**（interrupt-driven）版本的 blinky 程序，跟 TivaC 上的 blinky 是对应的。

The programs are very similar and consist of initializing the pins for the LEDs, setting up the periodic timer interrupt, enabling interrupts, and the while(1) loop, in which the one of the LEDs is rapidly turned on and off.

两个程序非常相似：初始化 LED 引脚、设置**定时器中断**（timer interrupt）、使能中断，然后是一个 while(1) 循环——在循环里快速地开关其中一个 LED。

Just to make it clear, MSP430 is a different processor than ARM, so I cannot use the IAR toolset for ARM. Instead I am using IAR Embedded Workbench for MSP430. You can get it from IAR.com, just like you got EW for ARM, whereas IAR offers a free KickStart version of the MSP430 toolset as well.

需要说明的是，MSP430 跟 ARM 是完全不同的处理器，所以我不能用 ARM 版的 IAR 工具链。我用的是 IAR Embedded Workbench for MSP430。跟获取 ARM 版 EW 一样，你可以从 IAR.com 下载，IAR 也提供免费的 KickStart 版本。

Before you load and run blinky on MSP430, please make sure that the FET debugger on the MSP430 LaunchPad is configured not to use software breakpoints. This means that the debugger will use the hardware breakpoints built into the MCU. The MSP430 variant you are using has two such hardware breakpoints, which is perfect for what you need today.

在 MSP430 上加载运行 blinky 之前，请确保 MSP430 LaunchPad 上的 FET **调试器**（debugger）配置为不使用**软件断点**（software breakpoint）。也就是说，调试器会使用 MCU 内置的**硬件断点**（hardware breakpoint）。你用的这个 MSP430 型号有两个硬件断点，刚好够今天用。

When you run the program you can see that the red LED blinks once per second and the green LED glows.

运行程序，你会看到红色 LED 每秒闪一次，绿色 LED 持续发光。

When you break into the code, you can see it spinning in the while (1) loop, whereas single-stepping through the code causes the green LED to turn on and off.

暂停执行，你会看到程序在 while(1) 循环里转圈；而**单步执行**（single-stepping）的时候，绿色 LED 就跟着一开一关。

Most importantly, though, when you set a breakpoint inside the Timer0_Handler, which is the interrupt handler in blinky for MSP430, you can see that, first of all, the breakpoint is hit at all, meaning that the interrupt handler runs.

但最关键的是：当你在 Timer0_Handler（MSP430 blinky 的中断处理程序）里面设一个断点，你会发现——首先，断点确实被命中了，说明中断处理程序在运行。

And second, the LED toggles every time the handler runs, so the handler is doing its job.

其次，每次处理程序运行时 LED 都会切换，说明它在正常工作。

But wait a minute, the Timer0_Handler is apparently written in C, so what's the big deal here?

等一下，Timer0_Handler 明明是用 C 语言写的，这有什么大不了的？

Well, the big deal here is the __interrupt extended keyword in front of the Timer0_Handler. This keyword instructs the IAR compiler that this is no ordinary C function, but rather an interrupt handler, also called interrupt service routine (ISR).

关键在于 Timer0_Handler 前面的 `__interrupt` **扩展关键字**（extended keyword）。它告诉 IAR 编译器：这不是一个普通的 C 函数，而是一个中断处理程序，也就是中断服务程序（ISR）。

Also, there is the pragma-vector directive that automatically assigns the designated interrupt handler to the specific location in the MSP430 vector table. This is a much simpler mechanism than in ARM Cortex-M.

另外，还有 `pragma-vector` **编译指示**（directive），它会自动把指定的中断处理程序放到 MSP430 向量表中对应的位置。这个机制比 ARM Cortex-M 里的简单多了。

Let me make absolutely clear that both the __interrupt keyword and the pragma-vector directive go beyond the standard C and are specific to both the IAR toolset and the MSP430 processor.

我要特别强调：`__interrupt` 关键字和 `pragma-vector` 编译指示都不属于标准 C 的范畴，它们是 IAR 工具链和 MSP430 处理器特有的。

All this makes Timer0_Handler a NON-standard C function that you definitely cannot call directly from your program.

这些加在一起，Timer0_Handler 就成了一个非标准的 C 函数——你绝对不能在程序里直接调用它。

But you don't need to take my word for it. In a minute you will examine closer the Timer0_Handler code by stepping through it in disassembly.

不过你不用光听我说。稍后你会通过**反汇编**（disassembly）视图单步执行来仔细观察 Timer0_Handler 的代码。

But first, you need to find a way to trigger the interrupt at will from the debugger. This is actually not quite trivial, because you need to fake the expiration of the Timer0 in your MSP430 MCU, for which you need to understand how this timer works.

但首先，你需要找到一种办法能从调试器里随时触发中断。这其实不太简单，因为你需要在 MSP430 MCU 里模拟 Timer0 到期的效果，为此你得先了解这个定时器是怎么工作的。

So, here is the MSP430 Timer0 peripheral. It consists of three registers, with functions quite similar to that of SysTick in ARM Cortex-M, but the registers are only 16-bit wide.

这就是 MSP430 Timer0 **外设**（peripheral）。它由三个寄存器组成，功能跟 ARM Cortex-M 里的 SysTick 很像，只不过寄存器只有 16 位宽。

Timer0 can be configured to use different clock sources, but in the blinky program it is set up to use the Subsystem Clock (SMCLK) divided by 8, meaning that only every 8th Subsystem Clock cycle increments the TA0R register.

Timer0 可以配置不同的**时钟源**，但 blinky 程序里用的是**子系统时钟**（SMCLK，Subsystem Clock）再除以 8，也就是说每 8 个子系统时钟周期 TA0R 寄存器才加 1。

This large divisor is necessary to fit the half-second worth of clock ticks in just 16-bits. It turns out that half-a-second is an awfully long time for any MCU, even an MSP430 running at only at 1MHz.

这么大的**分频系数**是必须的，因为要把半秒的时钟**滴答**数塞进 16 位里。要知道，半秒对任何 MCU 来说都是相当长的时间，即使 MSP430 只跑在 1MHz。

I said that Timer0 increments, because unlike SysTick in ARM Cortex-M, Timer0 is an up-counter that increments until it reaches the value in the TACCR0 register, at which point it is reset to 0 and the Timer0 interrupt is generated.

我说 Timer0 是递增的，因为跟 ARM Cortex-M 的 SysTick 不同，Timer0 是一个**向上计数器**（up-counter）。它一直往上加，加到 TACCR0 寄存器的值就清零，同时产生 Timer0 中断。

This gives you a clue how to trigger the interrupt. You can write to the TA0R register a value just below the limit in TACCR0. The next clock cycle will cause these values to match, which will trigger the Timer0 interrupt.

这就给你一个触发的思路：往 TA0R 寄存器里写一个比 TACCR0 里的上限值小 1 的数。下一个时钟周期两者就匹配了，Timer0 中断就会触发。

So, let's just try this idea.

那我们来试试这个办法。

Load the program to the MSP430 LaunchPad and run it free.

把程序加载到 MSP430 LaunchPad 上，让它自由运行。

Break into the program. As expected, you find the program inside the while(1) loop.

暂停程序。不出所料，程序停在 while(1) 循环里。

Next, open the Timer0 registers and find TA0R. Click on it and enter a value of 0xF422, which is one less than the value in TA0CCR0.

接下来，打开 Timer0 寄存器，找到 TA0R。点击它，输入 0xF422——比 TA0CCR0 里的值小 1。

Finally, set two breakpoints. One at the next instruction BIC (for bit-clear) and the other at Timer0_Handler.

最后，设两个断点。一个在下一条 BIC（位清除）指令处，另一个在 Timer0_Handler 处。

At this point, you have set up the following experiment:

好了，到这一步你就搭好了下面这个实验：

You are stopped at the BIS instruction. By writing to the TA0R register, you arranged for the Interrupt Line to go high on the next clock cycle.

你现在停在 BIS（位置位）指令处。通过往 TA0R 写值，你已经安排好了：下一个时钟周期**中断线**（interrupt line）就会变高。

You have also placed two breakpoints at the two possible paths through the code:

你还在代码的两条可能路径上各放了一个断点：

One is the very next BIC instruction. This breakpoint would be hit if the interrupt would not preempt after the BIS instruction and the program would execute as usual.

一个是紧接着的 BIC 指令。如果 BIS 指令之后中断没有抢占，程序照常执行，那就会命中这个断点。

Your other breakpoint is inside the Timer0 interrupt handler. This breakpoint would be hit only when the interrupt would fire right after the BIS instruction thus preempting the normal program flow in this exact point.

另一个在 Timer0 中断处理程序里。只有中断在 BIS 指令之后立刻触发、在这个确切位置抢占正常程序流程时，才会命中这个断点。

So, which one do you think is it gona be?

你觉得会是哪个？

To experimentally settle this question, you cannot single step, because it disables checking for interrupts after each instruction. Instead, you need to let the program run free.

要用实验来回答这个问题，你不能单步执行——单步执行会在每条指令之后禁用中断检查。你需要让程序自由运行。

So, the answer is... that the interrupt has fired.

答案是……中断触发了。

But wait, there is more, because now, you can single step through the code.

等等，还有更多——因为现在你可以单步执行代码了。

The XOR instruction toggles the red LED.

XOR 指令切换红色 LED。

And the next instruction called RET-I is very special, because it causes return from the interrupt.

下一条叫 **RETI**（Return from Interrupt，从中断返回）的指令就很特别了——它的作用就是从中断返回。

As you can see the program returns to the BIC instruction, where you still have your first breakpoint.

可以看到，程序返回到了 BIC 指令处——你第一个断点还在那里。

So, congratulations. You have just created an interrupt preemption at will.

恭喜你！你刚刚成功地随意制造了一次中断抢占。

Maybe you don't quite appreciate it at this point, but a technique of triggering any interrupt you want, exactly at the instruction of your choosing is invaluable, similarly to the fault-injection technique that I showed you a couple of lessons ago.

你现在可能还没充分意识到，但能够在任意一条指令处精确触发任意中断——这个技巧是无价的。就像几课之前我演示过的**故障注入**（fault injection）技术一样。

Such techniques will help you track down the most elusive, intermittent, and difficult problems in embedded systems programming, because instead of waiting forever for some rare event, you can make it happen at will, any number of times.

这种技巧能帮你追踪嵌入式编程中最难找、**间歇性出现**（intermittent）的棘手问题。因为你不用傻等某个罕见事件发生——你可以随时让它出现，想重现多少次就重现多少次。

For example, you can now answer the big question: How does the interrupt know where to return to?

比如，你现在就能回答一个大问题：中断怎么知道该返回到哪里？

So, let's reset the target and setup the experiment again...

好，我们重置目标板，再来做一次实验……

But this time, let's watch the CPU registers, and specifically the SP (stack pointer).

但这次我们要观察 CPU 寄存器，特别是 **SP**（栈指针，Stack Pointer）。

Let's also setup the memory view to the see the contents of the stack.

再打开内存视图，看看**栈**（stack）里的内容。

Because MSP430 is a 16-bit CPU, it is best to watch the stack in 2-byte chunks. Unfortunately, I can't make the window narrow enough to show you only one column of stack entries, but I highlight the current top of stack, that is the position of the SP.

MSP430 是 16 位 CPU，所以最好以 2 字节为单位来查看栈。可惜窗口没法缩到只显示一列，不过我高亮了当前的**栈顶**（top of stack），也就是 SP 指向的位置。

Now, when I run the program and hit the breakpoint inside the interrupt, you can see that the SP dropped from 0x3FE to 0x3FA, which is a difference of 4 bytes, that is 2 stack entries.

现在运行程序，在中断内部命中断点后，你会看到 SP 从 0x3FE 降到了 0x3FA——差了 4 个字节，也就是 2 个栈条目。

When you look into the datasheet of the MSP430 MCU, in the section about Interrupt Processing you can see that interrupt entry pushes the PC and the SR (status register) to the stack, so the SP drops by 4 bytes.

查 MSP430 MCU 的数据手册，在**中断处理**那部分你会看到：进入中断时会把 PC（程序计数器）和 SR（状态寄存器，Status Register）压栈，所以 SP 下降 4 个字节。

With this information, you can now identify that 0x000d is the saved value of the SR and 0xC038 is the saved PC, that is, the return address.

有了这个信息，你就能认出来了：0x000d 是保存的 SR 值，0xC038 是保存的 PC——也就是**返回地址**（return address）。

In fact, you can actually see that address in the disassembly window, which happens to be the BIC instruction inside the while (1) loop.

事实上你确实能在反汇编窗口里看到那个地址，它恰好就是 while(1) 循环里的 BIC 指令。

Interestingly, you can also see that, after being saved, the SR register is cleared upon the entry to the interrupt. Among others, this clears the Global Interrupt Enable bit (GIE), which disables further interrupts to the CPU.

有意思的是，你还会发现 SR 寄存器保存之后在进入中断时被清零了。这会清除**全局中断使能位**（GIE，Global Interrupt Enable），也就是说 CPU 不会再响应新的中断了。

The RETI instruction, causes the exact opposite to the interrupt entry instruction by restoring the SR and PC registers.

RETI 指令做的事情跟中断入口正好相反——恢复 SR 和 PC 寄存器。

So that's how the code returns back to exactly the preemption point. Also the GIE bit is restored, so the interrupts can be serviced again.

这就是程序精确返回到**抢占点**的原理。同时 GIE 位也恢复了，中断就又能被响应了。

The return from an interrupt service routine (ISR) through the RETI instruction is interesting, but an ISR can differ from a regular C function in one more important way.

通过 RETI 指令从中断服务程序返回确实很有意思，但 ISR 跟普通 C 函数还有另一个重要的区别。

And that is, an ISR must save more CPU registers than a regular function.

那就是，ISR 必须比普通函数保存更多的 CPU 寄存器。

To see this, you need to modify your Timer0_Handler ISR to use more CPU registers, for instance by calling a regular C function.

要看清这一点，你需要修改 Timer0_Handler，让它使用更多的 CPU 寄存器——比如在里面调用一个普通 C 函数。

So, here I copy the current body of the Timer0_Handler and make it into a regular C function LED_toggle().

我把 Timer0_Handler 的函数体复制出来，做成一个普通的 C 函数 `LED_toggle()`。

I then call this function from Timer0_Handler, instead of doing the toggling directly.

然后在 Timer0_Handler 里调用这个函数，不再直接做切换操作。

Next, I make another copy of the ISR and make it into a regular function Timer0_Function() to have a control sample for comparison with the original ISR.

接着，我又复制了一份 ISR，改成普通函数 `Timer0_Function()`，作为跟原始 ISR 对比的**对照组**。

To prevent the smart IAR linker from eliminating this control function, I need to actually call it somewhere, so I call it from main().

为了防止 IAR **链接器**（linker）把这个对照函数优化掉，我得在某个地方实际调用它，所以我在 main() 里调用了一下。

Finally, I need to provide the prototypes of all new functions, which I put in the bsp.h header file.

最后，还要把所有新函数的声明加到 bsp.h 头文件里。

When you load this new code and set breakpoints in Timer0_Handler and Timer0_Function,

加载这段新代码，在 Timer0_Handler 和 Timer0_Function 里各设一个断点，

you can see that Timer0_Function() consists of just one instruction: branch to LED_toggle().

你会看到 Timer0_Function() 只有一条指令：跳转到 LED_toggle()。

In contrast, the Timer0_Handler contains much more code. It starts with pushing registers R13/12/15 and R14 on the stack, then it calls LED_toggle via the CALL instruction, and then it pops the registers in the exact reverse order. Finally, the ISR returns via the RETI instruction.

相比之下，Timer0_Handler 的代码就多得多了。它先把 R13、R12、R15 和 R14 这些寄存器压栈，然后通过 CALL 指令调用 LED_toggle，之后再按相反顺序出栈。最后通过 RETI 指令返回。

So, as you can see, the compiler generated very different code for a C function and ISR that have otherwise identical bodies.

你看，明明函数体一模一样，编译器为普通 C 函数和 ISR 生成的代码却完全不同。

I hope you start sensing why the ISR more to do. A function call from within an ISR can apparently clobber registers R12 through R15, so they have to be preserved. Otherwise the interrupt preemption would have a side effect of clobbering registers.

希望你开始理解为什么 ISR 要做更多工作了。ISR 内部的函数调用可能会**破坏**（clobber）R12 到 R15 这些寄存器，所以必须提前保存。不然的话，中断抢占就会有破坏寄存器的副作用。

Please remember that an interrupt can preempt asynchronously any two instructions, so the compiler cannot tolerate clobbering registers.

别忘了，中断可以在任意两条指令之间**异步地**（asynchronously）抢占，所以编译器绝对不能容忍寄存器被破坏。

In contrast, a regular function call is synchronous, because the compiler is doing it via the CALL instruction or sometimes the BR instruction. In any case, the compiler is prepared that certain CPU registers will be potentially clobbered at this particular point in the code.

相比之下，普通函数调用是**同步的**（synchronous）——编译器知道是通过 CALL 指令或 BR 指令来调用的。不管哪种情况，编译器都已经做好了准备，知道在这个位置某些寄存器可能会被覆盖。

This concludes this closer look at interrupt handling in MSP430, which is much more typical than in ARM Cortex-M. In the next lesson, I will go back to ARM and take a similar closer look at how it handles interrupts.

以上就是 MSP430 中断处理的近距离观察，这种做法比 ARM Cortex-M 更具代表性。下一课我会回到 ARM，用同样的方式仔细看看 ARM 是怎么处理中断的。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads. There will be two projects for this lesson17, one for the ARM and the other for MSP430.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。本课 lesson17 会提供两个项目，一个给 ARM 用，一个给 MSP430 用。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Interrupt | 中断 | 处理器对外部或内部事件的异步响应机制 |
| Interrupt Service Routine (ISR) | 中断服务程序 | 响应中断而执行的处理函数 |
| Preemption | 抢占 | 中断暂停当前执行的代码，转而执行中断处理程序 |
| Vector Table | 向量表 | 存放中断处理程序入口地址的数据结构 |
| CMSIS (Cortex Microcontroller Software Interface Standard) | Cortex 微控制器软件接口标准 | ARM 定义的 Cortex-M 系列软件接口标准 |
| Busy-Polling | 忙等待轮询 | 通过循环检查条件来等待，浪费 CPU 资源 |
| Stack Pointer (SP) | 栈指针 | 指向当前栈顶的 CPU 寄存器 |
| Program Counter (PC) | 程序计数器 | 存放下一条待执行指令地址的寄存器 |
| Status Register (SR) | 状态寄存器 | 存储 CPU 状态标志的寄存器 |
| Global Interrupt Enable (GIE) | 全局中断使能位 | 控制是否允许 CPU 响应中断的状态位 |
| Up-Counter | 向上计数器 | 从 0 开始递增直到达到上限值的计数器 |
| Breakpoint | 断点 | 调试时程序暂停执行的位置 |
| Hardware Breakpoint | 硬件断点 | 由 MCU 内部硬件支持的断点 |
| Software Breakpoint | 软件断点 | 通过替换指令实现的断点 |
| Disassembly | 反汇编 | 将机器码转换为汇编指令的视图 |
| Linker | 链接器 | 将目标文件链接为可执行程序的工具 |
| Peripheral | 外设 | MCU 内部的功能模块，如定时器、GPIO 等 |
| Return Address | 返回地址 | 函数或中断返回时恢复执行的指令地址 |
| Single-Stepping | 单步执行 | 调试时逐条指令执行的方式 |
| Extended Keyword | 扩展关键字 | 编译器在标准 C 基础上增加的关键字 |
| Directive | 编译指示 | 编译器预处理阶段的指令，如 pragma |
| Fault Injection | 故障注入 | 故意引入错误以测试系统鲁棒性的技术 |
| Clobber | 破坏（寄存器） | 函数调用过程中寄存器值被覆盖 |
| Microcontroller (MCU) | 微控制器 | 集成了处理器、存储器和外设的单芯片 |
| Debugger | 调试器 | 用于调试嵌入式系统的工具 |
| Asynchronous | 异步 | 事件的发生不受当前程序流程控制 |
| Synchronous | 同步 | 事件的发生由当前程序流程决定 |
| Subsystem Clock (SMCLK) | 子系统时钟 | MSP430 的子系统主时钟 |
| Divisor | 分频系数 | 时钟频率的分频因子 |
