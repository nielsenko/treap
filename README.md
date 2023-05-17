A library implementing a persistent treap data structure for Dart developers.

## Usage

A simple usage example:

```dart
import 'package:test/test.dart';
import 'package:treap/treap.dart';

main() {
  group('Treap', () {
    test('set algebra', () {
      final rnd = Random(42);
      const max = 1000;
      final x = {for (int i = 0; i < max; ++i) rnd.nextInt(max)};
      final y = {for (int i = 0; i < max; ++i) rnd.nextInt(max)};

      final tx = Treap<num>.build(x);
      final ty = Treap<num>.build(y);

      expect((tx | ty).values, x.union(y));
      expect((tx & ty).values, x.intersection(y));
      expect((tx - ty).values, x.difference(y));
    });
  });
}
```

For something more significant see the [todo](example/) flutter app

## Status

![master](https://github.com/nielsenko/treap/actions/workflows/dart.yml/badge.svg?branch=master)
[![codecov](https://codecov.io/gh/nielsenko/treap/branch/master/graph/badge.svg?token=JI1PHY21A5)](https://codecov.io/gh/nielsenko/treap)
