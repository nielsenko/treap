import 'dart:math';

import 'package:treap/src/node.dart';
import 'package:treap/treap.dart';
import 'package:test/test.dart';

void main() {
  group('Treap', () {
    test('insert, delete, build, iterate', () {
      final x = Treap<num>.empty().insert(1);
      final y = x.insert(1);
      expect(x, y);
      final z = y.upsert(1);
      expect(y, isNot(z)); // upsert gives new Treap, even for existing items

      // Be aware, that chaining with .. operator probably don't do what you want
      expect((x..insert(2)..insert(3)).iterate(), [1]);

      final big = Treap<num>.build([9, 8, 7, 6, 1, 2, 3, 4, 5]);
      expect(big.iterate(), [1, 2, 3, 4, 5, 6, 7, 8, 9]);

      expect(big.delete(1).delete(0).delete(5).iterate(), [2, 3, 4, 6, 7, 8, 9]);

      final w = Treap<num>(1);
      expect(x, isNot(w)); // equal items does not imply equality
    });

    test('intersect', () {
      // TODO: This will fail for multiple reasons
      // 1) The method is not implemented
      // 2) Comparable<Treap<T>> is not implemented, so identical is used
      final treap = Treap('foo');
      expect(treap.intersect(Treap('bar')), Treap<String>.empty());
    });

    test('union', () {
      // TODO: This will fail for multiple reasons
      // 1) The method is not implemented
      // 2) Comparable<Treap<T>> is not implemented, so identical is used
      final treap = Treap('foo');
      expect(treap.union(Treap('bar')), Treap.build(['foo', 'bar']));
    });
  });

  group('Node', () {
    test('upsert, find, delete, inOrder', () {
      final rnd = Random(42 ^ 42);
      Node<num> node(num value) => Node<num>(value, rnd.nextInt(1 << 32));

      final first = node(1);
      final again = first.upsert(node(1));
      final second = first.upsert(node(2));
      final third = second.upsert(node(3));
      final another = third.upsert(node(3));
      final forth = third.upsert(node(0));

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

      final fifth = forth.delete(0);
      expect(fifth!.inOrder().map((n) => n.item), [1, 2, 3]);
      expect(identical(third, fifth), false);

      expect(forth.delete(2)!.inOrder().map((n) => n.item), [0, 1, 3]);
    });
  });
}
