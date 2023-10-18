import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:developer' as dev;
String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void SureExitDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Остаться"),
      onPressed:  () {Navigator.pop(context);},
    );
    Widget yesButton = TextButton(
      child: Text("Да"),
      onPressed:  () {
        exit(0);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Подтверждение"),
      content: Text("Вы действительно хотите выйти из приложения?"),
      actions: [
        cancelButton,
        yesButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Функция для красивого вывода числа шагов
  void onStepCount(StepCount event) {
    //_showSimpleDialog();
    print(event);
    print(prevnumOfsteps);
    setState(() {
      double S=0;
      S=high/4+37;
      calories=k*massa*numOfsteps*S/100000;
      nowHour = DateTime.now().hour.toInt();
      if (nowHour==16){
        nowMinute=DateTime.now().minute.toInt();
        if (nowMinute==40){
            flagEnd=1;
            prevnumOfsteps=event.steps;
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
        theme: new ThemeData(
          // Тут мы создаём новый объект темы AppBar
          appBarTheme: AppBarTheme(
            color: Colors
                .lightGreen, // Тут указываем нужный цвет фона по умолчанию
          ),
          // Тут мы создаём новый объект темы primaryTextThe
        ),
        home: Scaffold(
          backgroundColor: Colors.lime[50],
          appBar: AppBar(
            title: Text('Fitness part'),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Divider(
                height: 20,
                thickness: 0,
                color: Colors.lime[50],
              ),
              Icon(Icons.run_circle, size: 30, color: Colors.lightGreen),
              Text(
                'Steps: ${numOfsteps}',
                style: TextStyle(fontSize: 30),
              ),
              Divider(
                height: 60,
                thickness: 0,
                color: Colors.white,
              ),
              Icon(Icons.sports_handball, size: 30, color: Colors.lightGreen),
              Text(
                'Calories losted: ${calories}',
                style: TextStyle(fontSize: 30),
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