import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/features/tasks_list_screen.dart';

void main() {
  runApp( const TodoListApp()
    /*DevicePreview(
    enabled: true,
    builder: (context) => const TodoListApp()
    )*/
  );
}

class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Список задач',
      theme: ThemeData.light().copyWith(
        // Можно использовать темы из ui/themes.dart, но пока просто light
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      home: TasksListScreen()
    );
  }
}