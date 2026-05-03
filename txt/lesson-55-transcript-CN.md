# 第55课：抢占式 QK 内核 / Lesson 55: Preemptive QK Kernel

Hello and welcome to the Modern Embedded Systems Programming course. I'm Miro Samek, and in this lesson, I will demonstrate and explain the beautifully efficient, preemptive, real-time kernel called QK, which is particularly suitable for Active Objects and is available as one of the built-in kernels in the QP/C Active Object framework. Also, today, as last time, I will present QK and QP/C on the STM32 NUCLEO board using the popular STM32Cube development environment.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。今天这节课，我要给你演示并讲解一个精巧高效的抢占式实时内核——**QK**。它特别适合**活动对象**（Active Objects）使用，是 QP/C 活动对象框架中内置的内核之一。跟上次一样，今天我会在 STM32 NUCLEO 开发板上，用大家熟悉的 STM32Cube 开发环境来展示 QK 和 QP/C。

---

The preemptive QK kernel presented in this lesson is an example of a fundamentally different class of preemptive kernels from conventional real-time operating systems (RTOS), such as FreeRTOS. This video course features a segment of 7 lessons that explain the traditional RTOS, and I highly recommend re-watching some of these lessons, especially lesson #25 about blocking, to gain a better understanding and appreciation for QK.

本课介绍的 QK 抢占式内核，跟我们常见的**实时操作系统**（RTOS），比如 FreeRTOS，属于完全不同的类别。本课程有一个 7 节课的专题专门讲传统 RTOS，我强烈建议你回去重温一下，特别是第 25 课关于**阻塞**（blocking）的内容，这样才能更好地理解和欣赏 QK。

---

However, before I delve into the details of QK, let me make it absolutely clear that preemptive multitasking introduces an entirely new dimension of complexity to the application, to say the least. It's simply much easier to understand, analyze, and troubleshoot a program in which tasks cannot preempt each other at every machine instruction.

不过，在深入 QK 细节之前，我必须先把话说清楚：抢占式多任务给程序带来的是一个全新维度的复杂度。说白了，如果任务之间不会在每条机器指令上互相抢占，那理解、分析和调试起来都要容易得多。

---

So, when you choose a preemptive kernel, such as QK or any other preemptive RTOS, for that matter, I want you to do it for good reasons.

所以，当你选择 QK 或其他任何抢占式内核的时候，我希望你是经过深思熟虑的。

---

Let me begin with the wrong reasons for choosing a preemptive kernel. First, with Active Objects, you don't need a preemptive kernel for partitioning the problem, which is by far the most common rationale for choosing an RTOS in practice.

先说说选择抢占式内核的**错误理由**。第一，用活动对象的时候，你不需要靠抢占式内核来划分问题——而这恰恰是实践中选 RTOS 最常见的理由。

---

For example, here is the logic analyzer trace from the last lesson, in which the non-preemptive QV kernel executed five tasks: from the idle task to the periodic4 task. A simple kernel based on a "superloop" could execute multiple tasks (up to 64 maximum in the case of QV) because the tasks were simply function calls (with an Active Object passed as a pointer parameter) that processed events in a run-to-completion fashion without *blocking* and returned to the "superloop" after each event. This notion of one-shot, run-to-completion, non-blocking tasks will also apply to the QK kernel, so it breaks with the traditional RTOS tasks, which, as you recall, are structured as continuous, endless "mini-superloops."

比如这是上一课的逻辑分析仪截图，非抢占式 QV 内核执行了五个任务，从空闲任务到 periodic4 任务。一个基于"**超级循环**"（superloop）的简单内核就能执行多个任务（QV 最多支持 64 个），因为每个任务本质上就是一个函数调用——把活动对象指针作为参数传进去，以**运行到完成**（run-to-completion）的方式处理事件，不阻塞，处理完一个事件就回到超级循环。这种一次性、运行到完成、非阻塞的任务模型同样适用于 QK。所以它跟传统 RTOS 的任务有本质区别——你可能还记得，传统 RTOS 的任务是那种持续不断运行的"迷你超级循环"。

---

Second, you don't need a preemptive kernel for low-power designs. As demonstrated in lessons #52 through #54, the non-preemptive QV kernel supports a centralized and safe use of low-power sleep modes on your MCU.

第二，做**低功耗设计**也不需要抢占式内核。第 52 到 54 课已经演示过了，非抢占式 QV 内核就能在 MCU 上集中、安全地使用低功耗睡眠模式。

---

Third, you don't need a preemptive kernel to implement efficient blocking, which is so fundamental in the traditional RTOS, because event-driven Active Objects generally don't block for events. Any waiting for events occurs outside the Active Objects and may involve a sleep mode of the CPU.

第三，你不需要抢占式内核来实现高效阻塞——阻塞可是传统 RTOS 最根本的特性。但事件驱动的活动对象通常不会为等待事件而阻塞。对事件的等待都发生在活动对象之外，可能涉及 CPU 的睡眠模式。

---

And finally, since event-driven Active Objects don't poll or block, their run-to-completion steps tend to be naturally quite short. Therefore, it is likely that you can achieve an adequate task-level response with a simple non-preemptive kernel, such as QV.

最后一点，事件驱动的活动对象既不轮询也不阻塞，所以它们的运行到完成步骤天生就比较短。因此，用 QV 这种简单的非抢占式内核，很可能就已经能获得足够好的任务级响应时间了。

---

However, even if you have some CPU-bound tasks, you can improve the task-level response and thus reduce the length of priority inversion by splitting long run-to-completion steps into shorter pieces, which are sometimes referred to as "multi-stage tasks."

不过，即使你有**CPU 密集型任务**（CPU-bound tasks），也可以通过把较长的运行到完成步骤拆成更短的片段来改善任务级响应时间，从而缩短**优先级反转**（priority inversion）的时间。这种拆出来的片段有时叫做"**多阶段任务**"（multi-stage tasks）。

---

For example, the work in the sporadic-3 task is performed in a loop, which can quite easily be split into run-to-completion stages, each with fewer iterations. After executing each stage, the sporadic-3 task must post a "reminder" event to itself, so that the task will run again to perform the next stage.

比如 sporadic-3 任务的工作是在循环中做的，很容易拆成多个运行到完成阶段，每个阶段少迭代几次。每执行完一个阶段，sporadic-3 任务要给自己发一个"提醒"事件，这样它就会再次运行来处理下一个阶段。

---

The logic analyzer trace shows an example of converting the original sporadic2 and sporadic3 tasks into multi-stage tasks. This example is actually provided in the QP/C framework, in the directory `qpc\examples\arm-cm\real-time_nucleo-c031c6\qv-ms`. Please also refer to the "Reminder" design pattern. The video description provides the links.

逻辑分析仪截图展示了把原始的 sporadic2 和 sporadic3 任务转换成多阶段任务的例子。这个例子已经包含在 QP/C 框架里了，路径是 `qpc\examples\arm-cm\real-time_nucleo-c031c6\qv-ms`。也推荐你看看"Reminder"设计模式，视频描述里有相关链接。

---

Such multi-stage tasks can be a good strategy for achieving an adequate real-time response in the simple, non-preemptive kernel. However, this requires manual splitting tasks into RTC stages and self-posting the "reminder" events, and incurs additional multiple scheduling overheads. At some point, such complications and overheads may become overwhelming and unworkable.

在简单的非抢占式内核里，多阶段任务确实是获得足够实时响应的好策略。但问题是，你得手动拆分任务、自己发提醒事件，而且还会增加多次调度开销。搞到一定程度，这些麻烦和开销可能让你觉得根本搞不下去了。

---

If this is your situation, a preemptive kernel can actually be a safer and more effective tool. For example, this is how the preemptive QK kernel will execute the exact same set of tasks as QV did.

如果你确实遇到了这种情况，抢占式内核反而可能是更安全、更有效的选择。比如，下面是抢占式 QK 内核执行跟 QV 完全相同的一组任务的情况。

---

As you can see, the QK kernel no longer shows any priority inversions. This is precisely the preemptive, priority-based scheduling required by the Rate Monotonic Scheduling/Analysis method that you've learned in lesson #22, and the QK kernel is fully compatible with it.

可以看到，QK 内核不再出现任何优先级反转。这正是你在第 22 课学过的**速率单调调度/分析**（Rate Monotonic Scheduling/Analysis）所要求的基于优先级的抢占式调度，QK 内核与之完全兼容。

---

Now, let's see how the QK kernel works and how it differs from the conventional RTOS you've learned in lessons #22 through #28.

好，现在我们来看看 QK 内核是怎么工作的，以及它跟你在第 22 到 28 课中学的传统 RTOS 有什么不同。

---

For compatibility with Rate-Monotonic Scheduling, QK must ensure that the CPU always runs the highest-priority task that is ready to run. Luckily, there are only three scenarios in which a task can become ready to run.

为了兼容速率单调调度，QK 必须保证 CPU 始终运行就绪的最高优先级任务。好消息是，任务变为就绪状态只有三种情况。

---

First, a low-priority task can make a higher-priority task ready to run. For example, the sporadic2 task posts an event to the sporadic3 task, which in turn posts an event to the still higher-priority periodic4 task.

第一，低优先级任务可以让更高优先级的任务就绪。比如 sporadic2 任务给 sporadic3 任务发事件，后者又给优先级更高的 periodic4 任务发事件。

---

At every such occasion, the QK kernel must immediately suspend the lower-priority task and switch to the higher-priority task. You can see that the sporadic2 line indeed remains high, indicating that the task wasn't completed. Same for the sporadic3 line until periodic4 runs and completes. This type of preemption is called "**synchronous preemption**" because it occurs synchronously with the posting of an event, which is readily visible in your code.

每当发生这种情况，QK 内核必须立即挂起低优先级任务，切换到高优先级任务。你可以看到 sporadic2 那条信号线确实一直保持高电平，说明这个任务还没完成。sporadic3 也是一样，直到 periodic4 运行完才结束。这种抢占叫做"**同步抢占**"（synchronous preemption），因为它跟发送事件同步发生，在你的代码里是看得见的。

---

The second scenario, in which a task can become ready to run, occurs through an interrupt. For example, here the SysTick ISR preempts the sporadic2 task and posts an event to the high-priority periodic4 task, thus making it ready to run. As soon as the ISR completes, the QK kernel must switch to the periodic4 task and specifically not return to the original sporadic2 task. This type of preemption is called "**asynchronous preemption**" because it can occur at any point where interrupts are not explicitly disabled, and it is not visible in the code.

第二种让任务就绪的情况是通过**中断**。比如这里 SysTick 中断服务程序（ISR）抢占了 sporadic2 任务，给高优先级的 periodic4 任务发了事件，让它就绪。ISR 一结束，QK 内核就必须切换到 periodic4 任务，而不能回到原来的 sporadic2 任务。这种抢占叫做"**异步抢占**"（asynchronous preemption），因为只要没显式关中断，它在任何地方都可能发生，而且从代码里是看不出来的。

---

The third and final scenario that can lead to task preemption is when a task blocks and voluntarily stops being ready to run. This cannot happen with Active Objects; therefore, you won't see it in this logic analyzer trace. However, it occurs frequently in a traditional RTOS, so let's include it in this discussion.

第三种也是最后一种可能导致抢占的情况，是任务**阻塞**了，主动放弃就绪状态。活动对象不会出现这种情况，所以你在逻辑分析仪截图上不会看到。但传统 RTOS 中这种情况很常见，所以我们还是把它纳入讨论。

---

For example, suppose that somewhere in the middle of its long processing, sporadic2 task would make a blocking call to something like the operating system delay() function. In that case, it would stop being ready to run but without completing, so the kernel would have to find another highest-priority task that is ready to run, such as periodic1.

比如，假设 sporadic2 任务在漫长的处理过程中调用了类似 `delay()` 这样的阻塞函数。那它就不再是就绪状态了，但任务也没完成，所以内核必须去找另一个最高优先级的就绪任务来运行，比如 periodic1。

---

Now, let's review the same three scenarios, but this time, examine the possibility of using a single stack for all tasks and ISRs in the system.

好，现在我们回顾同样的三种情况，但这次来看看一个有意思的问题：能不能让系统里所有任务和 ISR 共用**单一栈**（single stack）？

---

The logic analyzer trace starts with the QK idle task running, so the stack contains the idle-task frame.

逻辑分析仪截图从 QK 空闲任务运行开始，所以栈里放的是空闲任务的栈帧。

---

At some point, the SysTick interrupts the idle task. The ISR stack frame gets pushed on the stack.

某个时刻，SysTick 中断了空闲任务。ISR 的栈帧被压入栈。

---

The SysTick ISR posts a couple of events to the sporadic2 task, thus making it ready to run. This is the asynchronous preemption scenario, where QK must switch to the sporadic2 task and not return to the idle task. At the completion of the ISR, the sporadic2 stack frame gets pushed on top of the ISR frame.

SysTick ISR 给 sporadic2 任务发了几个事件，让它就绪。这就是异步抢占的场景——QK 必须切换到 sporadic2 任务，不能回到空闲任务。ISR 结束的时候，sporadic2 的栈帧被压在 ISR 栈帧之上。

---

Now, sporadic2 posts an event to the higher-priority sporadic3. This is the synchronous preemption scenario, where the sporadic3 task is called and its stack frame gets pushed on top of the sporadic2 frame.

接着，sporadic2 给更高优先级的 sporadic3 发了事件。这是同步抢占场景——sporadic3 任务被调用，它的栈帧压在 sporadic2 栈帧之上。

---

Sporadic3 posts an event to the highest-priority periodic4. Again, according to the synchronous preemption scenario applied recursively here, QK must switch to the periodic4 task and not return to the sporadic3 task. The periodic4 stack frame gets pushed on top of the sporadic3 frame.

Sporadic3 又给最高优先级的 periodic4 发了事件。同样是同步抢占，只不过是递归地应用——QK 必须切换到 periodic4 任务，不能回到 sporadic3 任务。periodic4 的栈帧压在 sporadic3 栈帧之上。

---

Periodic4 runs to completion and returns, removing itself from the stack. Similarly, sporadic3 completes and returns, also removing its frame from the stack.

Periodic4 运行到完成然后返回，把自己从栈上弹出去。接着 sporadic3 也完成并返回，同样把自己的栈帧弹出去。

---

The same occurs upon the completion of the sporadic2 task.

sporadic2 任务完成时也是一样。

---

However, sporadic2 still has an event in its queue, so it remains ready to run. QK cannot return to the idle task just yet and must call sporadic2 again. Another instance of the sporadic2 frame is pushed on top of the original ISR stack frame.

不过 sporadic2 的事件队列里还有一个事件，所以它还是就绪状态。QK 暂时还不能回到空闲任务，必须再调用一次 sporadic2。于是 sporadic2 的又一个栈帧被压在最初的 ISR 栈帧之上。

---

Now, the long sporadic2 RTC step is preempted by another SysTick ISR. The ISR stack frame is pushed on top of the sporadic2 stack frame.

这时，sporadic2 这个漫长的运行到完成步骤被另一个 SysTick ISR 抢占了。ISR 栈帧压在 sporadic2 栈帧之上。

---

This SysTick ISR determines that it is time to post a time event to the highest-priority periodic4. According to the asynchronous preemption scenario, QK must switch to the periodic4 task and not return to sporadic2. The periodic4 stack frame is pushed on top of the ISR frame.

这个 SysTick ISR 判断该给最高优先级的 periodic4 发时间事件了。按照异步抢占的处理方式，QK 必须切换到 periodic4 任务，不能回到 sporadic2。periodic4 的栈帧压在 ISR 栈帧之上。

---

After periodic4 completes, sporadic2 must resume from the point of the original asynchronous preemption. Please note that this is not a simple function return: this is a special return from an interrupt that removes the interrupt stack frame. This is also the end of the asynchronous preemption scenario.

periodic4 完成后，sporadic2 必须从之前被异步抢占的那个点恢复。注意，这不是普通的函数返回，而是一种特殊的**中断返回**——它会移除中断栈帧。到这儿，异步抢占场景就结束了。

---

Sporadic2 continues, completes, and returns, removing itself from the stack.

Sporadic2 继续运行，完成后返回，把自己从栈上弹出去。

---

However, in the meantime, two events accumulated in the event queue of the lowest-priority periodic1 task. Since this task is now the highest priority and ready to run, QK activates it twice, as reflected in the stack activity.

与此同时，最低优先级的 periodic1 任务的事件队列里积攒了两个事件。现在它是最高优先级的就绪任务了，QK 把它激活两次，栈的活动也反映了这一点。

---

Finally, after the completion of periodic1, the idle task remains the only one ready to run. The original ISR returns to the asynchronously preempted idle task. Again, this is the special return from an interrupt that removes the ISR stack frame and completes the original asynchronous preemption scenario.

最后，periodic1 完成后，只剩空闲任务是就绪的了。最初的 ISR 返回到被异步抢占的空闲任务。同样，这是特殊的中断返回——移除了 ISR 栈帧，最初的异步抢占场景到此结束。

---

In summary, you just saw how all possible types of task scheduling and preemption in QK can indeed be implemented using a single stack.

总结一下，你刚才看到了 QK 中所有可能的任务调度和抢占类型，确实都能用单一栈来实现。

---

This is in stark contrast to the traditional blocking kernels, which require a private stack per task, as you saw in lessons #22 and #23. Interestingly, the stack usage in the traditional blocking kernels is reversed compared to non-blocking run-to-completion tasks of QK.

这跟传统阻塞内核形成了鲜明对比——传统内核需要为每个任务分配**私有栈**（private stack），你在第 22 和 23 课看到过。有意思的是，传统阻塞内核的栈使用方式跟 QK 的非阻塞运行到完成任务恰好是反过来的。

---

In QK, a task uses the common stack only when it is active, and otherwise, it does not use the stack at all. In a traditional RTOS, a task uses most of its private stack when it is blocked and much less when it is running. In fact, the CPU context saved on each private stack is bigger (about twice the size in Cortex-M) compared to the ISR stack frame in QK.

在 QK 里，任务只在活动时才用公共栈，其他时候根本不用栈。在传统 RTOS 里呢，任务被阻塞的时候反而用掉私有栈的大部分空间，运行时用得倒少。实际上，每个私有栈上保存的**CPU 上下文**（CPU context）比 QK 中的 ISR 栈帧还大——在 Cortex-M 上大约是两倍。

---

This means that QK requires significantly less stack space, on the order of 80% less, to handle the same number of preemptive tasks as a traditional blocking RTOS.

这意味着，处理同样数量的抢占式任务，QK 所需的栈空间要少得多——大约能省 **80%**。

---

The ability to block tasks is certainly very expensive, not just in terms of the precious RAM for the stacks, but also because the context switch is more elaborate and longer. For example, here is the logic analyzer trace for the same set of tasks, the same board, and shown with an identical timescale, but executed using the FreeRTOS kernel.

任务的阻塞能力确实代价高昂，不光是栈要占用宝贵的 RAM，**上下文切换**（context switch）也更复杂、更耗时。比如这里，同样的任务集合、同一块板子、同样的时间刻度，但换成 FreeRTOS 内核来执行。

---

As you can see, the traditional RTOS also executes all tasks without any priority inversions, ensuring compliance with the Rate-Monotonic Scheduling method. But the RTOS takes longer to process interrupts or to switch contexts between tasks. The projects for this lesson will include the FreeRTOS version, allowing you to make comparisons for yourself.

可以看到，传统 RTOS 也能在没有优先级反转的情况下执行所有任务，符合速率单调调度的要求。但 RTOS 处理中断和切换上下文花的时间更长。本课的项目会包含 FreeRTOS 版本，你可以自己对比一下。

---

However, going back to the QK inner workings, in my brief explanation, I omitted many technical details. For example, during any type of preemption, tasks don't call other tasks directly but rather always call the `QK_activate_()` function, which in turn calls the tasks. This is necessary to prevent losing tasks that aren't the highest priority at the beginning of the preemption, and to utilize the proper type of return from various preemptions.

不过回到 QK 的内部工作机制，我刚才的简单解释省略了很多技术细节。比如在任何类型的抢占中，任务不是直接调用其他任务，而是始终调用 `QK_activate_()` 函数，再由它来调用任务。这是有必要的——既能防止在抢占开始时丢失非最高优先级的任务，又能确保各种抢占场景下使用正确的返回方式。

---

For example, the first instance of `QK_activate_()` calls sporadic2 twice and periodic1 twice before eventually returning asynchronously to the idle task.

比如，`QK_activate_()` 的第一个实例调用了 sporadic2 两次和 periodic1 两次，最后才异步返回到空闲任务。

---

Additionally, as mentioned in lessons #17 and #18 about interrupts, the ARM Cortex-M with the NVIC interrupt controller handles interrupts in a unique manner; therefore, the QK implementation for ARM Cortex-M is more elaborate than that for other embedded processors.

另外，第 17 和 18 课讲中断时提到过，ARM Cortex-M 配合 **NVIC 中断控制器**处理中断的方式比较特殊，所以 QK 在 ARM Cortex-M 上的实现比在其他嵌入式处理器上更复杂。

---

Specifically, due to the possibility of interrupts preempting each other, the return from the interrupt level must go through the **PendSV exception** prioritized at the lowest level. Additionally, the final return from asynchronous preemption must also go through a Cortex-M exception, which in QK can be either the **NMI** or any IRQ configured by the user. These details can be found in the QP framework Manual.

具体来说，因为中断之间可能互相抢占，所以从中断级别返回必须经过优先级设为最低的 **PendSV 异常**。另外，从异步抢占最终返回时也必须经过 Cortex-M 异常，在 QK 中可以是 **NMI**（非屏蔽中断）或者用户配置的任何 IRQ。这些细节可以在 QP 框架手册中找到。

---

Now, let me show you how to convert the example application from the last lesson #54 from the non-preemptive QV kernel to the preemptive QK kernel.

好，现在我来演示怎么把上一课（第 54 课）的示例程序从非抢占式 QV 内核切换到抢占式 QK 内核。

---

Since you'll be using the exact same application as the last lesson, let's copy the project for lesson-54 to lesson-55.

因为用的是跟上一课完全相同的应用程序，所以我们先把 lesson-54 的项目复制一份，改成 lesson-55。

---

Get inside the new lesson-55 directory, `stm32c031-cube` project, and double click on the `.project` file to open it in STM32Cube IDE.

进入新的 lesson-55 目录下的 `stm32c031-cube` 项目，双击 `.project` 文件，在 STM32Cube IDE 中打开。

---

The provided Readme file says that you must generate the code from the `project.ioc` file, but let's try to build anyway. In that case, you get a compilation error about a missing STM32 include file.

Readme 文件说你必须从 `project.ioc` 文件生成代码，但我们先试试直接构建。结果你会得到一个编译错误，说找不到某个 STM32 头文件。

---

So, let's open the IOC file and generate the CubeMX code from it.

那就打开 IOC 文件，从中生成 CubeMX 代码吧。

---

This time, the project builds cleanly.

这次项目构建成功了。

---

However, this is still the non-preemptive QV kernel. Now, you need to make the changes to use the QK kernel.

不过这用的还是非抢占式 QV 内核。接下来要改用 QK 内核。

---

First, you remove the QV source code and the QV port. To do this, you exclude them from all build configurations.

首先把 QV 的源代码和移植文件去掉。做法是把它们从所有构建配置中排除。

---

Next, you add the QK source code for all build configurations by unchecking the "exclude from build" box.

然后取消勾选"exclude from build"复选框，给所有构建配置加上 QK 的源代码。

---

You do the same for the QK port to arm-cm, gnu compiler.

QK 针对 ARM Cortex-M、GNU 编译器的移植文件也做同样的操作。

---

When you attempt to build now, you encounter compiler errors regarding the missing QK functions. This is because the compiler include path still points to the QV directory. You need to change it to the QK directory.

再试着构建，会遇到编译器报错说找不到 QK 函数。这是因为编译器的头文件搜索路径还指向 QV 目录，需要改成 QK 目录。

---

Now, the compiler complains about the `bsp.c` file, where you still have some QV-specific code.

接下来编译器报 `bsp.c` 文件有问题，里面还有一些 QV 特有的代码。

---

To update the `bsp.c` board support package, you can compare the standard QPC example for arm-cm, `real-time-nucleo-c031`, QK kernel with your `bsp.c` for QV.

要更新 `bsp.c` 这个**板级支持包**（Board Support Package，BSP），你可以拿 QP/C 框架里标准的 ARM Cortex-M 示例 `real-time-nucleo-c031`（QK 内核版）跟你当前 QV 版本的 `bsp.c` 做个对比。

---

The first set of differences occurs in the SysTick ISR because the QK is a preemptive kernel, and so it has to be informed about entering every ISR by calling `QK_ISR_ENTRY()` macro and exiting every ISR by calling the `QK_ISR_EXIT()` macro.

第一组差异在 SysTick ISR 里。因为 QK 是抢占式内核，所以必须在进入每个 ISR 时调用 `QK_ISR_ENTRY()` 宏通知它，退出时调用 `QK_ISR_EXIT()` 宏通知它。

---

The next set of differences pertains to setting the priorities of the active objects. The real-time example demonstrates the preemption threshold feature, which I will explain in a minute. For now, let's keep the priorities exactly as they were with the QV kernel.

第二组差异是设置活动对象的优先级。实时示例演示了**抢占阈值**（preemption threshold）特性，我稍后会解释。现在先把优先级保持跟 QV 内核完全一样。

---

The last set of differences concerns the different idle processing in QK. As the preemptive kernel, QK does not need to enter sleep mode with interrupts disabled; therefore, the `QK_onIdle()` callback is called with interrupts enabled, unlike the `QV_onIdle()` callback that is called with interrupts disabled. For that reason, `QK_onIdle()` can call the **Wait-for-Interrupt instruction** directly, without concern for the proper sequence of interrupt enabling around it.

最后一组差异是 QK 的空闲处理方式不同。作为抢占式内核，QK 不需要在关中断的情况下进入睡眠模式，所以 `QK_onIdle()` 回调是在中断开着的情况下被调用的——而 `QV_onIdle()` 是在关中断状态下调用的。正因如此，`QK_onIdle()` 可以直接调用**等待中断**（Wait-for-Interrupt，WFI）指令，不用操心中断使能的顺序问题。

---

When you attempt to build now, you have no more compiler errors, but the linker still does not like the multiply defined PendSV and NMI handlers. This is because the QK port to ARM Cortex-M defines these exception handlers, so you need to remove them from the code generation for the NVIC component.

再构建的话，编译器不报错了，但链接器又说不高兴——PendSV 和 NMI 处理程序重复定义了。这是因为 QK 的 ARM Cortex-M 移植已经定义了这些异常处理程序，你需要从 NVIC 组件的代码生成配置里把它们去掉。

---

After re-generating the code, the project builds cleanly.

重新生成代码后，项目构建成功。

---

To test the code, you need to upload it to your NUCLEO-C031 board using either the debug or the correct run configuration. Once you receive confirmation of a successful code upload, reset the board and open the logic analyzer. Here, I'm using the cheap 8-channel, 24MHz logic analyzer with the free PulseView software. And here is how the board is connected to the logic analyzer lines.

要测试代码，得用调试配置或正确的运行配置把它上传到 NUCLEO-C031 板子上。确认上传成功后，复位板子，打开逻辑分析仪。我用的是便宜的 8 通道、24MHz 逻辑分析仪，搭配免费的 PulseView 软件。这是板子跟逻辑分析仪信号线的连接方式。

---

Set the logic analyzer trigger to the falling edge of the D0 line, and press the blue user button. Here is the collected trace, which I have already discussed to explain the QK kernel behavior.

把逻辑分析仪的触发设为 D0 信号线的下降沿，然后按一下蓝色用户按钮。这就是采集到的波形，前面讲解 QK 内核行为时用的就是这些数据。

---

While preemption is a desirable QK kernel property that enables techniques like RMS/RMA, too much preemption also has negative effects. These include more stack usage and restrictions on sharing resources. For example, suppose that sporadic2 and sporadic3 form a group, where some resources are shared between these two Active Objects. In that case, preemption of one group member by another might be unnecessary and undesirable.

虽然抢占是 QK 内核的好特性，能支持 RMS/RMA 等技术，但抢占太多也有负面影响，比如栈用得更多，**资源共享**（resource sharing）也受到限制。比如假设 sporadic2 和 sporadic3 组成一个组，它们之间共享某些资源。这种情况下，一个组成员被另一个成员抢占可能既没必要也不受欢迎。

---

QK offers an advanced feature called **Preemption Threshold Scheduling (PTS)**. PTS allows an Active Object to specify a preemption threshold, selectively restricting preemption by other Active Objects. Only Active Objects that have priorities higher than the preemption threshold are still allowed to preempt, while those with priorities equal or lower than the threshold are not allowed to preempt.

QK 提供了一项高级特性，叫**抢占阈值调度**（Preemption Threshold Scheduling，PTS）。PTS 允许活动对象指定一个抢占阈值，有选择地限制其他活动对象对它的抢占。只有优先级高于抢占阈值的活动对象还能抢占它，优先级等于或低于阈值的一律不许抢占。

---

For example, sporadic2 and sporadic3 Active Objects might specify the same preemption threshold of 3. Such a preemption threshold will prevent preemption within the group, while still allowing preemption by other Active Objects with higher priorities than the preemption threshold, such as periodic4.

比如 sporadic2 和 sporadic3 两个活动对象可以指定相同的抢占阈值 3。这个阈值会阻止组内互相抢占，但仍然允许优先级高于阈值的其他活动对象（比如 periodic4）来抢占。

---

After applying the preemption thresholds in the `bsp.c`, let's rebuild and test the project.

在 `bsp.c` 里设好抢占阈值之后，重新构建并测试项目。

---

I collect the logic analyzer trace as before.

跟之前一样采集逻辑分析仪波形。

---

And then compare the previous trace without preemption threshold against the trace with both sporadic tasks having the same preemption threshold of 3.

然后把之前没有抢占阈值的波形跟两个 sporadic 任务都设了抢占阈值 3 的波形做个对比。

---

As you can see, the sporadic3 task no longer preempts sporadic2, which is allowed to run to completion.

可以看到，sporadic3 不再抢占 sporadic2 了，sporadic2 被允许运行到完成。

---

After that RTC step, the QK scheduler makes an interesting decision, where both sporadic2 and sporadic3 are ready to run, and they both have the same preemption threshold. As you can see, QK chooses to run sporadic3 first because it has a higher priority. Only after that, sporadic2 runs again.

在那个运行到完成步骤之后，QK 调度器做了一个有意思的决定：sporadic2 和 sporadic3 都就绪，而且抢占阈值相同。可以看到，QK 选择先运行 sporadic3，因为它的优先级更高。等 sporadic3 跑完，sporadic2 才接着跑。

---

In contrast, without the preemption threshold, sporadic2 is immediately preempted and completes the first RTC step only after sporadic3.

相比之下，没有抢占阈值的时候，sporadic2 一开始就被抢占了，要等 sporadic3 跑完才能完成第一个运行到完成步骤。

---

The result of PTS in this particular case is one synchronous preemption less and less stack usage. But more importantly, with respect to preemption, sporadic2 and sporadic3 behave now like a single task, so they can safely share resources.

在这个例子中，PTS 的效果是减少了一次同步抢占，栈也用得更少。但更重要的是，在抢占方面，sporadic2 和 sporadic3 现在表现得就像一个任务一样，所以它们可以安全地共享资源。

---

Besides the Preemption Threshold Scheduling, QK also supports another advanced feature called **selective scheduler locking**, a non-blocking mutual exclusion mechanism for protecting resources shared among Active Objects.

除了抢占阈值调度，QK 还支持另一项高级特性——**选择性调度器锁定**（selective scheduler locking）。这是一种非阻塞的**互斥**（mutual exclusion）机制，用来保护活动对象之间的共享资源。

---

I've explained selective scheduler locking in Lesson #28 about the RTOS and the various mutual exclusion mechanisms.

选择性调度器锁定我在第 28 课讲 RTOS 和各种互斥机制的时候已经解释过了。

---

This concludes this quick introduction to the preemptive QK kernel. If you are interested to learn more about such non-blocking kernels, the video description provides some additional literature, such as **OSEK/VDX** operating system specification and the **Stack Resource Policy (SRP)**. In this channel, you can also find videos about the **Super-Simple Tasker** kernel, which is a hardware implementation of a preemptive, non-blocking kernel for ARM Cortex-M.

关于抢占式 QK 内核的快速入门就到这里。如果你想进一步了解这类非阻塞内核，视频描述里有一些参考资料，比如 **OSEK/VDX** 操作系统规范和**栈资源策略**（Stack Resource Policy，SRP）。在这个频道里你还能找到关于 **Super-Simple Tasker** 内核的视频——它是 ARM Cortex-M 上抢占式非阻塞内核的一种硬件实现。

---

The inability to block in the non-blocking kernels doesn't matter for truly event-driven systems because they don't block anyway. In fact, using a traditional blocking RTOS for event-driven Active Objects is certainly possible, but it is wasteful because blocking is very expensive.

非阻塞内核不支持阻塞，这对真正的事件驱动系统来说完全不是问题，因为它们本来就不阻塞。实际上，用传统阻塞式 RTOS 来跑事件驱动的活动对象当然可以，但很浪费——因为阻塞的代价实在太高了。

---

Speaking of traditional blocking RTOS kernels, the projects for this lesson (#55) will include, of course, the QK kernel project for Cube IDE, as well as the FreeRTOS project for comparison. You will also get the Keil uVision projects for QK on NUCLEO-C031 and for QK on TivaC LaunchPad.

说到传统阻塞式 RTOS 内核，本课（#55）的项目当然会包含 Cube IDE 的 QK 内核项目，还有 FreeRTOS 项目供你对比。另外还有 NUCLEO-C031 和 TivaC LaunchPad 上的 QK Keil uVision 项目。

---

As always, the projects are available for download from the companion webpage to this video course and from the GitHub repository.

跟往常一样，项目可以从本课程的配套网页和 GitHub 仓库下载。

---

If you enjoy this channel, please consider subscribing to help support the ongoing production of new videos. Thank you for watching!

如果你喜欢这个频道，请考虑订阅来支持我们继续制作新视频。感谢收看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Preemptive kernel | 抢占式内核 | 高优先级任务可以打断低优先级任务执行的内核 |
| QK kernel | QK 内核 | QP/C 框架中内置的抢占式、非阻塞实时内核 |
| Active Object | 活动对象 | 事件驱动的自主执行实体，封装了状态机和行为 |
| Run-to-completion (RTC) | 运行到完成 | 事件处理策略，每个事件处理步骤不被中断地执行完毕 |
| Synchronous preemption | 同步抢占 | 由事件发送操作触发的抢占，在代码中可见 |
| Asynchronous preemption | 异步抢占 | 由中断触发的抢占，可在任意点发生，代码中不可见 |
| Priority inversion | 优先级反转 | 低优先级任务延迟高优先级任务执行的现象 |
| Rate Monotonic Scheduling (RMS) | 速率单调调度 | 基于任务周期的静态优先级分配方法 |
| Multi-stage task | 多阶段任务 | 将长任务拆分为多个短阶段的策略 |
| Single stack | 单一栈 | 所有任务共享一个栈，非阻塞内核的特性 |
| Private stack | 私有栈 | 每个任务拥有独立栈空间，传统 RTOS 的特性 |
| Context switch | 上下文切换 | 保存当前任务状态并恢复另一个任务状态的过程 |
| CPU-bound task | CPU 密集型任务 | 需要大量 CPU 计算时间的任务 |
| Preemption Threshold Scheduling (PTS) | 抢占阈值调度 | QK 的高级特性，允许有选择地限制抢占 |
| Selective scheduler locking | 选择性调度器锁定 | 非阻塞的互斥机制，用于保护共享资源 |
| Superloop | 超级循环 | 嵌入式系统中常见的无限循环主程序结构 |
| Board Support Package (BSP) | 板级支持包 | 针对特定硬件板的底层驱动和初始化代码 |
| ISR (Interrupt Service Routine) | 中断服务程序 | 响应中断请求而执行的函数 |
| NVIC (Nested Vectored Interrupt Controller) | 嵌套向量中断控制器 | ARM Cortex-M 的中断控制器 |
| PendSV exception | PendSV 异常 | ARM Cortex-M 中用于上下文切换的可挂起系统服务异常 |
| NMI (Non-Maskable Interrupt) | 非屏蔽中断 | 无法被软件禁用的最高优先级中断 |
| Wait-for-Interrupt (WFI) | 等待中断指令 | 使 CPU 进入低功耗状态直到中断发生的指令 |
| OSEK/VDX | OSEK/VDX 规范 | 汽车电子的标准化实时操作系统规范 |
| Stack Resource Policy (SRP) | 栈资源策略 | 用于共享资源的非阻塞同步协议 |
| Super-Simple Tasker | 超简单任务器 | ARM Cortex-M 上抢占式非阻塞内核的硬件实现 |
| FreeRTOS | FreeRTOS | 广泛使用的开源传统阻塞式实时操作系统 |
