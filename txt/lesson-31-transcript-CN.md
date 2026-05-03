# 第31课：面向对象编程——多态 / Lesson 31: OOP — Polymorphism

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I continue the subject of Object-Oriented Programming. Today you will learn about the concept of *polymorphism* and you will see how it works in C++ and how to emulate it in C.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，这节课我们继续面向对象编程的话题。今天你要学的是**多态**（polymorphism）这个概念，看看它在 C++ 中是怎么工作的，以及怎么在 C 中模拟它。

Unlike the previously discussed notions of encapsulation and inheritance, polymorphism is a uniquely object-oriented concept that has no direct analog in a traditional procedural language like C. Therefore the plan for today is reversed compared to previous two lessons in that you will first see what polymorphism is and how it works in C++, and only with this knowledge you will see how to emulate it in C.

跟之前讲的封装和继承不同，多态是一个纯粹的面向对象概念，在 C 这种传统的过程式语言里没有直接的对应物。所以今天的安排跟前两课反过来了——先看多态是什么、在 C++ 里怎么运作，然后再学怎么在 C 里模拟它。

So, let's get started today by making a copy of the previous lesson 30-understcore-cpp directory and renaming it to lesson 31-underscore-cpp. Get inside this new directory and double-click on the uVision project "lesson" to open it.

先来做个准备工作：把上一课的 `lesson30_cpp` 目录复制一份，改名为 `lesson31_cpp`。进到这个新目录里，双击 uVision 项目文件 "lesson" 打开它。

To remind you quickly what happened so far, in the last lesson you learned about the concept of class inheritance and you've created a Rectangle class that inherited all attributes and operations from the Shape base class.

快速回顾一下上节课的内容：你学了**类继承**（inheritance）的概念，创建了一个 Rectangle 类，它继承了 Shape 基类的所有属性和操作。

But Rectangle also added its own attributes and operations, such as the draw() operation to draw the Rectangle on an LCD screen and the area() operation to calculate and return the surface area of the Rectangle.

不过 Rectangle 还添加了自己的属性和操作，比如 `draw()` 操作用来在 LCD 屏幕上画矩形，`area()` 操作用来计算并返回矩形的面积。

However, both added operations actually make sense for the Shape base class as well, because any Shape could be drawn on the screen and has a surface area.

其实这两个操作对 Shape 基类也完全说得通——任何形状都可以画到屏幕上，也都有面积。

The only problem is that the Shape class is so generic that you don't really know *how* to implement the draw() and area() operations at this high level.

唯一的问题是，Shape 类太泛了，在这个层面上你确实不知道*怎么*实现 `draw()` 和 `area()` 操作。

But by now you probably have noticed that object-oriented programming is all about separating the *interface* -- the "What can be done" from the implementation -- the "How it is done". So in this spirit, the Shape class could at least provide an *interface* to the draw() and area() operations and worry about the implementation later.

到这会儿你应该已经发现了：面向对象编程的核心就是把**接口**（interface）——"能做什么"——跟实现（implementation）——"怎么做"——分离开来。按这个思路，Shape 类至少可以为 `draw()` 和 `area()` 操作提供一个接口，具体实现以后再说。

So, let's have a look at how it could work.

来看看具体怎么做。

Let's at first simply copy the area() and draw() signatures from the Rectangle subclass to the Shape superclass.

先把 `area()` 和 `draw()` 的函数签名从 Rectangle 子类复制到 Shape 父类里。

Let's also copy the implementation of these operations from Rectangle and adapt it to Shape.

再把这些操作的实现也从 Rectangle 复制过来，适配到 Shape 上。

Of course at the high level of the generic Shape class, you cannot provide real implementations because you don't yet know if you are dealing with Rectangles, Circles, Triangles or Lines. So you provide only some dummy code.

当然，在 Shape 这个通用类的层面上，你没法给出真正的实现——因为你不知道将来处理的到底是矩形、圆形、三角形还是线条。所以先写点占位的假代码就行。

But now, when it comes to testing this new Shape interface, in the last lesson you learned about *upcasting*, which is casting a derived class to the base class. This is always safe and object-oriented languages like C++ perform such upcasting automatically without complaining.

现在要测试这个新的 Shape 接口了。上节课你学过**向上转型**（upcasting）——就是把派生类转成基类。这种转型总是安全的，C++ 这样的面向对象语言会自动帮你做，不会报错。

This opens an interesting option of upcasting a pointer to a Rectangle object "r1" to a pointer to Shape "ps" and then calling the draw() and area() operations on such an upcast pointer.

这就带来了一种有趣的玩法：把指向 Rectangle 对象 "r1" 的指针向上转型成指向 Shape 的指针 "ps"，然后通过这个转型后的指针来调用 `draw()` 和 `area()` 操作。

As you can see, this compiles error and warning-free, so let's check in the debugger which operations are called in this case.

如你所见，编译没有任何错误和警告。那我们在调试器里看看，这种情况下到底调用的是哪个实现。

And as I step into the call, you can see that... the Shape's implementation is called, which is rather unremarkable, because the compiler evidently chose the function corresponding to the type of the pointer, not the type of the object.

当我单步进入调用时，你会发现……调用的是 Shape 的实现。这并不奇怪，因为编译器显然是根据指针的类型来选择函数的，而不是根据对象的实际类型。

But, let's go back to the code and modify the declaration of the Shape class by adding the *virtual* keyword in front of the draw() and area() operations.

现在回到代码，在 Shape 类的 `draw()` 和 `area()` 操作前面加上 **virtual** 关键字。

With this change, the compiler raises some warnings, but let's ignore them for now and just open the debugger.

改完之后编译器会报几个警告，先不管它，直接打开调试器。

This time around, as you step into the draw() operation... the Rectangle's implementation is called.

这次再单步进入 `draw()` 操作……调用的就是 Rectangle 的实现了。

The same happens for the area() operation call as well.

`area()` 操作也一样。

This means that all of the sudden, the calls select implementations based on the type of the object, which is Rectangle, not the type of the pointer, which remains Shape. This is *polymorphism* in action.

也就是说，现在调用是根据对象的实际类型（Rectangle）来选择实现的，而不是根据指针的类型（Shape）。这就是**多态**在发挥作用。

The term "polymorphism" itself comes from the Greek roots "poly" meaning many and "morphe" meaning form. So polymorphism means multiple forms.

"多态"（polymorphism）这个词来自希腊语，"poly" 意思是"多"，"morphe" 意思是"形态"，合起来就是多种形态的意思。

And indeed this what's happening here. The same operation, such as draw() or area(), can take multiple forms, depending on the type of the object that the pointer happens to be pointing to.

确实就是这样。同一个操作——比如 `draw()` 或 `area()`——可以呈现不同的形态，具体呈现哪种形态取决于指针实际指向的对象类型。

This is all good and perhaps interesting, but what is polymorphism good for in practice?

这些听起来都不错，也挺有意思，但多态在实际中到底有什么用呢？

Well, among other things, polymorphism allows you to write generic code at a higher level of abstraction than you could without it.

简单来说，多态让你能写出更通用的代码，站在更高的抽象层次上编程。

For example, suppose that you want to draw a graph consisting of multiple Shapes on your LCD screen. For simplicity, suppose that a graph is an array of pointers to various Shape objects.

举个例子，假设你想在 LCD 屏幕上画一个由多个形状组成的图形。为简单起见，我们用一个指向各种 Shape 对象的指针数组来表示这个图形。

Note that the Shape pointers in a graph might actually point to different types, but because all of them inherit the Shape base class, all can be safely upcast to the Shape type.

注意，这些 Shape 指针实际上可能指向不同的类型，但因为它们都继承自 Shape 基类，所以都能安全地向上转型为 Shape 类型。

Now, you can declare a generic function drawGraph() at the Shape class level.

现在，你可以在 Shape 类的层级声明一个通用函数 `drawGraph()`。

And implement it in shape-dot-cpp.

然后在 `shape.cpp` 里实现它。

The drawGraph() function simply loops over the Shape pointers in the graph array until it encounters a zero pointer.

`drawGraph()` 函数很简单：遍历图形数组里的 Shape 指针，直到遇到空指针为止。

The pivotal point of the implementation is the graph[i]->draw() call that employs polymorphism to correctly select the draw() implementation depending on the type of the object, not the type of the pointer, which is evidently Shape.

实现的关键在于 `graph[i]->draw()` 这个调用——它利用多态机制，根据对象的实际类型来正确选择 `draw()` 实现，而不是根据指针类型（显然是 Shape）。

Now, it's time to address the compilation warnings that the draw() and area() declarations in the Rectangle class implicitly inherit virtual.

现在来解决编译警告。警告说的是 Rectangle 类中 `draw()` 和 `area()` 的声明隐式继承了 virtual。

The warnings appeared after adding the "virtual" keywords in the Shape base class and as you saw in the debugger, this has turned on polymorphism with respect to the draw() and area() operations.

这些警告是在 Shape 基类加上 "virtual" 关键字之后出现的。你在调试器里也看到了，这开启了 `draw()` 和 `area()` 操作的多态性。

But, polymorphism means that the draw() and area() operations in Rectangle are not completely new operations added in that subclass. Instead, they are merely different forms (or different *methods*) of the draw() and area() operations specified already in the Shape base class and inherited from it.

多态意味着 Rectangle 中的 `draw()` 和 `area()` 操作并不是子类里新增的全新操作——它们只是 Shape 基类中已经定义并继承下来的 `draw()` 和 `area()` 操作的不同形态（或者说不同的**方法**（method））。

So, to introduce some object-oriented terminology here: *methods* describe the different forms of the same operation and the different methods in the subclasses are said to *override* the original method inherited from the base class.

引入一些面向对象的术语：**方法**（method）描述的是同一个操作的不同形态；子类中不同的方法被称为**覆写**（override）了从基类继承来的原始方法。

But going back to the code, the compiler noticed that the draw() and area() operations in Rectangle are just different methods of the operations already declared in the Shape base class. As different methods of the same operation they are automatically virtual, meaning polymorphic, so the compiler strongly suggests to make these methods explicitly virtual.

回到代码，编译器注意到 Rectangle 中的 `draw()` 和 `area()` 操作只是 Shape 基类中已声明操作的不同方法。既然是同一个操作的不同方法，它们自动就是 virtual 的、也就是多态的，所以编译器强烈建议你显式加上 virtual 关键字。

And indeed, adding the keyword virtual to the draw() and area() declarations in the Rectangle subclass gets rid of the warnings.

确实，在 Rectangle 子类的 `draw()` 和 `area()` 声明前加上 virtual 关键字，警告就消失了。

OK, so with this out of the way, I'm sure you are interested how your high-level drawGraph() function will perform, so let's quickly test in main-dot-cpp.

好了，这个问题解决了。接下来你肯定想知道高层级的 `drawGraph()` 函数跑起来效果如何，那我们到 `main.cpp` 里快速测试一下。

First, declare an array of Shape pointers, which could be const, and initialize it with, say: pointer to the Rectangle r1 and the pointer to dynamically allocated Shape ps3. You need to terminate the array with a zero pointer.

首先声明一个 Shape 指针数组（可以加 const），用以下内容初始化：指向 Rectangle r1 的指针和指向动态分配的 Shape ps3 的指针。数组末尾要用空指针来终止。

Now, you can simply call the drawGraph() function on this graph array.

然后直接对这个图形数组调用 `drawGraph()` 函数就行了。

The project builds cleanly, so let's move the breakpoint to the drawGraph() function and open the debugger.

项目编译干净。把断点设到 `drawGraph()` 函数，打开调试器。

When you step into the drawGraph() implementation, you can see that the first graph[i]->draw() operation invokes the Rectangle::draw() method for r1 as the "this" pointer.

单步进入 `drawGraph()` 的实现，你会看到第一个 `graph[i]->draw()` 操作调用的是 `Rectangle::draw()` 方法，"this" 指针指向 r1。

The next graph[i]->draw() operation invokes the Shape::draw() method for ps3 as the "this" pointer.

下一个 `graph[i]->draw()` 操作调用的是 `Shape::draw()` 方法，"this" 指针指向 ps3。

Then the loop finds the zero-pointer and terminates.

然后循环遇到空指针，结束。

So, as you can see, the drawGraph() function does exactly what it was supposed to do in a very simple and intuitive way.

如你所见，`drawGraph()` 函数以非常简单直观的方式完成了它该做的事情。

But, to let you fully appreciate the extensibility of the design based on polymorphism, let's create another subclass of Shape, such as Circle.

为了让你充分感受基于多态的设计有多强的**可扩展性**（extensibility），我们再来创建一个 Shape 的子类，比如 Circle。

The Circle subclass is similar to Rectangle, so let's just copy rectangle.h and rectangle.cpp and rename to circle.h and circle.cpp, respectively.

Circle 子类跟 Rectangle 很像，所以直接复制 `rectangle.h` 和 `rectangle.cpp`，分别改名为 `circle.h` 和 `circle.cpp`。

Quickly add the new circle files to the project and adapt them. In the header file, simply rename the inclusion guards and the class name.

把新的 circle 文件加到项目里，稍作修改。头文件里改一下包含保护和类名就行。

The change in attributes is to replace width and height with radius of a circle.

属性方面，把宽度和高度换成圆的半径。

The Circle constructor takes r0 as the initial value of the radius.

Circle 的构造函数接受 `r0` 作为半径的初始值。

The Circle class also needs to provide its own specialized methods for the draw() and area() operations inherited from Shape, so the virtual declarations stay the same.

Circle 类也需要为从 Shape 继承的 `draw()` 和 `area()` 操作提供自己专门的实现，所以 virtual 声明保持不变。

Now, in the implementation, you include "circle.h" and again replace the class name.

在实现文件中，包含 `"circle.h"`，再把类名替换一下。

The constructor takes the r0 parameter and uses it to initialize the radius attribute.

构造函数接收 `r0` 参数，用它来初始化 radius 属性。

The Circle's method for the draw() operation will call the primitive drawEllipse() function.

Circle 的 `draw()` 方法会调用底层的 `drawEllipse()` 函数。

Finally, the Circle's method for the area() operation will calculate the area of the circle as pi times radius squared. For simplicity here, I will use only integer math and I'll approximate the pi to three.

最后，Circle 的 `area()` 方法计算圆的面积：pi 乘以半径的平方。为简单起见，这里只用整数运算，pi 就近似取 3。

With the Circle class complete, the last step is to test it in main-dot-cpp.

Circle 类写好了，最后一步在 `main.cpp` 里测试。

You include circle-dot-h header file and instantiate a Circle object c1 with the given values for x, y, and the radius. Then you add pointer to c1 to the graph array so that the Circle c1 becomes part of the graph subsequently drawn by the drawGraph() function.

包含 `circle.h` 头文件，用给定的 x、y 和半径值实例化一个 Circle 对象 c1。然后把指向 c1 的指针加到图形数组里，这样 Circle c1 就成了后续 `drawGraph()` 函数要绘制的图形的一部分。

When you build the project, please note that only circle-dot-cpp and main-dot-cpp have been re-compiled. But specifically, shape-dot-cpp with the drawGraph() algorithm has NOT been recompiled. This means that the final image in this case uses the drawGraph() implementation compiled before introducing the Circle class.

构建项目的时候请注意：只有 `circle.cpp` 和 `main.cpp` 被重新编译了。关键是，包含 `drawGraph()` 算法的 `shape.cpp` **没有**被重新编译。也就是说，最终烧录的映像用的还是引入 Circle 类之前就编译好的 `drawGraph()` 实现。

When you run the program now and step into the drawGraph() function, you can see that it calls the correct Circle::draw() method for your c1 object as the "this" pointer.

现在运行程序，单步进入 `drawGraph()` 函数，你会看到它正确地调用了 `Circle::draw()` 方法，"this" 指针指向你的 c1 对象。

The other graph[i]->draw virtual calls invoke the correct methods for the Rectangle r1 and Shape ps3.

其他的 `graph[i]->draw()` 虚调用也分别正确地调用了 Rectangle r1 和 Shape ps3 对应的方法。

So, as you can see, all this still works as expected. But wait a minute, the drawGraph() function has been written and compiled before the Circle class even existed. Yet, the algorithm automatically adapted and recognized the newly added class.

看到没？一切照常工作。但等等——`drawGraph()` 函数是在 Circle 类根本还不存在的时候写好并编译的，可算法却自动适应并识别了新加的类。

I hope this shows you the power and *extensibility* of polymorphism, but also that the virtual call mechanism must be quite different than the regular function call.

希望这让你体会到了多态的强大和**可扩展性**，同时也说明了虚调用机制跟普通函数调用肯定有很大的不同。

So, let's now see how virtual call really works. For this, let's add a regular function call right before the virtual call to compare the two.

那我们就来看看虚调用到底是怎么工作的。为了对比，在虚调用之前加一个普通的函数调用。

Please note that an operation invoked on a full object, like the Rectangle r1, is always a regular, non-virtual function call, even though the operation itself might be declared virtual. This is because the exact type of the object is known at compile time. Incidentally, the connection between the function call and function body is called "call binding".

注意，在完整对象（比如 Rectangle r1）上调用的操作，永远是普通的非虚函数调用，即使操作本身声明了 virtual 也一样。因为编译时就已经知道对象的确切类型了。顺便说一下，函数调用和函数体之间的关联叫做"**调用绑定**"（call binding）。

The connection established at compile and link time is called "early binding". This is the only call binding used in the procedural languages like C.

在编译和链接阶段就确定下来的绑定叫做"**早期绑定**"（early binding）。C 这种过程式语言只支持这一种绑定方式。

But in C++, a virtual operation invoked on a pointer, like ps here, establishes a different call binding, because the exact type of the object is not known at compile time since the pointer might be actually upcast from a derived class. This type of binding is called "late binding", "dynamic binding", or "real-time binding".

但在 C++ 中，通过指针（比如这里的 ps）调用虚操作时，用的是另一种绑定方式——因为编译时不知道对象的确切类型，指针可能是从某个派生类向上转型来的。这种绑定叫做"**后期绑定**"（late binding），也叫"动态绑定"（dynamic binding）或"实时绑定"（real-time binding）。

All right, so let's build the project and move the breakpoint to the early binding call to finally see how it compares and differs from the "late binding".

好，构建项目，把断点设到早期绑定调用那里，来跟后期绑定做个对比。

When you launch the debugger and continue to your breakpoint, in the disassembly view you can see that the early binding call consist of moving the value of the "this" pointer into R0 and then using the Branch with Link, BL-instruction, to call the Rectangle::draw() function hardcoded in the BL instruction itself.

启动调试器，运行到断点处。在反汇编视图中可以看到，早期绑定调用就是两步：先把 "this" 指针的值放入 R0，然后用**带链接的分支指令**（BL 指令）调用 `Rectangle::draw()` 函数——函数地址直接硬编码在 BL 指令里。

And indeed, when you step into the BL instruction, you end up in Rectangle::draw() function body. While you are at it, notice the address of this function in ROM, which is hex-250C.

确实，单步进入 BL 指令后，你就到了 `Rectangle::draw()` 的函数体。顺便记一下这个函数在 ROM 中的地址：十六进制的 0x250C。

Now, when you return back to main-dot-cpp, you can see that the late-binding machine code is significantly different than the early binding right before it.

回到 `main.cpp`，你会看到后期绑定生成的机器代码跟前面的早期绑定完全不一样。

It all starts with loading a 32-bit word from R6, which is later used as the "this" pointer in R0, so this 32-bit word must be coming from the "this" object.

它先从 R6 指向的位置加载一个 32 位字，这个字后来被用作 R0 中的 "this" 指针——也就是说这个 32 位字一定来自 "this" 对象本身。

This word is subsequently used as the base address, so the word from the "this" object is a pointer itself.

这个字随后被用作基地址，所以来自 "this" 对象的这个字本身就是一个指针。

But wait a minute, *you* certainly didn't add any pointer attributes to the Shape or Rectangle classes.

但等等，你肯定没有给 Shape 或 Rectangle 类添加过任何指针属性啊。

So, let's take a closer look at the "this" pointer in RAM.

来看看 RAM 中 "this" 指针指向的内容。

And indeed, you can recognize the 16-bit attributes x, and y, inherited from Shape as well as width and height added in Rectangle. But now all this is preceded by a pointer which apparently was added by the C++ compiler when you introduced virtual functions in the Shape base class. So the overall size of the Rectangle object is now enlarged by a pointer.

确实能认出来：从 Shape 继承的 16 位属性 x、y，以及 Rectangle 中添加的 width 和 height。但现在这些属性前面多了一个指针——显然是你引入虚函数后 C++ 编译器偷偷加上去的。于是 Rectangle 对象的总大小就多了一个指针的长度。

Now, regarding the added pointer inside the Rectangle object, it looks like an address in ROM, so let's see this ROM address in the memory view.

关于 Rectangle 对象里多出来的这个指针，它看起来像是 ROM 中的地址。在内存视图中看看这个 ROM 地址。

When you change the memory view to 32-bit quantities, I hope you can recognize that the first word at the ROM address is suspiciously similar to the hex-250C, which was the address of the Rectangle::draw() function. In fact, it is this exact address plus one.

把内存视图切换到 32 位显示方式，你应该能看出来：ROM 地址处的第一个字跟刚才的 0x250C 非常像——实际上就是那个地址加一。

As I explained many times in the earlier lessons of this video course, the program addresses in Cortex-M are stored as odd numbers, because the least-significant bit is not used for addressing but rather is always set to one to represent the Thumb state of the CPU.

正如我在前面的课程中多次解释过的，Cortex-M 中的程序地址存储为奇数——因为最低有效位不用于寻址，而是始终设为 1，表示 CPU 处于 **Thumb 状态**。

So, in short, the first word at the ROM address is the Rectangle::draw() function address.

简单说，ROM 地址处的第一个字就是 `Rectangle::draw()` 函数的地址。

But what about the second word at the ROM address?

那 ROM 地址处的第二个字呢？

Well, let's look for it in the disassembly window, remembering to subtract one from the address, which means that you are looking for... hex-00002502.

在反汇编窗口里找一下，记得从地址减 1，所以你要找的是……十六进制的 0x00002502。

And indeed, this is the address of the Rectangle::area() method, which is the second virtual function of the Rectangle class.

确实，这是 `Rectangle::area()` 方法的地址——Rectangle 类的第二个虚函数。

All this reverse-engineering can be summarized as follows: The compiler has added a pointer at the beginning of the class attributes, which points to a table in ROM that contains addresses of all virtual functions.

所有这些逆向分析总结起来就是：编译器在类属性的开头偷偷加了一个指针，指向 ROM 中的一张表，表里存放着所有虚函数的地址。

In the literature, the table of virtual functions is called the VTABLE and the pointer to it stored in the object is called the VPTR.

在文献中，这张虚函数表叫做 **VTABLE**（虚表），对象中指向它的指针叫做 **VPTR**（虚指针）。

But, continuing with the debugging, you can see that the address of the Rectangle::draw() function is loaded from the VTABLE into R1 and finally the "this" pointer is setup in R0.

继续看调试过程：`Rectangle::draw()` 函数的地址从 VTABLE 加载到 R1，然后 "this" 指针设置到 R0 中。

The actual function call is performed by the Branch with Link and Exchange, BLX-R1 instruction, which jumps to the address provided in R1.

实际的函数调用由 **BLX R1** 指令完成——带链接和交换的分支指令，跳转到 R1 中存放的地址。

And indeed, when you step into the BLX instruction you end up in the Rectangle::draw() method. Here, when you examine the "this" pointer, you can actually see that the first attribute of the object slice inherited from Shape is the vptr.

确实，单步进入 BLX 指令后就到了 `Rectangle::draw()` 方法。在这里检查 "this" 指针，你能看到从 Shape 继承过来的对象切片的第一个属性就是 vptr。

So, in summary, compared to early binding, the overhead of late binding is the additional VPTR in every object in RAM, one VTABLE per class in ROM and two more instructions per function call.

总结一下：跟早期绑定相比，后期绑定的开销是 RAM 中每个对象多一个 VPTR、ROM 中每个类多一张 VTABLE、每次函数调用多两条指令。

This is not a large overhead for what you are getting, but still it is non-negligible and therefore C++ applies this mechanism only to functions specified explicitly as "virtual". This is to prevent the overhead for functions that don't need late binding. Other object-oriented languages, such as Java for example, treat polymorphism as such a fundamental feature that all functions are virtual by default.

相对于你获得的能力来说，开销不算大，但也不是可以忽略的。所以 C++ 只对显式声明为 "virtual" 的函数才启用这个机制，避免给不需要后期绑定的函数白白增加开销。其他面向对象语言（比如 Java）把多态视为如此基本的功能，以至于所有函数默认就是虚函数。

Also, please note that this VPTR-VTABLE double indirection is just one possible implementation of late binding and the C++ standard leaves it completely open to the compiler designers. Having said that, essentially all existing C++ implementations for wide range of CPUs use the VPTR-VTABLE implementation that you just saw.

另外要注意，VPTR-VTABLE 这种双重间接寻址只是后期绑定的一种可能实现方式，C++ 标准把具体实现完全交给了编译器设计者。话虽如此，目前几乎所有针对各种 CPU 的 C++ 实现用的都是你刚才看到的这种 VPTR-VTABLE 方案。

So, the last remaining question for today is: Who sets the VPTR?

那么今天的最后一个问题：VPTR 是谁设置的？

I mean, the constant VTABLE per class in ROM can be easily added just like the code itself, but the VPTR needs to be set in each and every instance of a class, which often are allocated at runtime, for example as automatic objects in functions.

ROM 中每个类的常量 VTABLE 跟代码一样，很容易加进去。但 VPTR 需要在每个对象实例中设置——这些实例往往是在运行时才分配的，比如函数中的自动变量。

I hope that at this point you can guess that the ideal place where the VPTR can be established is the class constructor.

我想你应该能猜到，设置 VPTR 的理想位置就是类的**构造函数**（constructor）。

But of course, *you* didn't do anything about VPTR in your C++ code, which means that the C++ compiler must have secretly synthesized some code to do this for you.

当然，你在 C++ 代码中并没有写任何关于 VPTR 的东西——这意味着 C++ 编译器一定偷偷生成了一些代码来替你完成这项工作。

As an embedded engineer, I'm sure you must be especially curious about any such secret code.

作为嵌入式工程师，你对这种偷偷生成的代码肯定特别好奇。

So let's set a breakpoint in the Rectangle constructor, for example, and start the debugger.

那就在 Rectangle 构造函数里设个断点，启动调试器。

The breakpoint is hit right away, because there is a statically allocated instance of Rectangle, which is initialized even before main.

断点立刻就命中了，因为有一个静态分配的 Rectangle 实例——它在 `main()` 之前就已经初始化了。

When you expand the "this" pointer, you can see that the vptr is still not initialized.

展开 "this" 指针看看，vptr 还没被初始化。

So step in, and you end up in the Shape's constructor, which is invoked from the Rectangle's constructor initializer list. The "this" pointer now changes type to Shape, but the vptr is still not initialized.

单步进入，你到了 Shape 的构造函数——它是从 Rectangle 的构造函数初始化列表中被调用的。"this" 指针的类型变成了 Shape，但 vptr 还是没初始化。

Now, looking at the disassembly, you can see two lines of machine code that apparently set the VPTR.

看反汇编，有两行机器代码显然是在设置 VPTR。

But wait a minute, which VTABLE is it pointing to?

但等等，它指向的是哪个 VTABLE？

Well, you can inspect the VTABLE in the memory view.

在内存视图里检查一下 VTABLE。

Take for example the second entry in the table and locate it in the disassembly.

比如看看表中的第二个条目，在反汇编中定位它。

As explained before, you need to subtract one from the address in VTABLE, so you are looking for hex-000024EA.

如前所述，VTABLE 中的地址要减 1，所以你要找的是十六进制的 0x000024EA。

And, you end up in Shape::area() method, which means that the VTABLE belongs to the Shape class.

你到达了 `Shape::area()` 方法——说明这个 VTABLE 属于 Shape 类。

So, at this stage of initialization the Rectangle instance is still treated as its Shape base class.

所以，在初始化的这个阶段，Rectangle 实例仍然被当作它的 Shape 基类来对待。

But let's continue stepping through the initialization of the Shape's attributes and return back to the Rectangle's constructor.

继续单步执行，完成 Shape 属性的初始化，然后回到 Rectangle 的构造函数。

Here, in disassembly, you encounter similar instructions that apparently re-initialize the VPTR to a different value.

在反汇编中，你又看到了类似的指令——显然是把 VPTR 重新初始化成了不同的值。

So again, let's find out from the memory view which VTABLE this is by inspecting its second entry.

再从内存视图看看这是哪个 VTABLE，同样检查第二个条目。

Now, you are looking for the address hex-00002502.

这次你要找的地址是十六进制的 0x00002502。

...and, you end up in Rectangle::area() method, which means that the VTABLE now belongs to the Rectangle class.

……你到达了 `Rectangle::area()` 方法——说明现在 VTABLE 属于 Rectangle 类了。

So, as you see, the VPTR is initialized and re-initialized in every constructor to point to the VTABLE of that class. But the order of constructor calls is such that the superclasses are always initialized before subclasses, so the VPTR ends up pointing to the last derived class, which is correct.

如你所见，VPTR 在每个构造函数中都会被初始化（或重新初始化），指向当前类的 VTABLE。而构造函数的调用顺序保证了父类总是在子类之前初始化，所以 VPTR 最终指向的是最末端的派生类——这正是正确的结果。

This concludes this quick look at polymorphism in C++. In the next lesson, you will put your understanding of virtual functions to the test by implementing late binding in C.

关于 C++ 中多态的介绍就到这里。下一课，你要在 C 中亲手实现后期绑定——检验一下你对虚函数的理解到底有多到位。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Polymorphism | 多态 | 来自希腊语"poly"（多）+"morphe"（形态），指同一操作可根据对象类型呈现不同行为 |
| Virtual function | 虚函数 | C++ 中用 `virtual` 关键字声明的函数，支持后期绑定 |
| Override | 覆写 | 子类提供与基类虚函数同名同签名的新实现 |
| Method | 方法 | OOP 中描述同一操作的不同形态的术语，特指与特定类关联的函数 |
| Interface | 接口 | 操作的声明（"可以做什么"），与实现（"如何做"）分离 |
| VTABLE (Virtual Table) | 虚表 | 编译器在 ROM 中为每个含虚函数的类生成的表，存储虚函数地址 |
| VPTR (Virtual Pointer) | 虚指针 | 编译器在每个对象中添加的隐藏指针，指向该类的 VTABLE |
| Early binding | 早期绑定 | 编译/链接时确定调用的函数地址，C 语言只支持这种方式 |
| Late binding / Dynamic binding | 后期绑定 / 动态绑定 | 运行时通过 VTABLE 查找确定调用的函数地址，C++ 通过虚函数实现 |
| Call binding | 调用绑定 | 函数调用与函数体之间的关联方式 |
| Upcasting | 向上转型 | 将派生类指针/引用转换为基类类型，总是安全的 |
| Extensibility | 可扩展性 | 多态的核心优势——新类可以无缝接入已有框架而无需修改现有代码 |
| BL instruction | BL 指令 | ARM 的带链接分支指令（Branch with Link），用于直接函数调用 |
| BLX instruction | BLX 指令 | ARM 的带链接和交换的分支指令（Branch with Link and Exchange），用于间接函数调用 |
| Thumb state | Thumb 状态 | ARM Cortex-M 使用 Thumb 指令集，函数地址的最低位始终为 1 以表示 Thumb 状态 |
| Constructor initializer list | 构造函数初始化列表 | C++ 中初始化基类和成员变量的特殊语法 |
