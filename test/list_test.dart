// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:treap/treap.dart';
import 'package:test/test.dart';

void main() {
  for (final listFactory in {
    () => <int>[],
    () => TreapList<int>(),
  }) {
    final listType = listFactory().runtimeType;
    group(listType, () {
      test('add', () {
        final list = listFactory();
        list.add(0);
        expect(list, [0]);
        list.add(1);
        expect(list, [0, 1]);
        list.add(2);
        expect(list, [0, 1, 2]);
      });

      test('addAll', () {
        final list = listFactory();
        list.addAll([0, 1]);
        expect(list, [0, 1]);
      });

      test('insert', () {
        final list = listFactory();
        expect(() => list.insert(1, 1), throwsRangeError); // cannot leave gap
        list.insert(0, 0); // okay to insert just after last element (no gap)
        expect(list, [0]);
        list.addAll([1, 2]);
        expect(list, [0, 1, 2]);
        list.insert(1, 42);
        expect(list, [0, 42, 1, 2]);
        list.insert(list.length, 3);
        expect(list, [0, 42, 1, 2, 3]);
      });

      test('index', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        expect(list[0], 0);
        expect(list[1], 1);
        expect(list[2], 2);
        expect(() => list[3], throwsRangeError);
      });

      test('removeAt', () {
        final list = listFactory();
        expect(() => list.removeAt(0), throwsRangeError);
        list.add(42);
        list.add(1);
        expect(list, [42, 1]);
        list.removeAt(0);
        expect(list, [1]);
        expect(() => list.removeAt(list.length), throwsRangeError);
      });
      test('length', () {
        final list = listFactory();
        expect(list.length, 0);
        list.add(0);
        expect(list.length, 1);
        list.add(1);
        expect(list.length, 2);
      });

      test('sublist', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        expect(list.sublist(1), [1, 2]);
        expect(list.sublist(1, 2), [1]);
      });

      test('getRange', () {
        final list = listFactory();
        list.addAll([0, 1, 2, 3]);
        expect(list, [0, 1, 2, 3]);
        expect(list.getRange(1, 3), [1, 2]);
        expect(list.getRange(1, 2), [1]);
      });

      test('clear', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        list.clear();
        expect(list, <int>[]);
      });

      test('remove', () {
        final list = listFactory();
        list.addAll([0, 42, 2]);
        expect(list.remove(1), isFalse);
        expect(list.remove(42), isTrue);
        expect(list, [0, 2]);
        expect(list.remove(1), isFalse);
      });

      test('removeLast', () {
        final list = listFactory();
        list.addAll([0, 42, 2]);
        expect(list.removeLast(), 2);
        expect(list, [0, 42]);
        expect(list.removeLast(), 42);
        expect(list, [0]);
        expect(list.removeLast(), 0);
        expect(list, <int>[]);
        expect(() => list.removeLast(), throwsRangeError);
      });

      test('removeRange', () {
        final list = listFactory();
        list.addAll([0, 1, 2, 3, 4]);
        expect(() => list.removeRange(3, 6), throwsRangeError); // 6 > 5
        list.removeRange(1, 3);
        expect(list, [0, 3, 4]);
        list.removeRange(1, 2);
        expect(list, [0, 4]);
        list.removeRange(0, 2);
        expect(list, <int>[]);
      });

      test('replaceRange', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        list.replaceRange(1, 2, [3, 4]);
        expect(list, [0, 3, 4, 2]);
      });

      test('take', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        expect(list.take(0), <int>[]);
        expect(list.take(1), [0]);
        expect(list.take(2), [0, 1]);
        expect(list.take(6), [0, 1, 2]);
      });

      test('skip', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        expect(list, [0, 1, 2]);
        expect(list.skip(0), [0, 1, 2]);
        expect(list.skip(1), [1, 2]);
        expect(list.skip(2), [2]);
        expect(list.skip(6), <int>[]);
      });
    });
  }
}
