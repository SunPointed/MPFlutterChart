//import 'package:flutter/painting.dart';
//
//class ColorTemplate {
//  /**
//   * an "invalid" color that indicates that no color is set
//   */
//  static final Color COLOR_NONE = Color(0x00112233);
//
//  /**
//   * this "color" is used for the Legend creation and indicates that the next
//   * form should be skipped
//   */
//  static final Color COLOR_SKIP = Color(0x00112234);
//
//  /**
//   * THE COLOR THEMES ARE PREDEFINED (predefined color integer arrays), FEEL
//   * FREE TO CREATE YOUR OWN WITH AS MANY DIFFERENT COLORS AS YOU WANT
//   */
//  static final List<Color> LIBERTY_COLORS = List()
//    ..add(Color.fromARGB(255, 207, 248, 246))..add(
//        Color.fromARGB(255, 148, 212, 212))..add(
//        Color.fromARGB(255, 136, 180, 187))..add(
//        Color.fromARGB(255, 118, 174, 175))..add(
//        Color.fromARGB(255, 42, 109, 130));
//
//  static final List<Color> JOYFUL_COLORS = List()
//    ..add(Color.fromARGB(255, 217, 80, 138))..add(
//        Color.fromARGB(255, 254, 149, 7))..add(
//        Color.fromARGB(255, 254, 247, 120))..add(
//        Color.fromARGB(255, 106, 167, 134))..add(
//        Color.fromARGB(255, 53, 194, 209));
//  static final List<Color> PASTEL_COLORS = List()
//    ..add(Color.fromARGB(255, 64, 89, 128))..add(
//        Color.fromARGB(255, 149, 165, 124))..add(
//        Color.fromARGB(255, 217, 184, 162))..add(
//        Color.fromARGB(255, 191, 134, 134))..add(
//        Color.fromARGB(255, 179, 48, 80));
//  static final List<Color> COLORFUL_COLORS = List()
//    ..add(Color.fromARGB(255, 193, 37, 82))..add(
//        Color.fromARGB(255, 255, 102, 0))..add(
//        Color.fromARGB(255, 245, 199, 0))..add(
//        Color.fromARGB(255, 106, 150, 31))..add(
//        Color.fromARGB(255, 179, 100, 53));
//  static final List<Color> VORDIPLOM_COLORS = List()
//    ..add(Color.fromARGB(255, 192, 255, 140))..add(
//        Color.fromARGB(255, 255, 247, 140))..add(
//        Color.fromARGB(255, 255, 208, 140))..add(
//        Color.fromARGB(255, 140, 234, 255))..add(
//        Color.fromARGB(255, 255, 140, 157));
//  static final List<Color> MATERIAL_COLORS = List()
//    ..add(Color(0xff2ecc71))..add(Color(0xfff1c40f))..add(
//        Color(0xffe74c3c))..add(Color(0xff3498db));
//
//  /**
//   * Converts the given hex-color-string to rgb.
//   *
//   * @param hex
//   * @return
//   */
//  static Color rgb(String hex) {
//    int color = int.parse(hex.replaceAll("#", ""), radix: 16);
//    int r = (color >> 16) & 0xFF;
//    int g = (color >> 8) & 0xFF;
//    int b = (color >> 0) & 0xFF;
//    return Color.fromARGB(255, r, g, b);
//  }
//
//  /**
//   * Returns the Android ICS holo blue light color.
//   *
//   * @return
//   */
//  static Color getHoloBlue() {
//    return Color.fromARGB(255, 51, 181, 229);
//  }
//
//  /**
//   * Sets the alpha component of the given color.
//   *
//   * @param color
//   * @param alpha 0 - 255
//   * @return
//   */
//  static Color colorWithAlpha(Color color, int alpha) {
//    return Color((color.value & 0xffffff) | ((alpha & 0xff) << 24));
//  }
//
//  /**
//   * Turns an array of colors (integer color values) into an ArrayList of
//   * colors.
//   *
//   * @param colors
//   * @return
//   */
//  static List<Color> createColors(List<Color> colors) {
//    List<Color> result = List();
//
//    for (Color i in colors) {
//      result.add(i);
//    }
//    return result;
//  }
//}