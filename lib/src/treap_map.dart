// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';

import 'immutable_node.dart';
import 'node.dart';

typedef KeyValue<K, V> = ({K key, V? value});

class TreapMapBase<K, V, NodeT extends Node<KeyValue<K, V>, NodeT>>
    extends MapBase<K, V> {
  NodeT? _root;
  final NodeT Function(KeyValue<K, V>) _createNode;
  final Comparator<KeyValue<K, V>> _compare;

  TreapMapBase._(this._root, this._createNode, this._compare);

  TreapMapBase(NodeT Function(KeyValue<K, V>) createNode, Comparator<K> compare)
      : this._(
          null,
          createNode,
          (a, b) => compare(a.key, b.key),
        );

  @override
  V? operator [](covariant K key) => find<KeyValue<K, V>, NodeT>(
        _root,
        (key: key, value: null),
        _compare,
      )?.item.value;

  @override
  void operator []=(K key, V value) => _root = upsert<KeyValue<K, V>, NodeT>(
        _root,
        (key: key, value: value),
        true,
        _compare,
        _createNode,
      );

  @override
  void clear() => _root = null;

  @override
  Iterable<K> get keys => _root.inOrder().map((n) => n.item.key);

  @override
  Iterable<V> get values => _root.inOrder().map((n) => n.item.value as V);

  @override
  V? remove(covariant K key) {
    final toDie = this[key];
    if (toDie != null) {
      _root = erase<KeyValue<K, V>, NodeT>(
          _root, (key: key, value: null), _compare);
    }
    return toDie;
  }

  @override
  int get length => _root.size;

  @override
  bool containsKey(covariant K key) =>
      find<KeyValue<K, V>, NodeT>(_root, (key: key, value: null), _compare) !=
      null;

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

extension type TreapMap<K, V>._(
        TreapMapBase<K, V, ImmutableNode<KeyValue<K, V>>> base)
    implements TreapMapBase<K, V, ImmutableNode<KeyValue<K, V>>> {
  TreapMap(Comparator<K> compare)
      : base = TreapMapBase(immutableNodeFactory, compare);
}
