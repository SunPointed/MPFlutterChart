import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/matrix4_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class TransformerHorizontalBarChart extends Transformer {
  TransformerHorizontalBarChart(ViewPortHandler viewPortHandler)
      : super(viewPortHandler);

  /**
   * Prepares the matrix that contains all offsets.
   *
   * @param inverted
   */
  void prepareMatrixOffset(bool inverted) {
    mMatrixOffset = Matrix4.identity();

    // offset.postTranslate(mOffsetLeft, getHeight() - mOffsetBottom);

    if (!inverted)
      Matrix4Utils.postTranslate(mMatrixOffset, mViewPortHandler.offsetLeft(),
          mViewPortHandler.getChartHeight() - mViewPortHandler.offsetBottom());
    else {
      Matrix4Utils.setTranslate(
          mMatrixOffset,
          -(mViewPortHandler.getChartWidth() - mViewPortHandler.offsetRight()),
          mViewPortHandler.getChartHeight() - mViewPortHandler.offsetBottom());
      Matrix4Utils.postScale(mMatrixOffset, -1.0, 1.0);
    }

    // mMatrixOffset.set(offset);

    // mMatrixOffset.reset();
    //
    // mMatrixOffset.postTranslate(mOffsetLeft, getHeight() -
    // mOffsetBottom);
  }
}
