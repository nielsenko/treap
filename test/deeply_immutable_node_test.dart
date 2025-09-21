// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause

import 'package:test/scaffolding.dart';
import 'package:checks/checks.dart';
import 'package:treap/src/deeply_immutable/double_node.dart';
import 'package:treap/src/deeply_immutable/int_node.dart';
import 'package:treap/src/deeply_immutable/string_node.dart';

void main() {
  group('IntNode', () {
    const item1 = 100;
    const item2 = 200;
    const priority1 = 5;
    const priority2 = 15;

    test('constructor initializes properties correctly (null children)', () {
      final node = IntNode(item1, priority1, null, null);
      check(node.item).equals(item1);
      check(node.priority).equals(priority1);
      check(node.left).isNull();
      check(node.right).isNull();
      check(node.size).equals(1);
    });

    test('constructor initializes properties correctly (optional children)',
        () {
      final node = IntNode(item1, priority1); // Omitting optional children
      check(node.item).equals(item1);
      check(node.priority).equals(priority1);
      check(node.left).isNull();
      check(node.right).isNull();
      check(node.size).equals(1);
    });

    final childLeft = IntNode(item2, priority2, null, null);
    final childRight = IntNode(item1, priority1, null, null);

    test('constructor initializes properties correctly (with children)', () {
      final node = IntNode(item1, priority1, childLeft, childRight);
      check(node.item).equals(item1);
      check(node.priority).equals(priority1);
      check(node.left).identicalTo(childLeft);
      check(node.right).identicalTo(childRight);
      check(node.size).equals(1 + childLeft.size + childRight.size);
    });

    test('copy() returns the same instance', () {
      final node = IntNode(item1, priority1, null, null);
      check(node.copy()).identicalTo(node);
    });

    test('withItem() creates a new instance with the new item', () {
      final node = IntNode(item1, priority1, childLeft, childRight);
      const newItem = 300;
      final newNode = node.withItem(newItem);

      check(newNode.item).equals(newItem);
      check(newNode.priority).equals(node.priority);
      check(newNode.left).identicalTo(node.left);
      check(newNode.right).identicalTo(node.right);
      check(newNode.size).equals(node.size);
      check(newNode).not((it) => it.identicalTo(node));
    });

    test('withLeft() creates a new instance with the new left child', () {
      final node = IntNode(item1, priority1, null, childRight);
      final newLeftChild = IntNode(item2, priority2, null, null);
      final newNode = node.withLeft(newLeftChild);

      check(newNode.item).equals(node.item);
      check(newNode.priority).equals(node.priority);
      check(newNode.left).identicalTo(newLeftChild);
      check(newNode.right).identicalTo(node.right);
      check(newNode.size)
          .equals(1 + newLeftChild.size + (node.right?.size ?? 0));
      check(newNode).not((it) => it.identicalTo(node));
    });

    test('withRight() creates a new instance with the new right child', () {
      final node = IntNode(item1, priority1, childLeft, null);
      final newRightChild = IntNode(item2, priority2, null, null);
      final newNode = node.withRight(newRightChild);

      check(newNode.item).equals(node.item);
      check(newNode.priority).equals(node.priority);
      check(newNode.left).identicalTo(node.left);
      check(newNode.right).identicalTo(newRightChild);
      check(newNode.size)
          .equals(1 + (node.left?.size ?? 0) + newRightChild.size);
      check(newNode).not((it) => it.identicalTo(node));
    });

    test('withChildren() creates a new instance with new children', () {
      final node = IntNode(item1, priority1, null, null);
      final newLeft = IntNode(item2, priority2, null, null);
      final newRight = IntNode(item1, priority1, null, null);
      final newNode = node.withChildren(newLeft, newRight);

      check(newNode.item).equals(node.item);
      check(newNode.priority).equals(node.priority);
      check(newNode.left).identicalTo(newLeft);
      check(newNode.right).identicalTo(newRight);
      check(newNode.size).equals(1 + newLeft.size + newRight.size);
      check(newNode).not((it) => it.identicalTo(node));
    });
  });

  group('StringNode', () {
    const item1 = "apple";
    const item2 = "banana";
    const priority1 = 7;
    const priority2 = 17;

    test('constructor initializes properties correctly (null children)', () {
      final node = StringNode(item1, priority1, null, null);
      check(node.item).equals(item1);
      check(node.priority).equals(priority1);
      check(node.left).isNull();
      check(node.right).isNull();
      check(node.size).equals(1);
    });

    final childLeft = StringNode(item2, priority2, null, null);
    final childRight = StringNode(item1, priority1, null, null);

    test('constructor initializes properties correctly (with children)', () {
      final node = StringNode(item1, priority1, childLeft, childRight);
      check(node.item).equals(item1);
      check(node.priority).equals(priority1);
      check(node.left).identicalTo(childLeft);
      check(node.right).identicalTo(childRight);
      check(node.size).equals(1 + childLeft.size + childRight.size);
    });

    test('copy() returns the same instance', () {
      final node = StringNode(item1, priority1, null, null);
      check(node.copy()).identicalTo(node);
    });

    test('withItem() creates a new instance with the new item', () {
      final node = StringNode(item1, priority1, childLeft, childRight);
      const newItem = "cherry";
      final newNode = node.withItem(newItem);
      check(newNode.item).equals(newItem);
      check(newNode.priority).equals(node.priority);
      check(newNode).not((it) => it.identicalTo(node));
    });

    test('withLeft() creates a new instance with the new left child', () {
      final node = StringNode(item1, priority1, null, childRight);
      final newLeftChild = StringNode(item2, priority2, null, null);
      final newNode = node.withLeft(newLeftChild);
      check(newNode.left).identicalTo(newLeftChild);
      check(newNode).not((it) => it.identicalTo(node));
    });

    test('withRight() creates a new instance with the new right child', () {
      final node = StringNode(item1, priority1, childLeft, null);
      final newRightChild = StringNode(item2, priority2, null, null);
      final newNode = node.withRight(newRightChild);
      check(newNode.right).identicalTo(newRightChild);
      check(newNode).not((it) => it.identicalTo(node));
    });

    test('withChildren() creates a new instance with new children', () {
      final node = StringNode(item1, priority1, null, null);
      final newLeft = StringNode(item2, priority2, null, null);
      final newRight = StringNode(item1, priority1, null, null);
      final newNode = node.withChildren(newLeft, newRight);
      check(newNode.left).identicalTo(newLeft);
      check(newNode.right).identicalTo(newRight);
      check(newNode).not((it) => it.identicalTo(node));
    });
  });

  group('DoubleNode', () {
    const item1 = 3.14;
    const item2 = 2.71;
    const priority1 = 8;
    const priority2 = 18;

    test('constructor initializes properties correctly (null children)', () {
      final node = DoubleNode(item1, priority1, null, null);
      check(node.item).equals(item1);
      check(node.priority).equals(priority1);
      check(node.left).isNull();
      check(node.right).isNull();
      check(node.size).equals(1);
    });

    final childLeft = DoubleNode(item2, priority2, null, null);
    final childRight = DoubleNode(item1, priority1, null, null);

    test('constructor initializes properties correctly (with children)', () {
      final node = DoubleNode(item1, priority1, childLeft, childRight);
      check(node.item).equals(item1);
      check(node.priority).equals(priority1);
      check(node.left).identicalTo(childLeft);
      check(node.right).identicalTo(childRight);
      check(node.size).equals(1 + childLeft.size + childRight.size);
    });

    test('copy() returns the same instance', () {
      final node = DoubleNode(item1, priority1, null, null);
      check(node.copy()).identicalTo(node);
    });

    test('withItem() creates a new instance with the new item', () {
      final node = DoubleNode(item1, priority1, childLeft, childRight);
      const newItem = 1.618;
      final newNode = node.withItem(newItem);
      check(newNode.item).equals(newItem);
      check(newNode.priority).equals(node.priority);
      check(newNode).not((it) => it.identicalTo(node));
    });

    test('withLeft() creates a new instance with the new left child', () {
      final node = DoubleNode(item1, priority1, null, childRight);
      final newLeftChild = DoubleNode(item2, priority2, null, null);
      final newNode = node.withLeft(newLeftChild);
      check(newNode.left).identicalTo(newLeftChild);
      check(newNode).not((it) => it.identicalTo(node));
    });

    test('withRight() creates a new instance with the new right child', () {
      final node = DoubleNode(item1, priority1, childLeft, null);
      final newRightChild = DoubleNode(item2, priority2, null, null);
      final newNode = node.withRight(newRightChild);
      check(newNode.right).identicalTo(newRightChild);
      check(newNode).not((it) => it.identicalTo(node));
    });

    test('withChildren() creates a new instance with new children', () {
      final node = DoubleNode(item1, priority1, null, null);
      final newLeft = DoubleNode(item2, priority2, null, null);
      final newRight = DoubleNode(item1, priority1, null, null);
      final newNode = node.withChildren(newLeft, newRight);
      check(newNode.left).identicalTo(newLeft);
      check(newNode.right).identicalTo(newRight);
      check(newNode).not((it) => it.identicalTo(node));
    });
  });

  group('Node Factories', () {
    test('intNodeFactory creates an IntNode', () {
      const item = 42;
      final node = intNodeFactory(item);
      check(node).isA<IntNode>();
      check(node.item).equals(item);
      check(node.priority).isA<int>(); // Priority is generated
      check(node.left).isNull(); // Factories create leaf nodes
      check(node.right).isNull();
      check(node.size).equals(1);
    });

    test('stringNodeFactory creates a StringNode', () {
      const item = "test_string";
      final node = stringNodeFactory(item);
      check(node).isA<StringNode>();
      check(node.item).equals(item);
      check(node.priority).isA<int>();
      check(node.left).isNull();
      check(node.right).isNull();
      check(node.size).equals(1);
    });

    test('doubleNodeFactory creates a DoubleNode', () {
      const item = 123.456;
      final node = doubleNodeFactory(item);
      check(node).isA<DoubleNode>();
      check(node.item).equals(item);
      check(node.priority).isA<int>();
      check(node.left).isNull();
      check(node.right).isNull();
      check(node.size).equals(1);
    });
  });
}
