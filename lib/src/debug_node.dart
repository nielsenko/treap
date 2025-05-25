// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:math';

import 'package:meta/meta.dart';

import 'node.dart';
import 'util.dart';

@immutable
final class DebugNode<T> implements Node<T, DebugNode<T>> {
  @override
  final T item;
  @override
  final int priority;
  @override
  final int size;
  @override
  final DebugNode<T>? left, right;

  final int maxHeight;
  late final int leafCount;
  late final int leafHeightSum;

  double get averageHeight => leafHeightSum / leafCount;

  int get optimalHeight => 1 + log2floor(size);

  static double acceptableSkewFactor = 3;

  DebugNode(this.item, this.priority, [this.left, this.right])
      : size = 1 + left.size + right.size,
        maxHeight = 1 + max(left.maxHeight, right.maxHeight) {
    leafCount = isLeaf ? 1 : left.leafCount + right.leafCount;
    // every leaf gets a 1 node longer path
    leafHeightSum = left.leafHeightSum + right.leafHeightSum + leafCount;
    assert(() {
      assert(checkInvariant());
      final optimalHeight = this.optimalHeight;
      final averageHeightCeil = averageHeight.ceil();
      assert(optimalHeight <= averageHeightCeil, toString());
      assert(averageHeightCeil <= maxHeight, toString());
      assert(
        averageHeightCeil <= acceptableSkewFactor * optimalHeight,
        'optimalHeight == $optimalHeight, $this',
      );
      return true;
    }());
  }

  @override
  String toString() => 'item: $item, size: $size, '
      'optimalHeight: $optimalHeight, averageHeight: $averageHeight, maxHeight: $maxHeight, '
      'priority: $priority (left: ${left.priority}, right: ${right.priority})';

  @override
  @pragma('vm:prefer-inline')
  DebugNode<T> copy() => this;

  @override
  @pragma('vm:prefer-inline')
  DebugNode<T> withItem(T item) => DebugNode(item, priority, left, right);

  @override
  @pragma('vm:prefer-inline')
  DebugNode<T> withLeft(DebugNode<T>? left) =>
      DebugNode(item, priority, left, right);

  @override
  @pragma('vm:prefer-inline')
  DebugNode<T> withRight(DebugNode<T>? right) =>
      DebugNode(item, priority, left, right);

  @override
  @pragma('vm:prefer-inline')
  DebugNode<T> withChildren(DebugNode<T>? left, DebugNode<T>? right) =>
      DebugNode(item, priority, left, right);
}

extension DebugIntNodeEx<T> on DebugNode<T>? {
  @pragma('vm:prefer-inline')
  int get maxHeight {
    // same as `this?.maxHeight ?? 0` but avoids boxing a temporary nullable int
    final self = this;
    if (self == null) return 0;
    return self.maxHeight;
  }

  @pragma('vm:prefer-inline')
  int get leafCount {
    // same as `this?.leafCount ?? 0` but avoids boxing a temporary nullable int
    final self = this;
    if (self == null) return 0;
    return self.leafCount;
  }

  @pragma('vm:prefer-inline')
  int get leafHeightSum {
    // same as `this?.leafHeightSum ?? 0` but avoids boxing a temporary nullable int
    final self = this;
    if (self == null) return 0;
    return self.leafHeightSum;
  }
}
