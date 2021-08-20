import 'package:flutter/material.dart';
import 'package:treap/treap.dart';

import '../domain/history.dart';
import '../domain/task.dart';
import 'edit_task_page.dart';
import 'task_tile.dart';

class TodoListPage extends StatefulWidget {
  final String title;

  TodoListPage({Key? key, required this.title}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

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
        listKey.currentState?.insertItem(index); // animation handled by AnimatedList.itemBuilder itself
      }
    });
  }

  void _addTask() {
    _updateList(() {
      history.change((tl) {
        final id = ++count;
        final task = Task(id, 'Task #$count', DateTime.now(), const Duration(hours: 2), false);
        return tl.addOrUpdate(task);
      });
    });
  }

  void _editTask(Task old, Task current) {
    _updateList(() {
      history.change((tl) {
        return tl.remove(old).addOrUpdate(current); // remove first in case primary key is updated
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              key: listKey,
              initialItemCount: tasks.size,
              itemBuilder: (context, index, animation) {
                if (index >= tasks.size) {
                  print('$index missing!');
                  return SizedBox();
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
                            MaterialPageRoute(
                              builder: (ctx) => EditTaskPage(task: task),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              Text('Show completed'),
              Switch(
                value: showCompleted,
                onChanged: _setShowCompletion,
              ),
            ],
          ),
          _buildUndoRedo(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add new task',
        child: Icon(Icons.add),
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
                const SizedBox(width: 16),
                IconButton(
                  onPressed: history.canUndo ? () => _updateList(() => history.undo()) : null,
                  icon: Icon(Icons.undo),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackShape: RoundedRectSliderTrackShape(),
                      trackHeight: 4,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 28),
                      tickMarkShape: RoundSliderTickMarkShape(),
                      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                      valueIndicatorTextStyle: TextStyle(color: Colors.white),
                    ),
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
                IconButton(
                  onPressed: history.canRedo ? () => _updateList(() => history.redo()) : null,
                  icon: Icon(Icons.redo),
                ),
                const SizedBox(width: 96), // leave room for FAB
              ],
            )
          : SizedBox(),
    );
  }
}
