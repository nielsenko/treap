import 'package:flutter/material.dart';

import '../domain/task.dart';

class TaskHero extends StatelessWidget {
  final Task task;
  final double? radius;

  const TaskHero({
    super.key,
    required this.task,
    this.radius,
  });

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
