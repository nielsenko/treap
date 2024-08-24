import 'dart:collection';

import 'treap_base.dart';

class TreapSet<T> extends SetBase<T> {
  Treap<T> _root;

  TreapSet._(this._root);

  TreapSet([Comparator<T>? compare]) : _root = Treap<T>(compare);

  @override
  bool add(T value) {
    final oldRoot = _root;
    _root = _root.add(value);
    return _root.size != oldRoot.size; // grew
  }

  @override
  bool contains(covariant T element) => lookup(element) != null;

  @override
  Iterator<T> get iterator => _root.values.iterator;

  @override
  int get length => _root.size;

  @override
  T? lookup(covariant T element) => _root.find(element);

  @override
  bool remove(covariant T value) {
    final oldRoot = _root;
    _root = _root.erase(value);
    return _root.size != oldRoot.size; // shrunk
  }

  @override
  TreapSet<T> toSet() => TreapSet._(_root);

  @override
  TreapSet<T> intersection(covariant TreapSet<T> other) =>
      TreapSet._(_root.intersection(other._root));

  @override
  TreapSet<T> difference(covariant TreapSet<T> other) =>
      TreapSet._(_root.difference(other._root));

  @override
  TreapSet<T> union(covariant TreapSet<T> other) =>
      TreapSet._(_root.union(other._root));

  @override
  void clear() => _root = Treap(_root.compare);

  @override
  T elementAt(int index) => _root.select(index);

  @override
  T get first => _root.first;

  @override
  bool get isEmpty => _root.isEmpty;

  @override
  T get last => _root.last;

  @override
  TreapSet<T> skip(int n) => TreapSet._(_root.skip(n));

  int _countWhile(bool Function(T value) test) {
    int count = 0;
    for (final value in _root.values) {
      if (!test(value)) break;
      count++;
    }
    return count;
  }

  @override
  TreapSet<T> skipWhile(bool Function(T value) test) => skip(_countWhile(test));

  @override
  TreapSet<T> take(int n) => TreapSet._(_root.take(n));

  @override
  TreapSet<T> takeWhile(bool Function(T value) test) => take(_countWhile(test));
}
