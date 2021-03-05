import 'dart:convert';
import 'package:tuple/tuple.dart';

class Preprocessor {
  Map<String, dynamic> _mapper;
  int _eosId;
  
  Preprocessor(String mapperJson) {
    _mapper = json.decode(mapperJson);
    _eosId = _symbolToId(_eos[0]);
  }

  int _symbolToId(String symbol) {
    return _mapper["symbol_to_id"][symbol];
  }

  Tuple2<String, String> _pinyinDict(String pinyin) {
    if(!_mapper["pinyin_dict"].containsKey(pinyin))
      return null;
    return Tuple2.fromList(_mapper["pinyin_dict"][pinyin]);
  }

  static List<String> _pad = ["pad"];
  static List<String> _eos = ["eos"];
  static List<String> _pause = ["sil", "#0", "#1", "#2", "#3"];

  static List<String> _initials = [
    "^",
    "b",
    "c",
    "ch",
    "d",
    "f",
    "g",
    "h",
    "j",
    "k",
    "l",
    "m",
    "n",
    "p",
    "q",
    "r",
    "s",
    "sh",
    "t",
    "x",
    "z",
    "zh",
  ];

  static List<String> _tones = ["1", "2", "3", "4", "5"];

  static List<String> _finals = [
    "a",
    "ai",
    "an",
    "ang",
    "ao",
    "e",
    "ei",
    "en",
    "eng",
    "er",
    "i",
    "ia",
    "ian",
    "iang",
    "iao",
    "ie",
    "ii",
    "iii",
    "in",
    "ing",
    "iong",
    "iou",
    "o",
    "ong",
    "ou",
    "u",
    "ua",
    "uai",
    "uan",
    "uang",
    "uei",
    "uen",
    "ueng",
    "uo",
    "v",
    "van",
    "ve",
    "vn",
  ];

  static List<String> BAKER_SYMBOLS = _pad +
      _pause +
      _initials +
      _finals.map((i) => _tones.map((j) => i + j)).expand((x) => x) +
      _eos;

  static RegExp zhPattern = RegExp("[\u4e00-\u9fa5]");

  bool isZH(word) {
    return zhPattern.hasMatch(word);
  }

  List<String> getPhoneme(String character, List<String> pinyin) {
    character = character.replaceAll("#4", "");
    int charLen = character.length;
    int i = 0, j = 0;
    
    var result = ["sil"];
    while (i < charLen) {
      var curChar = character[i];
      print(curChar);
      if (isZH(curChar)) {
        if (_pinyinDict(pinyin[j].substring(0, pinyin[j].length - 1)) == null) {
          assert(character[i + 1] == "儿");
          assert(pinyin[j][pinyin[j].length - 2] == "r");
          var tone = pinyin[j][pinyin[j].length - 1];
          var p = _pinyinDict(pinyin[j].substring(0, pinyin[j].length - 1));

          result += [ p.item1, p.item2 + tone, "er5"];
          if (i + 2 < charLen && character[i + 2] != "#") result.add("#0");
          i += 2;
          j += 1;
        } else {
          var tone = pinyin[j][pinyin[j].length - 1];
          var p = _pinyinDict(pinyin[j].substring(0, pinyin[j].length - 1));

          result += [p.item1, p.item2 + tone];

          if (i + 1 < charLen && character[i + 1] != "#") result.add("#0");
          i += 1;
          j += 1;
        }
      } else if (curChar == "#") {
        result.add(character.substring(i, i + 2));
        i += 2;
      } else {
        i += 1;
      }
    }
    if (result.last == "#0") result = result.sublist(0, result.length - 1);
    result.add("sil");
    assert(j == pinyin.length);
    print("Resul $result");
    return result;
  }

  List<int> textToSequence(String text, List<String> pinyin) {
    var phonemes = getPhoneme(text, pinyin);

    var sequence = phonemes.map(_symbolToId).toList();
    sequence += [_eosId];
    return sequence;
  }
}
