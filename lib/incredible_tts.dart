import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' ;
import 'package:path/path.dart' as p ;

import 'preprocessor.dart';

typedef MainFunction = Int32 Function(Int32, Pointer<Pointer<Utf8>>);
typedef MainFunctionDart = int Function(int, Pointer<Pointer<Utf8>>);

class IncredibleTts {
  
  DynamicLibrary dl;
  MainFunctionDart _synthFn;
  String tempPath;
  Preprocessor _preprocessor;
  
  Future initialize() async {
    Directory tempDir = await getTemporaryDirectory();
    tempPath = tempDir.path;

    File(p.join(tempPath, "mb_melgan.tflite")).writeAsBytesSync(
        (await rootBundle.load("packages/incredible_tts/assets/mb_melgan.tflite")).buffer.asUint8List());
    File(p.join(tempPath, "fastspeech2_quan.tflite")).writeAsBytesSync(
        (await rootBundle.load("packages/incredible_tts/assets/fastspeech2_quan.tflite")).buffer.asUint8List());

    _preprocessor = Preprocessor(await rootBundle.loadString("packages/incredible_tts/assets/baker_mapper.json"));

    dl = Platform.isAndroid
        ? DynamicLibrary.open("libdemo.so")
        : DynamicLibrary.process();
    _synthFn = dl.lookupFunction<MainFunction, MainFunctionDart>("main");
    return true;
  }

  Future<File> synthesize(String input, List<String> pinyin) async {

    var symbolIds = _preprocessor.textToSequence(input, pinyin);
    print(symbolIds);
    var start = DateTime.now();
    var argArray = allocate<Pointer<Utf8>>(count: 4);
    File outfile = File(tempPath + "/foobar.wav");
    argArray.elementAt(0).value = Utf8.toUtf8(
        "unused"); // normally the executable at argv[0], but we're invoking via a library. temporary only -  use this for a log file to redirect stderr
    argArray.elementAt(1).value = Utf8.toUtf8(tempPath + "/");
    argArray.elementAt(2).value = Utf8.toUtf8(symbolIds.join(" "));
    argArray.elementAt(3).value = Utf8.toUtf8(outfile.path);

    _synthFn(4, argArray);
    print("Took ${DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch}ms");
    return outfile;

  }
}
