import 'node.dart';

class Treap<T extends Comparable<T>> {
  final Node<T>? _node;

  const Treap._(this._node);
  Treap(T item) : this._(Node(item, item.hashCode));
  Treap.empty() : this._(null);

  Treap<T> insert(T item) {
    return has(item) ? this : upsert(item);
  }

  Treap<T> upsert(T item) {
    final n = Node<T>(item, item.hashCode);
    return Treap<T>._(_node?.upsert(n) ?? n);
  }

  Treap<T> delete(T item) {
    return Treap._(_node?.delete(item));
  }

  T? find(T item) => _node?.find(item)?.item;

  bool has(T item) => find(item) != null;

  Treap<T> union(Treap<T> other) {
    throw UnimplementedError('TODO!');
  }

  Treap<T> intersect(Treap<T> other) {
    throw UnimplementedError('TODO!');
  }

  Iterable<T> iterate() => _node?.inOrder().map((n) => n.item) ?? [];

  factory Treap.build(Iterable<T> items) {
    // TODO: This O(N log(N)), an O(N) algorithm exists, if items are sorted.
    // The advantage is, this is simpler, and it works even in the unsorted case.
    return items.fold(Treap._(null), (acc, i) => acc.upsert(i));
  }
}
