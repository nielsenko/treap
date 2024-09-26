// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'node.dart';

final class MutableNode<T> implements Node<T, MutableNode<T>> {
  @override
  T item;
  @override
  final int priority;
  @override
  int size = -1;
  @override
  MutableNode<T>? left, right;

  MutableNode(this.item, this.priority, {this.left, this.right}) {
    _updateSize();
  }

  void _updateSize() {
    size = 1 + left.size + right.size;
  }

  /// Update the left child to [left].
  @pragma('vm:prefer-inline')
  @override
  MutableNode<T> withLeft(MutableNode<T>? left) {
    this.left = left;
    _updateSize();
    return this;
  }

  /// Update the right child to [right].
  @pragma('vm:prefer-inline')
  @override
  MutableNode<T> withRight(MutableNode<T>? right) {
    this.right = right;
    _updateSize();
    return this;
  }

  /// Create a copy with the item set to [item].
  @pragma('vm:prefer-inline')
  @override
  MutableNode<T> withItem(T item) {
    this.item = item;
    return this;
  }

  /// Create a copy of this node.
  @override
  MutableNode<T> copy() =>
      MutableNode(item, priority, left: left?.copy(), right: right?.copy());
}
