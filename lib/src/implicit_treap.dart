// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:treap/src/node.dart';

import 'immutable_node.dart';
import 'implicit_algo.dart' as n;

final _rnd = Random();
typedef _Node<T> = ImmutableNode<T>;
_Node<T> _createNode<T>(T item) => _Node<T>(item, _rnd.nextInt(1 << 32));

@immutable
final class ImplicitTreap<T> {
  final _Node<T>? _root;

  const ImplicitTreap._(this._root);
  const ImplicitTreap.empty() : this._(null);

  int get size => _root.size;

  /// Creates a copy of this treap.
  ImplicitTreap<T> copy() => _new(_root?.copy());

  ImplicitTreap<T> _new(_Node<T>? root) =>
      identical(root, _root) ? this : ImplicitTreap._(root);

  ImplicitTreap<T> insert(int index, T item) =>
      _new(n.insert<T, _Node<T>>(_root, _createNode(item), index));

  ImplicitTreap<T> remove(int index) =>
      _new(n.erase<T, _Node<T>>(_root, index));

  T operator [](int index) => n.select<T, _Node<T>>(_root, index).item;

  ImplicitTreap<T> take(int count) {
    return _new(n.take<T, _Node<T>>(_root, count));
  }

  ImplicitTreap<T> skip(int count) {
    return _new(n.skip<T, _Node<T>>(_root, count));
  }
}
