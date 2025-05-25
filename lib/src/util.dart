// Copyright 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:math';

final _base = log(2);
double log2(num x) => log(x) / _base;
int log2floor(num x) => log2(x).floor();

extension type Stack<T>._(List<T> list) {
  Stack() : list = [];
  void push(T item) => list.add(item);
  T pop() => list.removeLast();
  T peek() => list.last;
  bool get isEmpty => list.isEmpty;
}
