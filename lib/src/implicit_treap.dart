// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'immutable_node.dart';
import 'implicit_treap_base.dart';

extension type ImplicitTreap<T>._(ImplicitTreapBase<T, ImmutableNode<T>> base)
    implements ImplicitTreapBase<T, ImmutableNode<T>> {
  ImplicitTreap.of(Iterable<T> items)
      : base = ImplicitTreapBase.of(
          items,
          immutableNodeFactory,
        );

  ImplicitTreap.empty() : base = ImplicitTreapBase.empty(immutableNodeFactory);

  ImplicitTreap<T> take(int count) => ImplicitTreap._(base.take(count));

  ImplicitTreap<T> skip(int count) => ImplicitTreap._(base.skip(count));

  ImplicitTreap<T> copy() => ImplicitTreap._(base.copy());

  ImplicitTreap<T> remove(int index) => ImplicitTreap._(base.remove(index));

  ImplicitTreap<T> insert(int index, T item) =>
      ImplicitTreap._(base.insert(index, item));

  ImplicitTreap<T> add(T item) => ImplicitTreap._(base.add(item));

  ImplicitTreap<T> append(ImplicitTreap<T> other) =>
      ImplicitTreap._(base.append(other.base));
}
