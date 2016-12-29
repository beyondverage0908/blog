# iOS开发文档

## 项目常量，变量，方法，类，类别的命名规则

1. 基本原则

	1.1 清晰

	又清晰又简洁是最好的了，但简洁不如清晰重要。总的讲不要使用单词的简写，除了非常常用的简写以外，尽量使用单词全称。API的名称不要有歧义，一看你的API就知道是以什么方式做了什么事情，不要让人有疑问

	1.2 一致性

	做某个事情代码通常都叫这个名字，比如tag、setStringValue，那么你也这么叫。你在不确定怎么起名字的时候，可以参考一些常用的名字：Method Arguments

2. 类命名

	类名用大写开头的大驼峰命名法。类名中应该包含一个或多个名词来说明这个类（或者类的对象）是做什么的。
	
	在应用级别的代码里，尽量不要使用带前缀的类名。每个类都有相同的前缀不能提高可读性。不过如果是编写多个应用间的共享代码，前缀就是可接受并推荐的做法了(型如 JKPhotoBrowser )。
	
	示例1：
	
		@interface ImageBrowseView :UIView
	
		@end
	
	
	示例2：（带前缀JK）
	
		@interface JKPhotoBrowser :UIView
	
		@end


3. 类别命名

	类名+扩展（UIImageView+Web）
	
	例：如果我们想要创建一个基于UIImageView 的类别用于网络请求图片，我们应该把类别
	
	放到名字是UIImageView+Web.h的文件里。UIImageView为要扩展的类名，类别的方法应该都使用一个前缀(型如categoryMethodOnAString ),以防止Objective-C代码在单名空间里冲突。
	
	
	类别HPWeb头文件，UIImageView+HPWeb.h如下：
	
		@interface UIImageView (HPWeb)
		
		- (void)hp_setImageWithURLString:(NSString *)urlStr;
		
		@end

4. 方法命名 

	方法使用小驼峰法命名, 一个规范的方法读起来应该像一句完整的话，读过之后便知函数的作用。执行性的方法应该以动词开头，小写字母开头，返回性的方法应该以返回的内容开头，但之前不要加get。
	
	示例：
	
		- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
		- (instancetype)arrayWithArray:(NSArray *)array;
	
	
	如果有参数，函数名应该作为第一个参数的提示信息，若有多个参数，在参数前也应该有提示信息（一般不必加and）一些经典的操作应该使用约定的动词，如initWith,insert,remove,replace,add等等。

5. 变量命名 

	变量名使用小驼峰法, 使变量名尽量可以推测其用途属性具有描述性。别一心想着少打几个字母，让你的代码可以迅速被理解更加重要。

	5.1 类成员变量：

	成员变量用小驼峰法命名并前缀下划线，Objective-C 2.0，@property 和 @synthesize 提供了遵守命名规范的解决方法



	示例：
		
		@interface ViewController ()
		
		@property (nonatomic,strong)NSMutableArray    *dataArray;
		@property (nonatomic,strong)UITableView       *tableView;
		
		@end
		
		@implementation ViewController
	
		@end


	5.2 一般变量命名 
	
	示例：
	
		NSMutableArray  *ticketsArray = [NSMutableArrayarrayWithCapacity:0];  
		NSInteger numCompletedConnections =3;
	
	5.3 常量命名 
	
	常量(预定义，枚举，局部常量等)使用小写k开头的驼峰法，比如kInvalidHandle,kWritePerm 
	
	示例：

		#define kRunAnnotationStartPointTitle     @"起点"

		typedef NS_ENUM (NSInteger,RunGoalTypeE){
		    kRunGoalTypeNone       = 0,    //无目标
		    kRunGoalTypeTime       = 1,    //以时间为目标
		    kRunGoalTypeDistance   = 2,    //以距离为目标
		    kRunGoalTypeCalori     = 3,    //以消耗卡路里为目标
		};


		NSString *const kGroupInfoName =@"name";
		
## 项目结构介绍

1. 项目大部分采用Storyboard进行布局，针对每一个模块创建一个对应的Storyboard，便于对storyboard进行管理

	![](/Users/pingjunlin/Desktop/projectImg/storyboard@2x.png)

2. 项目中的所有ViewController都继承于BaseViewController,基类的Controller定义了controller的基本属性。如下的VHSLoginViewController

	![](/Users/pingjunlin/Desktop/projectImg/loginVC@2x.png)
	
3. 与H5端交互，通用一个"PublicWKWebViewController"
4. "VHSStepAlgorithm"属于手环和手机数据存储的逻辑交互层，会和"VHSDataBaseManager"，"DBSafetyCoordinator"进行交互

	4.1 "VHSDataBaseManager"负责和数据库交互
	
	4.2 "DBSafetyCoordinator"负责对运动数据进行加密

5. 项目使用Pod进行包管理，只需要在"Podfile"添加，然后执行"pod install"即可

	![](/Users/pingjunlin/Desktop/projectImg/podmanager@2x.png)


