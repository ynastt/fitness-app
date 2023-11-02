import 'package:flutter/material.dart';
import 'package:hive/hive.dart';  // библиотека Hive для работы с локальной базой данных

// Создаем класс Signup, который является Stateful виджетом (виджет состояний)
class Signup extends StatefulWidget {
  const Signup({super.key});  // Конструктор класса

  @override
  State<Signup> createState() => _SignupState();
}

// Этот класс представляет состояние виджета Signup.
// В нем объявляются различные переменные и контроллеры,
// которые используются на странице.
class _SignupState extends State<Signup> {
  // Ключ формы для валидации
  final GlobalKey<FormState> _formKey = GlobalKey();

  // Управление фокусом на всех полях ввода после имени пользователя,
  // чтобы перепрыгивал фокус после заполнения поля сверху и Enter
  // FocusNode - объект, который может быть использован виджетом состояния
  // для получения фокуса клавиатуры и обработки событий клавиатуры
  final FocusNode _focusNodeHeight = FocusNode();
  final FocusNode _focusNodeWeight = FocusNode();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();

  // Контроллер для поля ввода имени пользователя
  final TextEditingController _controllerUsername = TextEditingController();
  // Контроллер для поля ввода почты пользователя
  final TextEditingController _controllerEmail = TextEditingController();
  // Контроллер для поля ввода роста пользователя
  final TextEditingController _controllerHeight = TextEditingController();
  // Контроллер для поля ввода веса пользователя
  final TextEditingController _controllerWeight = TextEditingController();
  // Контроллер для поля ввода пароля (повторного тоже) пользователя
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConFirmPassword = TextEditingController();

  // Хранилище для данных об аккаунтах
  final Box _boxAccounts = Hive.box("accounts");
  // Хранилище для данных о росте пользователей
  final Box _boxAccountsHeight = Hive.box("heights");
  // Хранилище для данных о весе пользователей
  final Box _boxAccountsWeight = Hive.box("weights");

  // Флаг скрытия пароля
  bool _obscurePassword = true;

  // Переопределяем метод build для построения пользовательского интерфейса
  @override
  Widget build(BuildContext context) {
    // Возвращаем базовый виджет для построения интерфейса экрана страницы
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Text(
                "Регистрация",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "Создайте свой акаунт",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 35),

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
                // Валидация для поля ввода имени пользователя
                // Если пользователь не заполнил поле или
                // ввел неверное имя пользователя,
                // то появляется сообщение об ошибке под соответствующим полем.
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Пожалуйста введите имя пользователя.";
                  } else if (_boxAccounts.containsKey(value)) {
                    return "Пользователь с таким именем уже зарегистрирован.";
                  }
                  return null;
                },
                // После заполнения поля имени перенаправляем фокус на поле роста
                onEditingComplete: () => _focusNodeHeight.requestFocus(),
              ),
              const SizedBox(height: 10),

              // Поле для ввода роста пользователя
              TextFormField(
                controller: _controllerHeight,
                focusNode: _focusNodeHeight,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Рост",
                  prefixIcon: const Icon(Icons.accessibility_new),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Валидация для поля ввода роста пользователя
                // Если пользователь не заполнил поле,
                // то появляется сообщение об ошибке под соответствующим полем.
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Пожалуйста введите рост пользователя.";
                  }
                  return null;
                },
                // После заполнения поля имени перенаправляем фокус на поле веса
                onEditingComplete: () => _focusNodeWeight.requestFocus(),
              ),
              const SizedBox(height: 10),

              // Поле для ввода веса пользователя
              TextFormField(
                controller: _controllerWeight,
                focusNode: _focusNodeWeight,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Вес",
                  prefixIcon: const Icon(Icons.accessibility_new),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Валидация для поля ввода веса пользователя
                // Если пользователь не заполнил поле,
                // то появляется сообщение об ошибке под соответствующим полем.
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Пожалуйста введите вес пользователя.";
                  }
                  return null;
                },
                // После заполнения поля имени перенаправляем фокус на поле почты
                onEditingComplete: () => _focusNodeEmail.requestFocus(),
              ),
              const SizedBox(height: 10),

              // Поле для ввода почты пользователя
              TextFormField(
                controller: _controllerEmail,
                focusNode: _focusNodeEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Почта",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Валидация для поля почты пароля
                // Если пользователь не заполнил поле или
                // заполнил поле не почтой (нет собачки),
                // то появляется сообщение об ошибке под соответствующим полем.
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Пожалуйста введите почту.";
                  } else if (!(value.contains('@') && value.contains('.'))) {
                    return "Неверный адрес почты";
                  }
                  return null;
                },
                // После заполнения поля имени перенаправляем фокус на поле пароля
                onEditingComplete: () => _focusNodePassword.requestFocus(),
              ),
              const SizedBox(height: 10),

              // Поле для ввода пароля пользователя
              TextFormField(
                controller: _controllerPassword,
                obscureText: _obscurePassword,
                focusNode: _focusNodePassword,
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
                  } else if (value.length < 6) {
                    return "Пароль должен содержать не менее 6 символов.";
                  }
                  return null;
                },
                // После заполнения поля имени перенаправляем фокус на поле
                // повторного пароля
                onEditingComplete: () =>
                    _focusNodeConfirmPassword.requestFocus(),
              ),
              const SizedBox(height: 10),

              // Поле для повторного ввода имени пользователя
              TextFormField(
                controller: _controllerConFirmPassword,
                obscureText: _obscurePassword,
                focusNode: _focusNodeConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Подтверждение пароля",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          // Меняем значение флага на противоположное
                          // при нажатии на иконку глаза
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
                // ввел пароль, не совпадающий с предыдущим,
                // то появляется сообщение об ошибке под соответствующим полем.
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Пожалуйста введите пароль повторно.";
                  } else if (value != _controllerPassword.text) {
                    return "Пароли не совпадают.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),

              // Кнопка "Регистрация"
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    // Обработка события нажатия на кнопку "Зарегистрироваться"
                    onPressed: () {
                      // Если пользователь ввел корректные данные:
                      if (_formKey.currentState?.validate() ?? false) {
                        // сохраняется имя пользователя и пароль в Hive
                        _boxAccounts.put(
                          _controllerUsername.text,
                          _controllerConFirmPassword.text,
                        );
                        // сохраняется рост пользователя в Hive
                        _boxAccountsHeight.put(_controllerUsername.text,
                          _controllerHeight.text,
                        );
                        // сохраняется почта пользователя в Hive
                        _boxAccountsWeight.put(_controllerUsername.text,
                          _controllerWeight.text,
                        );
                        // выводится сообщение об успешной регистрации
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            width: 200,
                            backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            behavior: SnackBarBehavior.floating,
                            content: const Text("Регистрация прошла успешно!"),
                          ),
                        );
                        // происходит сброс формы
                        _formKey.currentState?.reset();
                        // снимаем со стека контекст регистрации
                        // тем самым возвращаемся на первую страницу входа
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Зарегистрироваться"),
                  ),
                  // Под кнопкой "Зарегистрироваться" есть текст и кнопка "Войдите"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Уже есть аккаунт?"),
                      TextButton(
                        // Переход на страницу входа при нажатии на
                        // кнопку "Войдите"
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Войдите"),
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
  // такие как контроллеры, ноды фокуса и экземпляр класса
  @override
  void dispose() {  // dispose method of the StatefulWidget
    _focusNodeHeight.dispose();
    _focusNodeWeight.dispose();
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();
    _controllerUsername.dispose();
    _controllerHeight.dispose();
    _controllerWeight.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerConFirmPassword.dispose();
    super.dispose();  // деструктор класса
  }
}