# 第29课：面向对象编程——封装 / Lesson 29: OOP — Encapsulation

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'd like to introduce object-oriented programming, which is an important stepping stone in understanding modern software of any kind, not just modern embedded programming.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。今天我们来聊面向对象编程（Object-Oriented Programming, OOP）——这是理解各种现代软件的重要基础，不限于嵌入式编程。

Today you will learn about the high-level concepts, but as usual in this video course, you will also see how object oriented programming works at the low-level inside your embedded microcontroller. This lesson lays the foundation for understanding most modern trends in programming and almost all upcoming lessons in this course will in one way or another rely on the concepts introduced today.

今天我们会先讲高层概念，但跟这个课程的一贯风格一样，你也会看到面向对象编程在嵌入式微控制器底层是怎么运作的。本课是理解大多数现代编程趋势的基石，后续几乎所有课程都会用到今天介绍的概念。

As usual, let's get started by making a copy of the previous lesson 28 directory and renaming it to lesson 29. Get inside the new lesson 29 directory and double-click on the uVision project "lesson" to open it.

老规矩，先把上一课的 lesson 28 目录复制一份，改名为 lesson 29。进到新目录里，双击 uVision 项目文件"lesson"打开。

To remind you quickly what happened so far, in the last seven lessons you learned about the Real-Time Operating System (RTOS) and the associated programming paradigm based on blocking and sharing of resources among concurrent threads, such as you blinky1, blinky2 and blinky3.

简单回顾一下：前面七节课你学了实时操作系统（RTOS），以及与之配套的编程范式——基于阻塞和并发线程之间的资源共享，比如你的 blinky1、blinky2 和 blinky3。

Indeed, the most important and complex parts of the RTOS turned out not to be the context switching and thread scheduling, but rather the numerous mechanisms for blocking, synchronization, and mutual exclusion to support the "shared-state concurrency" programming paradigm.

你也看到了，RTOS 中最复杂、最重要的部分其实不是上下文切换和线程调度，而是各种阻塞、同步和互斥机制——它们是支撑"共享状态并发"编程范式的核心。

From the historic perspective, the RTOS went mainstream in the 1980's, and the RTOS-based shared-state concurrency model with blocking, essentially unchanged, continues to be in the mainstream use to this day. However, during the 1980's other important trends went mainstream as well, and these include object-oriented programming and event-driven programming.

从历史上看，RTOS 在 80 年代成为主流，基于 RTOS 的带阻塞的共享状态并发模型基本没变，至今仍是主流用法。不过，80 年代还有其他几个重要趋势也成了主流，其中就包括面向对象编程和事件驱动编程。

And since all these trends are essential to understanding modern embedded software, today I will explain the main concepts behind object-oriented programming, while I promise to talk about event-driven programming in the future. Many people think that object-oriented programming--OOP must necessarily be done in an OOP programming language, such as C++, Java, or Python.

这几个趋势对于理解现代嵌入式软件都非常关键，所以今天我先讲面向对象编程的核心概念，事件驱动编程后面再聊。很多人觉得面向对象编程——也就是 OOP——必须用专门的 OOP 语言来写，比如 C++、Java 或 Python。

But actually, OOP is not the use of any specific language, but rather a way of software design based on the three fundamental concepts of: Encapsulation, Inheritance; and Polymorphism.

但实际上，OOP 跟用什么语言没关系，它是一种软件设计方法，基于三个核心概念：**封装**（Encapsulation）、**继承**（Inheritance）和**多态**（Polymorphism）。

Today you will see how to implement these concepts in standard, portable C. After that, you will see the exact same design implemented in C++, which will allow you to compare C to C++ and also to get a taste of programming in C++.

今天你会看到如何在标准、可移植的 C 语言中实现这些概念。然后，同样的设计我们再用 C++ 实现一遍，这样你可以对比 C 和 C++，顺便体验一下 C++ 编程。

So, let's start with the concept of Encapsulation, which is closely related to Information Hiding and Abstraction. You have actually already used some of these concepts in the design of the Board Support Package (BSP). Here, you have specifically separated the "What" needs to be done in the bsp.h header file, from "How" it is done in the bsp.c implementation file.

先从封装说起。封装跟**信息隐藏**（Information Hiding）和**抽象**（Abstraction）密切相关。其实你之前在设计板级支持包（BSP）的时候已经用过这些概念了——你把"做什么"放在 bsp.h 头文件里，把"怎么做"放在 bsp.c 实现文件里，两者分得清清楚楚。

You have used the concept of abstraction, because all the details of handling the LEDs on your TivaC LaunchPad board are abstracted away and simplified into just three operations: on, off, and toggle.

你用了抽象，因为 TivaC LaunchPad 板子上操作 LED 的所有细节都被屏蔽掉了，对外只暴露三个操作：开（on）、关（off）和翻转（toggle）。

You have also used the concept of information hiding, because the information about specific ways of performing these operations on the LEDs is hidden from the users of the LEDs, such as your blinky threads.

你也用了信息隐藏，因为 LED 操作的具体实现方式对使用者来说是看不到的——比如你的 blinky 线程就不需要知道这些细节。

All the users of the LEDs see and all they really need is the bsp.h header file.

LED 的使用者看到的、也真正需要的，就只是 bsp.h 这个头文件。

But thus far the design based on abstraction and information hiding within the BSP module has an important limitation, which is that the design handles only a fixed number of LEDs: red, blue, and green in this case, and it cannot be easily extended to handle an open-ended number of LEDs.

但到目前为止，基于抽象和信息隐藏的 BSP 设计有一个重要局限：它只能处理固定数量的 LED——比如这里就是红、蓝、绿三个。想扩展成任意数量就很难了。

For example, imagine that your project uses a graphic LCD display, on which you need to draw various shapes, such as rectangles, circles, and triangles. It is very hard to tell upfront how many of these shapes you would need, so it is difficult to hide all this in a module without resorting to some kind of dynamic memory allocation, which is generally a BAD idea in real-time and embedded systems.

举个例子：假设你的项目用了一块图形 LCD 显示屏，需要在上面画各种形状——矩形、圆形、三角形。你很难事先知道到底需要多少个形状，所以很难把所有这些都藏在一个模块里，除非用动态内存分配——而在实时和嵌入式系统中，动态内存分配通常是**糟糕的做法**。

Instead, you need to give the application programmers a chance to allocate as many shapes as they like in any way they like: statically, automatically inside functions, or even dynamically on the heap; If they choose to do so.

更好的做法是让应用程序员自己决定要创建多少个形状、用什么方式创建：可以静态分配，可以在函数里自动分配，甚至可以在堆上动态分配——如果他们愿意的话。

You can achieve this by creating a different Shape interface than the BSP.h. Inside the new shape.h header file, you represent the data needed by each Shape as a C structure, which then can be instantiated in any way you want.

要做到这一点，你需要设计一个跟 BSP.h 不同的 Shape 接口。在新的 shape.h 头文件中，每个 Shape 需要的数据用一个 C 结构体来表示，这样就可以用任意方式实例化了。

For example, every Shape has a specific position on the screen given by the x and y coordinates.

比如，每个 Shape 在屏幕上都有一个由 x、y 坐标确定的位置。

Since the LCD screen is small, the 16-bit integer provides adequate dynamic range, but let's allow negative (that is signed values) to represent Shapes that are off screen.

LCD 屏幕比较小，16 位整数已经够用了。不过我们允许负值（也就是有符号数），这样就能表示屏幕之外的 Shape。

So far all this is really noting new compared to lesson 12 of this course, which introduced C structures and typedefs.

到这里为止，跟第 12 课介绍 C 结构体和 typedef 的内容相比，还没有什么新东西。

But now, comes the encapsulation part: By a coding convention, you disallow accessing the members of the Shape struct directly and instead you provide a set of functions specialized to work with the Shape structure.

接下来就是封装的部分了：通过编码约定，我们禁止直接访问 Shape 结构体的成员，而是提供一组专门操作 Shape 结构体的函数。

For example, you provide a way of initializing a Shape, called the "constructor".

比如，你提供一个初始化 Shape 的方法，叫做**构造函数**（constructor）。

This function takes a pointer to the Shape structure as the first parameter, which by convention you will call "me".

这个函数的第一个参数是指向 Shape 结构体的指针，按照约定我们叫它 `me`。

Since the "me" pointer should always point to the same Shape instance, let's prevent changing it by making it const. Please note that const is after the STAR, which means that the "me" pointer cannot change, but the Shape instance pointed to by the pointer IS allowed to change, which is the main purpose of the "constructor".

既然 `me` 指针应该始终指向同一个 Shape 实例，我们把它设为 const 来防止被修改。注意，const 放在星号（`*`）**后面**，意思是 `me` 指针本身不能变，但它所指向的 Shape 实例**可以**修改——这正是构造函数要做的事。

Next, you can also provide a function to move a shape on the screen by a given dx and dy increments.

接下来，你还可以提供一个函数，按给定的 dx、dy 增量在屏幕上移动形状。

And one more function with a return value to provide the distance from the "me" Shape to another Shape "other". This other shape should not need to change, so let's make it const. Please note that now the const is before the STAR. But actually, the "me" Shape should not need to change either, so let's make it const as well. Again, by adding const before the STAR.

再来一个带返回值的函数，计算从 `me` Shape 到另一个 Shape `other` 的距离。另一个形状不需要被修改，所以把它设为 const。注意，这次 const 放在星号**前面**。不过仔细想想，`me` Shape 也不需要修改，所以也加上 const——同样，const 放在星号前面。

Please note that you establish the association between the Shape data and the Shape functions by means of the following two coding conventions:

注意，我们通过以下两条编码约定来建立 Shape 数据和 Shape 函数之间的关联：

First, the names of all associated functions start with the name of the associated structure.

第一，所有相关函数的名字都以对应的结构体名开头。

And second, all these functions take the "me" pointer as the first parameter, with the purpose to specify which specific Shape instance the function is operating on.

第二，所有这些函数都把 `me` 指针作为第一个参数，用来指定函数操作的是哪个具体的 Shape 实例。

As you will see later in this lesson, the "me" pointer corresponds to the implicit "this" pointer in C++, and the "self" variable in Python, if you are familiar with Python.

稍后你会看到，`me` 指针对应的就是 C++ 中隐式的 `this` 指针。如果你熟悉 Python 的话，它也对应 Python 中的 `self`。

Now, you can add the C file shape.c and provide there the implementation of the Shape functions prototyped in shape.h. The "constructor" performs the initialization of the "me" structure from the provided x0 and y0 parameters.

现在，添加 shape.c 文件，在里面实现 shape.h 中声明的那些函数。构造函数根据传入的 x0、y0 参数来初始化 `me` 结构体。

The move-by function modifies the position of the "me" Shape by adding the provided dx and dy offsets.

moveBy 函数把传入的 dx、dy 偏移量加到 `me` Shape 的位置上。

And finally, the distance-from function calculates the distance between the "me" Shape and the "other" Shape. This function uses the simple "taxicab" geometry, which is adequate for Shapes but does not require extracting square root as the standard Cartesian metric.

最后，distanceFrom 函数计算 `me` Shape 和 `other` Shape 之间的距离。这个函数用的是简单的"出租车几何"（taxicab geometry），对于形状来说够用了，而且不需要像标准笛卡尔度量那样开平方根。

So, all this is quite straightforward, isn't it?

这些都挺直观的，对吧？

But what you just crated is called a Shape **CLASS**, which is quite a fundamental concept in object-oriented programming.

但你刚刚创建的东西叫做一个 Shape **类**（CLASS）——这是面向对象编程中非常基础的概念。

A CLASS combines both data, which are called in OOP "attributes" and functions, which are called in OOP "operations" into one entity -- the CLASS.

**类**把数据和函数合为一体——数据在 OOP 中叫**属性**（attributes），函数叫**操作**（operations），它们共同构成了一个类。

One nice aspect of classes is that they can be drawn in class diagrams, which show a class as a box with the class name at the top, then attributes, and then operations. Later, when you have more classes, a class diagram can also show the relationships among classes.

类的一个好处是可以画成类图：一个方框，顶部是类名，下面依次是属性和操作。以后类多了，类图还能展示类与类之间的关系。

A class realizes the concept of encapsulation, because it presents to the outside only the outer shell in form of the operations, while the internal data and internal implementation remain encapsulated inside the shell.

类实现了封装的概念——对外只暴露操作这个"外壳"，内部数据和实现细节都封装在壳里。

But back to the code, you can think of a class as a cookie-cutter from which you can create any number of instances of the class, called **OBJECTS**.

回到代码层面，你可以把类想象成一个饼干模具，用它来创建任意数量的实例，这些实例叫做**对象**（OBJECTS）。

So, now let's include the shape.h class declaration in the main.c file and create a couple of such objects of the Shape class.

好，现在我们在 main.c 中包含 shape.h 的类声明，然后创建几个 Shape 类的对象。

First, you can allocate a Shape object s1 statically.

你可以先静态分配一个 Shape 对象 `s1`。

You can also allocate another Shape object s2 automatically on the stack, inside a function, such as main().

也可以在函数（比如 `main()`）内部的栈上自动分配另一个 Shape 对象 `s2`。

And finally, you can also allocate yet another Shape object dynamically on the heap using the malloc() function from the standard library "stdlib.h".

还可以用标准库 `stdlib.h` 中的 `malloc()` 在堆上动态分配一个 Shape 对象。

As always with dynamic memory, it is also a good idea to immediately add the explicit free() library call for this object to prevent a memory leak.

跟所有动态内存一样，最好紧接着就写上对应的 `free()` 调用，防止内存泄漏。

As I already mentioned, dynamic memory allocation is typically a rather BAD idea in real-time embedded software, but it is a possibility for instantiating classes, so I show it here only for completeness.

前面说过，在实时嵌入式软件中动态内存分配通常是**糟糕的做法**，但它确实是实例化类的一种方式，所以这里展示一下，权当完整性的考虑。

But to finish this point, since you are using dynamic memory now, you need to make sure that your heap has adequate size.

不过既然现在用了动态内存，就得确保堆的大小足够。

In the project-options dialog box choose the Asm tab.

在项目选项对话框中选 Asm 标签页。

Here you can find two symbols for the C-stack and the heap, because the sizes of these memory areas are determined in the startup code in assembly. You need to increase the size of the heap to, say, 1KB, that is 1024 bytes.

这里能看到 C 栈和堆的两个符号，因为这些内存区域的大小是在汇编启动代码里定义的。你需要把堆的大小增大，比如 1KB，也就是 1024 字节。

But, going back to the code, another important convention of OOP is that the objects get initialized before any other operations can be performed on them. Object-oriented languages call the class constructors automatically, which you will see in a couple of minutes in C++, but in C you need to do this manually, by calling the "ctor" functions explicitly.

回到代码，OOP 还有一个重要约定：对象在任何其他操作之前必须先初始化。面向对象语言会自动调用构造函数——等下在 C++ 中你会看到。但在 C 里，你得自己手动调用 ctor 函数。

By the way, you might recognize the same pattern already used with respect to the QXThread objects from the QP/C framework. So now you know what that is.

顺便说一下，你可能已经认出来了，QP/C 框架中的 QXThread 对象用的就是这个模式。现在你知道那是什么了吧。

After the initialization, you can perform any defined operations on your objects. For example, you can move them around with the moveBy() operation.

初始化之后，就可以对对象执行任何已定义的操作了。比如，用 `moveBy()` 来移动它们。

Or you can check their relative distances from each other. Here I use the assertion macros from the QP/C framework to assert the basic properties of the distance operation, which are: - the distance from a shape to the same shape must be zero - the distance from shape1 to shape2 must be the same as shape2 to shape1 - and the distance between two shapes s1 and s2 must be less or equal to the sum of distances to any other shape, like ps3.

也可以检查它们之间的相对距离。这里我用了 QP/C 框架的断言宏来验证 distance 操作的基本性质：
- 一个形状到自身的距离必须为零
- 从 shape1 到 shape2 的距离必须等于从 shape2 到 shape1 的距离
- 两个形状 s1 和 s2 之间的距离，必须小于等于它们分别到任意其他形状（比如 ps3）的距离之和

At this point, you can also check that the moveBy() operation is not allowed for const Shape objects. For this you can declare a Shape const pointer ps1 pointing to the s1 shape.

这时候你还可以验证一下：对 const Shape 对象调用 `moveBy()` 是不允许的。为此，声明一个指向 s1 的 Shape const 指针 ps1。

When you try to call the moveBy() operation on this pointer, the compiler protests with an error.

当你尝试对这个指针调用 `moveBy()` 时，编译器会报错。

This is an example of the main guiding principle for designing class interfaces: your interfaces should be easy to use correctly and hard to use incorrectly.

这就体现了设计类接口的核心指导原则：**让你的接口易于正确使用，难以错误使用**。

Now, let's have a look at how encapsulation works internally and how to debug object-oriented code based on classes.

好，现在我们来看看封装在底层是怎么工作的，以及怎么调试基于类的面向对象代码。

First, as you step through the main code, you can watch the call to the malloc function. The function takes the sizeof Shape parameter, which turns out to be 4 bytes. This makes sense, because the Shape struct consists of two two-byte integers.

首先，单步执行主代码时，你可以观察 `malloc` 的调用。它接收 `sizeof Shape` 作为参数，结果是 4 字节。这很合理，因为 Shape 结构体就是两个两字节的整数。

Next, you can see that a call to a class operation, such as the constructor, places the "me" pointer in the r0 register. This is per the ARM Application Procedure Call Standard (AAPCS) introduced back in lesson 9.

接下来可以看到，调用类操作（比如构造函数）时，`me` 指针被放进了 r0 寄存器。这符合第 9 课讲过的 ARM 应用过程调用标准（AAPCS）。

As you step inside a class operation, you can see in the disassembly window that the access to class attributes uses the offset-from-a-register addressing mode from the "me" pointer in r0. This is very efficient.

进入类操作内部后，在反汇编窗口中可以看到，访问类属性用的是从 r0 中 `me` 指针出发的"寄存器偏移寻址"模式，非常高效。

Also, inside a class operation, it is always convenient to watch the "me" pointer, which is at the top of the locals window. This means that you can very conveniently see the class attributes.

在类操作内部，观察 `me` 指针总是很方便——它在局部变量窗口的顶部，你可以直接看到所有类属性。

As you keep stepping through the code, you can see that this pattern of placing the "me" pointer in the r0 register repeats for ALL class operations.

继续单步执行，你会发现把 `me` 指针放进 r0 寄存器这个模式在**所有**类操作中都一样。

So in the end the "me" pointer helps you not only in understanding the code, but also in debugging, because you always easily see the object you are dealing with. As it turn out this also results in excellent performance.

所以 `me` 指针不光帮你理解代码，还帮你调试——你总是能轻松地看到当前操作的对象。事实证明性能也非常好。

So, this is how you can emulate class encapsulation in C. But what about "real" object-oriented programming languages? How would that work in C++, for example?

好，这就是在 C 中模拟类封装的方法。那"真正的"面向对象语言呢？比如 C++ 里是怎么做的？

Well, let me show you right now.

来，我这就给你演示。

Specifically, let's take this whole lesson and translate it into C++. This will allow you to directly find out how it differs from C. In the first step, let's just copy the whole lesson 29 directory and rename it lesson29_cpp.

具体来说，我们把整节课的内容翻译成 C++。这样你可以直接对比 C 和 C++ 的区别。第一步，把 lesson 29 的整个目录复制一份，改名为 lesson29_cpp。

Get inside the new directory and rename all dot-C files to dot-CPP. Finally, drop the project lesson onto the uVision IDE to open it instead of the previous project in C.

进到新目录，把所有 `.c` 文件重命名为 `.cpp`。然后把项目文件 lesson 拖到 uVision IDE 里打开，替代之前的 C 项目。

The IDE has obviously problems opening the no longer existing dot-C files, which you need to remove from the project.

IDE 显然打不开那些已经不存在的 `.c` 文件了，你需要把它们从项目中移除。

Instead, you need to now add the new existing dot-CPP files. You re-build the whole project, which produces some compilation errors.

然后把新的 `.cpp` 文件添加进去。重新构建整个项目，会出现一些编译错误。

The first error is in converting the void pointer returned from malloc to the Shape pointer ps3. This was fine in C, because void pointer implicitly converts to a pointer of any other type, but C++ is stricter and requires exact match between the types.

第一个错误是把 `malloc` 返回的 void 指针转换为 Shape 指针 ps3。在 C 中这没问题，因为 void 指针会隐式转换成任何其他类型的指针。但 C++ 更严格，要求类型精确匹配。

The other errors are of the exact same nature, because void pointers are used instead of pointers to the QPC event type QEvt.

其他错误性质完全一样，都是因为用了 void 指针而不是指向 QPC 事件类型 QEvt 的指针。

But after these few cosmetic changes, the project compiles and links error and warning-free.

不过改完这几处小问题之后，项目就能无错无警告地编译链接了。

That's very interesting, because it shows you that C++ compiler accepts the C implementation just fine, it is only a bit more strict in terms of type checking. This means that you can get into C++ programming quite easily form C and that you can treat C++ at first as a better, more strict version of C.

这很有意思——它说明 C++ 编译器完全可以接受 C 代码，只是类型检查更严格一些。这意味着从 C 过渡到 C++ 非常容易，你可以先把 C++ 当成一个更好、更严格的 C 来用。

But of course C++ offers you much more than this. It is truly an object-oriented language that supports classes directly. So, let's now convert your Shape class emulated in C into a true C++ class.

当然，C++ 提供的远不止这些。它是一门真正的面向对象语言，直接支持类。现在我们把用 C 模拟的 Shape 类转换成真正的 C++ 类。

The first thing is to replace the keyword struct with class followed by the class name.

第一步，把 `struct` 关键字换成 `class`，后面跟类名。

You also don't need the awkward typedef anymore, because the name after the class keyword in C++ can be used as a type by itself, without the class prefix.

那个别扭的 typedef 也不需要了，因为在 C++ 中 `class` 关键字后面的名字可以直接当类型用，不需要加 class 前缀。

Also, because a C++ class encompasses both attributes and operations, the closing brace goes now after the last operation.

而且，因为 C++ 的类同时包含属性和操作，所以右花括号现在要放到最后一个操作后面。

Now, because class operations are truly inside the class, you no longer need the pre-pended class name in front. But this concept of mangling the name of the class with the name of the operation is not completely lost. As you will see later in this lesson, the C++ compiler actually also performs such name-mangling behind the scenes.

现在类操作真正写在类里面了，前面不需要再加类名了。不过类名和操作名混在一起的概念并没有完全消失——稍后你会看到，C++ 编译器在幕后也做了类似的**名称修饰**（name-mangling）。

The class attributes should be encapsulated, meaning that they should be inaccessible outside of the class. In C it was just a coding convention, but C++ provides the special "private" keyword to restrict the access to these class members.

类属性应该被封装起来，在类外部不可访问。在 C 中这只是编码约定，而 C++ 提供了 `private` 关键字来真正限制对这些成员的访问。

On the other hand, class operations need to be publicly accessible, for which C++ provides the "public" keyword.

另一方面，类操作需要对外公开，C++ 提供了 `public` 关键字。

Now, regarding the constructor operation, C++ supports class constructors directly and calls them automatically whenever the class is instantiated. Because of this special status, the constructor must have a special name, which is the same as the name of the class. A C++ constructor also cannot return any value.

关于构造函数，C++ 直接支持，并且在实例化类的时候自动调用。正因为这种特殊地位，构造函数的名字必须跟类名一样，而且不能有返回值。

Now, the most interesting aspect of any class operation, including the constructors, is that in C++ they all take an implicit parameter called "this" that is exactly like the "me" pointer you applied in C.

所有类操作最有趣的一点——包括构造函数——是它们在 C++ 中都有一个隐式参数叫 `this`，跟你 C 里用的 `me` 指针完全一样。

Therefore, because the pointer to the class instance, now called "this", is already provided implicitly by the C++ compiler, you don't need to duplicate it, so you need to remove the "me" pointer.

既然指向类实例的指针——现在叫 `this`——已经由 C++ 编译器隐式提供了，就不需要再重复了，所以把 `me` 指针去掉。

The "me" pointer in the distanceFrom() operation is a bit tricky, because it has the const qualifier that you don't want to lose. C++ provides for this the special syntax, where you move the "const" qualifier after the operation.

`distanceFrom()` 操作中的 `me` 指针有点特殊，因为它有 const 限定符，不能丢掉。C++ 为此提供了专门的语法：把 `const` 放到操作声明的后面。

By the way, you could have named the "me" pointer as "this" in C, and the C compiler would happily compile such code. But that original C code would NOT compile in C++, because "this" is a keyword in C++.

顺便说一下，你本可以在 C 中把 `me` 指针命名为 `this`，C 编译器完全不会抱怨。但那段 C 代码在 C++ 中**编译不过**，因为 `this` 是 C++ 的关键字。

The moral here is to avoid using keywords for your identifiers, even if they are in different, but related languages like C and C++.

教训就是：不要用关键字做标识符，即使它们属于不同但相关的语言（比如 C 和 C++）。

OK, so this is the complete Shape class declaration in C++. Now, let's move on to adjust the definitions of the class operations in the shape.cpp file.

好，以上就是完整的 Shape 类在 C++ 中的声明。接下来调整 shape.cpp 文件中类操作的定义。

So, here it is.

就在这里。

Let's skip the constructor for the time being, and focus on the regular class operations.

先跳过构造函数，看普通的类操作。

The first thing you need to change is to replace the underscore with the colon-colon scope resolution operator, which tells the C++ compiler that the operation belongs to a given class, such as Shape in this case.

首先要把下划线换成双冒号**作用域解析运算符**（`::`），告诉 C++ 编译器这个操作属于哪个类——比如这里的 Shape。

Next, you need to remove the "me" pointer from the signature. Now, inside the body of the function, let's replace the "me" pointer with the "this" pointer to show you that this implicit pointer really exists and is indeed used to access the class attributes.

然后把函数签名中的 `me` 指针去掉。在函数体内，我们用 `this` 指针替换 `me`，让你看到这个隐式指针确实存在，而且确实用来访问类属性。

The same goes for the distanceFrom() operation, except you need to be careful with the const qualifier, just as you did in the declaration of this operation.

`distanceFrom()` 操作也一样，只是要注意 const 限定符，跟声明时一样处理。

In this case, let's simply remove the "me" pointer also from the body of the function without using the "this" pointer, because the C++ compiler will recognize the names of class attributes and will implicitly add the "this" pointer in front of them.

这次我们把函数体里的 `me` 也去掉，不用 `this`——因为 C++ 编译器会自动识别类属性的名字，隐式地在前面加上 `this` 指针。

And finally, with the constructor, you can also apply the same adjustments and it will also compile like that.

构造函数也一样做同样的调整，也能编译通过。

But the truly C++ way of initializing the class attributes in a constructor is by means of the constructor initializer list, which looks like this.

但在构造函数中初始化类属性的"正宗" C++ 做法是用**构造函数初始化列表**（constructor initializer list），长这样。

Now, let's try to compile just this one shape.cpp file. As you can see the C++ compiler accepts the Shape class without any errors or warnings.

来试着只编译 shape.cpp 这一个文件。可以看到，C++ 编译器完全接受这个 Shape 类，没有任何错误或警告。

To finish off the conversion to C++, you still need to adjust the actual use of the Shape class in the main.cpp file. Here, you need to replace the explicit calls to the Shape constructor with initialization right at the points of allocation of the Shape objects.

要完成 C++ 转换，还得调整 main.cpp 中 Shape 类的实际用法。这里要把显式的 Shape 构造函数调用替换为在分配对象时直接初始化。

For example, the static object s1 needs to be initialized right where it is allocated.

比如静态对象 `s1`，要在分配的地方直接初始化。

Similarly, the automatic object s2 must also be initialized at the point of allocation.

自动对象 `s2` 也一样，分配时就初始化。

A dynamic object, like ps3 here, is allocated in C++ by means of the C++ new operator, which is followed by the class constructor. While you are at it, any object allocated with new must be disposed of by means of the C++ delete operator.

动态对象（比如这里的 ps3）在 C++ 中用 `new` 运算符分配，后面跟上类构造函数。顺便说一下，任何用 `new` 分配的对象都必须用 `delete` 运算符来释放。

Now, the syntax of calling class operations is different in C++ and is performed by means of the dot-operator that in C was used only for accessing data members of a structure.

调用类操作的语法在 C++ 中不一样了——用**点运算符**（`.`）。在 C 中点运算符只用来访问结构体的数据成员。

Specifically, the moveBy operation is invoked by first specifying the object then the dot-operator and then the operation name and argument list.

具体来说，调用 moveBy 的方式是先写对象名，然后点运算符，再写操作名和参数列表。

An operation on a pointer to an object is invoked by the arrow-operator, which in C was used only for accessing member of a structure, but in C++ just like the dot-operator is used for both attributes and operations. Please note that while the syntax might be different between C and C++, the actual information supplied for each operation is identical in both cases.

通过指针调用操作则用**箭头运算符**（`->`）。在 C 中箭头运算符只用来访问结构体成员，但在 C++ 中跟点运算符一样，属性和操作都能用。注意，虽然 C 和 C++ 语法不同，但每次调用传递的实际信息是完全一样的。

After completing all the changes, you can see that the project builds cleanly.

所有改动完成后，项目可以干净地构建。

So now, comes the most interesting part, which is to see the machine code generated by the C++ compiler and to compare it with the previous code generated by the C compiler.

接下来是最有趣的部分——看看 C++ 编译器生成的机器代码，然后跟之前 C 编译器生成的做个对比。

But first, even before opening the debugger, go to the Shape class implementation and set a breakpoint in the Shape constructor. Now, launch the debugger.

不过在打开调试器之前，先到 Shape 类的实现里，在构造函数上设一个断点。然后启动调试器。

Interestingly, the code stops at the breakpoint in the Shape constructor, even before the main function was called.

有意思，代码停在了 Shape 构造函数的断点处——而此时 `main` 函数都还没被调用。

Indeed, when you examine the call stack, you can see that the Shape constructor is not called from main, but from some "cpp_initialization code".

看看调用栈就知道了：Shape 构造函数不是从 `main` 调用的，而是从某个 "cpp_initialization code" 调用的。

This is an interesting observation for two reasons:

这个观察很有意思，原因有两个：

First, you just learned that in C++ the constructors of static objects, like s1, are called even before the main() function.

第一，你刚刚看到：在 C++ 中，静态对象（比如 s1）的构造函数在 `main()` 之前就被调用了。

And second, you just learned that C++ requires an extra step in the startup code to invoke these static constructors.

第二，C++ 的启动代码中需要一个额外的步骤来调用这些静态构造函数。

But when it comes to the actual machine code generated by this very different C++ syntax of constructor initializer list, it turns out to be actually identical to the code generated from the C implementation.

不过，虽然 C++ 的构造函数初始化列表语法看起来跟 C 完全不同，生成的实际机器代码却一模一样。

When you continue from here, you can see that the Shape constructor has been called again, but this time from main. Indeed this is the constructor for the automatic s2 object inside main.

继续往下走，Shape 构造函数又被调用了一次——这次是从 `main` 里调的。没错，这就是 main 里面自动对象 s2 的构造函数。

When you keep stepping from here, you can see the invocation of the new operator.

继续单步执行，你会看到 `new` 运算符的调用。

Keep single stepping and... as you can see, you arrive at a call to malloc. So, you just found out that the C++ operator new calls malloc() internally.

继续单步走……看到了吧，你到达了对 `malloc` 的调用。所以你刚刚发现了：C++ 的 `new` 运算符内部调用的就是 `malloc()`。

Moreover, the parameter passed to malloc in r0 is 4, which means that the size allocated for the C++ Shape object is 4 bytes. This is again exactly the same as it was in C.

而且传给 `malloc` 的 r0 参数是 4，说明 C++ Shape 对象的大小也是 4 字节——跟 C 中的完全一样。

When you continue, you can see that the Shape constructor is invoked for the third time, which means that the new operator also calls the constructor for the object allocated dynamically.

继续，Shape 构造函数被第三次调用了——说明 `new` 运算符也为动态分配的对象调用了构造函数。

So, to quickly summarize, you just saw how C++ ensures that the constructor is invoked in every case after allocating an object.

快速总结一下：你刚刚看到了 C++ 如何确保在任何情况下，分配对象之后都会调用构造函数。

OK, so now let's move the breakpoint from the constructor to the first invocation of the moveBy() operation.

好，现在把断点从构造函数挪到 `moveBy()` 操作的第一次调用处。

When you continue and hit the breakpoint, you can compare the C++ code for calling moveBy() with the corresponding call in C. As you can see they turn out to be... identical.

继续执行命中断点后，你可以对比 C++ 调用 `moveBy()` 的代码和 C 中对应的调用。结果……完全一样。

After you step inside the moveBy() operation, it is a good idea to watch the locals window, where conveniently the "this" pointer shows at the top. This is exactly like the "me" pointer was in C.

进入 `moveBy()` 内部后，看看局部变量窗口——`this` 指针就显示在顶部，非常方便。这跟 C 中的 `me` 指针一模一样。

Moreover, the actual machine code for the moveBy() implementation in C++ turns out to be again exactly the same as the C code before.

而且 `moveBy()` 实际的机器代码跟之前 C 版本的也完全相同。

I'm not going to repeat it for the distanceFrom() operation, because I hope you are getting the idea: The C++ compiler generated identical code as your original C emulation of classes for both the invocations and implementations of the operations.

`distanceFrom()` 就不再重复了，希望你已经开始明白了：不管是操作调用还是操作实现，C++ 编译器生成的代码跟你用 C 模拟类的代码完全一样。

So, now I hope you know how classes and encapsulation work and what's going on behind the scenes in C++.

所以，现在你应该知道类和封装是怎么工作的，以及 C++ 幕后都在做什么了。

Before I wrap up for this lesson, the last aspect of encapsulation I'd like to explain is how it relates to the RTOS, because of course you can use classes and RTOS together.

结束之前，我还想解释封装的最后一个方面——它跟 RTOS 的关系。当然了，类和 RTOS 是可以一起用的。

Imagine, for example that you move the static object s1 to the top of the file and that you invoke the moveBy() operation from the blinky1 thread. You also copy the distanceFrom() operation on the same object s1 to your blinky2 thread.

比如，假设你把静态对象 s1 移到文件顶部，然后在 blinky1 线程里调用 `moveBy()` 操作，同时在 blinky2 线程里对同一个 s1 对象调用 `distanceFrom()`。

Please note that the assertion that a distance from s1 to s1 must be zero should be always true and that it is checked downstream from the semaphore-wait, which means that it will run only after you press the SW1 button on your TivaC LaunchPad board.

注意那个断言——s1 到自身的距离必须为零——按理说应该始终成立。它放在信号量等待之后，也就是说只有按下 TivaC LaunchPad 板子上的 SW1 按键后才会执行。

As you can see, the project still builds cleanly, so let's open it in the debugger.

可以看到项目仍然能干净地构建，我们在调试器中打开它。

This time, before running the code, set a breakpoint in the Q_onAssert() handler, so that you immediately know should any of the assertions fail.

这次运行之前，先在 `Q_onAssert()` 处理函数里设个断点，这样一旦有断言失败你就能立刻知道。

Now, run the code free and start pressing the SW1 button.

好，让代码自由运行，然后开始按 SW1 按钮。

As you can see, most of the time the code keeps running, which means that the assertion in blinky2 evaluates successfully thousands of times.

可以看到，大部分时间代码都在正常运行，说明 blinky2 里的断言成功通过了成千上万次。

But keep trying, and... Oops!!! You hit an assertion.

继续按……哎呀！断言失败了。

Check it, and indeed the assertion failed inside your blinky2 thread.

看看——确实，断言在 blinky2 线程内部失败了。

The reason is a race condition around the shared s1 object, which is being modified in one RTOS thread -- blinky1 while it is used in another RTOS thread -- blinky2. If you don't remember what race condition is, please refer to lesson 19.

原因是在共享的 s1 对象上发生了**竞态条件**（race condition）：一个 RTOS 线程 blinky1 在修改它，另一个线程 blinky2 在读取它。如果你不记得什么是竞态条件，可以回顾第 19 课。

The important corollary from this is that even though you applied encapsulation for accessing the shared object s1, it didn't really prevent a race condition.

这引出一个重要结论：即使你对共享对象 s1 的访问做了封装，它也并没有真正防止竞态条件。

And after what you've seen today, I hope you understand why.

看了今天的内容，希望你明白为什么。

You just saw that encapsulation works internally in C++ exactly the same way as you emulated it in C, and boils down to simple function calls. This might hide the internal implementation, but does really nothing to prevent race conditions.

你刚刚看到，C++ 中封装的内部实现跟你用 C 模拟的完全一样，归根结底就是简单的函数调用。隐藏内部实现是可以的，但对于防止竞态条件无能为力。

To achieve a true encapsulation for concurrency you need to go beyond the concept of a simple class and employ so called **active** class also known as the **active object** design pattern. This active object pattern is a fusion of concurrent programming, object-oriented programming, and event-driven programming and I will talk about active objects in the future lessons.

要实现真正的并发封装，你得超越简单类的概念，使用所谓的**活动类**（active class），也叫**活动对象**（active object）设计模式。活动对象模式是并发编程、面向对象编程和事件驱动编程三者的融合，后面的课程中我会专门讲。

But this is it for this lesson. Today, you have learned about the concept of encapsulation, that is, classes and objects both in C and in C++.

好，本课就到这里。今天你学了封装的概念——也就是 C 和 C++ 中的类和对象。

In the following lessons on Object-Oriented Programming you will learn about the two other fundamental concepts of inheritance and polymorphism.

接下来的面向对象编程课程中，你将学习另外两个核心概念：继承和多态。

If you like this channel, please subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请订阅以获取最新内容。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Object-Oriented Programming (OOP) | 面向对象编程 | 一种基于"对象"概念的编程范式，对象包含数据（属性）和操作（方法） |
| Encapsulation | 封装 | 将数据和操作数据的方法捆绑在一起，并隐藏内部实现细节 |
| Information Hiding | 信息隐藏 | 隐藏模块或类的内部实现细节，只暴露必要的接口 |
| Abstraction | 抽象 | 提取事物的本质特征，忽略非必要的细节 |
| Class | 类 | OOP 中的基本构造，将属性（数据）和操作（函数）组合为一个实体 |
| Object / Instance | 对象 / 实例 | 类的具体化，由类创建的实体 |
| Constructor | 构造函数 | 用于初始化对象的特殊操作，在 C++ 中自动调用 |
| Attribute | 属性 | 类中包含的数据成员 |
| Operation / Method | 操作 / 方法 | 类中定义的函数 |
| `me` pointer | `me` 指针 | C 语言中模拟类操作时用于指向当前对象实例的指针，对应 C++ 中的 `this` |
| `this` pointer | `this` 指针 | C++ 中隐式传递给每个类操作的指针，指向当前对象实例 |
| Name-mangling | 名称修饰 | C++ 编译器将类名与操作名组合以生成唯一内部名称的机制 |
| Scope resolution operator (`::`) | 作用域解析运算符 | C++ 中用于指定操作所属类的运算符 |
| Constructor initializer list | 构造函数初始化列表 | C++ 中在构造函数体执行之前初始化类属性的语法 |
| `private` keyword | `private` 关键字 | C++ 访问控制修饰符，限制成员只能在类内部访问 |
| `public` keyword | `public` 关键字 | C++ 访问控制修饰符，允许成员在类外部访问 |
| `new` / `delete` operators | `new` / `delete` 运算符 | C++ 中动态内存分配和释放的运算符，`new` 内部调用 `malloc()` |
| Race condition | 竞态条件 | 多个线程并发访问共享资源时可能导致的不确定行为 |
| Active Object pattern | 活动对象模式 | 将并发编程、OOP 和事件驱动编程融合的设计模式，实现真正的并发封装 |
| Board Support Package (BSP) | 板级支持包 | 硬件抽象层，封装了特定开发板的硬件操作细节 |
| AAPCS | ARM 应用过程调用标准 | ARM 架构的函数调用约定，规定参数通过寄存器（如 r0）传递 |
| Taxicab geometry | 出租车几何 | 一种度量方式，距离为坐标差值之和（曼哈顿距离），无需计算平方根 |
| Static allocation | 静态分配 | 在编译时确定内存位置，生命周期贯穿整个程序运行期 |
| Automatic allocation | 自动分配 | 在栈上分配，生命周期限于函数调用期间 |
| Dynamic allocation | 动态分配 | 在堆上通过 `malloc()`/`new` 在运行时分配内存 |
