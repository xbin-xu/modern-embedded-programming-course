# 第34课：事件驱动编程在实时嵌入式系统中的应用 / Lesson 34: Event-Driven Programming for Real-Time Embedded Systems

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and today I'll continue with event-driven programming, but this time as it applies to real-time embedded systems.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。今天我们继续聊事件驱动编程，不过这次要把目光转向实时嵌入式系统。

In the last lesson 33, you learned the main concepts related to event-driven programming, but they were all in the context of desktop Windows.

上一课你学了事件驱动编程的主要概念，但那些都是在桌面 Windows 环境下讲的。

Also, the whole explanation as to why events should drive the application was entirely based on Graphical User Interface (GUI), and it might not be clear to you, how any of this applies to real-time embedded systems.

而且关于"为什么应该由事件来驱动应用程序"的解释，也全都是围绕图形用户界面（GUI）展开的。你可能心里犯嘀咕：这些跟实时嵌入式系统有什么关系？

So, I'd like to begin today's lesson by going back to the sequential programming with a "superloop" and the Real-Time Operating System (RTOS) that you learned in the segment of eight lessons 21 through 28, because it is the most familiar and still dominating style of programming real-time embedded systems.

所以，今天的课我想先带你回到"超级循环"（superloop）顺序编程和实时操作系统（RTOS）——也就是第 21 到 28 这八节课中学过的内容。这是大家最熟悉的方式，也仍然是当今实时嵌入式编程的主流。

From that starting point, you will see how to gradually apply event-driven concepts and what kind of problems they will help you to solve.

从这个起点出发，你会看到如何一步步引入事件驱动的概念，以及它们能帮你解决哪些问题。

For today, I've prepared an example project very similar to what you used back in lesson 25 about the RTOS, except that today's code is based on Micro-C/OS-2 so that you get exposed to this popular RTOS as well.

我准备了一个示例项目，跟第 25 课 RTOS 中用的差不多，但今天的代码基于 Micro-C/OS-2，这样你也能接触一下这个流行的 RTOS。

Silicon Labs has recently released Micro-C/OS-2 on GitHub under the permissive Apache-2 open source license.

Silicon Labs 最近在 GitHub 上以宽松的 Apache-2 开源许可证发布了 Micro-C/OS-2。

The project for today's lesson is available for download as a ZIP file from the companion web-page to this video course at state-machine.com/quickstart.

今天课程的项目可以从配套网页 state-machine.com/quickstart 下载 ZIP 包。

For today, you will also need to download qpc-dot-ZIP. After downloading you need to unzip both archives into the same directory, like this.

另外还需要下载 qpc.zip。两个压缩包解压到同一个目录下，就像这样。

The slightly modified Micro-C/OS-2 code is included in the qpc\3rd_party folder.

经过少量修改的 Micro-C/OS-2 代码在 `qpc\3rd_party` 目录下。

When you build and run this example, it just blinks the green LED on the TivaC LaunchPad board, but this time you can speed up the blinking by pressing the SW1 button. Additionally, to visualize what's going on with the button, the blue LED is turned on when the button is depressed and is turned off when the button is released.

构建并运行这个示例，你会看到 TivaC LaunchPad 上的绿色 LED 在闪烁。这次多了一个功能：按下 SW1 按钮可以加快闪烁速度。另外，为了让你直观看到按钮的状态，按钮按下时蓝色 LED 点亮，松开时熄灭。

The 'main_blinky' thread in today's code is almost the same as in lesson 25, except is uses the Micro-C/OS `OSTimeDly()` API to block and wait in-line for the specific time delay.

`main_blinky` 线程跟第 25 课几乎一样，区别只是用了 Micro-C/OS 的 `OSTimeDly()` API 来阻塞等待指定的时间延迟。

The time delay used is coming from the 'shared_blink_time' variable, which as the name suggests is shared between the blinky and button threads. To avoid any concurrency hazards around that shared variable, it is protected by a mutual-exclusion mechanism, which happens to be the priority-ceiling mutex of MicroC/OS-II.

延迟时间来自 `shared_blink_time` 变量——顾名思义，它是 blinky 和 button 两个线程共享的。为了避免这个共享变量上的并发风险，用了互斥机制来保护，这里用的是 MicroC/OS-II 的优先级上限互斥量（priority-ceiling mutex）。

The 'main_button' thread also has the usual structure of the endless, while(1) "superloop". Here, the thread waits on the semaphore object that is signaled when the button is pressed.

`main_button` 线程也是经典的无限 `while(1)` "超级循环"结构。在这里，线程等待一个信号量，按钮按下时这个信号量会被触发。

When this happens, the button thread turns the Blue LED on and updates the shared_blink_time variable to speed up the blinking of the green LED in the blinky thread. Again, you see here the use of the Micro-C/OS mutex to protect the access to the shared variable.

信号量触发后，button 线程点亮蓝色 LED，并修改 `shared_blink_time` 变量让 blinky 线程中的绿色 LED 闪得更快。这里同样用了 Micro-C/OS 互斥量来保护共享变量的访问。

After this, the button thread waits again on the semaphore object signaled when the button is released. Immediately after that, the Blue LED is turned off.

之后，button 线程再次等待信号量——这次是按钮松开时触发。紧接着就把蓝色 LED 关掉。

Small as it is, this program demonstrates the general principles by which RTOS applications are designed.

这个程序虽然小，但体现了 RTOS 应用程序设计的通用套路。

The main characteristic of the design is that threads synchronize their execution with various events by means of *blocking* and waiting in-line for a chosen event to occur.

这套设计的核心特征是：线程通过**阻塞**来跟各种事件同步——内联等待某个特定事件发生。

But a blocked thread is unresponsive to any other events not explicitly waited for.

但线程一旦阻塞，对其他没有显式等待的事件就完全没有反应了。

Consequently the main workaround for adding new events is to create more threads, because multiple threads can wait for multiple events in parallel. But this ever growing number of threads quickly becomes very expensive and unmanageable.

所以，要支持更多事件，主要办法就是创建更多线程——多个线程可以并行等待多个事件。但线程越加越多，很快就变得又费资源又难管理。

But even more importantly, the new threads likely need to access the same data, peripherals, or other resources, as the already existing threads. And this leads to *sharing of resources* among threads, such as the shared_blink_time variable.

更要命的是，新线程往往需要访问跟已有线程相同的数据、外设或其他资源。这就导致了线程之间的**资源共享**问题——比如那个 `shared_blink_time` 变量。

Now, you recall that context switching in an RTOS is closely related to interrupt processing, and in fact, an RTOS just hijacks the interrupt processing hardware already available in the CPU to do its magic.

回想一下，RTOS 中的上下文切换跟中断处理密切相关。实际上，RTOS 就是利用 CPU 里现成的中断处理硬件来做它的那些事的。

But that means that threads inherit all the problems of interrupts, including race conditions around any shared resources. Overlooked or unhindered race conditions can lead directly to system failure.

这就意味着线程也继承了中断的所有问题，包括共享资源上的**竞态条件**（race condition）。竞态条件如果被忽视或未加处理，可能直接导致系统崩溃。

So, now, you need to identify and prevent all race conditions. The RTOS actually supports it by providing an assortment of mutual exclusion mechanisms, such as mutexes.

于是你就得找出所有竞态条件并加以防范。RTOS 确实提供了各种互斥机制来帮忙，比如互斥量。

But ironically, these mechanisms often lead to even more blocking, which brings a whole slew of secondary implications.

但讽刺的是，这些机制本身往往又引入了更多的阻塞，随之带来一大堆附带问题。

All this immensely complicates any timing analysis and can lead to missed real-time deadlines, which can ultimately lead to the system failure.

所有这些使得时序分析变得极其复杂，可能导致错过实时截止时间，最终引发系统故障。

For these and other reasons, the experienced software developers learned to be very wary of blocking and instead they apply a set of best practices that drastically reduce the blocking in their software.

因为这些以及其他原因，有经验的开发者对阻塞非常警惕，转而采用一套最佳实践来大幅减少软件中的阻塞。

One of the most succinct formulations of these best practices I found, comes from the C++ and concurrency expert Herb Sutter. Specifically, his article "Prefer Using Active Objects Instead of Naked Threads" contains the following three best practices:

我见过的对这些最佳实践最精炼的总结，来自 C++ 和并发专家 Herb Sutter。他的文章《优先使用活动对象而非裸线程》提出了以下三条最佳实践：

One: Keep data isolated, private to a thread where possible:

**第一：尽可能保持数据隔离，让数据成为线程私有的。**

This really means that threads should avoid sharing of data or resources with other threads, which eliminates the "shared-state concurrency" node in the "perils of blocking" diagram. Without sharing, there is no need for mutual exclusion and the big part of the vicious circle is eliminated.

说白了，就是线程之间尽量不要共享数据或资源。这样就去掉了"阻塞危害"图中"共享状态并发"这个节点。没有共享，就不需要互斥，恶性循环的一大块就被砍掉了。

Of course, "avoid sharing" is easy to say, but how are then the threads supposed to communicate and synchronize?

当然，"不要共享"说着容易——那线程之间怎么通信和同步呢？

Well, this is addressed in the best practice number two: Communicate among threads via asynchronous messages.

这就引出了第二条：**通过异步消息在线程之间通信。**

This best practice packs two important concepts: "messages" or "events" and "asynchronous communication". These are exactly the event-driven concepts you've learned in the past lesson 33. "Event objects", also called "messages", are packaged data specially designed for communication. They carry the information about what happened: for example a "timeout-occurred", or "button-was-pressed".

这条包含了两个重要概念："消息"或"事件"，以及"异步通信"。这正是你在上一课中学到的事件驱动概念。**事件对象**（event objects），也叫"消息"（messages），是专门为通信而设计的数据包。它们携带关于"发生了什么"的信息，比如"超时了"或者"按钮被按下了"。

Additionally, event objects can carry event parameters that pertain to the event. For example, an "ethernet-packet-arrived" event can carry the whole Ethernet data packet as its event parameter. You will see examples of events in a minute.

事件对象还可以携带与事件相关的**参数**。比如，"以太网数据包到达"事件可以把整个以太网数据包作为参数带上。你很快就会看到具体的例子。

"Asynchronous communication" means that senders of events only post the events to the recipients, but they don't wait in-line, meaning don't block, until the event is processed.

"**异步通信**"的意思是：发送方把事件投递给接收方就行了，不会在那儿干等着——也就是不会阻塞——直到事件被处理完。

So, the best practice number two is designed to eliminate the "synchronization by blocking" node from the "perils of blocking diagram".

所以，第二条最佳实践就是要把"阻塞危害"图中"通过阻塞来同步"这个节点去掉。

And finally, the best practice number three: Organize your thread's work around a message pump references directly the event-driven concept of "event loop" also called "message pump", which you learned in the last lesson 33. This best practice goes directly after the blocking node in the diagram.

最后，第三条：**围绕消息泵来组织线程的工作**。这直接用到了上一课学过的事件驱动概念——事件循环，也叫消息泵（message pump）。这条直接针对图中的阻塞节点。

Please note that the "blocking" node cannot be eliminated completely, at least not with a traditional RTOS, because as you remember, every RTOS thread must necessarily block somewhere in its "superloop".

注意，"阻塞"节点无法完全消除——至少在传统 RTOS 上做不到。因为你记得，每个 RTOS 线程都必须在它的"超级循环"中某处阻塞。

But the best practice number three prescribes the only allowed structure of the "superloop" as the "message pump", which restricts the blocking to only one specific place in the loop.

但第三条最佳实践规定了"超级循环"唯一允许的结构就是消息泵——把阻塞限制在循环中唯一的一个位置。

Of course, all these best practices combined establish a design pattern, which is known as the "Active Object" pattern. The pattern is valuable, because it provides a layer on top of naked threads, which otherwise let you do anything including troublesome things. In this pattern, Active Objects, like any other objects, have private data. But each active object also has a private thread and a private event queue.

这些最佳实践合在一起，就构成了一种设计模式——**活动对象模式**（Active Object pattern）。这个模式很有价值，因为它在裸线程之上加了一层约束——裸线程什么都让你做，包括惹麻烦的事。在这个模式中，活动对象跟其他对象一样有私有数据，但每个活动对象还额外拥有一个私有线程和一个私有**事件队列**。

The only way to interact with an active object is by posting events to its event queue. The posting is *asynchronous*, meaning that the event is only placed in the queue, but there is no waiting until the event is processed.

跟活动对象交互的唯一方式就是往它的事件队列里投递事件。投递是**异步的**——事件只是放进队列，不需要等它处理完。

The event processing happens in the event-loop running in the private thread of the active object. The processing might involve sending secondary events to other active objects or even to self.

事件处理发生在活动对象私有线程中的事件循环里。处理过程中可能会向其他活动对象甚至向自身发送后续事件。

In a sense active objects are the most stringent form of object-oriented programming, because the asynchronous communication enables active objects to be truly encapsulated. In contrast, the traditional OOP encapsulation, as provided by C++, C# or Java, does not really encapsulate anything in terms of concurrency.

从某种意义上说，活动对象是面向对象编程最严格的形式，因为异步通信让活动对象能做到真正的封装。相比之下，C++、C# 或 Java 提供的传统 OOP 封装，在并发层面其实什么也没封住。

Any operation on an object runs in the caller's thread and the object's private data are subject to the same race conditions as global data, not encapsulated at all. To become thread-safe, operations need to be explicitly protected by a mutual exclusion mechanism, such as a mutex or a monitor, but this leads to additional blocking and requires special attention from the programmer.

对对象的任何操作都是在调用者的线程中执行的，对象的私有数据跟全局数据一样面临竞态条件——根本没封装住。要变成**线程安全**的，就得用互斥量或监视器之类的机制显式保护，但这又引入了额外的阻塞，还要求程序员格外小心。

In contrast, all private data of an active object are truly encapsulated for concurrency without any mutual exclusion mechanism, because they can be only accessed from the active object's own thread. Note that this encapsulation for concurrency is not a programming language feature, so it is no more difficult to achieve in C++ as in C, but it requires a programming discipline to avoid sharing resources (known as the "shared-nothing principle").

而活动对象的所有私有数据在并发方面是真正封装的，不需要任何互斥机制，因为它们只能从活动对象自己的线程中访问。注意，这种并发封装不是编程语言的特性，所以用 C++ 实现并不比用 C 更容易，它需要的是编程纪律——避免共享资源（即所谓的"**无共享原则**"）。

However, the event-based communication helps immensely, because instead of sharing a resource, a dedicated active object can become the manager or broker of that resource and the rest of the system can access the resource only via events posted to this broker active object.

不过，基于事件的通信对此帮助极大。与其共享一个资源，不如让一个专门的活动对象来当这个资源的管理者或代理者，系统中的其他部分只能通过向这个代理活动对象投递事件来访问该资源。

From the historical perspective, the Active Object design pattern combines the RTOS, object-oriented programming, and event-driven programming. I will call these trends "Modern", as in the title of this whole "Modern Embedded Systems Programming" video course.

从历史角度看，活动对象设计模式把 RTOS、面向对象编程和事件驱动编程结合在了一起。我把这些趋势称为"现代的"——正如这门课的名字"现代嵌入式系统编程"。

This is in contrast to the still dominating "Traditional" approach, based on a traditional RTOS and shared-state-concurrency that dates back to the early 1980's when RTOSes went mainstream.

这与仍然占主导地位的"传统"方法形成对比——后者基于传统 RTOS 和共享状态并发，可以追溯到 80 年代初 RTOS 成为潮流的时候。

Alright, this was a lot of dry theory.

好了，以上是一大堆枯燥的理论。

So, now let's actually see how active objects could be implemented, on top of a traditional RTOS.

现在让我们动真格的——看看在传统 RTOS 之上如何实现活动对象。

Staring from the previous sequentially coded example with MicroC/OS-II, let's now add the Active Object services.

从之前用 MicroC/OS-II 写的顺序代码出发，我们来加上活动对象的服务。

Because the Active Object layer will be based on MicroC/OS, let's call it "MicroC/AO".

既然这个活动对象层建立在 MicroC/OS 之上，就叫它"MicroC/AO"吧。

The minimal implementation of "MicroC/AO" will consist of the UC-underscore-AO-dot-H header file and the UC-underscore-AO-dot-C source file, which I prepared in advance and will quickly review with you today.

MicroC/AO 的最小实现只需要 `uc_ao.h` 头文件和 `uc_ao.c` 源文件，我提前准备好了，今天带你快速过一遍。

The header file includes the MicroC/OS-II RTOS, and adds to it the event facilities.

头文件先包含 MicroC/OS-II RTOS，然后在它上面添加事件相关的设施。

The event signal will be just a small integer, which will hold enumerated signals representing various interesting occurrences in your application. There will be a couple of reserved signals, such as the INIT signal that will be dispatched to each active object right before entering the event loop. The USER signal, will be the first signal available to the users.

**事件信号**（event signal）就是一个小的整数，用来保存枚举值，代表应用程序中各种值得关注的事件。会有几个保留信号，比如 `INIT` 信号——在每个活动对象进入事件循环之前分派给它。`USER` 信号是用户可以使用的第一个信号编号。

Next, you need to define the event structure. It needs to contain the signal, but it also needs to be extensible to fit arbitrary event parameters. This would be accomplished by the object-oriented concept of inheritance, as you learned in lesson 30.

接下来定义事件结构体。它要包含信号，同时还得能扩展以适应各种事件参数。怎么扩展呢？用你在第 30 课学过的面向对象继承。

But just to give you an example use case, a hypothetical `EthernetEvent` could inherit the `Event` base structure and could add the Ethernet packet as the parameter.

举个用例：一个假想的 `EthernetEvent` 可以继承 `Event` 基结构，然后把以太网数据包作为参数加上去。

Next, you need to define the facilities for Active Objects. You start with the forward declaration of the active object struct, followed by the definition of the `DispatchHandler` pointer to function. This will be a "virtual" operation in the Active object class, as you learned in lesson 32 about polymorphism in C.

接下来定义活动对象的设施。先做活动对象结构体的前向声明，然后定义 `DispatchHandler` 函数指针。这就是活动对象类中的"虚"操作——第 32 课讲 C 语言多态的时候提过。

Next, you can define the Active object struct, which, as you recall, needs to have a private thread, and a private event queue.

然后定义活动对象结构体。你记得的，它需要一个私有线程和一个私有事件队列。

For MicroC/OS-II, the thread can be represented by its unique priority.

在 MicroC/OS-II 中，线程可以用它唯一的优先级来表示。

The event queue will be represented with the MicroC/OS-II "OS-Event" pointer. The name "OS-Event" here is a bit of a misnomer, because it means here operating-system object to *deliver* the event instances you just defined above.

事件队列用 MicroC/OS-II 的 `OS_EVENT` 指针来表示。`OS_EVENT` 这个名字有点误导——它在这里其实是操作系统用来**传递**你上面定义的事件实例的对象。

In case of MicroC/OS-II, this operating system object will be a message queue, which is somewhat of an overkill, because it can be potentially both written-to and read-from by multiple threads. In contrast, an event-queue of an active object can be much simpler, because it needs to be read from a single thread only. But, a message queue is the closest approximation of what you need, even though it's a bit more expensive than strictly necessary.

在 MicroC/OS-II 中，这个操作系统对象实际上是一个消息队列，这有点大材小用了——消息队列允许多个线程同时读写。而活动对象的事件队列其实可以简单得多，因为它只需要被一个线程读取。不过消息队列已经是最接近你所需的东西了，虽然开销比严格需要的稍大一点。

Finally, the Active struct contains the pointer to its "dispatch" virtual operation that will be provided in the subclasses. This is the implementation option of polymorphism you saw in lesson 32, where you embed the whole virtual table directly in the class. With just one virtual function "dispatch", this implementation makes the most sense.

最后，Active 结构体包含指向其 dispatch 虚操作的指针，具体实现由子类提供。这是第 32 课讲过的多态实现方式——把整个虚表直接嵌入类中。既然只有一个虚函数 `dispatch`，这种做法最合理。

The specific subclasses of the Active base class will also add their private data through inheritance, in the same way as subclasses of Event add event parameters. These will be the strictly encapsulated private active object data accessible only from the private thread of the active object. You'll see examples of it in a minute.

Active 基类的子类也会通过继承添加私有数据，就像 Event 的子类添加事件参数一样。这些就是严格封装的活动对象私有数据，只能从活动对象自己的线程中访问。马上就会看到例子。

The Active class will have a few public operations, starting with the constructor, which in C is just a regular function that you need to call explicitly.

Active 类有几个公共操作。首先是**构造函数**——在 C 语言中就是一个普通函数，需要你显式调用。

Then, the `Active_start()` operation will start the internal thread of the active object.

然后是 `Active_start()`，用来启动活动对象的内部线程。

And finally, the `Active_post()` operation will asynchronously post events to the active object's event queue.

最后是 `Active_post()`，用来异步地向活动对象的事件队列投递事件。

Now, let's quickly review the implementation of these services in the UC-underscore-AO-dot-C source file.

现在快速看一下 `uc_ao.c` 中这些服务的实现。

Let's begin with the `Active_start()` operation. First, the function creates the internal Micro-C-OS-2 message queue and asserts that the queue was created correctly.

先看 `Active_start()`。函数首先创建内部的 MicroC/OS-II 消息队列，然后断言队列创建成功。

But the most important is how the function creates the internal Micro-C-OS-2 task for the Active object.

但最关键的是它如何为活动对象创建内部的 MicroC/OS-II 任务。

Interestingly, you can see here that *EVERY* active object thread is based on the *SAME* event-loop function defined earlier in the file.

有意思的是，你会发现**每个**活动对象线程都基于**同一个**事件循环函数——这个函数在文件前面已经定义好了。

This is a drastic departure from the traditional way if creating RTOS threads, where each thread runs its own, custom thread function defined in the APPLICATION-level code, outside the RTOS.

这跟传统的 RTOS 线程创建方式截然不同。传统方式中，每个线程运行的是应用层代码中定义的、各自不同的线程函数。

In contrast, here, all Active object threads run exactly the *same* event-loop function defined inside the Active Object module and even made static, to hide it completely in this module.

而在这里，所有活动对象线程运行的是完全**相同的**事件循环函数，这个函数定义在 Active Object 模块内部，甚至被声明为 static，完全隐藏在这个模块中。

This means that the control over the thread function resides in the Active Object module rather than the application. Now, I hope you remember from lesson 33 that such "Inversion of Control" is one of the main characteristics of event-driven programming.

这意味着线程函数的控制权在 Active Object 模块手里，而不是在应用程序手里。还记得第 33 课吧？这种**控制反转**正是事件驱动编程的主要特征之一。

But, while all active objects run the exact same event-loop function, each such function operates on a *different* Active object instance "me", which is passed as the 'pdata' argument to the OSTaskCreateExt MicroC-OS-2 API.

不过，虽然所有活动对象运行同一个事件循环函数，但每个函数操作的是一个**不同的**活动对象实例 `me`——它通过 `pdata` 参数传给 `OSTaskCreateExt` 这个 MicroC/OS-II API。

So now, inside the Active event-loop implementation, which must conform to the MicroC/OS-II task function signature, the 'pdata' void poiner parameter is immediately cast back to Active and assigned to the "me" pointer to give it access to the Active object instance this function works on.

在事件循环的实现内部——它必须符合 MicroC/OS-II 任务函数的签名——`pdata` 这个 void 指针参数被立即转回 Active 类型并赋给 `me` 指针，这样函数就能访问它所操作的活动对象实例了。

The rest of the Active object event-loop code is quite similar to the Windows GUI code you've seen in the last lesson 33, so let's pull that code up for reference.

事件循环的其余代码跟上一课看到的 Windows GUI 代码非常相似，我们把那段代码调出来对比一下。

For example, the initialization of the application, which in Windows GUI happens in the call to CretateWindow, sends the WM_CREATE message to the window proc.

比如应用程序的初始化——在 Windows GUI 中是在调用 `CreateWindow` 时完成的，它会发送 `WM_CREATE` 消息给窗口过程。

In your embedded code, this is accomplished by directly calling the dispatch virtual function via a pointer to function, to which you pass the initial event carrying the reserved INIT signal.

在你的嵌入式代码中，初始化是通过函数指针直接调用 dispatch 虚函数来完成的，传入携带保留 `INIT` 信号的初始事件。

An interesting twist here is related to the chosen Active Object interface, which posts only pointers to events, not the whole event objects by value like it was in Windows.

这里有一个有趣的细节：Active Object 接口只投递指向事件的**指针**，不像 Windows 那样按值投递整个事件对象。

In general case of events that are modified outside a given active object, you must be very careful to avoid race conditions. But events without parameters can be constant and allocated in ROM. Such *immutable* events can be shared freely, because they don't pose any concurrency risks. You will see a few more examples of posting immutable events, later in this lesson.

对于在活动对象外部会被修改的事件，你必须格外小心以避免竞态条件。但不含参数的事件可以是常量，放在 ROM 中。这种**不可变事件**（immutable events）可以随意共享，因为它们不会带来任何并发风险。本课后面你还会看到更多投递不可变事件的例子。

The following code implements the actual event-loop the same way really as the Windows GUI code.

接下来的代码实现了实际的事件循环，方式跟 Windows GUI 代码基本一样。

At the top of the loop, you see the OS-Q-Pend() call that obtains the next event from the active object's event queue. This is the only place in the loop where blocking is allowed, when the queue is empty.

在循环顶部，`OSQPend()` 调用从活动对象的事件队列中取出下一个事件。这是循环中唯一允许阻塞的地方——队列为空时阻塞。

Next, the received event is dispatched to the active object "me" by means of the virtual call via the "me-dispatch" pointer to function.

然后，收到的事件通过 `me->dispatch` 函数指针的虚调用分派给活动对象 `me`。

The final touches of the implementation are the Active object constructor, which simply sets the virtual operation "dispatch".

实现的收尾部分是 Active 对象的构造函数，它做的事情很简单——设置虚操作 `dispatch`。

And finally, the asynchronous event posting to an active object boils down to posting the event to its private event queue.

最后，向活动对象异步投递事件，说白了就是往它的私有事件队列里放事件。

So, this is about it at this point.

到这里，这部分就差不多了。

Now, let's try to use the Active object layer instead of the "naked" Micro-C/OS-II RTOS.

现在来试试用 Active Object 层来代替"裸"的 MicroC/OS-II RTOS。

For starters, let's convert just one of the traditional sequential threads to an Active Object. It turns out that the Button thread is easier with the currently available Active object services. You can keep the original sequential code as a reference for now, but remember that most of it will be deleted after you're done.

先拿一个传统的顺序线程来开刀。用现有的 Active Object 服务来看，Button 线程更容易转换。你可以暂时保留原始的顺序代码作为参考，但记住完成后大部分要删掉。

So first you need to create the Button active object class by inheriting the Active base class as the first member 'super'. The Button active object has no private data, so you don't add any other members to the struct.

首先要创建 Button 活动对象类：把 Active 基类作为第一个成员 `super` 继承。Button 活动对象没有私有数据，所以不需要添加其他成员。

Next, you implement the Button dispatch virtual function, in which you process one event at a time.

然后实现 Button 的 dispatch 虚函数——每次处理一个事件。

Typically, you code the function with the switch statement, which discriminates based on the event signal.

通常用 switch 语句来写，根据事件信号进行分支。

When you receive the special, reserved INIT_SIG signal, you establish the initial state of the Blue LED as off.

当收到特殊的保留信号 `INIT_SIG` 时，把蓝色 LED 的初始状态设为关闭。

When you receive the application specific BUTTON_PRESSED signal, you perform all the actions that you did when the button-press semaphore was signaled.

当收到应用自定义的 `BUTTON_PRESSED` 信号时，执行之前在按钮按下信号量触发时所做的所有操作。

Finally, when you receive the application specific BUTTON_RELEASED signal, you perform the actions that you did when the button-release semaphore was signaled.

最后，当收到 `BUTTON_RELEASED` 信号时，执行之前在按钮释放信号量触发时所做的操作。

So, here you've just seen how to convert the sequential code to event-driven code.

好，你刚刚看到了怎么把顺序代码转换成事件驱动代码。

The most important thing to remember is that in the event-driven code you never block to wait for events. All waiting is external to the dispatch function and happens at the top of the event-loop.

记住最重要的一点：事件驱动代码中，**绝对不要阻塞来等待事件**。所有等待都在 dispatch 函数之外，发生在事件循环的顶部。

The last function you need to define is the constructor of your new Button active class. Here, you have to call the base class' constructor, where you attach the specific Button_dispatch implementation to the virtual dispatch operation.

最后一个要定义的函数是新的 Button 活动类的构造函数。这里必须调用基类的构造函数，把 `Button_dispatch` 的具体实现挂到虚 dispatch 操作上。

This completes the definition of your new Button class, so you can delete the sequential code including the blocking semaphores. But you need to keep the stack, because it is still needed for the internal thread of the Button active object.

Button 类定义完毕。现在可以删掉顺序代码和阻塞用的信号量了。但栈要留着——Button 活动对象的内部线程还需要它。

Apart of that, you also need to provide: the memory buffer for the private event queue of the active object, the instance of the Button active object, and the global pointer to the object so that other parts of the code, such as the BSP, can post events to it.

除此之外，还需要提供：活动对象私有事件队列的内存缓冲区、Button 活动对象的实例，以及一个指向该对象的全局指针——这样代码的其他部分（比如 BSP）才能向它投递事件。

The last change in main-dot-c is to call the Button constructor explicitly and to start the active object by calling the `Active_start()` member function.

`main.c` 的最后修改：显式调用 Button 构造函数，然后调用 `Active_start()` 启动活动对象。

Regarding the BSP -- Board Support Package, you need to replace the blocking semaphores with the definition of the event signals.

至于 BSP（板级支持包），要把阻塞用的信号量替换成事件信号的定义。

And you need to declare the global pointer to the Button active object. Please note that the global pointer is of the type Active, which is the superclass, rather than the specific Button subclass.

还需要声明指向 Button 活动对象的全局指针。注意：这个全局指针的类型是 `Active`——超类——而不是具体的 Button 子类。

This is intentional, to completely encapsulate any private data that the subclass might have inside. The rest of the application simply does not know about any such data and can only interact with the Button instance as a generic Active object.

这是故意的，目的是完全封装子类可能拥有的私有数据。应用程序的其他部分根本不知道这些数据的存在，只能把它当作一个通用的 Active 对象来交互。

In the BSP implementation bsp-dot-c, you need to replace the signaling on the semaphores with posting events to the Button active object. The BUTTON_PRESSED and BUTTON_RELEASED events have no changing parameters, so you can use the immutable, const events in ROM.

在 BSP 实现 `bsp.c` 中，要把信号量的触发替换为向 Button 活动对象投递事件。`BUTTON_PRESSED` 和 `BUTTON_RELEASED` 事件没有可变参数，所以可以使用 ROM 中的不可变 const 事件。

And this is finally all as far as the Button active object is concerned. The compiler still points out a few details to fix, but eventually the project builds cleanly.

Button 活动对象到这里就全部完成了。编译器还会报几个小问题需要修，但最终项目能干净地编译通过。

Please note that the Blinky functionality is still coded with the traditional sequential and blocking Micro-C/OS-2 thread.

注意，Blinky 功能仍然使用传统的顺序阻塞式 MicroC/OS-II 线程。

Alright, I know, you must be really curious to see how all this works. So, let's just load it to the board and run it.

好了，我知道你肯定迫不及待想看效果了。加载到板子上跑一下。

As you can see the Green LED blinks as before, but this is hardly surprising, because this is still the old sequential code.

绿色 LED 跟以前一样闪烁——这不意外，因为这部分还是旧的顺序代码。

But the Button is the new, event-driven active object code. And as you can see, it also works, exactly as before.

但 Button 部分是全新的事件驱动活动对象代码。看到了吗？也能正常工作，效果跟之前一模一样。

So, congratulations, you just implemented your first active object. Very well, so now I'm sure you want to go with all your guns blazing and convert the sequential Blinky thread to an active object as well.

恭喜，你实现了自己的第一个活动对象！好，现在我猜你一定摩拳擦掌，想把 Blinky 线程也转成活动对象了。

Using the existing Button active object as a template, you can just copy and paste that code, and replace Button with Blinky.

拿现有的 Button 活动对象当模板，复制粘贴一份，把 Button 换成 Blinky 就行。

But now, comes the most interesting part, which is the actual implementation of the Blinky_dispatch() operation, where, as you sure remember, you're not allowed to use any blocking calls.

接下来是最有意思的部分——实现 `Blinky_dispatch()` 操作。你肯定记得，这里面不允许用任何阻塞调用。

But herein lies a problem. Button-press and button-release were obvious events, but where is an event in the time delay?

但这里有个问题。按钮按下和松开都是现成的事件，可时间延迟里的事件在哪呢？

Well, *every* blocking call *always* corresponds to an event, even though initially you might not know how to call it. But time delays specifically correspond to Time Events.

其实，**每个阻塞调用都对应着一个事件**，即使一开始你可能不知道该怎么称呼它。时间延迟对应的叫做**时间事件**（Time Event）。

A Time Event is an event that an active object can request to be posted to its event queue in some time in the future. Such functionality does not yet exist in your Micro-C/AO layer, so you need to add it.

时间事件就是活动对象可以请求在未来某个时刻投递到自己事件队列里的事件。你的 MicroC/AO 层还没有这个功能，需要加上。

First, you go to the Micro-C/AO header file, where you add a Time Event class.

先到 MicroC/AO 头文件中添加一个 TimeEvent 类。

Because Time Events are just specialized events, the TimeEvent class inherits Event.

时间事件是一种专门化的事件，所以 TimeEvent 类继承 Event。

But in addition a Time Event must remember the active object that requested the timeout.

除此之外，时间事件还要记住是谁请求了这个超时——也就是对应的活动对象。

And a Time Event must also keep track of the timeout, which will be a down-counter decremented by every system clock tick. When the counter reaches zero, the Time Event will be posted to the active object and the Time Event will be considered disarmed. This also means that the timeout value of zero indicates a disarmed Time Event that is not ticking.

时间事件还要跟踪超时值——这是一个递减计数器，每个系统时钟节拍减一。计数器到零时，时间事件就被投递给活动对象，同时被视为已解除武装。超时值为零就表示一个已解除武装的、不在计时的时间事件。

Finally, often you might want the Time Event to be delivered periodically. This can be quite easily achieved by adding the interval member. This interval would be loaded to the timeout down-counter when it reaches zero. That way, the Time Event will automatically arm itself and will keep ticking towards the next timeout. The interval value of zero will then naturally correspond to a one-shot Time Event that would be automatically disarmed after expiring only once.

通常你还想让时间事件周期性地触发。加一个 interval 成员就行了——当超时计数器到零时，把 interval 的值加载回去。这样时间事件就会自动重新武装，继续向下一个超时计时。interval 为零自然就对应**一次性时间事件**——到期一次后自动解除武装。

The Time Event will have a few public operations, such as the constructor, as well as the arm and disarm operations. Finally, the class-wide operation TimeEvent-tick would be a "static" class operation without the "me" pointer for the specific instance. It will service all instances of the Time Event class every system clock tick.

时间事件有几个公共操作：构造函数、arm（武装）和 disarm（解除武装）。还有一个类级别的操作 `TimeEvent_tick`——这是一个"静态"操作，不需要 `me` 指针，每个系统时钟节拍调用一次，服务所有 TimeEvent 实例。

Now, regarding the implementation of the TimeEvent operations in Micro-C-A-O-dot-C, I'll use a very simple approach.

在 `uc_ao.c` 中实现 TimeEvent 操作时，我用了很简单的做法。

To keep track of all Time Event instances in the system I will simply use a static array of pointers sized for some maximum number of Time Events and the actual number of Time Events registered so far. I like to add a prefix l-underscore to indicate that these variables are local to the module.

为了跟踪系统中所有的时间事件实例，我用了一个静态指针数组，大小设为某个最大时间事件数，再加上一个记录已注册数量的计数器。我喜欢加 `l_` 前缀表示这些变量是模块内部的。

Then, in the TimeEvent constructor, you initialize the data members as usual, but you also store the TimeEvent pointer in your local array and you increment the actual number of TimeEvents "registered" in the system.

在 TimeEvent 构造函数中，照常初始化数据成员，同时把 TimeEvent 指针存到局部数组里，并递增已注册的 TimeEvent 计数。

An important consideration here is to realize that the local variables can be implicitly shared among concurrent RTOS threads and also system clock tick interrupt, through the interface of the TimeEvent operations. This means that there is a potential for race conditions around these variables, so you need to apply some mutual exclusion protection around them.

这里有个重要问题需要注意：这些局部变量会通过 TimeEvent 操作的接口，被并发的 RTOS 线程和系统时钟节拍中断隐式共享。也就是说这里有竞态条件的风险，需要加互斥保护。

Here, you can use the fast Micro-C/OS-II critical section mechanism, because the access is very short. This is exactly the same mechanism that Micro-C/OS-II itself uses internally in its own source code to protect its internal variables.

这里可以用 MicroC/OS-II 的快速**临界区**（critical section）机制，因为访问时间很短。MicroC/OS-II 自己的源代码中保护内部变量用的也是这个机制。

This leads to an interesting observation that, in a sense your active object layer is an event-driven *extension* of a traditional RTOS. As such an extension, it poses similar challenges as other parts of the RTOS code, for example, avoiding internal race conditions.

这引出了一个有趣的观察：从某种意义上说，你的活动对象层是传统 RTOS 的事件驱动**扩展**。既然是扩展，就面临着跟 RTOS 代码其他部分类似的挑战——比如避免内部竞态条件。

But going back to the TimeEvent "arm" operation, it simply sets the timeout and interval members inside a critical section. Similarly, the TimeEvent "disarm" operation clears the timeout to zero, also in a critical section.

回到 TimeEvent 的 arm 操作——它只是在临界区内设置 timeout 和 interval 成员。disarm 操作类似，在临界区内把 timeout 清零。

Finally, the most interesting class-wide TimeEvent-tick operation goes over all the registered Time Event instances.

最后看最有趣的类级别操作 `TimeEvent_tick`——它遍历所有已注册的时间事件实例。

This function is intended to be called from the system clock tick interrupt, which can never be preempted by any RTOS thread. Therefore, it does not need a critical section.

这个函数从系统时钟节拍中断中调用，而中断不会被任何 RTOS 线程抢占，所以不需要临界区。

Each time event is first checked whether it is armed. And if so, its timeout counter is decremented and checked again if it just has reached zero.

每个时间事件先检查是否已武装。如果是，就递减超时计数器，然后检查是否刚好到了零。

If so, the time event is posted to the active object and the timeout counter is reloaded from the interval data member. This works for both periodic time events and one-shot time events, when the interval is zero.

到了零就把时间事件投递给活动对象，然后从 interval 成员重新加载超时计数器。周期性时间事件和一次性时间事件（interval 为零）都适用。

The last modification you should not forget is to add the TimeEvent_tick call to the system clock tick Micro-C/OS-II callback, so that the registered time events are serviced.

最后别忘了：把 `TimeEvent_tick` 调用加到 MicroC/OS-II 的系统时钟节拍回调中，这样已注册的时间事件才能得到服务。

Alright, so this was the extension of the Active Object layer. Now let's use it to implement your Blinky AO.

好，Active Object 层的扩展完成了。现在用它来实现 Blinky 活动对象。

The Blinky active object clearly needs a time event, so let's add one TimeEvent instance as its private data.

Blinky 活动对象显然需要一个时间事件，所以在它的私有数据中加一个 TimeEvent 实例。

As all private data members, the TimeEvent member needs to be initialized in the constructor, where it becomes associated with the active object "me->super" and gets the signal TIMEOUT, defined in bsp-dot-h.

跟所有私有数据成员一样，TimeEvent 要在构造函数中初始化——把它跟活动对象 `me->super` 关联起来，并赋予 `bsp.h` 中定义的 `TIMEOUT` 信号。

So, now you have the event signal for your timeout and you can write the case statement for it. As usual, you copy a portion of sequential code upto the blocking call.

好了，现在有了超时事件的信号，可以为它写 case 分支了。照老办法，把顺序代码中阻塞调用之前的部分复制过来。

But here comes a problem. Should you turn the LED on or off? I mean, in the sequential code you had *two* blocking calls--one for LED-on time and the other for the LED-off time. But here, in the event-driven code you have only one TIMEOUT event and need to know whether the LED was most recently on or off.

但问题来了：应该开 LED 还是关 LED？我是说，在顺序代码中有**两个**阻塞调用——一个控制开灯时间，一个控制关灯时间。但事件驱动代码中只有一个 `TIMEOUT` 事件，你得知道 LED 最近是开着还是关着的。

This information needs to be stored in such a way that it would survive the calls and *returns* from the dispatch operation. This means that it definitely cannot live on the stack as an automatic variable.

这个信息必须能在 dispatch 操作的调用和返回之间存活下来。所以它绝对不能放在栈上当自动变量。

Instead, the ideal place for it is the private data in your active object class, where you add the isLedOn boolean flag. Assuming that the LED is initially off, you can set the flag accordingly in the constructor.

最理想的位置是活动对象类的私有数据——加一个 `isLedOn` 布尔标志。假设 LED 初始为关闭，在构造函数中把标志设好。

Now, in the TIMEOUT case, you first check the flag, and if it indicates that the LED is not on yet, you turn it on and remember this change in the flag. Then you arm your time event to expire in bt clock ticks.

在 `TIMEOUT` 分支中，先检查标志。如果 LED 还没开，就打开它并更新标志。然后武装时间事件在 `bt` 个时钟节拍后到期。

Otherwise, you turn the LED off and set the flag accordingly. Here, you arm your time event to expire in 3 times bt clock ticks.

否则就关掉 LED 并更新标志。这时武装时间事件在 3 倍 `bt` 个时钟节拍后到期。

But this code has still a basic flaw.

但这段代码还有一个根本缺陷。

The TimeEvent is armed only in the TIMEOUT case, but this case executes only when TIMEOUT event occurs. So, you need to somehow "prime the pump" so to speak, so that the TimeEvent gets armed the first time.

TimeEvent 只在 `TIMEOUT` 分支中武装，但这个分支只有在 `TIMEOUT` 事件发生时才会执行。也就是说你得想办法"启动水泵"——让 TimeEvent 第一次被武装起来。

And this is exactly where you can take advantage of the INIT event, dispatched to every active object right before entering its event loop.

这正是 `INIT` 事件的用武之地——每个活动对象进入事件循环之前都会收到它。

Here, you can explicitly turn the LED on, set the isLedOn flag and arm the Time Event. But this is just repeating what is happening in the TIMEOUT case when the flag is cleared.

你可以在这里显式打开 LED、设置 `isLedOn` 标志并武装时间事件。但这不就是重复了 `TIMEOUT` 分支中标志为清除时的操作吗？

So, your other option is just to intentionally fall-through from INIT to TIMEOUT.

所以另一个办法是：故意让 `INIT` 分支**穿透**（fall-through）到 `TIMEOUT`。

Now, you still need to move the shared_blink_time stuff before the new Blinky active object, remove the sequential code, and start the Blinky AO instead of the sequential blinky thread.

接下来还要把 `shared_blink_time` 相关的代码移到新的 Blinky 活动对象之前，删掉顺序代码，用启动 Blinky 活动对象代替启动顺序 blinky 线程。

Of course, now you want to see if the code still works, and... both Blinky and Button active objects work as expected.

当然，现在该验证一下了……Blinky 和 Button 两个活动对象都工作正常。

Now, as the very last exercise in this lesson, I'd like you to take a critical look at the two Active objects you've created.

作为本课的最后一个练习，我想让你审视一下刚才创建的两个活动对象。

They came to be only because you have translated the sequential design from the conventional RTOS to active objects. But the real and only reason why you ended up with two active objects is that sequential "superloops" were not composable due to unresponsiveness.

它们之所以存在，只是因为你把传统 RTOS 的顺序设计翻译成了活动对象。但你之所以需要两个活动对象，真正唯一的原因是：顺序的"超级循环"由于无响应性而没法组合在一起。

Making them composable again was the whole reason for existence for an RTOS, at the expense of creating multiple threads.

让它们重新变得可组合——这正是 RTOS 存在的全部理由，代价是创建多个线程。

But all this does not apply to event-driven code, which remains responsive to all events. This means that event-driven code IS directly composable.

但事件驱动代码不存在这个问题——它对所有事件都保持响应。也就是说，事件驱动代码**天然可组合**。

Well, in that case you should be able to merge Blinky and Button together into just *one* active object.

既然如此，你应该能把 Blinky 和 Button 合并成**一个**活动对象。

So, let's actually do it right now, starting with renaming Blinky to BlinkyButton.

说干就干——先把 Blinky 改名为 BlinkyButton。

Next, you need to move any private data, if present, from the Button class to BlinkyButton.

然后把 Button 类中的私有数据（如果有的话）搬到 BlinkyButton 中。

And you need to move all events handled by Button to the BlinkyButton_dispatch operation. Any duplicate cases need to be merged, such as event handling in INIT.

把 Button 处理的所有事件搬到 `BlinkyButton_dispatch` 操作中。重复的分支需要合并——比如 INIT 中的事件处理。

But wait a second. Now the shareed-blink-time is no longer really *shared* between threads! Instead, the variable can become internal, fully encapsulated, private data inside the BlinkyButton active object.

等等——`shared_blink_time` 不再在线程之间**共享**了！它可以变成 BlinkyButton 活动对象内部的、完全封装的私有数据。

As all other member variables, blink-time needs to be initialized in the constructor.

跟其他成员变量一样，`blink_time` 要在构造函数中初始化。

And since there can be no race conditions around blink-time anymore and you can get rid of the mutex protection. This not only reduces the overhead, but eliminates any potential blocking in the event-driven code. Thus the code has a more predictable timing and is better suited for hard real-time applications.

`blink_time` 上不再有竞态条件了，互斥量保护也可以去掉。这不仅减少了开销，还消除了事件驱动代码中所有可能的阻塞。代码的时序更加可预测，更适合**硬实时**应用。

So you replace the shared-blink-time variable with me->blink_time private attribute, cleanup the temporary variables, and get rid of the mutex.

用 `me->blink_time` 私有属性替换共享的 `shared_blink_time`，清理临时变量，删掉互斥量。

Now you can simply delete the Button active object altogether. Note that by doing so, you free up significant RAM for the stack and the queue buffer.

现在可以直接删掉 Button 活动对象了。注意这样做会释放不少 RAM——栈和队列缓冲区的空间都省了。

Obviously now, you no longer need to create or start the Button active object.

显然也不再需要创建或启动 Button 活动对象了。

You still need to make a few name changes to fix the syntax... And finally, as the compiler reminds you, you need to change the global AO_button pointer to AO_blinkyButton.

还得改几个名字来修复语法……最后，编译器会提醒你把全局指针 `AO_button` 改成 `AO_blinkyButton`。

Of course, the very last thing to do is to verify that the final code still works as before.

当然，最后一件事是验证最终代码是否仍然正常工作。

And indeed, it does...

确实没问题……

I hope that this exercise demonstrates the following two properties of active objects:

我希望这个练习展示了活动对象的两个特性：

First: an active object can hold much more functionality than a traditional, blocking thread, because you no longer need to create expensive threads just to make them responsive to events.

**第一**：一个活动对象能容纳比传统阻塞线程多得多的功能——你不再需要仅仅为了让代码响应事件就去创建昂贵的线程。

And second, the ability to combine functionality inside event-driven active objects makes it much easier to avoid sharing of resources among them than the traditional blocking threads.

**第二**：事件驱动活动对象内部可以自由组合功能，这让避免它们之间的资源共享变得比传统阻塞线程容易得多。

In summary, I realize that this lesson grew to be a little longer than usual, but really a lot happened today. You experienced nothing short of a paradigm shift from traditional sequential programming with an RTOS -- concepts that essentially didn't change since the early 1980's, to modern, event-driven active objects.

总结一下：我知道这节课比平时长了一些，但今天确实发生了很多事情。你经历了一次从传统 RTOS 顺序编程到现代事件驱动活动对象的**范式转变**——前者自 80 年代初以来几乎没有变化。

Not only this, you actually started to build your own active object framework called here MicroC/AO, which is very different from an RTOS because it is based on inversion of control.

不仅如此，你还开始构建自己的活动对象框架——MicroC/AO。它跟 RTOS 完全不同，因为它基于控制反转。

In your framework you used a few services from the traditional RTOS kernel, such as threads and message-queues. But a traditional RTOS does not provide much else needed in event-driven programming, which you had to create yourself.

框架中用到了传统 RTOS 内核的一些服务，比如线程和消息队列。但传统 RTOS 在事件驱动编程方面能提供的不多，大部分需要自己动手。

At the same time, most mechanisms provided in a traditional RTOS are of no use in programming the event-driven active objects. Not only they are not helpful, they can be outright harmful, because most of them are based on *blocking*, which is not allowed inside active objects.

同时，传统 RTOS 提供的大部分机制在编写事件驱动活动对象时根本用不上。不但没用，还可能有害——因为它们大多基于**阻塞**，而活动对象中不允许阻塞。

At the end of the day, even though a traditional RTOS can be used to implement an event-driven framework, it is not the best fit. I will hopefully get back to this in the future lessons.

归根结底，传统 RTOS 虽然能用来实现事件驱动框架，但并不是最合适的选择。希望在后续课程中能回到这个话题。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Active Object | 活动对象 | 一种设计模式，封装私有数据、私有线程和事件队列，通过异步事件通信 |
| Event-driven programming | 事件驱动编程 | 程序流程由事件驱动而非顺序执行 |
| Superloop | 超级循环 | 嵌入式系统中常见的无限 while(1) 循环结构 |
| RTOS | 实时操作系统 | 为实时应用提供服务的操作系统，如 MicroC/OS-II |
| Blocking | 阻塞 | 线程因等待某个条件而暂停执行 |
| Race condition | 竞态条件 | 多个执行流并发访问共享资源导致不确定结果 |
| Mutex | 互斥量 | 保护共享资源免受并发访问的同步机制 |
| Semaphore | 信号量 | 线程间同步的计数机制 |
| Inversion of Control | 控制反转 | 框架而非应用代码控制程序执行流 |
| Message pump / Event loop | 消息泵 / 事件循环 | 不断从队列取出并处理事件的循环结构 |
| Asynchronous communication | 异步通信 | 发送方投递消息后不等待处理完成 |
| Shared-nothing principle | 无共享原则 | 各执行单元之间不共享可变状态 |
| Time Event | 时间事件 | 在未来某时刻自动投递到活动对象队列的专用事件 |
| Immutable event | 不可变事件 | 内容不可更改的事件，可安全共享 |
| One-shot / Periodic Time Event | 一次性 / 周期性时间事件 | 一次性到期后解除武装；周期性到期后自动重新武装 |
| Critical section | 临界区 | 不可被中断或抢占的代码段 |
| Priority-ceiling mutex | 优先级上限互斥量 | 具有优先级上限协议的互斥量，防止优先级反转 |
| Down-counter | 递减计数器 | 从初始值递减至零的计数器 |
| Paradigm shift | 范式转变 | 编程方法的根本性转变 |
| Context switching | 上下文切换 | RTOS 在线程间切换时保存和恢复处理器状态 |
| BSP (Board Support Package) | 板级支持包 | 针对特定硬件板的底层驱动代码 |
| Encapsulation (for concurrency) | 并发封装 | 通过限制数据只在单一线程中访问来实现线程安全 |
