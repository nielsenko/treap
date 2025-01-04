import 'dart:collection';

import 'package:benchmark_harness/benchmark_harness.dart' as harness;

abstract class BenchmarkBase extends harness.BenchmarkBase {
  BenchmarkBase(super.name);

  @override
  void report() {
    try {
      super.report();
    } catch (e) {
      print('$name: Failed! $e');
    }
  }

  @override
  void exercise() => run(); // run once per exercise
}

typedef ListFactory<L extends List<T>, T> = L Function(Iterable<T> items);

abstract class ListBenchmark<L extends List<T>, T> extends BenchmarkBase {
  final ListFactory<L, T> listFactory;
  final List<T> items;
  final int noOfItems; // count up front
  ListBenchmark(this.listFactory, this.items, String name)
      : noOfItems = items.length,
        super('$L '.padRight(20) + name.padRight(20));
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
    assert(list.length == noOfItems);
  }
}

class InsertBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  InsertBenchmark(super.listFactory, super.items, [super.name = 'insert']);

  @override
  void run() {
    list.insert(noOfItems ~/ 2, list.last);
  }
}

class RemoveAtBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  RemoveAtBenchmark(super.listFactory, super.items, [super.name = 'removeAt']);

  @override
  void run() {
    final e = list.removeAt(noOfItems ~/ 2);
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
      list.take(noOfItems ~/ 2).lastOrNull; // ensure iteration is done
}

class SkipBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  SkipBenchmark(super.listFactory, super.items, [super.name = 'skip']);

  @override
  void run() =>
      list.skip(noOfItems ~/ 2).lastOrNull; // ensure iteration is done
}

class IndexBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  IndexBenchmark(super.listFactory, super.items, [super.name = 'index']);

  @override
  void run() => list[noOfItems ~/ 2];
}

class SublistBenchmark<L extends List<T>, T> extends UnaryOpBenchmark<L, T> {
  SublistBenchmark(super.listFactory, super.items, [super.name = 'sublist']);

  @override
  void run() => list.sublist(noOfItems ~/ 4, noOfItems ~/ 2);
}
