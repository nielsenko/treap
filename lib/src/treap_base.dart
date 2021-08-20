import 'node.dart';

class Treap<T extends Comparable<T>> {
  final Node<T>? _root;

  const Treap._(this._root);
  const Treap() : this._(null);

  // TODO: This is O(N log(N))! An O(N) algorithm exists, if items are sorted.
  // The advantage is, this is simpler, and it works even in the unsorted case.
  factory Treap.build(Iterable<T> items) => items.fold(Treap(), (acc, i) => acc.upsert(i));

  Treap<T> insert(T item) => has(item) ? this : upsert(item);

  Treap<T> upsert(T item) {
    final n = Node<T>(item, item.hashCode);
    return Treap<T>._(_root.add(n));
  }

  Treap<T> erase(T item) => Treap._(_root.erase(item));

  bool get isEmpty => _root == null;

  T? find(T item) => _root.find(item)?.item;
  bool has(T item) => find(item) != null;

  int rank(T item) => _root.rank(item);

  T select(int rank) => _root.select(rank).item;

  Iterable<T> get values => _root.values;

  Treap<T> union(Treap<T> other) => Treap._(_root.union(other._root));
  Treap<T> intersect(Treap<T> other) => Treap._(_root.intersect(other._root));
  Treap<T> difference(Treap<T> other) => Treap._(_root.difference(other._root));

  Treap<T> operator +(T item) => insert(item);
  Treap<T> operator |(Treap<T> other) => union(other);
  Treap<T> operator &(Treap<T> other) => intersect(other);
  Treap<T> operator -(Treap<T> other) => difference(other);
}
