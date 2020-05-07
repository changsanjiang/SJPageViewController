#
# Be sure to run `pod lib lint SJPageViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SJPageViewController'
  s.version          = '0.0.10'
  s.summary          = 'SJPageViewController.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A container view controller that manages navigation between pages of content, where each page is managed by a child view controller.
                       DESC

  s.homepage         = 'https://github.com/changsanjiang/SJPageViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'changsanjiang@gmail.com' => 'changsanjiang@gmail.com' }
  s.source           = { :git => 'https://github.com/changsanjiang/SJPageViewController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.default_subspec = 'ObjC'
  
  s.subspec 'ObjC' do |ss|
    ss.subspec 'PageViewController' do |sss|
      sss.source_files = 'SJPageViewController/ObjC/PageViewController/*.{h,m}'
      sss.subspec 'Core' do |ssss|
        ssss.source_files = 'SJPageViewController/ObjC/PageViewController/Core/**/*.{h,m}'
      end
    end
    
    ss.subspec 'PageMenuBar' do |sss|
      sss.source_files = 'SJPageViewController/ObjC/PageMenuBar/*.{h,m}'
      sss.subspec 'Core' do |ssss|
        ssss.source_files = 'SJPageViewController/ObjC/PageMenuBar/Core/**/*.{h,m}'
      end
    end
  end
  
  s.subspec 'Swift' do |ss|
    s.swift_versions = "5"
    ss.subspec 'PageViewController' do |sss|
        sss.source_files = 'SJPageViewController/Swift/PageViewController/*.swift'
        sss.subspec 'Core' do |ssss|
            ssss.source_files = 'SJPageViewController/Swift/PageViewController/Core/**/*.swift'
        end
    end

    ss.subspec 'PageMenuBar' do |sss|
        sss.source_files = 'SJPageViewController/Swift/PageMenuBar/*.swift'
        sss.subspec 'Core' do |ssss|
            ssss.source_files = 'SJPageViewController/Swift/PageMenuBar/Core/**/*.swift'
        end
    end
  end
end
