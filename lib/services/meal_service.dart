import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:todo_app/models/meal_model.dart';
import 'package:todo_app/utils/constants.dart';

class MealService {
  Future<List<Meals>?> getMealsByName(String name) async {
    Map<String, dynamic> parameters = {
      "s":name
    };
    var url1 = Uri.https(app_url, '${app_path}/search.php' , parameters);
    var response = await http.get(url1);
    if (response.statusCode==200) {
      var meal = Meal.fromJson(jsonDecode(response.body));
      return meal.meals;
    } else {
      throw Exception("no data");
    }
  }
}