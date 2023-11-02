import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'Dasha.dart';
import 'package:provider/provider.dart';
import 'karina.dart';

class CalorieDifference extends StatefulWidget {
  @override
  _CalorieDifferenceState createState() => _CalorieDifferenceState();
}

class _CalorieDifferenceState extends State<CalorieDifference> {
  ConfettiController _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  void initState() {
    super.initState();
    // Start the confetti animation when the widget is initialized.
    _controllerCenter.play();
  }

  @override
  void dispose() {
    super.dispose();
    // Stop the confetti animation and release resources when the widget is disposed.
    _controllerCenter.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCaloriesProvider = Provider.of<TotalCaloriesProvider>(context);
    final caloriesProvider = Provider.of<CaloriesProvider>(context);
    final calorieDifference = totalCaloriesProvider.totalCalories - caloriesProvider.calories;
    String resultText;
    if (calorieDifference <= 0) {
      resultText = "Сойдет...";
    } else {
      resultText = "ОЧЕНЬ!";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Я толстый?'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConfettiWidget(
              confettiController: _controllerCenter,
              emissionFrequency: 0.001,
              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop: true, // start again as soon as the animation is finished
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ], // manually specify the colors to be used
              createParticlePath: drawStar, // define a custom shape/path.
            ),

            ConfettiWidget(
              confettiController: _controllerCenter,
              emissionFrequency: 0.01,
              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop: true, // start again as soon as the animation is finished
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ], // manually specify the colors to be used
              createParticlePath: drawStar, // define a custom shape/path.
            ),

            Text(
              'Съедено калорий: ${totalCaloriesProvider.totalCalories} ккал',
              style: TextStyle(fontSize: 20),
            ),
            ConfettiWidget(
              confettiController: _controllerCenter,
              emissionFrequency: 0.01,
              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop: true, // start again as soon as the animation is finished
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ], // manually specify the colors to be used
              createParticlePath: drawStar, // define a custom shape/path.
            ),

            Divider(
              height: 30,
              thickness: 0,
              color: Colors.white,
            ),

            Text(
              'Потрачено калорий: ${caloriesProvider.calories} ккал',
              style: TextStyle(fontSize: 20),
            ),
            Divider(
              height: 30,
              thickness: 0,
              color: Colors.white,
            ),
            Text(
              resultText,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

          ],
        ),
      ),
    );
  }
}
