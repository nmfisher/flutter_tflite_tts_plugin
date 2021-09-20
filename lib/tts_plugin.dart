import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:tflite_tts/preprocesors/baker.dart';

class TTSPluginConfiguration {
  late final String melgenPath;
  late final String vocoderPath;
  late final String preprocessor;

  TTSPluginConfiguration(this.preprocessor, this.melgenPath, this.vocoderPath);

  TTSPluginConfiguration.fromJson(
      String baseAssetPath, Map<String, dynamic> json) {
    melgenPath = p.join(baseAssetPath, json["melgenPath"]);
    vocoderPath = p.join(baseAssetPath, json["vocoderPath"]);
    preprocessor = json["preprocessor"];
  }
}

class TTSPlugin {
  static const MethodChannel _channel = const MethodChannel('app.mimetic.tts');

  final Map<String, Preprocessor Function()> _preprocessors = {
    "baker": () => Baker()
  };

  final String outputDirectory;
  final TTSPluginConfiguration configuration;
  late final Preprocessor _preprocessor;

  TTSPlugin(this.configuration, this.outputDirectory) {
    this._preprocessor = _preprocessors[configuration.preprocessor]!();
  }

  Future initialize() async {
    var success = await _channel.invokeMethod('initialize', {
      "melgenAssetPath": configuration.melgenPath,
      "vocoderAssetPath": configuration.vocoderPath
    });

    if (success != 0) {
      throw Exception("Unknown exception initializing synthesizer.");
    }

    return true;
  }

  Future<File> synthesize(String text,
      {List<String>? pronunciation, String? outfile}) async {
    final symbolIds =
        _preprocessor.textToSequence(text, pronunciation: pronunciation);

    outfile = outfile ?? p.join(outputDirectory, "synthesized.wav");
    var success = await _channel.invokeMethod(
        "synthesize", {"symbolIds": symbolIds, "outfile": outfile});
    if (success != 0) {
      throw Exception("Unknown exception synthesizing sentntence.");
    }

    return File(outfile);
  }

  Future dispose() async {
    await _channel.invokeMethod('dispose');
  }
}
