import 'immutable_node.dart';
import 'treap_base.dart';

/// A persistent treap implementation using immutable nodes.
///
/// Provides efficient insertion, deletion, and lookup operations (O(log N)).
extension type Treap<T>._(TreapBase<T, ImmutableNode<T>> base)
    implements TreapBase<T, ImmutableNode<T>> {
  /// Creates an empty [Treap].
  Treap() : base = TreapBase(immutableNodeFactory);

  /// Creates a [Treap] containing the [items].
  Treap.of(Iterable<T> items)
      : base = TreapBase.of(
          items,
          immutableNodeFactory,
        );

  /// Returns a copy of this treap.
  Treap<T> copy() => Treap._(base.copy());

  /// Adds an [item] to this treap.
  Treap<T> add(T item) => Treap._(base.add(item));

  /// Adds or updates an [item] in this treap.
  Treap<T> addOrUpdate(T item) => Treap._(base.addOrUpdate(item));

  /// Adds all [items] to this treap.
  Treap<T> addAll(Iterable<T> items) => Treap._(base.addAll(items));

  /// Removes an [item] from this treap.
  Treap<T> remove(T item) => Treap._(base.remove(item));

  /// Returns a new treap containing the first [count] items.
  Treap<T> take(int count) => Treap._(base.take(count));

  /// Returns a new treap skipping the first [count] items.
  Treap<T> skip(int count) => Treap._(base.skip(count));

  /// Returns the union of this treap and [other].
  Treap<T> union(Treap<T> other) => Treap._(base.union(other.base));

  /// Returns the intersection of this treap and [other].
  Treap<T> intersection(Treap<T> other) =>
      Treap._(base.intersection(other.base));

  /// Returns the difference of this treap minus [other].
  Treap<T> difference(Treap<T> other) => Treap._(base.difference(other.base));
}
