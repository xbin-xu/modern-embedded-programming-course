# 第30课：面向对象编程——继承 / Lesson 30: OOP — Inheritance

Welcome to the Modern Embedded Systems Programming course. My name is Miro Samek and in this lesson I continue the subject of Object-Oriented Programming. Today you will learn about the concept of class *inheritance* and you will see how it works both in C and in C++.

欢迎来到现代嵌入式系统编程课程。我是 Miro Samek，这节课我们继续聊面向对象编程。今天你要学习的是类的**继承**（inheritance）概念，并且看看它在 C 和 C++ 中分别是怎样实现的。

As usual, let's get started by making a copy of the previous lesson 29 directory and renaming it to lesson 30. Get inside the new lesson 30 directory and double-click on the uVision project "lesson" to open it.

跟以前一样，先把上一课第 29 课的目录复制一份，改名为 lesson 30。进入新的 lesson 30 目录，双击 uVision 项目文件"lesson"打开它。

To remind you quickly what happened so far, in the last lesson you started to learn about Object-Oriented Programming (OOP) and you have implemented the first fundamental OOP concept of Encapsulation.

快速回顾一下：上一课你开始学习面向对象编程（OOP），并且实现了第一个核心 OOP 概念——封装。

Encapsulation means that you organize your code into *classes* that package data and functions together.

封装的意思是，你把代码组织成**类**（class），把数据和函数打包在一起。

Specifically, you have implemented a Shape class in C (and later in C++), to represent shapes on an LCD display.

具体来说，你先用 C（后来又用 C++）实现了一个 Shape 类，用来表示 LCD 显示屏上的形状。

Later, you created a few instances of this Shape class, which are called *objects*. These objects then where manipulated exclusively by the class operations, which was the whole point of encapsulation.

接着，你创建了几个 Shape 类的实例，也就是所谓的**对象**（object）。这些对象完全通过类的操作来操控——这正是封装的核心要义。

But, in real software for an LCD display, you would need not just nebulous Shapes. You would need concrete Rectangles, Circles and Triangles.

但在 LCD 显示屏的实际软件里，光有笼统的 Shape 是不够的。你需要具体的 Rectangle（矩形）、Circle（圆形）和 Triangle（三角形）。

Of course, now that you know the concept of a class, you could create a Rectangle class, a Circle class, a Triangle class and so on, from scratch.

当然，既然你已经知道类这个概念了，完全可以从头创建 Rectangle 类、Circle 类、Triangle 类等等。

But as you will do this, you will notice that all of them would contain attributes for their position on the screen and operations to move them around and to determine the distance among them, plus some other attributes and operations.

但这么做的时候你会发现，它们都包含屏幕位置的属性、移动位置和计算距离的操作，还有其他一些共同的属性和操作。

But wait a minute, didn't you just implement these exact attributes and operations in your Shape class? Could this be somehow reused in your Rectangle, Circle and Triangle classes?

等等，这些属性和操作你不是刚刚在 Shape 类里实现过吗？能不能想办法在 Rectangle、Circle 和 Triangle 类中复用呢？

The answer is yes, and is known as the fundamental OOP concept called *inheritance*, which is the ability to define new classes based on existing classes in order to reuse the code and organization. This is the main subject of this lesson.

答案是肯定的。这就是 OOP 的另一个核心概念——**继承**（inheritance），也就是基于现有的类来定义新类，从而复用代码和组织结构。这就是本课的重点。

So, here is how you go about creating a Rectangle class based on the Shape class in C.

好，接下来看看怎么在 C 语言中基于 Shape 类来创建 Rectangle 类。

You start the same way as you did for the Shape class by adding the rectangle.h header file to your project and placing the usual include guards in it.

跟创建 Shape 类时一样，先在项目里添加 `rectangle.h` 头文件，写上标准的**包含保护**（include guard）。

Then, you create the attribute structure. But instead of starting from scratch, you add the whole Shape instance as the very *first* attribute, which by a naming convention you call "super". Later you will see in which sense you can think of this "super" attribute as inherited from Shape, but for now you just state it in the comment. Of course, you need to include the shape.h header file with the Shape struct for this to compile.

然后创建属性结构体。但这次不是从零开始，而是把整个 Shape 实例作为**第一个**属性塞进去，按命名约定叫它"super"。稍后你会明白为什么可以把这个"super"属性看作是从 Shape 继承来的，现在先在注释里标注一下就行。当然，为了让代码能编译，你需要包含声明 Shape 结构体的 `shape.h` 头文件。

Now, you can add attributes specific to the Rectangle class, such as the width and the height of the rectangle.

接下来，添加 Rectangle 类特有的属性，比如矩形的宽度和高度。

Finally, you add operations specific to your Rectangle class. In the constructor, you provide parameters for all attributes: the x0 and y0 for x and y inherited from Shape, and w0 and h0 for width and height added in Rectangle.

最后，添加 Rectangle 类特有的操作。在**构造函数**（constructor）中，你要为所有属性提供参数：x0 和 y0 对应从 Shape 继承来的 x 和 y，w0 和 h0 对应 Rectangle 自己新增的宽度和高度。

Finally, you can add operations specific to the Rectangle. For example, you can add operation draw(), which will draw the rectangle on the LCD screen.

此外还可以添加 Rectangle 特有的操作。比如 `draw()` 操作，用来在 LCD 屏幕上画出这个矩形。

There is no reason why draw() should change the rectangle, so you could add const before the star to the "me" pointer. Similarly, you can add the area() operation, which will calculate and return the area of the rectangle. Again, the area() operation will not change the "me" instance.

`draw()` 不应该修改矩形本身，所以可以在"me"指针的星号前面加 `const`。类似地，还可以添加 `area()` 操作，计算并返回矩形的面积。同样，`area()` 也不会修改"me"实例。

When it comes to the definition of the Rectangle class, you add a C file rectangle to your project.

接下来是实现 Rectangle 类。在项目中添加 `rectangle.c` 文件。

Next, you need to include the rectangle.h header file with the class interface, after which you copy over the prototypes of the class operations.

先包含 `rectangle.h` 头文件拿到类接口，然后把类操作的原型抄过来。

In the constructor, you first call the Shape constructor for the member "super". This takes care of initializing the inherited attributes.

在构造函数中，首先为"super"成员调用 Shape 的构造函数。这一步负责初始化从 Shape 继承来的属性。

Only after this, you initialize the attributes added in the Rectangle class.

之后才去初始化 Rectangle 类自己新增的属性。

In the Rectangle area() operation, you simply return the product of with by height promoted to uint32_t.

`area()` 操作很简单，直接返回宽度乘以高度的结果，类型提升为 `uint32_t`。

Finally, in the Rectangle draw() operation, which is potentially more complex, you can simply use some commented out pseudocode for drawing vertical and horizontal lines on the LCD.

最后是 `draw()` 操作——这个操作可能比较复杂，现在先用注释掉的伪代码代替就行，写一下在 LCD 上画竖线和横线的逻辑。

This is good enough for today, because all you really need at this point is the ability to set a breakpoint inside this operation to determine in the debugger that it has been called.

今天这样已经足够了，因为你现在真正需要的只是能在这个操作里设个断点，确认调试器能调到它。

So now, to exercise your Rectangle class, you need to: instantiate it, initialize it with a constructor and call the Rectangle operations on it, like draw() and area().

好，现在来用一下你的 Rectangle 类：创建实例、用构造函数初始化，然后调用 Rectangle 的操作，比如 `draw()` 和 `area()`。

The code builds cleanly, so let's open it in the debugger.

代码编译通过，没有错误。我们在调试器里打开它。

The most interesting thing I would like you to see here is the layout of the Rectangle object in memory.

我最想让你看到的是 Rectangle 对象在内存中的布局。

For this, open the memory view and set it to the beginning of your RAM, that is at hex-2 followed by all zeros.

为此，打开内存视图，把地址设到 RAM 的起始位置，也就是 0x20000000。

Next, run to the Rectangle constructor and step into it. Here, note the "me" pointer value and find it in the memory view. Now, step into the Shape constructor, and note that the "me" pointer value is the same, even though the type of the "me" pointer has changed from Rectangle to Shape.

接下来，运行到 Rectangle 构造函数，单步进入。注意"me"指针的值，在内存视图中找到它。然后进入 Shape 构造函数——注意，"me"指针的值没变，虽然它的类型已经从 Rectangle 变成了 Shape。

Before continuing, change the memory view to display signed short values, because the attributes of Shape and also of Rectangle are 16-bit integers.

继续之前，把内存视图改为显示有符号短整型（signed short），因为 Shape 和 Rectangle 的属性都是 16 位整数。

Now, as the Shape constructor runs, it fills out the memory at the beginning of the Rectangle structure.

现在，Shape 构造函数开始执行，它在 Rectangle 结构体的开头填充内存。

When the control returns back to the Rectangle constructor, it fills out the memory after the Shape portion. In the end your memory layout looks as follows.

控制权回到 Rectangle 构造函数后，它在 Shape 部分之后继续填充内存。最终内存布局是这样的。

The whole Rectangle structure is aligned with its first member "super".

整个 Rectangle 结构体跟它的第一个成员"super"是对齐的。

This is not just a coincidence for the Rectangle struct, but rather a rule that is enshrined in the C-language.

这不是 Rectangle 结构体的巧合，而是 C 语言标准中明确规定的一条规则。

Here, for example is the International Standard ISO/IEC for the C programming language.

比如，这里是 C 语言的 ISO/IEC 国际标准。

In the section about Structure and unition specifiers you can read, that:

在结构体和联合体说明符那一节，你可以读到这样一句话：

"A pointer to a structure object, suitably converted, points to its initial member... There may be unnamed padding within a structure object, but not at its beginning"

"指向结构体对象的指针，经过适当转换后，就指向它的第一个成员……结构体对象内部可能有未命名的填充字节，但开头不会有。"

All of this is, of course, a rather complicated way of saying that a pointer to a structure can be always safely cast on the pointer to the initial member of the structure.

说白了，这句话的意思就是：指向结构体的指针，总是可以安全地转换为指向结构体第一个成员的指针。

This has rather important implications for your Rectangle class, because it means that any pointer to Rectangle can be safely passed to a function expecting a pointer to Shape.

这对 Rectangle 类的意义非常重大——因为它意味着，任何指向 Rectangle 的指针，都可以安全地传给期望 Shape 指针的函数。

This means that all operations for Shapes apply to Rectangles as well.

也就是说，Shape 的所有操作也适用于 Rectangle。

For example, you can call the Shape_moveBy() operation on your Rectangle object and you can also call the distanceFrom() operation as well.

比如，你可以在 Rectangle 对象上调用 `Shape_moveBy()` 操作，也可以调用 `distanceFrom()` 操作。

In this sense, the Rectangle class *inherits* all operations from the Shape class.

从这个意义上说，Rectangle 类**继承**了 Shape 类的所有操作。

However, for this to compile in C you need to explicitly cast Rectangle pointers to Shape pointers.

不过在 C 语言中，要让代码编译通过，你得显式地把 Rectangle 指针转换为 Shape 指针。

But truly object-oriented programming languages, like C++ *know* that such pointer casting, called "upcasting", is always safe, and OOP languages perform upcasting automatically, as you will see in the second part of this lesson.

但真正的面向对象语言（比如 C++）知道这种指针转换——叫做**向上转型**（upcasting）——总是安全的，会自动帮你完成。本课第二部分你就会看到。

Now you probably wonder where the term "up-casting" is coming from, so it's time to learn a little of terminology and graphical notation.

你可能在想"向上转型"这个名字是怎么来的。是时候学点术语和图形表示法了。

Here is a class diagram, which is drawn in a traditional way with the base class Shape on top and the derived class Rectangle below.

这是一个**类图**（class diagram），按传统画法，基类 Shape 在上面，派生类 Rectangle 在下面。

From this you can see that casting from the derived class to the base class goes "up", hence the term "up-casting".

可以看到，从派生类转到基类方向是"向上"的，所以叫"向上转型"。

The inheritance relationship itself is drawn as an arrow with a big triangular end pointing to the base class, which is often the exact opposite what most people initially think.

继承关系本身用一条带大三角形箭头的线来表示，箭头指向基类。这跟大多数人直觉想的刚好相反。

This is because the arrow points in the direction of generalization, that is from a more specialized class, like Rectangle, to a more general class, like Shape.

因为箭头指向的是**泛化**的方向——从更具体的类（比如 Rectangle）指向更一般的类（比如 Shape）。

Therefore, inheritance is also alternatively called generalization.

所以，继承也叫做泛化（generalization）。

The "base class" is alternatively called "superclass" or "parent class".

"基类"（base class）也叫"超类"（superclass）或"父类"（parent class）。

And the "derived class" is alternatively called "subclass" or a "child class".

"派生类"（derived class）也叫"子类"（subclass）或"子类"（child class）。

Finally, you should also realize that class inheritance is not limited to only one level. The Rectangle class itslef can be further specialized for example in a FilledRectangle class, for which Rectangle becomes the base class.

最后还要知道，类继承不限于一层。Rectangle 类本身还可以进一步特化，比如派生出 FilledRectangle 类，这时 Rectangle 就成了基类。

All of this can lead to whole family trees of increasingly specialized classes.

这样就能形成一棵越来越具体的类家族树。

With this bigger picture in mind, let me offer a few guidelines of how to best THINK about class inheritance.

有了这个大图景，我来给你几条建议，帮你正确理解类继承。

First, the term "inheritance" itself as well as terms like "parent class" and "child class" might suggest the family tree analogy. But this is an incorrect analogy and I would discourage that you think about class inheritance that way.

首先，"继承"这个词本身，还有"父类""子类"这些叫法，很容易让人联想到家族谱系。但这个类比是不对的，我建议你不要用这种方式来理解类继承。

As you saw in the Rectangle class emulation in C, every instance of the derived class literally contains the whole instance of the base class, like Rectangle contains Shape at the attribute "super".

正如你在 C 语言中模拟 Rectangle 类时看到的，派生类的每个实例确实包含了基类的完整实例——就像 Rectangle 通过"super"属性包含了 Shape。

With classes, this is done in such a way, that any derived instance can be treated AS an instance of the base class. In other words, inheritance establishes the "Is A..." relationship, such that it makes sense to say "a Rectangle IS A Shape".

类的设计保证了：任何派生类的实例都可以**当作**基类实例来使用。换句话说，继承建立的是"是一个"（Is A）关系——所以说"矩形**是一个**形状"是完全合理的。

In contrast, the family tree analogy does not work that way. Donald does not contain inside an instance of his parent Mary Anne and it make no sense to say that "Donald IS Mary Ann", or "Donald IS Fred" for that matter.

家族谱系的类比就不同了。Donald 身体里并没有包含他父母 Mary Anne 的实例，说"Donald **是** Mary Ann"或者"Donald **是** Fred"完全说不通。

So, which analogy could you use instead?

那用什么类比才对呢？

Well, a good analogy that will shape your thinking correctly is the biological classification of living organisms.

一个能帮你建立正确直觉的类比是生物的分类学。

In the biological CLASS-ification, it makes sense to say, for example, that a House Cat IS A Felis, meaning a cat-like animal. Further, it makes sense to say that a House Cat IS A Carnivore, meaning a predominantly meat-eating animal. And even further and at the same time, it makes sense to say that a House Cat IS A Mammal, meaning animal that feeds their young with milk.

在生物**分类**中，说"家猫**是一个**猫属动物（Felis）"是合理的，意思就是猫类动物。进一步，说"家猫**是一个**食肉动物（Carnivore）"也是合理的，意思是以肉食为主的动物。再往上，同时说"家猫**是一个**哺乳动物（Mammal）"同样合理，意思是用乳汁哺育后代的动物。

Also, the behaviors introduced in the higher level classes make sense to be inherited by the lower-level classes. For example, the Mammal class might introduce the "lactate operation", meaning to secrete milk to feed the young. This operation makes then sense in all subclasses of Mammal, such as Carnivores, Felis, and House Cats.

而且，高层类中引入的行为，被子类继承也是完全合理的。比如，哺乳动物类可能有"哺乳"这个操作——分泌乳汁喂养后代。这个操作对哺乳动物的所有子类（食肉动物、猫属、家猫）都有意义。

To finish this longish somewhat theoretical digression, I'd like to compare class inheritance to class composition, so that you understand the difference.

这段理论偏题有点长了，最后我想把类继承和**类组合**（composition）做个对比，帮你理解它们的区别。

So, going back to the code, you implemented inheritance by literally embedding an instance of the superclass inside the subclass. This means that the subclass is a *composition* of the superclass plus some added attributes and operations. This points to some similarities between inheritance and composition.

回到代码：你通过在子类中嵌入超类实例来实现继承。这意味着子类是超类加上额外属性和操作的**组合**。这说明继承和组合之间确实有些相似之处。

And in fact both approaches can accomplish similar goals, but there is an important difference. Inheritance is the "is a..." relationship, which comes about only when you embed the superclass as the very *first* attribute, so that every instance of the subclass can be treated as an instance of the superclass.

事实上，两种方式都能达到类似的目的，但有一个关键区别。继承是"是一个"的关系，只有当你把超类实例作为**第一个**属性嵌入时才成立——这样子类的每个实例才能被当作超类实例来使用。

If you move the superclass instance to a different position, you still have composition, which is the "has a..." relationship, like Rectangle has a Shape. But you can no longer legitimately perform upcasting.

如果你把超类实例挪到别的位置，那仍然算是组合——对应的是"有一个"（Has A）关系，比如"矩形有一个形状"。但这时你就不能合法地做向上转型了。

Instead, you would have to explicitly reference the component attribute inside the Rectangle class, which would break encapsulation.

那样的话，你就得显式地引用 Rectangle 类内部的组件属性，这就破坏了封装。

So, let me undo the changes and close this project as we are done in C for today.

好，让我撤销这些改动，关闭项目。今天 C 语言的部分就到这里。

In the last segment of this lesson, I'd like to show you how class inheritance is implemented in C++. Just like in the previous lesson, this will allow you to directly find out how your C emulation of inheritance differs from a truly object-oriented language and how C++ differs from C.

本课最后一段，我想给你看看 C++ 中类继承是怎么实现的。跟上一课一样，这样你可以直接对比：用 C 模拟继承跟真正的面向对象语言有什么不同，C++ 跟 C 又有什么区别。

So, let's start with the C++ code from the previous lesson 29, copy it and rename to lesson30-underscore-cpp. Also, go back to the today's lesson 30 directory, copy the files rectangle-dot-H and rectangle-dot-C, and paste them into the lesson30-underscore-cpp directory.

先从上一课第 29 课的 C++ 代码开始，复制一份并改名为 `lesson30_cpp`。同时回到今天的第 30 课目录，把 `rectangle.h` 和 `rectangle.c` 复制到 `lesson30_cpp` 目录里。

As the last touch, rename the rectangle-dot-c file to rectangle-dot-CPP.

最后，把 `rectangle.c` 改名为 `rectangle.cpp`。

Now, you can drop the project "lesson" onto the uVision IDE to open it.

现在把"lesson"项目拖到 uVision IDE 中打开。

After opening, the first thing you need to do is to add rectangle-dot-H and rectangle-dot-CPP to your project.

打开之后，第一件事就是把 `rectangle.h` 和 `rectangle.cpp` 添加到项目中。

So, let's open the rectangle-dot-H header file and convert it to C++. You start exactly like in the previous lesson: You replace typedef struct with the keyword "class" followed by the class name.

好，打开 `rectangle.h` 头文件，把它转换成 C++。跟上一课完全一样：把 `typedef struct` 替换成 `class` 关键字加类名。

But now comes the new element of inheritance. For this key object-oriented concept, C++ provides a special syntax, which is colon followed by the base class name and the keyword "public" in front.

接下来就是继承这个新元素了。对于这个关键的面向对象概念，C++ 提供了专门的语法——冒号后面跟 `public` 关键字和基类名称。

This means in C++ that Rectangle publicly inherits Shape. The other option would be to inherit Shape privately, but private inheritance is an advanced concept that you don't need to worry about right now.

这在 C++ 中表示 Rectangle **公有继承**（public inheritance）了 Shape。另一个选项是私有继承，但那是个高级概念，现在不用管。

So this is really all that's new. The rest of the Rectangle class like the private attributes and public operations are very similar to the previous lesson.

新增的内容就这么点。Rectangle 类其余的部分——私有属性、公有操作——跟上一课差不多。

So, again you adjust the operations by removing the class-name prefix and removing the "me" pointer, remembering to preserve the const before the asterisk at the end of the prototypes.

同样，调整操作声明：去掉类名前缀，去掉"me"指针参数，别忘了保留原型末尾星号前面的 `const`。

Now, regarding the derived class implementation, the most interesting change is in the constructor.

接下来看派生类的实现，最有趣的变化在构造函数。

Just like in C, the derived class needs to call the base-class constructor. But again, C++ provides a special syntax for it, which is based on the constructor initializer list introduced in the last lesson.

跟 C 一样，派生类需要调用基类的构造函数。C++ 为此提供了专门的语法——用的是上一课介绍过的**构造函数初始化列表**（constructor initializer list）。

The draw() operation, even though it is just pseudocode at this stage, offers an interesting dilemma, which is direct access to the inherited attributes from Shape, coded in C as super-dot-x and super-dot-y.

`draw()` 操作虽然目前还只是伪代码，但引出了一个有意思的两难问题：直接访问从 Shape 继承来的属性。在 C 代码中写的是 `super.x` 和 `super.y`。

If you check in the Shape class, these attributes are declared as private, which restricts the access to them to their own class only.

去看看 Shape 类你会发现，这些属性声明为 `private`——意味着只有 Shape 类自己才能访问。

In order for derived classes to have access as well, the base class needs to grant the "protected" access to its attributes. This means that derived classes at any level can access such attributes directly, but the attributes are still protected against any public access.

要让派生类也能访问，基类需要把这些属性的访问权限设为 `protected`。这样一来，任何层级的派生类都能直接访问这些属性，但外部代码仍然不能访问。

Now, in the draw() operation, you can remove the me-super indirection, because C++ allows you to access the inherited attributes directly, as though they were declared in the derived class.

现在在 `draw()` 操作中，可以去掉 `me->super` 的间接引用了，因为 C++ 允许你直接访问继承来的属性，就像它们是在派生类中声明的一样。

Of course, you can also remove the me pointer from all other parameters, because they are now accessed via the implicit this pointer.

当然，其他参数中的 `me` 指针也都可以去掉，因为现在通过隐式的 `this` 指针来访问。

Finally, you apply the same changes to the area() operation.

最后，对 `area()` 操作做同样的修改。

As you can see the Rectangle implementation in C++ compiles error- and warning-free.

如你所见，Rectangle 的 C++ 实现编译通过，没有错误和警告。

The last remaining step is to actually instantiate and use the Rectangle class in the main-dot-cpp file just like you did it in C.

最后一步就是在 `main.cpp` 中实际创建和使用 Rectangle 类，跟在 C 语言中做的类似。

For this, it is convenient to open the previous main.c file in the side view for reference. Please note that the C file is not added to the C++ project.

为了方便对照，可以在侧边栏打开之前的 `main.c` 文件做参考。注意，C 文件不会加入到 C++ 项目中。

So, first, you need to include the rectangle-dot-H header file in your main-dot-CPP.

首先，在 `main.cpp` 中包含 `rectangle.h` 头文件。

Next, you can statically allocate a Rectangle object in C++, but in C++ you need to immediately initialize the object via a constructor call.

然后可以在 C++ 中静态分配一个 Rectangle 对象。不过在 C++ 中，你必须在分配的同时通过构造函数来初始化它。

Next, you can call the operations introduced directly in the Rectangle class such as draw() and area(), which you modify the same way as before for the Shape class.

接下来，调用 Rectangle 类自己引入的操作，比如 `draw()` 和 `area()`。修改方式跟之前处理 Shape 类一样。

But now, you can also call the *inherited* operations from Shape. And here, you can remove the explicit upcasting, because the C++ compiler performs upcasting automatically, knowing that upcasting is always safe.

但现在，你还可以调用从 Shape **继承**来的操作。而且这里不需要显式地做向上转型——C++ 编译器知道向上转型总是安全的，会自动帮你完成。

The project builds cleanly, so let's see how the C++ implementation looks inside the CPU.

项目编译通过，来看看 C++ 实现在 CPU 内部是什么样的。

Before starting the debugger, however, let's set a breakpoint in the Rectangle constructor.

启动调试器之前，先在 Rectangle 构造函数里设个断点。

Only now you start the debugger.

然后才启动调试器。

As you can see, the breakpoint is hit right away, which means that C++ static constructors run even before main as you already learned in the last lesson.

可以看到，断点立刻就命中了。这说明 C++ 的静态构造函数在 `main` 之前就已经运行了——上一课你已经学过这一点。

The Locals view shows you the "this" pointer, through which you can conveniently see the object's attributes as consisting of the inherited Shape part followed by attributes added directly to Rectangle.

局部变量视图显示了 `this` 指针，通过它可以方便地查看对象的属性——先是继承来的 Shape 部分，接着是 Rectangle 自己新增的属性。

But let's also setup the memory view to see the exact layout of the Rectangle object in raw memory.

再打开内存视图，看看 Rectangle 对象在原始内存中的确切布局。

For this, set the memory view to the beginning of your RAM, that is at hex-2 followed by all zeros. Also, setup the view to show signed short numbers, because that happens to be the size of Shape and Rectangle attributes.

把内存视图地址设到 RAM 起始位置 0x20000000，显示格式改为有符号短整型，因为 Shape 和 Rectangle 的属性正好都是这个大小。

Now, step from Rectangle into the Shape constructor, and note that the "this" pointer value is the same, even though the type of the "this" pointer has changed from Rectangle to Shape.

现在从 Rectangle 构造函数单步进入 Shape 构造函数——注意 `this` 指针的值没变，虽然类型已经从 Rectangle 变成了 Shape。

As the Shape constructor runs, it fills out the Shape attributes, which are clearly at the beginning of the Rectangle memory.

Shape 构造函数开始执行，填充 Shape 的属性——它们明显位于 Rectangle 内存的开头。

When the control returns back to the Rectangle constructor, it fills out the memory after the Shape portion.

控制权回到 Rectangle 构造函数后，它在 Shape 部分之后继续填充内存。

In the end your memory layout in C++ looks identically as in your C emulation of inheritance.

最终 C++ 中的内存布局，跟你用 C 模拟继承时的布局完全一样。

The whole Rectangle object is aligned with the inherited Shape object, which is at the beginning of the Rectangle memory.

整个 Rectangle 对象跟继承来的 Shape 对象是对齐的，Shape 位于 Rectangle 内存的开头。

Now, let's step over the Shape class operations from the last lesson, and step into the Rectangle operations, such as Rectangle::draw().

现在跳过上一课的 Shape 类操作，进入 Rectangle 的操作看看，比如 `Rectangle::draw()`。

Here, like in the Rectangle constructor, you can use the Locals view to very conveniently examine the Rectangle object through the "this" pointer.

这里跟在 Rectangle 构造函数中一样，可以通过局部变量视图中的 `this` 指针方便地查看 Rectangle 对象。

Same goes for the Rectangle::area() operation.

`Rectangle::area()` 操作也一样。

But now come the operations inherited from Shape, like Shape::moveBy().

接下来是从 Shape 继承来的操作，比如 `Shape::moveBy()`。

As you can see in the Locals view, the "this" pointer still points to Rectangle r1, but is automatically upcast to the Shape type and only the Shape portion is now visible in the Locals view.

在局部变量视图中可以看到，`this` 指针仍然指向 Rectangle 的实例 r1，但被自动向上转型为 Shape 类型，现在只能看到 Shape 部分的属性了。

The moveBy() operation changes the Shape attributes, which you can see in both views: Locals and raw memory.

`moveBy()` 操作修改了 Shape 的属性，在局部变量视图和原始内存视图中都能看到变化。

Finally, the same upcasting of the "this" pointer happens for the distanceFrom() operation inherited from Shape.

最后，从 Shape 继承来的 `distanceFrom()` 操作中，`this` 指针也发生了同样的向上转型。

This concludes this quick introduction to the Object-Oriented concept of *inheritance*.

好了，关于面向对象的**继承**概念，快速入门就到这里。

Today you've learned what class inheritance is and how it is a mechanism for reusing common attributes and operations both in C and in C++.

今天你学到了什么是类继承，以及它是如何在 C 和 C++ 中复用公共属性和操作的机制。

But this is not the whole story. Inheritance enables even more reuse as well as extensibility through the third fundamental object-oriented concept of *polymorphism*. This will be the subject of the next lesson.

但这还不是全部。继承通过第三个核心面向对象概念——**多态**（polymorphism）——能实现更多的复用和扩展。这就是下一课的主题。

If you like this channel, please give this video a like and subscribe to stay tuned. You can also visit state-machine.com/quickstart for the class notes and project file downloads.

如果你喜欢这个频道，请点赞订阅。课程笔记和项目文件可以从 state-machine.com/quickstart 下载。

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Inheritance | 继承 | OOP 核心概念之一，基于现有类定义新类以复用代码的能力 |
| Base class / Superclass / Parent class | 基类 / 超类 / 父类 | 被继承的类，提供公共属性和操作 |
| Derived class / Subclass / Child class | 派生类 / 子类 | 通过继承从基类创建的新类 |
| `super` attribute | `super` 属性 | C 语言中模拟继承时，将基类实例作为派生类的第一个属性 |
| Upcasting | 向上转型 | 将派生类指针/引用转换为基类指针/引用，由于内存对齐规则这总是安全的 |
| Generalization | 泛化 | 继承的另一种叫法，强调从具体到一般的关系 |
| "Is A" relationship | "是一个"关系 | 继承建立的语义关系，如"矩形是一个形状" |
| "Has A" relationship | "有一个"关系 | 组合（composition）建立的语义关系，如"矩形有一个形状" |
| Composition | 组合 | 将一个类的实例作为另一个类的成员，但不一定是第一个成员 |
| Class diagram | 类图 | UML 中表示类及其关系的图形，继承用带三角形箭头的线表示 |
| `protected` keyword | `protected` 关键字 | C++ 访问控制修饰符，允许派生类访问但不允许公共访问 |
| Public inheritance | 公有继承 | C++ 中最常用的继承方式，表示"是一个"关系 |
| Private inheritance | 私有继承 | C++ 中的高级继承概念，表示"用……实现"的关系 |
| ISO/IEC C Standard | ISO/IEC C 标准 | C 语言的国际标准，规定了结构体内存布局的规则 |
| Structure alignment | 结构体对齐 | C 标准保证结构体与其第一个成员的地址相同，这是实现继承的基础 |
