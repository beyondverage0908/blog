# Finding Work - 劣实iOS基础二

## objc中向一个nil对象发送消息会怎么样？

**首先明确一点，在OC中对一个nil对象发送消息是有效的，不会有错误**

1. 对象是`nil`，该对象去调用一个方法，该方法的返回值是一个对象，此时返回的nil(0).如下：
	
		Dog *littleDog = [[Dog female] born];
	
	方法female的返回值是一个`nil`，发送消息born，返回值也是`nil`(0)
	
2. 当向一个`nil`对象发送消息，返回值是一个结构体，则返回值是0，结构体中属性的值都为0
3. 当返回值是一个指针类型，则等于`sizeof(void *)`
4. 当返回值是`int`,`float`,`NSInteger`,`double`,`long double`等常量类型，返回值都是0
5. 当返回值不是上述几种，则返回值为未定义

> 主要原因是因为，一个方法的调用，会在编译期间翻译成objc_msgSend(receiver, selector, args1, args2, ....)。在运行时才真正知道selector的具体实现。

看下`runtime.h`中的定义
	
	// 定义在runtime.h
	struct objc_class {
	    Class isa  OBJC_ISA_AVAILABILITY; // isa指针指向Meta Class元类，由于OC中ObjC的类也是一个对象，为了处理好之间的关系，所以运行时会创建一个Meta Class元类，用于存放类的类方法。所以[NSObject alloc]发送的消息，其实是发送给NSObject自己，也表明`alloc`是一个类方法。
	
	#if !__OBJC2__
	    Class super_class                       OBJC2_UNAVAILABLE; // 父类
	    const char *name                        OBJC2_UNAVAILABLE; // 类名
	    long version                            OBJC2_UNAVAILABLE; // 类版本，默认为0
	    long info                               OBJC2_UNAVAILABLE; // 类的相关信息
	    long instance_size                      OBJC2_UNAVAILABLE; // 类实例变量的大小
	    struct objc_ivar_list *ivars            OBJC2_UNAVAILABLE; // 成员变量的列表
	    struct objc_method_list **methodLists   OBJC2_UNAVAILABLE; // 类中的实例方法列表
	    struct objc_cache *cache                OBJC2_UNAVAILABLE; // 方法的缓存，主要用于优化。即当一个方法被调用，会被放到该缓存中，方便下次调用，需要要再去检索方法列表。
	    struct objc_protocol_list *protocols    OBJC2_UNAVAILABLE; // 协议列表
	#endif
	
	} OBJC2_UNAVAILABLE;

简述对象调用方法(向一个对象发送消息)的过程：  

**对象的isa指针会找到该对象所属的类，之后先从cache中查找方法运行，如果有则调用，如果没有则从方法列表及其父类的方法列表查找运行，之后在发送消息的时候。objc_msgSend(receiver, selector)不回立即有返回值，而是调用具体内容时候才执行。**

> 由上可知，本题中对象一开始就为nil，则对象的isa指针就是为0地址了，所以也不会寻找到其所属的类，故而无法去寻找方法，也不会报错。 

## 程序什么时候会报unrecognized selector的异常？

这是一个运行时报错，意为无法捕获到对应的方法，具体的场景是在.h文件中有方法的申明，.m中没有具体的实现。

> 亦如上题，对象的isa指针会找到对应的类，并从类中的method list和父类的method list中去查找方法的实现，如果直到最顶层都没有找到，就会抛出异常。unrecognized selector send to xxx;

当出现如上场景是，objc运行时可以让开发者对此种错误进行补救，使的程序不会crash掉。总的是三种方案：  

1. Method resolution  
2. Fast forwarding
3. Normal forwarding

具体的如何进行补救，可以参照这个以前的一篇文章[Runtime - 消息转发](http://www.jianshu.com/p/ee92f26ee35b)和其中对应的demo[RuntimeOfMessageTransation](https://github.com/beyondverage0908/RuntimeOfMessageTransation)

## 一个objc对象如何进行内存布局？（考虑有父类的情况）

* 我的理解是一个实例对象(instance class)，就是一块内存。对于一个实例对象(内存)中，**最前面存放的是一个isa指针，之后存放着父类的实例变量，在之后存放的是本类的实例变量。**

那如何证明我上面说的呢：

现在我创建一个如下关系(箭头指向代表继承关系)的类：`SonViewController`->`SuperViewController`->`UIViewController`

在类`SuperViewController`和`SonViewController`都简单的设置了实例变量，然后使用Xcode的debug模式下，使用lldb的p命令打印实例对象(instance class)的内部结构.
	
	(lldb) p *sonVC
	(SonViewController) $0 = {
	  SuperViewController = {
	    UIViewController = {
	      UIResponder = {
	        NSObject = {
	          isa = SonViewController
	        }
	      }
	    }
	    // 这是笔者添加的注释：父类SuperViewController的实例变量
	    _defineSuperString = 0x000c215c @"super string"
	    _defineSuperArray = nil
	    _innerSuperString = nil
	  }
	  // 这是笔者添加的注释：当前类SonViewController的实例变量
	  _sonString = 0x000c216c @"son string"
	  _innerSonString = nil
	}

如上结构，证明了——对于一个实例对象(内存)中，**最前面存放的是一个isa指针，之后存放着父类的实例变量，在之后存放的是本类的实例变量。**

~~在Objective-C2.0之前其实我们还可以利用lldb的p命令查看上面结构中isa指向的内容结构~~

> 这就是一个Class或者说objc_class结构在内存中的样子。其实在Objective-C2.0之前这个结构的定义是暴露给用户的，但在Objective-C2.0中，水果公司将它隐藏起来了。经过在网上的查找，发现在Objective-C2.0之前其定义大致如下：

	(gdb) p *dialUNC->isa
	$2 = {
	    isa = 0x1bebc30, 
	    super_class = 0x1bebba4, 
	    name = 0xd5dd8d0 "?", 
	    version = 45024840, 
	    info = 223886032, 
	    instance_size = 43102048, 
	    ivars = 0x1bebb7c, 
	    methodLists = 0xd5dab10, 
	    cache = 0x2af0648, 
	    protocols = 0xd584050
	}

是不是感觉很眼熟的样子，没错，其定义在`runtime.h`头文件中，如下

	// 定义在runtime.h
	struct objc_class {
	    Class isa  OBJC_ISA_AVAILABILITY; // isa指针指向Meta Class元类，由于OC中ObjC的类也是一个对象，为了处理好之间的关系，所以运行时会创建一个Meta Class元类，用于存放类的类方法。所以[NSObject alloc]发送的消息，其实是发送给NSObject自己，也表明`alloc`是一个类方法。
	
	#if !__OBJC2__
	    Class super_class                       OBJC2_UNAVAILABLE; // 父类
	    const char *name                        OBJC2_UNAVAILABLE; // 类名
	    long version                            OBJC2_UNAVAILABLE; // 类版本，默认为0
	    long info                               OBJC2_UNAVAILABLE; // 类的相关信息
	    long instance_size                      OBJC2_UNAVAILABLE; // 类实例变量的大小
	    struct objc_ivar_list *ivars            OBJC2_UNAVAILABLE; // 成员变量的列表
	    struct objc_method_list **methodLists   OBJC2_UNAVAILABLE; // 类中的实例方法列表
	    struct objc_cache *cache                OBJC2_UNAVAILABLE; // 方法的缓存，主要用于优化。即当一个方法被调用，会被放到该缓存中，方便下次调用，需要要再去检索方法列表。
	    struct objc_protocol_list *protocols    OBJC2_UNAVAILABLE; // 协议列表
	#endif
	
	} OBJC2_UNAVAILABLE;
	
	
看到这里，你是不是晕B了，最上面有一个指向`SonViewController`的isa指针，这里又有一个定义为`Class`(`typedef struct objc_class *Class;`)的isa指针，那它们有什么区别。快告诉我吧😓。这里会有一段论述：

**在OC中，会存在实例对象(instance object)，类对象(class object)，和元类对象(metaclass object)。  
实例对象：很容易理解。  
类对象：在OC中每一个类也会对应一个类对象，其中存在放着实例对象的成员变量列表，属性列表，方法列表，指向父类的superclass指针。  
元类对象：为了区分类对象，运行时库会为每个类创建一个元类对象，用于存放该类的类方法，其中也有一个superclass指针，指向元类对象的父类**

所以：实例对象中的isa指针指向的是对象所属的类对象，而类对象中的isa指针指向的是元类对象。

下面盗用两种图，用以说明问题：

继承关系：

![类的继承关系](/Users/user/MyMD/pic resource/111111.jpg)

内存结构：

![内存关系结构图](/Users/user/MyMD/pic resource/22222.png)



你还可以从这里看到更详细的：	
[Objective-C内存布局](http://www.cnblogs.com/csutanyu/archive/2011/12/12/Objective-C_memory_layout.html)

## 你如何理解OC中的`self`和`super`

先从网上拷贝一道题：下面的代码会输出什么

 	@implementation Son : Father
    - (id)init
    {
        self = [super init];
        if (self) {
            NSLog(@"%@", NSStringFromClass([self class]));
            NSLog(@"%@", NSStringFromClass([super class]));
        }
        return self;
    }
    @end

答案： 

本着都自己操作一遍的原则，输出结果结果都是Son

	2016-06-26 11:00:35.509 AutoreleasePool[16854:1718107] Son
	2016-06-26 11:00:35.509 AutoreleasePool[16854:1718107] Son

题目来自[刨根问底Objective－C Runtime（1）－ Self & Super](http://chun.tips/blog/2014/11/05/bao-gen-wen-di-objective%5Bnil%5Dc-runtime(1)%5Bnil%5D-self-and-super/)

> 很多人会想当然的认为“ super 和 self 类似，应该是指向父类的指针吧！”。这是很普遍的一个误区。其实 super 是一个 Magic Keyword， 它本质是一个编译器标示符，和 self 是指向的同一个消息接受者！他们两个的不同点在于：super 会告诉编译器，调用 class 这个方法时，要去父类的方法，而不是本类里的。
> 
> 当使用 self 调用方法时，会从当前类的方法列表中开始找，如果没有，就从父类中再找；而当使用 super 时，则从父类的方法列表中开始找。然后调用父类的这个方法。

我们可以继续探究为什么

如上博文中使用OC中的clang命令重写Son.m文件(不会clang命令——[使用clang命令行工具编译链接Objective-C应用程序](http://blog.csdn.net/pucker/article/details/7291240))

	clang -rewrite-objc Son.m
	
会得到一个Son.cpp文件，非常大，100000+行，建议用sublime编辑器打开。在文件的尾部，有对OC的C++实现

	// @implementation Son


	static instancetype _I_Son_init(Son * self, SEL _cmd) {
	    if (self = ((Son *(*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("Son"))}, sel_registerName("init"))) {
	        NSLog((NSString *)&__NSConstantStringImpl__var_folders_w2_nlhh1qs924sg_t6_72yc95b00000gn_T_Son_04092c_mi_0, NSStringFromClass(((Class (*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("class"))));
	        NSLog((NSString *)&__NSConstantStringImpl__var_folders_w2_nlhh1qs924sg_t6_72yc95b00000gn_T_Son_04092c_mi_1, NSStringFromClass(((Class (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("Son"))}, sel_registerName("class"))));
	    }
	    return self;
	}
	
	
	// @end
	
虽然本人C++功底不是很强😢，亦可以从上C++文件中得到如下信息：

`[self class]`:	  
被翻译成`objc_msgSend(receiver, selector)`=>`objc_msgSend(self, sel_registerName("class"))`  
所以，此处消息接受者即为Son，故打印Son

`[super class]`:  
 被翻译成`objc_ objc_msgSendSuper({receiver, class_getSuperclass(objc_getClass("Son"))}, selector)`=>`objc_ objc_msgSendSuper({self, class_getSuperclass(objc_getClass("Son"))}, sel_registerName("class"))`
 
 而`{self, class_getSuperclass(objc_getClass("Son"))}`返回的是Son的父类，但是此处消息的接受者self亦为Son，故而打印`[super class]`的结果也是Son
 
 **到此，结束**
 
**扩展**
 
 上文代码中的`Class *`是一个typedef
 
 	typedef struct objc_class *Class;
 	
 
`__rw_objc_super`定义：

	struct __rw_objc_super { 
		struct objc_object *object; 
		struct objc_object *superClass; 
		__rw_objc_super(struct objc_object *o, struct objc_object *s) : object(o), superClass(s) {} 
	};

## 如何在OC中使用C++或C