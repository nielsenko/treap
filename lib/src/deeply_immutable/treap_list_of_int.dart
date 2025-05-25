// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/src/deeply_immutable/int_node.dart';

import '../treap_list_base.dart';

extension type TreapListOfInt._(TreapListBase<int, IntNode> base)
    implements TreapListBase<int, IntNode> {
  TreapListOfInt.of(Iterable<int> items)
      : base = TreapListBase.of(
          items,
          intNodeFactory,
        );

  TreapListOfInt() : this.of(<int>[]);

  TreapListOfInt take(int count) => TreapListOfInt._(base.take(count));

  TreapListOfInt skip(int count) => TreapListOfInt._(base.skip(count));

  TreapListOfInt sublist(int start, [int? end]) =>
      TreapListOfInt._(base.getRange(start, end ?? length));

  TreapListOfInt getRange(int start, int end) =>
      TreapListOfInt._(base.getRange(start, end));

  TreapListOfInt toList({bool growable = true}) =>
      TreapListOfInt._(base.toList(growable: growable));
}
