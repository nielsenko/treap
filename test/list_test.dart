// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause

import 'package:treap/treap.dart';
import 'package:test/scaffolding.dart';
import 'package:checks/checks.dart';

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
        check(list).deepEquals([0]);
        list.add(1);
        check(list).deepEquals([0, 1]);
        list.add(2);
        check(list).deepEquals([0, 1, 2]);
      });

      test('addAll', () {
        final list = listFactory();
        list.addAll([0, 1]);
        check(list).deepEquals([0, 1]);
      });

      test('insert', () {
        final list = listFactory();
        check(() => list.insert(1, 1)).throws<RangeError>(); // cannot leave gap
        list.insert(0, 0); // okay to insert just after last element (no gap)
        check(list).deepEquals([0]);
        list.addAll([1, 2]);
        check(list).deepEquals([0, 1, 2]);
        list.insert(1, 42);
        check(list).deepEquals([0, 42, 1, 2]);
        list.insert(list.length, 3);
        check(list).deepEquals([0, 42, 1, 2, 3]);
      });

      test('index', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        check(list[0]).equals(0);
        check(list[1]).equals(1);
        check(list[2]).equals(2);
        check(() => list[3]).throws<RangeError>();
      });

      test('removeAt', () {
        final list = listFactory();
        check(() => list.removeAt(0)).throws<RangeError>();
        list.add(42);
        list.add(1);
        check(list).deepEquals([42, 1]);
        list.removeAt(0);
        check(list).deepEquals([1]);
        check(() => list.removeAt(list.length)).throws<RangeError>();
      });
      test('length', () {
        final list = listFactory();
        check(list.length).equals(0);
        list.add(0);
        check(list.length).equals(1);
        list.add(1);
        check(list.length).equals(2);
      });

      test('sublist', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        check(list.sublist(1)).deepEquals([1, 2]);
        check(list.sublist(1, 2)).deepEquals([1]);
      });

      test('getRange', () {
        final list = listFactory();
        list.addAll([0, 1, 2, 3]);
        check(list).deepEquals([0, 1, 2, 3]);
        check(list.getRange(1, 3)).deepEquals([1, 2]);
        check(list.getRange(1, 2)).deepEquals([1]);
      });

      test('clear', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        list.clear();
        check(list).deepEquals(<int>[]);
      });

      test('remove', () {
        final list = listFactory();
        list.addAll([0, 42, 2]);
        check(list.remove(1)).isFalse();
        check(list.remove(42)).isTrue();
        check(list).deepEquals([0, 2]);
        check(list.remove(1)).isFalse();
      });

      test('removeLast', () {
        final list = listFactory();
        list.addAll([0, 42, 2]);
        check(list.removeLast()).equals(2);
        check(list).deepEquals([0, 42]);
        check(list.removeLast()).equals(42);
        check(list).deepEquals([0]);
        check(list.removeLast()).equals(0);
        check(list).deepEquals(<int>[]);
        check(() => list.removeLast()).throws<RangeError>();
      });

      test('removeRange', () {
        final list = listFactory();
        list.addAll([0, 1, 2, 3, 4]);
        check(() => list.removeRange(3, 6)).throws<RangeError>(); // 6 > 5
        list.removeRange(1, 3);
        check(list).deepEquals([0, 3, 4]);
        list.removeRange(1, 2);
        check(list).deepEquals([0, 4]);
        list.removeRange(0, 2);
        check(list).deepEquals(<int>[]);
      });

      test('replaceRange', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        list.replaceRange(1, 2, [3, 4]);
        check(list).deepEquals([0, 3, 4, 2]);
      });

      test('take', () {
        final list = listFactory();
        check(() => list.take(-1)).throws<RangeError>();
        list.addAll([0, 1, 2]);
        check(list.take(0)).deepEquals(<int>[]);
        check(list.take(1)).deepEquals([0]);
        check(list.take(2)).deepEquals([0, 1]);
        check(list.take(6)).deepEquals([0, 1, 2]);
      });

      test('skip', () {
        final list = listFactory();
        check(() => list.skip(-1)).throws<RangeError>();
        list.addAll([0, 1, 2]);
        check(list).deepEquals([0, 1, 2]);
        check(list.skip(0)).deepEquals([0, 1, 2]);
        check(list.skip(1)).deepEquals([1, 2]);
        check(list.skip(2)).deepEquals([2]);
        check(list.skip(6)).deepEquals(<int>[]);
      });

      test('toList', () {
        final list = listFactory();
        list.addAll([0, 1, 2]);
        final copy = list.toList();
        list.add(3);
        check(copy).deepEquals([0, 1, 2]);
        check(list).deepEquals([0, 1, 2, 3]);
      });
    });
  }
}
