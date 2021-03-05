#import "TfliteTtsPlugin.h"
#if __has_include(<tflite_tts/tflite_tts-Swift.h>)
#import <tflite_tts/tflite_tts-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tflite_tts-Swift.h"
#endif

using namespace std;

static ifstream* melgen_s;
static ifstream* vocoder_s;

@implementation TfliteTtsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTfliteTtsPlugin registerWithRegistrar:registrar];
}

[channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"initialize" isEqualToString:call.method]) {
      NSString* key = [registrar lookupKeyForAsset:@"assets/fastspeech2_quan.tflite"];
      NSString* path = [[NSBundle mainBundle] pathForResource:key ofType:nil];
      melgen_s = new ifstream([path UTF8String]);

      key = [registrar lookupKeyForAsset:@"assets/mb_melgan.tflite"];
      path = [[NSBundle mainBundle] pathForResource:key ofType:nil];
      vocoder_s = new ifstream([path UTF8String]);
      
      if(initialize(melgen_s, vocoder_s) != 0) {
        NSLog(@"Failed to initialize TTS libs.");
        result(-1);
      } else {
        NSLog(@"Successfully initialized TTS libs.");
        result(0);
      }
      
    } else if([@"synthesize" isEqualToString:call.method]) {

        NSString* outfile = call.arguments[@"outfile"];
        
        FlutterStandardTypedData* tokenIds = [FlutterStandardTypedData typedDataWithInt32:call.argument("symbolIds")];
        Uint32 numTokens = [tokenIds elementSize];
        NSLog(@"Synthesizing %@ tokens to %@", numTokens, outfile);
        result(synthesize(numTokens, tokenIds, [outfile UTF8String]));
    } else {
      NSLog(@"Invalid method : %@", call.method);
      result(FlutterMethodNotImplemented);
    } 
    return;
  }];
@end
