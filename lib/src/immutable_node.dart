// Copyright 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:meta/meta.dart';

import 'node.dart';

@immutable
final class ImmutableNode<T> implements Node<T, ImmutableNode<T>> {
  @override
  final T item;
  @override
  final int priority;
  @override
  final int size;
  @override
  final ImmutableNode<T>? left, right;

  ImmutableNode(this.item, this.priority, {this.left, this.right})
      : size = 1 + left.size + right.size;

  /// Create a copy with the left child set to [left].
  @pragma('vm:prefer-inline')
  @override
  ImmutableNode<T> withLeft(ImmutableNode<T>? left) =>
      ImmutableNode(item, priority, left: left, right: right);

  /// Create a copy with the right child set to [right].
  @pragma('vm:prefer-inline')
  @override
  ImmutableNode<T> withRight(ImmutableNode<T>? right) =>
      ImmutableNode(item, priority, left: left, right: right);

  /// Create a copy with the item set to [item].
  @pragma('vm:prefer-inline')
  @override
  ImmutableNode<T> withItem(T item) =>
      ImmutableNode(item, priority, left: left, right: right);

  /// Create a copy of this node.
  @pragma('vm:prefer-inline')
  @override
  ImmutableNode<T> copy() => this; // immutable
}
