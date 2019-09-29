# mp_flutter_chart

flutter charts just like [**MPAndroidChart**](https://github.com/PhilJay/MPAndroidChart)

Thanks for [**MPAndroidChart**](https://github.com/PhilJay/MPAndroidChart), when translate this library to flutter I learned a lot about matrix use in animation.

## todos
**1.In the design of flutter, the change of the widget can only be refreshed by its parent widget, so the parent widget needs to save all the data of its child widget. Now Chart saves the data by itself, so Chart is single instance in the example. It doesn't feel like any of the other flutter widgets, so I need to learn the design model of flutter, and then save the data needed for the Chart into another class(maybe a controller).When we use Chart, let the parent widget of the Chart hold that class's(controller's) instance, which may be better to use**
<br/><br/>
**2.potential bugs fix**

## More Examples
**LineCharts**
<div align=center>
    <img src="./img/line_charts/basic.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/line_charts/multiple.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/line_charts/dual_axis.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/line_charts/invert_axis.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/line_charts/cubic.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/line_charts/colorful.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/line_charts/performance.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/line_charts/filled.png"  width="240" height="480">
</div>
<br/><br/>

**BarCharts**
<div align=center>
    <img src="./img/bar_charts/basic.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/bar_charts/basic2.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/bar_charts/multiple.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/bar_charts/horizontal.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/bar_charts/stacked.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/bar_charts/negative.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/bar_charts/stacked2.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/bar_charts/sine.png"  width="240" height="480">
</div>
<br/><br/>

**PieCharts**
<div align=center>
    <img src="./img/pie_charts/basic.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/pie_charts/value_lines.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/pie_charts/half_pie.png"  width="240" height="480">
</div>
<br/><br/>

**OtherCharts**
<div align=center>
    <img src="./img/other_charts/combined.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/other_charts/scatter.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/other_charts/bubble.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/other_charts/candle.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/other_charts/radar.png"  width="240" height="480">
</div>
<br/><br/>

**ScrollingCharts**
<div align=center>
    <img src="./img/scrolling_charts/multiple.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/scrolling_charts/view_pager.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/scrolling_charts/tall.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/scrolling_charts/many.png"  width="240" height="480">
</div>
<br/><br/>

**EvenMoreCharts**
<div align=center>
    <img src="./img/even_more_charts/dynamic.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/even_more_charts/basic.png"  width="240" height="480">
</div>
<br/><br/>
<div align=center>
    <img src="./img/even_more_charts/hourly.png"  width="240" height="480">
</div>
<br/><br/>