# 第19课：切换到 GNU-ARM 工具集和 Eclipse IDE / Lesson 19: Switching to GNU-ARM Toolset and Eclipse IDE

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I have decided to finally give in to the popular demand and switch the development toolset from IAR to the free and unlimited GNU-ARM compiler and the Eclipse-based Integrated Development Environment.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这堂课我决定顺应大家一直以来的呼声，把开发工具从 IAR 切换到免费无限制的 **GNU-ARM** 编译器，再加上基于 **Eclipse** 的**集成开发环境**（Integrated Development Environment, IDE）。

The switch of the toolset is actually a good opportunity to review the code and to see what "code portability" means in practice. As you will see, much of the code you've written so far will work with GNU-ARM without any changes, mostly due to the compliance with the Cortex Microcontroller Software Interface Standard (CMSIS). However, a few IAR-specific extensions in the startup code as well as board-support package will have to be replaced with the GNU compiler equivalents.

切换工具集其实是个很好的机会，可以回顾一下代码，看看"**代码可移植性**（code portability）"在实践中到底意味着什么。你会看到，到目前为止你写的代码大部分都能在 GNU-ARM 上直接用，不需要任何修改——这主要归功于我们一直遵循的 **Cortex 微控制器软件接口标准**（CMSIS）。不过，启动代码和**板级支持包**（Board Support Package, BSP）中有一些 IAR 特有的扩展，需要替换成 GNU 编译器的对应写法。

So, today let's start with downloading and installing a development toolset for GNU-ARM.

那么，今天我们就从下载和安装 GNU-ARM 开发工具集开始。

Actually, there are many choices of such toolsets, but you need to look for a toolset that supports your board. Here, the most important factor is the support for the specific debugger interface, which in case of the TivaC LaunchPad board is the Stellaris-ICDI.

实际上，这类工具集有很多选择，但你需要找一个支持你开发板的。这里面最关键的因素就是**调试器接口**（debugger interface）的支持——TivaC LaunchPad 板子上用的是 **Stellaris-ICDI**。

Since the board comes from Texas Instruments, the logical place to look is the TI.com website, where indeed you can find the toolset called Code Composer Studio (CCS).

既然开发板是德州仪器（TI）出的，那自然要去 TI.com 网站上找。果然，你会找到一个叫 **Code Composer Studio（CCS）** 的工具集。

As usual these days, instead of giving you a specific fixed URL for downloading CCS, which most likely won't work in a few weeks from now, I recommend using the search box.

现在网上的东西更新太快了，与其给你一个固定链接（很可能几周后就失效了），我建议直接用搜索框。

So, when you search for CCS, you quickly find the right web-page.

搜索 CCS，很快就能找到正确的页面。

In the download section, you can read that the CCS tool can be used for free with no limits with the GNU-GCC toolset.

在下载页面你可以看到，CCS 搭配 GNU-GCC 工具集可以免费使用，没有任何限制。

Click on the Windows download, which will lead you to the registration page and some more forms to fill to comply with the export control regulations.

点击 Windows 版下载，会跳转到注册页面，还需要填一些表格来符合出口管制要求。

Eventually, however, you should be able to download the CCS setup program for windows.

不过填完之后，你就能下载到 Windows 版的 CCS 安装程序了。

You need to launch it and agree to the licensing terms.

运行安装程序，同意许可条款。

In the next step you can choose the installation directory. You can leave the default, or choose your own destination, but I would strongly recommend against using directory names with spaces or any non-standard characters.

下一步是选择安装目录。你可以用默认路径，也可以自己选一个，但我强烈建议不要用带空格或非标准字符的目录名。

The following step allows you to choose the CCS components. Here you need to expand the 32-bit ARM MCUs and select the Tiva-C Series support. Also, you need to explicitly select the GCC ARM Compiler.

接下来选择 CCS 组件。你需要展开 32-bit ARM MCUs，勾选 Tiva-C Series 支持，另外还要手动勾选 GCC ARM Compiler。

You don't need to make any more choices, so finally click Finish to start the installation, which can take a couple of minutes.

其他都不用改了，直接点 Finish 开始安装，大概需要几分钟。

When you launch Code Composer Studio, it will ask you for the location of the "workspace". The concept of a "workspace" is common in all toolsets based on Eclipse and is intended to group together related projects.

启动 Code Composer Studio 时，它会让你指定**工作空间**（workspace）的位置。"工作空间"这个概念在所有基于 Eclipse 的工具中都很常见，用来把相关的项目组织在一起。

From what I see, most people tend to use one default workspace for everything they do, but I recommend that you use separate workspaces for your different project groups. Specifically, I recommend that you use a dedicated workspace for this Embedded Programming Course.

据我观察，大多数人所有项目都用一个默认工作空间。但我建议不同的项目组用单独的工作空间，特别是这个嵌入式编程课程，最好专门建一个工作空间。

Since I keep all the projects for this course in the directory "embedded_programming", I also create the CCS workspace there, in the "ccs" subdirectory.

我把本课程的所有项目都放在"embedded_programming"目录下，所以工作空间也建在那里，放在"ccs"子目录中。

So finally you are ready to create your first project. This part is specific to this particular re-packaging of Eclipse as Code Composer Studio, but the general process is similar in all Eclipse based Integrated Development Environments.

好，现在可以创建你的第一个项目了。这一步是 CCS 特有的操作，但所有基于 Eclipse 的 IDE 流程都差不多。

The first selection you make for a new project is the embedded target. Here you need to choose the Tiva-C family and the specific TM4C MCU within the family that is soldered on your TivaC LaunchPad board.

创建新项目首先要选嵌入式目标。你需要选 Tiva-C 系列，然后选你 LaunchPad 板子上焊的对应的 TM4C MCU 型号。

Next, you choose the connection to the target, which in case of your LanchPad is the Stellaris-ICDI. Please note that the support for this particular debugger interface was the primary reason you selected the CCS toolset in the first place.

接下来选择与目标的连接方式，LaunchPad 用的是 Stellaris-ICDI。前面说了，正是因为支持这个调试接口，我们才选了 CCS。

In the next step, you need to name the project. Here, I suggest a generic name "lesson" for projects belonging to this Embedded Programming Course. This name will be fitting for all upcoming lessons, because you will simply clone this original project instead of creating a new project from scratch each time.

下一步是给项目起名字。我建议用"lesson"这个通用名称，因为后续每节课你只需要克隆这个项目就行，不用每次都从头创建。

For the same reason, you also cannot create the project in the default location inside the workspace directory. Instead, you create the project in the directory where you keep all previous lessons. On my machine this is "embedded_programming", but it can be different on your computer.

同样因为这个原因，你不能用工作空间里的默认位置创建项目，而要把它放在之前课程所在的目录中。我机器上是"embedded_programming"，你的可能不同。

To finish with the project location, you need to add the lesson19 sub-directory for this particular project.

最后再加上 lesson19 子目录，项目位置就设好了。

The next and final step is critical. Here, you need to select the GNU toolset instead of the default TI compiler for ARM.

最后一步很关键——你要选 GNU 工具集，而不是默认的 TI ARM 编译器。

When you click Finish, CCS will create your "lesson" project in the workspace and in the "lesson19" directory on disk.

点 Finish 之后，CCS 就会在工作空间和磁盘上的"lesson19"目录里创建好你的"lesson"项目。

You can build the project by clicking on the hammer button at the top. As you can see, the build process succeeds with 0 problems.

点击顶部的锤子按钮就能构建项目。可以看到，构建成功，0 个问题。

So, let's take a quick look at the code that CCS has generated for this project.

让我们快速看一下 CCS 为这个项目生成的代码。

First, you get the main.c file with the empty main() function.

首先是一个 main.c 文件，里面有空的 `main()` 函数。

Second, is the startup code, which is very typical for code supplied by silicon vendors. Unfortunately, it has all the shortcomings that I've covered in lessons 13, 14, and 15.

然后是**启动代码**（startup code），芯片厂商提供的代码基本都是这样。遗憾的是，它有我在第 13、14、15 课里讲过的那些问题。

For starters, this startup code uses proprietary exception names that are not compliant with CMSIS.

首先，它用了专有的异常名称，不符合 CMSIS 标准。

Also, the vector table requires editing every time you start or stop using a given interrupt handler. For example, to use the SysTick_Handler interrupt, you would need to modify the appropriate entry in the vector table, and you would also need to declare a prototype of the handler at the top of the file.

另外，**向量表**（vector table）也必须手动编辑——每次启用或停用一个中断处理函数都要改。比如要用 SysTick_Handler 中断，你就得改向量表里对应的条目，还得在文件顶部声明处理函数的原型。

And finally, the provided implementation of the exception handlers contains endless loops that tie up the CPU. In other words, if any of such exception handler is ever executed, the system will freeze, which the user will perceive as denial of service. This is not acceptable in any production-grade code.

最后，那些异常处理函数的实现都是死循环，会把 CPU 卡住。也就是说，一旦触发了这些异常处理函数，系统就会冻住——用户感觉就是**拒绝服务**（denial of service）。这在任何**生产级代码**（production-grade code）中都是不可接受的。

The generated code also contains the file with the extension .lds, which is the linker script. The purpose of this file is to tell the linker where ROM and RAM are located in the address space and where to place various program sections. You saw an example of a linker script for the IAR toolset in lesson 14. Here you have a linker script for the GNU toolset.

生成的代码里还有一个 .lds 文件，就是**链接脚本**（linker script）。它的作用是告诉**链接器**（linker）ROM 和 RAM 在地址空间中的位置，以及各个程序段该放在哪里。第 14 课你看过 IAR 工具集的链接脚本，这里是 GNU 工具集的版本。

This is again a beaten-path linker script, which matches the startup code.

这也是一个常规的链接脚本，跟启动代码配套的。

Among others, it allocates the stack as the last section in RAM. In my opinion this is a mistake, because stack grows toward the lower addresses on ARM, and so a stack overflow could damage the RAM sections above it. In fact, this seems the likely cause of failure in the infamous Toyota unintended acceleration cases, as I have described in the article "Are we shooting ourselves in the foot with stack overflow?". I provide a link to this article in the comment section for this video.

其中，它把**栈**（stack）分配在 RAM 的最后一个段。我觉得这是个错误，因为在 ARM 上栈是往低地址方向增长的，一旦**栈溢出**（stack overflow），就会破坏它上面的 RAM 段。事实上，当年闹得沸沸扬扬的丰田意外加速事件，很可能就是这个原因——我在文章"Are we shooting ourselves in the foot with stack overflow?"里详细讨论过。视频评论区有这篇文章的链接。

So, it seems that the code generated by CCS is not terribly usable, but the good news is that you can fix all the issues in it by applying the lessons you've learned so far.

所以 CCS 生成的代码不太好用，但好消息是——用你前面学过的知识，这些问题都能修。

The first thing then is to copy all the relevant code from the previous lesson18 to the lesson19 folder. The usable files are: bsp.h, bsp.c, main.c, startup_tm4c.c, and the master header file for your TM4C MCU.

首先，把上一课 lesson18 里的相关代码复制到 lesson19 文件夹。需要复制的文件是：bsp.h、bsp.c、main.c、startup_tm4c.c，还有你 TM4C MCU 的主头文件。

Interestingly, the files copied to the lesson19 folder immediately show up inside your project. This is how all Eclipse projects behave. All source files in the project directory are automatically included in the project and you don't need to explicitly add them as it was the case in the IAR Embedded Workbench IDE.

有趣的是，复制到 lesson19 文件夹的文件会立刻出现在项目里。这是所有 Eclipse 项目的特点——项目目录下的所有源文件都会自动包含进来，不需要像 IAR Embedded Workbench 那样手动添加。

This Eclipse policy has its disadvantages too, however.

不过这种做法也有缺点。

For example, now you have two startup files in the project, so you need to delete one of them.

比如现在你的项目里有两个启动文件，得删掉一个。

So let's try to build this project.

来试试构建这个项目。

This time you get some errors.

这次报了一些错误。

The first error is that the compiler cannot find the include file "core_cm4.h". This file is part of the CMSIS, which is not directly available in Code Composer Studio, as it was in IAR Embedded Workbench.

第一个错误是编译器找不到头文件"core_cm4.h"。这个文件是 CMSIS 的一部分，CCS 里不像 IAR 那样自带。

This is not a big problem, as you can easily provide CMSIS yourself.

这不是什么大问题，你自己提供 CMSIS 就行了。

Here, I have prepared for you a directory CMSIS, which contains the core header files in the sub-directory Include.

我这里为你准备了一个 CMSIS 目录，核心头文件都在 Include 子目录下。

You should copy the CMSIS directory into the folder where you keep the lessons of this video course. That way you can re-use CMSIS in all upcoming lessons.

把 CMSIS 目录复制到你存放课程的文件夹中，这样后面每节课都能复用。

Of course copying a directory is not enough, because you also need to tell the compiler to look for include files in this new directory CMSIS/Include.

当然，光复制目录还不够，你还得告诉编译器去 CMSIS/Include 目录下找头文件。

You accomplish this by means of the project Properties dialog box, which you open by right-clicking on the project and selecting the Properties pop-up menu.

这通过项目属性对话框来完成——右键点击项目，选 Properties。

Specifically, you need to choose the Directories property in the GNU Compiler group, where you find the "include paths" panel.

具体来说，在 GNU Compiler 组里找到 Directories 属性，里面有"include paths"面板。

To add a new include directory, click on the plus button.

点加号按钮添加新的包含目录。

The first, easy way is to simply browse your file system for the CMSIS/Include directory.

最简单的办法是直接浏览文件系统，找到 CMSIS/Include 目录。

But the big drawback of doing this is that you add an *absolute* include path, which will only work on your computer with this specific C:\embedded_programming\CMSIS directory.

但这样做的缺点是你会添加一个**绝对路径**（absolute include path），只在你这台机器上有效——换台电脑就不行了。

A much better approach is to create a *relative* include path, which will work on any computer.

更好的办法是用**相对路径**（relative include path），这样在任何电脑上都能用。

The Eclipse IDE allows you to create relative paths by means of system variables. Specifically, in the list of these variables, you can choose PROJECT_LOC, which will create paths relative to the project location.

Eclipse IDE 支持通过系统变量创建相对路径。在变量列表中选择 PROJECT_LOC，路径就是相对于项目位置的。

From the project location, you need to go one level up, and then you append CMSIS/Include.

从项目位置往上一级，然后加上 CMSIS/Include。

Regarding the use of directory separators, on Windows you can use either back-slashes or forward-slashes. I use forward-slashes, because they seem more universal.

目录分隔符方面，Windows 上反斜杠正斜杠都可以。我用正斜杠，因为更通用一些。

When you build again, you see that the previous include error is gone, but you got a bunch of new errors.

再构建一次，之前的包含错误消失了，但又出现了一堆新错误。

As it turns out, most of these new errors come from the startup code. This should not be actually that surprising, because this code was written with IAR-specific extensions to the C language, which the GNU compiler does not recognize.

这些新错误大多来自启动代码。其实也不奇怪——那段代码用的是 IAR 特有的 C 语言扩展，GNU 编译器当然不认。

So, here I have prepared for you the startup code, which was re-written with the GNU-specific extensions to the C language.

所以我这里准备了用 GNU 特有扩展重写的启动代码。

As you will see in a minute, the startup code must closely match the linker script, so I included a matching linker script as well.

等下你会看到，启动代码必须跟链接脚本紧密配合，所以我也附上了配套的链接脚本。

To include these files in the project is simply copy them over to the lesson19 directory. I need to allow overwriting the previous linker script and I also need to remove the previous startup code.

把这些文件复制到 lesson19 目录就行了。需要覆盖之前的链接脚本，删掉之前的启动代码。

When you switch over to the Eclipse IDE, you can see that the project is immediately updated with the new files.

切回 Eclipse IDE，你会看到项目立刻更新了新文件。

Let's quickly review the code, so that you know how it works.

快速过一下代码，让你了解它是怎么工作的。

First, in contrast to the old file, the new GNU-specific startup code is compliant with the latest CMSIS 4.3.0.

首先，跟旧文件不同，新的 GNU 启动代码符合最新的 CMSIS 4.3.0 标准。

When you scroll down to the vector table, you can see that it has a special attribute section(.isr_vector). This is a GNU-specific extension, which tells the compiler to place the following symbol--the vector table in this case--in the specified section.

往下滚到向量表，你会看到它有一个特殊属性 `section(.isr_vector)`。这是 GNU 特有的扩展，告诉编译器把后面的符号——这里就是向量表——放到指定的段里。

To see where this section is, you can open the new GNU linker script, where you can see that .isr_vector is the first section in ROM.

要看这个段在哪，打开新的 GNU 链接脚本，可以看到 .isr_vector 是 ROM 中的第一个段。

The ROM section, in turn, is located at address 0, so the vector table at the beginning of ROM is also at zero, which is exactly what the ARM CPU needs.

ROM 段位于地址 0，所以 ROM 开头的向量表也在地址 0——正好是 ARM CPU 所需要的位置。

As you hopefully remember from lesson-15, the first element of the ARM vector table is the initial top of stack. So, here you see an ampersand, meaning address of, \_\_stack_end\_\_ cast on an int.

希望你还记得第 15 课的内容：ARM 向量表的第一个元素是初始栈顶。所以这里有个 & 符号，表示取 `__stack_end__` 的地址，并强制转换为 int 类型。

The symbol \_\_stack_end\_\_ comes again from the linker script. Indeed, when you scroll a bit down, you can see the .stack section as the first section in RAM.

`__stack_end__` 这个符号同样来自链接脚本。往下滚一点，你会看到 .stack 段是 RAM 中的第一个段。

Contrary to the beaten-path approach of putting the stack at the last section in RAM, I recommend placing it at the first section. That way, a stack overflow won't be able to damage any other RAM sections. As an additional bonus, a stack overflowing into the un-mapped memory below RAM will be detected automatically by executing the HardFault exception, so you will know about it.

跟把栈放在 RAM 末尾的常规做法相反，我建议放在 RAM 的开头。这样栈溢出就不会破坏其他 RAM 段。额外的好处是，如果栈溢出到 RAM 下方的未映射内存，CPU 会自动触发 HardFault 异常，你就知道出问题了。

Speaking of the stack, you can change its size by adjusting the symbol STACK_SIZE at the top of the linker script.

说到栈的大小，你可以通过修改链接脚本顶部的 STACK_SIZE 符号来调整。

Going back to the startup code, the symbol \_\_stack_end\_\_ is provided by the linker, but the compiler does not know about it. To tell the compiler, you need to declare \_\_stack_end\_\_ as an external variable at the top of the startup file.

回到启动代码——`__stack_end__` 这个符号是链接器提供的，编译器并不知道它的存在。所以要告诉编译器，你需要在启动文件顶部把它声明为外部变量。

The other elements of the vector table are addresses of handler functions for Cortex-M exceptions and interrupts. As you can see, the table already contains all the specific handlers, with names compliant with CMSIS, so you don't need to edit the code at all to use any of these exceptions or interrupts.

向量表的其他元素是 Cortex-M 异常和中断处理函数的地址。可以看到，表里已经包含了所有具体的处理函数，名字都符合 CMSIS 规范——所以不管你要用哪个异常或中断，都不需要改代码。

At the same time, if you don't use a given exception or interrupt, it will be automatically replaced by the Default_Handler implementation.

而如果你没用某个异常或中断，它会自动被 Default_Handler 的实现替换掉。

This is accomplished by means of a pair of GNU-specific attributes weak and alias.

这是通过一对 GNU 特有的属性 **weak** 和 **alias** 实现的。

The weak attribute means that such a symbol definition can be overridden by another definition and the linker will quietly discard the weak definition without reporting that the symbol was defined twice.

**weak** 属性的意思是：这个符号定义可以被另一个定义覆盖，链接器会悄悄丢弃弱定义，不会报"符号重复定义"的错误。

The alias attribute means that if the symbol is not defined, the alias symbol should be used instead.

**alias** 属性的意思是：如果这个符号没被定义，就用别名符号来替代。

So, for example, if you define the SysTick_Handler in your application, the linker will take your non-weak definition. If you don't define SysTick_Handler, the linker will take the Default_Handler alias for it and will not report any errors.

举个例子：如果你在应用程序中定义了 SysTick_Handler，链接器就用你的定义（非弱定义）。如果你没定义，链接器就取 Default_Handler 这个别名，也不报错。

Notice though that not all handlers are aliased. This is because the standard fault handlers are actually defined in this startup code so that you don't need to define them in your application.

注意，并不是所有处理函数都有别名。因为标准的**故障处理函数**（fault handlers）已经在启动代码里定义好了，你不需要在自己的应用程序中再定义。

But these handlers are not the primitive endless loops with denial of service. The provided implementations use inline assembly to carefully avoid any use of the stack, which might be corrupted at this point. The assembly code stores the information about the fault in r0 and r1 registers and then branches to assert_handler, where you can perform your last damage control.

但这些处理函数不是那种简单的死循环。它们的实现用了**内联汇编**（inline assembly），小心地避免了对栈的使用——因为此时栈可能已经坏了。汇编代码把故障信息存到 r0 和 r1 寄存器，然后跳转到 assert_handler，在那里你可以做最后的应急处理。

Here you encounter another GNU-specific attribute "naked", which instructs the compiler not do any stack operations for this function.

这里又遇到了一个 GNU 特有的属性"**naked**"，它告诉编译器不要为这个函数生成任何栈操作。

When you try to build again, you still have an error, this time in bsp.c.

再构建一次，还有一个错误，这次是在 bsp.c 里。

By now you should know what's the problem. The extended keyword \_\_stackless was an IAR extension for stackless functions. In GNU, you need to replace it with \_\_attribute\_\_("naked").

现在你应该知道问题在哪了。扩展关键字 `__stackless` 是 IAR 对无栈函数的扩展。在 GNU 里，要替换成 `__attribute__("naked")`。

Another build. This time, the compiler complains about \_\_enable_interrupts(), which was an IAR intrinsic function. In GNU this operation needs to be replaced with \_\_enable_irq().

再构建一次。这次编译器抱怨 `__enable_interrupts()`——这是 IAR 的**内建函数**（intrinsic function）。在 GNU 里要换成 `__enable_irq()`。

Another build, and..., Hallelujah! No errors at all.

再构建……哈利路亚！一个错误都没有了。

Congratulations, you have just finished your first port of deeply embedded code from one toolset to another.

恭喜！你刚刚完成了第一次把深度嵌入式代码从一个工具集**移植**（port）到另一个工具集。

Time to plug in your Tiva LaunchPad board and test the code.

现在插上你的 Tiva LaunchPad 开发板，测试一下代码。

To download the code to the flash memory of the board and start debugging, you press the bug button at the top.

按顶部的调试按钮，代码就会下载到板子的**闪存**（flash memory）中，并开始调试。

The debugger is setup to stop at the beginning of main and indeed it does. Press the Go button to run the code and watch the LED change color once a second.

调试器设置在 main 函数开头暂停，确实如此。按 Go 按钮运行代码，观察 LED 每秒变一次颜色。

Click on the Pause button to break into the code and watch it stop in the background loop.

按 Pause 按钮中断程序，你会看到它停在了后台循环里。

By the way, the different screen layout that you see now is called in Eclipse the "Debug Perspective". This is to differentiate this view from the "Edit Perspective" that you saw during editing the code.

顺便说一下，你现在看到的这个不同的屏幕布局，Eclipse 里叫 **Debug 透视图**（Debug Perspective），用来跟编辑代码时的 **Edit 透视图**（Edit Perspective）区分开。

The Debug Perspective provides all the debugger views that you encountered in IAR, such as the disassembly view.

Debug 透视图提供了你在 IAR 中见过的所有调试器视图，比如**反汇编视图**（disassembly view）。

You can also single-step through the code and watch the LED being turned on and off.

你也可以**单步执行**（single-step）代码，观察 LED 的亮灭。

You can set breakpoints, like for example inside the SysTick_Handler to see how frequently this interrupt is called.

你还可以设**断点**（breakpoint），比如在 SysTick_Handler 里面，看看这个中断被调用的频率。

To stop the debug session and return to the "Edit Perspective", press the Stop button at the top.

要停止调试、回到 Edit 透视图，按顶部的 Stop 按钮。

As the final step of this lesson, let's modify the behavior of the code copied from your previous IAR project to change the color of the toggled LED from red to blue, for example.

最后一步，我们来改一下从之前 IAR 项目复制过来的代码——比如把闪烁的 LED 颜色从红色改成蓝色。

Build the project and start debugging as before...

跟之前一样构建项目、开始调试……

Watch the LED blink in a new color.

观察 LED 以新的颜色闪烁。

This concludes this lesson about switching the toolset to GNU-ARM and Eclipse-based Code Composer Studio (CCS). The startup code and linker script from this lesson are much closer to production-quality than the typical code distributed by silicon vendors. The code is compliant with CMSIS and will work with any toolset based on GNU-ARM, not just with CCS. You can easily adapt it for any ARM Cortex-M microcontroller.

好，关于切换到 GNU-ARM 和基于 Eclipse 的 Code Composer Studio（CCS）这堂课就到这里。本课的启动代码和链接脚本比芯片厂商提供的典型代码更接近**生产级质量**（production-quality），而且符合 CMSIS 标准，不限于 CCS——任何基于 GNU-ARM 的工具集都能用。你可以轻松适配到任何 ARM Cortex-M 微控制器上。

If you'd like to learn more about using the free GNU-ARM toolset, I would recommend my 10-part article "Building Bare Metal ARM Systems with GNU", which in 2007 was the most popular article on Embedded.com.

如果你想进一步了解免费的 GNU-ARM 工具集，推荐看看我的系列文章"Building Bare Metal ARM Systems with GNU"——一共十篇，2007 年的时候是 Embedded.com 上最受欢迎的文章。

This article talks about the classic ARM7/ARM9 cores, but much of the information still applies to Cortex-M as well. I provide a link to this article in the description of this video on YouTube.

文章讲的是经典的 ARM7/ARM9 内核，但大部分内容对 Cortex-M 也适用。YouTube 视频描述里有这篇文章的链接。

The project download for this lesson will come in two parts: the usual lesson19.zip archive with the CCS project and code for the lesson and the CMSIS.zip archive with the CMSIS code.

本课的项目下载分两部分：一部分是常规的 lesson19.zip（包含 CCS 项目和课程代码），另一部分是 CMSIS.zip（包含 CMSIS 代码）。

In the next lesson I will finally talk about race conditions, which is a concept that you absolutely need to understand to effectively work with interrupts.

下一课我们终于要讲**竞态条件**（race conditions）了——这是你用好中断必须理解的一个概念。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅关注。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Integrated Development Environment (IDE) | 集成开发环境 | 用于软件开发的综合工具 |
| GNU-ARM | GNU-ARM | 基于 GCC 的 ARM 工具链 |
| Code Composer Studio (CCS) | Code Composer Studio | TI 的基于 Eclipse 的 IDE |
| Eclipse | Eclipse | 开源 IDE 框架 |
| Cortex Microcontroller Software Interface Standard (CMSIS) | Cortex 微控制器软件接口标准 | ARM 定义的软件接口标准 |
| Board Support Package (BSP) | 板级支持包 | 针对特定硬件板的底层支持代码 |
| startup code | 启动代码 | MCU 上电后执行的第一段代码 |
| linker script | 链接脚本 | 指导链接器安排内存布局的文件 |
| vector table | 向量表 | 存放异常和中断处理函数地址的表 |
| stack | 栈 | 后进先出的内存区域 |
| stack overflow | 栈溢出 | 栈超出其分配空间的错误 |
| debugger interface | 调试器接口 | 调试器与目标 MCU 的连接方式 |
| Stellaris-ICDI | Stellaris-ICDI | TI LaunchPad 板上的调试接口 |
| workspace | 工作空间 | Eclipse 中组织项目的容器 |
| absolute include path | 绝对路径 | 从根目录开始的完整路径 |
| relative include path | 相对路径 | 相对于项目位置的路径 |
| weak attribute | weak 属性 | GNU 扩展，允许符号被覆盖 |
| alias attribute | alias 属性 | GNU 扩展，为符号指定别名 |
| naked attribute | naked 属性 | GNU 扩展，指示编译器不生成函数序言/尾声 |
| intrinsic function | 内建函数 | 编译器提供的特殊内联函数 |
| inline assembly | 内联汇编 | 嵌入在 C 代码中的汇编指令 |
| fault handler | 故障处理函数 | 处理 CPU 异常/故障的函数 |
| Debug Perspective | Debug 透视图 | Eclipse 中的调试界面布局 |
| Edit Perspective | Edit 透视图 | Eclipse 中的代码编辑界面布局 |
| disassembly view | 反汇编视图 | 显示机器码反汇编结果的调试视图 |
| breakpoint | 断点 | 调试时暂停程序执行的标记点 |
| single-step | 单步执行 | 逐行或逐指令执行代码的调试方法 |
| flash memory | 闪存 | MCU 中的非易失性程序存储器 |
| code portability | 代码可移植性 | 代码在不同平台间迁移的能力 |
| port / porting | 移植 | 将代码适配到新的平台或工具集 |
| production-grade code | 生产级代码 | 达到产品发布质量标准的代码 |
| race condition | 竞态条件 | 并发访问共享资源导致的不可预测行为 |
| denial of service | 拒绝服务 | 系统无法正常提供功能的状态 |
| linker | 链接器 | 将目标文件合并为可执行程序的工具 |
| section | 段 | 可执行文件或内存中的逻辑分区 |
