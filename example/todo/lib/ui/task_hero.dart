import 'package:flutter/material.dart';

import '../domain/task.dart';

class TaskHero extends StatelessWidget {
  final Task task;
  final double? radius;

  const TaskHero({
    Key? key,
    required this.task,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: task.id,
      child: CircleAvatar(
        radius: radius,
        child: Text('${task.id}'),
      ),
    );
  }
}
