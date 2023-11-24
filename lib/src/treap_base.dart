import 'dart:math';

import 'node.dart';

final _rnd = Random(42);

/// A [fully persistent](https://en.wikipedia.org/wiki/Persistent_data_structure)
/// (immutable) implementation of a [Treap](https://en.wikipedia.org/wiki/Treap).
///
/// A treap is a type of binary search tree. Each node in the tree is assigned a
/// uniformly distributed priority, either randomly or by a strong hash.
///
/// Nodes in the tree are kept heap-ordered wrt. their priority. This ensures that
/// the shape of the tree is a random variable with the same probability distribution
/// as a random binary tree. Hence the name treap, which is a portmanteau of tree
/// and heap.
///
/// In particular (with high probability), given a treap with `N` keys, the height
/// is `O(log(N))`, so that [find], [add], [erase], etc. also takes `O(log(N))` time
/// to perform.
///
/// This particular implementation is made [persistent](https://en.wikipedia.org/wiki/Persistent_data_structure),
/// by means of path copying.
///
/// Both [add] and [erase] has a space complexity of `O(log(N))`, due to path copying,
/// but erased nodes can later be reclaimed by the garbage collector, if the old
/// treaps containing them becomes eligible for reaping.
class Treap<T extends Comparable<T>> {
  final Node<T>? _root;

  /// The [Comparator] used to determine element order.
  ///
  /// Defaults to [Comparable.compare].
  final Comparator<T> comparator;

  const Treap._(this._root, this.comparator);

  /// The empty [Treap] for a given [comparator].
  const Treap([Comparator<T>? comparator])
      : this._(null, comparator ?? Comparable.compare);

  /// Build a treap containing the [items].
  ///
  /// Constructs the treap by folding [add] over the [items], adding each one
  /// to the treap in turn.
  ///
  /// This method is `O(N log(N))` in complexity. An `O(N)` algorithm exists if the
  /// items are sorted. However, this works in all cases.
  factory Treap.of(Iterable<T> items, [Comparator<T>? comparator]) =>
      items.fold(Treap(comparator), (acc, i) => acc.add(i));

  /// Adds an [item].
  ///
  /// Creates a new node with the [item] and a random priority. Returns a new treap
  /// with the added node.
  Treap<T> add(T item) =>
      Treap<T>._(_root.add(Node<T>(item, _rnd.nextInt(1 << 32))), comparator);

  /// Adds a range of [items].
  ///
  /// Returns a new treap with the added [items].
  Treap<T> addRange(Iterable<T> items) => union(Treap.of(items, comparator));

  /// Erases an [item] from the treap, if it exists.
  ///
  /// Returns a new treap without the erased [item].
  Treap<T> erase(T item) => Treap._(_root.erase(item), comparator);

  /// Whether this treap is empty.
  bool get isEmpty => _root == null;

  /// The size of this treap.
  int get size => _root.size;

  /// Finds the [item] in this treap.
  ///
  /// Returns the [T] in the treap, if any, that orders together with [item] by [comparator].
  /// Otherwise returns `null`.
  T? find(T item) => _root.find(item)?.item;

  /// Whether an[item] exists in this treap.
  ///
  /// Returns `true` if `find` re
  bool has(T item) => find(item) != null;

  /// The rank of an [item].
  ///
  /// For an [item] in this treap, the rank is the index of the item. For an item not
  /// in this treap, the rank is the index it would be at, if it was added.
  int rank(T item) => _root.rank(item);

  /// Selects an item in this treap by its [index].
  T select(int index) => _root.select(index).item;

  /// The values in this treap ordered by the [comparator].
  Iterable<T> get values => _root.values;

  /// The first item in this treap, or `null` if it is empty.
  T? get firstOrDefault => _root?.min;

  /// The last item in this treap, or `null` if it is empty.
  T? get lastOrDefault => _root?.max;

  /// The first item in this treap.
  ///
  /// Throws a [StateError] if it is empty.
  T get first => firstOrDefault ?? (throw StateError('No element'));

  /// The last item in this treap.
  ///
  /// Throws a [StateError] if it is empty.
  T get last => lastOrDefault ?? (throw StateError('No element'));

  /// The item preceding a given [item] in this treap.
  ///
  /// Throws a [RangeError] if no such item exists. Note that [item] need not be
  /// contained this treap.
  T prev(T item) => _root.select(rank(item) - 1).item;

  /// Returns the next item in the treap for a given [item].
  ///
  /// [item] need not be contained this treap.
  /// Throws a [RangeError] if no such item exists.
  T next(T item) => _root.select(rank(item) + 1).item;

  /// Returns a new treap with the first [n] items.
  ///
  /// Returns the original treap, if [n] is greater than the [size] of this treap.
  Treap<T> take(int n) => n < size
      ? Treap._(_root.split(_root.select(n).item).low, comparator)
      : this;

  /// Skips the first [n] items and returns a new treap with the remaining items.
  ///
  /// Returns an empty treap, if [n] is greater than or equal to the [size] of this
  /// treap.
  Treap<T> skip(int n) {
    if (n >= size) return Treap(comparator); // empty
    final split = _root.split(_root.select(n).item);
    return Treap._(split.high.union(split.middle), comparator);
  }

  /// Returns a new treap that is the union of this treap and the [other] treap.
  Treap<T> union(Treap<T> other) =>
      Treap._(_root.union(other._root), comparator);

  /// Returns a new treap that is the intersection of this treap and the [other] treap.
  Treap<T> intersection(Treap<T> other) =>
      Treap._(_root.intersection(other._root), comparator);

  /// Returns a new treap that is the difference of this treap minus the [other] treap.
  Treap<T> difference(Treap<T> other) =>
      Treap._(_root.difference(other._root), comparator);

  /// Operator overload for [add]ing an [item] to the treap.
  Treap<T> operator +(T item) => add(item);

  /// Operator overload for the [union] of two treaps.
  Treap<T> operator |(Treap<T> other) => union(other);

  /// Operator overload for the [intersection] of two treaps.
  Treap<T> operator &(Treap<T> other) => intersection(other);

  /// Operator overload for the [difference] of two treaps.
  Treap<T> operator -(Treap<T> other) => difference(other);

  /// Operator overload for [select]ing an item in the treap by its [index].
  T operator [](int index) => select(index);
}
