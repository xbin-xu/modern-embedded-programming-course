# 第6课：C语言位运算符 / Lesson 6: Bit-wise Operators in C

Welcome to the Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll show you how to use the bit-wise operators in C to blink all the colors of the composite LED on the Launchpad board.

欢迎来到嵌入式系统编程课程。我是 Miro Samek，这节课我来带你学习 C 语言中的**位运算符**（bit-wise operators），然后用它们来点亮 Launchpad 开发板上复合 LED 的所有颜色。

As usual, let's start with making a copy of the previous "lesson5" project and renaming it to "lesson6". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

老规矩，先把上一课的"lesson5"项目复制一份，改名叫"lesson6"。如果你是刚加入课程的，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson6" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

进入"lesson6"目录，双击工作区文件打开 IAR 工具链。如果你还没有安装 IAR 工具链，回到"lesson0"去看安装说明。

So, this is the program you created in "lesson5". The program starts with configuring the GPIO pins connected to the three-color LED, then it enters an endless loop in which it turns the red LED on, waits a bit in a delay loop, and turns the red LED off, waits a bit again, and loops back. The result is blinking of the red LED.

这就是你在第 5 课中写的程序。程序先配置连接三色 LED 的 **GPIO 引脚**，然后进入一个无限循环：点亮红色 LED，延时等待一会儿，关掉红色 LED，再等一会儿，然后循环回去。最终效果就是红色 LED 在不停地闪烁。

In this lesson, your objective is to use the other colors of this composite LED, such as the blue and green colors.

这节课你的目标是让这个复合 LED 的其他颜色也亮起来，比如蓝色和绿色。

Suppose that you want to turn the blue LED on and keep it on all the time while you blink the red component on and off. How would you do that?

假设你想让蓝色 LED 一直亮着，同时让红色 LED 闪烁。你会怎么做？

The first step is simple. You need to turn the GPIOF data bit 2 corresponding to the blue LED before the endless loop.

第一步很简单。你只需要在进入无限循环之前，把 GPIOF 数据寄存器中对应蓝色 LED 的第 2 位置为 1 就行。

But then, inside the loop, when you turn the red LED on, you got a problem. When you set the bit-1 for the red LED, you also clear all other bits, including the bit-2 for the blue LED, because all the LED bits live inside a single register.

但问题来了——在循环里点亮红色 LED 的时候，当你设置第 1 位（红色 LED）的同时，所有其他位也被清零了，包括第 2 位（蓝色 LED）。原因很简单：所有 LED 的位都住在同一个**寄存器**（register）里。

So, what you really need is a method of setting and clearing the individual bits, without inadvertently disturbing the other bits.

所以，你真正需要的是一种能单独设置和清除某一位的方法，而且不能影响到其他位。

And this is where the bit-wise C operators come in.

这正是 C 语言位运算符大显身手的地方。

So, let's learn about the bit-wise operators in C by experimenting with them in the code.

那我们就边写代码边学，通过实际操作来搞懂这些位运算符。

Define a couple of unsigned integer variables with some initial values, and the variable c for holding the results of various bit-wise operations.

先定义几个带初始值的**无符号整型**（unsigned integer）变量，再定义一个变量 c 用来存放各种位运算的结果。

Now, let's first write the code for testing all the six bit-wise operators available in C, and let me hold on with explanations until you actually see the code in action inside the debugger:

先把 C 语言全部六种位运算符的测试代码写出来，解释先不着急，等你在调试器里看到实际运行效果再说：

this is bit-wise OR

这是**按位或**（OR）

this is bit-wise AND

这是**按位与**（AND）

this is bit-wise exclusive OR

这是**按位异或**（XOR）

this is bit-wise bit inversion, also known as one's complement

这是**按位取反**，也叫**反码**（one's complement）

this is the right bit-shift

这是**右移**

and finally, this is the left bit-shift operator

最后，这是**左移**运算符

Before compiling and running the code, please change the optimization level to None, and the debugger to Simulator, since you don't really need the Launchpad board.

编译运行之前，先把**优化级别**（optimization level）设为 None，调试器选**模拟器**（Simulator）——因为你不需要 Launchpad 开发板也能做这个实验。

Now, compile the code by pressing F7

好，按 F7 编译代码。

Let's run this code in the debugger by pressing the "Download and Debug" button.

点击"Download and Debug"按钮，在调试器里运行这段代码。

Single step over the initialization of a, b, and c and go to the Locals window to adjust the view to the binary format for.

单步跳过 a、b、c 的初始化，然后打开 Locals 窗口，把显示格式切换成二进制。

Step over the bit-wise OR expression and examine the result in the c variable.

单步跳过按位或表达式，看看变量 c 里的结果。

As you can see, the bit-wise OR operator performs the logical OR between each bit of a and each bit of b. If you remember the truth-tables from your elementary school, you can verify easily verify that: false, corresponding in binary to 0, OR true, corresponding to 1 is true-that is one. 1 OR 0 is 1, 1 OR 1 is 1, and 0 OR 0 is 0.

可以看到，按位或运算符对 a 和 b 的每一位逐个做逻辑或运算。如果你还记得基本的**真值表**（truth table），验证起来很简单：假（二进制的 0）或真（二进制的 1）结果为真——就是 1。1 OR 0 是 1，1 OR 1 是 1，0 OR 0 是 0。

In the disassembly window you can see, that the all these OR operations on all 32-bits of the two operands are performed in just one machine instruction ORRS, which is very fast and efficient.

打开**反汇编窗口**（disassembly window）看看——对两个操作数全部 32 位做的这些或运算，只需要一条机器指令 **ORRS** 就搞定了，非常快、非常高效。

The bit-wise AND operator performs the logical AND between each bit of a and each bit of b. If you remember the truth-table for logical AND, you can verify easily verify that: 0 AND 1 is 0. 1 AND 0 is 0, 1 AND 1 is 1, and 0 AND 0 is 0.

按位与运算符对 a 和 b 的每一位逐个做逻辑与运算。逻辑与的真值表你应该也记得：0 AND 1 是 0，1 AND 0 是 0，1 AND 1 是 1，0 AND 0 是 0。

In the disassembly window you can see, that the all these AND operations on all 32-bits of the two operands are performed in just one machine instruction ANDS

反汇编窗口里可以看到，对两个操作数全部 32 位做的与运算，同样只需要一条机器指令 **ANDS**。

The bit-wise Exclusive-OR operator performs logical Exclusive-OR between each bit of a and each bit of b. You can verify that: 0 XOR 1 is 1, 1 XOR 0 is 1, 1 XOR 1 is 0, and 0 XOR 0 is 0.

按位异或运算符对 a 和 b 的每一位逐个做逻辑异或运算。你可以验证一下：0 XOR 1 是 1，1 XOR 0 是 1，1 XOR 1 是 0，0 XOR 0 是 0。

In the disassembly window you can see, that the all these Exclusive OR operations on all 32-bits of the two operands are performed in just one machine instruction EORS.

反汇编窗口里可以看到，异或运算也只需要一条机器指令 **EORS** 就完成了。

The bit-wise NOT operator is unary, meaning that it acts on just one operand, in which it turns every 1 bit to 0 and 0 to 1.

按位取反运算符是**一元运算符**（unary operator），意思是它只作用于一个操作数——把所有的 1 变成 0，所有的 0 变成 1。

In the disassembly window you can see that bit-wise NOT is performed by the MVNS instruction, which stands for move-negative.

反汇编窗口里可以看到，按位取反由 **MVNS** 指令执行，意思是 move-negative（取反传送）。

The right bit-shift operation shifts all the bits in the first operand by the number of places specified in the second operand. For the shift by 1, this corresponds to integer division by 2, as you can verify with a calculator.

右移操作把第一个操作数的所有位，按第二个操作数指定的位数向右移动。移动 1 位的效果就相当于整数除以 2，你可以拿计算器验证一下。

In the disassembly window you can see that the right-shifting is performed by the RSRS instruction.

反汇编窗口里可以看到，右移由 **LSRS** 指令执行。

Please note that the RSRS instruction shifts zeros into the most significant bit positions.

注意，LSRS 指令会在**最高有效位**（MSB, Most Significant Bit）那边补 0。

The left bit-shift operation shifts all the bits in the first operand to the left by the number of places specified in the second operand. For the shift by 3, this corresponds to integer multiplication by 2 to the power 3, which is 8. But you need to be careful, because for a large first operand, like in this case, some of the most significant bits might "fall off the left edge", which simply means that the result after the shift no longer fits in the 32-bits.

左移操作把第一个操作数的所有位，按第二个操作数指定的位数向左移动。移动 3 位的效果相当于整数乘以 2 的 3 次方，也就是乘以 8。不过要小心——如果第一个操作数比较大的话（比如这里这个例子），一些最高有效位可能会"从左边掉出去"，说白了就是移位后的结果超出了 32 位能表示的范围。

In the disassembly window you can see that the left-shifting is performed by the LSLS instruction.

反汇编窗口里可以看到，左移由 **LSLS** 指令执行。

Please note that the LSLS instruction shifts zeros into the least significant bit position.

注意，LSLS 指令会在**最低有效位**（LSB, Least Significant Bit）那边补 0。

So, now you know how the bit-wise operators work on unsigned numbers. For signed numbers, the right-shift operator, works significantly different, however. Let's perform an additional experiment.

好，现在你知道位运算符对无符号数是怎么工作的了。但对**有符号数**（signed number），右移运算符的行为就大不一样了。我们来额外做一个实验。

Define a signed integer x and initialize it with a positive value. Define another signed integer y and initialize it with a negative value.

定义一个有符号整型 x，用正值初始化。再定义一个有符号整型 y，用负值初始化。

Next, perform right-shift of x by a couple of places. And finally perform right-shift of y by the same number of places. Let's compile and test it.

然后对 x 右移几位，再对 y 右移相同的位数。编译运行看看。

As you can see, the positive value is shifted right exactly as before, that is, zeros are shifted into the most significant bit position.

可以看到，正值的右移跟之前完全一样——0 被移入了最高有效位。

When you compare the decimal values of z and x, you can see that right-shift by 3 places corresponds to division by 8, which is 2 to the power of 3, as expected.

比较一下 z 和 x 的十进制值就知道，右移 3 位就等于除以 8，也就是除以 2 的 3 次方，跟预期一致。

However, the right-shift of the negative value y behaves completely differently than before, because now 1s are shifted to the most-significant bit.

但负值 y 的右移就完全不同了——这回移入最高有效位的是 1。

So, you've just found out that right-shifting of a signed integer shifts zeros into the most-significant bit, when the bit is zero before the shift, and ones when the bit is one before the shift. This is called sign-extending of a negative value in the 2's complement representation, which you learned in Lesson-1. This sign-extending is necessary to preserve the correspondence between right-shifting and division by a power of 2.

所以你刚才发现了：有符号整数右移时，如果移位前**符号位**（sign bit）是 0，就补 0；如果符号位是 1，就补 1。这叫做**二进制补码**（2's complement）表示下负数的**符号扩展**（sign extension）——第 1 课里你学过。符号扩展是必要的，这样才能保证右移和除以 2 的幂次之间的对应关系。

Indeed, when you convert the values to decimal, you can see that both z and y are negative and that z is still equal to y divided by 8, which is 2 to the power 3.

确实如此。把值转成十进制看看，z 和 y 都是负数，而且 z 仍然等于 y 除以 8（即 2 的 3 次方）。

This difference between right-shifting of signed integers versus unsigned integers becomes very obvious when you look in disassembly. As you can see, the compiler generated the instructions ASRS for right-shifting of signed numbers, which means Arithmetic right shift, whereas the compiler generated the instruction LSRS, logical-right-shift, for right-shifting of unsigned numbers.

有符号数和无符号数右移的差异，看反汇编就一目了然了。编译器为有符号数的右移生成了 **ASRS** 指令，也就是**算术右移**（Arithmetic Right Shift）；而为无符号数的右移生成了 **LSRS** 指令，也就是**逻辑右移**（Logical Right Shift）。

As an embedded systems programmer, you need to know the bit-wise C operators inside and out, and in fact questions about various nuances, such as logical shift versus arithmetic shift come quite often during the embedded programming job interviews. More importantly, though, the bit-wise operators are very useful, and you will take advantage of them right away in your "blinky" program.

做嵌入式开发，你得把 C 语言位运算符摸得烂熟。事实上，像逻辑移位和算术移位的区别这类细节问题，在嵌入式岗位的面试中经常会被问到。更重要的是，位运算符非常实用——你马上就会在 blinky 程序里用上它们。

For starters, you can now define the GPIO bits that control various LED colors by means of the bit-shift operators. For example, the red LED corresponds to bit 1, blue LED to bit 2, and green LED to bit 3.

首先，你可以用移位运算符来定义控制各种 LED 颜色的 GPIO 位了。比如，红色 LED 对应第 1 位，蓝色 LED 对应第 2 位，绿色 LED 对应第 3 位。

Please note that these bit-shift expressions are compile-time constants, so there is absolutely no overhead compared to defining LED_GREEN as 0x08, say. But the advantage here is that you immediately see the bit number as the shift displacement. For low-order bits this advantage is perhaps not that impressive, but for high-order bits, like, say, bit-18, it is not that easy at all to see that this is equivalent to 0x4000, while it is obvious in the expression 1 right-shifted by 18. This way of defining bit constants has saved me a lot of time counting bits and prevented a lot of stupid bugs in my programs, so I highly recommend it.

注意，这些移位表达式都是**编译时常量**（compile-time constant），所以跟直接写 `LED_GREEN 0x08` 相比，没有任何额外的开销。好处在于：你一眼就能看出是第几位。低位的优势可能不太明显，但碰到高位就不一样了——比如第 18 位，要一眼看出它等于 0x40000 可不容易，但写成 `1 << 18` 就一目了然了。这种定义位常量的写法帮我省了无数数位的时间，也避免了很多低级错误，强烈推荐。

After defining the macros for the LED colors, you can replace the cryptic hex numbers, which greatly improves the readability of the code. In fact, your code becomes self-explanatory, and the comment becomes redundant.

定义好 LED 颜色的宏之后，你就可以把那些晦涩的十六进制数字替换掉，代码的可读性大大提升。实际上代码本身就说明了意思，注释都显得多余了。

Now, let's tackle the really interesting case of setting the red-color bit in the GPIOF without extinguishing the blue color. For this you can use the bit-wise OR operator between the current value of the GPIOF data register and the red-color bit.

好，现在来处理真正有趣的情况：在 GPIOF 中设置红色位，同时不灭掉蓝色 LED。做法是——在 GPIOF 数据寄存器的当前值和红色位之间做按位或运算。

This works, because the bit-wise OR between any bit in GPIOF and LED_RED preserves the original GPIOF bit, for all bits where LED_RED is zero, and forces bit number 1 to 1.

为什么行得通？因为 GPIOF 中的每一位跟 LED_RED 做按位或时，LED_RED 为 0 的那些位保持原值不变，而第 1 位被强制设为 1。

Please note that this trick works only if you actually can read from and write to the GPIOF register, so you need to check in the Data Sheet that this register has Read/Write permissions.

注意，这个技巧的前提是你能对 GPIOF 寄存器进行读写，所以要去**数据手册**（data sheet）里确认这个寄存器有读/写权限。

The C language provides a special abbreviation notation for assignments in which the left hand side also appears as the first argument on the right hand side. You can use the operator-equals notation, which means exactly the same as the line above.

C 语言为这种"等号左边也出现在右边第一个参数"的赋值提供了简写记法。你可以用 `|=` 这种复合赋值写法，效果跟上面那行完全一样。

So, finally, here is the most succinct code for setting the LED_RED bit in the GPIOF register. Please remember this as a coding idiom for setting a bit in C.

所以，最终这就是在 GPIOF 寄存器中设置 LED_RED 位最简洁的写法。请把它当成 C 语言中**置位**（set bit）的**编程惯用法**（coding idiom）记下来。

To clear the LED_RED bit in the GPIOF register, you need to use the bit-wise AND operator with the complement of the LED_RED bit.

要清除 GPIOF 寄存器中的 LED_RED 位，你需要用按位与运算符，配合 LED_RED 位的取反（complement）。

This works, because the bit-wise AND between any bit in GPIOF and ~LED_RED preserves the original GPIOF bit, for all bits where ~LED_RED is 1, and forces bit number 1 to 0.

原理是这样的：GPIOF 中的每一位跟 ~LED_RED 做按位与时，~LED_RED 为 1 的那些位保持原值不变，而第 1 位被强制清零。

Again, you can use the operator-equals notation to represent this operation more succinctly.

同样，你可以用 `&=` 这种复合赋值写法来简化。

Please remember this as a coding idiom for clearing a bit in C.

请把这也记下来——这是 C 语言中**清位**（clear bit）的编程惯用法。

Now that you know the coding idioms you can step back and look at your code a bit more critically. For example, the turning the blue-LED on is also setting a bit in the GPIOF register, so it should be coded with the bit-set idiom.

既然学了这些惯用法，你可以回头审视一下之前的代码了。比如，打开蓝色 LED 其实也是在 GPIOF 寄存器中置位，所以应该用置位惯用法来写。

Actually, all of the lines above also perform setting of bits in various registers, so they too should be coded with the bit-set idiom. Please remember, however, that you need to check in the Data Sheet that the registers have read/write permissions.

实际上，上面的那些代码也是在各个寄存器中做置位操作，所以它们也应该用置位惯用法。不过别忘了，你得先确认数据手册里这些寄存器确实有读/写权限。

And finally, you can use your LED macros to further improve the readability of your code.

最后，用你定义的 LED 宏替换掉硬编码数字，代码可读性又提升了一个档次。

Before you re-compile, go to the project options and set the optimization level back to high and the debugger to TI Stellaris.

重新编译之前，回到项目选项，把优化级别改回 High，调试器选回 TI Stellaris。

Let's load the program into the Launchpad board and run it. As you can see the blue-LED is on all the time, and the fainter red-LED keeps blinking.

把程序烧录到 Launchpad 开发板上运行。可以看到，蓝色 LED 一直亮着，红色 LED 在不断地闪烁（稍微暗一些）。

Break into the code and set breakpoints at setting and clearing the red-LED bit.

暂停程序，在置位和清零红色 LED 位的代码处各设一个**断点**（breakpoint）。

As you can see, setting of the red LED bit happens as a sequence of load-modify-store operations, whereas the bit-wise ORR machine instruction is used to modify the data.

可以看到，置位红色 LED 位是一个**加载-修改-存储**（load-modify-store）的操作序列，用按位 ORR 机器指令来修改数据。

The clearing of the red-LED bit happens as another load-modify-store sequence, whereas interestingly, the compiler generated the beautiful code of just one BIC (bit-clear) instruction for clearing the bit. This is quite remarkable, because the compiler didn't literally follow your code to perform a bit-wise AND with the complemented bitmask. Instead, the compiler clearly understood your intent to clear the bit, and generated an even better code for it.

清零红色 LED 位同样是另一个加载-修改-存储序列，但有趣的是，编译器只生成了漂亮的一条 **BIC**（bit-clear，位清除）指令就完成了清位操作。这相当厉害——编译器并没有照着你写的代码字面去做按位与加取反掩码的操作，而是理解了你"清除这一位"的真正意图，生成了更优的代码。

I'd like you to remember this example, because it shows you that by following established coding idioms, like the idiom for clearing a bit, allows the compiler to understand your code at a higher level of your intent, not just the low-level operations.

我希望你记住这个例子。它说明了：遵循像清位惯用法这样的编程惯例，能让编译器在更高的层次上理解你的意图，而不仅仅是看到一堆低级操作。

This concludes this lesson about the bit-wise operators in C. Now you know how to set, clear, toggle, and shift bits in all sorts of registers. So congratulations!

好，这节关于 C 语言位运算符的课就到这里了。现在你知道了如何对各种寄存器中的位进行**置位**（set）、**清位**（clear）、**翻转**（toggle）和**移位**（shift）。恭喜你！

In the next lesson, I'd like to answer several questions about the GPIO DATA register that were asked in the comments on YouTube. This subject actually complements quite well the discussion of the bit-wise operators, because the Stellaris GPIO DATA register demonstrates a very different, hardware-assisted approach to manipulating whole groups of bits..

下一课我来回答 YouTube 评论中关于 GPIO DATA 寄存器的几个问题。这个主题跟本课的位运算符内容非常互补——Stellaris 的 GPIO DATA 寄存器展示了一种完全不同的方式，是靠**硬件辅助**（hardware-assisted）来操作整组位的。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文 | 中文 | 说明 |
|------|------|------|
| Bit-wise Operator | 位运算符 | 对二进制位进行操作的运算符 |
| Bit-wise OR (|) | 按位或 | 两操作数对应位进行逻辑或运算 |
| Bit-wise AND (&) | 按位与 | 两操作数对应位进行逻辑与运算 |
| Bit-wise XOR (^) | 按位异或 | 两操作数对应位不同则为 1 |
| Bit-wise NOT (~) | 按位取反 / 反码 | 将所有位反转，也叫 one's complement |
| Left Bit-shift (<<) | 左移 | 将位向左移动指定位数 |
| Right Bit-shift (>>) | 右移 | 将位向右移动指定位数 |
| Unary Operator | 一元运算符 | 只需要一个操作数的运算符 |
| Truth Table | 真值表 | 列出所有输入组合及对应输出的表格 |
| Most Significant Bit (MSB) | 最高有效位 | 二进制数中最左边的位 |
| Least Significant Bit (LSB) | 最低有效位 | 二进制数中最右边的位 |
| Sign Bit | 符号位 | 有符号数中表示正负的最高位 |
| Sign Extension | 符号扩展 | 右移时保持符号位不变的行为 |
| 2's Complement | 二进制补码 | 表示有符号整数的标准方法 |
| Arithmetic Right Shift | 算术右移 | 保持符号位的右移（ASRS 指令） |
| Logical Right Shift | 逻辑右移 | 高位补零的右移（LSRS 指令） |
| Compile-time Constant | 编译时常量 | 在编译时即可确定值的表达式 |
| Coding Idiom | 编程惯用法 | 特定编程语言中常用的代码模式 |
| Set Bit | 置位 | 将某一位设为 1 |
| Clear Bit | 清位 | 将某一位设为 0 |
| Toggle | 翻转 | 将某位从 0 变 1 或从 1 变 0 |
| Overhead | 开销 | 额外的计算或资源消耗 |
| Macro | 宏 | 通过 #define 定义的代码替换规则 |
| Load-Modify-Store | 加载-修改-存储 | 对寄存器进行读-改-写的操作模式 |
| Disassembly | 反汇编 | 将机器码转换为汇编语言的过程 |
| Breakpoint | 断点 | 调试时暂停程序执行的标记点 |
| Data Sheet | 数据手册 | 芯片的技术参考文档 |
| Readability | 可读性 | 代码易于理解的程度 |
| Hardware-assisted | 硬件辅助 | 由硬件而非软件来加速实现的机制 |
