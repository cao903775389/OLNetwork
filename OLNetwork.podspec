#
# Be sure to run `pod lib lint OLNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OLNetwork'
  s.version          = '1.0.0'
  s.summary          = 'OL网络层封装.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    OL网络请求基础库封装.
                       DESC

  s.homepage         = 'https://github.com/cao903775389/OLNetwork'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cao903775389' => '903775389@qq.com' }
  s.source           = { :git => 'https://github.com/cao903775389/OLNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
s.platform = :ios, '8.0'
  s.source_files = 'OLNetwork/Classes/**/*'
  
  # s.resource_bundles = {
  #   'OLNetwork' => ['OLNetwork/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'AdSupport'
    s.dependency 'AFNetworking', '~> 3.1.0'
    s.dependency 'NSString+TBEncryption', '~> 1.0'
    s.dependency 'YYModel', '~> 1.0.4'
end
