import 'package:path_provider/path_provider.dart' ;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/method_channel_audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:incredible_tts/incredible_tts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioPlayer _advancedPlayer = AudioPlayer();


  IncredibleTts _tts = IncredibleTts();
  bool _initialized = false;

  @override
  void initState() {
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
          RaisedButton(
            child: Text("GO"),
            onPressed: _initialized == false
                ? null
                : () {
                    _tts.go();
                  },
          ),
          RaisedButton(
            child: Text("PLAY"),
            onPressed: () async {
              _advancedPlayer.play((await getTemporaryDirectory()).path + "/foobar.wav");
            }
          ),
        ])),
      ),
    );
  }
}
