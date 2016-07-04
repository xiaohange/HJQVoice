Pod::Spec.new do |s|
  s.name         = "HJQVoice"
  s.version      = "0.0.1"
  s.summary      = "An open source framework in iFLYTEK based on the two development of the speech recognition function of HJQVoice."
  s.homepage     = "https://github.com/XiaoHanGe/HJQVoice"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "韩俊强" => "532167805@qq.com" }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/XiaoHanGe/HJQVoice.git", :tag => s.version.to_s }
  s.source_files  = "HJQVoice", "HJQVoice/**/*.{h,m,xib}"
  s.resources = "HJQVoice/**/*.png"
  s.frameworks = "CoreLocation", "CoreTelephony", "AVFoundation", "AddressBook", "AudioToolbox", "SystemConfiguration",  "QuartzCore", "CoreGraphics", "libz"
  s.vendored_frameworks = "HJQVoice/iflyMSC.framework"
  s.requires_arc = true
  s.libraries = "z","c++"
end
