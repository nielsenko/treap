import 'dart:math';

extension ListEx<T> on List<T> {
  void mix([int seed = 42]) => shuffle(Random(seed));
}
