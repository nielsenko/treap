import 'dart:math';

import 'node.dart';

final _rnd = Random(42);

class Treap<T extends Comparable<T>> {
  final Node<T>? _root;

  const Treap._(this._root);
  const Treap() : this._(null);

  // TODO: This is O(N log(N))! An O(N) algorithm exists, if items are sorted.
  // The advantage is, this is simpler, and it works even in the unsorted case.
  factory Treap.build(Iterable<T> items) =>
      items.fold(Treap(), (acc, i) => acc.add(i));

  Treap<T> add(T item) =>
      Treap<T>._(_root.add(Node<T>(item, _rnd.nextInt(1 << 32))));

  Treap<T> erase(T item) => Treap._(_root.erase(item));

  bool get isEmpty => _root == null;

  int get size => _root.size;

  T? find(T item) => _root.find(item)?.item;
  bool has(T item) => find(item) != null;

  int rank(T item) => _root.rank(item);

  T select(int rank) => _root.select(rank).item;

  Iterable<T> get values => _root.values;

  T? get firstOrDefault => _root?.min;
  T? get lastOrDefault => _root?.max;

  T get first => firstOrDefault ?? (throw StateError('No element'));
  T get last => lastOrDefault ?? (throw StateError('No element'));

  T prev(T item) => _root.select(rank(item) - 1).item;
  T next(T item) => _root.select(rank(item) + 1).item;

  Treap<T> take(int n) =>
      n < size ? Treap._(_root.split(_root.select(n).item).low) : this;
  Treap<T> skip(int n) {
    if (n >= size) return Treap(); // empty
    final split = _root.split(_root.select(n).item);
    return Treap._(split.high.union(split.middle));
  }

  Treap<T> union(Treap<T> other) => Treap._(_root.union(other._root));
  Treap<T> intersection(Treap<T> other) =>
      Treap._(_root.intersection(other._root));
  Treap<T> difference(Treap<T> other) => Treap._(_root.difference(other._root));

  Treap<T> operator +(T item) => add(item);
  Treap<T> operator |(Treap<T> other) => union(other);
  Treap<T> operator &(Treap<T> other) => intersection(other);
  Treap<T> operator -(Treap<T> other) => difference(other);
  T operator [](int i) => select(i);
}
