#
# Be sure to run `pod lib lint WiSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WiSDK'
  s.version          = '1.2.4'
  s.summary          = 'Welcome Interruption SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This Wi SDK allows integration of native mobile apps with the Welcome Interruption (Wi) servers.  It allows for the collecting
location information from a mobile device to the Wi Servers and allow the receipt of notifications from Wi servers..
                       DESC

  s.homepage         = 'http://www.welcomeinterruption.com'
  s.license          = { :type => '3es SDK Agreement', :file => 'LICENSE' }
  s.author           = { 'pfrantz' => 'pfrantz@3-elecric-sheep.com' }
  s.source           = { :git => 'https://github.com/3-electric-sheep/wisdk_ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'WiSDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WiSDK' => ['WiSDK/Assets/*.png']
  # }

  s.public_header_files = 'WiSDK/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit', 'CoreLocation'
  s.dependency 'AFNetworking', '~> 3.0'
end
