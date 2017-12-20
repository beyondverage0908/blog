//
//  hook_cpp_init.m
//  QWLoadTrace
//
//  Created by everettjf on 2016/11/30.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <unistd.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <vector> // C++ 向量的使用，用于声明动态长度的数组

static NSMutableArray *sInitInfos;
static NSTimeInterval sSumInitTime;

extern "C"
const char* getallinitinfo(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [sInitInfos addObject:[NSString stringWithFormat:@"SumInitTime=%@",@(sSumInitTime)]];
    });
    
    NSString *msg = [NSString stringWithFormat:@"%@",sInitInfos];
    return msg.UTF8String;
}


// 判断是否是六十四位机器
using namespace std;
#ifndef __LP64__
typedef uint32_t MemoryType;
#else /* defined(__LP64__) */
typedef uint64_t MemoryType;
#endif /* defined(__LP64__) */


// 声明一个动态的uint32_t/uint64_t的一维数组
static std::vector<MemoryType> *g_initializer;
static int g_cur_index;
static MemoryType g_aslr;



struct MyProgramVars
{
    const void*		mh;
    int*			NXArgcPtr;
    const char***	NXArgvPtr;
    const char***	environPtr;
    const char**	__prognamePtr;
};

// C++用法，给函数指针类型起一个别名
// void * (int argc, const char* argv[], const char* envp[], const char* apple[], const MyProgramVars* vars) 起一个OriginalInitializer别名
typedef void (*OriginalInitializer)(int argc, const char* argv[], const char* envp[], const char* apple[], const MyProgramVars* vars);

// 自定义的init方法，用于统计系统的init方法的执行时长
void myInitFunc_Initializer(int argc, const char* argv[], const char* envp[], const char* apple[], const struct MyProgramVars* vars){
    printf("my init func\n");
    ++g_cur_index;
    // vector向量的方法 - 表示at: 得到vector的坐标index
    OriginalInitializer func = (OriginalInitializer)g_initializer->at(g_cur_index);
    
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    
    func(argc,argv,envp,apple,vars);
    
    CFTimeInterval end = CFAbsoluteTimeGetCurrent();
    sSumInitTime += 1000.0 * (end-start);
    NSString *cost = [NSString stringWithFormat:@"%p=%@",func,@(1000.0*(end - start))];
    [sInitInfos addObject:cost];
}

static void hookModInitFunc(){
    Dl_info info;
    dladdr((const void *)hookModInitFunc, &info);
    
#ifndef __LP64__
    //        const struct mach_header *mhp = _dyld_get_image_header(0); // both works as below line
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    MemoryType *memory = (uint32_t*)getsectiondata(mhp, "__DATA", "__mod_init_func", & size);
#else /* defined(__LP64__) */
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    MemoryType *memory = (uint64_t*)getsectiondata(mhp, "__DATA", "__mod_init_func", & size);
#endif /* defined(__LP64__) */
    for(int idx = 0; idx < size/sizeof(void*); ++idx){
        MemoryType original_ptr = memory[idx];
        // vector方法：在一维最后添加一个元素
        g_initializer->push_back(original_ptr);
        // 调用myInitFunc_Initializer
        memory[idx] = (MemoryType)myInitFunc_Initializer;
    }
    
    NSLog(@"zero mod init func : size = %@",@(size));
    
    [sInitInfos addObject:[NSString stringWithFormat:@"ASLR=%p",mhp]];
    g_aslr = (MemoryType)mhp;
}

@interface FooObject : NSObject @end
@implementation FooObject
+ (void)load{
    printf("foo object load \n");
    
    sInitInfos = [NSMutableArray new];
    g_initializer = new std::vector<MemoryType>();
    g_cur_index = -1;
    g_aslr = 0;
    
    hookModInitFunc();
}
@end
