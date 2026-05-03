# 第3课：变量与指针 / Lesson 3: Variables and Pointers

Welcome to the Embedded Systems Programming course. My name is Miro Samek and in this lesson I'm going to talk about variables and pointers.

欢迎来到嵌入式系统编程课程。我是 Miro Samek，这节课我们来聊聊**变量**（variables）和**指针**（pointers）。

---

Let's start with making a copy of the previous lesson2-project and renaming it to lesson3. If you don't have the lesson2-project, you can get it online from state-machine.com/quickstart.

先把上一课的 lesson2 项目复制一份，重命名为 lesson3。如果你手头没有 lesson2 项目，可以去 state-machine.com/quickstart 下载。

---

Get inside the new lesson3 directory and double-click on the workspace file to open the IAR toolset. If you don't have the IAR toolset, go back to lesson 0.

进入 lesson3 目录，双击工作区文件，用 IAR 工具集打开。如果你还没装 IAR，回到第 0 课去看安装说明。

---

So, here is the C program you've created in lesson 2. Let's clean it up a little bit and have a quick look in the debugger to see where the counter variable lives and how it is accessed.

这就是你在第 2 课写的那个 C 程序。我们稍微整理一下，然后进调试器看看 counter 变量到底存在哪里、又是怎么被访问的。

---

As you step through the code and watch the Locals window, you see that the counter variable lives in the R0 register and is accessed by the machine instructions directly.

单步执行代码，同时看一眼 Locals 窗口——你会发现 counter 变量就在 **R0 寄存器**（R0 register）里，机器指令直接访问它。

---

Now, let's move the variable definition outside the main function, recompile, and go back to the debugger.

现在把变量定义挪到 main 函数外面，重新编译，再回到调试器。

---

Interestingly, the variable counter is no longer visible in the Locals window. This is because it is no longer local.

有意思了——counter 变量从 Locals 窗口消失了。原因很简单：它不再是**局部变量**（local variable）了。

---

To see the counter variable now we need a different view. Select the View menu and click on Watch, Watch1 view.

要查看这个变量，得换一个视图。点 View 菜单，选 Watch，打开 Watch1 窗口。

---

When the watch window opens, click on the first line and type the name of the variable: counter in out case.

Watch 窗口打开后，点第一行，输入变量名——我们这里是 `counter`。

---

As you can see, the location of the counter variable is now a big number starting with 0x2. This address is the beginning of the Random Accessed Memory in this particular ARM Cortex-M microcontroller, so the counter variable lives now in RAM.

看到了吧，counter 的位置现在变成了一个以 `0x2` 开头的大数字。这个地址正是这款 ARM Cortex-M 微控制器中**随机存取存储器**（RAM）的起始地址，也就是说，counter 现在住在 RAM 里了。

---

If this is really the case, than the variable should be also visible directly in the memory window. To check this, set the memory view to 0x2000000 and change the memory setting to 4x unit, to conveniently see 4-byte integers.

如果真是这样，那在内存窗口里也应该直接看得到。验证一下：把内存视图跳到地址 `0x2000000`，显示格式改成 4x 单位，这样方便查看 4 字节整数。

---

Now, let's single step through the code and watch the debugger views.

好，现在单步执行，观察调试器里的各个视图。

---

Note that the STR instruction caused change from zero to one in the Watch 1 view and the memory view. Now to 2... Now to 3...

注意看，**STR 指令**（Store instruction，存储指令）执行后，Watch1 和内存视图里的值从 0 变成了 1。然后变成 2……再变成 3……

---

Let's try to understand the machine instructions that the compiler has generated to access the counter variable in memory. The first interesting instruction is the LDR, which stands for load from memory to a register. The LDR.N instruction loads something from the label ??main2 to the R0 register.

来看看编译器为了访问内存中的 counter 变量，到底生成了哪些机器指令。第一条有意思的是 **LDR 指令**（Load instruction，加载指令），意思是把数据从内存加载到寄存器。`LDR.N` 从标签 `??main2` 处加载内容到 R0 寄存器。

---

You can actually Scroll down to this label to see what's being loaded. Hey, this looks familiar. The value loaded to R0 is the address of the counter variable. Let's execute the LDR.N instruction to watch R0.

你可以往下滚动到这个标签，看看到底加载了什么。嘿，看着眼熟吧——加载到 R0 的值就是 counter 变量的地址。执行这条 `LDR.N`，看看 R0。

---

The next LDR instruction loads R0 again, but this time the value comes from the address that the R0 currently holds, which is the address of the counter variable. Single step and verify that R0 now has the value 3.

下一条 LDR 指令又加载了 R0，不过这次是从 R0 当前保存的地址里取值——也就是 counter 变量的地址。单步执行，验证一下 R0 现在是 3。

---

The ADDS instruction does the actual work of incrementing R0 by 1, so R0 becomes 4.

**ADDS 指令**负责把 R0 加 1，R0 变成了 4。

---

The next LDR.N instruction loads the address of the counter variable to R1.

接下来又是一条 `LDR.N`，把 counter 的地址加载到 R1。

---

And finally, the STR instruction stores the value of the R0 register to the memory pointed to by the R1 register. Please note how the Watch1 and memory views change after this instruction executes.

最后，STR 指令把 R0 的值存到 R1 所指向的内存位置。注意看这条指令执行后，Watch1 和内存视图怎么变化。

---

At this point, I hope that you start to see the general pattern of accessing memory in the ARM processor. ARM is an example of the so called Reduced Instruction Set Computer (RISC) architecture, where memory can be only read by the specical load instructions, then all data manipulations must happen in the registers, and finally the modified register values can be stored back into the memory by the special store instructions. This is in contrast to the Complex Instruction Set Computer (CISC) architecture, such as the venerable x86 inside the personal computers, where some of the operands of complex instructions don't need to be in the registers, and can be still in memory.

说到这里，希望你开始看出 ARM 处理器访问内存的一般规律了。ARM 是典型的**精简指令集计算机**（RISC）架构——内存只能用专门的 load 指令来读，数据操作全部在寄存器里完成，改完的值再用专门的 store 指令写回内存。这跟**复杂指令集计算机**（CISC）不一样，比如个人电脑上经典的 x86——CISC 的复杂指令操作数可以不用先搬进寄存器，直接在内存上操作就行。

---

But regardless of the processor architecture, I hope that you start to appreciate the role of memory addresses, because every access to memory necessarily requires the knowledge of the address to load the data from or to store the data to.

不管什么架构，希望你开始体会到**内存地址**（memory address）有多重要了——每次访问内存，都得先知道地址，不管是读数据还是写数据。

---

All this leads to an interesting question. If those memory addresses are so fundamental to the CPU, can they be somehow represented at the C-language level?

这就引出了一个有意思的问题：内存地址对 CPU 来说这么基础，那在 C 语言层面能不能表示出来呢？

---

The answer is "yes". In the C language, the addresses can be stored inside variables called pointers.

答案是"能"。在 C 语言里，地址可以存放在一种叫**指针**的变量里。

---

Here is an example of a pointer variable in C. Like most C declarations, the best way to explain this one is to read it backwards. So, p_int is a pointer--which is what the star means after the type--to integers. In other words, p_int is a variable that can hold addresses of integer variables.

看这个 C 语言指针变量的例子。跟大多数 C 声明一样，最好从右往左读来理解：`p_int` 是一个**指针**——就是类型后面那个星号 `*` 的意思——指向整数。换句话说，`p_int` 这个变量能存放整数变量的地址。

---

If so, then p_int should be able to hold, among others, the address of the integer counter variable. Indeed, this can be very easily achieved in C. The operator ampersand gives the address of the counter variable, and this address can be legally assigned to p_int.

既然如此，`p_int` 自然就能存放整数变量 counter 的地址。在 C 语言里这很简单——用 `&` 运算符取 counter 的地址，然后赋给 `p_int`，完全合法。

---

Finally, it is also very useful to get the value stored at a given address from the pointer, which is called de-referencing the pointer. The C operator for this is the star. Star-p_int means the value at the address currently stored in the p_int pointer, which is the value of the counter variable in this case.

还有一个很实用的操作：通过指针拿到某个地址上存的值，这叫**解引用**（dereferencing）。C 语言用星号 `*` 来做这件事。`*p_int` 就是"p_int 里存的那个地址上的值"——在这里也就是 counter 变量的值。

---

Because of this equivalence, you can replace counter with *p_int, and the program should work exactly as before.

既然两者等价，你完全可以把 `counter` 替换成 `*p_int`，程序照样正常运行。

---

Let's see if the compiler is happy with this program.

看看编译器接不接受。

---

All right, so now let's go to the debugger and prepare the views. This time we need both the Watch1 view to see the counter variable and the Locals view to watch the p_int pointer.

好，进调试器，把视图准备好。这次既要看 Watch1 里的 counter 变量，又要看 Locals 里的 `p_int` 指针。

---

Before you step through the code, let's take a look at the disassembly view and compare it side-by-side with the code before introducing the p_int pointer.

单步执行之前，先看看**反汇编视图**（disassembly view），跟引入 `p_int` 指针之前的代码并排对比一下。

---

As you can see, the LDR instruction, which loads the address of the counter varible to the R0 register has been moved to the top, and another copy of the same instruction has been removed altogether. In other words, introduction of the p_int pointer has simplified the machine code and improved its efficiency. This code also suggests that the p_int pointer is now located in the R0 register.

看到了吧，那条把 counter 地址加载到 R0 的 LDR 指令被提到了最前面，另一条重复的指令直接删掉了。也就是说，引入 `p_int` 指针反而让机器代码更简洁、更高效了。代码也表明 `p_int` 现在就放在 R0 寄存器里。

---

Now you can single-step through the code and watch the counter variable increment, both in the Watch1 view and in the memory view, exactly as before. This confirms that the pointer is indeed an alias of the counter variable.

现在你可以单步执行，在 Watch1 和内存视图里看到 counter 跟之前一样递增。这证实了指针确实是 counter 变量的一个**别名**（alias）。

---

Finally, if you want to execute the loop to the end, but are getting tired of single-stepping through the code, you can set a breakpoint after the loop and click the Go button to execute the program at full speed. After you stop at the breakpoint, you can verify that the final counter value is 21, as expected.

最后，如果你想让循环跑完但又不想一直单步下去，可以在循环后面设一个**断点**（breakpoint），然后点 Go 按钮全速运行。停在断点后，验证一下 counter 的最终值——是 21，符合预期。

---

In the last step of this lesson, I'd like to demonstrate the incredible power of pointers. At this point, it will be just a horrible hack, but it will show you a technique that is actually used all the time in embedded systems programming.

这节课最后一步，我想演示一下指针的强大威力。接下来这个做法有点粗暴，但它展示的技巧在嵌入式编程中其实非常常用。

---

As I said before, a pointer variable, like p_int, holds the address of an integer. But this can be almost any address, not just the address of the counter variable. If so, then let's try to assign a fabricated address to p_int.

前面说过，`p_int` 这种指针变量存的是整数的地址。但这个地址几乎可以是任何地址，不一定非要是 counter 的地址。那我们就试试给 `p_int` 赋一个**手工捏造的地址**。

---

In your first attempt you might try to use an address expressed as a hex number, just as you saw it in the debugger. But when you compile by pressing F7, the compiler rejects the code.

第一次尝试，你可能会想直接用十六进制数写地址——就像调试器里看到的那样。但按 F7 编译，编译器直接报错。

---

In your next attempt, you might try to use an unsigned number by pre-pending the U suffix to the number. But the compiler doesn't like this either.

第二次尝试，给数字加上 `U` 后缀声明为无符号数。编译器还是不接受。

---

At this point your negotiations with the compiler really break down. But the C language has a mechanism to enforce a type by using type casting. You perform such type casting by placing the name of the type in parentheses in front of the cast expression. Now, the compiler has no choice, but to accept it.

到这一步，你跟编译器的谈判算是彻底破裂了。不过 C 语言有个机制叫**类型转换**（type casting），可以强制转换类型——在表达式前面加上括号括起来的类型名就行。这下编译器没辙了，只能接受。

---

All right, so now let's de-reference the pointer and poke some easily recognizable integer value into it. Embedded programmers seem to like DEAD BEEF for this purpose.

好，现在解引用这个指针，往里面塞一个容易辨认的整数值。嵌入式程序员最喜欢往里面写 `DEADBEEF`。

---

Obviously, this hack needs to be tested. But to preempt your objection that a simulator can take anything, I'd like to run this code on the Stellaris Launchpad board. So, if you have the board, plug it into the USB connector of your PC.

这种粗暴操作当然得测试一下。不过你可能说"模拟器什么都能跑"——为了打消这个疑虑，我们直接在 Stellaris Launchpad 实板上跑。所以如果你有这块板子，插到电脑的 USB 口上。

---

Next, set the debugger to the TI Stellaris interface. Also don't forget setting the "Use flash loader" option under the Download tab.

然后把调试器接口选成 TI Stellaris。别忘了在 Download 标签页里勾选"Use flash loader"。

---

If you don't have the board, just skip this step and follow along in the simulator.

没有板子也没关系，跳过这步，用模拟器跟着做就行。

---

Either way, click the download and debug button to get to the debugger.

不管用哪种方式，点 download and debug 按钮进入调试器。

---

Make sure that you have a breakpoint at the re-assignment of the p_int pointer and also make the Watch view visible so that you can see the counter variable.

确认一下：在 `p_int` 重新赋值的地方设好断点，Watch 视图也打开，这样能看到 counter 变量。

---

Press Go to run to the breakpoint.

按 Go 跑到断点处。

---

Click in the disassembly window to step one machine instruction at a time.

点一下反汇编窗口，这样每次单步执行一条机器指令。

---

Execute the LDR instruction, which loads the fabricated address to the R0 register, and verify that this address appears int the p_int variable in the locals view as well as in R0 in the register view.

执行 LDR 指令，把捏造的地址加载到 R0。然后验证一下：Locals 视图里的 `p_int` 和寄存器视图里的 R0 都显示了这个地址。

---

Execute the next LDR instruction, which loads the value hex-DEADBEEF to R1.

执行下一条 LDR 指令，把十六进制的 `DEADBEEF` 加载到 R1。

---

And finally, execute the STR instruction, which stores DEADBEEF in memory at the p_int address.

最后执行 STR 指令，把 `DEADBEEF` 写入 `p_int` 所指向的内存地址。

---

The effect of this is kind of scary. Due to the intentional misalignment of the fabricated address, the 0xDEADBEEF value gets written partially over the counter variable and partially over the next word in memory. The Cortex-M4 processor accepted this misaligned address, but Cortex-M0 would have a problem with it.

效果有点吓人。由于我们故意用了**不对齐**（misalignment）的地址，`0xDEADBEEF` 这个值一部分写到了 counter 变量上，一部分写到了内存中下一个**字**（word）上。Cortex-M4 处理器容忍了这种不对齐访问，但换成 Cortex-M0 就会出问题。

---

So, now you see how pointers, as any powerful mechanism, can also be dangerous, if used carelessly.

所以说，指针跟所有强大的机制一样——用得不小心，就可能是危险的。

---

This concludes this very quick introduction to pointers. In the next lesson you will put this knowledge to use to blink the LED of the Stellaris Launchpad board.

关于指针的快速入门就到这里。下一课，你会用上这些知识，让 Stellaris Launchpad 板子上的 LED 闪起来。

---

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以在 state-machine.com/quickstart 下载。

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
| variable | 变量 | 程序中用于存储数据的命名内存位置 |
| pointer | 指针 | 保存内存地址的变量 |
| register | 寄存器 | CPU 内部的高速存储单元 |
| R0 / R1 register | R0 / R1 寄存器 | ARM 处理器中的通用寄存器 |
| local variable | 局部变量 | 在函数内部定义的变量，只在该函数内可见 |
| RAM (Random Accessed Memory) | 随机存取存储器 | 可读写的易失性存储器 |
| LDR (Load) instruction | 加载指令 | 从内存读取数据到寄存器的指令 |
| STR (Store) instruction | 存储指令 | 将寄存器中的数据写入内存的指令 |
| ADDS instruction | 加法指令 | 执行加法运算并更新状态标志的指令 |
| RISC (Reduced Instruction Set Computer) | 精简指令集计算机 | 指令集简洁、操作在寄存器中完成的处理器架构 |
| CISC (Complex Instruction Set Computer) | 复杂指令集计算机 | 指令集丰富、操作可直接在内存上进行的处理器架构 |
| memory address | 内存地址 | 标识内存中特定位置的数值 |
| dereferencing | 解引用 | 通过指针获取其所指向地址处存储的值 |
| type casting | 类型转换 | 将一种数据类型强制转换为另一种数据类型 |
| breakpoint | 断点 | 调试时暂停程序执行的标记点 |
| disassembly view | 反汇编视图 | 将机器码显示为汇编指令的调试器窗口 |
| alias | 别名 | 指向同一内存位置的不同名称 |
| misalignment | 不对齐 | 数据地址不满足处理器对齐要求的情况 |
| word | 字 | 处理器一次能处理的固定长度数据单位，ARM 中通常为 4 字节 |
| fabricated address | 手工捏造的地址 | 人为构造的、非编译器分配的内存地址 |
