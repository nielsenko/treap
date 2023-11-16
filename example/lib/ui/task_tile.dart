import 'package:flutter/material.dart';

import '../domain/task.dart';
import '../extensions.dart';
import 'task_hero.dart';

const animationDuration = Duration(milliseconds: 200);

class TaskTile extends StatelessWidget {
  final Task task;
  final void Function(bool) onCompletionChanged;
  final void Function(DismissDirection)? onDismissed;
  final void Function()? onTap;
  final Animation<double> animation;

  const TaskTile({
    super.key,
    required this.task,
    required this.onCompletionChanged,
    required this.animation,
    this.onDismissed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final key = this.key ?? ValueKey(task.id);
    return Dismissible(
      key: key,
      background: Container(
        color: Colors.red,
        child: Center(
          child: Text(
            'You can always undo',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white),
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
          child: AnimatedSwitcher(
            key: key,
            duration: animationDuration,
            child: ListTile(
              onTap: onTap,
              leading: Tooltip(
                message: 'Tap to edit',
                child: TaskHero(task: task),
              ),
              title: Text(task.name),
              subtitle: Text('${task.due.yMdhm}\n${task.duration.hm}'),
              trailing: Tooltip(
                message:
                    'Tap to ${task.completed ? 'undo completion' : 'complete'}',
                child: Checkbox(
                  value: task.completed,
                  onChanged: (v) => onCompletionChanged(v ?? false),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
