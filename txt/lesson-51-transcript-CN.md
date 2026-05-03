# 第51课：使用 Doxygen 和 Spexygen 创建可追溯文档 / Lesson 51: Traceable Documentation with Doxygen & Spexygen

Hello and welcome to the "Modern Embedded Systems Programming" course. I'm Miro Samek, and in this lesson I'll show you how to document your software with Doxygen. However, I'll go several steps beyond just documenting the source code. You'll also see a Doxygen extension called Spexygen for creating traceable formal specifications, such as requirements, architecture, design, and many others, mandated by functional safety standards.

大家好，欢迎来到现代嵌入式系统编程课程。我是 Miro Samek。这节课我来讲怎么用 Doxygen 给软件写文档。不过我不会只停留在给源代码加注释这个层面。我还会给你介绍一个 Doxygen 的扩展工具，叫 **Spexygen**，专门用来创建可追溯的**正式规约**（formal specifications），比如需求、架构、设计文档等等——这些都是功能安全标准明确要求的。

Let me start by giving you an idea of what such traceable documentation looks like because if you think of a career in embedded systems, you will be increasingly required not only to create documentation but to create traceable documentation compliant with international functional safety standards, such as IEC 61508.

先让你看看这种可追溯文档长什么样。因为如果你想在嵌入式领域长期发展，会越来越多地被要求不只是写文档，还要写出符合国际功能安全标准（比如 IEC 61508）的**可追溯文档**（traceable documentation）。

Traceability is the cornerstone of any formal documentation system, especially those intended for managing functional safety. It is the explicit representation of the relationships among work artifacts. For example, a requirement can be connected to a code element that fulfills the requirement or a code element can be connected to a unit test that tests that code.

**可追溯性**（Traceability）是任何正式文档系统的基石，尤其是功能安全相关的文档系统。说白了，它就是把各个工作制品（work artifacts）之间的关系显式地表达出来。比如，一个需求可以关联到实现它的代码，一段代码也可以关联到测试它的单元测试。

The IEC 61508 functional safety standard addresses the bi-directional nature of traceability:

IEC 61508 功能安全标准对可追溯性的**双向特性**有明确要求：

Backward traceability begins at a specific work artifact and links it to the upstream artifact. For example, a code artifact can be linked with an original requirement or a test artifact with the upstream code artifact. Backward traceability is the most natural and efficient way of specifying hierarchical relationships, such as subclass-superclass in object-oriented programming (OOP). In most documentation systems, including Spexygen, the developer explicitly defines backward traceability links among work artifacts.

**后向追溯**（Backward traceability）就是从一个工作制品出发，往回链接到上游制品。比如，一段代码可以链接到它所实现的原始需求，一个测试可以链接到它所测的上游代码。后向追溯是指定层次关系最自然、最高效的方式，面向对象编程里的子类-超类关系就是这种模式。在包括 Spexygen 在内的大多数文档系统中，后向追溯链接都是由开发人员显式定义的。

Forward traceability begins at the original artifact and links it with all the resulting downstream work items. For example, a requirement can be linked with the source code element that implements that requirement.

**前向追溯**（Forward traceability）则相反，从原始制品出发，链接到所有由它产生的下游工作项。比如，一个需求可以链接到实现它的那段源代码。

In contrast to backward traceability, forward traceability links can and should be generated automatically based on the existing backward traceability links.

和后向追溯不同的是，前向追溯链接完全可以、也应该基于已有的后向追溯链接**自动生成**。

Please note that forward traceability is typically recursive, meaning that if an artifact, such as a unit test, traces to a code artifact and that code artifact traces to a requirement, then the test artifact also traces to the requirement artifact.

注意，前向追溯通常是**递归的**。也就是说，如果一个制品（比如单元测试）追溯到了某段代码，而这段代码又追溯到了某个需求，那么这个测试也就追溯到了那个需求。

Spexygen generates recursive forward traceability because it's needed to identify the potential consequences of changing a given artifact, which is called "impact analysis."

Spexygen 会生成递归的前向追溯，因为这样才能识别出修改某个制品会带来哪些潜在影响——这就是所谓的**影响分析**（impact analysis）。

In the end, backward traceability and forward traceability result in bi-directional traceability, which is highly desired for functional safety certification.

最终，后向追溯加前向追溯就构成了**双向可追溯性**（bi-directional traceability），这在功能安全认证中是非常需要的。

Of course, commercial Application Lifecycle Management (ALM) tools can automate traceability management, but Spexygen offers similar capabilities as a free and open-source alternative.

当然，商业的**应用生命周期管理**（Application Lifecycle Management, ALM）工具能自动化管理可追溯性，但 Spexygen 作为免费的开源方案，也能提供类似的能力。

Spexygen's most significant advantage is that it seamlessly incorporates source code in the bidirectional traceability management because it is based on Doxygen. In other words, Spexygen is a universal system that combines functional safety specifications with source code documentation.

Spexygen 最大的优势在于：因为它是基于 Doxygen 的，所以能把源代码无缝纳入双向可追溯性管理。换句话说，Spexygen 是一个通用系统，把功能安全规约和源代码文档整合在了一起。

Now, let me step back and show you how to create traceable documentation with Spexygen.

好了，回到正题，我来演示一下怎么用 Spexygen 创建可追溯文档。

You need to start with Doxygen.

首先得从 Doxygen 开始。

Type doxygen in the search box and go to the website. Download doxygen for your platform, which is Windows, in my case. The installation is straightforward.

在搜索框里输入 doxygen，进入官网。下载适合你平台的版本，我这里是 Windows。安装过程很简单。

Now, in the downloads for this lesson #51, you will find the examples for doxygen.

在第 51 课的下载文件里，你会找到 doxygen 的示例。

Let's open the folder for lesson-51 and look inside example0. This is just some code organized as a header.h file, source.c file, and a couple of tests. At this point, the project knows nothing about doxygen.

打开 lesson-51 文件夹，看看 example0。就是一些普通的代码，组织成 `header.h`、`source.c` 和几个测试文件。这时候项目跟 doxygen 还没有任何关系。

But launch the freshly installed doxywizard application. For the working directory, select lesson-51/example0. For project name type: example. For project synopsis type: doxygen example. For project version type: 0.0.0. You can select the project logo. For the directory to scan for source code type dot, meaning the already selected working directory. But here, you need to check the "Scan recursively" box because the code is in subdirectories inc, src, and test. For the destination directory, type a dot as well.

启动刚装好的 doxywizard。工作目录选 `lesson-51/example0`。项目名称输入 `example`，项目摘要输入 `doxygen example`，版本号输入 `0.0.0`。你还可以选个项目图标。源代码扫描目录填一个点号（`.`），意思就是当前选好的工作目录。不过这里要勾选"Scan recursively"，因为代码在 `inc`、`src`、`test` 这些子目录里。目标目录同样填点号。

Next, the desired extraction mode: All entries and include cross-reference. You can select "Optimize for C" because this is C code.

接下来选提取模式：选 All entries，并包含交叉引用。因为这是 C 代码，你可以选"Optimize for C"。

Next, you can leave the preselected HTML and LaTeX output formats.

输出格式方面，保留默认选中的 HTML 和 LaTeX 就行。

And you don't need to change anything in the Diagrams tab.

Diagrams 选项卡不用改。

Finally, you can run doxygen, after which you can click on Show HTML output. This opens your browser.

最后点 Run doxygen，跑完后点 Show HTML output，浏览器就打开了。

The main page doesn't show much, but you can view your files, such as the header.h and source.c. Doxygen has generated some documentation boxes for functions and data structs, but they only show the signatures.

主页上没太多内容，不过你可以查看文件，比如 `header.h` 和 `source.c`。Doxygen 为函数和数据结构生成了一些文档框，但只显示了函数签名。

However, when you go to the source code for this file and hover your mouse over various code elements, you can see the balloon help for them. This is useful and might be a faster way to explore and learn a new codebase, although modern IDEs also have this capability.

不过，当你打开文件的源代码视图，把鼠标悬停在不同的代码元素上时，会弹出气泡帮助。这还挺实用的，可能是快速了解一个陌生代码库的好办法——当然，现代 IDE 也能做到这些。

Now, let's look at the project directory because Doxygen has produced some output there. You can see the new HTML directory, which contains the static website you just browsed, but you also see the new LaTeX directory because you allowed Doxygen to produce LaTeX output.

来看看项目目录，Doxygen 已经在那生成了一些输出。你会看到新增的 `html` 目录，里面就是你刚才浏览的静态网站。同时还有个新的 `latex` 目录，因为你允许了 Doxygen 生成 LaTeX 输出。

This directory does not contain any PDF yet, but it has a make.bat file, which you can run. Now, this batch file requires a LaTeX processor, and I've installed MikTeX. But eventually, the make batch produces PDF output called refman.pdf, which looks like this.

这个目录里暂时还没有 PDF，但有个 `make.bat` 文件可以运行。这个批处理需要 LaTeX 处理器，我装的是 MikTeX。最终，make 批处理会生成一份叫 `refman.pdf` 的 PDF 输出，长这样。

Before moving on, save the doxywizard project, which creates the file Doxyfile in the project directory.

继续之前，先保存 doxywizard 项目，这样会在项目目录下生成一个 Doxyfile 文件。

Now, let's move on to example1, which already has its Doxyfile, so let's open this one in doxywizard.

接下来看 example1，它已经有自己的 Doxyfile 了，在 doxywizard 里打开它。

Note that the version number for example1 is 0.0.1.

注意 example1 的版本号是 0.0.1。

Now, let's compare the whole example0 directory with example1 to see the differences.

来对比一下 example0 和 example1 的区别。

The header.h file contains the same code, but now it has the special doxygen comments.

`header.h` 的代码是一样的，但多了特殊的 doxygen 注释。

These doxygen comments are just comments, so the compiler ignores them. Actually, so does doxygen, unless the comment starts with a special character.

这些 doxygen 注释本质上就是注释，编译器会忽略它们。实际上 doxygen 也会忽略——除非注释以特殊字符开头。

To be processed by doxygen, a multi-line comment must start with an exclamation point or a star. A single-line, double-slash comment must start with, again, an exclamation point or a slash.

要让 doxygen 处理，**多行注释**必须以感叹号（`!`）或星号（`*`）开头。**单行双斜杠注释**同样必须以感叹号或额外的斜杠（`/`）开头。

Most often, the doxygen comment must precede the documented element, but doxygen also supports comments after the element when they additionally start with the less-than character.

大多数情况下，doxygen 注释要放在被文档化的元素前面。不过 doxygen 也支持放在后面，只要额外加一个小于号（`<`）。

Inside the doxygen comments, you can see some special doxygen commands that start with an ampersand or a backslash. To use doxygen effectively, you need to learn about the available commands, but here you see some of the frequently used ones. The @brief command provides a brief description of the element, @par command starts a paragraph with a title, and @param command documents a function parameter.

在 doxygen 注释里，你会看到一些以 `@` 或反斜杠开头的特殊命令。要用好 doxygen，你得了解这些命令。这里出现的是几个常用的：`@brief` 给出简要描述，`@par` 开始一个带标题的段落，`@param` 用来描述函数参数。

Compared to example0, example1 adds a new file main.dox, which consists of one big doxygen comment. This file provides the main page with the description of the project. Here, you can see that doxygen allows you to create textual documentation of any kind, not just code comments.

和 example0 相比，example1 多了一个新文件 `main.dox`，整个文件就是一个大的 doxygen 注释。它提供了项目的主页和描述。你可以看到，doxygen 不只能给代码加注释，还能创建各种类型的文本文档。

Again, this textual documentation uses some doxygen commands, such as mainpage, section, verbatim, or reference. You can also see an example of using an image in the documentation.

同样，这些文本文档也用到了一些 doxygen 命令，比如 `mainpage`、`section`、`verbatim`、`reference`。你还能看到在文档里插入图片的例子。

Finally, let's look at the difference between Doxyfiles. The version number in example1 has changed to 0.0.1. The project logo has been changed to the relative path instead of the absolute path previously, the image path has been added as .., meaning relative directory one level up, and the HTML option GENERATE_TREEVIEW has been changed to YES.

最后看看 Doxyfile 的变化。版本号改成了 0.0.1。项目图标从之前的绝对路径改成了相对路径。图片路径加上了 `..`，指上一级目录。HTML 选项 `GENERATE_TREEVIEW` 改成了 YES。

You can access and change all these options from doxywizard, but now you should use the "Expert" tab.

这些选项都可以在 doxywizard 里改，不过现在要用"Expert"选项卡。

So, finally, you can run doxygen and view the generated HTML output.

好了，现在可以运行 doxygen，查看生成的 HTML 输出。

This time, you can see the main page generated from your main.dox file and the tree view along the left edge.

这次你能看到从 `main.dox` 生成的主页，左边还有树形导航。

The generated links from the ref commands allow quick navigation, for example, to the header.h file, which now contains all the brief descriptions, detailed descriptions, and parameter descriptions.

`ref` 命令生成的链接可以快速跳转，比如跳到 `header.h` 文件——现在里面已经有了简要描述、详细描述和参数描述。

The last example, number 2, shows how you can add a formal specification, such as a software requirements specification SRS. The goal is to represent the requirements so that doxygen can display, reference, and search the individual requirement work items.

最后一个示例——示例 2，演示了怎么添加正式规约，比如**软件需求规约**（Software Requirements Specification, SRS）。目标是把需求表示成 doxygen 能展示、引用和搜索的独立需求工作项。

There are a couple of ways to achieve this, but the simplest way, applied later in Spexygen, is to represent work items as doxygen subsections. You'll see in a minute how this looks and works.

有几种实现方式，但最简单的（Spexygen 后来也采用了这个方法）是把工作项表示成 doxygen 的子节。马上你就能看到具体效果。

However, once the work items are specified, you can reference them from other work items or code items. This is the explicitly provided backward traceability.

一旦定义好了工作项，你就可以从其他工作项或代码项里引用它们。这就是显式提供的后向追溯。

One more thing I wanted to point out with example2 is that the SRS can be incorporated as a subpage of the main page.

关于 example2 还有一点：SRS 可以作为主页的子页面嵌入进来。

When it comes to generating the HTML and LaTeX outputs, you could do this from doxywizard. But you can also do this directly from a command prompt, where you change to the project directory and type doxygen. The Doxygen directory should be added to your path during installation. When you launch it, Doxygen will look for the Doxyfile and process it if found.

生成 HTML 和 LaTeX 输出，可以在 doxywizard 里做，也可以直接在命令行里做。切换到项目目录，输入 `doxygen` 就行。安装时 Doxygen 的目录应该已经加到了你的 PATH 里。运行时，Doxygen 会自动找 Doxyfile 并处理它。

The generated HTML output is located in the html directory, where you can just double-click on the index.html file to open it in your browser.

生成的 HTML 输出在 `html` 目录里，双击 `index.html` 就能在浏览器中打开。

So, here is the example2 in HTML. The main page now lists Software Requirements Specification, so let's click it and take a look. The requirement artifacts are clearly visible in the SRS document and the tree view. You can also quickly navigate to the individual requirement items from any view.

这就是 example2 的 HTML 输出。主页上列出了软件需求规约，点进去看看。需求制品在 SRS 文档和树形导航中都清晰可见。从任何视图都能快速跳转到各个需求项。

When you copy a requirement name and paste it into the search box, doxygen finds it.

把需求名称复制到搜索框里，doxygen 就能搜到它。

So, these are all the properties you wanted, but they are enabled by the names assigned to the requirements. In the industry, such names are known as Unique Identifiers or UIDs.

这些都是你想要的特性，而它们之所以能实现，靠的是给需求分配的名称。在行业中，这种名称叫做**唯一标识符**（Unique Identifiers, UID）。

Many naming conventions exist to ensure that the UIDs are indeed unique, but specifically for doxygen, the UIDs should follow the naming restrictions for identifiers in programming languages such as C or Python. You should use only underscores and avoid dashes or dots to separate the various fields in the UIDs.

确保 UID 唯一的命名约定有很多种。但具体到 doxygen，UID 必须遵循编程语言（比如 C 或 Python）中标识符的命名限制。你应该只用下划线，不要用短横线或点号来分隔 UID 的各个字段。

Alright, so example2 shows how far you can push it in pure doxygen. You can write specifications, such as SRS, and you can create your own traceable work artifacts alongside already traceable code artifacts.

好，example2 展示了纯 doxygen 能做到什么程度。你可以编写规约（比如 SRS），也能在已经可追溯的代码制品旁边创建自己可追溯的工作制品。

But there is undoubtedly a lot of room for improvement. First, the specifications can be better structured and better formatted.

但改进空间还很大。首先，规约的结构和格式都可以更好。

But most importantly, the documentation contains only the explicitly created backward traceability links. Of course, you could manually add and maintain forward traceability links as well. However, this would quickly go out of sync with the backward traceability because it would violate the DRY principle (Don't Repeat Yourself).

更关键的是，文档里只有你手动创建的后向追溯链接。当然，你也可以手动加上前向追溯链接并维护它们。但这很快就会和后向追溯不同步——因为它违反了 **DRY 原则**（Don't Repeat Yourself，不要重复自己）。

As mentioned before, forward traceability can and should be generated automatically. Additionally, in any traceability view, the brief descriptions of work artifacts next to the cryptic UIDs would be very useful, so they should also be generated automatically. Which leads us to the Spexygen system that provides precisely the features just described.

前面说过，前向追溯可以、也应该自动生成。而且，在任何追溯视图里，那些晦涩难懂的 UID 旁边如果能附上工作制品的简要描述，那就太有用了——这些也应该自动生成。这正好引出了 Spexygen 系统，它提供的正是这些功能。

First, you need to get Spexygen and put it on your computer. The easiest way is to search for "spexygen" and click on the GitHub link.

首先你得把 Spexygen 下载到电脑上。最简单的方法是搜索"spexygen"，点进 GitHub 链接。

In the GitHub repo, you can just click on the code drop-down and download ZIP.

在 GitHub 仓库页面，点 code 下拉菜单，下载 ZIP 就行。

You can unzip spexygen into the lesson-51 directory.

把 spexygen 解压到 lesson-51 目录里。

Spexygen comes with an example that is very close to the examples you just saw for pure doxygen. So, again, let's examine the differences from the last example2 to see what changes were introduced in the example for Spexygen.

Spexygen 自带的示例跟刚才的纯 doxygen 示例非常接近。我们来对比 example2，看看 Spexygen 的示例引入了哪些变化。

Let's start with the differences in the SRS (Software Requirements Specification).

先看 SRS（软件需求规约）的差异。

On the Spexygen side, you can see that each work item specification starts with the custom Spexygen command @uid, which takes two parameters: the Unique Identifier and the brief description. The @uid command ends with the @enduid custom Spexygen command. Between those two, you can have various line items, such as Description, defined with the @uid_litem custom Spexygen command.

在 Spexygen 这边，你会看到每个工作项规约都以自定义命令 `@uid` 开头，它接收两个参数：唯一标识符和简要描述。`@uid` 命令以 `@enduid` 结束。两者之间可以有各种行项，比如 Description，由 `@uid_litem` 命令定义。

The backward traceability of the work item is specified by the @uid_bw_trace custom Spexygen command. This command takes a parameter "brief," which indicates that you want Spexygen to generate a brief description of the following traced UIDs. The traced UIDs are specified with the @tr custom Spexygen command.

工作项的后向追溯由 `@uid_bw_trace` 命令指定。这个命令接收一个参数"brief"，表示你希望 Spexygen 为后面的追溯 UID 生成简要描述。被追溯的 UID 由 `@tr` 命令指定。

Finally, the custom Spexygen command @uid_fw_trace indicates that you wish Spexygen to generate the forward trace in this precise place of the work item specification. In other words, the @uid_fw_trace command is a placeholder for the generated forward traceability section.

最后，`@uid_fw_trace` 命令告诉 Spexygen 在工作项规约的这个位置生成前向追溯。换句话说，`@uid_fw_trace` 就是前向追溯部分的占位符。

All these commands are documented in the Spexygen manual generated with Spexygen. You can access it from the Spexygen GitHub repo.

所有这些命令都在 Spexygen 的手册里有文档说明（手册本身也是用 Spexygen 生成的）。你可以从 Spexygen 的 GitHub 仓库查看。

Besides being used by Spexygen to correctly parse the specification, the custom commands provide a formal structure for the work items. Of course, you can easily impose your own company's standards on top of those commands. For example, you can have templates of UID line items that must be present for requirements, design, functional safety docs, etc.

这些自定义命令不仅让 Spexygen 能正确解析规约，还给工作项提供了正式的结构。当然，你可以在此基础上加上自己公司的标准。比如，可以定义需求、设计、功能安全文档等必须包含的 UID 行项模板。

Spexygen also provides a separate set of custom commands for specifying code items. These are similar to commands for work items but are used inside the doxygen code comments, where doxygen already applies a specific formatting.

Spexygen 还有一套专门的自定义命令用来描述代码项。这些命令跟工作项的类似，但用在 doxygen 代码注释里面——doxygen 在那里已经有自己的格式了。

You can find examples of the custom code commands in the header.h file. The crucial aspect here is to properly define the UID of the code item, which Spexygen will later use for traceability. The code UID you provide must be recognized by doxygen.

`header.h` 文件里有自定义代码命令的示例。这里的关键是正确定义代码项的 UID，Spexygen 后面要用它来做追溯。你提供的代码 UID 必须能被 doxygen 识别。

Once you prepare your documentation by applying the custom Spexygen commands, the next step is to generate the traceability information. The Spexygen system provides a Python script, spexygen.py, that automates this step. Before you can run this script, however, you need to tell Spexygen which files you'd like to generate and where to generate them. This is done in the configuration file spex.json located in your project directory.

用自定义 Spexygen 命令准备好文档后，下一步就是生成可追溯性信息。Spexygen 提供了一个 Python 脚本 `spexygen.py` 来自动完成这一步。不过在运行之前，你得告诉 Spexygen 要生成哪些文件、生成到哪里。这在项目目录下的配置文件 `spex.json` 里设置。

In this json file, you specify the files you wish to trace, which means collecting the traceability information. You can also specify the output directory for the generated documentation, the name of the include file for Doxygen, and the set of files to generate.

在这个 json 文件里，你指定要追溯的文件（也就是收集可追溯性信息的那些文件）。还可以指定生成文档的输出目录、Doxygen 的 include 文件名，以及要生成哪些文件。

At this point, you're ready to run the spexygen.py script and see what it generates.

好了，现在可以运行 `spexygen.py` 脚本，看看它生成了什么。

At first, you'll run the script manually. For this copy the current project directory and open a command prompt. Change to the project directory and type "python", relative path to the Spexygen directory, and "spexygen.py."

先手动运行一次。复制当前项目目录路径，打开命令提示符，切换到项目目录，然后输入 `python`，接着是到 Spexygen 目录的相对路径，再加上 `spexygen.py`。

In the console output, you can see that Spexygen reported that the requested forward traces for two UIDs were missing, which probably means that you still need to provide some tests.

控制台输出里，你会看到 Spexygen 报告说有两个 UID 的前向追溯缺失——这大概意味着你还需要补充一些测试。

But more interestingly, the spexygen.py script has generated a new folder spex in your project directory. This folder contains the code you told it to generate.

但更有意思的是，`spexygen.py` 脚本在项目目录下生成了一个新文件夹 `spex`，里面就是你让它生成的代码。

To see what Spexygen has done, say, to the SRS document, let's diff the generated srs.dox against the original.

要看看 Spexygen 做了什么，比如对 SRS 文档的改动，我们把生成的 `srs.dox` 和原始文件做个对比。

As you can see, spexygen generated the forward traceability sections and also added the brief descriptions to the backward traceability sections.

可以看到，Spexygen 生成了前向追溯部分，还在后向追溯部分补上了简要描述。

The generated traces include both work items, such as requirements, and code items, such as Foo::x or Foo_ctor(). The forward traceability sections are also recursive, whereas the levels of dependency are indicated by increasing the indentation of the trace commands. You'll see in a minute how this looks in the doxygen HTML output.

生成的追溯既包括工作项（比如需求），也包括代码项（比如 `Foo::x` 或 `Foo_ctor()`）。前向追溯部分也是递归的，依赖层级通过增加 trace 命令的缩进来表示。马上你就能在 doxygen 的 HTML 输出里看到效果。

Speaking of which, the final step is to run Doxygen. But before that, let's examine the Doxyfile because now it needs to contain some Spexygen stuff. First, the Doxyfile includes the Spexyfile from the Spexygen installation directory stored in the SPEXYGEN environment variable. This Spexyfile defines all the custom Spexygen commands you've seen before.

说到这个，最后一步就是运行 Doxygen。不过在运行之前，先看看 Doxyfile——现在它需要包含一些 Spexygen 相关的内容。首先，Doxyfile 会 include 来自 Spexygen 安装目录的 Spexyfile，安装目录存在 `SPEXYGEN` 环境变量里。这个 Spexyfile 定义了你之前看到的所有自定义 Spexygen 命令。

Second, the Doxyfile input comes from two sources: files that were not processed by Spexygen, such as main.dox, and files that were generated by Spexygen, conveniently listed in the generated Spexyinc file in the spex directory.

其次，Doxyfile 的输入来自两个地方：没被 Spexygen 处理过的文件（比如 `main.dox`），以及 Spexygen 生成的文件——后者方便地列在 `spex` 目录下的 Spexyinc 文件里。

Alright, so now let's run Doxygen manually, remembering to define the SPEXYGEN environment variable.

好，现在手动运行 Doxygen，别忘了定义 `SPEXYGEN` 环境变量。

As usual, Doxygen has generated the HTML output in the html folder inside your project directory.

跟之前一样，Doxygen 在项目目录的 `html` 文件夹里生成了 HTML 输出。

Please note the more attractive and modern styling of the doxygen output. This styling is coming from Spexygen, which, in turn, customized it from the doxygen-awesome project.

注意看 doxygen 输出的样式——更漂亮、更现代了。这是 Spexygen 带来的，它的样式是基于 doxygen-awesome 项目定制的。

As you can see, the work items, such as requirements, are consistently formatted with clearly delimited line items and now contain all the backward and forward traceability links.

可以看到，工作项（比如需求）的格式非常统一，行项分隔清晰，而且现在包含了所有的后向和前向追溯链接。

You can easily navigate to any work item or code item. You can also search for them in the doxygen search box.

你可以轻松跳转到任何工作项或代码项，也可以在 doxygen 的搜索框里搜它们。

You've arrived at this final output by running spexygen and doxygen manually, but of course, these two steps can be merged and automated. In fact, the Spexygen example comes with a make.bat batch file, which runs the whole process in one step.

虽然刚才你是手动跑 spexygen 和 doxygen 得到最终输出的，但这两个步骤当然可以合并自动化。事实上，Spexygen 的示例自带了一个 `make.bat` 批处理文件，一步就能搞定整个过程。

By default, this batch file produces HTML, but it can also generate PDF when invoked with the -PDF argument.

默认情况下它生成 HTML，加 `-PDF` 参数也能生成 PDF。

This concludes this quick introduction to Doxygen and Spexygen. Together, these two tools provide a powerful, automated documentation system that is a free alternative to costly commercial solutions.

Doxygen 和 Spexygen 的快速入门就到这里。这两个工具组合起来，提供了一个强大的自动化文档系统，完全可以替代昂贵的商业方案。

The toy example presented here doesn't really do justice to Spexygen's power. However, you can view real-life documentation created with Spexygen by visiting state-machine.com/qpc.

这里展示的只是个简单的示例，没法充分体现 Spexygen 的威力。不过你可以访问 state-machine.com/qpc，看看用 Spexygen 生成的真实项目文档。

Happy documenting, and thank you for watching!

祝你文档编写愉快，感谢观看！

---

## 术语说明 / Terminology Notes

| 英文术语 | 中文翻译 | 说明 |
|---------|---------|------|
| Traceability | 可追溯性 | 工作制品之间关系的显式表示，是功能安全文档系统的基石 |
| Backward traceability | 后向追溯 | 从一个工作制品出发，往回链接到上游制品 |
| Forward traceability | 前向追溯 | 从原始制品出发，链接到所有下游工作项，应自动生成 |
| Bi-directional traceability | 双向可追溯性 | 后向追溯与前向追溯的结合，功能安全认证所需 |
| Impact analysis | 影响分析 | 识别修改某个制品会带来哪些潜在影响，需要递归的前向追溯 |
| Work artifact | 工作制品 | 开发过程中产生的任何可追溯的工作项，如需求、代码、测试等 |
| Formal specification | 正式规约 | 遵循特定结构和格式的规范性文档，如需求规约、架构设计等 |
| Unique Identifier (UID) | 唯一标识符 | 分配给需求等工作项的唯一名称，用于追溯和引用 |
| Software Requirements Specification (SRS) | 软件需求规约 | 描述软件系统需求的正式文档 |
| Functional safety | 功能安全 | 与系统安全运行相关的标准和方法，如 IEC 61508 |
| IEC 61508 | IEC 61508 标准 | 国际电气/电子/可编程电子安全相关系统的功能安全标准 |
| Application Lifecycle Management (ALM) | 应用生命周期管理 | 管理软件开发全生命周期的工具和方法 |
| Doxygen | Doxygen | 从源代码生成文档的开源工具，广泛使用 |
| Doxyfile | Doxyfile | Doxygen 的配置文件，控制文档生成的各项设置 |
| doxywizard | doxywizard | Doxygen 提供的图形化配置向导工具 |
| Spexygen | Spexygen | 基于 Doxygen 的开源扩展，用于创建可追溯的正式规约 |
| DRY principle (Don't Repeat Yourself) | DRY 原则（不要重复自己） | 软件工程原则，避免重复维护相同信息以防不同步 |
| `@uid` command | `@uid` 命令 | Spexygen 自定义命令，定义工作项的唯一标识符和简要描述 |
| `@uid_bw_trace` command | `@uid_bw_trace` 命令 | Spexygen 自定义命令，指定工作项的后向追溯 |
| `@uid_fw_trace` command | `@uid_fw_trace` 命令 | Spexygen 自定义命令，作为前向追溯部分的占位符 |
| `@tr` command | `@tr` 命令 | Spexygen 自定义命令，指定被追溯的 UID |
| `spex.json` | `spex.json` | Spexygen 的配置文件，指定要追溯的文件和生成选项 |
| `spexygen.py` | `spexygen.py` | Spexygen 提供的 Python 脚本，自动生成追溯信息 |
| MikTeX | MikTeX | Windows 平台上的 LaTeX 排版系统 |
| doxygen-awesome | doxygen-awesome | Doxygen HTML 输出的现代化样式主题项目 |
