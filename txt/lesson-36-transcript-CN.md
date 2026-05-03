# 第36课：守卫条件 / Lesson 36: Guard Conditions

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this second lesson about state machines you'll learn about "guard conditions" as a mechanism of making your state machines more flexible. This concept will be needed in the upcoming lessons where I'll discuss the promised other variants of state machines.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。在状态机的第二节课里，我们将学习"守卫条件"（guard conditions）——它可以让你的状态机更加灵活。这个概念在后续课程中会用到，届时我会给大家介绍之前承诺过的其他状态机变体。

As usual, let's get started by copying the previous directory for lesson-35 to lesson-36. Get inside the new lesson-36 directory and double-click on the BlinkyButton-dot-QM model file to open it with the freeware QM modeling tool.

按照惯例，我们先把 lesson-35 的目录复制一份，改名为 lesson-36。进入新的 lesson-36 目录，双击 BlinkyButton.QM 模型文件，用免费的 QM 建模工具打开它。

If you don't have QM, you can download it from state-machine.com as part of the QP-bundle.

如果你还没有安装 QM，可以去 state-machine.com 下载，它包含在 QP 安装包里。

To remind you quickly what happened so far, in the last lesson you've learned the very basics of state machines. You also designed a simple state machine for your BlinkyButton application.

快速回顾一下：上一节课我们学习了状态机的基本概念，并且为 BlinkyButton 应用程序设计了一个简单的状态机。

In a nutshell, a state machine is the most optimal solution to the very common problem, where a system needs to react to events based not only on the event-type, but also depending on the history of past events.

简单来说，状态机是解决一类非常常见问题的最优方案——系统不仅要根据事件类型来做出反应，还要根据过去事件的历史来决定如何反应。

For example, in your BlinkyButton application the TIMEOUT event needs to trigger different reactions, depending on what happened to the green LED previously.

比如说，在 BlinkyButton 应用里，同样的 TIMEOUT 事件需要触发不同的反应，具体取决于绿色 LED 之前的状态。

This is very elegantly handled by the "off" and "on" states in your state machine.

状态机里的 "off" 和 "on" 两个状态非常优雅地解决了这个问题。

In the "off" state, the TIMEOUT event causes turning the LED *on* and a transition to the "on" state to remember the LED change.

在 "off" 状态下，TIMEOUT 事件会把 LED 点亮，然后转换到 "on" 状态，以此记住 LED 的变化。

In the "on" state, the **same** TIMEOUT event causes turning the LED *off* and a transition to the "off" state, to remember the LED change.

而在 "on" 状态下，**同一个** TIMEOUT 事件会把 LED 熄灭，然后转换回 "off" 状态，同样是为了记住 LED 的变化。

So, this is how the reaction to an event depends on both: the event-signal, TIMEOUT in this case, and on the current state of the state machine.

所以你看，对一个事件的反应取决于两个方面：事件信号（这里就是 TIMEOUT）和状态机当前所处的状态。

However, this is still not quite flexible enough for many real-life situations. The reason is that the whole structure of states and transitions in a state machine is fixed at design time.

不过，对于很多实际应用场景来说，这还不够灵活。原因在于，状态机中所有状态和转换的整体结构在设计阶段就已经固定下来了。

But what if the behavior,--that is, the reactions to future events--depends on the user input, which is obviously not known until runtime?

但如果行为——也就是对未来事件的反应——取决于用户输入呢？用户输入显然要到运行时才能知道。

This means that for certain transitions you cannot know at design time which state to transition to.

这意味着某些转换在设计阶段根本无法确定要转到哪个状态。

To address this need, the UML state machine notation includes the so called "choice pseudostates" and "guard conditions".

为了满足这种需求，UML 状态机表示法引入了所谓的"选择伪状态"（choice pseudostates）和"守卫条件"（guard conditions）。

The whole idea is actually very simple and is a way of combining a decision point from a flowchart with the transition notation. Specifically, a transition can go into a "choice pseudostate", depicted as a diamond.

这个想法其实非常简单，就是把流程图中的判断分支点和状态机的转换标记结合起来。具体来说，一条转换可以进入一个"选择伪状态"，用菱形符号表示。

Out of this diamond shape, you can have several outgoing transition segments, each labeled with a "guard condition" depicted in square brackets.

从这个菱形出发，可以引出多条转换分支，每条分支上都标注一个"守卫条件"，用方括号括起来。

Guard conditions are simply boolean expressions evaluated at runtime. If a guard condition evaluates to true, the corresponding transition is taken. Otherwise the transition is considered disabled, meaning that it is not taken.

守卫条件本质上就是布尔表达式，在运行时求值。如果某个守卫条件求值为真，对应的转换就会执行。否则该转换被视为禁用，也就是不会执行。

A special complementary guard depicted as "else" in square brackets evaluates to true only if all other guards from the same choice pseudostate evaluate to false.

还有一种特殊的互补守卫，用方括号中的 "else" 表示。只有当同一个选择伪状态上的所有其他守卫条件都为假时，它才为真。

Now, let me show you an application, where such choice pseudostates and guards would be very useful.

好，现在我给大家演示一个应用场景，在这个场景中，选择伪状态和守卫条件会非常有用。

So, suppose that you want to use your TivaC LaunchPad board as a controller for a time bomb, which should work as follows:

假设你想把 TivaC LaunchPad 开发板用作定时炸弹的控制器，它的工作方式如下：

After reset, the controller lights up the green-LED and waits for the user to press the button SW1.

复位之后，控制器点亮绿色 LED，然后等待用户按下 SW1 按钮。

When you press the button, the board turns the green-LED off and starts timing out. It blinks the red-LED on and off 3 times, after which the bomb explodes, which you emulate by turning all three LED colors on.

按下按钮后，开发板熄灭绿色 LED，开始倒计时。红色 LED 闪烁 3 次，然后炸弹"爆炸"——我们用同时点亮三种颜色的 LED 来模拟爆炸效果。

In other words, after the reset green light, and after the button press: blink-pause, blink-pause, blink-pause, boom!

换句话说，复位后绿灯亮起，按下按钮后：闪-停、闪-停、闪-停，轰！

OK, so now let's build a state machine for this behavior.

好，现在我们来为这个行为构建一个状态机。

Again, just as in the previous lesson-35, I will use the QM visual modeling tool with the previous BlinkyButton model as my starting point for the TimeBomb.

跟上一课一样，我还是用 QM 可视化建模工具，以之前的 BlinkyButton 模型作为起点来设计 TimeBomb。

I will save the model as TimeBomb-dot-QM and I will rename the active object to TimeBomb.

我把模型另存为 TimeBomb.QM，然后把主动对象（active object）重命名为 TimeBomb。

So now, as you remember, the initial transition should turn the green-LED on and transition to a state, where the time bomb waits for the user to press the button. Let's name this state "wait4button".

现在，按照之前学过的，初始转换应该点亮绿色 LED，然后转换到一个等待用户按下按钮的状态。我们把这个状态命名为 "wait4button"。

Inside the "wait4button" state, the only event of interest is BUTTON_PRESSED, so you can get rid of the other events.

在 "wait4button" 状态里，唯一需要关心的事件就是 BUTTON_PRESSED，所以其他事件都可以删掉。

The BUTTON_PRESSED event needs to perform the following actions:

BUTTON_PRESSED 事件需要执行以下动作：

1. turn the green-LED off,
2. turn the red-LED on,
3. arm the time event to expire in one-half second, and
4. transition to the "blink" state, because as you remember button-press should be followed by "blink".

1. 熄灭绿色 LED；
2. 点亮红色 LED；
3. 设置定时事件（time event）在半秒后触发；
4. 转换到 "blink" 状态，因为按下按钮后紧接着就是"闪烁"。

In the "blink" state, you can get rid of all events except TIMEOUT that you just armed on the transition to this state.

在 "blink" 状态中，除了刚设置的 TIMEOUT 事件外，其他事件都可以删掉。

The TIMEOUT event needs to turn the red-LED off, arm the time event for another one-half second, and transition to the "pause" state, because as you remember "blink" is followed by "pause".

TIMEOUT 事件需要熄灭红色 LED，重新设置定时事件为半秒后触发，然后转换到 "pause" 状态，因为"闪烁"之后是"停顿"。

In the "pause" state, you also need to handle the just armed TIMEOUT event, to get ready for another blink.

在 "pause" 状态中，你同样需要处理刚刚设置的 TIMEOUT 事件，为下一次闪烁做准备。

But wait a minute, where should you go with this transition?

等等，这条转换应该转到哪里呢？

I mean, you cannot naively go back to "blink", because that would create an endless loop of "blink" and "pause".

你不能简单地转回 "blink"，因为那样就会形成 "blink" 和 "pause" 的无限循环。

A brute-force solution would be to add three groups of blink and pause states, because at this point the time bomb is supposed to blink just three times.

一种暴力做法是添加三组 blink 和 pause 状态，因为此时定时炸弹只需要闪烁三次。

But this is obviously a rather brain-dead solution, not only because there are so many states that mindlessly repeat essentially the same behavior, but also because the number of blinks is likely to change.

但这显然不是一个聪明的方案。不仅因为大量状态在机械地重复本质上相同的行为，更因为闪烁次数很可能会发生变化。

Indeed, the next feature could very well be that the number of blinks before the time bomb goes off needs to be adjustable by the user. So, you simply cannot know this number at design time.

事实上，下一个功能需求很可能就是让用户能够自行设置炸弹爆炸前的闪烁次数。所以你根本不可能在设计阶段就知道这个数字。

So instead, a smarter design would be to add a "blink_counter" to the state machine that would simply count the number of blinks.

因此，更聪明的设计是给状态机加一个闪烁计数器（blink_counter），用来记录已经闪烁了多少次。

Specifically, each time through the pause state, the action on the TIMEOUT event would only decrement the counter.

具体来说，每次经过 pause 状态时，TIMEOUT 事件上的动作就是递减计数器。

Now, you need to apply the new concept for this lesson by adding a choice pseudostate, which you need to label with a guard condition.

接下来就要用到本课的新概念了——添加一个选择伪状态，并为它标注守卫条件。

The guard is simply a boolean expression: blink_counter greater than zero. This guard means that you still have some blinking to do,

守卫条件就是一个简单的布尔表达式：blink_counter 大于零。意思是还有闪烁没做完，

so you go to the blink state.

所以就转到 blink 状态。

But you should not forget to also perform actions to prepare for the blink state, such as turn the red-LED on and arm the time event for one-half second.

但别忘了还要执行准备进入 blink 状态的动作，比如点亮红色 LED、设置定时事件为半秒后触发。

You also need to add the complementary "else" guard, which will go to the new state "boom".

你还需要添加互补的 "else" 守卫，这条分支会转到新的 "boom" 状态。

On this transition segment, you also need to perform actions to prepare for that state, such as turning all LEDs on to emulate the explosion.

在这条转换分支上，同样需要执行准备动作，比如点亮所有 LED 来模拟爆炸效果。

Of course you still need to add the "boom" state and point the transition segment to it.

当然，你还需要添加 "boom" 状态，并把转换分支指向它。

Finally, you need to initialize the blink_counter variable to the total number of blinks you wish to have. You can put it in various transitions upstream from the "blink" state, for example "wait4button".

最后，你需要把 blink_counter 变量初始化为你想要的闪烁总次数。这个初始化可以放在 "blink" 状态之前的各种转换中，比如 "wait4button" 状态里的转换。

Alright, so now you just need to code the state machine. Again, like in the last lesson, you'll be doing this manually, even though the QM modeling tool could generate the code for you.

好，现在只需要把状态机写成代码了。跟上一课一样，这次我们还是手动编码，虽然 QM 建模工具可以自动生成代码。

But at this point, I haven't yet explained any other, more optimal state machine implementation strategies, so let's stick to the straightforward, nested-switch statement technique that you've learned in the last lesson-35.

不过到目前为止，我还没有讲解过其他更高效的状态机实现策略，所以我们继续用上一课学过的简单直接的嵌套 switch 语句方法。

So, first off, you need to rename BlinkyButton to TimeBomb in your whole project.

首先，你需要在整个项目中把 BlinkyButton 重命名为 TimeBomb。

After the global replacement, you need to make some manual corrections...

全局替换之后，还需要做一些手动修改……

And actually, since this is just a name change, the project should still build cleanly.

实际上，由于只是改了个名字，项目应该还能正常编译。

Now, inside your TimeBomb active object, you need to enumerate the states of your state machine. These states are: WAIT4BUTTON, BLINK, PAUSE, and BOOM.

接下来，在 TimeBomb 主动对象内部，你需要枚举状态机的各个状态。这些状态是：WAIT4BUTTON、BLINK、PAUSE 和 BOOM。

You also need to check the declarations of the internal private variables. You obviously need the time event, so you keep it.

你还需要检查内部私有变量的声明。定时事件肯定要保留。

But instead of the blink-time, you now need the blink_ctr data member.

但原来的 blink-time 现在要换成 blink_ctr 数据成员了。

At this point you can delete the no longer needed initial blink time constant.

这时候可以把不再需要的初始闪烁时间常量删掉。

But next, moving on to your state machine, you start with the initial transition.

接下来进入状态机部分，从初始转换开始。

As you remember from the last time, the whole state machine implementation goes into the dispatch function.

上节课讲过，整个状态机的实现都放在 dispatch 函数里。

So, here, for the initial transition, you tun the Green-LED on and transition to the WAIT4BUTTON state.

在初始转换中，点亮绿色 LED，然后转换到 WAIT4BUTTON 状态。

All states of your machine go into the switch statement, which discriminates based on the me-state variable.

状态机的所有状态都放在 switch 语句中，根据 me->state 变量来区分。

The first such state is wait4button.

第一个状态是 wait4button。

Here you handle just the BUTTON_PRESSED event, so you can delete all the others.

这里只处理 BUTTON_PRESSED 事件，其他都可以删掉。

The actions on BUTTON_PRESSED turn the Green-LED off, the Red-LED on, arm your time event for one-half second,

BUTTON_PRESSED 的动作是：熄灭绿色 LED、点亮红色 LED、设置定时事件为半秒后触发，

and initialize the blink-counter to 3. After this you transition to the blink state.

然后把闪烁计数器初始化为 3。之后转换到 blink 状态。

In the blink state you handle only the TIMEOUT event, so you can delete everything else.

在 blink 状态中只处理 TIMEOUT 事件，其他的都可以删掉。

The actions on TIMEOUT are: turn the Red-LED off, arm the Time Event for one half second, and transition to the pause state.

TIMEOUT 的动作是：熄灭红色 LED、设置定时事件为半秒后触发，然后转换到 pause 状态。

Now, the pause state is similar to blink, so I just copy and paste the blink code as my starting point for pause.

pause 状态跟 blink 类似，所以我直接复制 blink 的代码作为起点。

The first segment of the TIMEOUT transition only decrements the private me-blink-counter data member.

TIMEOUT 转换的第一部分只是递减私有成员 me->blink_counter。

But now comes the most interesting part of coding the choice point and the guard conditions.

接下来就是最有趣的部分了——编写选择点和守卫条件的代码。

I hope you can see the first branch corresponds to the IF-statement that simply checks the guard condition.

大家应该能看出来，第一个分支就是一个 if 语句，用来检查守卫条件。

If this guard evaluates to TRUE, you turn the Red-LED on, arm the time event for one-half second, and transition back to the blink state.

如果守卫条件为真，就点亮红色 LED、设置定时事件为半秒后触发，然后转回 blink 状态。

The complementary "else" guard corresponds then simply to the ELSE branch of the original iIF.

互补的 "else" 守卫就是原来 if 语句的 else 分支。

Here, you turn all the LEDs on, to emulate the bomb explosion and you transition to the boom state.

在这里，点亮所有 LED 来模拟炸弹爆炸，然后转换到 boom 状态。

Finally, the boom state handles no events, so it is an empty case statement.

最后，boom 状态不处理任何事件，所以是一个空的 case。

In summary, the choice pseudostate and guard conditions turn out to be simply IF-s and ELSEs in your C code.

总结一下，选择伪状态和守卫条件在 C 代码中其实就是 if 和 else。

Please note that these are exactly the same IFs and ELSEs that the state machine was designed to eliminate in the first place. Just recall the "spaghetti code" from the Visual Basic calculator example I showed you in the last lesson-35.

请注意，这些 if 和 else 正是状态机设计想要消除的东西。回想一下上一课我展示的 Visual Basic 计算器例子中的"面条式代码"（spaghetti code）。

So the moral here is that guard conditions should be used very judiciously. Too many of them, and you'll find yourself back in square one (spaghetti), where the guards effectively take over handling of all the relevant conditions in the system. On the other hand, guards are sometimes unavoidable, because they add the necessary flexibility to the state machines.

这里的教训是：守卫条件要谨慎使用。用得太多，你就会回到起点——守卫条件实质上接管了系统中所有条件的处理，代码又变成了面条式。但另一方面，守卫条件有时又是不可避免的，因为它们为状态机提供了必要的灵活性。

Therefore one of the main challenges in becoming an effective state machine designer is to develop a sense for which parts of the behavior should be captured in states and transitions at design time, and which parts require runtime flexibility of guard conditions. Generally, you should challenge yourself to use as few guard conditions as possible.

因此，成为一名优秀的状态机设计师的主要挑战之一，就是培养一种判断力：哪些行为应该在设计阶段用状态和转换来捕捉，哪些部分需要运行时的守卫条件来提供灵活性。总的来说，你应该尽量少用守卫条件。

Alright, so the last order of business for today is to check how your code works on the board.

好，今天的最后一项工作就是把代码烧录到开发板上看看效果。

For this, I'll simply upload the code to the board.

我直接把代码烧录到开发板上。

When I press the reset button, the green LED lights up, as expected.

按下复位按钮，绿色 LED 亮起，符合预期。

Now, when I press the SW1 button... three, two, one, boom!

现在按下 SW1 按钮……三、二、一，轰！

OK, so now let's change the blink counter to, say, count 10, and rebuild the code.

好，现在把闪烁计数器改成 10，重新编译。

Load the code to the board... and press reset: green light. Good.

烧录到开发板……按复位：绿灯亮起，很好。

Now: the button: ten, nine, eight, seven, six, five, four, three, two, one, boom!

现在按按钮：十、九、八、七、六、五、四、三、二、一，轰！

This concludes this lesson about guard conditions. Now, you are truly ready for the next lesson, where you'll learn about the other variants of so called input-driven or polled state machines and how they compare to the event-driven state machines that I've been discussing so far.

关于守卫条件的课程就到这里。现在你已经为下一课做好了准备——下一课我们将学习所谓的输入驱动型（input-driven）或轮询式状态机（polled state machines）的其他变体，并与目前讨论的事件驱动型状态机进行对比。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请给视频点赞并订阅。你也可以访问 state-machine.com/quickstart 下载课程笔记和项目文件。

---

## 术语表

| 英文术语 | 中文翻译 | 说明 |
|---|---|---|
| guard condition | 守卫条件 | 转换上的布尔表达式，在运行时求值决定转换是否执行 |
| choice pseudostate | 选择伪状态 | UML 中用菱形表示的判断分支点，根据守卫条件选择不同转换路径 |
| state machine | 状态机 | 根据当前状态和事件决定系统行为的计算模型 |
| active object | 主动对象 | 拥有自身执行线程和事件队列的对象 |
| time event | 定时事件 | 在指定时间后触发的事件 |
| transition | 转换 | 状态机中从一个状态到另一个状态的迁移 |
| event-driven | 事件驱动 | 由事件触发系统行为的编程范式 |
| input-driven / polled | 输入驱动 / 轮询式 | 通过主动轮询输入来驱动状态机的方式 |
| spaghetti code | 面条式代码 | 结构混乱、充斥嵌套条件判断、难以维护的代码 |
| boolean expression | 布尔表达式 | 求值为真或假的表达式 |
| nested-switch statement | 嵌套 switch 语句 | 状态机的一种简单实现方式，外层 switch 区分状态，内层 switch 区分事件 |
| blink counter | 闪烁计数器 | 记录剩余闪烁次数的变量 |
| dispatch function | dispatch 函数 | 负责事件分发的函数，状态机核心实现所在 |
| UML state machine notation | UML 状态机表示法 | 统一建模语言中定义的状态机图形表示规范 |
