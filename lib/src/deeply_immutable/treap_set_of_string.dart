// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/src/deeply_immutable/string_node.dart';

import '../treap_set_base.dart';

extension type TreapSetOfString._(TreapSetBase<String, StringNode> base)
    implements TreapSetBase<String, StringNode> {
  TreapSetOfString.of(Iterable<String> items, [Comparator<String>? compare])
      : base = TreapSetBase.of(
          items,
          stringNodeFactory,
          compare,
        );

  TreapSetOfString() : this.of(<String>[]);

  TreapSetOfString union(TreapSetOfString other) =>
      TreapSetOfString._(base.union(other.base));
  TreapSetOfString intersection(TreapSetOfString other) =>
      TreapSetOfString._(base.intersection(other.base));
  TreapSetOfString difference(TreapSetOfString other) =>
      TreapSetOfString._(base.difference(other.base));

  TreapSetOfString take(int count) => TreapSetOfString._(base.take(count));
  TreapSetOfString takeWhile(bool Function(String value) test) =>
      TreapSetOfString._(base.takeWhile(test));
  TreapSetOfString skip(int count) => TreapSetOfString._(base.skip(count));
  TreapSetOfString skipWhile(bool Function(String value) test) =>
      TreapSetOfString._(base.skipWhile(test));

  TreapSetOfString toSet() => TreapSetOfString._(base.toSet());
}
