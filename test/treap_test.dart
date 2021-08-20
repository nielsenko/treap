import 'dart:math';

import 'package:treap/src/node.dart';
import 'package:treap/treap.dart';
import 'package:test/test.dart';

void main() {
  group('Treap', () {
    test('insert, erase, build, iterate', () {
      final x = Treap<num>.empty().insert(1);
      final y = x.insert(1);
      expect(x, y);
      final z = y.upsert(1);
      expect(y, isNot(z)); // upsert gives new Treap, even for existing items

      // Be aware, that chaining with .. operator probably don't do what you want
      expect((x..insert(2)..insert(3)).values, [1]);

      final big = Treap<num>.build([9, 8, 7, 6, 1, 2, 3, 4, 5]..shuffle());
      expect(big.values, [1, 2, 3, 4, 5, 6, 7, 8, 9]);

      expect(big.erase(1).erase(0).erase(5).values, [2, 3, 4, 6, 7, 8, 9]);

      final w = Treap<num>(1);
      expect(x, isNot(w)); // equal items does not imply equality
    });

    test('intersect', () {
      expect(
        Treap.build(['foo', 'bar']).intersect(Treap('bar')).values,
        Treap('bar').values,
      );
    });

    test('union', () {
      expect(
        Treap('foo').union(Treap('bar')).values,
        Treap.build(['foo', 'bar']).values,
      );
    });

    test('difference', () {
      expect(
        Treap.build(['foo', 'bar']).difference(Treap('foo')).values,
        Treap('bar').values,
      );
    });

    test('rank, select', () {
      final top = Treap<num>.build([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle());
      expect(top.values, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(top.values.map((i) => top.rank(i)), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].fold<bool>(true, (acc, i) => acc && top.select(i) == i), isTrue);
    });
  });

  group('Node', () {
    final rnd = Random(42 ^ 42);
    Node<num> node(num value) => Node<num>(value, rnd.nextInt(1 << 32));

    test('upsert, find, erase, inOrder', () {
      final first = node(1);
      final again = first.fastAdd(node(1));
      final second = first.fastAdd(node(2));
      final third = second.fastAdd(node(3));
      final another = third.fastAdd(node(3));
      final forth = third.fastAdd(node(0));

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

      final fifth = forth.fastErase(0);
      expect(fifth!.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(identical(third, fifth), false);

      expect(forth.fastErase(2)!.inOrder().map((n) => n.item), [0, 1, 3]);
    });

    test('rank, select', () {
      final top = [1, 2, 3, 4, 5, 6, 7, 8, 9].reversed.fold<Node<num>>(node(0), (acc, i) => acc.fastAdd(node(i)));
      expect(top.inOrder().map((n) => n.item), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(top.inOrder().map((n) => top.rank(n.item)), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(top.rank(-1), 0); // -1 goes before all
      expect(top.rank(100), 10); // 100 goes after all
      expect([0, 1, 2, 3, 4, 5, 6, 7, 8, 9].fold<bool>(true, (acc, i) => acc && top.select(i).item == i), isTrue);
    });
  });
}
