import 'package:flutter/material.dart';
import 'package:treap/treap.dart';

import '../domain/history.dart';
import '../domain/task.dart';
import '../extensions.dart';
import 'edit_task_page.dart';
import 'task_tile.dart';

class TodoListPage extends StatefulWidget {
  final String title;

  const TodoListPage({Key? key, required this.title}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

const opacityCurve = Interval(0.0, 0.75, curve: Curves.fastOutSlowIn);

class _TodoListPageState extends State<TodoListPage> {
  final listKey = GlobalKey<AnimatedListState>();
  final history = History();

  var count = 0;
  var showCompleted = true;

  Treap<Task> get tasks {
    final l = history.currentList;
    return showCompleted ? l.all : l.uncompleted;
  }

  void _updateList(void Function() action, {bool fastRemove = false}) {
    setState(() {
      final before = tasks;
      action();
      final after = tasks;
      for (var task in (before - after).values) {
        final index = after.rank(task); // where it would have been
        listKey.currentState?.removeItem(
          index,
          (context, animation) {
            return TaskTile(
              key: ValueKey(task.id),
              task: task,
              onCompletionChanged: (v) => _setCompletion(task, v),
              animation: animation,
            );
          },
          duration: fastRemove ? Duration.zero : animationDuration,
        );
      }
      for (var task in (after - before).values) {
        final index = after.rank(task); // where it is
        listKey.currentState?.insertItem(
            index); // animation handled by AnimatedList.itemBuilder itself
      }
    });
  }

  void _addTask() {
    _updateList(() {
      history.change((tl) {
        final id = ++count;
        final task = Task(id, 'Task #$count', DateTime.now().offset(hours: 3),
            const Duration(hours: 2), false);
        return tl.addOrUpdate(task);
      });
    });
  }

  void _editTask(Task old, Task current) {
    _updateList(() {
      history.change((tl) {
        return tl.remove(old).addOrUpdate(
            current); // remove first in case primary key is updated
      });
    });
  }

  void _removeTask(Task t) {
    _updateList(() {
      history.change((tl) => tl.remove(t));
    }, fastRemove: true);
  }

  void _setCompletion(Task t, bool completed) {
    _updateList(() {
      history.change((tl) {
        return tl.addOrUpdate(t.copyWith(completed: completed));
      });
    });
  }

  void _setShowCompletion(bool show) {
    if (showCompleted == show) return;
    _updateList(() {
      showCompleted = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AnimatedList(
                key: listKey,
                initialItemCount: tasks.size,
                itemBuilder: (context, index, animation) {
                  if (index >= tasks.size) {
                    return const SizedBox();
                  }
                  final task = tasks[index];
                  return TaskTile(
                    key: ValueKey(task.id),
                    task: task,
                    onCompletionChanged: (v) => _setCompletion(task, v),
                    onDismissed: (d) => _removeTask(task),
                    onTap: () async {
                      _editTask(
                        task,
                        await Navigator.push(
                              context,
                              PageRouteBuilder<Task>(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  return AnimatedBuilder(
                                    animation: animation,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: opacityCurve
                                            .transform(animation.value),
                                        child: child,
                                      );
                                    },
                                    child: EditTaskPage(task: task),
                                  );
                                },
                              ),
                            ) ??
                            task,
                      );
                    },
                    animation: animation,
                  );
                },
              ),
            ),
            _buildUndoRedo(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add new task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUndoRedo(BuildContext context) {
    final max = history.history.length - 1;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: max > 0
          ? Row(
              children: [
                Tooltip(
                  message: 'Show completed task',
                  child: Switch(
                    value: showCompleted,
                    onChanged: _setShowCompletion,
                  ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: 'Undo',
                  child: IconButton(
                    onPressed: history.canUndo
                        ? () => _updateList(() => history.undo())
                        : null,
                    icon: const Icon(Icons.undo),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackShape: const RoundedRectSliderTrackShape(),
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 28),
                      tickMarkShape: const RoundSliderTickMarkShape(),
                      valueIndicatorShape:
                          const PaddleSliderValueIndicatorShape(),
                      valueIndicatorTextStyle:
                          const TextStyle(color: Colors.white),
                    ),
                    child: Tooltip(
                      message: 'Select version',
                      child: Slider(
                        value: history.current.toDouble(),
                        label: '${history.current}',
                        min: 0,
                        max: max.toDouble(),
                        divisions: max,
                        onChanged: (v) {
                          _updateList(() {
                            history.current = v.toInt();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Redo',
                  child: IconButton(
                    onPressed: history.canRedo
                        ? () => _updateList(() => history.redo())
                        : null,
                    icon: const Icon(Icons.redo),
                  ),
                ),
                const SizedBox(width: 96), // leave room for FAB
              ],
            )
          : const SizedBox(),
    );
  }
}
