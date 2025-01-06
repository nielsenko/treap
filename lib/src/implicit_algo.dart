// Copyright 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'node.dart';

(NodeT?, NodeT?) split<NodeT extends Node<dynamic, NodeT>>(
  NodeT? self,
  int index,
) {
  if (self == null) return const (null, null);
  final (l, _, r) = self.expose;
  final order = index.compareTo(l.size);
  if (order < 0) {
    final (ll, lr) = split(l, index);
    return (ll, join(lr, self, r));
  }
  if (order > 0) {
    final adjusted = index - l.size - 1;
    final (rl, rr) = split(r, adjusted);
    return (join(l, self, rl), rr);
  }
  return (l, r);
}

/// Throws a [RangeError] if [rank] is out of bounds
NodeT select<NodeT extends Node<dynamic, NodeT>>(
  NodeT? self,
  int rank,
) {
  final size = self.size;
  if (self == null || rank < 0 || rank >= size) {
    throw RangeError.range(rank, 0, size - 1, 'rank');
  }
  final (l, _, r) = self.expose;
  final ls = l.size;
  if (rank < ls) return select(l, rank);
  if (rank == ls) return self;
  return select(r, rank - ls - 1);
}

NodeT insert<NodeT extends Node<dynamic, NodeT>>(
  NodeT? self,
  NodeT newNode,
  int index,
) {
  if (self == null) return newNode;
  final (l, _, r) = self.expose;
  final order = index.compareTo(self.left.size);
  if (order < 0) return join(insert(l, newNode, index), self, r);
  if (order == 0) return join(l, newNode, self.withLeft(null));
  // order > 0
  final adjusted = index - self.left.size - 1;
  return join(l, self, insert(r, newNode, adjusted));
}

NodeT? append<NodeT extends Node<dynamic, NodeT>>(
  NodeT? self,
  NodeT? other,
) {
  if (self == null) return other;
  return join2(self, other);
}

NodeT? erase<NodeT extends Node<dynamic, NodeT>>(
  NodeT? self,
  int index,
) {
  if (self == null) return null;
  final (l, _, r) = self.expose;
  final order = index.compareTo(self.left.size);
  if (order < 0) return join(erase(l, index), self, r);
  if (order > 0) {
    final adjusted = index - self.left.size - 1;
    return join(l, self, erase(r, adjusted));
  }
  return join2(l, r);
}

NodeT? take<NodeT extends Node<dynamic, NodeT>>(
  NodeT? self,
  int n,
) {
  final (low, _) = split(self, n);
  return low;
}

NodeT? skip<NodeT extends Node<dynamic, NodeT>>(
  NodeT? self,
  int n,
) {
  final (_, high) = split(self, n - 1);
  return high;
}
