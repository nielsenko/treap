// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/treap.dart';
import 'package:test/scaffolding.dart';
import 'package:checks/checks.dart';

int _compare(int a, int b) => a - b;

void main() {
  group('TreapSet', () {
    test('add', () {
      final t = TreapSet(_compare);
      t.add(1);
      check(t.add(1)).isFalse();
      check(t).deepEquals([1]);
      t.add(3);
      check(t).deepEquals([1, 3]);
      t.add(2);
      check(t).deepEquals([1, 2, 3]);
      t.addAll([9, 8, 7]);
      check(t).deepEquals([1, 2, 3, 7, 8, 9]);
    });

    test('remove', () {
      final t = TreapSet.of([1, 2, 3, 4, 5], _compare);
      check(t.remove(0)).isFalse();
      check(t.remove(1)).isTrue();
      check(t).deepEquals([2, 3, 4, 5]);
      check(t.remove(5)).isTrue();
      check(t).deepEquals([2, 3, 4]);
      check(t.remove(5)).isFalse();
    });

    test('contains', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.contains(0)).isFalse();
      check(t.contains(1)).isTrue();
      check(t.contains(5)).isTrue();
      check(t.contains(6)).isFalse();
    });

    test('lookup', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.lookup(0)).isNull();
      check(t.lookup(1)).equals(1);
      check(t.lookup(5)).equals(5);
      check(t.lookup(6)).isNull();
    });

    test('intersection', () {
      final a = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      final b = TreapSet(_compare)..addAll([3, 4, 5, 6, 7]);
      final c = a.intersection(b);
      check(c).deepEquals([3, 4, 5]);
    });

    test('difference', () {
      final a = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      final b = TreapSet(_compare)..addAll([3, 4, 5, 6, 7]);
      final c = a.difference(b);
      check(c).deepEquals([1, 2]);
    });

    test('union', () {
      final a = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      final b = TreapSet(_compare)..addAll([3, 4, 5, 6, 7]);
      final c = a.union(b);
      check(c).deepEquals([1, 2, 3, 4, 5, 6, 7]);
    });

    test('length', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.toList().length).equals(5);
      check(t.length).equals(5);
    });

    test('toSet', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      final t2 = t.toSet();
      t2.add(6);
      check(t).deepEquals({1, 2, 3, 4, 5});
      check(t2).deepEquals({1, 2, 3, 4, 5, 6});
    });

    test('clear', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      t.clear();
      check(t).deepEquals(<int>[]);
    });

    test('elementAt', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.elementAt(0)).equals(1);
      check(t.elementAt(4)).equals(5);
    });

    test('first', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.first).equals(1);
    });

    test('isEmpty', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.isEmpty).isFalse();
      t.clear();
      check(t.isEmpty).isTrue();
    });

    test('last', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.last).equals(5);
    });

    test('skip', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.skip(0)).deepEquals([1, 2, 3, 4, 5]);
      check(t.skip(2)).deepEquals([3, 4, 5]);
      check(t.skip(6)).deepEquals(<int>[]);
    });

    test('skipWhile', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.skipWhile((e) => e < 3)).deepEquals([3, 4, 5]);
      check(t.skipWhile((e) => e < 6)).deepEquals(<int>[]);
    });

    test('take', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.take(0)).deepEquals(<int>[]);
      check(t.take(2)).deepEquals([1, 2]);
      check(t.take(6)).deepEquals([1, 2, 3, 4, 5]);
    });

    test('takeWhile', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      check(t.takeWhile((e) => e < 3)).deepEquals([1, 2]);
      check(t.takeWhile((e) => e < 6)).deepEquals([1, 2, 3, 4, 5]);
    });

    test('iterator', () {
      final t = TreapSet(_compare)..addAll([1, 2, 3, 4, 5]);
      final it = t.iterator;
      check(it.moveNext()).isTrue();
      check(it.current).equals(1);
      check(it.moveNext()).isTrue();
      check(it.current).equals(2);
      check(it.moveNext()).isTrue();
      check(it.current).equals(3);
      check(it.moveNext()).isTrue();
      check(it.current).equals(4);
      check(it.moveNext()).isTrue();
      check(it.current).equals(5);
      check(it.moveNext()).isFalse();
    });

    test("add don't update", () {
      final s = TreapSet.of([(1, 2)], (a, b) => a.$1 - b.$1);
      check(s.add((1, 3))).isFalse();
      check(s.lookup((1, 0))).equals((1, 2));
    });
  });
}
