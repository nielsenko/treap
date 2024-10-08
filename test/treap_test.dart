// Copyright 2021 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:math';

import 'package:treap/src/node.dart';
import 'package:treap/treap.dart';
import 'package:test/test.dart';

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

        final big = Treap<num>.of([9, 8, 7, 6, 1, 2, 3, 4, 5]..shuffle());
        expect(big.values, [1, 2, 3, 4, 5, 6, 7, 8, 9]);

        expect(big.erase(1).erase(0).erase(5).values, [2, 3, 4, 6, 7, 8, 9]);

        final w = Treap<num>.of([1]);
        expect(x, isNot(w)); // equal items does not imply equality
      });

      test('empty', () {
        final t = Treap<String>();
        expect(t.isEmpty, isTrue);
        expect(t.values, []);
      });

      test('duplicates', () {
        final t = Treap<num>.of([1, 1, 1, 1, 1]);
        expect(t.values, [1]);
      });
    });

    group('retrieval', () {
      test('find, has, rank, select', () {
        const max = 1000;
        final items = [for (int i = 0; i < max; ++i) i]..shuffle();
        final t = Treap<num>.of(items);
        for (final i in items) {
          expect(t.find(i), isNotNull);
          expect(t.rank(t.find(i)!), i);
          expect(t.has(i), isTrue);
          expect(t[t.rank(i)], i);
        }
        final foreigners = [for (int i = max; i < 2 * max; ++i) i]..shuffle();
        for (final i in foreigners) {
          expect(t.find(i), isNull);
          expect(t.rank(i), max);
          expect(t.has(i), isFalse);
          expect(() => t[t.rank(i)], throwsRangeError);
        }
        final empty = items.fold(t, (acc, i) => acc.erase(i));
        expect(empty.isEmpty, isTrue);
      });

      test('rank, select', () {
        final top = Treap<num>.of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle());
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
        final t = Treap<num>.of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle());
        expect(t.values, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      });

      test('take, skip', () {
        final t = Treap<num>.of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle());
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

        final many = Treap<num>.of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle());
        expect(many.first, many.values.first);
        expect(many.first, 0);
        expect(many.last, many.values.last);
        expect(many.last, 9);
      });

      test('prev, next', () {
        final t = Treap<num>.of([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle());
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
    final rnd = Random(42 ^ 42);
    Node<num> node(num value) =>
        PersistentNode<num>(value, rnd.nextInt(1 << 32));

    test('add, find, erase, inOrder', () {
      final first = node(1);
      final (root: again, old: _) = first.upsert(node(1), Comparable.compare);
      final (root: second, old: _) = first.upsert(node(2), Comparable.compare);
      final (root: third, old: _) = second.upsert(node(3), Comparable.compare);
      final (root: another, old: _) =
          second.upsert(node(3), Comparable.compare);
      final (root: forth, old: _) = third.upsert(node(0), Comparable.compare);

      expect(first.inOrder().map((n) => n.item), [1]);
      expect(again.inOrder().map((n) => n.item), [1]);
      expect(identical(first, again), false);
      expect(second.inOrder().map((n) => n.item), [1, 2]);
      expect(third.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(another.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(identical(third, another), false);
      expect(forth.inOrder().map((n) => n.item), [0, 1, 2, 3]);

      expect(first.find(1, Comparable.compare), isNotNull);
      expect(first.find(2, Comparable.compare), isNull);

      expect(second.find(1, Comparable.compare), isNotNull);
      expect(second.find(2, Comparable.compare), isNotNull);

      final (root: fifth, old: _) = forth.erase(0, Comparable.compare);
      expect(fifth!.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(identical(third, fifth), false);

      expect(
        forth.erase(2, Comparable.compare).root!.inOrder().map((n) => n.item),
        [0, 1, 3],
      );
    });

    test('rank, select', () {
      final top = [1, 2, 3, 4, 5, 6, 7, 8, 9].reversed.fold(
          node(0), (acc, i) => acc.upsert(node(i), Comparable.compare).root);
      expect(top.inOrder().map((n) => n.item), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(top.inOrder().map((n) => top.rank(n.item, Comparable.compare)),
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(top.rank(-1, Comparable.compare), 0); // -1 goes before all
      expect(top.rank(100, Comparable.compare), 10); // 100 goes after all
      expect(
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
              .fold(true, (acc, i) => acc && top.select(i).item == i),
          isTrue);
    });

    test('preOrder, inOrder, postOrder', () {
      // Deterministic shaped treap despite shuffle
      final items = [5, 6, 3, 9, 1, 8, 2, 4, 7]; // evil order
      print(items);
      final top = items.fold<Node<num>>(
        PersistentNode<num>(0, 0), // will have same priority (5,0)
        (acc, i) =>
            acc.upsert(PersistentNode<num>(i, 5 - i), Comparable.compare).root,
      );
      expect(
        top.inOrder().map((n) => n.item),
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      );
      expect(
        top.preOrder().map((n) => n.item),
        [1, 0, 2, 3, 4, 5, 6, 7, 8, 9],
      );
      expect(
        top.postOrder().map((n) => n.item),
        [0, 9, 8, 7, 6, 5, 4, 3, 2, 1],
      );
    });
  });
}
