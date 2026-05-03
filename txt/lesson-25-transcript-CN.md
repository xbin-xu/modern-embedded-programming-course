# 第25课：高效线程阻塞 / Lesson 25: Efficient Thread Blocking

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this forth lesson on Real-Time Operating System (RTOS) I'll show you how to replace the horribly inefficient polling for events with efficient BLOCKING of threads. Specifically, in this lesson you will add a blocking delay function to the MiROS RTOS and you'll learn about some far-reaching implications of thread blocking on the RTOS design.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。在 RTOS 系列的第四课中，我来给你演示如何用高效的线程**阻塞**（blocking）替换掉极其低效的事件轮询（polling）。具体来说，这一课你会给 MiROS RTOS 加上一个阻塞式延迟函数，同时也会了解到线程阻塞对 RTOS 设计的一些深远影响。

As usual, let's get started by making a copy of the previous lesson 24 directory and renaming it to lesson 25.

照老规矩，先把上一课的 lesson-24 目录复制一份，改名为 lesson-25。

Get inside the new lesson 25 directory and double-click on the uVision project "lesson" to open it.

进入新的 lesson-25 目录，双击 uVision 项目文件"lesson"把它打开。

To remind you quickly what happened so far, in the last lesson you brought the MiROS RTOS to the stage, where it can run fully autonomously, performing simple round robing scheduling of your threads.

快速回顾一下之前的进展：上一课结束时，MiROS RTOS 已经能完全自主运行了，可以对线程做简单的**轮转调度**（round-robin scheduling）。

However, the threads still use a primitive polling inside the BSP_delay() function.

不过，线程在 `BSP_delay()` 函数里还在用原始的轮询方式。

The brain-dead polling inside BSP_delay() is a horribly inefficient waste of the CPU cycles that could be put to a better use somewhere else.

`BSP_delay()` 里那种死循环轮询简直是在暴殄天物——CPU 周期白白浪费了，本来这些周期可以在别的地方派上大用场。

But how could you eliminate this waste? Well, you now have a new tool in your toolbox, which is the context switch. With this tool, you could approach the delay() function completely differently.

那怎么才能消除这种浪费呢？好消息是，你的工具箱里多了一个新工具——**上下文切换**（context switch）。有了它，你就可以用完全不同的思路来实现 `delay()` 了。

Instead of starting a brain-dead polling loop, at the begin of the delay you could switch the context away from the delayed thread and then switch the context back to it at the end of the delay. In between these two context switches the thread will be very efficiently BLOCKED consuming no CPU cycles at all.

与其开一个死循环去轮询，不如在延迟开始时把上下文从当前线程切走，等延迟结束时再切回来。在这两次上下文切换之间，线程就进入了高效的**阻塞**状态，一个 CPU 周期都不消耗。

From the perspective of the thread, the blocking delay will be no different whatsoever from the polling delay. Either way, the thread will simply call a delay() function, which will not return until the delay elapses.

从线程的角度看，阻塞延迟跟轮询延迟没有任何区别。不管用哪种方式，线程都是调用一个 `delay()` 函数，在延迟到期之前不会返回。

But from the perspective of a system as a whole, this would make all the difference, because now the CPU cycles between the two context switches will be available to other threads that actually have something to do.

但从整个系统的角度看，差别就大了——两次上下文切换之间的那些 CPU 周期，现在可以让给其他真正有事可做的线程去用。

From the description so far, it should be clear that such a blocking delay implementation must become a part of the RTOS, because you need the scheduler and the context switch. As a part of the RTOS then, the blocking delay operation will be called the OS_delay() function.

说到这里你应该明白了，阻塞延迟的实现必须放在 RTOS 里，因为要用到**调度器**（scheduler）和上下文切换。所以，作为 RTOS 的一部分，这个阻塞延迟操作就叫 `OS_delay()` 函数。

At this point I'd like to call your attention to an interesting and important trend, which is migration of functionality, such as delay() in this case, from the application to the system-level software, where it can be handled much more efficiently. You will encounter this trend repeatedly as you learn about more advanced software techniques that I'll cover in the future lessons.

这里我想提醒你注意一个有趣且重要的趋势——功能迁移。比如这里的 `delay()`，从应用层移到系统级软件中，就能处理得高效得多。随着后面课程中介绍越来越高级的软件技术，你会发现这个趋势会反复出现。

But before jumping into the implementation of the OS_delay() function, you need to realize one important property of a blocked thread.

不过在动手实现 `OS_delay()` 之前，你得先搞清楚被阻塞线程的一个关键属性。

To see this better, you need to use a timing diagram with all context switches that are happening, but which I have omitted for simplicity so far.

要看清这一点，需要借助**时序图**（timing diagram），把所有上下文切换都画出来。之前为了简化我一直没画，现在是时候了。

As you can see, a thread running a polling BSP_delay() function participates in the round-robin scheduling, meaning that sometimes the thread is scheduled in and sometimes it is scheduled out.

如你所见，运行轮询式 `BSP_delay()` 的线程仍然参与轮转调度——有时被调度进来，有时被调度出去。

In contrast, a thread that is in the Blocked state should never be scheduled-in. It simply is NOT READY to run. This means that your RTOS threads have a new property, which tells the scheduler whether a thread is READY or not READY to run.

而处于**阻塞状态**（blocked state）的线程，绝对不应该被调度进来——它根本没有**就绪**（ready）运行。这意味着 RTOS 线程多了一个新属性，用来告诉调度器这个线程到底是就绪还是未就绪。

One other way to visualize this property graphically is through a state diagram. I will introduce state diagrams more formally in the future lessons about state machines, but today I just want to show you a diagram depicting the life cycle of a thread.

另一种可视化这个属性的方式是**状态图**（state diagram）。以后讲状态机的时候我会更正式地介绍状态图，今天先给你看一个描述线程生命周期的图。

When a thread is first created, meaning that you allocated the OSThread object and the stack for it, it becomes Dormant, shown here as a rounded-corner rectangle. In this state, it cannot do anything until you have called the QSThread_start() function on it.

线程刚创建的时候——也就是你给它分配了 `OSThread` 对象和栈——它处于**休眠状态**（dormant），图中用圆角矩形表示。在这个状态下它什么都做不了，直到你调用 `OSThread_start()` 来启动它。

After that call, a thread looks exactly as though it was preempted by an interrupt, so it transitions to the stage of its life cycle shown as Preempted.

启动之后，线程看起来就跟被中断抢占过一样，于是它进入生命周期中的**被抢占**（preempted）阶段。

Finally, when the thread is scheduled for running, it transitions to the Running state. After a while, the thread gets scheduled out and another thread gets scheduled in, at which point the original thread becomes Preempted again.

接下来，当线程被调度运行时，就进入**运行状态**（running）。过一会儿它被调度出去，另一个线程被调度进来，原来的线程就又回到了被抢占状态。

Please note that in the single CPU system exactly one thread can be in the Running state at a time, which is shown here as a circle with number 1 in it.

注意，在单 CPU 系统中，同一时刻只能有一个线程处于运行状态，图上用带数字 1 的圆圈来标注。

But now, a Running thread can call the OS_delay() function, at which time it becomes Blocked, meaning NOT Ready to run.

而现在，运行中的线程可以调用 `OS_delay()` 函数，这时它就进入阻塞状态——也就是未就绪运行。

Now, let's think for a minute about the transition out of the Blocked state, which must happen at the end of the delay. This needs to be managed centrally for all threads by the RTOS, obviously, because a Blocked thread cannot do anything, and in particular, it cannot un-block itself.

那么来想想：从阻塞状态出来的转换——也就是延迟结束时——该怎么做？显然，这需要 RTOS 集中管理所有线程，因为被阻塞的线程什么都做不了，更不可能自己解除阻塞。

This central RTOS service will need to be activated periodically, typically from the system clock tick interrupt, and therefore will be called OS_tick(). Upon every activation, OS_tick() needs to update all delays of the individual threads, and needs to un-block the threads, whose delays have elapsed.

这个 RTOS 中央服务需要被周期性地激活，通常是由**系统时钟节拍中断**（system clock tick interrupt）来触发，所以叫它 `OS_tick()`。每次被激活时，`OS_tick()` 要更新每个线程的延迟计数，然后把延迟到期的线程解除阻塞。

An interesting observation now is that if a thread is NOT Ready in the Blocked state, it must be Ready in the Preempted and Running states. This can be shown graphically, by means of the Ready "super"-state encompassing those two states. And indeed, while in the Ready super-state, which means either in Preempted or Running, the thread is ready and willing to run. Except sometimes it needs to be Preempted to share the CPU with the other threads that are also ready and willing to run.

一个有趣的观察是：如果线程在阻塞状态下未就绪，那它在被抢占和运行状态下就一定是就绪的。这可以用一个**就绪"超"状态**（ready super-state）来表示，把这两个状态包在里面。确实，只要线程处于就绪超状态——不管是在被抢占还是运行——它都是就绪且愿意运行的。只不过有时需要被抢占一下，好把 CPU 让给其他同样就绪且愿意运行的线程。

The Not-Ready-To-Run property of the new Blocked state in the thread life cycle has also another interesting consequence. And that is, that a system of blocking threads is incomplete and necessarily requires one special thread that is always ready to run and cannot block.

线程生命周期中阻塞状态的"未就绪"属性，还会带来另一个有趣的后果：一个由可阻塞线程组成的系统是不完整的，必然需要一个始终就绪运行、且不能阻塞的特殊线程。

To see this, consider a system with two threads, like your Blinky1 and Blinky2. As long as both of them are in the Ready super-state, the scheduler can run one or the other.

为什么这么说？想想你的系统里有两个线程——Blinky1 和 Blinky2。只要它们都在就绪超状态里，调度器就能在两者之间来回调度。

When one of the threads goes to the Blocked state, the scheduler can still run the other thread.

其中一个进入阻塞状态了，没问题，调度器还能跑另一个。

But what if both threads become Blocked at some time? The CPU still must be running exactly one thread at a time, but none of the existing ones are Ready.

但如果某个时刻两个线程都阻塞了呢？CPU 还是得跑一个线程才行，但现在没有一个线程是就绪的。

The solution is to add another special thread, which the scheduler can run when no other threads are Ready. This situation in the system is called the "idle" condition and therefore the special thread is called the "idle" thread. This "idle" thread is not allowed to block, so its life cycle does not have the Blocked state.

解决方案就是再加一个特殊线程——调度器在没有其他就绪线程时就去跑它。系统的这种状况叫**空闲条件**（idle condition），这个特殊线程就叫**空闲线程**（idle thread）。空闲线程不允许阻塞，所以它的生命周期里没有阻塞状态。

So, as you can see, thread blocking has surprisingly many consequences, all of which you need to carefully consider in your implementation.

你看，线程阻塞带来的连锁反应还真不少，实现的时候都得仔细考虑。

Going back to the code, then, let's start with creating the idle thread.

回到代码，先来创建空闲线程。

At first, the idle thread will be created exactly as any other thread and only later you will add protections against it ever going into the Blocked state.

一开始，空闲线程的创建方式跟其他线程完全一样，后面再加保护措施防止它进入阻塞状态。

So let's just go to main.c and copy the boilerplate code for one of your blinky threads. After pasting it into miros.c rename blinky1 to idleThread.

先到 `main.c` 里，复制某个 blinky 线程的模板代码。粘贴到 `miros.c` 之后，把 `blinky1` 改名为 `idleThread`。

The thread routine for the idleThread will still have the endless "superloop" structure, but it will simply invoke a callback function OS_onIdle(), where the application-level code will be able to perform some processing.

空闲线程的线程函数仍然是那种无尽的超级循环（superloop）结构，不过它只做一件事：调用回调函数 `OS_onIdle()`，让应用层代码有机会在这里做一些处理。

Just like any other thread, the idle thread needs to be started. The most convenient place for this is OS_init().

跟其他线程一样，空闲线程也需要启动。最方便的位置是在 `OS_init()` 里。

Now, the interesting part is how to supply the stack for the idle thread. One option is to pre-allocate it in the RTOS, but at this level you don't know how much stack would be used by the OS_onIdle() callback.

有意思的问题来了：空闲线程的栈怎么分配？一种办法是在 RTOS 里预分配，但在这个层面你不知道 `OS_onIdle()` 回调会用多少栈空间。

Therefore, it is better to simply defer the idle stack allocation to the application, just as it is done in the OSThread_start() function. So now, you need to update the OS_init() signature in the miros.h header file, where you also need to add the OS_onIdle() callback prototype.

所以更好的做法是把栈分配推迟到应用层，就像 `OSThread_start()` 那样。这样一来，你需要更新 `miros.h` 头文件中 `OS_init()` 的函数签名，同时加上 `OS_onIdle()` 回调的声明。

When you try to build the project now, you get errors as the RTOS API has changed.

现在尝试构建项目，会报错——因为 RTOS 的 API 改了。

The fix the problems, you need to add the stack for the idle thread to the OS_init() call in main.c.

要修复这些错误，你需要在 `main.c` 的 `OS_init()` 调用中加上空闲线程的栈。

And you also need to define the OS_onIdle() callback in bsp.c. At first, let's just make the idle callback do nothing so that the project links correctly.

然后在 `bsp.c` 中定义 `OS_onIdle()` 回调。先让它什么都不做，保证项目能正确链接就行。

Moving on to implementing the centralized thread delay management, you need to augment the OSThread object by adding a private timeout counter to each thread. These timeout counters will work as follows: The OS_delay() function will start with loading the timeout counter with the number of clock ticks.

接下来实现集中式线程延迟管理。你需要给每个线程加一个私有的**超时计数器**（timeout counter）。工作方式是这样的：`OS_delay()` 函数先把超时计数器设为需要的时钟节拍数。

Subsequently, every clock tick will call the OS_tick() function, which will decrement all non-zero timeout counters. When any of these down-counter reaches zero, the corresponding thread will be un-blocked and scheduled.

之后，每个时钟节拍都会调用 `OS_tick()` 函数，把所有非零的超时计数器减一。当某个递减计数器到零时，对应的线程就被解除阻塞，加入调度。

As you can see, having a separate timeout counter in each thread will allow the delays to run in parallel and independently from each other. Of course, OS_tick() will run all the time, but all timeout counters that are already zero will be simply left alone.

可以看到，每个线程有独立的超时计数器，各个延迟就能并行、独立地运行。当然，`OS_tick()` 会一直执行，但已经为零的计数器就直接跳过不管了。

The next new attribute of a thread is a boolean flag, which will be 'true' when the thread is Ready and 'false' when it is NOT Ready to run. Putting such a flag in each thread object would be a logical thing to do, but it turns out that it is not optimal for the efficiency of the code.

线程还需要一个新属性——一个布尔标志：线程就绪时为 `true`，未就绪时为 `false`。直接在每个线程对象里放一个标志看似合理，但实际上对代码效率来说并不是最优方案。

Instead, it turns out that it is more efficient to group the ready-to-run flags together in a 32-bit bitmask OS_readySet. This OS_readySet bitmask will work together with the OS_thread[] array as follows: Each individual bit in the OS_readySet bitmask corresponds to a thread in the OS_thread[] array, with the idle Thread skipped, because it is always Ready to run.

更好的做法是把所有就绪标志集中到一个 32 位的**位掩码**（bitmask）`OS_readySet` 中。它跟 `OS_thread[]` 数组配合使用，规则如下：`OS_readySet` 中的每一位对应 `OS_thread[]` 中的一个线程，空闲线程跳过不算，因为它永远就绪。

The idle thread is always at index zero, because it has been started from OS_init(), which ensures that it is the very first thread in the OS_thread[] array. Therefore, skipping the index zero means that the bits in OS_readySet are simply shifted by one with respect to indexes into the OS_thread[] array.

空闲线程永远在索引 0 的位置，因为它是从 `OS_init()` 中启动的，保证是 `OS_thread[]` 数组里的第一个线程。所以跳过索引 0 意味着 `OS_readySet` 中的位跟 `OS_thread[]` 数组索引之间有一个偏移。

For example, a thread at index 1 corresponds to bit 0, thread at index 2 to bit 1, a thread at index n corresponds to bit n-1 and finally the last thread at index 32 corresponds to the last bit number 31 in the OS_readySet bitmask.

比如，索引 1 的线程对应位 0，索引 2 的线程对应位 1，索引 n 的线程对应位 n-1，索引 32 的最后一个线程对应 `OS_readySet` 的最高位——第 31 位。

The various values of the OS_readySet bitmask correspond to the following situations: bits 0,1 and n-1 set, mean that threads 1,2, and n are ready to run. Only bit 1 set represents thread 2 ready to run. And finally, all bits at zero represent the Idle Condition of the system. This situation can be checked in the code very efficiently by simply comparing OS_readySet to zero in a single instruction.

`OS_readySet` 位掩码的各种取值对应不同情况：位 0、1、n-1 被置位，表示线程 1、2、n 都就绪；只有位 1 被置位，表示只有线程 2 就绪；所有位都为零，表示系统处于空闲条件。最后这种情况在代码里检查起来特别高效——一条指令就能搞定，直接把 `OS_readySet` 跟零比较就行。

The other benefits of grouping the ready-to-run flags together in one bitmask will become clear in the next lesson, where you will implement priority-based scheduling.

把就绪标志集中到一个位掩码里的其他好处，下一课就会显现——到时候你要实现基于优先级的调度。

In that case the bit numbers in OS_readySet will represent thread priorities.

到时候 `OS_readySet` 中的位号就直接代表线程优先级了。

But for now, you are still working with round-robin scheduling, where there is no notion of thread priority.

不过现在你还在用轮转调度，没有线程优先级这个概念。

Going back to code, let's now modify the scheduler so that it will avoid scheduling threads that are NOT ready to run.

回到代码，现在来修改调度器，让它跳过未就绪的线程。

First, you quickly check for the idle condition by comparing OS_readySet to zero, in which case you set OS_currIdx to the index of the idle thread, that is to zero. As you will see later, this will the most frequent path through the code.

先快速检查空闲条件——把 `OS_readySet` 跟零比较，如果是零就把 `OS_currIdx` 设为空闲线程的索引，也就是 0。后面你会看到，这是代码中最常见的执行路径。

Otherwise, if OS_readySet is not zero, you have some ready-to-run threads. But now you cannot simply choose the next thread index, because the thread might not be ready to run.

否则，如果 `OS_readySet` 不为零，说明有就绪的线程。但现在你不能直接取下一个索引，因为那个线程可能没就绪。

Instead, you need to keep going in a round-robing fashion until you find a non-idle thread that IS ready to run.

所以得用轮转的方式一个一个找，直到找到一个确实就绪的非空闲线程。

As shown in this diagram, to check if thread-N is ready to run, you need to synthesize a bitmask that has only N-minus-oneth bit set and you need to bitwise-AND it with OS_readySet. If the result is zero, you need to keep going, because it means that the bit is not set so the corresponding thread is NOT ready to run.

如图所示，要检查线程 N 是否就绪，你需要构造一个只有第 N-1 位置位的位掩码，然后跟 `OS_readySet` 做**按位与**（bitwise-AND）运算。结果为零就说明该位没置位，对应线程未就绪，得继续找。

Also, you need to be careful to exclude the idle thread from the round-robin scheduling, by skipping the index 0.

另外，别忘了把空闲线程排除在轮转调度之外——跳过索引 0 就行。

So, here is the final algorithm. You advance the OS_currIdx in round-robin fashion, but you skip the idle thread by wrapping around to 1 instead of zero. You keep going as long as the OS_readySet indicates that the thread is NOT ready to run.

所以最终算法是这样的：以轮转方式推进 `OS_currIdx`，回绕时绕到 1 而不是 0，从而跳过空闲线程。只要 `OS_readySet` 表明当前线程未就绪，就继续往下找。

Now, you are finally in position to tackle the most interesting new service of your RTOS, which is the blocking OS_delay() function. The signature of the function will be identical as the polling BSP_delay().

好了，终于可以动手实现 RTOS 最有趣的新服务了——阻塞式 `OS_delay()`。函数签名跟轮询式的 `BSP_delay()` 一模一样。

Inside OS_delay(), you need to disable interrupts, and store the tick count in the current thread's timeout counter.

在 `OS_delay()` 内部，先禁用中断，然后把节拍数存入当前线程的超时计数器。

Next, you need to make the thread NOT ready to run by clearing the corresponding bit in the OS_readySet bitmask.

接着，把 `OS_readySet` 位掩码中对应的位清零，让线程变为未就绪。

And finally, you need to call the scheduler to immediately switch the context away from this thread, so that it can become Blocked.

最后，调用调度器，立即把上下文从当前线程切走，让它进入阻塞状态。

As you remember from the previous lessons, OS_sched() is designed to be called with interrupts disabled and the context switch happens right after the interrupts are re-enabled.

前面的课程讲过，`OS_sched()` 设计为在禁用中断时调用，上下文切换发生在中断重新启用之后的那一刻。

The last touch in the OS_delay() implementation is to forbid calling it from the idle thread, because it should never go to the Blocked state.

`OS_delay()` 实现的最后一步：禁止从空闲线程调用它，因为空闲线程永远不能进入阻塞状态。

You can accomplish this by adding an assertion that the current thread is NOT the idle thread at index 0.

加一个**断言**（assertion）就行，断言当前线程不是索引 0 处的空闲线程。

This specific assertion type is called pre-condition, because it introduces a specific requirement that must be met before calling this service. To make this intent clear, the quassert.h header file provides a specific macro named Q_REQUIRE(), which works exactly like Q_ASSERT(), except its name conveys the intent much more precisely.

这种断言叫做**前置条件**（pre-condition），因为它规定了调用这个服务之前必须满足的要求。为了清楚表达这个意图，`quassert.h` 头文件专门提供了 `Q_REQUIRE()` 宏——它跟 `Q_ASSERT()` 工作方式完全一样，只是名字更能传达"前置条件"的含义。

To quickly summarize the status so far, you have implemented the idle thread and you have added the Blocked state to the thread's lifecycle. You have also just implemented the transition to the Blocked state. This transition is unique in that it is the only one in the thread's lifecycle that is taken voluntarily by the Running thread itself. All other transitions are forced on the thread without necessarily its cooperation or consent.

快速总结一下目前的进展：空闲线程已经实现了，线程生命周期中也加上了阻塞状态，而且你刚刚实现了进入阻塞状态的转换。这个转换很特殊——它是线程生命周期中唯一由运行线程自己主动发起的转换。其他所有转换都是外部强加的，线程不一定知情或配合。

This includes the last transition you still need to implement, which is the OS_tick() service that would take a thread out of the Blocked state.

其中就包括你还需要实现的最后一个转换——`OS_tick()` 服务，它负责把线程从阻塞状态中拉出来。

The implementation of OS_tick() needs to loop over all threads, except the idle thread obviously, and decrement all non-zero timeout counters. The threads corresponding to counters that just become zero need to be un-blocked.

`OS_tick()` 的实现需要遍历所有线程（空闲线程显然除外），把所有非零超时计数器减一。计数器刚变成零的那些线程需要被解除阻塞。

The code of OS_tick() will therefore consist of a for-loop over all threads, starting with index 1 to skip the idle thread. Inside the loop you first need to check the timeout counter of the corresponding thread,

所以 `OS_tick()` 的代码就是一个遍历所有线程的 for 循环，从索引 1 开始以跳过空闲线程。循环体内先检查对应线程的超时计数器，

and if it is not zero, you need to decrement it.

不为零就减一。

If the counter is becoming zero, you need to make the thread ready-to-run by setting the corresponding bit in the OS_readySet bitmask.

如果减到零了，就把 `OS_readySet` 位掩码中对应的位置位，让线程变为就绪。

Please note that this implementation assumes that OS_tick() will be called from a single Interrupt Service Routine, such as SysTick_Handler(). In that case, you don't need to disable interrupts inside OS_tick(), because an ISR cannot be preempted by a thread, so any unexpected changing of the timeout counters, which can happen only in OS_delay(), is not possible.

请注意，这个实现有一个前提：`OS_tick()` 只从一个**中断服务例程**（ISR）中调用，比如 `SysTick_Handler()`。这种情况下不需要在 `OS_tick()` 里禁用中断，因为 ISR 不会被线程抢占，超时计数器只会在 `OS_delay()` 中被修改，但在 ISR 执行期间这不可能发生。

Also, it is not necessary to call OS_sched() from OS_tick(), because the scheduler is called at the end of SysTick_Handler anyway to schedule any un-blocked threads.

同样，也不需要在 `OS_tick()` 里调用 `OS_sched()`，因为 `SysTick_Handler()` 结束时本来就会调用调度器来调度刚解除阻塞的线程。

The implementation of the blocking delay is almost ready now, but you still need to make some final adjustments.

阻塞延迟的实现基本差不多了，还有几处最后的调整。

First, any started thread, except the idle thread, needs to be explicitly made Ready-to-run by setting the corresponding bit in the OS_readySet bitmask.

第一，每个启动的线程（空闲线程除外）都需要显式地在 `OS_readySet` 位掩码中置位，标记为就绪。

This corresponds to the transition into the Ready super-state in the thread's life-cycle.

这对应线程生命周期中进入就绪超状态的转换。

Second, you should increment the MiROS RTOS version number to lesson 25 both in the miros.c and in miros.h.

第二，把 MiROS RTOS 的版本号更新到 lesson 25，`miros.c` 和 `miros.h` 都要改。

And third, in miros.h, you need to add the prototypes for the newly added services: OS_delay() and OS_tick().

第三，在 `miros.h` 中加上新服务的函数声明：`OS_delay()` 和 `OS_tick()`。

And finally, you need to actually use the new OS_delay() and OS_tick() instead of the previous polling BSP_delay() and BSP_tickCtr().

最后，把代码中原来的轮询式 `BSP_delay()` 和 `BSP_tickCtr()` 替换成新的 `OS_delay()` 和 `OS_tick()`。

The code builds cleanly, so now I understand that you are quite keen to see how it works.

代码编译通过了，我知道你已经迫不及待想看效果了。

Let's then open the debugger and at first run the code free. What do you know, the code appears to be blinking all LEDs exactly as before.

打开调试器，先让它自由运行。你猜怎么着——所有 LED 闪烁得跟以前一模一样。

But now, it really works quite differently. When you break into the code, you find it in the OS_idle() callback.

但背后的工作方式已经完全不同了。暂停代码执行，你会发现程序停在 `OS_idle()` 回调里。

Indeed, when you set a breakpoint in the scheduler, you can see that the OS_readySet bitmask is zero, so the scheduler picks the idle thread. All this means that most of the time all threads are blocked, so the system spends most of its time in the idle condition.

没错，在调度器里设个断点就能看到，`OS_readySet` 位掩码为零，调度器选的是空闲线程。也就是说，大部分时间所有线程都在阻塞，系统大部分时间都处于空闲条件。

Only occasionally, a thread gets unblocked and scheduled to run.

只有偶尔，某个线程被解除阻塞、调度运行一下。

All right, as you can see the idle thread has become quite important, because the CPU spends most of its time there. So, let's study it a bit more.

可以看到，空闲线程变得相当重要了——CPU 大部分时间都在它那里度过。我们来深入研究一下。

Specifically, let's put some code into the OS_onIdle() callback. I'll use the technique from the previous lesson to toggle a pin up and down from the OS_onIdle() callback, so that this activity could be observed with a logic analyzer.

具体来说，我们在 `OS_onIdle()` 回调里放点代码。我用上一课的技术，在 `OS_onIdle()` 回调里来回翻转一个引脚，这样用**逻辑分析仪**（logic analyzer）就能观察到空闲线程的活动。

As I'm running out of pins, I will reuse the RED LED from the Blinky3 thread.

引脚不够用了，我就复用 Blinky3 线程的红色 LED。

To avoid any conflicts around the RED LED, I will simply comment out starting of the Blinky3 thread in main.c, so that this thread will stay in the Dormant state.

为了避免红色 LED 冲突，我直接把 `main.c` 中启动 Blinky3 线程的代码注释掉，让它一直留在休眠状态。

When I build and load the code to the board now, the Blue and Green LEDs blink as before, but the Red LED only glows at a low intensity.

构建并烧录到板子上之后，蓝色和绿色 LED 跟以前一样闪烁，但红色 LED 只是微微发光。

Now, let's connect logic analyzer signals D1 through D4 to pins PF1 through PF4, respectively.

现在把逻辑分析仪的信号 D1 到 D4 分别接到引脚 PF1 到 PF4 上。

As you can see in the logic analyzer view, the signal D1, corresponding to the RED LED keeps toggling rapidly, which means that the OS_onIdle() callback is constantly called. The signals for the Green and Blue LEDs change very slowly in comparison. The signal D4, which is switched in the SysTick ISR, is used here as the trigger.

在逻辑分析仪视图中可以看到，对应红色 LED 的信号 D1 在快速翻转，说明 `OS_onIdle()` 回调在不断被调用。相比之下，绿色和蓝色 LED 的信号变化就慢多了。信号 D4 是在 SysTick ISR 中翻转的，这里用作触发信号。

Most of the time the SysTick ISR takes about 3 microseconds, but occasionally it gets significantly longer.

大多数时候 SysTick ISR 大约耗时 3 微秒，但偶尔会明显变长。

To investigate this behavior, let's look through the accumulated traces.

来研究一下这个现象——看看累积的波形数据。

Indeed, here is an instance where SysTick gets longer. Interestingly, at the same time the Green LED changes from low to high and the idle thread activity gets delayed by over 5 microseconds.

果然，这里有一个 SysTick 变长的实例。有意思的是，与此同时绿色 LED 从低电平变高，空闲线程的活动被延迟了超过 5 微秒。

The explanation is quite simple. Most of the time, SysTick simply updates the timeout counters, but does not switch the context from the idle thread. You can see this directly from the idle thread activity before and after the SysTick.

解释很简单。大多数时候，SysTick 只是更新超时计数器，不会从空闲线程切走上下文。你可以从 SysTick 前后的空闲线程活动中直接看出这一点。

Only occasionally, a thread other than idle gets unblocked and scheduled. After the SysTick, the unblocked thread runs and does its thing, such as toggling an LED in this case. After this, the thread calls OS_delay() and voluntarily relinquishes the CPU, which switches back to the idle thread.

只有偶尔，某个非空闲线程被解除阻塞并得到调度。SysTick 之后，被解除阻塞的线程运行，做它该做的事——比如翻转 LED。做完之后，线程调用 `OS_delay()` 主动让出 CPU，上下文就切回空闲线程了。

Now, regarding the actual timing, the longest SysTick takes about 4.5 microseconds, which is three times longer than before blocking was introduced. This increased overhead is caused by more complex OS_tick() and OS_sched() implementations.

来看具体的时间数据：最长的 SysTick 大约 4.5 微秒，是引入阻塞之前的三倍。开销增加是因为 `OS_tick()` 和 `OS_sched()` 的实现变得更复杂了。

On the other hand, the context switch time remains about the same, below 2 microseconds.

另一方面，上下文切换时间基本没变，还是不到 2 微秒。

The tread blocking in OS_delay(), which involves marking the thread as NOT ready and scheduling another thread takes about 3.8 microseconds.

`OS_delay()` 中的线程阻塞——包括标记线程为未就绪和调度另一个线程——大约耗时 3.8 微秒。

Finally, the longest time spend outside the idle thread is only 10 microseconds. In most other cases this time is even shorter.

最后，空闲线程之外最长的一次执行也不过 10 微秒，大多数情况下甚至更短。

With all this, I hope to have convinced you that indeed the CPU spends almost all of its time in the idle thread, except for a few microseconds here and there to execute all other threads.

说了这么多，我希望已经让你信服：CPU 确实几乎所有时间都在空闲线程里度过，只有零星几微秒跑一跑其他线程。

But the idle tread still basically wastes all the CPU cycles it gets. So the question is what can you do about it.

但空闲线程拿到这些 CPU 周期基本还是浪费了。问题是，能拿它做点什么？

Well, the best thing you can do is to put the CPU and its peripherals to a low-power sleep mode. Indeed, you will never achieve a truly low-power design with the CPU and peripherals running at full speed. So, for battery-operated applications you have to use sleep modes.

最好的办法就是把 CPU 和外设进入**低功耗睡眠模式**（low-power sleep mode）。说真的，CPU 和外设全速运行的话，永远做不出真正的低功耗设计。所以电池供电的应用，必须用睡眠模式。

The full discussion of the subject of low-power design goes far beyond the scope of this lesson, but the most important takeaway for you today is that the idle thread, and specifically the OS_onIdle() callback is the ideal, central place in the code to put the CPU and peripherals to a low-power sleep mode.

低功耗设计这个话题远超本课范围，但今天最需要记住的一点是：空闲线程——特别是 `OS_onIdle()` 回调——是把 CPU 和外设进入低功耗睡眠模式的理想位置，而且是集中的、统一的管理点。

To this end, the ARM Cortex-M CPU provides a special instruction, called WFI (Wait-For-Interrupt) that shuts down the CPU clock until an interrupt occurs. You can put it in your OS_onIdle() callback using __WFI() CMSIS function and see what happens.

ARM Cortex-M CPU 为此提供了一条专门指令，叫 **WFI**（Wait-For-Interrupt，等待中断），它会关掉 CPU 时钟，直到有中断到来。你可以通过 CMSIS 函数 `__WFI()` 把它放到 `OS_onIdle()` 回调里，看看效果。

When you load this code to the board, you can see that the Green and Blue LEDs blink exactly as before, but the Red LED seems not active at all.

烧录到板子上之后，绿色和蓝色 LED 闪烁如常，但红色 LED 看起来完全不亮了。

The situation becomes clearer in the logic analyzer, where you can see that the Red LED actually toggles, but very infrequently. In fact, it toggles exactly once after each interrupt.

逻辑分析仪上看就清楚了——红色 LED 其实还是在翻转的，只是频率很低。准确地说，每次中断之后翻转一次。

This is because now, the CPU gets stopped inside each call to OS_onIdle(), and is only waken up by the next SysTick interrupt.

因为现在每次调用 `OS_onIdle()` 时 CPU 就停了，直到下一个 SysTick 中断到来才被唤醒。

This concludes this lesson about efficient thread blocking and its profound implications.

以上就是关于高效线程阻塞及其深远影响的全部内容。

At this point, your MiROS RTOS implements a round-robin timesharing scheduler with blocking, which corresponds to the state of the art of computer systems in the early 1960's.

到这里，你的 MiROS RTOS 已经实现了一个带阻塞的轮转分时调度器——大概相当于 1960 年代初计算机系统的技术水平。

Here is an introduction of the time-sharing system at MIT in the year 1963.

这是 1963 年麻省理工学院分时系统的介绍。

In the next lesson you'll bring the MiROS RTOS into the 1970's by implementing the preemptive priority-based scheduling.

下一课，你要实现抢占式优先级调度，把 MiROS RTOS 带进 1970 年代。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅以获取最新内容。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Blocking | 阻塞 | 线程暂停执行、不消耗 CPU 周期的状态，等待某个条件满足后恢复 |
| Polling | 轮询 | 通过不断检查条件是否满足来等待事件的低效方式 |
| Round-Robin Scheduling | 轮转调度 | 以循环方式依次给每个就绪线程分配 CPU 时间的调度策略 |
| Context Switch | 上下文切换 | 保存当前线程状态并恢复另一个线程状态的过程 |
| Scheduler | 调度器 | RTOS 中负责决定哪个线程接下来运行的组件 |
| Thread Life Cycle | 线程生命周期 | 线程从创建到结束经历的各种状态（休眠、被抢占、运行、阻塞） |
| Dormant State | 休眠状态 | 线程已创建但尚未启动的状态 |
| Preempted State | 被抢占状态 | 线程曾运行但因调度器切换到其他线程而暂停的状态 |
| Running State | 运行状态 | 线程当前正在 CPU 上执行的状态 |
| Blocked State | 阻塞状态 | 线程等待某个条件（如延迟到期）而暂停执行的状态 |
| Ready (Super-)State | 就绪（超）状态 | 包含运行状态和被抢占状态的复合状态，表示线程愿意且可以运行 |
| Idle Thread | 空闲线程 | 系统中始终就绪运行且不能阻塞的特殊线程，当无其他线程就绪时执行 |
| Idle Condition | 空闲条件 | 系统中所有非空闲线程都处于阻塞状态，只有空闲线程在运行的情况 |
| Timeout Counter | 超时计数器 | 每个线程中用于跟踪延迟剩余时间的倒计数器 |
| Bitmask (OS_readySet) | 位掩码 | 32 位整数中每一位表示对应线程是否就绪运行的数据结构 |
| System Clock Tick | 系统时钟节拍 | RTOS 中周期性的时间基准，用于驱动调度和超时管理 |
| ISR (Interrupt Service Routine) | 中断服务例程 | 响应硬件中断而执行的函数 |
| WFI (Wait-For-Interrupt) | 等待中断 | ARM Cortex-M 的低功耗指令，暂停 CPU 直到中断发生 |
| Low-Power Sleep Mode | 低功耗睡眠模式 | CPU 和外设降低功耗的运行模式 |
| Pre-condition | 前置条件 | 调用函数前必须满足的条件，通常用断言检查 |
| Assertion | 断言 | 在代码中检查假设是否成立的机制，失败时报告错误 |
| `OS_delay()` | `OS_delay()` 函数 | RTOS 提供的阻塞式延迟函数，使当前线程阻塞指定时钟节拍数 |
| `OS_tick()` | `OS_tick()` 函数 | RTOS 的时钟节拍服务，定期更新超时计数器并解除到期线程的阻塞 |
| `OS_onIdle()` | `OS_onIdle()` 回调 | 空闲线程中调用的回调函数，应用代码可在此执行处理或进入低功耗模式 |
