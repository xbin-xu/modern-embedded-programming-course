# 第4课：点亮LED / Lesson 4: Blinking the LED

Welcome to the Embedded Systems Programming course. My name is Miro Samek and in this lesson I'm going to show you how to blink the LED on the Stellaris Launchpad board.

欢迎来到嵌入式系统编程课程。我是 Miro Samek，这节课我来带你把 Stellaris Launchpad 开发板上的 **LED**（发光二极管）点亮并让它闪烁。

---

For this lesson, I highly recommend that you download the User Manual of the board from the link I provide in the class notes for this video.

这节课我强烈建议你先把开发板的**用户手册**（User Manual）下载下来，链接在视频的课程笔记里。

---

If you don't have the board, you can still follow along in the Simulator, but your debugger views will be slightly different, and of course, you won't see the LED blink.

如果你手头没有开发板，用**模拟器**（Simulator）也可以跟着做，不过调试器界面会有些不一样，当然你也看不到 LED 实际闪烁的效果。

---

The manual describes how to connect the board to your computer via the provided USB cable.

手册里有讲到怎么用附带的 USB 线把开发板连到电脑上。

---

For today, you are mostly interested in the very nice, Red-Green-Blue User LED located at the right edge of the board.

今天我们主要关注的是开发板右侧边缘那颗漂亮的**红绿蓝（RGB）用户 LED**。

---

The manual explains how the components on the board are connected to the microcontroller. Among others, you can see that the User LED is connected to GPIO, which means General Purpose Input-Output.

手册里画了开发板上各个元件是怎么连到**微控制器**（microcontroller）的。其中可以看到，用户 LED 连接到了 **GPIO**，也就是**通用输入输出**（General Purpose Input-Output）。

---

At the end of the manual, you can find the schematics of the board.

手册最后还有开发板的**原理图**（schematics）。

---

On the first page of the schematics you can see that the R, G, and B components, of the User LED are powered by transistors, which are controlled by outputs LED_R, LED_G, and LED_B, respectively.

在原理图第一页上你能看到，用户 LED 的红、绿、蓝三个颜色分别由**晶体管**（transistors）驱动，而这些晶体管又分别受 `LED_R`、`LED_G`、`LED_B` 三个输出信号控制。

---

You can see these outputs again higher up in the schematics, where they connect to the microcontroller pins labeled Pin F1, Pin F2, and Pin F3. The letter F, in this case, stands for GPIO-F.

顺着原理图再往上找，你会再次看到这几个输出信号——它们连到了微控制器的 Pin F1、Pin F2、Pin F3 引脚上。这里的字母 F 代表的就是 GPIO-F 端口。

---

So now, that you have some idea of how the LED is connected, let's prepare the IAR project for this lesson. As usual, let's start with making a copy of the previous lesson3-project and renaming it to lesson4. If you don't have the lesson3-project, you can get it online from state-machine.com/quickstart.

好，现在你对 LED 的连接方式有了基本概念，咱们来准备这节课的 IAR 项目。老规矩，先把上一课的 lesson3 项目复制一份，重命名为 lesson4。如果你手头没有 lesson3 项目，可以从 state-machine.com/quickstart 下载。

---

Get inside the new lesson4 directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to lesson 0.

进入新的 lesson4 目录，双击工作区文件打开 IAR 工具链。如果你还没装 IAR，回到第 0 课去看安装说明。

---

If you have the Launchpad board, you should connect it to your PC now and make sure that: the debugger is configured for the TI Stellaris interface, and that the Download tab has the "Use flash loader" option checked.

如果你有 Launchpad 开发板，现在就把它连到电脑上。然后确认两件事：调试器要选 TI Stellaris 接口，Download 选项卡里"Use flash loader"要勾上。

---

If you don't have the board, configure the Debugger for Simulator and follow along.

没有开发板的话，把调试器设成 Simulator，跟着做就行。

---

Also, if you're using the board, please click on the TI Stellaris menu and check the "Reset will do system reset" option, so that the board will always start from clean reset.

另外，如果你用的是开发板，点开 TI Stellaris 菜单，把"Reset will do system reset"勾上。这样每次**复位**（reset）都能从干净的状态开始。

---

Finally, please rebuild the project entirely, to prevent the IAR from pulling in the main.c file from the previous lesson3 project.

最后，记得做一次完整重新构建，不然 IAR 可能会把上一课 lesson3 的 `main.c` 文件拉进来。

---

Now, let's go to the debugger and review quickly how the processor uses various addresses.

好，现在进入调试器，快速回顾一下处理器是怎么使用各种地址的。

---

First, at the low addresses starting with 0, you can see the machine instructions. This is the compiled code of your program, which is stored permanently inside the microcontroller. This means that the low addresses starting from 0 are mapped to the Flash memory.

首先，从 0 开始的低地址区域里，你能看到**机器指令**（machine instructions）。这就是你程序编译后的代码，永久存储在微控制器里。也就是说，从 0 开始的低地址被映射到了**闪存**（Flash memory）。

---

You also already know that the addresses starting from 0x2 are used for variables, such as the counter variable. That means that address 0x2 followed by all zeros marks the start of the Random Access Memory (RAM). Indeed, you can see a "hole" in the addresses right before the beginning of RAM, which simply means that the debugger could not read anything from these addresses, most likely because they are unused.

你也已经知道，以 `0x2` 开头的地址用来存放变量，比如计数器变量。也就是说，`0x2` 后面跟一串零，这个地址就是**随机存取存储器**（Random Access Memory，RAM）的起始位置。实际上你能看到 RAM 起始地址前面有一段"空洞"——调试器从这些地址读不到东西，大概率是因为它们根本没被用到。

---

When you probe further, at the address 0x20008000, you can see that the RAM ends--so it is an "island" extending for 0x8000 addresses, which is 32KB in decimal. This means that this microcontroller has 32KB of RAM.

再往下探查，到了 `0x20008000` 这个地址，RAM 就结束了。所以它是一座延伸了 `0x8000` 个地址的"岛屿"，换算成十进制就是 32KB。也就是说，这个微控制器有 32KB 的 RAM。

---

This is as much as you know about the addresses at this point. However, in order to blink the LED, which is your goal of this lesson, you need to learn more. Ideally, you need to know the "map" of all the various continents and islands, such as the RAM island, in the address space.

到目前为止，你对地址的了解就这些了。但要完成本课的目标——点亮 LED——你还得再学点东西。理想情况下，你需要搞清楚**地址空间**（address space）里各个"大陆"和"岛屿"（比如刚才说的 RAM 岛）的分布地图。

---

The document that describes the "memory map" of your microcontroller and much more in excruciating detail is called the "data sheet". I highly recommend that you download the datasheet for the specific LM4F microcontroller on your Launchpad board from the link I provide in the class notes.

描述微控制器**内存映射**（memory map）以及各种细节的文档，叫做**数据手册**（datasheet），内容极其详尽。我强烈建议你从课程笔记里的链接下载 Launchpad 开发板上这颗 LM4F 微控制器的数据手册。

---

But I need to warn you right away, that datasheets tend to be huge. This particular one is over 1200 pages long, which is still relatively short as the datasheets go. Luckily, these documents are not intended to be read cover-to-cover. In fact, a large part of being an embedded systems engineer consists of knowing *how* to find your way around the datasheets so that you can find the information you need quickly. I hope that you will pick up this skill gradually as you participate in this course.

不过我得先提醒你，数据手册通常都巨厚无比。这份是 1200 多页，在数据手册里还算短的。好在这些文档不是让你从头读到尾的。说实在的，做嵌入式工程师，很大一部分功力就在于知道怎么在数据手册里快速找到你需要的信息。希望你跟着这个课程学下去，这项技能会逐渐上手。

---

So for example, to find the "memory map" of your microcontroller, simply search the datasheet for the string "memory map".

举个例子，想找微控制器的"内存映射"，直接在数据手册里搜"memory map"这个字符串就行。

---

So, here it is. The memory map of a typical modern ARM Cortex-M microcontroller. This is a very nice and simple linear address space without any segments or memory banks. If you worked with other micro-controllers, especially the older 8-bitters, I hope you appreciate the simplicity of a linear 32-bit address space.

找到了。这就是典型的现代 ARM Cortex-M 微控制器的内存映射。一个非常漂亮、简洁的**线性地址空间**（linear address space），没有什么段（segments）或内存块（memory banks）。如果你以前用过其他微控制器，特别是老式的 8 位机，你应该会感受到 32 位线性地址空间有多简洁。

---

I hope you recognize the first "island" on this map - called "on-chip flash" from address 0 to 0x3FFFF which corresponds to 256KB of flash memory.

希望你认出了图上第一个"岛屿"——叫"片上闪存"（on-chip flash），地址从 0 到 `0x3FFFF`，对应 256KB 的闪存。

---

You should also recognize the familiar RAM island starting at 0x2 followed by all zeroes, which is named here "Bit-banded on-chip S-RAM", whereas S-RAM stands for Static-RAM.

你也应该认出了那个眼熟的 RAM 岛，起始地址 `0x2` 后面一串零，这里标注的是"Bit-banded on-chip SRAM"。**SRAM** 就是**静态随机存取存储器**（Static RAM）。

---

In the Peripherals "continent", you should note the GPIO ports. These islands are interesting, because you are looking for "GPIO Port F" to control your LED.

在**外设**（Peripherals）这片"大陆"上，注意看 GPIO 端口。这些岛屿很重要，因为你需要找到"GPIO Port F"来控制 LED。

---

Keep looking further down the memory map. Hey! Here is "GPIO Port-F" that you've been looking for! Copy the starting address to the clipboard and go back to the IAR debugger.

继续往下看。嘿！"GPIO Port F"就在这里！把起始地址复制到剪贴板，然后回到 IAR 调试器。

---

Paste the starting address of GPIO-F to the memory view and watch what comes up.

把 GPIO-F 的起始地址粘贴到内存视图中，看看会出来什么。

---

Oops, this address range of GPIO-F advertised in the datasheet appears empty. If this happens to you, don't despair. The typical reason is that the hardware block is switched off by default to save power. The technique of blocking the clock signal to certain parts of the chip, called **clock-gating**, is a very common practice in modern micro-controllers.

糟糕，数据手册里说的 GPIO-F 地址范围竟然是空的。遇到这种情况别慌。通常的原因是**硬件模块**（hardware block）默认是关闭的，为了省电。把芯片某些部分的时钟信号阻断掉，这种技术叫做**时钟门控**（clock gating），在现代微控制器里非常常见。

---

So, first you need to discover how to turn the GPIO-F block on, which means you need to go back to the datasheet.

所以，首先你得找到怎么把 GPIO-F 模块打开——又得回到数据手册里翻了。

---

Go back to the beginning of the document and search for the string "clock gating".

回到文档开头，搜"clock gating"。

---

Oh, here is something interesting, let's go to that page.

哦，这里有条有意思的内容，跳到那一页看看。

---

Let's search for the string GPIO in this section...

在这一节里搜一下"GPIO"……

---

Oh, here it is: the GPIO Clock gating control register.

找到了：**GPIO 时钟门控控制寄存器**（GPIO Clock gating control register）。

---

Let's take a closer look at the register description, because this is a very typical format commonly used in datasheets. The register is shown as a block of bits, always numbered from zero. The type of each bit is indicated, whereas RO means Read-Only, R/W means Read-Write, and WO would mean write-only.

我们来仔细看看这个寄存器的描述，因为这是数据手册里非常典型的格式。寄存器用一排位来表示，位编号从 0 开始。每个位都标注了类型：**RO** 表示只读（Read-Only），**R/W** 表示可读可写（Read-Write），**WO** 表示只写（Write-Only）。

---

The logically related groups of bits are documented below the register block picture, starting from the most significant bit. For you, the most interesting is the description of bit 5, because this bit enables the clock to GPIO Port F. This confirms that this register is exactly what you've been looking for.

逻辑上相关的位组会在寄存器图下面逐个说明，从最高位开始。对你来说最重要的是第 5 位的描述——这一位负责给 GPIO Port F 开启时钟。这就确认了，这个寄存器正是你要找的。

---

Copy the base address of the register to the Clipboard and notice that the additional offset 0x608 needs to be added to the base to get the complete register address.

把寄存器的基地址复制到剪贴板，注意还要加上 `0x608` 的偏移量，才是完整的寄存器地址。

---

Go back to the debugger, and open the additional memory view called Symbolic Memory to set bit-5 in the clock-gating register, while simultaneously watching the GPIO-F start address in the original memory view.

回到调试器，再打开一个 Symbolic Memory 内存视图，准备设置时钟门控寄存器的第 5 位，同时在原来的内存视图里盯着 GPIO-F 的起始地址。

---

Paste the clock-gating register base address from the datasheet to the symbolic memory view and don't forget to add to it the 0x608 offset.

把数据手册里时钟门控寄存器的基地址粘贴到符号内存视图里，别忘了加上 `0x608` 偏移量。

---

Now, go to the highlighted clock-gating register and edit its value to set bit-5, which, as you remember from lesson 1 about counting, is 20 hexadecimal. Hit enter.

现在，找到高亮的时钟门控寄存器，编辑它的值，把第 5 位置 1。还记得第 1 课讲计数的时候说过吧，第 5 位就是十六进制的 `0x20`。按回车。

---

Hey, the GPIO-F hardware block wakes up!

嘿，GPIO-F 硬件模块被唤醒了！

---

You are getting really close to being able to blink the LED, but you are not quite there yet. As you should read in the GPIO section of the datasheet, you still need to configure the GPIO-F bits 1, 2, and 3, which drive Red, Green, and Blue colors, respectively, as digital outputs.

离点亮 LED 已经很近了，但还差一步。你去翻翻数据手册的 GPIO 章节就会看到，还需要把 GPIO-F 的第 1、2、3 位配置成数字输出——它们分别控制红、绿、蓝三种颜色。

---

To set the pins direction as output, scroll down within the GPIO-F address block to the address 0x40025400 and set the bits 1, 2, and 3 to 1, which corresponds to 1110 in binary, and E in hex.

要设置引脚方向为输出，在 GPIO-F 地址块里往下滚到 `0x40025400`，把第 1、2、3 位都置 1。二进制是 `1110`，十六进制就是 `E`。

---

Additionally, to set the function for the pins as digital output, scroll further down within the GPIO-F address block to the address 0x4002551C and again set the bits 1, 2, and 3 to 1.

另外，还要把引脚功能设为数字输出。在 GPIO-F 地址块里继续往下滚到 `0x4002551C`，同样把第 1、2、3 位都置 1。

---

So, finally, you can try to control the LED. You do this through the GPIO-F Data register located at 0x400253FC.

好，终于可以试着控制 LED 了。你要操作的是位于 `0x400253FC` 的 GPIO-F **数据寄存器**（Data register）。

---

Scroll up to this register, and first set just bit 1, by writing hex-2 to the lowest nibble, again remembering that the bits are always counted from 0.

滚到这个寄存器，先只设第 1 位。往最低**半字节**（nibble）写入十六进制的 `0x2`——再次提醒，位编号永远从 0 开始。

---

Hey, it worked! The red LED lights up. You should give yourself a big pat on the back.

嘿，成功了！红色 LED 亮了。给自己鼓个掌吧。

---

Try to turn the LED off by writing 0. Cool.

再写个 0 把 LED 关掉。很酷吧。

---

How about setting bit 2, by writing hex 4. Wow, the LED turned blue--you are rocking.

那设第 2 位呢？写入 `0x4`。哇，LED 变蓝了——你越玩越溜了。

---

How about setting bit 3, by writing hex 8. You got it too.

再设第 3 位，写入 `0x8`。也成功了。

---

The heavy-lifting is really over, because coding this all up in C will be a piece of cake. All there is to controlling the LED boils down to writing numbers to specific memory addresses and this you already know how to do with pointers. Specifically, you are going to use the pointer-hack that I showed you at the end of lesson-3, because this technique allows you to write any number to any memory address you choose.

最难的部分已经过去了，接下来用 C 语言写代码就是小菜一碟。控制 LED 说到底就是往特定的内存地址写数字，而你已经知道怎么用指针来做了。具体来说，你要用第 3 课末尾我展示的那个指针技巧——它允许你向任意内存地址写入任意数值。

---

Clean the code up to leave only the pointer stuff.

先把代码清理一下，只保留指针相关的部分。

---

Actually, you won't even need the separate pointer variable, because you can de-reference the pointer-cast, as you will see in a minute.

其实你连单独的指针变量都不需要，因为可以直接对类型转换后的指针做**解引用**（dereference），等一下你就看到了。

---

In lesson-3 you used pointers to int. But ARM registers are unsigned, so change the pointer type to unsigned int.

第 3 课里你用的是 `int` 指针。但 ARM 寄存器是无符号的，所以把指针类型改成 `unsigned int`。

---

Replace the fabricated address from lesson-3 with the address of the clock-gating system register that you used to turn the GPIO-F block on.

把第 3 课里那个编造的地址，替换成你刚才用来开启 GPIO-F 模块的时钟门控寄存器的地址。

---

Enclose the whole pointer cast in parentheses and notice that this whole thing is a pointer to unsigned int. If so, then you should be able to de-reference this pointer by means of the star operator, just as you see in the line below.

把整个指针类型转换用括号括起来。注意，这整个表达式就是一个指向 `unsigned int` 的指针。既然是指针，你就可以用星号运算符对它解引用，就像下面那行代码一样。

---

Now, you can write to the pointer. As you recall from the experiment in the debugger, you need to set bit 5, that is hex 20 into this register. The value should be unsigned, which you indicate by the U suffix.

好，现在可以往指针写值了。还记得刚才在调试器里的实验吧，你需要把第 5 位置 1，也就是十六进制的 `0x20` 写入这个寄存器。这个值应该是无符号的，加个 `U` 后缀就行。

---

Get rid of the no longer used p_int pointer and check if the compiler likes your code by pressing F7.

删掉不再用的 `p_int` 指针，按 F7 看看编译器能不能通过。

---

All right, so you now can press on with the next register, which was the GPIO-F pin-direction register, where you need to set bits 1, 2, and 3 by writing hex-E.

好，接下来处理第二个寄存器——GPIO-F 的**引脚方向寄存器**（pin-direction register），需要写入十六进制的 `0xE` 来把第 1、2、3 位置 1。

---

Finally, the GPIO-F configuration requires also setting bits 1, 2, and 3 in the digital-function register.

最后，GPIO-F 的配置还要求在**数字功能寄存器**（digital-function register）里也把第 1、2、3 位置 1。

---

With this done, you can turn the red-color LED on and off by setting and clearing bit 1, in the GPIO-F data register.

这些都搞定之后，你就可以通过 GPIO-F 数据寄存器来设置和清除第 1 位，从而控制红色 LED 的亮灭了。

---

Actually, if you want to really blink the LED, you can't turn it on and off just once, but you need to keep doing this forever. To do this, you can wrap a while loop around the code for turning the LED on and off. The constant 1 in place of the condition means that the condition is always true, so the loop runs forever.

不过，想让 LED 真正闪烁，你不能只开关一次就完事，得不停地重复才行。办法很简单：在开关 LED 的代码外面套一个 `while` 循环。条件写常量 1，意味着条件永远为真，循环就会**永远跑下去**。

---

When you compile this code, you get a warning that the return statement downstream from the endless while is unreachable, which is true.

编译的时候会有个警告，说死循环后面的 return 语句永远执行不到。确实如此。

---

Let's test this code on the Launchpad board.

咱们把代码下载到 Launchpad 开发板上试试。

---

Note that setting the clock-gating register wakes up the GPIO-F block, as expected.

可以看到，设置时钟门控寄存器之后，GPIO-F 模块如预期被唤醒了。

---

Here you see that the red LED lights up.

这里红色 LED 亮了。

---

And now it goes dark again.

现在又灭了。

---

The endless loop also seems to be working.

无限循环看起来也在正常工作。

---

Well, if everything looks so good, let's run the code at full speed by pressing the Go button.

既然一切正常，那我们按 Go 按钮全速运行吧。

---

What the heck, the LED stays on all the time.

怎么回事？LED 一直亮着不闪了。

---

Let's break into the code by pressing the Break button and single-step again.

按 Break 暂停程序，再单步走走看。

---

This time everything is fine, yet when you run at full speed the blinking stops?

这回又一切正常了。可是一全速运行，闪烁又消失了？

---

Do you know what's the problem here?

你知道问题出在哪吗？

---

Yes, you are right, the program just runs too fast for a human eye to notice the rapid blinking of the LED. We need to slow the program down.

没错，问题就在于程序跑得太快了，人眼根本分辨不出 LED 在快速闪烁。我们得想办法让程序慢下来。

---

For this, you can use the counting while-loop that you learned in lesson-2. A loop like this wastes a lot of CPU cycles, but the delay can be controlled by setting the upper limit in the condition of the while.

还记得第 2 课学的计数 while 循环吧？就可以用在这里。这种循环会消耗大量 **CPU 周期**（CPU cycles），不过延时大小可以通过 while 条件里的上限来控制。

---

Note that you need a delay both after turning the LED on and after turning it off again.

注意，开灯之后要延时，关灯之后也要延时，两边都得加。

---

OK, so let's give it a try.

好，试试看。

---

This concludes the lesson about blinking an LED. Even though it might not seem like much, this is a very significant milestone in your embedded career. So congratulations!

点亮 LED 的课程就到这里。看起来好像没什么了不起的，但这可是你嵌入式生涯中一个非常重要的里程碑。恭喜你！

---

In the next lesson you will learn how to improve the blinky program by using the C pre-processor and the volatile keyword.

下一课，你将学习如何用 **C 预处理器**（C pre-processor）和 **volatile 关键字**来改进这个 blinky 程序。

---

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

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
| LED (Light Emitting Diode) | 发光二极管 | 通电后可发光的半导体器件 |
| GPIO (General Purpose Input-Output) | 通用输入输出 | 微控制器上可编程的通用引脚接口 |
| User Manual | 用户手册 | 开发板的使用说明文档 |
| Simulator | 模拟器 | 在软件中模拟硬件行为的工具 |
| microcontroller | 微控制器 | 集成了处理器、内存和外设的单芯片计算机 |
| schematics | 原理图 | 描述电路连接关系的图纸 |
| transistor | 晶体管 | 用于放大或切换电子信号的基本半导体器件 |
| Flash memory | 闪存 | 非易失性可编程存储器，用于永久存储程序代码 |
| RAM (Random Access Memory) | 随机存取存储器 | 可读写的易失性存储器 |
| SRAM (Static RAM) | 静态随机存取存储器 | 不需要刷新电路即可保持数据的 RAM |
| memory map | 内存映射 | 描述处理器地址空间中各区域分配情况的图表 |
| address space | 地址空间 | 处理器可访问的全部地址范围 |
| datasheet | 数据手册 | 详细描述芯片功能和寄存器的技术文档 |
| linear address space | 线性地址空间 | 连续的、无分段无分块的单一地址范围 |
| clock gating | 时钟门控 | 通过控制时钟信号来开关硬件模块以节省功耗的技术 |
| hardware block | 硬件模块 | 芯片中实现特定功能的独立电路单元 |
| RO (Read-Only) | 只读 | 只能读取不能写入的位或寄存器属性 |
| R/W (Read-Write) | 可读可写 | 既能读取也能写入的位或寄存器属性 |
| WO (Write-Only) | 只写 | 只能写入不能读取的位或寄存器属性 |
| register | 寄存器 | 处理器或外设中用于存储和控制数据的小型存储单元 |
| Data register | 数据寄存器 | 用于读取或写入实际数据的寄存器 |
| pin-direction register | 引脚方向寄存器 | 控制 GPIO 引脚为输入或输出方向的寄存器 |
| digital-function register | 数字功能寄存器 | 配置引脚为数字功能的寄存器 |
| nibble | 半字节 | 4 位二进制数据，即半个字节 |
| dereference | 解引用 | 通过指针获取其所指向地址处的值 |
| CPU cycles | CPU 周期 | 处理器执行一条指令所需的最小时钟单位 |
| C pre-processor | C 预处理器 | 在编译之前对源代码进行文本替换处理的工具 |
| volatile keyword | volatile 关键字 | 告诉编译器变量可能被外部因素修改，禁止优化的关键字 |
| reset | 复位 | 将处理器或系统恢复到初始状态的操作 |
| offset | 偏移量 | 相对于基地址的地址差值 |
