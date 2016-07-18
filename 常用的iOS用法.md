#  常用iOS用法

1. enum

		typedef NS_ENUM(NSInteger, Weekday)
		{
		    WeekdaySunday = 1,
		    WeekdayMonday,
		    WeekdayTuesday
		};

2. 弱引用 
	
		__weak __typeof(self)weakSelf = self;
		__strong __typeof(weakSelf)strongSelf = weakSelf;noti
		
3. 键盘的弹出
	
		// 监听键盘的通知
    	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    	
    	// 键盘响应
		- (void)keyboardChangeFrame:(NSNotification *)noti
		{    
		    // 0.取出键盘动画的时间
		    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		    // 1.取得键盘最后的frame
		    CGRect keyboardFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
		    // 2.计算控制器的view需要平移的距离 - 其中的transformY的符号表示移动的方向 "- 表示向上移动，+ 表示向下移动"
		    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height;
		
		    // 3.执行动画
		    [UIView animateWithDuration:duration animations:^{
		        // 将需要的视图进行平移
		    }];
		}