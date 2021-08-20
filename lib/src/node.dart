class Node<T extends Comparable<T>> {
  final T item;
  final int priority;
  final int _size;
  final Node<T>? left, right;

  Node(this.item, this.priority, {this.left, this.right}) : _size = 1 + size(left) + size(right);

  static int size(Node? n) => n?._size ?? 0;

  //     t          L
  //    / \        / \
  //   l   r  =>  x   T
  //  / \            / \
  // x   y          y   r
  //
  /// throws if no left child exists
  Node<T> spinRight() {
    final l = left!;
    final x = l.left;
    final y = l.right;
    return Node(l.item, l.priority, left: x, right: Node(item, priority, left: y, right: right));
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
    final y = r.right;
    return Node(r.item, r.priority, right: y, left: Node(item, priority, left: left, right: x));
  }

  Node<T> upsert(Node<T> child) {
    Node<T> root;
    final order = child.item.compareTo(item);
    if (order < 0) {
      // add to left subtree
      root = Node(item, priority, left: left?.upsert(child) ?? child, right: right);
      if (root.priority < root.left!.priority) root = root.spinRight(); // maintain heap order
    } else if (order > 0) {
      // add to right subtree
      root = Node(item, priority, left: left, right: right?.upsert(child) ?? child);
      if (root.priority < root.right!.priority) root = root.spinLeft(); // maintain heap order
    } else {
      // when order == 0, make a copy and upsert item from child
      // (even though they compare equal they may not be identical)
      root = Node(child.item, priority, left: left, right: right);
    }
    return root;
  }

  Node<T>? find(T item) {
    final order = item.compareTo(this.item);
    if (order < 0) return left?.find(item);
    if (order > 0) return right?.find(item);
    return this; // order == 0
  }

  /// zero-based, throws if item not found
  int rank(T item) {
    final order = item.compareTo(this.item);
    if (order < 0) return left!.rank(item);
    final l = size(left);
    if (order > 0) return l + 1 + right!.rank(item);
    return l; // order == 0
  }

  /// throws if item not found
  Node<T> findByRank(int rank) {
    if (rank < 0 || rank >= _size) throw Error(); // TODO: Choose error!
    final l = size(left);
    if (rank < l) return left!.findByRank(rank); // 0 < rank < l implies left != null
    if (rank == l) return this;
    return right!.findByRank(rank - l - 1);
  }

  Node<T>? delete(T dead) {
    final order = dead.compareTo(item);
    if (order < 0) return Node(item, priority, left: left?.delete(dead), right: right);
    if (order > 0) return Node(item, priority, left: left, right: right?.delete(dead));
    // order == 0
    final l = left;
    final r = right;
    if (l != null && r != null) {
      // two children
      final root = l.priority < r.priority ? spinLeft() : spinRight(); // maintain heap order
      return root.delete(dead);
    }
    return l ?? r; // one or no children
  }

  Iterable<Node<T>> preOrder() sync* {
    yield this;
    yield* left?.preOrder() ?? [];
    yield* right?.preOrder() ?? [];
  }

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
}
