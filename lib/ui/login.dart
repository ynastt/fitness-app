import 'package:flutter/material.dart';
import 'package:hive/hive.dart';  // библиотека Hive для работы с локальной базой данных

import 'home.dart'; // Импорт домашней страницы
import 'signup.dart'; // Импорт страницы регистрации

// Создаем класс Login, который является Stateful виджетом (виджет состояний)
class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key); // Конструктор класса

  @override
  State<Login> createState() => _LoginState();
}
// Этот класс представляет состояние виджета Login.
// В нем объявляются различные переменные и контроллеры,
// которые используются на странице.
class _LoginState extends State<Login> {
  // Ключ формы для валидации
  final GlobalKey<FormState> _formKey = GlobalKey();

  // Управление фокусом на поле ввода пароля
  // FocusNode - объект, который может быть использован виджетом состояния
  // для получения фокуса клавиатуры и обработки событий клавиатуры
  final FocusNode _focusNodePassword = FocusNode();
  // Контроллер для поля ввода имени пользователя
  final TextEditingController _controllerUsername = TextEditingController();
  // Контроллер для поля ввода пароля
  final TextEditingController _controllerPassword = TextEditingController();

  // Флаг скрытия пароля
  bool _obscurePassword = true;

  // Хранилище для данных о входe
  final Box _boxLogin = Hive.box("login");
  // Хранилище для данных об аккаунтах
  final Box _boxAccounts = Hive.box("accounts");

  // Переопределяем метод build для построения пользовательского интерфейса
  @override
  Widget build(BuildContext context) {
    // Если пользователь уже вошел в аккаунт, перейти на домашнюю страницу
    // If _boxLogin.get("loginStatus") is non-null, returns its value;
    // otherwise, evaluates and returns the value of false.
    if (_boxLogin.get("loginStatus") ?? false) {
      return Home();
    }
    // Иначе загружаем страницу входа
    // Возвращаем базовый виджет для построения интерфейса экрана страницы
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,  // Привязка ключа формы
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 150),
              Text(
                "Добро пожаловать в ЛОПАТЬ И ТОПАТЬ",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Войдите в аккаунт",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 60),

              // Поле для ввода имени пользователя
              TextFormField(
                controller: _controllerUsername,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Имя пользователя",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // После заполнения поля имени еренаправляем фокус на поле пароля
                onEditingComplete: () => _focusNodePassword.requestFocus(),
                // Валидация для поля ввода имени пользователя
                // Если пользователь не заполнил поле или
                // ввел неверное имя пользователя,
                // то появляется сообщение об ошибке под соответствующим полем.
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Пожалуйста введите имя пользователя.";
                  } else if (!_boxAccounts.containsKey(value)) {
                    return "Пользователь с таким именем не зарегистрирован.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Поле для ввода пароля пользователя
              TextFormField(
                controller: _controllerPassword,
                focusNode: _focusNodePassword,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Пароль",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                      onPressed: () {
                        // Меняем значение флага на противоположное
                        // при нажатии на иконку глаза
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      // Иконка глаза, если пароль скрыт и флаг = true
                      // иконка глаза с чертой, если пароль виден и флаг false
                      icon: _obscurePassword
                          ? const Icon(Icons.visibility_outlined)
                          : const Icon(Icons.visibility_off_outlined)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Валидация для поля ввода пароля
                // Если пользователь не заполнил поле или
                // ввел неверный пароль,
                // то появляется сообщение об ошибке под соответствующим полем.
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Пожалуйста введите пароль.";
                  } else if (value !=
                      _boxAccounts.get(_controllerUsername.text)) {
                    return "Неверный пароль.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 60),

              // Кнопка "Войти"
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    // Обработка события нажатия на кнопку "Войти"
                    onPressed: () {
                      // Если пользователь ввел корректные данные
                      if (_formKey.currentState?.validate() ?? false) {
                        // Устанавливается флаг входа в аккаунт в Hive
                        _boxLogin.put("loginStatus", true);
                        // и сохраняется имя пользователя в Hive
                        _boxLogin.put("userName", _controllerUsername.text);

                        // Переход на домашнюю страницу при нажатии на
                        // кнопку "Войти"
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Home();
                            },
                          ),
                        );
                      }
                    },
                    child: const Text("Войти"),
                  ),
                  // Под кнопкой "Войти" есть текст и кнопка "Регистрация"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Еще нет аккаунта?"),
                      TextButton(
                        // При нажатии на кнопку
                        onPressed: () {
                          // происходит сброс формы
                          _formKey.currentState?.reset();
                          // Переход на страницу регистрации при нажатии на
                          // кнопку "Регистрация"
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Signup();
                              },
                            ),
                          );
                        },
                        child: const Text("Регистрация"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Метод, в котором при завершении работы страницы освобождаются ресурсы,
  // такие как контроллеры и экземпляр класса
  @override
  void dispose() {  // dispose method of the StatefulWidget
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose(); // деструктор класса, как я поняла
  }
}
