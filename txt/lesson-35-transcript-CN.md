# 第35课：状态机入门 / Lesson 35: Introduction to State Machines

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and today I'd like to start a new segment of lessons about STATE MACHINES. This subject is closely related to event-driven programming and active objects introduced in the last lesson.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，今天我们开始一个新的系列课程——状态机（State Machine）。这个主题和上一讲介绍的事件驱动编程（Event-Driven Programming）以及活动对象（Active Object）密切相关。

---

As it is actually a continuation, let's get started by copying the previous code for lesson-34 to lesson-35.

既然是延续上一讲的内容，我们先把 lesson-34 的代码复制到 lesson-35 目录。

---

Get inside the new lesson-35 directory and double-click on the project "lesson" to open it in the ARM/KEIL micro-Vision IDE.

进入 lesson-35 目录，双击工程文件 "lesson"，在 ARM/KEIL micro-Vision IDE 中打开它。

---

To remind you quickly what happened so far, in the last lesson, you've learned about the best practices of concurrent programming, and the Active Object design pattern that naturally implements and automatically enforces these best practices.

简单回顾一下。上一讲我们学习了并发编程的最佳实践，以及活动对象设计模式——这个模式天然地实现了这些最佳实践，而且会自动强制执行。

---

You also started to build your own, event-driven, Active Object framework, called Micro-C-A-O, because it was based on the traditional Micro-C-OS-2 RTOS, which you then applied to build a small Blinky-Button application.

我们还动手搭建了自己的事件驱动型活动对象框架，取名叫 Micro-C-AO，因为它基于传统的 Micro-C-OS-2 实时操作系统（RTOS）。随后用这个框架做了一个 Blinky-Button 小应用。

---

But already that small example showed some looming problems with the event-driven approach. Specifically, the part of the code that blinks the Green-LED required you to invent a boolean flag that was called isLedOn, and which you needed to remember the state of the Green-LED between the TIMEOUT events.

但就这么一个小例子，已经暴露出事件驱动方式的一些隐患。具体来说，闪烁绿色 LED 的那段代码里，你必须特意发明一个布尔标志变量 isLedOn，用来在两次 TIMEOUT 事件之间记住绿色 LED 当前是亮还是灭。

---

Please note that this boolean flag was NOT needed in the original RTOS thread, because in a sequential code the waiting between events happened by means of BLOCKING inside the OSTimeDly() function. After receiving the expected event the code unblocked and simply handled the event, because you knew exactly which event was received. Therefore, you didn't need to do anything special to remember where in the sequence of events you were.

请注意，在原来基于 RTOS 线程的实现中，这个布尔标志根本不需要。因为顺序代码中，事件之间的等待是通过在 OSTimeDly() 函数里阻塞（Blocking）来实现的。收到预期的事件后，代码解除阻塞，直接处理就行——你很清楚收到的是哪个事件，所以不需要任何特殊手段来记住"我执行到事件序列的哪个位置了"。

---

This is an example of maintaining the context between events naturally and automatically. As it turns out, this automatic context management is quite expensive, because, as you recall from the previous lessons about the RTOS, the context of a thread during a blocking call requires a whole private stack in the precious RAM. But the automatic context management surely is convenient, if you can live with hard-coded event sequences.

这就是在事件之间自动维护上下文（Context）的一个例子。不过，这种自动上下文管理的代价可不低——回忆一下之前讲 RTOS 的内容，线程在阻塞调用期间的上下文需要占用一整块私有栈空间，而这些宝贵的 RAM 资源是很有限的。当然，如果你能接受硬编码的事件序列，自动上下文管理确实方便。

---

All this is in stark contrast to event-driven code, which cannot block, and instead has to *return* to the event loop after every event. Such code obviously loses the stack context between events. Consequently, event-driven systems tend to use less stack space, but instead require a different form of preserving the context from one event to the next.

事件驱动代码则完全不同——它不能阻塞，每处理完一个事件就必须返回事件循环（Event Loop）。这样一来，栈上的上下文在事件之间自然就丢失了。所以事件驱动系统通常占用更少的栈空间，但需要用其他方式来保存事件之间的上下文。

---

The most popular is the manual context management, where programmers invent flags and variables, such as your isLedOn flag in your Blinky active object.

最常见的就是手动上下文管理——程序员自己发明各种标志和变量，比如你之前在 Blinky 活动对象里写的 isLedOn。

---

This approach seems to work initially, and the isLedOn flag certainly didn't loom as a big problem in a simplistic Blinky-Button event-driven active object.

刚开始看起来还行，在 Blinky-Button 这么简单的事件驱动活动对象里，一个 isLedOn 标志似乎也不是什么大问题。

---

But in most real-life programs, such approach is almost guaranteed to degenerate into unwieldy "spaghetti" code, which I'd like to quickly demonstrate with the event-driven Visual Basic calculator example.

但在大多数实际项目中，这种做法几乎注定会退化成难以维护的"意大利面条"式代码。我想用一个事件驱动的 Visual Basic 计算器例子来快速演示一下。

---

I understand that this is not an embedded system and is not even written in C, but it illustrates well the main problems, without the need to explain how a calculator like that is supposed to work.

我知道这不是嵌入式系统，甚至不是用 C 写的，但它能很好地说明核心问题，而且不需要解释计算器本身该怎么工作。

---

So the Visual Basic 4-operation calculator obviously adds, subtracts, multiplies, and divides.

这个 Visual Basic 四则运算计算器，当然能做加、减、乘、除。

---

But if you try some less usual sequences of key-presses, you would discover quite a few "corner cases" leading to crashes or misleading behavior.

但如果你尝试一些不太常见的按键顺序，就会发现不少"边界情况"会导致崩溃或行为异常。

---

One such "corner case" is the following sequence of operations:

比如下面这组操作：

3, +, -, = 4, =.

3, +, -, = 4, =.

---

The calculator crashes with "Run-time error 13".

计算器直接崩溃，报"运行时错误 13"。

---

One might argue that this is a meaningless sequence of events, but at the same time it is also obvious that no user actions should crash the software like that.

你可以说这组操作毫无意义，但同样明显的是，任何用户操作都不应该让软件这样崩溃。

---

So, the calculator apparently has trouble correctly responding to events in different contexts.

所以，这个计算器显然在处理不同上下文下的事件时出了问题。

---

But if you look at the underlying code, you will find out that managing the context is really the central concern here and most of the code is devoted to it.

但如果你看看底层代码，会发现管理上下文才是这里的核心问题，大部分代码都在做这件事。

---

Even though you might not be familiar with Visual Basic, I hope you can recognize a bunch of variable declarations with the sole purpose to remember the current context.

虽然你可能不熟悉 Visual Basic，但我希望你能看出，有一大堆变量声明，唯一的目的就是记住当前的上下文。

---

For example, the DecimalFlag remembers whether the decimal point has been entered to avoid displaying multiple decimal points in a number. Similarly, the NumOps variable remembers the number of operands entered so far, to distinguish between the first and second operand in an expression. And so on.

比如，DecimalFlag 记住是否已经输入了小数点，防止一个数字里出现多个小数点。类似地，NumOps 变量记住目前输入了几个操作数，用来区分表达式中的第一个和第二个操作数。诸如此类。

---

Then, there are a bunch of event-handler subroutines each designed to handle a group of related keypress events. For example, the minus-key that confused the calculator before, is handled in the subroutine Operator_Click(), which handles the plus, minus, multiply and divide keys and happens to be the most complex one.

然后还有一堆事件处理子程序，每个负责处理一组相关的按键事件。比如之前把计算器搞晕的减号键，就在 Operator_Click() 子程序里处理。这个子程序同时处理加、减、乘、除四个键，也是其中最复杂的一个。

---

Here you can see that the various flags and variables are checked in nontrivial conditions, then modified and re-checked again, so that it is really hard to know for sure which path through the code will be taken in a given situation.

你会看到各种标志和变量在复杂的条件里被检查，然后被修改，然后再被检查。根本搞不清在某种具体情况下代码到底会走哪条路径。

---

Apparently, a 4-operation calculator is already complex enough to reach the limit of such manual context management, because attempts to fix one bug tend to create another.

显然，一个四则运算计算器已经复杂到手动上下文管理的极限了——修一个 bug 往往会引入另一个。

---

The real problem here is that the variables and flags provide too much of redundant and poorly organized information, which then can easily become internally inconsistent.

根本问题在于，这些变量和标志提供了太多冗余且组织混乱的信息，很容易导致内部状态不一致。

---

But the improvised context management reflects the correct intuition of the software developers that you don't need to remember the *whole* history of past events, only certain *aspects* of it.

不过，这种临时拼凑的上下文管理也反映了开发者一个正确的直觉——你不需要记住过去所有事件的完整历史，只需要记住其中的某些方面就够了。

---

Specifically, to handle events correctly you just need to remember the *relevant history*, which is only what influences the *future* behavior of the system, and events don't contribute equally to that relevant history.

具体来说，要正确处理事件，你只需要记住相关历史——也就是那些会影响系统未来行为的信息。而且，不同事件对这段相关历史的贡献是不一样的。

---

For example, an electronic controller for a computer keyboard generates either lower-case or upper-case key codes. This behavior depends on whether the Shift key has been pressed or released, but it doesn't matter which other keys have been pressed or released, or how many of them were pressed.

举个例子，电脑键盘的电子控制器要么生成小写键码，要么生成大写键码。这个行为取决于 Shift 键当前是按下还是松开的状态，至于其他键按了什么、按了多少个，完全无关紧要。

---

Therefore, the whole relevant history of the keyboard can be reduced just to two classes: the "normal" class, where the keys generate lower-case codes, and the "shifted" class, where the same keys generate upper-case codes.

因此，键盘的整个相关历史可以归纳为两个类别：一个是"常规"类，按键生成小写码；另一个是"上档"类，同样的按键生成大写码。

---

Which leads to the most important concept of "State".

这就引出了最重要的概念——"状态"（State）。

---

"State" of a system is an *equivalence class* of past histories of a system, all of which are equivalent in the sense that the future behavior of the system given any of these past histories will be identical.

系统的"状态"是系统过去历史的等价类（Equivalence Class）。所谓等价，就是说给定其中任何一个过去历史，系统未来的行为都完全相同。

---

Thus the concept of "State" is the most efficient representation of the relevant history. It is the minimum information that captures only the relevant aspects for the future behavior and abstracts away all irrelevant aspects.

因此，"状态"是对相关历史最高效的表示。它用最少的信息，只保留对未来行为有影响的方面，把无关的方面全部抽象掉。

---

The concept of "State" naturally leads to the concept of "State Machine", which is the set of all states, that is equivalence classes of relevant histories, plus the rules for changing from one state to another. These rules are called *transitions* and capture the fact that some events contribute to the relevant history while others do not. Those events influencing the future behavior trigger the state transitions.

"状态"的概念自然引出了"状态机"的概念。状态机是所有状态的集合——即相关历史的等价类——加上从一个状态变到另一个状态的规则。这些规则叫作转换（Transition），它们体现了这样一个事实：有些事件会影响相关历史，有些不会。那些影响未来行为的事件会触发状态转换。

---

A very nice aspect of the "State Machine" concept is its compelling graphical representation in form of state diagrams. In the modern- Unified Modeling Language (UML) notation, states are represented as rounded-corner rectangles with the name of the state in the name compartment and regular state transitions are represented as arrows labeled by the triggering events.

状态机概念的一大优点是它有非常直观的图形表示，即状态图（State Diagram）。在现代统一建模语言（UML）记法中，状态用圆角矩形表示，名称写在名称区域里；常规的状态转换用箭头表示，箭头上标注触发事件。

---

In the UML you can also have so called "internal transitions", which do not cause change of state but only execute *actions* in response to a given event. These are represented just as triggering events inside states.

UML 中还有所谓的"内部转换"（Internal Transition），它不会改变状态，只是在响应某个事件时执行动作（Action）。内部转换直接写在状态内部。

---

The *actions* are listed after the slash character and are allowed on both kinds of transitions, internal and regular.

动作写在斜杠（/）后面，两种转换——内部转换和常规转换——都可以带动作。

---

Additionally, every state machine needs to have an initial transition that points to the default state, which is active when the state machine is created and before any events are dispatched to it.

此外，每个状态机都需要一个初始转换（Initial Transition），指向默认状态。状态机刚创建时、还没有任何事件分发给它之前，就处于这个默认状态。

---

A state machine can have many more features, and there are many kinds of state machines used in software, including the modern hierarchical state machines also known as UML statecharts. I'm going to cover some of the most important variants of state machines in the future lessons.

状态机还有很多其他特性，软件中使用的状态机也有多种类型，包括现代的层次式状态机（Hierarchical State Machine），也叫 UML 状态图（Statechart）。后续课程我会覆盖最重要的几种状态机变体。

---

But for today, I just want you to remember one universal feature in all state machine formalisms, and that is the Run-to-Completion event processing. RTC means that a state machine can process only one event at a time, so the processing of one event must necessarily end before the processing of the next event can begin.

不过今天，我希望你记住所有状态机形式体系中的一个通用特性——运行到完成（Run-to-Completion，RTC）事件处理。RTC 的意思是，状态机一次只能处理一个事件，必须把一个事件处理完毕，才能开始处理下一个。

---

Well, surprise, surprise, the RTC semantics universally assumed in all state machine formalisms matches exactly the RTC semantics assumed in all event-driven systems, such as Active Objects you've learned in the last lesson. So, in other words, state machines are an ideal mechanism to specify the behavior of Active Objects.

有意思的是，所有状态机形式体系都假设的 RTC 语义，正好和所有事件驱动系统（比如上一讲学的活动对象）的 RTC 语义完全一致。换句话说，状态机是描述活动对象行为的理想机制。

---

As an example, let's build the state machine representing the behavior of your BlinkyButton active object, but without the isLedOn flag.

作为例子，我们来构建 BlinkyButton 活动对象的状态机，但不再使用 isLedOn 标志。

---

For this, I will use the freeware QM graphical modeling tool from my company, Quantum Leaps. This is not to say that you necessarily need such tools to apply state machines. A piece of paper or a whiteboard for drawing state diagrams is completely adequate, especially in the beginning.

为此，我会用我公司 Quantum Leaps 开发的免费图形建模工具 QM。这并不是说你必须用这种工具才能用状态机——一张纸或一块白板画状态图完全够用，特别是刚开始的时候。

---

But for a screencast like this, an electronic drawing tool is more convenient. Also, while you certainly know how paper and pencil work, it might be more interesting for you to see how to use a graphical modeling tool.

不过在像这样的屏幕录像里，电子绘图工具更方便。而且，虽然你肯定知道纸笔怎么用，但看看图形建模工具怎么操作可能更有意思。

---

When you launch QM for the first time, it opens the New Model dialog box, whereas you can choose from a few models as your starting points. One of them: Blinky, seems close enough to what you are doing, so let's select that one.

首次启动 QM 时，会弹出"新建模型"对话框，你可以从几个模板中选择一个作为起点。其中有一个叫 Blinky 的模板，跟我们正在做的很接近，就选它吧。

---

Next you can re-name your new model to BlinkyButton and you can choose the location of your model as the directory of today's lesson.

接下来把模型重命名为 BlinkyButton，保存位置选今天课程的目录。

---

OK, so the model already comes with a Blinky state machine, but I'll delete it so that you can see how a state machine like that is built from scratch.

好，模型里已经有一个 Blinky 状态机了，但我会先删掉它，让你看看怎么从零开始构建一个状态机。

---

So the design process typically goes as follows:

设计过程一般按以下步骤进行：

---

A good place to start is the default state and the initial transition, because this establishes the initial condition of the system.

一个好的起点是默认状态和初始转换，因为它们确定了系统的初始条件。

---

At this point you might not even know how to name this default state, but don't worry, because it will become clearer as you flesh out the initial transition.

这时候你可能还不知道默认状态该叫什么名字，没关系，随着初始转换的细化，自然就会清晰起来。

---

In case of your BlinkyButton the initial transition will perform the following actions: turn the Green-LED off and arm a time event to expire in the off-time.

对 BlinkyButton 来说，初始转换要执行以下动作：关闭绿色 LED，设定一个定时事件（Time Event）在关闭时间后到期。

---

By the way, the QM tool provides two fields for specifying the action. The smaller filed is for the pseudocode, which is just a very concise comment as to what the action is all about. The bigger filed below, can contain the actual code in C, which, if provided, will be used for automatic code generation. Only the pseudocode is shown in the diagram, which reduces the clutter.

顺便说一下，QM 工具提供了两个字段来指定动作。上面较小的字段写伪代码（Pseudocode），就是一段简短的注释，说明动作的含义。下面较大的字段可以写实际的 C 代码，如果提供了的话，会用于自动代码生成。图上只显示伪代码，避免画面杂乱。

---

But going back to the state machine, the actions on the initial transition mean that the default state represents the "off" state of the BlinkyButton, so let's name it "off".

回到状态机本身——初始转换上的动作说明默认状态代表 BlinkyButton 的"关闭"状态，所以我们把它命名为 "off"。

---

Now, when the TIMEOUT event arrives in this "off" state, you need to turn the Green-LED ON and you need to arm the time event for the on-timeout.

现在，当 TIMEOUT 事件到达 "off" 状态时，你需要打开绿色 LED，并设定一个定时事件在点亮时间后到期。

---

But this means that you can no longer stay in the "off" state, so you need a different state, which logically should be called "on".

但这意味着你不能再停留在 "off" 状态了，需要一个不同的状态，逻辑上应该叫 "on"。

---

So, let's add the "on" state and point the transition to go there.

好，添加 "on" 状态，把转换指向它。

---

Now, when the TIMEOUT event arrives in the "on" state, you transition to the "off" state. In the actions on this transition you turn the Green-LED OFF and you arm the time event for the off-time.

现在，当 TIMEOUT 事件到达 "on" 状态时，你转换到 "off" 状态。转换动作是关闭绿色 LED，并设定定时事件在关闭时间后到期。

---

At this point the blinking feature is complete, but this is the Blinky-*Button* state machine, so it must also handle the BUTTON_PRESSED and BUTTON_RELEASED events.

到这里闪烁功能就完成了，但这是 Blinky-Button 状态机，还得处理 BUTTON_PRESSED 和 BUTTON_RELEASED 事件。

---

These events will be handled in the so called internal transitions, which just execute actions but don't trigger a change of state.

这些事件用所谓的内部转换来处理——只执行动作，不改变状态。

---

The internal transition for the BUTTON_PRESSED event turns the Blue-LED on and shortens the blink time for the Green-LED by 2.

BUTTON_PRESSED 事件的内部转换动作是打开蓝色 LED，并把绿色 LED 的闪烁周期缩短为原来的 1/2。

---

The internal transition for the BUTTON_RELEASED event just turns the Blue-LED off.

BUTTON_RELEASED 事件的内部转换动作就是关闭蓝色 LED。

---

But these two events need to be handled also when the Green-LED is on, which means that you need to repeat the same internal transitions in the "on" state as well.

但这两个事件在绿色 LED 亮着的时候也需要处理，也就是说你必须在 "on" 状态里重复同样的内部转换。

---

Of course, such repetition is perhaps not a big deal in a toy example like your BlinkyButton here, but in real-life projects repetitions like that can, and will, pile up. This is exactly the problem that the modern hierarchical state machines are designed to address. But I have to leave the discussion of hierarchical state machines to another lesson.

当然，在 BlinkyButton 这样的玩具例子里，这点重复也许不算什么。但在实际项目中，这种重复会越来越多。这正是现代层次式状态机要解决的问题。不过层次式状态机的讨论要留到后面的课了。

---

Because today, I'd still like to show you how you can implement the just designed BlinkyButton state machine in C.

因为今天，我还要演示如何用 C 语言实现刚才设计的 BlinkyButton 状态机。

---

The implementation technique I'm going to show you is not necessarily the most efficient or elegant. I will discuss other implementations in the future lessons in the state machine segment. But today, I'll show you the most straightforward way.

我要演示的实现方法不一定是最高效或最优雅的。在后续的状态机课程中会讨论其他实现方式。今天先讲最直接的方法。

---

As you remember from the state machine definition, the main job of a state machine is to remember its current state. For that, you obviously need a variable, which in state machine implementations is commonly called the "state variable".

根据状态机的定义，状态机的核心职责就是记住自己当前的状态。为此你显然需要一个变量，在状态机实现中通常叫作"状态变量"（State Variable）。

---

The most straightforward way to represent the state variable is to simply make it an enumeration of all possible states. In the BlinkyButton state machine you have states "off" and "on", so the enumeration will define OFF_STATE and ON_STATE constants.

最直接的方法就是把状态变量定义为一个枚举类型，列出所有可能的状态。BlinkyButton 状态机有 "off" 和 "on" 两个状态，所以枚举定义 OFF_STATE 和 ON_STATE 两个常量。

---

The state variable replaces all flags and variables that were part of the improvised, manual context management. In the simplistic BlinkyButton example, this means that you can get rid of the isLedOn flag, which might not look like much of an improvement.

状态变量取代了之前临时手动管理上下文所用的所有标志和变量。在 BlinkyButton 这个简单例子中，就是可以去掉 isLedOn 标志——看起来改进不大。

---

But please remember that in more advanced state machines, like for example the calculator, you have still only one state variable, which then replaces many more variables like those ones you saw in the Visual Basic example.

但请记住，在更复杂的状态机里——比如计算器——你仍然只有一个状态变量，但它能替代大量像 Visual Basic 例子里那样的变量。

---

But moving on, now you need to decide where to put the state machine code. As it turns out, the ideal place for this is the active object dispatch function.

继续往下，现在要决定把状态机代码放在哪里。最理想的位置是活动对象的分发函数（Dispatch Function）。

---

This is because the surrounding active object framework calls dispatch only when there is an event to process. Otherwise, the active object is completely dormant and does noting.

因为活动对象框架只有在有事件需要处理时才会调用 dispatch 函数。否则，活动对象完全处于休眠状态，什么都不做。

---

This happens to be exactly how a state machine operates. When there are no events, a state machine just waits in its current state and does absolutely nothing. This dormant condition is depicted in blue color in the QM modeling tool.

这恰好就是状态机的工作方式。没有事件时，状态机就在当前状态里等着，什么都不做。QM 建模工具用蓝色表示这种休眠状态。

---

Only when an event arrives, the state machine is activated to process the event in one of the transitions. This active condition is depicted in red color in the QM modeling tool.

只有当事件到达时，状态机才被激活，在某个转换中处理事件。QM 建模工具用红色表示这种活跃状态。

---

With this understanding, let's now re-code the BlinkyButton-dispatch function as a state machine.

理解了这些，让我们把 BlinkyButton 的 dispatch 函数重新用状态机来实现。

---

At this point, let's still keep the original code for reference, but remember to delete it eventually.

先把原来的代码留着作参考，但别忘了最后删掉。

---

Starting with the initial transition, the way it is organized in your Micro-C-A-O framework, the initial transition needs to be executed when the dispatch function receives special INIT event signal.

从初始转换开始。在 Micro-C-AO 框架中，初始转换在 dispatch 函数收到特殊的 INIT 事件信号（Event Signal）时执行。

---

To implement this, you check if the event signal is INIT_SIG and if so,

实现方式是判断事件信号是否为 INIT_SIG，如果是的话——

---

you execute the actions on your initial transition, such as Blue-LED off and arm the Time-Event to fire in the off-time.

执行初始转换上的动作：关闭蓝色 LED，设定定时事件在关闭时间后触发。

---

After the actions, you set your private "state variable", conveniently accessible through the "me" pointer, to the target of the initial transition. At this point, you can explicitly return, because you're done.

动作执行完后，通过 "me" 指针把私有状态变量设置为初始转换的目标状态。到这里就可以直接返回了。

---

Now comes the most interesting part of coding the states. In this most straightforward method, you use the switch statement that discriminates based on your state variable.

接下来是最有趣的部分——编写状态处理代码。在这个最直接的方法中，你用 switch 语句根据状态变量做分支。

---

You can then immediately provide all the cases for all the states in your state machine.

然后为状态机中的每个状态写一个 case。

---

After all the possible states, I recommend to add the default case, where you can put an assertion, because reaching the default case means that your state variable has become and invalid state.

在所有可能的状态之后，建议加一个 default 分支，放一个断言（Assertion）。因为走到 default 说明状态变量变成了一个无效值。

---

Now you can flesh out the state cases. For this, you use the second level switch statement, but this time discriminating based on the event signal.

现在填充各个状态的处理。在每个 case 里嵌套第二层 switch 语句，这次根据事件信号来分支。

---

For the "off" state, you find that the first signal it handles is TIMEOUT, so you provide a case for it. Inside this case, you execute the actions listed in the diagram.

在 "off" 状态中，第一个要处理的信号是 TIMEOUT，为它写一个 case，在里面执行图上列出的动作。

---

But you also notice that this a regular state transition that goes to the state... "on". You code it by explicitly changing your state variable to ON_STATE.

同时你会注意到这是一个常规状态转换，目标是 "on" 状态。把状态变量显式改为 ON_STATE 就行了。

---

The next event handled in your "off" state is BUTTON_PRESSED, so you provide a case for it.

"off" 状态中下一个要处理的事件是 BUTTON_PRESSED，为它写一个 case。

---

The actions associated with this internal transition are the same as you already coded in your old version, so you simply copy it from there.

这个内部转换的动作和旧版代码里的一样，直接复制过来就行。

---

Note that an internal transition causes no change of state, so you don't modify your state variable.

注意，内部转换不会改变状态，所以不需要修改状态变量。

---

The last BUTTON_RELEASED internal transition in your "off" state is coded in similar way as BUTTON_PRESSED. Again, you don't modify your state variable.

"off" 状态中最后一个内部转换 BUTTON_RELEASED 的编码方式和 BUTTON_PRESSED 类似。同样不需要修改状态变量。

---

Next, you move on to the "on" state, where you have the TIMEOUT event.

接下来看 "on" 状态，同样先处理 TIMEOUT 事件。

---

After the actions, you code the regular transition, which goes to... the "off" state.

执行完动作后，编写常规转换，目标是 "off" 状态。

---

The two remaining internal transitions in the "on" state are handled identically as you've already coded in the "off" state, so you simply copy over that code.

"on" 状态中剩下两个内部转换的处理方式跟 "off" 状态里完全一样，直接复制代码过来。

---

At this point you've implemented the whole state machine, so you can delete the old code.

至此整个状态机实现完毕，可以把旧代码删掉了。

---

But now, I'd like you to take a step back and recount what just happened.

现在，我想让你退一步，回顾一下刚才发生了什么。

---

Well, the state machine is not necessarily smaller than your old code, but this is mostly due to the repetitions in handling the Button events that I promise to address in the future.

状态机代码不一定比旧代码短，这主要是因为按钮事件的处理有重复。这个问题我保证后面会解决。

---

More importantly, however, I hope you've noticed that the whole state machine coding experience was very different than any other code you've written before.

但更重要的是，我希望你注意到——整个状态机编码体验跟你之前写过的任何代码都不一样。

---

Specifically, once you've worked out a few simple rules of mapping state machine elements, like states and transitions, to code, you could apply them mechanically. The actual coding did not require much thinking, because all the thinking has been already done when the state machine was designed.

具体来说，一旦你掌握了状态机元素（状态、转换等）到代码的几条简单映射规则，就可以机械地套用。实际编码不需要太多思考，因为所有思考已经在设计状态机时完成了。

---

In fact, I hope you can now imagine how a modeling tool, like QM, could *automatically generate* such code by applying the same simple rules as you did.

事实上，我希望你现在能想象到，像 QM 这样的建模工具可以应用和你一样的简单规则，自动生成代码。

---

By the way, QM can actually do this, it can automatically generate code from your state diagrams, although it uses a different implementation strategy than you've just seen. I'll explain other state machine implementation strategies in the future lessons.

顺便说一下，QM 确实能做到这一点——它可以从状态图自动生成代码，只不过它用的实现策略跟你刚看到的不同。其他状态机实现策略在后续课程中讲解。

---

But going back to your today's coding experience, I hope you can now quite easily see how every part of the code corresponds to the parts of the state diagram. This property is called "traceability" between code and design, and is a required property in safety-critical software.

回到今天的编码体验，我希望你现在能很容易地看到代码的每一部分如何对应状态图的每一部分。这个特性叫作代码和设计之间的"可追溯性"（Traceability），是安全关键软件中的必要属性。

---

And the last point I'd like to bring up is that you now know how to extend your code. Should you add new states or new events to your state machine or change things around, you know exactly which parts of code your need to change. This property is called "extensibility" and this is another great benefit of using state machines.

最后一点——你现在知道怎么扩展代码了。不管是给状态机加新状态、新事件，还是调整现有结构，你都很清楚需要改哪些代码。这个特性叫作"可扩展性"（Extensibility），也是使用状态机的另一个巨大好处。

---

Alright, but to wrap up for today I still need to check whether the state machine code actually works, so let me do it right now.

好，最后还得验证一下状态机代码是否能正常工作。

---

The compiler reminds me to cleanup the isLedOn flag from the constructor, but otherwise the state machine code builds with zero errors and zero warnings.

编译器提醒我从构造函数中清理掉 isLedOn 标志，除此之外状态机代码编译零错误零警告。

---

So, let me load the code to the Tiva LaunchPad board and run it.

把代码下载到 Tiva LaunchPad 开发板上运行。

---

Well, as you can see, the BlinkyButton example works just as it did before.

可以看到，BlinkyButton 的运行效果和之前完全一样。

---

This concludes this first lesson in the State Machine segment. In the next lesson, you'll learn about other variants of state machines as well as the common misconceptions and misunderstandings about state machines.

状态机系列的第一讲到此结束。下一讲我们会学习状态机的其他变体，以及关于状态机的常见误解和误区。

---

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请点赞并订阅。课程笔记和工程文件下载请访问 state-machine.com/quickstart。

---

## 术语表 / Glossary

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| State Machine | 状态机 | 由状态集合和转换规则组成的计算模型，用于描述系统行为 |
| State | 状态 | 系统过去历史的等价类，是相关历史的最高效表示 |
| Transition | 转换 | 从一个状态到另一个状态的规则，由事件触发 |
| Internal Transition | 内部转换 | 不改变状态、只执行动作的转换 |
| Initial Transition | 初始转换 | 状态机创建时指向默认状态的转换 |
| Action | 动作 | 转换触发时执行的操作，写在斜杠（/）后面 |
| Event | 事件 | 触发状态转换或动作的信号 |
| Event Signal | 事件信号 | 标识事件类型的枚举值 |
| Event-Driven Programming | 事件驱动编程 | 以事件响应为核心的编程范式 |
| Active Object | 活动对象 | 封装了状态机、事件队列和执行线程的设计模式 |
| Context | 上下文 | 系统在事件之间需要保存的状态信息 |
| Equivalence Class | 等价类 | 行为完全相同的一组过去历史，归为同一个状态 |
| Run-to-Completion (RTC) | 运行到完成 | 状态机一次只处理一个事件的语义保证 |
| State Diagram | 状态图 | 状态机的图形表示，状态用圆角矩形，转换用箭头 |
| State Variable | 状态变量 | 保存当前状态的变量，通常用枚举类型表示 |
| Hierarchical State Machine | 层次式状态机 | 支持状态嵌套的现代状态机，解决代码重复问题 |
| UML Statechart | UML 状态图 | UML 标准中的层次式状态机记法 |
| Traceability | 可追溯性 | 代码与设计之间可一一对应查找的属性 |
| Extensibility | 可扩展性 | 添加新功能时只需修改确定部分的属性 |
| Time Event | 定时事件 | 在指定时间后触发的事件 |
| Dispatch Function | 分发函数 | 活动对象中处理事件分发的函数，放置状态机代码的理想位置 |
| Assertion | 断言 | 用于检测非法状态的运行时检查 |
| Blocking | 阻塞 | 线程等待某个条件时暂停执行 |
| RTOS (Real-Time Operating System) | 实时操作系统 | 用于实时嵌入式系统的操作系统 |
| Event Loop | 事件循环 | 不断取事件并分发的循环结构 |
| Pseudocode | 伪代码 | 用自然语言简述算法逻辑的记法 |
| Spaghetti Code | 意大利面条式代码 | 结构混乱、充斥标志和条件判断、难以维护的代码 |
