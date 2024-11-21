import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

void main() {
  runApp(_ChartApp());
}

// Main application widget
class _ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const _WindmillChart(),
    );
  }
}

// Blog page with the chart
class _WindmillChart extends StatefulWidget {
  const _WindmillChart();

  @override
  _WindmillChartState createState() => _WindmillChartState();
}

class _WindmillChartState extends State<_WindmillChart> {
  late List<_WindEnergy> _windEnergyData;

  @override
  void initState() {
    _windEnergyData = [
      _WindEnergy('China', 441895, '+19.1%'),
      _WindEnergy('US', 148020, '+9.4%'),
      _WindEnergy('Germany', 69459, '+7.6%'),
      _WindEnergy('India', 44736, '+9.3%'),
      _WindEnergy('Spain', 31028, '+3.1%'),
      _WindEnergy('United Kingdom', 30215, '+10.4%'),
      _WindEnergy('Brazil', 29135, '+29.5%'),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 236, 207, 165),
              Color.fromARGB(255, 159, 217, 244),
              Color.fromARGB(255, 204, 238, 165),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          title: const ChartTitle(
            text:
                ' Visualize the largest top 7 wind power producers by country ',
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown,
              fontSize: 20,
            ),
          ),
          primaryXAxis: const CategoryAxis(
            title: AxisTitle(
              text: 'Wind Energy Producers by Country',
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            majorGridLines: MajorGridLines(width: 0),
            majorTickLines: MajorTickLines(color: Colors.brown),
            axisLine: AxisLine(color: Colors.brown, width: 2),
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          primaryYAxis: NumericAxis(
            title: const AxisTitle(
              text: 'Wind Energy Capacity (Megawatts)',
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            majorTickLines: const MajorTickLines(color: Colors.brown),
            axisLine: const AxisLine(color: Colors.brown, width: 2),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            axisLabelFormatter: (AxisLabelRenderDetails args) {
              double value = double.tryParse(args.text) ?? 0;
              String formattedText = _formatNumber(value);
              return ChartAxisLabel(formattedText, args.textStyle);
            },
          ),
          series: <CartesianSeries<_WindEnergy, String>>[
            ColumnSeries(
              dataSource: _windEnergyData,
              xValueMapper: (_WindEnergy data, int index) => data.country,
              yValueMapper: (_WindEnergy data, int index) => data.megawatt,
              animationDuration: 0,
              onCreateRenderer: (ChartSeries<_WindEnergy, String> series) {
                return _CustomColumnSeriesRenderer();
              },
            ),
          ],
          tooltipBehavior: TooltipBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            color: Colors.brown,
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 35,
                            child: Image.asset(_countryImages(pointIndex)),
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '${data.country}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Megawatts: ${point.y.toString()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ANNUAL GROWTH RATE\n(2013-2023) ${data.rate}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _countryImages(int pointIndex) {
    switch (pointIndex) {
      case 0:
        return 'assets/brazil.png';
      case 1:
        return 'assets/uk.png';
      case 2:
        return 'assets/spain.png';
      case 3:
        return 'assets/india.png';
      case 4:
        return 'assets/germany.png';
      case 5:
        return 'assets/us.png';
      case 6:
        return 'assets/china.png';
    }
    return '';
  }

  // Function to format numbers to a more readable form
  String _formatNumber(double num) {
    // Special case for zero to avoid decimal representation
    if (num == 0) {
      return '0';
    }
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(num >= 10000 ? 0 : 1)}K';
    }
    return num.toStringAsFixed(
        num == num.toInt() ? 0 : 1); // Remove ".0" for whole numbers
  }

  @override
  void dispose() {
    _windEnergyData.clear();
    super.dispose();
  }
}

class _WindEnergy {
  _WindEnergy(this.country, this.megawatt, this.rate);
  final String country;
  final double megawatt;
  final String rate;
}

// Custom renderer for column series
class _CustomColumnSeriesRenderer
    extends ColumnSeriesRenderer<_WindEnergy, String> {
  @override
  ColumnSegment<_WindEnergy, String> createSegment() => _ColumnSegment();
}

// Custom segment class to draw custom shapes.
class _ColumnSegment extends ColumnSegment<_WindEnergy, String> {
  final Path _bladesPath = Path();
  Path _postPath = Path();

  void _reset() {
    _bladesPath.reset();
    _postPath.reset();
  }

  @override
  bool contains(Offset position) {
    return _postPath.contains(position) || _bladesPath.contains(position);
  }

  @override
  void onPaint(Canvas canvas) {
    _reset();
    if (segmentRect == null) {
      return;
    }

    final Paint fillPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double bottom = segmentRect!.bottom;
    final double top = segmentRect!.top;
    final double centerX = segmentRect!.center.dx;
    final double centerY = top;
    final double postBaseWidth = segmentRect!.width * 0.2;
    final double postTopWidth = segmentRect!.width * 0.05;
    final double halfPostBaseWidth = postBaseWidth / 2;
    final double halfPostTopWidth = postTopWidth / 2;

    _postPath = Path()
      ..moveTo(centerX - halfPostBaseWidth, bottom)
      ..lineTo(centerX + halfPostBaseWidth, bottom)
      ..lineTo(centerX + halfPostTopWidth, top)
      ..lineTo(centerX - halfPostTopWidth, top)
      ..close();

    canvas.drawPath(_postPath, fillPaint);
    canvas.drawPath(_postPath, strokePaint);

    // Maintained a minimum value of 30 and a maximum value of 40 as the default
    // blade length range. Using the column segment value, I calculate the blade
    // length by normalizing it within this range. The formula maps the value to
    // a specified blade length range, ensuring proportional scaling.
    // This approach dynamically adjusts blade sizes based on the segment value.

    // Constants for blade length range.
    const double minBladeLength = 30;
    const double maxBladeLength = 40;

    // Constants for data normalization.
    const double minValue = 29135;
    const double maxValue = 441895;

    // Calculate the normalized value of the segment (based on y).
    const double lengthRange = maxBladeLength - minBladeLength;
    final double normalizedFactor = (y - minValue) / (maxValue - minValue);

    // Adjust blade length dynamically based on the reversed segment index.
    final double reverseScalingFactor =
        1 - (currentSegmentIndex * 0.1); // Decrease as segment index increases.

    double bladeLength = normalizedFactor * lengthRange + minBladeLength;
    bladeLength *= reverseScalingFactor; // Apply reverse scaling factor

    // Ensure the blade length doesn't drop below the minimum value.
    bladeLength = bladeLength.clamp(minBladeLength, maxBladeLength);

    final Offset center = Offset(centerX, centerY);
    const double bladeWidth = 20;

    // Define the angles for the three blades in radians.
    double angle1 = 0;
    double angle2 = 120 * pi / 180;
    double angle3 = 240 * pi / 180;

    // Draw first blade.
    _drawBlade(canvas, center, angle1, bladeLength, bladeWidth, fillPaint,
        strokePaint);

    // Draw second blade.
    _drawBlade(canvas, center, angle2, bladeLength, bladeWidth, fillPaint,
        strokePaint);

    // Draw third blade.
    _drawBlade(canvas, center, angle3, bladeLength, bladeWidth, fillPaint,
        strokePaint);

    // Draws circle at the center of the windmill.
    canvas.drawCircle(center, 5, Paint()..color = Colors.brown);
  }

  // Helper method to draw each blade
  void _drawBlade(
    Canvas canvas,
    Offset center,
    double angle,
    double bladeLength,
    double bladeWidth,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    Matrix4 transformMatrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..rotateZ(angle);

    final double halfWidth = bladeWidth / 2;
    final double quarterWidth = bladeWidth / 4;
    final Path bladePath = Path()
      ..moveTo(0, 0)
      ..cubicTo(
          quarterWidth, -bladeLength, halfWidth, -bladeLength, 0, -bladeLength)
      ..cubicTo(-quarterWidth, -bladeLength, -halfWidth, -bladeLength, 0, 0);

    _bladesPath.addPath(bladePath, Offset.zero,
        matrix4: transformMatrix.storage);

    // Draw the blade on the canvas
    canvas.drawPath(_bladesPath, fillPaint);
    canvas.drawPath(_bladesPath, strokePaint);
  }

  @override
  void dispose() {
    _reset();
    super.dispose();
  }
}
