// Copyright 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'node.dart';

/// Splits the implicit treap `self` at the given `index`.
///
/// Returns a tuple `(left, right)` where `left` contains the first `index`
/// elements, and `right` contains the remaining elements.
(NodeT?, NodeT?) split<NodeT extends NodeBase<NodeT>>(
  NodeT? self,
  int index,
) {
  if (self == null) return const (null, null);
  final (left, right) = self.expose;
  final order = index.compareTo(left.size);
  if (order < 0) {
    // Index is in the left subtree
    final (leftLeft, leftRight) = split(left, index);
    return (leftLeft, join(leftRight, self, right));
  }
  if (order > 0) {
    // Index is in the right subtree
    final adjustedIndex = index - left.size - 1;
    final (rightLeft, rightRight) = split(right, adjustedIndex);
    return (join(left, self, rightLeft), rightRight);
  }
  // Index is at the current node
  return (left, right);
}

/// Inserts `newNode` into the implicit treap `self` at the specified `index`.
///
/// Returns the root of the modified treap.
NodeT insert<NodeT extends NodeBase<NodeT>>(
  NodeT? self,
  NodeT newNode,
  int index,
) {
  if (self == null) return newNode;
  final (left, right) = self.expose;
  final order = index.compareTo(left.size);
  if (order < 0) {
    // Insert into left subtree
    return join(insert(left, newNode, index), self, right);
  }
  if (order == 0) {
    // Insert at the current position (between left and self)
    return join(left, newNode, self.withLeft(null)); // self becomes right child
  }
  // order > 0: Insert into right subtree
  final adjustedIndex = index - self.left.size - 1;
  return join(left, self, insert(right, newNode, adjustedIndex));
}

/// Appends the implicit treap `other` to the end of `self`.
///
/// Returns the root of the combined treap.
NodeT? append<NodeT extends Node<dynamic, NodeT>>(
  NodeT? self,
  NodeT? other,
) {
  if (self == null) return other;
  return join2(self, other);
}

/// Removes the element at `index` from the implicit treap `self`.
///
/// Returns the root of the modified treap.
NodeT? erase<NodeT extends NodeBase<NodeT>>(
  NodeT? self,
  int index,
) {
  if (self == null) return null;
  final (left, right) = self.expose;
  final order = index.compareTo(left.size);
  if (order < 0) {
    // Erase from left subtree
    return join(erase(left, index), self, right);
  }
  if (order > 0) {
    // Erase from right subtree
    final adjustedIndex = index - self.left.size - 1;
    return join(left, self, erase(right, adjustedIndex));
  }
  // Erase the current node by joining its children
  return join2(left, right);
}

/// Returns a new implicit treap containing the first `n` elements of `self`.
NodeT? take<NodeT extends NodeBase<NodeT>>(
  NodeT? self,
  int n,
) {
  final (low, _) = split(self, n);
  return low;
}

/// Returns a new implicit treap containing all elements of `self` except the first `n`.
NodeT? skip<NodeT extends NodeBase<NodeT>>(
  NodeT? self,
  int n,
) {
  final (_, high) = split(self, n - 1);
  return high;
}
