// Copyright 2021 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:math';

import 'package:test/scaffolding.dart';
import 'package:checks/checks.dart';
import 'package:treap/src/deeply_immutable/int_node.dart';
import 'package:treap/src/hash.dart';
import 'package:treap/src/immutable_node.dart';
import 'package:treap/treap.dart';

import 'util.dart';

void main() {
  for (final treapFactory in {
    ([Iterable<int>? items]) => Treap<int>.of(items ?? []),
    ([Iterable<int>? items]) => TreapBase<int, ImmutableNode<int>>.of(
        items ?? [], immutableNodeFactory),
    ([Iterable<int>? items]) =>
        TreapBase<int, IntNode>.of(items ?? [], intNodeFactory),
//    ([Iterable<int>? items]) =>
//        TreapBase<int, MutableNode<int>>.of(items ?? [], mutableNodeFactory),
  }) {
    final treapType = treapFactory().runtimeType;

    group('$treapType', () {
      group('creation', () {
        test('add, addOrUpdate, addAll, of(build), and remove', () {
          final x = treapFactory() + 1;
          final y = x.add(1);
          final z = x.addOrUpdate(1);
          check(x).equals(y);
          check(x).not((it) => it.equals(z));

          // Be aware, that chaining with .. operator probably don't do what you want
          x
            ..add(2)
            ..add(3);
          check(x.values).deepEquals([1]);

          final many = [1, 2, 3, 4, 5, 6, 7, 8, 9];
          final big = treapFactory(many..mix()); // shuffle,
          final big2 = treapFactory().addAll(many..mix()); // shuffle, then ..
          check(big.values).deepEquals(big2.values);
          check(big.values)
              .deepEquals(many..sort(big.compare)); // .. sort again

          check(big.remove(1).remove(0).remove(5).values)
              .deepEquals([2, 3, 4, 6, 7, 8, 9]);

          final w = treapFactory([1]);
          check(x.values).deepEquals(w.values);
          check(x)
              .not((it) => it.equals(w)); // equal items does not imply equality
        });

        test('empty', () {
          final t = treapFactory();
          check(t.isEmpty).isTrue();
          check(t.values).deepEquals(const <int>[]);
        });

        test('duplicates', () {
          final t = treapFactory([1, 1, 1, 1, 1]);
          check(t.values).deepEquals([1]);
        });

        test('copy', () {
          final t = treapFactory([1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
          final copy = t.copy();
          check(t.values).deepEquals(copy.values);
          check(t).equals(copy); // for an immutable treap, this is true too
          check(identical(t, copy)).isTrue();
        });
      });

      group('retrieval', () {
        test('find, has, rank, select', () {
          const max = 1000;
          final items = [for (int i = 0; i < max; ++i) i]..mix();
          final t = treapFactory(items);
          for (final i in items) {
            check(t.find(i)).isNotNull();
            check(t.rank(t.find(i)!)).equals(i);
            check(t.has(i)).isTrue();
            check(t[t.rank(i)]).equals(i);
          }
          final foreigners = [for (int i = max; i < 2 * max; ++i) i]..mix();
          for (final i in foreigners) {
            check(t.find(i)).isNull();
            check(t.rank(i)).equals(max);
            check(t.has(i)).isFalse();
            check(() => t[t.rank(i)]).throws<RangeError>();
          }
          final empty = items.fold(t, (acc, i) => acc.remove(i));
          check(empty.isEmpty).isTrue();
        });

        test('rank, select', () {
          final top = treapFactory([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
          check(top.values).deepEquals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
          check(top.values.map((i) => top.rank(i)))
              .deepEquals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
          check([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
              .fold(true, (acc, i) => acc && top.select(i) == i)).isTrue();
        });

        test('select when empty', () {
          final empty = treapFactory();
          check(() => empty.select(0)).throws<RangeError>();
        });
      });

      group('iterator', () {
        test('values', () {
          final t = treapFactory([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
          check(t.values).deepEquals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
        });

        test('take, skip', () {
          final t = treapFactory([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
          for (var i = 0; i < t.size + 10; ++i) {
            check(t.take(i).values).deepEquals(t.values.take(i));
            check(t.skip(i).values).deepEquals(t.values.skip(i));
          }
          // same exception on negative input, as iterator
          check(() => t.values.take(-1)).throws<RangeError>();
          check(() => t.take(-1)).throws<RangeError>();
          check(() => t.values.skip(-1)).throws<RangeError>();
          check(() => t.skip(-1)).throws<RangeError>();
        });

        test('first, last, firstOrDefault, lastOrDefault', () {
          // same exception on empty treap, as on empty iterator
          final empty = treapFactory();
          check(() => empty.values.first).throws<StateError>();
          check(() => empty.first).throws<StateError>();
          check(empty.firstOrDefault).isNull();
          check(() => empty.values.last).throws<StateError>();
          check(() => empty.last).throws<StateError>();
          check(empty.lastOrDefault).isNull();

          final single = treapFactory([1]);
          check(single.first).equals(single.last);
          check(single.first).equals(single.firstOrDefault!);
          check(single.first).equals(single.lastOrDefault!);

          final many = treapFactory([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
          check(many.first).equals(many.values.first);
          check(many.first).equals(0);
          check(many.last).equals(many.values.last);
          check(many.last).equals(9);
        });

        test('prev, next', () {
          final t = treapFactory([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]..mix());
          final l = t.values.toList();
          for (var i = 1; i < l.length - 1; ++i) {
            check(t.prev(t.select(i))).equals(l[i - 1]);
            check(t.next(t.select(i))).equals(l[i + 1]);
          }
          check(() => t.prev(0)).throws<RangeError>();
          check(() => t.next(t.last)).throws<RangeError>();
        });
      });

      group('set algebra', () {
        final x = Treap.of(['foo', 'bar']);
        final y = Treap.of(['bar', 'mitzvah']);

        test('union', () {
          check(x.union(y).values).deepEquals(['bar', 'foo', 'mitzvah']);
          check((x | y).values).deepEquals(['bar', 'foo', 'mitzvah']);
        });

        test('intersection', () {
          check(x.intersection(y).values).deepEquals(['bar']);
          check((x & y).values).deepEquals(['bar']);
        });

        test('difference', () {
          check(x.difference(y).values).deepEquals(['foo']);
          check((x - y).values).deepEquals(['foo']);
        });

        test('performance', () {
          final rnd = Random(42);
          const max = 1000;
          final x = {for (int i = 0; i < max; ++i) rnd.nextInt(max)};
          final y = {for (int i = 0; i < max; ++i) rnd.nextInt(max)};

          final tx = Treap.of(x);
          final ty = Treap.of(y);

          check((tx | ty).values).deepEquals(x.union(y).toList()..sort());
          check((tx & ty).values)
              .deepEquals(x.intersection(y).toList()..sort());
          check((tx - ty).values).deepEquals(x.difference(y).toList()..sort());
        });
      });
    });

    group('Node', () {
      ImmutableNode<int> createNode(int value) =>
          ImmutableNode<int>(value, Hash.hash(value, 42));

      final ctx = Comparable.compare as Comparator<int>;

      test('add, find, erase, inOrder', () {
        final first = createNode(1);
        final again = upsert(first, 1, true, ctx, createNode);
        final second = upsert(first, 2, true, ctx, createNode);
        final third = upsert(second, 3, true, ctx, createNode);
        final another = upsert(second, 3, true, ctx, createNode);
        final forth = upsert(third, 0, true, ctx, createNode);

        check(first.inOrder().map((n) => n.item)).deepEquals([1]);
        check(again.inOrder().map((n) => n.item)).deepEquals([1]);
        check(identical(first, again)).isFalse();
        check(second.inOrder().map((n) => n.item)).deepEquals([1, 2]);
        check(third.inOrder().map((n) => n.item)).deepEquals([1, 2, 3]);
        check(another.inOrder().map((n) => n.item)).deepEquals([1, 2, 3]);
        check(identical(third, another)).isFalse();
        check(forth.inOrder().map((n) => n.item)).deepEquals([0, 1, 2, 3]);

        check(find(first, 1, ctx)).isNotNull();
        check(find(first, 2, ctx)).isNull();

        check(find(second, 1, ctx)).isNotNull();
        check(find(second, 2, ctx)).isNotNull();

        final fifth = erase(forth, 0, ctx);
        check(fifth!.inOrder().map((n) => n.item)).deepEquals([1, 2, 3]);
        check(identical(third, fifth)).isFalse();

        check(erase(forth, 2, ctx)!.inOrder().map((n) => n.item))
            .deepEquals([0, 1, 3]);
      });

      test('rank, select', () {
        final top = [1, 2, 3, 4, 5, 6, 7, 8, 9].reversed.fold(
            createNode(0), (acc, i) => upsert(acc, i, true, ctx, createNode));
        check(top.inOrder().map((n) => n.item))
            .deepEquals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
        check(top.inOrder().map((n) => rank(top, n.item, ctx)))
            .deepEquals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
        check(rank(top, -1, ctx)).equals(0); // -1 goes before all
        check(rank(top, 100, ctx)).equals(10); // 100 goes after all
        check([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
            .fold(true, (acc, i) => acc && select(top, i).item == i)).isTrue();
      });

      test('preOrder, inOrder, postOrder', () {
        final items = [5, 6, 3, 9, 1, 8, 2, 4, 7]; // evil order
        var count = 0;
        node(int i) => ImmutableNode(i, count++);
        final ctx = Comparable.compare as Comparator<int>;
        final top = items.fold(
          ImmutableNode(0, 0), // will have same priority (5, 0)
          (acc, i) => upsert(acc, i, true, ctx, node),
        );
        check(top.inOrder().map((n) => n.item))
            .deepEquals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
        check(top.preOrder().map((n) => n.item))
            .deepEquals([7, 4, 2, 1, 0, 3, 6, 5, 8, 9]);
        check(top.postOrder().map((n) => n.item))
            .deepEquals([0, 1, 3, 2, 5, 6, 4, 9, 8, 7]);
      });
    });
  }
}
