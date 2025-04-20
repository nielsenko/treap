import 'package:treap/src/treap_list.dart';
import 'package:treap/src/util.dart';

import 'list_benchmark.dart';

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
  for (int n = 100; n <= 1000000; n *= 10) {
    print(''.padRight(80, '='));
    print('n: $n, log2(n): ${log2(n)}, n*log2(n): ${n * log2(n)}');

    final items = List.generate(n, (i) => i);

    runFor((items) => TreapList<int>()..addAll(items), items);
    runFor((items) => <int>[...items], items);
  }

  return 0;
}
