import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incredible_tts/incredible_tts.dart';

void main() {
  const MethodChannel channel = MethodChannel('incredible_tts');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await IncredibleTts.platformVersion, '42');
  });
}
