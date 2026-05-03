# 第49课：测试与嵌入式软件的演化 / Lesson 49: Testing and Evolution of Embedded Software

Hello and welcome to the "Modern Embedded Systems Programming" course. I'm Miro Samek, and in this lesson, I'd like to discuss testing and its central role in software development. You will also see some ways of testing embedded software on the host computer and embedded targets and how to obtain the necessary tools.

大家好，欢迎来到"现代嵌入式系统编程"课程。我是 Miro Samek。今天这节课，我想聊聊**测试（Testing）**以及它在软件开发中的核心地位。同时你也会看到，在主机和嵌入式目标上测试嵌入式软件有哪些方法，以及怎么拿到需要的工具。

My main goal today is to explain testing in the broader context of software development, which, in its essence, is creating complex systems. So, let's examine how complex systems generally come about because our understanding of this process has dramatically changed.

我今天的主要目标，是把测试放到软件开发更大的背景下来看——说到底，软件开发就是在创建复杂系统。所以咱们先来看看，复杂系统一般是怎么产生的，因为人类对这个过程的理解已经发生了翻天覆地的变化。

The change I'm talking about is one of the most profound in all science and concerns the most complex systems we know of, living organisms. Before Charles Darwin published "On the Origin of Species" in 1859, the established thinking was that all living things were created in a divinely inspired act in their current, perfect, and final form.

我说的这个变化，是整个科学界最深刻的变革之一，涉及我们所知最复杂的系统——生物体。在达尔文 1859 年发表《物种起源》之前，主流观点是：所有生物都是一次神圣的创造行为，以现在的、完美的、最终的形式被创造出来的。

The Darwinian theory of evolution by natural selection offered an entirely different explanation. All living organisms came into being through a gradual, incremental, and cumulative process of evolution from simpler to more complex forms. The critical and most radical idea at the time was that of natural selection that constantly and relentlessly weeds out the less-fit adaptations, leading to the constant struggle for existence.

达尔文的**自然选择进化论（Theory of Evolution by Natural Selection）**给出了一个完全不同的解释。所有生物都是从更简单的形态，通过一个渐进的、一点一点累积的演化过程，变成今天这样更复杂的形态的。当时最关键也最激进的想法就是**自然选择（Natural Selection）**——它无时无刻不在淘汰那些不太适应的变异，由此带来了持续的生存竞争。

Following Darwin's publication, the most significant intellectual challenge was imagining and accepting that such a process could produce complexity on this scale.

达尔文的著作发表之后，最大的思想挑战在于：要让人想象并接受，这么一个过程居然能产生如此规模的复杂性。

Nowadays, science has come full circle. Not only is evolution capable of producing complexity, but in fact, it is now recognized as the only process through which anything complex can be created anywhere, not just in biology.

到了今天，科学界的认知已经彻底转过来了。进化不仅能产生复杂性，而且现在人们认识到，它是任何复杂事物得以产生的唯一途径——不限于生物学，任何领域都一样。

A little-known scientific fact is that shortly after Darwin's publication, another lesser-known author published "On the Origin of Software by Means of Artificial Selection" with the subtitle "Preservation of favored code in the struggle to survive testing."

一个鲜为人知的科学史实是：达尔文发表著作后不久，另一位不太出名的作者也发表了一部作品——《通过人工选择论软件的起源》，副标题是"在存活的测试斗争中保留有利的代码"。

In this work, which frankly was far ahead of its time, the author, yours truly, Miro Samek, generalized Darwin's ideas to software development.

在这部坦率地说远远超前于时代的作品中，作者——也就是本人，Miro Samek——把达尔文的思想推广到了软件开发领域。

Here are the three most important findings from that forgotten book: First, "A complex system that works is invariably found to have evolved from a simple system that worked."

那本被遗忘的书里有三个最重要的结论。第一："一个能正常工作的复杂系统，必然是从一个能正常工作的简单系统演化而来的。"

Second, "A complex system designed from scratch never works and cannot be made to work. You have to start over, beginning with a working simple system."

第二："一个从零开始设计出来的复杂系统，永远不会工作，也没法让它工作。你必须从头来，先从一个能工作的简单系统起步。"

And third (actually, a corollary from the first two), "In embedded systems, nothing works until everything works." I'll come back to this fact later.

第三（其实是从前两条推出来的），"在嵌入式系统中，没有任何部分能真正工作，直到所有部分都能工作。"这点我后面还会再提。

Unfortunately, that important work has been forgotten. By the time software was actually invented, people still believed in a divinely inspired act of creation known as the waterfall process.

可惜那部重要著作被遗忘了。等到软件真正被发明出来的时候，人们仍然信奉一种类似"神创论"的做法——也就是所谓的**瀑布流程（Waterfall Process）**。

Such a big up-front design culminating with big-bang final testing cannot work because it lacks the critical evolutionary aspects of incremental development combined with constant selection, which are indispensable for anything complicated to actually work.

这种先做大量前期设计、最后再来一次总测试的做法，注定行不通。因为它缺少关键的演化要素——增量开发加上持续选择。而这两样东西，是任何复杂系统想要真正工作所不可或缺的。

Well, it seems that every discipline must repeat the same mistakes and separately rediscover the universal rules for creating complexity. In software, the importance of evolution by selection was rediscovered and forgotten several times.

看起来每个学科都得自己踩一遍同样的坑，才能各自重新发现创建复杂性的普遍规律。在软件领域，"通过选择来进化"的重要性就被重新发现过好几次，然后又被人遗忘。

But only the most recent movement, called "agile software development," fully acknowledged and embraced testing as the primary selection mechanism that must be applied continuously, not just to weed out the bad adaptations (known in software as "bugs") but to guide the whole development process. This use of testing for guidance is also known as test-driven development (TDD).

但只有最近的一场运动——**敏捷软件开发（Agile Software Development）**——才真正把测试当作核心的选择机制，并且要求持续地应用它。测试不光是为了淘汰不好的适应（在软件里我们叫它"bug"），还要用来引导整个开发过程。这种用测试来驱动开发的方式，叫做**测试驱动开发（Test-Driven Development, TDD）**。

Other agile best practices, such as continuous integration (CI) and continuous delivery (CD), might seem like recent inventions. However, they merely acknowledge that a software system must keep working continuously like any complex system. If it ever stops working, making it functional again is like trying to resurrect a dead organism.

敏捷里其他一些最佳实践，比如**持续集成（Continuous Integration, CI）**和**持续交付（Continuous Delivery, CD）**，看着像是最近才发明的。但其实它们只是在承认一个事实：软件系统必须像任何复杂系统一样，持续保持工作状态。一旦停下来，再想让它恢复功能，就跟试图让一个死去的生物复活一样难。

With these general insights, the question is no longer whether evolution coupled with strong selection applies to software. We know for a fact that this is the only way. The question then becomes how to evolve the software and what kind of selection mechanism testing should provide.

有了这些基本认识之后，问题就不再是"进化加强选择"这套东西适不适用于软件了——我们已经明确知道，这是唯一的路。真正的问题是：怎么演化软件，以及测试应该提供什么样的选择机制。

Obviously, in software development, we don't have eons of deep evolutionary time to emulate natural selection, and the customers certainly won't appreciate testing all iterations of the software on them in the "wild." But natural selection is not the only way.

显然，在软件开发里，我们没有几十亿年的进化时间来模拟自然选择，客户当然也不愿意当小白鼠，在"野外"被测试软件的每一个版本。但自然选择不是唯一的路。

We can use artificial selection, which is how humans evolved and transformed all domesticated plants and animals. Artificial selection works on much shorter time scales.

我们可以用**人工选择（Artificial Selection）**——人类正是用这种方式驯化和改造了所有家养动植物。人工选择运作的时间尺度要短得多。

However, artificial selection requires much more than natural selection because now we must take full responsibility for what we want to select and precisely how we do this.

不过，人工选择比自然选择的要求更高，因为现在我们必须完全由自己来决定：选什么，以及具体怎么选。

For that, we obviously need a suitable starting point for the software evolution — the first working version. But we also need to create an artificial "habitat" for the software to "live in."

为此，我们显然需要一个合适的软件演化起点——第一个能工作的版本。同时，我们还得为软件创建一个供它"生存"的人工"栖息地"。

Of course, this artificial "habitat" depends on the type of testing you wish to perform. Today, I will focus on "unit testing," which involves the smallest software components that can be isolated and individually tested, such as functions and modules in C. Unit testing is (or at least should be) the most extensive type of testing the original developers perform as they work on their code.

当然，这个人工"栖息地"长什么样，取决于你想做哪种测试。今天我重点讲**单元测试（Unit Testing）**——它针对的是可以隔离出来、单独测试的最小软件组件，比如 C 语言里的函数和模块。单元测试是（或者说至少应该是）开发人员写代码时做得最多的测试。

Generally, the lower the testing level, the more extensive the software "habitat" must be. For unit testing, this artificially created "habitat" is called "testing harness" or "testing framework."

一般来说，测试级别越低，软件的"栖息地"就得越完善。对于单元测试来说，这个人工搭建的"栖息地"叫做**测试线束（Testing Harness）**或**测试框架（Testing Framework）**。

Several such unit testing harnesses exist, most based on the heritage of the original xUnit. Harnesses that made their way into embedded software include CppUtest and Unity, both used in the book "Test-Driven Development for Embedded C" by James Grenning. Another popular testing harness is Google Test or gtest. The links to all those testing harnesses will be provided in the video description.

目前已经有不少这样的单元测试线束了，大多源自最初的 xUnit 家族。进入嵌入式领域的有 CppUTest 和 Unity，它们都用在了 James Grenning 的《Test-Driven Development for Embedded C》一书里。另一个流行的测试线束是 Google Test，也叫 gtest。这些测试线束的链接我会放在视频描述里。

Today, however, I'd like to show a unit testing harness called Embedded-Test or ET because it is much simpler than any of the alternatives, yet it can run all tests described in Grenning's TDD book. ET is written in C, but unlike Unity, it requires no "test runners" (I will explain that in a minute).

不过今天，我想给你介绍一个叫 **Embedded-Test**（简称 **ET**）的单元测试线束。它比其他任何替代方案都简单得多，但 Grenning 那本 TDD 书里描述的所有测试它都能跑。ET 是用 C 语言写的，而且跟 Unity 不同，它不需要"测试运行器"——这点我稍后会解释。

The ET framework runs on host computers and embedded boards with minimal porting.

ET 框架在主机和嵌入式开发板上都能跑，移植工作量极小。

ET is permissively licensed open source, and you can get it from GitHub, either by downloading the zipped code or cloning the repository with git.

ET 采用宽松的开源许可，你可以从 GitHub 获取——下载 ZIP 压缩包或者用 git 克隆仓库都行。

Assuming that you've downloaded ET as a ZIP file, unzip it into the directory where you keep projects for this course. After doing so, rename the Embedded-Test-main directory to lesson-49.

假设你下载的是 ZIP 文件，把它解压到你存放本课程项目的目录里。解压之后，把 Embedded-Test-main 这个目录名改成 lesson-49。

Get into the lesson-49 directory and right-click on Windows Explorer to open a terminal in this directory.

进入 lesson-49 目录，在 Windows 资源管理器里右键，在这个目录下打开一个终端。

So far in this course, you've only used embedded Integrated Development Environments, such as KEIL uVision, IAR Embedded Workbench, or TI Code Composer Studio. But unit testing is often performed directly from the command line; therefore, today, you will also use just a terminal to see how this works.

到目前为止在这门课里，你用的都是嵌入式**集成开发环境（IDE）**，比如 KEIL uVision、IAR Embedded Workbench 或者 TI Code Composer Studio。但单元测试往往是直接从命令行跑的，所以今天你也来体验一下纯终端操作，看看是怎么回事。

Embedded-Test comes with examples, so let me just explain some of them.

Embedded-Test 自带了一些示例，我挑几个给你讲讲。

The most basic is the "basic" example. Simple as it is, it demonstrates the typical code organization for unit testing, where the code under test (CUT) is located in the "src" subdirectory, while the tests are in the "test" subdirectory.

最基础的就是"basic"这个示例。别看它简单，它展示了单元测试典型的代码组织方式：**被测代码（Code Under Test, CUT）**放在 "src" 子目录下，而测试代码放在 "test" 子目录下。

I will then first go to this "test" subdirectory to show you what a test run looks like, and then I will explain the details.

我先进入这个 "test" 子目录，给你看看测试运行起来是什么样子，然后再讲细节。

So, to run the test, you type "make." This invokes the "make" utility, which executes the build process prescribed in the Makefile located in the current directory. After building the software, "make" immediately runs the tests, which is also customary in unit testing.

要运行测试，输入 `make`。这会调用 `make` 工具，按照当前目录下 Makefile 里定义的规则来构建。构建完成后，`make` 会立刻运行测试——这也是单元测试的惯例。

However, I need to back up at this point because it won't work like that on your machine. You probably don't have the "make" utility or the gcc compiler installed, so your attempt to run "make" will look like this.

不过我得退一步说——在你自己的机器上可能不会这么顺利。你很可能还没装 `make` 工具或 gcc 编译器，所以你运行 `make` 的时候会是这样。

You have several options to get "make" and other Unix-style utilities commonly used in building and testing.

要拿到 `make` 和其他构建、测试常用的 Unix 风格工具，你有几个选择。

First, you can use Linux or macOS instead of Windows, and the provided Makefile should work without any modifications. But even then, you must ensure that "make" and "gcc" are installed.

第一，你可以不用 Windows，改用 Linux 或 macOS，这样提供的 Makefile 不用改就能用。但即使这样，你也得确认 `make` 和 `gcc` 都装好了。

Another option is to activate the Windows Subsystem for Linux (WSL), but this requires installing a whole Linux distribution, on top of which you'll still need to install "make," "gcc," and perhaps other things.

第二个选择是启用**适用于 Linux 的 Windows 子系统（WSL）**，但这得装一整个 Linux 发行版，装完之后还得再装 `make`、`gcc`，可能还有别的东西。

Instead of all that, I use the QTools collection for Windows, which has been specifically designed to provide everything in one simple installation. QTools downloads are available from GitHub and contain all Unix-like utilities commonly used in Makefiles as native Windows executables.

与其这么折腾，我更推荐用 Windows 版的 **QTools** 工具集。它是专门设计的，一个安装包就能搞定一切。QTools 可以从 GitHub 下载，里面把 Makefile 常用的所有类 Unix 工具都打包成了原生 Windows 可执行文件。

To get QTools from GitHub, go to QTools releases and download the latest digitally signed Windows installer, which is the easiest way. If you are allergic to installers, you can also download QTools as a ZIP file, but this requires additional steps to set the PATH and some environment variables.

去 GitHub 上的 QTools releases 页面，下载最新的数字签名 Windows 安装程序，这是最省事的方式。如果你不喜欢安装程序，也可以下载 ZIP 包，但那样就得多做几步——手动设置 PATH 和一些环境变量。

You can install the qtools-windows executable (or unzip the qtools-windows ZIP archive) in any location, but I highly recommend avoiding locations with spaces or special characters, such as "Program Files." I installed my qtools in the default location: c:\qp.

安装 qtools-windows 可执行文件（或者解压 ZIP 包）放在哪都行，但我强烈建议避开带空格或特殊字符的路径，比如"Program Files"。我把它装在了默认位置：c:\qp。

After installation, the content of the qtools folder should look as follows:

装好之后，qtools 文件夹里的内容应该长这样：

In the bin directory, you get the Unix-style utilities, such as make, and commands commonly used in makefiles, like cp, rm, mkdir, etc.

bin 目录里有各种 Unix 风格的工具，比如 `make`，还有 Makefile 里常用的命令，像 `cp`、`rm`、`mkdir` 等等。

In the MinGW32 directory, which stands for "Minimalist GNU for Windows," you get the GNU C/C++ compiler for Windows. This is useful for building and running tests on the host computers.

**MinGW32** 目录里（名字的意思是"Windows 的极简 GNU"），有 Windows 版的 GNU C/C++ 编译器。在主机上构建和运行测试就靠它。

And finally, in the gnu_arm-none-eabi directory, you get the GNU cross compiler for ARM CPUs. This is useful for building and running tests on ARM boards, such as your TivaC LaunchPad or STM32 NUCLEO.

最后，gnu_arm-none-eabi 目录里有 ARM CPU 的 GNU 交叉编译器。要在 ARM 开发板上构建和运行测试——比如你的 TivaC LaunchPad 或 STM32 NUCLEO——就用它。

If you installed qtools using the Windows installer, the following qtools directories will be added to your PATH. Additionally, the environment variable QTOOLS will be defined.

如果你用的是 Windows 安装程序装的 qtools，以下这些 qtools 目录会自动加到你的 PATH 里，同时还会定义 QTOOLS 环境变量。

However, if you installed qtools from the ZIP file, you must manually modify the PATH and add the QTOOLS variable. You'll need these settings to conveniently access the tools from the command-line.

但如果你是从 ZIP 包安装的，就得自己手动改 PATH、添加 QTOOLS 变量。有了这些设置，你才能在命令行里方便地调用各种工具。

Alright, this would be all regarding general tooling, a general "testing habitat," if you will, for unit testing. All this is not specific to the ET testing harness and will also be useful for other testing harnesses.

好，关于通用工具就说到这里——如果愿意的话，你可以把它看作单元测试的通用"测试栖息地"。这些都不是 ET 线束特有的，对其他测试线束同样有用。

So, now, let's go back to the basic unit testing example, and look at the CUT (Code Under Test) and the tests around it.

好，现在回到那个基础单元测试示例，看看被测代码（CUT）和它周围的测试代码。

The CUT is trivial in this basic example and consists of the files sum.h and sum.c. The header file provides the prototype of the function sum(), while the source file contains the implementation. The function simply calculates and returns the integer sum of the integer x and y parameters.

在这个基础示例中，CUT 特别简单，就两个文件：sum.h 和 sum.c。头文件里放了 `sum()` 函数的原型声明，源文件里是具体实现。这个函数做的事很简单——把两个整数参数 x 和 y 加起来返回。

The test file in the test subdirectory is more interesting. It starts with including the CUT and the Embedded-Test unit testing harness.

test 子目录里的测试文件就有意思多了。它开头先包含了被测代码和 Embedded-Test 单元测试线束的头文件。

Next are two functions setup() and teardown(), which ET executes before and after each test.

接下来是两个函数 `setup()` 和 `teardown()`，ET 会在每个测试之前和之后分别调用它们。

Next comes a test group, which provides the name of this group of tests and produces the output shown in the terminal.

然后是一个**测试组（Test Group）**，给它起个名字，运行时这个名字会显示在终端里。

Next come individual tests. They start with the macro TEST() with the test description, which in ET is an arbitrary string displayed in the terminal.

接下来是各个具体的测试。每个测试以 `TEST()` 宏开头，后面跟测试描述——在 ET 里，描述可以是任意字符串，会显示在终端中。

Inside the tests, you see the VERIFY() macros, which evaluate the provided boolean expressions. The test passes only when all VERIFY() expressions in that test are true. Otherwise, the test fails at the first failing VERIFY().

在测试里面你会看到 `VERIFY()` 宏，它用来检查你传给它的布尔表达式。只有当测试中所有 `VERIFY()` 表达式都为真时，测试才算通过。否则，碰到第一个失败的 `VERIFY()` 测试就挂了。

If you watched previous lessons 47 and 48, you might have noticed that the VERIFY() macro resembles the ASSERT() facility. Indeed, other unit testing harnesses provide various "test assertions" to verify test conditions. However, this might create confusion with the true assertions in the Code Under Test, and therefore ET provides the VERIFY() facility. This basic test group also demonstrates a skipped test, which ET does not execute. Temporarily skipping a test is often useful when you work on a quickly changing code.

如果你看过第 47 和 48 课，可能会注意到 `VERIFY()` 宏跟 `ASSERT()` 机制很像。确实，其他单元测试线束提供各种"测试断言"来验证测试条件。但这容易跟被测代码里真正的断言搞混，所以 ET 用的是 `VERIFY()`。这个基础测试组还演示了一个被跳过的测试——ET 不会执行它。当你的代码还在快速变化时，临时跳过某个测试常常很有用。

Finally, this example contains an intentionally failing test, which terminates the test run with a printout of the line number and the failing expression in the VERIFY() facility. ET does not execute any tests after a failing one because the system might be in an unknown state, and any subsequent tests might give incorrect results.

最后，这个示例里还有一个故意让它失败的测试。一旦失败，测试运行就终止，并打印出失败的行号和 `VERIFY()` 中失败的表达式。ET 在遇到失败的测试后不会再跑后面的测试，因为系统状态可能已经不确定了，后面的测试结果可能也不靠谱。

Of course, ET has many more interesting features, such as a special way of testing assertions in the CUT, where you specifically test for and expect an assertion failure, resulting in a passing test.

当然，ET 还有很多有意思的功能。比如有一种特殊的方式来测试 CUT 中的断言——你专门去测试并期望某个断言失败，如果它真的失败了，测试反而算通过。

But perhaps the most significant difference from other unit testing harnesses written in C, such as Unity shown a moment ago, is that ET does not need any "test runners." Unlike in Unity, tests are not separate C functions in ET. Instead, individual tests are just code blocks with their own scope for local variables, all within the test-group, which is a function in ET.

但跟其他用 C 写的单元测试线束（比如刚才提到的 Unity）相比，最显著的区别可能就是：ET 不需要任何"测试运行器"。在 Unity 里，每个测试是一个独立的 C 函数，但在 ET 里不是这样。ET 中的每个测试只是一个代码块，有自己的局部变量作用域，所有测试都在测试组内部——而测试组本身才是一个函数。

Alright, with this quick introduction to ET, you should be able to explore other ET examples on your own as homework from this lesson. For instance, you should take a look at the "lock-free ring buffer" code, which is quite useful in embedded programming. You might also like to see how to test C++ code with ET. Finally, you might enjoy the "leddriver" example, which demonstrates that ET can test most of the code from the already mentioned TDD book, which I highly recommend.

好了，ET 就快速介绍到这里。作为本课的作业，你应该可以自己去探索其他 ET 示例了。比如那个"lock-free ring buffer"（无锁环形缓冲区）的代码，在嵌入式编程中相当实用。你也可以看看怎么用 ET 测试 C++ 代码。还有"leddriver"示例也挺有意思，它演示了 ET 能跑前面提到的那本 TDD 书里的大部分代码——那本书我强烈推荐。

Speaking of James Grenning's book, you might have noticed that I have performed the testing on the host computer. Grenning calls this strategy dual-targeting, meaning that from day one, your code is designed to run on two platforms: the final embedded target and your development host computer.

说到 James Grenning 的书，你可能注意到了，我刚才都是在主机上跑测试的。Grenning 把这种策略叫做**双重目标（Dual-Targeting）**，意思是从第一天起，你的代码就设计成能在两个平台上跑：最终的嵌入式目标板，和你开发用的主机。

Dual-targeting is sometimes confused with emulation of the embedded target on the host with software such as QEMU. But dual-targeting is actually simpler. You really build the embedded code with a native compiler for your host, such as MinGW gcc, and you also run the tests on your host.

双重目标有时会被人跟在主机上用 QEMU 之类的软件仿真嵌入式目标搞混。但双重目标其实更简单。你做的就是用主机的原生编译器（比如 MinGW gcc）来编译嵌入式代码，然后在主机上跑测试。

The dual-targeting strategy has a number of benefits, such as a much quicker evolutionary cycle because you avoid the target hardware bottleneck. Also, it's easier to automate host-based tests. But above all, dual-targeting influences your design because to test embedded code on the host, you must pay close attention to the boundaries between the hardware and software.

双重目标策略的好处不少。比如演化周期快得多，因为你不用等目标硬件的瓶颈。而且基于主机的测试更容易自动化。但最重要的是，双重目标会影响你的设计——因为要在主机上测试嵌入式代码，你必须认真对待硬件和软件之间的边界。

I have used dual-targeting for many years and cannot imagine embedded software development without it. A team that embraces dual-targeting will easily outperform any team that doesn't. This is one of the most powerful tools in the war chest of professional embedded developers.

我用双重目标很多年了，简直无法想象没有它怎么做嵌入式开发。采用双重目标的团队，轻松就能甩开不用的团队。这是专业嵌入式开发者武器库里最强大的工具之一。

Having said all this, running the tests exclusively on the host will not cut it, and at least occasionally, you need to run the tests on your embedded target as well. The ET testing harness has been specifically designed to make it easy, which I'd like to now demonstrate.

话虽如此，光在主机上跑测试还是不够的，至少偶尔你也得在实际的嵌入式目标上跑一跑。ET 测试线束专门做了设计，让这件事变得很简单——我现在就来演示一下。

So, let's go back to the basic ET example. Besides the Makefile you used to build and test on the host, you can find two .mak files for testing on the EK-TM4C and NUCLEO-C031 embedded boards, respectively.

回到那个 ET 基础示例。除了你用来在主机上构建和测试的 Makefile 之外，你还能看到两个 .mak 文件，分别用于 EK-TM4C 和 NUCLEO-C031 这两块嵌入式开发板。

Let's start with the EK-TM4C, a.k.a. Tiva Launchpad board. Plug it into your computer and open the serial terminal, such Termite, which the QTools collection conveniently provides. You can launch Termite from your terminal by typing termite ampersand.

先从 EK-TM4C，也就是 Tiva LaunchPad 开发板开始。把它插到电脑上，然后打开串口终端，比如 Termite——QTools 工具集里正好带了它。你可以在终端里输入 `termite &` 来启动。

Now, type make -f ek-tm4c123gxl.mak. This builds the same test code as before, but this time using the GNU-ARM cross-compiler from QTools.

现在输入 `make -f ek-tm4c123gxl.mak`。这会构建跟之前一样的测试代码，但这次用的是 QTools 里的 GNU-ARM 交叉编译器。

As usual, immediately after the build, "make" uploads the code to the target, and normally it would also run it. But the LmFlash utility for the TivaC board has some quirks with resetting the board that I couldn't figure out. Therefore, this "makefile" asks you to reset the board manually.

跟之前一样，构建完成后 `make` 会立刻把代码烧录到目标板上，通常也会自动运行。不过 TivaC 板用的 LmFlash 工具在重置开发板这件事上有些怪问题，我始终没搞定。所以这个 makefile 会提示你手动重置开发板。

After you reset the board, the tests execute, and the serial terminal displays the test run, which is identical to the one produced on the host.

重置之后，测试就开始跑了，串口终端里显示的测试结果跟主机上的一模一样。

You can also try the "makefile" for the NUCLEO board. For that, plug the NUCLEO-C031 board into your computer.

你也可以试试 NUCLEO 开发板的 makefile。把 NUCLEO-C031 开发板插到电脑上。

If you still have the serial terminal open, close it and launch it again to connect to the new board.

如果串口终端还开着，先关掉再重新打开，这样它才能连上新板子。

Now, type: make -f nucleo-c031c6.mak. This produces the message that the USB drive is not provided. That's because NUCLEO boards show up on your computer as USB drives and can be programmed by simply copying binaries to that drive. This is very convenient because you don't need any additional utilities, like LmFlash for TivaC.

现在输入 `make -f nucleo-c031c6.mak`。它会提示 USB 驱动器未指定。这是因为 NUCLEO 开发板在电脑上会显示为一个 USB 驱动器，烧录程序只需要把二进制文件拷贝到那个驱动器里就行。这很方便，因为你不需要额外的工具，不像 TivaC 还得用 LmFlash。

On my computer, the NUCLEO board enumerated as the G: drive, so I provide the USB drive as follows: make -f nucleo-c031c6.mak USB=E:

我这台电脑上，NUCLEO 开发板被识别为 G: 盘，所以我这样指定 USB 驱动器：`make -f nucleo-c031c6.mak USB=E:`

Of course, you need to use the appropriate USB drive for your NUCLEO.

当然，你要填你自己 NUCLEO 板对应的盘符。

The make command builds, uploads, and automatically executes the basic tests on the board.

make 命令会完成构建、烧录，并自动在开发板上运行基础测试。

Again, the output sent to the serial terminal is identical to the previous one for TivaC and the original testing on the host.

串口终端输出的结果跟之前 TivaC 的、以及最初在主机上跑的完全一样。

So now, let me quickly explain how this testing on the embedded boards, as well as the host, works. As always in embedded systems, the biggest problem is getting the information (like the test results in this case) from the board to the host. You've encountered this before in this course, back in lesson 45, about software tracing with printf().

好，现在我来快速解释一下，在嵌入式开发板和主机上跑测试到底是怎么回事。嵌入式系统的老问题——最大的困难就是从板子上把信息（比如测试结果）传回主机。你之前在这门课里就遇到过这个问题，第 45 课讲用 `printf()` 做软件追踪的时候。

The solution applied in ET is also similar to lesson 45 in that the communication happens over a UART. This always depends on the particular board, so in the test directory, you have the board support packages (BSPs) for TivaC and the NUCLEO board.

ET 里的解决方案也跟第 45 课类似——通信走的是 UART。但具体怎么做总是取决于具体的板子，所以在 test 目录下，你能找到 TivaC 和 NUCLEO 开发板各自的**板级支持包（Board Support Package, BSP）**。

When you look inside one of these BSPs, you see three ET callback functions. ET_onInit() initializes the UART. ET_onPrintChar() transmits one character to the UART. And finally, ET_onExit() implements behavior after all tests finish. An embedded target cannot really exit, so this function hangs in an endless loop, blinking the onboard LED.

打开其中一个 BSP，你会看到三个 ET 回调函数。`ET_onInit()` 负责初始化 UART，`ET_onPrintChar()` 通过 UART 发送一个字符，`ET_onExit()` 则处理所有测试跑完之后的行为。嵌入式目标没法真正"退出"，所以这个函数会挂在一个无限循环里，让板载 LED 闪烁。

Here, I'd like to note that ET does not actually use printf() because it is a huge function, and customizing it to work with a specific UART is implementation dependent. Indeed, one of the design principles for ET is to carefully avoid any dependencies on the standard library or anything else.

这里要说明一下，ET 实际上并不使用 `printf()`，因为那是个非常庞大的函数，而且要把它适配到特定的 UART 上，实现方式因平台而异。事实上，ET 的设计原则之一就是小心避免对标准库或任何其他东西产生依赖。

But none of these restrictions matter for the host computers, where the three ET callbacks are provided in the file et_host.c in the et directory. That implementation uses the fputc() and exit() functions from the standard library, but again, this is only for the host.

但这些限制对主机来说都不是事儿。主机的三个 ET 回调函数在 et 目录下的 et_host.c 文件里。那个实现用了标准库的 `fputc()` 和 `exit()` 函数，但再说一遍，这只是主机上的情况。

This concludes this quick introduction to testing embedded software. The most important takeaway from this lesson is that the only way to create non-trivial software is to evolve it, and the winners of the software development game are those who evolve the software faster by applying better, smarter, and more effective testing techniques to eliminate more defects sooner.

嵌入式软件测试的快速入门就到这里了。这节课最重要的结论是：创建真正有意义的软件，唯一的方法就是让它一步步演化。软件开发这场游戏的赢家，是那些演化得更快的人——他们用的是更好、更聪明、更高效的测试技术，能在更早的阶段消灭更多的缺陷。

This software evolution is guided by artificial selection that requires building artificial environments for testing the software.

这种软件演化靠的是人工选择来引导，而人工选择就需要你搭建人工环境来测试软件。

This lesson gave you a general idea about one such artificial environment for unit testing (a unit testing harness), but the general idea is similar for most such harnesses.

这节课给你介绍了一种用于单元测试的人工环境——单元测试线束。大多数类似的线束，基本思路都差不多。

Newcomers to unit testing are often confused as to what exactly is being tested. A first impression might be that testing is only about the CUT (Code Under Test). But you must realize that all tests necessarily exercise both the CUT and the test environment. Therefore, methodologies like Test Driven Development (TDD) recommend starting the process without a CUT. The purpose of this first failing test is really to test the environment.

刚接触单元测试的人经常会困惑：到底在测什么？第一印象可能觉得，测试就是测被测代码（CUT）。但你必须意识到，所有测试其实都在同时检验 CUT 和测试环境本身。正因如此，像**测试驱动开发（TDD）**这样的方法论建议你一开始先不写 CUT。第一个失败的测试，真正的目的就是验证测试环境本身是否正确。

And finally, when you start testing more systematically, you will accumulate many tests. On the one hand, such tests are valuable for checking that your software keeps working and the new features don't break the old ones, which is called regression testing. On the other hand, tests are code, too, and the more code you have, the slower you can progress. The trick is to find the right balance and discard the less relevant tests. Keeping all tests forever is a mistake.

最后，当你开始更系统地做测试，测试会越积越多。一方面，这些测试很有价值——它们能帮你确认软件没有出问题，新功能没有破坏老功能，这就是**回归测试（Regression Testing）**。另一方面，测试也是代码，代码越多，推进速度就越慢。关键在于找到平衡，该丢掉的测试就丢掉。永远保留所有测试是不对的。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads. Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course." Thanks for watching!

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/video-course 下载。所有项目也在 GitHub 上的 Quantum Leaps 仓库"modern embedded programming course"里。感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Testing | 测试 | 软件开发中验证代码正确性的过程，本课中作为软件演化的"选择机制" |
| Natural Selection | 自然选择 | 达尔文进化论的核心概念，不断淘汰不太适应的变异 |
| Artificial Selection | 人工选择 | 由人类主导的选择过程，在更短的时间尺度上运作，类比于软件测试 |
| Waterfall Process | 瀑布流程 | 一种传统的软件开发方法，强调大规模的前期设计和一次性最终测试 |
| Agile Software Development | 敏捷软件开发 | 一种强调迭代开发和持续测试的软件开发方法论 |
| Test-Driven Development (TDD) | 测试驱动开发 | 先写测试再写代码的开发方法，测试用于引导整个开发过程 |
| Continuous Integration (CI) | 持续集成 | 频繁将代码集成到共享仓库的实践，每次集成都通过自动化测试验证 |
| Continuous Delivery (CD) | 持续交付 | 持续集成之后的扩展实践，确保软件随时可以可靠地发布 |
| Unit Testing | 单元测试 | 对最小可隔离的软件组件（如函数和模块）进行的独立测试 |
| Testing Harness / Testing Framework | 测试线束 / 测试框架 | 用于支持单元测试的人工环境，提供测试组织、执行和报告功能 |
| Code Under Test (CUT) | 被测代码 | 正在被测试的软件代码 |
| Dual-Targeting | 双重目标 | 一种开发策略，从第一天起代码就设计为同时运行在主机和嵌入式目标上 |
| Regression Testing | 回归测试 | 确保新代码不会破坏已有功能的测试 |
| Board Support Package (BSP) | 板级支持包 | 针对特定开发板的硬件抽象层，封装了底层硬件操作细节 |
| UART | 通用异步收发传输器 | 一种常见的串行通信协议，用于嵌入式开发板与主机之间的数据传输 |
| Cross Compiler | 交叉编译器 | 在一个平台上编译生成另一个平台（如 ARM）上运行的代码的编译器 |
| ET (Embedded-Test) | Embedded-Test | 本课介绍的轻量级 C 语言单元测试线束，无需测试运行器 |
| VERIFY() macro | VERIFY() 宏 | ET 中用于验证测试条件的宏，失败时终止测试 |
| setup() / teardown() | setup() / teardown() | 在每个测试之前和之后执行的初始化和清理函数 |
| Makefile | Makefile | `make` 工具使用的构建配置文件，定义构建和测试的规则 |
| MinGW (Minimalist GNU for Windows) | Windows 的极简 GNU | Windows 平台上的 GNU 编译器工具集 |
| QTools | QTools | Quantum Leaps 提供的工具集，包含构建和测试嵌入式软件所需的工具 |
| Lock-free Ring Buffer | 无锁环形缓冲区 | 一种不需要锁机制的并发安全数据结构，常用于嵌入式编程中 |
| Software Tracing | 软件追踪 | 通过串口等接口从嵌入式目标输出调试信息的技术 |
