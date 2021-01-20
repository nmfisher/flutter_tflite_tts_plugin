// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' ;
import 'package:path/path.dart' as p ;
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/method_channel_audioplayers.dart';

typedef MainFunction = Int32 Function(Int32, Pointer<Pointer<Utf8>>);
typedef MainFunctionDart = int Function(int, Pointer<Pointer<Utf8>>);

class IncredibleTts {
  DynamicLibrary dl;
  MainFunctionDart _synthFn;
  String tempPath;
  
  Future initialize() async {
    Directory tempDir = await getTemporaryDirectory();
    tempPath = tempDir.path;

    File(p.join(tempPath, "mb_melgan.tflite")).writeAsBytesSync(
        (await rootBundle.load("packages/incredible_tts/assets/mb_melgan.tflite")).buffer.asUint8List());
    File(p.join(tempPath, "fastspeech2_quan.tflite")).writeAsBytesSync(
        (await rootBundle.load("packages/incredible_tts/assets/fastspeech2_quan.tflite")).buffer.asUint8List());

    dl = Platform.isAndroid
        ? DynamicLibrary.open("libdemo.so")
        : DynamicLibrary.process();
    _synthFn = dl.lookupFunction<MainFunction, MainFunctionDart>("main");
    return true;
  }

  void go() async {
    print("Starting");
    var start = DateTime.now();
    var argArray = allocate<Pointer<Utf8>>(count: 4);

    argArray.elementAt(0).value = Utf8.toUtf8(
        "unused"); // normally the executable at argv[0], but we're invoking via a library. temporary only -  use this for a log file to redirect stderr
    argArray.elementAt(1).value = Utf8.toUtf8(tempPath + "/");
    argArray.elementAt(2).value = Utf8.toUtf8("1 18 80 2 6 181 2 23 64 2 17 57 2 18 31 2 17 57 2 13 66 2 6 195 1 218");
    argArray.elementAt(3).value = Utf8.toUtf8(tempPath + "/foobar.wav");

    _synthFn(4, argArray);
    print("Took ${DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch}ms");

  }
}
