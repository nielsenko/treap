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
