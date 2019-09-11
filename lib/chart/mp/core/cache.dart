import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_data_set.dart';

class DataSetImageCache {
  Path mCirclePathBuffer = Path();

  List<ByteData> circleBitmaps;

  /// Sets up the cache, returns true if a change of cache was required.
  ///
  /// @param set
  /// @return
  bool init(ILineDataSet set) {
    int size = set.getCircleColorCount();
    bool changeRequired = false;

    if (circleBitmaps == null) {
      circleBitmaps = List(size);
      changeRequired = true;
    } else if (circleBitmaps.length != size) {
      circleBitmaps = List(size);
      changeRequired = true;
    }

    return changeRequired;
  }

  /// Fills the cache with bitmaps for the given dataset.
  ///
  /// @param set
  /// @param drawCircleHole
  /// @param drawTransparentCircleHole
  void fill(
      ILineDataSet set,
      bool drawCircleHole,
      bool drawTransparentCircleHole,
      Paint paint,
      Paint circlePaint,
      Function callback) {
    final int colorCount = set.getCircleColorCount();
    double circleRadius = set.getCircleRadius();
    double circleHoleRadius = set.getCircleHoleRadius();

    int finishCount = 0;
    for (int i = 0; i < colorCount; i++) {
//      Bitmap.Config conf = Bitmap.Config.ARGB_4444;
//      Bitmap circleBitmap = Bitmap.createBitmap((int) (circleRadius * 2.1), (int) (circleRadius * 2.1), conf);

      ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas canvas = Canvas(
          recorder,
          Rect.fromLTRB(
              0,
              0,
              drawCircleHole ? circleHoleRadius * 2 : circleRadius * 2,
              drawCircleHole ? circleHoleRadius * 2 : circleRadius * 2));
//      circleBitmaps[i] = circleBitmap;
      paint..color = set.getCircleColor(i);

      if (drawTransparentCircleHole) {
        // Begin path for circle with hole
        mCirclePathBuffer.reset();

        mCirclePathBuffer
            .addOval(Rect.fromLTRB(0, 0, circleRadius * 2, circleRadius * 2));

        // Cut hole in path
        mCirclePathBuffer.addOval(
            Rect.fromLTRB(0, 0, circleHoleRadius * 2, circleHoleRadius * 2));

        // Fill in-between
        canvas.drawPath(mCirclePathBuffer, paint);
      } else {
        canvas.drawCircle(
            Offset(circleRadius, circleRadius), circleRadius, paint);

        if (drawCircleHole) {
          canvas.drawCircle(Offset(circleRadius, circleRadius),
              circleHoleRadius, circlePaint);
        }
      }

      var length =
          (drawCircleHole ? circleHoleRadius * 2 : circleRadius * 2).toInt();
      recorder.endRecording().toImage(length, length).then((image) {
        image.toByteData(format: ImageByteFormat.rawRgba).then((data) {
          circleBitmaps[i] = data;
          if (finishCount >= colorCount - 1) {
            callback();
          }
          finishCount++;
        });
      });
    }
  }

  ByteData getBitmap(int index) {
    return circleBitmaps[index % circleBitmaps.length];
  }
}
