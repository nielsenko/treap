## 0.4.0

### New Features & API Enhancements
* Added specialized set variants for deeply immutable primitive types (`TreapSetOfInt`, `TreapSetOfDouble` and `TreapSetOfString` for sets, and `TreapListOfInt`, `TreapListOfDouble`, and `TreapListOfString` for lists) for efficient cross-isolate use.
* Introduced a settable `defaultPriority` function, defaulting to a hash of the item, making priorities customizable.
* Allowed all collection types (`TreapMapBase`, `TreapSetBase`, `TreapListBase`) to be parameterized by a custom `NodeT` type for advanced usage and flexibility.

### Refactoring & Internal Improvements
* Introduced `TreapBase` and `ImplicitTreapBase` to consolidate common logic.
* Refactored the internal node interface and improved benchmark structure.
* Moved the `Hash` utility class to its own file.

### Web & JS Compatibility
* Improved JavaScript compatibility, particularly for the `Hash` class and integer operations.
* Added testing support for `dart2js` and `dart2wasm`, ensuring broader platform compatibility.

### Testing & Benchmarking
* Improved benchmark output and structure.
* Parameterized tests by node type.
* Added web tests and refined CI test execution environments.

### Bug Fixes
* Fixed several bugs related to JavaScript compilation, integer handling (`1 << 32`), and bitwise operations (`~0`).
* Fixed a bug in the example code.

### Documentation & Build
* Updated README, API documentation comments, and CI configuration.

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
