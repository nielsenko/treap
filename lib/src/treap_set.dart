// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';

import 'package:treap/src/deeply_immutable_node.dart';

import 'immutable_node.dart';
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

/// A persistent set implementation based on a Treap.
///
/// Uses immutable nodes.
extension type TreapSet<T>._(TreapSetBase<T, ImmutableNode<T>> base)
    implements TreapSetBase<T, ImmutableNode<T>> {
  /// Creates a [TreapSet] containing the [items].
  ///
  /// If [compare] is not provided, defaults to [Comparable.compare].
  TreapSet.of(Iterable<T> items, [Comparator<T>? compare])
      : base = TreapSetBase.of(
          items,
          immutableNodeFactory,
          compare,
        );

  /// Creates an empty [TreapSet].
  ///
  /// If [compare] is not provided, defaults to [Comparable.compare].
  TreapSet([Comparator<T>? compare])
      : base = TreapSetBase(immutableNodeFactory, compare);

  TreapSet<T> union(TreapSet<T> other) => TreapSet<T>._(base.union(other.base));

  TreapSet<T> intersection(TreapSet<T> other) =>
      TreapSet<T>._(base.intersection(other.base));

  TreapSet<T> difference(TreapSet<T> other) =>
      TreapSet<T>._(base.difference(other.base));

  TreapSet<T> take(int count) => TreapSet<T>._(base.take(count));

  TreapSet<T> takeWhile(bool Function(T value) test) =>
      TreapSet<T>._(base.takeWhile(test));

  TreapSet<T> skip(int count) => TreapSet<T>._(base.skip(count));

  TreapSet<T> skipWhile(bool Function(T value) test) =>
      TreapSet<T>._(base.skipWhile(test));

  TreapSet<T> toSet() => TreapSet<T>._(base.toSet());
}

extension type TreapIntSet._(TreapSetBase<int, IntNode> base)
    implements TreapSetBase<int, IntNode> {
  TreapIntSet.of(Iterable<int> items, [Comparator<int>? compare])
      : base = TreapSetBase.of(
          items,
          intNodeFactory,
          compare ?? (a, b) => a - b,
        );

  TreapIntSet() : this.of(<int>[]);

  TreapIntSet union(TreapIntSet other) => TreapIntSet._(base.union(other.base));
  TreapIntSet intersection(TreapIntSet other) =>
      TreapIntSet._(base.intersection(other.base));
  TreapIntSet difference(TreapIntSet other) =>
      TreapIntSet._(base.difference(other.base));

  TreapIntSet take(int count) => TreapIntSet._(base.take(count));
  TreapIntSet takeWhile(bool Function(int value) test) =>
      TreapIntSet._(base.takeWhile(test));
  TreapIntSet skip(int count) => TreapIntSet._(base.skip(count));
  TreapIntSet skipWhile(bool Function(int value) test) =>
      TreapIntSet._(base.skipWhile(test));

  TreapIntSet toSet() => TreapIntSet._(base.toSet());
}

extension type TreapStringSet._(TreapSetBase<String, StringNode> base)
    implements TreapSetBase<String, StringNode> {
  TreapStringSet.of(Iterable<String> items, [Comparator<String>? compare])
      : base = TreapSetBase.of(
          items,
          stringNodeFactory,
          compare,
        );

  TreapStringSet() : this.of(<String>[]);

  TreapStringSet union(TreapStringSet other) =>
      TreapStringSet._(base.union(other.base));
  TreapStringSet intersection(TreapStringSet other) =>
      TreapStringSet._(base.intersection(other.base));
  TreapStringSet difference(TreapStringSet other) =>
      TreapStringSet._(base.difference(other.base));

  TreapStringSet take(int count) => TreapStringSet._(base.take(count));
  TreapStringSet takeWhile(bool Function(String value) test) =>
      TreapStringSet._(base.takeWhile(test));
  TreapStringSet skip(int count) => TreapStringSet._(base.skip(count));
  TreapStringSet skipWhile(bool Function(String value) test) =>
      TreapStringSet._(base.skipWhile(test));

  TreapStringSet toSet() => TreapStringSet._(base.toSet());
}

extension type TreapDoubleSet._(TreapSetBase<double, DoubleNode> base)
    implements TreapSetBase<double, DoubleNode> {
  TreapDoubleSet.of(Iterable<double> items, [Comparator<double>? compare])
      : base = TreapSetBase.of(
          items,
          doubleNodeFactory,
          compare,
        );

  TreapDoubleSet() : this.of(<double>[]);

  TreapDoubleSet union(TreapDoubleSet other) =>
      TreapDoubleSet._(base.union(other.base));
  TreapDoubleSet intersection(TreapDoubleSet other) =>
      TreapDoubleSet._(base.intersection(other.base));
  TreapDoubleSet difference(TreapDoubleSet other) =>
      TreapDoubleSet._(base.difference(other.base));

  TreapDoubleSet take(int count) => TreapDoubleSet._(base.take(count));
  TreapDoubleSet takeWhile(bool Function(double value) test) =>
      TreapDoubleSet._(base.takeWhile(test));
  TreapDoubleSet skip(int count) => TreapDoubleSet._(base.skip(count));
  TreapDoubleSet skipWhile(bool Function(double value) test) =>
      TreapDoubleSet._(base.skipWhile(test));

  TreapDoubleSet toSet() => TreapDoubleSet._(base.toSet());
}
