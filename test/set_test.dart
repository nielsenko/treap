// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/treap.dart';
import 'package:test/test.dart';

int _compare(int a, int b) => a - b;

void main() {
  group('TreapSet', () {
    test('add', () {
      final t = TreapSet(_compare);
      t.add(1);
      expect(t.add(1), isFalse);
      expect(t, [1]);
      t.add(3);
      expect(t, [1, 3]);
      t.add(2);
      expect(t, [1, 2, 3]);
      t.addAll([9, 8, 7]);
      expect(t, [1, 2, 3, 7, 8, 9]);
    });

    test('remove', () {
      final t = TreapSet.of([1, 2, 3, 4, 5], _compare);
      expect(t.remove(0), isFalse);
      expect(t.remove(1), isTrue);
      expect(t, [2, 3, 4, 5]);
      expect(t.remove(5), isTrue);
      expect(t, [2, 3, 4]);
      expect(t.remove(5), isFalse);
    });

    test('contains', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.contains(0), isFalse);
      expect(t.contains(1), isTrue);
      expect(t.contains(5), isTrue);
      expect(t.contains(6), isFalse);
    });

    test('lookup', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.lookup(0), isNull);
      expect(t.lookup(1), 1);
      expect(t.lookup(5), 5);
      expect(t.lookup(6), isNull);
    });

    test('intersection', () {
      final a = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      final b = TreapSet(_compare)..addAll([3, 4, 5, 6, 7]);
      final c = a.intersection(b);
      expect(c, [3, 4, 5]);
    });

    test('difference', () {
      final a = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      final b = TreapSet(_compare)..addAll([3, 4, 5, 6, 7]);
      final c = a.difference(b);
      expect(c, [1, 2]);
    });

    test('union', () {
      final a = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      final b = TreapSet(_compare)..addAll([3, 4, 5, 6, 7]);
      final c = a.union(b);
      expect(c, [1, 2, 3, 4, 5, 6, 7]);
    });

    test('length', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.toList().length, 5);
      expect(t.length, 5);
    });

    test('toSet', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      final t2 = t.toSet();
      t2.add(6);
      expect(t, {1, 2, 3, 4, 5});
      expect(t2, {1, 2, 3, 4, 5, 6});
    });

    test('clear', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      t.clear();
      expect(t, <int>[]);
    });

    test('elementAt', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.elementAt(0), 1);
      expect(t.elementAt(4), 5);
    });

    test('first', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.first, 1);
    });

    test('isEmpty', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.isEmpty, isFalse);
      t.clear();
      expect(t.isEmpty, isTrue);
    });

    test('last', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.last, 5);
    });

    test('skip', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.skip(0), [1, 2, 3, 4, 5]);
      expect(t.skip(2), [3, 4, 5]);
      expect(t.skip(6), <int>[]);
    });

    test('skipWhile', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.skipWhile((e) => e < 3), [3, 4, 5]);
      expect(t.skipWhile((e) => e < 6), <int>[]);
    });

    test('take', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.take(0), <int>[]);
      expect(t.take(2), [1, 2]);
      expect(t.take(6), [1, 2, 3, 4, 5]);
    });

    test('takeWhile', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      expect(t.takeWhile((e) => e < 3), [1, 2]);
      expect(t.takeWhile((e) => e < 6), [1, 2, 3, 4, 5]);
    });

    test('iterator', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      final it = t.iterator;
      expect(it.moveNext(), isTrue);
      expect(it.current, 1);
      expect(it.moveNext(), isTrue);
      expect(it.current, 2);
      expect(it.moveNext(), isTrue);
      expect(it.current, 3);
      expect(it.moveNext(), isTrue);
      expect(it.current, 4);
      expect(it.moveNext(), isTrue);
      expect(it.current, 5);
      expect(it.moveNext(), isFalse);
    });

    test("add don't update", () {
      final s = TreapSet.of([(1, 2)], (a, b) => a.$1 - b.$1);
      expect(s.add((1, 3)), isFalse);
      expect(s.lookup((1, 0)), (1, 2));
    });
  });
}
