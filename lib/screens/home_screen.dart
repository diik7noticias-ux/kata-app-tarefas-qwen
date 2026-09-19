{
  "code": "import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'home_screen.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  bool isCompleted;

  Task({
    required this.id,
    required this.description,
    this.isCompleted = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Task> taskBox;

  @override
  void initState() {
    super.initState();
    Hive.registerAdapter(TaskAdapter());
    Hive.openBox<Task>('tasks').then((box) {
      setState(() {
        taskBox = box;
      });
    });
  }

  void addTask(String description) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
    );
    taskBox.add(newTask);
    setState(() {});
  }

  void toggleTaskCompletion(String id) {
    final task = taskBox.values.firstWhere((task) => task.id == id);
    task.isCompleted = !task.isCompleted;
    taskBox.put(task.id, task);
    setState(() {});
  }

  void deleteTask(String id) {
    final task = taskBox.values.firstWhere((task) => task.id == id);
    taskBox.delete(task.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas Qwen'),
        automaticallyImplyLeading: false,
      ),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: ValueListenable(box: taskBox),
        builder: (context, box, _) {
          final tasks = box.values.toList();
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return CheckboxListTile(
                value: task.isCompleted,
                onChanged: (value) => toggleTaskCompletion(task.id),
                title: Text(
                  task.description,
                  style: TextStyle(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteTask(task.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text('Nova Tarefa'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Descrição'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        addTask(controller.text);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}",
  "ui": {
    "screen": "home_screen",
    "kind": "list",
    "topBar": {
      "title": "Tarefas Qwen",
      "hasBack": false,
      "actions": []
    },
    "body": {
      "type": "scrollable_list",
      "items": [
        {"id": "task_1", "text": "Comprar leite", "checked": false, "hasCheckbox": true, "hasDelete": true},
        {"id": "task_2", "text": "Lavar roupa", "checked": false, "hasCheckbox": true, "hasDelete": true},
        {"id": "task_3", "text": "Estudar Flutter", "checked": true, "hasCheckbox": true, "hasDelete": true}
      ]
    },
    "inputBar": null,
    "fab": {
      "icon": "add",
      "visible": true
    }
  },
  "colors": {
    "primary": "#6200EE",
    "background": "#FFFFFF",
    "surface": "#F5F5F5"
  }
}