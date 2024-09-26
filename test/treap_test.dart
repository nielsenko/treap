// Copyright 2021 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:math';

import 'package:treap/src/immutable_node.dart';
import 'package:treap/src/node.dart';
import 'package:treap/treap.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('Treap', () {
    group('creation', () {
      test('add, erase, build', () {
        final x = Treap<num>() + 1;
        final y = x.add(1);
        final z = x.addOrUpdate(1);
        expect(x, y);
        expect(x, isNot(z));

        // Be aware, that chaining with .. operator probably don't do what you want
        x
          ..add(2)
          ..add(3);
        expect(x.values, [1]);

        final big = Treap<num>.of([9, 8, 7, 6, 1, 2, 3, 4, 5]..mix());
        expect(big.values, [1, 2, 3, 4, 5, 6, 7, 8, 9]);

        expect(big.remove(1).remove(0).remove(5).values, [2, 3, 4, 6, 7, 8, 9]);

        final w = Treap<num>.of([1]);
        expect(x, isNot(w)); // equal items does not imply equality
      });

      test('empty', () {
        final t = Treap<String>();
        expect(t.isEmpty, isTrue);
        expect(t.values, const <String>[]);
      });

      test('duplicates', () {
        final t = Treap<num>.of([1, 1, 1, 1, 1]);
        expect(t.values, [1]);
      });
    });

    group('retrieval', () {
      test('find, has, rank, select', () {
        const max = 1000;
        final items = [for (int i = 0; i < max; ++i) i]..mix();
        final t = Treap<num>.of(items);
        for (final i in items) {
          expect(t.find(i), isNotNull);
          expect(t.rank(t.find(i)!), i);
          expect(t.has(i), isTrue);
          expect(t[t.rank(i)], i);
        }
        final foreigners = [for (int i = max; i < 2 * max; ++i) i]..mix();
        for (final i in foreigners) {
          expect(t.find(i), isNull);
          expect(t.rank(i), max);
          expect(t.has(i), isFalse);
          expect(() => t[t.rank(i)], throwsRangeError);
        }
        final empty = items.fold(t, (acc, i) => acc.remove(i));
        expect(empty.isEmpty, isTrue);
      });

      test('rank, select', () {
        final top = Treap<num>.of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
        expect(top.values, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
        expect(
            top.values.map((i) => top.rank(i)), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
        expect(
            [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                .fold(true, (acc, i) => acc && top.select(i) == i),
            isTrue);
      });

      test('select when empty', () {
        final empty = Treap<num>();
        expect(() => empty.select(0), throwsRangeError);
      });
    });

    group('iterator', () {
      test('values', () {
        final t = Treap<num>.of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
        expect(t.values, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      });

      test('take, skip', () {
        final t = Treap.of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
        for (var i = 0; i < t.size + 10; ++i) {
          expect(t.take(i).values, t.values.take(i));
          expect(t.skip(i).values, t.values.skip(i));
        }
        // same exception on negative input, as iterator
        expect(() => t.values.take(-1), throwsRangeError);
        expect(() => t.take(-1), throwsRangeError);
        expect(() => t.values.skip(-1), throwsRangeError);
        expect(() => t.skip(-1), throwsRangeError);
      });

      test('first, last, firstOrDefault, lastOrDefault', () {
        // same exception on empty treap, as on empty iterator
        final empty = Treap<num>();
        expect(() => empty.values.first, throwsStateError);
        expect(() => empty.first, throwsStateError);
        expect(empty.firstOrDefault, null);
        expect(() => empty.values.last, throwsStateError);
        expect(() => empty.last, throwsStateError);
        expect(empty.lastOrDefault, null);

        final single = Treap<num>.of([1]);
        expect(single.first, single.last);
        expect(single.first, single.firstOrDefault);
        expect(single.first, single.lastOrDefault);

        final many = Treap<num>.of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
        expect(many.first, many.values.first);
        expect(many.first, 0);
        expect(many.last, many.values.last);
        expect(many.last, 9);
      });

      test('prev, next', () {
        final t = Treap<num>.of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
        final l = t.values.toList();
        for (var i = 1; i < l.length - 1; ++i) {
          expect(t.prev(t.select(i)), l[i - 1]);
          expect(t.next(t.select(i)), l[i + 1]);
        }
        expect(() => t.prev(0), throwsRangeError);
        expect(() => t.next(t.last), throwsRangeError);
      });
    });

    group('set algebra', () {
      final x = Treap.of(['foo', 'bar']);
      final y = Treap.of(['bar', 'mitzvah']);

      test('union', () {
        expect(x.union(y).values, ['bar', 'foo', 'mitzvah']);
        expect((x | y).values, ['bar', 'foo', 'mitzvah']);
      });

      test('intersection', () {
        expect(x.intersection(y).values, ['bar']);
        expect((x & y).values, ['bar']);
      });

      test('difference', () {
        expect(x.difference(y).values, ['foo']);
        expect((x - y).values, ['foo']);
      });

      test('performance', () {
        final rnd = Random(42);
        const max = 1000;
        final x = {for (int i = 0; i < max; ++i) rnd.nextInt(max)};
        final y = {for (int i = 0; i < max; ++i) rnd.nextInt(max)};

        final tx = Treap<num>.of(x);
        final ty = Treap<num>.of(y);

        expect((tx | ty).values, x.union(y));
        expect((tx & ty).values, x.intersection(y));
        expect((tx - ty).values, x.difference(y));
      });
    });
  });

  group('Node', () {
    final rnd = Random(42);
    ImmutableNode<int> node(int value) =>
        ImmutableNode<int>(value, rnd.nextInt(1 << 32));

    final ctx = NodeContext(
      Comparable.compare as Comparator<int>,
      node,
    );

    test('add, find, erase, inOrder', () {
      final first = node(1);
      final again = upsert(first, 1, true, ctx);
      final second = upsert(first, 2, true, ctx);
      final third = upsert(second, 3, true, ctx);
      final another = upsert(second, 3, true, ctx);
      final forth = upsert(third, 0, true, ctx);

      expect(first.inOrder().map((n) => n.item), [1]);
      expect(again.inOrder().map((n) => n.item), [1]);
      expect(identical(first, again), false);
      expect(second.inOrder().map((n) => n.item), [1, 2]);
      expect(third.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(another.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(identical(third, another), false);
      expect(forth.inOrder().map((n) => n.item), [0, 1, 2, 3]);

      expect(find(first, 1, ctx), isNotNull);
      expect(find(first, 2, ctx), isNull);

      expect(find(second, 1, ctx), isNotNull);
      expect(find(second, 2, ctx), isNotNull);

      final fifth = erase(forth, 0, ctx);
      expect(fifth!.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(identical(third, fifth), false);

      expect(
        erase(forth, 2, ctx)!.inOrder().map((n) => n.item),
        [0, 1, 3],
      );
    });

    test('rank, select', () {
      final top = [1, 2, 3, 4, 5, 6, 7, 8, 9]
          .reversed
          .fold(node(0), (acc, i) => upsert(acc, i, true, ctx));
      expect(top.inOrder().map((n) => n.item), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(top.inOrder().map((n) => rank(top, n.item, ctx)),
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(rank(top, -1, ctx), 0); // -1 goes before all
      expect(rank(top, 100, ctx), 10); // 100 goes after all
      expect(
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
              .fold(true, (acc, i) => acc && select(top, i, ctx).item == i),
          isTrue);
    });

    test('preOrder, inOrder, postOrder', () {
      final items = [5, 6, 3, 9, 1, 8, 2, 4, 7]; // evil order
      var count = 0;
      node(int i) => ImmutableNode(i, count++);
      final ctx = NodeContext(
        Comparable.compare as Comparator<int>,
        node,
      );
      final top = items.fold(
        ImmutableNode(0, 0), // will have same priority (5, 0)
        (acc, i) => upsert(acc, i, true, ctx),
      );
      expect(
        top.inOrder().map((n) => n.item),
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      );
      expect(
        top.preOrder().map((n) => n.item),
        [7, 4, 2, 1, 0, 3, 6, 5, 8, 9],
      );
      expect(
        top.postOrder().map((n) => n.item),
        [0, 1, 3, 2, 5, 6, 4, 9, 8, 7],
      );
    });
  });
}
