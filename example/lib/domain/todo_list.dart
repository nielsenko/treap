import 'package:treap/treap.dart';

import 'task.dart';

class TodoList {
  final Treap<Task> all;
  final Treap<Task> uncompleted;

  const TodoList._(this.all, this.uncompleted);
  TodoList() : this._(Treap<Task>(), Treap<Task>());

  TodoList addOrUpdate(Task t) {
    return TodoList._(
        all.add(t), t.completed ? uncompleted.remove(t) : uncompleted.add(t));
  }

  TodoList remove(Task t) {
    return TodoList._(all.remove(t), uncompleted.remove(t));
  }
}
