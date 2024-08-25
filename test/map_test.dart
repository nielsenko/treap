import 'package:treap/treap.dart';
import 'package:test/test.dart';

int _compare(int a, int b) => a - b;
void main() {
  group('TreapMap', () {
    test('add', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      expect(tm.length, 3);
      expect(tm[1], 'one');
      expect(tm[2], 'two');
      expect(tm[3], 'three');
    });

    test('update', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      tm[2] = 'new two';
      tm[3] = 'new three';

      expect(tm.length, 3);
      expect(tm[1], 'one');
      expect(tm[2], 'new two');
      expect(tm[3], 'new three');
    });

    test('remove', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      tm.remove(2);

      expect(tm.length, 2);
      expect(tm.containsKey(2), false);
      expect(tm[1], 'one');
      expect(tm[3], 'three');
    });

    test('contains', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      expect(tm.containsKey(1), true);
      expect(tm.containsKey(4), false);
    });

    test('iterate', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      final keys = [];
      final values = [];

      for (final entry in tm.entries) {
        keys.add(entry.key);
        values.add(entry.value);
      }

      expect(keys, [1, 2, 3]);
      expect(values, ['one', 'two', 'three']);
    });

    test('clear', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';
      expect(tm.length, greaterThan(0));
      expect(tm.isNotEmpty, isTrue);

      tm.clear();

      expect(tm.length, 0);
      expect(tm.isEmpty, isTrue);
    });

    test('forEach', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      final keys = [];
      final values = [];

      tm.forEach((key, value) {
        keys.add(key);
        values.add(value);
      });

      expect(keys, [1, 2, 3]);
      expect(values, ['one', 'two', 'three']);
    });

    test('isEmpty', () {
      final tm = TreapMap<int, String>(_compare);
      expect(tm.isEmpty, isTrue);
      tm[1] = 'one';
      expect(tm.isEmpty, isFalse);
    });

    test('keys', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      final keys = tm.keys.toList();
      expect(keys, [1, 2, 3]);
    });

    test('values', () {
      final tm = TreapMap<int, String>(_compare);
      tm[1] = 'one';
      tm[2] = 'two';
      tm[3] = 'three';

      final values = tm.values.toList();
      expect(values, ['one', 'two', 'three']);
    });
  });
}
