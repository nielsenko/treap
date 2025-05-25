// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import '../treap_base.dart';
import 'string_node.dart';

/// A persistent treap implementation using immutable nodes.
///
/// Provides efficient insertion, deletion, and lookup operations (O(log N)).
extension type TreapOfString._(TreapBase<String, StringNode> base)
    implements TreapBase<String, StringNode> {
  /// Creates a [Treap] containing the [items].
  TreapOfString.of(Iterable<String> items, [Comparator<String>? compare])
      : base = TreapBase.of(
          items,
          stringNodeFactory,
        );

  TreapOfString copy() => TreapOfString._(base.copy());

  TreapOfString add(String item) => TreapOfString._(base.add(item));

  TreapOfString addOrUpdate(String item) =>
      TreapOfString._(base.addOrUpdate(item));

  TreapOfString addAll(Iterable<String> items) =>
      TreapOfString._(base.addAll(items));

  TreapOfString remove(String item) => TreapOfString._(base.remove(item));

  TreapOfString take(int count) => TreapOfString._(base.take(count));

  TreapOfString skip(int count) => TreapOfString._(base.skip(count));

  TreapOfString union(TreapOfString other) =>
      TreapOfString._(base.union(other.base));

  TreapOfString intersection(TreapOfString other) =>
      TreapOfString._(base.intersection(other.base));

  TreapOfString difference(TreapOfString other) =>
      TreapOfString._(base.difference(other.base));
}
