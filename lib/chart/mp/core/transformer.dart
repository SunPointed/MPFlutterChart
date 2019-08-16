import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

class Transformer {
  /**
   * matrix to map the values to the screen pixels
   */
  Matrix4 mMatrixValueToPx = Matrix4.identity();

  /**
   * matrix for handling the different offsets of the chart
   */
  Matrix4 mMatrixOffset = Matrix4.identity();

  ViewPortHandler mViewPortHandler;

  Transformer(ViewPortHandler viewPortHandler) {
    this.mViewPortHandler = viewPortHandler;
  }

  /**
   * Prepares the matrix that Matrix4Utils.transforms values to pixels. Calculates the
   * scale factors from the charts size and offsets.
   *
   * @param xChartMin
   * @param deltaX
   * @param deltaY
   * @param yChartMin
   */
  void prepareMatrixValuePx(
      double xChartMin, double deltaX, double deltaY, double yChartMin) {

    double scaleX = ((mViewPortHandler.contentWidth()) / deltaX);
    double scaleY = ((mViewPortHandler.contentHeight()) / deltaY);

    if (scaleX.isInfinite) {
      scaleX = 0;
    }
    if (scaleY.isInfinite) {
      scaleY = 0;
    }

    // setup all matrices
    mMatrixValueToPx = Matrix4.identity();
    Matrix4Utils.postTranslate(mMatrixValueToPx, -xChartMin, -yChartMin);
    Matrix4Utils.postScale(mMatrixValueToPx, scaleX, -scaleY);
  }

  /**
   * Prepares the matrix that contains all offsets.
   *
   * @param copyInverseed
   */
  void prepareMatrixOffset(bool copyInverseed) {
    mMatrixOffset = Matrix4.identity();

    // offset.postTranslate(mOffsetLeft, getHeight() - mOffsetBottom);

    if (!copyInverseed)
      Matrix4Utils.postTranslate(mMatrixOffset, mViewPortHandler.offsetLeft(),
          mViewPortHandler.getChartHeight() - mViewPortHandler.offsetBottom());
    else {
      Matrix4Utils.postTranslate(mMatrixOffset, mViewPortHandler.offsetLeft(),
          -mViewPortHandler.offsetTop());
      Matrix4Utils.postScale(mMatrixOffset, 1.0, -1.0);
    }
  }

  List<double> valuePointsForGenerateTransformedValuesScatter = List(1);

  /**
   * Transforms an List of Entry into a double array containing the x and
   * y values Matrix4Utils.transformed with all matrices for the SCATTERCHART.
   *
   * @param data
   * @return
   */
  List<double> generateTransformedValuesScatter(
      IScatterDataSet data, double phaseX, double phaseY, int from, int to) {
    final int count = (((to - from) * phaseX + 1) * 2).toInt();

    if (valuePointsForGenerateTransformedValuesScatter.length != count) {
      valuePointsForGenerateTransformedValuesScatter = List(count);
    }
    List<double> valuePoints = valuePointsForGenerateTransformedValuesScatter;

    for (int j = 0; j < count; j += 2) {
      Entry e = data.getEntryForIndex(j ~/ 2 + from);

      if (e != null) {
        valuePoints[j] = e.x;
        valuePoints[j + 1] = e.y * phaseY;
      } else {
        valuePoints[j] = 0;
        valuePoints[j + 1] = 0;
      }
    }

    Matrix4Utils.mapPoints(getValueToPixelMatrix(), valuePoints);

    return valuePoints;
  }

  List<double> valuePointsForGenerateTransformedValuesBubble = List(1);

  /**
   * Transforms an List of Entry into a double array containing the x and
   * y values Matrix4Utils.transformed with all matrices for the BUBBLECHART.
   *
   * @param data
   * @return
   */
  List<double> generateTransformedValuesBubble(
      IBubbleDataSet data, double phaseY, int from, int to) {
    final int count =
        (to - from + 1) * 2; // (int) Math.ceil((to - from) * phaseX) * 2;

    if (valuePointsForGenerateTransformedValuesBubble.length != count) {
      valuePointsForGenerateTransformedValuesBubble = List(count);
    }
    List<double> valuePoints = valuePointsForGenerateTransformedValuesBubble;

    for (int j = 0; j < count; j += 2) {
      Entry e = data.getEntryForIndex(j ~/ 2 + from);

      if (e != null) {
        valuePoints[j] = e.x;
        valuePoints[j + 1] = e.y * phaseY;
      } else {
        valuePoints[j] = 0;
        valuePoints[j + 1] = 0;
      }
    }

    Matrix4Utils.mapPoints(getValueToPixelMatrix(), valuePoints);

    return valuePoints;
  }

  List<double> valuePointsForGenerateTransformedValuesLine = List(1);

  /**
   * Transforms an List of Entry into a double array containing the x and
   * y values Matrix4Utils.transformed with all matrices for the LINECHART.
   *
   * @param data
   * @return
   */
  List<double> generateTransformedValuesLine(
      ILineDataSet data, double phaseX, double phaseY, int min, int max) {
    final int count = ((((max - min) * phaseX) + 1).toInt() * 2);

    if (valuePointsForGenerateTransformedValuesLine.length != count) {
      valuePointsForGenerateTransformedValuesLine = List(count);
    }
    List<double> valuePoints = valuePointsForGenerateTransformedValuesLine;

    for (int j = 0; j < count; j += 2) {
      Entry e = data.getEntryForIndex(j ~/ 2 + min);

      if (e != null) {
        valuePoints[j] = e.x;
        valuePoints[j + 1] = e.y * phaseY;
      } else {
        valuePoints[j] = 0;
        valuePoints[j + 1] = 0;
      }
    }

    Matrix4Utils.mapPoints(getValueToPixelMatrix(), valuePoints);

    return valuePoints;
  }

  List<double> valuePointsForGenerateTransformedValuesCandle = List(1);

  /**
   * Transforms an List of Entry into a double array containing the x and
   * y values Matrix4Utils.transformed with all matrices for the CANDLESTICKCHART.
   *
   * @param data
   * @return
   */
  List<double> generateTransformedValuesCandle(
      ICandleDataSet data, double phaseX, double phaseY, int from, int to) {
    final int count = (((to - from) * phaseX + 1) * 2).toInt();

    if (valuePointsForGenerateTransformedValuesCandle.length != count) {
      valuePointsForGenerateTransformedValuesCandle = List(count);
    }
    List<double> valuePoints = valuePointsForGenerateTransformedValuesCandle;

    for (int j = 0; j < count; j += 2) {
      CandleEntry e = data.getEntryForIndex(j ~/ 2 + from);

      if (e != null) {
        valuePoints[j] = e.x;
        valuePoints[j + 1] = e.getHigh() * phaseY;
      } else {
        valuePoints[j] = 0;
        valuePoints[j + 1] = 0;
      }
    }

    Matrix4Utils.mapPoints(getValueToPixelMatrix(), valuePoints);

    return valuePoints;
  }

  /**
   * Transform an array of points with all matrices. VERY IMPORTANT: Keep
   * matrix order "value-touch-offset" when Matrix4Utils.transforming.
   *
   * @param pts
   */
  void pointValuesToPixel(List<double> pts) {
    Matrix4Utils.mapPoints(mMatrixValueToPx, pts);
    Matrix4Utils.mapPoints(mViewPortHandler.getMatrixTouch(), pts);
    Matrix4Utils.mapPoints(mMatrixOffset, pts);
  }

  /**
   * Transform a rectangle with all matrices.
   *
   * @param r
   */
  Rect rectValueToPixel(Rect r) {
    r = Matrix4Utils.mapRect(mMatrixValueToPx, r);
    r = Matrix4Utils.mapRect(mViewPortHandler.getMatrixTouch(), r);
    r = Matrix4Utils.mapRect(mMatrixOffset, r);
    return r;
  }

  /**
   * Transform a rectangle with all matrices with potential animation phases.
   *
   * @param r
   * @param phaseY
   */
  Rect rectToPixelPhase(Rect r, double phaseY) {
    // multiply the height of the rect with the phase
    r = Rect.fromLTRB(r.left, r.top * phaseY, r.right, r.bottom * phaseY);

    r = Matrix4Utils.mapRect(mMatrixValueToPx, r);
    r = Matrix4Utils.mapRect(mViewPortHandler.getMatrixTouch(), r);
    r = Matrix4Utils.mapRect(mMatrixOffset, r);
    return r;
  }

  Rect rectToPixelPhaseHorizontal(Rect r, double phaseY) {
    // multiply the height of the rect with the phase
    r = Rect.fromLTRB(r.left * phaseY, r.top, r.right * phaseY, r.bottom);

    r = Matrix4Utils.mapRect(mMatrixValueToPx, r);
    r = Matrix4Utils.mapRect(mViewPortHandler.getMatrixTouch(), r);
    r = Matrix4Utils.mapRect(mMatrixOffset, r);
    return r;
  }

  /**
   * Transform a rectangle with all matrices with potential animation phases.
   *
   * @param r
   */
  Rect rectValueToPixelHorizontal1(Rect r) {
    r = Matrix4Utils.mapRect(mMatrixValueToPx, r);
    r = Matrix4Utils.mapRect(mViewPortHandler.getMatrixTouch(), r);
    r = Matrix4Utils.mapRect(mMatrixOffset, r);
    return r;
  }

  /**
   * Transform a rectangle with all matrices with potential animation phases.
   *
   * @param r
   * @param phaseY
   */
  Rect rectValueToPixelHorizontal2(Rect r, double phaseY) {
    // multiply the height of the rect with the phase
    r = Rect.fromLTRB(r.left * phaseY, r.top, r.right * phaseY, r.bottom);

    r = Matrix4Utils.mapRect(mMatrixValueToPx, r);
    r = Matrix4Utils.mapRect(mViewPortHandler.getMatrixTouch(), r);
    r = Matrix4Utils.mapRect(mMatrixOffset, r);
    return r;
  }

  /**
   * Matrix4Utils.transforms multiple rects with all matrices
   *
   * @param rects
   */
  void rectValuesToPixel(List<Rect> rects) {
    Matrix4 m = getValueToPixelMatrix();

    for (int i = 0; i < rects.length; i++) rects[i] = Matrix4Utils.mapRect(m, rects[i]);
  }

  Matrix4 mPixelToValueMatrixBuffer = Matrix4.identity();

  /**
   * Transforms the given array of touch positions (pixels) (x, y, x, y, ...)
   * into values on the chart.
   *
   * @param pixels
   */
  void pixelsToValue(List<double> pixels) {
    mPixelToValueMatrixBuffer = Matrix4.identity();
    Matrix4 tmp = mPixelToValueMatrixBuffer;
    // copyInverse all matrixes to convert back to the original value
    tmp.copyInverse(mMatrixOffset);
    Matrix4Utils.mapPoints(tmp, pixels);

    tmp.copyInverse(mViewPortHandler.getMatrixTouch());
    Matrix4Utils.mapPoints(tmp, pixels);

    tmp.copyInverse(mMatrixValueToPx);
    Matrix4Utils.mapPoints(tmp, pixels);
  }

  /**
   * buffer for performance
   */
  List<double> ptsBuffer = List(2);

  /**
   * Returns a recyclable MPPointD instance.
   * returns the x and y values in the chart at the given touch point
   * (encapsulated in a MPPointD). This method Matrix4Utils.transforms pixel coordinates to
   * coordinates / values in the chart. This is the opposite method to
   * getPixelForValues(...).
   *
   * @param x
   * @param y
   * @return
   */
  MPPointD getValuesByTouchPoint1(double x, double y) {
    MPPointD result = MPPointD.getInstance1(0, 0);
    getValuesByTouchPoint2(x, y, result);
    return result;
  }

  void getValuesByTouchPoint2(double x, double y, MPPointD outputPoint) {
    ptsBuffer[0] = x;
    ptsBuffer[1] = y;

    pixelsToValue(ptsBuffer);

    outputPoint.x = ptsBuffer[0];
    outputPoint.y = ptsBuffer[1];
  }

  /**
   * Returns a recyclable MPPointD instance.
   * Returns the x and y coordinates (pixels) for a given x and y value in the chart.
   *
   * @param x
   * @param y
   * @return
   */
  MPPointD getPixelForValues(double x, double y) {
    ptsBuffer[0] = x;
    ptsBuffer[1] = y;

    pointValuesToPixel(ptsBuffer);

    double xPx = ptsBuffer[0];
    double yPx = ptsBuffer[1];

    return MPPointD.getInstance1(xPx, yPx);
  }

  Matrix4 getValueMatrix() {
    return mMatrixValueToPx;
  }

  Matrix4 getOffsetMatrix() {
    return mMatrixOffset;
  }

  Matrix4 mMBuffer1 = Matrix4.identity();

  Matrix4 getValueToPixelMatrix() {
    mMatrixValueToPx.copyInto(mMBuffer1);
    Matrix4Utils.postConcat(mMBuffer1, mViewPortHandler.mMatrixTouch);
    Matrix4Utils.postConcat(mMBuffer1, mMatrixOffset);
    return mMBuffer1;
  }

  Matrix4 mMBuffer2 = Matrix4.identity();

  Matrix4 getPixelToValueMatrix() {
    mMBuffer2.copyInverse(getValueToPixelMatrix());
    return mMBuffer2;
  }
}
