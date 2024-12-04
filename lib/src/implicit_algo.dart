import 'node.dart';

(NodeT?, bool, NodeT?) split<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int index,
) {
  if (self == null) return const (null, false, null);
  final (l, _, r) = self.expose;
  final order = index.compareTo(self.left.size);
  if (order < 0) {
    final (ll, b, lr) = split<T, NodeT>(l, index);
    return (ll, b, join(lr, self, r));
  }
  if (order > 0) {
    final adjusted = index - self.left.size - 1;
    final (rl, b, rr) = split<T, NodeT>(r, adjusted);
    return (join(l, self, rl), b, rr);
  }
  return (l, true, r);
}

/// Throws a [RangeError] if [rank] is out of bounds
NodeT select<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int rank,
) {
  final size = self.size;
  if (self == null || rank < 0 || rank >= size) {
    throw RangeError.range(rank, 0, size - 1, 'rank');
  }
  final (l, _, r) = self.expose;
  final ls = l.size;
  if (rank < ls) return select<T, NodeT>(l, rank);
  if (rank == ls) return self;
  return select<T, NodeT>(r, rank - ls - 1);
}

NodeT insert<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  NodeT newNode,
  int index,
) {
  if (self == null) return newNode;
  final (l, T i, r) = self.expose;
  final order = index.compareTo(self.left.size);
  if (order < 0) return join(insert<T, NodeT>(l, newNode, index), self, r);
  if (order == 0) return join(l, newNode, self.withLeft(null));
  // order > 0
  final adjusted = index - self.left.size - 1;
  return join(l, self, insert<T, NodeT>(r, newNode, adjusted));
}

NodeT? erase<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int index,
) {
  if (self == null) return null;
  final (l, _, r) = self.expose;
  final order = index.compareTo(self.left.size);
  if (order < 0) return join(erase<T, NodeT>(l, index), self, r);
  if (order > 0) {
    final adjusted = index - self.left.size - 1;
    return join(l, self, erase<T, NodeT>(r, adjusted));
  }
  return join2(l, r);
}

NodeT? take<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int n,
) {
  if (n == 0) return null; // empty;
  if (n >= self.size) return self;
  final (low, _, _) = split<T, NodeT>(self, n);
  return low;
}

NodeT? skip<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int n,
) {
  if (n == 0) return self;
  if (n >= self.size) return null; // empty
  final (_, b, high) = split<T, NodeT>(self, n - 1);
  return high;
}
