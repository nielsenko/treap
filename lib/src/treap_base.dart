import 'dart:math';

import 'node.dart';

final _rnd = Random(42);

/// Treap class
/// A treap is a type of binary search tree data structure that maintains a dynamic
/// set of ordered keys and allows binary search tree operations in addition to operations
/// like add, find, and erase in O(log n) time. The name 'Treap' is a portmanteau
/// of tree and heap, as the tree maintains its shape using heap properties.
class Treap<T extends Comparable<T>> {
  final Node<T>? _root;

  const Treap._(this._root);
  const Treap() : this._(null);

  /// The build method takes an iterable of items and constructs a treap from them.
  /// It does this by folding over the items, adding each one to the treap in turn.
  /// This method is O(N log(N)) in complexity. An O(N) algorithm exists if the items
  /// are sorted. However, this method is simpler and works even if the items are not
  /// sorted.
  factory Treap.build(Iterable<T> items) =>
      items.fold(Treap(), (acc, i) => acc.add(i));

  /// Adds an item to the treap. Creates a new node with the item and a random priority.
  /// The new node is then added to the root of the treap. Returns a new treap with the
  /// added node.
  Treap<T> add(T item) =>
      Treap<T>._(_root.add(Node<T>(item, _rnd.nextInt(1 << 32))));

  /// Erases an item from the treap. Returns a new treap without the erased item.
  Treap<T> erase(T item) => Treap._(_root.erase(item));

  /// Checks if the treap is empty. Returns true if the treap is empty, false otherwise.
  bool get isEmpty => _root == null;

  /// Returns the size of the treap.
  int get size => _root.size;

  /// Finds an item in the treap. Returns the item if found, null otherwise.
  T? find(T item) => _root.find(item)?.item;

  /// Checks if an item exists in the treap. Returns true if the item exists, false
  /// otherwise.
  bool has(T item) => find(item) != null;

  /// Returns the rank of an item in the treap.
  int rank(T item) => _root.rank(item);

  /// Selects an item in the treap by its rank. Returns the selected item.
  T select(int rank) => _root.select(rank).item;

  /// Returns all the values in the treap.
  Iterable<T> get values => _root.values;

  /// Returns the first item in the treap, or null if the treap is empty.
  T? get firstOrDefault => _root?.min;

  /// Returns the last item in the treap, or null if the treap is empty.
  T? get lastOrDefault => _root?.max;

  /// Returns the first item in the treap. Throws an error if the treap is empty.
  T get first => firstOrDefault ?? (throw StateError('No element'));

  /// Returns the last item in the treap. Throws an error if the treap is empty.
  T get last => lastOrDefault ?? (throw StateError('No element'));

  /// Returns the previous item in the treap for a given item.
  T prev(T item) => _root.select(rank(item) - 1).item;

  /// Returns the next item in the treap for a given item.
  T next(T item) => _root.select(rank(item) + 1).item;

  /// Returns a new treap with the first n items. If n is greater than the size of
  /// the treap, returns the original treap.
  Treap<T> take(int n) =>
      n < size ? Treap._(_root.split(_root.select(n).item).low) : this;

  /// Skips the first n items and returns a new treap with the remaining items.
  /// If n is greater than or equal to the size of the treap, returns an empty treap.
  Treap<T> skip(int n) {
    if (n >= size) return Treap(); // empty
    final split = _root.split(_root.select(n).item);
    return Treap._(split.high.union(split.middle));
  }

  /// Returns a new treap that is the union of this treap and another treap.
  Treap<T> union(Treap<T> other) => Treap._(_root.union(other._root));

  /// Returns a new treap that is the intersection of this treap and another treap.
  Treap<T> intersection(Treap<T> other) =>
      Treap._(_root.intersection(other._root));

  /// Returns a new treap that is the difference of this treap and another treap.
  Treap<T> difference(Treap<T> other) => Treap._(_root.difference(other._root));

  /// Operator overloading for adding an item to the treap. Returns a new treap with
  /// the added item.
  Treap<T> operator +(T item) => add(item);

  /// Operator overloading for the union of this treap and another treap.
  /// Returns a new treap that is the union of the two treaps.
  Treap<T> operator |(Treap<T> other) => union(other);

  /// Operator overloading for the intersection of this treap and another treap.
  /// Returns a new treap that is the intersection of the two treaps.
  Treap<T> operator &(Treap<T> other) => intersection(other);

  /// Operator overloading for the difference of this treap and another treap.
  /// Returns a new treap that is the difference of the two treaps.
  Treap<T> operator -(Treap<T> other) => difference(other);

  /// Operator overloading for selecting an item in the treap by its rank.
  /// Returns the selected item.
  T operator [](int i) => select(i);
}
