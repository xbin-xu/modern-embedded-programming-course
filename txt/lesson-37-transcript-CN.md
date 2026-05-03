# 第37课：输入驱动型状态机 / Lesson 37: Input-Driven State Machines

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this third lesson on state machines you'll learn about the other types of state machines used in software design and how they compare to the event-driven state machines that you've learned so far.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这是状态机系列的第三节课，今天我们要学习软件设计中使用的其他类型的状态机，并且和前面学过的事件驱动型状态机做一个对比。

---

To understand state machines in this broader way, you need to go to the beginning, so let me pull up my usual historical timeline, where you can see the important developments that influenced our embedded programming discipline.

要想从更宏观的角度理解状态机，我们得回到起点。让我调出那张大家熟悉的历史时间线，上面标注了对嵌入式编程领域产生深远影响的那些重要里程碑。

---

As you can see, the interest in state machines started almost seventy years ago, when in the 1950's George Moore and Edward Mealy from Bell Telephone Company published their seminal papers on formal methods of synthesizing digital circuits. In those papers, they outlined the usefulness of state machines for designing such circuits.

大家可以看到，对状态机的研究差不多始于七十年前。上世纪五十年代，贝尔电话公司的 George Moore 和 Edward Mealy 发表了两篇开创性的论文，提出了用形式化方法来综合数字电路。正是在这些论文中，他们阐明了状态机在电路设计中的实用价值。

---

So, first off, perhaps the most important observation is that state machines originated in hardware design, as software was really in its infancy at the time. It turns out, this has deeply influenced state machines, so that even to this day state machines used in *software* carry a lot of the baggage from their hardware origins. I will provide some examples of this later in this lesson.

首先要指出的一点，也许也是最重要的一点：状态机诞生于硬件设计领域，毕竟那个年代软件才刚萌芽。这个出身深刻地影响了状态机的发展，以至于直到今天，用于*软件*中的状态机仍然带着许多硬件时代的烙印。稍后我会举一些具体的例子。

---

But going back to Mealy and Moore, they were concerned with digital circuits that had internal memory (or state) of some kind.

回到 Mealy 和 Moore，他们研究的是带有某种内部存储（或者说内部状态）的数字电路。

---

To appreciate the challenge, first let's consider digital circuits without internal state. Such circuits are called combinational, and examples include OR-gates, AND-gates, XOR-gates, inverters, and combinations of such elements.

要理解这个问题的难点，我们先来看看没有内部状态的数字电路。这类电路叫做组合逻辑电路（Combinational Circuit），常见的例子有或门、与门、异或门、反相器，以及由这些基本单元组合而成的各种电路。

---

For example, here you can see a combinational circuit that performs addition of two inputs A and B, and it produces two outputs: A + B and the Cary from the addition. Both the inputs and the outputs are digital signals that can be either high or low, representing logic 0 or 1.

举个例子，这里是一个组合逻辑电路，功能是把两个输入 A 和 B 相加，产生两个输出：A + B 的和以及进位（Carry）。输入和输出都是数字信号，非高即低，分别代表逻辑 0 或逻辑 1。

---

Because digital circuits work with logic values, they are often described by truth tables that you learned in math at school. For example, here is the truth table that fully describes the workings of the half adder circuit shown in the schematics. As you can see, the outputs depend only and entirely on the inputs and there is no need to remember any history of past inputs.

既然数字电路处理的是逻辑值，我们通常用真值表（Truth Table）来描述它们——这个大家在中学数学里就学过。比如，这张真值表完整地描述了原理图上那个半加器（Half Adder）的工作过程。可以看到，输出完全由当前的输入决定，不需要记住任何过去的输入历史。

---

However, consider for example a problem of detecting a rising edge of a digital input A, that is, we want the output Y to go high only when the input A changes from 0 to 1.

但是，考虑另一个问题：我们要检测数字输入 A 的上升沿，也就是说，只有当输入 A 从 0 变成 1 的那一瞬间，输出 Y 才变为高电平。

---

Such a problem cannot be solved with any purely combinational logic, because the circuit odiously needs to remember the previous state of the input A.

单靠纯粹的组合逻辑是解决不了这个问题的，因为电路显然需要记住输入 A 之前的状态。

---

Here is an example of a circuit that would do the job. The most important new component in this circuit is the memory element shown here as the D flip-flop, which remembers just one bit of information. This is the state of the circuit.

这里有一个能完成这项任务的电路。这个电路中最重要的新元件就是图中所示的 D 触发器（D Flip-Flop），它是一个存储元件，能记住一位信息。这一位就是电路的状态。

---

Also there is now a periodic clock signal connected to the flip-flop, which controls when the flip-flop stores new information. This clock provides a global "event" to the system and determines when the inputs and outputs are allowed to change.

此外，触发器还连接了一个周期性的时钟信号，它控制着触发器什么时候存储新信息。这个时钟为整个系统提供了一个全局"事件"，决定了输入和输出何时允许发生变化。

---

Circuits driven by a clock are called Synchronous and both Mealy and Moore focused predominantly on synchronous circuits. There are many reasons why to this day essentially only synchronous circuits are in use and I will mention some of them in a minute.

由时钟驱动的电路叫做同步电路（Synchronous Circuit）。Mealy 和 Moore 的研究重心主要就是同步电路。直到今天，实际使用的几乎全部是同步电路，原因有很多，我稍后会提到其中一些。

---

But going back to the edge-detection circuit, it also has two blocks of purely combinational logic, one for determining the output based both on the current input and the current state and another logic block to determine the next state.

回到边沿检测电路，它还有两个纯组合逻辑块：一个根据当前输入和当前状态来决定输出，另一个逻辑块用来决定下一个状态。

---

The workings of the circuit can be again described by the truth table, but this time the table needs to list also the previous and next state of the system. I'll leave it to you to pause the video and convince yourself that according to the truth table the output Y is 1 only when A was zero before and is 1 now.

这个电路的工作过程同样可以用真值表来描述，只不过这次真值表里还需要列出系统的前一状态和下一状态。我建议你暂停视频，对照真值表自己验证一下：只有当 A 之前为 0、现在为 1 的时候，输出 Y 才等于 1。

---

But the truth table is not the only useful representation.

当然，真值表并不是唯一有用的表示方法。

---

An important insight of the original articles by George Moore and Edward Mealy was to abstract the states of the system by naming them, and then by applying the automata theory to depict the truth table information as a state diagram.

George Moore 和 Edward Mealy 在他们的原始论文中提出了一个重要的洞见：给系统的状态取名字来进行抽象，然后利用自动机理论（Automata Theory），把真值表中的信息画成状态图（State Diagram）。

---

The association between the states names and the output values of the flip-flops is known as binary encoding, and here the encoding is particularly simple. State name S0 is assigned to the flip-flop value 0 and S1 to the value 1.

状态名称与触发器输出值之间的对应关系叫做二进制编码（Binary Encoding）。这里的编码特别简单：状态 S0 对应触发器值 0，状态 S1 对应触发器值 1。

---

With this encoding you can draw the following diagram, as proposed by Mealy:

有了这个编码，就可以按照 Mealy 的方式画出下面这个状态图：

---

States are represented as circles labeled with their names.

状态用圆圈表示，圆圈里标注状态的名称。

---

So for example, after reset the state of the flip-flop is zero, which is represented as a circle labeled S0.

比如，复位之后触发器的值为 0，用一个标有 S0 的圆圈来表示。

---

The arrows coming out of the states correspond to the lines in the truth table and in the Mealy representation they are labeled with the possible values of the inputs as well as the outputs produced in each case.

从状态出发的箭头对应真值表中的每一行。在 Mealy 表示法中，箭头上同时标注了可能的输入值以及每种情况下产生的输出值。

---

For example, the input 0 in S0 leads to S1 and produces the output 0;
Input 1 in S0 leads back to S0 and produces the output 0;
Input 0 in S1 leads back to S1 and produces the output 0;
and finally:
Input 1 in S1 leads to S0 and produces the output 1. This is when the circuit detects the rising edge of the input A and drives the output Y to high.

举例来说：
在 S0 状态下，输入为 0 则转移到 S1，输出为 0；
在 S0 状态下，输入为 1 则留在 S0，输出为 0；
在 S1 状态下，输入为 0 则留在 S1，输出为 0；
最后一种情况：
在 S1 状态下，输入为 1 则转移到 S0，输出为 1——这就是电路检测到输入 A 的上升沿、并将输出 Y 拉高的时刻。

---

This circuit is called the Mealy state machine, because there is a direct connection between the input and the combinational logic for the output.

这个电路被称为 Mealy 状态机（Mealy State Machine），因为输入和输出端的组合逻辑之间存在直接连接。

---

However, for reasons that I'll explain in a minute, it is often better to separate the inputs from the outputs and allow only the current state to determine the outputs.

不过，出于稍后会解释的原因，更好的做法通常是把输入和输出分离开来，只让当前状态来决定输出。

---

This leads to the more restricted circuit called the Moore state machine.

这就引出了结构更加受限的 Moore 状态机（Moore State Machine）。

---

So, here is an example of the circuit to perform the same function as the previous Mealy circuit, that is, to detect a rising edge of the input A.

这是一个实现相同功能——即检测输入 A 上升沿——的 Moore 电路。

---

Moore state machines typically require more states than Mealy state machines to perform equivalent function, which you can see here by the presence of two D flip-flops.

Moore 状态机完成相同功能通常需要更多的状态。从图中可以看到，这里用了两个 D 触发器。

---

On the other hand, there is no direct connection between the input A and the combinational logic for the output Y. Only the current state, that is, the outputs of the flip-flops influences the output Y.

另一方面，输入 A 和输出 Y 的组合逻辑之间没有直接连接。只有当前状态，也就是触发器的输出，才会影响输出 Y。

---

And here is the truth table for the Moore circuit. As you can see the state encoding now requires two bits, wheres the one-one bit combination is not used.

这是 Moore 电路的真值表。可以看到，状态编码现在需要两位，其中"11"这个组合没有被使用。

---

As before, the truth table can be translated into a state diagram, where again each line of the table corresponds to a transition.

和之前一样，真值表可以转换为状态图，表中的每一行对应一条状态转换。

---

But the Moore state diagram is slightly different in that transitions are labeled only with inputs. Outputs are placed inside the states, because outputs depend on the states only.

不过 Moore 状态图有一个细微的区别：转换箭头上只标注输入。输出被放在了状态圆圈里面，因为输出仅取决于状态。

---

So, let's quickly go over the truth table and see how it corresponds to the Moore state machine diagram:

我们快速过一遍真值表，看看它如何对应 Moore 状态图：

---

After reset, the flip-flops start in the 0,0 state, which is encoded as S0. This state produces output zero.

复位之后，触发器处于 0,0 状态，编码为 S0。该状态输出 0。

---

Input 0 in S0 leads to S1, and S1 produces output 0.
Input 1 in S0 leads back to S0, and S0 produces output 0.

在 S0 状态下，输入 0 转移到 S1，S1 输出 0。
在 S0 状态下，输入 1 留在 S0，S0 输出 0。

---

Input 0 in S1 leads back to S1, and S1 produces output 0.
Input 1 in S1 leads to S2, and S2 produces output 1. This is the detected rising edge.

在 S1 状态下，输入 0 留在 S1，S1 输出 0。
在 S1 状态下，输入 1 转移到 S2，S2 输出 1——这就是检测到的上升沿。

---

Input 0 in S2 leads back to S1, and S1 produces output 0.
And finally, input 1 in S2 leads all the way back to S0, and S0 produces output 0.

在 S2 状态下，输入 0 回到 S1，S1 输出 0。
最后，在 S2 状态下，输入 1 直接回到 S0，S0 输出 0。

---

OK, so I hope you now see how this works, and given the state encoding, you should be able to go back and forth between the state diagram and the corresponding truth table.

好了，希望现在你已经明白它是怎么工作的了。只要知道状态编码，你就应该能够在状态图和对应的真值表之间来回转换。

---

Of course, what you've seen so far was a very simple example with just one-bit input and one-bit output. But the approach can be generalized for multiple bits of input and multiple bits of output. In fact, this is exactly what Mealy and Moore papers were all about.

当然，到目前为止我们看的都是一个非常简单的例子——只有一位输入和一位输出。但这种方法完全可以推广到多位输入和多位输出。事实上，Mealy 和 Moore 的论文讨论的正是这种一般情况。

---

Here is a generic structure of such circuits with internal state.

这是一个带内部状态的电路的通用结构。

---

The central component of the circuit is the Current State register comprised of multiple D flip-flops, which are all driven by the common clock signal. Both the Current State bits and all the Input bits are fed to the combinational logic block, which decides about the Next State. The Next State is then fed back to the State register to become the Current State on the *next* clock cycle.

电路的核心元件是当前状态寄存器（Current State Register），由多个 D 触发器组成，它们共用同一个时钟信号。当前状态的各位和所有输入位一起送入一个组合逻辑块，由它决定下一状态。下一状态再反馈回状态寄存器，在*下一个*时钟周期变成新的当前状态。

---

The Current state is also fed to another combinational logic block to generate the Outputs. Additionaly, but only in the Mealy machine, the inputs are also fed to that logic block for outputs.

当前状态还会送入另一个组合逻辑块来产生输出。此外——但仅限于 Mealy 状态机——输入也会被送到这个输出逻辑块。

---

The synchronous nature of the circuit is reflected by the following timing diagram, which shows the operation of the edge-detection circuit discussed before.

电路的同步特性可以从下面的时序图看出来，展示的是前面讨论过的边沿检测电路的工作过程。

---

As you can see, synchronous means that all signals are allowed to change only when the clock is high and must remain stable when the clock is low. Of course, this ties everything to the clock and is quite restrictive.

可以看到，所谓同步，就是所有信号只允许在时钟为高电平时变化，在时钟为低电平时必须保持稳定。当然，这就把一切都和时钟绑定了，限制是比较大的。

---

Circuits without a clock are possible and are called *asynchronous* circuits. In fact, the original Mealy paper discusses such circuits as well. But it also mentioned the biggest problem of asynchronous circuits, which are *race conditions*--apparently well known already in the 1950s.

没有时钟的电路也是可以实现的，叫做异步电路（Asynchronous Circuit）。事实上，Mealy 的原始论文也讨论了异步电路。但论文同时也指出了异步电路最大的问题——竞态条件（Race Condition）。显然，这个问题在上世纪五十年代就已经广为人知了。

---

I've introduced *software* race conditions back in lesson-20, but race conditions can happen in hardware as well when the propagation delays through the electronic components can lead to different outputs depending on the relative timing.

我在第 20 课介绍过软件中的竞态条件。但在硬件中同样存在竞态条件——当信号通过电子元器件的传播延迟不同时，输出的结果可能因相对时序的差异而不同。

---

The problem of race conditions in hardware turns out to be so intractable, that to this day virtually all digital electronics, including all embedded CPUs, are synchronous.

硬件中的竞态条件问题极其棘手，以至于直到今天，几乎所有的数字电子器件——包括所有嵌入式 CPU——都是同步的。

---

But even synchronous circuits are not completely immune to race conditions. For example, as you can see, the Mealy machine's output rises a clock cycle sooner because it responds directly to the input rather than waiting for the state to change. But this faster reaction can occasionally lead to race conditions, because the state of the circuit might change in the same clock cycle as the inputs, so these two changes can race each other.

不过即便是同步电路也不能完全免疫竞态条件。比如可以看到，Mealy 状态机的输出会提前一个时钟周期变化，因为它直接响应输入，而不是等状态改变。但这种更快的反应偶尔也会引发竞态条件——因为电路状态的变化和输入的变化可能发生在同一个时钟周期内，两者互相竞争。

---

For these reasons, Moore state machines are often preferred, even though they are a bit slower and a bit more complex than Mealy machines.

正因为这些原因，Moore 状态机往往更受青睐，尽管它比 Mealy 状态机稍慢一些、也稍复杂一些。

---

Alright, so these the original hardware state machines. But now the question is how all this relates to the state machines used in *software*?

好了，以上这些就是最初的硬件状态机。那么问题来了：这些跟软件中使用的状态机有什么关系呢？

---

Well, if you search the web for "software state machine", chances are that you'll come up something like that:

or like that:

or like that:

如果你在网上搜索"software state machine"，很可能搜出来的结果是这样的：

或者是这样的：

又或者是这样的：

---

These are apparently state machines, but they are very different from the event-driven state machines that you've learned in this video course in lessons 35 and 36.

这些当然也是状态机，但和本课程第 35、36 课学过的事件驱动型状态机截然不同。

---

And I don't mean here the cosmetic change of state presentation as circles versus rounded-corner rectangles.

我指的不是状态表示形式上的表面差异——圆圈还是圆角矩形，这不重要。

---

No, I mean the real difference in what drives the state transitions, because these are apparently NOT events.

我说的是驱动状态转换的东西有本质区别——因为这些东西显然不是"事件"。

---

Instead, transitions are labeled with *inputs* as well as expressions built out of those inputs.

相反，转换箭头上标注的是输入以及由这些输入构成的表达式。

---

For example, you can see expressions containing logical: OR, AND, as well as comparisons like: equals, greater-than, or just TRUE or "always".

比如，你能看到包含逻辑或（OR）、逻辑与（AND）的表达式，以及等于、大于之类的比较运算，还有直接写 TRUE 或者"always"的情况。

---

So, what's going on here and what are those "inputs"?

那么，这到底是怎么回事？这些"输入"又是什么？

---

Well, it all goes back straight to hardware state machines, where inputs were simply bits or groups of bits. In software, groups of bits that can change are called variables.

说到底，这都要追溯到硬件状态机。在硬件中，输入就是一些位或者一组位。在软件中，可以变化的一组位就叫做变量（Variable）。

---

So for example, one bit of input could be represented as a Boolean variable "pilot's lever", which could take values UP or DOWN. Another input, such as "msCounts" could be a 16-bit variable that takes values 0 through 2 to 16th, etc.

举例来说，一位输入可以用一个布尔变量"pilot's lever"来表示，取值为 UP 或 DOWN。另一个输入比如"msCounts"可以是一个 16 位的变量，取值范围从 0 到 2 的 16 次方等等。

---

But at this point I hope you noticed something familiar.

说到这里，我希望你已经注意到了一些眼熟的东西。

---

Yes, these Boolean expressions of inputs are simply *guard conditions* that you've learned in the last lesson 36.

没错，这些基于输入的布尔表达式其实就是上一课学过的卫条件（Guard Condition）。

---

Indeed, in the more advanced tools, such as Stateflow by Mathworks (the same company that makes Matlab and Simulink), the transitions are labeled explicitly with guard conditions, because you can see the characteristic square brackets.

确实如此。在更高级的工具中，比如 Mathworks（也就是开发 Matlab 和 Simulink 的那家公司）的 Stateflow，转换箭头上明确标注的就是卫条件——你可以看到标志性的方括号。

---

So, the next even bigger question is: *When* do those state machine machines run and when do they wait?

那么接下来一个更大的问题是：这些状态机什么时候运行，什么时候等待？

---

I mean, with event-driven state machines this was very clear. An event driven state machine runs only when there is a new event to process.

对于事件驱动型状态机来说，这一点非常清楚——只有当有新事件需要处理时，状态机才会运行。

---

Also, when no events are available an event-driven state machine simply waits, meaning that it doesn't do anything.

同样，没有事件的时候，事件驱动型状态机就只是等待，也就是说什么都不做。

---

But the input-driven state machines are different. They run "always" or "periodically", whereas typically you wouldn't know from the diagram how frequently that is.

但输入驱动型状态机不一样。它们"一直在运行"或者"周期性运行"，而且仅从状态图上通常看不出运行频率是多少。

---

Sometimes, a state machine is shown in the context, like here in the Simulink model. From this wider context you can guess that the state machine must be driven by some "Clock", which means periodic execution.

有时候状态图会放在一个更大的上下文中展示，比如这里的 Simulink 模型。从更广的上下文中可以推测，这个状态机一定是由某个"时钟"驱动的，也就是说它是周期性执行的。

---

But other state machines of this type run "always". For example, state machines are frequently executed in the while(1) superloop directly from the main() function.

但也有些这类状态机是"一直在运行"的。比如，状态机经常直接放在 main() 函数的 while(1) 超级循环（Superloop）里执行。

---

You also encountered such a state machine in this video course, were in lesson 21 about foreground/background systems I showed the non-blocking, state machine version of the blinky implementation.

在本课程中你也遇到过这种状态机——第 21 课讲前台/后台系统（Foreground/Background System）时，我演示过非阻塞的、基于状态机的 blinky 实现。

---

State machines executed from the while(1) superloop take all the available CPU cycles, regardless if there are "events" for them or not.

在 while(1) 超级循环中执行的状态机会占满所有可用的 CPU 周期，不管有没有"事件"需要处理。

---

Regarding the terminology of calling this type of state machines, it does not seem to be firmly established. I already used the term "input-driven state machines".

关于这类状态机的叫法，目前似乎没有一个统一的术语。我前面已经用了"输入驱动型状态机"（Input-Driven State Machine）这个词。

---

But I've also seen other names, like:

"Controller state machine", because the state machines or this type are commonly used in process control, like the one shown in the Simulink model.

不过我也见过其他叫法，比如：

"控制器状态机"（Controller State Machine），因为这类状态机经常用在过程控制中，就像 Simulink 模型里展示的那样。

---

And I've also seen, "Periodic state machines", because they often execute periodically.

还见过叫"周期性状态机"（Periodic State Machine）的，因为它们通常是周期性执行的。

---

However, this name would suggest some well-defined periodicity of execution, whereas the simple state machines in the while(1) superloop might be executing in a very irregular fashion. For example, when all guard conditions in the current state evaluate to false, a state machine can finish in a matter of microseconds. But when some of the guards evaluate to TRUE, the execution can take many milliseconds. This means several orders of magnitude differences and it's hard to talk about any well-defined execution "period".

然而，这个名字暗示了执行周期是明确固定的，而实际上 while(1) 超级循环里的简单状态机执行节奏可能非常不规律。比如，当当前状态下所有卫条件都求值为 false 时，状态机可能几微秒就执行完了。但如果某些卫条件求值为 TRUE，执行可能需要好几毫秒。这意味着执行时间可能相差好几个数量级，很难说有什么明确的执行"周期"。

---

Which leads to yet another term used for describing this type of state machines, which is "polled state machines".

这就引出了描述这类状态机的另一个术语——"轮询式状态机"（Polled State Machine）。

---

This term captures the fact that such state machines constantly poll the "inputs" to discover the really interesting events that need to be handled. In other words, state machines of this type combine the event discovery by polling the inputs with the state machine logic.

这个名称抓住了这类状态机的本质特征：它们不断轮询"输入"，从中发现真正需要处理的感兴趣的事件。换句话说，这类状态机把通过轮询输入来发现事件的过程和状态机本身的逻辑结合在了一起。

---

In that sense you can view the inputs to the state machine as "proto-events", that is, inputs are variables that need to be polled and combined in guard expressions to distill the real interesting events.

从这个意义上说，你可以把状态机的输入看作"原始事件"（Proto-Event）——输入就是一些变量，需要通过轮询并在卫条件表达式中组合使用，才能提炼出真正有意义的事件。

---

But, speaking of the inputs, they are typically external to the state machine and originate either directly in the peripheral registers or in the interrupts.

说到输入，它们通常来自状态机外部，要么直接读取外设寄存器，要么来自中断。

---

For example, the "button" input in this state machine is read from a GPIO register in the Arudino function "digitalRead".

比如，这个状态机中的"button"输入就是通过 Arduino 的 digitalRead() 函数读取 GPIO 寄存器获得的。

---

Likewise, the variable "time" is read from the millisecond counter returned by the function millis(). The millisecond counter is updated in Arduino in the system clock tick interrupt.

同样，变量"time"来自 millis() 函数返回的毫秒计数器。这个毫秒计数器是在 Arduino 的系统时钟节拍中断里更新的。

---

The main point here is that the external inputs are variables that are *shared* between concurrent entities, like peripherals and interrupts.

这里的核心要点是：外部输入是变量，它们在并发的实体之间被共享——比如外设和中断之间。

---

I really hope that by now in this video course you've learned to be very circumspect of any such sharing, because anything that changes asynchronously with respect to your code's execution can lead to race conditions, data corruption, and other problems of this kind.

我真的希望学到这里，你已经学会了对任何形式的共享保持高度警惕。因为任何相对于你代码执行而言异步变化的东西，都可能导致竞态条件、数据损坏以及诸如此类的问题。

---

For these reasons, input-driven state machines could be compared to the asynchronous circuits mentioned before, while event-driven state machines to the synchronous circuits.

正因为这些原因，输入驱动型状态机可以类比为前面提到的异步电路，而事件驱动型状态机则类似于同步电路。

---

This is just an analogy, not a precise equivalence, so please don't take it too far. But the main reason for this comparison is the asynchronous nature of inputs driving the input-driven state machines. The external inputs can change at any time, including during the state machine processing. In contrast, events in the event-driven state machine are queued and guaranteed to not change during the whole run-to-completion step.

这只是个类比，不是严格的等价关系，请不要过度引申。但做这个类比的主要原因是：驱动输入驱动型状态机的输入具有异步特性。外部输入随时可能发生变化，包括在状态机处理过程中。相比之下，事件驱动型状态机中的事件是排队的，在整个运行至完成（Run-to-Completion）步骤中保证不会改变。

---

For example, consider the input-driven state machine from a popular article "Embedded State Machine Implementation".

再来看一个例子，来自一篇很流行的文章《Embedded State Machine Implementation》中的输入驱动型状态机。

---

The state machine, used as an example in this article, controls the landing gear of an aircraft.

这篇文章以一个飞机起落架控制系统作为示例状态机。

---

It is called directly from the while(1) "superloop" and happens to be implemented as a set of functions held in an array, each function representing a state. I will discuss the various state machine implementations in a future lesson.

它直接从 while(1) 超级循环中调用，具体实现方式是把一组函数放在数组里，每个函数代表一个状态。关于状态机的各种实现方式，我会在后续课程中专门讨论。

---

But for today, let's just focus on the inputs, which among others include here the "gear_lever variable". The intent of the guard condition in state "GearDown" is to detect the rising edge of that input by testing the current value of "gear_lever" as well as the previous value stored in the local variable "prev_gear_lever"

今天我们只关注输入。输入之一是"gear_lever"变量。在"GearDown"状态中，卫条件的意图是通过比较"gear_lever"的当前值和保存在局部变量"prev_gear_lever"中的前一次值来检测该输入的上升沿。

---

Now, inside the function for the GearDown state, if the "gear_lever" variable changes asynchronously in an interrupt or is read directly from a GPIO register, for example, it can be DOWN when the guard condition is evaluated, but it can change to UP when the value is stored in "prev_gear_lever".

问题是，在 GearDown 状态的函数内部，如果"gear_lever"变量在中断中被异步修改，或者直接从 GPIO 寄存器读取，那么可能在卫条件求值时它还是 DOWN，但等到存入"prev_gear_lever"时已经变成了 UP。

---

If this happens, the rising edge of this input will be missed and the guard condition will never evaluate to TRUE. This aircraft will never take off. Please note that it doesn't matter if the "gear_lever" input is accessed directly or perhaps through some functions, similar to digitalRead() from Arudino.

如果发生了这种情况，这个输入的上升沿就会被漏掉，卫条件永远不会求值为 TRUE。这架飞机就永远无法起飞了。请注意，不管"gear_lever"输入是直接访问还是通过类似 Arduino 的 digitalRead() 这样的函数来访问，问题都是一样的。

---

The solution to such problems is, of course, buffering the inputs. By this I mean copying the values of external inputs into local variables, which are then guaranteed not to change over the run-to-completion step of the state machine.

解决这类问题的方法当然是缓冲输入（Buffering）。我的意思是把外部输入的值复制到局部变量中，这样在整个状态机的运行至完成步骤中，这些值就保证不会再变了。

---

To show you how this can work in practice and to finally get to some coding for this lesson, let's go all the way back to lesson 21 about foreground-background systems.

为了展示这种方法在实践中怎么操作，也终于该进入这节课的编码环节了，让我们回到第 21 课的前台/后台系统。

---

To base today's code on that lesson, copy lesson-21 directory to lesson-37.

以那一课的代码为基础，把 lesson-21 目录复制一份，改名为 lesson-37。

---

Get inside the new lesson-37 directory and double-click on project lesson to open it with Keil Micro-Vision IDE.

进入新的 lesson-37 目录，双击项目文件 lesson，用 Keil Micro-Vision IDE 打开。

---

To remind you quickly what happened back then, at the end of lesson-21 you've seen a non-blocking implementation of the Blinky application, directly inside the while(1) superloop. This was exactly an input-driven state machine that you officially learned today.

快速回顾一下当时的内容：在第 21 课的最后，我们实现了一个非阻塞的 Blinky 应用，直接放在 while(1) 超级循环里。这正是你今天正式学习的输入驱动型状态机。

---

This input-driven state machine is coded with the usual switch-statement based on the current state, where in every case for each state you can see the characteristic if-statements. These are the guard conditions typical for an input-driven state machine.

这个输入驱动型状态机用经典的 switch 语句来编码，根据当前状态分支。每个状态的 case 里面都有典型的 if 语句，这就是输入驱动型状态机的标志性卫条件。

---

Here is the reverse-engineered state diagram of this state machine. As you can see, the actions are associated only with transitions, so this is a Mealy-type state machine.

这是该状态机逆向推导出来的状态图。可以看到，动作只和转换关联，所以这是一个 Mealy 类型的状态机。

---

Now, there is only one input to this state machine, which is provided by the BSP_tickCtr() function.

这个状态机只有一个输入，由 BSP_tickCtr() 函数提供。

---

This function reads the l_tickCtr variable that is constantly updated in the SystTick_Handler() interrupt. So indeed, the tick-counter input changes asynchronously to the execution of the background loop.

这个函数读取的是 l_tickCtr 变量，而该变量在 SysTick_Handler() 中断中不断更新。所以确实，节拍计数器这个输入相对于后台循环的执行是异步变化的。

---

Also, in this state machine code you can see that the tick-counter input is accessed twice in each of the states, so it could be different at each access point, because it changes asynchronously. This happens to be tolerable in this small toy example, but still, buffering would make it more robust for any future modifications. Please also note that the asynchronous nature of the input is not change regardless if it is accessed directly or by means of a function call to BSP_tickCtr().

另外，在这段状态机代码中可以看到，节拍计数器输入在每个状态中都被访问了两次。由于它是异步变化的，每次访问时值可能不同。在这个小例子中碰巧可以接受，但加上缓冲会让代码更加健壮，也更方便将来修改。还要注意，不管你是直接访问变量还是通过 BSP_tickCtr() 函数调用来访问，输入的异步特性是不会改变的。

---

Alright, so the first order of business today will be to buffer the tickCtr input in the local variable "now", so that the input will be read only once in each run-to-completion step through the state machine.

好，今天的首要任务就是把 tickCtr 输入缓冲到局部变量"now"中，这样在每次通过状态机的运行至完成步骤中，输入只读取一次。

---

Downstream from setting the local variable, you can replace all direct references to the BSP_tickCtr with that local variable "now".

设置好局部变量之后，下面所有直接引用 BSP_tickCtr 的地方都可以替换为局部变量"now"。

---

Let's quickly check how this works by building the code and loading it directly to the board. And... the gree-LED still blinks happily.

我们来快速验证一下——编译代码，直接烧录到板子上。结果……绿色 LED 还是愉快地闪烁着。

---

So, now, let's extend this example by adding the Blink-Button functionality similar to the previous lessons 34 and 35. This will give you an opportunity to add a second input, the SW1 button.

接下来扩展这个例子，加入类似第 34、35 课的 Blink-Button 功能。这也让我们有机会添加第二个输入——SW1 按钮。

---

The job for today will be to react to the SW1 button, which should turn the blue-LED on when depressed, and turn the blue-LED off when released.

今天的任务是响应 SW1 按钮：按下时点亮蓝色 LED，松开时熄灭蓝色 LED。

---

You start coding this new feature with adding the BSP function to access the SW1 button.

首先添加一个 BSP 函数来读取 SW1 按钮的状态。

---

The implementation of this function will read directly the GPIO register and return 1 if it's non-zero and zero if it is.

这个函数的实现就是直接读取 GPIO 寄存器，非零返回 1，为零返回 0。

---

You must also not forget to define the SW1 button bit and to configure the SW1 switch as GPIO input, with digital function enable, and with the pull-up resistor enabled.

别忘了定义 SW1 按钮对应的位，还要把 SW1 开关配置为 GPIO 输入模式，启用数字功能，并启用上拉电阻。

---

Now, inside the actual state machine, you add automatic variable "button" for buffering the button input to the state machine. You initialize it by calling to the new BSP_SW1() function.

然后在状态机内部，添加一个自动变量"button"来缓冲按钮输入。用新写的 BSP_SW1() 函数来初始化它。

---

Also, to detect the changes in the button input you will need to remember the previous value of the button in the static variable prev_button. You initialize this prev_input to the inactive state of the SW1 button, which is 1.

此外，要检测按钮输入的变化，还需要用静态变量 prev_button 记住上一次的按钮值。把这个变量初始化为 SW1 按钮的非激活状态，也就是 1。

---

Now, you add the guard condition to detect the falling edge, where previous button was not zero and current button input is zero.

然后添加检测下降沿的卫条件：前一次按钮值非零，当前按钮值为零。

---

As an action, you turn the Blue-LED on and you save the current button to prev_button. Since this is really an internal transition, you don't change the state variable.

动作是点亮蓝色 LED，并将当前按钮值保存到 prev_button。因为这其实是一个内部转换，所以不需要改变状态变量。

---

Otherwise, you add the guard condition to detect the raising edge, where previous button was zero and the current button input is not zero.

然后添加检测上升沿的卫条件：前一次按钮值为零，当前按钮值非零。

---

As an action, you turn the Blue-LED off and you save the current button to prev_button. Again, since this is really an internal transition, you don't change the state variable.

动作是熄灭蓝色 LED，并将当前按钮值保存到 prev_button。同样，这是内部转换，不改变状态变量。

---

Now, you copy and paste the same reactions to the button into the other ON state case.

然后把相同的按钮响应逻辑复制粘贴到另一个 ON 状态的 case 中。

---

The input-driven Blinky-Button state machine is now ready, so you clean up some unused code and build the project.

输入驱动型的 Blinky-Button 状态机就这样完成了。清理掉一些不再使用的代码，编译项目。

---

Let's check how this works.

看看效果如何。

---

After loading the code to the board, you can see that the Green-LED still blinks as before and that pressing the SW1 button lights up the Blue LED.

代码烧录到板子后，可以看到绿色 LED 仍然像以前一样闪烁，按下 SW1 按钮会点亮蓝色 LED。

---

But to look more precisely, I'll use a logic analyzer.

但为了更精确地观察，我用逻辑分析仪来看。

---

In this view, the top, white trace labeled SW1 shows the button input. The three traces below show the Red, Green and Blue-LEDs, respectively.

在这个视图中，最上面的白色信号线标注为 SW1，显示的是按钮输入。下面三条信号线分别是红色、绿色和蓝色 LED。

---

The trigger is set to the falling edge of SW1, so when I start the logic analyzer, only the Gree-LED is toggling as expected.

触发条件设置为 SW1 的下降沿，所以启动逻辑分析仪后，只有绿色 LED 按预期在翻转。

---

Now, when I press and release the SW1 button, the trace triggers and stops.

现在按下再松开 SW1 按钮，信号触发，采集停止。

---

As you can see, depressing SW1 turns the Blue-LED on and releasing the SW1 button turns the Blue-LED off.

可以看到，按下 SW1 点亮蓝色 LED，松开 SW1 熄灭蓝色 LED。

---

This is all exactly as expected,

一切完全符合预期。

---

but if you look more closely, you can see that in this case the SW1 trace bounced once before setting into the depressed state.

但如果仔细看，你会发现 SW1 信号在稳定到按下状态之前弹跳了一次。

---

This is, of course, the bouncing of the electrical contacts that you already encountered back in lesson-27.

这当然就是我们在第 27 课遇到过的电气触点抖动（Bouncing）现象。

---

In this particular case your state machine keeps up with the noisy signal and manages to turn the Blue-LED on and off.

在这个特定的例子中，状态机跟上了噪声信号，成功地点亮又熄灭了蓝色 LED。

---

But sometimes the state machine misses a bounce or two, as in this case of releasing the button.

但有时候状态机会漏掉一两次弹跳，比如这次松开按钮的情况。

---

This might or might not be acceptable in your particular application, but the problem is that you have no control.

在你的具体应用中，这可能可以接受，也可能不行。但问题在于你无法控制。

---

This is all because the sampling of the inputs is coupled with the execution speed of your input-driven state machine, which can vary widely depending on what the state machine happens to be doing at the moment.

这一切都是因为输入采样和输入驱动型状态机的执行速度耦合在了一起，而执行速度会因为状态机当前在做什么而大幅波动。

---

So, in applications, where you need to keep up with your inputs that might change faster than your worst-case state machine sampling rate, you might need to decouple the polling of the inputs from the state machine execution.

所以在某些应用中，如果输入变化的速度可能超过状态机的最差采样率，就需要把输入轮询和状态机执行解耦。

---

Such decoupling gives you an opportunity to pre-process your raw inputs. For example, you might perform some digital filtering of the inputs, like "deboucing" of your raw SW1 button input.

这种解耦给了你预处理原始输入的机会。比如，可以对输入做一些数字滤波，像对 SW1 按钮的原始输入进行消抖（Debouncing）。

---

Then you need to add some layers of buffering, or queuing of the inputs, so that they are not lost.

然后还需要增加缓冲层或者输入队列，这样输入就不会丢失。

---

But this leads more and more towards event-driven state machines.

但这越来越像事件驱动型状态机了。

---

Because really, every input-driven state machine can be quite easily converted into an event-driven state machine.

因为说到底，每个输入驱动型状态机都可以很方便地转换成事件驱动型状态机。

---

To see how, just go back to the code and look at the buffered inputs. If you simply wrap them into a structure and name an instance of it "evt", you create an event, where the inputs become the event parameters.

具体怎么做呢？回到代码看看那些已缓冲的输入。只要把它们包装成一个结构体，把一个实例命名为"evt"，你就创建了一个事件，而输入变成了事件的参数。

---

This grouping of inputs has an additional benefit of packaging together inputs that represent a consistent snapshot.

把输入组合在一起还有一个额外的好处：它把代表同一时刻快照的输入打包在了一起。

---

An interesting question now is about the signal of such event. This depends on when and how your state machine gets to run. If it simply runs "as often as possible", like here in the while(1) superloop, you might call this event a generic SAMPLE. This is a low-quality event, with quite an erratic repetition rate.

一个有趣的问题是：这个事件的信号（Signal）叫什么？这取决于状态机何时以及如何运行。如果它只是"尽可能频繁"地运行，就像这里在 while(1) 超级循环中那样，你可以把这个事件命名为通用的 SAMPLE。这是一个低质量的事件，重复频率非常不稳定。

---

But to finish the conversion of your input-driven state machine to event-driven, you can add a pointer "e" to the event instance "evt",

要完成从输入驱动型状态机到事件驱动型状态机的转换，可以添加一个指向事件实例"evt"的指针"e"。

---

so that all the inputs are now accessed via the event pointer e as event parameters.

这样所有的输入就都通过事件指针 e 作为事件参数来访问了。

---

I hope you can see, how this code starts to resemble the dispatch function of an event-driven state machine from previous lessons.

希望你能看出来，这段代码开始变得和前面课程中事件驱动型状态机的 dispatch 函数很像了。

---

So, let's try to build this version and check how this works.

来编译这个版本，看看效果。

---

Again, the Green-LED blinks as before, and the SW1 button turns the Blue-LED on and off.

绿色 LED 和之前一样闪烁，SW1 按钮也能正常点亮和熄灭蓝色 LED。

---

But in a logic analyzer you still can catch instances of the bouncing button input and unreliable response of the state machine.

但在逻辑分析仪上，仍然可以捕捉到按钮输入抖动和状态机响应不可靠的情况。

---

Of course, this is to be expected, because the single buffering of inputs, now inside an event, does not change the execution rate of the state machine.

当然这是意料之中的，因为仅仅把输入缓冲放到事件里面，并没有改变状态机的执行频率。

---

So here comes perhaps the most important observation for this lesson: The reliability and robustness of a state machine depends not just on its type: input-driven versus event-driven, but also on the environment in which the state machine runs. That's exactly why I've introduced state machines in the context of event-driven active objects with queuing of events back in lesson-35.

这大概就是本课最重要的一个结论：状态机的可靠性和健壮性不仅仅取决于它的类型——输入驱动还是事件驱动——还取决于状态机运行的环境。这正是为什么在第 35 课中，我把状态机放在了带有事件队列的事件驱动型主动对象（Active Object）的上下文中来介绍。

---

But state machine applications form the whole spectrum, from input-driven state machines executing in the while(1) superloop without any buffering of inputs, through increasingly event-driven state machines with generic events and guard conditions to fully event-driven state machines running inside active objects with full event queuing.

状态机的应用形成了一个完整的谱系：从在 while(1) 超级循环中执行、没有任何输入缓冲的输入驱动型状态机，到使用通用事件和卫条件的逐步事件化的状态机，一直到运行在主动对象内部、带有完整事件队列的全事件驱动型状态机。

---

All of this does not mean that input-driven state machines are all bad. To the contrary, input-driven state machines bring a whole number of advantages in situations where external discovery and queuing of events is difficult of impractical.

以上这些并不意味着输入驱动型状态机一无是处。恰恰相反，在外部发现和排队事件比较困难或不切实际的场景下，输入驱动型状态机有很多优势。

---

For example, computer games execute code periodically based on the generic FRAME event, which comes 30 or 60 times per second. In a computer game, the discovery of interesting events is very much part of the game itself and it is impractical to perform this externally to the game. For example, an interesting event might be proximity of some enemy. This is ideal application for input-driven or periodic state machines.

比如，电脑游戏基于通用的 FRAME 事件周期性执行代码，每秒 30 或 60 次。在游戏中，发现感兴趣的事件本身就是游戏逻辑的一部分，在外部来做这件事是不现实的。比如，"敌人接近"可能就是一个感兴趣的事件。这是输入驱动型或周期性状态机的理想应用场景。

---

Another application area is in robotics, where again the robot software runs periodically at a certain frame rate and the discovery of the interesting inputs from the sensors to the robot very much depends on what the robot is doing and what's going on around it.

另一个应用领域是机器人。机器人软件同样以一定的帧率周期性运行，而从传感器中发现有意义的输入，很大程度上取决于机器人正在做什么以及周围的环境状况。

---

Finally, input-driven state machines are very useful to discover events for event driven state machines. For example, the switch debouncing mentioned earlier is demonstrated in the previous lessons 35 and 36.

最后，输入驱动型状态机在为事件驱动型状态机发现事件方面也非常有用。比如前面提到的开关消抖，在第 35 和 36 课中已经演示过了。

---

It turns out that the debouncing algorithm is a very special input-driven, Moore type state machine running periodically from the SysTick interrupt hook. This is actually 32 state machines running simultaneously capable of debouncing 32 switches.

原来消抖算法本身就是一个非常特殊的输入驱动型 Moore 状态机，从 SysTick 中断钩子中周期性运行。实际上是 32 个状态机同时在运行，能够同时对 32 个开关进行消抖。

---

But I have to leave the discussion of this to the next lesson, where I will focus exactly on the various state machine implementations.

不过这部分内容要留到下一课，下一课我会专门讲解状态机的各种实现方式。

---

This concludes this lesson about input-driven state machines. I apologize for going a bit over time, but it's really hard to squeeze almost 60 years of state machine history in less than 30 minutes.

关于输入驱动型状态机的内容就讲到这里。抱歉这节课稍微超了点时，但将近六十年的状态机历史，要在不到三十分钟内讲完确实不容易。

---

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads.

如果你喜欢这个频道，请给视频点赞并订阅以获取最新更新。也可以访问 state-machine.com/video-course 下载课程笔记和项目文件。

---

## 术语表

| 英文 | 中文 | 说明 |
|------|------|------|
| State Machine | 状态机 | 根据输入和当前状态决定输出和下一状态的计算模型 |
| Event-Driven State Machine | 事件驱动型状态机 | 仅在有新事件时才运行的状态机 |
| Input-Driven State Machine | 输入驱动型状态机 | 通过轮询输入来驱动状态转换的状态机 |
| Mealy State Machine | Mealy 状态机 | 输出取决于当前输入和当前状态 |
| Moore State Machine | Moore 状态机 | 输出仅取决于当前状态 |
| Combinational Circuit | 组合逻辑电路 | 无内部存储、输出仅取决于输入的数字电路 |
| Synchronous Circuit | 同步电路 | 由时钟信号驱动的电路 |
| Asynchronous Circuit | 异步电路 | 无时钟信号的电路 |
| D Flip-Flop | D 触发器 | 存储 1 位信息的存储元件 |
| Binary Encoding | 二进制编码 | 状态名称与触发器输出值之间的映射 |
| State Diagram | 状态图 | 用圆圈和箭头表示状态及转换的图形 |
| Truth Table | 真值表 | 列出所有输入输出组合的表格 |
| Half Adder | 半加器 | |
| Rising Edge | 上升沿 | 信号从低到高的跳变 |
| Falling Edge | 下降沿 | 信号从高到低的跳变 |
| Guard Condition | 卫条件 | 决定状态转换是否发生的布尔表达式 |
| Race Condition | 竞态条件 | 由于相对时序不确定导致结果不可预测 |
| Propagation Delay | 传播延迟 | 信号通过电子元件所需的时间 |
| Run-to-Completion (RTC) | 运行至完成 | 状态机处理一个事件时必须完整执行完毕 |
| Superloop | 超级循环 | 嵌入式系统中 while(1) 主循环的俗称 |
| Foreground/Background System | 前台/后台系统 | |
| Bouncing | 抖动 | 机械开关接触时的电气噪声现象 |
| Debouncing | 消抖 | 消除机械开关抖动的滤波处理 |
| Controller State Machine | 控制器状态机 | |
| Periodic State Machine | 周期性状态机 | |
| Polled State Machine | 轮询式状态机 | 不断轮询输入来发现事件的状态机 |
| Proto-Event | 原始事件 | 需要通过轮询和卫条件提炼的输入变量 |
| Buffering | 缓冲 | 将外部输入复制到本地变量以保证一致性 |
| Active Object | 主动对象 | 带有执行线程和事件队列的事件驱动组件 |
| Automata Theory | 自动机理论 | |
| Current State Register | 当前状态寄存器 | |
| Next State | 下一状态 | |
| Event Parameter | 事件参数 | |
| Signal | 信号 | 事件的类型标识 |
