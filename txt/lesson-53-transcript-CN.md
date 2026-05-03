# 第53课：超级循环中的优先级调度器 / Lesson 53: Priority Scheduler for the "Superloop"

Hello and welcome to the Modern Embedded Systems Programming course. I'm Miro Samek, and in this lesson, I will explain how to generalize the simple non-preemptive scheduler that began to emerge in the last lesson for priority-based task execution inside the "superloop" architecture. The result will be a surprisingly capable, little real-time kernel with many practical applications.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这节课我来讲解如何把上一课初见雏形的简单**非抢占式调度器**（non-preemptive scheduler）进一步泛化，实现在"超级循环"（superloop）架构里按优先级执行任务。最终你会得到一个能力出人意料的小型**实时内核**（real-time kernel），在很多实际场景中都能派上用场。

Let me start today by making a copy of the last lesson and renaming it to lesson 53. I then enter that directory and the project for the TM4C TivaC LaunchPad board. Finally, I open the KEIL uVision project.

先来做准备工作——把上一课的工程复制一份，重命名为 lesson 53。然后进入对应的目录，找到 TM4C TivaC LaunchPad 开发板的项目，最后用 KEIL uVision 打开工程。

To summarize quickly what has happened so far, in the previous lesson, you adapted the "superloop" architecture to reliably detect when the system has nothing to do so the CPU can safely be put into a low-power sleep mode.

快速回顾一下之前的进展：在上一课中，你对"超级循环"架构做了改造，让它能可靠地检测系统什么时候没事可做，这样就可以放心地把 CPU 放进**低功耗睡眠模式**（low-power sleep mode）。

The central element of the design is the **ready_set** bitmask, where each bit represents a ready-to-run task. For example, bit 0 represents task 1, and bit 1 represents task 2.

整个设计的核心是一个叫 **ready_set** 的**位掩码**（bitmask），每一位代表一个就绪待运行的任务。比如第 0 位代表任务 1，第 1 位代表任务 2。

I will discuss the properties of these tasks at the end of this video, but first, let's focus on the mechanism of choosing which task to run next, which is called **scheduling**.

这些任务的具体特性我放到视频最后再讲。现在先来关注一个核心机制——怎么选择下一个该运行的任务。这个过程就叫做**调度**（scheduling）。

In the previous lesson, the two tasks were simply hard-coded, but the scheduling mechanism can be generalized for more tasks. For example, the 'ready_set' bitmask has 32 bits, so you could schedule up to that many tasks.

上一课里，两个任务还是简单硬编码的。但调度机制完全可以推广到更多任务。ready_set 位掩码有 32 位，也就是说理论上你最多能调度 32 个任务。

For this, you could add an array, called 'task_registry,' of 32 task handlers, each array entry corresponding to a bit in the 'ready_set' bitmask, as shown in the diagram.

为此，你可以加一个叫 `task_registry` 的数组，里面放 32 个任务处理函数，每个数组元素对应 ready_set 位掩码中的一个位，就像图中这样。

To make it compatible with the existing two tasks, you set the 'task_registry' of [0] to the BSP_deployAirbag handler and the 'task_registry' of [1] to the BSP_engageABS handler.

为了跟之前已有的两个任务保持兼容，你把 `task_registry[0]` 设为 BSP_deployAirbag 处理函数，`task_registry[1]` 设为 BSP_engageABS 处理函数。

Now, you can rewrite the scheduling algorithm in terms of the bit numbers and the 'task_registry' array. Of course, now you can continue beyond the first two bits for all 32 bits in the ready_set bitmask.

现在，你就可以根据位编号和 `task_registry` 数组来重写调度算法了。当然，现在可以不止检查前两位，而是遍历 ready_set 位掩码的全部 32 位。

Obviously, this code is very repetitious, and you'll deal with it next, but for now, let's just try to build and run this version.

很显然，这段代码重复太多了，等下会处理这个问题。现在先编译运行一下这个版本看看。

Well, let's see how this works...

好，来看看效果……

The first order of business is to run the code free and verify that it behaves as before.

首先要做的就是让代码自由跑起来，确认行为跟之前一致。

Pressing the B1 button lights up the Red LED, meaning "deploy airbag," and pressing the B2 button additionally lights up the Blue LED, meaning "engage ABS". So far, so good.

按下 B1 按钮，红色 LED 亮起，表示"部署安全气囊"；按下 B2 按钮，蓝色 LED 也亮起，表示"启动 ABS"。目前一切正常。

So let's now investigate a bit deeper what happens when both tasks are activated at the same time.

接下来咱们深入看看，当两个任务同时被激活时会发生什么。

Let's reset the target to start over and set a breakpoint at the top of the "superloop" and at the task execution.

先复位目标板从头开始，然后在"超级循环"的入口处和任务执行处各设一个**断点**（breakpoint）。

When you run the code, it immediately stops at the first breakpoint. Now, press button B1 to activate task-1 and also B2 to activate task-2.

运行代码，马上就在第一个断点处停下来了。现在同时按下 B1 激活任务 1，按下 B2 激活任务 2。

Only now you continue and hit the second breakpoint, where you can see that task-1 BSP_deployAirbag is about to execute. However, the ready_set bitmask still has a bit-1 set, meaning task-2 is also ready to run. Before continuing, press B1 again.

然后继续运行，命中第二个断点。可以看到任务 1 的 BSP_deployAirbag 即将被执行。但此时 ready_set 位掩码的第 1 位仍然置位，说明任务 2 也就绪了。在继续之前，再按一次 B1。

Only now you continue and hit the breakpoint at the top of the loop. Here, you can see that the ready_set has both bit-0 and bit-1 set, so both tasks are ready to run. When you continue, you can see that task-1 BSP_deployAirbag is about to execute, and so it runs. When you continue again, you see that task 2 eventually runs as well.

再继续运行，命中循环顶部的断点。可以看到 ready_set 的第 0 位和第 1 位都置位了，两个任务都已就绪。继续运行，任务 1 的 BSP_deployAirbag 先执行。再继续，任务 2 最终也执行了。

In summary, this scheduler has the following properties: **1. It always selects the lowest-order bit in the ready_set bitmask to execute next.** In other words, the bit number associated with a task becomes the task's **priority**. **2. Each pass through the superloop executes only one task**, allowing the scheduling decision to happen before every task.

总结一下，这个调度器有两个关键特性：**第一，它总是选择 ready_set 位掩码中编号最低的那一位对应的任务来执行。** 换句话说，任务关联的位编号就成了任务的**优先级**（priority）。**第二，每次经过超级循环只执行一个任务**，这样在下一次执行前就能重新做调度决策。

All this leads to a very different timing profile than the traditional "superloop" that executes multiple tasks in each pass. So, for comparison, here is the timing profile of a traditional "superloop."

这些特性让带调度器的超级循环在**时序特性**（timing profile）上跟传统超级循环截然不同。传统超级循环每次循环会执行多个任务。作为对比，这里展示了传统超级循环的时序特性。

Your adapted "superloop" with the scheduler prioritizes tasks much better because the highest-priority task that is ready to run always gets scheduled to run next and does not need to wait for the lower-priority tasks. The more tasks you add to the "superloop," the more dramatic the timing difference.

改造后的带调度器的超级循环在优先级处理上优势明显——最高优先级的就绪任务总是会被安排为下一个执行，不用等低优先级任务跑完。你往超级循环里加的任务越多，时序上的差距就越夸张。

Specifically, the most essential characteristic of a scheduler is its **task-level response**, which is the worst-case time from when the task becomes ready to run to the time when it actually starts running.

具体来说，衡量一个调度器最重要的指标是它的**任务级响应时间**（task-level response）——就是从任务变为就绪到它真正开始执行之间的最长等待时间。

The task-level response of your scheduler is the single longest run-to-completion step in the system.

你的调度器的任务级响应时间等于系统中最长的单个**运行至完成**（run-to-completion）步骤的耗时。

In contrast, the task-level response of the traditional "superloop" is the sum of all longest run-to-completion steps in the whole system, which is much longer.

相比之下，传统超级循环的任务级响应时间是整个系统中所有最长运行至完成步骤的耗时总和，那就长得多了。

So now, knowing that the bit numbers are priorities, you can replace the repetitious if-else decision tree with the following for-loop over all the task priorities.

既然位编号就是优先级，那你就可以用一个遍历所有任务优先级的 for 循环来替换那堆重复的 if-else 决策树。

You must also remember that the scheduler runs only one task per pass, so once you find the next task, you need to break out of the loop.

别忘了，调度器每次循环只执行一个任务。所以一旦找到了下一个要执行的任务，就得 break 跳出循环。

Now, you can delete the if-else decision tree because it has been rolled into the for-loop.

现在可以把那堆 if-else 决策树删掉了，因为逻辑已经整合到 for 循环里了。

However, you should keep the final assertion because it ensures the next task is found. The difference now is that you check that the loop didn't run till the end and was broken out of.

不过最后的**断言**（assertion）要保留，因为它确保确实找到了下一个任务。区别在于，现在你要检查的是循环是不是提前跳出的，而不是跑到了末尾。

At any such refactoring step, you should check that the code still runs, but I leave it for you as an exercise and move on.

每次做这样的**重构**（refactoring）之后，都应该验证代码是否仍然正常工作。这个就留给你自己练习了，我继续往下走。

Next, you should consider your scheduler's priority numbering scheme. At this point, the task priority is the bit number in the ready_set bitmask, and your scheduler checks the bits starting with bit 0. This means you're using the "upside down" priority numbering, where the priority 0 corresponds to the highest-priority task and higher numbers correspond to the lower-priority tasks. Such numbering has been used in the older RTOS kernels, such as uC/OS, embOS, and ThreadX, to name a few. But this "upside down" scheme is notoriously confusing and requires you to always qualify whether you mean the task urgency or its numerical priority.

接下来要考虑的是调度器的优先级编号方案。目前，任务优先级就是 ready_set 位掩码中的位编号，调度器从第 0 位开始检查。也就是说你用的是一种"倒过来"的编号——优先级 0 对应最高优先级的任务，数字越大反而优先级越低。这种方案在早期的 RTOS 内核中很常见，比如 uC/OS、embOS、ThreadX 等等。但这种"倒置"方案出了名的容易让人混淆，因为你每次都得费劲解释你说的是"紧急程度"还是"数值大小"。

However, this reverse logic has no advantage over direct, non-confusing priority numbering, where higher priority numbers correspond simply to higher task priorities. All you need to do is reverse the order of checking the bit numbers, but you must be careful with the priority index staying within the range of the task_registry array. Therefore, I will extend the task_registry by one entry and designate the first entry as the idle task at priority zero. Now, so as not to lose the lowest bit in the ready_set bitmask for regular tasks, the bit number will be priority minus 1.

其实这种反向逻辑相比直观不绕弯的编号方案没有任何优势。在直观方案里，优先级数字越大，任务优先级就越高，简单明了。你只需要把检查位编号的顺序反过来就行，但要注意优先级索引不能超出 task_registry 数组的范围。所以我把 task_registry 扩展一个元素，把第一个位置留给优先级为零的**空闲任务**（idle task）。这样一来，为了不占用 ready_set 位掩码中给常规任务用的最低位，位编号就是优先级减 1。

Finally, the assertion after the loop will check the priority for zero, meaning no regular task was found, which is an error.

最后，循环后面的断言会检查优先级是不是零——如果是零，说明没找到常规任务，那就是出错了。

But you're not entirely done because the reversal in task priority numbering also requires changing the bit numbers for the existing tasks. However, instead of bit numbers, it is now more convenient to deal with task priorities, which don't need to be consecutive. The only relevant consideration is that the task you wish to prioritize higher also has a higher priority relative to tasks that you wish to prioritize lower.

不过还没完事——优先级编号反过来之后，现有任务的位编号也得跟着改。但其实直接用优先级编号来操作更方便，而且优先级不需要连续。唯一的原则是：你想让哪个任务更紧急，它的优先级数字就得比不那么紧急的任务更高。

So, now you must consistently use the priority numbers in registering the tasks with the scheduler...

所以，现在在向调度器注册任务的时候，要统一使用优先级编号……

and also in setting the bit numbers, remembering that the bit number is offset by one from the task priority.

在设置位编号时也一样——记住位编号比任务优先级偏移了 1。

The last aspect you can significantly improve is the actual scheduling algorithm, which is a loop that runs longer, the lower the priority of the task to schedule. The problem is that the for-loop runs inside a **critical section**, so ideally, you would like this to be short and deterministic, meaning constant time.

还有一个地方可以大幅优化——就是调度算法本身。目前它是一个循环，要调度的任务优先级越低，循环转的圈数就越多。问题在于这个 for 循环运行在**临界区**（critical section）里，理想情况下你希望临界区尽量短、耗时确定，也就是常数时间。

If you watched earlier lessons in this course, you might remember that an identical issue came up in lesson 26 about the real-time operating system (RTOS). In that lesson, you saw that finding the highest-order bit in a bitmask boils down to counting the leading zeros preceding the 1-bit. This operation, called **CLZ**, is mathematically related to the LOG-base-2 function. As it turns out, the CLZ operation is supported in ARM Cortex-M3 and higher CPUs as a single instruction. Cortex-M0 does not support the CLZ instruction, but even there, the compiler generates a fairly efficient library implementation.

如果你看过之前的课程，可能记得第 26 课讲 RTOS 的时候遇到过完全一样的问题。那节课里你看到，在一个位掩码中找最高位的 1，本质上就是数这个 1 前面有多少个前导零。这个操作叫 **CLZ**（Count Leading Zeros），数学上跟以 2 为底的对数函数有关。ARM Cortex-M3 及以上的 CPU 用一条指令就能完成 CLZ 操作。Cortex-M0 虽然没有 CLZ 指令，但编译器也能生成相当高效的库实现。

This information lets you replace the whole loop with the beautifully efficient and deterministic expression based on the `__clz()` built-in function.

有了这个知识，你就可以用基于 `__clz()` 内建函数的简洁表达式来替换整个循环——既高效，耗时又确定。

The compilation fails because the `__clz()` built-in requires an additional include file, which is documented in the uVision help.

编译报错了，因为 `__clz()` 内建函数需要额外包含一个头文件，这在 uVision 的帮助文档里有说明。

Let's test this version on the board.

让我们在开发板上测试一下这个版本。

First, remove all breakpoints and run the code free to check that it still works.

先清除所有断点，让代码自由跑起来，看看功能是否还正常。

Button B1, red LED for airbag deployment.

按下 B1，红色 LED 亮起，表示安全气囊部署。

Now, button B2, additional blue LED for ABS engagement. So far, so good.

按下 B2，蓝色 LED 也亮起，表示 ABS 启动。目前一切正常。

Now, let's reset the target to start over. This time, set a breakpoint at the task priority computation because I'm sure you'd like to see the CLZ instruction.

现在复位目标板重新来。这次在任务优先级计算的地方设个断点，我知道你肯定想亲眼看看 CLZ 指令。

Run the code. Nothing happens because the CPU was put to sleep. But when you press a button, the system wakes up and hits your breakpoint. So now let's single-step in disassembly and here it is: the CLZ instruction.

运行代码，什么都没发生——因为 CPU 进了睡眠模式。但当你按下按钮，系统被唤醒并命中了断点。现在切换到反汇编视图单步执行，看到了吧——这就是 CLZ 指令。

Alright, so your scheduler is starting to take shape. But, at this point, I'd like to go back to the ST discussion referenced in the last lesson, 52, and the post by the ST expert who proposed this scheduler. Later in the same post, he recommended using the CLZ instruction for task selection. If you didn't immediately get what he meant, now you understand.

好，你的调度器逐渐成型了。不过说到这里，我想回到上一课（第 52 课）提到的那篇 ST 论坛讨论，以及那位提出这个调度器的 ST 专家的帖子。他在同一个帖子的后面建议用 CLZ 指令来做任务选择。如果你当时没马上理解他什么意思，现在应该明白了。

In the last few minutes of this lesson, let's step back and consider the bigger picture. The scheduler code in the main function has become generic, and except for the priority assignment, the specific tasks aren't hard-coded anymore.

这节课的最后几分钟，咱们退一步看看全貌。main 函数中的调度器代码已经变成了通用代码，除了优先级分配之外，具体的任务都不再硬编码了。

So, let's make this official and explicitly create a generic scheduler module by adding sched.c source file and sched.h header file to your project.

那就干脆正式一点，给项目添加 sched.c 源文件和 sched.h 头文件，把它做成一个独立的通用调度器模块。

Let's start with the sched.c source file and the main body of the scheduler, which is the whole superloop. This is already generic, so let's make it into a function called `sched_run()`.

先从 sched.c 源文件说起。调度器的主体就是整个超级循环——它已经是通用的了，所以把它封装成一个叫 `sched_run()` 的函数。

This function does not return.

这个函数不会返回。

Next, let's add the function `sched_start()` that will register a given task priority and associate it with a given handler function.

接下来添加 `sched_start()` 函数，用来注册指定的任务优先级，并把它跟对应的处理函数关联起来。

Now, you can use this scheduler API in your main code.

现在就可以在你的主代码中使用这套调度器 API 了。

The next scheduler API for the application use is for signaling the tasks, such as those used in the GPIO ISR. Let's call this function `sched_post()`.

下一个需要提供给应用程序的 API 是用来给任务发信号的，比如在 GPIO 中断服务程序中使用的那些。我们把函数叫做 `sched_post()`。

The function takes the task priority and sets the corresponding bit in the ready_set bitmask.

这个函数接收任务优先级作为参数，然后把 ready_set 位掩码中对应的位设为 1。

Currently, your application performs this operation only from an ISR, but in general, tasks should also be able to post other tasks. In that general case, the shared ready_set variable must be protected by a **critical section**.

目前你的程序只在中断服务程序里调用这个操作，但更一般的情况下，任务也应该能投递其他任务。这时候，共享的 ready_set 变量就必须用**临界区**来保护。

Now, you can apply this scheduler API in your BSP code.

现在你可以在 BSP 代码里用上这套调度器 API 了。

At this point, you can move the global task_registry array and hide it entirely inside the sched.c module.

这时候，你可以把全局的 task_registry 数组挪过来，完全隐藏在 sched.c 模块内部。

In fact, you can make it static to restrict its visibility to this module only.

事实上，你可以把它声明为 static，把可见性限制在本模块内。

Similarly, you can now take the global ready_set variable and also hide it completely inside the scheduler module. Encapsulating the critical variables is a significant benefit of the separate scheduler module.

同样地，全局的 ready_set 变量也可以完全隐藏在调度器模块内部。像这样**封装**（encapsulate）关键变量，是独立调度器模块的一大好处。

This would be the whole functionality of your scheduler for now, so let's copy it and turn it into prototypes in your sched.h header file.

这就是调度器目前的全部功能了。接下来把这些函数复制到 sched.h 头文件里，转换成函数**原型**（prototype）声明。

In addition to the API prototypes, your header file also needs the definition of the task handler pointer to function.

除了 API 原型之外，头文件里还需要定义任务处理函数的函数指针类型。

And of course, since this is a header file, you must not forget to add the usual inclusion guards.

当然，既然是头文件，别忘了加上常规的**头文件保护宏**（inclusion guards）。

The final touches involve including the new sched.h header file in your main.c source, in your sched.c module, and in the bsp.c source file.

最后收尾工作：在 main.c、sched.c 和 bsp.c 中都加上 `#include "sched.h"`。

The code builds cleanly, and I leave testing it on the board as an exercise for you.

代码编译通过，没有错误。在开发板上测试就留给你自己练习了。

Alright, so you have created a little priority-based scheduler, but what kind of tasks can it schedule?

好，你已经做了一个基于优先级的小型调度器。但它能调度什么样的任务呢？

Well, the tasks suitable for this scheduler are **one-shot, run-to-completion** functions that perform some processing and return to the scheduler. This is in stark contrast to tasks in a traditional real-time operating system (RTOS) that were structured as endless loops that never returned.

适合这个调度器的任务是**一次性的、运行至完成**（one-shot, run-to-completion）的函数——它们做一些处理就返回调度器。这跟传统 RTOS 中的任务形成了鲜明对比——RTOS 里的任务通常是永不返回的死循环。

At this point, your run-to-completion tasks are one-line functions, but they can be far more complex and contain elaborate conditional logic, calling other functions, and serious computations, including iterations, if necessary.

目前你的运行至完成任务都是只有一行的简单函数，但它们完全可以更复杂——包含精细的条件判断、调用其他函数、甚至需要的话做循环迭代和大量计算，都没问题。

However, one thing that these tasks should not do is block to wait in line for events. For example, a task function should not busy-wait for a time delay, a button press, or some data from a communication peripheral. Such waiting would clog the scheduler loop and prevent other tasks from running.

但有一件事这些任务绝对不能做，就是阻塞等待事件。比如任务函数不应该**忙等**（busy-wait）一个延时、等待按钮按下、或者等待通信外设的数据。这种等待会堵住整个调度器循环，导致其他任务没法运行。

Any waiting for events should happen outside a task handler, meaning that a task that wants to wait must necessarily return to the scheduler. When the event arrives, it must be announced by posting the task with the `sched_post()` API, which can be called from an ISR or another task. Then, the scheduler will call the task handler, which must pick up where it left off before returning.

任何等待事件的操作都应该在任务处理函数之外进行。也就是说，想要等待的任务必须先返回调度器。等事件到了，再通过 `sched_post()` API 来投递这个任务——这个 API 可以从中断服务程序或者其他任务中调用。然后调度器就会调用任务处理函数，函数接着上次中断的地方继续执行，执行完再返回。

If you have watched previous videos on this channel, you should recognize that this is precisely the use case for state machines and Active Objects. And this will be the subject of the next lesson, where you will see how to keep evolving the scheduler you created today for executing event-driven, non-blocking Active Objects.

如果你看过本频道之前的视频，应该能认出来——这正是**状态机**（state machine）和**活动对象**（Active Object）的典型用武之地。下一课的主题就是这个。到时候你会看到如何继续演进今天做的调度器，让它能执行事件驱动的、非阻塞的活动对象。

This concludes this lesson about a non-preemptive, priority-based scheduler for a "superloop." My objective was not only to present the scheduler but also to show you the whole process, which consisted of several refactoring steps to extract such a generic component from a specific application.

这节课关于超级循环的非抢占式优先级调度器就到这里。我的目标不仅是展示这个调度器本身，更想让你看到整个推导过程——通过一系列重构步骤，从具体应用中逐步提取出这个通用组件。

As usual, the code presented in this lesson will be available on the companion web page to this video course and from the course GitHub repository.

跟往常一样，本节课的代码可以在视频课程的配套网页和课程 GitHub 仓库中下载。

If you like these videos, please subscribe to stay tuned. The channel is approaching a very round number of 0x10000 subscribers, so your subscription will help break the 16-bit barrier and expand into the 32-bits. Thank you!

如果你喜欢这些视频，请订阅保持关注。频道订阅数马上要到一个很"整"的数字了——0x10000，你的订阅能帮我们突破 16 位上限，进入 32 位时代。谢谢！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| scheduler | 调度器 | 决定下一个运行哪个任务的机制 |
| non-preemptive | 非抢占式 | 任务不会被中断打断，运行至完成后才让出 CPU |
| superloop | 超级循环 | 嵌入式系统中主循环不断轮询执行任务的架构 |
| ready_set | 就绪集（位掩码） | 用位掩码表示哪些任务已就绪等待执行 |
| bitmask | 位掩码 | 用二进制位表示状态的数据结构 |
| task_registry | 任务注册表 | 存储任务处理函数的数组 |
| scheduling | 调度 | 选择下一个运行任务的过程 |
| priority | 优先级 | 任务执行的紧迫程度，数值越高越先执行 |
| task-level response | 任务级响应时间 | 从任务就绪到实际开始运行的最坏情况时间 |
| run-to-completion | 运行至完成 | 任务函数执行完毕后返回，不阻塞 |
| critical section | 临界区 | 不可被中断的代码段，用于保护共享资源 |
| CLZ (Count Leading Zeros) | 前导零计数 | 计算二进制数中从最高位开始的连续零的个数 |
| refactoring | 重构 | 在不改变外部行为的前提下改进代码结构 |
| assertion | 断言 | 用于检测程序错误条件的检查 |
| idle task | 空闲任务 | 系统无其他任务可运行时执行的默认任务 |
| encapsulation | 封装 | 将数据和实现细节隐藏在模块内部 |
| inclusion guards | 头文件保护宏 | 防止头文件被重复包含的预处理器指令 |
| function prototype | 函数原型 | 函数声明，指定函数名、返回类型和参数 |
| one-shot | 一次性 | 执行一次即返回的函数，非循环结构 |
| Active Object | 活动对象 | 事件驱动的编程模型，每个对象有自己的执行线程和事件队列 |
| state machine | 状态机 | 基于状态转换的事件驱动编程模式 |
| event-driven | 事件驱动 | 程序流程由事件触发而非顺序执行的编程范式 |
| breakpoint | 断点 | 调试时暂停程序执行的标记点 |
| ISR (Interrupt Service Routine) | 中断服务程序 | 响应硬件中断而执行的函数 |
| low-power sleep mode | 低功耗睡眠模式 | CPU 空闲时进入的省电状态 |
| busy-wait | 忙等 | CPU 不断循环检查条件，白白占用处理时间 |
| timing profile | 时序特性 | 任务执行的时间分布特征 |
