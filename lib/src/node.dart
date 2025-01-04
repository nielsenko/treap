// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:meta/meta.dart';

import 'split.dart';

sealed class Node<T> {
  final T item;
  final int priority;
  int get _size; // size is an extension method on Node<T>?
  Node<T>? get left;
  Node<T>? get right;

  Node(this.item, this.priority) {
    checkInvariant();
  }

  @pragma('vm:prefer-inline')
  Node<T> withLeft(Node<T>? left);

  @pragma('vm:prefer-inline')
  Node<T> withRight(Node<T>? right);

  @pragma('vm:prefer-inline')
  Node<T> withoutChildren();

  @pragma('vm:prefer-inline')
  Node<T> copy();

  /// The minimum item in the treap.
  @pragma('vm:prefer-inline')
  T get min => left == null ? item : left!.min;

  /// The maximum item in the treap.
  @pragma('vm:prefer-inline')
  T get max => right == null ? item : right!.max;

  void checkInvariant() {
    assert(() {
      final l = left;
      final r = right;
      // check heap order
      assert(l == null || l.priority <= priority);
      assert(r == null || r.priority <= priority);
      return true;
    }());
  }
}

@immutable
final class PersistentNode<T> extends Node<T> {
  @override
  final PersistentNode<T>? left, right;
  @override
  final int _size;

  PersistentNode(super.item, super.priority, {this.left, this.right})
      : _size = 1 + left.size + right.size;

  @pragma('vm:prefer-inline')
  @override
  PersistentNode<T> copy() => this; // immutable

  /// Create a copy with the left child set to [left].
  @pragma('vm:prefer-inline')
  @override
  PersistentNode<T> withLeft(covariant PersistentNode<T>? left) =>
      PersistentNode(item, priority, left: left, right: right);

  /// Create a copy with the right child set to [right].
  @pragma('vm:prefer-inline')
  @override
  PersistentNode<T> withRight(covariant PersistentNode<T>? right) =>
      PersistentNode(item, priority, left: left, right: right);

  /// Create a copy of this node without children.
  @pragma('vm:prefer-inline')
  @override
  PersistentNode<T> withoutChildren() => PersistentNode(item, priority);
}

extension NodeEx<T> on Node<T>? {
  @pragma('vm:prefer-inline')
  int get size => this?._size ?? 0;

  Split<T> split(T pivot, Comparator<T> compare) {
    final self = this; // for type promotion
    if (self == null) return const Split.empty();
    final order = compare(pivot, self.item);
    if (order < 0) {
      final s = self.left.split(pivot, compare);
      return s.withHigh(self.withLeft(s.high));
    }
    if (order > 0) {
      final s = self.right.split(pivot, compare);
      return s.withLow(self.withRight(s.low));
    }
    // order == 0
    return Split((low: self.left, middle: self, high: self.right))
      ..checkInvariant(compare);
  }

  Node<T>? join(Node<T>? other) {
    final self = this; // for type promotion
    if (self != null && other != null) {
      // two nodes - ensure heap order
      if (self.priority > other.priority) {
        return self.withRight(self.right.join(other));
      }
      return other.withLeft(self.join(other.left));
    }
    return self ?? other; // zero or one
  }

  ({Node<T> root, T? old}) upsert(Node<T> child, Comparator<T> compare) {
    final item = child.item;
    final s = split(item, compare);
    return (root: s.withMiddle(child).join()!, old: s.middle?.item);
  }

  ({Node<T>? root, T? old}) erase(T dead, Comparator<T> compare) {
    final s = split(dead, compare);
    return (root: s.withMiddle(null).join(), old: s.middle?.item);
  }

  Node<T>? union(Node<T>? other, Comparator<T> compare) {
    final self = this; // for type promotion
    if (self == null) return other; // {} | B == B
    if (other == null) return self; // A | {} == A
    final s = other.split(self.item, compare);
    return Split((
      low: self.left.union(s.low, compare),
      middle: self,
      high: self.right.union(s.high, compare)
    )).join();
  }

  Node<T>? intersection(Node<T>? other, Comparator<T> compare) {
    final self = this; // for type promotion
    if (self == null || other == null) return null; // {} & B == A & {} == {}
    final s = other.split(self.item, compare);
    return Split((
      low: self.left.intersection(s.low, compare),
      middle: s.middle,
      high: self.right.intersection(s.high, compare)
    )).join();
  }

  Node<T>? difference(Node<T>? other, Comparator<T> compare) {
    final self = this; // for type promotion
    if (self == null) return null; // {} - B == {}
    if (other == null) return self; // A - {} == A
    final s = other.split(self.item, compare);
    return Split((
      low: self.left.difference(s.low, compare),
      middle: s.middle == null ? self : null,
      high: self.right.difference(s.high, compare)
    )).join();
  }

  Node<T>? find(T item, Comparator<T> compare) {
    final self = this; // for type promotion
    if (self == null) return null;
    final order = compare(item, self.item);
    if (order < 0) return self.left.find(item, compare);
    if (order > 0) return self.right.find(item, compare);
    return this; // order == 0
  }

  int rank(T item, Comparator<T> compare) {
    final self = this; // for type promotion
    if (self == null) return 0;
    final order = compare(item, self.item);
    if (order < 0) return self.left.rank(item, compare);
    final l = self.left.size;
    if (order > 0) return l + 1 + self.right.rank(item, compare);
    return l; // order == 0
  }

  /// Throws a [RangeError] if [rank] is out of bounds
  Node<T> select(int rank) {
    final self = this; // for type promotion
    if (self == null || rank < 0 || rank >= size) {
      throw RangeError.range(rank, 0, size - 1, 'rank');
    }
    final l = self.left.size;
    if (rank < l) return self.left.select(rank);
    if (rank == l) return self;
    return self.right.select(rank - l - 1);
  }

  /// Iterate over the items in the treap in order.
  Iterable<T> get values => inOrder().map((n) => n.item);

  /// Iterates over the nodes in the treap in order.
  Iterable<Node<T>> inOrder() sync* {
    final self = this;
    if (self == null) return;
    yield* self.left.inOrder();
    yield self;
    yield* self.right.inOrder();
  }

  /// Iterates over the nodes in the treap in post-order.
  Iterable<Node<T>> postOrder() sync* {
    final self = this;
    if (self == null) return;
    yield* self.left.postOrder();
    yield* self.right.postOrder();
    yield self;
  }

  /// Iterates over the nodes in the treap in pre-order.
  Iterable<Node<T>> preOrder() sync* {
    final self = this;
    if (self == null) return;
    yield self;
    yield* self.left.preOrder();
    yield* self.right.preOrder();
  }
}
