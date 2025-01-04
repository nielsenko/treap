// Copyright 2021 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:math';

import 'package:meta/meta.dart';

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
@immutable
class Treap<T> {
  final Node<T>? _root;

  /// The [Comparator] used to determine element order.
  ///
  /// Defaults to [Comparable.compare].
  final Comparator<T> compare;

  const Treap._(this._root, this.compare);

  /// The empty [Treap] for a given [compare] function.
  const Treap([Comparator<T>? compare])
      : this._(null, compare ?? Comparable.compare as Comparator<T>);

  /// Build a treap containing the [items].
  ///
  /// Constructs the treap by folding [add] over the [items], adding each one
  /// to the treap in turn.
  ///
  /// This method is `O(N log(N))` in complexity. An `O(N)` algorithm exists if the
  /// items are sorted. However, this works in all cases.
  factory Treap.of(Iterable<T> items, [Comparator<T>? comparator]) =>
      Treap(comparator).addAll(items);

  /// Create a copy of this treap.
  Treap<T> copy() => _new(_root?.copy());

  Treap<T> _new(Node<T>? root) => root == _root ? this : Treap._(root, compare);

  /// Adds an [item].
  ///
  /// If the [item] is already present in the treap, the original treap is returned.
  /// Otherwise, a new treap is returned with the item added.
  Treap<T> add(T item) {
    final (:root, :old) = _root.upsert(_createNode(item), compare);
    return old == null ? _new(root) : this;
  }

  /// Adds or updates an [item].
  ///
  /// Returns a new treap, with [item] either added or updated.
  Treap<T> addOrUpdate(T item) {
    final (:root, :old) = _root.upsert(_createNode(item), compare);
    return _new(root);
  }

  Node<T> _createNode(T item) => PersistentNode<T>(item, _rnd.nextInt(1 << 32));

  /// Adds a range of [items].
  ///
  /// Returns a new treap with the added [items]. If all the [items] are already
  /// present, the original treap is returned.
  Treap<T> addAll(Iterable<T> items) =>
      items.fold(this, (acc, i) => acc.add(i));

  /// Erases an [item] from the treap, if it exists.
  ///
  /// Returns a new treap without the erased [item]. If the [item] was not present,
  /// the original treap is returned.
  Treap<T> erase(T item) {
    final (:root, :old) = _root.erase(item, compare);
    return old != null ? _new(root) : this;
  }

  /// Whether this treap is empty.
  bool get isEmpty => _root == null;

  /// The size of this treap.
  int get size => _root.size;

  /// Finds the [item] in this treap.
  ///
  /// Returns the [T] in the treap, if any, that orders together with [item] by [compare].
  /// Otherwise returns `null`.
  T? find(T item) => _root.find(item, compare)?.item;

  /// Whether an[item] exists in this treap.
  bool has(T item) => find(item) != null;

  /// The rank of an [item].
  ///
  /// For an [item] in this treap, the rank is the index of the item. For an item not
  /// in this treap, the rank is the index it would be at, if it was added.
  int rank(T item) => _root.rank(item, compare);

  /// Selects an item in this treap by its [index].
  T select(int index) => _root.select(index).item;

  /// The values in this treap ordered by the [compare].
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
  Treap<T> take(int n) {
    if (n == 0) return Treap(compare); // empty;
    if (n >= size) return this;
    return _new(_root.split(_root.select(n).item, compare).low);
  }

  /// Skips the first [n] items and returns a new treap with the remaining items.
  ///
  /// Returns an empty treap, if [n] is greater than or equal to the [size] of this
  /// treap.
  Treap<T> skip(int n) {
    if (n == 0) return this;
    if (n >= size) return Treap(compare); // empty
    return _new(_root.split(_root.select(n - 1).item, compare).high);
  }

  /// Returns a new treap that is the union of this treap and the [other] treap.
  Treap<T> union(Treap<T> other) => _new(_root.union(other._root, compare));

  /// Returns a new treap that is the intersection of this treap and the [other] treap.
  Treap<T> intersection(Treap<T> other) =>
      _new(_root.intersection(other._root, compare));

  /// Returns a new treap that is the difference of this treap minus the [other] treap.
  Treap<T> difference(Treap<T> other) =>
      _new(_root.difference(other._root, compare));

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

class MutableTreap<T> {}
