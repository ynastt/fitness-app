import 'package:flutter/material.dart';
import 'package:hive/hive.dart';  // библиотека Hive для работы с локальной базой данных
import 'package:my_part_of_project/pages/karina.dart';
import 'package:my_part_of_project/pages/Dasha.dart';
import 'package:my_part_of_project/pages/result.dart';
import 'login.dart'; // Импортируем модуль login.dart
import 'package:provider/provider.dart';

// Создаем класс Home, который является Stateless виджетом
class Home extends StatelessWidget {
  Home({super.key});  // Конструктор класса

  // Создаем объект Box из Hive для работы с данными пользователя.
  final Box _boxLogin = Hive.box("login");
  // final Box _boxAccounts = Hive.box("accounts");

  // Переопределяем метод build для построения пользовательского интерфейса
  @override
  Widget build(BuildContext context) {
    // Возвращаем базовый виджет для построения интерфейса домашнего экрана
    return Scaffold(
      appBar: AppBar( // Верхняя панель приложения
        title: const Text("ТОПАТЬ И ЛОПАТЬ"),
        elevation: 10,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.white),
              ),
              child: IconButton(  // Kнопка выхода
                onPressed: () {
                  // Очищаем данные пользователя в Hive
                  _boxLogin.clear();
                  // Устанавливаем статус входа пользователя на false
                  _boxLogin.put("loginStatus", false);
                  // Перенаправляем пользователя на экран входа (login.dart)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded), // Иконка выхода
              ),
            ),
          )
        ],
      ),
      // Задаем цвет фона, который зависит от текущей темы приложения
      // (см main_app.dart)
      //backgroundColor: Theme.of(context).colorScheme.primary,
      // Пока что в основном контенте страница просто приветствие
      // с именем пользователя, взятым из Hive (оно добавляется в базу в login.dart)
      body: Center( // Контент страницы (весь по центру)
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Divider(
                  height: 300,
                  thickness: 0,
                  color: Colors.white,),
                Text(
                  "Добро пожаловать 🎉",
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  _boxLogin.get("userName"),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Karina();
                      },
                    );
                  },
                  child: Text('Записать калории'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FitnessPart();
                      },
                    );
                  },
                  child: Text('Посмотреть активность'),
                ),

              ],
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CalorieDifference();
                  },
                );
              },
              child: Text('Я толстый?'),
            ),
          ],
        ),
      ),
    );
  }
}