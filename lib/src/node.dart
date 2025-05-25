// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:math';

/// Base interface for nodes in a Treap.
///
/// Contains properties common to all node types.
abstract interface class NodeBase<NodeT extends NodeBase<NodeT>> {
  /// The priority of this node, used for maintaining heap order.
  int get priority;

  /// The size of the subtree rooted at this node (including the node itself).
  int get size;

  /// The left child of this node.
  NodeT? get left;

  /// The right child of this node.
  NodeT? get right;

  /// Returns a copy of this node with the left child replaced.
  NodeT withLeft(NodeT? left);

  /// Returns a copy of this node with the right child replaced.
  NodeT withRight(NodeT? right);

  /// Returns a copy of this node with both children replaced.
  NodeT withChildren(NodeT? left, NodeT? right);

  /// Returns a shallow copy of this node.
  NodeT copy();
}

/// Interface for nodes in a Treap that hold an item of type [T].
abstract interface class Node<T, NodeT extends Node<T, NodeT>>
    extends NodeBase<NodeT> {
  /// The item stored in this node.
  T get item;

  /// Returns a copy of this node with the item replaced.
  NodeT withItem(T item);
}

final _random = Random();

/// Generates a random priority for a node item.
/// Returns a value between 0 and 65535 (inclusive).
int randomPriority(Object? item) => _random.nextInt(
    0xffff + 1); // 65536, dart2js friendly version (avoids bit-shift issues)

/// Calculates a priority based on the item's hash code.
int hashAsPriority(Object? i) => Object.hash(i, 1202);

/// The default priority function used when creating nodes.
///
/// Initially set to [hashAsPriority].
var defaultPriority = hashAsPriority;

Never noElement() => throw StateError('No element');

extension NodeEx<T, NodeT extends Node<T, NodeT>> on NodeT {
  @pragma('vm:prefer-inline')
  (NodeT?, T, NodeT?) get expose => (left, item, right);
}

extension NodeBaseEx<NodeT extends NodeBase<NodeT>> on NodeT {
  @pragma('vm:prefer-inline')
  (NodeT?, NodeT?) get expose => (left, right);

  /* NOTE: rotations are not used currently
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
  */

  /// The node containing the minimum item in the subtree rooted at this node.
  NodeT get first => left == null ? this : left!.first;

  /// The node containing the maximum item in the subtree rooted at this node.
  NodeT get last => right == null ? this : right!.last;

  /// Whether this node is a leaf node (has no children).
  bool get isLeaf => left == null && right == null;

  /// Checks if the invariants of the node (heap order) hold.
  ///
  /// Asserts violations in debug mode.
  bool checkInvariant() {
    // check heap order
    assert(priority >= 0, 'priority: $priority');
    assert(
      left.priority <= priority,
      'left: ${left.priority}, priority: $priority',
    );
    assert(
      right.priority <= priority,
      'right: ${right.priority}, priority: $priority',
    );
    return true;
  }
}

/// Extension methods for nullable [NodeBase] references.
extension NullableNodeEx<NodeT extends NodeBase<NodeT>> on NodeT? {
  /// The size of the subtree rooted at this node, or 0 if the node is null.
  @pragma('vm:prefer-inline')
  int get size {
    // same as `this?.size ?? 0` but avoids boxing a temporary nullable int
    final self = this;
    if (self == null) return 0;
    return self.size;
  }

  /// The priority of this node, or -1 if the node is null.
  @pragma('vm:prefer-inline')
  int get priority {
    // same as `this?.priority ?? -1` but avoids boxing a temporary nullable int
    final self = this;
    if (self == null) return -1;
    return self.priority;
  }

  /// The node containing the minimum item, or null if the treap is empty.
  @pragma('vm:prefer-inline')
  NodeT? get firstOrNull => this?.first;

  /// The node containing the maximum item, or null if the treap is empty.
  @pragma('vm:prefer-inline')
  NodeT? get lastOrNull => this?.last;

  /// The node containing the minimum item.
  ///
  /// Throws [StateError] if the treap is empty.
  @pragma('vm:prefer-inline')
  NodeT get first => firstOrNull ?? noElement();

  /// The node containing the maximum item.
  ///
  /// Throws [StateError] if the treap is empty.
  @pragma('vm:prefer-inline')
  NodeT get last => lastOrNull ?? noElement();

  /// Returns an iterable of the nodes in this treap in ascending order.
  Iterable<NodeT> inOrder() sync* {
    final self = this;
    if (self == null) return;
    yield* self.left.inOrder();
    yield self;
    yield* self.right.inOrder();
  }

  /// Returns an iterable of the nodes in this treap in post-order traversal.
  Iterable<NodeT> postOrder() sync* {
    final self = this;
    if (self == null) return;
    yield* self.left.postOrder();
    yield* self.right.postOrder();
    yield self;
  }

  /// Returns an iterable of the nodes in this treap in pre-order traversal.
  Iterable<NodeT> preOrder() sync* {
    final self = this;
    if (self == null) return;
    yield self;
    yield* self.left.preOrder();
    yield* self.right.preOrder();
  }
}

/// Joins three nodes `low`, `middle`, and `high` into a single treap.
///
/// Assumes that all items in `low` are less than `middle.item`,
/// and all items in `high` are greater than `middle.item`.
/// Preserves the heap order property based on node priorities.
NodeT join<NodeT extends NodeBase<NodeT>>(
  NodeT? low,
  NodeT middle,
  NodeT? high,
) {
  final p = middle.priority;
  if (p > low.priority && //
      p > high.priority) {
    if (identical(middle.left, low) && //
        identical(middle.right, high)) {
      return middle; // reuse
    }
    return middle.withChildren(low, high);
  }
  if (low.priority > high.priority) {
    return low!.withRight(join(low.right, middle, high));
  }
  return high!.withLeft(join(low, middle, high.left));
}

/// Splits the treap `self` into three parts based on the `pivot` item.
///
/// Returns a tuple `(left, found, right)` where:
/// - `left` contains all items less than `pivot`.
/// - `found` is true if `pivot` was found in the treap.
/// - `right` contains all items greater than `pivot`.
(NodeT?, bool, NodeT?) split<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  T pivot,
  Comparator<T> compare,
) {
  if (self == null) return const (null, false, null);
  final (l, T i, r) = self.expose;
  final order = compare(pivot, i);
  if (order < 0) {
    final (ll, b, lr) = split(l, pivot, compare);
    return (ll, b, join(lr, self, r));
  }
  if (order > 0) {
    final (rl, b, rr) = split(r, pivot, compare);
    return (join(l, self, rl), b, rr);
  }
  return (l, true, r);
}

/// Splits the treap `self` into its main part and the node with the maximum item.
///
/// Returns a tuple `(mainPart, lastNode)`.
(NodeT?, NodeT) splitLast<NodeT extends NodeBase<NodeT>>(
  NodeT self,
) {
  final (left, right) = self.expose;
  if (right == null) return (left, self);
  final (rightLeft, last) = splitLast(right);
  return (join(left, self, rightLeft), last);
}

/// Joins two treaps `left` and `right`.
///
/// Assumes all items in `left` are less than all items in `right`.
NodeT? join2<NodeT extends NodeBase<NodeT>>(
  NodeT? left,
  NodeT? right,
) {
  if (left == null) return right;
  final (l, last) = splitLast(left);
  return join(l, last, right);
}

/// Inserts or updates an item in the treap `self`.
///
/// If `allowUpdate` is true and an item equal to `item` already exists,
/// it updates the existing item. Otherwise, it inserts `item`.
/// Returns the root of the modified treap.
NodeT upsert<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  T item,
  bool allowUpdate,
  Comparator<T> compare,
  NodeT Function(T) createNode,
) {
  if (self == null) return createNode(item);
  final (l, T i, r) = self.expose;
  final order = compare(item, i);
  if (order < 0) {
    return join(
      upsert(l, item, allowUpdate, compare, createNode),
      self,
      r,
    );
  }
  if (order > 0) {
    return join(
      l,
      self,
      upsert(r, item, allowUpdate, compare, createNode),
    );
  }
  return allowUpdate ? self.withItem(item) : self;
}

/// Removes an item from the treap `self`.
///
/// Returns the root of the modified treap, or null if the item was not found
/// and the original treap was empty.
NodeT? erase<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  T item,
  Comparator<T> compare,
) {
  if (self == null) return null;
  final (l, T i, r) = self.expose;
  final order = compare(item, i);
  if (order < 0) return join(erase(l, item, compare), self, r);
  if (order > 0) return join(l, self, erase(r, item, compare));
  return join2(l, r);
}

/// Finds the node containing an item equal to `item` in the treap `self`.
///
/// Returns the node if found, otherwise returns null.
NodeT? find<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  T item,
  Comparator<T> compare,
) {
  if (self == null) return null; // {}
  final order = compare(item, self.item);
  if (order < 0) return find(self.left, item, compare);
  if (order > 0) return find(self.right, item, compare);
  return self; // order == 0
}

/// Returns the rank of the `item` in the treap `self`.
///
/// The rank is the number of items strictly less than `item`.
int rank<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  T item,
  Comparator<T> compare,
) {
  if (self == null) return 0; // {}
  final (l, T i, r) = self.expose;
  final order = compare(item, i);
  if (order < 0) return rank(l, item, compare);
  if (order > 0) return 1 + l.size + rank(r, item, compare);
  return l.size; // order == 0
}

/// Returns the node at the given `rank` (0-based index) in the treap `self`.
///
/// Throws [RangeError] if `rank` is out of bounds.
NodeT select<NodeT extends NodeBase<NodeT>>(
  NodeT? self,
  int rank,
) {
  final size = self.size;
  if (self == null || rank < 0 || rank >= size) {
    throw RangeError.range(rank, 0, size - 1, 'rank');
  }
  return _select(self, rank);
}

NodeT _select<NodeT extends NodeBase<NodeT>>(
  NodeT? self,
  int rank,
) {
  if (self == null) return noElement();
  final (left, right) = self.expose;
  final leftSize = left.size;
  if (rank < leftSize) return select(left, rank);
  if (rank == leftSize) return self;
  return _select(right, rank - leftSize - 1);
}

/// Computes the union of two treaps, `self` and `other`.
///
/// Returns a new treap containing all items present in either treap.
NodeT? union<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  NodeT? other,
  Comparator<T> compare,
) {
  if (self == null) return other; // {} | B == B
  if (other == null) return self; // A | {} == A
  final (l, _, r) = split(other, self.item, compare);
  return join(
    union(self.left, l, compare),
    self,
    union(self.right, r, compare),
  );
}

/// Computes the intersection of two treaps, `self` and `other`.
///
/// Returns a new treap containing only items present in both treaps.
NodeT? intersection<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  NodeT? other,
  Comparator<T> compare,
) {
  if (self == null || other == null) return null; // {} & B == A & {} == {}
  final (l, b, r) = split(other, self.item, compare);
  final low = intersection(self.left, l, compare);
  final high = intersection(self.right, r, compare);
  return b ? join(low, self, high) : join2(low, high);
}

/// Computes the difference of two treaps, `self` and `other` (`self` - `other`).
///
/// Returns a new treap containing items present in `self` but not in `other`.
NodeT? difference<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  NodeT? other,
  Comparator<T> compare,
) {
  if (self == null) return null; // {} - B == {}
  if (other == null) return self; // A - {} == A
  final (l, b, r) = split(other, self.item, compare);
  final low = difference(self.left, l, compare);
  final high = difference(self.right, r, compare);
  return b ? join2(low, high) : join(low, self, high);
}

/// Returns a new treap containing the first `n` items of the treap `self`.
///
/// If `n` is 0, returns an empty treap. If `n` is greater than or equal
/// to the size of `self`, returns `self`.
NodeT? take<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int n,
  Comparator<T> compare,
) {
  if (n == 0) return null; // empty;
  if (n >= self.size) return self;
  final (low, _, _) = split(self, select(self, n).item, compare);
  return low;
}

/// Returns a new treap containing all items of the treap `self` except the first `n`.
///
/// If `n` is 0, returns `self`. If `n` is greater than or equal to the size
/// of `self`, returns an empty treap.
NodeT? skip<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int n,
  Comparator<T> compare,
) {
  if (n == 0) return self;
  if (n >= self.size) return null; // empty
  final (_, _, high) = split(self, select(self, n - 1).item, compare);
  return high;
}
