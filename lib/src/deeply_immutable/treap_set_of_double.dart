// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/src/deeply_immutable/double_node.dart';

import '../treap_set_base.dart';

extension type TreapSetOfDouble._(TreapSetBase<double, DoubleNode> base)
    implements TreapSetBase<double, DoubleNode> {
  TreapSetOfDouble.of(Iterable<double> items, [Comparator<double>? compare])
      : base = TreapSetBase.of(
          items,
          doubleNodeFactory,
          compare,
        );

  TreapSetOfDouble() : this.of(<double>[]);

  TreapSetOfDouble union(TreapSetOfDouble other) =>
      TreapSetOfDouble._(base.union(other.base));
  TreapSetOfDouble intersection(TreapSetOfDouble other) =>
      TreapSetOfDouble._(base.intersection(other.base));
  TreapSetOfDouble difference(TreapSetOfDouble other) =>
      TreapSetOfDouble._(base.difference(other.base));

  TreapSetOfDouble take(int count) => TreapSetOfDouble._(base.take(count));
  TreapSetOfDouble takeWhile(bool Function(double value) test) =>
      TreapSetOfDouble._(base.takeWhile(test));
  TreapSetOfDouble skip(int count) => TreapSetOfDouble._(base.skip(count));
  TreapSetOfDouble skipWhile(bool Function(double value) test) =>
      TreapSetOfDouble._(base.skipWhile(test));

  TreapSetOfDouble toSet() => TreapSetOfDouble._(base.toSet());
}
