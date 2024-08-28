import 'dart:collection';
import 'dart:math';

import 'package:treap/src/treap_set.dart';

import 'set_benchmark.dart';

void runFor<S extends Set<T>, T>(
  SetFactory<S, T> setFactory,
  Iterable<T> items,
) {
  print('-- $S '.padRight(80, '-'));
  CtorBenchmark(setFactory, items).report();
  AddAllBenchmark(setFactory, items).report();
  ToSetBenchmark(setFactory, items).report();
  TakeBenchmark(setFactory, items).report();
  SkipBenchmark(setFactory, items).report();
  ElementAtBenchmark(setFactory, items).report();
  UnionBenchmark(setFactory, items).report();
  IntersectionBenchmark(setFactory, items).report();
  DifferenceBenchmark(setFactory, items).report();
}

int main(List<String> args) {
  for (int n = 10; n <= 10000000; n *= 10) {
    print('n: $n, log(n): ${log(n)}, n*log(n): ${n * log(n)}');

    final items = List.generate(n, (i) => i)..shuffle();

    runFor((items) => TreapSet.of(items), items);
    runFor((items) => LinkedHashSet.of(items), items);
    runFor((items) => SplayTreeSet.of(items), items);
    runFor((items) => HashSet.of(items), items);
  }

  return 0;
}
