import 'dart:collection';
import 'dart:math';

import 'package:treap/src/treap_set.dart';

import 'set_benchmark.dart';

final _base = log(2);
double log2(num x) => log(x) / _base;

void runFor<S extends Set<T>, T>(
  SetFactory<S, T> setFactory,
  List<T> items,
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
  for (int n = 100; n <= 10000000; n *= 10) {
    print(''.padRight(80, '='));
    print('n: $n, log2(n): ${log2(n)}, n*log2(n): ${n * log2(n)}');

    final items = List.generate(n, (i) => i)..shuffle(Random(42));

    runFor((items) => TreapSet.of(items), items);
    runFor((items) => SplayTreeSet.of(items), items);
    runFor((items) => LinkedHashSet.of(items), items);
    runFor((items) => HashSet.of(items), items);
  }

  return 0;
}
