// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/src/deeply_immutable/int_node.dart';

import '../treap_base.dart';

/// A persistent treap implementation using immutable nodes.
///
/// Provides efficient insertion, deletion, and lookup operations (O(log N)).
extension type TreapOfInt._(TreapBase<int, IntNode> base)
    implements TreapBase<int, IntNode> {
  /// Creates a [Treap] containing the [items].
  TreapOfInt.of(Iterable<int> items, [Comparator<int>? compare])
      : base = TreapBase.of(
          items,
          intNodeFactory,
          compare ?? (a, b) => a - b,
        );

  /// Returns a copy of this treap.
  TreapOfInt copy() => TreapOfInt._(base.copy());

  /// Adds an [item] to this treap.
  TreapOfInt add(int item) => TreapOfInt._(base.add(item));

  /// Adds or updates an [item] in this treap.
  TreapOfInt addOrUpdate(int item) => TreapOfInt._(base.addOrUpdate(item));

  /// Adds all [items] to this treap.
  TreapOfInt addAll(Iterable<int> items) => TreapOfInt._(base.addAll(items));

  /// Removes an [item] from this treap.
  TreapOfInt remove(int item) => TreapOfInt._(base.remove(item));

  /// Returns a new treap containing the first [count] items.
  TreapOfInt take(int count) => TreapOfInt._(base.take(count));

  /// Returns a new treap skipping the first [count] items.
  TreapOfInt skip(int count) => TreapOfInt._(base.skip(count));

  /// Returns the union of this treap and [other].
  TreapOfInt union(TreapOfInt other) => TreapOfInt._(base.union(other.base));

  /// Returns the intersection of this treap and [other].
  TreapOfInt intersection(TreapOfInt other) =>
      TreapOfInt._(base.intersection(other.base));

  /// Returns the difference of this treap minus [other].
  TreapOfInt difference(TreapOfInt other) =>
      TreapOfInt._(base.difference(other.base));
}
