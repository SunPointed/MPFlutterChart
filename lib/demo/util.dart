import 'package:flutter/services.dart' show rootBundle;

abstract class Util {
  static Future<String> loadAsset(String filename) async {
    return await rootBundle.loadString('assets/$filename');
  }
}
