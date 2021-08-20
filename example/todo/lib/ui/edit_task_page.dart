import 'package:flutter/material.dart';

import '../domain/task.dart';
import '../extensions.dart';
import 'task_hero.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late Task _editedTask;
  final _nameController = TextEditingController();

  Future<void> _selectTime(BuildContext context) async {
    var due = _editedTask.due;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(due),
    );
    if (picked == null) return;
    setState(() {
      due = DateTime(due.year, due.month, due.day, picked.hour, picked.minute);
      _editedTask = _editedTask.copyWith(due: due);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    var due = _editedTask.due;
    final picked = await showDatePicker(
      context: context,
      initialDate: due,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().offset(years: 5),
    );
    if (picked == null) return;
    setState(() {
      due = DateTime(picked.year, picked.month, picked.day, due.hour, due.minute);
      _editedTask = _editedTask.copyWith(due: due);
    });
  }

  void _submit(BuildContext context) {
    _editedTask = _editedTask.copyWith(name: _nameController.text);
    Navigator.pop(context, _editedTask);
  }

  @override
  void initState() {
    super.initState();
    _editedTask = widget.task.copyWith();
    _nameController.text = _editedTask.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
      ),
      body: ListView(
        children: [
          TaskHero(
            task: task,
            radius: 80,
          ),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
              hintText: 'Enter a descriptive name for the task',
            ),
          ),
          Row(
            children: [
              OutlinedButton(
                child: Text('${_editedTask.due.yMdhm}'),
                onPressed: () => _selectDate(context),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                child: Text('${TimeOfDay.fromDateTime(_editedTask.due).hm}'),
                onPressed: () => _selectTime(context),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _submit(context),
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
