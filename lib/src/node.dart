// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:meta/meta.dart';

final class NodeContext<T, NodeT extends Node<T, NodeT>> {
  final Comparator<T> compare;
  final NodeT Function(T) create;

  const NodeContext(this.compare, this.create);
}

sealed class Node<T, NodeT extends Node<T, NodeT>> {
  T get item;
  int get priority;
  int get size;
  NodeT? get left;
  NodeT? get right;

  NodeT withLeft(NodeT? left);
  NodeT withRight(NodeT? right);
  NodeT withItem(T item);
  NodeT copy();
}

@immutable
final class PersistentNode<T> implements Node<T, PersistentNode<T>> {
  @override
  final T item;
  @override
  final int priority;
  @override
  final int size;
  @override
  final PersistentNode<T>? left, right;

  PersistentNode(this.item, this.priority, {this.left, this.right})
      : size = 1 + left.size + right.size;

  /// Create a copy with the left child set to [left].
  @pragma('vm:prefer-inline')
  @override
  PersistentNode<T> withLeft(PersistentNode<T>? left) =>
      PersistentNode(item, priority, left: left, right: right);

  /// Create a copy with the right child set to [right].
  @pragma('vm:prefer-inline')
  @override
  PersistentNode<T> withRight(PersistentNode<T>? right) =>
      PersistentNode(item, priority, left: left, right: right);

  /// Create a copy with the item set to [item].
  @pragma('vm:prefer-inline')
  @override
  PersistentNode<T> withItem(T item) =>
      PersistentNode(item, priority, left: left, right: right);

  /// Create a copy of this node.
  @pragma('vm:prefer-inline')
  @override
  PersistentNode<T> copy() => this; // immutable
}

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

Never _noElement() => throw StateError('No element');

extension NodeEx<T, NodeT extends Node<T, NodeT>> on NodeT {
  @pragma('vm:prefer-inline')
  (NodeT?, T, NodeT?) get expose => (left, item, right);

  //     t            R
  //    / \          / \
  //   l   r   =>   T   y
  //      / \      / \
  //     x   y    l   x
  //
  /// throws if no right child exists
  @pragma('vm:prefer-inline')
  NodeT spinLeft() {
    final r = right!;
    final x = r.left;
    return r.withLeft(withRight(x));
  }

  //     t          L
  //    / \        / \
  //   l   r  =>  x   T
  //  / \            / \
  // x   y          y   r
  //
  /// throws if no left child exists
  @pragma('vm:prefer-inline')
  NodeT spinRight() {
    final l = left!;
    final y = l.right;
    return l.withRight(withLeft(y));
  }

  /// The minimum item in the treap.
  NodeT get first => left == null ? this : left!.first;

  /// The maximum item in the treap.
  NodeT get last => right == null ? this : right!.last;

  void checkInvariant() {
    assert(() {
      final l = left;
      final r = right;
      // check heap order
      assert(priority >= 0); // ensure non-negative
      assert(l == null || l.priority <= priority);
      assert(r == null || r.priority <= priority);
      return true;
    }());
  }
}

extension NullableNodeEx<T, NodeT extends Node<T, NodeT>> on NodeT? {
  @pragma('vm:prefer-inline')
  int get size => this?.size ?? 0;

  @pragma('vm:prefer-inline')
  int get priority => this?.priority ?? -1;

  @pragma('vm:prefer-inline')
  NodeT? get firstOrNull => this?.first;

  @pragma('vm:prefer-inline')
  NodeT? get lastOrNull => this?.last;

  @pragma('vm:prefer-inline')
  NodeT get first => this?.first ?? _noElement();

  @pragma('vm:prefer-inline')
  NodeT get last => this?.last ?? _noElement();

  /// Iterates over the nodes in the treap in order.
  Iterable<NodeT> inOrder() sync* {
    final self = this;
    if (self == null) return;
    yield* self.left.inOrder();
    yield self;
    yield* self.right.inOrder();
  }

  /// Iterates over the nodes in the treap in post-order.
  Iterable<NodeT> postOrder() sync* {
    final self = this;
    if (self == null) return;
    yield* self.left.postOrder();
    yield* self.right.postOrder();
    yield self;
  }

  /// Iterates over the nodes in the treap in pre-order.
  Iterable<NodeT> preOrder() sync* {
    final self = this;
    if (self == null) return;
    yield self;
    yield* self.left.preOrder();
    yield* self.right.preOrder();
  }
}

(NodeT?, T, NodeT?) expose<T, NodeT extends Node<T, NodeT>>(NodeT self) =>
    (self.left, self.item, self.right);

NodeT join<T, NodeT extends Node<T, NodeT>>(
  NodeT? low,
  NodeT middle,
  NodeT? high,
  NodeContext<T, NodeT> ctx,
) {
  assert(low == null || ctx.compare(low.last.item, middle.item) < 0);
  assert(high == null || ctx.compare(middle.item, high.first.item) < 0);
  final p = middle.priority;
  if (p > low.priority && //
      p > high.priority) {
    final (l, _, r) = middle.expose;
    if (l == low && r == high) return middle; // reuse
    return middle.withLeft(low).withRight(high);
  }
  if (low.priority > high.priority) {
    return low!.withRight(join(low.right, middle, high, ctx));
  }
  return high!.withLeft(join(low, middle, high.left, ctx));
}

(NodeT?, bool, NodeT?) split<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  T pivot,
  NodeContext<T, NodeT> ctx,
) {
  if (self == null) return const (null, false, null);
  final (l, T i, r) = self.expose;
  final order = ctx.compare(pivot, i);
  if (order < 0) {
    final (ll, b, lr) = split(l, pivot, ctx);
    return (ll, b, join(lr, self, r, ctx));
  }
  if (order > 0) {
    final (rl, b, rr) = split(r, pivot, ctx);
    return (join(l, self, rl, ctx), b, rr);
  }
  return (l, true, r);
}

(NodeT?, NodeT) splitLast<T, NodeT extends Node<T, NodeT>>(
  NodeT self,
  NodeContext<T, NodeT> ctx,
) {
  final (l, _, r) = self.expose;
  if (r == null) return (l, self);
  final (rl, last) = splitLast(r, ctx);
  return (join(l, self, rl, ctx), last);
}

NodeT? join2<T, NodeT extends Node<T, NodeT>>(
  NodeT? left,
  NodeT? right,
  NodeContext<T, NodeT> ctx,
) {
  if (left == null) return right;
  final (l, last) = splitLast(left, ctx);
  return join(l, last, right, ctx);
}

NodeT upsert<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  T item,
  bool allowUpdate,
  NodeContext<T, NodeT> ctx,
) {
  if (self == null) return ctx.create(item);
  final (l, T i, r) = self.expose;
  final order = ctx.compare(item, i);
  if (order < 0) return join(upsert(l, item, allowUpdate, ctx), self, r, ctx);
  if (order > 0) return join(l, self, upsert(r, item, allowUpdate, ctx), ctx);
  return allowUpdate ? self.withItem(item) : self;
}

NodeT? erase<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  T item,
  NodeContext<T, NodeT> ctx,
) {
  if (self == null) return null;
  final (l, T i, r) = self.expose;
  final order = ctx.compare(item, i);
  if (order < 0) return join(erase(l, item, ctx), self, r, ctx);
  if (order > 0) return join(l, self, erase(r, item, ctx), ctx);
  return join2(l, r, ctx);
}

NodeT? find<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  T item,
  NodeContext<T, NodeT> ctx,
) {
  if (self == null) return null; // {}
  final order = ctx.compare(item, self.item);
  if (order < 0) return find(self.left, item, ctx);
  if (order > 0) return find(self.right, item, ctx);
  return self; // order == 0
}

int rank<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  T item,
  NodeContext<T, NodeT> ctx,
) {
  if (self == null) return 0; // {}
  final (l, T i, r) = self.expose;
  final order = ctx.compare(item, i);
  if (order < 0) return rank(l, item, ctx);
  if (order > 0) return 1 + l.size + rank(r, item, ctx);
  return l.size; // order == 0
}

/// Throws a [RangeError] if [rank] is out of bounds
NodeT select<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int rank,
  NodeContext<T, NodeT> ctx,
) {
  final size = self.size;
  if (self == null || rank < 0 || rank >= size) {
    throw RangeError.range(rank, 0, size - 1, 'rank');
  }
  final (l, _, r) = self.expose;
  final ls = l.size;
  if (rank < ls) return select(l, rank, ctx);
  if (rank == ls) return self;
  return select(r, rank - ls - 1, ctx);
}

NodeT? union<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  NodeT? other,
  NodeContext<T, NodeT> ctx,
) {
  if (self == null) return other; // {} | B == B
  if (other == null) return self; // A | {} == A
  final (l, _, r) = split(other, self.item, ctx);
  return join(
    union(self.left, l, ctx),
    self,
    union(self.right, r, ctx),
    ctx,
  );
}

NodeT? intersection<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  NodeT? other,
  NodeContext<T, NodeT> ctx,
) {
  if (self == null || other == null) return null; // {} & B == A & {} == {}
  final (l, b, r) = split(other, self.item, ctx);
  final low = intersection(self.left, l, ctx);
  final high = intersection(self.right, r, ctx);
  return b ? join(low, self, high, ctx) : join2(low, high, ctx);
}

NodeT? difference<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  NodeT? other,
  NodeContext<T, NodeT> ctx,
) {
  if (self == null) return null; // {} - B == {}
  if (other == null) return self; // A - {} == A
  final (l, b, r) = split(other, self.item, ctx);
  final low = difference(self.left, l, ctx);
  final high = difference(self.right, r, ctx);
  return b ? join2(low, high, ctx) : join(low, self, high, ctx);
}

NodeT? take<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int n,
  NodeContext<T, NodeT> ctx,
) {
  if (n == 0) return null; // empty;
  if (n >= self.size) return self;
  final (low, _, _) = split(
    self,
    select(self, n, ctx).item,
    ctx,
  );
  return low;
}

NodeT? skip<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int n,
  NodeContext<T, NodeT> ctx,
) {
  if (n == 0) return self;
  if (n >= self.size) return null; // empty
  final (_, _, high) = split(
    self,
    select(self, n - 1, ctx).item,
    ctx,
  );
  return high;
}
