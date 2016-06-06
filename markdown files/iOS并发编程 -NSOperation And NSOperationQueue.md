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
	2. 创建NSInvocationOperation对象
	3. 创建NSBlockOperation对象

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

* **术语**

> Operation: The NSOperation class is an abstract class you use to encapsulate the code and data associated with a single task.

解释：Operation是一个抽象类，用于概括由一段代码和数据组成的任务。

> Operation Queue: The NSOperationQueue class regulates the execution of a set of NSOperation objects.

解释： NSOperationQueue用于规则的去执行一系列Operation。

* **串行 vs 并发**

最简单的理解就是，串行和并发是用来修饰是否可以同时执行任务的数量的。串行设计只允许同一个时间段中只能一个任务在执行。并发设计在同一个时间段中，允许多个任务在逻辑上交织进行。(在iOS中，串行和并发一般用于描述队列)
**说个题外话，刚开始是将并发写成并行的，后觉得并发和并行的概念一直挥之不去，可以参考这篇，很赞奥——[还在疑惑并发和并行？](https://laike9m.com/blog/huan-zai-yi-huo-bing-fa-he-bing-xing,61/)**

* **同步 vs 异步**

同步操作，只有当该操作执行完成返回后，才能执行其他代码，会出现等待，易造成线程阻塞。异步操作，不需要等到当前操作执行完，就可以返回，执行其他代码。(一般用于描述线程)

* **队列 vs 线程**

队列用于存放Operation。在iOS中，队列分为串行队列和并发队列。使用NSOperationQueue时，我们不需要自己创建去创建线程，我们只需要自己去创建我们的任务(Operation)，将Operation放到队列中去。队列会负责去创建线程执行，执行完后，会销毁释放线程占用的资源。

*****************************