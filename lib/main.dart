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
      _WindEnergy('Brazil', 29135),
      _WindEnergy('United Kingdom', 30215),
      _WindEnergy('Spain', 31028),
      _WindEnergy('India', 44736),
      _WindEnergy('Germany', 69459),
      _WindEnergy('US', 148020),
      _WindEnergy('China', 441895),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.7,
            fit: BoxFit.cover,
            image: AssetImage('assets/background.png'),
          ),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            majorTickLines: MajorTickLines(color: Colors.white),
            axisLine: AxisLine(color: Colors.white, width: 2),
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          primaryYAxis: NumericAxis(
            title: const AxisTitle(text: 'Megawatts'),
            majorGridLines: const MajorGridLines(width: 0),
            majorTickLines: const MajorTickLines(color: Colors.white),
            axisLine: const AxisLine(color: Colors.white, width: 2),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            axisLabelFormatter: (AxisLabelRenderDetails args) {
              return ChartAxisLabel('${args.text} MW', args.textStyle);
            },
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            color: Colors.brown,
            borderColor: Colors.brown,
            borderWidth: 5,
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              return Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                        width: 35,
                        child: Image.asset(_countryImages(pointIndex)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${point.y.toString()}MW',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaler: TextScaler.noScaling,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          title: const ChartTitle(
            backgroundColor: Colors.white,
            text: ' Visualize the largest wind power producers by country ',
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown,
              fontSize: 20,
            ),
          ),
          series: <CartesianSeries<_WindEnergy, String>>[
            ColumnSeries(
              dataSource: _windEnergyData,
              xValueMapper: (_WindEnergy data, int index) => data.country,
              yValueMapper: (_WindEnergy data, int index) => data.megawatt,
              onCreateRenderer: (ChartSeries<_WindEnergy, String> series) {
                return _ColumnSeriesRenderer();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _countryImages(int pointIndex) {
    return pointIndex == 0
        ? 'assets/brazil.png'
        : pointIndex == 1
            ? 'assets/uk.png'
            : pointIndex == 2
                ? 'assets/spain.png'
                : pointIndex == 3
                    ? 'assets/india.png'
                    : pointIndex == 4
                        ? 'assets/germany.png'
                        : pointIndex == 5
                            ? 'assets/us.png'
                            : 'assets/china.png';
  }
}

// Model class to hold stock data
class _WindEnergy {
  _WindEnergy(this.country, this.megawatt);
  final String country;
  final double megawatt;
}

// Custom renderer for column series
class _ColumnSeriesRenderer extends ColumnSeriesRenderer<_WindEnergy, String> {
  @override
  ColumnSegment<_WindEnergy, String> createSegment() => _ColumnSegment();
}

// Custom segment class to draw custom shapes.
class _ColumnSegment extends ColumnSegment<_WindEnergy, String> {
  Path bladesPath = Path();

  // Check if the position is within the drawn shapes.
  @override
  bool contains(Offset position) {
    return (segmentRect != null && segmentRect!.contains(position)) ||
        bladesPath.contains(position);
  }

  // Custom painting method for drawing .
  @override
  void onPaint(Canvas canvas) {
    bladesPath.reset();

    // Return if segmentRect is null.
    if (segmentRect == null) {
      return;
    }

    // Paint settings for the blades and the post.
    Paint bladeFillPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;

    Paint postFillPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;

    final Paint bladeStrokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint postStrokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double centerX = segmentRect!.center.dx;
    double centerY = segmentRect!.top;

    // Post dimensions for the windmill post.
    double postBaseWidth = segmentRect!.width * 0.2;
    double postTopWidth = segmentRect!.width * 0.05;

    // Define the path for the windmill post.
    Path postPath = Path()
      ..moveTo(centerX - postBaseWidth / 2, segmentRect!.bottom) // Bottom left.
      ..lineTo(centerX + postBaseWidth / 2, segmentRect!.bottom) // Bottom right
      ..lineTo(centerX + postTopWidth / 2, segmentRect!.top) // Top right.
      ..lineTo(centerX - postTopWidth / 2, segmentRect!.top) // Top left.
      ..close(); // Close the path

    // Draw the windmill post.
    canvas.drawPath(postPath, postFillPaint);
    canvas.drawPath(postPath, postStrokePaint);

    // Blade dimensions
    double bladeLength =
        10 * (currentSegmentIndex < 3 ? 3 : currentSegmentIndex.toDouble());
    double bladeWidth = 20;

    // Loop to draw three curved blades.
    for (int i = 0; i < 3; i++) {
      double angle = (i * 120) * pi / 180;

      // Transformation for positioning and rotating blades.
      Matrix4 transformMatrix = Matrix4.identity()
        ..translate(centerX, centerY)
        ..rotateZ(angle);

      // Define the blade path using cubic curves.
      Path bladePath = Path()
        ..moveTo(0, 0) // Start at the center.
        ..cubicTo(bladeWidth / 4, -bladeLength, bladeWidth / 2, -bladeLength, 0,
            -bladeLength) // Right curve.
        ..cubicTo(-bladeWidth / 4, -bladeLength, -bladeWidth / 2, -bladeLength,
            0, 0); // Left curve

      // Add each blade to the combined path.
      bladesPath.addPath(bladePath, Offset.zero,
          matrix4: transformMatrix.storage);
    }

    // Draw the blades on the canvas.
    canvas.drawPath(bladesPath, bladeFillPaint);
    canvas.drawPath(bladesPath, bladeStrokePaint);

    // Draw the center circle of the windmill.
    canvas.drawCircle(
        Offset(centerX, centerY), 5, Paint()..color = Colors.white);
  }

  // Cleanup the path resources.
  @override
  void dispose() {
    bladesPath.reset();
    super.dispose();
  }
}
