// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause

import 'package:test/test.dart';
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
      expect(node.item, item1);
      expect(node.priority, priority1);
      expect(node.left, isNull);
      expect(node.right, isNull);
      expect(node.size, 1);
    });

    test('constructor initializes properties correctly (optional children)',
        () {
      final node = IntNode(item1, priority1); // Omitting optional children
      expect(node.item, item1);
      expect(node.priority, priority1);
      expect(node.left, isNull);
      expect(node.right, isNull);
      expect(node.size, 1);
    });

    final childLeft = IntNode(item2, priority2, null, null);
    final childRight = IntNode(item1, priority1, null, null);

    test('constructor initializes properties correctly (with children)', () {
      final node = IntNode(item1, priority1, childLeft, childRight);
      expect(node.item, item1);
      expect(node.priority, priority1);
      expect(node.left, same(childLeft));
      expect(node.right, same(childRight));
      expect(node.size, 1 + childLeft.size + childRight.size);
    });

    test('copy() returns the same instance', () {
      final node = IntNode(item1, priority1, null, null);
      expect(node.copy(), same(node));
    });

    test('withItem() creates a new instance with the new item', () {
      final node = IntNode(item1, priority1, childLeft, childRight);
      const newItem = 300;
      final newNode = node.withItem(newItem);

      expect(newNode.item, newItem);
      expect(newNode.priority, node.priority);
      expect(newNode.left, same(node.left));
      expect(newNode.right, same(node.right));
      expect(newNode.size, node.size);
      expect(newNode, isNot(same(node)));
    });

    test('withLeft() creates a new instance with the new left child', () {
      final node = IntNode(item1, priority1, null, childRight);
      final newLeftChild = IntNode(item2, priority2, null, null);
      final newNode = node.withLeft(newLeftChild);

      expect(newNode.item, node.item);
      expect(newNode.priority, node.priority);
      expect(newNode.left, same(newLeftChild));
      expect(newNode.right, same(node.right));
      expect(newNode.size, 1 + newLeftChild.size + (node.right?.size ?? 0));
      expect(newNode, isNot(same(node)));
    });

    test('withRight() creates a new instance with the new right child', () {
      final node = IntNode(item1, priority1, childLeft, null);
      final newRightChild = IntNode(item2, priority2, null, null);
      final newNode = node.withRight(newRightChild);

      expect(newNode.item, node.item);
      expect(newNode.priority, node.priority);
      expect(newNode.left, same(node.left));
      expect(newNode.right, same(newRightChild));
      expect(newNode.size, 1 + (node.left?.size ?? 0) + newRightChild.size);
      expect(newNode, isNot(same(node)));
    });

    test('withChildren() creates a new instance with new children', () {
      final node = IntNode(item1, priority1, null, null);
      final newLeft = IntNode(item2, priority2, null, null);
      final newRight = IntNode(item1, priority1, null, null);
      final newNode = node.withChildren(newLeft, newRight);

      expect(newNode.item, node.item);
      expect(newNode.priority, node.priority);
      expect(newNode.left, same(newLeft));
      expect(newNode.right, same(newRight));
      expect(newNode.size, 1 + newLeft.size + newRight.size);
      expect(newNode, isNot(same(node)));
    });
  });

  group('StringNode', () {
    const item1 = "apple";
    const item2 = "banana";
    const priority1 = 7;
    const priority2 = 17;

    test('constructor initializes properties correctly (null children)', () {
      final node = StringNode(item1, priority1, null, null);
      expect(node.item, item1);
      expect(node.priority, priority1);
      expect(node.left, isNull);
      expect(node.right, isNull);
      expect(node.size, 1);
    });

    final childLeft = StringNode(item2, priority2, null, null);
    final childRight = StringNode(item1, priority1, null, null);

    test('constructor initializes properties correctly (with children)', () {
      final node = StringNode(item1, priority1, childLeft, childRight);
      expect(node.item, item1);
      expect(node.priority, priority1);
      expect(node.left, same(childLeft));
      expect(node.right, same(childRight));
      expect(node.size, 1 + childLeft.size + childRight.size);
    });

    test('copy() returns the same instance', () {
      final node = StringNode(item1, priority1, null, null);
      expect(node.copy(), same(node));
    });

    test('withItem() creates a new instance with the new item', () {
      final node = StringNode(item1, priority1, childLeft, childRight);
      const newItem = "cherry";
      final newNode = node.withItem(newItem);
      expect(newNode.item, newItem);
      expect(newNode.priority, node.priority);
      expect(newNode, isNot(same(node)));
    });

    test('withLeft() creates a new instance with the new left child', () {
      final node = StringNode(item1, priority1, null, childRight);
      final newLeftChild = StringNode(item2, priority2, null, null);
      final newNode = node.withLeft(newLeftChild);
      expect(newNode.left, same(newLeftChild));
      expect(newNode, isNot(same(node)));
    });

    test('withRight() creates a new instance with the new right child', () {
      final node = StringNode(item1, priority1, childLeft, null);
      final newRightChild = StringNode(item2, priority2, null, null);
      final newNode = node.withRight(newRightChild);
      expect(newNode.right, same(newRightChild));
      expect(newNode, isNot(same(node)));
    });

    test('withChildren() creates a new instance with new children', () {
      final node = StringNode(item1, priority1, null, null);
      final newLeft = StringNode(item2, priority2, null, null);
      final newRight = StringNode(item1, priority1, null, null);
      final newNode = node.withChildren(newLeft, newRight);
      expect(newNode.left, same(newLeft));
      expect(newNode.right, same(newRight));
      expect(newNode, isNot(same(node)));
    });
  });

  group('DoubleNode', () {
    const item1 = 3.14;
    const item2 = 2.71;
    const priority1 = 8;
    const priority2 = 18;

    test('constructor initializes properties correctly (null children)', () {
      final node = DoubleNode(item1, priority1, null, null);
      expect(node.item, item1);
      expect(node.priority, priority1);
      expect(node.left, isNull);
      expect(node.right, isNull);
      expect(node.size, 1);
    });

    final childLeft = DoubleNode(item2, priority2, null, null);
    final childRight = DoubleNode(item1, priority1, null, null);

    test('constructor initializes properties correctly (with children)', () {
      final node = DoubleNode(item1, priority1, childLeft, childRight);
      expect(node.item, item1);
      expect(node.priority, priority1);
      expect(node.left, same(childLeft));
      expect(node.right, same(childRight));
      expect(node.size, 1 + childLeft.size + childRight.size);
    });

    test('copy() returns the same instance', () {
      final node = DoubleNode(item1, priority1, null, null);
      expect(node.copy(), same(node));
    });

    test('withItem() creates a new instance with the new item', () {
      final node = DoubleNode(item1, priority1, childLeft, childRight);
      const newItem = 1.618;
      final newNode = node.withItem(newItem);
      expect(newNode.item, newItem);
      expect(newNode.priority, node.priority);
      expect(newNode, isNot(same(node)));
    });

    test('withLeft() creates a new instance with the new left child', () {
      final node = DoubleNode(item1, priority1, null, childRight);
      final newLeftChild = DoubleNode(item2, priority2, null, null);
      final newNode = node.withLeft(newLeftChild);
      expect(newNode.left, same(newLeftChild));
      expect(newNode, isNot(same(node)));
    });

    test('withRight() creates a new instance with the new right child', () {
      final node = DoubleNode(item1, priority1, childLeft, null);
      final newRightChild = DoubleNode(item2, priority2, null, null);
      final newNode = node.withRight(newRightChild);
      expect(newNode.right, same(newRightChild));
      expect(newNode, isNot(same(node)));
    });

    test('withChildren() creates a new instance with new children', () {
      final node = DoubleNode(item1, priority1, null, null);
      final newLeft = DoubleNode(item2, priority2, null, null);
      final newRight = DoubleNode(item1, priority1, null, null);
      final newNode = node.withChildren(newLeft, newRight);
      expect(newNode.left, same(newLeft));
      expect(newNode.right, same(newRight));
      expect(newNode, isNot(same(node)));
    });
  });

  group('Node Factories', () {
    test('intNodeFactory creates an IntNode', () {
      const item = 42;
      final node = intNodeFactory(item);
      expect(node, isA<IntNode>());
      expect(node.item, item);
      expect(node.priority, isA<int>()); // Priority is generated
      expect(node.left, isNull); // Factories create leaf nodes
      expect(node.right, isNull);
      expect(node.size, 1);
    });

    test('stringNodeFactory creates a StringNode', () {
      const item = "test_string";
      final node = stringNodeFactory(item);
      expect(node, isA<StringNode>());
      expect(node.item, item);
      expect(node.priority, isA<int>());
      expect(node.left, isNull);
      expect(node.right, isNull);
      expect(node.size, 1);
    });

    test('doubleNodeFactory creates a DoubleNode', () {
      const item = 123.456;
      final node = doubleNodeFactory(item);
      expect(node, isA<DoubleNode>());
      expect(node.item, item);
      expect(node.priority, isA<int>());
      expect(node.left, isNull);
      expect(node.right, isNull);
      expect(node.size, 1);
    });
  });
}
