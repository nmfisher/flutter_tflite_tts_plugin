#import "TfliteTtsPlugin.h"
#if __has_include(<tflite_tts/tflite_tts-Swift.h>)
#import <tflite_tts/tflite_tts-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tflite_tts-Swift.h"
#endif

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#import <fstream> 
#import "synthesize.hpp"

using namespace std;

static ifstream* melgen_s;
static ifstream* vocoder_s;

@implementation TfliteTtsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTfliteTtsPlugin registerWithRegistrar:registrar];
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"com.avinium.tflite_tts"
                                  binaryMessenger:[registrar messenger]];

  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"initialize" isEqualToString:call.method]) {
      NSString* key = [registrar lookupKeyForAsset:@"assets/fastspeech2_quan.tflite"];
      NSString* path = [[NSBundle mainBundle] pathForResource:key ofType:nil];
      melgen_s = new ifstream([path fileSystemRepresentation], ios_base::binary);
      struct stat sb;

      stat([path fileSystemRepresentation], &sb);
      long melgen_size = sb.st_size;

      key = [registrar lookupKeyForAsset:@"assets/mb_melgan.tflite"];
      path = [[NSBundle mainBundle] pathForResource:key ofType:nil];
      
      vocoder_s = new ifstream([path fileSystemRepresentation], ios_base::binary);
      
      stat([path fileSystemRepresentation], &sb);
      long vocoder_size = sb.st_size;
      int retCode = initialize(melgen_s, vocoder_s, melgen_size, vocoder_size);
      if(retCode != 0) {
        NSLog(@"Failed to initialize TTS libs.");
      } else {
        NSLog(@"Successfully initialized TTS libs.");
      }
      result([NSNumber numberWithInt:retCode]);      
    } else if([@"synthesize" isEqualToString:call.method]) {

        NSString* outfile = call.arguments[@"outfile"];

        FlutterStandardTypedData* tokenIds = [FlutterStandardTypedData typedDataWithInt32:call.arguments[@"symbolIds"]];
        UInt32 numTokens = [tokenIds elementSize];
        int tokenIds_int[numTokens];
        [[tokenIds data] getBytes:tokenIds_int length:numTokens * sizeof(int)];
        NSLog(@"Synthesizing %u tokens to %@", numTokens, outfile);
        int retCode = synthesize(numTokens, tokenIds_int, [outfile UTF8String]);
        result([NSNumber numberWithInt:retCode]);
    } else {
      NSLog(@"Invalid method : %@", call.method);
      result(FlutterMethodNotImplemented);
    } 
    return;
  }];
}
@end
