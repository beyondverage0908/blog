# AutoLayout - iOS自动布局

其实AutoLayout很早就已经有了(iOS6/xcode4)，并且已经在工作中使用蛮久了。但是自己一直没有对这方面的东西做一个总结，丰富一下自己知识树。

AutoLayout : Apple官方提供的对于各种屏幕更方便适配的机制，它更像Android中的相对布局。通过相对于其他控件的相对坐标，进行的一种屏幕适配方式。

** 相对布局都遵循一个线性公式 resView = originView * multiplier + constant **

* 1.1 VFL(Visual Format Language)语法


	NSString *vfl = @"V:|-5-[_view]-10-[_imageView(20)]-10-[_backBtn]-5-|";

看着都已经云晕了。


* 1.2 手写约束(Contraint)


    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:blueView
    attribute:NSLayoutAttributeLeft 
    relatedBy:NSLayoutRelationEqual
	toItem:redView
	attribute:NSLayoutAttributeLeft
	multiplier:1
	constant:0]];

注释：上面手动添加的约束的意思是：blueView的左侧 = redView的左侧 * 1 + 0;
亦是 blueView.left = redView.left * multiplier + constant.

* 1.3 使用可视化的界面-StoryBoard/xib


[学习资源](http://vit0.com/blog/2013/12/07/iosxue-xi-zhi-autolayout/)