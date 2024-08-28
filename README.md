# Treap 

[![main](https://github.com/nielsenko/treap/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/nielsenko/treap/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/nielsenko/treap/branch/main/graph/badge.svg?token=JI1PHY21A5)](https://codecov.io/gh/nielsenko/treap)

A package implementing a [persistent](https://en.wikipedia.org/wiki/Persistent_data_structure) (immutable) [order statistic tree](https://en.wikipedia.org/wiki/Order_statistic_tree) by means of the [treap](https://en.wikipedia.org/wiki/Treap) data structure (a kind of [cartesian tree](https://en.wikipedia.org/wiki/Cartesian_tree)). Apart from the regular set operations, it allows for:

- `select(i)` – find the `i`-th smallest element.
- `rank(x)` – find the rank of element `x`, i.e. the number of elements smaller than `x`.

both in `O(log(N))` time.

This particular implementation is made fully persistent by means of path copying. That is, any operation that would otherwise mutate the treap, instead produces a new treap, and does so using only `O(log(N))` extra space. This allow copies to be `O(1)` in time and space.

## TreapSet

`TreapSet<T>` (build on top of `Treap<T>`) implements `Set<T>`. It resembles `SplayTreeSet<T>` in behavior, keeping elements ordered, but is differs in performance of:
- `take`
- `skip`
- `elementAt`

which are all `O(log(N))` (given `select` and `rank`) and `toSet` which is `O(1)` and hence much faster than all the 3 standard sets (`LinkedHashSet` (default), `HashSet` and `SplayTreeSet`).

As a rule of thumb the mutating operations `add`, `remove` are roughly twice as slow as for `SplaySetTree` (which is already a lot slower than `HashSet` and `LinkedHashSet` in this regard). This is mostly due to the cost of the _path copying_ done to make `Treap<T>` immutable. A full benchmark suite can be found in `benchmark/main.dart` comparing various set operations on the three standard sets  and `TreapSet`.

## Example

A toy [todo](https://github.com/nielsenko/treap/blob/main/example) flutter app, that illustrates how to use persistent treaps to efficiently handle undo/redo and animate a list view.

If your browser supports WasmGC (such as Chrome 119+, or Firefox 120+), you can try out the app [here](https://byolimit.github.io)