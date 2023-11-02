import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_part_of_project/pages/karina.dart';
import 'package:my_part_of_project/pages/Dasha.dart';
import 'package:my_part_of_project/pages/Nastenka/main_app.dart';
import 'package:provider/provider.dart';

void main() async {
  await _initHive();

  final totalCaloriesProvider = TotalCaloriesProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CalorieTracker>(
          create: (context) => CalorieTracker(),
        ),
        ChangeNotifierProvider(create: (_) => CalorieTracker()),
        ChangeNotifierProvider(create: (_) => TotalCaloriesProvider()),
        ChangeNotifierProvider(create: (_) => CaloriesProvider()),
      ],
      child: MainApp(),
    ),
  );
  print(totalCaloriesProvider.totalCalories);
}


Future<void> _initHive() async{
  await Hive.initFlutter();
  await Hive.openBox("login");
  await Hive.openBox("accounts");
  await Hive.openBox("heights");
  await Hive.openBox("weights");
  await Hive.openBox("calories");
  await Hive.openBox('food_entries');
}

