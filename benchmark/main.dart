import 'dart:collection';
import 'dart:math';

import 'package:treap/src/treap_set.dart';

import 'set_benchmark.dart';

void header<T>() => print('-- $T '.padRight(80, '-'));

int main(List<String> args) {
  for (int n = 1000; n <= 10000000; n *= 10) {
    print('n: $n, log(n): ${log(n)}, n*log(n): ${n * log(n)}');

    final items = List.generate(n, (i) => i)..shuffle();

    header<TreapSet<int>>();
    CtorBenchmark((items) => TreapSet.of(items), items).report();
    AddAllBenchmark((items) => TreapSet.of(items), items).report();
    ToSetBenchmark((items) => TreapSet.of(items), items).report();
    TakeBenchmark((items) => TreapSet.of(items), items).report();
    SkipBenchmark((items) => TreapSet.of(items), items).report();
    ElementAtBenchmark((items) => TreapSet.of(items), items).report();
    UnionBenchmark((items) => TreapSet.of(items), items).report();
    IntersectionBenchmark((items) => TreapSet.of(items), items).report();
    DifferenceBenchmark((items) => TreapSet.of(items), items).report();

    header<LinkedHashSet<int>>();
    CtorBenchmark((items) => LinkedHashSet.of(items), items).report();
    AddAllBenchmark((items) => LinkedHashSet.of(items), items).report();
    ToSetBenchmark((items) => LinkedHashSet.of(items), items).report();
    TakeBenchmark((items) => LinkedHashSet.of(items), items).report();
    SkipBenchmark((items) => LinkedHashSet.of(items), items).report();
    ElementAtBenchmark((items) => LinkedHashSet.of(items), items).report();
    UnionBenchmark((items) => LinkedHashSet.of(items), items).report();
    IntersectionBenchmark((items) => LinkedHashSet.of(items), items).report();
    DifferenceBenchmark((items) => LinkedHashSet.of(items), items).report();

    header<SplayTreeSet<int>>();
    CtorBenchmark((items) => SplayTreeSet.of(items), items).report();
    AddAllBenchmark((items) => SplayTreeSet.of(items), items).report();
    ToSetBenchmark((items) => SplayTreeSet.of(items), items).report();
    TakeBenchmark((items) => SplayTreeSet.of(items), items).report();
    SkipBenchmark((items) => SplayTreeSet.of(items), items).report();
    ElementAtBenchmark((items) => SplayTreeSet.of(items), items).report();
    UnionBenchmark((items) => SplayTreeSet.of(items), items).report();
    IntersectionBenchmark((items) => SplayTreeSet.of(items), items).report();
    DifferenceBenchmark((items) => SplayTreeSet.of(items), items).report();

    header<HashSet<int>>();
    CtorBenchmark((items) => HashSet.of(items), items).report();
    AddAllBenchmark((items) => HashSet.of(items), items).report();
    ToSetBenchmark((items) => HashSet.of(items), items).report();
    TakeBenchmark((items) => HashSet.of(items), items).report();
    SkipBenchmark((items) => HashSet.of(items), items).report();
    ElementAtBenchmark((items) => HashSet.of(items), items).report();
    UnionBenchmark((items) => HashSet.of(items), items).report();
    IntersectionBenchmark((items) => HashSet.of(items), items).report();
    DifferenceBenchmark((items) => HashSet.of(items), items).report();
  }

  return 0;
}
