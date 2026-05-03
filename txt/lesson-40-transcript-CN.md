# 第40课：层次状态机初探 / Lesson 40: First Glimpse of Hierarchical State Machines

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this sixth lesson on state machines I would like to give you the first glimpse of modern hierarchical state machines. Today, you will learn what hierarchical state machines are and how they differ from the traditional finite state machines. You will also get an idea how to implement state hierarchy in C and you'll see which aspects are easy and which are harder to implement. Finally, you'll port your TimeBomb application from the toy Micro-C-AO framework to the professional QP/C framework, where hierarchical state machines are fully supported.

大家好，欢迎来到现代嵌入式系统编程课程。我叫 Miro Samek，在状态机系列的第六节课中，我想带你初步了解现代的层次状态机（Hierarchical State Machine, HSM）。今天你将学习什么是层次状态机，它和传统的有限状态机有什么区别。你还会了解如何用 C 语言实现状态层次，看看哪些部分容易、哪些部分比较棘手。最后，你将把 TimeBomb 应用从实验性的 Micro-C-AO 框架迁移到专业的 QP/C 框架——后者对层次状态机提供了完整支持。

---

As usual, let's start with copying the previous lesson-39 directory and renaming it to lesson-40. Get inside the new lesson-40 directory and double-clink on the project "lesson" to open it in the uVision IDE.

照例，先把上一课的 lesson-39 目录复制一份，重命名为 lesson-40。进入新的 lesson-40 目录，双击项目文件"lesson"在 uVision IDE 中打开。

---

To remind you quickly what happened so far, in the previous lesson you've learned the "optimal" state machine implementation, which you evolved from an idealized "domain-specific language" for state machines. That's why the implementation was very readable with a clear, one-to-one correspondence between the state machine elements in the diagram and the corresponding code. The implementation had also small memory footprint and was reasonably efficient in the CPU use.

快速回顾一下之前的进展：上一课你学习了"最优"状态机实现方式，它是从理想化的状态机领域专用语言逐步演化而来的。正因如此，这种实现的代码可读性非常高，状态机图中的每个元素和对应代码之间有清晰的一一对应关系。同时它的内存占用很小，CPU 使用效率也不错。

---

But, the optimal implementation has one more huge advantage, and that is, that it is very easy to extend it to support the modern version of state machines, which will be the subject of this lesson.

而且，这种最优实现还有一个巨大的优势——它非常容易扩展以支持现代版本的状态机，而这正是本课的主题。

---

But, I'm getting ahead of myself, because you first need to see the biggest problem with the traditional state machines.

不过我有点超前了，因为你首先需要了解传统状态机最大的问题所在。

---

To illustrate what I mean, suppose that you need to extend your TimeBomb application to allow the user to defuse the bomb. Specifically, the second button on your TivaC LaunchPad board should now defuse the bomb and should turn the Blue-LED on to show that the bomb is defused. The most important aspect is that the defusing should work at any stage, including when the bomb already started to time out.

为了说明我的意思，假设你需要扩展 TimeBomb 应用，让用户能够拆除炸弹。具体来说，TivaC LaunchPad 开发板上的第二个按键应该能拆除炸弹，并点亮蓝色 LED 表示炸弹已被拆除。最关键的一点是，拆除操作必须在任何阶段都有效，包括炸弹已经开始倒计时之后。

---

In the state diagram, this means that you now need an additional state: "defused" with an entry action that turns the Blue-LED on.

在状态图中，这意味着你需要新增一个状态："defused"（已拆除），带有一个点亮蓝色 LED 的进入动作（entry action）。

---

And then you need transitions triggered by the BUTTON2_PRESSED event that lead to this new state. The ability to ALWAYS defuse the bomb means that the BUTTON2_PRESSED transition has to be repeated in ALL existing states, because otherwise the bomb would NOT defuse reliably.

然后你需要由 BUTTON2_PRESSED 事件触发的转换，指向这个新状态。"随时都能拆除炸弹"这一需求意味着 BUTTON2_PRESSED 转换必须在所有已有状态中重复出现，否则炸弹就无法可靠地被拆除。

---

Now in your code, to replicate these changes from the diagram, you need to add the new "defused" state.

现在回到代码，要把状态图中的改动落实下来，你需要添加新的"defused"状态。

---

In the code, you typically work by copying, pasting, and modifying the existing elements to reuse the established coding patterns, rather than writing them from scratch.

在实际编码中，你通常会复制、粘贴、修改已有代码来复用成熟的编码模式，而不是从零开始写。

---

So for example, you can copy the "boom" state-handler function and modify it for the "defused" state.

比如，你可以复制"boom"状态处理函数，然后修改为"defused"状态。

---

Similarly, you can copy the BUTTON_PRESSED transition and modify it for BUTTON2_PRESSED.

类似地，你可以复制 BUTTON_PRESSED 转换，修改为 BUTTON2_PRESSED。

---

Then, to replicate the transition, you copy it and paste in all the states.

然后，为了在所有状态中都加上这个转换，你把它复制粘贴过去。

---

At this point, the TimeBomb state machine itself is done, but you still need to add the new BUTTON2_PRESSED and RELEASED event signals.

至此，TimeBomb 状态机本身完成了，但你还需要添加新的 BUTTON2_PRESSED 和 RELEASED 事件信号。

---

And you need to modify the Board Support Package to configure the GPIO for the SW2 button as input.

还需要修改板级支持包（Board Support Package, BSP），把 SW2 按键的 GPIO 配置为输入。

---

A tricky aspect here is that SW2 is multiplexed with the NMI line on the TivaC MCU, so before you can use it as an input, you need to unlock the access to this pin.

这里有个坑：SW2 在 TivaC MCU 上跟 NMI（不可屏蔽中断）引脚是复用的，所以把它用作输入之前，需要先解锁这个引脚的访问权限。

---

Only now you can configure the SW2 pin as input, just like SW1.

解锁之后才能把 SW2 引脚配置为输入，和 SW1 一样。

---

Once the pin is correctly configured, you need to generate and post the BUTTON2_PRESSED events to the TimeBomb active object, which you copy and modify from the SW1 button.

引脚正确配置好之后，你需要生成 BUTTON2_PRESSED 事件并发送给 TimeBomb 主动对象（Active Object），这部分代码同样可以从 SW1 按键的处理复制过来修改。

---

Here, you take advantage of the switch debouncing algorithm, which was discussed in lesson-37, and which allows you to debounce up to 32 signals simultaneously.

这里用到了第 37 课讨论过的按键消抖（debouncing）算法，它可以同时对最多 32 个信号进行消抖处理。

---

Before you build the code, though, please make sure that the compiler optimization is NOT set to -OZ image size. For some reason, which looks really like a compiler error, the code will not work when the -OZ optimization is selected.

不过在编译之前，请确保编译器优化选项没有设置为 -OZ image size。出于某种看起来很像编译器 bug 的原因，选中 -OZ 优化时代码会无法正常工作。

---

The last step is of course to check how it works...

最后一步当然是验证运行效果。

---

Let's open the debugger and run the code free.

打开调试器，让代码自由运行。

---

When you press the SW2 button, the Blue-LED lights up, which means that you are in the "defused" state.

按下 SW2 按键，蓝色 LED 亮起，说明进入了"defused"状态。

---

Alright. Second test: Reset the board and run the code free. Now, press SW1 button. The TimeBomb starts to blink red. But when you press the SW2 button, again the Blue-LED lights up and the bomb stops timing out.

好，第二个测试：复位开发板，自由运行。按下 SW1 按键，TimeBomb 开始闪烁红灯。但按下 SW2 按键后，蓝色 LED 亮起，炸弹停止倒计时。

---

So, all is fine and the new defusing feature seems to be working fine.

一切正常，新的拆除功能看起来工作得很好。

---

But, suppose that you want to debug the new BUTTON2_PRESSED transition. The problem is that you now have four of those, so where do you put your breakpoint? Even if you have enough breakpoints, you run the risk of missing some of the transitions. For instance, suppose that you missed one right here.

但假设你想调试新的 BUTTON2_PRESSED 转换。问题是你现在有四个这样的转换，断点该设在哪里？即使你有足够的断点，也有可能漏掉其中某些转换。比如，假设你漏掉了这里的这一个。

---

When you run the previous test again, you typically hit one of your breakpoints.

当你再次运行之前的测试时，通常会命中某个断点。

---

But, sometimes you take the transition without hitting a breakpoint, so your debugging is unreliable.

但有时候转换在没命中断点的情况下就发生了，所以你的调试是不可靠的。

---

Another facet of the same problem is with maintaining such code. For instance, if you need to modify in some way the repeated transitions, you need to do this identically in all instances. It's just too easy to miss some of the instances, or make slightly different changes in some places, and thus introduce inconsistencies.

同一个问题的另一个方面是代码维护。比如，如果你需要修改这些重复的转换，就必须在所有实例中做完全一致的修改。漏掉某些实例实在太容易了，或者在某个地方做了稍有差异的修改，从而引入不一致性。

---

Well, all these problems are well known, because all of them stem from violating one of the most important principles of software development: the DRY principle, which stands for Don't Repeat Yourself.

这些问题其实都是众所周知的，因为它们都源于违反了软件开发中最重要的原则之一：DRY 原则——不要重复自己（Don't Repeat Yourself）。

---

Please note that the repetition in the code is ultimately the problem of the original state machine design, of which the code is merely a faithful reflection.

请注意，代码中的重复归根到底是原始状态机设计的问题，代码只是忠实地反映了设计。

---

As it turns out, this problem with repetitions in traditional state machines is fundamental and is known as the "state-transition explosion". What that means is that complexity of the state machine solution to a given problem tends to grow disproportionately faster than the complexity of the problem.

事实上，传统状态机中的这种重复问题是一个根本性问题，被称为状态转换爆炸（state-transition explosion）。意思是说，对于给定的问题，状态机方案的复杂度往往比问题本身的复杂度增长得快得多。

---

For example, an additional state and an additional transition in the TimeBomb state diagram would be an increase of complexity that is proportional to the increased complexity of the problem. But the 4 repeated transitions add the extra complexity.

举个例子，在 TimeBomb 状态图中增加一个状态和一条转换，复杂度的增加和问题复杂度的增加是成比例的。但那 4 条重复的转换带来了额外的复杂度。

---

Of course, as the problem grows more complex, the repetitions pile up even faster and "explode", making the traditional state machines unworkable for bigger problems. This is probably one of the main obstacle to a widespread adoption of state machines in embedded software.

当然，随着问题变得越来越复杂，重复会积累得更快并"爆炸"，使得传统状态机在面对更大规模的问题时变得不可用。这很可能是状态机在嵌入式软件中未能被广泛采用的主要原因之一。

---

Fortunately, a very elegant solution to this problem has been known since the late 1980's, when David Harel invented advanced state machines that he called "statecharts". The main innovation of "statecharts" is the introduction of hierarchically nested states and therefore "statecharts" are also called "hierarchical state machines".

幸运的是，早在 20 世纪 80 年代末，David Harel 就发明了一种优雅的解决方案。他发明了一种高级状态机，称为状态图（statecharts）。状态图的核心创新是引入了层次嵌套的状态，因此也被称为层次状态机（hierarchical state machines）。

---

So, first let me show you how hierarchical state nesting looks and then I'll explain how it works and how it helps to eliminate the troublesome repetitions.

首先让我展示层次状态嵌套是什么样的，然后解释它的工作原理以及它如何帮我们消除那些令人头疼的重复。

---

So, the extension of the state machine formalism is to allow states to contain other states. Specifically, in your TimeBomb state machine, you can surround the four of the original states with another state, which you can call "armed".

状态机形式体系的扩展就是允许状态包含其他状态。具体来说，在你的 TimeBomb 状态机中，可以用另一个状态包围原来的四个状态，这个外层状态叫"armed"（已武装）。

---

This introduces a state hierarchy, in which state "armed" is at a higher-level and therefore is called the superstate. The internal states are then at a lower-level and are called substates.

这样就引入了状态层次：状态"armed"处于更高层级，因此被称为超状态（superstate）。内部的状态处于较低层级，被称为子状态（substate）。

---

The meaning of the state hierarchy is that the behavior of the superstate applies to all its substates.

状态层次的含义是：超状态的行为适用于它所有的子状态。

---

With this in mind, you can now move the BUTTON2_PRESSED transition up one level to the "armed" superstate, so that it applies to all four substates of "armed".

理解了这一点，你现在就可以把 BUTTON2_PRESSED 转换往上移一层，放到"armed"超状态中，这样它就适用于"armed"的所有四个子状态了。

---

The semantics associated with state nesting now means that, while the state machine is in the substate "wait4button" and the BUTTON2_PRESSED event occurs, the event is NOT ignored, as it would be the case in the traditional, non-hierarchical state machine. Instead, the event is propagated to the higher-level state "armed", where it triggers the transition to "defused".

状态嵌套的语义意味着，当状态机处于子状态"wait4button"时发生了 BUTTON2_PRESSED 事件，这个事件不会被忽略——在传统的非层次状态机中它会被忽略。相反，事件会被传播（propagate）到更高层的状态"armed"，在那里触发到"defused"的转换。

---

On the other hand, if a substate already handles a given event, it will NOT be propagated to the superstate. This is how substates can override the behavior from the superstates.

另一方面，如果子状态已经处理了某个事件，该事件就不会被传播到超状态。这就是子状态如何覆盖（override）超状态行为的方式。

---

However, in case of your TimeBomb, the transition in the "armed" superstate is exactly what you want, so you can delete the repeated transitions in all substates and rely on the common transition already defined in the superstate "armed".

不过在你的 TimeBomb 中，"armed"超状态中的转换正是你需要的，所以你可以删掉所有子状态中重复的转换，直接依赖超状态"armed"中已定义的公共转换。

---

The end result is that you could replace the 4 repeated transitions with just one, so this is how state hierarchy allows you to get rid of the repetitions and instead capture the common behavior in the higher-level states.

最终结果是你用一条转换替代了 4 条重复的转换。这就是状态层次如何帮你消除重复、把公共行为提取到高层状态中的方式。

---

But at this point, I hope that you might remember already seeing something like that in this video course. Well, actually, similar combination of abstraction and hierarchy came up already a few times before.

说到这里，你可能记得在本课程中已经见过类似的东西了。实际上，类似的抽象与层次的组合之前已经出现过好几次。

---

The more recent one was in Lesson-33 about event-driven programming on Windows with the original Win32 API.

最近一次是在第 33 课，讲的是使用 Win32 API 进行 Windows 事件驱动编程。

---

In that lesson, you've seen how all Windows events are first passed to the Window-Procedure (Win-Proc), but the events not handled explicitly there are not discarded, but rather passed on to the Windows System, where they are handled according to the "characteristic look and feel" of the Windows GUI. This mechanism is known under the names: "Ultimate Hook" or "Programming by Difference".

在那节课中，你看到所有 Windows 事件首先传递给窗口过程（Window Procedure, WndProc），但在那里没有被显式处理的事件并不会被丢弃，而是传递给 Windows 系统，由系统按照 Windows GUI 的"典型外观和行为"来处理。这个机制叫做终极钩子（Ultimate Hook）或按差异编程（Programming by Difference）。

---

Another occasion when you've applied "Programming by Difference" was in lesson 30 about "inheritance". You learned there that "inheritance" is a mechanism of capturing commonalities in a higher level superclass in order to reuse them in the lower-level subclasses.

另一次应用"按差异编程"是在第 30 课讲继承（inheritance）的时候。你学到了继承是一种在高层超类（superclass）中捕获共性、在低层子类（subclass）中复用它们的机制。

---

So, you can also think of hierarchical state nesting as a form of inheritance called "behavioral inheritance" in which substates inherit the behavior from their superstates. In fact, an alternative view of the TimeBomb statechart could be explicitly hierarchical, as shown on the left as the traditional inheritance tree, or in the nested form on the right, as in the QM model explorer view.

所以，你也可以把层次状态嵌套看作一种继承形式——叫做行为继承（behavioral inheritance），子状态从超状态继承行为。事实上，TimeBomb 状态图可以用显式的层次结构来表示，左边是传统的继承树形式，右边是 QM 模型浏览器中的嵌套形式。

---

By the way, in a tree view like that, it's often convenient to think of the whole state machine as nested inside a single "top" state, which typically is not shown in the diagram, but turns out to be a useful concept for implementing hierarchical state machines.

顺便说一句，在这样的树形视图中，通常很方便把整个状态机看作嵌套在一个单独的"top"状态内部。这个状态通常不会在图中画出来，但在实现层次状态机时它是一个很有用的概念。

---

Speaking of which, how would you code your updated TimeBomb hierarchical state machine?

说到这里，更新后的 TimeBomb 层次状态机代码该怎么写呢？

---

Well, again, let's first look at your existing code as a specification of a state machine, not just implementation.

再次强调，让我们先把你现有的代码看作状态机的规格说明，而不仅仅是实现。

---

With this perspective, the question becomes: how to unambiguously specify the hierarchical state nesting?

从这个角度看，问题就变成了：如何无歧义地指定层次状态的嵌套关系？

---

For this, you can take clues from other forms of inheritance, like the class inheritance, where all that needs to be done is for a subclass to specify the single superclass that it inherits.

为此，你可以从其他形式的继承中找线索，比如类继承，子类只需要指定它继承的超类就行了。

---

So similarly, all a substate-handler needs to do is to specify its superstate.

类似地，子状态处理函数只需要指定它的超状态。

---

Now, the obvious most appropriate place to specify the superstate is the default case, because at this point the event is not being handled, so instead of being ignored, it should be passed on to the superstate.

显然，指定超状态最合适的地方就是 default 分支，因为此时事件没有被处理，与其忽略它，不如把它传给超状态。

---

Alright, so you can introduce a macro SUPER(), similar to the macro TRAN(), with a parameter being the superstate-handler, like TimeBomb_armed in this case.

好，你可以引入一个 SUPER() 宏，和已有的 TRAN() 宏类似，参数是超状态处理函数，在这个例子中就是 TimeBomb_armed。

---

Now, so you can copy this macro into all substates of "armed".

然后你可以把这个宏复制到"armed"的所有子状态中。

---

But the state "defused" is not a substate of "armed". In that case, you can still use the SUPER() macro, but the superstate is the implicit "top" state, encoded as Hsm_top.

但"defused"状态不是"armed"的子状态。这种情况你仍然可以使用 SUPER() 宏，只是超状态是隐式的"top"状态，编码为 Hsm_top。

---

Now, you need to add the TimeBomb_armed state-handler, which is similar to TimeBomb_defused in that it nests only inside Hsm_top.

接下来需要添加 TimeBomb_armed 状态处理函数，它和 TimeBomb_defused 类似，也是直接嵌套在 Hsm_top 内部。

---

In that "armed" state, you copy the BUTTON2_PRESSED transition from any of the substates.

在"armed"状态中，你从任意一个子状态复制 BUTTON2_PRESSED 转换过来。

---

You add the prototype of the new "armed" state-handler.

添加新的"armed"状态处理函数的声明。

---

And you can also delete all the repeated transitions from the substates of "armed".

然后就可以删掉"armed"所有子状态中重复的转换了。

---

So, this is actually all that needs to be done to convert your traditional finite state machine into a hierarchical state machine. This is what I meant by saying that the "optimal" state machine implementation is easily extensible.

这就是把传统有限状态机转换成层次状态机需要做的全部工作。这就是我之前说"最优"状态机实现很容易扩展的意思。

---

But you still need to add the SUPER() macro and the Hsm_top state-handler to the event-processor, which is now part of your Micro-C-AO framework.

但你还需要把 SUPER() 宏和 Hsm_top 状态处理函数添加到事件处理器（event processor）中——事件处理器现在是 Micro-C-AO 框架的一部分。

---

Let's start with renaming the class FSM, which stands for Finite State Machine to HSM, which stands for Hierarchical State Machine.

先从重命名 FSM 类开始。FSM 代表有限状态机（Finite State Machine），改名为 HSM，代表层次状态机（Hierarchical State Machine）。

---

Now, let's add the macro SUPER() based on the existing macro TRAN().

接下来，基于已有的 TRAN() 宏来添加 SUPER() 宏。

---

Here, you should be careful not to clobber the state variable, because unlike during a transition, when you specify the superstate, you actually don't change the current state.

这里要小心，不要覆盖状态变量，因为和转换不同，指定超状态时你实际上并不改变当前状态。

---

Instead, let's set an additional attribute temp in the Hsm class, and add it as the temporary storage specifically for the superstate.

解决办法是在 Hsm 类中添加一个额外的属性 temp，专门用来临时存放超状态。

---

Also, you now need to return a different SUPER_STATUS, which you need to add to the State enumeration.

另外，现在需要返回一个不同的 SUPER_STATUS，你要把它加到状态枚举中。

---

Finally, you need to add the prototype of the Hsm_top state-handler.

最后，添加 Hsm_top 状态处理函数的声明。

---

In the implementation of the event processor inside the Micro-C-AO-dot-C file, you again replace Fsm with Hsm.

在 Micro-C-AO.c 文件中事件处理器的实现部分，同样把 Fsm 替换为 Hsm。

---

Next, you add the Hsm_top state-handler, which ignores all events, so it always returns the IGNORED_STATUS.

然后添加 Hsm_top 状态处理函数，它忽略所有事件，所以总是返回 IGNORED_STATUS。

---

And finally, you need to augment the Hsm_dispatch() operation to implement the state hierarchy.

最后，你需要增强 Hsm_dispatch() 操作来实现状态层次。

---

Here, you add a check whether the current state-handler returns the SUPER_STATUS and if so, that means that the same event must be tried in the superstate, which is now provided in the temp attribute.

这里添加一个检查：当前状态处理函数是否返回了 SUPER_STATUS，如果是，就意味着同一个事件需要在超状态中尝试处理，超状态信息现在存放在 temp 属性中。

---

Actually, because the state nesting is not limited to one level only, this should be a while-loop that continues as long as the state-handlers return the SUPER_STATUS.

实际上，因为状态嵌套不限于一层，这里应该是一个 while 循环，只要状态处理函数返回 SUPER_STATUS 就继续循环。

---

When the loop then terminates, it's because a transition is taken, or because you reached the top state, which returns IGNORED_STATUS.

循环终止有两种情况：要么是发生了转换，要么是到达了返回 IGNORED_STATUS 的 top 状态。

---

Either way, in case it was a transition, you exit the previous state and enter the new state, as before.

无论哪种情况，如果是发生了转换，就和之前一样退出前一个状态、进入新状态。

---

This is a gross simplification, because with hierarchical states, you need to correctly exit all the nested source states and you also need to correctly enter all the nested target states, but let's keep this for now and see how this works.

这是一个很大的简化。对于层次状态，你需要正确退出所有嵌套的源状态，也需要正确进入所有嵌套的目标状态。不过先这样处理，看看效果如何。

---

The code builds correctly, so let's load it to your TivaC LaunchPad board and perform some basic tests.

代码编译通过了，把它下载到 TivaC LaunchPad 开发板上做一些基本测试。

---

First test: reset: Green-LED, SW2 button → Blue-LED, meaning "defused" state. This means that the inherited BUTTON2_PRESSED transition was taken.

第一个测试：复位后绿灯亮，按 SW2 → 蓝灯亮，说明进入了"defused"状态。这意味着继承的 BUTTON2_PRESSED 转换被执行了。

---

Second test: reset: Green-LED, SW1 button → blinking Red-LED, SW2 button → Blue-LED, meaning "defused" state. This means that the inherited BUTTON2_PRESSED transition was taken again.

第二个测试：复位后绿灯亮，按 SW1 → 红灯闪烁，按 SW2 → 蓝灯亮，说明进入了"defused"状态。继承的 BUTTON2_PRESSED 转换再次被成功执行。

---

Third test: reset: Green-LED, SW1-button → blinking Red-LED, White-light: we're in "boom". SW2 button → no visible change.

第三个测试：复位后绿灯亮，按 SW1 → 红灯闪烁，白灯亮——我们进入了"boom"状态。按 SW2 → 没有可见变化。

---

This looks like a flaw in the state machine design, because the LEDs aren't turned off on the way out of the "boom" state, so turning the Blue-LED on in the "defused" state makes no noticeable difference.

这看起来像是状态机设计的一个缺陷，因为退出"boom"状态时 LED 没有被关掉，所以在"defused"状态中打开蓝色 LED 看不出明显变化。

---

Alright, so let's correct this problem first in the state machine, and then in the code.

好，让我们先在状态机中修正这个问题，然后再改代码。

---

Here, possibly the best fix would be to add an exit action to "boom", which would exactly undo the entry actions. So, if the entry action turns all LEDs ON, the exit action should turn all LEDs OFF.

最好的修复方式可能是给"boom"添加一个退出动作（exit action），精确地撤销进入动作的操作。也就是说，如果进入动作打开了所有 LED，退出动作就应该关闭所有 LED。

---

But for the sake of today's subject, let's move this exit action to the higher-level of the "armed" superstate.

但为了配合今天的主题，让我们把这个退出动作移到更高层的"armed"超状态中。

---

I will explain the exact semantics of entry and exit actions in hierarchical state machines in a future lesson, but they are intuitive, in that a transition out of a state, hierarchical or not, must cleanly exit the state.

我会在未来的课程中详细解释层次状态机中进入和退出动作的精确语义，但含义很直观：从状态转出时——不管是不是层次状态——都必须干净地退出。

---

But, there is more. For example, a superstate "armed" can have its own, nested initial transition to one of its substates, such as "wait4button".

但还不止这些。例如，超状态"armed"可以有自己的嵌套初始转换（initial transition），指向它的某个子状态，比如"wait4button"。

---

The meaning of such nested initial transition is that any direct transition to "armed", like for example BUTTON2_PRESSED from "defused", is required to also take the initial transition, so the end state will be "wait4button".

这种嵌套初始转换的含义是：任何直接到"armed"的转换——比如从"defused"通过 BUTTON2_PRESSED 触发的转换——都必须同时执行初始转换，所以最终状态会是"wait4button"。

---

Alright, so let's actually add all these new elements to your code.

好，现在把这些新元素都添加到代码中。

---

First, let's grab the entry action to "boom", copy it to "armed", change it to exit and reverse the actions.

首先，把"boom"的进入动作复制到"armed"中，改为退出动作，然后把操作反过来——进入时开的灯，退出时就关掉。

---

Now, the nested initial transition in "armed" is a new element. You can code it by the case with the special signal INIT_SIG followed by the TRAN() macro with the substate name as the target.

然后，"armed"中的嵌套初始转换是一个新元素。你可以用一个特殊信号 INIT_SIG 的 case 分支来编码，后面跟 TRAN() 宏，参数是目标子状态的名称。

---

Finally, the transition from "defused" to "armed" is also coded in the already established way.

最后，从"defused"到"armed"的转换也用已有的方式编码。

---

At this point, your application-level code for hierarchical state machine contains the most major elements and, as you can see, it is quite straightforward.

至此，你的层次状态机应用层代码包含了最主要的元素，如你所见，代码结构相当清晰。

---

The code even compiles, but it obviously won't work, because the nested exit and entry actions as well as nested initial transitions are not yet implemented in your Hsm_dispatch() operation.

代码甚至能编译通过，但显然无法正常工作，因为嵌套的退出和进入动作以及嵌套的初始转换还没有在 Hsm_dispatch() 操作中实现。

---

The bad news here is that, in the general case of multiple levels of state nesting, these elements are tricky and quite complex to implement.

坏消息是，在多层状态嵌套的通用情况下，这些元素的实现既棘手又复杂。

---

The good news is that all that complexity is confined to the Hsm_dispatch() and Hsm_init() operations inside the active-object framework, which means that the complexity can be completely hidden from your application-level, state-machine code.

好消息是，所有这些复杂性都局限于主动对象框架内部的 Hsm_dispatch() 和 Hsm_init() 操作中，这意味着复杂性对应用层的状态机代码是完全隐藏的。

---

But at this point you are really reaching the limits of your toy Micro-C-AO framework.

但此时你确实已经触及了实验性的 Micro-C-AO 框架的能力极限。

---

So instead of implementing the complete rich semantics of hierarchical state machines from scratch in Micro-C-AO, in the last segment of today's lesson I will show you how to move on to a professional-grade QP/C framework.

因此，与其在 Micro-C-AO 中从零开始实现层次状态机的完整丰富语义，不如在今天课程的最后一段，我带你迁移到专业级的 QP/C 框架。

---

QP/C provides not just full implementation of hierarchical state machines, but also much more complete implementation of active objects. The framework will also enable you to apply automatic code generation, which is very much a part of the modern embedded systems programming and which I'd like to show you in the next lesson.

QP/C 不仅提供了层次状态机的完整实现，还提供了更加完善的主动对象实现。这个框架还将使你能够使用自动代码生成——这是现代嵌入式系统编程的重要组成部分，我会在下一课中展示。

---

Actually, you've been already using various parts of QP/C over many lessons, including this one.

实际上，你在很多课中（包括本课）已经在使用 QP/C 的各个部分了。

---

You've also already gone through the porting exercise back in lesson-27 about the RTOS, where you replaced the toy MiROS RTOS that you've been building as a teaching aid until that point with the QXK kernel from QP/C.

你在第 27 课关于 RTOS 的内容中也做过类似的移植练习，把作为教学工具构建的实验性 MiROS RTOS 替换成了 QP/C 的 QXK 内核。

---

Interestingly, back then, the tricky parts turned out not to be the context-switch magic. You did the Context-switch in the first two lessons on RTOS. The tricky parts turned out to be the complex inter-thread communication mechanisms.

有趣的是，当时最棘手的部分并不是上下文切换的那些技巧——你在前两节 RTOS 课程中就已经搞定了上下文切换。真正棘手的是复杂的线程间通信机制。

---

The situation repeats here again with the modern hierarchical state machines, because the tricky parts turned out not to be the state-hierarchy. This was handled in a simple while-loop. The complexity lies in the proper handling of transition chains of exit actions from the current state configuration and entry actions into the target state configurations.

现在在层次状态机中，情况再次重演。棘手的部分不是状态层次——那用一个简单的 while 循环就解决了。复杂性在于正确处理从当前状态配置退出的退出动作链，以及进入目标状态配置的进入动作链。

---

The process of moving an application from one framework to another is a form of refactoring and is called porting an application. It is like replacing the foundation from under a house with minimal disturbance to the house itself.

把应用从一个框架迁移到另一个框架的过程是一种重构（refactoring），叫做应用移植（porting）。就像在不影响房屋本身的情况下更换地基一样。

---

To start the porting, let's create the groups QPC and QPC_port, similar to uCOS-II and uCOS-II_port.

开始移植之前，先创建 QPC 和 QPC_port 分组，和之前创建 uCOS-II 和 uCOS-II_port 分组类似。

---

Now you can delete the Micro-C-OS groups.

现在可以删掉 Micro-C-OS 分组了。

---

And also, to make sure that none of the Micro-C-OS stuff is being used, let's go to the current lesson 40 project on disk and delete the files app_cfg.h, os_cfg.h, uc_ao.c and uc_ao.h.

同时，为了确保不再使用任何 Micro-C-OS 的内容，到磁盘上的 lesson-40 项目目录中，删除 app_cfg.h、os_cfg.h、uc_ao.c 和 uc_ao.h 文件。

---

Also, you need to remove these files from your project.

同时也要从项目中移除这些文件的引用。

---

Next, you need to add the QPC source code to the QPC group.

接下来，把 QP/C 的源代码添加到 QPC 分组中。

---

If, by any reason you don't have QPC yet, please visit the companion web-page to this video course at state-machine.com/video-course and download QPC in a ZIP file.

如果由于某种原因你还没有 QP/C，请访问本视频课程的配套网页 state-machine.com/video-course，下载 QP/C 的 ZIP 压缩包。

---

Inside the QPC directory, go to src/qf sub-directory and select all the files. This is the code for state machines and active objects.

在 QP/C 目录下，进入 src/qf 子目录并选择所有文件。这些是状态机和主动对象的核心代码。

---

In addition to this, you will need to choose the real-time kernel for QP/C. For this lesson, choose the simplest, non-preemptive QV kernel in the QV sub-directory. I will explain the other real-time kernels available in QP/C in the future lessons.

除此之外，你还需要为 QP/C 选择一个实时内核。本课选择最简单的非抢占式（non-preemptive）QV 内核，位于 QV 子目录中。我会在未来的课程中介绍 QP/C 中可用的其他实时内核。

---

And finally, you will need the specific port of the QV kernel for your ARM Cortex-M processor and the ARMCLANG toolchain you are using. For this, you go up to the ports directory and down to arm-cm, and inside there to qv and armclang sub-directory for your specific compiler.

最后，你还需要 QV 内核针对 ARM Cortex-M 处理器和 ARMCLANG 工具链的特定移植版本。为此，先到 ports 目录，然后进入 arm-cm，再进入 qv 和 armclang 子目录。

---

The next step is to adapt the include paths for your compiler. You need to add here the qpc\include sub-directory, the qpc\src sub-directory and the specific qpc port with the QV kernel and ARMCLANG compiler.

下一步是调整编译器的头文件搜索路径。你需要添加 qpc\include 子目录、qpc\src 子目录，以及 QV 内核和 ARMCLANG 编译器的特定移植目录。

---

These changes should be now sufficient to compile the QP/C framework itself, as you can test with one of the QP/C source files.

这些修改应该足以编译 QP/C 框架本身了，你可以用某个 QP/C 源文件来验证。

---

Now you can move on to adapting your application, starting with the Board Support Package (BSP).

现在可以着手适配应用代码了，从板级支持包（BSP）开始。

---

Here, in the BSP-dot-H header file, you add the Q-prefix to the items that now come from the QP framework. The practice of starting all names with a common prefix is quite popular in designing reusable software, because it minimizes potential name conflicts and helps to recognize the framework API in the code.

在 BSP.h 头文件中，把来自 QP 框架的项前面加上 Q 前缀。在可复用软件设计中，给所有名称加上公共前缀是一种很常见的做法，因为这样可以尽量减少名称冲突，也有助于在代码中识别框架 API。

---

You can also remove the BSP_ASSERT macro, because the assertion mechanism is already provided in QP/C.

你可以删掉 BSP_ASSERT 宏，因为断言（assertion）机制已经在 QP/C 中提供了。

---

And you also add the constant BSP_TICKS_PER_SEC to replace similar constant from uC/OS-II.

同时添加 BSP_TICKS_PER_SEC 常量，替代 uC/OS-II 中的类似常量。

---

Now, inside the BSP-dot-C source file you perform similar changes.

接下来在 BSP.c 源文件中做类似的修改。

---

You replace the Micro-C-AO header file with QPC-dot-H.

把 Micro-C-AO 头文件替换为 QPC.h。

---

And instead of the Micro-C-OS-II time-tick hook you use directly the SysTick_Handler ISR.

不用 Micro-C-OS-II 的时间节拍钩子函数，改为直接使用 SysTick_Handler 中断服务程序（ISR）。

---

Here, you replace the time event processing with QF_TICK macro.

把时间事件处理替换为 QF_TICK 宏。

---

And you also replace Event with QEvt.

把 Event 替换为 QEvt。

---

and Active_post with QACTIVE_POST macro.

把 Active_post 替换为 QACTIVE_POST 宏。

---

You delete the other Micro-C-OS hooks.

删掉其他的 Micro-C-OS 钩子函数。

---

And you replace BSP_start with the QP/C callback QF_onStartup().

把 BSP_start 替换为 QP/C 的回调函数（callback）QF_onStartup()。

---

Just to remind you, callbacks are functions that you need to provide, but you don't call, because they are called by the framework. The naming convention for QP callbacks is that they all start with on..., like QV_onIdle, QF_onStartup, or QF_onCleanup.

提醒一下，回调函数是你需要提供但不需要自己调用的函数，因为它们由框架来调用。QP 回调函数的命名约定是都以 on... 开头，比如 QV_onIdle、QF_onStartup 或 QF_onCleanup。

---

At this point you can try to compile the updated BSP, and you fix the remaining issues, like the parameters for the QACTIVE_POST macro.

现在可以尝试编译更新后的 BSP，修复剩余的问题，比如 QACTIVE_POST 宏的参数。

---

OK, so with the BSP done, you move on to adapting the most interesting part, which is your TimeBomb state machine code in main-dot-c.

BSP 改完了，接下来处理最有趣的部分——main.c 中的 TimeBomb 状态机代码。

---

Here, you replace the header file to use QP/C and you provide the module name for the QP/C assertions.

把头文件替换为 QP/C 的头文件，并提供 QP/C 断言所需的模块名称。

---

But then, you need to make a bunch of global replacements to adjust the API to the QP/C framework.

然后需要做一系列全局替换，把 API 调整为 QP/C 框架的接口。

---

Specifically, you need to replace:

具体来说，需要替换以下内容：

---

Active with QActive

Active 替换为 QActive

---

TimeEvent with QTimeEvt

TimeEvent 替换为 QTimeEvt

---

State with QState

State 替换为 QState

---

Event with QEvt

Event 替换为 QEvt

---

TRAN with Q_TRAN

TRAN 替换为 Q_TRAN

---

EXIT signal with Q_EXIT_SIG

EXIT signal 替换为 Q_EXIT_SIG

---

ENTRY_SIG with Q_ENTRY_SIG

ENTRY_SIG 替换为 Q_ENTRY_SIG

---

INIT_SIG with Q_INIT_SIG

INIT_SIG 替换为 Q_INIT_SIG

---

SUPER with Q_SUPER

SUPER 替换为 Q_SUPER

---

HANDLED_STATUS with Q_HANDLED()

HANDLED_STATUS 替换为 Q_HANDLED()

---

Please note that these are all rather trivial name substitutions, which don't really change the structure of your state machine code.

请注意，这些都是相当简单的名称替换，并不会真正改变状态机代码的结构。

---

In other words, QP/C uses the exact same "optimal" state machine implementation you've learned in the last lesson and extended today for hierarchical state machines.

换句话说，QP/C 使用的正是你在上一课学到的、今天又扩展到层次状态机的那个"最优"状态机实现方式。

---

Now, there are still some adjustments for the QP API, but perhaps the most interesting change for the QV kernel is that you don't need the expensive per-thread stack.

还有一些 QP API 的调整，但 QV 内核最有趣的一个变化是：你不再需要每个线程独立的栈了，这节省了大量开销。

---

A few more changes, but finally the project builds cleanly, so the very last thing to do is to check how it works.

再做一些修改，项目终于可以干净地编译了。最后一件事情就是验证运行效果。

---

Reset: Green-LED, SW1-button: blinking Red-LED, SW2-button: blue-LED meaning "defused" state.

复位：绿灯亮，按 SW1：红灯闪烁，按 SW2：蓝灯亮，说明进入了"defused"状态。

---

But now, SW2-button again: combination of Blue and Green-LEDs, meaning back to the armed superstate and wait4button substate.

再按一次 SW2：蓝色和绿色 LED 同时亮，说明回到了 armed 超状态的 wait4button 子状态。

---

Now, SW1-button: solid Blue-LED and blinking Red-LED and finally White LED, meaning the "boom" state.

按 SW1：蓝色 LED 常亮、红色 LED 闪烁，最后白色 LED 亮起，说明进入了"boom"状态。

---

Of course, the Blue-LED should be turned off in the exit action from "defused", but I leave as an exercise for you. More importantly, however, all aspects of state hierarchy now work correctly.

当然，蓝色 LED 应该在"defused"的退出动作中关闭，但这留作练习给你。更重要的是，状态层次的所有方面现在都正确工作了。

---

This concludes this first glimpse of hierarchical state machines. I devoted a lot of time to the implementation, because I wanted to disprove the common misconception that hierarchical state machines are too hard to code manually. As you saw, given the right, "optimal" state machine implementation strategy the complications were quite manageable.

关于层次状态机的初步介绍就到这里。我在实现上花了很多时间，因为我想打破一个常见的误解——层次状态机太难了，不适合手动编码。如你所见，只要采用正确的"最优"状态机实现策略，复杂度是完全可控的。

---

But still, coding state machines is manual labor that can and should be automated. In the next lesson I will show you exactly this: automatic generation of state machine code. Stay tuned!

不过，编写状态机代码毕竟还是手工活，它可以而且应该被自动化。下一课我就给你展示：状态机代码的自动生成。敬请期待！

---

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads.

如果你喜欢这个频道，请给视频点赞并订阅以保持关注。你也可以访问 state-machine.com/video-course 获取课堂笔记和项目文件下载。

---

Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course". Thanks for watching!

最后，所有项目也可以在 GitHub 上 Quantum Leaps 的"modern embedded programming course"仓库中找到。感谢观看！

---

## 术语表

| 英文术语 | 中文翻译 | 说明 |
|---|---|---|
| Hierarchical State Machine (HSM) | 层次状态机 | 支持状态嵌套的状态机 |
| Finite State Machine (FSM) | 有限状态机 | 传统的不支持嵌套的状态机 |
| Statechart | 状态图 | David Harel 发明的高级状态机表示法 |
| Superstate | 超状态 | 层次状态中处于较高层级、包含子状态的状态 |
| Substate | 子状态 | 层次状态中嵌套在超状态内部的较低层级状态 |
| State hierarchy | 状态层次 | 状态之间的嵌套层级关系 |
| Behavioral inheritance | 行为继承 | 子状态从超状态继承行为的机制 |
| State-transition explosion | 状态转换爆炸 | 传统状态机中转换重复导致的复杂度急剧膨胀 |
| Event propagation | 事件传播 | 子状态未处理的事件向超状态传递的机制 |
| Override | 覆盖 | 子状态处理事件后阻止事件传播到超状态 |
| Programming by Difference | 按差异编程 | 只定义与通用行为不同的部分 |
| Ultimate Hook | 终极钩子 | Windows 中事件向上传播的处理模式 |
| Entry action | 进入动作 | 进入状态时自动执行的动作 |
| Exit action | 退出动作 | 退出状态时自动执行的动作 |
| Initial transition | 初始转换 | 进入复合状态时自动指向默认子状态的转换 |
| Active Object | 主动对象 | 封装了状态机和执行线程的并发模型 |
| Event processor | 事件处理器 | 负责分发和处理事件的核心组件 |
| Board Support Package (BSP) | 板级支持包 | 硬件相关的底层支持代码 |
| Callback | 回调函数 | 由框架调用、用户提供的函数 |
| Non-preemptive kernel | 非抢占式内核 | 不会打断正在运行任务的实时内核 |
| Context switch | 上下文切换 | RTOS 中任务切换时保存和恢复处理器状态 |
| Inter-thread communication | 线程间通信 | 不同线程之间交换数据的机制 |
| Debouncing | 消抖 | 消除机械开关抖动信号的算法 |
| DRY principle | DRY 原则（不要重复自己） | 避免代码重复的软件设计原则 |
| Refactoring | 重构 | 在不改变功能的前提下改善代码结构 |
| Porting | 移植 | 将应用从一个框架/平台迁移到另一个 |
| Assertion | 断言 | 用于运行时检查条件的调试机制 |
| ISR | 中断服务程序 | 中断发生时由硬件自动调用的处理函数 |
| Domain Specific Language (DSL) | 领域专用语言 | 针对特定问题领域设计的专用语言 |
| QP/C | QP/C 框架 | Quantum Leaps 提供的专业级事件驱动框架 |
| QV kernel | QV 内核 | QP/C 中最简单的非抢占式实时内核 |
