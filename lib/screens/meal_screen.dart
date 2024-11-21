import 'package:flutter/material.dart';
import 'package:todo_app/models/meal_model.dart';
import 'package:todo_app/services/database_service.dart';
import 'package:todo_app/services/meal_service.dart';
//import 'package:todo_app/services/meal_service.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  List<Meals>? meals = [];
  final mealNameController = TextEditingController();
  final instructionsController = TextEditingController();
  final ingredientController = TextEditingController();
  final measureController = TextEditingController();
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  void _loadMeals() async {
    final loadedMeals = await DatabaseService.instance.getAllMeals();
    setState(() {
      meals = loadedMeals;
    });
  }

  void _addMealFromSearch(List<Meals> meals) async {
    for (var meal in meals) {
      await DatabaseService.instance.insertMeal(meal);
    }
    _loadMeals();
  }

  void _addManualMeal() async {
    final newMeal = Meals(
      strMeal: mealNameController.text,
      strInstructions: instructionsController.text,
      strIngredient1: ingredientController.text,
      strMeasure1: measureController.text,
    );

    await DatabaseService.instance.insertMeal(newMeal);
    _loadMeals();
    
    mealNameController.clear();
    instructionsController.clear();
    ingredientController.clear();
    measureController.clear();
    
    Navigator.of(context).pop();
  }

  void _deleteMeal(String id) async {
    await DatabaseService.instance.deleteMeal(id);
    _loadMeals();
  }

  void searchMeal (String name) async {
    MealService mealService = MealService();
    meals = await mealService.getMealsByName(name);
    _addMealFromSearch(meals!);
  }

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: mealNameController,
              decoration: const InputDecoration(labelText: 'Meal Name'),
            ),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(labelText: 'Instructions'),
            ),
            TextField(
              controller: ingredientController,
              decoration: const InputDecoration(labelText: 'Ingredient'),
            ),
            TextField(
              controller: measureController,
              decoration: const InputDecoration(labelText: 'Measure'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addManualMeal,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Meals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMealDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Search',
                  ),
                  controller: searchController,
                ),
              ),
              TextButton(onPressed: () {
                String search = searchController.text;
                searchMeal(search);
              },
              child: const Row(
                children: [
                  Icon(Icons.search), Text("Search")
                ],
              ))
            ],
        ),
          Expanded(
            child: ListView.builder(
              itemCount: meals!.length,
              itemBuilder: (context, index) {
                final meal = meals![index];
                return Dismissible(
                  key: Key(meal.idMeal ?? index.toString()),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    _deleteMeal(meal.idMeal ?? '');
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(meal.strMeal ?? 'Unnamed Meal'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (meal.strMealThumb != null)
                            Image.network(meal.strMealThumb!, width: 100),
                          Text(meal.strInstructions ?? ''),
                          Row(
                            children: [
                              Text(meal.strIngredient1 ?? ''),
                              const SizedBox(width: 10),
                              Text(meal.strMeasure1 ?? ''),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:todo_app/models/meal_model.dart';
import 'package:todo_app/services/meal_service.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  List<Meals>? meals = List.empty(growable: true);
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void searchMeal (String name) async {
    MealService mealService = MealService();
    this.meals = await mealService.getMealsByName(name);
    setState(() {
      this.meals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
      ),
      body: Column(children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Search',
                ),
                controller: searchController,
              ),
            ),
            TextButton(onPressed: () {
              String search = searchController.text;
              searchMeal(search);
            },
            child: Row(
              children: [
                Icon(Icons.search), Text("Search")
              ],
            ))
          ],
        ),
        Expanded(
          child: ListView(
            children: meals!.map((meal) => Column(children: [
              Container(padding: EdgeInsets.all(10), child: Text(meal.strMeal!, style: TextStyle(fontWeight: FontWeight.bold),)),
              if (meal.strMealThumb!=null)
                Image.network(meal.strMealThumb!, width: 300,),
              Container(padding: EdgeInsets.all(10), child: Text(meal.strInstructions!)),
              Row(
                children: [
                  Text(meal.strIngredient1!),
                  Text(meal.strMeasure1!),
                ],
              ),
              Divider()
            ],
          )).toList(),),
        )
      ],
    ));
  }
}*/