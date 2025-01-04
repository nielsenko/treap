// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';

import 'package:treap/src/implicit_treap.dart';

class TreapList<T> extends ListBase<T> {
  ImplicitTreap<T> _treap;

  TreapList._(this._treap);
  TreapList() : _treap = ImplicitTreap.empty();

  @pragma('vm:prefer-inline')
  @override
  int get length => _treap.size;

  @override
  set length(int newLength) {
    if (newLength < length) _treap = _treap.take(newLength);
    // Ignore extensions
  }

  @override
  T operator [](int index) => _treap[index];

  @override
  void operator []=(int index, T element) {
    // TODO!
    // Consider optimizing this to avoid the intermediate treap after remove.
    _treap = _treap.remove(index).insert(index, element);
  }

  @override
  void add(T element) => _treap = _treap.add(element);

  @override
  void addAll(Iterable<T> iterable) =>
      _treap = _treap.append(ImplicitTreap.of(iterable));

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
  TreapList<T> sublist(int start, [int? end]) => getRange(start, end ?? length);

  // TODO!
  // Currently sublist and getRange has identical semantics, but I wonder if
  // getRange should show modifications that happens after getRange is called,
  // but before the iterator is consumed. I guess that match better with the
  // behavior or the regular List class.
  @override
  TreapList<T> getRange(int start, int end) =>
      TreapList._(_treap.skip(start).take(end - start));

  @override
  TreapList<T> toList({bool growable = true}) {
    // TODO!
    // We just ignore growable for now.
    return TreapList._(_treap.copy());
  }

  @override
  TreapList<T> take(int count) => TreapList._(_treap.take(count));

  @override
  TreapList<T> skip(int count) => TreapList._(_treap.skip(count));
}
