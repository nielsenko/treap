// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';
import 'dart:math';

import 'immutable_node.dart';
import 'node.dart';
import 'node.dart' as node;

typedef _Node<T> = ImmutableNode<T>;
final _rnd = Random();
_Node<T> _createNode<T>(T item) => _Node<T>(item, _rnd.nextInt(1 << 31));

class TreapSet<T> extends SetBase<T> {
  _Node<T>? _root;
  final NodeContext<T, _Node<T>> _ctx;

  TreapSet._(this._root, this._ctx);

  TreapSet([Comparator<T>? compare])
      : this._(
          null,
          NodeContext(
            compare ?? Comparable.compare as Comparator<T>,
            _createNode,
          ),
        );

  factory TreapSet.of(Iterable<T> items, [Comparator<T>? compare]) =>
      TreapSet(compare)..addAll(items);

  @override
  bool add(T value) {
    final oldSize = _root.size;
    _root = upsert(_root, value, false, _ctx);
    return _root.size != oldSize; // grew
  }

  @override
  void addAll(Iterable<T> elements) =>
      _root = elements.fold(_root, (acc, e) => upsert(acc, e, false, _ctx));

  @override
  bool contains(covariant T element) => lookup(element) != null;

  @override
  Iterator<T> get iterator => _root.inOrder().map((n) => n.item).iterator;

  @override
  int get length => _root.size;

  @override
  T? lookup(covariant T element) => find(_root, element, _ctx)?.item;

  @override
  bool remove(covariant T value) {
    final oldSize = _root.size;
    _root = erase(_root, value, _ctx);
    return _root.size != oldSize; // shrunk
  }

  @override
  TreapSet<T> toSet() => TreapSet._(_root?.copy(), _ctx);

  @override
  TreapSet<T> intersection(covariant TreapSet<T> other) =>
      TreapSet._(node.intersection(_root, other._root, _ctx), _ctx);

  @override
  TreapSet<T> difference(covariant TreapSet<T> other) =>
      TreapSet._(node.difference(_root, other._root, _ctx), _ctx);

  @override
  TreapSet<T> union(covariant TreapSet<T> other) =>
      TreapSet._(node.union(_root, other._root, _ctx), _ctx);

  @override
  void clear() => _root = null;

  @override
  T elementAt(int index) => select(_root, index, _ctx).item;

  @override
  T get first => _root.first.item;

  @override
  bool get isEmpty => _root == null;

  @override
  T get last => _root.last.item;

  @override
  TreapSet<T> skip(int n) => TreapSet._(node.skip(_root, n, _ctx), _ctx);

  int _countWhile(bool Function(T value) test) {
    int count = 0;
    for (final value in this) {
      if (!test(value)) break;
      count++;
    }
    return count;
  }

  @override
  TreapSet<T> skipWhile(bool Function(T value) test) => skip(_countWhile(test));

  @override
  TreapSet<T> take(int n) => TreapSet._(node.take(_root, n, _ctx), _ctx);

  @override
  TreapSet<T> takeWhile(bool Function(T value) test) => take(_countWhile(test));
}
