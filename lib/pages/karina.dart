import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Karina extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(10, 10, 68, 1.0),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Подсчет калорий'),
        ),
        body: CalorieTrackerScreen(),
      ),
    );
  }
}

// Главный экран приложения для отслеживания продуктов и калорий
class CalorieTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tracker = Provider.of<CalorieTracker>(context);
    final products = tracker.products;
    final consumedFoodEntries = tracker.foodEntries;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('${product.caloriesPer100g} ккал/100г'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddFoodDialog(product: product);
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return EditProductDialog(product: product);
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        tracker.removeProduct(product);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ConsumedFoodEntriesScreen(),
                  ),
                );
              },
              child: Text('Съеденные продукты'),
            ),
            Spacer(), // Добавляет пространство между кнопками
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddNewProductDialog();
                  },
                );
              },
              child: Text('Добавить новый продукт'),
            ),
          ],
        ),
        Divider(),
        TotalCalories(),
      ],
    );
  }
}

// Экран, показывающий съеденные продукты
class ConsumedFoodEntriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tracker = Provider.of<CalorieTracker>(context);
    final consumedFoodEntries = tracker.foodEntries;

    return Scaffold(
      appBar: AppBar(
        title: Text('Список съеденных продуктов'),
      ),
      body: Column(
        children: <Widget>[
          if (consumedFoodEntries.isNotEmpty) ...[
            Text(
              'Съедено:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ConsumedFoodList(consumedFoodEntries: consumedFoodEntries),
          ],
        ],
      ),
    );
  }
}

// Диалог для добавления съеденного продукта
class AddFoodDialog extends StatefulWidget {
  final Product product;

  AddFoodDialog({required this.product});

  @override
  _AddFoodDialogState createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final TextEditingController _gramsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tracker = Provider.of<CalorieTracker>(context);

    return AlertDialog(
      title: Text('Добавить продукт'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(widget.product.name),
          TextField(
            controller: _gramsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Граммы'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            final gramsConsumed = int.tryParse(_gramsController.text);
            if (gramsConsumed != null) {
              tracker.addFoodEntry(widget.product, gramsConsumed);
              Navigator.of(context).pop();
            }
          },
          child: Text('Добавить'),
        ),
      ],
    );
  }
}

// Список съеденных продуктов
class ConsumedFoodList extends StatelessWidget {
  final List<FoodEntry> consumedFoodEntries;

  ConsumedFoodList({required this.consumedFoodEntries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: consumedFoodEntries.map((entry) {
        return ListTile(
          title: Text(' ${entry.gramsConsumed} грамм ${entry.product.name}'),
          subtitle: Text('Калории: ${entry.totalCalories} ккал'),
        );
      }).toList(),
    );
  }
}

// Модель продукта
class Product {
  final String name;
  final int caloriesPer100g;

  Product(this.name, this.caloriesPer100g);
}

// Модель для записи съеденного продукта
class FoodEntry {
  final Product product;
  final int gramsConsumed;

  FoodEntry(this.product, this.gramsConsumed);

  int get totalCalories => (gramsConsumed * product.caloriesPer100g) ~/ 100;
}

// Модель для добавления нового продукта
class NewProduct {
  final String name;
  final int caloriesPer100g;

  NewProduct(this.name, this.caloriesPer100g);
}

// Модель для отслеживания калорий
class CalorieTracker with ChangeNotifier {
  final List<Product> _products = []; // Список продуктов
  final List<FoodEntry> _foodEntries = []; // Список съеденных продуктов
  final Duration resetDuration = Duration(days: 1); // Время до сброса данных

  CalorieTracker() {
    loadProducts(); // Загрузка продуктов из хранилища
    loadFoodEntries(); // Загрузка съеденных продуктов из хранилища
    _scheduleDataReset(); // Запланировать сброс данных
  }

  void _scheduleDataReset() {
    final now = DateTime.now();
    final nextResetTime = DateTime(
        now.year,
        now.month,
        now.day + 1, // Сброс данных в полночь следующего дня
        0, // Полночь
        0 // Полночь
    );
    final timeUntilReset = nextResetTime.isBefore(now)
        ? nextResetTime.add(Duration(days: 1)).difference(now)
        : nextResetTime.difference(now);
    Timer(timeUntilReset, () {
      resetData(); // Вызвать метод сброса данных
      _scheduleDataReset(); // Запланировать следующий сброс данных
    });
  }

  void resetData() {
    _foodEntries.clear(); // Очистить список съеденных продуктов
    notifyListeners(); // Уведомить слушателей об изменении данных
  }

  List<Product> get products => _products; // Получить список продуктов
  List<FoodEntry> get foodEntries => _foodEntries; // Получить список съеденных продуктов

  // Добавить съеденный продукт
  Future<void> addFoodEntry(Product product, int gramsConsumed) async {
    _foodEntries.add(FoodEntry(product, gramsConsumed)); // Добавить запись о съеденном продукте
    await saveFoodEntries(); // Сохранить записи о съеденных продуктах в хранилище
    notifyListeners(); // Уведомить слушателей об изменении данных
  }

  // Добавить новый продукт в список доступных продуктов
  Future<void> addNewProduct(NewProduct newProduct) async {
    _products.add(Product(newProduct.name, newProduct.caloriesPer100g)); // Добавить новый продукт
    await saveProducts(); // Сохранить список доступных продуктов в хранилище
    notifyListeners(); // Уведомить слушателей об изменении данных
  }

  // Удалить продукт из списка доступных продуктов
  Future<void> removeProduct(Product product) async {
    _products.remove(product); // Удалить продукт из списка
    await saveProducts(); // Сохранить обновленный список продуктов
    notifyListeners(); // Уведомить слушателей об изменении данных
  }

  // Редактировать продукт в списке доступных продуктов
  Future<void> editProduct(Product oldProduct, Product newProduct) async {
    final index = _products.indexOf(oldProduct); // Найти индекс старого продукта
    if (index >= 0) {
      _products[index] = newProduct; // Заменить старый продукт на новый
      await saveProducts(); // Сохранить обновленный список продуктов
      notifyListeners(); // Уведомить слушателей об изменении данных
    }
  }

  // Загрузить список продуктов из хранилища
  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productStrings = prefs.getStringList('products') ?? [];
    _products.clear();
    for (var productString in productStrings) {
      final parts = productString.split(':');
      if (parts.length == 2) {
        final name = parts[0];
        final caloriesPer100g = int.tryParse(parts[1]);
        if (caloriesPer100g != null) {
          _products.add(Product(name, caloriesPer100g));
        }
      }
    }
    notifyListeners(); // Уведомить слушателей об изменении данных
  }

  // Сохранить список продуктов в хранилище
  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productStrings = _products.map((product) {
      return '${product.name}:${product.caloriesPer100g}';
    }).toList();
    await prefs.setStringList('products', productStrings);
    notifyListeners();
  }

  // Загрузить список съеденных продуктов из хранилища
  Future<void> loadFoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final foodEntriesString = prefs.getStringList('foodEntries') ?? [];
    _foodEntries.clear();
    for (var foodEntryString in foodEntriesString) {
      final parts = foodEntryString.split(':');
      if (parts.length == 3) {
        final productName = parts[0];
        final gramsConsumed = int.tryParse(parts[1]);
        final caloriesPer100g = int.tryParse(parts[2]);
        if (gramsConsumed != null && caloriesPer100g != null) {
          final product = Product(productName, caloriesPer100g);
          _foodEntries.add(FoodEntry(product, gramsConsumed));
        }
      }
    }
    notifyListeners(); // Уведомить слушателей об изменении данных
  }

  // Сохранить список съеденных продуктов в хранилище
  Future<void> saveFoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final foodEntriesStrings = _foodEntries.map((entry) {
      final product = entry.product;
      return '${product.name}:${entry.gramsConsumed}:${product.caloriesPer100g}';
    }).toList();
    await prefs.setStringList('foodEntries', foodEntriesStrings);
    notifyListeners();
  }
}


// Диалог для редактирования продукта
class EditProductDialog extends StatefulWidget {
  final Product product;

  EditProductDialog({required this.product});

  @override
  _EditProductDialogState createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _caloriesController.text = widget.product.caloriesPer100g.toString();
  }

  @override
  Widget build(BuildContext context) {
    final tracker = Provider.of<CalorieTracker>(context);

    return AlertDialog(
      title: Text('Изменить продукт'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Имя продукта'),
          ),
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Калории на 100 грамм'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () async {
            final name = _nameController.text;
            final caloriesPer100g = int.tryParse(_caloriesController.text);

            if (name.isNotEmpty && caloriesPer100g != null) {
              final updatedProduct = Product(name, caloriesPer100g);
              await tracker.editProduct(widget.product, updatedProduct);
              Navigator.of(context).pop();
            }
          },
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}

// Кнопка для добавления нового продукта
class AddNewProductButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddNewProductDialog();
          },
        );
      },
      child: Text('Добавить новый продукт'),
    );
  }
}

// Диалог для добавления нового продукта
class AddNewProductDialog extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tracker = Provider.of<CalorieTracker>(context);
    return AlertDialog(
      title: Text('Добавить новый продукт'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Имя продукта'),
          ),
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Калории на 100 грамм'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () async {
            final name = _nameController.text;
            final caloriesPer100g = int.tryParse(_caloriesController.text);

            if (name.isNotEmpty && caloriesPer100g != null) {
              final newProduct = NewProduct(name, caloriesPer100g);
              await tracker.addNewProduct(newProduct);
              Navigator.of(context).pop();
            }
          },
          child: Text('Добавить'),
        ),
      ],
    );
  }
}

// Виджет для отображения общего количества калорий
class TotalCalories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tracker = Provider.of<CalorieTracker>(context);
    final foodEntries = tracker.foodEntries;

    int totalCalories = 0;
    for (var entry in foodEntries) {
      totalCalories += entry.totalCalories;
    }

    final totalCaloriesProvider = Provider.of<TotalCaloriesProvider>(context);
    totalCaloriesProvider.setTotalCalories(totalCalories);

    return ListTile(
      title: Text('Итого калорий: $totalCalories ккал'),
    );
  }
}


class TotalCaloriesProvider with ChangeNotifier {
  int _totalCalories = 0;

  int get totalCalories => _totalCalories;

  void setTotalCalories(int calories) {
    _totalCalories = calories;
    notifyListeners();
  }
}

