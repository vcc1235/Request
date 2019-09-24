#
# Be sure to run `pod lib lint Request.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Request'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Request.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/1041497818@qq.com/Request'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1041497818@qq.com' => '1041497818@qq.com' }
  s.source           = { :git => 'https://github.com/1041497818@qq.com/Request.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.dependency 'AFNetworking', '~> 3.1.0'
  
  s.source_files = 'Request/Classes/Request.h'
  
  path = 'Request/Classes/Home/'
  
  s.subspec 'Socket' do |ss|
    ss.source_files = path + 'Request/Socket/*{.h,.m}'
  end
  
  s.subspec 'Core' do |ss|
    ss.source_files = path + 'Request/Core/*{.h,.m}'
  end
  
  s.subspec 'Lib' do |ss|
    ss.subspec 'SocketRocket' do |sss|
      sss.source_files = path + 'Lib/SocketRocket/**'
    end
  end
  
  
  
  # s.resource_bundles = {
  #   'Request' => ['Request/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
