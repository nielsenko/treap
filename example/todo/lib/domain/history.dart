import 'todo_list.dart';

typedef Command = TodoList Function(TodoList);

/// Manages the undo/redo history for a [TodoList].
class History {
  /// The list of [TodoList] states, representing the history.
  final List<TodoList> _history = [TodoList()];

  int _current = 0;

  /// Whether a "redo" operation is possible.
  bool get canRedo => _current < _history.length - 1;

  /// Whether an "undo" operation is possible.
  bool get canUndo => _current > 0;

  /// The index of the current state in the history list.
  int get current => _current;

  /// Sets the current state index, clamping it to valid bounds.
  set current(int value) {
    value = value.clamp(0, _history.length - 1);
    if (_current != value) {
      _current = value;
    }
  }

  /// The current [TodoList] state based on the [current] index.
  TodoList get currentList => _history[current];

  /// Provides read-only access to the list of historical states.
  List<TodoList> get history => List.unmodifiable(_history);

  /// Applies a [command] to the current list state, creating a new state.
  ///
  /// This clears any future states (redo history).
  void change(Command command) {
    // Clear redo history if we branch off
    if (canRedo) {
      _history.removeRange(current + 1, _history.length);
    }
    _history.add(command(_history[current]));
    current = _history.length - 1; // Move to the new state
  }

  /// Moves to the next state in the history (redo).
  /// Does nothing if [canRedo] is false.
  void redo() {
    if (canRedo) {
      current++; // Use setter for bounds check
    }
  }

  /// Moves to the previous state in the history (undo).
  /// Does nothing if [canUndo] is false.
  void undo() {
    if (canUndo) {
      current--; // Use setter for bounds check
    }
  }
}
