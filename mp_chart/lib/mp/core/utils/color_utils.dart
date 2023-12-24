import 'package:flutter/painting.dart';

abstract class ColorUtils {
  // ignore: non_constant_identifier_names
  static const Color BLUE = Color(0xFF0000FF);

  // ignore: non_constant_identifier_names
  static const Color COLOR_SKIP = Color(0x00112234);

  // ignore: non_constant_identifier_names
  static const Color COLOR_NONE = Color(0x00112233);

  // ignore: non_constant_identifier_names
  static const Color DKGRAY = Color(0xFF444444);

  // ignore: non_constant_identifier_names
  static const Color GRAY = Color(0xFF999999);

  // ignore: non_constant_identifier_names
  static const Color YELLOW = Color(0xFFFFFF00);

  // ignore: non_constant_identifier_names
  static const Color BLACK = Color(0xFF000000);

  // ignore: non_constant_identifier_names
  static const Color LTGRAY = Color(0xFFCCCCCC);

  // ignore: non_constant_identifier_names
  static const Color RED = FADE_RED_END;

  // ignore: non_constant_identifier_names
  static const Color HOLO_BLUE = Color.fromARGB(255, 51, 181, 229);

  // ignore: non_constant_identifier_names
  static const  Color WHITE = Color(0xFFFFFFFF);

  // ignore: non_constant_identifier_names
  static const Color PURPLE = Color(0xFF512DA8);

  // ignore: non_constant_identifier_names
  static const Color FADE_RED_START = Color(0x00FF0000);

  // ignore: non_constant_identifier_names
  static const Color FADE_RED_END = Color(0xFFFF0000);

// ignore: non_constant_identifier_names
  static const Color HOLO_ORANGE_LIGHT = Color(0xffffbb33);

  // ignore: non_constant_identifier_names
  static const Color HOLO_BLUE_LIGHT = Color(0xff33b5e5);

  // ignore: non_constant_identifier_names
  static const Color HOLO_GREEN_LIGHT = Color(0xff99cc00);

  // ignore: non_constant_identifier_names
  static const Color HOLO_RED_LIGHT = Color(0xffff4444);

  // ignore: non_constant_identifier_names
  static const Color HOLO_BLUE_DARK = Color(0xff0099cc);

  // ignore: non_constant_identifier_names
  static const Color HOLO_PURPLE = Color(0xffaa66cc);

  // ignore: non_constant_identifier_names
  static const Color HOLO_GREEN_DARK = Color(0xff669900);

  // ignore: non_constant_identifier_names
  static const Color HOLO_RED_DARK = Color(0xffcc0000);

  // ignore: non_constant_identifier_names
  static const Color HOLO_ORANGE_DARK = Color(0xffff8800);

// ignore: non_constant_identifier_names
  static final List<Color> VORDIPLOM_COLORS = <Color>[
    Color.fromARGB(255, 192, 255, 140),
    Color.fromARGB(255, 255, 247, 140),
    Color.fromARGB(255, 255, 208, 140),
    Color.fromARGB(255, 140, 234, 255),
    Color.fromARGB(255, 255, 140, 157)];

// ignore: non_constant_identifier_names
  static final List<Color> JOYFUL_COLORS = <Color>[
    Color.fromARGB(255, 217, 80, 138),
    Color.fromARGB(255, 254, 149, 7),
    Color.fromARGB(255, 254, 247, 120),
    Color.fromARGB(255, 106, 167, 134),
    Color.fromARGB(255, 53, 194, 209),
    ];

// ignore: non_constant_identifier_names
  static final List<Color> MATERIAL_COLORS = <Color>[
    Color(0xFF2ecc71),
    Color(0xFFf1c40f),
    Color(0xFFe74c3c),
    Color(0xFF3498db),
    ];

// ignore: non_constant_identifier_names
  static final List<Color> COLORFUL_COLORS = <Color>[
    Color.fromARGB(255, 193, 37, 82),
    Color.fromARGB(255, 255, 102, 0),
    Color.fromARGB(255, 245, 199, 0),
    Color.fromARGB(255, 106, 150, 31),
    Color.fromARGB(255, 179, 100, 53),
    ];

// ignore: non_constant_identifier_names
  static final List<Color> LIBERTY_COLORS = <Color>[
    Color.fromARGB(255, 207, 248, 246),
    Color.fromARGB(255, 148, 212, 212),
    Color.fromARGB(255, 136, 180, 187),
    Color.fromARGB(255, 118, 174, 175),
    Color.fromARGB(255, 42, 109, 130),
    ];

// ignore: non_constant_identifier_names
  static final List<Color> PASTEL_COLORS = <Color>[
    Color.fromARGB(255, 64, 89, 128),
    Color.fromARGB(255, 149, 165, 124),
    Color.fromARGB(255, 217, 184, 162),
    Color.fromARGB(255, 191, 134, 134),
    Color.fromARGB(255, 179, 48, 80),
    ];

  static Color colorWithAlpha(Color strokeColor, int alpha) {
    return Color.fromARGB(
        alpha, strokeColor.red, strokeColor.green, strokeColor.blue);
  }

  static Color getHoloBlue() {
    return Color.fromARGB(255, 51, 181, 229);
  }
}
