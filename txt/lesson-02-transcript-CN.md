# 第2课：控制流 / Lesson 2: Flow of Control

Welcome to the Embedded Systems Programming course. My name is Miro Samek and in this lesson I'm going to show you how to change the flow of control through your code.

欢迎来到嵌入式系统编程课程。我是 Miro Samek，这节课我来讲讲怎么改变代码的**控制流**（flow of control）。

---

Let's start with making a copy of the previous lesson1-project and renaming it to lesson2. If you don't have the lesson1-project, you can get it online from state-machine.com/quickstart.

先把上一课的 lesson1 项目复制一份，重命名为 lesson2。如果你手头没有 lesson1 项目，可以去 state-machine.com/quickstart 下载。

---

Making frequent backup copies of a working project is something I highly recommend. The golden rule of software development is to keep the code working at all times, by making only small incremental changes. So, if you get something working--save it. You will sure be glad you did, when you mess up a step. Typically it's much easier to back up to the last working version than try to fix broken code.

我强烈建议你经常备份能正常工作的项目。软件开发的黄金法则是：每次只做**小的增量改动**（incremental changes），让代码始终保持可运行状态。所以，一旦某个功能跑通了——马上保存。等你哪步搞砸的时候，一定会庆幸自己这么做了。通常回退到上一个能用的版本，比去修坏掉的代码要容易得多。

---

Get inside the lesson2 directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to lesson 0.

进入 lesson2 目录，双击工作区文件打开 IAR 工具集。如果你还没装 IAR，回到第 0 课去看安装方法。

---

So, here is the C program we've created in lesson 1. As every C program, this one starts execution at the main function. Inside main, you have a very simple linear code, in which the control flows from top to bottom. Let's have a quick look in the debugger, to see how our processor handles this simplest flow of control.

这就是我们在第 1 课写的那个 C 程序。跟所有 C 程序一样，它从 **main 函数**开始执行。main 里面是一段很简单的线性代码，控制流从上往下依次执行。我们在调试器里快速看一下，看看处理器是怎么处理这种最简单的控制流的。

---

Make sure that the debugger is set to the Simulator and click the "Download and Debug" button.

确保调试器选的是模拟器（Simulator）模式，然后点 "Download and Debug" 按钮。

---

Let me quickly remind you what you see in the debug mode. The disassembly window shows the machine instructions. The Register view shows the state of the ARM Cortex-M registers. The most interesting for you today is the Program Counter (PC) register, which contains the address of the current instruction, which is the one highlighted in the disassembly view.

先快速回顾一下调试模式里你看到的内容。反汇编窗口显示的是**机器指令**（machine instructions），寄存器视图显示的是 ARM Cortex-M 各寄存器的状态。今天你最需要关注的是**程序计数器**（Program Counter, PC）寄存器，它保存着当前指令的地址——就是反汇编视图里高亮的那条指令。

---

Single step through the code one machine instruction at a time and watch how the PC changes at each step. Please note that you are only executing instructions to increment the R1 register, but there are no any specific instructions for incrementing the PC. Rather, every instruction increments the PC as a side effect.

单步执行代码，每次走一条机器指令，观察 PC 每一步的变化。注意，你执行的指令只是在递增 R1 寄存器，并没有专门用来递增 PC 的指令。实际上，每条指令都会把递增 PC 当作**副作用**（side effect）来完成。

---

So, here you have it: the simplest, linear control flow through the code from top to bottom is hardwired in the instructions themselves.

所以你看，最简单的线性控制流——从上往下依次执行——是硬编码在指令本身里面的。

---

In this lesson, you will learn how to change this hardwired flow of control, so that the program can loop or conditionally skip over parts of the code. Such changes in the flow of control will allow you to avoid repetitions and make decisions at run time.

这节课你要学的是怎么打破这种硬编码的控制流，让程序能够**循环**（loop）或者**有条件地跳过**（conditionally skip）某些代码。有了这些能力，你就能避免重复代码，还能在**运行时**（run time）做判断。

---

So now, let's exit the debugger and modify the code to use a loop.

好，退出调试器，我们来改代码，加个循环。

---

The simplest loop in C is the while-loop. You code it by adding the while keyword, followed by a condition in parentheses, followed by the body of the loop.

C 语言里最简单的循环是 **while 循环**（while-loop）。写法是：`while` 关键字，后面跟括号里的条件，再跟循环体。

---

This code starts with checking the condition, and if it is true, it executes the body of the loop and goes back to checking the condition. The loop exits only when the condition is false.

这段代码先检查条件，条件为真就执行循环体，然后回去再检查条件。只有条件为假时，循环才会退出。

---

In this particular case, we happened to have 21 increments of the counter variable, so to execute the same number of increments the condition is (counter < 21).

在我们这个例子中，计数器变量恰好递增了 21 次，所以为了执行相同次数的递增，条件设成 `(counter < 21)`。

---

Let's compile and run this code in the simulator.

编译一下，在模拟器里跑跑看。

---

The first instruction moves 0 to the R0 register, which is now used to hold the counter variable

第一条指令把 0 存入 R0 寄存器，R0 现在被用来保存计数器变量。

---

The next B instruction is the very interesting Branch instruction, because it modifies the PC, so it skips over a few instructions.

接下来是 B 指令，也就是非常有趣的**分支指令**（Branch instruction）。它会修改 PC，从而跳过几条指令。

---

The next, CMP instruction, compares the R0 to the number 21 that you can actually see encoded as hex 15 in the instruction itself.

再往下是 **CMP 指令**（Compare instruction），把 R0 跟数字 21 做比较。实际上你能在指令编码里看到 21 被编码成十六进制的 `0x15`。

---

The CMP instruction has a very interesting side effect of modifying the APSR register, which stands for Application Program Status Register. Specifically, the CMP instruction sets the N-bit (negative) in the APSR, because the comparison is performed as a difference R0-21, which turns out negative.

CMP 指令有一个很有意思的副作用——它会修改 **APSR 寄存器**（Application Program Status Register，应用程序状态寄存器）。具体来说，CMP 指令会设置 APSR 中的 **N 位**（负数标志位），因为比较操作实际算的是 R0 减去 21，结果为负。

---

The BLT instruction is a variant of the Branch instruction you already saw, but this one is conditional. Specifically, the BLT instruction modifies the PC only when the N-bit in the APSR is set. Otherwise the BLT instruction simply falls through to the next instruction.

**BLT 指令**（Branch if Less Than）是你刚才看到的分支指令的一个变种，但它是**条件分支**（conditional branch）。也就是说，BLT 只有在 APSR 的 N 位被置位时才会修改 PC，否则就顺序执行下一条指令。

---

At this point a good question is this: "How does the Branch instruction know where to jump?"

这里有个好问题：分支指令怎么知道该跳到哪里去？

---

Well, it turns out that this information is encoded in the instruction.

答案是：这个信息就编码在指令里面。

---

Here is a page from the ARM Architecture Reference Manual, which explains the encoding of all the B instruction variants. Our instruction starts with 0xD, which means that it uses the encoding T1. The next nibble in the instruction denotes the condition, and 0xB means the LT condition.

这是 ARM 架构参考手册中的一页，解释了所有 B 指令变体的编码方式。我们的指令以 `0xD` 开头，说明用的是 **T1 编码**。指令中的下一个**半字节**（nibble）表示条件，`0xB` 代表 LT（小于）条件。

---

Finally, the byte FC encodes by how much the PC should be changed, which is called the offset. Now, the offset is a signed quantity, and from Lesson 1, you should remember that signed numbers use the two's complement representation. Therefore, the byte 0xFC represents -4.

最后，字节 `0xFC` 编码的是 PC 要改变多少，也就是**偏移量**（offset）。注意，偏移量是有符号数，第 1 课你应该学过，有符号数用的是**二进制补码**（two's complement）表示。所以 `0xFC` 实际上是 -4。

---

So, now we can calculate the new value of the PC. You take the current PC 0x7E and subtract 4, which gives 0x7A. This is what you expect the jump to go to.

现在我们可以算 PC 的新值了。当前 PC 是 `0x7E`，减去 4，得到 `0x7A`。这就是跳转的目标地址。

---

Let's verify this by executing the BLT instruction. Hey, what do you know, you are correct! The PC jumps backwards, so you have a loop, which you can verify by stepping through the code.

执行一下 BLT 指令来验证。嘿，你算对了！PC 往回跳了，于是就有了循环——你可以继续单步执行来验证。

---

Please don't worry--I won't spend any more time on drilling into instructions. But I think that dissecting the BLT instruction has been really educational, because it gave you a glimpse into the inner workings of the ARM Cortex-M processor.

别担心——我不会再继续深挖指令细节了。不过我觉得拆解 BLT 指令确实很有价值，因为它让你窥见了 ARM Cortex-M 处理器内部是怎么工作的。

---

So now, let's go back to the flow of control. I hope you have noticed that the disassembled code implements a different flow of control from what I've described for the while loop. The original code was supposed to test the condition first and then jump over the loop body if the condition wasn't true. The compiled code starts with an unconditional branch and reverses the order of the loop body and the testing of the condition. When you think about it, though, those two flows of control are equivalent, except the generated one is faster, because it has only one conditional branch at the bottom of the loop.

好，回到控制流的话题。希望你注意到了，反汇编出来的代码跟我之前讲的 while 循环的控制流不太一样。原始代码应该是先测条件，条件不成立就跳过循环体。但编译出来的代码以一个**无条件分支**（unconditional branch）开头，把循环体和条件测试的顺序反过来了。不过仔细想想，两种控制流其实是等价的，只是编译器生成的那个更快，因为它在循环底部只有一个条件分支。

---

This example demonstrates two important points. First, a single C statement, such as "while", can generate multiple machine instructions, which don't even have to be grouped together. Second: the compiler is pretty darn smart and knows the processor better than you.

这个例子说明了两个要点。第一，一条 C 语句（比如 `while`）可以生成多条机器指令，这些指令甚至不需要挨在一起。第二：**编译器**（compiler）比你聪明得多，它对处理器的了解远胜于你。

---

The non-linear flow of control has also a significant effect on how fast the processor can execute your code, and as an Embedded Systems programmer you need to be aware of it.

非线性控制流对处理器执行代码的速度影响很大，作为嵌入式程序员，你必须意识到这一点。

---

First, there is the loop overhead, because you now execute additional tests and jumps just to handle the loop.

首先是**循环开销**（loop overhead）——为了维持循环，你得多执行一些测试和跳转指令。

---

But wait, it gets worse. The jumps add additional execution delays due to the pipeline stalls. Let me explain.

等等，还有更糟的。跳转还会因为**流水线停顿**（pipeline stall）带来额外的执行延迟。我来解释一下。

---

All modern processors, including ARM Cortex-M, use an instruction pipeline to increase the throughput. Pipeline is like an assembly line, in which the processor works on multiple instructions at various stages of completion. This increases the number of instructions that can be processed in a given time.

所有现代处理器——包括 ARM Cortex-M——都使用**指令流水线**（instruction pipeline）来提升吞吐量。流水线就像工厂的装配线，处理器同时在处理多条处于不同完成阶段的指令。这样单位时间内能处理更多指令。

---

Each instruction is split into a sequence of independent steps, such as fetch from memory, decode, and execute, whereas each of these steps takes one clock cycle to complete. The pipeline works at full capacity when the instructions are executed in order. But, when this ordering is disrupted by a Branch instruction, the pipeline needs to discard the partially processed instructions and re-start at the new instruction. This means that the pipeline stalls for a few cycles.

每条指令被拆成一系列独立的步骤，比如从内存**取指**（fetch）、**译码**（decode）、**执行**（execute），每个步骤需要一个**时钟周期**（clock cycle）。指令按顺序执行时，流水线满负荷运转。但一旦分支指令打乱了这个顺序，流水线就得把已经处理了一半的指令丢掉，从新指令重新开始。这就是流水线停顿几个周期的原因。

---

Please note that I'm saying that you should avoid loops in your programs. The effects I've just discussed are really important only in time-critical code, such as interrupt processing, and are irrelevant for most of the other cases.

请注意，我不是说你在程序中要避免用循环。刚才讨论的这些影响只在**时间关键代码**（time-critical code）中才真正重要，比如**中断处理**（interrupt processing），大多数其他场景下根本不用在意。

---

However, when you really need to speed things up, you now know what to do. You can unroll some loops either entirely or by as much as you need. For example, you can modify the while loop as follows:

但如果你确实需要提速，现在知道该怎么做了吧。你可以对循环做**循环展开**（loop unrolling），可以完全展开，也可以按需部分展开。比如，把 while 循环改成这样：

---

You increase the number of counter increments per a single pass through the loop and adjust the loop

增加每次循环中计数器递增的次数，同时相应调整循环条件。

---

Now, when you execute the code, you can see that the testing and branching happens less frequently, yet you execute the same number of 21 increments.

现在跑一下代码，你会发现测试和分支的频率降低了，但仍然是 21 次递增，一次没少。

---

Finally for this lesson, I'd like to show you how to use flow of control to make decisions at run time. Assume, for example, that you want to do something special every time the value of the counter variable becomes odd.

最后，我想演示一下怎么用控制流在运行时做判断。举个例子，假设你想在计数器变成奇数的时候执行一些特殊操作。

---

Let's revert to the previous version by typing Ctrl-Z a few times and start coding the "if" statement, which you code as follows:

按几次 Ctrl-Z 回到之前的版本，然后开始写 **if 语句**（if statement），写法如下：

---

You start with the if keyword followed by the condition in parentheses, followed by the code to execute when the condition is true.

先写 `if` 关键字，后面跟括号里的条件，再跟条件为真时要执行的代码。

---

The condition expression used to test whether the counter is odd needs some explanation. The ampersand stands for the bit-wise AND operator, which performs the AND operation between every bit of the counter and the second operand. As you can see in the few examples, the second operand of 1 tests the least significant bit of the counter, which is zero when the counter is even and 1 when the counter is odd.

判断计数器是不是奇数的条件表达式需要解释一下。`&` 是**按位与运算符**（bit-wise AND operator），它对计数器的每一位跟第二个操作数做 AND 运算。第二个操作数 1 只测试计数器的**最低有效位**（least significant bit）——偶数时该位为 0，奇数时为 1。

---

The exclamation-point equals operator means not-equal.

`!=` 运算符表示**不等于**（not-equal）。

---

You can also add an optional else branch to the if, which is executed only when the condition is false:

你还可以在 if 后面加一个可选的 **else 分支**（else branch），只在条件为假时执行：

---

I hope that you noticed by now, that the control-flow statements in C can nest, so you can have an if within the while and so on.

希望你已经注意到了，C 语言的控制流语句可以**嵌套**（nest）使用——在 while 里套 if，以此类推。

---

This concludes this lesson about flow of control. In the next lesson you'll learn a bit more about variables and pointers. If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

控制流这节课就到这里。下一课我们会聊聊变量和指针。如果你喜欢这个频道，请订阅保持关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

Course web-page:
http://www.state-machine.com/quickstart

YouTube playlist of the course:
http://www.youtube.com/playlist?list=PLPW8O6W-1chwyTzI3BHwBLbGQoPFxPAPM

课程网页：
http://www.state-machine.com/quickstart

课程 YouTube 播放列表：
http://www.youtube.com/playlist?list=PLPW8O6W-1chwyTzI3BHwBLbGQoPFxPAPM

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| flow of control / control flow | 控制流 | 程序执行的顺序和路径 |
| while-loop | while 循环 | C 语言中最基本的循环结构 |
| main function | main 函数 | 每个 C 程序的入口函数 |
| Program Counter (PC) | 程序计数器 | 存储当前执行指令地址的寄存器 |
| machine instruction | 机器指令 | CPU 可直接执行的二进制指令 |
| Branch instruction (B) | 分支指令 | 修改 PC 以改变执行顺序的指令 |
| conditional branch | 条件分支 | 仅在特定条件满足时才跳转的分支指令 |
| CMP (Compare) instruction | 比较指令 | 比较两个值并设置状态标志的指令 |
| BLT (Branch if Less Than) | 小于则分支 | N 位被设置时跳转的条件分支指令 |
| APSR (Application Program Status Register) | 应用程序状态寄存器 | 保存算术逻辑运算状态标志的寄存器 |
| N-bit (negative flag) | N 位 / 负数标志位 | APSR 中指示结果为负数的标志位 |
| offset | 偏移量 | 分支指令中编码的跳转距离 |
| two's complement | 二进制补码 | 计算机中表示有符号整数的方法 |
| nibble | 半字节 | 4 位二进制数据 |
| unconditional branch | 无条件分支 | 始终执行的分支指令，不受条件限制 |
| loop overhead | 循环开销 | 管理循环所需的额外测试和跳转指令 |
| instruction pipeline | 指令流水线 | 将指令处理分为多个阶段以提高吞吐量的技术 |
| pipeline stall | 流水线停顿 | 流水线因分支跳转等原因暂停工作，造成性能损失 |
| fetch / decode / execute | 取指 / 译码 / 执行 | 指令流水线的三个基本阶段 |
| clock cycle | 时钟周期 | 处理器执行一个基本步骤所需的时间单位 |
| time-critical code | 时间关键代码 | 对执行时间有严格要求的代码段 |
| interrupt processing | 中断处理 | 响应硬件或软件中断的服务例程 |
| loop unrolling | 循环展开 | 通过减少循环次数来降低循环开销的优化技术 |
| if statement | if 语句 | 根据条件选择性执行代码的控制流语句 |
| bit-wise AND operator (&) | 按位与运算符 | 对操作数的每一位执行 AND 操作 |
| least significant bit | 最低有效位 | 二进制数中最右边的一位 |
| not-equal operator (!=) | 不等于运算符 | 比较两个值是否不相等 |
| side effect | 副作用 | 指令执行的主要目的之外产生的附加效果 |
| nest / nesting | 嵌套 | 将一个控制结构放置在另一个控制结构内部 |
| incremental changes | 增量改动 | 对代码进行小幅度、渐进式修改 |
| compiler | 编译器 | 将高级语言代码转换为机器指令的程序 |
