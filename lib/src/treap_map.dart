// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:collection';
import 'package:treap/src/treap_base.dart';

class TreapMap<K, V> extends MapBase<K, V> {
  Treap<({K key, V? value})> _root;

  TreapMap._(this._root);

  TreapMap(Comparator<K> compare)
      : this._(Treap((a, b) => compare(a.key, b.key)));

  @override
  V? operator [](covariant K key) => _root.find((key: key, value: null))?.value;

  @override
  void operator []=(K key, V value) =>
      _root = _root.addOrUpdate((key: key, value: value));

  @override
  void clear() => _root = Treap(_root.compare);

  @override
  Iterable<K> get keys => _root.values.map((e) => e.key);

  @override
  Iterable<V> get values => _root.values.map((e) => e.value as V);

  @override
  V? remove(covariant K key) {
    final toDie = _root.find((key: key, value: null));
    if (toDie != null) _root = _root.remove(toDie);
    return toDie?.value;
  }

  @override
  int get length => _root.size;

  @override
  bool containsKey(covariant K key) =>
      _root.find((key: key, value: null)) != null;

  @override
  Iterable<MapEntry<K, V>> get entries =>
      _root.values.map((e) => MapEntry(e.key, e.value as V));

  @override
  void forEach(void Function(K key, V value) action) {
    for (final e in _root.values) {
      action(e.key, e.value as V);
    }
  }

  @override
  bool get isEmpty => _root.isEmpty;
}
