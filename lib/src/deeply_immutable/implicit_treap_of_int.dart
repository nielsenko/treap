// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/src/deeply_immutable/int_node.dart';

import '../implicit_treap_base.dart';

extension type ImplicitTreapOfInt._(ImplicitTreapBase<int, IntNode> base)
    implements ImplicitTreapBase<int, IntNode> {
  ImplicitTreapOfInt.of(Iterable<int> items)
      : base = ImplicitTreapBase.of(items, intNodeFactory);

  ImplicitTreapOfInt take(int count) => ImplicitTreapOfInt._(base.take(count));

  ImplicitTreapOfInt skip(int count) => ImplicitTreapOfInt._(base.skip(count));

  ImplicitTreapOfInt copy() => ImplicitTreapOfInt._(base.copy());

  ImplicitTreapOfInt remove(int index) =>
      ImplicitTreapOfInt._(base.remove(index));

  ImplicitTreapOfInt insert(int index, int item) =>
      ImplicitTreapOfInt._(base.insert(index, item));

  ImplicitTreapOfInt add(int item) => ImplicitTreapOfInt._(base.add(item));

  ImplicitTreapOfInt append(ImplicitTreapOfInt other) =>
      ImplicitTreapOfInt._(base.append(other.base));
}
