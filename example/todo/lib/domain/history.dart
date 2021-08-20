import 'todo_list.dart';

typedef Command = TodoList Function(TodoList);

class History {
  var history = [TodoList()];

  var _current = 0;
  bool get canRedo => _current < history.length - 1;
  bool get canUndo => _current > 0;

  int get current => _current;

  set current(value) {
    value = value.clamp(0, history.length - 1);
    if (_current != value) {
      _current = value;
    }
  }

  TodoList get currentList => history[current];

  void change(Command command) {
    history.removeRange(current + 1, history.length); // Redo dies
    history.add(command(history[current]));
    ++current;
  }

  void redo() => ++current;

  void undo() => --current;
}
