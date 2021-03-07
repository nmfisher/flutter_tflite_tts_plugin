import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class TfliteTts {
  static const MethodChannel _channel =
      const MethodChannel('com.avinium.tflite_tts');

  String _tempDir;

  bool _initialized = false;

  Future initialize({String melgenAssetPath="assets/lightspeech_quan.tflite", String vocoderAssetPath="assets/mb_melgan.tflite"}) async {
    if (_initialized) return;
    _tempDir = (await getTemporaryDirectory()).path;

    var success = await _channel.invokeMethod('initialize', { "melgenAssetPath": melgenAssetPath, "vocoderAssetPath": vocoderAssetPath});
    
    if (success != 0) {
      throw Exception("Unknown exception initializing synthesizer.");
    }

    _initialized = true;
    return true;
  }

  Future<File> synthesize(List<int> symbolIds) async {
    var outfile = p.join(_tempDir, "synthesized.wav");
    var success = await _channel.invokeMethod(
        "synthesize", {"symbolIds": symbolIds, "outfile": outfile});
    if (success != 0) {
      throw Exception("Unknown exception synthesizing sentntence.");
    }

    return File(outfile);
  }
}
