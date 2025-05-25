// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'immutable_node.dart';
import 'treap_set_base.dart';

/// A persistent set implementation based on a Treap.
///
/// Uses immutable nodes.
extension type TreapSet<T>._(TreapSetBase<T, ImmutableNode<T>> base)
    implements TreapSetBase<T, ImmutableNode<T>> {
  /// Creates a [TreapSet] containing the [items].
  ///
  /// If [compare] is not provided, defaults to [Comparable.compare].
  TreapSet.of(Iterable<T> items, [Comparator<T>? compare])
      : base = TreapSetBase.of(
          items,
          immutableNodeFactory,
          compare,
        );

  /// Creates an empty [TreapSet].
  ///
  /// If [compare] is not provided, defaults to [Comparable.compare].
  TreapSet([Comparator<T>? compare])
      : base = TreapSetBase(immutableNodeFactory, compare);

  TreapSet<T> union(TreapSet<T> other) => TreapSet<T>._(base.union(other.base));

  TreapSet<T> intersection(TreapSet<T> other) =>
      TreapSet<T>._(base.intersection(other.base));

  TreapSet<T> difference(TreapSet<T> other) =>
      TreapSet<T>._(base.difference(other.base));

  TreapSet<T> take(int count) => TreapSet<T>._(base.take(count));

  TreapSet<T> takeWhile(bool Function(T value) test) =>
      TreapSet<T>._(base.takeWhile(test));

  TreapSet<T> skip(int count) => TreapSet<T>._(base.skip(count));

  TreapSet<T> skipWhile(bool Function(T value) test) =>
      TreapSet<T>._(base.skipWhile(test));

  TreapSet<T> toSet() => TreapSet<T>._(base.toSet());
}
