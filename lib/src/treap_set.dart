import 'dart:collection';

import 'treap_base.dart';

class TreapSet<T extends Comparable<T>> extends SetBase<T> {
  Treap<T> _root;

  TreapSet._(this._root);

  TreapSet([Comparator<T> comparator = Comparable.compare])
      : _root = Treap<T>(comparator);

  @override
  bool add(T value) {
    final oldRoot = _root;
    _root = _root.add(value);
    return _root.size != oldRoot.size; // grew
  }

  @override
  bool contains(Object? element) => lookup(element) != null;

  @override
  Iterator<T> get iterator => _root.values.iterator;

  @override
  int get length => _root.size;

  @override
  T? lookup(Object? element) => _root.find(element as T);

  @override
  bool remove(Object? value) {
    final oldRoot = _root;
    _root = _root.erase(value as T);
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
}
