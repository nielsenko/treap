// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:meta/meta.dart';

import 'node.dart';

@immutable
@pragma('vm:deeply-immutable')
class DeeplyImmutable {
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
      : size = 1 + left.size + right.size;

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
}

@immutable
@pragma('vm:deeply-immutable')
class BoolNode implements Node<bool, BoolNode> {
  @override
  final bool item;
  @override
  final int priority;
  @override
  final int size;
  @override
  final BoolNode? left, right;

  BoolNode(this.item, this.priority, this.left, this.right)
      : size = 1 + left.size + right.size;

  @override
  BoolNode copy() => this;

  @override
  BoolNode withItem(bool item) => BoolNode(item, priority, left, right);

  @override
  BoolNode withLeft(BoolNode? left) => BoolNode(item, priority, left, right);

  @override
  BoolNode withRight(BoolNode? right) => BoolNode(item, priority, left, right);
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

  IntNode(this.item, this.priority, this.left, this.right)
      : size = 1 + left.size + right.size;

  @override
  IntNode copy() => this;

  @override
  IntNode withItem(int item) => IntNode(item, priority, left, right);

  @override
  IntNode withLeft(IntNode? left) => IntNode(item, priority, left, right);

  @override
  IntNode withRight(IntNode? right) => IntNode(item, priority, left, right);
}

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
  StringNode copy() => this;

  @override
  StringNode withItem(String item) => StringNode(item, priority, left, right);

  @override
  StringNode withLeft(StringNode? left) =>
      StringNode(item, priority, left, right);

  @override
  StringNode withRight(StringNode? right) =>
      StringNode(item, priority, left, right);
}
