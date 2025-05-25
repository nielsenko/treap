// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/src/deeply_immutable/double_node.dart';

import '../implicit_treap_base.dart';

extension type ImplicitTreapOfDouble._(
        ImplicitTreapBase<double, DoubleNode> base)
    implements ImplicitTreapBase<double, DoubleNode> {
  ImplicitTreapOfDouble.of(Iterable<double> items)
      : base = ImplicitTreapBase.of(items, doubleNodeFactory);

  ImplicitTreapOfDouble take(int count) =>
      ImplicitTreapOfDouble._(base.take(count));

  ImplicitTreapOfDouble skip(int count) =>
      ImplicitTreapOfDouble._(base.skip(count));

  ImplicitTreapOfDouble copy() => ImplicitTreapOfDouble._(base.copy());

  ImplicitTreapOfDouble remove(int index) =>
      ImplicitTreapOfDouble._(base.remove(index));

  ImplicitTreapOfDouble insert(int index, double item) =>
      ImplicitTreapOfDouble._(base.insert(index, item));

  ImplicitTreapOfDouble add(double item) =>
      ImplicitTreapOfDouble._(base.add(item));

  ImplicitTreapOfDouble append(ImplicitTreapOfDouble other) =>
      ImplicitTreapOfDouble._(base.append(other.base));
}
