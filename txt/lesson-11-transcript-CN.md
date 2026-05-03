# 第11课：定宽整数类型、字节序与混合数据类型 / Lesson 11: Fixed-Width Integer Types, Endianness, and Mixing Data Types

Welcome to the Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll talk about the fixed-width integer types stdint.h, endianness, mixing data types in expressions and a little about the floating point data types. For those of you, who watch this video in preparation for a job interview in embedded programming, this lesson will provide answers to some tricky questions.

欢迎来到嵌入式系统编程课程。我是 Miro Samek，今天这节课我们聊聊 **定宽整数类型**（fixed-width integer types）和 `stdint.h`，还有 **字节序**（endianness）、表达式中混用不同数据类型的问题，顺便也提一下浮点类型。如果你正在用这套视频准备嵌入式编程的面试，这节课会帮你解答一些容易踩坑的面试题。

As usual, let's get started with making a copy of the previous "lesson10" project and renaming it to "lesson11". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

跟之前一样，先把上一课的"lesson10"项目复制一份，改名为"lesson11"。如果你刚开始跟这套课程，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson11" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

进入新的"lesson11"目录，双击工作区文件打开 IAR 工具集。如果你还没装 IAR，先回到第 0 课看一下。

So far in this course, you have been only using the C built-in integer types, such as 'int' or 'unsigned'. The problem with these built-in types is that the C Standard does not actually prescribe their size. For example, 'int' or 'unsigned' can be 32-bit wide on a 32-bit machine, such as ARM, but they can be only 16-bit wide on a 16-bit or 8-bit machines, such as MSP430 or AVR.

到目前为止，课程里用的都是 C 语言的**内置整数类型**（built-in integer types），比如 `int` 或 `unsigned`。这些内置类型有个问题：C 标准并没有规定它们到底占多少位。比如 `int` 和 `unsigned`，在 ARM 这种 32 位机器上是 32 位的，但在 MSP430 或 AVR 这种 16 位、8 位机器上可能只有 16 位。

Beyond 'int' and 'unsigned', the C language offers also 'short' and 'unsigned short', 'long' and 'unsigned long', as well as 'char' and 'unsigned char' built-in data types. But, here again the C standard prescribes only that the size of 'short' must not be bigger than int and int must be not bigger than long. The plain 'char' data type is typically one byte, but it can be either signed or unsigned, depending on the compiler options.

除了 `int` 和 `unsigned`，C 语言还有 `short`/`unsigned short`、`long`/`unsigned long`，以及 `char`/`unsigned char` 这些内置类型。但 C 标准也只是说 `short` 不能比 `int` 大、`int` 不能比 `long` 大，仅此而已。普通的 `char` 通常是一个字节，但它到底是有符号还是无符号，取决于编译器选项。

All these ambiguities are actually intentional in the original C standard to give the compiler vendors more flexibility, but in embedded work it is often imperative to know exactly the size, signedness, and dynamic range of your variables, so that your code runs the same way, regardless of the target processor.

这些模糊性其实是早期 C 标准有意为之的——为了给编译器厂商更多灵活性。但在嵌入式开发中，你往往必须精确知道变量的**大小**（size）、**符号性**（signedness）和**动态范围**（dynamic range），这样不管目标处理器是什么，代码的行为都是一致的。

This is obviously not a new problem and solutions have been around for decades. The approach generally taken is to define a new data type for each fixed-width integer you plan to use in your programs. For example, the popular MicroC/OS-II Real-Time Operating System uses the typedef statements to define the fixed width integer types as follows:

这显然不是什么新问题，几十年前就有解决方案了。常见的做法是：为你打算在程序中使用的每一种定宽整数单独定义一个新类型。比如，流行的 MicroC/OS-II **实时操作系统**（RTOS）就是用 `typedef` 来定义定宽整数类型的，像这样：

Each typedef statement defines a new type and, as most definitions in C, should be read backwards.

每条 `typedef` 语句都定义了一个新类型，跟 C 里大多数定义一样，要**从后往前读**。

For example, the new type CPU_INT32U, is defined as the unsigned int built-in type.

比如，新类型 `CPU_INT32U` 被定义成 `unsigned int` 这个内置类型。

Once you typedef a new type name, you can use it in the same way as a built-in type to define your own variables, such as x, y, and z defined here.

一旦用 `typedef` 定义了新的类型名，你就可以像使用内置类型一样去声明变量，比如这里的 x、y、z。

Of course, in a real project, you would put all these typedef statements in a header file with the .h extension, and then include this header file in all your .c files.

当然，在实际项目中，你会把这些 `typedef` 统一放到一个 `.h` **头文件**（header file）里，然后在所有 `.c` 文件中 `include` 它。

However, please note that such a hand-made header file cannot be universal for two reasons. First, it uses some made-up names, which aren't standardized in the same sense as the built-in types are. And second, the definitions are correct only for a specific processor and a specific compiler. For example, the type CPU_INT32U is defined in terms of the 'int' type, which can have different size on different processors.

但要注意，这种手工写的头文件没法通用，原因有两个。第一，类型名是自己起的，没有像内置类型那样被标准化。第二，这些定义只对特定的处理器和编译器才正确。比如 `CPU_INT32U` 是基于 `int` 定义的，而 `int` 在不同处理器上大小可能不同。

It sure would have been nice if the authors of the C standard had defined some standard names and made compiler vendors responsible for providing the appropriate typedefs in a standard library header file.

要是 C 标准的作者能直接定义好标准名称，然后让编译器厂商负责在标准库头文件里提供对应的 `typedef`，那就太好了。

Interestingly, this is exactly what finally happened in the C99 ISO Standard, which provides the standard header file 'stdint.h'. For an embedded programmer, the 'stdint.h' header file is one of the most valuable features of the C99 Standard.

有趣的是，**C99 标准**（C99 ISO Standard）最终就是这么做的——它提供了标准头文件 `stdint.h`。对嵌入式程序员来说，`stdint.h` 可以说是 C99 标准里最有价值的东西之一。

The IAR compiler supports the C99 Standard, if you select it in the project options.

IAR 编译器是支持 C99 的，只要你在项目选项里选上就行。

You can actually look inside the stdint.h file, because it is inside the IAR toolset on your disk.

你甚至可以打开 `stdint.h` 看看里面的内容，这个文件就在你磁盘上的 IAR 工具集目录里。

As you can see, the file uses typedefs to define the following fixed-width integer types:

可以看到，文件里用 `typedef` 定义了这些定宽整数类型：

```c
int8_t:   // for signed 8-bit integer  有符号8位整数
uint8_t:  // for unsigned 8-bit integer  无符号8位整数

int16_t:  // for signed 16-bit integer  有符号16位整数
uint16_t: // for unsigned 16-bit integer  无符号16位整数

int32_t:  // for signed 32-bit integer  有符号32位整数
uint32_t: // for unsigned 32-bit integer  无符号32位整数
```

The file defines more types, but these six are the most important.

文件还定义了更多类型，但这六个是最常用的。

The value of the stdint header file is in standardizing the type names and the fact that it is now the responsibility of the compiler vendor to provide the right definitions for your CPU. The compilers do it frequently by means of macros, such as __INT32_T_TYPE__, which in turn are defined in terms of the built-in types.

`stdint` 头文件的价值在于两点：一是统一了类型名称，二是把提供正确定义的责任交给了编译器厂商。编译器通常通过**宏**（macro）来实现这一点，比如 `__INT32_T_TYPE__`，而这些宏最终又基于内置类型来定义。

Obviously, with the ISO standard in place, inventing your own integer type names is counter-productive. Even if your compiler is not C99 compliant, you should provide the stdint.h header file with the standard names. For example, the Microsoft Visual C++ compiler is not C99 compliant, so if you wish to use it for developing embedded code on the PC, you can still do it by providing your own stdint.h header file.

有了 ISO 标准，再自己发明一套整数类型名就是费力不讨好了。即使你的编译器不完全兼容 C99，你也应该提供一份带标准名称的 `stdint.h`。比如微软的 Visual C++ 编译器就不兼容 C99，如果你想在 PC 上用它开发嵌入式代码，自己提供一个 `stdint.h` 就行。

So, now, let's use the standard fixed-width integer types to take a bit closer look at how the ARM Cortex-M processor will handle them.

好，现在我们就用标准的定宽整数类型，仔细看看 ARM Cortex-M 处理器是怎么处理它们的。

Here I define a few variables of each fixed-width type, whereas I name the variables so that the type is reflected in the name.

这里我为每种定宽类型各定义了几个变量，变量名本身就体现了类型信息。

The unsigned variables start with 'u' and signed variables start with 's'.

无符号变量以 `u` 开头，有符号变量以 `s` 开头。

First, let's check that the fixed-width integers have really the expected size.

首先来验证一下，这些定宽整数是不是真的占了预期的位数。

The C language provides the sizeof() operator that returns the size in bytes either of a variable, such as u8a,

C 语言提供了 `sizeof()` **运算符**，可以返回一个变量（比如 `u8a`）占多少字节，

or the data type, such as uint16_t or uint32_t.

也可以返回一个数据类型（比如 `uint16_t` 或 `uint32_t`）占多少字节。

Let's build the code by pressing F7 to make sure that the compiler likes it so far.

按 F7 构建一下代码，确保编译器到目前为止没有报错。

While you can run the code on the LaunchPad board, I will today use the simulator so that anybody without the board can follow along as well.

代码可以在 LaunchPad 板子上跑，不过今天我用**仿真器**（simulator），这样没有开发板的同学也能跟着做。

So let's start debugging in the simulator.

好，就在仿真器里开始调试吧。

Open the watch1 view and type the names of the variables you want to watch.

打开 watch1 窗口，把想观察的变量名输进去。

At this point, some variables that you have defined are not available, because they are not yet used anywhere in the code and the compiler has eliminated them.

这时候你会发现，有些定义了的变量看不到——因为代码里还没用到它们，编译器已经把她们优化掉了。

When you step through the code, you can see that the reported sizeof(u8a) is 1 byte,

单步执行代码，可以看到 `sizeof(u8a)` 报告为 1 个字节，

the size of the uint16_t type is 2 bytes,

`uint16_t` 类型是 2 个字节，

and the sizeof the uint32_t type is 4 bytes, as expected.

`uint32_t` 类型是 4 个字节，跟预期一致。

I'd also like to point your attention to the addresses of your variables, because their order in memory is different than the order in which you have defined them in the code.

我还想提醒你注意变量的**地址**（address）——它们在内存中的排列顺序，跟你代码里定义的顺序并不一样。

The compiler allocated the 4-byte variable u32e at a lower address than the 2-byte variable u16c,

编译器把 4 字节的 `u32e` 放在了比 2 字节的 `u16c` 更低的地址上，

and left the 1-byte variable u8a at the end.

而 1 字节的 `u8a` 被放到了最后面。

The point to remember here is that the compiler can and will change the order of your definitions, so you should never assume that the order will be preserved.

这里要记住的是：编译器可以、也确实会调整你定义的顺序，所以千万别假设定义顺序会被保留。

Next, let's initialize the variables to hex constants, but in such a way that you can distinguish each byte.

接下来，我们用**十六进制常量**来初始化变量，而且每个字节用不同的值，方便区分。

For example, the first byte of u16c is hex-c1 and the second is hex-c2.

比如 `u16c` 的第一个字节是 c1，第二个字节是 c2。

Also, let's use some assignment statements to see how the CPU reads the values of one variable and writes it to another variable.

再用一些赋值语句来观察 CPU 怎样从一个变量读值、再写到另一个变量。

Before you start debugging, please prepare the memory view to show the raw bytes, as they are naturally ordered in memory. For this you need to set the address of beginning of RAM

开始调试之前，先把**内存视图**准备好，显示原始字节的自然排列。为此你需要设置 RAM 的起始地址，

and select the "1-times units" view.

然后选择"1-times units"视图。

Now, take a look at the disassembly view as you single-step through the code.

现在一边单步执行，一边看**反汇编视图**（disassembly view）。

Notice that the processor uses the LDRB instruction to load the byte-wide variable u8a into R1 and the STRB instruction to store R1 into the 1-byte variable u8b.

注意，处理器用的是 LDRB 指令把字节变量 `u8a` 加载到 R1，用 STRB 指令把 R1 存到字节变量 `u8b`。

Similarly, the instruction LDRH is used to load u16b into R1 and STRH to store it into u16d.

类似地，LDRH 指令把 `u16b` 加载到 R1，STRH 指令把它存到 `u16d`。

And finally, the instruction LDR is used to load u32e into R1 and STR to store it into u32f.

最后，LDR 指令把 `u32e` 加载到 R1，STR 指令把它存到 `u32f`。

The interesting point to remember here is that the ARM processor has special instructions LDRB and STRB to read and write bytes, LDRH and STRH to read and write half-words, and plain LDR and STR to read and write whole words into memory.

这里值得记住的是：ARM 处理器有专门的指令来处理不同宽度的数据——LDRB/STRB 读写**字节**，LDRH/STRH 读写**半字**，而普通的 LDR/STR 读写**字**。

Now, let's take a closer look in the memory view. The interesting thing here is that the order of bytes in the multi-byte variables, such u32e, is reversed compared to the order of these bytes in the register R1.

现在仔细看看内存视图。有意思的地方来了：多字节变量（比如 `u32e`）在内存中字节的排列顺序，跟寄存器 R1 中的顺序正好是反的。

This is because ARM is a so called little-endian machine, or strictly speaking the ARM core has configurable endianness, but virtually all silicon vendors, such as Texas Instruments, choose the little-endian configuration.

这是因为 ARM 是所谓的**小端模式**（little-endian）机器。严格来说 ARM 内核的字节序是可配置的，但几乎所有芯片厂商（比如德州仪器）都选择了小端模式。

**Little-endian** means that lower-order bytes from a register are placed at lower-addresses than higher-order bytes.

**小端模式**的意思是：寄存器中低位字节存放在低地址，高位字节存放在高地址。

For example, the least-significant byte e4 from the R1 register has been stored by the last STR instruction at a lower address than the e3, e2, and e1 bytes.

比如，R1 寄存器中的**最低有效字节** e4，被 STR 指令存储在了最低的地址上，e3、e2、e1 依次放在更高的地址。

I don't have a big-endian machine to show you the difference, but I can manually change the order of bytes to big-endian in the memory, so that you can see how it would look like on a big-endian processor. An example of such a big-endian processor is PowerPC used in the Mac computers before they switched to x86.

我没有**大端模式**（big-endian）的机器来给你看区别，但我可以在内存里手动把字节序改成大端，让你看看大端处理器上是什么样子。大端处理器的一个例子是 Mac 切换到 x86 之前用的 PowerPC。

Once you start using the various integer data types, you will inevitably encounter situations when you will have to mix them in expressions and assignments. This will require conversions from one type to another and the good news is that the C language does it automatically through implicit conversions.

当你开始使用各种整数类型之后，迟早会遇到在表达式和赋值中混用它们的情况。这需要进行类型转换，好消息是 C 语言会通过**隐式转换**（implicit conversion）自动帮你搞定。

The bad news is that the rules for the implicit conversions are rather complicated, counter-intuitive, and often lead to developer confusion.

坏消息是，隐式转换的规则相当复杂，跟直觉对着干，经常让开发者掉坑里。

I can't possibly cover all the nuances of type conversions in C, but I will explain a couple of the most important principles. I'd like you to remember that this is perhaps the most tricky part of the C language, and often leads to subtle bugs.

C 语言类型转换的细节太多，我没法全部讲到，但我会挑几个最重要的原则来讲。记住，这可能是 C 语言中最容易出问题的地方，经常导致隐蔽的 bug。

In the first example, I want to illustrate that C always automatically promotes any smaller-size integers to the built-in 'int' or 'unsigned int' type before performing any computations.

第一个例子想说明的是：C 语言在执行任何运算之前，会自动把比 `int` 小的整数**提升**为 `int` 或 `unsigned int`。这叫**整数提升**（integer promotion）。

Consider the following expression:

来看这个表达式：

When you run this example

运行这段代码，

you can see that the result is 70000, which obviously is 40000 + 30000. Nothing surprising here.

可以看到结果是 70000，显然就是 40000 加 30000，没什么好奇怪的。

But this is because you have executed this code on an ARM processor, which is a 32-bit machine.

但这是因为你是在 ARM 处理器上跑的，而 ARM 是 32 位机器。

In order to see a problem, you need to execute the code on a machine, where the standard 'int' data type is only 16-bit wide, such as MSP430.

要看到问题，你得在一个 `int` 只有 16 位宽的机器上跑这段代码，比如 MSP430。

In fact, I have here the MSP-EXP430G2 LaunchPad board, which is quite similar to the Tiva LaunchPad, except it has the MSP430 microcontroller instead of the ARM Cortex-M.

正好我手边有一块 MSP-EXP430G2 LaunchPad 开发板，跟 Tiva LaunchPad 长得很像，只是上面用的是 MSP430 **微控制器**，不是 ARM Cortex-M。

I have also prepared a blinky program version for the MSP430 LaunchPad, that I would like to demonstrate first.

我为 MSP430 LaunchPad 准备了一个 blinky 程序，先演示一下。

Since MSP430 is entirely different than the ARM, I am using here a version of the IAR toolset for MSP430.

MSP430 跟 ARM 完全不同，所以这里用的是针对 MSP430 的 IAR 工具集版本。

In fact, I have the IAR toolset for ARM still open on my screen in the background.

其实我屏幕后台还开着 ARM 版的 IAR 工具集。

So, let me show you how the blinky code executes on the MSP430 LaunchPad.

好，来看看 blinky 在 MSP430 LaunchPad 上怎么跑。

Before I let the program run free, I first step through the code to demonstrate that the LED on the MSP430 board is turned on and off from the code.

让程序跑起来之前，我先单步走一下，演示 LED 是通过代码控制亮灭的。

OK, so now I will just copy and paste the example code from the IAR for ARM to IAR for MSP430.

好，现在把示例代码从 ARM 版 IAR 复制粘贴到 MSP430 版 IAR。

I need to type again the names of the variables into the watch1 view.

需要再往 watch1 窗口里输入一遍变量名。

And finally, I can step through the code and see how the expression is evaluated.

好了，单步执行代码，看看表达式是怎么求值的。

Oops, as you can see the result is 4464, instead of the expected 70000. Now, I don't think that you've expected this, did you?

哎，结果居然是 4464，不是预期的 70000。我想你应该没料到吧？

To understand what has just happened, you need to go back to my original statement. I said that C always automatically promotes any smaller-size integers to the built-in type 'int' or 'unsigned int' before performing any computations.

要搞明白刚才发生了什么，得回到我一开始说的那句话：C 语言在执行任何运算之前，会自动把比 `int` 小的整数提升为 `int` 或 `unsigned int`。

On the 32-bit ARM machine, the promotion was to 32-bits, because this is the size of 'int' on the ARM.

在 32 位的 ARM 上，提升到了 32 位，因为 ARM 上 `int` 就是 32 位的。

However, on MSP430, there was no real promotion, because the type 'int' is only 16-bit wide on MSP430. So, the computation happened in 16-bits, which overflowed. So, the result 4464 that you saw is just the truncated value to 16-bits. Please check this with your calculator.

但在 MSP430 上，根本就没有真正的提升，因为 MSP430 上的 `int` 只有 16 位。所以运算是按 16 位做的，发生了**溢出**（overflow）。你看到的 4464 就是截断到 16 位后的值。你可以拿计算器验证一下。

The tricky aspect of this example is that the result of the computation is eventually assigned to a 32-bit wide number, which has enough dynamic range to represent 70000. This is something that throws many developers off.

这个例子 tricky 的地方在于，计算结果最终赋给了一个 32 位的变量，而 32 位完全装得下 70000。正是这一点让很多开发者上当。

But I hope that this example will help you remember that the precision in which the computation is performed does *not* depend on the left-hand side of the assignment.

希望这个例子能帮你记住一个关键点：运算的精度 *不* 取决于赋值号左边那个变量的类型。

So, knowing this, how would you fix the problem?

知道了这一点，该怎么修复呢？

Well, you need to enforce promotion to a 32-bit precision of at least one of the operands. That way, the other implicit conversion rule of the C language will apply, which is that the computation is performed at the largest precision of the involved operands. Specifically, if one of the operands is 32-bit wide, the other will be promoted to 32-bits and the whole computation will be performed at 32-bits.

你需要强制把至少一个**操作数**（operand）提升到 32 位精度。这样一来，C 语言的另一条隐式转换规则就会生效：**运算以参与操作数中的最大精度来执行**。也就是说，如果其中一个操作数是 32 位的，另一个也会被提升到 32 位，整个运算就按 32 位来做。

So, the solution is to explicitly cast one, or both of the operands to uint32_t, as follows.

所以解决方案是：把一个或两个操作数**显式转换**为 `uint32_t`，像这样。

As I step through this code on the MSP430 LaunchPad, please watch the values of the operands and the result u32e. I specifically single-step through the disassembly to show you the additional work the 16-bit MSP430 CPU needs to do to promote both arguments to 32-bits. In particular, note the familiar partial value 4464, which is subsequently extended to 32-bits.

我在 MSP430 LaunchPad 上单步执行这段代码，请注意观察操作数和结果 `u32e` 的值。我特意在反汇编里一步步走，让你看看 16 位 MSP430 CPU 为了把两个参数提升到 32 位需要做多少额外工作。特别留意一下你之前看到的中间值 4464，它随后被**扩展**到了 32 位。

In the end, the final result is 70,000, as expected.

最终结果 70000，符合预期。

So, this final version is the truly portable code. You should copy and paste it to the IAR for ARM, because the version left there is not portable. Of course, on a 32-bit machine, the explicit cast to uint32_t will not cost any additional CPU cycles.

所以这个最终版本才是真正的**可移植代码**（portable code）。你应该把它复制粘贴回 ARM 版 IAR，因为留在那边的那版不可移植。当然，在 32 位机器上，显式转换成 `uint32_t` 不会多花任何 CPU 周期。

Just to confirm, I run the code and verify the disassembly is the identical as before and the result is 70,000.

确认一下，运行代码后反汇编跟之前完全一样，结果也是 70000。

In the next example, I would like to show you problems that can arise with changing the signedness of an arithmetic operation. Consider the following expression:

下一个例子，我想给你看看算术运算中符号性发生变化时会出什么问题。看这个表达式：

Here I mix signed 10 with unsigned u16c. The expected result of this computation is 10 minus 100 equals -90, which is stored in the signed s32 variable.

这里我把有符号的 10 和无符号的 `u16c` 混在一起了。预期结果应该是 10 减 100 等于 -90，存到有符号变量 `s32` 里。

When you run this code on ARM, the result is indeed -90.

在 ARM 上跑，结果确实是 -90。

However, when you copy this code to MSP430, and run it on the MSP430 LaunchPad, you get a different result.

但把代码复制到 MSP430 LaunchPad 上跑，结果就不一样了。

The value in s32 in this case is 65446.

这种情况下 `s32` 的值是 65446。

The implicit conversion rule that applies in this case is that when you mix a signed and unsigned operands, both are promoted to 'unsigned int' and the result is 'unsigned int'. Subsequently, the result is converted to signed 32-bit, because this is the type of the s32 variable on the left-hand side of the assignment.

这里适用的隐式转换规则是：当你混用有符号和无符号操作数时，两者都被提升为 `unsigned int`，结果也是 `unsigned int`。之后，结果再转换成有符号 32 位——因为赋值号左边的 `s32` 是这个类型。

When this expression is evaluated on the 32-bit ARM, the 'unsigned int' value is 32-bit wide, so it fills completely the s32 variable and the value is re-interpreted in the 2s-complement representation as negative. If you don't remember the 2s-complement representation of negative numbers, please go back to lesson 1.

在 32 位 ARM 上求值时，`unsigned int` 是 32 位的，刚好填满 `s32` 变量，然后用**二进制补码**（2's complement）来解释，就是负数了。如果你忘了负数的补码表示，回顾一下第 1 课。

However, when the same expression is evaluated on the 16-bit MSP430, the 'unsigned int' is only 16-bit wide and fills up only the lower half of the s32 variable. Because the value is unsigned, it is not sign-extended to 32-bits, and is interpreted as a big positive number.

但在 16 位 MSP430 上，`unsigned int` 只有 16 位，只填了 `s32` 的低半部分。因为这个值是无符号的，不会做**符号扩展**（sign extension）到 32 位，于是就被解释成了一个很大的正数。

The best way to avoid such non-portable code is to avoid mixing signed and unsigned. Instead, you should explicitly cast the unsigned variable to a signed type.

避免这种不可移植代码的最好办法就是：别混用有符号和无符号。你应该显式地把无符号变量转换成有符号类型。

Note also that in this case the problem was not with insufficient number of bits, so you can cast to the signed int16_t type, because it is sufficient.

另外注意，这里的问题不是位数不够，所以你转成有符号的 `int16_t` 就够了。

When you run the corrected code on MSP430, you can see that the value in s32 is sign-extended, so it is -90, as expected.

在 MSP430 上运行修正后的代码，可以看到 `s32` 的值被符号扩展了，结果是 -90，跟预期一致。

The problem of mixing signed and unsigned integers arises often in comparisons. Consider the following if statement:

有符号和无符号混用的问题在**比较**操作中也很常见。看这个 if 语句：

When you compile this code, you get a warning that you have a pointless integer comparison. When you think about it, it seems to make sense, because the smallest value an unsigned number can hold is zero, which is always bigger than -1.

编译时你会收到一个警告，说这个整数比较没有意义。仔细想想好像也说得通——无符号数最小就是 0，0 总是大于 -1 嘛。

But wait a minute, the warning says that the comparison is always false, which is exactly the opposite what you would think.

等等，警告说比较结果总是**假**——这跟你认为的正好相反。

But this is apparently exactly what the compiler thinks, because you cannot even set a breakpoint in the if branch, only in the else branch. Indeed, when you run the code, you hit the breakpoint in the else branch.

但这确实就是编译器的逻辑，因为你甚至没法在 if 分支里设**断点**（breakpoint），只能在 else 分支设。而且运行时确实走到了 else 分支。

So how can that be? Well, this makes sense only when you recall that in the mixed signed-unsigned expressions, the C standard promotes the signed operand to 'unsigned int'. The -1 value promoted to 'unsigned int' is 0xFFFFFFFF, which is the largest value a 32-bit unsigned integer can hold. That's why the comparison is always false.

这怎么可能？只有回忆起那条规则才能说通：在混合有符号-无符号的表达式中，C 标准会把有符号操作数提升为 `unsigned int`。-1 被提升为 `unsigned int` 后就变成了 0xFFFFFFFF——32 位无符号整数能表示的最大值。所以比较当然总是假了。

Again, you can fix the problem by an explicit cast from unsigned to signed.

同样，显式地把无符号转成有符号就能修复这个问题。

The last frequent confusion I'd like to discuss is with binary operations on small integers. Consider the following comparison:

最后再讲一个常见的坑：小整数的位运算。看这个比较：

You compare here a bit-wise 1s-complement of a byte with zero. Something like this could come up, for example, when your byte represents a checksum over some data and you want to make sure that the checksum adds up.

你在这里把一个字节的**按位取反**（bitwise 1's complement）结果跟 0 比较。这种情况很常见，比如一个字节代表某些数据的**校验和**（checksum），你想确认校验和是否正确。

At first glance, with value 0xff in u8a, the comparison should be true, because 1s-complement simply inverts all the bits.

乍一看，`u8a` 里是 0xff，取反就是翻转所有位，比较应该为真。

But in fact the comparison will always be false, although the compiler does not report a warning in this case. However, you cannot even set a breakpoint inside the if or even on the if itself, because the compiler has eliminated the whole thing.

但实际上比较总是假，而且编译器这回连警告都不报。你甚至没法在 if 里或 if 本身上设断点——因为编译器已经把整段代码优化掉了。

The compiler knows that the comparison will never be true, because the byte u8a will be promoted to int, so the most significant bytes will be zero. When 1s complement is taken, the most significant bytes will be all ones, so the result can never be zero.

编译器知道比较永远不会为真，因为字节 `u8a` 会被提升为 `int`，高位的字节都是 0。取反之后，高位字节全部变成 1，结果就绝不可能为 0 了。

The remedy in this case is to specifically revert the promotion to int by casting the inverted value back to a byte.

解决办法是：把取反后的结果**转换回字节类型**，撤消对 `int` 的提升。

This concludes this lesson about the standard fixed-width integers, endianness and mixing types in expressions. I haven't covered the floating point types, so I have to leave that subject for another time.

关于标准定宽整数、字节序和表达式中混用类型的内容就讲到这里。浮点类型没来得及讲，只能留到以后了。

In the next lesson, I will talk about C structures and the Cortex Microcontroller Software Interface Standard (CMSIS).

下一课我们聊 C 语言的**结构体**（structures）和 **CMSIS**（Cortex 微控制器软件接口标准）。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---
Course web-page:
http://www.state-machine.com/quickstart

YouTube playlist of the course:
http://www.youtube.com/playlist?list=PLPW8O6W-1chwyTzI3BHwBLbGQoPFxPAPM

---

## 术语说明 / Terminology Notes

| 英文 / English | 中文 / Chinese | 说明 / Notes |
|---|---|---|
| Fixed-Width Integer Types | 定宽整数类型 | 通过 `stdint.h` 定义的标准整数类型 |
| stdint.h | stdint.h 头文件 | C99 标准提供的定宽整数类型定义头文件 |
| Endianness | 字节序 | 多字节数据在内存中的存储顺序 |
| Little-Endian | 小端模式 | 低位字节存储在低地址 |
| Big-Endian | 大端模式 | 高位字节存储在低地址 |
| Built-in Data Types | 内置数据类型 | C 语言原生提供的数据类型 |
| Integer Promotion | 整数提升 | 小于 `int` 的类型自动提升为 `int` |
| Implicit Conversion | 隐式转换 | 编译器自动执行的类型转换 |
| Explicit Cast | 显式转换 | 程序员手动指定的类型转换 |
| Sign Extension | 符号扩展 | 有符号数扩展时复制符号位 |
| Signedness | 符号性 | 有符号或无符号的属性 |
| Dynamic Range | 动态范围 | 数据类型能表示的数值范围 |
| 2's Complement | 二进制补码 | 负数在计算机中的表示方法 |
| 1's Complement | 反码 / 按位取反 | 所有位翻转 |
| Overflow | 溢出 | 计算结果超出数据类型的表示范围 |
| Truncated | 截断 | 超出部分被丢弃 |
| Portable Code | 可移植代码 | 在不同平台上行为一致的代码 |
| typedef | 类型定义 | C 语言中定义新类型名称的机制 |
| Macro | 宏 | 预处理器定义的替换规则 |
| sizeof() | sizeof 运算符 | 返回数据类型或变量字节大小的运算符 |
| Operand | 操作数 | 表达式中参与运算的值 |
| Checksum | 校验和 | 用于验证数据完整性的值 |
| Breakpoint | 断点 | 调试时暂停程序执行的标记点 |
| Disassembly View | 反汇编视图 | 显示机器码对应汇编指令的调试窗口 |
| Simulator | 仿真器 | 在软件中模拟硬件执行的环境 |
| Header File | 头文件 | 包含声明和定义的 `.h` 文件 |
| C99 ISO Standard | C99 标准 | ISO/IEC 9899:1999 C 语言标准 |
| CMSIS | CMSIS / Cortex 微控制器软件接口标准 | Cortex Microcontroller Software Interface Standard |
| LDRB / STRB | 字节加载/存储指令 | ARM 中读写单字节的指令 |
| LDRH / STRH | 半字加载/存储指令 | ARM 中读写半字的指令 |
| LDR / STR | 字加载/存储指令 | ARM 中读写字的指令 |
| RTOS | 实时操作系统 | Real-Time Operating System |
| Microcontroller | 微控制器 | 集成处理器内核与外设的单芯片 |
