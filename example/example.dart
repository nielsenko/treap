import 'package:treap/treap.dart';

void main() {
  print('--- TreapSet Example ---');
  exampleTreapSet();

  print('\n--- TreapMap Example ---');
  exampleTreapMap();
}

void exampleTreapSet() {
  // Create a TreapSet of integers.
  // TreapSet maintains elements in sorted order.
  var treapSet = TreapSet<int>();

  // Add elements
  print('Adding elements: 5, 2, 8, 1, 2');
  treapSet.add(5);
  treapSet.add(2);
  treapSet.add(8);
  treapSet.add(1);
  treapSet.add(2); // Adding a duplicate element has no effect

  // Print the set (elements are usually printed in sorted order)
  print('TreapSet: $treapSet'); // Expected: {1, 2, 5, 8}

  // Check for element presence
  print('Contains 5: ${treapSet.contains(5)}'); // Expected: true
  print('Contains 3: ${treapSet.contains(3)}'); // Expected: false

  // Get the size of the set
  print('Size: ${treapSet.length}'); // Expected: 4

  // Get the first and last elements (requires the set to be non-empty)
  if (treapSet.isNotEmpty) {
    print('First element: ${treapSet.first}'); // Expected: 1
    print('Last element: ${treapSet.last}'); // Expected: 8
  }

  // Remove an element
  bool removed = treapSet.remove(2);
  print('Removed 2: $removed'); // Expected: true
  print('After removing 2: $treapSet'); // Expected: {1, 5, 8}

  // Attempt to remove a non-existent element
  removed = treapSet.remove(99);
  print('Removed 99: $removed'); // Expected: false
  print('After attempting to remove 99: $treapSet'); // Expected: {1, 5, 8}

  // Iterate over the set (elements are iterated in sorted order)
  print('Iterating over the set:');
  for (var element in treapSet) {
    print('- $element');
  }

  // Using `lookup` (similar to SplayTreeSet)
  // `lookup` returns the element if found, otherwise null.
  var lookedUpValue = treapSet.lookup(8);
  print('Lookup 8: $lookedUpValue'); // Expected: 8
  var lookedUpNonExistent = treapSet.lookup(10);
  print('Lookup 10: $lookedUpNonExistent'); // Expected: null

  // Clear the set
  treapSet.clear();
  print('After clearing: $treapSet'); // Expected: {}
  print('Is empty after clear: ${treapSet.isEmpty}'); // Expected: true

  // Example with a custom comparator (if supported by TreapSet constructor)
  // var customComparatorSet = TreapSet<String>((a, b) => b.compareTo(a)); // Reverse order
  // customComparatorSet.addAll(['apple', 'banana', 'cherry']);
  // print('Custom sorted TreapSet: $customComparatorSet'); // Expected: {cherry, banana, apple}
}

void exampleTreapMap() {
  // Create a TreapMap with String keys and int values.
  // TreapMap maintains entries sorted by keys.
  var treapMap = TreapMap<String, int>();

  // Add key-value pairs using operator[]=
  print('Adding entries: {"apple": 10, "banana": 5, "cherry": 20}');
  treapMap['apple'] = 10;
  treapMap['banana'] = 5;
  treapMap['cherry'] = 20;

  // Adding a pair with an existing key updates the value
  treapMap['apple'] = 15;
  print('Updated "apple" value.');

  // Print the map (entries are usually printed sorted by key)
  print('TreapMap: $treapMap'); // Expected: {apple: 15, banana: 5, cherry: 20}

  // Get value by key
  print('Value for "banana": ${treapMap['banana']}'); // Expected: 5
  print(
      'Value for "grape" (non-existent): ${treapMap['grape']}'); // Expected: null

  // Check for key presence
  print(
      'Contains key "cherry": ${treapMap.containsKey('cherry')}'); // Expected: true
  print(
      'Contains key "grape": ${treapMap.containsKey('grape')}'); // Expected: false

  // Check for value presence
  print('Contains value 5: ${treapMap.containsValue(5)}'); // Expected: true
  print('Contains value 25: ${treapMap.containsValue(25)}'); // Expected: false

  // Get the size of the map
  print('Size: ${treapMap.length}'); // Expected: 3

  // Get the first and last keys (if supported, and map is non-empty)
  // These methods are common in ordered map implementations like SplayTreeMap.
  // If not directly available, `treapMap.keys.first` and `treapMap.keys.last` can be used.
  if (treapMap.isNotEmpty) {
    print(
        'firstKey()/lastKey() not directly supported, using keys.first/keys.last:');
    if (treapMap.keys.isNotEmpty) {
      print('First key: ${treapMap.keys.first}');
      print('Last key: ${treapMap.keys.last}');
    }
  }

  // Remove an entry by key
  var removedValue = treapMap.remove('banana');
  print('Removed entry for "banana", value was: $removedValue'); // Expected: 5
  print(
      'After removing "banana": $treapMap'); // Expected: {apple: 15, cherry: 20}

  // Attempt to remove a non-existent key
  removedValue = treapMap.remove('grape');
  print(
      'Removed entry for "grape", value was: $removedValue'); // Expected: null

  // Iterate over keys (sorted order)
  print('Iterating over keys:');
  for (var key in treapMap.keys) {
    print('- $key');
  }

  // Iterate over values (in order of corresponding keys)
  print('Iterating over values:');
  for (var value in treapMap.values) {
    print('- $value');
  }

  // Iterate over entries (MapEntry<K, V>) (sorted by key)
  print('Iterating over entries:');
  for (var entry in treapMap.entries) {
    print('- ${entry.key}: ${entry.value}');
  }

  // `putIfAbsent`: Adds a key-value pair if the key is not already present.
  treapMap.putIfAbsent('date', () => 25);
  print('After putIfAbsent("date", () => 25): $treapMap');
  treapMap.putIfAbsent('apple',
      () => 100); // "apple" is already present, so value won't change to 100
  print('After putIfAbsent("apple", () => 100): $treapMap');

  // Clear the map
  treapMap.clear();
  print('After clearing: $treapMap'); // Expected: {}
  print('Is empty after clear: ${treapMap.isEmpty}'); // Expected: true

  // Example with a custom comparator for keys (if supported by TreapMap constructor)
  // var customKeyOrderMap = TreapMap<int, String>((k1, k2) => k2.compareTo(k1)); // Sort keys in descending order
  // customKeyOrderMap[1] = 'one';
  // customKeyOrderMap[3] = 'three';
  // customKeyOrderMap[2] = 'two';
  // print('Custom sorted TreapMap: $customKeyOrderMap'); // Expected: {3: three, 2: two, 1: one}
}
