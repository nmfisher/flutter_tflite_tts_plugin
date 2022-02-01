import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_tflite_tts_plugin/preprocesors/ipa.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_tflite_tts_plugin/preprocesors/baker.dart';

class TTSPluginConfiguration {
  final String baseAssetPath;
  final String outputDirectory;
  late final String melgenPath;
  late final String vocoderPath;
  late final String preprocessor;

  TTSPluginConfiguration(
      this.baseAssetPath, this.outputDirectory, this.melgenPath,
      {this.preprocessor = "ipa", this.vocoderPath = "mb_melfgan.tflite"});

  TTSPluginConfiguration.fromJson(
      this.baseAssetPath, this.outputDirectory, Map<String, dynamic> json) {
    melgenPath = json["melgenPath"];
    vocoderPath = json["vocoderPath"];
    preprocessor = json["preprocessor"];
  }
}

class TTSPlugin {
  static const MethodChannel _channel = const MethodChannel('app.mimetic.tts');

  final Map<String, Preprocessor Function()> _preprocessors = {
    "baker": () => Baker(),
    "ipa": () => IPA()
  };

  final TTSPluginConfiguration configuration;

  late final Preprocessor _preprocessor;

  ///
  /// [baseAssetPath] is the absolute path to the asset folder that contains all TTS assets (e.g. "assets/tts"). All paths in the TTS config will be resolved relative to this path.
  ///
  ///
  TTSPlugin(this.configuration) {
    this._preprocessor = _preprocessors[configuration.preprocessor]!();
    if (!Directory(configuration.outputDirectory).existsSync()) {
      Directory(configuration.outputDirectory).createSync(recursive: true);
    }
  }

  Future initialize() async {
    var success = await _channel.invokeMethod('initialize', {
      "melgenAssetPath":
          p.join(configuration.baseAssetPath, configuration.melgenPath),
      "vocoderAssetPath":
          p.join(configuration.baseAssetPath, configuration.vocoderPath)
    });

    if (success != 0) {
      throw Exception("Unknown exception initializing synthesizer.");
    }

    return true;
  }

  Future<File> synthesize(String text,
      {List<String>? pronunciation,
      List<int>? symbolIds,
      String? outfile}) async {
    symbolIds = symbolIds ??
        _preprocessor.textToSequence(text, pronunciation: pronunciation);

    outfile =
        outfile ?? p.join(configuration.outputDirectory, "synthesized.wav");
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
