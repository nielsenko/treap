// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';

import 'package:treap/src/deeply_immutable_node.dart';
import 'package:treap/src/hash.dart';
import 'package:treap/src/implicit_treap.dart';
import 'immutable_node.dart';
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

/// A persistent list implementation based on a Treap.
///
/// Uses immutable nodes.
extension type TreapList<T>._(TreapListBase<T, ImmutableNode<T>> base)
    implements TreapListBase<T, ImmutableNode<T>> {
  /// Creates a [TreapList] containing the [items].
  TreapList.of(Iterable<T> items)
      : base = TreapListBase.of(
          items,
          immutableNodeFactory,
        );

  /// Creates an empty [TreapList].
  TreapList() : this.of(<T>[]);

  TreapList<T> take(int count) => TreapList._(base.take(count));

  TreapList<T> skip(int count) => TreapList._(base.skip(count));

  TreapList<T> sublist(int start, [int? end]) =>
      TreapList._(base.getRange(start, end ?? length));

  TreapList<T> getRange(int start, int end) =>
      TreapList._(base.getRange(start, end));

  TreapList<T> toList({bool growable = true}) =>
      TreapList._(base.toList(growable: growable));
}

extension type TreapIntList._(TreapListBase<int, IntNode> base)
    implements TreapListBase<int, IntNode> {
  TreapIntList.of(Iterable<int> items)
      : base = TreapListBase.of(
          items,
          (i) => IntNode(i, Hash.hash(i, 1202)),
        );

  TreapIntList() : this.of(<int>[]);

  TreapIntList take(int count) => TreapIntList._(base.take(count));

  TreapIntList skip(int count) => TreapIntList._(base.skip(count));

  TreapIntList sublist(int start, [int? end]) =>
      TreapIntList._(base.getRange(start, end ?? length));

  TreapIntList getRange(int start, int end) =>
      TreapIntList._(base.getRange(start, end));

  TreapIntList toList({bool growable = true}) =>
      TreapIntList._(base.toList(growable: growable));
}

extension type TreapStringList._(TreapListBase<String, StringNode> base)
    implements TreapListBase<String, StringNode> {
  TreapStringList.of(Iterable<String> items)
      : base = TreapListBase.of(
          items,
          stringNodeFactory,
        );

  TreapStringList() : this.of(<String>[]);

  TreapStringList take(int count) => TreapStringList._(base.take(count));

  TreapStringList skip(int count) => TreapStringList._(base.skip(count));

  TreapStringList sublist(int start, [int? end]) =>
      TreapStringList._(base.getRange(start, end ?? length));

  TreapStringList getRange(int start, int end) =>
      TreapStringList._(base.getRange(start, end));

  TreapStringList toList({bool growable = true}) =>
      TreapStringList._(base.toList(growable: growable));
}

extension type TreapDoubleList._(TreapListBase<double, DoubleNode> base)
    implements TreapListBase<double, DoubleNode> {
  TreapDoubleList.of(Iterable<double> items)
      : base = TreapListBase.of(
          items,
          doubleNodeFactory,
        );

  TreapDoubleList() : this.of(<double>[]);

  TreapDoubleList take(int count) => TreapDoubleList._(base.take(count));

  TreapDoubleList skip(int count) => TreapDoubleList._(base.skip(count));

  TreapDoubleList sublist(int start, [int? end]) =>
      TreapDoubleList._(base.getRange(start, end ?? length));

  TreapDoubleList getRange(int start, int end) =>
      TreapDoubleList._(base.getRange(start, end));

  TreapDoubleList toList({bool growable = true}) =>
      TreapDoubleList._(base.toList(growable: growable));
}
