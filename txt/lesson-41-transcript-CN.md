# 第41课：状态机——自动代码生成 / Lesson 41: State Machines — Automatic Code Generation

Hello and welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this seventh lesson on state machines I'd like to show you how you can automatically generate code from your state machines. Graphical modeling and automatic code generation do not seem to be mainstream yet, but they are very much parts of the *modern* approach and I believe they are the future of embedded software development.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。在状态机系列的第七课里，我来给你演示如何从状态机自动生成代码。图形化建模和自动代码生成目前还不是主流，但它们确实是*现代*方法的重要组成部分，而且我相信这就是嵌入式软件开发的未来。

Today, you'll see how code generation actually works and in the process, I will try to convince you about the benefits of graphical modeling as opposed to writing your code manually. You'll then see what the *real* issues with modeling and code generation are, because chances are that they are quite different from what you might think right now. So, let's get to it!

今天你会看到代码生成到底是怎么工作的。在这个过程中，我会试着说服你——图形化建模比起手动写代码到底好在哪里。然后你还会看到建模和代码生成的*真正*问题是什么——很可能跟你现在的想法完全不一样。那我们开始吧！

As usual, let's get started with copying the previous lesson-40 directory and renaming it to lesson-41.

照例，先把上一课的 lesson-40 目录复制一份，改名为 lesson-41。

Get inside the new lesson-41 directory, but instead of opening the project "lesson" in the Micro-Vision IDE right away, let's start today with the QM model, also provided in that directory.

进入新的 lesson-41 目录。不过先别急着在 Micro-Vision IDE 里打开项目——今天我们先从目录里的 QM 模型文件开始。

Now, you've seen the QM modeling tool before, but it was used just as a drawing tool for creating state machine diagrams. The way those diagrams were created didn't really matter and any other tool would do, including just pen and paper or a whiteboard.

之前你见过 QM 建模工具，但那时候只是拿它当画图工具来画状态机图。图怎么画的其实无所谓，用其他任何工具都行——甚至纸笔或白板也可以。

But today, QM will be an essential tool, because you will finally use its code generation capabilities. Therefore, I first need to show you how you can get QM and install it on your machine.

但今天不一样了，QM 会成为不可或缺的工具——因为你终于要用它的代码生成功能了。所以，我得先教你如何获取 QM 并安装到你的电脑上。

To download QM, you can visit the companion web-page to this video course at state-machine.com/video-course and look for the project downloads. The software that you need for each lesson is listed in the table.

要下载 QM，可以去本课程的配套网页 state-machine.com/video-course，找到项目下载区域。每节课需要用到的软件都列在表格里了。

So, for today's lesson 41 you will need qp-bundle, which you can download for Windows, Linux, and MacOS.

今天的第41课需要用到 **qp-bundle**，它有 Windows、Linux 和 MacOS 版本可以下载。

Assuming that you work on Windows, you should download QP-bundle for Windows.

如果你用 Windows，就下载 Windows 版的 QP-bundle。

Now, as the name suggests, the QP-bundle contains much more than just QM. For example, you also get the QP/C framework that you have already used for the past several lessons, but separately.

顾名思义，QP-bundle 里的东西远不止 QM 一个。比如，里面还有 QP/C 框架——过去几节课你一直在用它，只不过之前是单独安装的。

If you're interested exactly what's inside QP-bundle, you could watch the "Getting Started" video.

如果你想知道 QP-bundle 里具体有什么，可以看看"Getting Started"那个视频。

But for today, let's just run the digitally signed Windows installer.

今天我们直接运行经过数字签名的 Windows 安装程序就行。

As far as the installation is concerned, after accepting the license agreement, I recommend to install the QP-bundle in the default location C:\qp.

安装方面，接受许可协议后，我建议安装在默认位置 C:\qp。

Next, you can de-select the individual components of the bundle, but I recommend that you keep all of them. Among others, you're getting here the QP/C and QP/C++ frameworks, the QM modeling tool, and the GNU C-and-C++ compilers for the desktop Windows as well as the cross-compiler for ARM Cortex-M. These command-line compilers are quite useful for testing embedded software both on the desktop and on the embedded targets. You will see how to do this in the future lessons of this course.

接下来你可以取消选择某些组件，但我建议全部保留。其中包括 QP/C 和 QP/C++ 框架、QM 建模工具，还有桌面 Windows 用的 GNU C/C++ 编译器以及 ARM Cortex-M 的交叉编译器。这些命令行编译器在桌面和嵌入式目标上测试嵌入式软件时非常好用。后面的课程会教你如何使用它们。

I also recommend that you keep the option to add the QP-bundle installation folder to your path.

另外我建议保留"将 QP-bundle 安装目录添加到系统路径"这个选项。

So, finally, you can run the installation, which takes a minute or two.

最后运行安装，大概一两分钟就好了。

Once the installation completes, the .QM files are recognized in the Windows Explorer and shown with a red-ball icon. You can open them in QM by double-clicking.

安装完成后，Windows 资源管理器会识别 .QM 文件，显示一个红色球体图标。双击就能在 QM 里打开它们。

Alternatively, you can simply open the QM modeler via a QM shortcut on your desktop and either open the model through the file menu or by dragging and dropping the model file on the QM modeler.

你也可以通过桌面上的 QM 快捷方式打开建模器，然后从文件菜单打开模型，或者直接把模型文件拖进 QM 窗口。

Either way, you should now have the model of your TimeBomb from the last lesson open in QM. If you don't see the state machine, you can double-click on the TimeBomb class in the Model Explorer.

不管用哪种方式，现在你应该在 QM 里打开了上一课的 TimeBomb 模型。如果看不到状态机，在**模型浏览器**（Model Explorer）里双击 TimeBomb 类就行。

Of course, QM offers also the Help menu, where, among others, you can learn how to get started with QM. Here, I'd recommend that you check out the QM Tutorial, which is available as a video, or as a step-by-step guide.

当然，QM 也有帮助菜单，里面有入门指南等内容。我推荐你看看 QM 教程，有视频版也有分步指南版。

But going back to your TimeBomb model, let's start with correcting the model documentation.

回到你的 TimeBomb 模型，先来修正一下模型文档。

Now, the state diagram is done, but the actions taken in the state machine are only provided as pseudocode. This was good enough to avoid clutter in your diagram, but for code generation, you need to provide the actual actions in C.

状态图本身已经画好了，但状态机里的动作只写了伪代码。这样画图的时候不显乱，挺好。但要生成代码的话，你得提供真正的 C 语言动作代码。

For that, alongside QM, you can open the Micro-Vision project, where you have your manually written state machine code. You can then copy the actions in C back into the model.

为此，在 QM 旁边再打开 Micro-Vision 项目，那里有你手写的状态机代码。然后把 C 语言的动作代码复制回模型里就行。

This is actually my general game plan for today. I will go backwards: from the final code that you already know, because you wrote it manually. You will then see what you need to do, back in the model, in order to generate essentially the same code, but this time do it automatically.

这其实就是今天的总体思路——我要倒过来做。从你已经熟悉的最终代码开始（因为那是你手写的），然后看回到模型里需要做什么，才能生成基本相同的代码——只不过这次是自动生成的。

For every action code, every time you see some pseudocode in the model, you need to copy over the actual, corresponding code in C for that action.

每个动作代码都是这样——你在模型里看到伪代码，就把对应的真实 C 代码复制过去。

OK, so now the state machine is fully defined, but you still need to make sure that your TimeBomb class has all the attributes that you accessed through the "me" pointer. Specifically, in your actions you used the "te" attribute to be the QP time event of the type QTimeEvt. You also used the blink_ctr attribute of the type uint32_t.

好了，状态机现在完全定义好了。但你还得确保 TimeBomb 类具备所有通过 `me` 指针访问的属性。具体来说，你的动作里用了 `te` 属性来存放 QTimeEvt 类型的 QP 时间事件，还用了 uint32_t 类型的 `blink_ctr` 属性。

You can also provide operations of your TimeBomb class, for example, the constructor. Please remember that QM will automatically prepend the class name to all class operations, because it knows the conventions for object-oriented programming in C, which you've learned back in lessons 29 through 32. Here, you can also specify both the return type as well as any parameters, if needed, again remembering that QM will automatically supply the "me" pointer for class operations. Finally, you can provide the actual code of the operation.

你还可以给 TimeBomb 类添加操作，比如构造函数。记住，QM 会自动给所有类操作加上类名前缀，因为它懂第 29 到 32 课里你学过的 C 语言面向对象编程的命名约定。在这里你也可以指定返回类型和参数（如果需要的话）。同样要记住，QM 会自动为类操作提供 `me` 指针。最后，你可以填写操作的实际代码。

So, now all aspects of your TimeBomb class are fully designed. This is called **"logical design"**, because it specifies all the items, such as classes, and their internal structure, such as attributes, operations, and state machines.

好，TimeBomb 类的所有方面都设计完了。这叫做**逻辑设计**（logical design）——它定义了所有的模型项（比如类）及其内部结构（属性、操作和状态机）。

But such logical design says nothing about the code organization. The code structure, that is, the directories and files, are the subject of the so called **physical design**.

但逻辑设计不管代码怎么组织。代码的结构——也就是目录和文件——是**物理设计**（physical design）要操心的事。

The majority of modeling and code generating tools don't really support the "physical design". The generated code goes simply to a predetermined directory and has a rather rigid structure: Typically, for each class a tool generates a header file named "class-name.h" and an implementation file named "class-name.c".

大多数建模和代码生成工具并不真正支持物理设计。生成的代码就是丢到一个预定义的目录里，结构也很死板：通常是每个类生成一个 `类名.h` 头文件和一个 `类名.c` 实现文件。

But QM is a unique modeling tool that fully supports the physical design and allows *you* to organize the generated code whichever way you like.

但 QM 不一样——它完全支持物理设计，允许*你*按自己喜欢的方式组织生成的代码。

Fully supporting physical design means that directories and files become explicit, first-class model items, just like classes, attributes, operations and state machines are.

完全支持物理设计意味着，目录和文件变成了显式的、一等公民级别的模型项——跟类、属性、操作和状态机平起平坐。

So, for example, in QM you *can* choose to generate the code exactly as you have organized your manually-written code.

所以，举个例子，在 QM 里你*可以*选择让生成的代码跟你手写代码的组织方式完全一致。

Specifically, your current code consists of main.c, bsp.h and bsp.c. Out of these files, only the source file main.c contains the TimeBomb active object class and its state machine.

具体来说，你现在的代码由 main.c、bsp.h 和 bsp.c 组成。其中只有 main.c 包含 TimeBomb 活动对象类和它的状态机。

So, let's generate only the main.c file in the same directory as your TimeBomb.qm model file. This will illustrate a non-standard physical design, as well as flexibility to mix and match generated code with any other code located in the same file, like main.c, and in other files, such as bsp.h and bsp.c.

那我们就只生成 main.c 文件，放在跟 TimeBomb.qm 模型文件同一个目录里。这样可以演示一种非标准的物理设计，同时展示生成的代码可以和同一文件（如 main.c）及其他文件（如 bsp.h、bsp.c）中的手工代码灵活混搭。

The physical design starts with a directory item. Your current model already contains a directory, but it was for the original Blinky model template, so let's just delete it and start today from scratch.

物理设计从目录项开始。你当前的模型已经有一个目录了，但那是原来 Blinky 模型模板带的，我们把它删掉，今天从头来。

To add a directory to your model, right-click on the model item and choose "Add Directory" from the popup menu.

要给模型添加目录，右键点击模型项，从弹出菜单中选择"Add Directory"。

Next in the Property Editor, change the generic directory path to "." (dot), meaning that your code directory will be the same as the model directory. The directory path is always relative to the model file and can include ".." for going up levels, as well as slashes and directory names for going down levels. But today, you just want the current model directory, so you leave it as "." (dot).

然后在属性编辑器里，把目录路径改成 `.`（点），意思是代码目录就跟模型目录一样。目录路径始终相对于模型文件，可以用 `..` 往上一级，也可以用斜杠和目录名往下一级。但今天我们就要当前目录，所以保持 `.` 就行。

Once you have a directory you can add files into it by right-clicking on the directory and choosing "Add File" popup menu.

有了目录之后，右键点击它，从弹出菜单选"Add File"就能往里面添加文件。

Your physical design for today is to generate the file named main.c. As soon as you provide the extension, QM will recognize it as a C file and will apply C syntax coloring to it.

今天的物理设计是生成一个叫 main.c 的文件。你一输入扩展名，QM 就认出这是 C 文件，自动给它加上 C 语法高亮。

Now, you need to edit the body of the file. For this you open the file by double-clicking on it.

接下来要编辑文件内容。双击文件就能打开。

Your main.c file starts obviously empty, but today you want it to look like your manually-created code. So, continuing to work backwards, you first copy the entire content of your existing main.c file and paste all of this into your main.c model item.

main.c 文件一开始当然是空的，但你今天想让它跟你手写的代码一样。所以继续倒着来——先把现有 main.c 文件的全部内容复制过来，粘贴到 main.c 这个模型项里。

Now, if you would leave it at this, QM would literally copy the content of the file item from the model to the specified directory and file on disk.

就这样放着的话，QM 会把模型里文件项的内容原样复制到磁盘上对应的目录和文件。

But the twist here is that you can also instruct QM to generate specific parts of the file.

但妙就妙在，你还可以让 QM 只生成文件的特定部分。

For example, this part of your manually created code corresponds to the *declaration* of your TimeBomb class.

比如，你手写代码中的这一段对应的是 TimeBomb 类的*声明*（declaration）。

So, you can replace it with the directive to QM to generate such a declaration for you.

那你可以把它替换成一条指令，让 QM 替你生成这个声明。

You specify this by typing $declare and dragging the desired model element, such as your TimeBomb class, from the Model Explorer like this. Of course, you could also simply type the name of the model item.

输入 `$declare`，然后从 Model Explorer 把想要的模型元素（比如你的 TimeBomb 类）拖过来就行。当然，你也可以直接输入模型项的名字。

The next big segment of code contains the definitions of the TimeBomb class state machine and other operations. So, you can again replace all of this with the directive to QM to generate the *definition* of the whole TimeBomb class. As you probably expect, you specify this by typing $define and dragging the TimeBomb class item from the Model Explorer, like this.

下面一大段代码是 TimeBomb 类的状态机和其他操作的定义。同样，你可以把它们全部替换成一条指令，让 QM 生成整个 TimeBomb 类的*定义*。你可能猜到了——输入 `$define`，然后从 Model Explorer 把 TimeBomb 类拖过来。

And this is it. Now you can let QM generate the code by clicking on the toolbar button or pressing the F7 shortcut key.

就这样。现在点击工具栏按钮或者按 F7 快捷键，就能让 QM 生成代码了。

This causes QM to generate the main.c file on disk, and in the process to verify your model items that you asked QM to generate.

QM 会在磁盘上生成 main.c 文件，同时验证你让它生成的那些模型项。

QM reports all this in the Log Console, whereas only the files that actually have changed get overwritten on disk.

QM 在 Log Console 里报告所有信息，而磁盘上只有实际发生变化的文件才会被覆盖。

This time around the file main.c has changed, which the Micro-Vision IDE notices and asks you to reload the file.

这次 main.c 确实变了，Micro-Vision IDE 检测到了，会提示你重新加载文件。

At the top of the generated file, you can see the comment added by QM, which tells you not to edit the file manually, because all your changes will be lost when the file is re-generated. This means that from now on, you should only modify the file in QM and let QM re-generate the file after each change.

在生成文件的顶部，你会看到 QM 加的注释，告诉你不要手动编辑这个文件——重新生成时所有改动都会丢失。也就是说，从现在开始，你只能在 QM 里修改，每次改完后让 QM 重新生成。

But below that you can see the section copied verbatim from your file item in the model.

注释下面是从模型文件项中原样复制的代码段。

The $declare directive from the model is expanded into the declaration of your TimeBomb class, essentially identical to how you declared the class before.

模型里的 `$declare` 指令被展开成了 TimeBomb 类的声明，跟你之前手写的声明基本一模一样。

Below this, you have the expanded $define directive.

再往下是展开后的 `$define` 指令。

And below that, again a snippet of code copied verbatim from your file item.

再往下，又是一段从文件项原样复制的代码片段。

Again, the generated code is essentially identical to your hand-written code before, and in particular it follows exactly the same rules for coding states, transitions, entry/exit actions and superstates.

生成的代码跟你之前手写的代码本质上是一样的，尤其是在编码状态、转换、进入/退出动作和超状态时，遵循的是完全相同的规则。

This must be so, because the implementation strategy for state machines is determined by the underlying framework, which is QP/C in this case. In fact, the framework is the whole enabler of code generation, exactly because it provides the well-established rules for codifying various model elements.

这是必然的，因为状态机的实现策略由底层框架决定——这里就是 QP/C。事实上，框架正是代码生成的基石，因为它为各种模型元素的编码提供了成熟的规则。

The generated code contains also some comments, which are designed to help you navigate between the model and the code, but I'll discuss all this in a minute.

生成的代码里还有一些注释，是用来帮你在模型和代码之间导航的，我稍后再详细说。

Because right now perhaps the most interesting for you is whether the generated code still compiles and runs...

因为你现在最关心的可能是：生成的代码能不能编译、能不能跑起来……

Well, the code builds error- and warning-free right off the bat. That's great.

结果呢，编译一次通过，零错误零警告。太棒了。

So let's load it to your TivaC LaunchPad board and test how it works...

烧录到 TivaC LaunchPad 板子上试试……

Reset: Green-LED. SW1 button: blinking Red-LED. SW2 button: Blue-LED, meaning "defused" state. SW2 button again: combination of Blue- and Green-LEDs, meaning back to "wait4button" substate. Now, SW1 button: solid Blue-LED and blinking Red-LED and finally White-LED, meaning back to the "boom" state.

复位：绿色 LED 亮。按 SW1：红色 LED 闪烁。按 SW2：蓝色 LED 亮，表示进入"defused"状态。再按 SW2：蓝色加绿色 LED 同时亮，表示回到"wait4button"子状态。再按 SW1：蓝色 LED 常亮加红色 LED 闪烁，最后白色 LED 亮——回到"boom"状态。

This is exactly the same behavior as at the end of the previous lesson-40, which means that the auto-generated code works exactly as your hand-written code before.

这跟上一课结束时的行为完全一样，说明自动生成的代码跟你之前手写的代码效果完全一致。

Alright, so this was just a simple example of code generation from a visual model, whereas I glossed over many details that turn out to be important in everyday programming practice.

好，以上只是一个从可视化模型生成代码的简单例子，很多日常编程中很重要的细节我一带而过了。

But before getting into some of these details, I'd like to step back for a minute and address some of the more fundamental questions.

在展开这些细节之前，我想先退一步，聊几个更根本的问题。

The most important such question is: Why should you even bother with modeling and code generation? I mean, isn't modeling just a costly overhead that distracts from the real work of writing code?

最重要的问题就是：为什么要费劲搞建模和代码生成？建模不就是白白浪费时间、分散你写代码的注意力吗？

Well, some of the best arguments to such a criticism I found in the article "The Pragmatics of Model-Driven Development" by Bran Selic. Please see the video description for a link to this article.

关于这种质疑，我找到的最好的反驳来自 Bran Selic 的一篇文章《The Pragmatics of Model-Driven Development》。视频描述里有这篇文章的链接。

The first argument for modeling comes from the more mature engineering disciplines, where it is inconceivable to construct a car or a house without first preparing conceptual models and detailed drawings.

建模的第一个理由来自更成熟的工程学科。在那些领域，不先做概念模型和详细图纸就去造车、盖房子——这是不可想象的。

This popularity of visual representations goes back to the human psychology. Our brain has at least an order of magnitude more hardware (more neurons) devoted to visual processing than all other senses combined. Consequently, we process visual information at a much higher bandwidth, and retain it better than any other form of information, especially complex textual representation.

为什么视觉表示这么受欢迎？这要从人类心理学说起。大脑中负责视觉处理的硬件（神经元）至少比所有其他感官加起来还多一个数量级。所以我们处理视觉信息的带宽高得多，也记得更牢——尤其是跟复杂的文字表示比起来。

As they say: "A picture is worth a thousand words", or perhaps in our field, "a thousand lines of code". But not any picture will do.

俗话说"一图胜千言"，在我们的领域可能得说"一图胜千行代码"。但不是随便什么图都行。

In order to take advantage of our visual super-intelligence, we need to choose a visual representation that is intuitive, yet precise enough to convey the information unambiguously. For example, mechanical or architectural drawings apply quite specific projections and cross-sections. Similarly, electrical schematics contain carefully chosen, and standardized symbols.

要想发挥我们的视觉超能力，就得选择一种既直观又足够精确的表示方式，确保信息传达不含糊。比如，机械或建筑图纸用的是特定的投影和剖面；电路原理图用的也是精心挑选的标准化符号。

Unfortunately in software, when visual representations are used at all, more often than not these are informal, nebulous "block diagrams" of some kind. These are often missed opportunities for applying visual intelligence, because of ambiguities and overall confusion. For example, such diagrams often mix notations: Does this arrow represent inheritance? Do these multiplicities indicate aggregation? Do the other arrows represent communication? What do the different shadings of boxes mean? How about the meaning of the different fonts? And so on...

可惜在软件领域，就算用了可视化表示，多半也是那种非正式的、含含糊糊的"方框图"。这种图根本没发挥出视觉智能的优势，因为到处都是歧义和混乱。比如，箭头代表继承吗？那些数字代表聚合吗？其他箭头代表通信吗？不同阴影的框代表什么？不同字体又是什么意思？没完没了……

For these reasons, the efforts like the Unified Modeling Language (UML), have standardized the diagrams and their semantics. But even in the UML, not all diagrams are equally expressive. Out of all the UML, **state machine diagrams** stand out as intuitive, yet precise and truly constructive, meaning really useful for effective code generation.

正因如此，**统一建模语言**（Unified Modeling Language, UML）等工作对各种图及其语义进行了标准化。但即使在 UML 里，也不是所有图的表达力都一样。在所有 UML 图中，**状态机图**（state machine diagram）脱颖而出——既直观又精确，而且真正具有构造性，也就是说对高效的代码生成非常有用。

Regarding the intuitive nature of state diagrams, here is one of the stories described by David Harel — the inventor of statecharts — in his article "Statecharts in the Making: A Personal Account". (Again, a link to this article is provided in the video description.)

说到状态图的直观性，状态图（statecharts）的发明者 David Harel 在他的文章《Statecharts in the Making: A Personal Account》中讲过一个故事。（文章链接同样在视频描述里。）

Here is what David Harel writes: "I recall an anecdote from late 1983 in which in the midst of one session an Air Force pilot entered the room. I remember him staring at our intricate statechart diagram on the blackboard... and asking, 'What's that?' One of the engineers said, 'Oh, that's the behavior of the so-and-so part of the system, and, by the way, these rounded rectangles are states, and the arrows are transitions between states.' The pilot studied the blackboard for a couple of minutes, then said, 'I think you have a mistake down here; this arrow should go over here and not over there.' He was right!

David Harel 是这么写的："我记得 1983 年末有一次开会，一位空军飞行员走进了房间。他盯着黑板上我们那张复杂的状态图……问了一句'这是什么？'一位工程师说，'哦，这是系统某部分的行为，顺便说一下，这些圆角矩形是状态，箭头是状态之间的转换。'飞行员看了几分钟黑板，然后说，'我觉得这里有个错误——这个箭头应该指到那边，不是这里。'他说对了！"

So there are certainly some compelling reasons for modeling, not just coding. Basically, you don't want to miss out on the extra visual-brainpower and the chance to engage more stakeholders in the design process, not necessarily just software developers. If you don't take advantage of these opportunities, your competition will.

所以，建模确实有充分的理由，不能只埋头写代码。说白了，你不应该浪费大脑额外的视觉处理能力，也不该错过让更多相关人员（不只是程序员）参与设计的机会。你不抓住这些机会，你的竞争对手会。

But going back to the subject of today's lesson. Code generation turns out to be critical to the success of modeling. Modeling without code generation has been tried and failed. Every time. Models that don't contribute to the final production code are like cars without wheels: they cannot go too far, become outdated and get abandoned sooner or later.

回到今天的主题。代码生成其实是建模能否成功的关键。光建模不生成代码的做法，试过了，失败了，每次都失败。不能产出最终产品代码的模型，就像没有轮子的汽车——走不远，过时就落伍，迟早被扔掉。

Alright, so assuming that you are intrigued about code generation, the next set of concerns expressed by developers first exposed to this method is about the correctness, quality, and efficiency of the generated code. These are, of course, the very same questions that were asked when compilers were first introduced more than 50 years ago. But today nobody questions anymore the efficiency of the machine code generated by the compilers.

好，假设你已经对代码生成产生了兴趣，那初次接触这种方法的开发者往往会担心：生成代码的正确性、质量和效率怎么样？其实，50 多年前编译器刚出来的时候，大家问的也是同样的问题。但今天已经没人质疑编译器生成的机器代码的效率了。

Same thing applies to modeling and code generation, because in practice correctness and efficiency are really non-issues. In fact, the reality is quite the opposite. The automatically generated code tends to be the most solid part of the project, while the manually written parts are typically more problematic, due to human errors.

建模和代码生成也是一样——在实践中，正确性和效率根本不是问题。事实恰恰相反：自动生成的代码往往是项目中最可靠的部分，手写的部分反而更容易因为人为错误出问题。

So, what are the *real* problems of code generation when it is actually applied in the everyday programming practice?

那么，在日常编程实践中，代码生成的*真正*问题到底是什么？

Well, here is a list that I'd like to go over with you and illustrate with the QM tool.

我列了一个清单，跟你逐条过一遍，同时用 QM 工具来演示。

The biggest real problem is what the developers call the need to constantly **"fight the tool"**. This feeling arises when things that used to be simple without the tool, suddenly become complex with the tool.

最大的真正问题是开发者常说的——你得不断地**"跟工具较劲"**（fight the tool）。这种感觉就是：不用工具的时候明明很简单的事，用了工具反而变复杂了。

The QM modeling tool has been very carefully designed to minimize the need to "fight the tool". For example, any code that you enter into the tool is directly in C (or C++ if you chose the QP/C++ framework) and the tool itself doesn't attempt to change any of your code.

QM 建模工具在这一点上花了很多心思，尽量减少"较劲"的需要。比如，你在工具里输入的代码就是原原本本的 C 语言（如果你选了 QP/C++ 框架就是 C++），工具本身不会动你的代码。

Other modeling tools handle things like that differently, and often put various restrictions on what you can or cannot do in your actions. To appreciate the simplicity of QM you'd really need to see some other tools, especially the big, "high ceremony" modeling tools.

其他建模工具就不是这样了，它们经常对你的动作代码施加各种限制。要真正体会 QM 有多简洁，你得去看看其他工具——特别是那些大型的、"重仪式感"的建模工具。

But to give you an idea of how "fighting the tool" might look like, back in lesson-39 of this video course you saw the State-Machine Compiler (SMC). Even though this was not a visual tool, its job was to generate code from a textual model in that case.

不过要让你感受一下"较劲"是什么滋味，还记得第 39 课里你见过的状态机编译器（SMC）吗？虽然它不是可视化工具，但当时也是从文本模型生成代码的。

The problem is that SMC tries to be smart about your action code. For example, SMC will not let you use simple assignment.

问题在于 SMC 总想在你的动作代码上"耍聪明"。比如，SMC 连简单的赋值语句都不让你用。

You cannot access attributes of your state machine either.

状态机的属性也不能直接访问。

All you can really do is to call operations on the context class. So, instead of writing your actions in the simple way, you need to invent workarounds, such as adding a bunch of class operations in this case.

你真正能做的只有调用上下文类的操作。于是本该简简单单写的动作代码，非得绕一大圈——比如在这里你就得额外加一堆类操作来做变通。

But moving on, the next big issue is that the generated code must be **complete**, meaning that no changes of any kind should be necessary for the code to cleanly compile and link with the rest of the application.

继续往下，下一个重要问题是生成的代码必须是**完整的**（complete）——也就是说，不需要做任何修改就能干净地编译、链接到应用程序的其余部分。

Generating only code skeletons with the "TODO" comments in places that later need to be coded manually are just not good enough.

只生成代码骨架、在需要手动补代码的地方放个"TODO"注释——这种做法远远不够。

To that end, QM generates complete code only. In fact, QM assumes that the generated code won't be modified and to prevent any accidental changes, QM marks the generated files as read-only. What that means is that any changes must be performed in the model, and the code must be re-generated, as opposed to being modified manually.

为此，QM 只生成完整的代码。实际上，QM 默认生成的代码不会被修改，为了防止意外改动，QM 会把生成的文件标记为只读。意思是所有修改都必须在模型里做，然后重新生成代码——而不是直接改生成的文件。

The next issue, critically important in practice, is the ease of integration between the generated code and the existing code.

下一个问题在实践中至关重要：生成的代码和已有代码之间的集成要方便。

As you saw in the TimeBomb model, in QM *you* write the body of each file, and then you direct QM to generate specified model elements for you. In this arrangement it is trivial to surround the generated code with any include directives, macro definitions, or anything else you need.

你在 TimeBomb 模型里已经看到了——在 QM 中，每个文件的正文由*你*来写，然后你指示 QM 生成指定的模型元素。在这样的安排下，在生成的代码前后加 include 指令、宏定义或其他任何需要的东西，都轻而易举。

This is actually unique to QM, because in most other tools such simple things require going through dialog boxes or special "deployment models".

这其实是 QM 独有的特性。在大多数其他工具里，这么简单的事都得通过对话框或专门的"部署模型"来搞。

Also, the TimeBomb example showed you how to generate code for a class. But QM allows you to generate code of both a finer and a coarser granularity than that. For example, you can generate definitions of individual operations, like, say just the constructor.

另外，TimeBomb 的例子演示了如何为一个类生成代码。但 QM 还支持更细和更粗粒度的生成。比如，你可以只生成单个操作的定义——光一个构造函数也行。

Or you can generate the whole package.

或者你可以生成整个包。

As you noticed, I keep creating here new files to show how easy that is and not to disturb the working code.

你可能注意到了，我一直在创建新文件——这是为了演示有多方便，同时不破坏已经能跑的代码。

For state machines, you can generate definitions of individual states, whereas the $define directive generates a recursive definition of a state and all its substates.

对于状态机，你可以生成单个状态的定义；而 `$define` 指令会递归地生成一个状态及其所有子状态的定义。

While the $define-1 directive generates a non-recursive definition of just a given state. You can then use these directives to split the definition of a larger state machine among multiple files.

而 `$define-1` 指令只生成给定状态的非递归定义。你可以利用这些指令把一个较大的状态机定义拆分到多个文件里。

The next pragmatic consideration is the **traceability** from the generated code back to the model.

下一个实际问题是从生成代码回到模型的**可追溯性**（traceability）。

For example, suppose that your model has an error and the generated code fails to compile.

比如，假设你的模型有错误，生成的代码编译不过。

In that case you want to quickly correct the problem in your model, because you are not supposed to change the generated code.

这时候你想在模型里快速定位并修复问题——因为生成的代码是不允许改的。

And here is where "traceability" comes in. QM generates special model-link comments right before each element. This allows you to select a piece of the code, including the comment and copy it to the Clipboard. This works for any code editor.

这就是"可追溯性"派上用场的地方了。QM 在每个元素前面都生成了特殊的**模型链接注释**（model-link comment）。你可以选中一段代码（连同注释一起）复制到剪贴板——任何代码编辑器都行。

You can then paste the model-link into QM, which causes QM to highlight the corresponding model element, where you can conveniently correct the problem.

然后把这个模型链接粘贴到 QM 里，QM 就会高亮显示对应的模型元素，你直接在那里改就行了。

Traceability is also important in the opposite direction: from the model to code.

可追溯性在反方向也很重要：从模型到代码。

For instance, suppose that you want to set a breakpoint upon the entry to the "boom" state. Your problem is to quickly and reliably locate the corresponding place in the generated code.

比如，你想在进入"boom"状态时设断点。问题是怎样快速、可靠地找到生成代码中对应的位置。

In QM you can do this easily by highlighting the desired state in the model and copying the model-link to the Clipboard.

在 QM 里很简单——在模型中选中目标状态，把模型链接复制到剪贴板。

You can then simply search your code for the model-link comment. Again, any code editor supports simple text search.

然后在代码里搜索这个模型链接注释就行了。任何代码编辑器都支持文本搜索。

After locating the place in the code, you can set your breakpoint and proceed with the standard debugger.

找到位置后设断点，然后用标准调试器继续调试。

Please note that the bi-directional traceability from the model to code and vice versa is the property of the particular **"optimal" state machine implementation** that you learned back in lesson-39, and which is used in the QP/C framework.

请注意，这种从模型到代码、从代码到模型的双向可追溯性，是第 39 课里你学过的那种**"最优"状态机实现**（optimal state machine implementation）的特性，它用在 QP/C 框架中。

Such traceability is not a given, and many other code generators don't produce bi-directionally traceable code. For example, some code generators transform hierarchical state machines into classical "flat" state machines for implementation. This, unfortunately, brings back the repetitions of transitions, which hierarchical state machines were exactly designed to remove. In that case the traceability from the model to code is destroyed, because a single transition in the model can map to several transitions in the code.

这种可追溯性并不是理所当然的，很多其他代码生成器并不产出双向可追溯的代码。比如，有些代码生成器会把层次状态机转换成经典的"扁平"状态机来实现。不幸的是，这又带来了转换的重复——而层次状态机恰恰就是为了消除这种重复才发明的。在这种情况下，模型到代码的可追溯性就被破坏了，因为模型中的一条转换可能对应代码中的好几条转换。

Yet, the bi-directional traceability is a very desirable property and is actually required by various **functional safety standards**.

然而，双向可追溯性是非常理想的特性，各种**功能安全标准**（functional safety standards）实际上都要求它。

When you start modeling, your models will become a new kind of source code. That means that you will gradually produce different versions of your models, which then you'd need to diff and merge, like any other source files.

当你开始建模后，模型就成了一种新的源代码。也就是说，你会逐渐产生模型的不同版本，然后需要像其他源文件一样做差异比较和合并。

For example, let's save the current version of your TimeBomb.qm model file as TimeBomb0.qm.

比如，先把当前版本的 TimeBomb.qm 模型文件另存为 TimeBomb0.qm。

And next, let's add the exit action to the "defused" state to undo the entry action, that is, to turn the Blue-LED off.

然后给"defused"状态加一个退出动作，把进入动作的效果撤销——也就是关掉蓝色 LED。

Please note that this creates two differences: one is the new exit action code and the other is the graphical rendering of the exit action box, which has been resized.

注意这会产生两处差异：一是新的退出动作代码，二是退出动作框的图形大小变了。

Now, let's change some views in the model and save it as the new version.

现在再改一下模型里的视图，然后保存为新版本。

At this point, let's say that you would like to see the differences between your original and the new model.

这时候，假设你想看看原始模型和新模型之间的差异。

QM does not support such model differencing directly, but to see the difference between your two models you can use any standard code differencing tool, like WinMerge. This is possible, because QM stores the models in XML.

QM 本身不直接支持模型差异比较，但你可以用任何标准的代码比较工具，比如 WinMerge。这之所以可行，是因为 QM 用 XML 格式存储模型。

So, here you can see your two differences: the first being the exit code and the second being the size of the exit box. The QM model format in XML is specifically designed to be quite readable.

你看，这里就能看到那两处差异：一是退出代码，二是退出框的大小。QM 的 XML 模型格式是专门设计过的，可读性相当不错。

And also here again, in the model file itself, QM generates the model-link comments, which you can copy and paste into QM to visually locate the item that has changed.

同样，在模型文件本身里，QM 也有模型链接注释，你可以复制粘贴到 QM 中，直观地定位发生变化的项目。

The saving of the model-link comments in the XML is controlled by the checkbox in the model's property sheet.

XML 中是否保存模型链接注释，由模型属性表里的复选框控制。

It's important to note that, just like the generated code, the XML is read-only, because you are not supposed to make any manual changes there. All changes to the model should be done through the QM modeling tool.

需要强调的是，跟生成的代码一样，XML 也是只读的——你不应该手动去改它。所有对模型的修改都应该通过 QM 建模工具来完成。

And finally, your models should scale up to efficiently support really big projects and teams. This is where modeling really shows its biggest advantages.

最后，你的模型应该能扩展到高效支持真正的大型项目和团队。这才是建模真正发挥最大优势的地方。

Here I would like to mention only two QM features that support large-scale projects.

这里我只提两个支持大型项目的 QM 特性。

First, is the unique support for the physical design in QM, which becomes critically important for larger-scale projects. Physical design is vastly underappreciated, and there are very few resources that cover it well. One notable exception is John Lakos' book "Large Scale C++ Software Design", which I highly recommend and list in the video description.

第一是 QM 对物理设计的独特支持，这对大型项目至关重要。物理设计这个话题被严重低估了，讲得好的资料很少。一个值得一提的例外是 John Lakos 的《Large Scale C++ Software Design》，我强烈推荐，链接在视频描述里。

The other feature of QM for bigger projects is the ability to break up models into **"external packages"** that are saved into separate files.

QM 面向大型项目的另一个特性是，可以把模型拆分成**外部包**（external packages），每个包保存成单独的文件。

These external packages can be then managed separately by sub-teams and can be imported into multiple models.

这些外部包可以由不同的子团队分别管理，也可以导入到多个模型中。

This concludes this quick introduction to automatic code generation.

以上就是对自动代码生成的快速介绍。

The three main points I'd like you to remember are: that to succeed, modeling must be accompanied by code generation; that besides the big, heavy, and expensive tools of the past, there are now lightweight modeling tools that you no longer need to "fight"; and that success of modeling and code generation in everyday practice requires many little accommodations that collectively bring about the paradigm shift.

我想让你记住三个要点：第一，建模必须配合代码生成才能成功；第二，除了过去那些又大又重又贵的工具之外，现在有了轻量级的建模工具，你再也不用跟工具较劲了；第三，建模和代码生成在日常实践中要真正落地，需要很多细微的配套措施——这些措施加在一起，才能完成范式的转变。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/video-course for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/video-course 下载。

Finally, all the projects are also available on GitHub in the Quantum Leaps repository "modern embedded programming course". Thanks for watching!

最后，所有项目也可以在 GitHub 上的 Quantum Leaps 仓库"modern embedded programming course"中找到。感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Automatic Code Generation | 自动代码生成 | 从模型自动生成源代码的技术，是模型驱动开发的核心环节 |
| Graphical Modeling | 图形化建模 | 使用可视化图形（如状态机图）来设计软件的方法 |
| QM (QP Modeler) | QM 建模工具 | Quantum Leaps 提供的图形化建模和代码生成工具 |
| QP-bundle | QP-bundle | 包含 QP/C 框架、QM 建模工具和编译器的软件包 |
| Logical Design | 逻辑设计 | 指定类、属性、操作和状态机等模型项及其内部结构的设计阶段 |
| Physical Design | 物理设计 | 指定代码的目录结构和文件组织的设计阶段 |
| Model Explorer | 模型浏览器 | QM 中用于浏览和管理模型元素的导航面板 |
| `$declare` directive | `$declare` 指令 | QM 中指示生成类声明的指令 |
| `$define` directive | `$define` 指令 | QM 中指示生成类定义（包括状态机）的指令 |
| State Machine Compiler (SMC) | 状态机编译器 | 一种从文本模型生成代码的工具，不是可视化工具 |
| Traceability | 可追溯性 | 生成代码与模型元素之间双向映射的能力 |
| Model-link comment | 模型链接注释 | QM 在生成代码中插入的特殊注释，用于代码与模型之间的导航 |
| Optimal State Machine Implementation | 最优状态机实现 | 一种保留层次结构并支持双向可追溯性的状态机实现策略 |
| Hierarchical State Machine | 层次状态机 | 支持状态嵌套的状态机，避免转换重复 |
| Flat State Machine | 扁平状态机 | 不支持状态嵌套的传统状态机，可能导致转换重复 |
| Functional Safety Standards | 功能安全标准 | 如 IEC 61508 等，要求代码与设计之间具有可追溯性 |
| External Package | 外部包 | QM 中可独立管理并导入多个模型的模块 |
| Unified Modeling Language (UML) | 统一建模语言 | 软件工程中标准化的建模语言，包含状态机图等多种图表类型 |
| Statechart / State Machine Diagram | 状态图 / 状态机图 | David Harel 发明的用于表示层次状态机的可视化表示法 |
| Active Object | 活动对象 | 结合事件驱动和状态机的并发编程模式中的基本单元 |
| WinMerge | WinMerge | 一种标准的代码差异比较工具 |
| High Ceremony Tool | 重仪式感工具 | 指那些复杂、笨重、使用成本高的建模工具 |
