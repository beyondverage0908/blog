# Method Swizzling - 统计功能

	#import <objc/runtime.h>
	
> 在OC中，最具争议的语法，莫过于`runtime`中的运行时的语法。而其中黑魔法Method Swizzling更让人着迷。

Method Swizzling是一项在运行时，通过改变方法名(SEL)与函数指针之间的映射。从而改变方法实现的黑魔法技术。如下图。

![Method Swizzling模型图.png](http://upload-images.jianshu.io/upload_images/1626952-940656a52c93368a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 场景需求

> 实践是检验真理的唯一标准 - 毛某某

能否快速而可靠的学习到某个技术点，最好的方法，还是找到一个场景，去实现它。项目中，我们经常会有这样的需求，去统计用户每一个页面的访问量，什么时候页面出现，什么时候页面消失。由此获取来的数据，去判断用户黏性，功能点的使用情况的等。对于统计的功能，我们可以交给第三方的厂商，比如百度统计，友盟等。

但是，我们最少需要告诉第三方厂商的库，现在是用户打开了这个页面。现在是用户关闭了这个页面。之前的做法是，在每一个Controller的`- viewDidAppear:`中调用一个用户开始使用的方法。在`- viewDidDisappear`中调用一个用户结束使用的方法。OK了，这个需求解决了。但是随着项目的的增大，发现每一个Controller中都需要写两个一摸一样的方法。这样违背了软件开发的开发准则---"一个方法只写一遍"。

幸好的是，在学习微信阅读开源的一款内存检测工具[MLeaksFinder](https://github.com/Zepo/MLeaksFinder)。其中的代码零侵染，易用性，很好的在开发中帮助我解决了一些内存泄露的问题。而从源码中，MLeaksFinder就是利用了Method Swizzling技术。受该框架启发，也希望实现对代码侵染程度小，却可以很好的实现统计的功能。

### Method Swizzling实现
		
	+ (void)load {
	    static dispatch_once_t onceToken;
	    dispatch_once(&onceToken, ^{
	        [self swizzleSEL:@selector(viewDidAppear:) withSEL:@selector(swizzled_viewDidAppear:)];
	        [self swizzleSEL:@selector(viewDidDisappear:) withSEL:@selector(swizzled_viewDidDisappear:)];
	    });
	}
		
	/// 交换两个方法的实现
	+ (void)swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL {
	    Class class = [self class];
	    
	    Method originalMethod = class_getInstanceMethod(class, originalSEL);
	    Method swizzledMethod = class_getInstanceMethod(class, swizzledSEL);
	    
	    // When swizzling a class method, use the following:
	    // Class class = object_getClass((id)self);
	    // ...
	    // Method originalMethod = class_getClassMethod(class, originalSelector);
	    // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
	    
	    BOOL didAddMethod = class_addMethod(class, originalSEL, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
	    
	    if (didAddMethod) {
	        class_replaceMethod(class, swizzledSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
	    } else {
	        method_exchangeImplementations(originalMethod, swizzledMethod);
	    }
	}
	
	#pragma mark - Swizzled Method
	
	- (void)swizzled_viewDidAppear:(BOOL)animated {
	    [self swizzled_viewDidAppear:animated];
	}
	
	- (void)swizzled_viewDidDisappear:(BOOL)animated {
	    [self swizzled_viewDidDisappear:animated];
	}
	
上面的代码，便已经实现了`- viewDidAppear:`和`- swizzled_viewDidAppear:`方法实现的互换。如果仅仅是拷贝和黏贴，这样已经实现了功能。想要更深的了解运行时的工作机制。还需要了解这部分内容。

#### + (void)load; & + (void)initialize;

load方法和initialize方法都是可选方法。load方法在类初装载的时候被调用，即load方法一定被调用。Method Swizzling同样应该在load方法实现。initailize方法仅在类的实例方法或者类方法第一次调用的时候调用。

#### dispatch_once

由于Method Swizzling触发是全局范围内的。必须保证只触发一次，并且是原子性的，在多线程间也仅仅调用一次。GCD中的dispatch_once很好的符合了要求。同样的，在OC中的单利对象的标准也应该使用这种方式。

#### SEL，Method，IMP

> Selector（typedef struct objc_selector *SEL）:在运行时 Selectors 用来代表一个方法的名字。Selector 是一个在运行时被注册（或映射）的C类型字符串。Selector由编译器产生并且在当类被加载进内存时由运行时自动进行名字和实现的映射。
> 
> Method（typedef struct objc_method *Method）:方法是一个不透明的用来代表一个方法的定义的类型。
> 
> Implementation（typedef id (*IMP)(id, SEL,...)）:这个数据类型指向一个方法的实现的最开始的地方。该方法为当前CPU架构使用标准的C方法调用来实现。该方法的第一个参数指向调用方法的自身（即内存中类的实例对象，若是调用类方法，该指针则是指向元类对象metaclass）。第二个参数是这个方法的名字selector，该方法的真正参数紧随其后。

#### 说说Method Swizzling工作过程

在类初始化，初次装载的时候，执行load方法。找到类维护的方法(包含方法名SEL和映射的实现IMP)列表，修改selector(方法名)和imp(实现体)的映射关系。因此当系统调用系统方法时候，其实调用的是我们自定义的方法。

#### 看似错误的代码

	- (void)swizzled_viewDidAppear:(BOOL)animated {
	    [self swizzled_viewDidAppear:animated];
	}
	
如上，这段代码，对于一个合格的工程师而言，应该会很警惕。正常情况下在类中调用，必然进入无限循环。然而，在Method Swizzling中，这样才是正确的用法。理解下其中的逻辑。在load方法中实现了Swizzling，系统SEL的`viewDidAppear`指向的是`swizzled_viewDidAppear`的实现，方法SEL名为`swizzled_viewDidAppear`指向的是系统名为`viewDidAppear`的实现。所以在调用过程中相当两个方法交叉调用了，并没有导致死循环。
	
### 最后-百度统计逻辑业务代码的实现
	
	#pragma mark - Method Swizzling

	- (void)swizzled_viewDidAppear:(BOOL)animated {
	    [self swizzled_viewDidAppear:animated];
	    
	    NSString *currentControllerTitle = self.title;
	    if (!currentControllerTitle) return;
	    
	    [[BaiduMobStat defaultStat] pageviewStartWithName:currentControllerTitle];
	}
	
	- (void)swizzled_viewDidDisappear:(BOOL)animated {
	    [self swizzled_viewDidDisappear:animated];
	    
	    NSString *currentControllerTitle = self.title;
	    if (!currentControllerTitle) return;
	    
	    [[BaiduMobStat defaultStat] pageviewEndWithName:currentControllerTitle];
	}
	
统计的代码仅仅几行而已，只需要放在`UIControllerView+Traking.m`类别中。不仅减少了项目无关业务逻辑的代码量，同样做到了代码的侵染度很少。

### 思考

引自NSHipster

> 很多人认为交换方法实现会带来无法预料的结果。然而采取了以下预防措施后, method swizzling 会变得很可靠：

> * 在交换方法实现后记得要调用原生方法的实现（除非你非常确定可以不用调用原生方法的实现）：APIs 提供了输入输出的规则，而在输入输出中间的方法实现就是一个看不见的黑盒。交换了方法实现并且一些回调方法不会调用原生方法的实现这可能会造成底层实现的崩溃。

> * 避免冲突：为分类的方法加前缀，一定要确保调用了原生方法的所有地方不会因为你交换了方法的实现而出现意想不到的结果。

> * 理解实现原理：只是简单的拷贝粘贴交换方法实现的代码而不去理解实现原理不仅会让 App 很脆弱，并且浪费了学习 Objective-C 运行时的机会。阅读 Objective-C Runtime Reference 并且浏览 能够让你更好理解实现原理。

> * 持续的预防：不管你对你理解 swlzzling 框架，UIKit 或者其他内嵌框架有多自信，一定要记住所有东西在下一个发行版本都可能变得不再好使。做好准备，在使用这个黑魔法中走得更远，不要让程序反而出现不可思议的行为。