// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';

import 'node.dart' as node;
import 'node.dart';

/// Base class for Treap-based set implementations.
///
/// Provides a mutable set API on top of an immutable Treap.
class TreapSetBase<T, NodeT extends Node<T, NodeT>> extends SetBase<T> {
  NodeT? _root;
  final NodeT Function(T) _createNode;
  final Comparator<T> compare;

  TreapSetBase._(this._root, this._createNode, this.compare);

  /// Creates an empty [TreapSetBase].
  ///
  /// Requires a `createNode` function.
  /// If [compare] is not provided, defaults to [Comparable.compare].
  TreapSetBase(NodeT Function(T) createNode, [Comparator<T>? compare])
      : this._(
          null,
          createNode,
          compare ?? Comparable.compare as Comparator<T>,
        );

  /// Creates a [TreapSetBase] containing the [items].
  ///
  /// Requires a `createNode` function.
  /// If [compare] is not provided, defaults to [Comparable.compare].
  factory TreapSetBase.of(
    Iterable<T> items,
    NodeT Function(T) createNode, [
    Comparator<T>? compare,
  ]) =>
      TreapSetBase(createNode, compare)..addAll(items);

  @override
  bool add(T value) {
    final oldSize = _root.size;
    _root = upsert(_root, value, false, compare, _createNode);
    return _root.size != oldSize; // grew
  }

  @override
  void addAll(Iterable<T> elements) => _root = elements.fold(
      _root, (acc, e) => upsert(acc, e, false, compare, _createNode));

  @override
  bool contains(covariant T element) => lookup(element) != null;

  /// An iterator over the elements of this set in ascending order.
  @override
  Iterator<T> get iterator => _root.inOrder().map((n) => n.item).iterator;

  /// The number of elements in this set.
  @override
  int get length => _root.size;

  @override
  T? lookup(covariant T element) => find(_root, element, compare)?.item;

  @override
  bool remove(covariant T value) {
    final oldSize = _root.size;
    _root = erase(_root, value, compare);
    return _root.size != oldSize; // shrunk
  }

  /// Returns a new [TreapSetBase] with the same elements as this set.
  @override
  TreapSetBase<T, NodeT> toSet() =>
      TreapSetBase._(_root?.copy(), _createNode, compare);

  TreapSetBase<T, NodeT> _new(NodeT? root) => identical(root, _root)
      ? this
      : TreapSetBase._(root, _createNode, compare);

  /// Returns a new set which is the union of this set and [other].
  @override
  TreapSetBase<T, NodeT> union(covariant TreapSetBase<T, NodeT> other) =>
      _new(node.union(_root, other._root, compare));

  /// Returns a new set which is the intersection of this set and [other].
  @override
  TreapSetBase<T, NodeT> intersection(covariant TreapSetBase<T, NodeT> other) =>
      _new(node.intersection(_root, other._root, compare));

  /// Returns a new set with the elements of this set that are not in [other].
  @override
  TreapSetBase<T, NodeT> difference(covariant TreapSetBase<T, NodeT> other) =>
      _new(node.difference(_root, other._root, compare));

  @override
  void clear() => _root = null;

  /// Returns the element at the given [index] in the sorted iteration order.
  @override
  T elementAt(int index) => select(_root, index).item;

  /// The first element in the sorted iteration order.
  /// Throws [StateError] if the set is empty.
  @override
  T get first => _root.first.item;

  /// Whether this set is empty.
  @override
  bool get isEmpty => _root == null;

  /// The last element in the sorted iteration order.
  /// Throws [StateError] if the set is empty.
  @override
  T get last => _root.last.item;

  /// Returns a new set skipping the first [n] elements in sorted order.
  @override
  TreapSetBase<T, NodeT> skip(int n) => _new(node.skip(_root, n, compare));

  int _countWhile(bool Function(T value) test) {
    int count = 0;
    for (final value in this) {
      if (!test(value)) break;
      count++;
    }
    return count;
  }

  /// Returns a new set skipping leading elements while [test] is true.
  @override
  TreapSetBase<T, NodeT> skipWhile(bool Function(T value) test) =>
      skip(_countWhile(test));

  /// Returns a new set containing the first [n] elements in sorted order.
  @override
  TreapSetBase<T, NodeT> take(int n) => _new(node.take(_root, n, compare));

  /// Returns a new set containing the leading elements while [test] is true.
  @override
  TreapSetBase<T, NodeT> takeWhile(bool Function(T value) test) =>
      take(_countWhile(test));
}
