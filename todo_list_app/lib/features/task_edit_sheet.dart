import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import '../models/task.dart';

class TaskEditSheet extends StatefulWidget {
  final Task task;
  final Function(Task) onSave;

  const TaskEditSheet({Key? key, required this.task, required this.onSave}) : super(key: key);

  @override
  _TaskEditSheetState createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends State<TaskEditSheet> {
  late TextEditingController _titleController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _textController = TextEditingController(text: widget.task.text ?? '');
  }

  bool get _isCupertino => Theme.of(context).platform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 8,
      ),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          // Элемент для свайпа вниз
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Заголовок и кнопка "Готово"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Редактирование задачи',
                style: _isCupertino
                    ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                    : Theme.of(context).textTheme.bodyLarge,
              ),
              _isCupertino
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Готово'),
                      onPressed: () {
                        widget.onSave(Task(
                          id: widget.task.id,
                          title: _titleController.text,
                          text: _textController.text,
                        ));
                        Navigator.pop(context);
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.done),
                      onPressed: () {
                        widget.onSave(Task(
                          id: widget.task.id,
                          title: _titleController.text,
                          text: _textController.text,
                        ));
                        Navigator.pop(context);
                      },
                    ),
            ],
          ),
          const SizedBox(height: 16),
          // Поле для заголовка (платформенное)
          _isCupertino
              ? CupertinoTextField(
                  controller: _titleController,
                  placeholder: 'Заголовок',
                  padding: const EdgeInsets.all(16),
                )
              : TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Заголовок',
                    border: OutlineInputBorder(),
                  ),
                ),
          const SizedBox(height: 16),
          // Поле для текста задачи (платформенное)
          Expanded(
            child: _isCupertino
                ? CupertinoTextField(
                    controller: _textController,
                    placeholder: 'Описание задачи',
                    padding: const EdgeInsets.all(16),
                    maxLines: null,
                    expands: true,
                  )
                : TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Описание задачи',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                  ),
          ),
          const SizedBox(height: 16),
          // Переключатель статуса задачи (платформенный)
          _isCupertino
              ? CupertinoButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      CupertinoRadio<bool>(
                        value: true,
                        groupValue: false,
                        onChanged: (value) {},
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Задача выполнена',
                        style: TextStyle(
                          // ignore: dead_code
                          color: false ? CupertinoColors.systemGrey : CupertinoColors.label,
                        ),
                      ),
                    ],
                  ),
                )
              : ListTile(
                  leading: Radio<bool>(
                    value: true,
                    groupValue: false,
                    onChanged: (value) {},
                  ),
                  title: Text(
                    'Задача выполнена',
                    style: TextStyle(
                      // ignore: dead_code
                      color: false ? Colors.grey : null,
                    ),
                  ),
                  onTap: () {},
                ),
        ],
      ),
    );
  }
}