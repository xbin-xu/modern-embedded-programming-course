# 第32课：用标准 C 实现多态 / Lesson 32: Polymorphism in Portable, Standard-Compliant C

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I'll continue with OOP and polymorphism, but this time you will see how to implement polymorphism in portable, standard-compliant C code. This should reinforce what you've learned about virtual functions in C++ in the last lesson and expose some additional nuances of the VPTR-VTABLE implementation. This lesson will also provide some general principles and guidelines about using object-oriented programming in embedded software.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，这节课我们继续聊面向对象编程（OOP）和多态（polymorphism）——不过这次，你将看到如何用可移植、符合标准的 C 代码来实现多态。这会让你对上一课学到的 C++ 虚函数（virtual function）理解得更扎实，还会揭示 VPTR-VTABLE 实现中一些更深层的细节。本课还会给出在嵌入式软件中使用 OOP 的一些通用原则和指导。

By the way, this is a very round lesson number hex-20, which coincides with the even more round number of subscribers to the Quantum Leaps video channel, which is about to cross hex-8000 or 2-to-15-th. I'd like to thank you all for your help in reaching these fantastic milestones.

顺便说一下，本课编号是 0x20，一个很整的十六进制数，刚好 Quantum Leaps 视频频道的订阅数也即将突破 0x8000——也就是 2 的 15 次方。感谢大家帮忙达成了这些了不起的里程碑。

As usual, let's get started by copying the previous lesson30--the C version without the underscore-CPP suffix, to lesson32. Get inside the new lesson32 directory and double-click on the project lesson to open it in the micro-Vision IDE.

跟往常一样，先把上一课（第30课，不带 `_CPP` 后缀的 C 版本）复制一份作为 lesson32。进到新的 lesson32 目录，双击项目文件，在 micro-Vision IDE 里打开它。

To remind you quickly what happened so far, in the last lesson, you learned about the OOP concept of polymorphism, which is the ability to provide different methods for the same inherited operation in the subclasses of a given class.

快速回顾一下：上一课你学了 OOP 中的多态概念——就是同一个继承操作，在不同的子类里可以有不同的实现。

Specifically, you saw how polymorphism is implemented in C++ by means of virtual functions and you have reverse-engineered the late-binding mechanism, where the specific method for a given operation is resolved at runtime based on the type of the object, not the type of the pointer used in the call.

具体来说，你看到了 C++ 如何通过虚函数来实现多态，还逆向分析了**后期绑定**（late binding）机制——也就是根据对象的实际类型（而不是调用时指针的类型）在运行时决定到底调用哪个方法。

But before you go any further, from the last lesson it should be clear that unlike class encapsulation and single inheritance, which were essentially free in C, polymorphism in C will add coding complexity and overhead. Therefore, if you intend to use polymorphism extensively, you would be probably better off by switching to C++.

不过在继续之前，上一课你应该已经看清了一点：类的封装和单继承在 C 中几乎零成本，但多态就不同了——它会增加编码复杂度和运行开销。所以如果你打算大量使用多态，最好还是切换到 C++。

However, if you build or use software libraries (such as the QP/C real-time framework), the complexities of polymorphism in C can be confined to the library and can be effectively hidden from the application developers.

但话说回来，如果你是构建或使用软件库（比如 QP/C 实时框架），那多态在 C 中的复杂性可以被封装在库内部，对应用开发者完全屏蔽。

But either way, this lesson's primary goal is to show you how things really work under the hood, which should help you to use polymorphism more efficiently and with greater confidence in any language.

不过无论如何，本课的主要目标是带你搞清楚底层到底是怎么运作的——弄明白之后，不管用什么语言，你都能更高效、更有底气地使用多态。

So, today you will implement the virtual functions manually in C following exactly the C++ VPTR-VTABLE design.

所以今天，你将严格按照 C++ 的 VPTR-VTABLE 设计，在 C 中手动实现虚函数。

For this, you need to explicitly add the VPTR to the attribute structure of the Shape base class.

为此，你需要把 VPTR 显式地加到 Shape 基类的属性结构里。

The VPTR will be the first attribute, and will be a pointer to the 'const' ShapeVtable structure. This 'const' will allow the VTABLE to reside in ROM.

VPTR 作为第一个属性，是一个指向 `const` `ShapeVtable` 结构的指针。这个 `const` 让 VTABLE 可以放在 ROM 里。

Please note that at this point you have not provided the declaration of the ShapeVtable struct just yet. But here you are using only a *pointer* to this struct, which the compiler accepts, because all it needs to know for processing the Shape attribute structure is the size of the pointer, which is known, not the size of the whole VTable.

注意，此时你还没有声明 `ShapeVtable` 结构体。不过这里你只用了一个指向该结构体的*指针*，编译器完全可以接受——因为它处理 Shape 属性结构时只需要知道指针的大小就行了，这是已知的，不需要知道整个 VTable 有多大。

But now, you obviously need to declare the VTABLE, which even though it's called a "Table", is typically not implemented as an array but rather as a structure of pointers to all *virtual* functions, such as draw() and area() in the case of the Shape class.

现在显然需要声明 VTABLE 了。虽然名字里有个"Table"，但它通常不是用数组实现的，而是一个结构体——里面放了一组指向所有*虚函数*的指针，比如 Shape 类中的 `draw()` 和 `area()`。

I used pointers to functions in this video course before, but today is the time to introduce them a bit more carefully.

在之前的课程中我用过函数指针，但今天得好好介绍一下。

So, the C language allows you to provide a pointer to a function, just like you can provide a pointer to a variable. In both cases, a pointer contains the address (of the function or variable, respectively) and also the type information about the entity that is being pointed to.

C 语言允许你用指针指向函数，就跟指向变量一样。两种情况下，指针里面都保存了地址（函数地址或变量地址），同时也携带了所指向实体的类型信息。

In case of pointers to functions, the type information consist of the full signature of the function.

对于函数指针来说，类型信息就是函数的完整签名（signature）。

So, to declare a pointer to the draw() function, you first need to write the signature of this function. And then, you need to convert the actual name of the function into a pointer, which means using the asterisk operator. But because of the specific operator precedence rules in C, the asterisk would be bound to the return value instead of the function name, so you need to add explicit parentheses around the pointer, like this.

所以要声明一个指向 `draw()` 函数的指针，你先把函数签名写出来，然后把函数名变成指针——也就是加上星号。但 C 语言的运算符优先级有个坑：星号会先绑定到返回值而不是函数名上。所以你必须给指针加上括号，像这样。

You apply the exact same steps to declare a pointer to the area() function.

声明指向 `area()` 函数的指针，步骤完全一样。

OK, so the VPTR and VTABLE are both declared, but now the users of the Shape class as well as its subclasses must be able to call the virtual functions.

好了，VPTR 和 VTABLE 都声明好了，但现在 Shape 类及其子类的使用者还得能调用这些虚函数才行。

You can provide this virtual call functionality, also known as late binding, in a few different ways.

有几种方式可以提供这种虚调用功能（也就是后期绑定）。

First, you can provide member functions for that, just like all the other operations of the Shape class. Specifically, you can take the draw() method signature and turn it into the Shape_draw_vcall() function. Similarly, you can take the area() method signature and turn it into the Shape_area_vcall() member function.

第一种方式是提供成员函数，跟 Shape 类的其他操作一样。具体来说，把 `draw()` 方法的签名改造成 `Shape_draw_vcall()` 函数，类似地，把 `area()` 改造成 `Shape_area_vcall()` 成员函数。

The implementation of these virtual call functions goes to the shape.c file.

这些虚调用函数的实现放在 `shape.c` 文件里。

Here, in the Shape_draw_vcall() function you first get from the "me" pointer to the vptr. Next, you get from the vptr to the specific pointer to function, such as draw. And finally, you need to provide the parameters of the call, which include the "me" pointer and potentially other parameters included in the signature of the function.

在 `Shape_draw_vcall()` 函数里，你先从 `me` 指针取到 vptr，再从 vptr 取到具体的函数指针（比如 draw）。最后传入调用参数——包括 `me` 指针，以及函数签名中可能有的其他参数。

You repeat the exact same steps for the Shape_area_vcall() function, except that this function returns a value, so you need to add the return statement in front.

`Shape_area_vcall()` 的做法完全一样，只是它有返回值，所以前面要加个 `return`。

As you can see, the C compiler accepts this syntax without complaints, because the presence of the parameter list following the pointer to function tells the compiler that this is a function call based on this pointer-to-function.

可以看到，C 编译器对这种语法毫无异议，因为函数指针后面跟了参数列表，编译器就知道这是通过函数指针发起的函数调用。

However, this syntax fails to show you that you are de-referencing a pointer and I prefer to be very explicit about it. Therefore I prefer the alternative syntax analogous to de-referencing any other pointer, that is, with the asterisk in front. Of course, again, just like in the declaration of a pointer-to-function, you need to use parentheses around the pointer.

不过这种写法看不出你在解引用一个指针，我更喜欢把事情说清楚。所以我倾向另一种写法——像解引用其他指针一样在前面加星号。当然，跟声明函数指针时一样，星号要加括号。

As you see, the compiler accepts this version just as well. But, either way, the most important point here is that the "me" pointer is used *twice*: once to find the VPTR within the object, so that the call is specific to the object, not to the type of the "me" pointer; and the second time the "me" pointer is used as the usual first parameter of a member function.

编译器同样接受这种写法。但不管哪种写法，最关键的一点是：`me` 指针被使用了*两次*。第一次用于从对象中找到 VPTR，这样调用就绑定到了具体对象上，而不是 `me` 指针的类型上；第二次是作为成员函数的第一个参数正常传入。

So, this is the first clean and straightforward solution that will work. But it has a big drawback, and that is the additional function-call overhead to call the invented vcall() functions.

这是第一个干净利落的可行方案。但它有个大缺点——调用这些额外的 `vcall()` 函数会带来额外的函数调用开销。

But, the good news is that the newer C99 language standard allows you to avoid this overhead, by using the "inline" functions introduced exactly for this purpose.

好消息是，C99 标准引入了 `inline` 函数，正好可以解决这个问题，避免额外开销。

To make the functions inline, you move the whole definitions of the functions into the header file and you add the keywords inline and static in front.

要变成内联函数，你需要把整个函数定义搬到头文件里，前面加上 `inline` 和 `static` 关键字。

The discussion as to why it is a good idea to use both inline and static is a bit lengthy and I'm going to leave it for another day, as it is off topic for today.

为什么同时用 `inline` 和 `static` 是个好做法，这个话题说来话长，而且跟今天的主线无关，就先不展开了。

But now, when you try to compile this code it fails, because as it turns out, this compiler still works in the older C89 mode and does not recognize the "inline" keyword.

但现在编译会失败——因为这个编译器还在用老版的 C89 模式，不认识 `inline` 关键字。

You can remedy this, by opening the Project Options dialog box, and going to the C/C++ tab, where you can tick the box next to C99 Mode.

解决办法是打开 Project Options 对话框，进到 C/C++ 选项卡，勾选 C99 Mode。

As you can see, this triggers the complete re-compilation of the whole project, but this time the code builds cleanly.

可以看到，这会触发整个项目的完全重编译，但这次编译通过了。

While the inline implementation of the virtual call mechanism is the preferred way, for completeness I'd like to mention the third implementation option based on preprocessor macros, which will look as follows:

内联函数是虚调用机制的首选实现方式。不过为了完整性，我再提一下第三种方案——用预处理器宏（macro）来实现，大概长这样：

You take the function definition and turn it into a macro by stripping away most of the type information. This is because macros provide only purely textual substitutions. Therefore, to avoid any surprises, when for instance the client code would use expressions for the macro parameters, it's always a good idea to enclose the macro parameters, like the "me" pointer here in additional set of parentheses.

做法是把函数定义变成宏，去掉大部分类型信息。因为宏只是纯文本替换。所以为了避免意外——比如调用方传入表达式作为参数——最好把宏参数（比如这里的 `me` 指针）用括号包起来。

For all these reasons, macros are not nearly as good as inline functions. But I still show you the macros, because they are the only low-overhead option for the older C89 compilers, which are still in extensive use.

由于这些原因，宏远不如内联函数好用。但我还是展示了宏的写法，因为老版本的 C89 编译器仍在广泛使用，而宏是它们唯一的低开销选择。

Alright, so you've seen how to define and how to de-reference pointers to functions, but you are not quite out of the woods yet with your virtual functions in C.

好了，你已经看到了如何定义和解引用函数指针，但在 C 中搞虚函数的工作还没完。

You still need to somehow define the VTABLE in ROM and also you need to setup the VPTR in each instance of the Shape class and its subclasses.

你还得想办法在 ROM 中定义 VTABLE，并且要在 Shape 类及其子类的每个实例中设置好 VPTR。

As you remember from the reverse-engineered C++ implementation from the last lesson, the VPTR and VTABLE setup occurs in the constructor, so that's where you need to go next.

上一课逆向分析 C++ 实现的时候你应该还记得，VPTR 和 VTABLE 的设置是在构造函数里完成的，所以接下来就去看构造函数。

Here, you need to define an instance of the struct ShapeVtable in ROM, meaning that it will be both "static", that is not on the stack, and "const".

在这里，你要在 ROM 中定义一个 `struct ShapeVtable` 的实例——也就是说它既是 `static`（不在栈上），又是 `const`。

Now, a "const" object cannot be changed, so you must immediately initialize at the point of creation.

`const` 对象不能修改，所以必须在定义的同时就初始化。

But before you can initialize the vtable, you need to provide the functions, with which to initialize the draw and area pointers-to-functions in your VTABLE.

不过在初始化 VTABLE 之前，你得先准备好用来初始化 `draw` 和 `area` 函数指针的函数。

So, let's provide the prototypes for the functions: Shape_draw() and Shape_area(). You can make these functions static, because they will be only used locally inside the shape.c module.

先提供函数原型：`Shape_draw()` 和 `Shape_area()`。这两个函数可以声明为 `static`，因为它们只在 `shape.c` 模块内部使用。

So, now you can finally initialize your vtable instance, whereas you can choose between the two options of the syntax.

现在终于可以初始化 VTABLE 实例了。语法上有两种选择。

First, you can directly use the function names. The compiler will accept this, because the absence of parentheses after the function names means that these are not function calls but rather addresses of the functions.

第一种是直接写函数名。编译器能接受，因为函数名后面没跟括号，说明这不是函数调用，而是取函数地址。

However, I prefer the alternative syntax, in which you explicitly use the ampersands, that is address-of operators, to leave absolutely no doubt that here you mean addresses of the functions.

不过我更倾向另一种写法——显式用 `&`（取地址运算符），这样一眼就知道这里取的是函数地址，毫无歧义。

So, now, you can setup the vptr in the newly constructed Shape object to point to the vtable for the Shape class. And finally, you need to define the Shape_draw() and Shape_area() functions.

好了，现在可以把新创建的 Shape 对象里的 VPTR 指向 Shape 类的 VTABLE 了。最后，还得实现 `Shape_draw()` 和 `Shape_area()` 函数。

Interestingly, at the level of the Shape class, you cannot really provide meaningful implementations, because Shape is too abstract. So, for now you just leave the functions empty, but to avoid compiler warnings about unused parameters, you can use the idiom of casting the unused parameter on void.

有意思的是，在 Shape 类这个层面上，你其实没法提供有意义的实现——因为 Shape 太抽象了。所以现在函数体先空着，但为了避免编译器对未使用参数发出警告，可以用 `(void)` 转换这个惯用法。

At this point, you are done with the general virtual function machinery in the Shape base class, and you can immediately put it to good use by writing the generic drawGraph() operation discussed in the last lesson.

到这里，Shape 基类中通用的虚函数机制就搞定了。你可以马上把它用起来——实现上一课讨论过的通用 `drawGraph()` 操作。

So, here is the C++ code from lesson 31, where an array graph[] holds pointers to Shape, but these pointers actually point to subclasses of Shape, such as Rectangle, Circle or Triangle. The central point here is that this C++ code applies polymorphism to call the specific draw() method for each Shape pointer in the graph array in a very intuitive and elegant way.

这是第31课的 C++ 代码。`graph[]` 数组里存的是指向 Shape 的指针，但它们实际指向的是 Shape 的子类——Rectangle、Circle 或 Triangle。关键在于，C++ 用非常直观优雅的方式实现了多态：对 `graph` 数组中的每个 Shape 指针，自动调用对应的 `draw()` 方法。

So, now your job is to do the same in C, using the virtual call mechanism you just implemented.

现在你的任务就是在 C 中用刚实现的虚调用机制做同样的事情。

Well, it's actually very similar to the C++ version. The only difference now is that you use the Shape_draw_vcall() inline function to apply polymorphism.

其实跟 C++ 版本非常像。唯一的区别是你现在用 `Shape_draw_vcall()` 内联函数来应用多态。

So, this is all there is to it, except that you obviously still need to provide the prototype of the drawGraph() operation in the shape.h header file.

就这么简单。当然，你还得在 `shape.h` 头文件里加上 `drawGraph()` 的函数原型。

OK, the Shape base class is done, but some work is still needed in the subclasses of Shape, like Rectangle or Circle.

好，Shape 基类搞定了，但 Shape 的子类（比如 Rectangle、Circle）还得做些工作。

They will all inherit the VPTR and the virtual call mechanism from Shape. But, each subclass, like Rectangle, still needs to provide its own VTABLE and its own specific implementation of the virtual functions draw() and area(). This was the main purpose of polymorphism.

它们都会从 Shape 继承 VPTR 和虚调用机制。但每个子类（比如 Rectangle）还需要提供自己的 VTABLE，以及 `draw()` 和 `area()` 的具体实现。这正是多态的核心意义。

So, let's do it now for the Rectangle subclass of Shape. You need to go to rectangle.c and pretty much repeat the steps you did for the Shape base class. So first, you add the static and const virtual table inside the Rectangle constructor.

现在来处理 Shape 的 Rectangle 子类。进到 `rectangle.c`，基本重复你给 Shape 基类做过的步骤。首先，在 Rectangle 构造函数内部定义 static const 的虚函数表。

At this point, I presume that Rectangle does not add any new virtual functions to the ones already specified in the Shape superclass. In that case, Rectangle can use the ShapeVtable structure directly. Otherwise, you would need to apply inheritance in C with respect to VTABLES, but let's keep it simple here and not add any new virtual functions in Rectangle.

这里我假设 Rectangle 不会在 Shape 超类已定义的虚函数之外再添加新的虚函数。这样 Rectangle 就可以直接使用 `ShapeVtable` 结构。否则的话，你还得在 C 中处理 VTABLE 的继承——不过为了简单起见，这里不给 Rectangle 加新虚函数。

So, back to the initialization of the VTABLE, instead of Shape's methods, the Rectangle VTABLE will obviously contain the Rectangle's implementations.

回到 VTABLE 的初始化——Rectangle 的 VTABLE 里放的当然是 Rectangle 自己的实现，而不是 Shape 的。

But now, Rectangle already provides its own Rectangle_draw() and Rectangle_area() functions. The problem is that the "me" pointers in the signatures of the Rectangle implementations are of type "Rectangle", while the pointers-to-functions in the Shape's VTABLE have signatures that expect "me" pointers of type Shape. Because remember, that even though Rectangle and Shape are related by inheritance, the C compiler doesn't know about it and will not perform upcasting automatically.

但问题来了：Rectangle 已经有了自己的 `Rectangle_draw()` 和 `Rectangle_area()` 函数，可它们签名中的 `me` 指针类型是 `Rectangle`，而 Shape VTABLE 中的函数指针签名期望的是 `Shape` 类型的 `me`。记住，虽然 Rectangle 和 Shape 通过继承关联，但 C 编译器并不知道这一点，不会自动帮你做**向上转型**（upcasting）。

So, to make the Rectangle signatures fit into the VTABLE originally defined for the Shape base class, you need to cast pointer-to-functions, by using the whole function signatures, like this.

所以，要让 Rectangle 的函数签名塞进为 Shape 基类定义的 VTABLE 里，你需要对函数指针做强制类型转换——用完整的函数签名来转，像这样。

Only now, you can finally assign the inherited VPTR for the Rectangle class, but you need to be very careful to do it *after* calling the constructor of the Shape superclass. This is because, just like in C++, the Shape constructor sets the VPTR to point to the Shape's VTABLE, but here you want to override this setting to the Rectangle's VTABLE.

现在你才能设置 Rectangle 类继承来的 VPTR——但一定要小心，必须在调用 Shape 超类构造函数*之后*再做。因为跟 C++ 一样，Shape 构造函数会把 VPTR 指向 Shape 的 VTABLE，而你要把它覆盖成 Rectangle 的 VTABLE。

And this is all, because rectangle.c already contains the implementations of the Rectangle_draw() and Rectangle_area() functions.

到这里就完成了，因为 `rectangle.c` 中已经有了 `Rectangle_draw()` 和 `Rectangle_area()` 的实现。

The very final touch, which will allow you to test all this in the debugger, is to call the generic drawGraph() operation that makes use of the virtual call mechanism.

最后一步——调用使用虚调用机制的通用 `drawGraph()` 操作，这样就能在调试器里测试了。

For this, you can open the C++ code from the last lesson and copy the relevant snippet to your main.c file. In the C version, you need to setup the graph array of pointers slightly differently, because you don't have the Circle class in C, so let's use the s1 Shape object instead. Also, instead of creating a Shape object dynamically, let's create a Rectangle object. Then, of course you need to call the right constructor on it as well. So this is about it, but to make the C compiler happy, you still need to add an explicit cast in the Rectangle constructor and in the initialization of the graph[] array of pointers.

你可以打开上一课的 C++ 代码，把相关片段复制到 `main.c` 里。在 C 版本中，指针数组 `graph` 的设置稍有不同——因为 C 中没有 Circle 类，就用 s1 这个 Shape 对象代替。另外，不动态创建 Shape 对象，而是创建一个 Rectangle 对象，然后对它调用正确的构造函数。大致就这样，但 C 编译器还需要你在 Rectangle 构造函数和 `graph[]` 指针数组初始化中加上显式类型转换。

Alright, so you got the code to build cleanly. Now I'm sure you are curious how all this will work in a real embedded board.

好了，代码编译通过了。现在我猜你一定很好奇，这一切在真正的嵌入式开发板上会怎么跑。

So, let's connect the TivaC LaunchPad board and open the debugger. The first thing I'd like you to verify is the Rectangle constructor. When you step inside, the first code you see is the call to the Shape constructor of the superclass.

连上 TivaC LaunchPad 开发板，打开调试器。首先验证的是 Rectangle 构造函数。单步进去，你看到的第一行代码是调用超类的 Shape 构造函数。

Let's step inside again and verify that the VPTR is initially not set, but gets initialized to the Shape VTABLE containing addresses of Shape_draw and Shape_area functions. Also, please note that the VTABLE is definitely in ROM, because its address starts with zeros.

继续单步进去，可以看到 VPTR 初始时是未设置的，然后被初始化为 Shape VTABLE——里面放着 `Shape_draw` 和 `Shape_area` 的函数地址。另外注意，VTABLE 确实在 ROM 中，因为它的地址以 0 开头。

Now, when you keep stepping, you return back to the Rectangle constructor and there, the VPTR gets overridden to the Rectangle's VTABLE with addresses of Rectangle_draw and Rectangle_area functions.

继续单步执行，回到 Rectangle 构造函数，VPTR 就被覆盖成 Rectangle 的 VTABLE 了——里面放的是 `Rectangle_draw` 和 `Rectangle_area` 的地址。

So, your constructors in C now work exactly like the C++ constructors from the last lesson, except that in C you had to add the VTABLE and the code to set the VPTR manually, while C++ synthesized that code automatically.

所以现在 C 中的构造函数跟上一课 C++ 的构造函数行为完全一致，唯一的区别是：C 中你得手动写 VTABLE 和设置 VPTR 的代码，而 C++ 会自动生成这些。

Now, the most interesting part is to see the virtual calls inside the generic drawGraph() function. But before you step there, just note that the first object to draw will be Shape s1, the second will be the Rectangle r1, and the third will be another Rectangle pointed to by the pointer ps3.

接下来最有趣的部分——看通用 `drawGraph()` 函数中的虚调用。在单步进入之前，先注意一下：第一个要绘制的是 Shape s1，第二个是 Rectangle r1，第三个是 ps3 指针指向的另一个 Rectangle。

Once inside drawGraph, step to the Shape_draw_vcall() virtual call, and take a look at the disassembly.

进入 `drawGraph` 后，单步到 `Shape_draw_vcall()` 虚调用处，看看反汇编代码。

When you compare it to the code generated by the C++ compiler, you can see that they are... identical.

跟 C++ 编译器生成的代码对比一下——完全一模一样。

So, let's step through this late-binding code a single instruction at the time. The first LDR fetches the VPTR from the me pointer in R6 and places it in R0. The second LDR fetches the first virtual function from the VTABLE now in R0, and places it in R1. The MOV instruction copies the "me" pointer in R6 to R0 to prepare it as the first parameter of the call. And finally, the BLX R1 instruction executes the call to the address in R1.

来逐条指令走一遍这段后期绑定代码。第一条 `LDR` 从 R6 中的 `me` 指针取出 VPTR 放进 R0。第二条 `LDR` 从现在位于 R0 的 VTABLE 中取出第一个虚函数放进 R1。`MOV` 指令把 R6 中的 `me` 指针复制到 R0，准备好作为调用的第一个参数。最后，`BLX R1` 跳转到 R1 中的地址执行调用。

And indeed, you end up in the Shape_draw() method, because as you remember the first pointer in the graph array was the s1 Shape class object.

果然，你进入了 `Shape_draw()` 方法——因为 `graph` 数组里的第一个指针就是 s1 这个 Shape 类对象。

The second time through the loop in the drawGraph function the same late-binding code now invokes the Rectangle_draw function, however. So, as you just saw, the C implementation of virtual functions works exactly like the C++ original, down to the machine instructions for late binding.

第二次循环时，同样的后期绑定代码调用的是 `Rectangle_draw`。所以你刚看到了：C 语言实现的虚函数跟 C++ 原版完全一样，连后期绑定的机器指令都一字不差。

At this point, I'd like to note that the VPTR-VTABLE implementation of polymorphism in C that you learned here is not the only possibility. In the literature or online you can find plenty of other techniques.

到这里我想指出，你学的这套 VPTR-VTABLE 多态实现并不是唯一的方法。文献和网上还能找到很多其他技术。

Perhaps the most frequently used alternative is to remove the VPTR level of indirection and embed the whole VTABLE inside every object.

最常见的一种替代方案是去掉 VPTR 这层间接引用，把整个 VTABLE 直接嵌入每个对象里。

The advantage here is a little simpler virtual call as well as a nicer syntax more closely resembling C++, because the draw() method, for example, is invoked on an object using the dot operator, like this.

好处是虚调用稍微简单一些，语法也更像 C++——比如 `draw()` 方法可以直接用点运算符在对象上调用，像这样。

But the drawback is the increased RAM usage, because VTABLE is now in RAM rather than ROM. Not only this, the VTABLE is repeated in every object, so if you have many objects you can easily double or triple your RAM usage.

但缺点是 RAM 占用量增加——VTABLE 现在在 RAM 里而不是 ROM 里。不仅如此，每个对象都有一份 VTABLE 的副本，对象一多，RAM 用量很容易翻倍甚至更多。

An example book that presents this implementation method is "Design Patterns for Embedded Systems in C" by Bruce Powel Douglass. You can find there the whole chapter on object-oriented programming and specifically its C implementation. The author discusses Classes, Objects, Polymorphism and Virtual Functions, Subclasses and other aspects.

展示这种实现方式的一本参考书是 Bruce Powel Douglass 的《Design Patterns for Embedded Systems in C》。里面有一整章讲面向对象编程，特别是 C 语言实现。作者讨论了类、对象、多态与虚函数、子类等内容。

There is also specific C code where you can clearly recognize the VTABLE embedded directly in the attribute structure.

书中还有具体的 C 代码，你可以清楚地看到 VTABLE 直接嵌入在属性结构体里。

Interestingly, please note how this book also uses the "me" pointer naming convention for the class member functions in C.

有意思的是，注意这本书也用了 `me` 指针这个命名约定来表示 C 中的类成员函数。

The last subject I want to touch upon today is when to use polymorphism and perhaps even more importantly when not to. Let's start with a simple "code-smell" indicating that polymorphism might be helpful.

今天最后一个话题：什么时候该用多态——也许更重要的是，什么时候不该用。先从一个"代码异味"（code smell）说起，它暗示你可能需要多态。

For that imagine how the generic drawGraph() function would be implemented in a very traditional C-code, without late-binding. Well, it would probably look something like that:

想象一下，如果没有后期绑定，通用的 `drawGraph()` 函数用传统 C 代码怎么写？大概长这样：

Specifically, you would probably add an attribute "kind" into the Shape structure, and you would also provide an enumeration of all possible kinds of shapes, such as RECTANGLE, CIRCLE, TRIANGLE, etc.

具体来说，你可能会在 Shape 结构里加一个 `kind` 属性，再定义一个枚举列出所有可能的形状类型——RECTANGLE、CIRCLE、TRIANGLE 等等。

Then every time you would need behavior specific to the kind of shape, you would use a switch or if-then-else branching to invoke the right function for the kind of shape you happen to be dealing with.

然后每次需要根据形状类型执行特定行为时，就用 switch 或 if-else 来分支调用对应的函数。

But such code is far less maintainable, because every time you add or remove a new kind of Shape, you would need to find and change all places throughout the code.

但这样的代码可维护性差得多——每新增或删除一种 Shape 类型，你就得到处找、到处改。

In contrast, the virtual call mechanism is not only much more efficient. It is also automatically extensible, because you can keep adding and removing different shape subclasses, but you don't need to change the code with the virtual call at all. You don't even need to recompile the whole Shape base class, including drawGraph() and any other functions like it.

相比之下，虚调用机制不仅效率更高，而且天然具有可扩展性——你可以不断添加和删除 Shape 子类，但使用虚调用的代码完全不用改。甚至不需要重新编译 Shape 基类，包括 `drawGraph()` 及类似的函数。

So, here is your main guideline. Whenever you see or anticipate code like the switch statement scattered throughout your project, you should consider polymorphism.

所以这里有一条主要指导原则：每当你在项目中看到或预见到像 switch 语句这样散布各处的代码，就该考虑用多态了。

But please remember that the only valid reason for applying polymorphism is that the object-specific behavior needs to be selected at runtime.

但要记住，应用多态的唯一正当理由是：对象特定的行为确实需要在运行时才能确定。

Which brings me to the guidelines when NOT to use polymorphism. Well, you don't need polymorphism when the selection based on object type does not need to happen at runtime.

这就引出了什么时候不该用多态。如果基于对象类型的选择不需要在运行时做，那就不需要多态。

The most frequent misuse of polymorphism I see in the industry is in attempts to manage product lines of related, but slightly different products.

我在行业中最常见的多态误用，是拿它来管理相关但略有不同的产品线。

For example, a medical company making, say, infusion pumps for drugs might start with a single pump, but then keeps coming up with ever more versions for various drugs and market segments.

举个例子：一家做药物输液泵的医疗公司，一开始可能只有一个产品，但随后不断为不同的药物和市场推出越来越多的版本。

The software for the new pumps is almost never created from scratch, but rather is continuously tweaked and adapted from the existing software. But actually, the software for a new pump is not copied and changed separately. Instead, a single, ever growing code base is extended to service all existing pumps.

新泵的软件几乎不会从零开始写，而是在现有软件上不断修改适配。但实际上不是每个泵单独复制一份代码来改，而是在一个不断膨胀的单一代码库上扩展，服务所有泵。

And herein lies madness. Developers litter the code with conditional logic, which quickly becomes unmanageable and untestable. This code makes decisions at runtime based on the product type, version numbers and similar variables, while really any given code set ends up in only one specific product. Therefore, the selection of the product does NOT need to happen at runtime. It can happen at compile-time and link-time.

问题就在这里。开发者在代码里到处塞条件判断，很快代码就变得没法管、没法测。这些代码在运行时根据产品类型、版本号之类的变量做决策，但实际上每一份代码最终只跑在一个特定的产品上。所以产品的选择根本不需要在运行时做——在编译时和链接时搞定就行了。

So, even if polymorphism could eliminate much of the convoluted IF-THEN-ELSE logic, a better way is to design a clean Board Support Package (BSP) interface and then provide different implementations, different BSPs, for different products. So, for product ABC, you would have bsp_ABC, and so on. This is the use of abstraction, as I explained back in lesson 29.

所以，即使多态能干掉大量纠缠不清的 if-else，更好的做法是设计一个干净的**板级支持包**（Board Support Package, BSP）接口，然后为不同产品提供不同的实现——不同的 BSP。比如产品 ABC 就有 `bsp_ABC`，以此类推。这就是对抽象的运用，我在第29课中讲过。

Of course, there is much more to it than just a simple BSP abstraction. The effective management of product lines requires careful *physical design*, which is the way you partition your code into directories and files, such as header files and implementation files. That way, you can build the final software for any given product by combining various modules at *link-time*, rather than using techniques like polymorphism at runtime.

当然，远不止 BSP 抽象这么简单。有效的产品线管理需要精心的**物理设计**（physical design）——也就是你怎么把代码划分成目录和文件（头文件、实现文件）。这样你就可以在**链接时**组合不同的模块来构建特定产品的软件，而不是在运行时用多态之类的技术。

The art of good physical design is very valuable especially in embedded systems programming. Unfortunately, the subject is not widely known or appreciated. While tons of books talk about logical design techniques, such as OOP, very few resources exist for physical design.

良好的物理设计在嵌入式编程中非常有价值。遗憾的是，这个话题并不广为人知，也不够受重视。讲逻辑设计（比如 OOP）的书汗牛充栋，但讲物理设计的资源却少之又少。

One notable exception is the book "Large Scale C++ Software Design" by John Lakos. This book explains *physical design* really well. Highly recommended.

一个值得一提的例外是 John Lakos 的《Large Scale C++ Software Design》。这本书把**物理设计**讲得非常好，强烈推荐。

And this concludes this group of lessons about object-oriented programming in embedded systems.

关于嵌入式系统中面向对象编程的这一系列课程到此结束。

In the next lesson, I will go back to my overarching theme, which is introducing the main trends that shaped the modern embedded systems programming.

下一课我会回到主线——介绍塑造了现代嵌入式系统编程的主要趋势。

Specifically, I will start a new segment, in which you will learn about the last big trend that went mainstream during the 1980s, and that is event-driven programming.

具体来说，我将开始一个新的篇章，带你了解 80 年代最后一个成为主流的大趋势——**事件驱动编程**（event-driven programming）。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| polymorphism | 多态 | OOP 核心概念，允许子类为同一继承操作提供不同实现 |
| virtual function | 虚函数 | 通过 VPTR-VTABLE 机制实现运行时方法解析的函数 |
| VPTR (Virtual Pointer) | 虚指针 | 对象中指向 VTABLE 的指针，是实现多态的关键 |
| VTABLE (Virtual Table) | 虚函数表 | 存放虚函数地址的结构体，通常放在 ROM 中 |
| late binding | 后期绑定 | 在运行时而非编译时确定调用的具体函数 |
| pointer-to-function | 函数指针 | 指向函数的指针，包含函数的完整签名信息 |
| upcasting | 向上转型 | 将子类指针转换为基类指针，C 编译器不会自动执行 |
| inline function | 内联函数 | C99 引入的特性，避免函数调用开销，适合实现虚调用包装 |
| preprocessor macro | 预处理器宏 | 纯文本替换机制，作为 C89 编译器的低开销虚调用替代方案 |
| constructor | 构造函数 | 负责 VPTR 和 VTABLE 初始化的函数 |
| code smell | 代码异味 | 代码中暗示设计问题的信号，比如大量散布的 switch 语句 |
| physical design | 物理设计 | 代码划分成目录和文件的方式，影响编译和链接时的模块组合 |
| BSP (Board Support Package) | 板级支持包 | 硬件抽象层，不同产品可提供不同实现 |
| product line | 产品线 | 相关但略有不同的产品系列 |
| link-time | 链接时 | 编译后的链接阶段，可用于组合不同模块替代运行时多态 |
| encapsulation | 封装 | 隐藏实现细节，对外暴露接口的 OOP 原则 |
| single inheritance | 单继承 | 一个子类只继承一个父类 |
| ROM | 只读存储器 | 存放 VTABLE 的理想位置，节省 RAM |
| event-driven programming | 事件驱动编程 | 下一课将介绍的编程范式 |
