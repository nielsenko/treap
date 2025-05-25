// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:meta/meta.dart';
import 'package:treap/src/node.dart';

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

@pragma('vm:prefer-inline')
StringNode stringNodeFactory(String item) =>
    StringNode(item, defaultPriority(item.hashCode), null, null);
