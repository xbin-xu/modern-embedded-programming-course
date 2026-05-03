# 第50课：阻塞还是不阻塞，这是个问题！ / Lesson 50: To Block, or Not to Block, That Is the Question!

Hello and welcome to the "Modern Embedded Systems Programming" course. I'm Miro Samek, and in this lesson, I'd like to explain why "To block or not to block?" is the single, most fundamental question determining the architecture of your embedded software. In fact, the issue of blocking is the most important discussion we can have in embedded programming, even though many embedded developers don't realize that.

大家好，欢迎来到"现代嵌入式系统编程"课程。我是 Miro Samek。这节课我想跟你聊一个问题——"阻塞还是不阻塞？"——这是决定你嵌入式软件架构最根本的问题。说真的，**阻塞（blocking）** 这个话题是嵌入式编程中最值得深入讨论的事，可惜很多嵌入式开发者并没有意识到这一点。

Let me start by reminding you what blocking is and that it occurs in two forms: busy-polling and blocking through context switching, as in a Real-Time Operating System (RTOS).

先来回顾一下什么是阻塞。阻塞有两种形式：一种是**忙等待（busy-polling）**，另一种是通过**上下文切换（context switching）**实现的阻塞，也就是实时操作系统（RTOS）里的那种。

Busy polling should be familiar to everybody because this is how the introductory "Blink" application is invariably coded. For example, here is the basic "Blink" example from Arduino: https://docs.arduino.cc/built-in-examples/basics/Blink/

忙等待大家应该都不陌生，因为入门的 "Blink" 程序几乎都是这么写的。比如 Arduino 的基础 "Blink" 示例：https://docs.arduino.cc/built-in-examples/basics/Blink/

The "Blink" code heavily depends on the `delay()` function, which happens to be the most frequently used function in all Arduino programming. Its whole purpose is to wait in line for the specified number of milliseconds by blocking the progression of the code.

"Blink" 代码严重依赖 `delay()` 函数——这恰恰是整个 Arduino 编程中用得最多的函数。它的作用很简单：通过阻塞代码执行来等待指定的毫秒数。

Internally, the `delay()` function is implemented as a busy-polling loop.

在内部，`delay()` 函数其实就是用一个忙等待循环实现的。

The same idea of blocking in line to wait for certain things to happen is also the fundamental feature of any traditional Real-Time Operating System (RTOS). For example, here is the "Blink" functionality coded as an RTOS thread:

同样，"阻塞等待某件事发生"这个思路，也是任何传统实时操作系统（RTOS）的核心特征。比如，下面是把 "Blink" 功能写成 RTOS 线程的样子：

Of course, the RTOS `vTaskDelay()` function works internally entirely differently than the busy-polling `delay()` from Arduino. I devoted the whole lesson #25 to explaining the efficient blocking in an RTOS: https://youtu.be/JurV5BgjQ50?si=JsCoc1GX3Ouk4bjd

当然，RTOS 的 `vTaskDelay()` 在内部工作方式上跟 Arduino 的忙等待 `delay()` 完全不同。我在第 25 课专门讲过 RTOS 里高效的阻塞机制：https://youtu.be/JurV5BgjQ50?si=JsCoc1GX3Ouk4bjd

Still, the purpose of the Arduino polling `delay()` and FreeRTOS `vTaskDelay()` is the same, and from your perspective, as the application developer, there is no difference in their behavior.

尽管如此，Arduino 的轮询 `delay()` 和 FreeRTOS 的 `vTaskDelay()` 目的完全一样。站在你——应用开发者——的角度来看，它们的行为没有区别。

But why is that important? Well, because the ability to block and voluntarily wait anywhere in your code is considered the most valuable property, and it presumably simplifies your software development.

那为什么这个很重要？因为能够在代码的任何位置阻塞、自愿等待，一直被认为是最有价值的能力——大家觉得它能简化软件开发。

In fact, the ability to block is the main argument for using an RTOS in the first place. For example, here is an introduction to the PX5 RTOS User Guide.

事实上，阻塞能力本来就是使用 RTOS 最主要的理由。比如，这里有一段 PX5 RTOS 用户指南的介绍。

In the section "Why use an RTOS?" you see the usual critique of the **superloop**, called here "control loop," and the difficulties with scaling it up while maintaining the loop's real-time response.

在"为什么要用 RTOS？"这一节，你会看到对**超级循环（superloop）** 的常见批评——这里叫它"控制循环"——说的是在保持实时响应的同时扩展规模有多困难。

But the really crucial argument is about blocking. For example, if `process_secondary_task()` needs to wait for something, such as an I/O operation, blocking would clog the whole control loop and may adversely affect the timing of `process_primary_task()`.

但真正关键的论点是围绕阻塞展开的。比如，`process_secondary_task()` 如果需要等待某个东西——比如 I/O 操作——阻塞就会把整个控制循环堵死，还可能影响 `process_primary_task()` 的时序。

In lesson #21, you learned about the valuable software property called **"composability."** As long as the components of the superloop don't block, they are largely composable, meaning you can keep adding or removing them, and the loop will still work. But the minute you introduce any form of blocking into any component, you destroy the composability.

第 21 课里你学过一个很重要的软件特性——**可组合性（composability）**。只要超级循环里的组件不阻塞，它们在很大程度上就是可组合的，也就是说你可以不断添加或删除组件，循环照样能正常工作。但只要你在任何一个组件中引入任何形式的阻塞，可组合性就被破坏了。

Interestingly, the presumed workaround in this scenario is the necessity to create a **state machine** in `process_secondary_task()`, which is seen as a complexity and overhead.

有意思的是，在这种情况下大家认为的解决办法是：在 `process_secondary_task()` 里写一个**状态机（state machine）**——而这往往被视为额外的复杂性和开销。

But let me unpack this statement because suddenly mentioning a state machine is a leap of thought that requires an explanation.

不过让我展开说说这个观点，因为突然提到状态机其实是个思维跳跃，需要解释一下。

To understand why a state machine might be needed, let's go back to the original Arduino "Blink" example. Here, the code description explains the blocking nature of the `delay()` function and recommends checking out the "BlinkWithoutDelay" example to avoid blocking.

要理解为什么可能需要状态机，我们回到最初的 Arduino "Blink" 示例。它的代码说明解释了 `delay()` 函数的阻塞性质，并且推荐你去看 "BlinkWithoutDelay" 这个示例来避免阻塞。

So, let's go there and inspect the non-blocking code. This implementation centers around the Arduino `millis()` function, which provides the current number of milliseconds and returns immediately without blocking. If the expected waiting interval has elapsed, the code checks the `ledState` variable and depending on this state selects the desired new state of the LED.

好，我们过去看看这个非阻塞的代码。它的核心是 Arduino 的 `millis()` 函数，这个函数返回当前的毫秒数，而且立即返回、不阻塞。如果预期的等待时间已经过了，代码就检查 `ledState` 变量，根据这个状态选择 LED 需要切换到的新状态。

If you watched some of my previous lessons in the State Machine segment, particularly lesson #37, "Input-Driven State Machines," you should recognize this if-else statement around the `ledState` variable as an improvised state machine.

如果你看过之前状态机系列的一些课程，特别是第 37 课"输入驱动状态机"，你应该能认出来：围绕 `ledState` 变量的这个 if-else 语句，其实就是一个**即兴状态机（improvised state machine）**。

Unfortunately, the BlinkWithoutDelay state machine is not equivalent to the original Blink because it allows only one interval for both the LED "on" and "off" states. In contrast, the original uses two different blocking delays, so you can very easily use different intervals.

不过有个遗憾：BlinkWithoutDelay 的状态机跟原始的 Blink 并不等价，因为它对 LED 的"亮"和"灭"两个状态只能设一个时间间隔。而原始版本用了两个不同的阻塞延迟，你可以很方便地设置不同的间隔。

Anyway, for a clearer, reusable, and equivalent example, lesson #21 provides the Blinky **input-driven state machine** coded explicitly.

不管怎样，第 21 课里有一个更清晰、可复用、完全等价的例子——明确编码的 Blinky **输入驱动状态机（input-driven state machine）**。

So that is an instance of a state machine the PX5 RTOS User Guide was talking about. Without blocking, the code must necessarily return to the loop, but it must also remember what it was doing to "find its way back" next time. This is what the state machine is for.

这就是 PX5 RTOS 用户指南提到的那种状态机。没有阻塞的情况下，代码必须返回到循环里，但同时还得记住自己之前在干什么，下次才能"找到回来的路"。状态机就是干这个的。

Now, let's look at how an RTOS solves the problem of non-composability of the blocking code.

好，那我们来看看 RTOS 怎么解决阻塞代码不可组合的问题。

So, the RTOS approach splits the single control loop into multiple control loops, called **threads** or **tasks**. Now, each such thread can block (and actually must block, even if it didn't block before). However, the blocking does not interfere with the other functionality because they run in separate threads. Multiple threads can voluntarily block and wait in line for multiple events in parallel.

RTOS 的做法是把一个控制循环拆成多个控制循环，称为**线程（threads）** 或**任务（tasks）**。这样一来，每个线程都可以阻塞——实际上必须阻塞，哪怕它以前不需要阻塞。但因为各自运行在独立的线程中，阻塞不会互相干扰。多个线程可以同时自愿阻塞、并行等待多个事件。

I explained all this in the lesson segment about the RTOS, where you saw how the RTOS can juggle all these threads. The critical element of the RTOS operation is that each thread maintains its own private **stack**, and that stack maintains the context while a thread is blocked so that it can "find its way back" after unblocking.

这些我在 RTOS 课程系列里都讲过，你看过 RTOS 是怎么在这些线程之间来回切换的。RTOS 运行的关键要素是：每个线程维护自己的私有**栈（stack）**，栈在线程阻塞期间保存上下文，这样线程解除阻塞后才能"找到回来的路"。

So, here is a summary of the embedded architectures discussed so far. Simple super loops with blocking calls fall into the "to block" column. They are intuitive, but they don't scale because blocking destroys composability.

好，总结一下目前讨论过的嵌入式架构。带阻塞调用的简单超级循环属于"阻塞"那一列。它们写起来直观，但扩展不了，因为阻塞会破坏可组合性。

One way to make a superloop extensible is to avoid blocking by restructuring each function in the loop into a non-blocking state machine, whereas the input-driven state machine variety is the most frequently used. (Actually, the most commonly used are "improvised state machines," also known as "spaghetti code." But let's be charitable and assume developers are somewhat familiar with state machines.)

要让超级循环具备扩展性，一种办法是避免阻塞——把循环中的每个函数重构成非阻塞状态机，其中输入驱动状态机用得最多。（当然了，实际上最常见的是"即兴状态机"，也叫"面条代码"。不过我们宽厚一点，假设开发者多少懂一些状态机吧。）

The other way of making the superloop extensible is to use an RTOS, which allows you to create multiple superloops. This approach is definitely in the "to block" column, as it doubles down on blocking because every RTOS thread (except the lowest-priority thread in the whole system) must block for other threads to run.

另一种让超级循环可扩展的办法是用 RTOS——它允许你创建多个超级循环。这个方案毫无疑问属于"阻塞"列，因为它加倍依赖阻塞：每个 RTOS 线程（除了整个系统中优先级最低的那个）都必须阻塞，其他线程才有机会运行。

This general landscape of embedded architectures has existed since RTOSes became mainstream in the 1980s. Consequently, most embedded developers believe these are the main and only games in town.

这种嵌入式架构的大格局从 80 年代 RTOS 成为主流以来就一直没变。所以大多数嵌入式开发者认为，这就是仅有的选择。

But this is no longer accurate. In recent decades, more architectures and new approaches have been introduced, mainly in the "NOT to block" column. Basically, blocking is no longer considered as good or desirable as it used to, and state machines, especially the modern event-driven state machines, are not considered as bad or onerous. Let me explain.

但这已经不准确了。近几十年来出现了更多架构和新方法，主要集中在"不阻塞"那一列。简单来说，阻塞不再像以前那样被认为是好的、值得追求的；而状态机——特别是现代的**事件驱动状态机（event-driven state machine）**——也不再被认为是糟糕的、负担很重的。我来解释一下。

Regarding blocking, one notable trend is that concurrency experts drastically restrict blocking in their RTOS-based designs by applying the **event-driven paradigm**.

关于阻塞，有一个值得关注的趋势：并发专家们在基于 RTOS 的设计中，通过采用**事件驱动范式（event-driven paradigm）**来大幅限制阻塞。

For example, the article "Managing Concurrency in Complex Embedded Systems," by Dr. David Cummings, describes the event-driven architecture used by NASA JPL in all its Martian rovers. Cummings' paper recommends the **event-loop** structure I introduced in lessons #33 and #34 of this course.

比如，David Cummings 博士的文章《复杂嵌入式系统中的并发管理》描述了 NASA 喷气推进实验室（JPL）在所有火星探测器上使用的事件驱动架构。Cummings 的论文推荐的，正是我在本课程第 33 和 34 课中介绍的**事件循环（event loop）** 结构。

The event loop blocks only at the top and should never block afterward. Cummings' paper describes various temptations to apply blocking and cautions to avoid it in all circumstances. So, even though traditional RTOSes, such as VxWorks RTOS used in the NASA rovers, are capable of blocking in any number of points, the experts advise to AVOID that blocking. At least, this is what they found to be critical for creating reliable mission-critical software.

事件循环只在最顶端阻塞一次，之后绝不能再阻塞。Cummings 的论文列举了各种让人想用阻塞的诱惑，并告诫在所有情况下都要避免。所以，虽然传统的 RTOS——比如 NASA 探测器上用的 VxWorks——可以在无数个点上阻塞，但专家们建议：**避免阻塞**。至少，他们发现这是创建可靠的**任务关键型软件（mission-critical software）** 的关键所在。

Now, regarding state machines, the constantly running input-driven state machines are indeed a lot of overhead. But these are no longer the only option. **Event-driven state machines**, such as UML statecharts, run only when events are present and otherwise don't use the CPU. These state machines beautifully complement the event-loop and the **Active Object** design pattern I introduced in lesson #34.

再说状态机。持续运行的输入驱动状态机确实开销不小。但这已经不是唯一选择了。**事件驱动状态机**——比如 UML 状态图（UML statecharts）——只在有事件的时候才运行，没事的时候不占 CPU。这些状态机跟事件循环以及我在第 34 课介绍的**活动对象（Active Object）** 设计模式配合得天衣无缝。

However, the innovations in the "non-blocking" column do not stop there. The obvious question is, why pay for the ability to block in an RTOS kernel and not to use it? Well, there are much simpler and more efficient real-time kernels that cannot voluntarily block but don't require multiple stacks for threads, either. Such kernels have been known and extensively used in the automotive sector.

不过，"非阻塞"这一列的创新还不止于此。一个很自然的问题是：既然不用阻塞，为什么要为 RTOS 内核的阻塞能力买单？确实有更简单、更高效的实时内核——它们不支持自愿阻塞，但也不需要为每个线程分配独立的栈。这种内核在汽车行业早已广为人知并被大量使用。

In the next lesson, I will present a simple, cooperative, **single-stack kernel** of this type, which is called **QV** and is part of the QP real-time embedded framework.

下一课，我会介绍一个简单的协作式**单栈内核（single-stack kernel）**，叫做 **QV**，是 QP 实时嵌入式框架的一部分。

However, right after that, I will present a fully preemptive, single-stack kernel called **QK**, which is also part of the QP real-time framework. The preemptive QK kernel is fully compatible with the **Rate Monotonic Scheduling (RMS) / Rate Monotonic Analysis (RMA)** method introduced in lesson #26 in the RTOS segment. In fact, QK is even more suitable for RMS/RMA than a traditional RTOS kernel because blocking is avoided, which vastly simplifies the real-time analysis.

紧接着，我还会介绍一个完全抢占式的单栈内核 **QK**，它同样是 QP 实时框架的一部分。抢占式 QK 内核与 RTOS 系列第 26 课讲的**速率单调调度（Rate Monotonic Scheduling, RMS）**/ **速率单调分析（Rate Monotonic Analysis, RMA）** 方法完全兼容。事实上，QK 比 传统 RTOS 内核更适合做 RMS/RMA 分析——因为没有阻塞，实时分析大大简化了。

In summary, the ability to block is the most critical defining characteristic of any embedded software architecture. A traditional blocking RTOS is still the dominant approach, but this is changing. There is much more innovation in the non-blocking architectures, and they are gaining more traction, especially in mission-critical systems.

总结一下：阻塞能力是定义任何嵌入式软件架构最关键的特征。传统的阻塞式 RTOS 目前仍然是主流，但情况正在变化。非阻塞架构领域的创新要多得多，而且越来越受关注——特别是在任务关键型系统中。

If you like this channel, please like this video and subscribe to stay tuned. Thanks for watching!

如果你喜欢这个频道，请点赞、订阅。感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| blocking | 阻塞 | 代码执行被暂停，等待某个条件满足后才能继续 |
| busy-polling | 忙等待 | CPU 不断循环检查条件，不释放执行权 |
| context switching | 上下文切换 | RTOS 中保存和恢复线程执行上下文的过程 |
| superloop | 超级循环 | 嵌入式系统中常见的单一主循环架构 |
| composability | 可组合性 | 软件组件能够自由组合、添加或移除而不影响整体功能的特性 |
| state machine | 状态机 | 根据当前状态和输入决定行为和状态转换的模型 |
| improvised state machine | 即兴状态机 | 用 if-else 或 switch-case 临时拼凑的状态机逻辑 |
| input-driven state machine | 输入驱动状态机 | 通过外部输入（如时间、传感器）触发状态转换的状态机 |
| event-driven state machine | 事件驱动状态机 | 仅在有事件到来时运行，不占用 CPU 的状态机 |
| thread / task | 线程 / 任务 | RTOS 中独立调度的执行单元 |
| stack | 栈 | 用于保存线程局部变量和上下文的数据结构 |
| event-driven paradigm | 事件驱动范式 | 以事件触发执行的编程模式，避免忙等待和阻塞 |
| event loop | 事件循环 | 从事件队列中取出事件并分发的循环结构 |
| Active Object | 活动对象 | 结合事件队列和状态机的并发设计模式 |
| single-stack kernel | 单栈内核 | 所有线程共享一个栈的内核，不需要为每个线程分配独立栈 |
| Rate Monotonic Scheduling (RMS) | 速率单调调度 | 基于任务执行频率分配优先级的实时调度算法 |
| Rate Monotonic Analysis (RMA) | 速率单调分析 | 基于 RMS 理论分析系统可调度性的方法 |
| mission-critical software | 任务关键型软件 | 失败可能导致严重后果的软件系统 |
| UML statechart | UML 状态图 | 基于 UML 标准的层次化状态机建模方法 |
| QV kernel | QV 内核 | QP 框架中的协作式单栈实时内核 |
| QK kernel | QK 内核 | QP 框架中的抢占式单栈实时内核 |
