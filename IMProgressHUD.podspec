Pod::Spec.new do |s|
  s.name = 'IMProgressHUD'
  s.version = '0.0.2'
  s.summary  = 'A clean and lightweight progress HUD for your iOS app.'
  s.description = 'IMProgressHUD is a clean and easy-to-use HUD meant to display the progress of an ongoing task on iOS.'
  
  s.homepage = 'https://github.com/immortal-it/IMProgressHUD'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Immortal' => 'immortal@gmail.com' }
  s.source = { :git => 'https://github.com/immortal-it/IMProgressHUD.git', :tag => s.version }

  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.swift_versions = ['5.1', '5.2', '5.3']
  
  s.source_files = 'IMProgressHUD/**/*.{swift}'

  s.pod_target_xcconfig = {
    'SWIFT_INSTALL_OBJC_HEADER' => 'NO'
  }
  
end
