// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';

import 'package:treap/src/deeply_immutable_node.dart';

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

abstract final class Hash {
  @pragma('vm:prefer-inline')
  static int combine(int hash, int value) {
    hash ^= value + 0x9e3779b97f4a7c15;
    hash = (hash ^ (hash >> 30)) * 0xbf58476d1ce4e5b9;
    hash = (hash ^ (hash >> 27)) * 0x94d049bb133111eb;
    return hash;
  }

  @pragma('vm:prefer-inline')
  static int finish(int hash) {
    hash ^= hash >> 33;
    hash *= 0xff51afd7ed558ccd;
    hash ^= hash >> 33;
    hash *= 0xc4ceb9fe1a85ec53;
    hash ^= hash >> 33;
    return hash;
  }

  static int hash(int v1, int seed) {
    int hash = seed;
    hash = combine(hash, v1);
    return finish(hash);
  }

  static int hash2(int v1, int v2, int seed) {
    int hash = seed;
    hash = combine(hash, v1);
    hash = combine(hash, v2);
    return finish(hash);
  }

  static int foo(int key) {
    key = (~key + (key << 21)) & 0xFFFFFFFFFFFFFFFF;
    key = key ^ (key >> 33);
    key = ((key + (key << 3)) + (key << 8)) & 0xFFFFFFFFFFFFFFFF;
    key = key ^ (key >> 29);
    key = ((key + (key << 2)) + (key << 4)) & 0xFFFFFFFFFFFFFFFF;
    key = key ^ (key >> 47);
    return key;
  }

  // add more as needed ..
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
