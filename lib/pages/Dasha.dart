import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FitnessPart extends StatefulWidget{

  @override
  _FitnessPartState createState() => _FitnessPartState();
}

class _FitnessPartState extends State<FitnessPart>{
  late Stream<StepCount> _stepCountStream;
  //Флаг для конца дня
  //Рост человека
  var high=168;
  var flagEnd=0;
  //k=1 Для прогулки
  final k=1;
  var lhs=0;
  double calories=0;
  var massa=52;
  var nowHour = DateTime.now().hour.toInt();
  var nowMinute=DateTime.now().minute.toInt();
  //late Stream<PedestrianStatus> _pedestrianStatusStream;
  //String _status = '?', _steps = '?';
  int numOfsteps=0;
  var prevnumOfsteps=0;
  String _steps='?';
  //Используется для запроса разрешения
  final activityRecognition = FlutterActivityRecognition.instance;
  String timeString='';
  bool firstRun = true;

  @override
  void initState() {
    super.initState();
    initPlatformState();

  }




  //Функция для красивого вывода числа шагов
  void onStepCount(StepCount event) {
    //_showSimpleDialog();
    print(event);
    print(prevnumOfsteps);
    setState(() {
      if (firstRun==true){
        prevnumOfsteps=event.steps;
        firstRun=false;
      }
      double S=0;
      S=high/4+37;
      calories=k*massa*numOfsteps*S/100000;
      nowHour = DateTime.now().hour.toInt();
      if (nowHour==11){
        nowMinute=DateTime.now().minute.toInt();
        if (nowMinute==59){
          var nowSec=DateTime.now().second.toInt();
          if (nowSec==0){
            flagEnd=1;
            prevnumOfsteps=event.steps;
          }
          else{
            numOfsteps = event.steps-prevnumOfsteps;
          }
          //_showSimpleDialog();
        }
        else{
          numOfsteps = event.steps-prevnumOfsteps;
        }
      }
      else {
        numOfsteps = event.steps-prevnumOfsteps;
      }
    });
  }

  //Спрашивает разрешение

  Future<bool> isPermissionGrants() async {
    // Check if the user has granted permission. If not, request permission.
    PermissionRequestResult reqResult;
    reqResult = await activityRecognition.checkPermission();
    if (reqResult == PermissionRequestResult.PERMANENTLY_DENIED) {
      dev.log('Permission is permanently denied.');
      return false;
    } else if (reqResult == PermissionRequestResult.DENIED) {
      reqResult = await activityRecognition.requestPermission();
      if (reqResult != PermissionRequestResult.GRANTED) {
        dev.log('Permission is denied.');
        return false;
      }
    }

    return true;
  }


//В случае ошибки
  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      numOfsteps=0;
      _steps = 'Step Count not available';
    });
  }


  //Постоянный выброс разрешения (не сдаемся!)
  void handlevalueMINE(value){
    Future<bool> flag;
    if (value==false){
      flag=isPermissionGrants();
      flag.then((value) => handlevalueMINE(value))
          .catchError((error) => print('ERROR'));
    }
  }

  void initPlatformState() {

    var flag=isPermissionGrants();
    flag.then((value) => handlevalueMINE(value))
        .catchError((error) => print('ERROR'));

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    if (!mounted) return;
  }






  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Step',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(10, 10, 68, 1.0),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fitness part'),
        ),
        body: Column(
          children: <Widget>[
            Divider(
              height: 60,
              thickness: 0,
              color: Colors.white,
            ),
            Icon(Icons.run_circle, size: 50, color: Color.fromRGBO(10, 10, 68, 1.0)),
            Text(
              'Шаги: ${numOfsteps}',
              style:TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Divider(
              height: 60,
              thickness: 0,
              color: Colors.white,
            ),
            Icon(Icons.sports_handball, size: 50, color: Color.fromRGBO(10, 10, 68, 1.0)),
            Text(
              'Потрачено калорий: ${calories}',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Divider(
              height: 60,
              thickness: 0,
              color: Colors.white,
            ),
          ],

        ),
      ),
    );
  }
}