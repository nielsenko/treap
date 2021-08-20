import 'package:flutter/material.dart';

import '../domain/task.dart';
import '../extensions.dart';

final animationDuration = const Duration(milliseconds: 200);

class TaskTile extends StatelessWidget {
  final Task task;
  final void Function(bool) onCompletionChanged;
  final void Function(DismissDirection)? onDismissed;
  final void Function()? onTap;
  final Animation<double> animation;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onCompletionChanged,
    required this.animation,
    this.onDismissed,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      key: Key(task.name),
      duration: animationDuration,
      child: Dismissible(
        key: Key(task.name),
        background: Container(
          color: Colors.red,
          child: Center(
            child: Text(
              'You can always undo',
              style: Theme.of(context).textTheme.headline5?.copyWith(color: Colors.white),
            ),
          ),
        ),
        resizeDuration: animationDuration,
        movementDuration: animationDuration,
        onDismissed: onDismissed,
        child: FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: ListTile(
              onTap: onTap,
              leading: Hero(
                tag: task,
                child: CircleAvatar(
                  child: Text('${task.id}'),
                ),
              ),
              title: Text(task.name),
              subtitle: Text('${task.due.yMdhm}\n${task.duration.hm}'),
              trailing: Checkbox(
                value: task.completed,
                onChanged: (v) => onCompletionChanged(v ?? false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
