import 'package:example/demo/bar_chart/basic.dart';
import 'package:example/demo/bar_chart/basic2.dart';
import 'package:example/demo/bar_chart/horizontal.dart';
import 'package:example/demo/bar_chart/multiple.dart';
import 'package:example/demo/bar_chart/negative.dart';
import 'package:example/demo/bar_chart/sine.dart';
import 'package:example/demo/bar_chart/stacked.dart';
import 'package:example/demo/bar_chart/stacked2.dart';
import 'package:example/demo/even_more/dynamic.dart';
import 'package:example/demo/even_more/hourly.dart';
import 'package:example/demo/line_chart/basic.dart';
import 'package:example/demo/line_chart/colorful.dart';
import 'package:example/demo/line_chart/cubic.dart';
import 'package:example/demo/line_chart/dual_axis.dart';
import 'package:example/demo/line_chart/filled.dart';
import 'package:example/demo/line_chart/invert_axis.dart';
import 'package:example/demo/line_chart/multiple.dart';
import 'package:example/demo/line_chart/performance.dart';
import 'package:example/demo/other_chart/bubble.dart';
import 'package:example/demo/other_chart/candlestick.dart';
import 'package:example/demo/other_chart/combined.dart';
import 'package:example/demo/other_chart/radar.dart';
import 'package:example/demo/other_chart/scatter_plot.dart';
import 'package:example/demo/pie_chart/basic.dart';
import 'package:example/demo/pie_chart/half_pie.dart';
import 'package:example/demo/pie_chart/value_lines.dart';
import 'package:example/demo/res/styles.dart';
import 'package:example/demo/scrolling_chart/multiple.dart';
import 'package:example/demo/scrolling_chart/tall_bar.dart';
import 'package:example/demo/scrolling_chart/view_pager.dart';
import 'package:flutter/material.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';

import 'demo/even_more/realtime.dart';
import 'demo/scrolling_chart/many_bar_chart.dart';

void main() {
//  debugPrintGestureArenaDiagnostics = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'example Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'example example'),
      routes: <String, WidgetBuilder>{
        '/line_chart/basic': (_) => LineChartBasic(),
        '/line_chart/multiple': (_) => LineChartMultiple(),
        '/line_chart/dual_axis': (_) => LineChartDualAxis(),
        '/line_chart/invert_axis': (_) => LineChartInvertAxis(),
        '/line_chart/cubic': (_) => LineChartCubic(),
        '/line_chart/colorful': (_) => LineChartColorful(),
        '/line_chart/performance': (_) => LineChartPerformance(),
        '/line_chart/filled': (_) => LineChartFilled(),
        '/bar_chart/basic': (_) => BarChartBasic(),
        '/bar_chart/basic2': (_) => BarChartBasic2(),
        '/bar_chart/multiple': (_) => BarChartMultiple(),
        '/bar_chart/horizontal': (_) => BarChartHorizontal(),
        '/bar_chart/stacked': (_) => BarChartStacked(),
        '/bar_chart/negative': (_) => BarChartNegative(),
        '/bar_chart/stacked2': (_) => BarChartStacked2(),
        '/bar_chart/sine': (_) => BarChartSine(),
        '/pie_chart/basic': (_) => PieChartBasic(),
        '/pie_chart/value_lines': (_) => PieChartValueLines(),
        '/pie_chart/half_pie': (_) => PieChartHalfPie(),
        '/other_chart/combined_chart': (_) => OtherChartCombined(),
        '/other_chart/scatter_plot': (_) => OtherChartScatterPlot(),
        '/other_chart/bubble_chart': (_) => OtherChartBubble(),
        '/other_chart/candlestick': (_) => OtherChartCandlestick(),
        '/other_chart/redar_chart': (_) => OtherChartRadar(),
        '/scrolling_chart/multiple': (_) => ScrollingChartMultiple(),
        '/scrolling_chart/view_pager': (_) => ScrollingChartViewPager(),
        '/scrolling_chart/tall_bar_chart': (_) => ScrollingChartTallBar(),
        '/scrolling_chart/many_bar_charts': (_) => ScrollingChartManyBar(),
        '/even_more_line_chart/dynamic': (_) => EvenMoreDynamic(),
        '/even_more_line_chart/realtime': (_) => EvenMoreRealtime(),
        '/even_more_line_chart/hourly': (_) => EvenMoreHourly(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PopupMenuItem _item(String text, String id) {
    return PopupMenuItem<String>(
        value: id,
        child: Container(
            padding: EdgeInsets.only(top: 15.0),
            child: Center(
                child: Text(
              text,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: ColorUtils.BLACK,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ))));
  }

  void _itemClick(String action) {
    switch (action) {
      case 'A':
        break;
      case 'B':
        break;
      case 'C':
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                  _item('View on GitHub', 'A'),
                  _item('Problem Report', 'B'),
                  _item('Developer Website', 'C'),
                ],
            onSelected: (String action) {
              _itemClick(action);
            },
          ),
        ],
      ),
      body: CustomScrollView(shrinkWrap: false, slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(15.0),
                          child: Center(
                              child: Text(
                            "Line Charts",
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorUtils.BLACK,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ))),
                      Gaps.line
                    ],
                  ),
                ),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/line_chart/basic'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Basic",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Simple line chart.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/line_chart/multiple'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Multiple",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Show mutiple data sets.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/line_chart/dual_axis'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Dual Axis",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Line chart with dual y-axes.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/line_chart/invert_axis'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Inverted Axis",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Inverted y-axis.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/line_chart/cubic'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Cubic",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Line chart with a cubic line shape.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/line_chart/colorful'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Colorful",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Colorful line chart",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/line_chart/performance'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Performance",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Render 30.000 data points smoothly.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/line_chart/filled'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Filled",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Colored area between two lines.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(15.0),
                          child: Center(
                              child: Text(
                            "Bar Charts",
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorUtils.BLACK,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ))),
                      Gaps.line
                    ],
                  ),
                ),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/bar_chart/basic'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Basic",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Simple bar chart.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/bar_chart/basic2'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Basic 2",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Variation of the simple bar chart.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/bar_chart/multiple'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Multiple",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Show multiple data sets.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/bar_chart/horizontal'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Horizontal",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Render bar chart horizontally.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/bar_chart/stacked'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Stacked",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Stacked bar chart.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/bar_chart/negative'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Negative",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Positive and negative values with unique colors.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/bar_chart/stacked2'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Stacked 2",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Stacked bar chart with negative values.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/bar_chart/sine'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Sine",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Sine function in bar chart format.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(15.0),
                          child: Center(
                              child: Text(
                            "Pie Charts",
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorUtils.BLACK,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ))),
                      Gaps.line
                    ],
                  ),
                ),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/pie_chart/basic'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Basic",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Simple pie chart.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/pie_chart/value_lines'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Value lines",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Stylish lines drawn outward from slices.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/pie_chart/half_pie'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Half Pie",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "180° (half) pie chart.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(15.0),
                          child: Center(
                              child: Text(
                            "Other Charts",
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorUtils.BLACK,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ))),
                      Gaps.line
                    ],
                  ),
                ),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/other_chart/combined_chart'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Combined Chart",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Bar and line chart together.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/other_chart/scatter_plot'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Scatter Plot",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Simple scatter plot.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/other_chart/bubble_chart'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Bubble Chart",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Simple Bubble chart.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/other_chart/candlestick'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Candlestick",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Simple financial chart.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/other_chart/redar_chart'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Redar Chart",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Simple web chart.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(15.0),
                          child: Center(
                              child: Text(
                            "Scrolling Charts",
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorUtils.BLACK,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ))),
                      Gaps.line
                    ],
                  ),
                ),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/scrolling_chart/multiple'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Multiple",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Various types of charts.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/scrolling_chart/view_pager'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "View Pager",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Swipe through different charts.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/scrolling_chart/tall_bar_chart'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Tall Bar Chart",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Bars bigger than your screen.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/scrolling_chart/many_bar_charts'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Many Bar Charts",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "More bars than your screen can handle!.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(15.0),
                          child: Center(
                              child: Text(
                            "Even More Line Charts",
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorUtils.BLACK,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ))),
                      Gaps.line
                    ],
                  ),
                ),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/even_more_line_chart/dynamic'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Dynamic",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Build a line chart by adding points and sets.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/even_more_line_chart/realtime'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Realtime",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Add data points in realtime.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
                InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/even_more_line_chart/hourly'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Hourly",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorUtils.BLACK,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(
                                "Uses the current time to add a data point for each hour.",
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorUtils.BLACK, fontSize: 12),
                              ),
                            ),
                            Gaps.line
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
