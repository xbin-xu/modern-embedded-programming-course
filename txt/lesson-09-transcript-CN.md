# 第9课：模块、递归函数与ARM过程调用标准 / Lesson 9: Modules, Recursive Functions, and APCS

Welcome to the Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll continue the subject of functions in C. Today you'll learn how functions allow you to split your program into separate files, you'll write your first recursive function, and you'll learn about the ARM Procedure Call Standard (APCS).

欢迎来到嵌入式系统编程课程。我是 Miro Samek，本课我们继续聊 C 语言函数的话题。今天你将学会如何用函数把程序拆分到不同文件中，你会写出自己的第一个递归函数，还会了解到 **ARM 过程调用标准**（APCS，ARM Procedure Call Standard）。

As usual, let's start with making a copy of the previous "lesson8" project and renaming it to "lesson9". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

老规矩，先把上一课的 "lesson8" 项目复制一份，改名为 "lesson9"。如果你是新加入的，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson9" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

进入新的 "lesson9" 目录，双击工作区文件打开 **IAR 工具集**。如果你还没装 IAR 工具集，回到第 0 课去看安装说明。

Let me very quickly remind you what happened so far. In the last lesson, you've created a function delay(), to busy-wait for the specified number of loop iterations.

快速回顾一下之前的进展。上一课你写了一个 `delay()` 函数，用来忙等待指定的循环次数。

Here is the declaration of the delay() function, also known as the prototype

这是 `delay()` 函数的声明，也叫**原型**（prototype）。

and here is the definition of the delay() function, which contains the actual code.

这是 `delay()` 函数的定义，里面是实际的代码。

The delay() function is then called in two places in your main program.

然后在主程序的两个地方调用了这个 `delay()` 函数。

The fact that a single function can be called multiple times, instead of repeating the same code verbatim, was--in fact--your main motivation for using functions in the first place. But functions allow you to achieve even a greater feat. Functions enable you to split the program into multiple files rather than having to keep all the code in the main file, which, for any non-trivial program would quickly become like a kitchen sink.

一个函数可以被多次调用，不用一遍遍写重复代码——这是你当初用函数的主要原因。但函数能做的还不止这些。函数可以把程序拆分到多个文件里，不用把所有代码都塞在主文件中。对于任何稍微复杂的程序来说，全堆在一个文件里很快就会乱成一锅粥。

So, the first thing I want you to do today is to move the delay function to its own file.

所以，今天第一件事就是把 `delay` 函数挪到它自己的文件里。

First, create a new file by clicking the "New document" tool button. Next, cut-and-paste the delay() function into the new file. And finally, save the file as delay.c into your project directory.

先点 "New document" 工具按钮创建一个新文件。然后把 `delay()` 函数剪切粘贴过去。最后保存为 `delay.c`，放到项目目录中。

At this point, the file exists on the disk, but it is not yet part of the project.

这时候文件已经在磁盘上了，但还不是项目的一部分。

You need to add the file to the project by right-clicking on the project and choosing the Add and 'Add delay.c' popup menu.

右键点击项目，选择 Add，再选 "Add delay.c" 弹出菜单，把文件加到项目里。

When you compile your project at this stage by pressing F7, you get an error that the delay() function has been defined without a prototype. You can easily make this error go away by copying the prototype from main.c to delay.c.

这时候按 F7 编译项目，会报一个错：`delay()` 函数定义了但没有原型。解决办法很简单，把原型从 `main.c` 复制到 `delay.c` 就行。

But this is a very lousy fix, because now the repeated prototypes can very easily become different, if you change one and forget about the other. This is just one more example of violating the DRY principle (Do NOT Repeat Yourself), which I hope you remember from the last lesson.

但这个修法很糟糕。因为现在原型写了两份，改了一个忘了另一个，两边就不一致了。这就是违反 **DRY 原则**（Don't Repeat Yourself，不要重复自己）的又一个例子——希望你还记得上一课讲过的这个原则。

The right solution is to place the prototype itself in a separate file, which you could then include in all files that call the delay() function.

正确的做法是把原型放到一个单独的文件里，然后在所有调用 `delay()` 函数的地方包含这个文件。

As before, create new document and cut-and-paste the delay() function prototype into it. Save the file as delay.h header file.

跟刚才一样，新建文档，把 `delay()` 函数的原型剪切粘贴进去。保存为 `delay.h` **头文件**（header file）。

Now you can include the delay.h header file in main.c and in delay.c instead of repeating the prototype code.

现在在 `main.c` 和 `delay.c` 中包含 `delay.h` 头文件就行了，不用再重复写原型。

The final touch you can add to the delay.h header file is the protection against multiple inclusion. Such automatic protection is useful, because header files can include other header files, which can easily lead to a situation when a header file can be included more than once.

最后可以给 `delay.h` 加一道**多重包含保护**（multiple inclusion guard）。这个保护很有用，因为头文件可以包含其他头文件，很容易出现同一个头文件被多次包含的情况。

In fact, most header files provided in various libraries, such as the lm4f.h header file contain this sort of protection against multiple inclusion.

事实上，各种库提供的头文件大多都带这种多重包含保护，比如 `lm4f.h` 就有。

This is achieved by means of the C pre-processor as follows. At the top of the file you have an #if-not-defined pre-processor directive followed by the mangled name of the file. There are many conventions of mangling the name, here for example you see two underscores pre-pended and appended to the capitalized file name. The idea here is that this macro is NOT defined initially, so the pre-processor WILL go beyond the #ifndef directive the first time.

这是通过 **C 预处理器**（C pre-processor）实现的。具体做法是：文件顶部放一条 `#ifndef`（if-not-defined）预处理指令，后面跟一个经过改写的文件名。改写方式有很多约定，比如这里是在大写文件名前后各加两个下划线。关键点是：这个宏一开始没有被定义，所以预处理器第一次会正常通过 `#ifndef` 这一行。

However, the next line defines this macro, so that it IS defined from now on. Therefore, should the header file be included again, the preprocessor will NOT go past the #if-not-defined directive and the body of the file will be skipped up to the matching #endif directive.

紧接着下一行就定义了这个宏，从此它就被定义了。所以如果这个头文件再次被包含，预处理器就不会通过 `#ifndef` 这一行，文件内容会被跳过，直到匹配的 `#endif` 为止。

So, now let's apply this technique to your delay.h header file. Copy and paste the top two lines and change the mangled file name.

好，现在把这个技巧用到你的 `delay.h` 上。复制粘贴顶部的两行，然后把改写的文件名改掉。

Don't forget to provide the matching #endif directive at the end.

别忘了在文件末尾加上匹配的 `#endif`。

In quick summary, you've just learned about one of the most powerful features of the C programming language, which is the ability to build programs from separately compiled source files. This ability, which is enabled by the use of functions, is critically important, because having a complete program in just one file is both impractical and inconvenient. The way a program is organized into files can help you understand the overall structure and enable the compiler to enforce that structure. Such modularization is also beneficial for speeding the compilation process, because only the changed files need to be re-compiled.

总结一下，你刚刚学了 C 语言最强大的特性之一——从**单独编译的源文件**构建程序。这个能力是通过函数实现的，非常重要。把整个程序塞在一个文件里既不实际也不方便。程序按文件组织，既能帮你理解整体结构，也能让编译器帮你维护这个结构。这种**模块化**还有一个好处：编译更快，因为只需要重编译改动过的文件。

Now let's move on to explore some other properties of functions, such as the ability to return a value. As an example, consider a function to calculate the factorial of an integer argument n.

接下来看看函数的其他特性，比如返回值。举个例子，写一个计算整数参数 n 的**阶乘**（factorial）的函数。

Let's design this function top-down, that is, starting with the prototype and the use case. The function name is 'fact' and it takes one unsigned argument 'n'.

我们用**自顶向下**（top-down）的方式来设计这个函数——先写原型，再想怎么用。函数名叫 `fact`，接收一个无符号参数 `n`。

The factorial function returns an unsigned value equal to 1*2*3 all the way up to n.

阶乘函数返回一个无符号值，等于 1×2×3，一直乘到 n。

With the prototype in place, you can write the code that uses the factorial function, even before you actually define it.

原型写好之后，你就可以写调用阶乘函数的代码了，哪怕函数还没定义也没关系。

An unsigned volatile variable 'x' will be used to store the values returned by the factorial function. The variable is volatile, to prevent the compiler from optimizing it away.

用一个无符号 `volatile` 变量 `x` 来保存阶乘函数的返回值。之所以用 **volatile**，是为了防止编译器把它优化掉。

So, now here is how you call a function that returns a value. You can simply assign the returned value to a variable. At this point, you should also think about the allowed range of the function arguments. Mathematically, the lowest value for which factorial is defined is zero.

好，那怎么调用有返回值的函数呢？很简单，把返回值赋给一个变量就行。这时候你也该想想参数的合法范围。从数学上说，阶乘有定义的最小值是零。

Actually, strictly speaking the argument type should be an unsigned zero.

严格来说，参数类型应该是无符号零。

A function returning a value can also be used inside an expression rather than being immediately assigned to a variable.

有返回值的函数也可以直接用在**表达式**（expression）里，不一定要马上赋给变量。

Finally, you can also just call the function without doing anything with the return value. This would make sense only if your function has some meaningful side effects. However, to make clear that you don't care about the return value, I recommend explicitly casting the return value to void.

最后，你也可以调用函数但不管返回值。这只有当函数有某种有意义的**副作用**（side effect）时才说得通。不过，为了明确表示你不在乎返回值，我建议把它显式转换为 `void`。

When you try to build your program at this stage, you get an error. But note that this is not a compiler error. This error is generated by the linker, which is the next step of building your program, where all the compilation units are "linked" together.

这时候尝试构建程序，会报错。但注意，这不是编译器报的错。这个错误是**链接器**（linker）产生的——链接是构建程序的下一步，把所有**编译单元**（compilation units）"链接"在一起。

When you scroll up, you can see that the linking stage failed, because the function "fact()" has not been found. Obviously, you have not defined this function yet, so this reason is clear. But I wanted to point out that this type of error is not detectable by the compiler, because the compiler cannot know in which file the definition of this function might reside.

往上翻可以看到，链接阶段失败了，因为找不到函数 `fact()`。显然，你还没定义这个函数，原因很清楚。但我想强调的是，这种错误编译器是检测不到的——因为编译器不知道函数的定义会在哪个文件里。

So, let's define the fact() function. Copy the prototype and provide the braces for the body of the function. Before writing the actual code, you might want to brush up on your math by writing the mathematical definition of factorial in a comment. In fact, there are two definitions: iterative and recursive. For this exercise, you will use the recursive definition, in which the factorial of zero is 1 and the factorial of n is n times factorial of n-1 for all ns greater than zero.

好，来定义 `fact()` 函数。复制原型，加上花括号作为函数体。写代码之前，可以先在注释里写一下阶乘的数学定义来复习一下。阶乘有两种定义：**迭代**（iterative）和**递归**（recursive）。这次练习用递归定义：0 的阶乘是 1；对于所有大于 0 的 n，n 的阶乘等于 n 乘以 n-1 的阶乘。

Translating this into C you get: if n equals unsigned-zero, return the value unsigned-1. Otherwise, return n times factorial of n-1. So, as you can see, a function produces the result by means of the return statements, which are followed by numerical expressions.

翻译成 C 语言就是：如果 n 等于无符号 0，返回无符号 1。否则返回 n 乘以 n-1 的阶乘。如你所见，函数通过 `return` 语句产生结果，`return` 后面跟的是数值表达式。

When you build now, both the compilation and linking succeed. So, congratulations. You've just written your first recursive function that calls itself.

现在再构建，编译和链接都成功了。恭喜你——你刚刚写出了第一个调用自身的**递归函数**（recursive function）。

All right, so now it's finally the time to see how it really works. I'll run the code on the TI board, to show that it works on real hardware, but you might just as well use the simulator.

好，终于该看看它是怎么运作的了。我在 TI 开发板上跑这段代码，证明它在真实硬件上能工作。当然你用模拟器也完全可以。

Before stepping into the code, adjust the memory view to see the top of the stack, which, as you recall from the last lesson, is stored in the Stack Pointer (SP) register.

单步执行之前，先调整内存视图来观察**栈顶**。上一课讲过，栈顶保存在**栈指针**（SP，Stack Pointer）寄存器里。

To help you keep track of the stack content in the memory view, I will use an arrow pointing to the current top of the stack.

为了方便你在内存视图中追踪栈的内容，我会用一个箭头指向当前的栈顶。

Stepping into the code, you can see that the call to your factorial function consists of two instructions. First the argument value is moved to R0 and then the function is called with the Branch-and-Link (BL) instruction.

单步进入代码，可以看到调用阶乘函数由两条指令完成：先把参数值移入 R0，然后用 **BL**（Branch with Link，带链接分支）指令调用函数。

Inside the factorial function, the first thing that the code does is to push the registers R4 and the LR (link-register) to the stack. By now you should understand why the LR has to be saved, and this is because factorial is not a leaf function, so it must preserve the LR clobbered by the BL instruction when it calls itself.

进入阶乘函数内部，代码做的第一件事就是把 R4 和 **LR**（链接寄存器，Link Register）压栈。现在你应该明白为什么要保存 LR 了——因为阶乘函数不是**叶函数**（leaf function），它调用自身时 BL 指令会覆盖 LR，所以必须提前保存。

The very next instruction should give you a clue why saving the R4 register is also necessary. As you perhaps remember from the last lesson, the first argument to a function is passed in the R0 register, but inside factorial R0 is re-used to return the value and also as the argument to the nested factorial call, so the compiler moves R0 to R4.

紧接着的下一条指令会告诉你为什么 R4 也需要保存。上一课讲过，函数的第一个参数通过 R0 传递。但在阶乘函数里，R0 既要用来存返回值，又要作为嵌套调用的参数，所以编译器把 R0 的值挪到了 R4。

Here you can see that the function moves the return value (1 in this case) into the R0 register.

这里可以看到函数把返回值（本例中是 1）移入 R0 寄存器。

The last instruction of the function is very interesting, because it kills two birds with one stone. As you know by now, any stack operation executed in the beginning of a function code must be exactly reversed before the function returns. So here the function pops the two registers, which it pushed initially. But the content of the orignal LR is popped directly into the Program Counter (PC), which causes the return.

函数的最后一条指令很有意思——一箭双雕。如你所知，函数开头做了什么栈操作，返回前就必须原样反转。所以这里弹出开头压入的两个寄存器。但原始 LR 的内容直接弹入了**程序计数器**（PC，Program Counter），这就完成了返回。

Please notice that the value on the stack that was popped into PC is actually an odd number 0x49, whereas the return address the PC has become an even number 0x48. I explained why the least-significant bit of the address is handled specially in the BX instruction, which was used to return from a leaf function, such as delay(). Here you can see that the pop to PC instruction is also a special case, and behaves like the BX instruction.

注意看：从栈弹入 PC 的值其实是奇数 0x49，而 PC 变成的返回地址是偶数 0x48。之前我解释过 BX 指令中地址最低位为什么会被特殊处理——BX 指令用于从叶函数（比如 `delay()`）返回。这里的 pop 到 PC 也是同样的特殊情况，行为跟 BX 指令一样。

Finally, here you see again that the function returns the value in R0, which is then stored on the top of the stack, where the x variable lives.

最后，你又看到函数通过 R0 返回值，然后这个值被存到栈顶——也就是变量 `x` 所在的位置。

In the next call to factorial(), you see that factorial calls itself.

下一次调用 `factorial()` 时，你会看到阶乘函数调用了自身。

The most important observation here is that the next call to factorial happens before the previous call returns and pops the registers from the stack, so it nests on top of the stack allocated by the first call.

这里最关键的观察是：下一次阶乘调用发生在前一次调用返回、弹出寄存器之前，所以它嵌套在第一次调用所分配的栈空间之上。

Here you can see that after the recursive call returns, the value returned in R0 is multiplied by the original value of the argument n stored in R4. The result is again stored in R0 to be returned from the function.

这里可以看到，递归调用返回后，R0 中的返回值跟保存在 R4 中的原始参数 n 相乘。结果又存回 R0，用于函数返回。

Back in the main function, you can see how the expression is evaluated, whereas the factorial value is taken from R0.

回到 `main` 函数，可以看到表达式是怎么求值的——阶乘值是从 R0 中取出来的。

The last call to factorial of 5 shows 6-levels of recursive calls. As I quickly step through the code, please watch the stack building up with the clearly distinguishable pattern of the decrementing arguments 'n' and return addresses.

最后一次计算阶乘 5 会展示 6 层递归调用。我快速单步执行，请注意观察栈的增长过程——你能清楚看到递减的参数 `n` 和返回地址交替出现的规律。

At this point the recursive calling stops and now all these nested calls will return one at a time.

此时递归调用停止，所有嵌套的调用开始逐一返回。

Again, as I step through this return sequence, please watch how this causes the stack to unwind.

再看我单步执行这个返回序列，注意观察**栈展开**（stack unwind）的过程。

After the factorial function eventually returns all the way to main, you can see that the result it produced in R0 is hex 78, which is 120 decimal, which is indeed the factorial of 5.

阶乘函数最终一路返回到 `main` 之后，可以看到 R0 中的结果是十六进制 0x78，也就是十进制 120——正是 5 的阶乘。

The last subject I'd like to touch upon in this lesson is the function calling convention. From the discussion so far, I hope you have noticed that there must be some agreement between the caller of a function and the function being called. For example, both sides must have an understanding that the return address will be provided to the function in the LR register. Also, both parties must agree that the first argument will be passed in R0 and that the return value will be returned in R0 as well.

本课最后一个话题：**函数调用约定**（function calling convention）。从刚才的讨论中，我希望你已经注意到，调用方和被调用方之间必须有某种约定。比如，双方都得知道返回地址会放在 LR 寄存器里。参数怎么传？第一个参数通过 R0 传递。返回值怎么回？也通过 R0 返回——这些都得提前说好。

Of course there are many more such little agreements that all form a whole formal contract called the ARM Application Procedure Call Standard (AAPCS). The whole formal document is quite complex and you can find it online by searching for "AAPCS". Here, I would only like to mention how the AAPCS assigns the responsibilities for the ARM registers, because this will be very useful when you will learn about handling interrupts on the ARM processor.

当然，类似的约定还有很多，它们共同构成了一份正式规范，叫做 **ARM 应用过程调用标准**（AAPCS，ARM Application Procedure Call Standard）。完整的文档相当复杂，搜索 "AAPCS" 就能找到。这里我只讲 AAPCS 如何分配 ARM 寄存器的职责——因为后面学 ARM 处理器**中断**（interrupt）处理时会用到。

So, the registers R0-R3 and R12 are used for passing arguments and returning values, and can be clobbered by a function. On the other hand, the function must preserve the 8 registers R4-R11. This doesn't mean that a function cannot use R4-R11, but if it does, the function code must save them on the stack and restore before returning. For example, please recall that your factorial function used the R4, but it saved on the stack.

具体来说：R0-R3 和 R12 用来传参数和返回值，函数可以随意覆盖。而 R4-R11 这 8 个寄存器，函数必须保存。这并不是说函数不能用 R4-R11，而是说用了就必须压栈保存，返回前再恢复。回想一下，你的阶乘函数就用了 R4，但它做了压栈保存。

This convention allows the caller of the function to use the preserved registers for values that must survive a function call. Again, recall that the value of the argument 'n' was stored in R4 exactly to survive the recursive call to factorial, because it was needed in the final multiplication.

这个约定让调用方可以放心地把"必须跨函数调用存活"的值放在这些被保存的寄存器里。再回想一下：参数 `n` 的值正是存在 R4 中的，为的就是在递归调用阶乘函数后还能活着回来——因为最后做乘法时还要用到它。

Speaking of the factorial computation. The recursive implementation that I've used in this lesson was just for a convenient demonstration of a deep call sequence so that you can watch the stack grow and shrink. But in fact, any such deep call sequences should be avoided in embedded programming, exactly because they use a lot precious RAM for the stack. A much better implementation of factorial would be the iterative version or, perhaps better yet, a lookup table.

说到阶乘计算：本课用递归实现只是为了方便演示**深度调用序列**（deep call sequence），让你观察栈的增长和缩减。但实际上，在嵌入式编程中应该尽量避免这种深度调用，因为它会消耗大量宝贵的 RAM 作为栈空间。阶乘更好的实现方式是迭代版本，或者更好的做法——用**查找表**（lookup table）。

This concludes this lesson about modules, functions that return values, recursive functions, and the ARM Application Procedure Call Standard.

本课关于模块、返回值的函数、递归函数以及 ARM 应用过程调用标准的内容就到这里了。

However, we are still not done with functions. In the next lesson, you will learn more about function arguments, including pointer arguments, and you'll learn about scope and local stack-based variables. Finally you will see what can happen when you overflow the stack.

不过，函数的话题还没完。下一课你会学到更多关于函数参数的知识，包括**指针参数**（pointer argument），还有**作用域**（scope）和基于栈的局部变量。最后你还会看到**栈溢出**（stack overflow）会发生什么。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅保持关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---|---|---|
| ARM Procedure Call Standard (APCS) | ARM 过程调用标准 | 定义 ARM 处理器上函数调用约定的标准 |
| ARM Application Procedure Call Standard (AAPCS) | ARM 应用过程调用标准 | APCS 的扩展版本，包含更完整的调用约定规范 |
| Prototype | 原型 | 函数声明，包含返回类型、名称和参数列表 |
| Header File | 头文件 | 包含函数原型、宏定义等的 `.h` 文件 |
| Multiple Inclusion Guard | 多重包含保护 | 使用 `#ifndef`/`#define`/`#endif` 防止头文件被重复包含 |
| C Pre-processor | C 预处理器 | 在编译前处理 `#include`、`#define` 等指令的工具 |
| DRY Principle (Don't Repeat Yourself) | DRY 原则（不要重复自己） | 编程中应避免代码重复 |
| Modularization | 模块化 | 将程序拆分为独立的、可维护的模块 |
| Separate Compilation | 单独编译 | 各源文件独立编译，再由链接器合并 |
| Linker | 链接器 | 将编译单元合并为最终可执行程序的工具 |
| Compilation Unit | 编译单元 | 单个源文件经过预处理后的翻译单元 |
| Recursive Function | 递归函数 | 调用自身的函数 |
| Factorial | 阶乘 | n! = n × (n-1) × ... × 2 × 1 的数学运算 |
| Leaf Function | 叶函数 | 不调用任何其他函数的函数 |
| Function Calling Convention | 函数调用约定 | 定义函数调用时参数传递、返回值、寄存器使用的规则 |
| Callee-Saved Register | 被调用者保存寄存器 | 函数必须在使用前保存、返回前恢复的寄存器（R4-R11） |
| Caller-Saved Register | 调用者保存寄存器 | 函数可以自由覆盖的寄存器（R0-R3, R12） |
| Stack Pointer (SP) | 栈指针 (SP) | R13 寄存器，指向当前栈顶地址 |
| Program Counter (PC) | 程序计数器 (PC) | 保存当前执行指令地址的寄存器 |
| Link Register (LR) | 链接寄存器 (LR) | R14 寄存器，保存函数返回地址 |
| Stack Unwind | 栈展开 | 函数返回时栈逐渐恢复到先前状态的过程 |
| Deep Call Sequence | 深度调用序列 | 多层嵌套的函数调用链 |
| Lookup Table | 查找表 | 预先计算好的数据表，用于替代运行时计算 |
| Stack Overflow | 栈溢出 | 栈增长超出分配的内存空间 |
| Scope | 作用域 | 变量或标识符在程序中可见的范围 |
| Side Effect | 副作用 | 函数执行过程中对外部状态产生的可观察变化 |
| volatile | volatile 关键字 | 告知编译器变量可能被外部修改，禁止优化 |
| IAR Toolset | IAR 工具集 | IAR Systems 提供的嵌入式开发集成环境 |
| BL (Branch with Link) | 带链接分支指令 | 调用函数并将返回地址保存到 LR 的指令 |
| BX (Branch and eXchange) | 分支并交换指令 | 根据寄存器值跳转并可切换指令集 |
| Interrupt | 中断 | 处理器对外部或内部事件的异步响应机制 |
