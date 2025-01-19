// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';

import 'immutable_node.dart';
import 'node.dart';
import 'node.dart' as node;

class TreapSetBase<T, NodeT extends Node<T, NodeT>> extends SetBase<T> {
  NodeT? _root;
  final NodeT Function(T) _createNode;
  final Comparator<T> compare;

  TreapSetBase._(this._root, this._createNode, this.compare);

  TreapSetBase.empty(NodeT Function(T) createNode, [Comparator<T>? compare])
      : this._(
          null,
          createNode,
          compare ?? Comparable.compare as Comparator<T>,
        );

  factory TreapSetBase.of(
    Iterable<T> items,
    NodeT Function(T) createNode, [
    Comparator<T>? compare,
  ]) =>
      TreapSetBase.empty(createNode, compare)..addAll(items);

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

  @override
  Iterator<T> get iterator => _root.inOrder().map((n) => n.item).iterator;

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

  @override
  TreapSetBase<T, NodeT> toSet() =>
      TreapSetBase._(_root?.copy(), _createNode, compare);

  TreapSetBase<T, NodeT> _new(NodeT? root) => identical(root, _root)
      ? this
      : TreapSetBase._(root, _createNode, compare);

  @override
  TreapSetBase<T, NodeT> union(covariant TreapSetBase<T, NodeT> other) =>
      _new(node.union(_root, other._root, compare));

  @override
  TreapSetBase<T, NodeT> intersection(covariant TreapSetBase<T, NodeT> other) =>
      _new(node.intersection(_root, other._root, compare));

  @override
  TreapSetBase<T, NodeT> difference(covariant TreapSetBase<T, NodeT> other) =>
      _new(node.difference(_root, other._root, compare));

  @override
  void clear() => _root = null;

  @override
  T elementAt(int index) => select(_root, index).item;

  @override
  T get first => _root.first.item;

  @override
  bool get isEmpty => _root == null;

  @override
  T get last => _root.last.item;

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

  @override
  TreapSetBase<T, NodeT> skipWhile(bool Function(T value) test) =>
      skip(_countWhile(test));

  @override
  TreapSetBase<T, NodeT> take(int n) => _new(node.take(_root, n, compare));

  @override
  TreapSetBase<T, NodeT> takeWhile(bool Function(T value) test) =>
      take(_countWhile(test));
}

extension type TreapSet<T>._(TreapSetBase<T, ImmutableNode<T>> base)
    implements TreapSetBase<T, ImmutableNode<T>> {
  TreapSet.of(Iterable<T> items, [Comparator<T>? compare])
      : base = TreapSetBase.of(
          items,
          immutableNodeFactory,
          compare,
        );

  TreapSet([Comparator<T>? compare])
      : base = TreapSetBase.empty(immutableNodeFactory, compare);

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
