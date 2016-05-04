# iOS -  圆角的设计策略 - 及绘画出没有离屏渲染的圆角

* 设计圆角时候为什么需要策略

在我们做APP开发的过程中，设计圆角应该是最为基础的功能之一。就是因为时常需要用到，所以就有必要考虑到，圆角的设计是否会对我们APP的流畅性有影响。我们一般设计圆角的通用方法：

    someView.layer.corneRadius = 10;
    someView.maskToBounds = Yes;

> 由于`maskToBounds`会触发离屏渲染，所以就有可能导致APP的fps下降，从而使APP产生卡顿的现象，所以遵从某些简单的策略在我们的开发过程中会更加有利于APP的流畅。

##### 具体的策略

* 当界面中只有view(不包括view的子类控件)需要设计圆角


	UIView *someView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    someView.layer.cornerRadius = 10;

**注意到：如果仅仅是`view`需要设置圆角，是不要设置maskToBounds的，并且someView.layer.cornerRadius并不会触发离屏渲染(很多的文章提到了会触发，其实这是对该cornerRadius属性的错误认识，可能也误导了许多新手开发者)，所以可以安心的设置**

*******************

* 当界面中有其他的包含子控件的view，如label，imageView等，需要设置圆角，但是数量并不多。此时可以安心的使用如下的方法，这里虽然会触发离屏渲染，但是由于数量比较少，所以对全局的影响一般不会很大。


	someLabel.layer.cornerRadius = 10;
    someLabel.maskToBounds = Yes;

*********************


* 但是当界面中有非常多需要设置圆角，比如tableView中。当界面中的tableView有超过25个圆角(使用上面的方法)，那么那么fps将会下降很多，特别是对某些控件还设置了阴影的效果，更加会加剧界面卡顿的现象。此时对于不同的控件将采用不同的方法进行处理，如下

	1. 对于label类，可以通过CoreGraphics来画出一个圆角的label
	2. 对于imageView类，通过CoreGraphics对绘画出来的image进行裁边处理，从而形成一个圆角的imageView

**对如label类，可以用如下方法进行绘制，仅给出核心的OC代码，项目示例代码可以在github中找到[CornerRadius](https://github.com/beyondverage0908/MyDemo/tree/master/CornerRadius)**

给UILabel绘画圆角


	- (UIImage *)dr_drawRectWithRoundedCornerRadius:(CGFloat)radius
                                    borderWidth:(CGFloat)borderWidth
                                backgroundColor:(UIColor *)backgroundColor
                                   borderCorlor:(UIColor *)borderColor {
    	CGSize sizeToFit = CGSizeMake([DrCorner pixel:self.bounds.size.width], self.bounds.size.height);
    	CGFloat halfBorderWidth = borderWidth / 2.0;
    
    	UIGraphicsBeginImageContextWithOptions(sizeToFit, NO, [UIScreen mainScreen].scale);
    	CGContextRef context = UIGraphicsGetCurrentContext();
    
    	CGContextSetLineWidth(context, borderWidth);
    	CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    	CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    
   	 CGFloat width = sizeToFit.width, height = sizeToFit.height;
    	CGContextMoveToPoint(context, width - halfBorderWidth, radius + halfBorderWidth); // 准备开始移动坐标
    	CGContextAddArcToPoint(context, width - halfBorderWidth, height - halfBorderWidth, width - radius - halfBorderWidth, height - halfBorderWidth, radius);
    	CGContextAddArcToPoint(context, halfBorderWidth, height - halfBorderWidth, halfBorderWidth, height - radius - halfBorderWidth, radius); // 左下角角度
    	CGContextAddArcToPoint(context, halfBorderWidth, halfBorderWidth, width - halfBorderWidth, halfBorderWidth, radius); // 左上角
    	CGContextAddArcToPoint(context, width - halfBorderWidth, halfBorderWidth, width - halfBorderWidth, radius + halfBorderWidth, radius);
    	CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    
    	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    	UIGraphicsEndImageContext();
    
    	return image;
	}
    
   
之后用绘画出来的image生成imageView，并将其插入到view的最底层

	- (void)dr_addCornerRadius:(CGFloat)radius
               borderWidth:(CGFloat)borderWidth
           backgroundColor:(UIColor *)backgroundColor
              borderCorlor:(UIColor *)borderColor {
    	UIImageView *imageView = [[UIImageView alloc] initWithImage:[self dr_drawRectWithRoundedCornerRadius:radius borderWidth:borderWidth backgroundColor:backgroundColor borderCorlor:borderColor]];
    	[self insertSubview:imageView atIndex:0];
	}


** 之后在你需要圆角的地方就可以放心的调用此方法了 **


给UIImageVIew绘画圆角-裁边处理，如下


	- (UIImage*)dr_imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size{
    	CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    	UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    	CGContextRef ctx = UIGraphicsGetCurrentContext();
    	UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    	CGContextAddPath(ctx,path.CGPath);
    	CGContextClip(ctx);
    	[self drawInRect:rect];
    	CGContextDrawPath(ctx, kCGPathFillStroke);
    	UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    	UIGraphicsEndImageContext();
    	return newImage;
	}


示例代码[CornerRadius](https://github.com/beyondverage0908/MyDemo/tree/master/CornerRadius)中还对这些核心方法进行了简单的封装，可以下载下来再仔细的看看。

声明：如果你觉得该文章对有一点点帮助，请移步到[iOS 高效添加圆角效果实战讲解](http://www.jianshu.com/p/f970872fdc22)中点赞，该文章的最初想法来自于该大大bestswifter的这篇博文。并且该大大bestswifter用swift实现了所有的核心代码。本文使用的全部是OC。

参考大大们的文章
[iOS 高效添加圆角效果实战讲解](http://www.jianshu.com/p/f970872fdc22)


**接下来会介绍使用Core Animation的UI的调试方法，欢迎一起讨论**