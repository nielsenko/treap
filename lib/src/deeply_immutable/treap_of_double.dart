// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import '../treap_base.dart';
import 'double_node.dart';

/// A persistent treap implementation using immutable nodes.
///
/// Provides efficient insertion, deletion, and lookup operations (O(log N)).
extension type TreapOfDouble._(TreapBase<double, DoubleNode> base)
    implements TreapBase<double, DoubleNode> {
  /// Creates a [Treap] containing the [items].
  TreapOfDouble.of(Iterable<double> items, [Comparator<double>? compare])
      : base = TreapBase.of(
          items,
          doubleNodeFactory,
          compare ?? (a, b) => a < b ? -1 : (a > b ? 1 : 0),
        );

  TreapOfDouble copy() => TreapOfDouble._(base.copy());

  TreapOfDouble add(double item) => TreapOfDouble._(base.add(item));

  TreapOfDouble addOrUpdate(double item) =>
      TreapOfDouble._(base.addOrUpdate(item));

  TreapOfDouble addAll(Iterable<double> items) =>
      TreapOfDouble._(base.addAll(items));

  TreapOfDouble remove(double item) => TreapOfDouble._(base.remove(item));

  TreapOfDouble take(int count) => TreapOfDouble._(base.take(count));

  TreapOfDouble skip(int count) => TreapOfDouble._(base.skip(count));

  TreapOfDouble union(TreapOfDouble other) =>
      TreapOfDouble._(base.union(other.base));

  TreapOfDouble intersection(TreapOfDouble other) =>
      TreapOfDouble._(base.intersection(other.base));

  TreapOfDouble difference(TreapOfDouble other) =>
      TreapOfDouble._(base.difference(other.base));
}
