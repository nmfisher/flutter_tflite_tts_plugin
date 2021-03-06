import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tflite_tts/preprocessor.dart';
import 'package:tflite_tts/tflite_tts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioPlayer _advancedPlayer = AudioPlayer();

  TfliteTts _tts = TfliteTts();
  bool _initialized = false;
  TextEditingController _pinyinController = TextEditingController();
  TextEditingController _charController = TextEditingController();
  Preprocessor _preprocessor;

  @override
  void initState() {
    rootBundle.loadString("assets/baker_mapper.json").then((p) {
      _preprocessor = Preprocessor(p);
    });

    super.initState();
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
          RaisedButton(
              child: Text("INITIALIZE"),
              onPressed: () async {
                setState(() {
                  _initialized = false;
                });
                await _tts.initialize();
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
          RaisedButton(
            child: Text("SYNTHESIZE"),
            onPressed: _initialized == false
                ? null
                : () async {
                    var symbolIds =
                        _preprocessor.textToSequence("你好", ["ni3", "hao3"]);
                        print("Got symbol ids $symbolIds");
                    var file = await _tts.synthesize(symbolIds);
                    _advancedPlayer.play(file.path);
                  },
          ),
        ])),
      ),
    );
  }
}

