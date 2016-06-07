# iOS 并发编程 - Operation And NSOperation Queue

* 基本概念
	1. 术语
	2. 串行 vs 并发(concurrency)
	3. 同步 vs 异步
	4. 队列 vs 线程

* iOS的并发编程模型

* Operation Queues vs. Grand Central Dispatch (GCD)

* 关于Operation对象
	1. 并发的Operation 和非并发的Operation
	2. 创建NSBlockOperation对象 
	3. 创建NSInvocationOperation对象

* 自定义Operation对象
	1. 执行主任务
	2. 响应取消的事件
	3. 配置并发执行的Operation
	4. 维护KVO通知

* 定制Operation对象的执行行为
	1. 配置依赖关系
	2. 修改Operation在队列中的优先级
	3. 修改Operation执行任务线程的优先级
	4. 设置Completion Block

* 执行Operation对象
	1. 添加Operation到Operation Queue中
	2. 手动执行Operation
	3. 取消Operation
	4. 等待Operation执行完成
	5. 暂停和恢复Operation Queue

* 添加Operation Queue中Operation对象之间的依赖

* 总结

******************************

看过上面的结构预览，下面就开始我们这篇blog

## 术语

> Operation: The NSOperation class is an abstract class you use to encapsulate the code and data associated with a single task.

解释：Operation是一个抽象类，用于概括由一段代码和数据组成的任务。

> Operation Queue: The NSOperationQueue class regulates the execution of a set of NSOperation objects.

解释： NSOperationQueue用于规则的去执行一系列Operation。

## 串行 vs 并发

最简单的理解就是，串行和并发是用来修饰是否可以同时执行任务的数量的。串行设计只允许同一个时间段中只能一个任务在执行。并发设计在同一个时间段中，允许多个任务在逻辑上交织进行。(在iOS中，串行和并发一般用于描述队列)
**说个题外话，刚开始是将并发写成并行的，后觉得并发和并行的概念一直挥之不去，可以参考这篇，很赞奥——[还在疑惑并发和并行？](https://laike9m.com/blog/huan-zai-yi-huo-bing-fa-he-bing-xing,61/)**

## 同步 vs 异步

同步操作，只有当该操作执行完成返回后，才能执行其他代码，会出现等待，易造成线程阻塞。异步操作，不需要等到当前操作执行完，就可以返回，执行其他代码。(一般用于描述线程)

## 队列 vs 线程

队列用于存放Operation。在iOS中，队列分为串行队列和并发队列。使用NSOperationQueue时，我们不需要自己创建去创建线程，我们只需要自己去创建我们的任务(Operation)，将Operation放到队列中去。队列会负责去创建线程执行，执行完后，会销毁释放线程占用的资源。

*****************************

## iOS并发编程模型

对于一个APP，需要提高应用的性能，一般需要创建其它的线程去执行任务，在整个APP的声明周期内，我们需要自己手动去创建，销毁线程，以及暂停，开启线程。对于这创建一个这样的线程管理器，已经是非常复杂且艰巨的任务。但是苹果爸爸为开发者提供了两套更好的解决方案：**[NSOperation](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/NSOperation_class/)**，**[Grand Central Dispatch (GCD) Reference](https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/)**，GCD的方式具体的本文暂不讨论。

使用NSOperationQueue 和 NSOperation的方式是苹果基于GCD再一次封装的一层，比GCD更加的灵活，而且是一种面向对象设计，更加适合开发人员。虽然相对于GCD会牺牲一些性能，但是我们可以对线程进行更多的操作，比如暂停，取消，添加Operation间的依赖。但是GCD如果暂停和取消线程操作则十分的麻烦。

## Operation Queues vs. Grand Central Dispatch (GCD)

> 简单来说，GCD 是苹果基于 C 语言开发的，一个用于多核编程的解决方案，主要用于优化应用程序以支持多核处理器以及其他对称多处理系统。而 Operation Queues 则是一个建立在 GCD 的基础之上的，面向对象的解决方案。它使用起来比 GCD 更加灵活，功能也更加强大。下面简单地介绍了 Operation Queues 和 GCD 各自的使用场景：

> Operation Queues ：相对 GCD 来说，使用 Operation Queues 会增加一点点额外的开销，但是我们却换来了非常强大的灵活性和功能，我们可以给 operation 之间添加依赖关系、取消一个正在执行的 operation 、暂停和恢复 operation queue 等；
> GCD ：则是一种更轻量级的，以 FIFO 的顺序执行并发任务的方式，使用 GCD 时我们并不关心任务的 调度情况，而让系统帮我们自动处理。但是 GCD 的短板也是非常明显的，比如我们想要给任务之间添加依赖关系、取消或者暂停一个正在执行的任务时就会变得非常棘手。

**上引用自[Operation Queues vs. Grand Central Dispatch (GCD)](http://blog.leichunfeng.com/blog/2015/07/29/ios-concurrency-programming-operation-queues/)**

## 关于Operation对象

`NSOperation`对象是一个抽象类，是不能直接创建对象的。但是它有两个子类——`NSBlockOperation`，`NSInvocationOperation`.通常情况下我们都可以直接使用这两个子类，创建可以并发的任务。

我们查看关于NSOperation.h的头文件，可以发现任意的operation对象都可以自行开始任务(start)，取消任务(cancle)，以及添加依赖(addDependency:)和移除依赖(removeDependency:).**关于依赖，有一种很好的一种开发思路**。在operation对象中有很多属性，可以用于检测当前任务的状态，如`isCancelled`:是否已经取消，`isFinished`:是否已经完成了任务。
![NSOperation](/Users/user/Desktop/屏幕快照 2016-06-07 下午8.29.04.png)

* **创建NSBlockOperation**

以下使用到的代码片段取自我的[LSOperationAndOperationQueueDemo]()

`NSBlockOperation`顾名思义，是是用block来创建任务，主要有两种方式创建，一种是是用类方法，一种是创建operation对象，再添加任务。上代码：以下代码包括了两种block创建任务的方式。以及已经有任务的operation对象再添加任务。及直接添加任务到queue中。

	@implementation LSBlockOperation

	+ (LSBlockOperation *)lsBlockOperation {
	    return [[LSBlockOperation alloc] init];
	}
	
	- (void)operatingLSBlockOperation {
	    
	    NSBlockOperation *blockOpt1 = [NSBlockOperation blockOperationWithBlock:^{
	        NSLog(@"-------- blockOpt1, mainThread:%@, currentThread:%@", [NSThread mainThread], [NSThread currentThread]);
	    }];
	    /// 继续添加执行的block
	    [blockOpt1 addExecutionBlock:^{
	        NSLog(@"-------- blockOpt1 addExecutionBlock1 mainThread:%@, currentThread:%@", [NSThread mainThread], [NSThread currentThread]);
	    }];
	    
	    [blockOpt1 addExecutionBlock:^{
	        NSLog(@"-------- blockOpt1 addExecutionBlock2 mainThread:%@, currentThread:%@", [NSThread mainThread], [NSThread currentThread]);
	    }];
	    
	    NSBlockOperation *blockOpt2 = [[NSBlockOperation alloc] init];
	    [blockOpt2 addExecutionBlock:^{
	        NSLog(@"-------- blockOpt2 mainThread:%@, currentThread:%@", [NSThread mainThread], [NSThread currentThread]);
	    }];
	    
	    NSBlockOperation *blockOpt3 = [[NSBlockOperation alloc] init];
	    [blockOpt3 addExecutionBlock:^{
	        NSLog(@"-------- blockOpt3 mainThread:%@, currentThread:%@", [NSThread mainThread], [NSThread currentThread]);
	    }];
	    
	    NSBlockOperation *blockOpt4 = [NSBlockOperation blockOperationWithBlock:^{
	        NSLog(@"-------- blockOpt4 mainThread:%@, currentThread:%@", [NSThread mainThread], [NSThread currentThread]);
	    }];
	    
	    // 添加执行优先级 - 并不能保证执行顺序
	//    blockOpt2.queuePriority = NSOperationQueuePriorityVeryHigh;
	//    blockOpt4.queuePriority = NSOperationQueuePriorityHigh;
	    
	    /// 可以设置Operation之间的依赖关系 - 执行顺序3 2 1 4
	    [blockOpt2 addDependency:blockOpt3];
	    [blockOpt1 addDependency:blockOpt2];
	    [blockOpt4 addDependency:blockOpt1];
	    
	    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	    [queue addOperation:blockOpt1];
	    [queue addOperation:blockOpt2];
	    [queue addOperation:blockOpt3];
	    [queue addOperation:blockOpt4];
	    [queue addOperationWithBlock:^{
	        NSLog(@"-------- queue addOperationWithBlock1 mainThread:%@, currentThread:%@", [NSThread mainThread], [NSThread currentThread]);
	    }];
	    [queue addOperationWithBlock:^{
	        NSLog(@"-------- queue addOperationWithBlock2 mainThread:%@, currentThread:%@", [NSThread mainThread], [NSThread currentThread]);
	    }];
	}
	
* **创建NSInvocationOperation**

`NSInvocationOperation`是另一种可创建的operation对象的类。但是在Swift中已经被去掉了。`NSInvocationOperation`是一种可以非常灵活的创建任务的方式，主要是其中包含了一个`target`和`selector`。假设我们现在有一个任务，已经在其它的类中写好了，为了避免代码的重复，我们可以将当前的`target`指向为那个类对象，方法选择器指定为那个方法即可，如果有参数，可以在`NSInvocationOperation`创建中指定对应的Object(参数).

具体的可以看如下代码：[LSOperationAndOperationQueueDemo]()

	@implementation LSInvocationOperation

	+ (LSInvocationOperation *)lsInvocationOperation {
	    return [[LSInvocationOperation alloc] init];
	}
	
	- (void)operationInvocationOperation {
	    
	    NSInvocationOperation *invoOpt1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invoOperated1) object:self];
	    NSInvocationOperation *invoOpt2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invoOperated2) object:self];
	    
	    // invocated other obj method
	    /// 可以执行其它类中方法，并且可以带参数
	    NSInvocationOperation *invoOpt4 = [[NSInvocationOperation alloc] initWithTarget:[[Person alloc] init] selector:@selector(running:) object:@"linsir"];
	    
	    // 设置优先级 － 并不能保证按指定顺序执行
	//    invoOpt1.queuePriority = NSOperationQueuePriorityVeryLow;
	//    invoOpt4.queuePriority = NSOperationQueuePriorityVeryLow;
	//    invoOpt2.queuePriority = NSOperationQueuePriorityHigh;
	    
	    // 设置依赖 - 线性执行
	    [invoOpt1 addDependency:invoOpt2];
	    [invoOpt2 addDependency:invoOpt4];
	    
	    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	    [queue addOperation:invoOpt1];
	    [queue addOperation:invoOpt2];
	    [queue addOperation:invoOpt4];
	}
	
	- (void)invoOperated1 {
	    NSLog(@"--------- invoOperated1, mainThread:%@, currentThread:%@", [NSThread mainThread],[NSThread currentThread]);
	}
	
	- (void)invoOperated2 {
	    NSLog(@"--------- invoOperated2, mainThread:%@, currentThread:%@", [NSThread mainThread],[NSThread currentThread]);
	}
	
	@end