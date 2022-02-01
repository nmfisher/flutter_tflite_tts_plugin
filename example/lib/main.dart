import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tflite_tts_plugin/tts_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioPlayer _advancedPlayer = AudioPlayer();

  late TTSPlugin _ttsPlugin;
  bool _initialized = false;
  TextEditingController _pinyinController = TextEditingController();
  TextEditingController _charController = TextEditingController();

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() async {
    final config = await rootBundle.loadString("assets/tts_config.json");
    getTemporaryDirectory().then((dir) {
      _ttsPlugin = TTSPlugin(
        TTSPluginConfiguration.fromJson(
            "assets", dir.path, json.decode(config)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(children: [
          ElevatedButton(
              child: Text("INITIALIZE"),
              onPressed: () async {
                setState(() {
                  _initialized = false;
                });
                await _ttsPlugin.initialize();
                setState(() {
                  _initialized = true;
                });
              }),
          // TextField(
          //   controller: _charController,
          //   decoration: InputDecoration(
          //     border: OutlineInputBorder(),
          //     labelText: 'Character',
          //   ),
          // ),
          // TextField(
          //   controller: _pinyinController,
          //   decoration: InputDecoration(
          //     border: OutlineInputBorder(),
          //     labelText: 'Pinyin',
          //   ),
          // ),
          ElevatedButton(
            child: Text("SYNTHESIZE"),
            onPressed: _initialized == false
                ? null
                : () async {
                    var file = await _ttsPlugin
                        .synthesize("你好", pronunciation: ["ni3", "hao3"]);
                    _advancedPlayer.play(file.path);
                  },
          ),
        ])),
      ),
    );
  }
}
