# 第12课：C 结构体与 CMSIS / Lesson 12: C Structures and CMSIS

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll talk about the C structures. I will also introduce you to the Cortex Microcontroller Software Interface Standard (CMSIS), which uses structures to access hardware in Cortex-M microcontrollers.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，本课我们来聊聊 C 语言中的**结构体**（structure）。同时我也会给你介绍**Cortex 微控制器软件接口标准**（Cortex Microcontroller Software Interface Standard，CMSIS）——它就是用结构体来访问 Cortex-M 微控制器硬件的。

As usual, let's get started with making a copy of the previous "lesson11" project and renaming it to "lesson12". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

老规矩，先把上次的"lesson11"项目复制一份，重命名为"lesson12"。如果你刚加入这个课程，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson12" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0". The latest version published by IAR is 7.10, which I'm using in this lesson.

进入新的"lesson12"目录，双击工作区文件打开 IAR 工具集。如果你还没装 IAR，先回去看第 0 课。IAR 目前发布的最新版本是 7.10，本课就用的这个版本。

So far in this course, you have been only using the so called scalar data types, such as the built-in integers or the exact-width integer types introduced in the last lesson 11.

到目前为止，我们在课程里用到的都是所谓的**标量数据类型**（scalar data types），比如内置的整数类型，或者上一课刚介绍的**定宽整数类型**（exact-width integer types）。

In lesson 7, you also learned about arrays, which is a way to group together variables of the *same* type. For example, array a contains 32 identical uint32_t integers.

第 7 课你还学过**数组**（array），它可以把*相同*类型的变量组合在一起。比如数组 a 就包含 32 个 `uint32_t` 整数。

Structures are another mechanism in C to group together variables, possibly of *different* types. The benefit of structures is that they permit a group of related variables to be treated as a unit instead of as separate entities.

**结构体**是 C 语言中另一种组合变量的机制，而且可以包含*不同*类型的变量。结构体的好处在于，它让一组相关的变量可以作为一个整体来处理，而不是各自为政。

In embedded systems, structures also permit you to access hardware in an elegant and intuitive way. I will explore this aspect later in this lesson.

在嵌入式系统中，结构体还能让你以一种优雅、直观的方式访问硬件。这部分我稍后再展开讲。

But first, let me explain the syntax and give you a few examples of structures in C.

先来说说语法，给你看几个 C 语言结构体的例子。

For this I will create a few structures for an embedded graphic LCD display. The basic object is a point, which groups together an x coordinate and a y coordinate.

我会以嵌入式图形 LCD 显示屏为例来创建几个结构体。最基本的对象是一个**点**（Point），它把 x 坐标和 y 坐标组合在一起。

The keyword struct introduces a structure declaration.

关键字 `struct` 用来引入一个**结构体声明**（structure declaration）。

An optional name called a *structure tag* may follow the word struct (as does the tag Point in this example).

`struct` 后面可以跟一个可选的名字，叫**结构体标签**（structure tag），比如这个例子里的 `Point`。

The variables enlisted between the braces in a structure are called members, so here x and y are members of struct Point. On a horizontally elongated LCD display, x might need a bigger dynamic range than y, so let's make x uint16_t and y only uint8_t.

结构体花括号里列出的变量叫做**成员**（member），所以这里的 x 和 y 就是 `struct Point` 的成员。在水平方向较宽的 LCD 显示屏上，x 可能比 y 需要更大的动态范围，所以我们把 x 设成 `uint16_t`，y 只用 `uint8_t`。

A structure declaration can be immediately followed by a list of variables. So for example, you can define variables pa and pb, both being Points.

结构体声明后面可以直接跟一个变量列表。比如，你可以同时定义 pa 和 pb 两个 `Point` 变量。

Actually, if you define variables immediately after the structure, you might omit the structure tag altogether.

实际上，如果你在结构体后面紧接着定义变量，连结构体标签都可以省掉。

I press F7 to quickly show you that the compiler accepts this form just fine.

我按 F7 编译一下，快速给你演示编译器完全接受这种写法。

However, more common is to define a structure followed with an empty list of variables. This is then the only situation in C, where the closing brace must be immediately followed by a semicolon.

不过更常见的做法是结构体后面跟一个空的变量列表。这也是 C 语言中唯一一个右花括号后面必须紧跟分号的场景。

A structure declaration that is not followed by a list of variables reserves no storage, but if the structure is tagged, you can use it later to declare variables as follows.

不跟变量列表的结构体声明不会占用存储空间，但如果结构体有标签，你就可以在后面用它来声明变量，像这样。

Nonetheless, this way of using structure types is still a little cumbersome, because you must always repeat the struct keyword in front of the structure tag. This is also not how it is in C++, where you don't need to repeat the keyword struct or class in front of all of class names.

不过这种用法还是有点繁琐，因为你每次都得在标签前面重复写 `struct` 关键字。C++ 里就不是这样——你不需要在每个类名前面都加上 `struct` 或 `class`。

But by now you should know the solution. In the previous lesson you learned about the typedef directive, which you can use to define the Point type as follows:

到这你应该想到解决方案了。上一课我们学过 `typedef` 指令，可以用它把 `Point` 定义成一个类型，像这样：

Now, you can define variables p1 and p2 of type Point without the keyword struct in front.

现在，你可以直接用 `Point` 类型来定义 p1 和 p2 变量，前面不需要再加 `struct` 关键字了。

An interesting wrinkle here is that, as you can see, the compiler accepted the same name Point for both the struct tag and the typedef name. This is because tag names in C occupy a different namespace than typedef names, variable names, or function names.

这里有个有趣的细节：编译器允许 `Point` 同时作为结构体标签和 `typedef` 的名字。这是因为 C 语言中的**标签名**（tag name）跟 `typedef` 名、变量名、函数名处于不同的**命名空间**（namespace）。

Interestingly also, you can place the typedef even before the struct declaration, and the compiler still likes it.

更有意思的是，你甚至可以把 `typedef` 放在 `struct` 声明之前，编译器照样接受。

Finally, there is a way to remove the repetition of the Point name altogether by using the un-tagged struct declaration inside the typedef.

最后还有一种办法可以完全避免 `Point` 这个名字的重复——在 `typedef` 里面用不带标签的 `struct` 声明。

In this last case the compiler obviously no longer recognizes the 'struct Point' type, but it still likes the typedef'ed Point type.

最后这种写法下，编译器当然不再认识 `struct Point` 这个类型了，但它仍然接受 `typedef` 出来的 `Point` 类型。

In summary, my preference is to use the last typedef form without the struct tag. Actually, this is also recommended by the latest safety C standard called MISRA:C-2012, where the advisory rule 2.4 recommends that a project should not contain unused tag declarations.

总结一下，我倾向于用最后这种不带标签的 `typedef` 形式。实际上，最新的 C 语言安全编码标准 **MISRA:C-2012** 也是这么建议的——它的建议规则 2.4 说，项目中不应该包含未使用的标签声明。

Struct tag names are almost never needed. The notable exception being the so called self-referential structures, such as nodes of linked lists or trees. But this is an advanced way of using structures, which goes beyond the scope of this course for the time being.

结构体标签几乎用不到。一个显著的例外是所谓的**自引用结构体**（self-referential structure），比如**链表**（linked list）或**树**（tree）的节点。不过这是结构体的高级用法，目前超出了本课程的范围。

So now, that you know all the different forms of declaring structure types, it's time to find out what you can actually do with them.

好，现在你已经了解了声明结构体类型的各种写法，该来看看你到底能用它们做什么了。

Well, the first thing you can do is to get access to the individual struct members.

首先，你可以访问结构体的各个成员。

As usual in C, this is achieved by the special "member access" operator, which is a dot.

在 C 语言里，这通过一个特殊的运算符来实现——**成员访问运算符**（member access operator），就是一个点号 `.`。

For example, here you obtain the size of the structure Point and assign it to p1 dot x member.

比如这里，你获取 `Point` 结构体的大小，然后赋给 `p1.x` 成员。

Of course, you can also use the '.' operator inside an expression. Here, for example, you calculate p1.x member minus unsigned 3 and assign it to p1.y member.

当然，`.` 运算符也可以用在表达式里面。比如这里，你用 `p1.x` 减去无符号整数 3，然后赋给 `p1.y` 成员。

At this point you need to know that the '.' operator has a very high precedence, which is higher than any arithmetic operators, such as '-'. That's why you typically don't need to use parentheses around the access to struct members.

这里你需要知道，`.` 运算符的**优先级**（precedence）非常高，比所有算术运算符（比如 `-`）都高。所以你通常不需要在结构体成员访问外面加括号。

So now it's finally time to step down to the machine code and see how your Point structure actually looks in memory and what's its size, because it is not three bytes--2 bytes for x and 1 byte for y--as you might expect.

好了，现在该深入到**机器码**（machine code）层面，看看你的 `Point` 结构体在内存中到底是什么样子、到底占多少字节了。因为它的实际大小并不是你可能会猜的 3 个字节——x 占 2 字节，y 占 1 字节。

For this part of the lesson, I'm going to use the Simulator, but you can also run the code on your LauchPad board.

这部分我会用**仿真器**（simulator）来演示，当然你也可以在自己的 LaunchPad 板上跑。

I cleanup the Watch 1 view and prepare it to watch the p1 structure variable. I also setup the Memory view to show the memory around the address of p1. As you can see in both views, p1 starts with all zeroes.

我把 Watch 1 窗口清理一下，准备监视 `p1` 结构体变量。同时打开 Memory 窗口，显示 `p1` 地址附近的内存。你可以看到两个视图中 `p1` 一开始全是零。

When you step through the code, you can see that the compiler treats p1.x as any other half-word variable and uses the already familiar STRH instruction to store a value in it.

单步执行代码时，你会看到编译器把 `p1.x` 当成一个普通的**半字**（half-word）变量来处理，用的就是你已经熟悉的 `STRH` 指令来存储值。

But the compiler evidently thinks that the size of the Point struct is 4 bytes, not 3.

但编译器显然认为 `Point` 结构体的大小是 4 字节，而不是 3 字节。

In the evaluation of the expression, you can see again that p1.y is treated as a byte-size variable, because the result of the expression is stored with the STRB instruction.

在表达式求值过程中，你可以再次看到 `p1.y` 被当作字节大小的变量处理——因为表达式的结果是用 `STRB` 指令存储的。

Looking in the memory view, you can now recognize the Point structure as the *four* bytes at address 0x2 followed by all zeroes. The p1.x member with value 4 is at the beginning of the structure, and p1.y member, with value 1 is immediately after it. Interestingly, the compiler has padded the structure by one byte after the p1.y member.

看看内存视图，你现在可以把 `Point` 结构体认出来了——地址 0x2 处的*四*个字节，后面全是零。值为 4 的 `p1.x` 成员在结构体的开头，值为 1 的 `p1.y` 成员紧随其后。有意思的是，编译器在 `p1.y` 成员后面做了**填充**（padding），多塞了一个字节。

To investigate the structure layout and padding, let's reverse the order of members and run again.

为了进一步研究结构体的**布局**（layout）和填充，我们把成员顺序反过来再跑一次。

As you can see, the order of members has also been reversed in memory, because p1.y is now at a lower address than p1.x.

可以看到，成员在内存中的顺序也跟着反过来了——`p1.y` 现在在比 `p1.x` 更低的地址上。

Looking in the memory view now, you can see that indeed the p1.y member at the beginning of the structure is followed by one unused byte before the p1.x member, so that the total structure size is 4 bytes.

现在再看内存视图，确实——结构体开头的 `p1.y` 成员后面有一个未使用的字节，然后才是 `p1.x` 成员，所以结构体总大小是 4 字节。

Compared to the previous run, this change of order should convince you that the compiler will honor the order of structure members, exactly as you typed them in the structure declaration. However, the compiler can and sometimes will insert extra padding bytes into your structure.

跟上次运行对比一下，成员顺序的改变应该能让你相信：编译器会严格按照你在声明中写的顺序来排列结构体成员。不过，编译器可以、有时也确实会在结构体中插入额外的**填充字节**（padding byte）。

The second interesting observation is that evidently, the compiler for ARM Cortex-M preferred to waste one byte of memory rather than place the p1.x half-word member at an odd address. The obvious question is why?

第二个有趣的发现是：ARM Cortex-M 的编译器宁愿浪费一个字节的内存，也不愿意把 `p1.x` 这个半字成员放在**奇数地址**（odd address）上。你肯定会问：为什么？

To investigate this last question, it would be interesting to somehow force the compiler not to waste the byte between the y and x members.

为了搞清楚这个问题，如果能想办法强制编译器不浪费 y 和 x 之间的那个字节，那就好了。

This is not possible in the standard C, but most embedded compilers provide some non-standard extension to pack the structure members tightly, without any padding.

标准 C 做不到这一点，但大多数嵌入式编译器都提供了非标准的扩展，可以把结构体成员**紧凑排列**（pack），不带任何填充。

The IAR compiler, provides for this an extended keyword __packed, which you can place in front of the struct keyword. So, let's do this right now and see what happens.

IAR 编译器为此提供了一个扩展关键字 `__packed`，放在 `struct` 前面就行。来，我们现在加上它看看会发生什么。

Also, to avoid value zero in p1.y, which will happen when the size of the struct will indeed be 3, let's change it to something else.

另外，为了避免 `p1.y` 出现零值（当结构体大小确实是 3 字节时就会这样），我们给它改个值。

The first interesting thing to notice in the Watch view is that this time around the p1.x member is allocated at an odd memory address.

在 Watch 视图中，首先要注意的是：这次 `p1.x` 成员被分配到了一个奇数内存地址上。

In the disassembly window notice that the code is still very efficient. In particular, the assignment to p1.x is still handled by the STRH instruction, even though p1.x is at the odd address.

看反汇编窗口，代码仍然非常高效。特别是，对 `p1.x` 的赋值仍然由 `STRH` 指令完成——即使 `p1.x` 位于奇数地址。

So, what's the big deal? The CPU handled the packed structure just fine.

那有什么大不了的？CPU 不是照样正常处理了紧凑结构体嘛。

To see a real difference, let's change the CPU...

要看真正的区别，我们得换一个 CPU……

Open the project options dialog box, go to General options, and select the Cortex-M0 core instead of Cortex-M4F.

打开项目选项对话框，进入 General Options，把内核从 Cortex-M4F 改成 Cortex-M0。

Next, go to the Debugger section and select the TI Stellaris interface and make sure that the "Use flash loaders" option is checked.

然后进入 Debugger 部分，选择 TI Stellaris 接口，并确保勾选了"Use flash loaders"选项。

Yep, that's right. I really intend to run the code not just in the Simulator, but on real hardware. If fact, I will run on the Tiva-C LaunchPad board, even though it has the Cortex-M4F processor, not Cortex-M0.

没错，我确实打算不仅用仿真器跑，还要在真实硬件上跑。实际上，我会在 Tiva-C LaunchPad 板上运行——虽然它用的是 Cortex-M4F 处理器，不是 Cortex-M0。

This way, I hope to convince you that Cortex-M processors are truly binary compatible. Specifically, from the chart of Cortex-M machine instructions, you can see that Cortex-M4 recognizes all instructions for Cortex-M3, which recognizes all instructions for Cortex-M0/M1. This is like a set of nested dolls, where any bigger doll can hold all the smaller ones inside.

通过这个方式，我想让你看到 Cortex-M 处理器确实是**二进制兼容**（binary compatible）的。具体来说，看 Cortex-M 机器指令图表你会发现：Cortex-M4 认识 Cortex-M3 的所有指令，而 Cortex-M3 又认识 Cortex-M0/M1 的所有指令。就像一组**俄罗斯套娃**，大套娃可以把所有小套娃装在里面。

After the code is programmed into the LauchPad board, quickly check that p1.x is still at the odd address and setup the memory view.

代码烧录到 LaunchPad 板之后，快速确认 `p1.x` 还在奇数地址上，然后把内存视图设置好。

When I start stepping through the code, notice that the code for the simple assignment of p1.x is bigger than before. To help you see the difference, I put the previous disassembly for Cortex-M4F side-by-side.

我开始单步执行，注意看——对 `p1.x` 简单赋值的代码比之前多了不少。为了让你看清楚区别，我把之前 Cortex-M4F 的反汇编代码并排放在一起了。

As you can see, the same C source code compiled for Cortex-M0 consists of two STRB instructions plus a logical-shift-right instruction, whereas Cortex-M4 achieved the same effect with just one STRH instruction.

可以看到，同样的 C 源代码编译给 Cortex-M0 后，变成了两条 `STRB` 指令加一条**逻辑右移**（logical shift right）指令，而 Cortex-M4 只用一条 `STRH` 指令就搞定了。

Interestingly, this is not because Cortex-M0 does not have the STRH instruction. In fact it does, but it can't use it at this point, because the STRH instruction in Cortex-M0 is less powerful than in Cortex-M4 and cannot access a half-word allocated at an odd address.

有意思的是，这并不是因为 Cortex-M0 没有 `STRH` 指令。它有的，但这里用不了——因为 Cortex-M0 的 `STRH` 指令没有 Cortex-M4 那么强，没法访问奇数地址上的半字。

So here for the first time you see that alignment of the data in memory matters to the processor. As an embedded programmer you absolutely need to know about it, because otherwise you will never understand why the compiler inserts padding into your structures. The compiler prefers to keep the data aligned instead of wasting the CPU cycles to access the mis-aligned data.

所以你第一次看到了：内存中数据的**对齐**（alignment）对处理器来说很重要。做嵌入式编程，你必须搞明白这一点，否则你永远无法理解为什么编译器要在结构体里插填充字节。编译器宁愿多占一点空间保持数据对齐，也不愿意浪费 CPU 周期去访问**未对齐的数据**（misaligned data）。

You can also see here, that packed structures might not be as efficient to access as the regular, un-packed structures. In other words, you need to use packed structures judiciously only when you absolutely need to avoid padding.

你在这里也可以看到，紧凑结构体的访问效率可能不如普通的非紧凑结构体。换句话说，你得**谨慎地**使用紧凑结构体——只有在确实需要避免填充的时候才用。

To conclude the experiment of running Cortex-M0 code on Cortex-M4 CPU, I just run the program so that you can see that the LauchPad board keeps blinking the LED as before, so it haply executes the M0 code.

总结一下在 Cortex-M4 上运行 Cortex-M0 代码的实验——我直接运行程序，你可以看到 LaunchPad 板上的 LED 仍然像之前一样闪烁，说明它确实执行了 M0 的代码。

So now, I would like to show you a few more things that you can do with structures.

好，接下来我再给你看看结构体的更多用法。

First, you can make more complex structures, including structures that contain other structures.

首先，你可以创建更复杂的结构体，包括包含其他结构体的结构体。

For example, a struct Window might contain two points for top_left and bottom_right corners of the window.

比如，一个 `Window` 结构体可以包含两个点——分别表示窗口的左上角（`top_left`）和右下角（`bottom_right`）。

Structures can also contain arrays, for example, a structure Triangle might contain an array of three corners, each one being a point. So you can see here that you can have arrays of structures.

结构体也可以包含数组。比如 `Triangle` 结构体可以包含一个三个角的数组，每个角都是一个点。所以你看，还可以有**结构体数组**（array of structures）。

The variables of structure types are sometimes called "instances", so here 'w' is an instance of Window and 't' is an instance of Triangle struct.

结构体类型的变量有时被称为**实例**（instance），所以这里的 `w` 是 `Window` 的一个实例，`t` 是 `Triangle` 结构体的一个实例。

Now, regarding accessing members of such complex structures, here are examples of accessing nested members of the Window and Triangle structures. Please note how the IAR editor helps you by displaying all possible members of a given structure.

至于怎么访问这种复杂结构体的成员呢，这里展示了访问 `Window` 和 `Triangle` 结构体**嵌套成员**（nested member）的例子。注意看 IAR 编辑器是怎么帮你的——它会显示结构体所有可能的成员供你选择。

But assignment is not limited just to the basic scalar types. You might also assign whole structures.

不过赋值不仅限于基本的标量类型，你还可以对整个结构体赋值。

For example, you can assign the whole p1 structure to the p2 structure, or the whole complex Window structure to another Window structure.

比如，你可以把整个 `p1` 结构体赋给 `p2`，或者把整个复杂的 `Window` 结构体赋给另一个 `Window`。

However, I hope you realize that more complex structures can occupy considerable memory, so an innocently looking assignment of structures can mean copying a sizable chunk of memory from one variable to another.

不过我希望你意识到，复杂的结构体会占用不少内存，一个看起来人畜无害的赋值操作，背后可能是在做一大块内存的复制。

Therefore, instead of copying entire structures from one place in memory to another, it is often more efficient to use *pointers* to structures.

所以，与其把整个结构体在内存中搬来搬去，通常更高效的做法是使用指向结构体的**指针**（pointer）。

As you perhaps remember from Lesson 3, a pointer type is created by simply adding a star after the type name. This is exactly how you make pointers to structure types as well. For example, pp is a pointer to the Point type, while wp is a pointer to the Window type.

你可能还记得第 3 课讲的，指针类型就是在类型名后面加个星号。结构体类型的指针也是一样的做法。比如 `pp` 是指向 `Point` 类型的指针，`wp` 是指向 `Window` 类型的指针。

To initialize a pointer you can take an address of a variable with the address-of operator. For example, you can set pp to point to the p1 Point, or wp to point to the w2 Window.

要初始化指针，你可以用**取地址运算符**（address-of operator）获取变量的地址。比如，你可以让 `pp` 指向 `p1`，或者让 `wp` 指向 `w2`。

The next question is how to access the members of a structure using a pointer. The C language provides two ways. First, as you learned in Lesson 3, you can apply the star operator in front of a pointer to obtain the object pointed to by the pointer. So, if pp is a pointer to Point, *pp is the Point type. From there you can access any member using the dot operator.

下一个问题是：怎么通过指针访问结构体的成员？C 语言提供了两种方式。第一种，正如你在第 3 课学到的，你可以在指针前面加星号运算符来获取指针指向的对象。所以如果 `pp` 是指向 `Point` 的指针，那 `*pp` 就是 `Point` 类型，然后你就可以用点运算符访问任何成员了。

Note that the parentheses around *pp are necessary, because the precedence of the '.' operator is very high, even higher than the '*' operator.

注意 `*pp` 外面的括号是必须的，因为 `.` 运算符的优先级非常高，比 `*` 运算符还高。

In a similar way, you can de-reference the wp pointer to set the top_left member. Notice that here again you can see an assignment of whole structures, because both top_left member and *pp are Points.

类似地，你可以**解引用**（dereference）`wp` 指针来设置 `top_left` 成员。注意这里又出现了整个结构体的赋值——因为 `top_left` 成员和 `*pp` 都是 `Point` 类型。

But pointers to structures are so frequently used in C that the language offers an alternative operator 'arrow' as a quicker way to access a structure member via a pointer. So, the following two assignments are equivalent to the previous versions.

但指向结构体的指针在 C 语言中太常用了，所以语言专门提供了另一种运算符——**箭头运算符**（arrow operator）`->`，让你通过指针访问成员更方便。所以下面这两个赋值跟前面的写法是完全等价的。

Let's now take a look in the debugger to see how these more complex structures are accessed. You can keep the Cortex-M0 core, but remove the packed extended keyword from the Point structure to avoid muddying the picture with accessing misaligned data.

现在让我们到调试器里看看这些更复杂的结构体是怎么被访问的。你可以继续用 Cortex-M0 内核，但要把 `Point` 结构体上的 `__packed` 扩展关键字去掉，免得未对齐数据访问干扰我们的观察。

Step through the code to where the Window structure is accessed and put the w variable in the Watch window making sure that all the members are expanded and visible.

单步执行到访问 `Window` 结构体的地方，把 `w` 变量加到 Watch 窗口里，确保所有成员都展开显示。

Now single-step through the disassembly and note a few interesting things. First, you should notice the STRH instruction, which means that it is available in Cortex-M0, but only when the Point member x is aligned.

接下来在反汇编中单步执行，注意几个有趣的地方。首先你应该看到 `STRH` 指令——说明它在 Cortex-M0 中是可用的，但前提是 `Point` 成员 x 必须**对齐**（aligned）。

Second, please note the square brackets after the STRH instruction. This means that the content of the R0 register must be stored at the address in R1 plus the offset of 2 bytes in this case.

其次，注意 `STRH` 指令后面的方括号。这表示 R0 寄存器的内容要存储到 R1 中的地址再加上 2 字节**偏移量**（offset）的位置。

This addressing mode with additional offset from a given base register is very convenient for accessing structures. In fact, it has probably been designed specifically for this purpose. Because, a structure for the compiler is nothing else but a bunch of offsets, one for each member, from the beginning of the structure.

这种从给定基址寄存器加上额外偏移量的**寻址模式**（addressing mode），用来访问结构体非常方便。实际上它可能就是专门为此设计的——因为对编译器来说，结构体不过是一堆偏移量而已，每个成员对应一个，从结构体开头算起。

Here again you can see this addressing mode used in the STRB instruction to access the y member of the bottom_right point in the Window struct. As you can immediately see this member has the offset of 4 bytes from the beginning of the Window structure.

这里你又可以看到这种寻址模式——`STRB` 指令用它来访问 `Window` 结构体中 `bottom_right` 点的 y 成员。你可以直接看到，这个成员相对于 `Window` 结构体开头的偏移量是 4 字节。

Let's confirm these offsets by looking at the address of the w variable in the memory view.

让我们到内存视图里看看 `w` 变量的地址，确认一下这些偏移量。

So here is the whole structure

好，这就是整个结构体

here is the 2-byte offset to top_left.x member

这里是到 `top_left.x` 成员的 2 字节偏移量

and here is the 4-byte offset to bottom_right.y member.

这里是到 `bottom_right.y` 成员的 4 字节偏移量。

So, now I hope you are really getting ready for the idea of applying structures to access hardware registers in an embedded microcontroller, such as the SYS-control registers to enable or disable various peripherals, or the GPIO registers through which you can turn the various color LEDs on and off on your LanuchPad board.

好了，我希望你已经做好准备接受这个想法了——用结构体来访问嵌入式微控制器中的**硬件寄存器**（hardware register），比如用来启用或禁用各种外设的**系统控制寄存器**（SYSCTL register），或者用来控制 LaunchPad 板上各种颜色 LED 开关的 **GPIO 寄存器**（GPIO register）。

Please note that the way you have accessed the hardware registers so far was quite primitive and did not involve structures. You used the lm4f header file, which defined the hardware registers of your LM4F microcontroller simply as preprocessor macros.

注意，到目前为止你访问硬件寄存器的方式还比较原始，没有用到结构体。你用的是 `lm4f` 头文件，它把 LM4F 微控制器的硬件寄存器简单地定义成了**预处理器宏**（preprocessor macro）。

For example, the GPIO_PORTF_AHB_DIR register was defined as de-referencing of a pointer with the hardcoded address of the register from the datasheet.

比如，`GPIO_PORTF_AHB_DIR` 寄存器就是被定义成对某个指针的解引用，而那个指针指向的地址是直接从数据手册里抄过来的硬编码值。

All other registers were defined in a similar way.

所有其他寄存器也都是类似这样定义的。

In contrast, the idea now is to design a C structure in such a way that its data members would correspond to all the registers within a given hardware block, such as SYCTL or GPIO.

而现在的新思路是：设计一个 C 结构体，让它的数据成员一一对应某个**硬件块**（hardware block）里的所有寄存器，比如 SYSCTL 或 GPIO。

For that, you need to consult the datasheet. Here, I have the the datasheet of the specific TM4C microcontroller used on your Tiva LauchPad board, which is also identical to the LM4F microcontroller used on the slightly older LM4F LaunchPad. This PDF is available either directly from Texas Instruments or from the state-machine.com/quickstart web-page accompanying this video course.

为此你需要查阅**数据手册**（datasheet）。这里打开的是你的 Tiva LaunchPad 板上使用的 TM4C 微控制器的数据手册——它跟稍早的 LM4F LaunchPad 上用的 LM4F 微控制器完全相同。这份 PDF 可以直接从德州仪器获取，也可以从本课程配套网页 state-machine.com/quickstart 下载。

For example, in the description of the General-Purpose Input/Output block, you can find the section "Register Map". As you can see there, all registers within the GPIO block are specified as offsets from the base address of the block. The register map provides thus a blueprint of the GPIO structure in C, because as you recall from the debug session a minute ago, a structure is just a bunch of offsets, one for each of its members.

比如，在**通用输入/输出**（General-Purpose Input/Output，GPIO）块的描述中，你可以找到"Register Map"这一节。如你所见，GPIO 块中的所有寄存器都表示为从**基地址**（base address）开始的偏移量。所以寄存器映射表其实就是 C 语言中 GPIO 结构体的**蓝图**（blueprint）——因为刚才调试时你也看到了，结构体就是一堆偏移量，每个成员一个。

So, given the datasheet, I hope you start to see how a C structure for the GPIO block can be written.

有了数据手册，你应该开始能看出 GPIO 块的 C 结构体该怎么写了。

The good news is that you don't need to do it, because it has already been done by the microcontroller vendor.

好消息是——你不需要自己写，芯片厂商已经帮你写好了。

In fact, to your current project directory, I have copied the tm4c_cmsis.h header file, which contains definitions of structures for all hardware blocks found in your microcontroller.

事实上，我已经把 `tm4c_cmsis.h` 头文件复制到了你当前的项目目录中，这个文件里包含了你微控制器中所有硬件块的结构体定义。

When you open the tm4c header file and scroll down a bit, you can see that it contains typedef'ed structure definitions. For example, here you can see the structure for the System Controller--SYSCTL.

打开 `tm4c` 头文件往下翻一翻，你会看到里面全是 `typedef` 定义的结构体。比如这里，你看到的就是**系统控制器**（System Controller，SYSCTL）的结构体。

And right below you can see the structure for the GPIO.

紧接着下面是 GPIO 的结构体。

As a quick exercise, let's compare the structure definition in the tm4c header file with the GPIO Register Map in the datasheet.

做个小练习：我们来对比一下 `tm4c` 头文件中的结构体定义和数据手册中的 GPIO 寄存器映射表。

As you can see the first register in the datasheet is GPIODATA, but when you look closer, you can see that there is a big gap of 400 hex in the offests to the next register in the map. This is because GPIODATA is not a single register, but rather a group of 256 4-byte registers, which I discussed in detail in Lesson 7.

可以看到，数据手册里的第一个寄存器是 `GPIODATA`，但仔细看你会发现，到下一个寄存器的偏移量之间有一个 0x400 的大间隙。这是因为 `GPIODATA` 不是单个寄存器，而是 256 个 4 字节寄存器组成的一组——这个我在第 7 课里详细讲过。

In the C structure, the group of 256 DATA registers is represented as an array of 255 Data_bits member plus the DATA structure member. Again, please refer to Lesson 7 to see why this last DATA register is special.

在 C 结构体中，这 256 个 DATA 寄存器被表示为一个包含 255 个 `Data_bits` 成员的数组，再加上 `DATA` 结构体成员。至于为什么最后一个 DATA 寄存器是特殊的，还是请回顾第 7 课。

All the following registers in the GPIO map have a one-to-one correspondence to the members of the C structure in the header file.

GPIO 映射表中后面的所有寄存器，跟头文件中 C 结构体的成员之间都是**一一对应**（one-to-one correspondence）的关系。

I only wanted to point out the gap in the offsets after the GPIO Alternate Functin SELlect register. Such a gap is represented in the C struct as the RESERVED1[] array member, so that the following members align exactly at the offsets specified in the datasheet.

我特别想指出的是 GPIO Alternate Function Select 寄存器之后偏移量中的那个间隙。这种间隙在 C 结构体中被表示为 `RESERVED1[]` 数组成员，这样后面的成员就能精确对齐到数据手册中指定的偏移量了。

Finally, I'm sure that you are wondering about the types used in the C structure. I hope you recognize the uint32_t fixed with integer type, which means that all the registers are 32-bit wide. But the __IO,__I and __O identifiers surely look strange.

最后，我猜你一定对 C 结构体中使用的类型感到好奇。`uint32_t` 这个定宽整数类型你应该认得——它说明所有寄存器都是 32 位宽。但 `__IO`、`__I` 和 `__O` 这些标识符看起来确实有点奇怪。

As it turns out these are the preprocessor macros defined in the Cortex Microcontroller Software Interface Standard (CMSIS), which the tm4c header file is part of.

其实它们是 **CMSIS**（Cortex 微控制器软件接口标准）中定义的预处理器宏，`tm4c` 头文件就是 CMSIS 的一部分。

I will show you the actual definitions of these CMSIS macros in a minute, but first just notice that the macros correspond to the third column in the datasheet, whereas IO, which stands for Input/Output, corresponds to Read/Write. I, which stands for Input, corresponds to Read-Only. And O, which stand for output, corresponds to Write-Only.

等一下我会给你看这些 CMSIS 宏的实际定义，但先注意一点：这些宏对应的是数据手册里的第三列。`IO` 代表 Input/Output，对应 Read/Write（读写）；`I` 代表 Input，对应 Read-Only（只读）；`O` 代表 Output，对应 Write-Only（只写）。

Going back to CMSIS, you can see that the tm4c header file is not completely standalone, but rather it includes the core_cm4.h header file. This header file is part of the CMSIS industry standard and IAR distributes it as an integral part of the toolset.

回到 CMSIS，你可以看到 `tm4c` 头文件并不是完全独立的，它还包含了 `core_cm4.h` 头文件。这个头文件是 CMSIS 行业标准的一部分，IAR 把它作为工具集的组成部分一起分发。

To see the core_cm4.h header file, go to the installation directory of your IAR toolset, get into arm, CMSIS, Include, and open the file.

要查看 `core_cm4.h` 头文件，进入 IAR 工具集的安装目录，依次进入 arm、CMSIS、Include，然后打开这个文件。

So, here are the definitions of the macros __I,__O, and __IO. These macros turn out to be defined as the volatile keyword, which I hope makes sense to you. It also means that the volatile qualifier can be used for individual structure members.

好，这就是 `__I`、`__O` 和 `__IO` 宏的定义。它们实际上被定义为 `volatile` 关键字——希望这对你来说说得通。这也意味着 `volatile` 限定符可以用在单个结构体成员上。

The __I macro has additional qualifier const, which means that such designated variable is constant and cannot be modified. I hope to cover the use of the 'const' keyword and the concept of const-correctness of programs in one of the future lessons.

`__I` 宏多了一个 `const` 限定符，意思是这类变量是**常量**（constant），不能被修改。关于 `const` 关键字的使用和程序的 **const 正确性**（const-correctness），我打算在以后的课程中再专门讲。

To finish with the core_cm4 header file, I only want to show you that it too contains structures that define hardware registers. Here for example is the structure for the Nested Vectored Interrupt Controller (NVIC), which is part of every Cortex-M core and therefore it make sense to define it in the CMSIS core header file. You will use the NVIC in the future lessons about interrupts.

最后关于 `core_cm4` 头文件，我只想再给你看一样东西——它里面也包含了定义硬件寄存器的结构体。比如这里就是**嵌套向量中断控制器**（Nested Vectored Interrupt Controller，NVIC）的结构体。NVIC 是每个 Cortex-M 内核都有的，所以放在 CMSIS 核心头文件里定义很合理。以后讲到**中断**（interrupt）的课程中你会用到 NVIC。

With all this information, you can finally re-write your code to use the CMSIS-compliant way of accessing hardware using structures.

有了这些信息，你终于可以重写代码，改用符合 CMSIS 规范的方式——通过结构体来访问硬件了。

The last piece of the puzzle you need to understand is how to make sure that the SYSCTL or GPIO structures are at the right base addresses. This might seem like a big problem, because so far you have only created instances of Point, Window, or Triangle structures, where the compiler controlled their placement in memory.

你需要理解的最后一块拼图是：怎么确保 SYSCTL 或 GPIO 结构体放在正确的基地址上。这看起来好像是个大问题，因为到目前为止你创建的 `Point`、`Window`、`Triangle` 实例，都是编译器自动安排它们在内存中的位置的。

But this problem is not really new, and you have encountered it before, already in Lesson 4. The solution is to use *pointers* to structures initialized to the hard-coded base address from the datasheet.

但这个问题其实并不新鲜，你在第 4 课就遇到过了。解决方案是：使用指向结构体的指针，并把它初始化为数据手册中的硬编码基地址。

Indeed, this is exactly what's done in the tm4c header file.

没错，`tm4c` 头文件里正是这么做的。

At the end of the file, you can find #-defined base addresses of various hardware blocks.

在文件末尾，你可以找到各个硬件块用 `#define` 定义的基地址。

And below that you have a bunch #-defined hard-coded pointers to various structure types.

再往下，是一系列用 `#define` 定义的硬编码指针，分别指向各种结构体类型。

For example, the SYSCTL macro defines a pointer to the SYSCTL_Type structure, which is hard-coded to the SYSCTL base address.

比如，`SYSCTL` 宏定义了一个指向 `SYSCTL_Type` 结构体的指针，这个指针被硬编码为 SYSCTL 的基地址。

Similarly, the GPIOF-high-speed macro defines a pointer to the GPIO_Type structure, which is hard-coded to the GPIO_PORTF_AHB base address.

类似地，`GPIOF` 高速宏定义了一个指向 `GPIO_Type` 结构体的指针，硬编码为 `GPIO_PORTF_AHB` 的基地址。

The first step in replacing the way you access the hardware is to change the header file name to tm4c_cmsis.h. You can also remove the lm4f header file from the project.

替换硬件访问方式的第一步，是把头文件名改成 `tm4c_cmsis.h`。你也可以把 `lm4f` 头文件从项目中删掉。

Next, you replace every register access using the new form.

然后把每个寄存器访问都替换成新的写法。

For example, to replace the first register access, you take the SYSCTL pointer and append the member access operator. At this point, the IAR editor will help you by displaying all the members of this structure. You choose the appropriate register from the list. To know for sure which one, you might need to consult the datasheet and the SYSCTL_Type structure definition.

比如替换第一个寄存器访问：你拿 `SYSCTL` 指针，加上成员访问运算符。这时候 IAR 编辑器会弹出该结构体所有成员的列表来帮你。你从列表里选正确的寄存器就行了。要确定具体选哪个，你可能需要对照数据手册和 `SYSCTL_Type` 结构体定义。

You proceed in a similar way with all other registers.

其他寄存器也用同样的方式替换。

The GPIO Port-F Data register is actually an array of 255 registers, as you saw a few minutes ago.

GPIO Port-F Data 寄存器实际上是一个 255 个寄存器的数组，你刚才已经看到了。

As you can see, the program compiles cleanly.

可以看到，程序编译通过，没有报错。

The last thing left to do is to verify that the LED still blinks as before.

最后要做的就是验证 LED 是否仍然像以前一样闪烁。

This concludes this lesson about the structures in C and the CMSIS standard.

本课关于 C 语言结构体和 CMSIS 标准的内容就到这里。

In the next lesson, I will talk about pointers to functions, which you will need to understand the startup code and interrupt handlers.

下一课我们来聊聊**函数指针**（pointer to function），你需要理解它才能看懂**启动代码**（startup code）和**中断处理程序**（interrupt handler）。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Structure / structure | 结构体 | C 语言中将不同类型变量组合在一起的数据类型 |
| Structure Tag | 结构体标签 | `struct` 关键字后可选的标识符名称 |
| Member | 成员 | 结构体花括号内定义的变量 |
| Scalar Data Types | 标量数据类型 | 只能保存单个值的基本数据类型 |
| Exact-Width Integer Types | 定宽整数类型 | 具有确定位宽的整数类型，如 `uint32_t` |
| Padding | 填充 | 编译器为对齐而插入的额外字节 |
| Alignment | 对齐 | 数据在内存中按特定边界存放的要求 |
| Misaligned Data | 未对齐的数据 | 数据地址不满足对齐要求 |
| Pack | 紧凑排列 | 去除填充字节使结构体成员紧密排列 |
| `__packed` | `__packed` 关键字 | IAR 编译器扩展关键字，用于紧凑结构体 |
| Binary Compatible | 二进制兼容 | 不同处理器间可直接执行相同机器码 |
| Member Access Operator | 成员访问运算符 | 点号 `.` 运算符，用于访问结构体成员 |
| Arrow Operator | 箭头运算符 | `->` 运算符，通过指针访问结构体成员 |
| Dereference | 解引用 | 通过指针获取其指向的对象 |
| Address-of Operator | 取地址运算符 | `&` 运算符，获取变量的内存地址 |
| Addressing Mode | 寻址模式 | 指令访问内存的方式，如带偏移量的基址寻址 |
| Offset | 偏移量 | 相对于基地址的字节距离 |
| Base Address | 基地址 | 硬件块或结构体在内存中的起始地址 |
| Instance | 实例 | 结构体类型的变量 |
| Nested Member | 嵌套成员 | 结构体中包含的结构体的成员 |
| Namespace | 命名空间 | C 语言中标识符的不同分类域 |
| Precedence | 优先级 | 运算符在表达式中的执行顺序 |
| Self-Referential Structure | 自引用结构体 | 包含指向自身类型指针的结构体 |
| Linked List | 链表 | 通过指针链接的数据结构 |
| CMSIS | Cortex 微控制器软件接口标准 | Cortex Microcontroller Software Interface Standard |
| Hardware Register | 硬件寄存器 | 微控制器中外设的控制寄存器 |
| Register Map | 寄存器映射表 | 数据手册中列出寄存器偏移量的表格 |
| Hardware Block | 硬件块 | 微控制器中特定功能的外设模块 |
| NVIC | 嵌套向量中断控制器 | Nested Vectored Interrupt Controller，Cortex-M 内核的中断管理单元 |
| Interrupt | 中断 | 硬件或软件触发的异步事件处理机制 |
| Interrupt Handler | 中断处理程序 | 响应中断请求而执行的函数 |
| Startup Code | 启动代码 | 程序运行前执行的初始化代码 |
| Pointer to Function | 函数指针 | 指向函数的指针变量 |
| `volatile` | `volatile` 关键字 | 告知编译器变量可能被外部修改，禁止优化 |
| `const` / Const-Correctness | `const` 关键字 / const 正确性 | 限定变量为只读及正确使用 `const` 的编程实践 |
| Preprocessor Macro | 预处理器宏 | 由预处理器进行文本替换的定义 |
| Blueprint | 蓝图 | 用于指导结构体设计的模板或参照 |
| MISRA:C-2012 | MISRA:C-2012 标准 | 汽车行业软件可靠性协会发布的 C 语言安全编码标准 |
| Half-Word | 半字 | 16 位（2 字节）的数据单位 |
| Simulator | 仿真器 | 在软件中模拟硬件执行的环境 |
| Datasheet | 数据手册 | 芯片厂商提供的技术参考文档 |
| One-to-One Correspondence | 一一对应 | 两个集合间元素完全匹配的关系 |
| Logical Shift Right | 逻辑右移 | 将二进制位向右移动，高位补零 |
| STRH / STRB | 半字/字节存储指令 | ARM 中存储半字和单字节的指令 |
