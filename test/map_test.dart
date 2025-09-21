// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/treap.dart';
import 'package:test/scaffolding.dart';
import 'package:checks/checks.dart';

int _compare(int a, int b) => a - b;
void main() {
  group('TreapMap', () {
    test('add', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      check(tm.length).equals(3);
      check(tm[1]).equals('one');
      check(tm[2]).equals('two');
      check(tm[3]).equals('three');
    });

    test('update', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      tm[2] = 'new two';
      tm[3] = 'new three';

      check(tm.length).equals(3);
      check(tm[1]).equals('one');
      check(tm[2]).equals('new two');
      check(tm[3]).equals('new three');
    });

    test('remove', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      tm.remove(2);

      check(tm.length).equals(2);
      check(tm.containsKey(2)).isFalse();
      check(tm[1]).equals('one');
      check(tm[3]).equals('three');
    });

    test('contains', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      check(tm.containsKey(1)).isTrue();
      check(tm.containsKey(4)).isFalse();
    });

    test('iterate', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      final keys = <int>[];
      final values = <String>[];

      for (final entry in tm.entries) {
        keys.add(entry.key);
        values.add(entry.value);
      }

      check(keys).deepEquals([1, 2, 3]);
      check(values).deepEquals(['one', 'two', 'three']);
    });

    test('clear', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';
      check(tm.length).isGreaterThan(0);
      check(tm.isNotEmpty).isTrue();

      tm.clear();

      check(tm.length).equals(0);
      check(tm.isEmpty).isTrue();
    });

    test('forEach', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      final keys = <int>[];
      final values = <String>[];

      tm.forEach((key, value) {
        keys.add(key);
        values.add(value);
      });

      check(keys).deepEquals([1, 2, 3]);
      check(values).deepEquals(['one', 'two', 'three']);
    });

    test('isEmpty', () {
      final tm = TreapMap<int, String>(_compare);
      check(tm.isEmpty).isTrue();
      tm[1] = 'one';
      check(tm.isEmpty).isFalse();
    });

    test('keys', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      final keys = tm.keys.toList();
      check(keys).deepEquals([1, 2, 3]);
    });

    test('values', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      final values = tm.values.toList();
      check(values).deepEquals(['one', 'two', 'three']);
    });
  });
}
