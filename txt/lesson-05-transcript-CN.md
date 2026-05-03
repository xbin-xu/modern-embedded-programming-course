# 第5课：C预处理与volatile关键字 / Lesson 5: C Pre-Processor and the Volatile Keyword

Welcome to the Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll show you how to improve the "blinky" program by using the C pre-processor and the volatile keyword.

欢迎来到嵌入式系统编程课程。我是 Miro Samek。这节课我来教你如何用 **C预处理器**（C Pre-Processor）和 **volatile 关键字** 来改进 blinky 程序。

As usual, let's start with making a copy of the previous "lesson4" project and renaming it to "lesson5". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

跟以前一样，先把上节课的 lesson4 项目复制一份，改名为 lesson5。如果你刚加入这个课程，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson5" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

进入新的 lesson5 目录，双击工作区文件，打开 IAR 工具链。如果你还没装 IAR，回到第 0 课看看怎么安装。

So, this is the program you created in "lesson4". It works in that it manages to blink the RED led on the Stellaris Launchpad board, but it is certainly is not very readable, because it is full of cryptic numbers and there are no comments to explain what's going on.

这就是你在第 4 课写的程序。它能正常工作——Stellaris Launchpad 板子上的红色 LED 确实在闪。但可读性很差，到处都是让人看不懂的数字，也没有注释解释到底在干什么。

To improve the readability of the code, it would be very nice to use names for the registers instead of the cryptic numbers. One way you can achieve it, is by means of the C pre-processor, which lets you define any piece of code as a **macro**.

要提高代码的可读性，最好用有意义的名字来代替那些看不懂的数字。办法之一就是用 **C预处理器**——它可以让你把任意代码片段定义成**宏**（macro）。

For example, let's define a macro for the first register you write-to. Start a new line with the #-sign followed by the word "define", followed by the name of the macro. The data sheet calls the register Run-Mode Clock Gating Control Register for GPIO, so let's name the macro RCGC-GPIO.

举个例子，我们来给你写入的第一个寄存器定义一个宏。新起一行，以 # 号开头，接着写 `define`，再写宏的名字。数据手册上把这个寄存器叫做 GPIO 运行模式时钟门控寄存器（Run-Mode Clock Gating Control Register），所以我们就把宏命名为 RCGC_GPIO。

After the name you simply paste the piece of code this macro is going to replace.

名字写好之后，把宏要替换的那段代码粘贴上去就行了。

Once the macro is defined, you can use it instead of the original piece of code.

定义好之后，你就可以用这个宏来替代原来的代码片段了。

Press F7 to check if the compiler accepts your code so far.

按 F7 看看编译器目前能不能接受你的代码。

The C pre-processor is called that way, because it is conceptually a separate first step of simple text substitution before the real compilation. The pre-processor removes all lines starting with the #-sign, so the compiler does not see them at all. For example, you can define a macro to be anything, but as long as it is not used in the code, it doesn't matter and the code still compiles.

C预处理器之所以叫这个名字，是因为它在概念上是真正编译之前的一个独立的**文本替换**步骤。预处理器会把所有以 # 号开头的行删掉，所以编译器根本看不到它们。比如，你可以随便定义一个宏，只要代码里没用到它，就完全没影响，程序照常编译。

Also, the pre-processor replaces only the macros that are actually used in the code, so the compiler sees only the replacement sequences of characters and never the macro names themselves.

而且，预处理器只替换代码中实际用到的宏。所以编译器看到的只是替换后的字符序列，宏的名字它根本见不到。

This means that a macro does not need to be any complete element of the C language. For example, a macro FOO is just a piece of the pointer-cast expression, but as long as the text substituted for the macro makes sense in the specific context, the compiler will happily accept it, because really the compiler cannot tell the difference.

也就是说，宏不必是 C 语言的某个完整语法元素。比如 FOO 这个宏，它只是指针强制转换表达式的一部分。但只要宏替换后的文本在具体上下文中说得通，编译器就会接受——因为编译器根本分不出区别。

The corollary of all this is that you need to be careful how you define your macros, so that their meaning will not change unexpectedly depending on the context in which they are substituted. For example, to avoid surprises, it is always a good idea to enclose the macro like RCGC-GPIO in parentheses, so that it always means de-referencing of a pointer in any context it might be used.

由此带来的一个推论是：定义宏的时候要小心，避免宏的含义在不同上下文中意外改变。比如，为了不出问题，把 RCGC_GPIO 这样的宏用括号括起来是个好习惯——这样不管在什么上下文中使用，它都表示**指针解引用**（pointer dereferencing）。

It is also possible to define macros using other macros. For example, if you define the macro GPIOF_BASE as it is specified in the Data Sheet, you can use it in the definitions of other macros,

宏还可以用其他宏来定义。比如，你按数据手册定义好 GPIOF_BASE 这个宏，就可以在别的宏定义中引用它——

such as GPIOF_DIR for the pin direction register with the offset 0x400 from the base address,

GPIOF_DIR 是引脚方向寄存器，偏移量是 0x400；

GPIOF_DEN for digital enable with the offset 0x51C from the base address,

GPIOF_DEN 是**数字使能**（Digital Enable）寄存器，偏移量是 0x51C；

and GPIOF_DATA with the offset 0x3FC from the base address.

GPIOF_DATA 的偏移量是 0x3FC。

Finally, it is always highly recommended to add comments to your code. Comments are only for the benefit of humans, who read your code, and are completely ignored by the compiler. The C99 Standard supports two types of comments: the traditional C comment delimited by /* */, such as this one:

最后，强烈建议你养成写注释的习惯。注释是给人看的，编译器完全忽略它们。C99 标准支持两种注释方式：一种是传统的 C 注释，用 `/* */` 包围，比如这个：

and the C++-style comment starting with // and terminated by the end of line, such as these ones

另一种是 C++ 风格的注释，以 `//` 开头，到行末结束，比如这些：

Comments are allowed everywhere where you could legally place a space, and in fact, all comments are replaced with a single space before the compilation. Both types of comments can also be used in the macro definitions.

注释可以放在任何合法放空格的地方。实际上，编译之前所有注释都会被替换成一个空格。两种注释都可以用在宏定义里。

So, now it will be interesting to see if this code still blinks the LED. To actually see this, I'm going to use the Stellaris Launchpad board. But If you don't have the board, configure the Debugger for Simulator and follow along.

好，现在来看看改完的代码还能不能正常闪烁 LED。我用 Stellaris Launchpad 实物板来演示。如果你没有板子，把调试器配成模拟器（Simulator）也行，跟着操作就好。

Great, the LED blinks as before, so all your changes seem to work.

很好，LED 跟之前一样闪，说明你的改动没问题。

Let's examine in some detail how the compiler translated the GPIO_DATA macro and whether or not it introduced any overheads. After all, you might be concerned that now the CPU needs to add the base address to the offset at run time.

下面我们仔细看看编译器是怎么处理 GPIO_DATA 宏的，有没有引入额外的**开销**（overhead）。你可能担心：现在 CPU 是不是要在运行时去做基地址加偏移量的加法？

But when you step through the code, you can immediately see that the LDR.N instruction loads directly the full address 0x400253FC into R0 without performing any additions. In other words, the code is as efficient as before, because the compiler folds any constants computable at compile time and avoids unnecessary computations at run time.

但当你单步执行代码时，一眼就能看到：`LDR.N` 指令直接把完整地址 0x400253FC 加载到 R0 中，根本没做任何加法运算。换句话说，代码跟以前一样高效，因为编译器会在**编译时**（compile time）把能算的常量都算好，避免在**运行时**（run time）做多余的计算。

Finally, it is very interesting to see which single instruction actually turns the LED on. It turns out that this is the STR instruction. In other words, from the CPU point of view, talking to the outside world is fundamentally very simple and boils down to writing a specific value into a specific address.

还有一个很有意思的事：到底是哪条指令真正点亮了 LED？答案是 `STR` 指令。换句话说，从 CPU 的角度看，跟外部世界打交道其实非常简单——就是往特定地址写一个特定值，就这么回事。

OK, so your program still works and is as efficient as before. But I don't want to leave you with the impression that you have to define macros for all the registers yourself. In fact, typically you don't need to, because the microcontroller vendors, such as Texas Instruments in the case of the Stellaris board, already provide the macros for you in a separate file, which I've copied to the lesson5 directory.

好了，程序照常工作，效率也没变。但我不想给你留下一个印象——好像所有寄存器的宏都得你自己定义。实际上通常不需要，因为**微控制器厂商**会替你准备好。比如 Stellaris 板子的厂商德州仪器（TI）就提供了一个现成的文件，我已经把它复制到 lesson5 目录里了。

You can add this file to the project by right-clicking on the project and choosing the Add->Add Files menu option. The file name is "lm4f120h5qr.h", which corresponds exactly to the microcontroller type on your Stellaris Launchpad board. The file extension ".h" means that it is a **header file**, specifically designed for inclusion into ".c" files, such as main.c.

右键点击项目，选 Add -> Add Files，就能把这个文件加到项目里。文件名叫 `lm4f120h5qr.h`，跟你 Stellaris Launchpad 板子上的微控制器型号完全对应。`.h` 扩展名表示这是一个**头文件**（header file），专门用来被 `.c` 文件（比如 main.c）包含的。

When you open the header file, you can see that it contains a whole bunch of macros very similar to what you have defined yourself. However, the pointer casts used in the header file are significantly different, which requires some explanation.

打开这个头文件，你会看到里面有一大堆宏，跟你之前自己定义的很像。不过，头文件里用的指针强制转换跟你的写法有明显不同，这需要解释一下。

Let me grab one macro from the header file and copy it to the main.c file for comparison. The first discrepancy is the pointer type. The macros in main.c use "unsigned int", while the header file "unsigned long". I will discuss data types in a separate lesson, but for now let me only say that on a 32-bit machine, like the ARM processor, the int-type is 32-bit wide, so is the long-type. So, "unsigned int" and "unsigned long" are equivalent.

我从头文件里拿一个宏，复制到 main.c 中对比一下。第一个不一样的地方是指针类型：main.c 里用的是 `unsigned int`，头文件里用的是 `unsigned long`。数据类型我会在专门的课程中讲，现在只需知道一点——在 ARM 这种 32 位处理器上，`int` 是 32 位的，`long` 也是 32 位的，所以 `unsigned int` 和 `unsigned long` 完全等价。

So, the real difference is the "volatile" qualifier. It informs the compiler that the object pointed-to by the pointer might change spontaneously.

所以，真正的区别在于 `volatile` 限定符。它告诉编译器：这个指针所指向的对象，可能会"自发地"发生变化。

When you declare an object to be "volatile", you are telling the compiler that the object might change even though no statements in the program appear to change it. For example, two bits in the GPIOF register on the Launchpad board are connected to the user switches. These bits can be changed when the user presses or releases the switches, which is obviously not caused by any program instruction. Therefore, the GPIOF register, and in fact most other I/O registers, are volatile.

当你把一个对象声明为 `volatile`，就是在告诉编译器：这个对象的值可能会变，即使程序中没有任何语句看上去在修改它。举个例子，Launchpad 板子上 GPIOF 寄存器中有两位是接了用户按键开关的。用户按下或松开开关时，这两位就会改变——显然不是任何程序指令造成的。所以 GPIOF 寄存器，事实上大多数 **I/O 寄存器**（I/O register）都是 volatile 的。

This is important, because the compiler can optimize access to non-volatile objects by reading an object's value into a CPU register, working with that register for a while, and eventually writing the value in the register back to the object.

这很重要。因为对于非 volatile 的对象，编译器可以做**优化**（optimization）：把值读进 CPU 寄存器，在寄存器里操作一阵子，最后再写回内存。

The compiler is NOT permitted to do this sort of optimization with "volatile" objects. Every time the source program says to read-from or to write-to a "volatile" object, the compiler has to do so.

但对于 volatile 对象，编译器**不允许**这样做。源代码每要求一次读或写 volatile 对象，编译器就必须老老实实生成对应的内存访问指令。

So clearly, the "volatile" qualifier is useful for I/O registers such as GPIOF. But it can also be very useful for "normal" variables to prevent optimizations that the compiler otherwise might do.

显然，volatile 对 GPIOF 这种 I/O 寄存器很有用。但它对"普通"变量也一样有用——可以防止编译器做不该做的优化。

For example, the "counter" variable is used only in the two delay loops. But if you look at these loops from the compiler's perspective, they make no contribution whatsoever to the computation, because the final value of the "counter" is either overwritten or discarded.

举个例子，`counter` 变量只在两个延时循环里用。但从编译器的角度看，这两个循环对计算没有任何贡献——因为 `counter` 的最终值要么被覆盖，要么被丢弃，根本没用到。

In this case, the compiler is permitted to optimize both delay loops "away".

这种情况下，编译器完全可以把两个延时循环给"优化掉"。

You can actually see this quite easily by allowing a higher-level of optimization as follows.

你可以很容易地验证这一点——把优化级别调高就行，操作如下。

Click on the Project options, choose "C/C++ Compiler" section and click on the "Optimizations" tab. Select "High" optimization level and click OK.

点击 Project 选项，选 C/C++ Compiler 部分，切到 Optimizations 标签页，选"High"**优化级别**（optimization level），点 OK。

Recompile and run the program on the Launchpad board.

重新编译，在 Launchpad 板子上运行。

As you can see, the LED lights up and stays on, all the time...

看到了吧，LED 亮了就不再灭了，一直亮着……

When you single-step through the code, you can see that the instructions for turning the LED on and off are still there, but the delay loops between them are gone.

单步执行代码就能看到：开关 LED 的指令还在，但中间的延时循环已经消失了。

But now, that you know about the "volatile" keyword, you know how to prevent the compiler from optimizing the delay loops away.

现在你知道了 volatile 关键字，也就知道怎么防止编译器把延时循环优化掉了。

You need to make the "counter" variable "volatile".

把 `counter` 变量声明为 `volatile` 就行。

By the way, the "volatile" keyword can be placed either before the type, like in the macro from the header file, or after the type. I recommend placing it after the type.

顺便说一下，`volatile` 关键字既可以放在类型前面（像头文件里的宏那样），也可以放在类型后面。我建议放在类型后面。

Let's quickly test whether the "volatile" counter indeed fixed the problem.

快速测试一下，加了 volatile 的 counter 是不是确实解决了问题。

Yes, the LED blinks...

是的，LED 又开始闪了……

You can also see the delay loop when you single-step through the code.

单步执行时，延时循环也回来了。

So now, let's make use of the .h header file by actually including it into the main program. Again, you use the pre-processor for this.

好了，现在来正式使用这个头文件——把它包含到主程序里。又是用预处理器来完成。

To include a file, you start a new line with the #-sign, followed by the word "include" followed by the name of the file in double quotes.

包含文件的方法：新起一行，以 # 号开头，接着写 `include`，再写用双引号括起来的文件名。

Let's put the header file side-by-side with the main program to replace all the macros you've defined so far with the macros from the header file.

把头文件和主程序并排对比，用头文件里的宏替换掉你之前自己定义的所有宏。

The header file provided by the microcontroller vendor uses the register names from the Datasheet, so you should have no trouble to recognize the interesting registers, such as:

厂商提供的头文件里用的就是数据手册上的寄存器名称，所以你应该很容易认出那些常用的寄存器，比如：

GPIO_PORTF_DATA

GPIO_PORTF_DIR

and GPIO_PORTF_DEN

If you have any doubts about the correct name of the register, you can always check its address to make sure that this is what you want.

如果不确定寄存器的名字对不对，随时可以检查它的地址来确认。

After replacing all the macros, you can remove your own definitions and recompile the code.

全部替换完之后，删掉你自己写的那些宏定义，重新编译。

Let's test the code one last time to check if the LED will still blink...

最后再测试一次，看看 LED 还能不能正常闪烁……

This concludes this lesson about the C pre-processor and the "volatile" keyword. From now on, you are able to write programs that will run correctly at any level of optimization. So congratulations!

关于 C预处理器和 volatile 关键字这节课就到这里。从现在开始，你写的程序在任何优化级别下都能正确运行了。恭喜！

In the next lesson you will learn how to use the bit-wise OR and AND operators to blink other colors of the composite LED and you will also learn about the more advanced features of the GPIO register.

下一课你会学到如何用**按位 OR 和 AND 运算符**来让复合 LED 闪出其他颜色，还会了解 GPIO 寄存器的更多高级功能。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文 | 中文 | 说明 |
|------|------|------|
| C Pre-Processor | C预处理器 | 编译前的文本替换阶段 |
| macro | 宏 | 通过 #define 定义的代码替换规则 |
| volatile | volatile 限定符 | 告诉编译器对象可能自发改变的限定符 |
| header file | 头文件 | .h 扩展名的文件，包含宏定义和声明 |
| register | 寄存器 | 硬件中的存储位置 |
| I/O register | I/O 寄存器 | 用于输入/输出操作的硬件寄存器 |
| Run-Mode Clock Gating Control | 运行模式时钟门控控制 | 控制外设时钟使能的寄存器 |
| Digital Enable (DEN) | 数字使能 | 启用引脚数字功能的寄存器 |
| optimization level | 优化级别 | 编译器优化代码的程度 |
| compile time | 编译时 | 程序被编译的阶段 |
| run time | 运行时 | 程序实际执行的阶段 |
| overhead | 开销 | 额外的计算或资源消耗 |
| pointer dereferencing | 指针解引用 | 通过指针访问其指向的值 |
| delay loop | 延时循环 | 通过循环计数实现的延时 |
| Simulator | 模拟器 | 软件模拟硬件执行的环境 |
| Datasheet | 数据手册 | 芯片的技术参考文档 |
| microcontroller vendor | 微控制器厂商 | 制造微控制器的公司 |
| comment | 注释 | 代码中供人阅读的说明文字 |
