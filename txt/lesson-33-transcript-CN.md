# 第33课：事件驱动编程 / Lesson 33: Event-Driven Programming

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and today I'd like to start a new segment of lessons about event-driven programming, which is an important stepping stone in understanding modern software of any kind, not just modern embedded programming.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。今天我们开始一个新的系列——事件驱动编程（event-driven programming）。这是理解各种现代软件的重要基础，不限于嵌入式编程。

In this lesson, you will learn the main concepts of event-driven programming based on its origins in graphical user interfaces, which went mainstream during the personal computer revolution in the 1980s.

本课将从图形用户界面（GUI）讲起，带你了解事件驱动编程的核心概念。GUI 在 20 世纪 80 年代个人电脑革命期间普及开来，而事件驱动编程正是为了解决 GUI 编程问题而诞生的。

So, the plan for today is to explain why graphical user interface, abbreviated to GUI, required a new programming paradigm, and how this new paradigm, known today as event-driven programming, really works.

今天的计划是这样的：先解释为什么 GUI 需要一种全新的编程范式，再看看这种范式——也就是今天所说的事件驱动编程——到底是怎么运作的。

Specifically, in this lesson you will see the most important characteristics of event-driven programming exemplified by the original Win32 API that was designed back in the 1980s and still works today, even on the latest 64-bit Windows 10.

具体来说，我们会用 Win32 API 作为范例来展示事件驱动编程最重要的特征。这个 API 是微软在 80 年代设计的，至今仍然可用——即使是最新的 64 位 Windows 10 也没问题。

With this background, in the following lessons, you will see how these main characteristics of event-driven programming can be applied to real-time embedded systems, such as your TivaC LaunchPad board.

打好了这个基础，后面的课程中你就会看到，如何把这些概念应用到 TivaC LaunchPad 这样的实时嵌入式系统上。

But let's start from the beginning.

让我们从头说起。

Perhaps the most consequential, from the programming perspective, was the invention of the mouse in the mid 1960s.

从编程的角度看，影响最深远的发明可能就是 60 年代中期出现的鼠标。

Well, this basically characterizes what we've been pursuing for many years in what we call the Augmented Human Intellect Research Center at Stanford Research Institute. Here is Don Andrew's hand in Menlo Park. And in a second we will see the screen that he is working and the way the tracking spot moves in conjunction with movements of that mouse. I don't know why we call it a mouse. Sometimes I apologize. It started that way and we never did change it.

> 这段是道格·恩格尔巴特在斯坦福研究所（SRI）人类智能增强研究中心演示鼠标时的原始录音：
> "这基本上就是我们在斯坦福研究所人类智能增强研究中心多年来一直在追求的目标。这是 Don Andrew 在门洛帕克的手。稍后你们会看到他操作的屏幕，以及那个跟踪光点如何跟着鼠标一起移动。我也不知道为什么叫它鼠标，有时候我还得为此道个歉。一开始就这么叫了，后来就再也没改过。"

But it took another full decade to work out the technical details of how to actually implement the ideas. This eventually happened at Xerox Palo Alto Research Center (PARC) in mid 1970s. The mouse is a pointing device that moves the cursor around the display screen.

不过，把这些设想变成现实又花了整整十年。最终是在 70 年代中期，施乐帕洛阿尔托研究中心（Xerox PARC）完成了这项工作。鼠标是一种指点设备（pointing device），用来在屏幕上移动光标。

Demonstration of the Alto computer developed at Xerox Palo Alto Research Center around 1973.

以下是 1973 年左右在施乐 PARC 开发的 Alto 计算机的演示画面。

A selected window displays above other windows much like placing a piece of paper on top of a stack on a desk.

被选中的窗口会显示在其他窗口之上，就像把一张纸放在桌上一叠纸的最上面。

Compared to command-line systems of the day, such as a teletype or a terminal, the implementation of a graphical user interface required a paradigm shift.

当时的命令行系统——比如电传打字机或终端——跟 GUI 完全不是一个路子。要实现图形用户界面，必须换一种全新的编程思路。

Here is the main problem: In a command-line system, the only input device is the keyboard and the only output device is the bottom of the screen, which scrolls up like an electronic teletype.

核心问题在于：命令行系统只有一个输入设备——键盘，输出也只有一个位置——屏幕底部，像电子电传打字机一样往上滚动。

Consequently, as I'm trying to illustrate in this piece of pseudocode, the software can still have the traditional sequential structure.

所以，正如我在这段伪代码中所展示的，软件仍然可以采用传统的顺序结构。

Basically, the software waits for a key press, after which it echoes the character to the screen and then processes the key press, which might cause some more output to the screen. There is no question of where to produce the output because it always goes to the bottom of the screen.

简单来说：程序等待按键，然后把字符回显到屏幕上，再处理这个按键——处理过程中可能还会产生更多输出。输出往哪里写？根本不是问题，因为永远都是写到屏幕底部。

But with a graphical user interface the situation is fundamentally different. For starters, you now have multiple sources of input: the keyboard and the mouse.

但在 GUI 中，情况完全不同了。首先，你现在有两个输入源：键盘和鼠标。

This is a problem, which I'm again trying to illustrate with a piece of pseudocode. If you explicitly wait for the keyboard, for example, you are unresponsive to the mouse input and vice-versa, if you start with waiting for the mouse, you are unresponsive to the keyboard.

这就带来了一个问题，我再用一段伪代码来说明。比如，如果你显式地等待键盘输入，那你就对鼠标没反应；反过来也一样，如果你先等鼠标，就对键盘没反应。

So, first you need to find a way to somehow wait for multiple inputs simultaneously. But assuming that you've done this, downstream of such a blocking call you now have to check which one of the multiple inputs has been actually received.

所以，首先你得想办法同时等待多个输入。假设你做到了这一点，在阻塞调用返回之后，你还得判断实际收到的到底是哪个输入。

Moreover, with the keyboard you no longer know where on the screen the output needs to be produced. For this, you would have to know which part of the screen has been active, which is called the "keyboard focus" in today's GUI programming.

而且，用键盘输入时，你根本不知道输出该写到屏幕的什么位置。你得知道屏幕的哪一部分当前是活动的——这就是今天 GUI 编程中所说的"键盘焦点"（keyboard focus）。

But with the mouse, there are even more fundamental problems. The mouse provides two-dimensional input, so you have the X and Y coordinates on the screen plus the state of the mouse buttons. But the raw coordinates are not sufficient to take a meaningful action. You need to additionally know which object on the screen is at these coordinates.

鼠标的问题更根本。鼠标给出的是二维输入——屏幕上的 X、Y 坐标，加上鼠标按键的状态。但光有原始坐标还不够，你没法仅凭坐标做出有意义的操作。你还得知道这些坐标处是屏幕上的哪个对象。

For this, you would typically call a service of the GUI system. But since this would happen for every mouse input, you could just skip the step and always let the GUI system find the object at the current mouse coordinates.

通常你会调用 GUI 系统的服务来完成这个定位。但既然每次鼠标输入都要这么做，不如干脆跳过这一步，让 GUI 系统自己去查找当前鼠标坐标下的对象。

This effectively means that the mouse can produce many more kinds of inputs, such as 'object_id' in this pseudocode, all of them depending on the constantly changing situation on the screen.

这实际上意味着鼠标能产生更多种类的输入，比如这段伪代码里的 `object_id`——具体产生什么，取决于屏幕上不断变化的状况。

I hope that you start to see that graphical user interface introduces new levels of complexity, which are not in the same ballpark as the command-line interface. In fact, GUI programming is an entirely different ball game.

希望你开始看出来了：GUI 引入的复杂度跟命令行完全不在一个量级上。说白了，GUI 编程就是一门完全不同的手艺。

Therefore, no wonder that GUI programming required a different way of thinking. The key insight that enabled a workable solution was the focus on the inputs, which are called *events* or *messages*, such as the key-presses, mouse moves, and the secondary inputs, from objects on the screen, like buttons, desktop icons, scroll bars, etc.

所以，GUI 编程需要一种不同的思维方式，这并不奇怪。关键的突破口在于：把注意力集中在输入上——这些输入被称为**事件**（events）或**消息**（messages），比如按键、鼠标移动，以及来自屏幕上对象（按钮、桌面图标、滚动条等）的二次输入。

The focus on events means that the events drive the software, not the other way around like it was in the sequentially coded command-line programs.

以事件为中心，就意味着**事件来驱动软件**——而不是像顺序编写的命令行程序那样反过来。

To see what this event-driven paradigm really means and how it works, I've prepared a simple "HelloWin" GUI application running on Windows.

为了让你直观感受事件驱动范式到底是什么意思、怎么运作，我准备了一个运行在 Windows 上的简单 GUI 程序——"HelloWin"。

You can download this project as lesson33 from the companion web-page to this video course at state-machine.com/quickstart. Once inside the project directory, I've just clicked on the hellowin.sln solution file to open it in Visual Studio 2019 Community Edition. If you wish to follow along, you can download Visual Studio 2019 from the Microsoft website. The community edition is free after registration.

你可以从本课程配套网页 state-machine.com/quickstart 下载 lesson33 项目。进入项目目录后，双击 `hellowin.sln` 解决方案文件，就会在 Visual Studio 2019 Community Edition 中打开。如果你想跟着做，可以去微软网站下载 Visual Studio 2019，社区版注册后免费使用。

But even though the development environment is quite modern, the software is written in C, using the ancient Windows Application Programming Interface (API), which Microsoft developed back in the 1980s.

虽然开发环境很现代，但这个程序是用 C 语言写的，用的是微软在 80 年代开发的那个古老的 Windows API。

It turns out that, unlike other, more modern Windows APIs in other programming languages, this low-level Win32 API in C demonstrates the main concepts of event-driven programming in their simplest and most direct form.

事实证明，与其他语言中更现代的 Windows API 相比，这个底层的 C 语言 Win32 API 反而能以最简单、最直接的方式展示事件驱动编程的核心概念。

So, let's just walk through this simplistic Windows application, which is my adaption of the "Hello-Windows" program from the book "Programming Windows" by Charles Petzold. This book, first published in 1988, became the Windows programming bible back in the day.

让我们来过一遍这个简单的 Windows 程序。它是我根据 Charles Petzold 的《Programming Windows》一书中的 "Hello-Windows" 程序改编的。这本书 1988 年首次出版，在当时就是 Windows 编程的圣经。

The code begins with include Windows.h header file that defines the Windows API, types and constants.

代码开头包含了 `Windows.h` 头文件，里面定义了 Windows API 的类型和常量。

Next, you can see a prototype of the `WndProc` function, which will be needed to initialize a quote-unquote virtual table, and which I will discuss in quite a detail in a minute.

接下来是 `WndProc` 函数的原型声明，它用来初始化所谓的"虚函数表"（virtual table），我稍后会详细讨论。

But first comes the `WinMain()` function. This is the main entry point to a Windows GUI application and plays the same role as the `main()` function in the conventional C environment, except in a GUI environment the entry point takes more parameters, because a GUI application is more complex.

先看 `WinMain()` 函数。它是 Windows GUI 程序的入口，作用跟普通 C 程序的 `main()` 一样，只不过 GUI 程序更复杂，所以入口函数需要接收更多参数。

Here, in the simple Hello-Windows application, some of these parameters are not even used.

在我们这个简单的 Hello-Windows 程序中，有些参数甚至根本没用到。

But next, comes an interesting part, where you prepare the Window Class to be registered with Windows.

接下来是有意思的部分——准备要向 Windows 注册的**窗口类**（Window Class）。

I've specifically formatted and commented the initialization, so that you recognize that here you engage in a kind of object-oriented programming, as I explained in the last lesson 32 about OOP in C. So, specifically, you first see the setting of the attributes of a window-class instance 'wnd', such as the windows style, the mouse cursor for the window, and the window class name.

我特意对这段初始化代码做了格式化和注释，让你能看出这里其实用到了面向对象编程——就像上一课第32课讲的 C 语言中的 OOP 一样。具体来说，你首先看到的是设置窗口类实例 `wnd` 的属性，比如窗口样式、鼠标光标、窗口类名。

But, next, you can hopefully recognize the assignment of a quote-unquote virtual function -- the windows procedure -- `WndProc`, specific for this windows class.

接下来，希望你能够认出来：这是在给这个窗口类指定一个所谓的"虚函数"——窗口过程（window procedure）`WndProc`。

Here, the Windows API designers used the simple implementation technique of embedding a pointer to virtual function directly in the attribute structure, which I mentioned in my last lesson about object-oriented programming in C.

Windows API 的设计者在这里用了一个简单的实现技巧：把虚函数的指针直接嵌入到属性结构体中。这就是我在上一课 C 语言 OOP 中提到过的做法。

Next, comes the call to Windows to register the prepared windows-class.

然后，调用 Windows 的注册函数，把这个准备好的窗口类注册上去。

And finally, the call to `CreateWindow()` plays the role of a constructor, because it creates a window object based on the just registered window-class.

最后，`CreateWindow()` 的调用扮演了**构造函数**的角色——它根据刚刚注册的窗口类创建了一个窗口对象。

Once the application window is created, it is shown on the screen and updated.

窗口创建好之后，就显示在屏幕上并完成更新。

But then, after all this initialization, the `WinMain` function enters the **event loop** also known as **message loop** or **message pump**, where the program performs the real work. This is the most important part of every event-driven program.

初始化全部完成后，`WinMain` 就进入了**事件循环**（event loop），也叫**消息循环**（message loop）或**消息泵**（message pump）——程序真正干活的地方就在这里。这是每个事件驱动程序最重要的部分。

The event loop has a very specific structure, consisting of two main steps:

事件循环的结构非常明确，就两个主要步骤：

First, the call to the `GetMessage()` Windows API blocks and waits for any input from the keyboard, mouse or the screen. When any of such events occur, the Windows system records it as a message object and places it in the message queue for this application.

第一步，调用 `GetMessage()` 这个 Windows API，它会阻塞等待键盘、鼠标或屏幕的任何输入。当有事件发生时，Windows 把它记录为一个消息对象，放入该程序的**消息队列**（message queue）中。

`GetMessage()` then unblocks and copies the message from the queue to the `msg` object.

然后 `GetMessage()` 解除阻塞，把消息从队列复制到 `msg` 对象中。

This is how the event-loop solves the problem of waiting simultaneously for multiple events, as I tried to illustrate in the pseudocode before.

看到没？事件循环就是这样解决"同时等待多个事件"这个问题的——前面伪代码里提到的难题，在这里解决了。

If the status returned from `GetMessage()` is zero, it means that the application has been closed, and so the event loop needs to be terminated by executing the break statement in this case.

如果 `GetMessage()` 返回的状态是零，说明程序已经被关闭了，这时就通过 `break` 语句退出事件循环。

Otherwise the message is passed to the `DispatchMessage()` Windows API, which then calls the "window proc" registered for the current Window.

否则，消息被传给 `DispatchMessage()` 这个 API，它会去调用当前窗口注册的"窗口过程"。

You will see the "window proc" for this simple Hello-Win application in a minute, but before leaving this piece of code, let me summarize the key properties of the event loop.

稍后你会看到这个 Hello-Win 程序的窗口过程。不过在看它之前，让我先总结一下事件循环的几个关键特性。

The first key property is that an event-loop uses special **message objects** to record all events potentially interesting to an application. These message objects serve only for communication and can be conveniently stored in the event queue and later retrieved for processing.

第一，事件循环使用专门的**消息对象**来记录程序可能关心的所有事件。这些消息对象只用于通信，可以方便地存入消息队列，之后取出来处理。

Because of the message queue, events can be delivered both when the loop is waiting for them and when the loop is busy processing previous events.

有了消息队列，事件不管是在循环等待时还是在忙于处理前一个事件时，都能被投递进来。

In any case, the Windows system only records the event as a message and places it in the message queue, but does NOT wait for the actual processing of the event. This type of event delivery is called **asynchronous**, and means that event producer (which is the Windows system in this case) executes independently from the consumer of events (which is your application in this case).

不管哪种情况，Windows 只是记录事件、放入队列，**不会**等事件处理完。这种投递方式叫做**异步的**（asynchronous），意思是事件的生产者（这里是 Windows 系统）和事件的消费者（这里是你的程序）各自独立运行。

In other words, these two activities are asynchronous, meaning not synchronized. Later in this lesson you will see some experiments that will demonstrate this asynchronous nature of event delivery.

换句话说，生产和消费这两件事是不同步的。稍后我们会做一些实验来演示这种异步特性。

The second property of the event-loop is that the `DispatchMessage()` call must necessarily complete and return to the event-loop before the loop gets around to the next event. This means that event processing proceeds in **Run-to-Completion (RTC)** steps that cannot be interrupted by processing of any other event.

第二，`DispatchMessage()` 调用必须执行完毕、返回到事件循环之后，循环才能去处理下一个事件。也就是说，事件处理是按**运行到完成**（Run-to-Completion, RTC）的方式一步步进行的，处理一个事件的过程中不会被其他事件打断。

And the third key property of event-loop is that it makes calls to your application code -- the "windows proc".

第三，事件循环会调用你写的代码——也就是那个"窗口过程"。

This is backwards compared to what you've been used to, because in all your previous experience with a Real-Time Operating System, for instance, which you saw in lessons 20 through 26, your application was calling the services of the RTOS. But now the event-driven Windows system is calling *your* application.

这跟以前完全反过来了。之前用 RTOS 的时候——比如第 20 到 26 课中你看到的——是你的程序调用 RTOS 的服务。而现在，是事件驱动的 Windows 系统在调用**你的**程序。

This property of the event-loop leads to **inversion of control** compared to traditional sequential programming.

这种特性，跟传统的顺序编程相比，就是所谓的**控制反转**（inversion of control）。

This is the key characteristic of all event-driven systems and is the essence of event-driven programming. The inversion of control is really what it means that "events drive the application" and not the other way around.

这是所有事件驱动系统最核心的特征，也是事件驱动编程的本质。控制反转的真正含义就是"**事件驱动应用程序**"——而不是反过来。

So, now let's take a look at the "WndProc" for this GUI application.

现在让我们看看这个 GUI 程序的 `WndProc`。

First, to understand the signature, you need to see the declaration of the message structure that I skipped until now.

要理解函数签名，先得看一下之前跳过的消息结构定义。

The MSG structure happens to be defined in the `WinUser.H` header file, which is included from `Windows.h`.

MSG 结构定义在 `WinUser.H` 头文件中，这个文件是从 `Windows.h` 中包含进来的。

As you can see, the types of the four parameters of the "WndProc" are identical to the first four attributes of the MSG structure.

可以看到，`WndProc` 四个参数的类型跟 MSG 结构的前四个属性完全一致。

I only took the liberty of re-naming the first parameter from `HWND` window handle, to "me", to make it more clear that the "WndProc" is a member function of the window class. This is the naming convention for member functions introduced in lesson 30 about implementing classes in C.

我擅自把第一个参数从 `HWND`（窗口句柄）改名为 `me`，是为了更清楚地表明 `WndProc` 是窗口类的成员函数。这个成员函数的命名约定是在第 30 课"C 语言实现类"中引入的。

Actually, as you saw in `WinMain`, the "WndProc" is not just a member function, it is a *virtual* member function that is specific to the type of the window class registered with Windows for this application.

实际上，正如你在 `WinMain` 中看到的，`WndProc` 不仅仅是个成员函数——它是一个**虚成员函数**，专门对应于这个程序向 Windows 注册的那种窗口类。

I also took the liberty of renaming the second parameter of the "WndProc" from "message" to "sig", because this is the part of the message informing you about the kind of event that was recorded in this message. In the modern event-driven programming this information is called the **signal** of the event, so I named it "sig".

我还把第二个参数从 `message` 改名为 `sig`，因为它告诉你这条消息记录的是什么种类的事件。在现代事件驱动编程中，这个信息叫做事件的**信号**（signal），所以我就用了 `sig` 这个名字。

And finally, the last two parameters, `wParam` and `lParam`, are the event parameters that provide additional information about the recorded event. The meaning of these parameters depends on the event signal.

最后两个参数 `wParam` 和 `lParam` 是事件参数，提供所记录事件的附加信息。具体含义取决于事件信号是什么。

Inside the "WndProc", the main job is to process the received message. This requires to first determine what kind of the message you are dealing with.

在 `WndProc` 内部，主要工作就是处理收到的消息。首先得判断这条消息是什么类型。

For this, the Windows programmers use the **switch statement** based on the integer signal of the message as the control expression.

Windows 程序员的做法是用 **switch 语句**，以消息的整数信号作为判断条件。

Each case statement then represents a different message kind that needs to be processed according to that signal.

每个 case 分支对应一种消息类型，根据信号进行相应的处理。

The case statements are labeled with the symbolic names of various message signals, which are listed again in the `WinUser.H` header file.

case 分支用各种消息信号的符号名来标记，这些符号名列在 `WinUser.H` 头文件中。

For example, the `WM_CREATE` signal corresponds to numerical value 1 and is sent to the WndProc when the window is created.

比如，`WM_CREATE` 信号对应数值 1，在窗口创建时发送给 WndProc。

Similarly, `WM_DESTROY` corresponds to numerical value 2 and is sent to the WndProc when the window is about to be destroyed.

类似地，`WM_DESTROY` 对应数值 2，在窗口即将被销毁时发送。

In the latter case, the "WndProc" calls the `PostQuitMessage` API, which inserts the `WM_QUIT` message into the program's message queue, which, in turn, will then cause termination of the event-loop. This is an interesting example showing you that an application can asynchronously post events to itself.

在 `WM_DESTROY` 这个分支里，`WndProc` 调用 `PostQuitMessage` API，往程序自己的消息队列里插入一条 `WM_QUIT` 消息，进而导致事件循环终止。这个例子很有意思——它说明了程序可以异步地给自己投递事件。

But in all cases, the "WndProc" also sets the local variable 'status' that records the status of processing. For example, when "WndProc" handles a given message, it sets the status to `WIN_HANDLED`.

不管哪个分支，`WndProc` 都会设置局部变量 `status` 来记录处理结果。比如，当 `WndProc` 处理了某条消息，就把状态设为 `WIN_HANDLED`。

This status is then returned back to the Windows system, so there is the two-way communication: Windows tells the "WndProc" which message to process, but then the "WndProc" reports the status of processing back to windows.

这个状态随后返回给 Windows 系统。所以这是一来一回的**双向通信**：Windows 告诉 `WndProc` 处理哪条消息，`WndProc` 处理完再向 Windows 报告结果。

Now, perhaps the most important message that "WndProc" needs to handle is the `WM_PAINT` message, which the Windows system generates when it determines that part or all of the window needs to be repainted.

`WndProc` 要处理的最重要的消息可能就是 `WM_PAINT` 了。当 Windows 判定窗口需要全部或部分重绘时，就会生成这条消息。

Your Hello-Windows application handles this by painting some text in the center of the window rectangle. The details of all this are not that relevant for today,

你的 Hello-Windows 程序的处理方式是在窗口矩形中心绘制一些文本。具体细节今天不是重点，

except perhaps to note that the painting displays the current values of the counters for keyboard presses and mouse moves.

值得提一下的是，绘制的内容包括键盘按下和鼠标移动计数器的当前值。

What *is* more important, however, is that these counters are defined as **static** variables, because they must outlive the many invocations and *returns* from the "WndProc". Notice, that if you would define the counters as the local automatic variables, they would go out of scope by every return.

但**更重要的**是：这些计数器被定义为 **static 变量**，因为它们必须在 `WndProc` 的多次调用和返回之间一直存在。注意，如果你把它们定义成普通的局部自动变量，每次返回时它们就没了。

Now you might be curious where these counters are actually incremented... So, here they are:

你可能好奇这些计数器在哪里递增的……在这里：

the `wm_keydown` counter is incremented in the `WM_KEYDOWN` message

`wm_keydown` 计数器在 `WM_KEYDOWN` 消息处理中递增，

and the `wm_mousemove` counter is incremented in the `WM_MOUSEMOVE` message.

`wm_mousemove` 计数器在 `WM_MOUSEMOVE` 消息处理中递增。

In both cases, the processing must also include the call to `InvalidateRect()` API to tell Windows that the window rectangle needs to be repainted, because otherwise the new value of the counter won't be updated right away.

这两种情况下，处理逻辑都必须调用 `InvalidateRect()` API 通知 Windows 窗口需要重绘，否则计数器的新值不会立即更新到屏幕上。

This is another aspect of the two-way communication between the application code and the Windows system.

这是应用程序代码与 Windows 系统之间双向通信的又一个体现。

And finally, the default case handles all the message signals that the "wind proc" did not choose to handle explicitly in one of the provided case statements. In that default case, the "WndProc" calls the default "windows-proc" provided by Windows.

最后，default 分支处理所有你没有在 case 语句中显式处理的消息。在这里，`WndProc` 调用的是 Windows 提供的默认窗口过程。

This is a very interesting design that has huge implications, because this is how the "characteristic look and feel" of the GUI system comes about.

这是一个非常有意思的设计，影响深远——GUI 系统那种"特有的外观和感觉"就是这么来的。

To explain what I mean, let's just run this Hello-Windows application and see what it can do.

解释一下我是什么意思——运行这个 Hello-Windows 程序，看看它能做什么。

Well, it turns out that the application has the usual window, with the window bar and a title.

可以看到，程序有个普通的窗口，带窗口栏和标题。

You can resize the window.

你可以调整窗口大小。

You can move it around.

可以拖动它。

You can minimize it.

可以最小化。

You can restore it

可以还原，

and you can maximize it.

也可以最大化。

But *you* have only explicitly coded the counting of mouse moves and keyboard presses.

但**你**只写了鼠标移动和键盘按下的计数逻辑。

Yet, the application can apparently do all those other things as well and really looks and feels like any other Windows application. This is all thanks to the default "window-proc", which provides these other behaviors for you.

然而程序显然也能做所有这些事情，而且看起来、用起来就跟其他 Windows 程序一模一样。这全靠默认窗口过程替你提供了这些行为。

The default case in your "WndProc" might not look impressive at all,

你 `WndProc` 里的 default 分支看起来可能毫不起眼，

but to appreciate it, you only need to scan through the hundreds of windows messages defined in `WinUser.H`. Most of these `WM_` message signals go through your "WndProc", and most of them are handled by the default "window-proc" provided by Windows.

但只要你去翻翻 `WinUser.H` 中定义的那几百个 Windows 消息就明白了。大部分 `WM_` 消息信号都会经过你的 `WndProc`，其中绝大部分由 Windows 提供的默认窗口过程处理。

Yet, you as the programmer, can be blissfully unaware about all this complexity, because all you need to know is a handful of messages that you actually handle.

而你作为程序员，完全可以对这些复杂性浑然不知——你只需要关心你实际处理的那几条消息就行了。

A good way of thinking about this design is that it is layered in the order of hierarchy.

理解这种设计的一个好办法是把它看成一种层级结构。

At the lowest level of the hierarchy is your code. It has the first shot at every event, because every event is sent to your "WndProc" first.

层级最底层是你的代码。每个事件它都有优先处理权，因为所有事件首先都发送给你的 `WndProc`。

But when your code does not explicitly handle an event, it is not ignored, but rather it is passed on to the Windows system, which is at the higher-level of hierarchy.

当你的代码没有显式处理某个事件时，事件不会被忽略，而是被交给上层的 Windows 系统来处理。

The other names of this hierarchical design are the **"Ultimate Hook"** and **"Programming by Difference"**. These two names mean exactly the same thing, but emphasize the different aspects of it. "Ultimate Hook" emphasizes the ease of attaching, or "hooking up", your code to every event.

这种层级设计还有两个名字：**"终极钩子"**（Ultimate Hook）和**"按差异编程"**（Programming by Difference）。它们说的是同一回事，只是强调的侧面不同。"终极钩子"强调的是把你的代码"钩入"每个事件有多方便。

"Programming by Difference" emphasizes the fact that you only need to explicitly program the *differences* from the default behavior.

"按差异编程"强调的是，你只需要编写跟默认行为**不同**的那部分就行了。

But at this point, I hope that you starting to realize that you already saw something similar in the previous lessons 29 through 32, where you learned about object-oriented programming.

说到这里，希望你开始意识到：之前第 29 到 32 课学面向对象编程的时候，你已经见过类似的东西了。

Specifically, with the OOP perspective you can view the design as a **class hierarchy** in which the Windows System is the base class with hundreds of virtual functions, one for each message signal. Windows applications, such as your Hello-Win or Microsoft Word are then the subclasses that override the selected virtual functions in their "WndProcs".

具体来说，从 OOP 的角度看，你可以把这个设计理解为一个**类层次结构**（class hierarchy）：Windows 系统是基类，有几百个虚函数——每种消息信号一个。而你的 Hello-Win 或 Microsoft Word 这样的 Windows 应用程序就是子类，在各自的 `WndProc` 中覆盖了选定的虚函数。

Alright, so this was a quick code review of a simple event-driven Hello-Windows GUI application. I hope that it gave you main ideas of how this programming paradigm works.

好，以上就是对这个简单的 Windows GUI 程序的代码走读。希望你理解了事件驱动这种编程范式的基本思路。

But no introduction to event-driven programming would give you a correct understanding without contrasting it with the traditional, sequential programming and the role of blocking within the code in particular.

但是，如果不把事件驱动编程跟传统的顺序编程做个对比——特别是阻塞在代码中的作用——那就不算真正理解。

And, this is exactly what I'd like to briefly explain in the last few minutes of this lesson.

接下来的几分钟，我正好来讲讲这个问题。

As an example of sequential programming, let me pull up some code from lesson 27 about the Real-Time Operating System -- RTOS. For instance, here is the sequentially coded blinky3 thread, which blinks the red LED on the TivaC LaunchPad board.

作为顺序编程的例子，我调出第 27 课 RTOS 中的一些代码。比如这个顺序编写的 blinky3 线程，它让 TivaC LaunchPad 上的红色 LED 闪烁。

So, let's try to do something similar in your event-driven "WndProc". For instance, let's say that you want to briefly blink an LED after pressing any key on your keyboard.

那我们试试在你的事件驱动 `WndProc` 里做类似的事情。比如，按下键盘上任意一个键后，让 LED 短暂闪一下。

From the code review before, you know that the right place in the "WndProc" is the `WM_KEYDOWN` case, where keyboard presses are handled.

从前面的代码走读中你知道，正确的位置是 `WM_KEYDOWN` 这个 case 分支。

A traditional, sequential implementation would be to turn an LED on, and then wait, meaning block, for, say 200 milliseconds, to actually see the blink and then to turn the LED off.

传统的顺序做法：开 LED，然后等待（也就是阻塞）200 毫秒让你能看到闪烁，再关掉 LED。

The Windows API actually provides an equivalent to the `delay()` RTOS service, which is called `Sleep()`. The Windows `Sleep()` API blocks and waits for the specified number of milliseconds.

Windows API 中有跟 RTOS 的 `delay()` 等价的函数，叫 `Sleep()`。它会阻塞等待指定的毫秒数。

Also, you obviously don't have LEDs on your Windows computer, so instead you could just display the LED state as text in the center of your window.

当然，Windows 电脑上没有 LED，所以你可以把 LED 状态用文本显示在窗口中央。

As in all other cases, after changing the text to display, you would need to invalidate the window rectangle to force the re-painting of the window.

跟其他情况一样，改了显示文本之后要调用 `InvalidateRect()` 让窗口重绘。

Sleep for 200 milliseconds.

然后 `Sleep` 200 毫秒。

After the `Sleep()` delay, you would change the LED text to "OFF" and invalidate the window rectangle again.

`Sleep` 结束后，把 LED 文本改成"OFF"，再次让窗口重绘。

As the other status variables, the LED text pointer needs to be defined as static in your "WndProc".

跟其他状态变量一样，LED 文本指针也要在 `WndProc` 中定义为 static。

And finally, you need to augment the painting of the window by adding the LED text to the displayed string buffer.

最后，在窗口绘制逻辑里把 LED 文本加到显示的字符串缓冲区中。

So now, let's simply build and run this program.

好，现在构建并运行这个程序。

When you press the keyboard once the LED state does not change as expected, even though the keyboard counter increments. So, your code for the LED does NOT work as you imagined.

按一下键盘，LED 状态并没有像预期那样变化，虽然键盘计数器确实递增了。你的 LED 代码**没有按你想象的那样工作**。

But wait, it's getting worse. When you press several keys in quick succession, the program freezes and does not update the keyboard counter immediately. Then, after a considerable while, the keyboard counter jumps all at once by some big increment.

等等，还有更糟的。快速连续按几个键，程序会卡住，键盘计数器也不更新。过好一会儿，计数器突然跳一大截。

Actually, when you press several keys and also wiggle the mouse, nothing happens in the application and no counter gets incremented until both keyboard and mouse counter jump by a big increment.

实际上，如果一边连按键一边晃鼠标，程序什么都不做，计数器也不动，直到最后所有计数器一起跳一个很大的数字。

All this is obviously not good, because the application appears frozen and unresponsive. Also, the massive jumps in the displayed event counters are rather strange.

这些显然都有问题：程序看起来冻结了、无响应了，而且计数器突然大幅跳跃也很诡异。

It turns out that this behavior is a consequence of asynchronous event posting and queuing of events inside Windows.

造成这种行为的原因，是 Windows 内部的异步事件投递和排队机制。

The problem is that the sleep delay blocks the "WndProc" and prevents it from quickly returning to the event-loop.

问题在于 `Sleep` 延迟阻塞了 `WndProc`，使它不能快速返回到事件循环。

When the event-loop spins too slowly, the keyboard events accumulate in the event queue. Only, when finally all the `WM_KEYDOWN` messages with their blocking delays are processed, the event-loop unclogs and quickly processes all other events. Hence the sudden jump in the counter values.

事件循环转得太慢，键盘事件就在队列里堆积。等到所有带阻塞延迟的 `WM_KEYDOWN` 消息都处理完，事件循环才疏通，快速把积压的事件一口气处理掉——计数器于是突然跳了一大截。

This problem is well known and Windows programmers have a name for it: They call such an application a **"pig"** and, believe me, you don't want to be a "pig".

这个问题业内都知道，Windows 程序员给这类程序起了个名字——叫**"猪"**（pig）。相信我，你不会想当一头"猪"的。

The old rule of thumb for Windows programs is that if anything requires more than about 100 milliseconds, it should be broken down into shorter pieces by using *events*.

Windows 编程有一条老经验法则：任何操作如果超过大约 100 毫秒，就应该用**事件**把它拆成更短的片段。

So, this explains the lack of responsiveness and the "freezing" of your program.

这就解释了程序为什么卡顿和冻结。

But, remember? The LED update after keypress events didn't actually work. And the reason for *that* is even more interesting.

但是，还记得吗？按键后 LED 更新实际上也没生效。这背后的**原因**更有意思。

From the event-driven perspective, every blocking call in your code, such as `Sleep()`, really means waiting for some event to happen. Then the unblocking means that the event has occurred.

从事件驱动的角度看，你代码里的每个阻塞调用（比如 `Sleep()`）本质上都是在等待某个事件发生。阻塞解除就意味着事件来了。

The event you get after unblocking might not be explicitly named, but still, it is delivered in the middle of processing of another event -- `WM_KEYDOWN` in this case. But this violates the Run-to-Completion semantics of event processing, which the event-driven Windows system assumes.

解除阻塞后得到的这个事件，虽然没有明确的名字，但它确确实实是在你处理另一个事件（`WM_KEYDOWN`）的过程中被投递进来的。这就违反了事件驱动的 Windows 系统所依赖的**运行到完成**（RTC）语义。

Quite specifically, the call to `InvalidateRect()` right before the blocking `Sleep()` has no effect, because the "WndProc" does not return back to Windows at this point. Therefore Windows has no chance to send the `WM_PAINT` message to the "WndProc" to actually update the LED state. Therefore you never see the update.

具体来说，在阻塞的 `Sleep()` 之前调用 `InvalidateRect()` 是没用的，因为 `WndProc` 这时候并没有返回到 Windows。Windows 也就没机会发 `WM_PAINT` 消息给 `WndProc` 来更新 LED 状态。所以你永远看不到更新。

So, as you can see, any use of the sequential programming paradigm, and especially blocking, is a BAD IDEA in event-driven systems for two reasons:

所以你看，在事件驱动系统里用顺序编程——尤其是阻塞——是**糟糕的做法**，原因有两个：

First, it clogs the event-loop and destroys the responsiveness of the program to all events, not just those that block for a while.

第一，它堵塞事件循环，程序对所有事件的响应都变差了，不只是那些阻塞的地方。

And second, it violates the Run-to-Completion semantics universally assumed in all event-driven systems.

第二，它违反了所有事件驱动系统都默认遵守的运行到完成语义。

This is the most important takeaway from this lesson I want you to remember: **Sequential programming and event-driven programming are two distinct paradigms that don't mix well -- so always keep them separate.**

这是我想让你记住的本课最重要的结论：**顺序编程和事件驱动编程是两种截然不同的范式，不能混在一起——始终要把它们分开。**

This means that in an event-driven program, you need to use a truly "event-driven" solution to implement your LED-blink-after-keypress feature.

也就是说，在事件驱动程序中，你必须用真正"事件驱动"的方式来实现"按键后闪 LED"这个功能。

To this end, instead of sequentially blocking with `Sleep`, you can use the Windows facility specifically designed for this purpose called the **"timer"**, which you can set to generate a special event called `WM_TIMER` in the given number of milliseconds in the future.

为此，不要用 `Sleep` 来顺序阻塞，而是用 Windows 专门为此设计的工具——**定时器**（timer）。你可以设置它在指定的毫秒数后产生一个特殊事件 `WM_TIMER`。

And this is really all you need to do in the `WM_KEYDOWN` case, because the rest of the processing then goes to the `WM_TIMER` case. Of course, you need to finish the processing in the usual way, with the only additional step to call `KillTimer`, because otherwise the Windows timer will keep expiring periodically with the programmed interval.

在 `WM_KEYDOWN` 分支里只需要做这些就够了，剩下的处理交给 `WM_TIMER` 分支。当然，处理完之后要调用 `KillTimer`，否则定时器会按设定的间隔不断触发。

Interestingly, in this case you use the `wParam` message parameter, which in this case holds the ID of the timer that generated the `WM_TIMER` message.

有意思的是，这里用到了 `wParam` 消息参数——它保存的是产生这条 `WM_TIMER` 消息的定时器 ID。

So, let's now see how this works.

来看看效果。

Let's first start with isolated keypress... As you can see, after every keypress the LED now changes the status momentarily to RED.

先试单次按键……可以看到，每次按键后 LED 状态都会短暂变为红色。

Now let's try bursts of keypresses plus wiggling the mouse at the same time... As you can see the LED status changes correctly and the event counters keep updating, so the application remains responsive.

再试试快速连按键盘同时晃鼠标……LED 状态正常变化，事件计数器持续更新，程序响应一切正常。

This concludes this quick introduction to event-driven programming using GUI and Windows API as an example. You've learned quite a few new concepts, which are summarized here for you.

以上就是用 GUI 和 Windows API 为例的事件驱动编程快速入门。你学到了不少新概念，这里做个总结。

To be called "event-driven" a program must possess most of the characteristics listed in this chart. But perhaps the property that sets an event-driven program most apart from a sequential one is **NO-BLOCKING** inside the application-level code.

要称得上"事件驱动"，一个程序必须具备这个图表中列出的大部分特征。但最能区分事件驱动程序和顺序程序的，可能就是应用程序级代码中**禁止阻塞**（NO-BLOCKING）这一条。

I will come back to this issue in the next lesson, where you will learn how event-driven programming applies to real-time embedded systems like your TivaC LaunchPad board. I hope you will join me for this fun.

下一课我们会继续讨论这个问题，届时你会看到事件驱动编程如何应用到 TivaC LaunchPad 这样的实时嵌入式系统上。希望你能继续跟着学。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| event-driven programming | 事件驱动编程 | 一种编程范式，程序执行流由事件驱动而非顺序执行 |
| event loop / message loop / message pump | 事件循环/消息循环/消息泵 | 事件驱动程序的核心结构，不断从队列取出事件并分发处理 |
| message queue | 消息队列 | 存储待处理事件的先进先出队列 |
| event / message | 事件/消息 | 系统中需要被程序处理的异步输入或通知 |
| signal | 信号 | 事件中标识事件类型的部分 |
| Run-to-Completion (RTC) | 运行到完成 | 每个事件的处理过程不可被其他事件中断 |
| inversion of control | 控制反转 | 框架调用应用程序代码，而非反过来 |
| asynchronous | 异步的 | 生产者投递事件后不等待消费者处理完成 |
| keyboard focus | 键盘焦点 | GUI 中当前接收键盘输入的窗口或控件 |
| Window Class | 窗口类 | 定义窗口行为模板的结构，包含属性和窗口过程指针 |
| window procedure (WndProc) | 窗口过程 | 处理窗口消息的回调函数，类似于虚成员函数 |
| Ultimate Hook | 终极钩子 | 应用程序可钩入每个事件的设计模式 |
| Programming by Difference | 按差异编程 | 只编写与默认行为不同的部分 |
| class hierarchy | 类层次结构 | 基类与子类的继承关系 |
| blocking | 阻塞 | 线程暂停执行等待某个条件满足 |
| NO-BLOCKING | 禁止阻塞 | 事件驱动编程的核心原则 |
| two-way communication | 双向通信 | 系统发消息给程序，程序返回处理状态 |
| timer | 定时器 | 到期后产生 WM_TIMER 事件，替代阻塞式 Sleep |
| static variable | 静态变量 | 在函数多次调用之间保持其值的变量 |
