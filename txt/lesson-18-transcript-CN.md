# 第18课：ARM Cortex-M 中断处理 / Lesson 18: ARM Cortex-M Interrupt Handling

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll finally explain how ARM Cortex-M handles interrupts and why interrupt handlers can be regular C functions on this CPU. Specifically, you will see how the designers of the chip have solved the problem with saving all the right CPU registers and returning from interrupt functions.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这节课我终于要讲 ARM Cortex-M 是怎么处理中断的了，以及为什么在这种 CPU 上中断处理程序可以是普通的 C 函数。具体来说，你会看到芯片设计者是怎么解决保存正确的 CPU **寄存器**（registers）以及从中断函数返回这个问题的。

As usual, let's get started with making a copy of the previous "lesson17" project and renaming it to "lesson18". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

跟往常一样，先把之前的 "lesson17" 项目复制一份，改名为 "lesson18"。如果你是刚加入这个课程的，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson18" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

进入新的 "lesson18" 目录，双击工作区文件打开 **IAR 工具集**（IAR toolset）。如果你没有 IAR 工具集，回到第 0 课去安装。

To quickly summarize what happened so far: in the last lesson you saw how interrupts work on MSP430, which is simpler than ARM Cortex-M and handles interrupts in a way that is much more typical for embedded CPUs.

快速回顾一下之前的进展：上一课你看到了 MSP430 上中断是怎么工作的。MSP430 比 ARM Cortex-M 简单，它处理中断的方式在嵌入式 CPU 中更有代表性。

Based on MSP430, you learned that interrupts differ from regular functions in the two important ways:

基于 MSP430，你了解到中断跟普通函数有两个重要区别：

First, interrupts return with a different machine instruction than regular functions. Specifically, regular functions like LED_toggle return with the RET instruction on MSP430, while interrupts, like Timer0_Handler return with RETI instruction. The instructions must be different, because they pop different registers from the stack.

第一，中断用不同的机器指令来返回。具体来说，在 MSP430 上，普通函数比如 `LED_toggle` 用 **RET** 指令返回，而中断比如 `Timer0_Handler` 用 **RETI** 指令返回。这两条指令必须不同，因为它们从**栈**（stack）上弹出的寄存器不一样。

Second, interrupts must save more registers than regular functions. For example, Timer0_Handler saves registers R12-R15, while regular function Timer0_Function with the exact same body does not need to save any registers.

第二，中断必须保存比普通函数更多的寄存器。比如 `Timer0_Handler` 要保存 R12-R15，而函数体完全一样的普通函数 `Timer0_Function` 一个寄存器都不用保存。

So, the question now is, how ARM Cortex-M addresses these two requirements, so that it can indeed use regular functions as interrupt handlers.

那么问题来了：ARM Cortex-M 是怎么解决这两个需求的，从而真正做到用普通函数当中断处理程序？

As in the previous lesson, you will answer these questions experimentally. To do this, you need to trigger the SysTick interrupt on ARM Cortex-M from the debugger, so that you can precisely control when the interrupt occurs.

跟上一课一样，我们通过实验来回答这些问题。为此，你需要从调试器中触发 ARM Cortex-M 上的 **SysTick 中断**（SysTick interrupt），这样就能精确控制中断什么时候发生。

The method you used on MSP430, was to set the counter register of the timer in the debugger to the value one-less than the limit. The timer then reached the limit on the next clock cycle, which triggered the interrupt.

你在 MSP430 上用的方法是：在调试器里把定时器的计数器寄存器设为比上限值小 1，这样下一个时钟周期定时器就会到达上限，从而触发中断。

Unfortunately, you cannot use this method with the SysTick timer in ARM Cortex-M, because the STCURRENT register is write-clear, meaning that writing to it with any value clears the register without triggering an interrupt.

不幸的是，ARM Cortex-M 的 SysTick 定时器没法用这个方法，因为 **STCURRENT** 寄存器是写清除的——往里面写任何值都会直接清零，不会触发中断。

But not all hope is lost. As described in the TivaC datasheet, ARM Cortex-M offers another, even more direct way, which is to manually set the interrupt pending bit in the Interrupt Control and State register. Specifically, bit 26 in this register sets the SysTick interrupt to the pending state.

但也不是没办法。TivaC 数据手册里说了，ARM Cortex-M 还提供了另一种更直接的方式——手动设置**中断控制和状态寄存器**（ICSR, Interrupt Control and State Register）中的中断挂起位。具体来说，这个寄存器的第 26 位可以把 SysTick 中断设置为**挂起状态**（pending state）。

OK, so let's use this information to generate the SysTick interrupt at will.

好，那我们就利用这个方法来随心所欲地触发 SysTick 中断。

Load the code to the TivaC LaunchPad board and set a breakpoint at the top of the while(1) loop.

把代码加载到 TivaC LaunchPad 板上，在 while(1) 循环的顶部设一个**断点**（breakpoint）。

Run the code.

运行代码。

When the breakpoint is hit, move the breakpoint to the very next LDR.N instruction and also, set another breakpoint in your SysTick_Handler.

命中断点后，把断点移到紧挨着的下一条 LDR.N 指令处，同时在 `SysTick_Handler` 里也设一个断点。

Finally, in the Register panel, select the System Control Block and expand the ICSR section. Go to the PENDSTSET bit and set it to 1.

最后，在寄存器面板中选择 System Control Block，展开 ICSR 部分，找到 PENDSTSET 位，把它设为 1。

By the way, Cortex-M provides an interrupt pending bit for every interrupt source, so you can trigger every interrupt in the system by this method. Most of these pending bits reside inside the Nested Vectored Interrupt Controller (NVIC).

顺便说一句，Cortex-M 为每个中断源都提供了一个中断挂起位，所以你可以用这种方法触发系统中的每一个中断。这些挂起位大部分位于**嵌套向量中断控制器**（NVIC, Nested Vectored Interrupt Controller）内部。

But going back to your code, you've just set up the following experiment:

回到代码，你刚刚设置了这样一个实验：

You are stopped at the MOVS instruction. By writing to the PENDSTSET register, you arranged for the Interrupt Line to go high on the next clock cycle.

你现在停在 MOVS 指令处。通过写入 PENDSTSET 寄存器，你让**中断线**（interrupt line）在下一个时钟周期变高。

You have also placed two breakpoints at the two possible paths through your code:

你还在代码的两条可能路径上各放了一个断点：

One is at the very next LDR.N instruction. This breakpoint would be hit if the interrupt would not preempt after the MOVS instruction and the program would execute as usual.

一个在紧挨着的下一条 LDR.N 指令处。如果中断在 MOVS 指令之后没有**抢占**（preempt），程序正常执行的话，就会命中这个断点。

Your other breakpoint is inside the SysTick_Handler. This breakpoint would be hit only when the interrupt would fire right after the MOVS instruction thus preempting the normal program flow at this exact point.

另一个在 `SysTick_Handler` 内部。只有当中断在 MOVS 指令之后立即触发，在这个精确位置抢占正常程序流时，才会命中这个断点。

To experimentally settle this question, you cannot single step, because it disables checking for interrupts after each instruction. Instead, you need to let the program run free.

要通过实验验证这一点，你不能单步执行，因为单步执行会在每条指令之后禁用中断检查。你需要让程序自由运行。

And the answer is... that the SysTick interrupt has fired.

答案是……SysTick 中断确实触发了。

At this point you have a verified method to trigger your interrupt at a machine instruction of your choosing. You will use it in a minute to take a closer look at the interrupt stack frame and the interrupt return process, just like you did in the previous lesson for MSP430.

现在你有了一个经过验证的方法，可以在你选定的机器指令处触发中断。接下来你会用它来仔细查看**中断栈帧**（interrupt stack frame）和中断返回过程——就像上一课在 MSP430 上做的那样。

But before this, please go back to the project options and set the Floating Point Unit (FPU) to None. The FPU is a complex peripheral for speeding up floating-point computations, but unfortunately, it adds complications to the interrupt processing, which you don't want to deal with at this time.

不过在此之前，先回到项目选项，把**浮点运算单元**（FPU, Floating Point Unit）设为 None。FPU 是用来加速浮点计算的一个复杂**外设**（peripheral），但遗憾的是它会给中断处理增加复杂性，现在先不碰它。

All right, so after re-building your project without the FPU, you can finally take a closer look at the details of ARM Cortex-M interrupt handling.

好，不用 FPU 重新构建项目之后，终于可以仔细看看 ARM Cortex-M 中断处理的细节了。

Let's set the breakpoints and trigger the SysTick interrupt exactly as before.

像之前一样设置断点，触发 SysTick 中断。

But this time, let's also setup the memory view to watch the stack content. Remember that the stack grows down on ARM, so I scroll the memory view to place current SP at the bottom.

不过这次，我们再把内存视图也设置好，用来观察栈的内容。记住，ARM 上栈是向下增长的，所以我滚动内存视图把当前 SP 放在底部。

Now, when you run the program and hit the breakpoint inside the SysTick interrupt, you can see that the SP dropped to by 8 stack entries.

现在运行程序，在 SysTick 中断内部命中断点时，你可以看到 SP 下降了 8 个栈单元。

When you look into the datasheet of your TivaC MCU, in the section about "Exception Entry and Return" you can see the interrupt stack frame without FPU.

翻开 TivaC MCU 的数据手册，找到"**异常进入与返回**"（Exception Entry and Return）那一节，你可以看到不带 FPU 的中断栈帧。

Remembering that datasheets show memory from high to low, you need to turn the picture upside down to align it with the memory view in your debugger.

注意数据手册是从高地址到低地址显示内存的，所以你需要把图倒过来看，才能跟调试器里的内存视图对上。

When you do this, you can now identify which registers are saved on the stack.

这样做了之后，你就能识别出栈上保存的是哪些寄存器了。

For example, you can identify the saved PC, that is, the address to return to after the interrupt.

比如，你可以找到保存的 **PC**（程序计数器），也就是中断之后要返回的地址。

In fact, when you scroll up the disassembly window, you can see that the return address is the LDR.N instruction inside the while (1) loop.

事实上，在反汇编窗口里往上滚一滚，就能看到返回地址是 while(1) 循环里的那条 LDR.N 指令。

But, more importantly, let me mark for you all the registers saved in the interrupt stack frame, with the hope that you might recognize this particular group.

但更重要的是，让我把中断栈帧中保存的所有寄存器标出来，希望你能够认出这组寄存器。

Well, back in lesson 9, you learned about the ARM Application Procedure Call Standard AAPCS. AAPCS was a convention that specified, among others, which registers must be preserved by a function call. I mark these registers for you again, so that you can see that this group precisely complements the registers saved in the interrupt stack frame.

还记得第 9 课吧，你学了 **ARM 应用过程调用标准**（AAPCS, ARM Application Procedure Call Standard）。AAPCS 是一个约定，规定了（除其他内容外）哪些寄存器必须通过函数调用保留。我再把这些寄存器标出来，你会看到这组寄存器恰好跟中断栈帧中保存的寄存器**互补**。

So, here you have the answer to today's first issue: Cortex-M interrupt entry complements the ARM Procedure Call Standard, so that's why a regular C function can be used as an interrupt handler.

所以，今天第一个问题的答案就在这里：Cortex-M 的中断进入过程跟 ARM 过程调用标准互补，这就是为什么普通 C 函数可以用作中断处理程序。

Please note that this elevates the AAPCS from merely a calling convention that in principle could be different for each compiler, to a hard rule that must be implemented the same way by all compilers.

请注意，这让 AAPCS 从一个原则上每个编译器可以不一样的单纯**调用约定**（calling convention），升级成了所有编译器必须以相同方式实现的硬性规则。

OK, so now let's step through the interrupt function and take a look at how it returns.

好，现在让我们单步执行中断函数，看看它是怎么返回的。

Well, the function returns in a completely standard way via the BX LR instruction, because after all, this is just a regular C function.

函数用完全标准的方式返回——通过 **BX LR** 指令——因为说到底，这就是一个普通的 C 函数。

But wait a minute, the value in the LR register is 0xFFFFFFF9, which is negative 7 in two's complement. This is NOT a valid address in the code space. So what the hell is it?

但是等等，LR 寄存器里的值是 `0xFFFFFFF9`，也就是二进制补码的负 7。这**不是**代码空间中的有效地址。那这到底是什么鬼？

Well, this is an ARM-special. When this special value is loaded into the PC, the Cortex-M hardware treats this as a return from interrupt.

嗯，这是 ARM 的特殊机制。当这个特殊值被加载到 PC 时，Cortex-M 硬件就把它当作中断返回来处理。

That's why when you execute the BX LR instruction, you can see that the SP goes back to 0x3F8 and that the contents of registers is restored to the pre-interrupt state. The PC jumps back to your while(1) loop, just after your original breakpoint, which is exactly the point of preemption.

这就是为什么执行 BX LR 指令时，你会看到 SP 回到了 0x3F8，寄存器内容也恢复到了中断前的状态。PC 跳回了 while(1) 循环中原来断点的下一条指令——恰好就是被抢占的那个位置。

So, here you have the answer to today's second question. A standard return from a function works also as a special return from an interrupt, because the LR is loaded with a special value upon the interrupt entry.

所以，今天第二个问题的答案也出来了：标准的函数返回之所以也能当特殊的中断返回用，是因为 LR 在中断进入时被加载了一个特殊值。

Anther way of looking at this is, is that what other processors, such as MSP430, achieve by a special instruction (interrupt-return "iret"), ARM Cortex-M achieves by using special data--content of the LR register in this case.

换一种理解方式：其他处理器（比如 MSP430）通过特殊指令（中断返回指令 "iret"）实现的功能，ARM Cortex-M 通过特殊数据来实现——在这里就是 LR 寄存器的内容。

The ARM solution based on data is actually more flexible and extensible than a special instruction. In fact, ARM provides several variants of interrupt returns, which are all summarized in the Datasheet.

ARM 这种基于数据的方案实际上比特殊指令更灵活、更具可扩展性。事实上，ARM 提供了好几种中断返回的变体，数据手册里都有汇总。

I'm not going to discuss in detail all the options, which you can simply read about. But let me only quickly explain the terminology used in this table.

我不打算逐个讨论所有选项，你自己看就行。我只快速解释一下这个表里用到的术语。

Handler mode is the distinct processor state when it handles an exception, such as an interrupt or a fault. Thread mode is when it executes regular code, such as your while(1) loop inside your main function.

**处理器模式**（Handler mode）是处理器处理**异常**（exception，比如中断或故障）时的独特处理器状态。**线程模式**（Thread mode）则是处理器执行常规代码（比如 main 函数里的 while(1) 循环）时的状态。

Floating-point state means here that FPU is activated and that interrupts use the FPU stack frame as opposed to the regular stack frame. I'm going to show you the FPU stack frame in a couple of minutes.

浮点状态意味着 FPU 已激活，中断使用的是 FPU 栈帧而不是常规栈帧。几分钟后我会给你看 FPU 栈帧。

MSP stands for the Main Stack Pointer, while PSP stands for Process Stack Pointer. The datasheet makes this distinction, because your ARM CPU has actually two stack pointers, SP_main and SP_process, but only one of them is visible as SP, depending on the internal state of the CPU. This concept is called register banking and is another of the "ARM-specials". At this point I only mention banking of the SP register to explain the terminology, but the concept will be important when I'll talk about real-time operating system (RTOS), which I plan to do in one of the future lessons.

**MSP** 是**主栈指针**（Main Stack Pointer），**PSP** 是**进程栈指针**（Process Stack Pointer）。数据手册做这个区分，是因为你的 ARM CPU 实际上有两个栈指针——SP_main 和 SP_process——但根据 CPU 的内部状态，只有一个作为 SP 可见。这个概念叫做**寄存器分组**（register banking），是 ARM 的又一个特殊机制。这里我提到 SP 寄存器的分组只是为了解释术语，等到将来讲到**实时操作系统**（RTOS, Real-Time Operating System）时，这个概念才会真正变得重要。

But to finish with the basic interrupt stack frame, let me only explain the optional "aligner" word. The purpose of this optional stack entry is to align the interrupt stack frame at an address that is a multiple of 8 bytes.

关于基本中断栈帧最后一点，让我解释一下可选的"**对齐字**"（aligner word）。这个可选的栈项作用是把中断栈帧对齐到 8 字节倍数的地址上。

The reason the hardware needs SP to be aligned is to perform highly optimized, block transfers of registers to and from the stack. In fact, interrupt entry and exit take only 12 clock cycles each, which is very fast, when you consider that 8 registers are pushed or popped from the stack.

硬件需要 SP 对齐的原因是为了执行高度优化的寄存器与栈之间的**块传输**（block transfer）。事实上，中断进入和退出各只需 12 个时钟周期——考虑到要压栈或弹栈 8 个寄存器，这已经非常快了。

To show you when stack alignment will be necessary, let's run the program again, but intentionally misalign the SP in the debugger.

为了演示什么时候需要栈对齐，我们再运行一次程序，不过在调试器中故意把 SP 错位。

As before, when the breakpoint in your while(1) loop is hit, you trigger the SysTick interrupt.

跟之前一样，while(1) 循环中的断点命中后，触发 SysTick 中断。

You also setup the memory view to watch the stack in the same way as before.

内存视图也跟之前一样设置好，用来观察栈。

But this time, to better see what has changed on the stack, you additionally pre-fill the unused stack above the current value of SP with some easy to identify garbage, such as 0xDEADBEEF.

不过这次为了更清楚地看到栈上发生了什么变化，你额外把当前 SP 上方未使用的栈空间预填充一些容易辨认的垃圾数据，比如 `0xDEADBEEF`。

And finally, you misalign the stack by subtracting 4 bytes from the SP. I you wish, you can check that the value 0x3F4 is not divisible by 8.

最后，把 SP 减去 4 个字节来让栈错位。有兴趣的话，你可以验证一下 `0x3F4` 确实不能被 8 整除。

After you hit the breakpoint in the SysTick interrupt, you can see that the 8-register interrupt stack frame has been pushed on the stack,

在 SysTick 中断中命中断点后，你可以看到 8 个寄存器的中断栈帧已经被压入了栈中，

but, interestingly, one stack entry at address 0x3F0 has been skipped. This is the "aligner" word.

但有趣的是，地址 0x3F0 处的一个栈单元被跳过了。这就是"对齐字"。

Upon the interrupt return, the whole 9-word stack frame is removed, because the SP goes back to the original, mis-aligned value 0x3F4.

中断返回时，整个 9 个字的栈帧被移除，因为 SP 回到了原始的错位值 0x3F4。

Please note that in practice stack misalignment should never happen. This is because the eight byte stack alignment is a requirement of the AAPCS and compilers make sure that the stack is always aligned. Still, the stack alignment concept will be important when I'll talk about the real-time operating system (RTOS) in one of the future lessons.

请注意，实际中栈错位是不应该发生的。因为 8 字节栈对齐是 AAPCS 的要求，编译器会确保栈始终对齐。不过，等以后讲到 RTOS 的时候，栈对齐这个概念还是会很重要。

As a final subject of this lesson, let me show you the impact of the FPU on the interrupt stack frame.

作为本课最后一个话题，让我给你看看 FPU 对中断栈帧的影响。

To do this, please open the project options dialog box and re-enable the FPU.

为此，打开项目选项对话框，重新启用 FPU。

Re-build the project and setup the interrupt entry experiment exactly as before.

重新构建项目，像之前一样设置中断进入实验。

Note that right before the interrupt, the SP is 0x3F8.

注意中断之前 SP 是 0x3F8。

When the SysTick interrupt in entered this time, please note that the SP drops all the way to 0x390, which is 26 4-byte words. This is because now the CPU uses the stack frame with floating-point storage, which is more than 4 times bigger than the regular exception.

这次进入 SysTick 中断时，注意 SP 一直降到了 0x390，也就是 26 个 4 字节字。这是因为现在 CPU 使用带浮点存储的栈帧，比常规异常栈帧大了 4 倍多。

Also, please note that the LR is now set to 0xFFFFFFE9 instead of 0xFFFFFFF9, which is the special FPU-type interrupt return utilizing the much bigger FPU stack frame.

另外注意 LR 现在被设成了 `0xFFFFFFE9` 而不是 `0xFFFFFFF9`——这是特殊的 FPU 类型中断返回，利用了更大的 FPU 栈帧。

The moral from this is that you need to size the stack significantly bigger if you use the FPU. There is also an additional price to pay in longer interrupt entry and exit time.

这里的启示是：如果你用了 FPU，栈就要开得大得多。另外中断进入和退出的时间变长，也是要付出的额外代价。

This concludes this lesson about interrupt entry and exit on ARM Cortex-M. In the next lesson I will talk about race conditions, which is a concept that you absolutely need to understand to effectively work with interrupts.

以上就是 ARM Cortex-M 中断进入和退出的全部内容。下一课我会讲**竞态条件**（race conditions）——这是一个你必须理解才能有效使用中断的概念。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅以保持关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| registers | 寄存器 | CPU 内部的高速存储单元 |
| stack | 栈 | 后进先出的内存区域，用于保存临时数据 |
| interrupt stack frame | 中断栈帧 | 中断发生时硬件自动保存到栈上的寄存器集合 |
| preemption | 抢占 | 中断打断当前程序执行的过程 |
| breakpoint | 断点 | 调试时暂停程序执行的标记点 |
| pending state | 挂起状态 | 中断已请求但尚未被处理的状态 |
| NVIC (Nested Vectored Interrupt Controller) | 嵌套向量中断控制器 | Cortex-M 中管理中断优先级和嵌套的硬件模块 |
| ICSR (Interrupt Control and State Register) | 中断控制和状态寄存器 | 用于控制和查看中断状态的系统寄存器 |
| FPU (Floating Point Unit) | 浮点运算单元 | 用于加速浮点计算的硬件外设 |
| AAPCS (ARM Application Procedure Call Standard) | ARM 应用过程调用标准 | ARM 架构的函数调用约定，规定寄存器使用和栈对齐规则 |
| calling convention | 调用约定 | 编译器遵循的函数调用规则 |
| Handler mode | 处理器模式 | Cortex-M 处理异常（中断、故障）时的处理器状态 |
| Thread mode | 线程模式 | Cortex-M 执行常规代码时的处理器状态 |
| MSP (Main Stack Pointer) | 主栈指针 | Cortex-M 的主栈指针寄存器 |
| PSP (Process Stack Pointer) | 进程栈指针 | Cortex-M 的进程栈指针寄存器 |
| register banking | 寄存器分组 | 同一寄存器在不同处理器模式下映射到不同物理寄存器的机制 |
| aligner word | 对齐字 | 用于将栈帧对齐到 8 字节边界的可选填充字 |
| block transfer | 块传输 | 一次传输多个寄存器的优化操作 |
| exception | 异常 | 中断、故障等需要特殊处理的事件统称 |
| exception entry and return | 异常进入与返回 | 异常发生时保存上下文和返回时恢复上下文的过程 |
| race condition | 竞态条件 | 多个执行流访问共享资源时可能导致不确定结果的问题 |
| RTOS (Real-Time Operating System) | 实时操作系统 | 支持实时任务调度的操作系统 |
| IAR toolset | IAR 工具集 | IAR Systems 公司提供的嵌入式开发工具链 |
| write-clear | 写清除 | 写入任何值都会清除该寄存器的特性 |
