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

  /// Creates an empty [TreapBase].
  ///
  /// Requires a `createNode` function to instantiate nodes.
  /// If [compare] is not provided, it defaults to [Comparable.compare].
  TreapBase(NodeT Function(T) createNode, [Comparator<T>? compare])
      : this._(
          null,
          createNode,
          compare ?? Comparable.compare as Comparator<T>,
        );

  /// Creates a [TreapBase] containing the [items].
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

  /// Returns a copy of this treap.
  ///
  /// This is an O(1) operation as it only copies the root reference.
  TreapBase<T, NodeT> copy() => _new(_root?.copy());

  TreapBase<T, NodeT> _new(NodeT? root) =>
      identical(root, _root) ? this : TreapBase._(root, _createNode, compare);

  /// Adds an [item] to this treap.
  ///
  /// If the [item] is already present, returns the original treap.
  /// Otherwise, a new treap is returned with the item added.
  @pragma('vm:prefer-inline')
  TreapBase<T, NodeT> add(T item) =>
      _new(upsert(_root, item, false, compare, _createNode));

  /// Adds or updates an [item] in this treap.
  ///
  /// Returns a new treap with the [item] added or updated.
  @pragma('vm:prefer-inline')
  TreapBase<T, NodeT> addOrUpdate(T item) =>
      _new(upsert(_root, item, true, compare, _createNode));

  /// Adds all [items] to this treap.
  ///
  /// Returns a new treap containing all original items plus the added [items].
  /// If an item already exists, it's ignored.
  /// present, the original treap is returned.
  @pragma('vm:prefer-inline')
  TreapBase<T, NodeT> addAll(Iterable<T> items) =>
      items.fold(this, (acc, i) => acc.add(i));

  /// Removes an [item] from this treap.
  ///
  /// Returns a new treap without the [item]. If the [item] was not present,
  /// the original treap is returned.
  @pragma('vm:prefer-inline')
  TreapBase<T, NodeT> remove(T item) => _new(erase(_root, item, compare));

  /// Whether this treap is empty.
  bool get isEmpty => _root == null;

  /// The number of items in this treap.
  int get size => _root.size;

  /// Finds the item in this treap equal to [item].
  ///
  /// Returns the stored item if found, according to [compare].
  /// Otherwise returns `null`.
  T? find(T item) => node.find(_root, item, compare)?.item;

  /// Whether this treap contains an item equal to [item].
  bool has(T item) => find(item) != null;

  /// Returns the rank of [item] in the sorted sequence of items.
  ///
  /// The rank is the number of items strictly less than [item].
  /// For an [item] in this treap, the rank is its index. For an item not
  /// in this treap, the rank is the index it would be at, if it was added.
  int rank(T item) => node.rank(_root, item, compare);

  /// Returns the item at the given [index] in the sorted sequence.
  ///
  /// Throws [RangeError] if the [index] is out of bounds.
  T select(int index) => node.select(_root, index).item;

  /// An [Iterable] of the items in this treap in ascending order according to [compare].
  Iterable<T> get values => _root.inOrder().map((n) => n.item);

  /// The first item in the sorted sequence, or `null` if this treap is empty.
  T? get firstOrDefault => _root.firstOrNull?.item;

  /// The last item in the sorted sequence, or `null` if this treap is empty.
  T? get lastOrDefault => _root.lastOrNull?.item;

  /// The first item in the sorted sequence.
  ///
  /// Throws a [StateError] if this treap is empty.
  T get first => _root.first.item;

  /// The last item in the sorted sequence.
  ///
  /// Throws a [StateError] if this treap is empty.
  T get last => _root.last.item;

  /// Returns the item preceding [item] in the sorted sequence.
  ///
  /// Throws [RangeError] if [item] is the first item or not found.
  /// Note that [item] need not be contained in this treap.
  /// contained in this treap.
  T prev(T item) => node.select(_root, rank(item) - 1).item;

  /// Returns the item succeeding [item] in the sorted sequence.
  ///
  /// Note that [item] need not be contained in this treap.
  /// Throws a [RangeError] if no such item exists.
  T next(T item) => node.select(_root, rank(item) + 1).item;

  /// Returns a new treap containing the first [n] items of the sorted sequence.
  ///
  /// Returns the original treap if [n] >= [size].
  TreapBase<T, NodeT> take(int n) => _new(node.take(_root, n, compare));

  /// Returns a new treap skipping the first [n] items of the sorted sequence.
  ///
  /// Returns an empty treap if [n] >= [size].
  /// treap.
  TreapBase<T, NodeT> skip(int n) => _new(node.skip(_root, n, compare));

  /// Returns a new treap containing all items from this treap and [other].
  TreapBase<T, NodeT> union(TreapBase<T, NodeT> other) =>
      _new(node.union(_root, other._root, compare));

  /// Returns a new treap containing only items present in both this treap and [other].
  TreapBase<T, NodeT> intersection(TreapBase<T, NodeT> other) =>
      _new(node.intersection(_root, other._root, compare));

  /// Returns a new treap containing items from this treap that are not in [other].
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
