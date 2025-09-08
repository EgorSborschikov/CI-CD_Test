import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/features/task_edit_sheet.dart';
import 'package:todo_list_app/repositories/task_repository.dart';
import '../models/task.dart';

class TasksListScreen extends StatefulWidget{
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final TaskRepository _repository = TaskRepository();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _repository.getTasks();
    setState(() => _tasks = tasks);
  }

  Future<void> _addTask() async {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Новая задача',
    );
    setState(() => _tasks.add(newTask));
    await _repository.saveTasks(_tasks);
    _openEditSheet(newTask);
  }

  Future<void> _updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      setState(() => _tasks[index] = updatedTask);
      await _repository.saveTasks(_tasks);
    }
  }

  Future<void> _deleteTask(Task task) async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    
    if (isAndroid) {
      // iOS-style confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Удалить задачу?'),
          content: Text('Вы уверены, что хотите удалить задачу "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Удалить'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        _performDelete(task);
      }
    } else {
      await showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Удалить задачу?'),
          message: Text('Задача "${task.title}" будет удалена безвозвратно'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _performDelete(task);
              },
              isDestructiveAction: true,
              child: const Text('Удалить'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ),
      );
    }
  }

  Future<void> _performDelete(Task task) async {
    setState(() => _tasks.remove(task));
    await _repository.saveTasks(_tasks);
    
    // Показать уведомление об удалении
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Задача "${task.title}" удалена'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openEditSheet(Task task) {
    final isCupertino = Theme.of(context).platform == TargetPlatform.iOS;
    
    if (isCupertino) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => TaskEditSheet(
          task: task,
          onSave: _updateTask,
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => TaskEditSheet(
          task: task,
          onSave: _updateTask,
        ),
      );
    }
  }

  Widget _buildPlatformAppBar() {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.android){
      return SliverAppBar(
        floating: true,
        title: const Text('Мои задачи'),
      );
    } else {
      return CupertinoSliverNavigationBar(
        largeTitle: const Text("Мои задачи"),
        trailing: IconButton(icon: const Icon(CupertinoIcons.add), onPressed: _addTask)
      );
    }
  }

  Widget _buildTaskCard(Task task) {
    final isCupertino = Theme.of(context).platform == TargetPlatform.iOS;
    
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart || direction == DismissDirection.startToEnd) {
          await _deleteTask(task);
          return false; // Уже обработали удаление в _deleteTask
        }
        return false;
      },
      onDismissed: (direction) {
        // Уже обработано в confirmDismiss
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: task.text != null && task.text!.isNotEmpty
              ? Text(
                  task.text!,
                  style: TextStyle(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                )
              : null,
          trailing: isCupertino
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _deleteTask(task),
                  child: const Icon(
                    CupertinoIcons.delete,
                    color: CupertinoColors.destructiveRed,
                    size: 20,
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteTask(task),
                ),
          onTap: () => _openEditSheet(task),
          onLongPress: () => _deleteTask(task),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildPlatformAppBar(),
          if (_tasks.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('Нет задач\nНажмите + чтобы добавить', 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildTaskCard(_tasks[i]),
                childCount: _tasks.length,
              ),
            ),
        ],
      ),
      floatingActionButton: Theme.of(context).platform == TargetPlatform.android
          ? FloatingActionButton(
              onPressed: _addTask,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}