import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

class ViewPortHandler {
  /**
   * matrix used for touch events
   */
  final Matrix4 mMatrixTouch = Matrix4.identity();

  /**
   * this rectangle defines the area in which graph values can be drawn
   */
  Rect mContentRect = Rect.zero;

  double mChartWidth = 0;
  double mChartHeight = 0;

  /**
   * minimum scale value on the y-axis
   */
  double mMinScaleY = 1;

  /**
   * maximum scale value on the y-axis
   */
  double mMaxScaleY = 100;

  /**
   * minimum scale value on the x-axis
   */
  double mMinScaleX = 1;

  /**
   * maximum scale value on the x-axis
   */
  double mMaxScaleX = 100;

  /**
   * contains the current scale factor of the x-axis
   */
  double mScaleX = 1;

  /**
   * contains the current scale factor of the y-axis
   */
  double mScaleY = 1;

  /**
   * current translation (drag distance) on the x-axis
   */
  double mTransX = 0;

  /**
   * current translation (drag distance) on the y-axis
   */
  double mTransY = 0;

  /**
   * offset that allows the chart to be dragged over its bounds on the x-axis
   */
  double mTransOffsetX = 0;

  /**
   * offset that allows the chart to be dragged over its bounds on the x-axis
   */
  double mTransOffsetY = 0;

  /**
   * Constructor - don't forget calling setChartDimens(...)
   */
  ViewPortHandler() {}

  /**
   * Sets the width and height of the chart.
   *
   * @param width
   * @param height
   */

  void setChartDimens(double width, double height) {
    double offsetLeft = this.offsetLeft();
    double offsetTop = this.offsetTop();
    double offsetRight = this.offsetRight();
    double offsetBottom = this.offsetBottom();

    mChartHeight = height;
    mChartWidth = width;

    restrainViewPort(offsetLeft, offsetTop, offsetRight, offsetBottom);
  }

  bool hasChartDimens() {
    if (mChartHeight > 0 && mChartWidth > 0)
      return true;
    else
      return false;
  }

  void restrainViewPort(double offsetLeft, double offsetTop, double offsetRight,
      double offsetBottom) {
    mContentRect = Rect.fromLTRB(offsetLeft, offsetTop,
        mChartWidth - offsetRight, mChartHeight - offsetBottom);
  }

  double offsetLeft() {
    return mContentRect.left;
  }

  double offsetRight() {
    return mChartWidth - mContentRect.right;
  }

  double offsetTop() {
    return mContentRect.top;
  }

  double offsetBottom() {
    return mChartHeight - mContentRect.bottom;
  }

  double contentTop() {
    return mContentRect.top;
  }

  double contentLeft() {
    return mContentRect.left;
  }

  double contentRight() {
    return mContentRect.right;
  }

  double contentBottom() {
    return mContentRect.bottom;
  }

  double contentWidth() {
    return mContentRect.width;
  }

  double contentHeight() {
    return mContentRect.height;
  }

  Rect getContentRect() {
    return mContentRect;
  }

  MPPointF getContentCenter() {
    return MPPointF.getInstance1(
        mContentRect.center.dx, mContentRect.center.dy);
  }

  double getChartHeight() {
    return mChartHeight;
  }

  double getChartWidth() {
    return mChartWidth;
  }

  /**
   * Returns the smallest extension of the content rect (width or height).
   *
   * @return
   */
  double getSmallestContentExtension() {
    return min(mContentRect.width, mContentRect.height);
  }

  /**
   * ################ ################ ################ ################
   */
  /** CODE BELOW THIS RELATED TO SCALING AND GESTURES */

  /**
   * Zooms in by 1.4f, x and y are the coordinates (in pixels) of the zoom
   * center.
   *
   * @param x
   * @param y
   */
  Matrix4 zoomIn1(double x, double y) {
    Matrix4 save = Matrix4.identity();
    zoomIn2(x, y, save);
    return save;
  }

  void zoomIn2(double x, double y, Matrix4 outputMatrix) {
    mMatrixTouch.copyInto(outputMatrix);
    Matrix4Utils.postScaleByPoint(outputMatrix, 1.4, 1.4, x, y);
  }

  /**
   * Zooms out by 0.7f, x and y are the coordinates (in pixels) of the zoom
   * center.
   */
  Matrix4 zoomOut1(double x, double y) {
    Matrix4 save = Matrix4.identity();
    zoomOut2(x, y, save);
    return save;
  }

  void zoomOut2(double x, double y, Matrix4 outputMatrix) {
    mMatrixTouch.copyInto(outputMatrix);
    Matrix4Utils.postScaleByPoint(outputMatrix, 0.7, 0.7, x, y);
  }

  /**
   * Zooms out to original size.
   * @param outputMatrix
   */
  void resetZoom(Matrix4 outputMatrix) {
    mMatrixTouch.copyInto(outputMatrix);
    Matrix4Utils.postScaleByPoint(outputMatrix, 1.0, 1.0, 0.0, 0.0);
  }

  /**
   * Post-scales by the specified scale factors.
   *
   * @param scaleX
   * @param scaleY
   * @return
   */
  Matrix4 zoom1(double scaleX, double scaleY) {
    Matrix4 save = Matrix4.identity();
    zoom2(scaleX, scaleY, save);
    return save;
  }

  void zoom2(double scaleX, double scaleY, Matrix4 outputMatrix) {
    mMatrixTouch.copyInto(outputMatrix);
    Matrix4Utils.postScale(outputMatrix, scaleX, scaleY);
  }

  /**
   * Post-scales by the specified scale factors. x and y is pivot.
   *
   * @param scaleX
   * @param scaleY
   * @param x
   * @param y
   * @return
   */
  Matrix4 zoom3(double scaleX, double scaleY, double x, double y) {
    Matrix4 save = Matrix4.identity();
    zoom4(scaleX, scaleY, x, y, save);
    return save;
  }

  void zoom4(
      double scaleX, double scaleY, double x, double y, Matrix4 outputMatrix) {
    mMatrixTouch.copyInto(outputMatrix);
    Matrix4Utils.postScaleByPoint(outputMatrix, scaleX, scaleY, x, y);
  }

  /**
   * Sets the scale factor to the specified values.
   *
   * @param scaleX
   * @param scaleY
   * @return
   */
  Matrix4 setZoom1(double scaleX, double scaleY) {
    Matrix4 save = Matrix4.identity();
    setZoom2(scaleX, scaleY, save);
    return save;
  }

  void setZoom2(double scaleX, double scaleY, Matrix4 outputMatrix) {
    mMatrixTouch.copyInto(outputMatrix);
    Matrix4Utils.setScale(outputMatrix, scaleX, scaleY);
  }

  /**
   * Sets the scale factor to the specified values. x and y is pivot.
   *
   * @param scaleX
   * @param scaleY
   * @param x
   * @param y
   * @return
   */
  Matrix4 setZoom3(double scaleX, double scaleY, double x, double y) {
    Matrix4 save = Matrix4.identity();
    save.add(mMatrixTouch);
    Matrix4Utils.setScaleByPoint(save, scaleX, scaleY, x, y);
    return save;
  }

  List<double> valsBufferForFitScreen = List(16);

  /**
   * Resets all zooming and dragging and makes the chart fit exactly it's
   * bounds.
   */
  Matrix4 fitScreen1() {
    Matrix4 save = Matrix4.identity();
    fitScreen2(save);
    return save;
  }

  /**
   * Resets all zooming and dragging and makes the chart fit exactly it's
   * bounds.  Output Matrix is available for those who wish to cache the object.
   */
  void fitScreen2(Matrix4 outputMatrix) {
    mMinScaleX = 1;
    mMinScaleY = 1;

    mMatrixTouch.copyInto(outputMatrix);

    outputMatrix
      ..storage[3] = 0
      ..storage[7] = 0
      ..storage[0] = 1
      ..storage[5] = 1;
    List<double> vals = valsBufferForFitScreen;
    for (int i = 0; i < 16; i++) {
      vals[i] = outputMatrix.storage[i];
    }
  }

  /**
   * Post-translates to the specified points.  Less Performant.
   *
   * @param transformedPts
   * @return
   */
  Matrix4 translate1(List<double> transformedPts) {
    Matrix4 save = Matrix4.identity();
    translate2(transformedPts, save);
    return save;
  }

  /**
   * Post-translates to the specified points.  Output matrix allows for caching objects.
   *
   * @param transformedPts
   * @return
   */
  void translate2(final List<double> transformedPts, Matrix4 outputMatrix) {
    mMatrixTouch.copyInto(outputMatrix);
    final double x = transformedPts[0] - offsetLeft();
    final double y = transformedPts[1] - offsetTop();
    Matrix4Utils.postTranslate(outputMatrix, -x, -y);
  }

  Matrix4 mCenterViewPortMatrixBuffer = Matrix4.identity();

  /**
   * Centers the viewport around the specified position (x-index and y-value)
   * in the chart. Centering the viewport outside the bounds of the chart is
   * not possible. Makes most sense in combination with the
   * setScaleMinima(...) method.
   *
   * @param transformedPts the position to center view viewport to
   * @param view
   * @return save
   */
  void centerViewPort(
      final List<double> transformedPts, final Function refresh) {
    mCenterViewPortMatrixBuffer = Matrix4.identity();
    Matrix4 save = mCenterViewPortMatrixBuffer;
    mMatrixTouch.copyInto(save);

    final double x = transformedPts[0] - offsetLeft();
    final double y = transformedPts[1] - offsetTop();

    Matrix4Utils.postTranslate(save, -x, -y);

    refresh(save, refresh, true);
  }

  List<double> matrixBuffer = List(16);

  /**
   * call this method to refresh the graph with a given matrix
   *
   * @param newMatrix
   * @return
   */
  Matrix4 refresh(Matrix4 newMatrix) {
    newMatrix.copyInto(mMatrixTouch);
    // make sure scale and translation are within their bounds
    limitTransAndScale(mMatrixTouch, mContentRect);
    mMatrixTouch.copyInto(newMatrix);
    return newMatrix;
  }

  /**
   * limits the maximum scale and X translation of the given matrix
   *
   * @param matrix
   */
  void limitTransAndScale(Matrix4 matrix, Rect content) {
    for (int i = 0; i < 16; i++) {
      matrixBuffer[i] = matrix.storage[i];
    }

    double curTransX = matrixBuffer[12];
    double curScaleX = matrixBuffer[0];

    double curTransY = matrixBuffer[13];
    double curScaleY = matrixBuffer[5];

    // min scale-x is 1f
    mScaleX = min(max(mMinScaleX, curScaleX), mMaxScaleX);

    // min scale-y is 1f
    mScaleY = min(max(mMinScaleY, curScaleY), mMaxScaleY);

    double width = 0;
    double height = 0;

    if (content != null) {
      width = content.width;
      height = content.height;
    }

    double maxTransX = -width * (mScaleX - 1);
    mTransX = min(max(curTransX, maxTransX - mTransOffsetX), mTransOffsetX);

    double maxTransY = height * (mScaleY - 1);
    mTransY = max(min(curTransY, maxTransY + mTransOffsetY), -mTransOffsetY);

    matrixBuffer[12] = mTransX;
    matrixBuffer[0] = mScaleX;

    matrixBuffer[13] = mTransY;
    matrixBuffer[5] = mScaleY;

    for (int i = 0; i < 16; i++) {
      matrix.storage[i] = matrixBuffer[i];
    }
  }

  /**
   * Sets the minimum scale factor for the x-axis
   *
   * @param xScale
   */
  void setMinimumScaleX(double xScale) {
    if (xScale < 1) xScale = 1;

    mMinScaleX = xScale;

    limitTransAndScale(mMatrixTouch, mContentRect);
  }

  /**
   * Sets the maximum scale factor for the x-axis
   *
   * @param xScale
   */
  void setMaximumScaleX(double xScale) {
    if (xScale == 0) xScale = double.infinity;

    mMaxScaleX = xScale;

    limitTransAndScale(mMatrixTouch, mContentRect);
  }

  /**
   * Sets the minimum and maximum scale factors for the x-axis
   *
   * @param minScaleX
   * @param maxScaleX
   */
  void setMinMaxScaleX(double minScaleX, double maxScaleX) {
    if (minScaleX < 1) minScaleX = 1;

    if (maxScaleX == 0) maxScaleX = double.infinity;

    mMinScaleX = minScaleX;
    mMaxScaleX = maxScaleX;

    limitTransAndScale(mMatrixTouch, mContentRect);
  }

  /**
   * Sets the minimum scale factor for the y-axis
   *
   * @param yScale
   */
  void setMinimumScaleY(double yScale) {
    if (yScale < 1) yScale = 1;

    mMinScaleY = yScale;

    limitTransAndScale(mMatrixTouch, mContentRect);
  }

  /**
   * Sets the maximum scale factor for the y-axis
   *
   * @param yScale
   */
  void setMaximumScaleY(double yScale) {
    if (yScale == 0) yScale = double.infinity;

    mMaxScaleY = yScale;

    limitTransAndScale(mMatrixTouch, mContentRect);
  }

  void setMinMaxScaleY(double minScaleY, double maxScaleY) {
    if (minScaleY < 1) minScaleY = 1;

    if (maxScaleY == 0) maxScaleY = double.infinity;

    mMinScaleY = minScaleY;
    mMaxScaleY = maxScaleY;

    limitTransAndScale(mMatrixTouch, mContentRect);
  }

  /**
   * Returns the charts-touch matrix used for translation and scale on touch.
   *
   * @return
   */
  Matrix4 getMatrixTouch() {
    return mMatrixTouch;
  }

  /**
   * ################ ################ ################ ################
   */
  /**
   * BELOW METHODS FOR BOUNDS CHECK
   */

  bool isInBoundsX(double x) {
    return isInBoundsLeft(x) && isInBoundsRight(x);
  }

  bool isInBoundsY(double y) {
    return isInBoundsTop(y) && isInBoundsBottom(y);
  }

  bool isInBounds(double x, double y) {
    return isInBoundsX(x) && isInBoundsY(y);
  }

  bool isInBoundsLeft(double x) {
    return mContentRect.left <= x + 1;
  }

  bool isInBoundsRight(double x) {
    x = ((x * 100.0).toInt()) / 100.0;
    return mContentRect.right >= x - 1;
  }

  bool isInBoundsTop(double y) {
    return mContentRect.top <= y;
  }

  bool isInBoundsBottom(double y) {
    y = ((y * 100.0).toInt()) / 100.0;
    return mContentRect.bottom >= y;
  }

  /**
   * returns the current x-scale factor
   */
  double getScaleX() {
    return mScaleX;
  }

  /**
   * returns the current y-scale factor
   */
  double getScaleY() {
    return mScaleY;
  }

  double getMinScaleX() {
    return mMinScaleX;
  }

  double getMaxScaleX() {
    return mMaxScaleX;
  }

  double getMinScaleY() {
    return mMinScaleY;
  }

  double getMaxScaleY() {
    return mMaxScaleY;
  }

  /**
   * Returns the translation (drag / pan) distance on the x-axis
   *
   * @return
   */
  double getTransX() {
    return mTransX;
  }

  /**
   * Returns the translation (drag / pan) distance on the y-axis
   *
   * @return
   */
  double getTransY() {
    return mTransY;
  }

  /**
   * if the chart is fully zoomed out, return true
   *
   * @return
   */
  bool isFullyZoomedOut() {
    return isFullyZoomedOutX() && isFullyZoomedOutY();
  }

  /**
   * Returns true if the chart is fully zoomed out on it's y-axis (vertical).
   *
   * @return
   */
  bool isFullyZoomedOutY() {
    return !(mScaleY > mMinScaleY || mMinScaleY > 1);
  }

  /**
   * Returns true if the chart is fully zoomed out on it's x-axis
   * (horizontal).
   *
   * @return
   */
  bool isFullyZoomedOutX() {
    return !(mScaleX > mMinScaleX || mMinScaleX > 1);
  }

  /**
   * Set an offset in dp that allows the user to drag the chart over it's
   * bounds on the x-axis.
   *
   * @param offset
   */
  void setDragOffsetX(double offset) {
    mTransOffsetX = Utils.convertDpToPixel(offset);
  }

  /**
   * Set an offset in dp that allows the user to drag the chart over it's
   * bounds on the y-axis.
   *
   * @param offset
   */
  void setDragOffsetY(double offset) {
    mTransOffsetY = Utils.convertDpToPixel(offset);
  }

  /**
   * Returns true if both drag offsets (x and y) are zero or smaller.
   *
   * @return
   */
  bool hasNoDragOffset() {
    return mTransOffsetX <= 0 && mTransOffsetY <= 0;
  }

  /**
   * Returns true if the chart is not yet fully zoomed out on the x-axis
   *
   * @return
   */
  bool canZoomOutMoreX() {
    return mScaleX > mMinScaleX;
  }

  /**
   * Returns true if the chart is not yet fully zoomed in on the x-axis
   *
   * @return
   */
  bool canZoomInMoreX() {
    return mScaleX < mMaxScaleX;
  }

  /**
   * Returns true if the chart is not yet fully zoomed out on the y-axis
   *
   * @return
   */
  bool canZoomOutMoreY() {
    return mScaleY > mMinScaleY;
  }

  /**
   * Returns true if the chart is not yet fully zoomed in on the y-axis
   *
   * @return
   */
  bool canZoomInMoreY() {
    return mScaleY < mMaxScaleY;
  }
}

class HorizontalViewPortHandler extends ViewPortHandler{

}
