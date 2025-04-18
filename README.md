[![main](https://github.com/nielsenko/treap/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/nielsenko/treap/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/nielsenko/treap/branch/main/graph/badge.svg?token=JI1PHY21A5)](https://codecov.io/gh/nielsenko/treap)

# Treap

A package implementing a [persistent](https://en.wikipedia.org/wiki/Persistent_data_structure) (immutable) [order statistic tree](https://en.wikipedia.org/wiki/Order_statistic_tree) by means of the [treap](https://en.wikipedia.org/wiki/Treap) data structure (a kind of [cartesian tree](https://en.wikipedia.org/wiki/Cartesian_tree)). Apart from the regular binary tree operations, it allows for:

- `select(i)` – find the `i`-th smallest element.
- `rank(x)` – find the rank of element `x`, i.e. the number of elements smaller than `x`.

both in _O(log(N))_ time.

The package also contains an implementation based on the related [implicit treap](https://en.wikipedia.org/wiki/Treap#Implicit_treap) (providing dynamic array-like functionality). Which has better computational complexity _O(Log(N))_ on:

- `insert(i, x)` - insert element `x` at index `i`
- `remove(i)` - remove element at index `i`.

than a regular dynamic array.

The implementation of both are made fully persistent by means of path copying. That is, any operation that would otherwise mutate a treap (or implicit treap), instead produces a new treap, and does so using only _O(log(N))_ extra space. This allow copies to be _O(1)_ in time and space.

The package contains implementations of the standard Dart `Set<T>` and `List<T>` interfaces, built on top of this foundation.

## Core Treap Structures

Before diving into the `Set` and `List` implementations, it's useful to understand the core persistent structures:

### Ordered Treap (`TreapBase`)

This is the fundamental ordered treap implementation, providing:

- **Basic Operations:** `add`, `remove`, `find` (lookup by value), `has` (contains)
- **Order Statistics:** `rank` (get index of value), `select` (get value at index)
- **Accessors:** `first`, `last`, `firstOrDefault`, `lastOrDefault`, `prev`, `next`
- **Properties:** `size`, `isEmpty`, `values` (ordered iterable)
- **Range Operations:** `take`, `skip`
- **Set Algebra:** `union`, `intersection`, `difference`
- **Immutability:** `copy`

### Implicit Treap (`ImplicitTreapBase`)

This structure uses treaps to implement a persistent list/array with efficient index-based operations:

- **Basic Operations:** `add` (append), `insert` (at index), `remove` (at index), `append` (concatenate another implicit treap)
- **Accessors:** `[]` (index operator), `values` (iterable)
- **Properties:** `size`
- **Range Operations:** `take`, `skip`
- **Immutability:** `copy`

These base structures are used internally by `TreapSet` and `TreapList` respectively.

## TreapSet

`TreapSet<T>` is a persistent, ordered set implementation based on the treap data structure. It implements Dart's `Set<T>` interface, providing familiar operations like:

- **Adding/Removing:** `add`, `addAll`, `remove`, `removeAll`, `retainAll`, `clear`
- **Querying:** `contains`, `lookup`, `length`, `isEmpty`
- **Iteration:** `iterator`, `forEach`
- **Set Operations:** `union`, `intersection`, `difference`
- **Order-Based Operations:** `first`, `last`, `elementAt`, `take`, `skip`, `takeWhile`, `skipWhile`

Its performance characteristics differ from standard collections:

### Performance Characteristics

- **Ordered Elements**: Like `SplayTreeSet<T>`, elements are kept in order.
- **Efficient Range/Order Operations**: `take`, `skip`, and `elementAt` are all _O(log N)_, scaling better than standard sets.
- **Constant-Time Copying**: `toSet()` (creating a copy) is _O(1)_ due to persistence.
- **Mutation Speed**: Mutating operations (`add`, `remove`) are generally slower (roughly 2x) than `SplayTreeSet` due to path copying overhead and the native implementation of standard collections.

This makes TreapSet particularly well-suited for scenarios where:
- Ordered iteration is required.
- Frequent `take`, `skip`, or `elementAt` operations are performed.
- Immutable snapshots of the set are needed (e.g., for history or concurrency).

### Benchmarks

A benchmark suite comparing set operations is available in _benchmark/set_main.dart_:

```sh
# Run with Dart
dart run --no-enable-asserts benchmark/set_main.dart

# Or compile to native executable for better performance
dart compile exe benchmark/set_main.dart
./benchmark/set_main.exe
```

### TreapSet Usage Example

```dart
import 'package:treap/treap.dart';

void main() {
  // Create sets
  final set1 = TreapSet<int>();
  final set2 = set1.add(1).add(2).add(3);  // Immutable operations

  // Original set remains unchanged
  print(set1.isEmpty);  // true
  print(set2.length);   // 3

  // Efficient set operations
  final set3 = TreapSet<int>.of([2, 3, 4]);
  final union = set2.union(set3);           // [1, 2, 3, 4]
  final intersection = set2.intersection(set3);  // [2, 3]
  final difference = set2.difference(set3);      // [1]

  // Order statistics
  print(set2.elementAt(1));  // 2 (O(log N) operation)
}
```

## TreapList

`TreapList<T>` is a persistent list implementation based on the implicit treap data structure. It implements Dart's `List<T>` interface, providing familiar operations like:

- **Adding/Removing:** `add`, `addAll`, `insert`, `insertAll`, `remove`, `removeAt`, `removeLast`, `removeWhere`, `retainWhere`, `clear`
- **Accessing Elements:** `[]` (index operator), `first`, `last`, `elementAt`
- **Querying:** `length`, `isEmpty`, `isNotEmpty`
- **Iteration:** `iterator`, `forEach`
- **Range Operations:** `sublist`, `getRange`, `take`, `skip`, `takeWhile`, `skipWhile`

Its performance characteristics differ significantly from the standard `List`:

### Performance Characteristics

- **Logarithmic Access**: Element access operations (`[]`, first, last) are _O(log N)_, unlike standard List's O(1)
- **Efficient Insertions/Deletions**: `insert` and `remove` are _O(log N)_, significantly better than standard List's O(N)
- **Efficient Range Operations**: `sublist`, `getRange`, `take`, and `skip` are all _O(log N)_

This makes TreapList particularly well-suited for scenarios where:
- Elements are frequently inserted or removed at arbitrary positions
- The list is frequently sliced into sublists
- Immutability is required

### Benchmarks

A benchmark suite comparing list operations is available in _benchmark/list_main.dart_:

```sh
# Run with Dart
dart run --no-enable-asserts benchmark/list_main.dart

# Or compile to native executable for better performance
dart compile exe benchmark/list_main.dart
./benchmark/list_main.exe
```

### TreapList Usage Example

```dart
import 'package:treap/treap.dart';

void main() {
  // Create a list
  final list = TreapList<String>();
  list.add("apple");
  list.add("banana");
  list.add("cherry");

  // Efficient operations at any position
  list.insert(1, "blueberry");  // O(log N) operation
  final removed = list.removeAt(2);  // O(log N) operation

  // Efficient sublist operations
  final sublist = list.sublist(1, 3);  // O(log N) operation

  print(list[0]);  // "apple" - O(log N) access
}
```

## Specialized Variants for Cross-Isolate Sharing

This package includes specialized implementations optimized for cross-isolate communication using Dart's `@pragma('vm:deeply-immutable')` annotation:

### Specialized Collections

| Type             | Purpose                     | Node Implementation |
|------------------|-----------------------------|---------------------|
| `TreapIntSet`    | Set of integers             | `IntNode`           |
| `TreapStringSet` | Set of strings              | `StringNode`        |
| `TreapDoubleSet` | Set of doubles              | `DoubleNode`        |
| `TreapIntList`   | List of integers            | `IntNode`           |
| `TreapStringList`| List of strings             | `StringNode`        |
| `TreapDoubleList`| List of doubles             | `DoubleNode`        |

### Benefits of Specialized Variants

- **Efficient Sharing**: The primary benefit is passing these collections *to* worker isolates without copying, crucial for large datasets or frequent isolate communication.
- **Performance**: Avoids serialization/deserialization overhead, speeding up multi-threaded applications.
- **Safety**: Deep immutability ensures safe concurrent access from multiple isolates.

While returning data *from* an isolate can also benefit, simple return values are often handled efficiently by mechanisms like `Isolate.run`, which automatically merges the heaps upon completion. The main advantage of these specialized types lies in efficiently providing input data *to* the isolate.

### Creating Custom Deeply-Immutable Types

For your own deeply-immutable types, you can reference the `DeeplyImmutableNode` class in _lib/src/deeply_immutable_node.dart_.

> **Note:** Due to VM limitations, `@pragma('vm:deeply-immutable')` can only be used on `final` or `sealed` classes. You'll need to copy this implementation to your own project. Consider supporting [this issue](https://github.com/dart-lang/sdk/issues/55120) for future improvements.

### Cross-Isolate Usage Example

This example demonstrates sending a specialized `TreapIntList` (which is deeply immutable) to another isolate. The list is accessed directly in the new isolate without any copying.

```dart
import 'dart:isolate';
import 'package:treap/treap.dart';

// Function to be executed in the new isolate.
// It receives the TreapIntList directly.
void processReadOnlyInIsolate(TreapIntList dataList) {
  // Access the list directly in the new isolate.
  // No copying occurred when passing the list.
  print('Isolate received list with length: ${dataList.length}');
  if (dataList.isNotEmpty) {
    print('Isolate accessing first element: ${dataList.first}');
  }
  // No need to send data back for this example.
}

void main() async {
  // Create a specialized list in the main isolate.
  final mainList = TreapIntList.of([10, 20, 30, 40, 50]);

  print('Main isolate created list: ${mainList.join(', ')}');

  // Spawn the isolate, passing the TreapIntList directly.
  // Because TreapIntList is deeply immutable, it's passed by reference (no copy).
  try {
    await Isolate.spawn(processReadOnlyInIsolate, mainList);
    print('Isolate spawned successfully.');
  } catch (e) {
    print('Error spawning isolate: $e');
  }

  // Give the isolate some time to run and print its output.
  await Future.delayed(Duration(seconds: 1));
  print('Main isolate finished.');
}
```

## Example Application

The package includes a [Todo Application Example (Flutter)](https://github.com/nielsenko/treap/blob/main/example) that demonstrates:

- Using persistent treaps for efficient undo/redo functionality
- Animating list view changes with persistent data structures
- Maintaining application state history without memory overhead

You can try the application in your browser if it supports WebAssembly Garbage Collection (WasmGC):
- Chrome 119+
- Firefox 120+
- Edge 119+

[Live Demo](https://byolimit.github.io)
