// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

import 'package:mp_flutter_chart/main.dart';

void main() {
//  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//    // Build our app and trigger a frame.
//    await tester.pumpWidget(MyApp());
//
//    // Verify that our counter starts at 0.
//    expect(find.text('0'), findsOneWidget);
//    expect(find.text('1'), findsNothing);
//
//    // Tap the '+' icon and trigger a frame.
//    await tester.tap(find.byIcon(Icons.add));
//    await tester.pump();
//
//    // Verify that our counter has incremented.
//    expect(find.text('0'), findsNothing);
//    expect(find.text('1'), findsOneWidget);
//  });

  test("11111", () {
//    print("xxx");
//
//    Matrix4 A = Matrix4(
//        22.142046, 0.0, 0.0, 0.0,
//        0.0, -5.2080936, 0.0, 0.0,
//        0.0, 0.0, 1.0, 0.0,
//        0.0, -260.4047, 0.0, 1.0);
//    Matrix4 B = Matrix4.identity();
//    Matrix4 C = Matrix4(
//        1.0, 0.0, 0.0, 0.0,
//        0.0, 1.0, 0.0, 0.0,
//        0.0, 0.0, 1.0, 0.0,
//        64.5, 1343.2734, 0.0, 1.0);
//
//    List<double> list = List()
//      ..add(0)
//      ..add(0.0)
//      ..add(10)
//      ..add(0)
//      ..add(20)
//      ..add(0)
//      ..add(30)
//      ..add(0)
//      ..add(40)
//      ..add(0);
//
//    print(list);
//    Matrix4Utils.mapPoints(A, list);
//    print(list);
//    Matrix4Utils.mapPoints(B, list);
//    print(list);
//    Matrix4Utils.mapPoints(C, list);
//    print(list);
//
//    print("-----------------------");
//
//    Matrix4 L = Matrix4(
//        -1.076, 0.0, 0.0, 0.0,
//        0.0, 8.431818181818182, 0.0, 0.0,
//        0.0, 0.0, 1.0, 0.0,
//        0.0, 50.0, 0.0, 1.0);
//    Matrix4 M = Matrix4.identity();
//    Matrix4 N = Matrix4(
//        1.0, 0.0, 0.0, 0.0,
//        0.0, 1.0, 0.0, 0.0,
//        0.0, 0.0, 1.0, 0.0,
//        28, 285.0, 0.0, 1.0);
//    print(L);
//
//    List<double> list2 = List()
//      ..add(0)
//      ..add(0.0)
//      ..add(10)
//      ..add(0)
//      ..add(20)
//      ..add(0)
//      ..add(30)
//      ..add(0)
//      ..add(40)
//      ..add(0);
//
//    print(list2);
//    Matrix4Utils.mapPoints(L, list2);
//    print(list2);
//    Matrix4Utils.mapPoints(M, list2);
//    print(list2);
//    Matrix4Utils.mapPoints(N, list2);
//    print(list2);
    
    Matrix4 X = Matrix4(
        22.142046, 0.0, 0.0, 0.0,
        0.0, -5.2080936, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, -260.4047, 0.0, 1.0);
    Matrix4 Y = Matrix4.identity();
    Matrix4 Z = Matrix4(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        64.5, 1343.2734, 0.0, 1.0);

    Matrix4 mMBuffer1 =  Matrix4.identity();
    X.copyInto(mMBuffer1);
    print("mMBuffer1 1 -> $mMBuffer1");
    Matrix4Utils.postConcat(mMBuffer1, Y);
    print("mMBuffer1 2 -> $mMBuffer1");
    Matrix4Utils.postConcat(mMBuffer1, Z);
//    print(Z);
    print("mMBuffer1 3 -> $mMBuffer1");

    StringBuffer b = new StringBuffer();
    for (int i = 0; i < 1; i++) {
      if (i == 0) b.write(".");
      b.write("0");
    }
    var format = NumberFormat("###,###,###,##0" + b.toString());
    print(format.format(242432.854850));
  });
}
