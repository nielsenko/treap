import 'dart:collection';

import 'benchmark_base.dart';

typedef ListFactory<L extends List<T>, T> = L Function(Iterable<T> items);

abstract class ListBenchmark<L extends List<T>, T> extends BenchmarkBase {
  final ListFactory<L, T> listFactory;
  final List<T> items;
  final int numberOfItems; // count up front
  ListBenchmark(this.listFactory, this.items, String name)
      : numberOfItems = items.length,
        super(name.padRight(40)); // Align padding with set_benchmark
}

class AddAllBenchmark<L extends List<T>, T> extends ListBenchmark<L, T> {
  AddAllBenchmark(super.listFactory, super.items, [super.name = 'addAll']);

  @override
  void run() {
    listFactory(const []).addAll(items);
  }
}

abstract class UnaryOpBenchmark<L extends List<T>, T>
    extends ListBenchmark<L, T> {
  late final L list;
  UnaryOpBenchmark(super.listFactory, super.items, super.name);

  @override
  void setup() {
    list = listFactory(items);
    assert(list.length == numberOfItems);
  }
}

class InsertBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  InsertBenchmark(super.listFactory, super.items, [super.name = 'insert']);

  @override
  void run() {
    // Insert last element in the middle. We remove the last element before
    // inserting again to ensure the list doesn't grow. Using the last element
    // should be an advantage for a regular list.
    final e = list.removeLast();
    list.insert(numberOfItems ~/ 2, e); // insert in the middle
  }
}

class RemoveAtBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  RemoveAtBenchmark(super.listFactory, super.items, [super.name = 'removeAt']);

  @override
  void run() {
    final e = list.removeAt(numberOfItems ~/ 2);
    list.add(e); // to ensure list is same size on all runs
  }
}

class ToListBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  ToListBenchmark(super.listFactory, super.items, [super.name = 'toList']);

  @override
  void run() => list.toList();
}

class TakeBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  TakeBenchmark(super.listFactory, super.items, [super.name = 'take']);

  @override
  void run() =>
      list.take(numberOfItems ~/ 2).lastOrNull; // ensure iteration is done
}

class SkipBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  SkipBenchmark(super.listFactory, super.items, [super.name = 'skip']);

  @override
  void run() =>
      list.skip(numberOfItems ~/ 2).lastOrNull; // ensure iteration is done
}

class IndexBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  IndexBenchmark(super.listFactory, super.items, [super.name = 'index']);

  @override
  void run() => list[numberOfItems ~/ 2];
}

class SublistBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  SublistBenchmark(super.listFactory, super.items, [super.name = 'sublist']);

  @override
  void run() => list.sublist(numberOfItems ~/ 4, numberOfItems ~/ 2);
}
