[![main](https://github.com/nielsenko/treap/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/nielsenko/treap/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/nielsenko/treap/branch/main/graph/badge.svg?token=JI1PHY21A5)](https://codecov.io/gh/nielsenko/treap)

# Treap

A package implementing a [persistent](https://en.wikipedia.org/wiki/Persistent_data_structure) (immutable) [order statistic tree](https://en.wikipedia.org/wiki/Order_statistic_tree) by means of the [treap](https://en.wikipedia.org/wiki/Treap) data structure (a kind of [cartesian tree](https://en.wikipedia.org/wiki/Cartesian_tree)). Apart from the regular binary tree operations, it allows for:

- `select(i)` – find the `i`-th smallest element.
- `rank(x)` – find the rank of element `x`, i.e. the number of elements smaller than `x`.

both in `O(log(N))` time.

The package also contains an implementation the related [implicit treap](https://en.wikipedia.org/wiki/Treap#Implicit_treap) (a kind of [dynamic array](https://en.wikipedia.org/wiki/Dynamic_array)). Which has better computational complexity on:

- `insert(i, x)` - insert element `x` at index `i`
- `remove(i)` - remove element at index `i`.

than a regular `dynamic array`.

The implementation of both are made fully persistent by means of path copying. That is, any operation that would otherwise mutate a treap (or implicit treap), instead produces a new treap, and does so using only `O(log(N))` extra space. This allow copies to be `O(1)` in time and space.

The package contains implementations of the standard Dart `Set<T>` and `List<T>` interfaces, build on top of this foundation.

## TreapSet

`TreapSet<T>` implements `Set<T>`. It resembles `SplayTreeSet<T>` in behavior, keeping elements ordered, but it differs on the computational complexity for:

- `take`,
- `skip`, and
- `elementAt`,

which are all `O(log(N))` (given `select` and `rank`) and `toSet` which is `O(1)`.

Hence it scales better than all the three standard sets `LinkedHashSet` (default), `HashSet` and `SplayTreeSet` on these operations.

However there is no such thing as free lunch.
As a rule of thumb the mutating operations `add`, `remove`, etc. are roughly twice as slow as for `SplaySetTree` (which is already a lot slower than `HashSet` and `LinkedHashSet`).

This is mostly due to the cost of the _path copying_ done to make `Treap<T>` immutable, and the fact that `HashSet` and `LinkedHashSet` is implemented directly in the runtime.

A benchmark suite can be found in _benchmark/set_main.dart_ comparing various set operations on the three standard sets and `TreapSet`.

Run with

```sh
dart run --no-enable-asserts benchmark/set_main.dart
```

or better yet, compile to exe and run the executable.

```sh
dart compile exe benchmark/set_main.dart
./benchmark/set_main.exe
```

## TreapList

`TreapList<T>` implements `List<T>`, but again differs on the computational complexity. No operations (including indexing) are better than `O(log(N))`, however `insert` and `remove` are also `O(log(N))`, so it scales much better than the regular `List` on these operations.

A benchmark suite can be found in _benchmark/list_main.dart_ comparing various list operations on the standard list with `TreapList`.

Run with

```sh
dart run --no-enable-asserts benchmark/list_main.dart
```

or better yet, compile to exe and run the executable.

```sh
dart compile exe benchmark/list_main.dart
./benchmark/list_main.exe
```

## Example

The package includes a toy [todo](https://github.com/nielsenko/treap/blob/main/example) flutter app, that illustrates how to use persistent treaps to efficiently handle undo/redo and animate a list view.

If your browser supports WasmGC (such as Chrome 119+, or Firefox 120+), you can try out the app [here](https://byolimit.github.io)
