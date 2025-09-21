// create tests covering all the existing features of the `ImplicitTreap` class.

import 'package:test/scaffolding.dart';
import 'package:checks/checks.dart';
import 'package:treap/src/implicit_treap.dart';

void main() {
  group('ImplicitTreap', () {
    test('insert', () {
      final t = ImplicitTreap<int>.empty();
      final t1 = t.insert(0, 1);
      check(t1.size).equals(1);
      check(t1[0]).equals(1);
      final t2 = t1.insert(0, 2);
      check(t2.size).equals(2);
      check(t2[0]).equals(2);
      check(t2[1]).equals(1);
      final t3 = t2.insert(1, 3);
      check(t3.size).equals(3);
      check(t3[0]).equals(2);
      check(t3[1]).equals(3);
      check(t3[2]).equals(1);
      final t4 = t3.insert(42, 4);
      check(t4.size).equals(4);
      check(t4[3]).equals(4); // 4 is inserted at the end, not index 42
    });

    test('remove', () {
      final t = ImplicitTreap<int>.empty();
      final t1 = t.insert(0, 1).insert(0, 2).insert(1, 3);
      final t2 = t1.remove(1);
      final t3 = t1.remove(42);
      check(t1).equals(t3);
      check(t3.size).equals(3);
      check(t2.size).equals(2);
      check(t2[0]).equals(2);
      check(t2[1]).equals(1);
    });

    test('take', () {
      final t = ImplicitTreap<int>.empty();
      final t1 = t.insert(0, 1).insert(0, 2).insert(1, 3);
      final t2 = t1.take(2);
      check(t2.size).equals(2);
      check(t2[0]).equals(2);
      check(t2[1]).equals(3);
      check(() => t1.take(-1)).throws<RangeError>();
    });

    test('skip', () {
      final t = ImplicitTreap<int>.empty();
      final t1 = t.insert(0, 1).insert(0, 2).insert(1, 3);
      final t2 = t1.skip(1);
      check(t2.size).equals(2);
      check(t2[0]).equals(3);
      check(t2[1]).equals(1);
    });

    test('values', () {
      final t = ImplicitTreap<int>.empty();
      final t1 = t.insert(0, 1).insert(0, 2).insert(1, 3);
      check(t1.values).deepEquals([2, 3, 1]);
    });
  });
}
