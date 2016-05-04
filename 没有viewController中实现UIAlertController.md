## 没有viewController中实现UIAlertController



> 在最新的iOS的api中，使用了UIAlertController代替了iOS7及其以下的UIAlertView，同时取消了UIAlertView的代理方法。UIAlertController在Controller中使用是十分方便的，但是不尽人意的是，在很多其他情况下，我们需要在其他环境中使用UIAlertController.

1. 介绍UIAlertView
UIAlertView中能在iOS7及其以下的系统中使用，UIAlertView官方文档。主要是生成一个alertView,通过实现的它对应的代理方法，来实现不同按钮对应的不同的业务逻辑。具体的方法可以参照Apple的文档，很详细。

2. 在ViewController中实现UIAlertController
UIAlertController文档，UIAlertController主要是为了替换UIAlertView和UIActionSheet类，自iOS8之后有效。

(1).创建UIAlertController

	+ (instancetype)alertControllerWithTitle:(NSString*)title message:	(NSString*)message preferredStyle:(UIAlertControllerStyle)preferredStyle

其中通过属性UIAlertControllerStyle来区分创建的是UIAlertView类型，还是UIActionSheet类型。

(2).新增UIAlertAction

UIAlertController的对象是通过新增的UIAlertAction对象来进行单击反馈的。所以要创建UIAlertAction对象。

	+ (instancetype)actionWithTitle:(NSString*)title style:(UIAlertActionStyle)style 	handler:(void (^)(UIAlertAction *action))handler

之后通过

	- (void)addAction:(UIAlertAction*)action

方法将Action添加到UIAlertController对象实例中。

备注：

1. 在action的block中，就是该action触发的处理事件(handler)。
2. 可以通过配置action的UIAlertActionStyle属性来展示action的样式。

(3).显示UIAlertController

	[self presentViewController:alertController animated:YES completion:nil];
	
	
* **没有在 ViewController下实现UIAlertController**

首先看一篇文章，就是介绍如何实现在没有ViewController的情况下实现UIAlertController。

> 因为UIAlertController使用只能使用ViewController的presentViewController:animated:completion的方法才能显示。所有在没有直接的ViewController时候，只能想法子找到一个(viewController)或者创建一个。如下demo

(1).首先继承UIAlertController，定制一个自己的UIAlertController(WPSAlertController)

	@interface WPSAlertController :UIAlertController
	
	- (void)show; // 显示，animated = NO
	
	- (void)showAnimated:(BOOL)animated; // 显示 animated = NO or YES
	
	+ (void)presentOkayWithTitle:(NSString*)title message:(NSString*)message；
	
	+ (void)presentOkayAlertWithError:(nullableNSError*)error;
	
	@end
	
(2)核心方法的实现 - (void)showAnimated:(BOOL)animated

.m文件中的实现如下

	@interfaceWPSAlertController()
	
	@property(nonatomic,strong)UIWindow*alertWindow;
	
	@end
	@implementation WPSAlertController
	
	......
	
	// 核心方法 － 自行创建一个rootViewController，
	
	- (void)showAnimated:(BOOL)animated {
	
		UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		[window setBackgroundColor:[UIColor clearColor]];
		UIViewController*rootViewController = [[UIViewController alloc] init];
		[[rootViewController view] setBackgroundColor:[UIColor clearColor]];
		// set window level
		[window setWindowLevel:UIWindowLevelAlert + 1];
		[window makeKeyAndVisible];
		[self setAlertWindow:window];
		[window setRootViewController:rootViewController];
	
		[rootViewController presentViewController:self animated:animated completion:nil];
	}
	
	
	+ (void)presentOkayWithTitle:(NSString*)title message:(NSString*)message {
	
		WPSAlertController*alertController = [WPSAlertController 		alertControllerWithTitle:title message:message 		preferredStyle:UIAlertControllerStyleAlert];
	
		//创建UIAlertAction
	
		UIAlertAction*okayAction = [UIAlertAction actionWithTitle:@"Okay" 		style:UIAlertActionStyleDefault handler:^(UIAlertAction*_Nonnull action) {
	
		// you code for okay action
	
	}];
	
		[alertController addAction:okayAction];
	
		UIAlertAction*errorAction = [UIAlertAction actionWithTitle:@"cancle" 	style:UIAlertActionStyleCancel handler:^(UIAlertAction*_Nonnull action) {
	
		// you code for cancle action
	
	}];
	
		[alertController addAction:errorAction];
		// present the alertController with animated
		[alertControllershowAnimated:YES];
	
	}
	
	@end
	
最后，只需要在需要的地方直接调用+ (void)presentOkayWithTitle:(NSString*)title message:(NSString*)message方法即可。(其他个性化的都可以自行实现)