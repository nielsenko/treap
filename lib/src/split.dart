// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'node.dart';

typedef SplitTuple<T> = ({Node<T>? low, Node<T>? middle, Node<T>? high});
extension type const Split<T>(SplitTuple<T> tuple) {
  const Split.empty() : this((low: null, middle: null, high: null));

  Split<T> withLow(Node<T>? low) =>
      Split((low: low, middle: tuple.middle, high: tuple.high));

  Split<T> withMiddle(Node<T>? middle) =>
      Split((low: tuple.low, middle: middle, high: tuple.high));

  Split<T> withHigh(Node<T>? high) =>
      Split((low: tuple.low, middle: tuple.middle, high: high));

  Node<T>? get low => tuple.low;
  Node<T>? get middle => tuple.middle;
  Node<T>? get high => tuple.high;

  Node<T>? join() {
    final (low: l, middle: m, high: h) = tuple;
    if (m == null) return l.join(h);
    if (m.left == l && m.right == h) return m; // reuse
    return l.join(m.withoutChildren()).join(h);
  }

  void checkInvariant(Comparator<T> compare) {
    assert(() {
      final (low: l, middle: m, high: h) = tuple;
      assert(m == null || (h == null || compare(m.item, h.min) < 0));
      assert(m == null || (l == null || compare(l.max, m.item) < 0));
      assert((l == null || h == null) || compare(l.max, h.min) < 0);
      return true;
    }());
  }
}
