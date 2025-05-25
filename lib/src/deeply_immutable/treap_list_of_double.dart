// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/src/deeply_immutable/double_node.dart';

import '../treap_list_base.dart';

extension type TreapListOfDouble._(TreapListBase<double, DoubleNode> base)
    implements TreapListBase<double, DoubleNode> {
  TreapListOfDouble.of(Iterable<double> items)
      : base = TreapListBase.of(
          items,
          doubleNodeFactory,
        );

  TreapListOfDouble() : this.of(<double>[]);

  TreapListOfDouble take(int count) => TreapListOfDouble._(base.take(count));

  TreapListOfDouble skip(int count) => TreapListOfDouble._(base.skip(count));

  TreapListOfDouble sublist(int start, [int? end]) =>
      TreapListOfDouble._(base.getRange(start, end ?? length));

  TreapListOfDouble getRange(int start, int end) =>
      TreapListOfDouble._(base.getRange(start, end));

  TreapListOfDouble toList({bool growable = true}) =>
      TreapListOfDouble._(base.toList(growable: growable));
}
