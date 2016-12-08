## iOS下的Url Scheme

在iOS的Application中。每一个应用都存在于一个沙盒路径中，应用和应用之间是不能进行数据访问的。

但是在某些情况下，需要进行app间的数据传递。另一种情况下是，需要用appA打开appB，最熟悉的情况莫过于打开支付宝。

有趣的是，苹果提供了供我们进行app间调用的方法——Url Scheme.

************

* 交互场景

appA点击某个按钮，打开appB

* 步骤

	1. appB需要在对应的plist中设置URL types，其中包括四个要素。

	**identifier :** identifier:表示这个UrlType的唯一表示，一般都是用域名反转的方式，如com.riyunyuan.vplus.test，
	
	**Url Schemes :** `Url Schemes`，对应的是一个数组，可以添加很多子项，只需要一个字符串就可以，例如填写`vplustest`
	
	![plist配置](/Users/pingjunlin/Desktop/屏幕快照 2016-11-16 19.18.24.png)

	2. 利用Url Scheme
	
	**Safari :** 在Safari地址栏中输入`vplustest://`就可以打开应用
	
	**使用appA :**
	
		- (IBAction)openOtherBtn:(id)sender {
    		NSString *vhealthUrlType = @"vplustest://query=25&name=125";
    		UIApplication *app = [UIApplication sharedApplication];
    		if ([app canOpenURL:[NSURL URLWithString:vhealthUrlType]]) {
        		[app openURL:[NSURL URLWithString:vhealthUrlType]
        	     		options:@{@"param1" : @"10000"}
   			completionHandler:^(BOOL success) {
       		NSLog(@"打开vhealth成功");
             }];
    		}
		}	
		
	**这里通常会报一个错误，`This app is not allowed to query for scheme **`，这里是需要在appA中的plist中使用`LSApplicationQueriesSchemes`，在对应的item中为vplustest**
	![plist](/Users/pingjunlin/Desktop/屏幕快照 2016-11-16 19.48.14.png)
	
	就可以打开了
	
	**传参**
	
	了解三个函数，需要appB中实现，用于接收从appA传递过来的参数
	
	// iOS2.0 ~ iOS9.0
	`- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url`
	
	// iOS4.x ~ iOS9.0 
	`    				
	- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation`
    
  	// iOS9.0 之后 
   `- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0)`
   
 	三个函数作用相同，都是用于其他app调用，返回YES就表示可以被调用
 	
 	
 	> 参数携带方式`vplustest://?query=25&name=125`
	
	1. 在appB中可以直接拿到url = vplustest://?query=25&name=125，
	2. 可以使用`[url query]`得到`query=25&name=125`。
	3. BundleId: 在最新的iOS9.0之后的api中可以获取options对应key为`UIApplicationOpenURLOptionsSourceApplicationKey`获取到appA的BundleId
	4. BundleId: 之前的api，可以使用`sourceApplication`参数获取

	获取到参数，就可以做具体的操作了