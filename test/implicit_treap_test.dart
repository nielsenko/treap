// create tests covering all the existing features of the `ImplicitTreap` class.

import 'package:test/test.dart';
import 'package:treap/src/implicit_treap.dart';

void main() {
  group('ImplicitTreap', () {
    test('insert', () {
      final t = ImplicitTreap<int>.empty();
      final t1 = t.insert(0, 1);
      expect(t1.size, 1);
      expect(t1[0], 1);
      final t2 = t1.insert(0, 2);
      expect(t2.size, 2);
      expect(t2[0], 2);
      expect(t2[1], 1);
      final t3 = t2.insert(1, 3);
      expect(t3.size, 3);
      expect(t3[0], 2);
      expect(t3[1], 3);
      expect(t3[2], 1);
      final t4 = t3.insert(42, 4);
      expect(t4.size, 4);
      expect(t4[3], 4); // 4 is inserted at the end, not index 42
    });

    test('remove', () {
      final t = ImplicitTreap<int>.empty();
      final t1 = t.insert(0, 1).insert(0, 2).insert(1, 3);
      final t2 = t1.remove(1);
      final t3 = t1.remove(42);
      expect(t1, t3);
      expect(t3.size, 3);
      expect(t2.size, 2);
      expect(t2[0], 2);
      expect(t2[1], 1);
    });

    test('take', () {
      final t = ImplicitTreap<int>.empty();
      final t1 = t.insert(0, 1).insert(0, 2).insert(1, 3);
      final t2 = t1.take(2);
      expect(t2.size, 2);
      expect(t2[0], 2);
      expect(t2[1], 3);
      expect(() => t1.take(-1), throwsRangeError);
    });

    test('skip', () {
      final t = ImplicitTreap<int>.empty();
      final t1 = t.insert(0, 1).insert(0, 2).insert(1, 3);
      final t2 = t1.skip(1);
      expect(t2.size, 2);
      expect(t2[0], 3);
      expect(t2[1], 1);
    });

    test('values', () {
      final t = ImplicitTreap<int>.empty();
      final t1 = t.insert(0, 1).insert(0, 2).insert(1, 3);
      expect(t1.values, [2, 3, 1]);
    });
  });
}
