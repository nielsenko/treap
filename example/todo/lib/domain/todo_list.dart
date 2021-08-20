import 'package:treap/treap.dart';

import 'task.dart';

class TodoList {
  final Treap<Task> all;
  final Treap<Task> uncompleted;

  const TodoList() : this._(const Treap<Task>(), const Treap<Task>());
  const TodoList._(this.all, this.uncompleted);

  TodoList addOrUpdate(Task t) {
    return TodoList._(all.add(t), t.completed ? uncompleted.erase(t) : uncompleted.add(t));
  }

  TodoList remove(Task t) {
    return TodoList._(all.erase(t), uncompleted.erase(t));
  }
}
