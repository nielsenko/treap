// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/src/deeply_immutable/string_node.dart';

import '../implicit_treap_base.dart';

extension type ImplicitTreapOfString._(
        ImplicitTreapBase<String, StringNode> base)
    implements ImplicitTreapBase<String, StringNode> {
  ImplicitTreapOfString.of(Iterable<String> items)
      : base = ImplicitTreapBase.of(items, stringNodeFactory);

  ImplicitTreapOfString take(int count) =>
      ImplicitTreapOfString._(base.take(count));

  ImplicitTreapOfString skip(int count) =>
      ImplicitTreapOfString._(base.skip(count));

  ImplicitTreapOfString copy() => ImplicitTreapOfString._(base.copy());

  ImplicitTreapOfString remove(int index) =>
      ImplicitTreapOfString._(base.remove(index));

  ImplicitTreapOfString insert(int index, String item) =>
      ImplicitTreapOfString._(base.insert(index, item));

  ImplicitTreapOfString add(String item) =>
      ImplicitTreapOfString._(base.add(item));

  ImplicitTreapOfString append(ImplicitTreapOfString other) =>
      ImplicitTreapOfString._(base.append(other.base));
}
