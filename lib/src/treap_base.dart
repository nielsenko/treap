import 'package:meta/meta.dart';

import 'immutable_node.dart';
import 'node.dart';
import 'node.dart' as node;

/// A [fully persistent](https://en.wikipedia.org/wiki/Persistent_data_structure)
/// (immutable) implementation of a [Treap](https://en.wikipedia.org/wiki/Treap).
///
/// A treap is a type of binary search tree where each node is assigned a
/// uniformly distributed priority, either randomly or by a strong hash.
///
/// Nodes in the tree are kept heap-ordered with respect to their priority. This ensures that
/// the shape of the tree is a random variable with the same probability distribution
/// as a random binary tree. Hence the name treap, which is a portmanteau of tree
/// and heap.
///
/// In particular (with high probability), given a treap with `N` keys, the height
/// is `O(log(N))`, so that [find], [add], [remove], etc. also take `O(log(N))` time
/// to perform.
///
/// This particular implementation is made [persistent](https://en.wikipedia.org/wiki/Persistent_data_structure)
/// by means of path copying.
///
/// Both [add] and [remove] have a space complexity of `O(log(N))` due to path copying,
/// but erased nodes can later be reclaimed by the garbage collector if the old
/// treaps containing them become eligible for collection.
@immutable
final class TreapBase<T, NodeT extends Node<T, NodeT>> {
  final NodeT? _root;
  final NodeT Function(T) _createNode;

  /// The [Comparator] used to determine element order.
  ///
  /// Defaults to [Comparable.compare].
  final Comparator<T> compare;

  const TreapBase._(this._root, this._createNode, this.compare);

  /// Creates an empty [Treap] with an optional [compare] function.
  ///
  /// If [compare] is not provided, it defaults to [Comparable.compare].
  TreapBase(NodeT Function(T) createNode, [Comparator<T>? compare])
      : this._(
          null,
          createNode,
          compare ?? Comparable.compare as Comparator<T>,
        );

  /// Builds a treap containing the [items].
  ///
  /// Constructs the treap by folding [add] over the [items], adding each one
  /// to the treap in turn.
  ///
  /// This method has a complexity of `O(N log(N))`. An `O(N)` algorithm exists if the
  /// items are sorted. However, this method works in all cases.
  factory TreapBase.of(
    Iterable<T> items,
    NodeT Function(T) createNode, [
    Comparator<T>? compare,
  ]) {
    compare ??= Comparable.compare as Comparator<T>;
    NodeT? root;
    final it = items.iterator;
    if (it.moveNext()) {
      var last = it.current;
      root = createNode(last);
      while (it.moveNext()) {
        final next = it.current;
        if (compare(last, next) < 0) {
          // Fast path for sorted items
          root = join(root, createNode(last = next), null);
        } else {
          do {
            root = upsert(root, it.current, false, compare, createNode);
          } while (it.moveNext());
        }
      }
    }
    return TreapBase._(root, createNode, compare);
  }

  /// Creates a copy of this treap.
  TreapBase<T, NodeT> copy() => _new(_root?.copy());

  TreapBase<T, NodeT> _new(NodeT? root) =>
      identical(root, _root) ? this : TreapBase._(root, _createNode, compare);

  /// Adds an [item] to the treap.
  ///
  /// If the [item] is already present in the treap, the original treap is returned.
  /// Otherwise, a new treap is returned with the item added.
  @pragma('vm:prefer-inline')
  TreapBase<T, NodeT> add(T item) =>
      _new(upsert(_root, item, false, compare, _createNode));

  /// Adds or updates an [item] in the treap.
  ///
  /// Returns a new treap with [item] either added or updated.
  @pragma('vm:prefer-inline')
  TreapBase<T, NodeT> addOrUpdate(T item) =>
      _new(upsert(_root, item, true, compare, _createNode));

  /// Adds a range of [items] to the treap.
  ///
  /// Returns a new treap with the added [items]. If all the [items] are already
  /// present, the original treap is returned.
  @pragma('vm:prefer-inline')
  TreapBase<T, NodeT> addAll(Iterable<T> items) =>
      items.fold(this, (acc, i) => acc.add(i));

  /// Removes an [item] from the treap, if it exists.
  ///
  /// Returns a new treap without the removed [item]. If the [item] was not present,
  /// the original treap is returned.
  @pragma('vm:prefer-inline')
  TreapBase<T, NodeT> remove(T item) => _new(erase(_root, item, compare));

  /// Checks whether this treap is empty.
  bool get isEmpty => _root == null;

  /// Returns the size of this treap.
  int get size => _root.size;

  /// Finds the [item] in this treap.
  ///
  /// Returns the [T] in the treap, if any, that orders together with [item] by [compare].
  /// Otherwise returns `null`.
  T? find(T item) => node.find(_root, item, compare)?.item;

  /// Checks whether an [item] exists in this treap.
  bool has(T item) => find(item) != null;

  /// Returns the rank of an [item].
  ///
  /// For an [item] in this treap, the rank is the index of the item. For an item not
  /// in this treap, the rank is the index it would be at, if it was added.
  int rank(T item) => node.rank(_root, item, compare);

  /// Selects an item in this treap by its [index].
  T select(int index) => node.select(_root, index).item;

  /// Returns the values in this treap ordered by the [compare].
  Iterable<T> get values => _root.inOrder().map((n) => n.item);

  /// Returns the first item in this treap, or `null` if it is empty.
  T? get firstOrDefault => _root.firstOrNull?.item;

  /// Returns the last item in this treap, or `null` if it is empty.
  T? get lastOrDefault => _root.lastOrNull?.item;

  /// Returns the first item in this treap.
  ///
  /// Throws a [StateError] if it is empty.
  T get first => _root.first.item;

  /// Returns the last item in this treap.
  ///
  /// Throws a [StateError] if it is empty.
  T get last => _root.last.item;

  /// Returns the item preceding a given [item] in this treap.
  ///
  /// Throws a [RangeError] if no such item exists. Note that [item] need not be
  /// contained in this treap.
  T prev(T item) => node.select(_root, rank(item) - 1).item;

  /// Returns the next item in the treap for a given [item].
  ///
  /// [item] need not be contained in this treap.
  /// Throws a [RangeError] if no such item exists.
  T next(T item) => node.select(_root, rank(item) + 1).item;

  /// Returns a new treap with the first [n] items.
  ///
  /// Returns the original treap, if [n] is greater than the [size] of this treap.
  TreapBase<T, NodeT> take(int n) => _new(node.take(_root, n, compare));

  /// Skips the first [n] items and returns a new treap with the remaining items.
  ///
  /// Returns an empty treap, if [n] is greater than or equal to the [size] of this
  /// treap.
  TreapBase<T, NodeT> skip(int n) => _new(node.skip(_root, n, compare));

  /// Returns a new treap that is the union of this treap and the [other] treap.
  TreapBase<T, NodeT> union(TreapBase<T, NodeT> other) =>
      _new(node.union(_root, other._root, compare));

  /// Returns a new treap that is the intersection of this treap and the [other] treap.
  TreapBase<T, NodeT> intersection(TreapBase<T, NodeT> other) =>
      _new(node.intersection(_root, other._root, compare));

  /// Returns a new treap that is the difference of this treap minus the [other] treap.
  TreapBase<T, NodeT> difference(TreapBase<T, NodeT> other) =>
      _new(node.difference(_root, other._root, compare));

  /// Operator overload for [add]ing an [item] to the treap.
  TreapBase<T, NodeT> operator +(T item) => add(item);

  /// Operator overload for the [union] of two treaps.
  TreapBase<T, NodeT> operator |(TreapBase<T, NodeT> other) => union(other);

  /// Operator overload for the [intersection] of two treaps.
  TreapBase<T, NodeT> operator &(TreapBase<T, NodeT> other) =>
      intersection(other);

  /// Operator overload for the [difference] of two treaps.
  TreapBase<T, NodeT> operator -(TreapBase<T, NodeT> other) =>
      difference(other);

  /// Operator overload for [select]ing an item in the treap by its [index].
  T operator [](int index) => select(index);
}

extension type Treap<T>._(TreapBase<T, ImmutableNode<T>> base)
    implements TreapBase<T, ImmutableNode<T>> {
  Treap() : base = TreapBase(immutableNodeFactory);

  Treap.of(Iterable<T> items)
      : base = TreapBase.of(
          items,
          immutableNodeFactory,
        );

  Treap<T> copy() => Treap._(base.copy());

  Treap<T> add(T item) => Treap._(base.add(item));
  Treap<T> addOrUpdate(T item) => Treap._(base.addOrUpdate(item));
  Treap<T> addAll(Iterable<T> items) => Treap._(base.addAll(items));
  Treap<T> remove(T item) => Treap._(base.remove(item));

  Treap<T> take(int count) => Treap._(base.take(count));
  Treap<T> skip(int count) => Treap._(base.skip(count));

  Treap<T> union(Treap<T> other) => Treap._(base.union(other.base));
  Treap<T> intersection(Treap<T> other) =>
      Treap._(base.intersection(other.base));
  Treap<T> difference(Treap<T> other) => Treap._(base.difference(other.base));
}
