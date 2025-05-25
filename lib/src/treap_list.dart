// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'immutable_node.dart';
import 'treap_list_base.dart';

/// A persistent list implementation based on a Treap.
///
/// Uses immutable nodes.
extension type TreapList<T>._(TreapListBase<T, ImmutableNode<T>> base)
    implements TreapListBase<T, ImmutableNode<T>> {
  /// Creates a [TreapList] containing the [items].
  TreapList.of(Iterable<T> items)
      : base = TreapListBase.of(
          items,
          immutableNodeFactory,
        );

  /// Creates an empty [TreapList].
  TreapList() : this.of(<T>[]);

  TreapList<T> take(int count) => TreapList._(base.take(count));

  TreapList<T> skip(int count) => TreapList._(base.skip(count));

  TreapList<T> sublist(int start, [int? end]) =>
      TreapList._(base.getRange(start, end ?? length));

  TreapList<T> getRange(int start, int end) =>
      TreapList._(base.getRange(start, end));

  TreapList<T> toList({bool growable = true}) =>
      TreapList._(base.toList(growable: growable));
}
