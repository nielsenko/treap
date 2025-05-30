// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'immutable_node.dart';
import 'treap_map_base.dart';

/// A persistent map implementation based on a Treap.
///
/// Uses immutable nodes.
extension type TreapMap<K, V>._(
        TreapMapBase<K, V, ImmutableNode<KeyValue<K, V>>> base)
    implements TreapMapBase<K, V, ImmutableNode<KeyValue<K, V>>> {
  /// Creates an empty [TreapMap].
  ///
  /// Requires a key [compare] function.
  TreapMap([Comparator<K>? compare])
      : base = TreapMapBase(immutableNodeFactory, compare);
}
