// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';
import 'dart:math';

import 'immutable_node.dart';
import 'node.dart';

final _rnd = Random();
typedef _Item<K, V> = ({K key, V? value});
typedef _Node<K, V> = ImmutableNode<_Item<K, V>>;
_Node<K, V> _createNode<K, V>(_Item<K, V> item) =>
    _Node(item, _rnd.nextInt(1 << 32));

class TreapMap<K, V> extends MapBase<K, V> {
  _Node<K, V>? _root;
  NodeContext<_Item<K, V>, _Node<K, V>> _ctx;

  TreapMap._(this._root, this._ctx);

  TreapMap(Comparator<K> compare)
      : this._(
          null,
          NodeContext(
            (a, b) => compare(a.key, b.key),
            _createNode,
          ),
        );

  @override
  V? operator [](covariant K key) =>
      find(_root, (key: key, value: null), _ctx)?.item.value;

  @override
  void operator []=(K key, V value) =>
      _root = upsert(_root, (key: key, value: value), true, _ctx);

  @override
  void clear() => _root = null;

  @override
  Iterable<K> get keys => _root.inOrder().map((n) => n.item.key);

  @override
  Iterable<V> get values => _root.inOrder().map((n) => n.item.value as V);

  @override
  V? remove(covariant K key) {
    final toDie = this[key];
    if (toDie != null) _root = erase(_root, (key: key, value: null), _ctx);
    return toDie;
  }

  @override
  int get length => _root.size;

  @override
  bool containsKey(covariant K key) =>
      find(_root, (key: key, value: null), _ctx) != null;

  @override
  Iterable<MapEntry<K, V>> get entries => _root.inOrder().map((n) {
        final i = n.item;
        return MapEntry(i.key, i.value as V);
      });

  @override
  void forEach(void Function(K key, V value) action) {
    for (final n in _root.inOrder()) {
      final i = n.item;
      action(i.key, i.value as V);
    }
  }

  @override
  bool get isEmpty => _root == null;
}
