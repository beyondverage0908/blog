# 关于使用WKWebView时，ViewController不调用dealloc方法的记录


在当前的项目中，会嵌入很多的H5页面，所以就考虑封装一个Controller，用于完全的显示H5页面。基于当前项目对iOS版本的支持在iOS8.0之上，所以选用`WKWebView`。

很正常的在`ViewDidLoad`中初始化，设置`WKWebView`

	- (void)setupWKWebView {
    	WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    	WKUserContentController *controller = [[WKUserContentController alloc] init];
    	configuration.userContentController = controller;
    	self.contentWKWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, SCREENW, SCREENH - NAVIAGTION_HEIGHT)
                                               configuration:configuration];
    	self.contentWKWebView.UIDelegate = self;
    	self.contentWKWebView.navigationDelegate = self;
    	self.contentWKWebView.allowsBackForwardNavigationGestures = YES;
    	// 监听进度条
    	[self.contentWKWebView addObserver:self
                            forKeyPath:@"estimatedProgress"
                               options:NSKeyValueObservingOptionNew context:nil];
		
		// 注册JS交互对象
		WKUserContentController *controller = self.contentWKWebView.configuration.userContentController;
    	[controller addScriptMessageHandler:self name:@"vhswebview"];
	}
	
然后加载H5页面，一切看着都很正常，但是经过多次测试，发现对应的`- (void)dealloc;`一次都没有调用，所以必然出现了内存泄漏。检查该`Controller`代码，发现诸如block的循环引用，代理等地方都没有问题。

最后猜测是否是注册JS交互对象的时候，将对象本身`self`传给`MessageHandler`导致的。后面查询了一些资料，发现在Apple的development中提到了需要移除JS交互对象`removeScriptMessageHandlerForName`。

所以将页面关闭`WKWebView`的`Controller`的时候，就去移除JS交互对象

	WKUserContentController *controller = self.contentWKWebView.configuration.userContentController;
    [controller removeScriptMessageHandlerForName:@"vhswebview"];
    
最后，就可以在关闭页面后调用`dealloc`了。
