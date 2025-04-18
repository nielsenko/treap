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

### TreapSet Usage Example

```dart
import 'package:treap/treap.dart';

void main() {
  // Create a new TreapSet
  final set = TreapSet<int>();
  
  // Add elements
  final set2 = set.add(1).add(2).add(3);
  
  // Operations return new sets without modifying the original
  print(set.isEmpty);  // true
  print(set2.length);  // 3
  
  // Efficient set operations
  final otherSet = TreapSet<int>.of([2, 3, 4]);
  final union = set2.union(otherSet);        // [1, 2, 3, 4]
  final intersection = set2.intersection(otherSet);  // [2, 3]
  final difference = set2.difference(otherSet);      // [1]
  
  // Order statistics
  print(set2.elementAt(1));  // 2 (the element at index 1)
}
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

### TreapList Usage Example

```dart
import 'package:treap/treap.dart';

void main() {
  // Create a new TreapList
  final list = TreapList<String>();
  
  // Add elements
  list.add("apple");
  list.add("banana");
  list.add("cherry");
  
  // Insert elements efficiently at any position
  list.insert(1, "blueberry");  // O(log N) operation
  
  // Remove elements efficiently from any position
  final removed = list.removeAt(2);  // O(log N) operation
  
  // Efficient sublist operations
  final sublist = list.sublist(1, 3);  // O(log N) operation
  
  // Access elements
  print(list[0]);  // "apple" - O(log N) operation, unlike O(1) in standard List
}
```

## Specialized Variants for Cross-Isolate Sharing

The package includes specialized implementations for primitive types:

- `TreapIntSet` - A specialized set for integers marked with the deeply-immutable pragma
- `TreapStringSet` - A specialized set for strings marked with the deeply-immutable pragma
- `TreapDoubleSet` - A specialized set for floating-point numbers marked with the deeply-immutable pragma

These specialized variants are designed for efficient sharing between Dart isolates. By using the deeply-immutable pragma, these collections can be passed between isolates without copying, which significantly improves performance in multi-threaded environments. The deeply immutable property ensures that the data structure can be safely accessed from multiple isolates simultaneously without risking data corruption.

## Implementation Details

Treaps combine the properties of binary search trees (BST) and heaps:
- Each node has a key (used for BST ordering)
- Each node has a priority value (used for heap ordering)
- The tree maintains BST property by key and heap property by priority

The random priorities ensure that the tree remains balanced with high probability, providing O(log N) performance for operations without requiring complex rebalancing algorithms like AVL or Red-Black trees.

Path copying (also known as "path cloning" or "path copying persistence") is the technique used to make operations persistent:
1. When modifying a node, create a new copy of it
2. Also create new copies of all its ancestors
3. Link the copies appropriately
4. Return the new root

This approach ensures that the original tree remains unchanged while using only O(log N) extra space per operation.

## When to Use Treaps

Treaps are particularly useful when:
1. You need both ordered collections and efficient updates
2. You require persistent/immutable data structures
3. Order statistics operations (rank, select) are frequent
4. You need efficient undo/redo capabilities
5. Efficient operations on subsequences are required
6. You need to share data structures between isolates (using specialized variants)

## Example

The package includes a toy [todo](https://github.com/nielsenko/treap/blob/main/example) flutter app, that illustrates how to use persistent treaps to efficiently handle undo/redo and animate a list view.

If your browser supports WasmGC (such as Chrome 119+, or Firefox 120+), you can try out the app [here](https://byolimit.github.io)