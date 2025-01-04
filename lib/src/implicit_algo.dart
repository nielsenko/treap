import 'node.dart';

(NodeT?, NodeT?) split<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int index,
) {
  if (self == null) return const (null, null);
  final (l, _, r) = self.expose;
  final order = index.compareTo(l.size);
  if (order < 0) {
    final (ll, lr) = split<T, NodeT>(l, index);
    return (ll, join(lr, self, r));
  }
  if (order > 0) {
    final adjusted = index - l.size - 1;
    final (rl, rr) = split<T, NodeT>(r, adjusted);
    return (join(l, self, rl), rr);
  }
  return (l, r);
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

NodeT? append<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  NodeT? other,
) {
  if (self == null) return other;
  return join2(self, other);
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
  final (low, _) = split<T, NodeT>(self, n);
  return low;
}

NodeT? skip<T, NodeT extends Node<T, NodeT>>(
  NodeT? self,
  int n,
) {
  final (_, high) = split<T, NodeT>(self, n - 1);
  return high;
}
