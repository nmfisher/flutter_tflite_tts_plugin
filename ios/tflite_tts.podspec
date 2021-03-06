#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint incredible_tts.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tflite_tts'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*', 'src/synthesize.cpp', 'src/tensorflowtts/*.cpp'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.xcconfig = { 
    'ALWAYS_SEARCH_USER_PATHS' => 'YES',
    'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/../.symlinks/plugins/tflite_tts/ios/src" "${PODS_ROOT}/../.symlinks/plugins/tflite_tts/ios/include" "${PODS_ROOT}/../.symlinks/plugins/tflite_tts/ios/src/tensorflowtts"',
    'LIBRARY_SEARCH_PATHS' => '${PODS_ROOT}/../.symlinks/plugins/tflite_tts/ios/lib',
    'OTHER_LDFLAGS' => '-L${PODS_ROOT}/../.symlinks/plugins/tflite_tts/ios/lib -ltensorflowlite'
  }
  s.vendored_libraries = "libtensorflowlite.dylib"
  s.swift_version = '5.0'
end
