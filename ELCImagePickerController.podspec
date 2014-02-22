Pod::Spec.new do |s|
    s.name = 'ELCImagePickerController'
    s.version = '0.2.1-beta3'
    s.summary = 'A Multiple Selection Image Picker.'
    s.homepage = 'https://github.com/CleanShavenApps/ELCImagePickerController.git'
    s.license = {
      :type => 'MIT',
      :file => 'README.md'
    }
    s.author = {'Clean Shaven Apps Pte. Ltd.' => 'http://www.dispatchapp.net'}
    s.source = {:git => 'https://github.com/CleanShavenApps/ELCImagePickerController.git',
    			:tag => '0.2.1-beta3'
    		   }
    s.platform = :ios, '6.0'
    s.resources = 'Classes/**/*.{xib,png}'
    s.source_files = 'Classes/ELCImagePicker/*.{h,m}'
    s.framework = 'Foundation', 'UIKit', 'AssetsLibrary', 'CoreLocation'
    s.requires_arc = true
end
