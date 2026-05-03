# 第39课：最优状态机实现（状态处理器方法） / Lesson 39: Optimal State Machine Implementation (State-Handler Approach)

---

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this fifth lesson on state machines, I'd like to show you the state machine implementation in C that I consider optimal according to the criteria that I'll enumerate. In the process, you will see how to build a reusable "event processor" to include this optimal state machine implementation strategy directly in the Micro-C-AO active object framework that you've been building in this segment of lessons.

大家好，欢迎来到《现代嵌入式系统编程》课程。我是 Miro Samek。这是状态机专题的第五节课，今天我要给大家展示一种用 C 语言实现状态机的方法，我认为这是最优方案——我会列出评判标准来说明为什么。在讲解过程中，你会学到如何构建一个可复用的"事件处理器"（event processor），然后把这种最优的状态机实现策略直接集成到你一直在搭建的 Micro-C-AO 活跃对象（Active Object）框架中。

---

To allow you for a direct comparison with the other state machine implementations presented so far, today you will keep working with the same "TimeBomb" example you used before.

为了方便你和之前讲过的其他状态机实现方式做直接对比，今天我们继续沿用之前用过的"TimeBomb"（定时炸弹）示例。

---

So, let's start with copying the previous lesson-38 directory and rename it to lesson-39. Get inside the new lesson-39 directory and double-clink on the project "lesson" to open it in the uVision IDE.

好，先把上一课的 lesson-38 目录复制一份，重命名为 lesson-39。进入新的 lesson-39 目录，双击工程文件 "lesson"，在 uVision IDE 中打开它。

---

To remind you quickly what happened so far, in the previous couple of lessons you've learned a few state machine implementation strategies in C, such as the nested-switch statement and the state table technique.

先快速回顾一下之前的进展：在前几节课里，你已经学了几种用 C 语言实现状态机的方法，比如嵌套 switch 语句（nested-switch statement）和状态表（state table）技术。

---

All of them had drawbacks, but they also had some promising features. So, today you'll explore the ways to mix and match the nice properties while getting rid of the drawbacks.

这些方法各有各的缺点，但也都有一些不错的特性。所以今天，我们要想办法把它们各自的优点组合起来，同时消除各自的缺陷。

---

But before all that, to arrive at an optimal solution, it often pays off to start with first imagining what that ideal should look like, and then to work *backwards* to the implementation in a programming language, like C in this case.

不过在动手之前，想要找到最优方案，一个好办法是先设想理想状态下应该是什么样子，然后从这个理想目标出发，反向推导出具体编程语言——在这里就是 C 语言——的实现。

---

So, let's imagine that you are inventing a Domain Specific Language (DSL), not so much to implement state machines, but to *specify* them. Such a DSL will then be a textual representation of the state machine diagrams.

那么，假设你要发明一种领域特定语言（Domain Specific Language, DSL），目的不是用来实现状态机，而是用来描述状态机。这种 DSL 本质上就是状态机图的文本表示。

---

At this point, please don't even think of the C syntax. Let's just try to specify your TimeBomb state machine in the most clear and succinct way you can think of.

现在先不要去想 C 语言的语法。我们就专注于一个问题：怎么用最清晰、最简洁的方式来描述你的 TimeBomb 状态机。

---

Well, in the state diagram, the most prominent elements you can see are states, so let's start with that...

在状态图中，最醒目的元素就是状态（state），所以我们就从状态开始。

---

The first state is wait4button, so here is the simplest possible way you can specify it as text.

第一个状态是 wait4button，下面是能用文本描述它的最简单方式。

---

This state has an entry action that you can specify as the word "Entry" followed by the actions, which you can simply copy over from the existing implementation in C.

这个状态有一个入口动作（entry action），你可以用 "Entry" 这个词开头，后面跟上具体的动作代码——这些代码可以直接从现有的 C 语言实现中复制过来。

---

The state has also also an exit action that you can specify in the similar way.

这个状态还有一个出口动作（exit action），用类似的方式来描述。

---

Finally, the state has a transition, triggered by the BUTTON_PRESSED event.

最后，这个状态有一个状态转移（transition），触发条件是 BUTTON_PRESSED 事件。

---

You can specify this by typing the name of the triggering event, followed by the actions in C. The state-table implementation explicitly assigned the state variable with the enumerated constant for that state. But this is neither the most concise nor it is consistent with your state names. So, let's specify the transition with the word "TRAN" followed by the target state name in parentheses, exactly as it is in your diagram.

你可以这样描述：先写触发事件的名称，后面跟上 C 语言的动作代码。之前的状态表实现中，显式地把状态变量赋值为对应的枚举常量。但这种写法既不够简洁，又和状态名称不一致。所以，我们用 "TRAN" 加上括号里的目标状态名称来描述转移，这和你的状态图中的写法完全一致。

---

Next is the blink state, which you specify the same way:

接下来是 blink 状态，描述方式相同：

---

You just follow your simple patterns for specifying the entry action, exit action and the TIMEOUT transition to pause.

你只需按照同样的简单模式来描述入口动作、出口动作以及 TIMEOUT 转移到 pause 状态就行了。

---

The pause state has only entry action and no exit.

pause 状态只有入口动作，没有出口动作。

---

But the TIMEOUT trigger leads to a choice point with guard conditions, which you can copy over from the previous C code:

但 TIMEOUT 触发器会导向一个选择点（choice point），带有守卫条件（guard condition），这部分代码可以从之前的 C 代码中复制过来。

---

Here, you only need to change the transition specifications.

在这里，你只需要修改转移的描述方式。

---

The last state is boom, which has only an entry action, where it simulates an explosion.

最后一个状态是 boom，它只有入口动作，用来模拟爆炸效果。

---

So, this would be the specification of the TimeBomb state machine, except that you still need to add the top-most initial transition.

好了，这就是 TimeBomb 状态机的完整描述了，不过你还需要加上最顶层的初始转移（initial transition）。

---

Here, you can reuse the generic state specification, because you can think of the initial transition as originating from the special "initial" pseudo-state -- the black dot. This black-dot pseudostate has only one transition, which is not triggered by any event and which goes to state wait4button, in case of your TimeBomb state machine.

这里你可以复用通用的状态描述格式，因为你可以把初始转移看作是从一个特殊的"初始"伪状态（pseudo-state）——也就是那个黑点——出发的转移。这个黑点伪状态只有一条转移，不需要任何事件触发，在你的 TimeBomb 状态机中，它指向 wait4button 状态。

---

So, here it is: a Domain Specific Language -- DSL for state machines that you've just invented. Such DSLs actually exist and most of them are similar to your invention.

好，这就是你刚刚发明出来的、用于状态机的领域特定语言——DSL。实际上，这类 DSL 是真实存在的，而且大多数和你的发明大同小异。

---

For instance, there is special tool called the State Machine Compiler -- SMC, which provides an "easy to understand language" for state machines. SMC then can translate that DSL into several programming languages, including C and C++.

比如，有一个专门的工具叫做状态机编译器（State Machine Compiler, SMC），它提供了一套"简单易懂的语言"来描述状态机。SMC 可以把这种 DSL 翻译成多种编程语言，包括 C 和 C++。

---

So, for a direct comparison, here is the same TimeBomb state machine specified with the SMC DSL.

为了直接对比，这里是同一个 TimeBomb 状态机用 SMC DSL 描述的结果。

---

As you can see, the general structure is remarkably similar, with the states playing the central role and other internal elements like Entry/Exit actions, Transitions, and guards very similar to your DSL. The biggest differences are in the specification of actions, because SMC does not allow you to use C directly.

如你所见，整体结构非常相似：状态是核心，其他的内部元素比如入口/出口动作、转移、守卫条件，都和你的 DSL 很像。最大的区别在于动作的描述方式，因为 SMC 不允许你直接使用 C 语言代码。

---

I will get back to the SMC example later in this lesson, because right now I have a bigger fish to fry. The idea is exactly NOT to use a special compiler, like SMC, but rather to add a minimal amount of syntax directly to your DSL to turn it into a legal C program. So let's see what you can do...

稍后我会回到 SMC 的例子，因为现在我有更重要的事情要做。我的想法恰恰是不使用像 SMC 这样的专门编译器，而是在你的 DSL 上添加最少的语法，让它直接变成一个合法的 C 程序。来看看怎么做。

---

Well, the state specifications could be turned into C functions. This should make sense, because the main job of a state is to respond to events by executing action code, and executing code is exactly what function are for.

状态描述可以转换成 C 语言函数。这很合理，因为状态的主要工作就是响应事件、执行动作代码，而执行代码正是函数的职责。

---

The syntax of your DSL is already pretty close to a C function. The missing piece in the signature is the list of parameters. But here, when you look at the actions, you can see that they need to access the "me" pointer and you also need the current event signal to determine what event you are getting. Therefore the state-handler functions need the same parameters as the action-handlers from the previous state-table implementation.

你的 DSL 语法已经非常接近 C 函数了，缺的只是参数列表。但你看一下里面的动作代码，它们需要访问 "me" 指针，还需要获取当前的事件信号来判断收到的是什么事件。所以，状态处理器（state-handler）函数需要的参数和之前状态表实现中的动作处理器（action-handler）是一样的。

---

But now, the presence of the "me" pointer indicates that the state-handlers are not just any functions. Rather, they are *member* functions of the TimeBomb class, just like the action-handlers were before. The coding convention for member functions in C, which I introduced in the segment of lessons 29 through 32 about object-oriented programming, requires to add the class name prefix to all of the member functions. So, let's just do that.

现在，"me" 指针的存在意味着状态处理器不是普通的函数。它们是 TimeBomb 类的成员函数（member function），和之前的动作处理器一样。在第 29 到 32 课关于面向对象编程的部分，我介绍过 C 语言中成员函数的编码规范：所有成员函数都要加上类名前缀。那我们就照做。

---

Please note that you need to add the prefix also to the target states of transitions.

请注意，你还需要在转移的目标状态前面加上这个前缀。

---

And finally, to finish off the signature, the word "State" now corresponds to the return value from the state-handler function. This could be the same status information used before for the action-handlers as to what happened inside the handler. So, let's rename Status to State, so that the specification for a state reads exactly as you originally designed.

最后，为了完成函数签名，"State" 这个词现在对应状态处理器函数的返回值。这个返回值可以和之前动作处理器使用的状态信息一样，用来表示处理器内部发生了什么。所以，我们把 Status 改名为 State，这样状态的描述方式就和你最初设计的完全一致了。

---

Alright, so now you need to adjust the syntax inside your states-handler functions. For this, you can reuse the design from the nested-switch statement technique you've learned back in lesson-36.

好，现在你需要调整状态处理器函数内部的语法。这里可以复用你在第 36 课学过的嵌套 switch 语句技术中的设计思路。

---

Specifically, each of your state-handler functions now corresponds to a case statement at the first level of the nested switch.

具体来说，每个状态处理器函数对应的是嵌套 switch 第一层的 case 分支。

---

The second level of the switch, based on the event-signal, corresponds then to the inside of each state. This inside structure is exactly what you need now, so you can just copy it over.

switch 的第二层基于事件信号，对应的就是每个状态的内部结构。这个内部结构正是你现在需要的，所以可以直接复制过来。

---

As far as the entry and exit actions are concerned, the nested-switch technique didn't support them. But they can be handled similarly as you already did in the state-table technique, by means of the special, reserved event signals: ENTRY_SIG and EXIT_SIG that are already defined in your Micro-C-AO header file.

至于入口动作和出口动作，嵌套 switch 技术之前并不支持。但可以像状态表技术中那样处理，使用特殊的保留事件信号：ENTRY_SIG 和 EXIT_SIG，这些在你的 Micro-C-AO 头文件中已经定义好了。

---

Putting this all together, this is how the internal implementation of a state-handler function could look like:

把所有这些组合起来，状态处理器函数的内部实现大概是这样的。

---

But according to the signature, your state-handler function needs to return the status information. For example, after handling an Entry or Exit action, you should return the HANDLED_STATUS.

但根据函数签名，状态处理器函数需要返回状态信息。比如，处理完 Entry 或 Exit 动作后，应该返回 HANDLED_STATUS。

---

But having multiple returns from a function is against some popular, embedded coding standards, such as MISRA-C. So, to avoid violating such rules, you can declare an automatic variable 'status', which you will then set in every case statement and return at the end of the function.

但一个函数中有多个 return 语句违反了一些流行的嵌入式编码规范，比如 MISRA-C。为了避免违反这类规则，你可以声明一个局部变量 status，然后在每个 case 分支中给它赋值，最后在函数末尾统一返回。

---

Here you need to be careful not to forget to return the IGNORED_STATUS, when an event is NOT handled. You can do this either by initializing the status variable, or by providing the default case.

这里要小心，不要忘了在事件未被处理时返回 IGNORED_STATUS。你可以通过初始化 status 变量来实现，或者提供一个 default 分支。

---

I prefer to leave status uninitialized and provide the default case, because then the compiler could issue a warning if I forget to set the status variable in some cases.

我个人更倾向于不初始化 status 变量、而是提供 default 分支。因为这样如果我忘了在某些分支中设置 status 变量，编译器就能发出警告。

---

This particular compiler will do this when you provide the minus-W conditional-uninitialized and minus-W-sometimes-uninitialized options.

这个编译器在你提供 -Wconditional-uninitialized 和 -Wsometimes-uninitialized 选项时就能做到这一点。

---

Which leads to the case where you don't yet set the status -- that is when a state transition is taken.

这就引出了还有一种情况你没有设置 status——那就是发生了状态转移的时候。

---

Here, the TRAN() facility is perhaps the most interesting aspect of the design. It is closely related to the internal representation of the state variable, because transition means changing the state variable.

这里的 TRAN() 机制可能是整个设计中最有趣的部分。它和状态变量的内部表示密切相关，因为转移就意味着改变状态变量。

---

Previously, in all your state machine implementations, the state variable was an enumeration of states.

之前在所有状态机实现中，状态变量都是一个状态的枚举类型。

---

But today, it must be directly related to the state-handler functions, because they are provided as the parameter to the TRAN() facility.

但今天，它必须直接关联到状态处理器函数，因为这些函数被作为参数传给了 TRAN() 机制。

---

Well, this is a classic use case for a pointer-to-function, which can point at different times to all the different state-handler functions comprising your state machine.

这是一个经典的函数指针（pointer-to-function）使用场景——函数指针可以在不同时刻指向组成你状态机的各个不同的状态处理器函数。

---

So in your C code, you need to typedef the StateHandler as a pointer-to-function, which has the signature of your state handler-function.

所以在 C 代码中，你需要把 StateHandler 用 typedef 定义为一个函数指针类型，它的签名和你的状态处理器函数一致。

---

Now, you need to move the State enumeration before the StateHandler typedef.

接下来，你需要把 State 枚举的定义移到 StateHandler typedef 之前。

---

And you also need to move around the typedefs for TimeBomb, so that they appear in the right order.

你还需要调整 TimeBomb 的 typedef 定义，确保它们出现的顺序正确。

---

So, finally, you can define the TRAN() facility as a macro with the parameter target_, which it would simply assign to the state variable.

好，现在你可以把 TRAN() 定义为一个带参数 target_ 的宏，它的功能就是把 target_ 赋值给状态变量。

---

But, it would be also nice if the macro could take on the value of TRAN_STATUS, so that you can directly assign this to the status variable, like so.

但如果这个宏还能取值为 TRAN_STATUS 就更好了，这样你就可以直接把它赋给 status 变量，像这样。

---

This is possible by means of the C-language comma-operator, which evaluates expressions from left-to-right and takes on the value last expression. So, the following will assign the parameter target_ to me->state and it will take on the value TRAN_STATUS, which is exactly what you want.

这可以通过 C 语言的逗号运算符（comma operator）来实现——逗号运算符会从左到右依次计算各个表达式，最终取最后一个表达式的值。所以，下面的代码会把参数 target_ 赋给 me->state，同时整个表达式的值是 TRAN_STATUS——这正是你想要的效果。

---

This completes the transformation of the "wait4button" state specification to a state-handler function in C, so let me quickly apply the same syntax changes to all the other states in your state machine.

这样就把 wait4button 状态的描述完整转换成了 C 语言的状态处理器函数。让我快速把同样的语法修改应用到状态机中的其他状态。

---

In the special initial pseudostate, you can simply return the TRAN() status.

在特殊的初始伪状态中，你可以直接返回 TRAN() 的状态。

---

The last problem is that the TRAN() macro references the state-handler functions that are often not yet known to the compiler, because they are defined later. You can easily fix this by providing the prototypes of all state-handlers right after the TimeBomb stuct. This list of all state-handler functions roughly corresponds to your previous enumeration of all states.

最后一个问题是 TRAN() 宏引用的状态处理器函数往往编译器还不知道，因为它们在后面才定义。你可以在 TimeBomb 结构体定义之后、提供所有状态处理器的函数原型来轻松解决这个问题。这个函数原型的列表大致对应你之前的所有状态的枚举。

---

So, now you can delete the previous state-table-based code. But before you do, just note that your implementation based on state-handlers falls in the sweet spot, between the action-handlers that are too fine in granularity and the monolithic nested-switch implementation.

好，现在你可以删除之前基于状态表的代码了。但在删除之前请注意，基于状态处理器的实现恰好处于一个理想的中间位置——比动作处理器粒度更粗，又不像整体式的嵌套 switch 那样粗糙。

---

You also no longer need the problematic state-table, which was often sparse and thus wasteful, and discouraged developers from adding new states or new events. The state-handlers are much more maintainable.

你也不再需要那个有问题的状态表了——状态表通常很稀疏、浪费内存，而且会阻碍开发者添加新的状态或事件。状态处理器要容易维护得多。

---

But their greatest advantage lies in readability, because now the state-handlers directly represent the main components of a state machine: the states. Inside those states, you can very easily recognize other state machine elements, such as entry/exit actions, state transitions, and guard conditions.

但状态处理器最大的优势在于可读性——因为现在状态处理器直接对应状态机的核心组成元素：状态。在这些状态的内部，你可以很容易地识别出其他状态机元素，比如入口/出口动作、状态转移和守卫条件。

---

In fact, I really hope that you view the state-handlers as a domain-specific language that works directly at the higher-level of abstraction of state machine elements, not the low-level C instructions.

实际上，我真心希望你能把状态处理器看成一种领域特定语言——它直接在状态机元素这个更高的抽象层次上工作，而不是在底层 C 语言指令的层次上。

---

Alright, but you are not quite done yet, because you still need to adjust the dispatch() operation from the previous lesson to work with state-handlers rather than the state-table.

好了，但还没完，因为你还需要修改上一课的 dispatch() 操作，让它适配状态处理器而不是状态表。

---

First, change the type Status to State consistently with your new definition.

首先，把 Status 类型改为 State，和你的新定义保持一致。

---

Next, change the type of prev_state to StateHandler pointer-to-function.

然后，把 prev_state 的类型改为 StateHandler 函数指针。

---

In the assertion, change the check of the state variable to make sure that it is not zero, meaning that it is initialized.

在断言（assertion）中，修改状态变量的检查方式，确保它不为零，即已初始化。

---

Now, in the call to the state handler you just remove the indirection layer of the state-table and all the indexing. Your state pointer-to-function variable offers a faster, immediate access to the current state handler.

现在，在调用状态处理器时，你只需要去掉状态表这一层间接访问以及所有的索引操作。你的状态函数指针变量提供了更快、更直接的方式来访问当前的状态处理器。

---

When the state-handler reports that a transition has been taken...

当状态处理器报告发生了状态转移时……

---

You again adjust the assertion to make sure that the new state is valid.

你同样需要调整断言，确保新状态是有效的。

---

And you again remove the indirection layer of the state-table in the calls to the state-handlers to process the exit of the previous state and entry to the new state.

你还需要去掉状态表这一层间接访问，在调用状态处理器处理前一状态的退出和新状态的进入时。

---

Here, you cannot pass NULL-pointers for events, because your state handler always de-references the event-pointer parameter.

这里你不能传递 NULL 指针作为事件参数，因为你的状态处理器总是会解引用（dereference）事件指针参数。

---

But instead, you can use the immutable, static and const events with the reserved ENTRY_SIG and EXIT_SIG signals.

但你可以使用不可变的、静态的 const 事件，带有保留的 ENTRY_SIG 和 EXIT_SIG 信号。

---

So, you pass the exit event to the previous state-handler and the entry event to the new state-handler.

所以，你把退出事件传给前一状态处理器，把进入事件传给新状态处理器。

---

Finally, you need to change the handling of the initial transition, because your initial state handler does not return the INIT_STATUS anymore.

最后，你需要修改初始转移的处理方式，因为你的初始状态处理器不再返回 INIT_STATUS 了。

---

Instead, for now, you can just check if the event passed to the dispatch operation has the reserved INIT_SIG, and if so, you skip the exit from the previous state.

目前，你可以先检查传给 dispatch 操作的事件是否是保留的 INIT_SIG，如果是，就跳过前一状态的退出处理。

---

The state machine initialization aspect will be re-designed in the next step, but right now you just want something that works.

状态机初始化部分将在下一步重新设计，但现在你只需要一个能工作的方案。

---

The last thing you need to change is the initialization of the state variable in the constructor. Here, you set it to the initial pseudostate-handler.

最后一处需要修改的是构造函数中状态变量的初始化。在这里，你把它设置为初始伪状态处理器。

---

Now, you can re-build the project and...,

好，现在重新编译工程……

---

what do you know -- the compiler reports no errors and no warnings.

你猜怎么着——编译器报告零错误、零警告。

---

By the way, let's check if the compiler notices an uninitialized case of the status variable...

顺便看看编译器是否能检测到 status 变量未初始化的情况……

---

Well, it actually does.

确实检测到了。

---

I'm sure you're curious how it works on your TivaC LanuchPad, so let's load it and test.

我相信你一定迫不及待想看看它在 TivaC LaunchPad 上的实际表现，那我们就下载进去测试一下。

---

Reset -- green light.

复位——绿灯亮起。

---

Button press -- five, four, three, two, one, BOOM!

按下按钮——五、四、三、二、一，BOOM！

---

It works!

成功了！

---

Alright! This is very encouraging. But you can still do much better than that!

太好了！这非常鼓舞人心。但你还可以做得更好！

---

Because, as it turns out, the dispatch operation for your new state-handler implementation is completely generic. There is really nothing specific to the TimeBomb sate machine there and the exact same implementation would work for any other state machine, like for example Blinky or something much more interesting.

因为，事实证明，你的新状态处理器实现的 dispatch 操作是完全通用的。里面没有任何 TimeBomb 状态机特有的东西，完全相同的实现可以用于任何其他状态机，比如 Blinky 或者更复杂的例子。

---

So, there is an opportunity here to improve the design and include the generic state machine management right into your Micro-C-AO framework.

所以这里有一个改进设计的机会——把这个通用的状态机管理功能直接集成到你的 Micro-C-AO 框架中。

---

Specifically, the current design is that your Micro-C-AO active object framework provides the Active base class, which you then inherit in your application-level classes, like your TimeBomb, or Blinky, or other such classes.

具体来说，当前的设计是：你的 Micro-C-AO 活跃对象框架提供了 Active 基类（base class），然后你在应用层的类中继承它，比如 TimeBomb、Blinky 等等。

---

So, now, you can exploit this inheritance to consolidate the common elements, like the state machine management shown in blue, in the  "Active" base class to be inherited rather than repeated. This is exactly what inheritance is for. By the way, if you missed my lessons about object-oriented-programming in C, inheritance is discussed in lesson-30.

现在，你可以利用这种继承关系，把公共元素整合起来——比如蓝色标注的状态机管理部分——放到 Active 基类中，通过继承来使用而不是重复编写。这正是继承的用途。顺便说一句，如果你错过了我关于 C 语言面向对象编程的课程，继承在第 30 课有详细讲解。

---

But you can go even smarter about it. You can create even more useful class hierarchy by adding the FSM (for Finite State Machine) base class, which then will be inherited by Active and also, indirectly, by TimeBomb and Blinky.

但你还可以做得更巧妙。你可以创建一个更有用的类层次结构——增加一个 FSM（有限状态机，Finite State Machine）基类，然后让 Active 继承 FSM，TimeBomb 和 Blinky 再间接继承 FSM。

---

The advantage of separating FSM from Active is that FSM can then be used by itself, for passive state machines that are not necessarily active objects. Such FSMs could be then useful for example inside interrupt service routines.

把 FSM 从 Active 中分离出来的好处是，FSM 可以独立使用，用于不一定是活跃对象的被动状态机。这种 FSM 可以用在中断服务程序（Interrupt Service Routine, ISR）等场景中。

---

OK, this sounds like a plan, so let's try to code it.

好，计划已定，开始编码。

---

So, the first set of changes will be in the Micro-C-AO-dot-H header file, where you need to declare the Fsm class based on the TimeBomb class.

第一组修改在 Micro-C-AO.h 头文件中，你需要基于 TimeBomb 类来声明 Fsm 类。

---

By the way, this type of code modification, where you want to improve the design but without really changing the behavior is called "Refactoring.

顺便提一下，这种类型的代码修改——你想改进设计但不改变行为——叫做"重构"（Refactoring）。

---

The TRAN() macro will require some changes, but let's leave it for later when the context will become clearer.

TRAN() 宏需要一些修改，但我们先放一放，等上下文更清楚了再处理。

---

Inside the Fsm base class, all you really need is the state variable typed as the StateHandler pointer-to-function.

在 Fsm 基类内部，你真正需要的只是一个 StateHandler 函数指针类型的 state 变量。

---

As far as the member functions of the Fsm class are concerned:

至于 Fsm 类的成员函数：

---

The constructor will take the initial state-handler in the specific subclass, such as the TimeBomb_initial.

构造函数接收一个初始状态处理器，它来自具体的子类，比如 TimeBomb_initial。

---

The init operation will execute the initial transition and also an entry action to the first state.

init 操作执行初始转移，同时也会执行第一个状态的入口动作。

---

The dispatch operation will handle all subsequent events.

dispatch 操作处理后续的所有事件。

---

Now, you need to adjust the Active class to inherit Fsm.

好，现在你需要修改 Active 类来继承 Fsm。

---

Here you no longer need to remember the dispatch operation, because this will be handled by the Fsm_dispatch.

这里你不再需要声明 dispatch 操作了，因为这会由 Fsm_dispatch 来处理。

---

Instead, you need to adjust the signature of the Active constructor to take the initial pseudo-state, just like in the Fsm constructor.

取而代之的是，你需要修改 Active 构造函数的签名，让它接收初始伪状态，和 Fsm 构造函数一样。

---

OK, so let's copy the FSM class declaration and open the Micro-C-AO-dot-C source file to add the implementation of this class.

好，把 FSM 类的声明复制过来，然后打开 Micro-C-AO.c 源文件来添加这个类的实现。

---

Get rid of the unnecessary stuff and start defining the member functions.

删掉不需要的内容，开始定义成员函数。

---

The FSM constructor simply initializes the me-state variable to the initial pseudostate.

FSM 构造函数很简单，就是把 me->state 变量初始化为初始伪状态。

---

Let's skip the init operation for now...

先跳过 init 操作……

---

And go straight to the dispatch operation:

直接看 dispatch 操作：

---

which you already implemented for the TimeBomb state machine.

这个你已经为 TimeBomb 状态机实现过了。

---

The only change here is getting rid of the check for the initial transition, because this has been redesigned and now is handled in the init() operation.

唯一的改动是去掉了初始转移的检查，因为这部分已经重新设计，现在由 init() 操作来处理了。

---

Speaking of which, the init operation is similar to dispatch, but it is simpler, because after executing the initial transition you can simply enter the new state.

说到 init 操作，它和 dispatch 类似，但更简单，因为执行完初始转移后，你只需要进入新状态就行了。

---

But to enter a state, you need the immutable (static and const) entryEvt, which is local to the dispatch operation. To avoid duplicating this event, you can promote the immutable events to the file scope.

但要进入一个状态，你需要那个不可变的（静态 const）entryEvt，而这个事件之前是 dispatch 操作的局部变量。为了避免重复定义这个事件，你可以把不可变事件提升到文件作用域。

---

Now, you need to adjust the Active class constructor, because Active now inherits FSM, so the Active constructor must call the FSM's constructor.

接下来，你需要修改 Active 类的构造函数，因为 Active 现在继承了 FSM，所以 Active 的构造函数必须调用 FSM 的构造函数。

---

And finally, in the Active start operation, you need to adjust the initialization of the state machine.

最后，在 Active 的 start 操作中，你需要调整状态机的初始化方式。

---

Here, you call the FSM-init operation, whereas you can pass a NULL event pointer, because initial transition is not triggered by an event and this parameter is passed to the initial pseduo-state handler only to conform with the StateHandler signature.

在这里调用 FSM 的 init 操作，你可以传一个 NULL 事件指针，因为初始转移不是由事件触发的，这个参数只是传给初始伪状态处理器以符合 StateHandler 的签名要求。

---

The previous, generic dispatch via a pointer-to-function becomes now the specific FSM_dispatch().

之前通过函数指针的通用 dispatch 调用现在变成了具体的 FSM_dispatch()。

---

The framework update is now finished, so let's check whether the file Micro-C-AO-dot-C compiles.

框架更新到此完成，我们来检查一下 Micro-C-AO.c 文件能否编译通过。

---

Alright, so let's move on to the TimeBomb implementation, which needs a few tweaks due to the framework refactoring that you just did.

好，接下来看 TimeBomb 的实现，由于你刚才对框架做了重构，这里也需要做一些调整。

---

You need to delete the typedefs that were moved up to the framework.

你需要删除已经移到框架中的那些 typedef 定义。

---

And you also need to delete the state variable from the TimeBomb class, because it is now inherited from the Active and indirectly from the Fsm superclass.

你还需要从 TimeBomb 类中删除 state 变量，因为它现在从 Active 间接继承自 Fsm 父类了。

---

The last change will be in the TimeBomb constructor, due to the changed constructor of the Active superclass.

最后一处修改在 TimeBomb 的构造函数中，因为 Active 父类的构造函数签名改了。

---

Here, you need to pass on TimeBomb_initial state-handler instead of the deleted TimeBomb_dispatch operation, and you don't need to initialize the state variable, because this is already done in the constructors of subperclasses.

在这里，你需要传入 TimeBomb_initial 状态处理器，替代已删除的 TimeBomb_dispatch 操作，而且你不需要再初始化 state 变量了，因为这已经在父类的构造函数中完成了。

---

That should be all, so let's try to compile the updated TimeBomb implementation.

应该就这些了，让我们试着编译更新后的 TimeBomb 实现。

---

Well, the compiler complains about the TRAN macro, because it cannot find the member "state" in the "me" struct.

编译器抱怨 TRAN 宏有问题，因为在 "me" 结构体中找不到 "state" 成员。

---

This is because now state is no longer a direct member of the TimeBomb class, but rather it is inherited from the Fsm super-super class.

这是因为现在 state 不再是 TimeBomb 类的直接成员了，而是从 Fsm 超超类中继承的。

---

The remedy is to modify the TRAN() macro to explicitly up-cast the "me" pointer to the Fsm superclass. As you remember from lessons about object-oriented programming, such upcasting is always legal and OOP languages, like C++ perform them automatically.

解决办法是修改 TRAN() 宏，显式地把 "me" 指针向上转型（upcast）为 Fsm 超类指针。正如你在面向对象编程课程中学到的，这种向上转型总是合法的，C++ 等面向对象语言会自动执行这种转换。

---

And as your are at it, you also need to cast the target parameter to StateHandler, because of the slight differences in the parameter list. Specifically, the "me" pointer of all TimeBomb state handlers points to the TimeBomb subclass, whereas the StateHandler pointer-to-function type expects the "me" pointer of the Fsm type, of the superclass.

与此同时，你还需要把 target 参数转型为 StateHandler，因为参数列表有细微差异。具体来说，所有 TimeBomb 状态处理器的 "me" 指针指向 TimeBomb 子类，而 StateHandler 函数指针类型期望的是 Fsm 类型——即父类的 "me" 指针。

---

OK, so after these final tweaks, the whole project builds cleanly.

好，经过这些最后的调整，整个工程可以干净地编译了。

---

Of course, the first order of business now is to check whether your TimeBomb still works...

当然，现在的首要任务是验证 TimeBomb 是否仍然正常工作。

---

Button press: five, four, three, two, one, BOOM! It works!

按下按钮：五、四、三、二、一，BOOM！正常工作！

---

Alright, but as you already have your new state-handler implementation in the debugger, I though that you might be interested in quantifying the execution speed, especially because I claim that this method is "optimal".

太好了。既然你的新状态处理器实现已经加载到调试器中了，我想你可能会对量化执行速度感兴趣，尤其因为我声称这种方法是"最优的"。

---

For this, you might use an interesting feature supported by your TivaC Cortex-M4 processor, which allows you to measure the number of clock cycles taken by code execution. Specifically, the CPU has a hardware block called DWT (Data Watchpoint and Trace), where there is a cycle counter register.

为此，你可以利用 TivaC Cortex-M4 处理器支持的一个有趣特性——它可以测量代码执行所消耗的时钟周期数。具体来说，CPU 内部有一个叫做 DWT（Data Watchpoint and Trace，数据监视点与跟踪）的硬件模块，里面有一个周期计数器（cycle counter）寄存器。

---

So, here is how you can use this:

使用方法如下：

---

After resetting the CPU, open the Micro-C-AO-dot-C file and set a breakpoint at Fsm_dispatch. Your goal will be to time this function.

复位 CPU 后，打开 Micro-C-AO.c 文件，在 Fsm_dispatch 处设置一个断点。你的目标是测量这个函数的执行时间。

---

Now, run the code free and press the button. The breakpoint is hit, because you are about to dispatch the BUTTON_PRESSED event to your state machine.

现在让代码自由运行，然后按下按钮。断点被命中了，因为你即将把 BUTTON_PRESSED 事件分派给状态机。

---

Open a memory view and point it to the address of the DWT at hex-E000 1000. The cycle counter is the second word. Click on it and type zero to clear it.

打开内存查看窗口，指向 DWT 的地址 0xE0001000。周期计数器是第二个字（word）。点击它并输入零来清零。

---

Now, step OVER the Fsm_dispatch call. The cycle-counter register reads now hex-DF, which is the number of CPU clock cycles it took. This is 226 cycles in decimal.

现在，单步跳过（Step Over）Fsm_dispatch 调用。周期计数器寄存器现在显示 0xDF，这就是消耗的 CPU 时钟周期数，换算成十进制是 226 个周期。

---

Assuming 40 MHz CPU clock, this is about 5 microseconds. But more meaningful would be the relative comparison to the other state machine implementations.

假设 CPU 时钟频率为 40 MHz，这大约是 5 微秒。但更有意义的是和其他状态机实现方式的相对比较。

---

So for example, I performed the same experiment, for the same transition, with the state-table implementation from lesson-38, and it executed in about 206 cycles. This is only 10% better than state-handlers, even though state-table is generally advertised as the fastest, because it avoids the switch statements.

比如，我用第 38 课的状态表实现做了同样的实验，同样的转移，它执行了大约 206 个周期。这只比状态处理器快 10%，虽然状态表通常被宣传为最快的方案，因为它避免了 switch 语句。

---

As it tuns out, the new state-handler method is almost as fast, while being much more readable, maintainable, and significantly smaller in terms of memory, because you don't need the big and sparse state-table.

事实证明，新的状态处理器方法在速度上几乎一样快，同时可读性和可维护性好得多，内存占用也显著更小，因为你不需要那个庞大而稀疏的状态表。

---

The nested-switch statement method from lesson 36 performed the fastest, at only 146 cycles, but this version didn't support entry and exit actions (which are both present in the measured transition), so this is not really comparable.

第 36 课的嵌套 switch 语句方法最快，只有 146 个周期，但那个版本不支持入口和出口动作（而这两者在被测量的转移中都存在），所以这并不是真正的同等比较。

---

I'm unfortunately running out of my time budget for this lesson, but I still promised to show you the State Machine Compiler, SMC as yet another state machine implementation technique.

很遗憾这节课的时间快到了，但我之前还答应过要展示状态机编译器（State Machine Compiler, SMC）这种状态机实现技术。

---

So, let me open the second project, lesson-39-smc, that will be also included in the download for this lesson. This second project contains fully functional TimeBomb for your TivaC LauchPad board with SMC.

让我打开第二个工程——lesson-39-smc，它也会包含在这节课的下载资源中。这个第二工程包含了用 SMC 实现的、完全可运行的、适用于你的 TivaC LaunchPad 开发板的 TimeBomb。

---

The central piece of the SMC project is the file timebomb-dot-sm, containing the TimeBomb state machine specification in the SMC domain specific language.

SMC 工程的核心是 timebomb.sm 文件，里面是用 SMC 领域特定语言描述的 TimeBomb 状态机。

---

Frankly, to me, such a DSL makes little sense, because the SMC language is still just textual representation not really simpler or more expressive than the direct state-handler-based implementation in C. I mention it here only because various DSLs and special compilers have been quite popular back in the day, so you should know about this approach.

说实话，对我来说这种 DSL 意义不大，因为 SMC 语言本质上还是文本表示，并不比直接用 C 语言基于状态处理器的实现更简单或更有表现力。我在这里提到它，只是因为各种 DSL 和专门编译器在过去确实很流行，所以你应该了解这种方式。

---

The dot-SM file requires an additional step of compiling it into the C code, and the Micro-Vision IDE offers you a way to assign the pre-processing tool to such custom files. Here, you assign the SMC compiler, which is included in the project. The only requirement is that you have java installed on your machine.

.sm 文件需要一个额外的编译步骤来生成 C 代码，而 Micro-Vision IDE 提供了一种方式，可以为这类自定义文件指定预处理工具。在这里你指定 SMC 编译器，它已包含在工程中。唯一的前提条件是你的机器上安装了 Java。

---

So now, when you build the project, the SMC compiler is invoked and it re-generates the files timebomb-unerscore-sm-dot-h and dot-c.

现在，当你编译工程时，SMC 编译器会被调用，并重新生成 timebomb_sm.h 和 timebomb_sm.c 文件。

---

These files are included in the project, so you need to re-fresh them in the editor.

这些文件已包含在工程中，所以你需要在编辑器中刷新它们。

---

So, here is the C code generated by the SMC compiler. You can examine it by yourself, but it is obviously much more complex than your state-handlers.

好，这就是 SMC 编译器生成的 C 代码。你可以自己仔细看看，但很明显它比你的状态处理器要复杂得多。

---

The SMC code is based on the object-oriented State Pattern, with several classes, including every state being a separate class. There is also a special Context class for managing the state objects.

SMC 代码基于面向对象的状态模式（State Pattern），包含多个类，其中每个状态都是一个独立的类。还有一个特殊的 Context 类来管理状态对象。

---

Overall, the State-Pattern belongs to the category of the Data-Based strategies, which tend to be complex.

总体来说，状态模式属于基于数据的策略（Data-Based strategy）类别，这类策略往往比较复杂。

---

In contrast, the State-Handlers belong to the Code-Based strategies, which tend to be simpler.

而状态处理器属于基于代码的策略（Code-Based strategy），这类策略通常更简单。

---

This concludes this overview of the various state implementation strategies. Of course, there many more variants, but they all tend to be combinations of the basic techniques that you've just learned.

关于各种状态机实现策略的介绍到此结束。当然还有很多变体，但它们基本都是你刚学过的这些基本技术的组合。

---

My clear preference and recommendation is the state-handler method, because I consider it the most readable and maintainable with good performance both in memory use and in CPU time.

我明确推荐的是状态处理器方法，因为它可读性最好、可维护性最强，在内存使用和 CPU 时间方面性能也很好。

---

That's why, this "optimal" implementation is now built into your Micro-C-AO framework.

因此，这种"最优"实现现在已经内置到你的 Micro-C-AO 框架中了。

---

In the next lesson, I'll move on to the modern, hierarchical state machines, which are perhaps the most powerful design tool I've ever used.

下一节课，我们将进入现代的层次化状态机（Hierarchical State Machine）——这可能是我用过的最强大的设计工具。

---

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads.

如果你喜欢这个频道，请给这个视频点个赞并订阅，以便持续关注。你也可以访问 state-machine.com/video-course 获取课堂笔记和工程文件下载。

---

Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course". Tanks for watching!

最后，所有工程也可以在 GitHub 上 Quantum Leaps 的 "modern embedded programming course" 仓库中找到。感谢观看！

---

## 术语表

| 英文术语 | 中文翻译 | 说明 |
|---|---|---|
| State Machine | 状态机 | |
| State Handler | 状态处理器 | 以函数形式实现的状态 |
| Action Handler | 动作处理器 | 状态表中处理具体动作的函数 |
| Active Object | 活跃对象 | 具有独立执行线程和事件队列的对象模型 |
| Event Processor | 事件处理器 | 分派事件到状态机的通用机制 |
| Domain Specific Language (DSL) | 领域特定语言 | 为特定领域设计的专用语言 |
| State Machine Compiler (SMC) | 状态机编译器 | 将 DSL 描述的状态机翻译为 C/C++ 代码的工具 |
| Entry Action | 入口动作 | 进入状态时执行的动作 |
| Exit Action | 出口动作 | 退出状态时执行的动作 |
| Transition | 状态转移 / 转移 | 从一个状态到另一个状态的切换 |
| Guard Condition | 守卫条件 | 转移上的条件判断 |
| Choice Point | 选择点 | 状态图中的菱形判断节点 |
| Initial Transition | 初始转移 | 状态机启动时执行的第一个转移 |
| Pseudo-state | 伪状态 | 如初始黑点等非真正状态的特殊节点 |
| State Table | 状态表 | 用二维表格存储状态-事件到动作映射的实现方式 |
| Nested-Switch Statement | 嵌套 switch 语句 | 用多层 switch-case 实现状态机的方法 |
| Pointer-to-Function | 函数指针 | 指向函数的指针，用于在运行时动态选择调用目标 |
| Member Function | 成员函数 | 属于某个类的函数 |
| Base Class | 基类 | 被其他类继承的父类 |
| Inheritance | 继承 | 面向对象编程中子类获得父类特性的机制 |
| Upcast / Upcasting | 向上转型 | 子类指针转为父类指针，总是安全的 |
| Refactoring | 重构 | 改进设计但不改变行为的代码修改 |
| Assertion | 断言 | 运行时条件检查 |
| Dereference | 解引用 | 对指针取其指向的值 |
| Immutable | 不可变的 | 值不能被修改 |
| Finite State Machine (FSM) | 有限状态机 | 具有有限个状态并在状态间转移的计算模型 |
| Interrupt Service Routine (ISR) | 中断服务程序 | 响应硬件中断的处理函数 |
| State Pattern | 状态模式 | 面向对象设计模式，将每个状态封装为单独的类 |
| Data-Based Strategy | 基于数据的策略 | 以数据结构为主要组织手段的状态机实现方式 |
| Code-Based Strategy | 基于代码的策略 | 以代码（函数）为主要组织手段的状态机实现方式 |
| Hierarchical State Machine | 层次化状态机 | 支持状态嵌套的状态机 |
| Comma Operator | 逗号运算符 | C 语言运算符，从左到右求值，取最后一个表达式的值 |
| DWT (Data Watchpoint and Trace) | 数据监视点与跟踪 | ARM Cortex-M 的调试硬件模块，含周期计数器 |
| Cycle Counter | 周期计数器 | 记录 CPU 时钟周期数的寄存器 |
| MISRA-C | MISRA-C | 嵌入式 C 语言编码规范 |
| Micro-C-AO | Micro-C-AO | 本课程中的轻量级活跃对象框架 |
