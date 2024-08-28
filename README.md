[![main](https://github.com/nielsenko/treap/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/nielsenko/treap/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/nielsenko/treap/branch/main/graph/badge.svg?token=JI1PHY21A5)](https://codecov.io/gh/nielsenko/treap)

# Treap

A package implementing a [persistent](https://en.wikipedia.org/wiki/Persistent_data_structure) (immutable) [order statistic tree](https://en.wikipedia.org/wiki/Order_statistic_tree) by means of the [treap](https://en.wikipedia.org/wiki/Treap) data structure (a kind of [cartesian tree](https://en.wikipedia.org/wiki/Cartesian_tree)). Apart from the regular binary tree operations, it allows for:

- `select(i)` – find the `i`-th smallest element.
- `rank(x)` – find the rank of element `x`, i.e. the number of elements smaller than `x`.

both in `O(log(N))` time.

This particular implementation is made fully persistent by means of path copying. That is, any operation that would otherwise mutate the treap, instead produces a new treap, and does so using only `O(log(N))` extra space. This allow copies to be `O(1)` in time and space.

## TreapSet

`TreapSet<T>` (build on top of `Treap<T>`) implements `Set<T>`. It resembles `SplayTreeSet<T>` in behavior, keeping elements ordered, but it differs in performance of:
- `take`,
- `skip`, and
- `elementAt`,

which are all `O(log(N))` (given `select` and `rank`) and `toSet` which is `O(1)`. 

Hence it is much faster than all the 3 standard sets `LinkedHashSet` (default), `HashSet` and `SplayTreeSet` on these operations. 

The advantage naturally grows with _N_ (no of items), but `LinkedHashSet<int>` is already a bit behind for _N = 10_, and `Treap` stays below 1us for _N = 1000000_ on all these 4 operations (as tested on my old 2,4 GHz 8-Core Intel Core i9 MacBook Pro).

However there is no such thing as free lunch.
As a rule of thumb the mutating operations `add`, `remove`, etc. are roughly twice as slow as for `SplaySetTree` (which is already a lot slower than `HashSet` and `LinkedHashSet`).

This is mostly due to the cost of the _path copying_ done to make `Treap<T>` immutable, and the fact that `HashSet` and `LinkedHashSet` is implemented directly in the runtime. 

A full benchmark suite can be found in _benchmark/main.dart_ comparing various set operations on the three standard sets  and `TreapSet`. 

Run with
```sh
dart run --no-enable-asserts benchmark/main.dart
```

## Example

A toy [todo](https://github.com/nielsenko/treap/blob/main/example) flutter app, that illustrates how to use persistent treaps to efficiently handle undo/redo and animate a list view.

If your browser supports WasmGC (such as Chrome 119+, or Firefox 120+), you can try out the app [here](https://byolimit.github.io)