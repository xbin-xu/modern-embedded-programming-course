# 第7课：数组与指针算术 / Lesson 7: Arrays and Pointer Arithmetic

Welcome to the Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll introduce you to arrays and basic pointer arithmetic in C. You will learn how to apply these concepts to take advantage of the more advanced features of the Stellaris GPIO DATA registers, which I hope will answer some questions asked in the comments to this video course posted on YouTube.

欢迎来到嵌入式系统编程课程。我是 Miro Samek。这节课我们来学 C 语言中的**数组（array）**和基本的**指针算术（pointer arithmetic）**。你会看到怎么用这些概念来发挥 Stellaris GPIO DATA 寄存器更高级的功能——YouTube 上不少同学在评论里问的问题，看完这节课应该就有答案了。

As usual, let's start with making a copy of the previous "lesson6" project and renaming it to "lesson7". If you are just joining the course, you can download the previous projects from state-machine.com/quickstart.

老规矩，先把上节课的"lesson6"项目复制一份，重命名为"lesson7"。如果你是刚开始跟这门课，可以从 state-machine.com/quickstart 下载之前的项目。

Get inside the new "lesson7" directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to "lesson0".

进入"lesson7"目录，双击工作区文件打开 IAR 开发环境。如果你还没有安装 IAR，回到第 0 课去看安装说明。

So, this is the program you created in "lesson6". Let's clean it up a bit and step into the debugger.

这就是你在第 6 课写的程序。我们稍作整理，然后进调试器看看。

As you can see, this program uses read-modify-write sequences to change the value of individual bits of the GPIO register without disturbing the other bits. For example, to set bit-1 controlling the red-LED, the program first reads the current value of the GPIOF DATA register with the LDR instruction. Next it uses the bit-wise OR to set the bit-1, and finally it writes the modified value back with the STR instruction.

可以看到，程序用的是**读-改-写（read-modify-write）**的方式来改变 GPIO 寄存器中单个位的值，同时不影响其他位。比如要置位控制红色 LED 的第 1 位，程序先用 LDR 指令读出 GPIOF DATA 寄存器的当前值，再用按位或（OR）把第 1 位置 1，最后用 STR 指令把修改后的值写回去。

The read-modify-write sequence is necessary, because all the GPIO bits are co-located in a single byte, with a single address. But imagine that each bit could be accessed separately through its own unique address. Or better yet, every possible combination of GPIO bits would have its own unique address. Then a single, atomic write operation to this particular address would change the selected bits without disturbing any other GPIO bits.

读-改-写之所以必要，是因为所有 GPIO 位都挤在一个字节里，共用一个地址。但想象一下——如果每个位都有自己的独立地址呢？再进一步，如果每一种位的组合都对应一个唯一地址呢？那只要对这个特定地址做一次**原子写操作（atomic write operation）**，就能只改变你想改的位，其他位完全不受影响。

In this lesson, I will show you how the Stellaris GPIO hardware allows you to do exactly this, so that you can replace the typical read-modify-write sequence with a single and atomic write operation.

这节课我就来展示 Stellaris GPIO 硬件是怎么做到这一点的——让你用一次原子写操作就能替代传统的读-改-写。

But before I explain HOW to do this, I think it's interesting to understand WHY bother. After all, the read-modify-write sequence is fast enough for most cases.

不过在我讲"怎么做"之前，先聊聊"为什么要费这个劲"。毕竟读-改-写在大多数场景下已经够快了。

Well, it turns out that it is not so much about the speed in this case, but rather to give you the ability to manipulate the individual GPIO bits truly independently; from any part of your code, including from interrupts.

实际上，在这个场景下，速度倒不是主要原因。关键在于——它能让你真正独立地操控每一个 GPIO 位，不管是从代码的哪个位置，包括从中断里。

Now, I realize that I haven't talked about interrupts yet, and I promise I will, because it is a fascinating subject, especially in embedded systems. But just for now let me only say that interrupts are a hardware-supported mechanism for a processor to abruptly change the flow of control in your program. When an interrupt occurs, a special hardware in the processor changes the value of the program counter register so that the processor suddenly starts executing a different piece of code called the interrupt service routine or ISR, which is typically quite short. When the ISR ends, the processor resumes the execution of the original code as though nothing happened.

我知道还没讲过**中断（interrupt）**，别急，后面一定会讲——这是嵌入式系统里非常精彩的话题。现在你只需要知道：中断是处理器用来突然改变程序执行流的一种硬件机制。中断发生时，处理器内部的特殊硬件会修改**程序计数器（program counter）**的值，让处理器跳去执行另一段代码，叫做**中断服务程序（ISR, Interrupt Service Routine）**——通常很短。ISR 执行完后，处理器回到原来的代码继续执行，就像什么都没发生过一样。

The interesting case is when the ISR changes some GPIO bits. If the interrupt happens to come in the middle of the read-modify-write cycle, after the main code reads the GPIO register, but before it writes the modified value back, any changes to the GPIO bits made in the interrupt service routine will get lost. This is because the main code will still use the previous value of the GPIO register, before the interrupt happened. This is the inherent problem with the read-modify-write sequence.

有意思的情况是：ISR 也去改某些 GPIO 位。如果中断刚好卡在读-改-写的中间——主代码刚读完 GPIO 寄存器、还没来得及写回修改值——那 ISR 里对 GPIO 位做的所有改动都会丢失。因为主代码用的还是中断发生前的旧值。这就是读-改-写方式天生的缺陷。

So that's the main reason why the designers of the Stellaris GPIO hardware devised a way to avoid the read-modify-write sequence and replace it with a single and atomic write operation.

正是这个原因，Stellaris GPIO 硬件的设计者才想出了这套方案——避开读-改-写，改用一次原子写操作搞定。

Here is how it works. The GPIO bits are connected to the CPU with the bunch of wires called a bus. Each bit is connected to both a dedicated data line and a dedicated address line as well. The bit can be changed only when the connected address line is 1, otherwise the bit is unaffected, regardless of the value of the attached data line.

原理是这样的。GPIO 位通过一组叫做**总线（bus）**的导线连接到 CPU。每个位都有自己专用的数据线和地址线。只有当对应的地址线为 1 时，这个位才能被改变；地址线为 0 时，不管数据线上是什么值，这个位都不受影响。

For example, to isolate the three GPIO bits connected to the LEDs, you need to write to the address ending with 0000111000 binary. Please note that the two lowest-order address lines A0 and A1 are not used, because the hardware requires all addresses to be divisible by 4.

举个例子，要单独隔离连接 LED 的那三个 GPIO 位，你需要写入一个以二进制 0000111000 结尾的地址。注意，最低两位地址线 A0 和 A1 没用到，因为硬件要求所有地址都必须能被 4 整除。

The data you write determine the state of the pins. For example, you can light up the red-LED, extinguish the blue-LED and light-up the green-LED, all in a single write operation.

你写入的数据决定了引脚的状态。比如，你可以一次写操作同时点亮红色 LED、熄灭蓝色 LED、点亮绿色 LED——一步到位。

I hope it is becoming clear that this hardware design requires many registers with unique addresses, because not only each GPIO bit has its own address-- for this you would need only 8 registers. Each combination of bits has its own address in this scheme. To cover all possible bit combinations of 8 GPIO bits, the Stellaris GPIO provides 256 32-bit DATA registers starting with the address 0x40025000.

希望你已经看出来了：这种硬件设计需要大量拥有独立地址的寄存器。因为不只是每个 GPIO 位有自己的地址——那只需要 8 个寄存器就够了——而是每种位的组合都有自己的地址。为了覆盖 8 个 GPIO 位的所有组合，Stellaris GPIO 提供了 256 个 32 位的 DATA 寄存器，起始地址是 0x40025000。

So far in the previous lessons, you have been using only the last of these registers called GPIO_PORTF_DATA_R corresponding to the offset 1111111100 binary, which is 0x3FC hex. This register obviously didn't isolate any bits, and enabled all 8 GPIO bits to be changed with data lines. In this lesson we will use the other registers.

在之前的课程里，你一直只用这些寄存器中的最后一个——GPIO_PORTF_DATA_R，对应的偏移量是二进制 1111111100，也就是十六进制 0x3FC。这个寄存器没有隔离任何位，所有 8 个 GPIO 位都可以通过数据线来改变。这节课我们要用到其他寄存器了。

So, now the question is how to access all those GPIO registers in C.

那么问题来了：在 C 语言中怎么访问这些 GPIO 寄存器呢？

One way is to hard-code the address directly, with the brute-force approach you learned in lesson 3. For example, to isolate only the bit-1 corresponding to the red-LED, you could manually compute the address by starting with the base address from the datasheet and adding to it the LED_RED bit left-shifted by two to skip the two unused address bits.

一种办法是直接硬编码地址——用第 3 课学过的那种暴力方式。比如，要单独隔离红色 LED 对应的第 1 位，你可以从数据手册查到基地址，然后加上 LED_RED 左移两位后的值（左移两位是为了跳过那两个未使用的地址位）。

You need to cast the synthesized address to a pointer and de-reference the pointer.

然后把合成出来的地址**强制转换（cast）**成指针，再**解引用（dereference）**这个指针。

Remembering that this address isolates just a single bit, it matters only what you write to this particular bit, and it is irrelevant what you write to the other bits. For the sake of demonstration, let's write 1 to the LED_RED bit and 0 to all the other bits. Let's check if this code compiles by pressing F7.

记住，这个地址只隔离了一个位，所以只有你写到这个位的值才有意义，其他位写什么都无所谓。为了演示，我们向 LED_RED 位写 1，其他位写 0。按 F7 看看能不能编译通过。

Now it is of course interesting to test this on the Launchpad board.

当然，拿到 LaunchPad 板子上跑一下才过瘾。

As you can see, the read-modify-write sequence is simplified to just the STR instruction to the address in R2, which is the GPIO base address plus the offset 8. When you step through the code, you see that the red-LED lights up, and the other LEDs stay unchanged, proving that the code does exactly what you wanted.

可以看到，读-改-写被简化成了仅仅一条 STR 指令，写入 R2 中的地址——也就是 GPIO 基地址加上偏移量 8。单步执行时，红色 LED 亮了，其他 LED 不变，说明代码确实按你的预期在工作。

So the code works, but is not very elegant. You can improve it significantly by applying the concept of an array.

代码能用，但不太优雅。引入数组的概念之后，可以大幅改进。

An array is a group of variables of the same type, occupying consecutive memory locations, such as the group of 256 identical GPIO DATA registers.

**数组**就是一组相同类型的变量，占据连续的内存位置——比如那 256 个一模一样的 GPIO DATA 寄存器。

In C you can declare an array by adding the number of elements in square brackets to a variable. For example, this is an array of two counters, each being a volatile integer. You can even initialize the whole array at once, by using the array initializer, like this.

在 C 语言中，声明数组就是在变量名后面加方括号，里面写上元素个数。比如，这里声明了一个包含两个计数器的数组，每个元素都是 volatile 整型。你还可以用初始化器一次性初始化整个数组，像这样。

Now, you can use the array elements as normal variables by referring to the elements by their numbers. The number in the brackets is called the array index and the first element of an array in C has always 0. The second is 1 and so on.

现在你可以通过编号来访问数组元素，跟使用普通变量一样。方括号里的数字叫做**数组索引（array index）**。在 C 语言中，数组的第一个元素索引总是 0，第二个是 1，依此类推。

Let's compile by pressing F7 to see if the compiler accepts the syntax.

按 F7 编译一下，看编译器认不认这个语法。

Arrays in C are closely related to pointers. The C compiler treats an array as a pointer, which points to the beginning of the array. To get a pointer to an element with index i, you simply need to add i to the array pointer.

C 语言中的数组跟**指针（pointer）**关系密切。编译器其实把数组当作一个指向数组开头的指针。要拿到索引为 i 的元素的地址，只要在数组指针上加 i 就行了。

So instead of counter[1] you can write *(counter + 1). This is an example of a simple pointer arithmetic.

所以 `counter[1]` 完全可以写成 `*(counter + 1)`。这就是一个简单的**指针算术**的例子。

The correspondence between arrays and pointers goes both ways, because every pointer can also be viewed as an array. For example, the standard LM4F header file defines the pointer GPIO_PORTF_DATA_BITS_R. This pointer can be used to access all 256 GPIO DATA registers as an array.

数组和指针之间的对应关系是双向的——每个指针也都可以当成数组来用。比如，标准的 LM4F 头文件里定义了一个指针 GPIO_PORTF_DATA_BITS_R。用这个指针，你可以像操作数组一样访问全部 256 个 GPIO DATA 寄存器。

So, for instance to access only the LED_RED bit, you can index into GPIO_PORTF_DATA_BITS_R like this...

所以，比如你想只访问 LED_RED 位，可以这样对 GPIO_PORTF_DATA_BITS_R 进行索引……

```c
GPIO_PORTF_DATA_BITS_R[LED_RED] = LED_RED;
```

which is exactly equivalent to using the following pointer arithmetic...

这完全等价于用指针算术这样写……

```c
*(GPIO_PORTF_DATA_BITS_R + LED_RED) = LED_RED;
```

Let's step into the debugger to see how these three options compare.

进调试器看看这三种写法的对比。

As you can see, all three implementation options write to the same address stored in the R4 register,

如你所见，三种写法写入的都是 R4 寄存器里存的同一个地址。

So this little experiment shows that indeed all the three alternatives are equivalent and generate the exact same machine code.

这个小实验说明：这三种写法确实完全等价，生成的机器码一模一样。

Going back to the source code, let me point out the very important difference between address arithmetic and pointer arithmetic. In the first case, you perform address arithmetic first and only then you cast the raw address to the unsigned long pointer. In this case, you had to left-shift the LED_RED value by two bits, to take into account the size of the GPIO register, which is 4-byte wide.

回到源代码，我要特别指出**地址算术（address arithmetic）**和指针算术之间一个非常重要的区别。第一种写法是先做地址算术，再把原始地址强制转换成 unsigned long 指针。这种情况下，你得手动把 LED_RED 的值左移两位，因为 GPIO 寄存器是 4 字节宽的。

In the second case, you use pointer arithmetic, because GPIO_PORTF_DATA_BITS_R is a pointer to unsigned long. In pointer arithmetic you don't need to scale the offset by the size of the element, because this is done automatically for you. This must be so, because of the equivalence between pointer arithmetic and array indexing.

第二种写法用的是指针算术，因为 GPIO_PORTF_DATA_BITS_R 是一个指向 unsigned long 的指针。指针算术中，你不需要手动乘以元素大小来缩放偏移量——编译器自动帮你做了。这是必须的，因为指针算术和数组索引本来就是等价的。

Of all these three options, I think that array indexing looks the cleanest, so I am going to leave this one and comment out the others.

三种写法里，我觉得数组索引看起来最干净，所以保留这个，把其他两种注释掉。

Now, let's use the array indexing technique to clear the red-LED. As you remember from the wiring diagram, this requires writing 0 to the LED_RED bit position.

现在用数组索引的方式来熄灭红色 LED。从接线图你应该记得，只需要在 LED_RED 位的位置写 0 就行。

```c
GPIO_PORTF_DATA_BITS_R[LED_RED] = 0;
```

Finally, I use the array indexing consistently for setting the blue-LED bit in the beginning.

最后，开头设置蓝色 LED 的地方也统一用数组索引来写。

```c
GPIO_PORTF_DATA_BITS_R[LED_BLUE] = LED_BLUE;
```

So, this is the final program that uses the fast and interrupt-safe technique for manipulating GPIO bits.

好，这就是最终版的程序——用快速且**中断安全（interrupt-safe）**的方式操控 GPIO 位。

Let's test this program on the Launchpad board...

拿到 LaunchPad 板上测试一下……

First, let's run full speed and watch the LEDs. As you can see the program works as before.

先全速运行，观察 LED。跟之前一样，程序工作正常。

When you break into the code, you can see that clearing the red-LED bit takes only one STR instruction to the GPIO address in R0.

暂停程序后可以看到，熄灭红色 LED 只需要一条 STR 指令，写入 R0 中的 GPIO 地址。

So, your program is about as good as it gets, except that, as it turns out, the Stellaris LM4F microcontroller can do even better.

程序已经相当不错了。不过，Stellaris LM4F 微控制器还能做得更好。

As you can find out in the Datasheet, the microcontroller has not one, but two peripheral busses.

翻翻数据手册你会发现，这款微控制器不只有一条，而是有两条**外设总线（peripheral bus）**。

Advanced Peripheral Bus (APB) and Advanced High-Performance Bus (AHB). The GPIO ports are connected to both.

一条叫**高级外设总线（APB, Advanced Peripheral Bus）**，另一条叫**高级高性能总线（AHB, Advanced High-Performance Bus）**。GPIO 端口同时连在这两条总线上。

The APB bus is the default and this is what you've been using so far. But APB is older and slower than AHB, and is kept only for backwards compatibility. So in the remaining minute of this lesson, I will show you how to switch to the faster and better AHB.

APB 总线是默认的，你之前一直用的就是它。但 APB 比 AHB 更老更慢，留下来只是为了**向后兼容（backwards compatibility）**。这节课最后一点时间，我来演示怎么切换到更快更好的 AHB。

First, you need to find in the Datasheet how to switch GPIO from the default APB to AHB. In the system control section, you find the GPIOHBCTL register, which does exactly this. You note that PortF is controlled by bit number 5.

首先，在数据手册里找到怎么把 GPIO 从默认的 APB 切换到 AHB。在系统控制部分，你会找到 GPIOHBCTL 寄存器——干的就是这事。PortF 由第 5 位控制。

```c
SYSCTL_GPIOHBCTL_R |= (1 << 5);
```

Next, you go to the LM4F header file and look for the GPIOHBCTL register. You copy the register name and set bit 5 in it.

然后，去 LM4F 头文件里找到 GPIOHBCTL 寄存器。复制寄存器名称，把第 5 位置 1。

Finally, you need to change all GPIO addresses from the APB address range, which is called APB aperture in the Datasheet, to the AHB aperture.

最后，要把所有 GPIO 地址从 APB 地址范围（数据手册里叫 APB **孔径（aperture）**）切换到 AHB 孔径。

You search again the LM4F header file for GPIO_PORTF and you find a set of registers with the _AHB suffix. So, you need to add this suffix to all the GPIO_PORTF registers in your program.

在 LM4F 头文件里再搜一下 GPIO_PORTF，你会发现一组带 _AHB 后缀的寄存器。所以，你需要给程序里所有的 GPIO_PORTF 寄存器都加上这个后缀。

Let's test this final version on the Launchpad board...

在 LaunchPad 板上测试一下这个最终版本……

This concludes this lesson about arrays and pointer arithmetic in C. Now you are an expert in Stellaris GPIO, so congratulations!

好，这节关于 C 语言数组和指针算术的课就到这里。恭喜你，现在你已经是 Stellaris GPIO 的专家了！

In the next lesson, I'll talk about C functions!

下一课，我们来聊 C 语言函数！

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅保持关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文 / English | 中文 / Chinese |
|---|---|
| Array | 数组 |
| Pointer | 指针 |
| Pointer Arithmetic | 指针算术 |
| Address Arithmetic | 地址算术 |
| Array Index | 数组索引 |
| Read-Modify-Write | 读-改-写 |
| Atomic Write Operation | 原子写操作 |
| Interrupt | 中断 |
| Interrupt Service Routine (ISR) | 中断服务程序 |
| Program Counter | 程序计数器 |
| Bus | 总线 |
| Cast | 强制转换 |
| Dereference | 解引用 |
| Volatile | volatile 关键字 |
| Backwards Compatibility | 向后兼容 |
| Peripheral Bus | 外设总线 |
| Advanced Peripheral Bus (APB) | 高级外设总线 |
| Advanced High-Performance Bus (AHB) | 高级高性能总线 |
| Aperture | 孔径（地址范围） |
| Interrupt-Safe | 中断安全的 |
| Base Address | 基地址 |
| Offset | 偏移量 |
| Bit-wise OR | 按位或 |
| Left-shift | 左移 |
| Datasheet | 数据手册 |
