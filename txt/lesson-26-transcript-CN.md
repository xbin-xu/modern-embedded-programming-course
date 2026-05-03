# 第26课：RTOS 实时调度 / Lesson 26: RTOS Real-Time Scheduling

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this fifth lesson on RTOS I'll finally address the real-time aspect in the "Real-Time Operating System" name. Specifically, in this lesson you will augment the MiROS RTOS with a preemptive, priority-based scheduler, which can be mathematically proven to meet real-time deadlines under certain conditions.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这是关于 RTOS 的第五节课，终于要聊聊"实时操作系统"中"实时"这两个字到底是什么意思了。具体来说，这节课你要给 MiROS RTOS 加上一个**抢占式优先级调度器**（preemptive, priority-based scheduler），在特定条件下，它可以被数学证明能满足实时截止时间。

As usual, let's get started by making a copy of the previous lesson 25 directory and renaming it to lesson 26.

跟以前一样，先把上一课第25课的目录复制一份，改名叫 lesson 26。

Get inside the new lesson 26 directory and double-click on the uVision project "lesson" to open it.

进到新的 lesson 26 目录，双击 uVision 项目文件 "lesson" 打开。

To remind you quickly what happened so far, in the last lesson you added efficient blocking delay to the MiROS RTOS. However, the RTOS is not yet worthy of it's name, because the round-robin scheduler is not really "Real-Time" yet. So, let's start today with introducing the concept of "Real-Time".

简单回顾一下：上一课你给 MiROS RTOS 加了高效的阻塞延迟。不过，这个 RTOS 目前还配不上这个名字，因为它的**轮转调度器**（round-robin scheduler）还谈不上"实时"。所以今天就从"实时"这个概念讲起。

Until now, in all your code, any computation that was performed was considered equally useful, and you cared only whether the computation was correct, but not whether it was performed within a given time. "Real-Time" adds the timeliness requirement to the computations.

到目前为止，你写的所有代码里，任何计算都被一视同仁——你只关心结果对不对，不关心它花多长时间。而"实时"给计算加上了**时效性**（timeliness）的要求。

Specifically, a computation that is performed too late (or too early for that matter) is considered less useful and even harmful as an outright wrong computation.

具体来说，一个计算如果执行得太晚（或者太早），它的价值就大打折扣，甚至跟完全算错一样有害。

Here is a graphical representation of the "real-time" usefulness of a computation as a function of time.

下面这张图展示了计算的"实时"有用性随时间变化的关系。

In the so called "hard real-time systems", a computation is useful from the triggering event up to the deadline. After the deadline, the usefulness of the computation becomes "negative infinity", which means that the computation is worse that useless (for that its usefulness would be merely zero). A missed deadline represents a system failure. For example, deploying an air-bag too late is not just useless--it is disastrous.

在所谓的**硬实时系统**（hard real-time system）中，计算从触发事件开始到截止时间之前是有用的。过了截止时间，有用性直接变成"负无穷"——也就是说比没用还糟糕（毕竟"没用"只是有用性为零）。错过截止时间就意味着系统故障。比如安全气囊弹得太晚，不光是没用，而是灾难性的。

But there are also "soft real-time systems", where timeliness is also important, but the deadline is not as firm. For example, a text message is expected to be delivered somewhat timely, say within 20 seconds. But it is still useful much longer, although its usefulness diminishes with time.

也有**软实时系统**（soft real-time system），时效性同样重要，但截止时间没那么死。比如短信，期望 20 秒内送达，但即使更晚也还有用——只是有用性逐渐降低。

In the following discussion, I will focus on hard real-time systems.

接下来的讨论中，我会聚焦在硬实时系统上。

From the historical perspective, mainstream use of computers in hard real-time systems started in the 1960's and 70's.

从历史上看，计算机在硬实时系统中的大规模应用始于 20 世纪 60 到 70 年代。

For example, the Apollo program used two identical real-time computers: one in the command module and another in the lunar module. Here is a picture of Margaret Hamilton, who led much of this effort, with the stack of code listings showing how much real-time software was created during the 1960's and early 70's.

比如阿波罗计划用了两台相同的实时计算机——一台在指令舱，一台在登月舱。这是 Margaret Hamilton 的照片，她主持了大量软件工作，旁边那一摞代码清单就是 60 年代到 70 年代初写出来的实时软件的规模。

Already in these early days, people realized that most real-time systems operate in a periodic fashion, meaning that the triggering events and the deadlines repeat with a certain period.

早在那个时候，人们就认识到大多数实时系统都是以**周期性**（periodic）方式运行的——触发事件和截止时间按一定周期重复出现。

For example, landing a spacecraft on the lunar surface required fine corrections to the rocket thrusters that the on-board computer had to perform every few milliseconds. Similarly, industrial processes require periodic control ranging from milliseconds to tens of seconds. Electronic control of combustion engines requires periodic control synchronized with the revolutions of the engine, and so on.

比如航天器要在月球表面着陆，需要对火箭推进器做精细修正，机载计算机每隔几毫秒就要执行一次。工业过程控制也需要从毫秒到几十秒不等的周期控制。内燃机的电子控制要跟发动机转速同步做周期控制，等等。

To better understand how the real-time concepts apply to periodic threads, let's perform a few experiments with your current version of the MiROS RTOS.

为了更好地理解实时概念怎么应用到周期性线程上，我们用当前版本的 MiROS RTOS 做几个实验。

Specifically, you can increase the system clock tick rate to 1000 times per second, that is, one clock tick per millisecond.

先把系统时钟节拍（system clock tick）速率提高到每秒 1000 次，也就是每毫秒一次节拍。

Next, you can modify your binky1 and blinky2 threads so that they actually put some computational load on your CPU, because right now they only turn the LED on or off, which takes a microsecond, after which the thread blocks and relinquishes the CPU.

然后修改 blinky1 和 blinky2 线程，让它们真正给 CPU 加点负载。目前它们只是开关 LED，一微秒就完了，然后就阻塞释放 CPU。

In order to simulate a more realistic CPU loading, you can turn the LED on and off not once, but a few thousand times in a for-loop. This particular for-loop, will take about 1.2 milliseconds to execute, which is intentionally slightly longer than your system clock tick.

为了模拟更真实的负载，可以在 for 循环里把 LED 开关几千次，而不是只开关一次。这个循环大约需要 1.2 毫秒——故意设计成比你的系统时钟节拍稍长一点。

After the for-loop, the blinky1 thread delays for 1 clock tick, which will block until the very next SysTick interrupt. This means that the body of the wile(1)-loop will repeat with the period of 2 milliseconds.

for 循环结束后，blinky1 线程延迟 1 个时钟节拍，阻塞到下一个 SysTick 中断到来。也就是说，while(1) 循环体以 2 毫秒为周期重复执行。

At this point, let me introduce a few symbols, commonly used in the literature to characterize a periodic real-time thread, like your Blinky1:

好，现在来引入几个文献中常用的符号，用来描述像 Blinky1 这样的周期性实时线程：

The time of computation of Thread1 is denoted as C1 and is equal to 1.2 milliseconds.

线程 1 的**计算时间**（computation time）记为 C1，等于 1.2 毫秒。

The period of Thread1 is denoted T1 and is equal to 2 milliseconds.

线程 1 的**周期**（period）记为 T1，等于 2 毫秒。

And finally, the processor utilization of Thread1 is denoted U1 and is the ratio between the time of computation and the period. This is the percentage of the time the CPU spends executing Thread1, and is 60 percent in this case.

最后，线程 1 的**处理器利用率**（processor utilization）记为 U1，等于计算时间除以周期。它表示 CPU 有多少时间花在线程 1 上，这里是 60%。

Similarly to Blinky1, you can modify the Blinky2 thread to simulate a CPU load that runs 3 times longer than Blinky1, that is for about 3.6 milliseconds.

跟 Blinky1 类似，修改 Blinky2 线程，模拟一个运行时间是 Blinky1 三倍的负载——大约 3.6 毫秒。

After the for-loop, the blinky2 thread will delay for 50 milliseconds, so that its total period will be about 54 milliseconds.

for 循环之后，blinky2 线程延迟 50 毫秒，所以它的总周期大约是 54 毫秒。

In the diagram, the computation time of Blinky2, C2, will be 3.6 milliseconds,

图中 Blinky2 的计算时间 C2 是 3.6 毫秒，

and its period, T2, will be 54 milliseconds.

周期 T2 是 54 毫秒。

The CPU utilization of Blinky2, U2, will be 6.6 percent.

Blinky2 的 CPU 利用率 U2 是 6.6%。

One last thing before building the code is to comment out the Wait-For-Interrupt instruction in the OS_onIdle() callback. This will prevent the CPU from stopping and will allow you to see the toggling of the Red LED from the idle thread in the logic analyzer view.

构建代码之前还有一件事：把 OS_onIdle() 回调里的等待中断（Wait-For-Interrupt）指令注释掉。这样 CPU 就不会停下来，你就能在逻辑分析仪视图中看到空闲线程中红色 LED 的翻转。

The code builds correctly, so let's load it into your TivaC LauchPad board and see how it runs using a logic analyzer.

代码编译通过，把它烧到 TivaC LaunchPad 板上，用逻辑分析仪看看运行效果。

The top trace, labeled ISR corresponds to the SysTick_Halder, and it repeats every 1 millisecond. This is your fast 1000 times per second system clock tick.

最上面的那条迹线标记为 ISR，对应 SysTick_Handler，每 1 毫秒重复一次。这就是你每秒 1000 次的快速系统时钟节拍。

The trace immediately below, labeled T1 corresponds to Blinky1 and most of the time it runs for about 1.2 milliseconds.

紧挨着的下面那条标记为 T1，对应 Blinky1，大部分时候运行大约 1.2 毫秒。

It repeats every 2 milliseconds.

每 2 毫秒重复一次。

The trace below, labeled T2 corresponds to Blinky2. This thread runs for about 3 to 4 milliseconds, not counting the gaps.

再下面那条标记为 T2，对应 Blinky2。这个线程运行大约 3 到 4 毫秒（不算中间的间隔）。

T2 repeats every 55 milliseconds.

T2 每 55 毫秒重复一次。

Finally, the bottom trace, labeled IDL corresponds to the idle thread, and it runs only when no other thread or ISR is running.

最底下的那条标记为 IDL，对应**空闲线程**（idle thread），只有没有其他线程或 ISR 在运行时它才执行。

But the most interesting part of the logic analyzer view is the time when Blinky1 and Blinky2 are both unblocked and are ready to run at the same time.

但逻辑分析仪视图中最有意思的部分，是 Blinky1 和 Blinky2 同时被解除阻塞、同时准备运行的那个时刻。

When you zoom in, you can see that Blinky1 starts running, but is scheduled out on the next clock tick, at which point Blinky2 is scheduled to run. Blinky2 also runs only for one clock tick, and only then Blinky1 is scheduled in again to finish the processing, after which it blocks, so Blinky2 runs for the rest of the time slice.

放大来看，Blinky1 开始运行，但下一个时钟节拍就被调度出去了，换 Blinky2 上来。Blinky2 也只跑了一个时钟节拍，然后 Blinky1 才又被调度进来完成剩下的处理。Blinky1 完成后阻塞，Blinky2 接着跑完剩余的时间片。

On the subsequent clock tick, Blinky1 becomes ready to run again, but notice that this is the THIRD tick from the previous activation, which means that Blinky1 misses its TWO millisecond deadline by one tick.

再下一个时钟节拍，Blinky1 又准备运行了，但注意——这已经是上一次激活后的第三个节拍了，也就是说 Blinky1 错过了 2 毫秒的截止时间，差了一个节拍。

This happens, because the current scheduler inside the MiROS RTOS is still round-robin. This scheduler was designed for timesharing systems, where the most important goal was to share the CPU FAIRLY among all threads. Therefore, the scheduler takes the CPU away from Blinky1 after it exhausts its time slice.

之所以会这样，是因为 MiROS RTOS 目前的调度器还是轮转式的。轮转调度器是为**分时系统**（timesharing system）设计的，最重要的目标是让所有线程**公平**地分享 CPU。所以 Blinky1 一用完自己的时间片，调度器就把 CPU 拿走了。

But this is NOT what you want in a hard-real time system. For example, suppose that Blinky1 represents an important thread that controls lunar module's descend to the Moon's surface. It HAS to run every 2 milliseconds, and missing even one of these deadlines can cause a catastrophic system failure. In that case, you don't care about the fairness of CPU assignment. You care about meeting your 2 millisecond hard real-time deadline.

但这不是你在硬实时系统中想要的。打个比方，假如 Blinky1 代表的是控制登月舱降落月球表面的关键线程——它必须每 2 毫秒运行一次，错过哪怕一个截止时间都可能导致灾难性故障。这种时候你根本不在乎 CPU 分配公不公平，你只在乎能不能满足 2 毫秒的硬实时截止时间。

For this you need a different scheduler, which somehow KNOWS about the importance of the threads, so that it can execute a more important thread before executing a less-important thread.

要做到这一点，你需要一个不一样的调度器——它得能感知线程的重要性，让更重要的线程先于不那么重要的线程执行。

Today, you will implement the simplest version of such a real-time scheduler, called priority-based, preemptive scheduler with static priorities. This means that each thread will be assigned a unique PRIORITY number when it is started and this priority will not change thereafter. The job of the scheduler will be to always run the the highest-priority thread that is ready-to-run.

今天你要实现这种实时调度器最简单的版本——带**静态优先级**（static priority）的抢占式优先级调度器。也就是说，每个线程启动时会被分配一个唯一的**优先级**（priority）编号，之后不再改变。调度器的职责就是始终运行当前**就绪**（ready-to-run）线程中优先级最高的那个。

Let's see in a timing diagram, how your Blinky threads would execute under such a priority-based scheduler and how the timing would differ from the current round-robin scheduler.

用时序图来看看，在优先级调度器下你的 Blinky 线程会怎么执行，跟现在的轮转调度器有什么不同。

As long as the thread T1 remains the only one ready-to-run, because T2 is blocked inside the OS_deleay() function, the execution is identical under both schedulers.

只要 T1 还是唯一就绪的线程（因为 T2 在 OS_delay() 里阻塞着），两种调度器下的执行完全一样。

But as soon as T2 becomes ready-to-run, the round-robin scheduler suspends T1 and schedules T2. Already at this point T1 looses its chance to meet the 2 millisecond deadline.

但 T2 一旦变为就绪状态，轮转调度器就会暂停 T1，调度 T2 上来运行。从这一刻起，T1 就已经不可能满足 2 毫秒的截止时间了。

In contrast, the priority-based scheduler also sees that T2 is becoming ready-to-run, but T1 has a higher PRIORITY, so the scheduler chooses T1 to run. Therefore, T1 continues and easily meets its 2 millisecond deadline.

而优先级调度器也看到 T2 变为就绪了，但 T1 的优先级更高，所以调度器选择让 T1 继续运行。于是 T1 顺利完成，轻松满足 2 毫秒的截止时间。

The T2 thread is scheduled only after T1 voluntarily BLOCKS in the OS_delay() function. But as soon as T1 is unblocked again, the scheduler immediately switches back to T1, because it has higher PRIORITY than T2. The situation repeats as long as T2 eventually blocks as well.

T2 只有在 T1 主动在 OS_delay() 里**阻塞**之后才会被调度。但 T1 一旦再次解除阻塞，调度器立刻切回 T1，因为它的优先级比 T2 高。就这样一直重复，直到 T2 也完成并阻塞。

But interestingly, notice that even though T2 is significantly delayed by constant interruptions from T1, it too eventually completes and blocks way before its deadline of 54 milliseconds. This means that the priority-based scheduler executes T1 AND T2 in such a way that they BOTH meet their hard real-time deadlines.

有意思的是，虽然 T2 被 T1 不断打断、严重推迟，但它最终也在 54 毫秒截止时间之前就完成了并阻塞。也就是说，优先级调度器能让 T1 和 T2 两个线程都满足各自的硬实时截止时间。

So now, let's actually implement the priority-based scheduler in the MiROS RTOS.

好，现在就在 MiROS RTOS 中动手实现优先级调度器。

The first thing is to bump up the version number and add the thread priority to the thread control block and to the OSThread_start() function. The priority number will be a small integer in the range from 0 to the number of supported threads, which is 32 in the MiROS RTOS, so it will comfortably fit in a uint8_t type.

第一步是把版本号升上去，然后把线程优先级加到**线程控制块**（Thread Control Block, TCB）和 OSThread_start() 函数里。优先级是一个小整数，范围从 0 到支持的最大线程数（MiROS 里是 32），所以用 uint8_t 类型完全够放。

In the RTOS implementation, you need to also bump up the version number and add the priority parameter to the OSThread_start() function. Here, you also need to re-design the use of the OS_thread[] array.

在 RTOS 实现这边，同样要升版本号，给 OSThread_start() 加上优先级参数。同时还要重新设计 OS_thread[] 数组的用法。

As you perhaps recall from the last lesson 25, the OS_thread[] array holds pointers to all thread objects that have been started. In the round-robin scheduler, the array was filled consecutively from index 0, which is reserved for the idle thread, up to the index OS_threadNum.

你可能还记得上一课第25课，OS_thread[] 数组保存了所有已启动线程对象的指针。在轮转调度器里，这个数组从索引 0（保留给空闲线程）一直连续填到 OS_threadNum。

For the priority-based scheduler, the difference will be that indexes into the OS_thread[] array will be the thread PRIORITIES, and that these priorities don't need to be consecutive, meaning that there could be gaps in the OS_thread[] array. For example, the picture shows the idle thread at priority 0, Blinky2 at priority 2, Blinky1 at priority 5, and ThreadN at priority N.

对于优先级调度器，区别在于：OS_thread[] 数组的索引就是线程的优先级，而且这些优先级不需要连续——也就是说数组里可能有空位。比如图中空闲线程在优先级 0，Blinky2 在优先级 2，Blinky1 在优先级 5，ThreadN 在优先级 N。

This means that you replace the OS_threadNum index with the priority number passed as the function parameter. Also, you need to save the user-specified priority into the thread control block.

也就是说，你要用传入的优先级编号来替代原来的 OS_threadNum 索引。同时还要把用户指定的优先级保存到线程控制块中。

However, to avoid overbooking of the OS_thread[] array, you must now make sure that not only the priority level is in range, but also that it is not already used, meaning that OS_thread at the prio index is still a zero-pointer.

不过，为了避免 OS_thread[] 数组被重复占用，现在必须检查两点：优先级在有效范围内，而且这个优先级还没被用过——也就是说 OS_thread[prio] 那个位置还得是空指针。

You can move this assertion to the top of the function and make it into a precondition that you code with the Q_REQUIRE() macro introduced in the last lesson. Precondition means that it must be satisfied by the CALLER of the function, not by the function itself. For example, it is the job of the application programmer to assign a unique priority to each thread.

你可以把这个断言移到函数开头，用上一课介绍的 Q_REQUIRE() 宏把它写成**前置条件**（precondition）。前置条件的意思是它由函数的调用者来保证，而不是函数自己。比如给每个线程分配唯一的优先级，就是应用程序员的责任。

Now, let's think for a minute about the use of the OS_readySet bitmask. For the priority-based scheduling, the most interesting information will be to find the highest-priority thread that is ready-to-run based on the current value of the bitmask.

现在来想想 OS_readySet **位掩码**（bitmask）怎么用。对于优先级调度来说，最关键的信息就是：根据位掩码的当前值，找到就绪线程中优先级最高的那个。

At this point, you need to decide about your preferred priority numbering scheme.

这里需要决定用哪种优先级编号方案。

For historical reasons, many RTOSes you might encounter, such as NUCLEUS, ThreadX, MicroC/OS, embOS, and others, use the INVERSE priority numbering scheme, where priority 0 corresponds to the highest-priority thread and higher priority numbers correspond to LOWER priority threads. Needless to say, the inverse priority numbering scheme leads to constant confusion when talking about higher and lower thread priorities.

由于历史原因，你遇到的很多 RTOS——比如 NUCLEUS、ThreadX、MicroC/OS、embOS 等等——用的是**反向优先级编号**（inverse priority numbering scheme）：优先级 0 反而是最高优先级，数字越大优先级越低。不用说，每次讨论"高优先级""低优先级"的时候，这种反向编号都让人头疼。

But it is of course possible to use a simple, DIRECT priority numbering scheme, where priority 0 corresponds to the idle thread and higher priority numbers correspond to threads of higher priority. The MiROS RTOS will use this simple, DIRECT priority numbering convention.

但完全可以采用更直观的**直接优先级编号**（direct priority numbering scheme）：优先级 0 是空闲线程，数字越大优先级越高。MiROS RTOS 就用这种简单直接的编号方式。

The basic principle of finding the priority number of the highest-priority thread that is ready-to-run will be to count the leading zeros in the OS_readySet bitmask up to the first one-bit and subtracting it from the total number of bits, which is 32.

找到就绪的最高优先级线程的基本思路是：统计 OS_readySet 位掩码中从最高位到第一个 1 位之间的**前导零**（leading zeros）个数，然后用总位数 32 减去它。

For example, if the Blinky2 thread is the only one ready-to-run, the OS_readySet bitmask would have all zero bits except bit number 1. In this case, the count of leading zeros is 30, which can be converted to the priority number by subtracting it from the total number of bits of 32.

比如，如果只有 Blinky2 线程是就绪的，OS_readySet 位掩码就只有第 1 位是 1，其余全是 0。这时前导零有 30 个，用 32 减去 30 就得到优先级编号 2。

If the Blinky1 thread with priority 5 is ready-to-run, then the OS_readySet bitmask will have 27 leading zeros up to the first one-bit, which converts to the priority number of 5 by subtracting it from the total number of bits of 32.

如果优先级为 5 的 Blinky1 线程也就绪了，那 OS_readySet 位掩码中从最高位到第一个 1 之间有 27 个前导零，32 减 27 得到优先级编号 5。

In the general case of a thread with priority N being ready-to-run, the count of leading zeros will be 32 minus N, so that the priority number works out again as 32 minus the count of leading zeros in the OS_readySet bitmask.

一般情况，如果优先级为 N 的线程就绪，前导零个数就是 32 减 N，所以优先级编号总是等于 32 减去位掩码中前导零的个数。

The formula works even for the idle condition of the system, where all 32 bits in the OS_readySet bitmask are zero, which results in priority of zero, that is, the priority of the idle thread.

这个公式在系统空闲时也成立——此时 OS_readySet 全部 32 位都是 0，算出来的优先级就是 0，正好是空闲线程的优先级。

Mathematically, the formula 32-CLZ(x) that finds the most-significant one-bit in the number x, is the integer approximation of the log-base-2 function. And that's why I will code it as the LOG2() macro in the miros.c implementation file.

数学上说，公式 32-CLZ(x) 找的是数字 x 中最高位的 1，它其实是以 2 为底的对数函数的整数近似。所以我在 miros.c 实现文件中把它写成一个 LOG2() 宏。

Of course, the algorithm is only as fast as the Count-Leading-Zeros operation, but it turns out that your ARM Cortex-M4 processor supports it in hardware, as the CLZ instruction.

当然，算法快不快取决于计算前导零（Count-Leading-Zeros, CLZ）操作有多快。好消息是，你的 ARM Cortex-M4 处理器有硬件支持——就是 CLZ 指令。

You can actually find this instruction in the datasheet of your TivaC microcontroller.

你可以在 TivaC 微控制器的数据手册中找到这条指令。

To take advantage of the CLZ instruction, you can search the compiler help for CLZ. As you can see, this particular compiler supports it through the intrinsic function __clz().

要利用 CLZ 指令，可以在编译器帮助里搜索 CLZ。可以看到，这个编译器通过**内联函数**（intrinsic function）__clz() 来支持它。

With the very efficient LOG2() operation, you can now implement the priority-based scheduler.

有了高效的 LOG2() 操作，就可以实现优先级调度器了。

As before, when the scheduler detects the idle condition of the system, it needs to choose the idle thread. But now, you no longer use the OS_currIdx variable, so you just directly set OS_next to OS_thread of zero, which is the idle thread.

跟之前一样，调度器检测到系统空闲时要选择空闲线程。但现在不用 OS_currIdx 变量了，直接把 OS_next 设为 OS_thread[0] 就行——那就是空闲线程。

Otherwise, if some threads are ready-to-run, you use the LOG2() macro with the OS_readySet argument to find the highest-priority thread that is ready-to-run. Please note that the LOG2() macro is guaranteed to produce a number between zero and 32, inclusive, so it can be used directly as an index into the OS_thread[] array without range checking the index.

否则，如果有线程就绪，就用 LOG2() 宏加上 OS_readySet 参数，找出就绪线程中优先级最高的。注意，LOG2() 宏保证返回 0 到 32（含）之间的值，所以可以直接拿来索引 OS_thread[] 数组，不需要额外的范围检查。

At this point, it is also a good idea to assert that the OS_next pointer is not zero.

这里最好再断言一下 OS_next 指针不为空。

The final change is re-designing of the OS_tick() and OS_delay() services. This is necessary, because both implementations currently assume that the OS_thread[] array is populated consecutively up to the OS_threadNum level, which is no longer the case.

最后还要重新设计 OS_tick() 和 OS_delay() 两个服务。这是必须的，因为之前的实现都假设 OS_thread[] 数组是连续填充到 OS_threadNum 的，现在不再是这样了。

In OS_tick(), instead of iterating over the whole OS_thread[] array with potentially big gaps of unused priority levels, you can leverage the fast LOG2() operation.

在 OS_tick() 中，与其遍历可能有大量空位的整个 OS_thread[] 数组，不如利用快速的 LOG2() 操作。

Specifically, you can introduce a bitmask of delayed threads, which is similar to the OS_readySet, except it holds the delayed threads.

具体做法是引入一个延迟线程的位掩码 OS_delayedSet，跟 OS_readySet 类似，只不过它保存的是正在延迟的线程。

While you are at it, you might also remove the no longer needed variables OS_currIdx and OS_threadNum.

顺便把不再需要的变量 OS_currIdx 和 OS_threadNum 也删掉。

With the OS_delayedSet bitmask in place, the OS_tick() function will iterate only over the 1-bits in the bitmask, instead of scanning all the bits. But, because you will need to remove the already processed bits from the bitmask, you need to use a temporary bitmask 'workingSet'.

有了 OS_delayedSet 位掩码，OS_tick() 只需要遍历位掩码中值为 1 的位，而不是扫描所有位。但因为处理完之后要把对应的位从位掩码中清除，所以需要一个临时位掩码 workingSet。

You loop as long as the workingSet has some bits set, meaning that some threads are delayed and need processing at this clock tick.

只要 workingSet 里还有位被置位——说明还有线程在延迟、需要在这个时钟节拍处理——就继续循环。

You first quickly obtain the number of the highest-order 1-bit in the workingSet using your fast LOG2() macro, and you use it to index into the OS_therad[] array. You save the obtained thread pointer in a temporary variable t.

先用 LOG2() 宏快速拿到 workingSet 中最高位 1 的编号，用它去索引 OS_thread[] 数组，把拿到的线程指针存到临时变量 t 里。

You then assert that the t pointer is not zero, meaning that the thread is in use.

然后断言 t 指针不为空，确认这个线程确实在使用中。

And you also assert that the timeout of this thread is not zero, because it must be a delayed thread.

还要断言这个线程的超时值不为零——既然在延迟集合里，超时值肯定大于 0。

Next, you decrement the timeout counter for this thread and if it becomes zero, you make the thread ready to run by setting the corresponding priority bit in the OS_readySet bitmask.

接着递减这个线程的超时计数器。如果减到零了，就把对应优先级的位在 OS_readySet 中置位，让这个线程变为就绪状态。

At the same time, you remove the same bit from the OS_delayedSet bitmask, because this thread is no longer delayed.

同时把同一个位从 OS_delayedSet 中清除，因为线程不再延迟了。

Finally, you always remove the same priority bit from the workingSet, because it is now processed.

最后把这个优先级位从 workingSet 中也清除，因为已经处理完了。

To avoid the apparent code duplication, you can introduce a temporary variable 'bit', like this.

为了避免代码重复，可以引入一个临时变量 bit，像这样。

In the OS_delay() function, you need to replace the OS_currIdx variable with the priority number of the current thread.

在 OS_delay() 函数里，把 OS_currIdx 替换成当前线程的优先级编号。

In addition to removing the priority-bit from the ready set, the function now also needs to add the same bit to the OS_delayedSet, because this thread is now becoming delayed.

从就绪集合中清除优先级位之后，还要把同一位加到 OS_delayedSet 里，因为线程马上要进入延迟状态了。

And finally, to avoid code duplication, you can introduce a temporary variable 'bit', just like in OS_tick() before.

最后，同样为了避免代码重复，引入临时变量 bit，跟 OS_tick() 中的做法一样。

The priority-based scheduler implementation is ready now, so let's try to build the code.

优先级调度器实现完成，来编译看看。

The project fails to compile, because the signature of the OSThread_start() function has changed. With the priority-based scheduler, each thread you start needs a unique priority to run at.

编译报错了，因为 OSThread_start() 函数的签名变了。用优先级调度器，每个启动的线程都需要一个唯一的优先级。

To remain consistent with the previously used diagrams, let's assign priority 5 to Blinky1 and priority 2 to Blinky2.

为了跟之前的图保持一致，给 Blinky1 分配优先级 5，Blinky2 分配优先级 2。

As you can see, the priorities don't need to be consecutive. What really matters is that they are unique and that priority of Blinky1 is higher than priority of Blinky2.

如你所见，优先级不需要连续。真正重要的是：每个线程的优先级互不相同，而且 Blinky1 的优先级比 Blinky2 高。

There is still one more compilation error. You now need to add explicit priority zero when starting the idle thread.

还有一个编译错误——启动空闲线程时现在要显式传入优先级 0。

The code builds cleanly, so let's see how it works.

编译通过了，看看效果。

First, I'm sure you are curious about the code generated by the LOG2() macro, so let's set a breakpoint inside the OS_sched() function, where the macro is used.

首先，你肯定好奇 LOG2() 宏生成的代码长什么样。在 OS_sched() 函数中使用这个宏的地方设个断点。

As you can see, the disassembly starts with loading addresses of the OS_thread array and the OS_readySet bitmask and then the whole calculation of the highest-priority thread ready to run is accomplished with just two instructions.

可以看到，反汇编先是加载 OS_thread 数组和 OS_readySet 位掩码的地址，然后整个"找最高优先级就绪线程"的计算只用两条指令就搞定了。

The CLZ instruction counts the number of leading zeros in the bitmask and stores it in r0 in just one CPU cycle.

CLZ 指令统计位掩码中的前导零个数，存入 r0，只需要 1 个 CPU 周期。

Similarly, the RSB instruction--reverse subtract--converts it to the priority-number in r0, also in just one CPU cycle. The resulting priority in this case turns out to be 5, which you should recognize as the priority of Blinky1.

接着 RSB 指令——反向减法——把它转换成优先级编号存入 r0，同样只要 1 个周期。这次算出来的优先级是 5——没错，就是 Blinky1 的优先级。

Indeed, the OS_next variable is set to the address of the Blinky1 thread.

确实，OS_next 变量被设置成了 Blinky1 线程的地址。

When you finally run the code free you can watch some activity of the LEDs on your board.

让代码自由运行，就能看到板上 LED 有动作了。

But to really see how your new priority-based scheduler works, you need to use a logic analyzer.

但要真正看清新的优先级调度器是怎么工作的，还得靠逻辑分析仪。

As you can see, the Blinky1 thread runs now completely undisturbed even when Blinky2 becomes ready to run.

可以看到，即使 Blinky2 变为就绪状态，Blinky1 线程也完全不受干扰地运行。

Blinky1 always meets its deadline and so does Blinky2, even though Blinky2 is preempted by Blinky1 several times.

Blinky1 总是能满足截止时间，Blinky2 也是——虽然 Blinky2 被 Blinky1 **抢占**（preempted）了好几次。

Finally, the idle thread runs as well, but only when none of the other threads or interrupts are active.

空闲线程也会运行，但只在没有其他线程或中断活动的时候。

It's nice to notice that this analyzer trace matches exactly the timeline of the priority-based scheduler you've designed earlier and subsequently implemented in the MiROS RTOS.

值得注意的一点是，逻辑分析仪的波形跟你之前设计的、随后在 MiROS RTOS 中实现的优先级调度器的时序图完全吻合。

At this point, I would like you to notice the absolutely critical importance of BLOCKING for the priority-based scheduler. A high-priority thread runs for as long as it wants and no thread of lower-priority can run until the high-priority thread BLOCKS and voluntarily relinquishes the CPU. Without the blocking, NO lower-priority thread will EVER run. For example Blinky2 and the Idle thread run only when Blinky1 blocks and similarly, the Idle thread runs only when BOTH Blinky1 and Blinky2 are blocked.

说到这里，我想让你特别注意**阻塞**（blocking）对优先级调度器有多关键。高优先级线程想运行多久就运行多久，在它阻塞、主动释放 CPU 之前，任何低优先级线程都别想运行。没有阻塞，低优先级线程就永远没机会。比如 Blinky2 和空闲线程只有等 Blinky1 阻塞了才能运行，而空闲线程更要等 Blinky1 和 Blinky2 都阻塞了才有机会。

This is very different from the round-robin scheduler, which executed all your blinky threads in succession even when they didn't block at all. So now you know why I had to implement efficient thread blocking in the last lesson 25 before introducing real-time priority-based scheduling in this lesson.

这跟轮转调度器完全不一样——轮转调度器即使线程根本不阻塞，也会轮流让每个 blinky 线程执行。所以现在你知道了，为什么上一课要先实现高效的线程阻塞，然后这节课才能引入实时优先级调度。

With the code working as expected, let's now focus on the most important decision you face when working with the priority-based scheduler, and that is, on how to assign priorities to your threads.

代码按预期工作了，接下来聊聊使用优先级调度器时最重要的决策——怎么给线程分配优先级。

With just two threads, like your Blinky1 and Blinky2, you have only two possibilities: priority of Blinky1 higher than Blinky2 and priority of Blinky1 lower than Blinky2. As you just saw, the first option meets both real-time deadlines.

只有 Blinky1 和 Blinky2 两个线程的话，就两种选择：Blinky1 优先级高于 Blinky2，或者低于 Blinky2。你刚看到了，第一种方案两个截止时间都能满足。

On the other hand, it is easy to see that the second possibility of assigning lower priority to Blinky1 than Blinky2 leads to Blinky1 missing its deadline as soon as Bliny2 becomes ready to run.

反过来，把 Blinky1 的优先级设得比 Blinky2 低，那 Blinky2 一就绪，Blinky1 就会错过截止时间——这很容易看出来。

So, the rule that emerges here is to assign higher priorities to threads with shorter periods, which means also shorter deadlines.

所以这里得出的规则是：周期越短的线程，优先级越高——周期短也就意味着截止时间短。

It turns out that this rule has been discovered already in the 1970s. Specifically, in 1973 C.L.Liu and James W. Layland published a seminal paper titled: "Scheduling Algorithms for Multiprogramming in Hard-Real-Time Environment". I provide a web link to this article in the video description.

其实这个规则早在 70 年代就被发现了。1973 年，C.L. Liu 和 James W. Layland 发表了一篇里程碑式的论文："Scheduling Algorithms for Multiprogramming in Hard-Real-Time Environment"（硬实时环境中多道程序设计的调度算法）。视频描述里有链接。

But basically, Liu and Layland described in this article that the simple static priority-based scheduler that you've just implemented can be mathematically proven to meet all hard-real-time deadlines for all threads under certain conditions.

简单说，Liu 和 Layland 在这篇论文中证明了：你刚刚实现的这种简单的静态优先级调度器，在特定条件下可以被数学证明能满足所有线程的硬实时截止时间。

The method was later generalized and called "Rate-Monotonic Analysis" (RMA) or "Rate-Monotonic Scheduling" (RMS), and has been very well explained in another article "Rate Monotonic Analysis for Real-Time Systems", to which I also provide a web link in the video description.

这个方法后来被推广，叫做**速率单调分析**（Rate-Monotonic Analysis, RMA）或**速率单调调度**（Rate-Monotonic Scheduling, RMS）。另一篇文章 "Rate Monotonic Analysis for Real-Time Systems" 讲得很清楚，链接也在视频描述里。

I bring it up here, because no discussion of priority-based scheduler can be complete without mentioning the RMA slash RMS method.

之所以提这个，是因为讨论优先级调度器不能不提 RMA/RMS。

The term rate monotonic (RM) derives from a method of assigning priorities to a set of threads as a monotonic function of the rate of a (periodic) thread.

"速率单调"（rate monotonic）这个名字，来源于一种按线程速率的**单调函数**（monotonic function）来分配优先级的方法。

A function is called "monotonic" in mathematics, when it preserves (or reverses) the order between two ordered sets. Specifically, RMA refers to priority assignment that maps increasing order of thread rates to increasing order of thread priorities. As such, it is just a fancy name for the simple rule you have discovered yourself.

数学上，当一个函数保持（或反转）两个有序集合之间的顺序关系时，就叫"单调函数"。具体来说，RMA 的优先级分配方式就是把线程速率从小到大映射到优先级从低到高。说白了，就是你刚才自己发现的那个简单规则，换了个高大上的名字。

But there is of course more to RMA than this, and the full discussion would be really out of scope for this short lesson. For today, let me just summarize the most important guidelines of the RMA/RMS method:

当然 RMA 不止这些，完整讨论超出了这堂课的范围。今天只总结 RMA/RMS 方法最重要的几条指导原则：

First, always assign thread priorities monotonically, meaning that threads with higher rates must run at higher priorities than threads with lower rates.

第一，优先级要按速率单调分配——速率高的线程优先级必须高于速率低的线程。

Second, you need to know the CPU utilization of each thread, which you calculate as the ratio between the measured execution time Cn to the period Tn.

第二，你需要知道每个线程的 CPU 利用率，用实测的执行时间 Cn 除以周期 Tn 来算。

And third, you need to calculate the total CPU utilization as the sum of all individual CPU utilization factors. If this total utilization is below the theoretical bound, all threads in the set are guaranteed to meet their deadlines. This was already proven mathematically by Liu and Layland back in the 1973 paper.

第三，计算总 CPU 利用率——就是所有线程各自利用率的总和。如果总利用率低于理论上限，那这组线程就一定能全部满足截止时间。这在 Liu 和 Layland 1973 年的论文中已经给出了数学证明。

The utilization bound U(n) depends on the number of threads n. For the large number of threads, U(n) approaches natural logarithm of 2, which is just under 0.7. So, in practice, if you stay below 70% of the CPU utilization, your set of threads will be schedulable, meaning that they will all meet their deadlines.

利用率上限 U(n) 跟线程数 n 有关。当线程数很多时，U(n) 趋近于 2 的自然对数，大约是 0.7。所以在实际应用中，只要总 CPU 利用率控制在 70% 以下，你这组线程就是**可调度的**（schedulable）——都能满足截止时间。

For example, the total CPU utilization for your Blinky1 and Blinky2 threads is as follows:

比如你的 Blinky1 和 Blinky2 线程，总 CPU 利用率如下：

1.2ms/2ms for Blinky1 plus 3.6ms/54ms for Blinky2. The total CPU utilization is thus 0.666, which is below the theoretical bound.

Blinky1 的 1.2ms/2ms 加上 Blinky2 的 3.6ms/54ms，总利用率是 0.666，低于理论上限。

Of course, the basic RMA assumes periodic threads that execute in constant time. But the method can be extended to aperiodic threads with variable execution time. In that case you need to consider the worst-case, that is the shortest time between the thread activations and the longest execution time.

当然，基本的 RMA 假设线程是周期性的、执行时间是恒定的。但这个方法也可以扩展到非周期性线程和可变执行时间的情况。这时就要按最坏情况来算——用两次激活之间的最短间隔和最长执行时间。

Also, in practice typically only a few highest-priority threads have hard-real-time deadlines, while other threads have only soft-real-time requirements. In that case, you use RMA for the hard-real-time threads and prioritize all soft-real-time threads lower.

另外，实际项目中通常只有少数几个最高优先级的线程有硬实时截止时间，其余线程只有软实时要求。这时对硬实时线程用 RMA 分析，软实时线程统一分配更低的优先级就行。

The beauty of preemptive priority-based scheduling is that a high-priority thread can always immediately preempt all lower-priority threads, so a high-priority thread is insensitive to changes in execution time or period of lower-priority threads. In other words, the preemptive, priority-based scheduler decouples threads in the time domain.

抢占式优先级调度的妙处在于：高优先级线程总是能立即抢占所有低优先级线程，所以高优先级线程完全不受低优先级线程执行时间或周期变化的影响。换句话说，抢占式优先级调度器在时间维度上把线程之间**解耦**（decouple）了。

For all these reasons, the preemptive, priority-based scheduler became the norm and is supported in most Real-Time Operating Systems to this day.

正是因为这些优势，抢占式优先级调度器成了行业标准，至今绝大多数实时操作系统都支持它。

This concludes this lesson on real-time computing and the priority-based scheduling. In the next lesson, you'll advance by another decade from the 1970's to the 1980's, when the commercial RTOSes went mainstream, and when inter-thread synchronization and communication mechanisms have been added.

关于实时计算和优先级调度的这节课就到这里。下一课我们要从 70 年代再往后推进十年，来到 80 年代——那时商业 RTOS 开始普及，线程间同步和通信机制也被加入进来。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅以获取最新内容。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Real-Time Operating System (RTOS) | 实时操作系统 | 专门设计用于满足实时计算约束的操作系统 |
| Hard real-time system | 硬实时系统 | 错过截止时间会导致灾难性后果的实时系统 |
| Soft real-time system | 软实时系统 | 截止时间重要但不是绝对严格，错过之后有用性递减 |
| Deadline | 截止时间 | 任务必须完成的时间限制 |
| Timeliness | 时效性 | 计算在规定时间内完成的要求 |
| Periodic thread | 周期性线程 | 以固定周期重复执行的线程 |
| Preemptive scheduler | 抢占式调度器 | 可以中断当前运行线程并切换到更高优先级线程的调度器 |
| Priority-based scheduler | 优先级调度器 | 根据线程优先级决定执行顺序的调度器 |
| Round-robin scheduler | 轮转调度器 | 以公平方式轮流分配 CPU 时间片的调度器 |
| Static priority | 静态优先级 | 线程启动时分配且运行期间不变的优先级 |
| Ready-to-run | 就绪 | 线程已准备好执行，等待调度器分配 CPU |
| Blocking | 阻塞 | 线程主动放弃 CPU 并等待某个条件满足 |
| Preemption | 抢占 | 高优先级线程中断低优先级线程执行的机制 |
| Thread Control Block (TCB) | 线程控制块 | RTOS 中保存线程状态信息的核心数据结构 |
| Bitmask | 位掩码 | 用位来表示线程集合状态的数据结构 |
| Count-Leading-Zeros (CLZ) | 计算前导零 | 计算一个数从最高位开始连续零的个数的操作 |
| Inverse priority numbering | 反向优先级编号 | 优先级 0 为最高优先级的编号方案 |
| Direct priority numbering | 直接优先级编号 | 优先级 0 为最低优先级的编号方案 |
| Processor utilization | 处理器利用率 | CPU 执行特定线程的时间占总时间的百分比 |
| Rate-Monotonic Analysis (RMA) | 速率单调分析 | 根据线程速率单调分配优先级并分析可调度性的方法 |
| Rate-Monotonic Scheduling (RMS) | 速率单调调度 | 基于 RMA 的静态优先级调度策略 |
| Monotonic function | 单调函数 | 保持或反转两个有序集合之间顺序的函数 |
| Schedulable | 可调度的 | 线程集合在给定调度策略下能全部满足截止时间 |
| Utilization bound | 利用率上限 | 保证可调度性的总 CPU 利用率上限 |
| Time slice | 时间片 | 轮转调度中分配给每个线程的 CPU 时间段 |
| Timesharing system | 分时系统 | 公平地在多个任务间共享 CPU 的系统设计 |
| System clock tick | 系统时钟节拍 | RTOS 中用于时间管理的周期性定时器中断 |
| Intrinsic function | 内联函数 | 编译器直接映射到特定硬件指令的函数 |
| Precondition | 前置条件 | 函数调用前必须满足的条件，由调用者负责 |
| SysTick | 系统节拍定时器 | ARM Cortex-M 处理器内置的定时器，常用于 RTOS 时钟 |
| Logic analyzer | 逻辑分析仪 | 用于捕获和显示数字信号时序的调试工具 |
