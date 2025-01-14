## 0.3.0

- Fix a bug where `TreapSet<T>.add` would update an existing item.
- Add a persistent implicit treap (`ImplicitTreap`). 
- Add `TreapList<T>` with logarithmic `insert` and `remove`, build on top of `ImplicitTreap`.
- Add comparative benchmark for `list` and `TreapList`.

## 0.2.0

- Add `TreapSet<T>` a `Set<T>` with constant time `toSet` and logarithmic `elementAt`, `skip`, and `take`.
- Add comparative benchmark for `HashSet`, `LinkedHashSet`, `SplayTreeSet`, and `TreapSet`.
- Increase test coverage to 100% branch coverage

## 0.1.0

- Initial version. Public interface still subject to change.
