import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/models/meal_model.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _mealTableName = "meals";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "meal_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          Create Table $_mealTableName (
          id INTEGER PRIMARY KEY,
          strMeal TEXT NOT NULL,
          strInstructions TEXT,
          strIngredient1 TEXT,
          strMeasure1 TEXT
          )
        ''');
      },
    );
    return database;
  }

  Future<void> insertMeal(Meals meal) async {
    final db = await database;
    await db.insert(_mealTableName, {
      'strMeal': meal.strMeal,
      'strInstructions': meal.strInstructions,
      'strIngredient1': meal.strIngredient1,
      'strMeasure1': meal.strMeasure1,
    });
  }

  Future<List<Meals>> getAllMeals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_mealTableName);
    
    return List.generate(maps.length, (i) {
      return Meals(
        idMeal: maps[i]['id'].toString(),
        strMeal: maps[i]['strMeal'],
        strInstructions: maps[i]['strInstructions'],
        strIngredient1: maps[i]['strIngredient1'],
        strMeasure1: maps[i]['strMeasure1'],
      );
    });
  }

  // Update a meal
  Future<int> updateMeal(Meals meal) async {
    final db = await database;
    return await db.update(
      _mealTableName,
      {
        'strMeal': meal.strMeal,
        'strInstructions': meal.strInstructions,
        'strIngredient1': meal.strIngredient1,
        'strMeasure1': meal.strMeasure1,
      },
      where: 'id = ?',
      whereArgs: [meal.idMeal],
    );
  }

  // Delete a meal
  Future<int> deleteMeal(String id) async {
    final db = await database;
    return await db.delete(
      _mealTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}