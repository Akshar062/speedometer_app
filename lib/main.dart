import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:math';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speedometer App',
      home: SpeedometerPage(),
    );
  }
}

class SpeedometerPage extends StatefulWidget {
  @override
  _SpeedometerPageState createState() => _SpeedometerPageState();
}

class _SpeedometerPageState extends State<SpeedometerPage> {
  Location location = Location();
  double? _speed;
  String _selectedSpeedUnit = 'm/s';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    if (await location.hasPermission() != true) {
      await location.requestPermission();
    }
    _getLocation();
  }

  void _getLocation() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _speed = currentLocation.speed;
      });
    });
  }

  void _changeSpeedUnit(String? unit) {
    if (unit != null) {
      setState(() {
        _selectedSpeedUnit = unit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speedometer App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            painter: SpeedometerPainter(_speed ?? 0, _selectedSpeedUnit),
            size: const Size(200, 200),
          ),
          const SizedBox(height: 20),
          Text(
            'Speed: ${_speed ?? 0} $_selectedSpeedUnit',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: _selectedSpeedUnit,
            onChanged: _changeSpeedUnit,
            items: ['m/s', 'km/h'].map((unit) {
              return DropdownMenuItem<String>(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double speed;
  final String speedUnit;

  SpeedometerPainter(this.speed, this.speedUnit);

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final Paint arrowPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = min(centerX, centerY) - 20;

    // Draw the speedometer circle
    canvas.drawCircle(Offset(centerX, centerY), radius, circlePaint);

    // Calculate the angle based on the speed
    final double maxSpeed = 20.0; // Adjust this based on your maximum expected speed
    final double angle = (speed / maxSpeed) * 180.0;

    // Draw the arrow
    final double arrowLength = radius - 10;
    final double arrowX = centerX + arrowLength * cos(degreesToRadians(-90 + angle));
    final double arrowY = centerY + arrowLength * sin(degreesToRadians(-90 + angle));

    canvas.drawLine(Offset(centerX, centerY), Offset(arrowX, arrowY), arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
