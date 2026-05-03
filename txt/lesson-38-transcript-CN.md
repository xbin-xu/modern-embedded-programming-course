# 第38课：状态表与状态的进入/退出动作 / Lesson 38: State Tables and State Entry/Exit Actions

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this forth lesson on state machines you'll learn about state tables. In the process, you will see how to implement state tables in C and how to extend this implementation to add state entry and exit actions.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，在状态机（State Machine）系列的第四课中，我们将学习**状态表（State Table）**。过程中，我会演示如何用 C 语言实现状态表，以及如何在这个基础上添加状态的**进入动作（Entry Action）**和**退出动作（Exit Action）**。

---

So far in this segment about state machines you've learned the most straightforward nested-switch statement implementation in C. For example, the time-bomb project from lesson 36 was implemented that way.

到目前为止，在状态机这一板块中，你已经学过最直接的 C 语言实现方式——**嵌套 switch 语句**。比如第36课的 TimeBomb（定时炸弹）项目就是用这种方式写的。

The whole state machine was coded in just one dispatch function and consisted of the switch statement that discriminated based on the state-variable. Each case handled a separate state. Within each state, you had another, nested switch that discriminated based on the event signal. The cases were all events handled by this particular state.

整个状态机的代码全放在一个 dispatch 函数里，外层 switch 根据状态变量分支，每个 case 对应一个独立的状态。在每个状态内部，再嵌套一层 switch，根据事件信号来分支，处理该状态要响应的那些事件。

A variation of this implementation technique was also applicable to the input-driven state machines that you've learned in the previous lesson-37. For instance, the Blinky-Button project from that lesson was again coded with the switch statement around the state-variable. But because the whole state machine handled essentially just one event -- the low-quality SAMPLE-event-- there was no need for the second level of nested switch based on the event. Instead, each state contained guard conditions that checked the event parameters to discover the truly interesting events.

这种实现思路的变体同样适用于上一课（第37课）学到的**输入驱动状态机**。比如那节课的 Blinky-Button 项目，也是用围绕状态变量的 switch 来写的。不过因为整个状态机本质上只处理一个事件——低质量的 SAMPLE 事件——所以不需要第二层按事件分支的嵌套 switch。取而代之的是，每个状态里放**守卫条件（Guard Condition）**，通过检查事件参数来筛选出真正需要处理的事件。

But, as I mentioned in those previous lessons, this particular state machine implementation is not the most efficient or elegant. It's just the most straightforward and therefore the most common.

但正如之前几课我说过的，这种实现方式并不是最高效、最优雅的方案。它只是最简单直接，所以用的人最多。

So, today I'd like to show you another implementation of a different kind, based on state tables. Again, I don't think that this technique is the most elegant or efficient either, but it demonstrates a different way of thinking about the problem and therefore is a good stepping stone to understanding other state machine implementations. Also, state tables are a quite popular representation of state machines, so you definitely need to know how they work.

所以今天，我想给你展示另一种不同风格的实现——基于**状态表**的实现。同样，我也不认为这种技术是最优雅或最高效的，但它展示了一种截然不同的思考角度，是理解其他状态机实现方式的好跳板。而且状态表这种表示方式本身就很流行，你确实需要掌握它的工作原理。

---

Actually, you've already seen some state tables in the last lesson-37 in the part about Mealy and Moore state machines for describing electronic circuits. Because the inputs to those state machines were logic signals, the tables were Truth Tables, but they can be easily generalized to events.

其实，你在上一课第37课讲到用 Mealy 和 Moore 状态机描述电子电路的时候，就已经见过状态表了。因为那些状态机的输入是逻辑信号，所以表格的形式是**真值表（Truth Table）**，但这个思路很容易推广到事件。

For example, if we just use the already assigned names for states and name the events, LOW for 0 and HIGH for 1, we can re-write the Truth Table as follows:

比如，我们用已经定义好的状态名称，把事件也命名一下——LOW 对应 0，HIGH 对应 1——就可以把真值表改写成这样：

But then, notice that for every state in this one dimensional table you repeat all the events. This means that you can re-organize the same information into a two-dimensional table.

但你会发现，在这个一维表格里，每个状态下面都在重复列出所有事件。这就意味着，同样的信息可以重新组织成一张**二维表格**。

You leave the states as they are, but you list events along the second, horizontal dimension. Now, every cell in the two-dimensional table contains the pair: next-state and action to be performed for the given event in a given state.

状态还是竖着排列，但事件沿着水平方向展开。这样一来，二维表格中的每个单元格包含一对信息：**下一个状态**，以及在该状态下收到该事件时要执行的**动作**。

So, these are the state tables: 1-dimensional and 2-dimensional. They both contain exactly the same information, and both correspond one-to-one to the state diagram, just as the original Truth Table did.

这就是状态表——一维的和二维的。它们包含的信息完全相同，都与**状态图（State Diagram）**一一对应，就像最初那个真值表一样。

---

Alright, so now, let's apply the same technique to represent the Time-Bomb software state machine from lesson 36 as the two-dimensional state table.

好了，现在我们用同样的方法，把第36课的 TimeBomb 软件状态机表示成二维状态表。

First, open up the project from lesson 36 and look up all events that are posted to the TimeBomb. These events are enumerated in the bsp.h header file and are: BUTTON_PRESSED, BUTTON_RELEASED, and TIMEOUT.

首先，打开第36课的项目，查看所有发送给 TimeBomb 的事件。这些事件在 `bsp.h` 头文件中定义，分别是：`BUTTON_PRESSED`、`BUTTON_RELEASED` 和 `TIMEOUT`。

Now, let's open up the model of TimeBomb, and see which states you have in your state machine there. These states are: wait4button, blink, pause, and boom.

然后打开 TimeBomb 的模型，看看状态机里有哪些状态。这些状态是：`wait4button`、`blink`、`pause` 和 `boom`。

For each state, you look whether it handles a given event. For example, state "wait4button" handles the BUTTON_PRESSED event, so you put the next state and actions in the corresponding cell of the table.

对每个状态，检查它是否处理某个事件。比如状态 "wait4button" 处理 `BUTTON_PRESSED` 事件，就在表格对应的单元格里填上下一状态和要执行的动作。

For all events not found in the given state, you put "ignore", or alternatively, you can put "error" if you believe that a given event should never arrive at that state.

如果某个事件在该状态里没有被处理，就填 "ignore"。或者，如果你认为某个事件根本不应该出现在那个状态，也可以填 "error"。

You do the same for the "blink" state, which handles only the TIMEOUT event.

对 "blink" 状态也做同样的操作，它只处理 `TIMEOUT` 事件。

Now, in state "pause" there is a problem, because this state has a guard condition with one transition going to the "blink" state and the other going to the "boom" state. Here, I just put both these next-states, but with the question marks. These are then further explained as a footnote to the state table.

到了 "pause" 状态就有问题了，因为这里有一个守卫条件——满足条件时转到 "blink"，不满足时转到 "boom"。这里我把两个下一状态都写了进去，但打上问号，然后在状态表的脚注里做进一步说明。

An alternative notation is to put the whole guard conditions directly in the table, but that leads to quite a clutter. You'll see how to work around it in the actual code.

另一种写法是把完整的守卫条件直接写在表格里，但那样会很杂乱。等会儿在实际代码中你会看到怎么处理这个问题。

---

Which leads to the most interesting question for today: how to use the state table representation as a basis for the actual implementation?

这自然引出了今天最有趣的问题：怎么把状态表这种表示方式变成真正的代码实现？

So, for the coding exercise in this lesson, let's start with the TimeBomb from lesson-36, which I showed already to remind you about the nested-switch statement state machine implementation.

今天的编码练习，我们从第36课的 TimeBomb 项目开始，我之前展示过它，帮大家回顾嵌套 switch 语句的状态机实现。

So, for today, copy lesson-36 directory to lesson-38, get inside the new directory and double-click on the project lesson to open it in the micro-Vision IDE.

今天的操作是：把 lesson-36 目录复制一份改名为 lesson-38，进入新目录，双击项目文件，在 micro-Vision IDE 中打开它。

---

The first question in implementing the state table is how to represent it in code.

实现状态表首先要解决的问题，就是怎么在代码中表示它。

Well, the C language supports two-dimensional arrays directly.

C 语言本身就直接支持**二维数组**。

So, you can have the "TimeBomb_table" array, with the first dimension corresponding to the number of your states and second dimension to the number of your events.

所以你可以建一个 `TimeBomb_table` 数组，第一维对应状态的数量，第二维对应事件的数量。

A noteworthy trick to codify these dimensions is to place a special constant at the very end of the enumeration for states, which I call MAX_STATE

这里有一个编码技巧：在状态枚举的最后放一个特殊常量，我叫它 `MAX_STATE`。

and another in bsp.h at the end of the enumeration for event signals: MAX_SIG.

同样，在 `bsp.h` 中事件信号枚举的最后放另一个常量：`MAX_SIG`。

If you keep these MAX constants at the end, you will automatically keep track of any changes inside your enumerations.

只要你把这些 MAX 常量放在末尾，枚举里面任何增删都会自动反映出来。

---

Now, the most interesting decision is about the type of the entries in your TimeBomb_table.

接下来最关键的设计决策，就是 `TimeBomb_table` 里每个元素应该是什么类型。

Well, some state table implementations make each entry in such state table to be a struct, with a whole bunch of members like: guard condition, new state, transition action, and other elements.

有些状态表实现会把每个单元格做成一个结构体，包含一大堆成员：守卫条件、新状态、转换动作等等。

However, this abundant information in each and every cell of the state table makes the table very complex to initialize, takes a lot of memory, and, most importantly, makes even a simple state machine implementation fragmented into literally hundreds of little functions.

然而，每个单元格塞这么多信息，初始化会非常复杂，占用的内存也多。更要命的是，哪怕一个很简单的状态机，也会被拆得七零八落，变成上百个碎片化的小函数。

So, instead I recommend a much simpler solution, in which every cell in the array simply holds an action, named here TimeBombAction. This action function can then evaluate guards and can also change the state internally, so no separate next-state information needs to be stored.

所以我推荐一个简洁得多的方案：数组中的每个单元格只存放一个动作，这里命名为 `TimeBombAction`。这个动作函数内部可以评估守卫条件，也可以改变状态，所以不需要单独存储下一状态的信息。

The TimeBombAction is a pointer to function to be called when a given event arrives in the given state. I already used pointers to functions in several lessons in this video course, for example in lesson-15 about the startup code and vector table initialization, in lesson-23 about real-time operating system, and in lesson-32 about polymorphism in C.

`TimeBombAction` 是一个**函数指针（Pointer to Function）**，当某个事件在某个状态到达时，就调用它指向的函数。在这门课程里，我已经在好几课中用过函数指针了——第15课讲启动代码和向量表初始化、第23课讲实时操作系统、第32课讲 C 语言中的多态性。

The best way to specify a pointer to function in C is through a typedef. The actual pointer to function must be in parentheses followed by the parameter list.

在 C 语言中定义函数指针类型，最好的做法是用 **typedef**。函数指针本身要用括号括起来，后面跟上参数列表。

The action function will return void.

动作函数的返回类型是 `void`。

To get easy access to data members of the TimeBomb, the action function will take the pointer "me", and to get access to the event parameters, it will also take the event pointer "e".

为了方便访问 TimeBomb 的数据成员，动作函数接收一个 "me" 指针；为了能拿到事件参数，还要接收一个事件指针 "e"。

With this definition, you can now start filling up your state table.

有了这个类型定义，就可以开始填充状态表了。

---

Please note that the state table is completely known at design time and fixed at runtime. Consequently, it can and should be constant. This is not only safer, because the compiler will not allow you to change the const state table, but it will also allow the state table to be placed in ROM, instead of taking up space in the precious RAM.

请注意，状态表在设计阶段就完全确定了，运行时不会改变。因此它可以、也应该是 **const** 的。这不仅仅是为了安全——编译器会阻止你意外修改——而且 const 修饰后，状态表可以放到 **ROM** 中，不去挤占宝贵的 **RAM** 空间。

But a constant object has to be initialized right away, at its definition. The only way to perform this in C is by using the C array initializer.

但 const 对象必须在定义的同时初始化。在 C 语言中，唯一的方式就是用数组初始化器。

For a two-dimensional array like this one, you initialize entire rows determined by the last dimension, which are the event signals.

对于这样的二维数组，按最后一维（即事件信号）逐行初始化。

To simplify the job and to avoid mistakes, let me place comments with the labels for all the signals enumerated in bsp.h and all states enumerated inside the TimeBomb class.

为了方便填写、避免出错，我在注释中标注了 `bsp.h` 里所有信号的名称和 TimeBomb 类中所有状态的名称。

But you have to be very careful here, because the indexes into the state table array must be consecutive and start at zero. However, the signals in bsp.h don't start at zero, but rather are offset by the USER_SIG constant. This offset is then defined in the `uc_ao.h` header file, where you see that the very first signal with the default value zero is INIT_SIG.

但这里要特别小心：状态表数组的索引必须连续，并且从零开始。然而 `bsp.h` 中的信号并不是从零开始的，而是偏移了一个 `USER_SIG` 常量。这个偏移量定义在 `uc_ao.h` 头文件中，在那里你会看到默认值为零的第一个信号是 `INIT_SIG`。

So, the complete list of signals in your state table must include INIT_SIG at the beginning.

因此，你的状态表中完整的信号列表开头必须包含 `INIT_SIG`。

---

Now, you can fill out the table cells, per the state table you've designed before, except the INIT_SIG, which will be handled only in the "wait4button" state in the TimeBomb_init function.

现在按照之前设计好的状态表逐个填入单元格内容。唯一的例外是 `INIT_SIG`，它只在 `TimeBomb_init` 函数中的 "wait4button" 状态里处理。

For each signal-state combination that *is* being handled, you insert a pointer to function with the name TimeBomb followed by the state name followed by the signal name. For example, the state "wait4button" handles the BUTTON_PRESSED event, so you insert here pointer to function TimeBomb_wait4button_PRESSED.

对于每个*确实*被处理的信号-状态组合，填入一个函数指针，命名规则是 TimeBomb 后面跟状态名再跟信号名。比如状态 "wait4button" 处理 `BUTTON_PRESSED` 事件，就填入函数指针 `TimeBomb_wait4button_PRESSED`。

If a given signal-state combination should be ignored, you insert the TimeBomb_ignore function pointer.

如果某个信号-状态组合应该忽略，就填入 `TimeBomb_ignore` 函数指针。

You proceed like this, effectively copying your initial design, until you fill out the entire TimeBomb_table array.

就这样继续，相当于把设计稿照搬到代码里，直到填满整个 `TimeBomb_table` 数组。

---

The last step is then to define all the functions used in the table.

最后一步，就是定义表格中用到的所有函数。

So, starting with the TimeBomb_init, you provide the prototype corresponding to your TimeBombAction pointer to function and just copy the actions from the original top-most initial transition.

先从 `TimeBomb_init` 开始，按照 `TimeBombAction` 函数指针的类型提供函数原型，然后把原始最顶层初始转换中的动作复制过来。

As you are at the initialization, the state variable me->state must be initialized to the WAIT4BUTTON state in the constructor. This is because me->state will be used as an index into the state table, so it has to have a well-defined value.

因为这是初始化阶段，在构造函数中必须把状态变量 `me->state` 初始化为 `WAIT4BUTTON` 状态。因为 `me->state` 将被用作状态表的索引，所以必须有一个明确的初始值。

The action function for the "wait4button" state and BUTTON_PRESSED event is implemented the same way. Again, you just copy the action from the original nested-switch statement.

"wait4button" 状态处理 `BUTTON_PRESSED` 事件的动作函数也类似。同样是直接从原始的嵌套 switch 语句里把动作复制过来。

The ignore action is just an empty function.

ignore 动作就是一个空函数，什么都不做。

The blink-TIMEOUT action function is done the same way.

`blink-TIMEOUT` 动作函数也是同样的做法。

And so is the pause-TIMEOUT action function. You just copy over the corresponding case from the nested-switch statement.

`pause-TIMEOUT` 动作函数也一样，直接从嵌套 switch 语句中把对应的 case 复制过来。

---

So now, you can clean up the old code inside the TimeBomb_dispatch function and re-implement it with the state table.

现在可以清理掉 `TimeBomb_dispatch` 函数里的旧代码，用状态表重新实现。

The code here is remarkably simple and elegant. You take your TimeBomb_table and index into it with the me->state variable and the e->sig signal. Then you call the selected action function via a pointer. You pass the "me" pointer and "e" pointer as parameters to the call.

这段代码非常简洁优雅。用 `me->state` 和 `e->sig` 作为索引查 `TimeBomb_table`，然后通过函数指针调用选中的动作函数。调用时传入 "me" 指针和 "e" 指针作为参数。

A good idea at this point is also to assert that the variables used as indexes into the array are in bounds.

这时候还有一个好习惯：加一个**断言（assert）**，检查用作数组索引的变量是否在有效范围内。

As a final touch, you can add the static keyword to all your TimeBomb functions, just as it is already done for the dispatch function. This is a good programming practice, because the static keyword limits the visibility of the static elements inside the given module and prevents any accidental access to them from anywhere else.

最后再做一点收尾：给所有 TimeBomb 函数加上 **static** 关键字，dispatch 函数已经是 static 的了。这是一个好的编程习惯——static 限制了这些函数的可见范围，只在本模块内可见，防止其他地方意外调用。

---

Alright, so let's build the code and load it to the TivaC LaunchPad board.

好了，现在编译代码，下载到 TivaC LaunchPad 开发板上。

Now: reset button -- green light.

操作：按下复位按钮——绿灯亮起。

SW1 button: five, four, three, two, one, BOOM!

按下 SW1 按钮：五、四、三、二、一，BOOM！

OK, it works!

没问题，正常工作！

---

So now, in the second part of this lesson I'd like to introduce another big improvement in state machines, which can eliminate many annoying repetitions in both your designs and code.

接下来进入本课的第二部分，我想介绍状态机的另一个重大改进——它可以消除设计和代码中很多令人头疼的重复。

For example, in your TimeBomb state machine, the state "blink" can be entered through two different transitions: The BUTTON_PRESSED transition from "wait4button" and the TIMEOUT transition with a guard from "pause".

举例来说，在你的 TimeBomb 状态机中，状态 "blink" 可以通过两条不同的转换进入：从 "wait4button" 来的 `BUTTON_PRESSED` 转换，以及从 "pause" 来的带守卫条件的 `TIMEOUT` 转换。

In both of these transitions, there is a group of actions (Red-LED ON and arm Time-event for one-half second) that is repeated. This is because these actions are a required preparation for the "blink" state and so they must be executed whichever way the "blink" state is entered.

这两条转换中都重复了一组动作（点亮红色 LED，设置半秒定时事件）。因为这些动作是进入 "blink" 状态前的必要准备，不管从哪条路进来都得执行。

These actions logically belong to the "blink" state, and it would be much better if you could attach these actions explicitly to that state.

这些动作在逻辑上属于 "blink" 状态，如果能直接把它们绑定到这个状态上，那就好多了。

And this is exactly what entry and exit actions to states allow you to do.

而状态的**进入动作和退出动作**，正是为此而生的。

Specifically, you can provide an entry action to state "blink" and put there the actions that always need to be executed upon the entry to that state.

具体来说，你可以给 "blink" 状态加一个进入动作，把每次进入该状态都必须执行的操作放在那里。

As you can see, the UML notation for this is the word "entry", or just the letter "e", inside the state shape, followed by the forward slash and a list of actions.

在 **UML 表示法**中，写法是在状态框内写 "entry" 或字母 "e"，后面跟斜杠和动作列表。

You can then remove these actions from all the incoming transitions.

然后把这些动作从所有进入该状态的转换中删掉。

But you don't need to apply the entry and exit mechanism just to the repeated actions on transitions. In fact, you should take a critical look at your entire state machine and check which actions would better fit into states rather than transitions.

不过进入和退出机制不仅限于转换上重复的动作。实际上，你应该审视整个状态机，看看哪些动作更适合归属到状态上，而不是放在转换上。

For example, the action Green-LED-on in the top-most initial transition really belongs to the "wait4button" state, so you can put it in the entry action and remove it from the transition.

比如最顶层初始转换中的 Green-LED-on 动作，其实属于 "wait4button" 状态，所以可以把它挪到进入动作中，从转换上去掉。

Now, whatever is done in the entry actions, often needs to be undone in the exit actions. For example, the Green-LED turned on upon the entry to "wait4button" needs to be turned off upon the exit, whichever way the exit happens. So, you should move that action from the BUTTON_PRESSED transition to the exit action from the state.

进入动作里做的事情，通常需要在退出动作中对应地撤销。比如进入 "wait4button" 时点亮了绿色 LED，那退出时不管怎么退，都应该把它熄灭。所以你应该把熄灯动作从 `BUTTON_PRESSED` 转换挪到该状态的退出动作中。

Similarly, if the "blink" state turns the Red-LED on in its entry action, it should turn it off in its exit action, instead of doing it on the transition.

同理，如果 "blink" 状态在进入动作里点亮了红色 LED，就应该在退出动作里把它熄灭，而不是在转换上做这件事。

On the other hand, the arming of the time event that also happens on that transition logically belongs to the "pause" state, because it determines how long the pause state will be active.

另一方面，那个转换上设置定时事件的操作，逻辑上属于 "pause" 状态，因为它决定了暂停状态持续多长时间。

Finally, the action to turn all LEDs on to simulate the explosion logically belongs to the entry action to state "boom".

最后，点亮所有 LED 模拟爆炸的动作，逻辑上属于 "boom" 状态的进入动作。

So, here it is: Your TimeBomb state machine version that performs most of the actions in states rather than transitions.

这就是改进后的 TimeBomb 状态机版本——大部分动作都放在状态上，而不是转换上。

If you remember the last lesson, state machines that associate actions with states are called Moore machines and state machines that associated actions with transitions are called Mealy machines.

回顾上一课：把动作与状态关联的状态机叫做 **Moore 机**，把动作与转换关联的状态机叫做 **Mealy 机**。

So, in a sense what you've just done is that you converted your TimeBomb state machine from Mealy-type into Moore-type.

所以从某种意义上说，你刚才把 TimeBomb 状态机从 Mealy 型改造成了 Moore 型。

But, I wouldn't take the Mealy-Moore classification from hardware state machines too far into the software domain. Because typically, software state machines have characteristics of both Mealy and Moore machines.

不过，我不会把硬件领域那套 Mealy-Moore 分类法硬套到软件上。因为典型的软件状态机，往往同时具有 Mealy 和 Moore 两种特征。

For example, your TimeBomb still performs some actions on transitions, such as the action on TIMEOUT transition in state "pause", and this is OK.

比如你的 TimeBomb 仍然在转换上执行了一些动作，像 "pause" 状态中 `TIMEOUT` 转换上的动作，这完全没问题。

Having said that, my decades of experience with software state machines shows that Moore-type state machines with actions associated with states tend to be generally better, cleaner, more robust and more maintainable than Mealy machines with actions associated with transitions.

话虽如此，我几十年搞软件状态机的经验告诉我：把动作绑定在状态上的 Moore 型状态机，通常比把动作绑定在转换上的 Mealy 机更好、更清晰、更健壮、更易维护。

---

So now, the last step in this lesson is obviously to implement your Moore-version of the TimeBomb state machine using the state table technique.

本课最后一步，自然就是用状态表技术来实现 Moore 版的 TimeBomb 状态机了。

You have of course many options to incorporate entry and exit actions into the state table.

把进入和退出动作整合进状态表，当然有很多做法。

But one possibility is to apply the same idea that you already used for the initial transition, and that is to add two new special signals ENTRY and EXIT into the "uc_ao.h" header file.

一种思路是沿用初始转换的做法——在 `uc_ao.h` 头文件中添加两个新的特殊信号：`ENTRY` 和 `EXIT`。

Now, you immediately need to add these signals to the state table as well, because otherwise the table won't match your event enumeration.

加完之后，状态表里也要相应增加这些信号列，否则表格维度就跟事件枚举对不上了。

And then, you need to insert entry and exit action functions for all states that handle them in your state diagram.

然后，在状态图中所有需要处理进入/退出动作的状态，都要在表格里填上对应的函数指针。

So for example: your state "wait4button" has an entry action and an exit action.

比如：状态 "wait4button" 有进入动作和退出动作。

State "blink" has also both entry and exit actions.

状态 "blink" 也有进入和退出动作。

On the other hand, state "pause" has only entry and ignores exit.

而状态 "pause" 只有进入动作，退出是忽略的。

and so does state "boom".

状态 "boom" 也是如此。

---

The next step is then to define the Entry and Exit action functions that you've already placed in your state table.

接下来要做的，就是定义那些已经填入状态表的进入和退出动作函数。

The "wait4button" state entry action turns the Green-LED on.

"wait4button" 状态的进入动作：点亮绿色 LED。

And the exit action turns the Green-LED off.

退出动作：熄灭绿色 LED。

The "blink" state entry action turns the Red-LED-on and arms the time event for one-half second.

"blink" 状态的进入动作：点亮红色 LED，设置半秒定时事件。

And the exit action turns the Red-LED-off.

退出动作：熄灭红色 LED。

The "pause" state entry action just arms the time event for one-half second.

"pause" 状态的进入动作：设置半秒定时事件。

The "boom" state entry action turns all the LEDs on.

"boom" 状态的进入动作：点亮所有 LED。

---

And finally, in your dispatch function, you must actually call the correct exit and entry actions when the transitions are taken.

最后，在 dispatch 函数中，当状态转换发生时，你必须正确地调用退出和进入动作。

But here is a problem: how would you know that a transition was taken?

但这里有个问题：你怎么知道发生了状态转换？

Well, one solution for this would be that the action handlers themselves would "tell" you what just happened inside.

一种解决方案是让动作处理函数自己"汇报"它内部做了什么。

Specifically, an action handler could return an enumerated status information, such as:

具体来说，动作处理函数可以返回一个枚举的状态值，比如：

TRAN_STATUS will tell you that a transition was taken.

`TRAN_STATUS` 表示发生了状态转换。

HANDLED_STATUS will tell you that an action was handled but without taking a transition.

`HANDLED_STATUS` 表示事件已处理，但没有发生转换。

IGNORED_STATUS will tell you that an event was ignored.

`IGNORED_STATUS` 表示事件被忽略了。

and finally, INIT_STATUS will tell you that the initial transition was taken.

最后，`INIT_STATUS` 表示执行了初始转换。

---

With this, you now need to add the Status return type to the signature of your action handler.

有了这些状态码，现在需要把 Status 返回类型加到动作处理函数的签名中。

And, of course, you need to go back and add the Status return to all your TimeBomb action handlers.

当然，还得回头给所有 TimeBomb 动作处理函数都加上对应的 return 语句。

So, starting from the top: you need to add "return INIT_STATUS" to the initial transition.

从最上面开始：初始转换要加 "return INIT_STATUS"。

You return the HANDLED_STATUS from the entry action.

进入动作返回 `HANDLED_STATUS`。

And from the exit action as well.

退出动作也返回 `HANDLED_STATUS`。

You return TRAN_STATUS from a transition action that changes the state.

改变了状态的转换动作返回 `TRAN_STATUS`。

Again, you return the HANDLED_STATUS from the entry and exit actions.

进入和退出动作还是返回 `HANDLED_STATUS`。

And you return TRAN_STATUS from the transition actions.

转换动作返回 `TRAN_STATUS`。

Finally, you return the IGNORED_STATUS from the ignored action.

最后，忽略动作返回 `IGNORED_STATUS`。

---

With that preparation, you can get to modify the dispatch operation to add calling the exit and entry actions on transitions.

准备工作做好了，现在可以修改 dispatch 函数，在转换时加入退出和进入动作的调用。

First you define the status variable as well as the prev_state variable to save there the current state before any potential transition.

先定义一个 status 变量，再定义一个 prev_state 变量，用来在转换发生前保存当前状态。

Next, you execute the appropriate action from your state table, but now you save the returned status into your variable.

然后执行状态表中对应的动作，但这次把返回的状态码保存下来。

But next, you check if the reported status corresponds to a transition.

接着检查返回的状态码是否表示发生了转换。

If so, you assert that the new state is in range.

如果是，先断言新状态在有效范围内。

and then you call the state table action corresponding to the previous state and the EXIT signal.

然后调用状态表中对应前一状态和 `EXIT` 信号的动作。

At this point it really doesn't matter which event you pass to the action, because the exit action should never use the event. It is there only for compliance with the action-handler signature. Therefore, you can pass here the zero pointer.

此时传递什么事件参数其实无关紧要，因为退出动作不会去读事件。这个参数只是为了满足函数签名的统一接口要求。所以直接传空指针就行。

After the exit from the previous state, you need to enter the current state, so you call the state table action corresponding to the current state and the ENTRY signal.

退出前一状态之后，就要进入当前状态了——调用状态表中对应当前状态和 `ENTRY` 信号的动作。

Again, you can pass the zero pointer for the event parameter.

同样，事件参数传空指针即可。

But you are not completely done yet, because you still need to correctly handle the state entry after initial transition.

还没完，还有一个特殊情况要处理：初始转换后的状态进入。

So, if the returned status is INIT_STATUS, you just enter the new state, as before, but you don't exit any state.

如果返回的状态是 `INIT_STATUS`，只需要进入新状态，不需要退出任何状态——因为初始化之前根本没有旧状态。

And this is about it. You try to build the code and load it to the board.

这样就差不多了。编译代码，下载到开发板上试试。

Reset button: Green light.

按下复位按钮：绿灯亮起。

SW1: five, four, three, two, one, BOOM!

按下 SW1：五、四、三、二、一，BOOM！

Well, it still works!

很好，还是正常工作！

---

This concludes this lesson about state tables and entry/exit actions to states.

关于状态表和状态进入/退出动作的课程就到这里。

To summarize: The state table represents a different type of the state machine implementation strategy, because in contrast to the nested-switch that was pure code, state table is data-driven.

总结一下：状态表代表了一种与嵌套 switch 完全不同的状态机实现策略。嵌套 switch 是纯代码驱动的，而状态表是**数据驱动（Data-Driven）**的。

Specifically, the implementation is centered around the state table data structure, which is then indexed into by both states and event-signals. Other data-driven state machine implementations include representing states as data objects, which are then interconnected and traversed at run time to execute transitions.

具体来说，整个实现以状态表数据结构为核心，通过状态和事件信号来索引。其他数据驱动的状态机实现方式还包括把状态表示为数据对象，运行时在这些对象之间连接和遍历来执行转换。

The main advantage of the state table representation is the highly regular structure that forces you to consider all possible state and event combinations. Also, the implementation provides relatively good and deterministic runtime performance.

状态表的主要优点是结构高度规整，强迫你考虑所有可能的状态和事件组合。而且运行时性能也比较好，而且是确定性的。

However, the technique has also many disadvantages.

但这种技术也有不少缺点。

The whole state machine code is highly fragmented into a large number of little "action handlers".

整个状态机代码被高度碎片化，分成了一大堆小"动作处理函数"。

Also, state tables themselves tend to be sparse with a lot of gaps, like even in your case of a trivially simple TimeBomb state machine.

状态表本身往往是稀疏的，里面有大量空位——即使像 TimeBomb 这么简单的状态机也不例外。

This is because the event-signals are used as indexes into the table and it is difficult to avoid gaps in the numerical values of the signals. For example, the event BUTTON_RELEASED is not handled by the current version of your TimeBomb. But it might be needed somewhere else in the system and it is generally difficult to optimize the numerical values of signals for multiple state machines.

这是因为事件信号被直接用作表格索引，而信号数值之间很难避免间隔。比如你的 TimeBomb 当前版本不处理 `BUTTON_RELEASED` 事件，但系统的其他地方可能需要它。要为多个状态机统一优化信号的数值编排，一般是很困难的。

But perhaps the biggest disadvantage of state tables is that they discourage adding new states and events, because that requires adding the whole new column or row into the table. Developers perceive this as a lot of overhead, and therefore they tend to avoid it. Instead, they add internal variables and guard conditions, which leads back to "spaghetti code" and defeats the purpose of using state machines that were exactly intended to avoid the "spaghetti".

但状态表最大的缺点，可能是它让人不愿意添加新的状态和事件——因为那意味着要给表格加一整行或一整列。开发者觉得太麻烦了，于是倾向于偷懒，改用内部变量和守卫条件来凑合。结果代码又退化成"面条式代码（Spaghetti Code）"，完全违背了使用状态机的初衷——状态机本来就是用来消灭面条代码的。

In the next lesson, I will show you another state machine implementation strategy based on a reusable event processor that I consider most optimal. Stay tuned!

下一课，我会介绍另一种基于**可复用事件处理器（Reusable Event Processor）**的状态机实现策略，我认为这是最优方案。敬请期待！

---

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads.

如果你喜欢这个频道，请给视频点赞、订阅。课程笔记和项目文件可以到 state-machine.com/video-course 下载。

Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course". Thanks for watching!

所有项目代码也在 GitHub 上，仓库是 Quantum Leaps 的 "modern embedded programming course"。感谢观看！

---

## 术语表 / Terminology

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| State Table | 状态表 | 用二维表格表示状态机的转换关系和动作 |
| State Machine | 状态机 | 描述系统行为的计算模型 |
| Nested-switch Statement | 嵌套 switch 语句 | 一种状态机实现方式，用多层 switch 结构 |
| Dispatch Function | dispatch 函数 | 分发事件到状态机进行处理的核心函数 |
| Event Signal | 事件信号 | 表示事件类型的标识符 |
| State Variable | 状态变量 | 跟踪状态机当前状态的变量 |
| Guard Condition | 守卫条件 | 决定转换是否发生的布尔条件 |
| Entry Action | 进入动作 | 进入状态时自动执行的动作 |
| Exit Action | 退出动作 | 退出状态时自动执行的动作 |
| Action Handler | 动作处理函数 | 处理特定事件-状态组合的函数 |
| Pointer to Function / Function Pointer | 函数指针 | 指向函数的指针，用于回调机制 |
| Transition | 转换 | 状态机中从一个状态到另一个状态的变化 |
| Truth Table | 真值表 | 列出所有输入组合及其对应输出的表格 |
| Mealy Machine | Mealy 机 | 动作与转换关联的状态机类型 |
| Moore Machine | Moore 机 | 动作与状态关联的状态机类型 |
| Data-Driven | 数据驱动 | 以数据结构为核心驱动程序逻辑的设计方式 |
| ROM | 只读存储器 | 非易失性存储器，断电后数据不丢失 |
| RAM | 随机存取存储器 | 易失性存储器，用于运行时数据存储 |
| Reusable Event Processor | 可复用事件处理器 | 通用的、可复用的状态机执行框架 |
| Spaghetti Code | 面条式代码 | 结构混乱、难以维护的代码 |
| typedef | 类型定义 | C 语言中为类型创建别名的关键字 |
| Initial Transition | 初始转换 | 状态机启动时执行的第一个转换 |
| assert | 断言 | 用于验证程序假设的调试机制 |
| UML Notation | UML 表示法 | 统一建模语言中的图形表示规范 |
