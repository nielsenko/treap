class Node<T extends Comparable<T>> {
  final T item;
  final int priority;
  final int _size;
  final Node<T>? left, right;

  Node(this.item, this.priority, {this.left, this.right}) : _size = 1 + left.size + right.size;

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

  //     t            R
  //    / \          / \
  //   l   r   =>   T   y
  //      / \      / \
  //     x   y    l   x
  //
  /// throws if no right child exists
  Node<T> spinLeft() {
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
  Node<T> spinRight() {
    final l = left!;
    final y = l.right;
    return l.withRight(withLeft(y));
  }

  Node<T> withLeft(Node<T>? left) => Node(item, priority, left: left, right: right);
  Node<T> withRight(Node<T>? right) => Node(item, priority, left: left, right: right);
}

class Split<T extends Comparable<T>> {
  final Node<T>? low, pivot, high;

  const Split(this.low, this.pivot, this.high);
  const Split.empty() : this(null, null, null);

  Node<T>? join() {
    final p = pivot;
    if (p == null) return low.join(high);
    return low.join(Node(p.item, p.priority).join(high));
  }

  Split<T> withHigh(Node<T>? high) => Split(low, pivot, high);
  Split<T> withLow(Node<T>? low) => Split(low, pivot, high);
}

extension NodeEx<T extends Comparable<T>> on Node<T>? {
  int get size => this?._size ?? 0;

  Split<T> split(T pivot) {
    final self = this;
    if (self == null) return Split.empty();
    final order = pivot.compareTo(self.item);
    if (order < 0) {
      final s = self.left.split(pivot);
      return s.withHigh(self.withLeft(s.high));
    }
    if (order > 0) {
      final s = self.right.split(pivot);
      return s.withLow(self.withRight(s.low));
    }
    return Split(self.left, self, self.right); // order == 0
  }

  Node<T>? join(Node<T>? other) {
    final self = this;
    assert(values.fold<bool>(true, (acc, i) => acc && other.find(i) == null));
    assert(values.fold<bool>(true, (acc, i) => acc && other.rank(i) == 0));
    assert(other.values.fold<bool>(true, (acc, i) => acc && self.find(i) == null));
    if (self != null && other != null) {
      // two - ensure heap order
      if (self.priority > other.priority) return self.withRight(self.right.join(other));
      return other.withLeft(self.join(other.left));
    }
    return self ?? other; // zero or one
  }

  Node<T> add(Node<T> child) {
    // elegant, but less efficient
    // final s = split(node.item);
    // return s.withPivot(node).join()!;

    final self = this;
    if (self == null) return child;

    Node<T> root;
    final order = child.item.compareTo(self.item);
    if (order < 0) {
      // add to left subtree
      root = self.withLeft(self.left.add(child));
      if (root.priority < root.left!.priority) root = root.spinRight(); // maintain heap order
    } else if (order > 0) {
      // add to right subtree
      root = self.withRight(self.right.add(child));
      if (root.priority < root.right!.priority) root = root.spinLeft(); // maintain heap order
    } else {
      // when order == 0, make a copy and upsert item from child
      // (even though they compare equal they may not be identical)
      root = Node(child.item, self.priority, left: self.left, right: self.right);
    }
    return root;
  }

  Node<T>? erase(T dead) {
    // elegant, but less efficient
    // final s = split(dead);
    // return s.withPivot(null).join();

    final self = this;
    if (self == null) return null;

    final l = self.left;
    final r = self.right;

    final order = dead.compareTo(self.item);
    if (order < 0) return self.withLeft(l.erase(dead));
    if (order > 0) return self.withRight(r.erase(dead));
    // order == 0
    if (l != null && r != null) {
      // two children
      final root = l.priority < r.priority ? self.spinLeft() : self.spinRight(); // maintain heap order
      return root.erase(dead);
    }
    return l ?? r; // one or no children
  }

  Node<T>? union(Node<T>? other) {
    final self = this;
    if (self == null) return other;
    final s = other.split(self.item);
    return Split(
      self.left.union(s.low),
      self,
      self.right.union(s.high),
    ).join();
  }

  Node<T>? intersect(Node<T>? other) {
    final self = this;
    if (self == null || other == null) return null;
    final s = other.split(self.item);
    return Split(
      self.left.intersect(s.low),
      s.pivot == null ? null : self,
      self.right.intersect(s.high),
    ).join();
  }

  Node<T>? difference(Node<T>? other) {
    final self = this;
    if (self == null) return null;
    if (other == null) return self;
    final s = other.split(self.item);
    return Split(
      self.left.difference(s.low),
      null,
      self.right.difference(s.high),
    ).join();
  }

  Node<T>? find(T item) {
    final self = this;
    if (self == null) return null;
    final order = item.compareTo(self.item);
    if (order < 0) return self.left?.find(item);
    if (order > 0) return self.right?.find(item);
    return this; // order == 0
  }

  int rank(T item) {
    final self = this;
    if (self == null) return 0;
    final order = item.compareTo(self.item);
    if (order < 0) return self.left.rank(item);
    final l = self.left.size;
    if (order > 0) return l + 1 + self.right.rank(item);
    return l; // order == 0
  }

  /// throws if out of bounds
  Node<T> select(int rank) {
    final self = this;
    if (self == null || rank < 0 || rank >= size) throw Error(); // TODO: Choose error!
    final l = self.left.size;
    if (rank < l) return self.left.select(rank);
    if (rank == l) return self;
    return self.right.select(rank - l - 1);
  }

  Iterable<T> get values {
    final self = this;
    if (self == null) return [];
    return self.inOrder().map((n) => n.item);
  }
}
