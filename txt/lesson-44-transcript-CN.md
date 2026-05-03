# 第44课：活动对象——可变事件与实时性 / Lesson 44: Active Objects — Mutable Events and Real-Time

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I continue the subject of Active Objects for Real-Time. Specifically, today you'll see how the use of asynchronous, mutable events makes Active Objects even more suitable for hard real-time than traditional with a Real-Time Operating System (RTOS).

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，这节课我们继续聊实时**活动对象**（Active Objects）的话题。今天你会看到，异步的**可变事件**（Mutable Events）为什么能让活动对象比传统的 RTOS 方式更适合硬实时系统。

---

As usual, let's get started by copying the previous lesson-43 directory to lesson 44. Get inside the new lesson-44 directory and double-click on the project lesson to open it in the micro-Vision IDE.

照惯例，先把上一课的 lesson-43 目录复制一份，改名为 lesson-44。进到新目录里，双击项目文件 lesson，在 micro-Vision IDE 中打开它。

---

To remind you quickly what happened in the last lesson-43, you saw that Active Objects do NOT have to monopolize the CPU for the whole duration of run-to-completion event-processing.

快速回顾一下上一课的内容：你看到了活动对象并不需要在整个**运行到完成**（Run-to-Completion, RTC）事件处理过程中一直霸占 CPU。

Indeed, under a preemptive, priority-based scheduler, Active Objects with their state machines CAN freely preempt each other, and so they meet all the requirements of the Rate-Monotonic Scheduling (RMS) or Rate-Monotonic Analysis (RMA) method, which you learned back in lesson #26.

没错，在抢占式优先级调度器下，带状态机的活动对象可以自由地互相抢占，因此完全满足你在第 26 课学过的**速率单调调度**（Rate-Monotonic Scheduling, RMS）和**速率单调分析**（Rate-Monotonic Analysis, RMA）方法的所有要求。

But the example in last lesson was a bit simplistic in that it didn't include any interactions: neither among the original RTOS threads nor among the Active Objects, after you've translated the threads to active objects.

不过上一课的例子有点太简单了——没有任何交互：原来的 RTOS 线程之间没有交互，你把线程转成活动对象之后，活动对象之间也没有交互。

So, today you will make the example much more realistic by adding interactions among Active Objects to see how that impacts their real-time behavior.

所以今天我们要让例子更贴近实际——加上活动对象之间的交互，看看这会对实时性产生什么影响。

---

Specifically, suppose that now after each button press you want your Blinky2 thread to change the blinking pattern of your Blinky1 thread.

具体来说，假设你希望每次按下按钮后，Blinky2 线程能改变 Blinky1 线程的闪烁模式。

The first implementation I'll show you will be based on a naive sharing of global variables between the Blinky1 and Blinky2 active objects. Such sharing is precisely something that I've been trying to convince you to avoid, at any cost.

我给你演示的第一个方案，是在 Blinky1 和 Blinky2 两个活动对象之间直接共享全局变量。这种做法，正是我一直劝你不惜一切代价要避免的。

But perhaps the best way to learn a rule like that is to see the consequences of breaking the rule.

不过，理解一条规则最好的办法，可能就是看看违反它会有什么后果。

---

So, let's exactly break the "no-sharing" rule as follows:

那我们就来打破"不共享"这条规则，具体做法如下：

Let's replace the current, hard-coded blinking pattern of the Blinky1 thread with global variables, so that the pattern can be later changed.

把 Blinky1 线程里硬编码的闪烁模式替换成全局变量，这样后面就能改了。

The global variable "g_ticks" will hold the number of clock ticks for the time event.

全局变量 `g_ticks` 用来保存时间事件的时钟节拍数。

It will be initialized with the current value of clock ticks.

它用当前的节拍值来初始化。

The global variable "g_iter" will hold the number of iterations inside the Blinky1 event handler.

全局变量 `g_iter` 用来保存 Blinky1 事件处理程序里的迭代次数。

It will also be initialized with the current number of iterations.

同样用当前的迭代次数来初始化。

---

But actually, the time event cannot be armed for periodic timeouts only once at the beginning, because it won't change the timeout as the global variable g_ticks changes. So, instead, let's arm the time event for one-shot timeout and then arm it again after each timeout.

但有个问题：时间事件不能一开始就设成周期性超时，因为那样的话它不会跟着 `g_ticks` 的变化而调整超时时间。所以，我们改成**单次触发**（one-shot）超时——每次超时之后再重新设置一次。

Now, comes the sharing of the global variables in Blinky2.

接下来看 Blinky2 那边怎么共享全局变量。

Here, after each button press event you want to change the global variables "g_ticks" and "g_iter" to some new values, which will in turn change the blinking pattern in Blinky1.

每次按钮按下事件到来，你要把 `g_ticks` 和 `g_iter` 设成新的值，Blinky1 的闪烁模式就会跟着变。

Such change can be accomplished in many ways, but one simple solution is to store the values in two static and constant arrays for ticks and iterations, respectively.

实现方式有很多，一个简单的办法是把值分别存到两个静态常量数组里——一个存节拍数，一个存迭代次数。

And then to set the global variables from the arrays indexed by a private sequence counter.

然后用一个私有序列计数器作为数组下标，从中取值赋给全局变量。

To make sure that a different set of values is used each time, the sequence counter needs to be incremented and wrapped around at the end of the sequence.

为了保证每次用不同的值，序列计数器要递增，到序列末尾再绕回来。

Finally, of course you need to add the sequence counter to the Blinky2 class and you need to initialize the counter in the top-most initial transition.

最后别忘了把序列计数器加到 Blinky2 类里，并在最顶层的初始转换中初始化它。

---

Alright, let's run this code in your TivaC LaunchPad board...

好，让我们在 TivaC LaunchPad 板子上跑一下这段代码……

At the first button press, you can see that the blinking pattern of Blinky1 changes from fast to slow.

第一次按下按钮，可以看到 Blinky1 的闪烁模式从快变慢了。

At the next press, the pattern changes back from slow to fast. So the code appears to be working just fine.

再按一次，又从慢变回快。看起来代码工作得挺好的。

---

But I hope that by now you can see that there is a race condition in this code. If you don't see it, please re-watch lesson #20 about race conditions.

不过我希望你已经看出来了——这段代码里存在**竞态条件**（race condition）。要是没看出来，建议回去重温第 20 课关于竞态条件的内容。

But yes, if the button press would come just after changing g_ticks but before changing g_iter, the Blinky1 active object would see an inconsistent pair of values: the new g_ticks and the old g_iter.

没错，如果按钮按下恰好发生在改完 `g_ticks` 但还没改 `g_iter` 的那个窗口里，Blinky1 活动对象就会看到一对不一致的值：新的 `g_ticks` 配上旧的 `g_iter`。

Now, this race condition exists in a very narrow time window, so most likely it would escape casual testing in the lab. But rest assured that if you ship your code in thousands of devices to thousands of customers, some of them will inadvertently trigger the race condition.

这个竞态条件的时间窗口非常窄，实验室里随便测测多半测不出来。但相信我——一旦你的代码部署到成千上万台设备上交付给成千上万的用户，肯定会有人无意间触发它。

One way or another, it's much better to face the problem right now, during the development, than to wait for the customers to find it.

无论如何，在开发阶段就把问题面对掉，总比等客户来发现要好得多。

---

So, let's increase the chance of the race condition by adding some workload between setting g_ticks and g_iter.

那我们来加大触发竞态条件的概率——在设置 `g_ticks` 和 `g_iter` 之间加点工作量。

For example, you can borrow one-third of the workload from the loop below, like that.

比如，从下面的循环里借三分之一的工作量过来，像这样。

Such delay between setting variables might seem completely unnatural at first, but it actually can easily happen in practice. For example, if the values were delivered by a serial interface. Serial transmission of the 4 bytes of g_iter would take about as much as your loop.

设置两个变量之间插一段延迟，看起来可能很不自然，但实际中很容易出现。比如，值是通过串口传过来的——串口传输 `g_iter` 那 4 个字节的时间，差不多就跟你加的循环一样长。

I want to stress it once more that the loop is NOT creating the problem, because the race condition exists even without any loop, it merely makes it easier to find.

我要再强调一遍：循环不是在制造问题。就算没有循环，竞态条件照样存在，循环只是让问题更容易暴露出来。

But anyway, I'm sure you're curious to see how that works on your TivaC board.

不过说回来，我猜你肯定好奇板子上会是什么效果。

---

Well, now the timing of Blinky1 is completely different. Just after some activity in Blinky2, Blinky1 takes over the whole CPU and nothing else is running.

好家伙，现在 Blinky1 的时序完全乱套了。Blinky2 刚有点动作，Blinky1 就把整个 CPU 占了，别的什么都跑不了。

Alright, I reset the board and try again:

我重置板子再试一次：

Essentially the same thing.

结果基本一样。

Now, I try without resetting the board...

这次我不重置板子再试……

And this time, Blinky1 was still taking all the CPU to begin with, so the button press didn't make any difference.

这次 Blinky1 一上来还是霸占了所有 CPU，按钮按下完全没效果。

---

So, what's going on? Well, when you zoom in, you can see that Blinky1 occasionally pauses, which happens with two overlapping periods:

到底怎么回事？放大来看，你会发现 Blinky1 偶尔会暂停一下，暂停有两种重叠的周期：

1000 microseconds

1000 微秒

and about 1285 microseconds.

和大约 1285 微秒。

The 1000 microsecond period is caused by the SysTick interrupt preempting the Blinky1 active object.

1000 微秒那个周期是 SysTick 中断抢占 Blinky1 活动对象造成的。

But the 1285 microsecond period is caused by the original Blinky1 workload of 1500 iterations, corresponding to the previous value of g_iter. But this time when Blinky1 finishes its run-to-completion step, the TIMEOUT event is already waiting in its event queue, because it was armed for just one clock tick, corresponding to the new value of g_ticks.

而 1285 微秒那个周期，是 Blinky1 原来 1500 次迭代的工作负载造成的，对应的是 `g_iter` 之前的值。但这次 Blinky1 完成运行到完成步骤的时候，TIMEOUT 事件已经在事件队列里等着了——因为它被设置成只过一个时钟节拍就触发，对应的是 `g_ticks` 的新值。

This situation causes total lockup of the embedded target, which becomes completely unresponsive. This is a classic example of "denial of service".

这种状况导致嵌入式目标完全锁死，什么都响应不了。这就是一个典型的**拒绝服务**（denial of service）例子。

---

But all this shouldn't sound new to you, because the issues related to resource sharing among RTOS threads have been discussed back in lesson #28. The only new aspect here is that all this applies equally to Active Objects as well.

不过这些对你来说不应该陌生，因为 RTOS 线程之间资源共享的问题，我们在第 28 课已经讨论过了。这里唯一新的点是：这些问题对活动对象同样适用。

Well, if this is the case, then the traditional solutions based on mutual exclusion should apply also. So, let's just apply one such mechanism.

既然如此，基于**互斥**（mutual exclusion）的传统解决方案应该也管用。那我们就来试一种。

In traditional threads, a mutual mechanism of choice is the mutex introduced in lesson #28. But mutex is a blocking mechanism, so it cannot be used in the non-blocking active objects.

传统线程里，首选的互斥机制是第 28 课介绍的**互斥量**（mutex）。但互斥量是阻塞式的，没法用在非阻塞的活动对象里。

But in the same lesson #28 you also learned about selective scheduler locking, which is a non-blocking mutual exclusion mechanism and therefore you can apply it inside active objects.

不过在同一课里你还学过**选择性调度器锁定**（selective scheduler locking），这是一种非阻塞的互斥机制，所以可以在活动对象里使用。

---

So here, around the code that modifies the global variables, you can just copy the QXK scheduler lock from lesson #28.

所以在修改全局变量的代码前后，你直接从第 28 课复制 QXK 调度器锁的代码就行。

Typically, you need to adjust the priority ceiling. But here, it just so happens that the ceiling of 5 is right, because the highest-priority Blinky1 active object accessing the shared global variables has also priority 5.

一般来说需要调整**优先级上限**（priority ceiling）。不过在这里，上限值 5 恰好是对的，因为访问这些共享全局变量的最高优先级活动对象 Blinky1 的优先级就是 5。

Alright, let's test this version.

好，来测一下这个版本。

As you can see, the software now works much better in that Blinky1 no longer overloads the CPU.

可以看到，现在好多了——Blinky1 不再把 CPU 占满。

And also, the Blinky1 pattern changes at each button press, so definitely the mutual exclusion works.

而且每次按下按钮 Blinky1 的模式都会变，说明互斥确实起作用了。

---

But now something strange is going on with the timing of Blinky1 during the transient from one blinking pattern to another. Specifically, the period at the transient sometimes takes over 3 milliseconds, which exceeds the Blinky1 deadline of 2 milliseconds.

但从一种闪烁模式切换到另一种的时候，Blinky1 的时序出了点怪事。具体来说，过渡期间周期有时会超过 3 毫秒，超出了 Blinky1 的 2 毫秒**截止时间**（deadline）。

A hiccup like that might be unacceptable in a hard real-time system.

在**硬实时系统**（hard real-time system）里，这种毛刺可能是不可接受的。

But this is a consequence of the bounded priority inversion always present with mutual exclusion.

这是互斥机制中始终存在的**有界优先级反转**（bounded priority inversion）带来的后果。

The whole time that the low-priority Blinky2 spends holding the priority-ceiling lock prevents the high-priority Blinky1 from running and should really be counted towards Blinky1 CPU utilization, whereas CPU utilization is the critical concept in the Rate Monotonic Scheduling method.

低优先级的 Blinky2 持有优先级上限锁的整段时间里，高优先级的 Blinky1 都没法运行——这段时间其实应该算进 Blinky1 的 CPU 利用率里，而 CPU 利用率正是速率单调调度方法的关键指标。

During the bounded priority inversion, the CPU utilization is increased, so the system is temporarily above the RMS schedulability bound and therefore the deadline is missed.

有界优先级反转期间，CPU 利用率升高，系统暂时超出了 RMS 的**可调度性界限**（schedulability bound），于是截止时间就被错过了。

---

So in short summary: You just saw some consequences of sharing resources among active objects and why you should avoid it. Sharing without mutual exclusion is simply wrong. Sharing with mutual exclusion can screw up real-time performance.

简单总结一下：你刚看到了活动对象之间共享资源的后果，以及为什么要避免这么做。不加互斥的共享根本就是错的；加了互斥的共享又会搞坏实时性能。

So even though this traditional approach known as "shared state concurrency" is still dominating embedded programming, using *events* for interactions allows you to avoid the sharing and eliminates the whole need for mutual exclusion.

所以，虽然这种被称为**共享状态并发**（shared-state concurrency）的传统做法仍然主导着嵌入式编程，但用事件来做交互就能完全避免共享，也就根本不需要互斥了。

So now, let's take a look at that event-driven alternative with the focus on today's subject of real-time performance.

那接下来，我们就来看看事件驱动的替代方案，重点关注今天的主题——实时性能。

---

The first thing you will need is a special event that will carry the information about blinking pattern in its event parameters. In the introduction to event-driven programming, I mentioned that events can have such parameters, but today is the first time you will actually see how to do this.

首先你需要一种特殊的事件，用它的参数来携带闪烁模式的信息。在事件驱动编程的介绍中我提到过事件可以有参数，但今天是第一次看到具体怎么做。

So, you need to create a new event class, let's call it BlinkPatternEvt that will inherit QEvt and add to it the two parameters with the same meaning as your global variables.

你需要创建一个新的事件类，叫它 `BlinkPatternEvt`，让它**继承**（inherit）`QEvt`，然后加上两个参数——含义跟之前的全局变量一样。

Next, in Blinky2, upon BUTTON_PRESS, you want to create such an event, set the parameters to the desired values and post it to Blinky1.

接下来在 Blinky2 里，收到 BUTTON_PRESS 时创建这样一个事件，把参数设成想要的值，然后**投递**（post）给 Blinky1。

---

It turns out that you've already done something similar with *immutable* events, such as BUTTON_PRESS, in your bsp.c.

其实在 `bsp.c` 里，你已经对**不可变事件**（immutable events）做过类似的事情了，比如 BUTTON_PRESS。

Well then, let's try, as the first attempt, to do essentially the same here as well.

那作为第一次尝试，我们在这里也用差不多的做法。

So you allocate a static event of the type BlinkPatternEvt, but now it cannot be const, because you will want to change its parameters.

声明一个 `BlinkPatternEvt` 类型的静态事件，但这次不能加 `const`，因为你需要修改它的参数。

This also means that you cannot use a one-time initializer, because you need to modify the parameters every time.

这也意味着不能用一次性初始化器了——因为每次都要改参数。

But still, you should not to forget that every event needs a signal. Let's call it BLINK_PATTERN_SIG and add it to the enumeration of all signals in bsp.h.

不过别忘了，每个事件都需要一个**信号**（signal）。我们叫它 `BLINK_PATTERN_SIG`，把它加到 `bsp.h` 的信号枚举里。

---

Next, you can get rid of the mutual exclusion protection and replace setting the global variable with setting the ticks event parameter.

接下来，把互斥保护去掉，把原来设置全局变量的地方改成设置事件的 `ticks` 参数。

You can leave the for-loop with the emulated workload, and then you again replace the global with the "iter" parameter.

模拟工作负载的 for 循环可以留着，然后再把全局变量替换成 `iter` 参数。

Finally, you post the event to the Blinky1 active object.

最后把事件投递给 Blinky1 活动对象。

Here, I'd like to emphasize that this is NOT the final, recommended way of generating *mutable* events, and you'll see that it can be actually wrong. However, I see similar attempts made by developers new to event-driven programming, so I show this step for instructional reasons to later explain why it's not good in general.

这里我要强调一下：这**不是**生成**可变事件**的最终推荐做法，你后面会看到它其实是有问题的。不过我刚接触事件驱动编程的开发者经常这么干，所以我先演示一下，后面再来解释为什么不好。

---

But let's leave it for now and continue to Blinky1, where you still need to receive the generated event.

先不管这个，继续看 Blinky1——你还需要在那里接收生成的事件。

For that, you add a case for the BLINK_PATTERN signal.

为此，给 `BLINK_PATTERN` 信号加一个 case 分支。

Inside, you can access the event parameters by explicitly down-casting the received generic event e of type QEvt to the subclass BlinkPatternEvt, like this.

在里面，你需要把收到的通用事件 `e`（`QEvt` 类型）显式地**向下转型**（down-cast）为子类 `BlinkPatternEvt`，这样才能访问事件参数，像这样。

You can use the ticks parameter immediately to arm the time event to time out: *after* the received number of ticks and subsequently *every* number of received ticks.

拿到 `ticks` 参数后，立刻用它来设置时间事件：先在收到节拍数*之后*触发一次，之后*每隔*同样的节拍数再触发。

You can revert to this periodic time out, because now you have this explicit change event.

可以恢复成周期性超时了，因为现在有了这个显式的更改事件。

Previously, without this event, you had to use a one-shot timeout, because you had to be ready for a change in the global variables at every timeout.

以前没有这个事件的时候，必须用单次触发超时，因为每次超时都得准备好应对全局变量的变化。

---

You should also not forget to arm the time event for periodic operation in the initial transition.

别忘了在初始转换里也要把时间事件设成周期性操作。

Regarding the number of iterations, you need to have it available in all subsequent TIMEOUT events, so you need to store it in the class attribute.

至于迭代次数，你需要在后续所有 TIMEOUT 事件里都能用到它，所以要把它存到类的属性里。

You change the value of this attribute in the BLINK_PATTERN event, whereas you access the event parameter the same way as before.

在 `BLINK_PATTERN` 事件处理中修改这个属性的值，访问事件参数的方式跟之前一样。

Of course, now you need to add this attribute to the class

当然，你需要把这个属性加到类里，

and you need to initialize it in the initial transition.

并且在初始转换中初始化它。

---

Well, this would be it for now, so let's try to compile the code.

好，目前就这些，来试着编译一下。

OK, the C compiler doesn't perform upcasting automatically, so you need to do it explicitly.

C 编译器不会自动做**向上转型**（upcasting），你得自己显式写。

And, as you are at it, you also need to add disarming of the time event before arming it again.

顺便还得加上重新设置时间事件之前先解除当前设置的代码。

Well, time for testing: upload the code and reset the board

好，测试时间到了——上传代码，重置板子。

---

As you can see, the first button press causes Blinky1 to change from slow to fast.

可以看到，第一次按下按钮，Blinky1 从慢变快。

And the second press causes it to change from fast to slow.

第二次按下，又从快变慢。

There are also no more hiccups in Blinky1 timing.

Blinky1 的时序也不再出现毛刺了。

So, everything seems to be working perfectly without mutual exclusion and without sharing.

一切看起来都很完美——没有互斥，没有共享，照样跑得好好的。

Or is it really...

真的吗……

---

Well, unfortunately, there is still sharing going on around the static BlinkPattern event.

遗憾的是，在静态的 BlinkPattern 事件上，其实还是有共享。

I mean, the static event object bpevt might not be completely global, because it is hidden inside the Blinky2 state-handler function, but there is still only one such object in the system.

我是说，静态事件对象 `bpevt` 看起来不算完全全局的——毕竟它藏在 Blinky2 状态处理函数内部——但整个系统里毕竟只有这一个对象。

The static event is obviously constantly available to the Blinky2 thread, which changes it from time to time, and it is made available to the concurrently executing Blinky1 active object via a pointer sent through the event queue.

这个静态事件显然一直对 Blinky2 线程可用，Blinky2 隔三差五就改它，同时它又通过事件队列发出去的指针，被并发执行的 Blinky1 活动对象拿到了。

This is in contrast to the buttonPress event, which is also shared between concurrently executing SysTick interrupt and Blinky2, but that event is *immutable*, can be declared constant, and it lives in ROM.

这跟 `buttonPress` 事件不一样。`buttonPress` 也在 SysTick 中断和 Blinky2 之间共享，但它是**不可变的**（immutable），可以声明为常量，放在 ROM 里就行。

So, the mutability of the ButtonPress event makes all the difference and requires completely different, much more complex approach.

所以，事件的可变性改变了整个局面，需要完全不同、也更复杂的处理方式。

---

The good news is, that the active object framework, like QP in this case, handles most of this complexity for you in a generic, thread safe way.

好消息是，活动对象框架（比如这里的 QP）会以通用的、**线程安全**（thread-safe）的方式帮你处理大部分复杂性。

So, to do this correctly, you need to let the framework allocate the mutable event dynamically via the macro Q_NEW.

要正确地做这件事，你需要通过 `Q_NEW` 宏让框架来**动态分配**（dynamically allocate）可变事件。

This macro allocates an event of the given type and also sets the provided signal in the event, so you don't need to worry about that later.

这个宏会分配指定类型的事件，同时把信号也设好，省得你后面再操心。

The macro returns a pointer to the event, which you need to keep, but it does not need to be static.

宏返回一个指向事件的指针，你需要保留这个指针，但它不需要是静态的。

Now, you don't need to set the signal.

现在不需要手动设置信号了。

And you fill the event parameters as before, remembering that now you have a pointer.

然后像以前一样填充事件参数，记住现在你拿到的是一个指针。

Finally you post the event, as before

最后像以前一样投递事件，

And that's all for creating and posting a mutable event.

创建和投递可变事件就这么多。

---

The reception of the event in Blinky1 does not need to change at all. In particular, you don't need to worry about deleting the dynamically allocated event, because the framework will handle this automatically for you.

Blinky1 里接收事件的代码完全不用改。特别是，你不用操心删除动态分配的事件这件事——框架会自动帮你处理。

The only thing that you still need to do is to initialize the part of the framework that deals with the dynamic events.

你唯一还需要做的，是初始化框架中处理动态事件的那部分。

Specifically, you need to allocate the storage for the dynamic events, which are kept in deterministic, fixed-size event pools. The QP framework can handle many such pools with different sizes, but here you need just one pool for holding events of type ButtonPressEvt.

具体来说，你要为动态事件分配存储空间，这些事件存放在确定性的、固定大小的**事件池**（event pool）里。QP 框架支持多个不同大小的池，但这里你只需要一个池，用来存放 `ButtonPressEvt` 类型的事件。

Once you statically allocate the pool storage, you hand it over to the framework by calling QF_poolInit(), like this.

静态分配好池的存储空间后，调用 `QF_poolInit()` 把它交给框架，像这样。

---

So, this is finally the correct version of event-driven code, free of sharing and mutual exclusion.

这终于是一个正确的事件驱动版本了——没有共享，没有互斥。

Let's quickly test it to see how it performs, especially in real-time

赶紧测一下，看看效果如何，尤其是实时性方面的表现。

Well, as you can see, it looks really good...

嗯，如你所见，效果非常好……

---

Alright! So, here is the summary of today's lesson:

好！来总结一下今天的课程：

Every real-life application eventually needs mutable events, but today you saw that such mutable events must be handled with great care.

任何实际应用最终都会需要可变事件，但今天你看到了，可变事件必须小心处理。

Real-time frameworks, like QP, provide support for deterministic and thread-safe allocation and exchange of mutable events. In fact, this is one of the most valuable services that the framework provides.

像 QP 这样的实时框架，为可变事件的确定性、线程安全分配和交换提供了支持。事实上，这是框架最有价值的服务之一。

The framework creates an abstraction that is often called "Zero-Copy Event Delivery", because from the application perspective it looks like copying events, whereas under the hood the framework performs a clever management of reference-counted events and deterministic event pools.

框架提供了一种通常被称为**零拷贝事件投递**（zero-copy event delivery）的抽象——从应用的角度看，好像是在复制事件，但底层框架其实是对**引用计数事件**（reference-counted events）和确定性事件池做了巧妙的管理。

But as all non-trivial abstractions, this one is also subject to the "Law of Leaky Abstractions", which states that "All non-trivial abstractions, to some degree, are leaky.".

但跟所有非平凡的抽象一样，这个抽象也逃不过"**抽象泄漏定律**"（Law of Leaky Abstractions）——它说的是"所有非平凡的抽象，在某种程度上，都是会泄漏的。"

In case of the "Zero-Copy Event Delivery" abstraction, this means that for it to work correctly, the application needs to obey certain ownership rules, summarized in this lifecycle diagram of a dynamic event.

就零拷贝事件投递这个抽象而言，这意味着要让它正确工作，应用程序必须遵守某些**所有权规则**（ownership rules），这些规则总结在一个动态事件的生命周期图里。

---

At first, all dynamic events are owned by the framework.

一开始，所有动态事件都归框架所有。

An event producer, like Blinky2 here, can gain ownership ow anew event by calling Q_NEW(). At this point, the producer gains the ownership rights with the permission to write to the event.

事件生产者（比如这里的 Blinky2）可以通过调用 `Q_NEW()` 获得一个新事件的所有权。这时生产者拿到了所有权，包括对事件的写入权限。

The event producer might keep changing event as long as it needs, which might be over multiple run-to-completion steps, but eventually the producer must transfer the ownership back to the framework.

生产者可以在需要的时间内一直修改事件，这甚至可以跨越多个运行到完成步骤，但最终必须把所有权交还给框架。

Typically the producer posts or publishes the event. As a special case, the producer might decide that the event is not good, in which case the producer must call the garbage collector explicitly.

通常的做法是投递或发布事件。特殊情况是生产者觉得这个事件不想要了，那就必须显式调用**垃圾回收**（garbage collector）。

After any of these three operations, the producer loses ownership of the event and can no longer access it. For example, changing the event after posting it is NOT allowed.

这三种操作中的任何一种完成之后，生产者就失去了事件的所有权，不能再访问它。比如，投递之后再修改事件是不允许的。

Also, posting or publishing the event again would be wrong, because at this point, the application doesn't have ownership rights to the event anymore.

同样，再次投递或发布也是错的，因为此时应用程序已经没有这个事件的所有权了。

---

The consumer active object gains ownership of the current event "e" when it receives the event.

消费者活动对象收到事件时，就获得了当前事件 `e` 的所有权。

This time, however, the active object gains merely a *read-only* ownership of the event.

不过这次，活动对象获得的只是对事件的**只读**（read-only）所有权。

The consumer active object is also allowed to post or publish the event, and this happens without losing the ownership of the event.

消费者活动对象也可以投递或发布事件，而且不会因此失去所有权。

So, for example, this event posting would be OK. And that publishing in addition would be fine as well.

所以，比如这样投递事件是可以的，再发布一次也没问题。

The ownership ends, however, at the end of the run-to-completion step. So, if the current event has any information that is needed in the future RTC steps, this needs to be saved, typically in the internal attributes of the active object.

但所有权在运行到完成步骤结束时就会终止。所以，如果当前事件里有未来 RTC 步骤需要用到的信息，就必须保存下来——通常保存到活动对象的内部属性中。

---

So, these are the rules that you need to obey. In exchange, the framework will safely and deterministically deliver your mutable events with hard real-time performance, which is superior to the traditional "shared-state concurrency and mutual exclusion" approach.

以上就是你需要遵守的规则。作为回报，框架会安全地、确定性地投递你的可变事件，并提供硬实时性能——这比传统的"共享状态并发加互斥"方案要优越得多。

This concludes this lesson about active objects, mutable events, and real-time. In the next lesson I plan to talk about software tracing, also known as logging.

关于活动对象、可变事件和实时性的内容就到这里。下一课我打算讲**软件追踪**（software tracing），也叫**日志记录**（logging）。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/video-course 下载。

Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course". Thanks for watching!

所有项目也可以在 GitHub 上找到，在 Quantum Leaps 的 "modern embedded programming course" 仓库里。感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Active Object | 活动对象 | 一种事件驱动的并发编程模型，每个对象拥有自己的执行线程和事件队列 |
| Mutable Event | 可变事件 | 创建后参数可以被修改的事件，与不可变事件相对 |
| Immutable Event | 不可变事件 | 创建后不可修改的事件，可以存储在 ROM 中 |
| Run-to-Completion (RTC) | 运行到完成 | 事件处理的执行模型，每个事件处理步骤在处理下一个事件之前完成 |
| Race Condition | 竞态条件 | 多个并发执行流访问共享资源时可能导致不确定结果的情况 |
| Rate-Monotonic Scheduling (RMS) | 速率单调调度 | 一种实时调度策略，周期越短的任务优先级越高 |
| Rate-Monotonic Analysis (RMA) | 速率单调分析 | 用于分析实时系统可调度性的方法 |
| Schedulability Bound | 可调度性界限 | RMS 分析中判断系统是否可调度的 CPU 利用率上限 |
| Deadline | 截止时间 | 实时任务必须完成的最晚时间 |
| Hard Real-Time | 硬实时 | 错过截止时间会导致系统失败或严重后果的实时系统 |
| Mutual Exclusion | 互斥 | 确保同一时刻只有一个执行流可以访问共享资源的机制 |
| Mutex | 互斥量 | 用于实现互斥的同步原语，可能导致阻塞 |
| Priority Ceiling | 优先级上限 | 优先级上限协议中为共享资源分配的最高优先级值 |
| Bounded Priority Inversion | 有界优先级反转 | 高优先级任务被低优先级任务阻塞的时间有上限的情况 |
| Selective Scheduler Locking | 选择性调度器锁定 | 一种非阻塞的互斥机制，通过锁定调度器防止上下文切换 |
| Denial of Service | 拒绝服务 | 系统因资源耗尽或死锁而无法响应的状态 |
| Shared-State Concurrency | 共享状态并发 | 基于共享内存和互斥的并发编程范式 |
| One-shot Timeout | 单次触发超时 | 时间事件只触发一次的超时模式，与周期性超时相对 |
| Event Pool | 事件池 | 框架中用于动态分配事件的固定大小内存池 |
| Zero-Copy Event Delivery | 零拷贝事件投递 | 一种事件投递抽象，通过引用计数避免实际复制事件数据 |
| Reference-Counted Event | 引用计数事件 | 使用引用计数管理生命周期的事件，引用为零时被回收 |
| Law of Leaky Abstractions | 抽象泄漏定律 | 所有非平凡的抽象在某种程度上都会暴露底层细节 |
| Ownership Rules | 所有权规则 | 动态事件生命周期中关于谁有权访问和修改事件的规则 |
| Garbage Collector | 垃圾回收 | 自动回收不再使用的事件内存的机制 |
| Down-cast | 向下转型 | 将基类指针转换为派生类指针的类型转换操作 |
| Upcasting | 向上转型 | 将派生类指针转换为基类指针的类型转换操作 |
| Software Tracing | 软件追踪 | 记录软件执行过程的技术，用于调试和分析 |
| Signal | 信号 | 事件的标识符，用于区分不同类型的事件 |
| Post | 投递 | 将事件发送到特定活动对象事件队列的操作 |
| Publish | 发布 | 将事件广播给所有订阅者的操作 |
| Event Producer | 事件生产者 | 生成并发送事件的组件 |
| Dynamic Allocation | 动态分配 | 在运行时从内存池中分配内存的操作 |
| Q_NEW | Q_NEW 宏 | QP 框架中用于动态分配事件的宏 |
| QF_poolInit() | QF_poolInit() 函数 | QP 框架中用于初始化事件池的函数 |
