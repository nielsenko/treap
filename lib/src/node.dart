class Node<T> {
  final T item;
  final int priority;
  final int _size;
  final Node<T>? left, right;

  Node(this.item, this.priority, {this.left, this.right})
      : _size = 1 + left.size + right.size;

  Iterable<Node<T>> inOrder() sync* {
    yield* left?.inOrder() ?? [];
    yield this;
    yield* right?.inOrder() ?? [];
  }

  Iterable<Node<T>> postOrder() sync* {
    yield* left?.postOrder() ?? [];
    yield* right?.postOrder() ?? [];
    yield this;
  }

  Iterable<Node<T>> preOrder() sync* {
    yield this;
    yield* left?.preOrder() ?? [];
    yield* right?.preOrder() ?? [];
  }

  Node<T> withLeft(Node<T>? left) =>
      Node(item, priority, left: left, right: right);
  Node<T> withRight(Node<T>? right) =>
      Node(item, priority, left: left, right: right);
  Node<T> withoutChildren() => Node(item, priority);

  T get min => left == null ? item : left!.min;
  T get max => right == null ? item : right!.max;
}

// NOTE: Use inline class when available.
// For now, use typedef + extension methods
typedef Split<T> = ({
  Node<T>? low,
  Node<T>? middle,
  Node<T>? high,
});

extension<T> on Split<T> {
  Split<T> withLow(Node<T>? low) => (low: low, middle: middle, high: high);
  Split<T> withMiddle(Node<T>? middle) =>
      (low: low, middle: middle, high: high);
  Split<T> withHigh(Node<T>? high) => (low: low, middle: middle, high: high);
  Node<T>? join() {
    final m = middle;
    if (m == null) return low.join(high);
    return low.join(m.join(high));
  }
}

Split<T> emptySplit<T>() => const (low: null, middle: null, high: null);

Split<T> newSplit<T>(
  Node<T>? low,
  Node<T>? middle,
  Node<T>? high,
  Comparator<T> compare,
) {
  final m = middle?.withoutChildren();
  final l = low;
  final h = high;
  assert(m == null || (h == null || compare(m.item, h.min) < 0));
  assert(m == null || (l == null || compare(l.max, m.item) < 0));
  assert((l == null || h == null) || compare(l.max, h.min) < 0);

  return (low: l, middle: m, high: h);
}

extension NodeEx<T> on Node<T>? {
  int get size => this?._size ?? 0;

  Split<T> split(T pivot, Comparator<T> compare) {
    final self = this; // for type promotion
    if (self == null) return emptySplit<T>();
    final order = compare(pivot, self.item);
    if (order < 0) {
      final s = self.left.split(pivot, compare);
      return s.withHigh(self.withLeft(s.high));
    }
    if (order > 0) {
      final s = self.right.split(pivot, compare);
      return s.withLow(self.withRight(s.low));
    }
    return newSplit(self.left, self, self.right, compare); // order == 0
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

  Node<T> add(Node<T> child, Comparator<T> compare) =>
      split(child.item, compare).withMiddle(child).join()!;

  Node<T>? erase(T dead, Comparator<T> compare) =>
      split(dead, compare).withMiddle(null).join();

  Node<T>? union(Node<T>? other, Comparator<T> compare) {
    final self = this; // for type promotion
    if (self == null) return other; // {} | B == B
    final s = other.split(self.item, compare);
    return newSplit(
      self.left.union(s.low, compare),
      self,
      self.right.union(s.high, compare),
      compare,
    ).join();
  }

  Node<T>? intersection(Node<T>? other, Comparator<T> compare) {
    final self = this; // for type promotion
    if (self == null || other == null) return null; // {} & B == A & {} == {}
    final s = other.split(self.item, compare);
    return newSplit(
      self.left.intersection(s.low, compare),
      s.middle,
      self.right.intersection(s.high, compare),
      compare,
    ).join();
  }

  Node<T>? difference(Node<T>? other, Comparator<T> compare) {
    final self = this; // for type promotion
    if (self == null) return null; // {} - B == {}
    if (other == null) return self; // A - {} == A
    final s = other.split(self.item, compare);
    return newSplit(
      self.left.difference(s.low, compare),
      s.middle == null ? self : null,
      self.right.difference(s.high, compare),
      compare,
    ).join();
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

  Iterable<T> get values {
    final self = this; // for type promotion
    if (self == null) return [];
    return self.inOrder().map((n) => n.item);
  }
}
