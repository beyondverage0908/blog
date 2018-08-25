# UIView动画

> 一般来说，对于UIView的动画，大概分为UIView的仿射变换，基于CA和它的子类的动画，以及CG相关的动画。

动画的形式一般为平移，缩放，旋转，翻转，一种或多种组合。设置动画变换常用的属性`.frame`和`.transform`，因此常被称为

1. frame动画
2. transform动画

使用这两种动画模式，只需要在apple提供的动画api中适当的添加动画后的frame和transform，并设置好动画时长，即可达到动画过度的效果。但是使用`frame`的局限性很强，使用平移和缩放还好，旋转则需要使用比较复杂的矩阵计算公式，才能得到旋转后的`frame`，所以只适合实现最简单的平移和缩放的动画。

所以本章主要的还是讨论`transform`动画

## 动画的语法api

动画的语法常用的有两种方式

1. UIView的block方式
		
		[UIView animateWithDuration:2.0 animations:^{
			view.transform = transform;
	    }];

2. UIView的begin-commit方式

		
		- (void)transformLeftToRightAndScale {
		    UIView *view = [self getView];
		    CGRect start = CGRectMake(10, 64 + 10 + 2 * (50 + 10), 50, 50);
		    view.frame = start;
		    [self.view addSubview:view];
		    
		    CGAffineTransform bigTransform = CGAffineTransformMakeScale(1.2, 1.2);
		    
		    CGFloat fx = BoundW - CGRectGetWidth(view.frame) - 10 - 10; // 沿着X方向平移
		    CGFloat fy = - 2 * (50 + 10); // 沿着Y方向平移
		    CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(fx, fy);
		    
		    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI);
		    
		    [UIView beginAnimations:@"move" context:nil];
		    [UIView setAnimationDelegate:self];
		    [UIView setAnimationDuration:2.0];
		    
		    [view setTransform:CGAffineTransformConcat(rotate, CGAffineTransformConcat(bigTransform, moveTransform))];
		    
		    [UIView commitAnimations];
		}
		

## 仿射变换，仿射变换的两种类型--二维和三维

仿射变换分为二维的仿射变换和三维的仿射变换，对应的api分别为`CGAffineTransform`，`CATransform3D`.

### CGAffineTransform

`CGAffineTransform`适用于平移，缩放，旋转，在二维空间进行操作。api为`animationView.transform = transform`。来先看一下`CGAffineTransform`的数据结构。

	struct CGAffineTransform {
		CGFloat a, b, c, d;
		CGFloat tx, ty;
	};
	
CGAffineTransform使用一个结构体进行封装，本质上表达的是一个3*3的矩阵。由于第三列始终是(0,0,1)，因此数据结构仅包含前两列的值。

![CGAffineTransform矩阵.png](https://upload-images.jianshu.io/upload_images/1626952-8ebc2939d5f892d6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

CGAffineTransform从概念上讲，仿射变换将表示图形中每个点（x，y）的行向量乘以该矩阵，从而生成表示对应点（x'，y'）的向量：

![image.png](https://upload-images.jianshu.io/upload_images/1626952-dadd6bd576127276.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

给定3乘3矩阵，以下等式用于将一个坐标系中的点（x，y）变换为另一个坐标系中的合成点（x'，y'）

![image.png](https://upload-images.jianshu.io/upload_images/1626952-dc680a593a79a3b7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>**所以当两个仿射进行连接，本质上是两个仿射变换的矩阵乘积**

矩阵数学计算公式 [理解矩阵乘法](http://www.ruanyifeng.com/blog/2015/09/matrix-multiplication.html)

![矩阵计算公式.png](https://upload-images.jianshu.io/upload_images/1626952-4152baacf9a6e418.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


### CGAffineTransform的相关api

最具体的还是参考 [CGAffineTransform文档](https://developer.apple.com/documentation/coregraphics/cgaffinetransform-rb5?language=objc)

1. 创建仿射变换矩阵

		CGAffineTransform CGAffineTransformMake(CGFloat a, CGFloat b, CGFloat c, CGFloat d, CGFloat tx, CGFloat ty); //返回根据您提供的值构造的仿射变换矩阵
	
		CGAffineTransform CGAffineTransformMakeRotation(CGFloat angle); //返回根据您提供的旋转值构造的仿射变换矩阵。
	
		CGAffineTransform CGAffineTransformMakeScale(CGFloat sx, CGFloat sy); //返回由您提供的缩放值构造的仿射变换矩阵。
	
		CGAffineTransform CGAffineTransformMakeTranslation(CGFloat tx, CGFloat ty); //返回根据您提供的转换值构造的仿射变换矩阵

2. 修改仿射变换

		
		CGAffineTransform CGAffineTransformTranslate(CGAffineTransform t, CGFloat tx, CGFloat ty); // 通过修改现有仿射变换而构造的仿射变换矩阵。
		
		CGAffineTransformScale // 返回通过缩放现有仿射变换而构造的仿射变换矩阵
		
		CGAffineTransformRotate // 返回通过旋转现有仿射变换构造的仿射变换矩阵
		
		CGAffineTransformInvert // 返回通过反转现有仿射变换而构造的仿射变换矩阵
		
		CGAffineTransformConcat // 返回通过组合两个现有仿射变换而构造的仿射变换矩阵

3. 应用仿射变换
	
		CGPoint CGPointApplyAffineTransform(CGPoint point, CGAffineTransform t); // 将指定的仿射变换应用于现有点所产生的新点
		
		CGSize CGSizeApplyAffineTransform(CGSize size, CGAffineTransform t); // 通过将指定的仿射变换应用于现有大小而产生的新大小
		
		CGRect CGRectApplyAffineTransform(CGRect rect, CGAffineTransform t); // 变换后的矩形
		
### CGAffineTransformConcat

组合两个已存在的仿射变换，数学本质上是两个矩阵进行乘积。

	CGAffineTransform CGAffineTransformConcat(CGAffineTransform t1, CGAffineTransform t2);
	
## CATransform3D

`CATransform3D `变换矩阵用于旋转，缩放，平移，倾斜和投影图层内容，适用于二维和三维空间进行变换。api为`animationView.layer.transform = transform`。来先看一下`CATransform3D`的数据结构。

	struct CATransform3D
	{
	  CGFloat m11, m12, m13, m14;
	  CGFloat m21, m22, m23, m24;
	  CGFloat m31, m32, m33, m34;
	  CGFloat m41, m42, m43, m44;
	};

CATransform3D是一4*4的矩阵，同样表示一个点的映射关系 [iOS核心动画：高级技巧（2014）](http://apprize.info/apple/ios_5/6.html)

![image.png](https://upload-images.jianshu.io/upload_images/1626952-270c7d8ec27fd6cc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### CATransform3D操作api

	//还原
	 CATransform3DIdentity
	
	//位移3D仿射  ==> (CGFloat tx, CGFloat ty, CGFloat tz)
	CATransform3DMakeTranslation
	CATransform3DTranslate        
	//旋转3D仿射 ==> (CGFloat angle, CGFloat x, CGFloat y, CGFloat z)
	CATransform3DMakeRotation
	CATransform3DRotate  
	//缩放3D仿射 ==>  (CGFloat angle, CGFloat x, CGFloat y, CGFloat z)
	CATransform3DMakeScale
	CATransform3DScale
	//叠加3D仿射效果
	CATransform3DConcat    
	//仿射基础3D方法，可以直接做效果叠加
	CGAffineTransformMake (sx,shx,shy,sy,tx,ty)
	//检查是否有做过仿射3D效果  == ((CATransform3D t))
	CATransform3DIsIdentity(transform)
	//检查2个3D仿射效果是否相同
	CATransform3DEqualToTransform(transform1,transform2)
	//3D仿射效果反转（反效果，比如原来扩大，就变成缩小）
	CATransform3DInvert(transform)

带有Make的为构建api，即创建一个CATransform3D类型的仿射变换。没有带Make一般为修改给定的仿射变换，并返回修改后的仿射变换。如：

	CATransform3D CATransform3DMakeTranslation(CGFloat tx, CGFloat ty, CGFloat tz); // 返回一个设定了转移的仿射变换
	
	CATransform3D CATransform3DTranslate(CATransform3D t, CGFloat tx, CGFloat ty, CGFloat tz); // 修改给定的`CATransform3D t`
	
### CATransform3DConcat

类似的，和`CGAffineTransformConcat`一样，用于连接两个仿射变换，返回一个连接后的仿射变换。

	CATransform3D CATransform3DConcat(CATransform3D a, CATransform3D b); // Concatenates b to a and returns the result: t = a * b.


## 结尾

下一章节，可以看看Core Animation中的动画实现。