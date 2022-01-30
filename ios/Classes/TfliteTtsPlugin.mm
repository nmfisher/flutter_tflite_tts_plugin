#import "TfliteTtsPlugin.h"

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#import <fstream> 

#include "TextToSpeech.hpp"

using namespace std;

static ifstream* melgen_s;
static ifstream* vocoder_s;

@implementation TfliteTtsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"app.mimetic.tts"
                                  binaryMessenger:[registrar messenger]];

  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"initialize" isEqualToString:call.method]) {
      NSString* melgenAssetPath = call.arguments[@"melgenAssetPath"]; 
      NSString* vocoderAssetPath = call.arguments[@"vocoderAssetPath"];

      NSString* key = [registrar lookupKeyForAsset:melgenAssetPath];
      NSString* path = [[NSBundle mainBundle] pathForResource:key ofType:nil];
      if(!path) {
        NSLog(@"Couldn't find model at path %@", key);
        exit(-1);
      }
      melgen_s = new ifstream([path fileSystemRepresentation], ios_base::binary);
      struct stat sb;

      stat([path fileSystemRepresentation], &sb);
      long melgen_size = sb.st_size;

      key = [registrar lookupKeyForAsset:vocoderAssetPath]; 
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
        NSArray* ns_symbolIds = call.arguments[@"symbolIds"];
        int numSymbols = [ns_symbolIds count];

        int symbolIds[numSymbols];
        int i = 0;
        for(id symbolId in ns_symbolIds) {
            symbolIds[i] = [symbolId intValue];
          i++;
        }
        
        int retCode = synthesize(numSymbols, symbolIds, [outfile fileSystemRepresentation]);
        result([NSNumber numberWithInt:retCode]);
    } else if([@"dispose" isEqualToString:call.method]) {

    
    } else {
      NSLog(@"Invalid method : %@", call.method);
      result(FlutterMethodNotImplemented);
    } 
    return;
  }];
}
@end
