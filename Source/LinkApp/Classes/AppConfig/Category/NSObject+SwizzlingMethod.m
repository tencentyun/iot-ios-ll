//
//  NSObject+SwizzlingMethod.m
//  SEEXiaodianpu
//
//

#import "NSObject+SwizzlingMethod.h"
#import <objc/runtime.h>
@implementation NSObject (SwizzlingMethod)

+ (void)swizzlingMethod:(SEL)method replace:(SEL)replaceMethod
{
    Method objc_method = class_getInstanceMethod([self class],method);
    
    Method objc_methodReplace = class_getInstanceMethod([self class], replaceMethod);
    
    BOOL success = class_addMethod([self class], method, class_getMethodImplementation([self class], replaceMethod), method_getTypeEncoding(objc_methodReplace));
    
    if (!success) {
        method_exchangeImplementations(objc_method, objc_methodReplace);
        
    }else{
        class_replaceMethod([self class], replaceMethod, method_getImplementation(objc_method), method_getTypeEncoding(objc_methodReplace));
    }
}

@end
