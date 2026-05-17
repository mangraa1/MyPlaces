platform :ios, '15.0'

target 'MyPlaces' do
  use_frameworks!

  pod 'RealmSwift'
  pod 'Cosmos', '~> 23.0'

  # Unit-тести запускаються всередині хост-додатку, тому
  # успадкування search paths дає доступ до RealmSwift.
  target 'MyPlacesTests' do
    inherit! :search_paths
  end

  # UI-тести — окремий процес, не потребують жодних pod-фреймворків.
  # Порожній таргет уникає помилки dlopen для Cosmos.framework.
  target 'MyPlacesUITests' do
  end

end

# Realm 10.41 не містить IPHONEOS_DEPLOYMENT_TARGET_1700 для Xcode 17+,
# цей хук явно виставляє мінімальний target для всіх pod-таргетів.
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
