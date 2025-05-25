// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/src/deeply_immutable/int_node.dart';

import '../treap_set_base.dart';

extension type TreapSetOfInt._(TreapSetBase<int, IntNode> base)
    implements TreapSetBase<int, IntNode> {
  TreapSetOfInt.of(Iterable<int> items, [Comparator<int>? compare])
      : base = TreapSetBase.of(
          items,
          intNodeFactory,
          compare ?? (a, b) => a - b,
        );

  TreapSetOfInt() : this.of(<int>[]);

  TreapSetOfInt union(TreapSetOfInt other) =>
      TreapSetOfInt._(base.union(other.base));
  TreapSetOfInt intersection(TreapSetOfInt other) =>
      TreapSetOfInt._(base.intersection(other.base));
  TreapSetOfInt difference(TreapSetOfInt other) =>
      TreapSetOfInt._(base.difference(other.base));

  TreapSetOfInt take(int count) => TreapSetOfInt._(base.take(count));
  TreapSetOfInt takeWhile(bool Function(int value) test) =>
      TreapSetOfInt._(base.takeWhile(test));
  TreapSetOfInt skip(int count) => TreapSetOfInt._(base.skip(count));
  TreapSetOfInt skipWhile(bool Function(int value) test) =>
      TreapSetOfInt._(base.skipWhile(test));

  TreapSetOfInt toSet() => TreapSetOfInt._(base.toSet());
}
