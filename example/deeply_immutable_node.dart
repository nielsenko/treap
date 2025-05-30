// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:treap/treap.dart';

// NOTE: Classes has to be sealed or final when marked as deeply immutable.
//
// This is the reason the package cannot provide a common base class for
// deeply immutable nodes.
//
// Hopefully, the Dart team will add support for an interface class for deeply
// immutable classes in the future, so this can become part of the package
//
// Until then this example shows how to roll your own.

// All your deeply immutable classes should inherit from this base class.
// Copy this to your own project.
@immutable
@pragma('vm:deeply-immutable')
sealed class DeeplyImmutable {
  const DeeplyImmutable();
}

// This is the node type to use for all deeply immutable classes.
// Copy this to your own project.
@immutable
@pragma('vm:deeply-immutable')
final class DeeplyImmutableNode<T extends DeeplyImmutable>
    implements Node<T, DeeplyImmutableNode<T>> {
  @override
  final T item;
  @override
  final int priority;
  @override
  final int size;
  @override
  final DeeplyImmutableNode<T>? left, right;

  DeeplyImmutableNode(this.item, this.priority, this.left, this.right)
      : size = 1 + left.size + right.size {
    assert(checkInvariant());
  }

  @override
  DeeplyImmutableNode<T> copy() => this;

  @override
  DeeplyImmutableNode<T> withItem(T item) =>
      DeeplyImmutableNode(item, priority, left, right);

  @override
  DeeplyImmutableNode<T> withLeft(DeeplyImmutableNode<T>? left) =>
      DeeplyImmutableNode(item, priority, left, right);

  @override
  DeeplyImmutableNode<T> withRight(DeeplyImmutableNode<T>? right) =>
      DeeplyImmutableNode(item, priority, left, right);

  @override
  DeeplyImmutableNode<T> withChildren(
          DeeplyImmutableNode<T>? left, DeeplyImmutableNode<T>? right) =>
      DeeplyImmutableNode(item, priority, left, right);
}

// Has to go in same file as DeeplyImmutable as
// the base has to be sealed.
final class Person extends DeeplyImmutable {
  // Only deeply immutable members allowed
  final String name;
  final int age;

  // You probably want to override == and hashCode, in order to use Person in
  // sets or as keys in maps. But you can always pass a custom compare function
  // otherwise.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Person) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  const Person(this.name, this.age);
}

// Define a factory function for the node type. This can be generic, so you
// only need to define one, regardless of how many _item_ classes you need.
DeeplyImmutableNode<T> deeplyImmutableNodeFactory<T extends DeeplyImmutable>(
  T item,
) =>
    DeeplyImmutableNode(item, defaultPriority(item), null, null);

// It is convenient with a typedef, as the signature is a bit repetetive.
// If you want to avoid parsing the factory to the ctor, take a look at the
// implementation of TreapSetOfInt, which is an extension type instead of a
// typedef, to see how to achieve this.
typedef TreapSetOfMyItem = TreapSetBase<Person, DeeplyImmutableNode<Person>>;

Future<void> main() async {
  final persons = TreapSetOfMyItem.of([], deeplyImmutableNodeFactory);
  await Isolate.run(() {
    print(persons); // pass persons into another isolate without copy
  });
}
