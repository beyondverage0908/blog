# 整理iOS中关于时间的使用

1. 获取一天的开始 例：2017-03-12 00:00:00

		NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
		NSDateComponents *currentComponents = [calendar components:NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour fromDate:[NSDate date]];
    	NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow: - (currentComponents.hour * 3600 + currentComponents.minute * 60 + currentComponents.second)];
    	
2. 判断两个时间点相隔个了几天(实际的一天，并非语意上的一天)

		// 以24小时为一个一天，并非语意上的一天
		// 2017-03-13 09:10:43 -> 2017-03-14 09:10:44 一天
		// 2017-03-13 09:10:43 -> 2017-03-14 09:10:42 零天
		// 2017-03-13 09:10:43 -> 2017-03-14 00:00:01 零天
		+ (NSInteger)differentDayWithOldDay:(NSString *)oldDay otherDay:(NSString *)otherDay {
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    		
    		NSDate *oldDate = [dateFormatter dateFromString: oldDay];
    		NSDate *otherDate = [dateFormatter dateFromString:otherDay];
    		
    		**NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    		unsigned int unitFlags = NSCalendarUnitDay;
    		NSDateComponents *comps = [gregorian components:unitFlags fromDate:oldDate toDate:now options:0];
    		
    		return comps.day;
		}
		
3. 判断两个时间点相隔了几天(平时语意上的一天，例如2017-03-13 09:10:43 -> 2017-03-14 00:00:01 1天)

		// 语意上的一天，只要跨过当天的24点，即为一天
		// 2017-03-13 09:10:43 -> 2017-03-14 09:10:44 一天
		// 2017-03-13 09:10:43 -> 2017-03-14 09:10:42 一天
		// 2017-03-13 09:10:43 -> 2017-03-14 00:00:01 一天
		+ (NSInteger)differentDayWithOldDay:(NSString *)oldDay otherDay:(NSString *)otherDay {
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    		
    		NSDate *oldDate = [dateFormatter dateFromString: oldDay];
    		NSDate *otherDate = [dateFormatter dateFromString:otherDay];
    		
    		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    		unsigned int unitFlags = NSCalendarUnitDay;
    		NSDateComponents *comps = [gregorian components:unitFlags fromDate:oldDate toDate:now options:0];
    		
    		NSDateComponents *oldComponent = [gregorian components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:oldDate];
    		NSInteger overOldSecond = (24 - oldComponent.hour) * 3600 + (60 - oldComponent.minute) * 60 + (60 - oldComponent.second);
    		NSDateComponents *nowComponent = [gregorian components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:now];
    		NSInteger overNowSecond = (24 - nowComponent.hour) * 3600 + (60 - nowComponent.minute) * 60 + (60 - nowComponent.second);
    		
    		NSInteger day = comps.day;
    		if (overNowSecond > overOldSecond) {
        		day = day + 1;
    		}
    		
    		return day;
		}