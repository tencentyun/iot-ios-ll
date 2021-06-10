//
//  getgateway.h
//  MSTEnterprise
//
//



#ifndef MSTEnterprise_getgateway_h
#define MSTEnterprise_getgateway_h
#include <TargetConditionals.h>


// 模拟器调试里可以编译通过并执行，而选真机调试时却在编译中显示该文件找不到 net/route.h

#if  TARGET_IPHONE_SIMULATOR
//#include <net/route.h>
#include "route.h"
#elif TARGET_OS_IPHONE
#include "route.h"
#endif



 

// C语言的方法获得当前路由器的IP地址
int getdefaultgateway(in_addr_t * addr);

#endif
