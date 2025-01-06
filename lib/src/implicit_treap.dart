// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:meta/meta.dart';
import 'package:treap/src/node.dart';

import 'immutable_node.dart';
import 'implicit_algo.dart' as n;

typedef _Node<T> = ImmutableNode<T>;
_Node<T> _createNode<T>(T item) => _Node<T>(item, defaultPriority(item));

@immutable
final class ImplicitTreapBase<T, NodeT extends Node<T, NodeT>> {
  final NodeT? _root;

  const ImplicitTreapBase._(this._root);

  /// Creates an empty treap.
  const ImplicitTreapBase.empty() : this._(null);

  /// Creates a treap from [items].
  factory ImplicitTreapBase.of(Iterable<T> items) {
    var treap = ImplicitTreapBase<T, NodeT>.empty();
    for (final item in items) {
      treap = treap.add(item);
    }
    return treap;
  }

  /// The number of items in the treap.
  int get size => _root.size;

  /// Creates a copy of this treap.
  ImplicitTreapBase<T, NodeT> copy() => _new(_root?.copy());

  ImplicitTreapBase<T, NodeT> _new(NodeT? root) =>
      identical(root, _root) ? this : ImplicitTreapBase._(root);

  /// Inserts [item] at [index].
  ///
  /// Throws a [RangeError] if [index] is out of bounds.
  ImplicitTreapBase<T, NodeT> insert(int index, T item) =>
      _new(n.insert(_root, _createNode(item), index));

  /// Adds [item] to the end of the treap.
  ImplicitTreapBase<T, NodeT> add(T item) =>
      _new(n.append(_root, _createNode(item)));

  /// Appends [other] to the end of this treap.
  ImplicitTreapBase<T, NodeT> append(ImplicitTreapBase<T, NodeT> other) =>
      _new(n.append(_root, other._root));

  /// Removes the item at [index].
  ImplicitTreapBase<T, NodeT> remove(int index) => _new(n.erase(_root, index));

  /// Returns the item at [index].
  T operator [](int index) => n.select(_root, index).item;

  /// Returns a new treap with the first [count] items.
  ImplicitTreapBase<T, NodeT> take(int count) {
    RangeError.checkNotNegative(count);
    return _new(n.take(_root, count));
  }

  /// Skips the first [count] items and returns a new treap with the remaining items.
  ImplicitTreapBase<T, NodeT> skip(int count) {
    RangeError.checkNotNegative(count);
    return _new(n.skip(_root, count));
  }

  /// Iterate over the items in the treap.
  Iterable<T> get values => _root.inOrder().map((n) => n.item);
}

typedef ImplicitTreap<T> = ImplicitTreapBase<T, Node<T, ImmutableNode<T>>>;
