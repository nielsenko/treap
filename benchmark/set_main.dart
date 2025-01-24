// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';
import 'dart:math';

import 'package:treap/src/treap_set.dart';
import 'package:treap/src/util.dart';

import 'set_benchmark.dart';

void runFor<S extends Set<T>, T>(
  SetFactory<S, T> setFactory,
  T Function(int i) itemGenerator,
  int count,
) {
  final items = List.generate(count, itemGenerator)..shuffle(Random(42));
  final sorted = items.toList()..sort();

  print('-- $S '.padRight(80, '-'));
  CtorBenchmark(setFactory, items).report();
  CtorBenchmark(setFactory, sorted, 'of (sorted input)').report();
  AddAllBenchmark(setFactory, items).report();
  AddAllBenchmark(setFactory, sorted, 'addAll (sorted input)').report();
  ToSetBenchmark(setFactory, items).report();
  TakeBenchmark(setFactory, items).report();
  SkipBenchmark(setFactory, items).report();
  ElementAtBenchmark(setFactory, items).report();
  UnionBenchmark(setFactory, items).report();
  IntersectionBenchmark(setFactory, items).report();
  DifferenceBenchmark(setFactory, items).report();
  ContainsBenchmark(setFactory, items).report();
}

int main(List<String> args) {
  for (int n = 100; n <= 1000000; n *= 10) {
    print(''.padRight(80, '='));
    print('n: $n, log2(n): ${log2(n)}, n*log2(n): ${n * log2(n)}');

    // all trees benefit from explicit integer compare function
    int intCompare(int a, int b) => a - b;

    runFor((items) => SplayTreeSet.of(items, intCompare), (i) => i, n);
    //runFor((items) => TreapSet.of(items, intCompare), (i) => i, n);
    runFor((items) => TreapIntSet.of(items, intCompare), (i) => i, n);
    runFor((items) => LinkedHashSet.of(items), (i) => i, n);
    runFor((items) => HashSet.of(items), (i) => i, n);
  }

  return 0;
}
