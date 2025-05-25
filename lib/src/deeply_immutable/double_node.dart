// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:meta/meta.dart';
import 'package:treap/src/node.dart';

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

@pragma('vm:prefer-inline')
DoubleNode doubleNodeFactory(double item) =>
    DoubleNode(item, defaultPriority(item.hashCode), null, null);
