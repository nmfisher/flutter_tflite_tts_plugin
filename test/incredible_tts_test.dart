import 'package:flutter_test/flutter_test.dart';

import '../lib/preprocessor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
  });

  tearDown(() {
  });

  test('getSymbolIds', () async {
    
    var pp = Preprocessor("lib/assets/baker_mapper.json");
    var symbolIds = pp.textToSequence("张文你好", ["zhang1", "wen2", "ni3", "hao3"]);
    expect(symbolIds, ["a"]);
  });
}

