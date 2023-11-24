# Treap 

[![main](https://github.com/nielsenko/treap/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/nielsenko/treap/actions/workflows/dart.yml)
[![codecov](https://codecov.io/gh/nielsenko/treap/branch/master/graph/badge.svg?token=JI1PHY21A5)](https://codecov.io/gh/nielsenko/treap)

A package implementing a [persistent](https://en.wikipedia.org/wiki/Persistent_data_structure) (immutable) [order statistic tree](https://en.wikipedia.org/wiki/Order_statistic_tree) by means of the [treap](https://en.wikipedia.org/wiki/Treap) data structure (a kind of [cartesian tree](https://en.wikipedia.org/wiki/Cartesian_tree)). Apart from the regular set operations, it allows for:

- `select(i)` – find the `i`-th smallest element.
- `rank(x)` – find the rank of element `x`, i.e. the number of elements smaller than `x`.

both in `O(log(N))` time.

This particular implementation is made fully persistent by means of path copying. That is, any operation that would otherwise mutate the treap, instead produces a new treap, and does so using only `O(log(N))` extra space.

## Example

A toy [todo](https://github.com/nielsenko/treap/blob/main/example) flutter app, that illustrates how to use persistent treaps to efficiently handle undo/redo and animate a list view.

If your browser supports WasmGC (such as Chrome 119+, or Firefox 120+), you can try out the app [here](https://byolimit.github.io)