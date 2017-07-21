Pod::Spec.new do |s|

s.name             = 'YHttpClient'
s.version          = '1.0.0'
s.summary      = "YHttpClient is a network framework."
s.license          = { :type => 'MIT' }
s.homepage         = 'https://github.com/JianChunyang'
s.authors          = { 'young yang' => 'jianchun.yang@outlook.com' }
s.source       = { :git => "https://github.com/JianChunyang/YHttpClient.git", :tag => s.version }
s.source_files  = "YHttpClient", "YHttpClient/**/*.{h,m}"
s.framework        = 'Foundation'
s.platform     = :ios, "8.0"
s.ios.deployment_target = "8.0"
s.requires_arc     = true
end
