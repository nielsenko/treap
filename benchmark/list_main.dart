import 'dart:math';

import 'package:treap/src/treap_list.dart';

import 'list_benchmark.dart';

final _base = log(2);
double log2(num x) => log(x) / _base;

void runFor<L extends List<T>, T>(
  ListFactory<L, T> listFactory,
  List<T> items,
) {
  print('-- $L '.padRight(80, '-'));
  AddAllBenchmark(listFactory, items).report();
  InsertBenchmark(listFactory, items).report();
  RemoveAtBenchmark(listFactory, items).report();
  ToListBenchmark(listFactory, items).report();
  TakeBenchmark(listFactory, items).report();
  SkipBenchmark(listFactory, items).report();
  IndexBenchmark(listFactory, items).report();
  SublistBenchmark(listFactory, items).report();
}

int main(List<String> args) {
  for (int n = 100; n <= 10000000; n *= 10) {
    print(''.padRight(80, '='));
    print('n: $n, log2(n): ${log2(n)}, n*log2(n): ${n * log2(n)}');

    final items = List.generate(n, (i) => i);

    runFor((items) => TreapList<int>()..addAll(items), items);
    runFor((items) => <int>[...items], items);
  }

  return 0;
}
