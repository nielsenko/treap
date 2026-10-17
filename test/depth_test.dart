// Copyright 2026, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:math';

import 'package:test/test.dart';
import 'package:treap/src/immutable_node.dart';
import 'package:treap/treap.dart';

int depthOf(ImmutableNode<int>? node) {
  final seen = <ImmutableNode<int>, int>{};
  int go(ImmutableNode<int>? n) {
    if (n == null) return 0;
    return seen[n] ??= 1 + max(go(n.left), go(n.right));
  }

  return go(node);
}

/// A random binary search tree over n nodes has height about 4.3 ln n with
/// high probability (Devroye, 1986).
void expectLogarithmic(ImmutableNode<int>? root, int size) {
  expect(
    depthOf(root),
    lessThanOrEqualTo(4.5 * log(size) + 2),
    reason: 'depth ${depthOf(root)} for $size nodes',
  );
}

void main() {
  setUp(() => joinRandom = Random(42));

  test('twenty doublings of x.append(x) stay logarithmic', () {
    var t = ImplicitTreapBase<int, ImmutableNode<int>>.of([
      1,
      2,
      3,
    ], immutableNodeFactory);
    for (var i = 0; i < 20; i++) {
      t = t.append(t);
    }
    expect(t.size, 3 << 20);
    expectLogarithmic(t.root, t.size);
  });

  test('repeated r.append(r.skip(a).take(b)) stays logarithmic', () {
    final random = Random(1);
    var r = ImplicitTreapBase<int, ImmutableNode<int>>.of(
      List.generate(300, (i) => i),
      immutableNodeFactory,
    );
    for (var i = 0; i < 2000; i++) {
      final a = random.nextInt(r.size);
      final b = a + random.nextInt(min(50, r.size - a));
      r = r.append(r.skip(a).take(b - a));
      if (r.size > 20000) r = r.skip(r.size - 10000);
    }
    expectLogarithmic(r.root, r.size);
  });

  test('appending in order stays logarithmic', () {
    var t = ImplicitTreapBase<int, ImmutableNode<int>>.of(
      const [],
      immutableNodeFactory,
    );
    for (var i = 0; i < 100000; i++) {
      t = t.add(i);
    }
    expectLogarithmic(t.root, t.size);
  });
}
