// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:meta/meta.dart';

import '../node.dart';

// NOTE: This is in reality useless to outside users as it has to be sealed when
// marked as deeply immutable, but it's here to show a user can easily create
// treaps supporting deeply immutable data structures for efficient inter-isolate
// communication.
//
// Hopefully, the Dart team will add support for an interface class for deeply
// immutable classes in the future, so we can remove this class, and simplify
// IntNode, and friends.
@immutable
@pragma('vm:deeply-immutable')
sealed class DeeplyImmutable {
  const DeeplyImmutable();
}

@immutable
@pragma('vm:deeply-immutable')
final class DeeplyImmutableNode<T extends DeeplyImmutable>
    implements Node<T, DeeplyImmutableNode<T>> {
  @override
  final T item;
  @override
  final int priority;
  @override
  final int size;
  @override
  final DeeplyImmutableNode<T>? left, right;

  DeeplyImmutableNode(this.item, this.priority, this.left, this.right)
      : size = 1 + left.size + right.size {
    assert(checkInvariant());
  }

  @override
  DeeplyImmutableNode<T> copy() => this;

  @override
  DeeplyImmutableNode<T> withItem(T item) =>
      DeeplyImmutableNode(item, priority, left, right);

  @override
  DeeplyImmutableNode<T> withLeft(DeeplyImmutableNode<T>? left) =>
      DeeplyImmutableNode(item, priority, left, right);

  @override
  DeeplyImmutableNode<T> withRight(DeeplyImmutableNode<T>? right) =>
      DeeplyImmutableNode(item, priority, left, right);

  @override
  DeeplyImmutableNode<T> withChildren(
          DeeplyImmutableNode<T>? left, DeeplyImmutableNode<T>? right) =>
      DeeplyImmutableNode(item, priority, left, right);
}
