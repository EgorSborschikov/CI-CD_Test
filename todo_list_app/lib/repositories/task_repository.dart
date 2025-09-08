import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskRepository {
  static const _key = 'tasks';

  Future<List<Task>> getTasks() async{
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tasks = prefs.getStringList(_key);
    return tasks?.map((e) => Task.fromMap(Map<String, dynamic>.from(json.decode(e)))).toList() ?? [];
  }

  Future<void> saveTasks(List<Task> tasks) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key, 
      tasks.map((e) => json.encode(e.toMap())).toList()
    );
  }
}