* ## 产品介绍

  腾讯云物联网开发平台（Tencent IoT）是集智能生活、智能制造、智能人居等功能于一体的解决方案。如家庭生活类产品，智能门锁可通过 wifi 设备接入腾讯云 IoT 平台进行管理。

  项目工程中包含三大块，App 体验模块、SDK Demo、SDK 模块。 用户可通过 App 体验产品功能，通过现有 App 快速搭建起属于自己的 IoT 应用。 也可通过 SDK 接入到自己的工程来完成与腾讯云物联网开发平台对接功能。

  

  ## 接入的第三方组件

  腾讯连连是一个完整的应用项目，集成了业内主流的推送、定位、日志系统、性能统计和微信授权登录等功能。推送集成了信鸽推送，定位使用了腾讯地图，日志系统和性能统计依赖 Firebase，微信授权登录则需要微信的支持。

  

  ## 快速开始

  用户需要根据实际情况调整 **app-config.json** 中的内容，app-config.json 位于项目的/LinkApp/Supporting Files/AppConfig目录，如截图所示位置。

  <img src="/Users/eagleychen/Documents/readme/readme/IMG/image-20200619141407513.png" alt="image-20200619141407513" style="zoom: 67%;" />

  app-config.json 需要配置的内容，如下图所示。

  <img src="/Users/eagleychen/Documents/readme/readme/IMG/image-20200622192726634.png" alt="image-20200619141716806" style="zoom:67%;" />

    **1、物联网平台**

  * **TencentIotLinkAppkey** 和 **TencentIotLinkAppSecrecy** 请使用在[物联网开发平台](https://cloud.tencent.com/product/iotexplorer)创建应用时生成的 **APP Key** 和 **APP Secret**。


    **2、信鸽（可选）**
    
    ​	腾讯连连开源体验版集成了**信鸽推送**，用于实现消息推送。
    
    * 若确认使用推送功能，需要前往[信鸽推送平台](https://cloud.tencent.com/product/tpns?fromSource=gwzcw.2454256.2454256.2454256&utm_medium=cpc&utm_id=gwzcw.2454256.2454256.2454256)申请获得的 **AccessID** 和 **AccessKey**，[申请步骤](https://cloud.tencent.com/product/tpns/getting-started)。
    
    * 若不使用推送功能，**XgAccessId** 和 **XgAccessKey**  设置为**长度为0字符串**即可。
    
    **3、 Firebase （可选）**
    
    ​	腾讯连连开源体验版集成了 **Firebase** 插件，用于记录应用的异常日志和性能状况。
    
    * 若用户确认使用 Firebase 插件，需通过 [Firebase 官网](https://firebase.google.cn/?hl=zh-cn) 创建应用并获取 **GoogleService-Info.plist** 文件；将 GoogleService-Info.plist 文件放在 app 目录下，如图所示位置。
    
      <img src="/Users/eagleychen/Documents/readme/readme/IMG/image-20200619150459211.png" alt="image-20200619150459211" style="zoom:67%;" />
    
    * 若不依赖 Firebase 插件，请注释截图中标注的内容即可
    
      <img src="/Users/eagleychen/Documents/readme/readme/IMG/image-20200619150752594.png" alt="image-20200619150752594" style="zoom: 50%;" />
    
      <img src="/Users/eagleychen/Documents/readme/readme/IMG/image-20200619151433681.png" alt="image-20200619151433681" style="zoom: 50%;" />
    
      <img src="/Users/eagleychen/Documents/readme/readme/IMG/image-20200619151507503.png" alt="image-20200619151507503" style="zoom: 50%;" />
    
    ​    **4、微信授权登录（可选）**
    
    ​    腾讯连连开源体验版集成了微信授权登录。
    
    * 若确认使用自定义的微信授权登录，需要在[微信开放平台](https://open.weixin.qq.com/)注册开发者帐号，创建移动应用，审核通过后，即可获得相应的 AppID 和 AppSecret，[申请步骤](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/WeChat_Login/Development_Guide.html)。
    
      使用微信授权登录还需：
    
      将配置项 **WXAccessAppId** 设置为在微信开放平台申请并获得的 **AppID**；
    
    * 若确认使用默认的微信授权登录，无需修改 **WXAccessAppId** 配置先内容 。
    
    * 若不使用微信授权登录功能，**WXAccessAppId** 设置为**长度为0字符串**即可。


​    

  完成上述配置后，依赖 Xcode 的构建，即可在手机上运行。
