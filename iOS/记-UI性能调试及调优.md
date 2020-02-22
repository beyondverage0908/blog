# 记-UI性能调试及调优

本文使用的Demo--[UIPerformanceTestDemo](https://github.com/beyondverage0908/MyDemo/tree/master/UIPerformanceTestDemo)，建议下载后跟着后面的步骤玩一次

在最近的一段时间里看了些iOS开发过程中对UI性能方面的调试方法，及如何调优。在以前的开发中并没有对这方给予足够的重视，而是专注于逻辑功能方面的。但毕竟作为手持设备，体验方面的优秀也是项目优秀重要的一部分。

对于开发不是很久的半新手而言，很多东西都是一知半解的，比如在UI性能方面，总会听到几方面的忠告：

	someView.opaque = true //设置不透明
	someView.layer.shouldRasterize = true // 开启光栅化
	smoeView.layer.cornerRadius = 10 // 圆角会触发离屏渲染
    /*
    	设置阴影效果，会影响滑动效果
    */
    someView.layer.shadowRadius = 10
    ...


** 正如以上的几点，我们是不是应该打个问号，为什么要这样做？这样做到底有没有用？经过一系列的操作之后，是不是达到了我们需要的效果？我们应该怎么检测？ **

### UI的测试方式

现在开始介绍

用于检测UI性能有两种方式

1. 使用模拟器，只能检测UI性能方面的几个重要方面，不能监测fps(frame per seconds)。打开方式，运行模拟器，单击Debug，可以看到Color Blended Layers等几项
2. 使用Core Animation，可以检测fps，并且其中有更多的选项对UI性能做测试。但必须使用真机。

注：第一种方式截图


![Debug 调试界面.jpg](http://upload-images.jianshu.io/upload_images/1626952-88d237405349d1d1.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


*****************

本文使用的是第二种方式

### 打开Core Animation 及介绍其界面组成

* 先用真机运行项目，只有停止运行，此时按Command+I，选择Core Animation，进入主界面，可以看到如下的界面，当连接了真机的时候，只需要按左上角的小红色按钮，就可以开始调试了，so easy。


![Core Animation.png](http://upload-images.jianshu.io/upload_images/1626952-7ef569f4887768bd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![调试主界面.png](http://upload-images.jianshu.io/upload_images/1626952-c66abc39add9ca02.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

注：FPS(Frame Per Seconds)每秒的帧数，即一秒钟内界面刷新的次数，iOS推荐推荐的是60.

*****************

### 图层混合(Color Blended Layers)

由于图层的表现形式都是RGBA组成的，当我们多个图层混合的时候，GPU就会去计算最终的颜色是什么，所以会花费一定的时间去计算，比如上层红色RGBA(1,0,0,0.5)，下层绿色RGBA(0,1,0,0.5)，最终得到的颜色就是RGBA(0.5,0.5,0,0.5)。图层混合的性能损耗就在这里，所以应该避免这样的计算，当图层的最上层的alpha值为1(不透明时)，GPU则会忽略其他图层的影响，仅仅表现为最上层的颜色。

**右侧的第一个选项就是检测图层混合的，出现图层混合的地方会使用红色进行标记，所以我们应该尽量不让红色出现**，如下图：


![图层混合.png](http://upload-images.jianshu.io/upload_images/1626952-9217b1044fb05931.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


基于上面的概念

可以知道，尽量保证图层alpha值为为1，并且设置图层的背景色和父控件的颜色保存一致。如前文提到的someView.opaque属性在此处作用并不大，因为view的opaque默认就是true，并且在demo中仅仅对opaque设置，图层依旧出现了图层混合。我们可是设置label的背景色和父控件一致。所以第一个优化就是：

	demoLabel.backgroundColor = UIColor.whiteColor()

** 有趣的是，图层混合不但对原生控件有影响，对图片本身也是有影响的，因为图片自身也有alpha通道值，如上图所示，仅仅只有最后一张图片没有出现红色，所以当你确定的code没有问题时，出现这种情况，你可以找你的设计师撕逼了 **


********************

### 光栅化(Color Hits Green and Misses Red)


如果对栅格化不是很理解，请参考[栅格化-维基百科](https://zh.wikipedia.org/wiki/%E6%A0%85%E6%A0%BC%E5%8C%96)

	someView.shouldRasterize = true // 开启栅格化

在iOS中，栅格化就是将layer矢量图转化为bitmap(位图)，并且存储在缓存中，下次存储的时候就从缓存中读取。从第二个检测选项就可以看出，绿色越多越好，也证明了命中了缓存。没有命中缓存的则以红色显示。

**但是值得注意的是，栅格化会手动触发离屏渲染(之后讲解)，所以并不是所以地方都合适开启栅格化的。并且先将layer转化为bitmap，存入缓存，再从缓存中获取，是需要一定时间的**

比较试用的场景是：

**给列表中的view添加了阴影效果，此时可以利用栅格化将阴影效果缓存起来。之后使用缓存中的阴影效果。**

所以此处给出的优化是

     headerImageView.layer.shouldRasterize = true
     headerImageView.layer.rasterizationScale = UIScreen.mainScreen().scale


**********************

### 图片格式(Color Copied Images)

由于手机显示都是基于像素的，所以当手机要显示一张图片的时候，系统会帮我们对图片进行转化。比如一个像素占用一个字节，故而RGBA则占用了4个字节，则1920 x 1080的图片占用了7.9M左右，但是平时jpg活着png的图片并没有那么大，因为它们对图片做了压缩，但是是可逆的。所以此时，如果图片的格式不正确，则系统将图片转化为像素的时间就有可能变长。而该选项就是检测图片的格式是否是系统所支持的，不支持的用蓝绿色标记。

遗憾的是，在demo中并没有找到不符合的图片格式，所以在示例中没有得到演示。

![图片格式.png](http://upload-images.jianshu.io/upload_images/1626952-2bce0c7fe98e4985.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



*************************

### 图片对齐方式(Color Misaligned Images)

图片对齐是指所给的图片大小(width, height)没有和imageView中的frame的size(width, height)相匹配，会使图片缩放，而缩放的过程会损耗一部分时间。所以做好再coding的时候保证图片的大小匹配好imageView。

该选项可以检测出图片是否匹配frame，不匹配的使用黄色标记，如下图，只有第一张图片不显示黄色，因为imageView是128*128的，图片的大小是256*256，在retina显示正常。

![图片大小对齐.png](http://upload-images.jianshu.io/upload_images/1626952-3b7d143af6033c78.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

此处优化:

**修改imagView的frame坐标，或者是调整图片的size大小**

*****************************

### 离屏渲染(Color Offscreen-Rendered Yellow)

离屏渲染，顾名思义，即发生了在屏幕之外的渲染效果，亦和原来的渲染路线不一致。使用Color Offscreen-Rendered Yellow进行检测，发生离屏渲染的黄色标记。[UIPerformanceTestDemo](https://github.com/beyondverage0908/MyDemo/tree/master/UIPerformanceTestDemo)demo中的检测结果

![离屏渲染检测结果](/Users/user/MyDemo/UIPerformanceTestDemo/DebugPicture/离屏渲染.png)

如下图：第一个是正常的渲染路径，第二个为离屏渲染路径

![正常的渲染路径](/Users/user/Desktop/based-rendering.png)

![离屏渲染路径](/Users/user/Desktop/MaskingRender.jpg)

如上图可以看到离屏渲染路径中，在收到Command Buffer后会额外的多两条路径进行渲染，之后合成最终的Render Buffer并显示。所以离屏渲染会消耗更多的时间。

而触发离屏渲染的可能有如下

	/* 圆角处理 */
	someView.layer.maskToBounds = true
	someView.clipsToBounds = true
	
	/* 设置阴影 */
	someView.shadow..
	
	/* 栅格化 */
	someView.layer.shouldRastarize = true
	

而此处的优化是

* 针对阴影效果做栅格化处理

		headerImageView.layer.shouldRasterize = true
		headerImageView.layer.rasterizationScale = UIScreen.mainScreen().scale
		
* 指定阴影路径，可以防止离屏渲染

		headerImageView.layer.shadowPath = UIBezierPath(rect: headerImageView.bounds).CGPath // 指定阴影曲线，防止阴影效果带来的离屏渲染


这样可以让你的页面的fps保持在50之上，如果此处还需要对imageView做圆角处理，可以参考我的另一篇博文[iOS - 圆角的设计策略 - 及绘画出没有离屏渲染的圆角](http://www.jianshu.com/p/af70feefbc89)

*********************

其它UI检测选项用的比较少，自己也很少用到，待以后熟悉之后在补齐，平时使用最多的就是这些...


*********************

### 总结

* 图层混合(Color Blended Layers)
	
	没有特殊情况，保证alpha值为1，设置背景色backgroundColor和父视图一致。
	
* 栅格化(Color Hits Green and Misses Red)

	并不是所有的视图都适用于栅格化(可能得破藏失)，它有自己的使用场景，对于一些比较复杂的效果，可以使用，常用的情况下，是在做阴影效果中使用。
	
* 图片格式(Color Copied Images)

	比较少碰到，如有联系你们的设计师
	
* 图片大小对齐(Color Misaligned Images)

	使用的图片大小和你设置的frame一致
	
* 离屏渲染(Color Offscreen-Rendered Yellow)

	使用其它的方式替换可能出发离屏渲染的方式，增加一些设置，使其不发生离屏渲染
	
	
**************************

### 扩展阅读

非常感谢以下的牛牛们

[iOS - 圆角的设计策略 - 及绘画出没有离屏渲染的圆角](http://www.jianshu.com/p/af70feefbc89)

[UIKit性能调优实战讲解](http://www.jianshu.com/p/619cf14640f3)