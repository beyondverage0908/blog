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
		__strong __typeof(weakSelf)strongSelf = weakSelf;
		
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
		
4. 获取设备的UUID

		+(NSString *)getUUID {
		    CFUUIDRef uuidObj = CFUUIDCreate(nil);
		    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
		    CFRelease(uuidObj);
		    return uuidString;
		}
		
5. 生成颜色图片

		// 颜色生成图片
		+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
		    CGRect rect = CGRectMake(0, 0, size.width,size.height);
		    UIGraphicsBeginImageContext(rect.size);
		    CGContextRef context = UIGraphicsGetCurrentContext();
		    CGContextSetFillColorWithColor(context, [color CGColor]);
		    CGContextFillRect(context, rect);
		    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
		    UIGraphicsEndImageContext();
		    return img;
		}
		
6. 请求麦克风权限

		// 麦克权限
		+ (BOOL)haveMicPromission {
		    __block int tip = 0;
		    AVAudioSession *avSession = [AVAudioSession sharedInstance];
		    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
		        //创建一个出事信号量为0的信号
		        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
		        [avSession requestRecordPermission:^(BOOL available) {
		            if (!available) {
		                tip = 0;
		            } else {
		                tip = 1;
		            }
		            //发送一次信号
		            dispatch_semaphore_signal(sema);
		        }];
		        //等待信号触发
		        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
		    }
		    return tip;
		}
		
7. 请求通讯录权限

		// 通讯录权限
		+ (BOOL)haveContactsPromission{
		    //这个变量用于记录授权是否成功，即用户是否允许我们访问通讯录
		    __block int tip = 0;
		    //声明一个通讯簿的引用
		    ABAddressBookRef addBook =nil;
		    //因为在IOS6.0之后和之前的权限申请方式有所差别，这里做个判断
		    if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
		        //创建通讯簿的引用
		        addBook = ABAddressBookCreateWithOptions(NULL, NULL);
		        //创建一个出事信号量为0的信号
		        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
		        //申请访问权限
		        ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error) {
		            //greanted为YES是表示用户允许，否则为不允许
		            if (greanted) {
		                tip = 1;
		            } else {
		                tip = 0;
		            }
		            //发送一次信号
		            dispatch_semaphore_signal(sema);
		        });
		        //等待信号触发
		        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
		    }else{
		        //IOS6之前
		        addBook = ABAddressBookCreate();
		    }
		    return tip;
		}
		
8. 获取指定路径下的文件大小(缓存)

		+ (long long)fileSizeAtPath:(NSString *) filePath {
		
		    NSFileManager* manager = [NSFileManager defaultManager];
		    if ([manager fileExistsAtPath:filePath]){
		        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
		    }
		    return 0;
		}
		
		+ (float)folderSizeAtPath:(NSString*) folderPath {
		    NSFileManager* manager = [NSFileManager defaultManager];
		    if(![manager fileExistsAtPath:folderPath]) return 0;
		    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath]objectEnumerator];
		    NSString *fileName;
		    long long folderSize = 0;
		    while((fileName = [childFilesEnumerator nextObject]) != nil){
		        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
		        folderSize += [self fileSizeAtPath:fileAbsolutePath];
		    }
		    return folderSize/(1024.0*1024.0);
		}
		
		
9. 判断应用是否接受远程通知

		if (IOS8) { //iOS8以上包含iOS8  
	        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  == UIRemoteNotificationTypeNone) {  
			    }  
		 }else{ // ios7 一下      
		    if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes]  == UIRemoteNotificationTypeNone) {  
		  }  
		}