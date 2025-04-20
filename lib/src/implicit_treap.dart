// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:meta/meta.dart';

import 'immutable_node.dart';
import 'implicit_algo.dart' as n;
import 'node.dart';

@immutable
final class ImplicitTreapBase<T, NodeT extends Node<T, NodeT>> {
  final NodeT? _root;
  final NodeT Function(T) _createNode;

  const ImplicitTreapBase._(this._root, this._createNode);

  /// Creates an empty treap.
  const ImplicitTreapBase.empty(NodeT Function(T) createNode)
      : this._(null, createNode);

  /// Creates a treap from [items].
  factory ImplicitTreapBase.of(
    Iterable<T> items,
    NodeT Function(T) createNode,
  ) {
    var treap = ImplicitTreapBase<T, NodeT>.empty(createNode);
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
      identical(root, _root) ? this : ImplicitTreapBase._(root, _createNode);

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
  T operator [](int index) => select(_root, index).item;

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

  /// Returns the first item in this treap, or `null` if it is empty.
  T? get firstOrDefault => _root.firstOrNull?.item;

  /// Returns the last item in this treap, or `null` if it is empty.
  T? get lastOrDefault => _root.lastOrNull?.item;

  /// Returns the first item in this treap.
  ///
  /// Throws a [StateError] if it is empty.
  T get first => _root.first.item;

  /// Returns the last item in this treap.
  ///
  /// Throws a [StateError] if it is empty.
  T get last => _root.last.item;

  /// Iterate over the items in the treap.
  Iterable<T> get values => _root.inOrder().map((n) => n.item);
}

extension type ImplicitTreap<T>._(ImplicitTreapBase<T, ImmutableNode<T>> base)
    implements ImplicitTreapBase<T, ImmutableNode<T>> {
  ImplicitTreap.of(Iterable<T> items)
      : base = ImplicitTreapBase.of(
          items,
          immutableNodeFactory,
        );

  ImplicitTreap.empty() : base = ImplicitTreapBase.empty(immutableNodeFactory);

  ImplicitTreap<T> take(int count) => ImplicitTreap._(base.take(count));

  ImplicitTreap<T> skip(int count) => ImplicitTreap._(base.skip(count));

  ImplicitTreap<T> copy() => ImplicitTreap._(base.copy());

  ImplicitTreap<T> remove(int index) => ImplicitTreap._(base.remove(index));

  ImplicitTreap<T> insert(int index, T item) =>
      ImplicitTreap._(base.insert(index, item));

  ImplicitTreap<T> add(T item) => ImplicitTreap._(base.add(item));

  ImplicitTreap<T> append(ImplicitTreap<T> other) =>
      ImplicitTreap._(base.append(other.base));
}
