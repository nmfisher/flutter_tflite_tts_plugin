#import "IncredibleTtsPlugin.h"
#if __has_include(<incredible_tts/incredible_tts-Swift.h>)
#import <incredible_tts/incredible_tts-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "incredible_tts-Swift.h"
#endif

@implementation IncredibleTtsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIncredibleTtsPlugin registerWithRegistrar:registrar];
}
@end
