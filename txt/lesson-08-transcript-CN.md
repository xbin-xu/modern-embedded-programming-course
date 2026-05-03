# 第8课：C 函数与栈 / Lesson 8: C Functions and the Stack

Welcome to the Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll introduce you to C functions and the stack. I can't possibly cover all the important aspects of working with functions in just one lesson. So today, I will mainly focus on explaining how the C Stack enables calling functions that call other functions, etc.

欢迎来到嵌入式系统编程课程。我是 Miro Samek，今天我们来聊聊**函数（function）**和**栈（stack）**。函数这个话题很大，一节课肯定讲不完，所以今天我主要讲一个核心问题：C 栈是怎么支撑函数调用的——包括函数再调用其他函数这样的嵌套调用。

If you only ever bother to learn about one aspect of the low level behavior of C or C++, then the C stack is most likely this one thing, because it is key to understanding functions, interrupts, context switch, and the RTOS.

如果你只打算深入了解 C/C++ 底层行为的某一个方面，那我推荐你学栈。因为它是理解函数、**中断（interrupt）**、**上下文切换（context switch）**和**实时操作系统（RTOS）**的关键。

As usual, let's start with making a copy of the previous "lesson7" project and renaming it to "lesson8". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

老规矩，先把上一课的 "lesson7" 项目复制一份，重命名为 "lesson8"。如果你是刚加入的，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson8" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

进入 "lesson8" 目录，双击工作区文件打开 **IAR 工具集（IAR Toolset）**。如果你还没装，回到第 0 课去看安装说明。

While I do some clean up, let me quickly remind you what this program does.

趁我清理一下代码，快速回顾一下这个程序的功能。

It starts with setting up the registers inside the LM4F microcontroller to control the LEDs attached to the GPIO lines. Next, it lights up the blue LED and then it enters an endless loop in which it lights up the red LED, waits in a delay loop, extinguishes the red LED, waits again in another delay loop and loops back to the beginning.

程序先配置 **LM4F 微控制器（microcontroller）**内部的寄存器，控制连接在 **GPIO** 引脚上的 LED。然后点亮蓝色 LED，接着进入一个无限循环：点亮红色 LED，延时等待，熄灭红色 LED，再延时等待，周而复始。

When you look at the program at this stage, I hope you agree that the repetition of the delay loop is rather ugly. In fact, it goes against the DRY principle, which stands for Do Not Repeat Yourself. In other words, in programming, you should strive to eliminate repetitions so that parts of code that are supposed to be the same can't get out of sync.

看一下现在的代码，我希望你也觉得延时循环的重复很碍眼。这其实违反了 **DRY 原则（Don't Repeat Yourself，不要重复自己）**。编程中应该尽量避免重复，否则本该一样的代码可能会变得不一致。

Today you are going to learn one of the main techniques of avoiding repetitions, which is to turn a piece of code into a function, and then call this function as many times as needed, instead of repeating the same code verbatim.

今天你要学的就是避免重复的常用手段：把一段代码封装成函数，然后需要的时候调用它，而不是把同样的代码抄一遍又一遍。

A function in C, also known as a procedure, subroutine, or sub-program in other programming languages, is a reusable piece of code that can be executed from many different points in a program.

C 语言中的函数，在其他语言里也叫**过程（procedure）**、**子例程（subroutine）**或**子程序（sub-program）**。本质上就是一段可以反复使用的代码，程序的多个地方都可以调用它。

In order to turn a piece of code into a function, you need to give it a name, a list of arguments, and a return type. So, to start simple, our dealy function will have the name delay, will take no arguments and will return no value. These three elements: the return type, the name, and the list of arguments are called together the signature of the function. The function code goes between the opening and closing braces that follow the signature.

要把一段代码变成函数，你需要给它起个名字、指定参数列表和返回类型。先来个简单的——我们的 `delay` 函数，名字就叫 `delay`，不接收参数，也不返回值。返回类型、函数名、参数列表，这三样东西合起来叫做函数的**签名（signature）**。函数的具体代码写在签名后面的一对花括号里。

Once your function is defined, you can very easily call it as many times as you like. The syntax for calling a function is the function name followed by arguments in parentheses. The parentheses are necessary, even if the function takes no arguments.

函数定义好之后，想调用几次就调用几次，非常方便。调用语法就是函数名加括号里的参数。即使函数没有参数，括号也不能省。

Calling a function means changing the flow of control to jump to the beginning of the function code, executing the code, and returning to the next instruction just after the call.

调用函数其实就是改变**控制流（flow of control）**：跳到函数代码开头执行，执行完了再回到调用点的下一条指令。

Let's check if this code compiles by pressing F7.

按 F7 看看代码能不能编译通过。

I'm sure you are eager to run this code on a real board. But before you do this, please change the project options as follows:

我猜你已经迫不及待想在开发板上跑了。不过先别急，把项目选项改一下：

set the optimization to LOW, because at high level of optimization the compiler is so smart that it will eliminate the function call overhead by essentially reversing what you have done so far. This is called "inlining" a function and obviously, you don't want that at this point.

把优化级别设为 LOW。因为高优化级别下编译器太聪明了，它会直接把函数调用开销消除掉——基本上就是把你刚做的工作给撤销了。这叫**内联（inlining）**，现在你显然不希望出现这种情况。

Also, whenever you work with functions, I strongly recommend checking the option "REQUIRE PROTOTYPES".

另外，只要你用到函数，我强烈建议勾选 "REQUIRE PROTOTYPES"（需要原型）这个选项。

When you try to compile this time by pressing F7, you get an error that the function delay() has no prototype. A function prototype is the signature of the function followed by a semicolon instead of the code block. The compiler must see a prototype of each function before the definition.

这次按 F7 编译，你会收到一个错误，说 `delay()` 函数没有**原型（prototype）**。函数原型就是签名后面加分号，不带代码块。编译器要求在函数定义之前必须先看到它的原型。

By the way, your function delay() takes no arguments at this point. In the older standards of the C language, you might code it by simply an empty argument list rather than a void argument list. So let's try to do this now.

顺便说一下，此时你的 `delay()` 函数不接收参数。在 C 语言的旧标准中，你可以写一个空的参数列表，而不用写 `void`。我们来试试。

As you can see, the code no longer compiles. This is because, for backwards compatibility, the empty argument list means that arguments are not specified, and could be anything. With the "require prototypes" option, the compiler is much stricter and does not recognize such a weakly specified prototype.

果然，代码编译不过了。这是因为为了向后兼容，空的参数列表意味着"参数未指定"，可以是任何东西。开了 "require prototypes" 选项后，编译器严格多了，不认可这种模棱两可的原型。

OK, so finally you are ready to run the code on the Stellaris Board. The first line of business is to check if your program still blinks the LED as before; and so it does.

好了，现在终于可以在 Stellaris 开发板上运行代码了。先确认程序还能不能像之前一样让 LED 闪烁——没问题，一切正常。

When you stop the code, you find the program inside the delay() function. This is to be expected, because your program spends 99.999% percent of the time executing the delay loop.

暂停程序，你会发现它停在 `delay()` 函数内部。这很正常，因为你的程序 99.999% 的时间都在执行延时循环。

The next interesting thing to check is to find out how your processor actually calls the delay function. So, let's set a breakpoint and run the program.

接下来一个有意思的问题是：处理器到底是怎么调用 delay 函数的？我们设一个**断点（breakpoint）**，然后运行程序看看。

As you can see, the call to your delay function boils down to just one instruction called BL. From the earlier lesson 2 about the flow of control, you might remember that a branch instruction simply change the value of the program counter (PC) register. The BL instruction has however an additional important side effect, and that is to save the address of the next instruction into the R14 register, which is also called the Link Register (LR). This way, the LR remembers the place in the code to return to after the function completes.

可以看到，调用 delay 函数其实就是一条指令——**BL（Branch with Link，带链接分支）**。还记得第 2 课讲控制流时提到的吗？分支指令就是改变**程序计数器（PC，Program Counter）**寄存器的值。但 BL 指令还多做了一个重要的事情：把下一条指令的地址存到 R14 寄存器里。R14 也叫**链接寄存器（LR，Link Register）**。这样一来，LR 就记住了函数完成后该返回到哪里。

So, let's remember that the next instruction following the BL is at address 0x9C. By the way, please note that the BL instruction itself is 4 bytes long, while most other instructions are only 2 bytes long. So, you can see that the instruction set of the ARM Cortex-M processor, which is called THUMB2, consists of mostly 2-byte and occasionally 4-byte instructions.

记住 BL 后面的下一条指令在地址 0x9C。顺便注意一下，BL 指令本身占 4 个字节，而大多数其他指令只占 2 个字节。可以看出 ARM Cortex-M 处理器使用的 **THUMB2 指令集**，大部分是 2 字节指令，偶尔出现 4 字节指令。

When you single step over the BL instruction, you can see that indeed the program counter jumped to the beginning of your delay function, while the LR changed to 0x9C. Or wait a minute, it actually changed to 0x9D. This is of course very strange, because all THUMB2 instructions must be aligned at an even address, and value 0x9D is odd. I will explain this oddity in a minute when we see how the function returns. But before that, let me point out a few interesting things about the function code.

单步执行 BL 指令后，程序计数器确实跳到了 delay 函数的开头，LR 变成了 0x9C。等等，实际上变成了 0x9D。这就很奇怪了——所有 THUMB2 指令必须对齐到偶数地址，而 0x9D 是个奇数。等会儿看到函数怎么返回时我再解释这个怪事。在那之前，先看看函数代码里几个有意思的细节。

The function starts with adjusting the SP register. SP stands for Stack Pointer and is an alias for the R13 register. The SP is the hardware implementation of the C call stack mechanism, and so it is the most important register to learn about in this lesson. A C stack is simply an area of RAM that can grow or shrink from one end only. The end is called the top of the stack and the SP register contains this top address.

函数开头先调整了 SP 寄存器。SP 是 **栈指针（Stack Pointer）**的缩写，也就是 R13 寄存器的别名。SP 是 C **调用栈（call stack）**机制的硬件基础，也是本课最关键的寄存器。C 栈就是一块只能从一端增长或缩减的 RAM 区域。这一端叫做**栈顶（top of stack）**，SP 寄存器保存的就是这个地址。

You can very easily see the stack in memory by pointing your memory view to the address stored in the SP. For viewing the stack, it is best to adjust the memory view to show only one column. In the ARM processor, the stack grows towards the lower addresses (which is up in the memory view) and shrinks towards to high addresses (which is down in the memory view). In other processors, the stack might grow in the opposite direction.

把内存视图定位到 SP 存的地址，就能直接看到栈了。查看栈的时候，建议把内存视图调成只显示一列。ARM 处理器中，栈向低地址方向增长（内存视图里是往上），向高地址方向缩减（内存视图里是往下）。其他处理器的栈增长方向可能相反。

A good metaphor for the C stack is a stack of dishes. You can only add or remove the dishes from the top of the stack.

C 栈就像一摞盘子——你只能从最上面放盘子或者拿盘子。

So, now you understand that subtracting 4 from the SP grows the stack by this amount and creates space for the local variable 'counter' at the top of the stack. Subsequently, this variable is cleared and incremented a million times.

所以现在你明白了：SP 减 4 就是让栈增长 4 个字节，在栈顶腾出空间给局部变量 `counter`。然后这个变量被清零，再递增一百万次。

Now, let's set a breakpoint at the end of the function to see how it returns. The first thing the compiler needed to before returning was to exactly reverse any operations on the stack that were performed at the entry to the function. In this case the stack is shrunk by 4 bytes to free the space initially allocated by the counter variable. As you can see at the current top of the stack, the last value of counter is 0xf4240, which is 1 million in decimal, which is the number of iterations of your delay loop.

现在在函数末尾设个断点，看看它怎么返回。返回之前，编译器做的第一件事就是精确地撤销进入函数时对栈的所有操作。这里就是把栈缩减 4 个字节，释放掉分配给 counter 变量的空间。你可以看到，当前栈顶保存的 counter 最终值是 0xf4240，换算成十进制就是 1,000,000——正好是延时循环的迭代次数。

The next instruction is the actual return from your function. The return is accomplished by the branch instruction BX, which stands for branch and exchange. This instruction sets the Program Counter to the value in the specified register, which is LR in this case. However, not all bits in LR are transferred to the PC. Specifically, the least-significant bit in the PC is always set to zero, which makes sense because a return address must be even.

下一条指令是函数的真正返回操作。返回用的是 **BX（Branch and eXchange，分支并交换）**指令。它把指定寄存器的值赋给程序计数器，这里就是 LR。不过 LR 的值并不是原封不动地搬到 PC 里——具体来说，PC 的**最低有效位（LSB）**总是被设为零，这也合理，因为返回地址必须是偶数。

So instead of being used for addressing, the least-significant bit in LR is interpreted as the instruction set exchange bit. If this bit is 1, the processor switches to the THUMB instruction set, if it is zero it switches to the ARM instruction set. Problem is that ARM Cortex-M supports only the THUMB2 instruction set, and cannot really switch to ARM. So in Cortex-M this behavior of the BX instruction is just a historical legacy.

所以 LR 的最低位并不用于寻址，而是被当作**指令集交换位**来解读。如果这一位是 1，处理器切换到 THUMB 指令集；如果是 0，切换到 ARM 指令集。但问题是 ARM Cortex-M 只支持 THUMB2 指令集，根本没法切换到 ARM。所以在 Cortex-M 上，BX 指令的这个行为纯粹是历史遗留。

So let's execute the BX instruction and see where it goes. Indeed, we end up at address 0x9C, which is exactly the next instruction after the call to your delay() function.

执行 BX 指令看看跳到哪里。果然，我们回到了地址 0x9C——正好是调用 `delay()` 后面的下一条指令。

Finally, just to see what happens, let's run again to the end of the delay() function and set the least-significant bit of LR to zero. This should exchange the core state to ARM, but ARM is not supported on Cortex-M cores.

最后做个实验：再运行到 `delay()` 函数末尾，把 LR 的最低位改成零。这应该会让内核切换到 ARM 状态，但 Cortex-M 内核根本不支持 ARM 指令集。

Well, as you can see, you end up in a BusFault exception. I will talk about exceptions in an upcoming lesson about interrupts, but for now, I though it would be interesting to see how a processor handles an impossible condition. The machine ends up in an exception handler, which is like a function that you can define for your specific project.

如你所见，程序直接进了 **BusFault（总线故障）异常**。异常我会在后面讲中断的课程中详细介绍，现在只是想让你看看处理器怎么应对不可能的情况——它跳进了一个**异常处理程序（exception handler）**，这东西就像一个你可以自己定义的函数。

To get out of the exception handler, you need to reset the machine. As the reset brings you back to the beginning of main, it is a good opportunity to examine a function that calls another function. By now, I hope, you noticed that main() is also a function, just like your delay function. Before you called delay() from it, main was a so called leaf function (like a leaf of a tree) because it did not call any other functions. When you added the call to delay(), main stopped being a leaf function and had to do something special to preserve its own return address. As you recall, the return address is kept in the LR register, but this register is clobbered with a new return address by the BL instruction. So, any fucntion that executes BL, must somehow save the previous value of LR, so that it can return to the right place.

要退出异常处理程序，得复位（reset）一下。复位后程序回到 `main` 开头，正好趁机看看一个函数调用另一个函数的情况。现在你应该已经注意到了，`main()` 本身也是个函数，跟你的 delay 函数一样。在 `main` 里调用 `delay()` 之前，`main` 是所谓的**叶函数（leaf function）**——就像树叶一样——因为它不调用任何其他函数。加了 `delay()` 调用后，`main` 就不再是叶函数了，得想办法保存自己的返回地址。还记得吧，返回地址存在 LR 寄存器里，但 BL 指令会用新的返回地址覆盖它。所以任何执行 BL 的函数，都必须先把 LR 之前那个值存好，不然就找不到回去的路了。

The question is, of course, where is the best place to save LR? I hope you see from the code that this place is the stack. The PUSH operation saves the specified list of registers on the stack and automatically and atomically decrements the stack pointer to grow the stack.

那问题来了：LR 存哪里最好？希望你看代码就能想到——就是栈。**PUSH（压栈）**操作把指定的寄存器保存到栈上，同时自动地递减栈指针，让栈增长。

Let's verify this by executing the PUSH instruction.

执行一下 PUSH 指令验证看看。

To summarize, you found out that the stack is used for two purposes. First it holds the local variables of the functions called, and second it stores the return addresses.

总结一下，栈干了两件事：第一，保存被调用函数的**局部变量（local variable）**；第二，存储**返回地址（return address）**。

Finally, in this lesson, I'd like to show you what the function arguments are for and how to use them. Function arguments allow you to specified initial values of the local variables at the point of the function is called, whereas each call can be made with different set of values of the arguments.

最后，再来看看**函数参数（function argument）**有什么用、怎么用。函数参数让你在调用时指定局部变量的初始值，而且每次调用可以传不同的值。

For example, you might want the delay() function to execute a different number of iterations at every invocation. To achieve it you can specify an integer argument iter which will be used as the iteration limit inside the function.

比如，你可能想让 `delay()` 每次执行不同的迭代次数。那就加一个整型参数 `iter`，在函数内部用它来控制循环上限。

Once a function takes some arguments, its every invocation must provide the initial value for all those arguments. So, if you try to compile the program right now, the compiler will report errors for the two calls to the delay() function, because they no longer match the prototype. This is the beauty of using prototypes, because the compiler can now warn you whenever you forget to provide the right number and type of arguments for every function call.

一旦函数有了参数，每次调用都必须把参数传齐。所以现在编译的话，两次 `delay()` 调用都会报错——因为它们跟原型对不上了。这就是用原型的好处：你忘了传参数或者参数类型不对，编译器都能帮你揪出来。

OK, so let's provide the arguments. For the first call, I use 1million iterations, but for the second call only 500 thousand, so that the red LED will be twice as long on as it will be off.

好，来补上参数。第一次调用传 1,000,000 次迭代，第二次只传 500,000，这样红色 LED 亮的时间就是灭的两倍。

Let's run this code on the LanuchPad board. First, remove all the breakpoints and run freely for a while to watch the LED. Indeed the red color appears to be about twice as long on as it is off.

在 LaunchPad 开发板上跑一下。先把所有断点清掉，自由运行一会儿观察 LED。确实，红色亮的时间大约是灭的两倍。

Next, set breakpoints at the calls to the delay() function to see how the parameter is passed to the function. As you can see, the BL instruction is now preceded by loading a constant value into R0. For the second call to delay() this constant is 0x7A120, which is 500 thousand decimal.

接下来在 `delay()` 调用处设断点，看看参数是怎么传进去的。可以看到，BL 指令前面多了一条把常量加载到 R0 的指令。第二次调用时这个常量是 0x7A120，也就是十进制的 500,000。

For the first call, the value loaded into R0 is the familiar 0xF4240, which is 1 million in decimal.

第一次调用时，加载到 R0 的值是我们熟悉的 0xF4240，十进制就是 1,000,000。

So, as you can see, in both cases the argument "iter" is passed in the R0 register.

所以，两种情况下参数 `iter` 都是通过 R0 寄存器传递的。

Let's now step into the delay function to see how it uses the iter argument. Indeed, as you can see, the argument "iter" is located in R0 and the counter is at the top of the stack, because its address is the same as the value of the SP register.

再单步进入 delay 函数，看看它怎么用这个 `iter` 参数。确实，参数 `iter` 在 R0 里，而 `counter` 在栈顶——因为它的地址和 SP 寄存器的值一样。

This concludes this first lesson about functions and the call stack. Functions are critically important, because when you design them properly, you can ignore HOW a job is done and you can focus only on WHAT is being done instead, which is a lot simpler.

关于函数和调用栈的第一课就到这里。函数非常重要——设计得当的话，你可以不用关心事情是怎么做的，只需关注做了什么，这就简单多了。

But we are not done with functions yet. In the next lesson, I will talk more about the stack and function calling other functions, including functions calling themselves recursively. You will also learn more about function arguments as well as the non-void return types. Finally, at the low level, I hope to get to presenting the ARM Procedure Call Standard.

不过函数的话题还没完。下一课我会继续讲栈，以及函数调用其他函数——包括函数**递归（recursion）**调用自身。还会介绍更多关于函数参数和非 void 返回类型的内容。最后在底层层面，希望能讲到 **ARM 过程调用标准（AAPCS，ARM Procedure Call Standard）**。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅保持关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文 / English | 中文 / Chinese | 说明 / Notes |
|---|---|---|
| Function | 函数 | 可重复使用的代码块 |
| Stack | 栈 | 后进先出的内存区域 |
| Call Stack | 调用栈 | 管理函数调用的栈结构 |
| Stack Pointer (SP) | 栈指针 (SP) | R13 寄存器，指向栈顶地址 |
| Program Counter (PC) | 程序计数器 (PC) | 保存当前执行指令的地址 |
| Link Register (LR) | 链接寄存器 (LR) | R14 寄存器，保存函数返回地址 |
| Signature | 签名 | 函数的返回类型、名称和参数列表 |
| Prototype | 原型 | 函数声明，编译器在定义前需要看到 |
| Argument / Parameter | 参数 | 传递给函数的值 |
| Local Variable | 局部变量 | 在函数内部定义的变量 |
| Return Address | 返回地址 | 函数完成后应返回的代码位置 |
| Leaf Function | 叶函数 | 不调用其他函数的函数 |
| BL (Branch with Link) | 带链接分支指令 | 调用函数并保存返回地址到 LR |
| BX (Branch and eXchange) | 分支并交换指令 | 根据寄存器值跳转，可切换指令集 |
| PUSH | 压栈 | 将寄存器值保存到栈上 |
| THUMB2 | THUMB2 指令集 | ARM Cortex-M 使用的指令集 |
| Inlining | 内联 | 编译器将函数体直接嵌入调用处 |
| DRY Principle | DRY 原则 | Don't Repeat Yourself，不要重复自己 |
| BusFault | 总线故障 | 访问无效地址时触发的异常 |
| Exception Handler | 异常处理程序 | 处理异常条件的特殊函数 |
| GPIO | 通用输入输出 | General Purpose Input/Output |
| IAR Toolset | IAR 工具集 | 嵌入式开发用的集成开发环境 |
| Context Switch | 上下文切换 | 在不同执行流之间切换 |
| Recursion | 递归 | 函数调用自身 |
| AAPCS (ARM Procedure Call Standard) | ARM 过程调用标准 | 定义函数调用约定的标准 |
| Breakpoint | 断点 | 暂停程序执行的调试功能 |
| Optimization | 优化 | 编译器对代码的性能改进 |
