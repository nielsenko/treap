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

typedef SetFactory<S extends Set<T>, T> = S Function(Iterable<T> items);

abstract class SetBenchmark<S extends Set<T>, T> extends BenchmarkBase {
  final SetFactory<S, T> setFactory;
  final List<T> items;
  final int noOfItems; // count up front
  SetBenchmark(this.setFactory, this.items, String name)
      : noOfItems = items.length,
        super(name.padRight(40));
}

class CtorBenchmark<S extends Set<T>, T> extends SetBenchmark<S, T> {
  CtorBenchmark(super.setFactory, super.items, [super.name = 'of']);

  @override
  void run() {
    setFactory(items); // SetT.of(items) (see main.dart)
  }
}

abstract class UnaryOpBenchmark<S extends Set<T>, T>
    extends SetBenchmark<S, T> {
  late final S set;
  UnaryOpBenchmark(super.setFactory, super.items, super.name);

  @override
  void setup() => set = setFactory(items);
}

class ToSetBenchmark<S extends Set<T>, T> extends UnaryOpBenchmark<S, T> {
  ToSetBenchmark(super.setFactory, super.items, [super.name = 'toSet']);

  @override
  void run() => set.toSet();
}

class AddAllBenchmark<S extends Set<T>, T> extends SetBenchmark<S, T> {
  AddAllBenchmark(super.setFactory, super.items, [super.name = 'addAll']);

  @override
  void run() {
    setFactory(const []).addAll(items);
  }
}

class TakeBenchmark<S extends Set<T>, T> extends UnaryOpBenchmark<S, T> {
  TakeBenchmark(super.setFactory, super.items, [super.name = 'take']);

  @override
  void run() => set.take(noOfItems ~/ 2).lastOrNull; // ensure iteration is done
}

class SkipBenchmark<S extends Set<T>, T> extends UnaryOpBenchmark<S, T> {
  SkipBenchmark(super.setFactory, super.items, [super.name = 'skip']);

  @override
  void run() => set.skip(noOfItems ~/ 2).lastOrNull; // ensure iteration is done
}

class ElementAtBenchmark<S extends Set<T>, T> extends UnaryOpBenchmark<S, T> {
  ElementAtBenchmark(super.setFactory, super.items, [super.name = 'elementAt']);

  @override
  void run() => set.elementAt(noOfItems ~/ 2);
}

abstract class BinaryOpBenchmark<S extends Set<T>, T>
    extends SetBenchmark<S, T> {
  late final S set;
  late final S other;
  BinaryOpBenchmark(super.setFactory, super.items, super.name);

  @override
  void setup() {
    final third = noOfItems ~/ 3;
    set = setFactory(items.take(2 * third));
    other = setFactory(items.skip(third));
  }
}

class UnionBenchmark<S extends Set<T>, T> extends BinaryOpBenchmark<S, T> {
  UnionBenchmark(super.setFactory, super.items, [super.name = 'union']);

  @override
  void run() => set.union(other);
}

class IntersectionBenchmark<S extends Set<T>, T>
    extends BinaryOpBenchmark<S, T> {
  IntersectionBenchmark(super.setFactory, super.items,
      [super.name = 'intersection']);

  @override
  void run() => set.intersection(other);
}

class DifferenceBenchmark<S extends Set<T>, T> extends BinaryOpBenchmark<S, T> {
  DifferenceBenchmark(super.setFactory, super.items,
      [super.name = 'difference']);

  @override
  void run() => set.difference(other);
}

class ContainsBenchmark<S extends Set<T>, T> extends UnaryOpBenchmark<S, T> {
  ContainsBenchmark(super.setFactory, super.items, [super.name = 'contains']);

  @override
  void run() => set.contains(items[noOfItems ~/ 2]);
}
