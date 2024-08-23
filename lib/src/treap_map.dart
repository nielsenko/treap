import 'dart:collection';
import 'package:treap/src/treap_base.dart';

class TreapMap<K extends Comparable<K>, V> extends MapBase<K, V> {
  Treap<({K key, V? value})> _root;

  TreapMap._(this._root);

  TreapMap([Comparator<K> comparator = Comparable.compare])
      : this._(Treap((a, b) => comparator(a.key, b.key)));

  @override
  V? operator [](Object? key) {
    if (key is! K) throw ArgumentError.value(key, 'key', 'is not a $K');
    final node = _root.find((key: key, value: null));
    return node?.value;
  }

  @override
  void operator []=(K key, V value) {
    _root.add((key: key, value: value));
  }

  @override
  void clear() {
    _root = Treap((a, b) => a.key.compareTo(b.key)); // TODO: wrong comparator
  }

  @override
  Iterable<K> get keys => _root.values.map((e) => e.key);

  @override
  Iterable<V> get values => _root.values.map((e) => e.value as V);

  @override
  V? remove(Object? key) {
    if (key is! K) throw ArgumentError.value(key, 'key', 'is not a $K');
    final toDie = _root.find((key: key, value: null));
    if (toDie != null) _root = _root.erase(toDie);
    return toDie?.value;
  }
}
