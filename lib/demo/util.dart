import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

abstract class Util {
  static Future<String> loadAsset(String filename) async {
    return await rootBundle.loadString('assets/$filename');
  }

  static int currentTimeMillis() {
    return new DateTime.now().millisecondsSinceEpoch;
  }

  static void openGithub() {
    _launchURL();
  }

  static void _launchURL() async {
    const url = 'https://github.com/SunPointed/js_learn';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}
