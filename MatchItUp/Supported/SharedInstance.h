//
//  SharedInstance.h
//  MatchItUp
//
//  Created by 安子和 on 2021/2/25.
//

#ifndef SharedInstance_h
#define SharedInstance_h

//如果项目需要的单例类比较多
//实现单例不能使用继承，不让子父类会只有一个,因为存储单例对象的静态变量大家用的是一个
//需要用宏来实现 写在一个头文件里 以后使用在.h中SingleH(类名)，.m文件中SingleM(类名)
#define SingleH(name) +(instancetype)shared##name;
#define SingleM(name) static id _instance;\
+ (instancetype)shared##name{\
    if(!_instance) {\
        _instance = [[self alloc] init];\
    }\
return _instance;\
}\
+ (instancetype)allocWithZone:(struct _NSZone *)zone{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [super allocWithZone:zone];\
    });\
    return _instance;\
}\
- (id)copyWithZone:(struct _NSZone *)zone{\
    return _instance;\
}\
- (id)mutableCopyWithZone:(struct _NSZone *)zone{\
    return _instance;\
}

#endif /* SharedInstance_h */
