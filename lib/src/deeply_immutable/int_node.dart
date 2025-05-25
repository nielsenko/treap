// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:meta/meta.dart';
import 'package:treap/src/node.dart';

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
