platform :ios, '9.0'
#inhibit_all_warnings!
use_frameworks!

def common_all_pods
  pod 'Masonry', '1.1.0'
  pod 'MBProgressHUD', '1.1.0'
  pod 'SDWebImage', '4.4.2'
  pod 'YYModel', '1.0.4'
  pod 'QCloudCOSXML/Transfer', '5.5.2'
  pod 'Firebase/Analytics', '6.31.1'
  pod 'Firebase/Crashlytics', '6.31.1'
  pod 'Firebase/Performance', '6.31.1'
end

target 'LinkApp' do
  common_all_pods
  
  pod 'TIoTLinkKit', :path => './'
  pod 'TIoTLinkKit/LinkRTC', :path => './'
  pod 'MJRefresh', '3.2.0'
  pod 'IQKeyboardManager', '6.1.1'
  pod 'FDFullscreenPopGesture', '1.1'
  pod 'SocketRocket', '0.5.1'
  pod 'TZImagePickerController', '3.2.1'
  pod 'MGJRouter', '0.10.0'
  pod 'TrueTime','5.0.3'
  pod 'KeychainAccess', '4.2.0'
  pod 'Tencent-MapSDK', '4.3.9'
  pod 'lottie-ios', '3.1.8'
  pod 'CocoaAsyncSocket', '7.6.5'
  pod 'CocoaLumberjack', '~> 3.7.2'
  pod 'TIoTLinkThirdPartyKit/TPNS-iOS', '2.2.1'
  pod 'TIoTLinkThirdPartyKit/WechatOpenSDK_NoPay', '2.2.1'
end


target 'LinkSDKDemo' do
  common_all_pods
  
  pod 'TIoTLinkKit', :path => './'
  pod 'TIoTLinkKit/LinkRTC', :path => './'
  
  pod 'TIoTLinkVideo', :path => './'
  pod 'TIoTLinkThirdPartyKit/IJKPlayer-iOS', '2.2.1'
end
