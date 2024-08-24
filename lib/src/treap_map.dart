import 'dart:collection';
import 'package:treap/src/treap_base.dart';

class TreapMap<K, V> extends MapBase<K, V> {
  Treap<({K key, V? value})> _root;

  TreapMap._(this._root);

  TreapMap(Comparator<K> comparator)
      : this._(Treap((a, b) => comparator(a.key, b.key)));

  @override
  V? operator [](covariant K key) => _root.find((key: key, value: null))?.value;

  @override
  void operator []=(K key, V value) =>
      _root = _root.add((key: key, value: value));

  @override
  void clear() => _root = Treap(_root.compare);

  @override
  Iterable<K> get keys => _root.values.map((e) => e.key);

  @override
  Iterable<V> get values => _root.values.map((e) => e.value as V);

  @override
  V? remove(covariant K key) {
    final toDie = _root.find((key: key, value: null));
    if (toDie != null) _root = _root.erase(toDie);
    return toDie?.value;
  }

  @override
  int get length => _root.size;

  @override
  bool containsKey(covariant K key) =>
      _root.find((key: key, value: null)) != null;

//  @override
//  V elementAt(int index) => _root.select(index).value!;
}
