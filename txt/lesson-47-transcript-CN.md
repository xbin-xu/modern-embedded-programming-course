# 第47课：软件断言与按契约设计（上）/ Lesson 47: Software Assertions and Design by Contract (Part 1)

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek, and in this lesson, you'll learn about software assertions and, more formally, the Design by Contract methodology in the context of embedded programming. This is part-1 of the two-part series on this subject.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这节课我们要学的是**软件断言**（software assertion），以及更正式的**按契约设计**（Design by Contract, DBC）方法论在嵌入式编程中的应用。这是这个主题两节课中的第一节。

The technique you're going to learn today is the single most valuable and effective strategy for delivering high-quality code. In my programming career, assertions and Design by Contract helped me more than any other programming technique, even more than my favorite state machines.

你今天要学的这项技术，是交付高质量代码最有价值、最有效的策略，没有之一。在我整个编程生涯中，断言和按契约设计给我的帮助比任何其他编程技术都大——甚至超过了我最爱的状态机。

Unfortunately, assertions seem to be the most important non-practice in embedded software. An alarming number of embedded developers haven't heard about assertions at all, know about them but still don't use them, or use them incorrectly.

遗憾的是，断言大概是嵌入式软件中"最重要却最没人用的"技术了。让人担忧的是，大量嵌入式开发者压根没听说过断言，或者听说了却不用，又或者用法不对。

So, today in part-1, my goal is to explain what assertions and Design by Contract are and, even more important, what they are not, and the proper use of assertions. In part-2, you'll see how to apply assertions and DBC in embedded C or C++ and other practical aspects of assertions in embedded systems.

所以今天第一节课，我的目标是讲清楚断言和按契约设计到底是什么——更重要的是，它们不是什么——以及断言的正确用法。第二节课你会看到怎么在嵌入式 C/C++ 中实际运用断言和 DBC，还有嵌入式系统中断言的各种实践要点。

---

## 什么是软件断言？ / What Are Software Assertions?

Assertions are Boolean expressions that allow a program to check itself as it runs. When an assertion evaluates to true, a program is operating as expected. Conversely, an assertion evaluating to false indicates an error, and it makes no sense for the program to continue.

断言就是让程序在运行时自我检查的**布尔表达式**（Boolean expression）。断言为真，说明程序按预期运行；断言为假，说明出错了，程序再往下跑就没什么意义了。

The C Standard provides a simple `assert` facility. To use these standard assertions, you need to include the <assert.h> standard header file. You then specify a Boolean assertion expression as the argument of the assert() macro.

C 标准库提供了一个简单的 `assert` 工具。要使用标准断言，你需要包含 `<assert.h>` 头文件，然后把一个布尔表达式传给 `assert()` 宏作为参数。

For example, here you see a function `int_div()` that performs an integer division of x by y. But the division is not defined for zero divisors, so you assert that y is not zero. You then print the x and y parameters and then return x divided by y.

举个例子，这里有个 `int_div()` 函数，做的是 x 除以 y 的整数除法。但除以零是未定义的，所以你断言 y 不为零。然后打印 x 和 y 的值，返回 x 除以 y。

Of course, you can have more than one such assertion in a given file, so here, you have another function to calculate integer log-base-two. You've encountered such a function in the lessons about the RTOS, where it was used in the scheduler to quickly find the highest-priority task ready to run.

当然，一个文件里可以有多条断言。比如这里还有另一个函数，用来计算以 2 为底的整数对数。你在 RTOS 相关的课程中见过这个函数——调度器用它来快速找到就绪的最高优先级任务。

But anyway, a logarithm is not defined for a zero argument, so you assert that x is not zero. Moreover, the function here is implemented with a lookup table, so you additionally assert that you don't index beyond the end of that table.

不管怎样，对零取对数也是未定义的，所以你断言 x 不为零。另外，这个函数是用**查找表**（lookup table）实现的，所以你还额外断言不会越界访问这张表。

So now, in main, you just call the div and log functions with various parameters and print the results. The last two calls intentionally violate the assertions so that you can see what happens.

然后在 `main` 里，你用各种参数调用 div 和 log 函数，打印结果。最后两次调用是故意触发断言失败的，这样你就能看到会发生什么。

Now, I will demonstrate how to build and run that simple program on a desktop computer from the command prompt using the GCC compiler. The code will be provided in the `lesson-47_desk` directory.

现在我来演示一下，怎么用 GCC 编译器在命令行里构建和运行这个简单程序。代码放在 `lesson-47_desk` 目录下。

If you work on Windows, as I do here, you might not have the GCC compiler, but one way of getting it is to download the QP-bundle for Windows, which, among others, contains the MinGW GCC toolset. You build the assert program with GCC as follows.

如果你跟我一样在 Windows 上工作，可能没有 GCC 编译器。一个办法是下载 Windows 版的 QP-bundle，里面包含了 MinGW GCC 工具集。用 GCC 构建断言程序的方法如下。

When you run the assert executable, you can see that the program continues until an assertion fails, whereas the printout tells you the assertion expression and the line of code where the failure occurred.

运行 assert 可执行文件，你会看到程序一直运行到某个断言失败为止。输出信息会告诉你失败的断言表达式以及出错的代码行号。

In a regular run, the output produced by the program and the error message from the failing assertion are combined. But when you redirect the output into the stdout and stderr streams, you can see that a failing assertion sends the error message to the stderr stream, whereas the normal output from the program goes to the stdout stream.

普通运行时，程序的正常输出和断言失败的错误信息是混在一起的。但如果你把输出重定向，分别查看 stdout 和 stderr，就会发现：断言失败的错误信息发到了 stderr，而程序的正常输出走的是 stdout。

Finally, you can see that a failing assertion apparently aborts the program because the final "end" output is not produced. This is consistent with the premise that continuing after a failing assertion makes no sense.

最后你还能看到，断言失败后程序显然中止了——因为最后的 "end" 输出并没有出现。这跟"断言失败后继续运行毫无意义"这个前提是一致的。

The last feature of the standard assertions I'd like to demonstrate is the ability to disable assertions by defining the NDEBUG macro, for example, in a command-line option to the compiler. This causes the assertion macros to expand into nothing, so assertions generate no code and no overhead.

标准断言还有一个功能我想演示一下：通过定义 `NDEBUG` 宏可以禁用断言，比如在编译器的命令行选项中定义。这样一来，断言宏会展开成空，不产生任何代码，也没有任何开销。

When you run the executable this time, you indeed no longer see assertion messages. Interestingly, now the program prints a logarithm of zero (as minus 1), so it survives the first error previously causing an assertion failure. But the program does not survive division by zero and silently aborts. You guess the program was aborted only because the final printout "end" is still missing.

这次运行可执行文件，确实看不到断言信息了。有意思的是，程序现在打印出了零的对数（值为 -1），挺过了之前会导致断言失败的那个错误。但除以零它挺不过去，程序静默中止了。你只能猜测程序被中止了，因为最后的 "end" 输出还是没出现。

So, this is all there is to the standard `assert()` facility. It is remarkably simple but, unfortunately, not directly applicable to embedded systems because they typically don't have the stderr stream for assertion messages and cannot abort the same way as desktop systems. Later in this lesson, you will see an implementation that is much more appropriate for embedded systems. But before that, I'd like to discuss the proper use of assertions.

以上就是标准 `assert()` 工具的全部内容了。它非常简单，但遗憾的是不能直接用在嵌入式系统上——因为嵌入式系统通常没有 stderr 流来输出断言信息，也不能像桌面系统那样直接中止。稍后你会看到一种更适合嵌入式系统的实现。不过在那之前，我想先聊聊断言的正确用法。

---

## 错误与异常情况 / Errors Versus Exceptional Conditions

To use assertions properly and effectively, you must clearly distinguish between programming errors and exceptional conditions.

要想正确有效地使用断言，你必须清楚地分辨**编程错误**（programming error）和**异常情况**（exceptional condition）。

Errors (known otherwise as "bugs") are persistent defects due to design or implementation mistakes (e.g., dividing by zero, overrunning an array index, de-referencing a NULL-pointer, or using a peripheral before initializing it).

错误（也叫"bug"）是设计或实现失误导致的持续性缺陷——比如除以零、数组越界、解引用空指针，或者外设还没初始化就去用它。

When your software has a bug, typically, you cannot reasonably "handle" the situation. Instead, you should focus on detecting, reporting, and ultimately fixing the bug. Also, you typically cannot continue execution. Instead, you must carefully devise a damage control strategy. This is where the assertions come in.

软件有了 bug，你通常没法"处理"这种情况。你应该做的是检测、报告，最终修复它。而且你通常也没法继续执行——必须精心制定一套损害控制策略。断言就是干这个的。

In contrast to errors, exceptional conditions are specific circumstances that can legitimately arise during the system's lifetime but are relatively rare and lie off the main execution path of your software.

跟错误不同，异常情况是系统生命周期中合法出现、但比较少见的特定情形，它们偏离了软件的主要执行路径。

Examples include incorrect user input, transmission errors on inherently unreliable connections (such as wireless), abnormal or degraded modes of operation, etc. In those cases, you should NOT use assertions; rather, you must carefully design and implement strategies that handle such exceptional conditions using regular code.

比如：用户输入错误、无线等不可靠连接上的传输错误、异常或降级运行模式等等。这些情况下你不应该用断言，而是要用常规代码仔细设计和实现应对策略。

---

## 防御性编程 / Defensive Programming

Attempting to "handle" an error as an exceptional condition is just as bad as the other way around. This programming style is known as "defensive programming." It aims to make the software more "robust" to errors by accepting a wider range of inputs or allowing an order of operations inconsistent with the program's state.

把错误当异常情况来"处理"，跟反过来一样糟糕。这种编程风格叫做**防御性编程**（defensive programming）。它试图通过接受更广范围的输入，或者允许跟程序状态不一致的操作顺序，来让软件对错误更"健壮"。

For example, a defensively programmed `int_div()` function would not assert, but instead, it would "handle" the zero-divisor by returning some bogus value, such as `0xFFFF`.

比如，用防御性编程写的 `int_div()` 不会加断言，而是"处理"零除数的情况——返回一个虚假的值，比如 `0xFFFF`。

Similarly, a defensively programmed `int_log2()` would "handle" the below the range x by returning, say -1, the above-the-range value, by another made-up value, such as 999, and only otherwise the real value from the lookup table.

同样，防御性编程的 `int_log2()` 会"处理"低于范围的 x——返回 -1；高于范围的值呢，返回另一个编造的数字比如 999；只有正常范围内才返回查找表里的真实值。

Another example would be the Board Support Package functions for turning LEDs on and off in your TivaC LaunchPad board. Normally, these functions simply write to the GPIO registers, assuming that the GPIO pins have been initialized. But coded defensively, the functions would check whether the GPIO was initialized and would silently perform the initialization if needed.

再举个例子，TivaC LaunchPad 板上开关 LED 的**板级支持包**（Board Support Package, BSP）函数。正常情况下这些函数就是往 GPIO 寄存器写值，前提是 GPIO 引脚已经初始化了。但用防御性编程的话，函数会先检查 GPIO 有没有初始化，没有就静默地帮你初始化。

Defensive programming is often advertised as a better coding style, but unfortunately, it hides bugs and frequently introduces new bugs due to the additional complexity.

防御性编程经常被吹捧为更好的编码风格，但遗憾的是，它会掩盖 bug，而且因为多出来的复杂性，还经常引入新的 bug。

Please also note that behaviors, like reacting to incorrect user inputs or limping mode in a vehicle, are always a result of intentional design and dedicated code. Specifically, it is rather naive to expect that such behaviors could ever miraculously emerge from "defensive programming." Instead, it is far more likely that defensive programming will produce bogus, incorrect results and undesirable behaviors.

还要注意一点：像对错误用户输入做出反应、或者车辆的跛行模式这类行为，都是专门设计和专用代码的产物。指望这些行为从"防御性编程"中奇迹般地冒出来，那就太天真了。真实情况是，防御性编程更可能产生虚假、错误的结果和不可控的行为。

---

## 按契约设计 / Design by Contract

But going back to assertions, a powerful methodology that takes assertions to the next level is Design by Contract (DBC), pioneered by Bertrand Meyer in the mid 1980's. (A link to Bertrand Meyer's article "Applying Design by Contract" is in the video description.)

回到断言的话题。有一种方法论把断言提升到了更高的层次，那就是**按契约设计**（Design by Contract, DBC），由 Bertrand Meyer 在 1980 年代中期提出。（视频描述里有他那篇 "Applying Design by Contract" 文章的链接。）

DBC views assertions as specifications of mutual obligations between software components -- analogous to contracts between people. The central idea of this method is to inherently embed those contracts in the code (as assertions) and validate them automatically at run time.

DBC 把断言看作软件组件之间互相承担义务的规范——就好比人与人之间的契约。核心思想是把这些契约直接嵌入代码中（以断言的形式），然后在运行时自动验证。

Doing so consistently has two significant benefits: 1) It automatically helps detect bugs (as opposed to "handling" them), and 2) It is one of the best ways to document the mutual obligations of software components and the internal assumptions necessary for the code to work correctly.

坚持这样做有两个显著好处：第一，它能自动帮你检测 bug（而不是"处理" bug）；第二，它是文档化软件组件间义务和代码正确运行所需内部假设的最佳方式之一。

---

## 断言不是什么 / What Assertions are NOT

Design by Contract perspective helps you to truly understand software assertions. And that is, assertions are NOT an error-handling mechanism. They neither handle nor prevent errors, just like contracts among people don't prevent fraud.

从按契约设计的视角，你才能真正理解软件断言。关键在于：断言不是错误处理机制。它们既不处理错误，也不防止错误——就像人与人签合同并不能防止欺诈一样。

For example, asserting that the divisor is not zero does not really prevent calling the `int_div()` function with zero divisors.

比如，断言除数不为零，并不能阻止别人用零除数去调用 `int_div()`。

Similarly, asserting that an array index is in range might give you a warm and fuzzy feeling that you have "handled" or prevented a bug, when actually, you haven't.

同样，断言数组索引在范围内，可能会让你有种很踏实的感觉，觉得你已经"处理"或"防止"了 bug——但实际上并没有。

What really happened, however, is that you did establish a contract, in which you spelled out that the parameter to your function `int_log2()` must be in a certain range.

你真正做的，是建立了一份契约——明确声明了 `int_log2()` 函数的参数必须在某个范围内。

As long as assertions are enabled, the contract will be checked automatically, and sure enough, the program will brutally abort if the contract fails. At first, you might think that this must be backward. Contracts not only do nothing to handle (let alone fix) bugs, but they actually make things worse by turning every asserted condition, however benign, into a fatal error!

只要断言是开启的，契约就会被自动检查。一旦契约被违反，程序会毫不留情地中止。你一开始可能会觉得这搞反了——契约不但没有处理（更别说修复）bug，反而把每个被断言的条件都变成了致命错误！

However, please recall from the previous discussion that the first priority when dealing with errors is to detect them, not to hide them. To this end, a bug that causes a loud crash (and identifies precisely which contract was violated) is much easier to find and fix than a subtle one that manifests itself intermittently with millions of machine instructions downstream from the spot where you could have easily detected it.

但是回想一下前面的讨论：处理错误的第一优先级是检测，而不是隐藏。从这个角度看，一个导致明显崩溃、精确告诉你哪个契约被违反的 bug，比一个时隐时现、在你本该轻松检测到的位置之后数百万条指令处才发作的 bug，要好找好修得多。

Also, as you'll see in a minute, assertions can provide the last line of defense and an opportunity to perform corrective actions and damage control. In contrast, defensive programming surrenders to the bugs and does not offer such an opportunity.

另外，你马上就会看到，断言可以提供最后一道防线，给你机会执行纠正操作和损害控制。相比之下，防御性编程是直接向 bug 投降，根本不给你这个机会。

---

## 断言如同保险丝 / Assertions as Fuses

Besides assertions as contracts, another insightful analogy is to think of assertions in software as corresponding to fuses in electrical circuits. Electrical engineers insert fuses in various places of their circuits to instill controlled damage (burning a fuse) in case the circuit fails or is mishandled. It is unimaginable to have any non-trivial circuit, such as a home wiring or electrical system of a car, without many differently rated fuses.

除了把断言看作契约，还有一个很形象的类比：把软件中的断言比作电路中的**保险丝**（fuse）。电气工程师在电路的各处安放保险丝，一旦电路出故障或被误操作，就让损害以可控的方式发生——烧断一根保险丝。任何像样的电路——比如家里的布线、汽车的电气系统——都不可能没有一堆不同规格的保险丝。

Please note that a fuse can neither prevent nor fix a problem, so replacing a burned fuse doesn't help until the root cause of the problem is removed. In fact, the terms "bug" and "debugging" originate from an actual bug found in the wiring. The problem was fixed only after removing the bug.

请注意，保险丝既不能防止问题也不能修复问题。在找到根本原因之前，换个烧断的保险丝是没用的。说个趣事，"bug" 和 "debugging" 这两个词，还真就是从线路里发现的一只真正的虫子来的。把那只虫子拿掉，问题才算修好。

---

This concludes Part-1 of the two-part series about assertions and Design by Contract. In Part-2, you'll see how to apply assertions and DBC in embedded C or C++.

关于断言和按契约设计的两节课，第一节就到这里。第二节你会看到如何在嵌入式 C/C++ 中实际应用断言和 DBC。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/video-course 下载。

Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course." Thanks for watching!

所有项目也可以在 GitHub 上的 Quantum Leaps 仓库 "modern embedded programming course" 中找到。感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| assertion | 断言 | 运行时检查的布尔表达式，用于验证程序正确性 |
| Design by Contract (DBC) | 按契约设计 | Bertrand Meyer 提出的将断言视为软件组件间契约的方法论 |
| assert() macro | assert() 宏 | C 标准库提供的断言宏，定义在 `<assert.h>` 中 |
| NDEBUG macro | NDEBUG 宏 | 定义该宏可禁用标准断言，使其不生成任何代码 |
| stderr | 标准错误流 | C 标准中用于输出错误信息的流 |
| stdout | 标准输出流 | C 标准中用于正常输出的流 |
| programming error (bug) | 编程错误（bug） | 设计或实现失误导致的持续性软件缺陷 |
| exceptional condition | 异常情况 | 系统生命周期中合法出现但相对少见的情形 |
| defensive programming | 防御性编程 | 试图通过接受更广范围输入来"处理"错误的编程风格，通常会掩盖 bug |
| damage control | 损害控制 | 检测到错误后采取的减轻后果的策略 |
| lookup table | 查找表 | 用于快速检索预计算结果的数据结构 |
| Board Support Package (BSP) | 板级支持包 | 针对特定硬件板的底层驱动和配置代码 |
| contract | 契约 | 软件组件之间关于互相承担义务的正式规范 |
| fuse | 保险丝 | 断言的类比对象，故障时以可控方式断开电路 |
| QP-bundle | QP-bundle | Quantum Leaps 提供的软件包，包含 QP 框架和工具链 |
| MinGW GCC | MinGW GCC | Windows 平台上的 GNU C 编译器工具集 |
