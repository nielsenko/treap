// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import '../treap_list_base.dart';
import 'string_node.dart';

extension type TreapListOfString._(TreapListBase<String, StringNode> base)
    implements TreapListBase<String, StringNode> {
  TreapListOfString.of(Iterable<String> items)
      : base = TreapListBase.of(
          items,
          stringNodeFactory,
        );

  TreapListOfString() : this.of(<String>[]);

  TreapListOfString take(int count) => TreapListOfString._(base.take(count));

  TreapListOfString skip(int count) => TreapListOfString._(base.skip(count));

  TreapListOfString sublist(int start, [int? end]) =>
      TreapListOfString._(base.getRange(start, end ?? length));

  TreapListOfString getRange(int start, int end) =>
      TreapListOfString._(base.getRange(start, end));

  TreapListOfString toList({bool growable = true}) =>
      TreapListOfString._(base.toList(growable: growable));
}
