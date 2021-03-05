import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'preprocessor.dart';

typedef MainFunction = Int32 Function(Int32, Pointer<Pointer<Utf8>>);
typedef MainFunctionDart = int Function(int, Pointer<Pointer<Utf8>>);

class TfliteTts {
  static const MethodChannel _channel =
      const MethodChannel('com.avinium.tflite_tts');

  String tempPath;
  Preprocessor _preprocessor;
  bool _initialized = false;

  Future initialize() async {
    if (_initialized) return;

    _preprocessor = Preprocessor(await rootBundle
        .loadString("assets/baker_mapper.json"));

    var success = await _channel.invokeMethod('initialize');
    
    if(success != 0) {
      throw Exception("Unknown exception initializing synthesizer.");
    }

    _initialized = true;
    return true;
  }

  Future<File> synthesize(String input, List<String> pinyin) async {
    var symbolIds = _preprocessor.textToSequence(input, pinyin);
    var outfile =
        p.join((await getTemporaryDirectory()).path, "synthesized.wav");
    var success = await _channel.invokeMethod(
        "synthesize", {"symbolIds": symbolIds, "outfile": outfile});
    if(success != 0) {
      throw Exception("Unknown exception synthesizing sentntence.");
    }

    return File(outfile);
  }
}
