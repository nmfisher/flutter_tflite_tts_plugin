import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class TfliteTts {
  static const MethodChannel _channel =
      const MethodChannel('com.avinium.tflite_tts');

  String tempPath;

  bool _initialized = false;

  Future initialize() async {
    if (_initialized) return;

    var success = await _channel.invokeMethod('initialize');
    print(success);
    if (success != 0) {
      throw Exception("Unknown exception initializing synthesizer.");
    }

    _initialized = true;
    return true;
  }

  Future<File> synthesize(List<int> symbolIds) async {
    var outfile =
        p.join((await getTemporaryDirectory()).path, "synthesized.wav");
    var success = await _channel.invokeMethod(
        "synthesize", {"symbolIds": symbolIds, "outfile": outfile});
    if (success != 0) {
      throw Exception("Unknown exception synthesizing sentntence.");
    }

    return File(outfile);
  }
}
