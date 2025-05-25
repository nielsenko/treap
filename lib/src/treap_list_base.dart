// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';

import 'implicit_treap_base.dart';
import 'node.dart';

/// Base class for Treap-based list implementations.
///
/// Provides a mutable list API on top of an immutable [ImplicitTreapBase].
class TreapListBase<T, NodeT extends Node<T, NodeT>> extends ListBase<T> {
  ImplicitTreapBase<T, NodeT> _treap;
  final NodeT Function(T) _createNode;

  TreapListBase._(this._treap, this._createNode);

  /// Creates an empty [TreapListBase].
  ///
  /// Requires a `createNode` function.
  TreapListBase(NodeT Function(T) createNode)
      : _treap = ImplicitTreapBase<T, NodeT>.empty(createNode),
        _createNode = createNode;

  /// Creates a [TreapListBase] containing the [items].
  ///
  /// Requires a `createNode` function.
  factory TreapListBase.of(
    Iterable<T> items,
    NodeT Function(T) createNode,
  ) {
    return TreapListBase<T, NodeT>(createNode)..addAll(items);
  }

  @pragma('vm:prefer-inline')
  @override
  int get length => _treap.size;

  /// Setting the length is only supported for truncation.
  ///
  /// Setting a larger length is ignored.
  @override
  set length(int newLength) {
    if (newLength < length) _treap = _treap.take(newLength);
    // Ignore extensions
  }

  @override
  T operator [](int index) => _treap[index];

  @override
  void operator []=(int index, T element) {
    _treap = _treap.remove(index).insert(index, element);
  }

  @override
  void add(T element) => _treap = _treap.add(element);

  @override
  void addAll(Iterable<T> iterable) {
    for (final item in iterable) {
      add(item);
    }
  }

  @override
  void insert(int index, T element) {
    RangeError.checkValueInInterval(index, 0, length);
    _treap = _treap.insert(index, element);
  }

  @override
  T removeAt(int index) {
    RangeError.checkValueInInterval(index, 0, length - 1);
    final item = _treap[index];
    _treap = _treap.remove(index);
    return item;
  }

  @override
  T removeLast() => removeAt(length - 1);

  @override
  TreapListBase<T, NodeT> sublist(int start, [int? end]) =>
      getRange(start, end ?? length);

  @override
  TreapListBase<T, NodeT> getRange(int start, int end) =>
      TreapListBase._(_treap.skip(start).take(end - start), _createNode);

  /// Returns a new [TreapListBase] containing the same elements.
  ///
  /// The `growable` parameter is ignored.
  @override
  TreapListBase<T, NodeT> toList({bool growable = true}) {
    // We just ignore growable for now.
    return TreapListBase._(_treap.copy(), _createNode);
  }

  @override
  TreapListBase<T, NodeT> take(int count) =>
      TreapListBase._(_treap.take(count), _createNode);

  @override
  TreapListBase<T, NodeT> skip(int count) =>
      TreapListBase._(_treap.skip(count), _createNode);
}
