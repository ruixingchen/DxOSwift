#platform :ios, '10.0'
use_frameworks!
target 'DXOSwift' do
    platform :ios, '11.0'

    #Swift4
    pod 'XCGLogger', '~> 6.0'
    pod 'SnapKit', '~> 4.0'
    pod 'Kingfisher', '~> 4.0'

    #Swift3
    pod 'Toast-Swift', '~> 2.0'
    pod 'StatefulViewController', '~> 3.0'
    pod 'Kanna', '~> 2.1.0'

    #DEBUG
    pod 'GDPerformanceView-Swift', :configurations => ['Debug']
    pod 'netfox', :configurations => ['Debug']

    #OC
    pod 'UITableView+FDTemplateLayoutCell', '~>1.6'
    pod 'FMDB', '~> 2.7'
    pod 'MJRefresh', '~> 3.1'
    pod 'SDCycleScrollView','~> 1.73'
end
post_install do |installer|
    oldSwiftTargets = ['Toast-Swift', 'StatefulViewController', 'Kanna', 'GDPerformanceView-Swift']
    installer.pods_project.targets.each do |target|
        if oldSwiftTargets.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end
