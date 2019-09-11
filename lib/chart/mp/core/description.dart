import 'dart:core';
import 'dart:ui';

import 'package:mp_flutter_chart/chart/mp/core/component.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class Description extends ComponentBase {
  /// the text used in the description
  String text = "Description Label";

  /// the custom position of the description text
  MPPointF mPosition;

  /// the alignment of the description text
  TextAlign mTextAlign = TextAlign.right;

  Description() : super() {
    // default size
    mTextSize = Utils.convertDpToPixel(8);
  }

  /// Sets the text to be shown as the description.
  /// Never set this to null as this will cause nullpointer exception when drawing with Android Canvas.
  ///
  /// @param text
  void setText(String text) {
    this.text = text;
  }

  /// Returns the description text.
  ///
  /// @return
  String getText() {
    return text;
  }

  /// Sets a custom position for the description text in pixels on the screen.
  ///
  /// @param x - xcoordinate
  /// @param y - ycoordinate
  void setPosition(double x, double y) {
    if (mPosition == null) {
      mPosition = MPPointF.getInstance1(x, y);
    } else {
      mPosition.x = x;
      mPosition.y = y;
    }
  }

  /// Returns the customized position of the description, or null if none set.
  ///
  /// @return
  MPPointF getPosition() {
    return mPosition;
  }

  /// Sets the text alignment of the description text. Default RIGHT.
  ///
  /// @param align
  void setTextAlign(TextAlign align) {
    this.mTextAlign = align;
  }

  /// Returns the text alignment of the description.
  ///
  /// @return
  TextAlign getTextAlign() {
    return mTextAlign;
  }
}
