// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause

import 'package:meta/meta.dart';

import 'node.dart';

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

@immutable
@pragma('vm:deeply-immutable')
final class DoubleNode implements Node<double, DoubleNode> {
  @override
  final double item;
  @override
  final int priority;
  @override
  final int size;
  @override
  final DoubleNode? left, right;

  DoubleNode(this.item, this.priority, this.left, this.right)
      : size = 1 + left.size + right.size;

  @override
  DoubleNode copy() => this;

  @override
  DoubleNode withItem(double item) => DoubleNode(item, priority, left, right);

  @override
  DoubleNode withLeft(DoubleNode? left) =>
      DoubleNode(item, priority, left, right);

  @override
  DoubleNode withRight(DoubleNode? right) =>
      DoubleNode(item, priority, left, right);

  @override
  DoubleNode withChildren(DoubleNode? left, DoubleNode? right) =>
      DoubleNode(item, priority, left, right);
}

@immutable
@pragma('vm:deeply-immutable')
final class IntNode implements Node<int, IntNode> {
  @override
  final int item;
  @override
  final int priority;
  @override
  final int size;
  @override
  final IntNode? left, right;

  IntNode(this.item, this.priority, [this.left, this.right])
      : size = 1 + left.size + right.size;

  @override
  @pragma('vm:prefer-inline')
  IntNode copy() => this;

  @override
  @pragma('vm:prefer-inline')
  IntNode withItem(int item) => IntNode(item, priority, left, right);

  @override
  @pragma('vm:prefer-inline')
  IntNode withLeft(IntNode? left) => IntNode(item, priority, left, right);

  @override
  @pragma('vm:prefer-inline')
  IntNode withRight(IntNode? right) => IntNode(item, priority, left, right);

  @override
  @pragma('vm:prefer-inline')
  IntNode withChildren(IntNode? left, IntNode? right) =>
      IntNode(item, priority, left, right);
}

IntNode intNodeFactory(int item) => IntNode(item, defaultPriority(item));

@pragma('vm:prefer-inline')
StringNode stringNodeFactory(String item) =>
    StringNode(item, defaultPriority(item.hashCode), null, null);

@pragma('vm:prefer-inline')
DoubleNode doubleNodeFactory(double item) =>
    DoubleNode(item, defaultPriority(item.hashCode), null, null);

@immutable
@pragma('vm:deeply-immutable')
final class StringNode implements Node<String, StringNode> {
  @override
  final String item;
  @override
  final int priority;
  @override
  final int size;
  @override
  final StringNode? left, right;

  StringNode(this.item, this.priority, this.left, this.right)
      : size = 1 + left.size + right.size;

  @override
  @pragma('vm:prefer-inline')
  StringNode copy() => this;

  @override
  @pragma('vm:prefer-inline')
  StringNode withItem(String item) => StringNode(item, priority, left, right);

  @override
  @pragma('vm:prefer-inline')
  StringNode withLeft(StringNode? left) =>
      StringNode(item, priority, left, right);

  @override
  @pragma('vm:prefer-inline')
  StringNode withRight(StringNode? right) =>
      StringNode(item, priority, left, right);

  @override
  @pragma('vm:prefer-inline')
  StringNode withChildren(StringNode? left, StringNode? right) =>
      StringNode(item, priority, left, right);
}
