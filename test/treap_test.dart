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
        expect(x, isNot(y)); // add gives new Treap, even for existing items

        // Be aware, that chaining with .. operator probably don't do what you want
        expect((x..add(2)..add(3)).values, [1]);

        final big = Treap<num>.build([9, 8, 7, 6, 1, 2, 3, 4, 5]..shuffle());
        expect(big.values, [1, 2, 3, 4, 5, 6, 7, 8, 9]);

        expect(big.erase(1).erase(0).erase(5).values, [2, 3, 4, 6, 7, 8, 9]);

        final w = Treap<num>.build([1]);
        expect(x, isNot(w)); // equal items does not imply equality
      });

      test('empty', () {
        final t = Treap<String>();
        expect(t.isEmpty, isTrue);
        expect(t.values, []);
      });
    });
    group('retrieval', () {
      test('find, has, rank, select', () {
        const max = 1000;
        final items = [for (int i = 0; i < max; ++i) i]..shuffle();
        final t = Treap<num>.build(items);
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
        final empty = items.fold<Treap<num>>(t, (acc, i) => acc.erase(i));
        expect(empty.isEmpty, isTrue);
      });

      test('rank, select', () {
        final top = Treap<num>.build([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle());
        expect(top.values, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
        expect(top.values.map((i) => top.rank(i)), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
        expect([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].fold<bool>(true, (acc, i) => acc && top.select(i) == i), isTrue);
      });
    });

    group('set algebra', () {
      test('union, intersection, difference', () {
        final x = Treap.build(['foo', 'bar']);
        final y = Treap.build(['bar', 'mitzvah']);
        expect(x.intersection(y).values, ['bar']);
        expect(x.union(y).values, ['bar', 'foo', 'mitzvah']);
        expect(x.difference(y).values, ['foo']);
        expect((x & y).values, ['bar']);
        expect((x | y).values, ['bar', 'foo', 'mitzvah']);
        expect((x - y).values, ['foo']);
      });

      test('union', () {
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
  });

  group('Node', () {
    final rnd = Random(42 ^ 42);
    Node<num> node(num value) => Node<num>(value, rnd.nextInt(1 << 32));

    test('add, find, erase, inOrder', () {
      final first = node(1);
      final again = first.add(node(1));
      final second = first.add(node(2));
      final third = second.add(node(3));
      final another = third.add(node(3));
      final forth = third.add(node(0));

      expect(first.inOrder().map((n) => n.item), [1]);
      expect(again.inOrder().map((n) => n.item), [1]);
      expect(identical(first, again), false);
      expect(second.inOrder().map((n) => n.item), [1, 2]);
      expect(third.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(another.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(identical(third, another), false);
      expect(forth.inOrder().map((n) => n.item), [0, 1, 2, 3]);

      expect(first.find(1), isNotNull);
      expect(first.find(2), isNull);

      expect(second.find(1), isNotNull);
      expect(second.find(2), isNotNull);

      final fifth = forth.erase(0);
      expect(fifth!.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(identical(third, fifth), false);

      expect(forth.erase(2)!.inOrder().map((n) => n.item), [0, 1, 3]);
    });

    test('rank, select', () {
      final top = [1, 2, 3, 4, 5, 6, 7, 8, 9].reversed.fold<Node<num>>(node(0), (acc, i) => acc.add(node(i)));
      expect(top.inOrder().map((n) => n.item), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(top.inOrder().map((n) => top.rank(n.item)), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(top.rank(-1), 0); // -1 goes before all
      expect(top.rank(100), 10); // 100 goes after all
      expect([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].fold<bool>(true, (acc, i) => acc && top.select(i).item == i), isTrue);
    });
  });
}
