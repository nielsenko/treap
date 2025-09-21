// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause
import 'package:test/scaffolding.dart';
import 'package:checks/checks.dart';
import 'package:treap/src/hash.dart'; // Assuming Hash class is in src/hash.dart

void main() {
  group('Hash class', () {
    // Test Hash.hash (already covered, but good to have a baseline understanding)
    test('Hash.hash generates distinct hashes for different values or seeds',
        () {
      final h1 = Hash.hash(123, 0);
      final h2 = Hash.hash(123, 1); // Different seed
      final h3 = Hash.hash(456, 0); // Different value

      check(h1).isA<int>();
      check(h1).not((it) => it.equals(h2));
      check(h1).not((it) => it.equals(h3));
    });

    // Tests for Hash.hash2
    test('Hash.hash2 generates distinct hashes for different values or seeds',
        () {
      final h1 = Hash.hash2(10, 20, 0);
      final h2 = Hash.hash2(10, 20, 1); // Different seed
      final h3 = Hash.hash2(10, 30, 0); // Different second value
      final h4 = Hash.hash2(5, 20, 0); // Different first value

      check(h1).isA<int>();
      check(h1).not((it) => it.equals(h2));
      check(h1).not((it) => it.equals(h3));
      check(h1).not((it) => it.equals(h4));
    });

    // Tests for Hash.hash3
    test('Hash.hash3 generates distinct hashes for different values or seeds',
        () {
      final h1 = Hash.hash3(10, 20, 30, 0);
      final h2 = Hash.hash3(10, 20, 30, 1); // Different seed
      final h3 = Hash.hash3(10, 20, 40, 0); // Different third value
      final h4 = Hash.hash3(10, 5, 30, 0); // Different second value
      final h5 = Hash.hash3(1, 20, 30, 0); // Different first value

      check(h1).isA<int>();
      check(h1).not((it) => it.equals(h2));
      check(h1).not((it) => it.equals(h3));
      check(h1).not((it) => it.equals(h4));
      check(h1).not((it) => it.equals(h5));
    });

    // Tests for Hash.hash4
    test('Hash.hash4 generates distinct hashes for different values or seeds',
        () {
      final h1 = Hash.hash4(10, 20, 30, 40, 0);
      final h2 = Hash.hash4(10, 20, 30, 40, 1); // Different seed
      final h3 = Hash.hash4(10, 20, 30, 50, 0); // Different fourth value
      final h4 = Hash.hash4(10, 20, 5, 40, 0); // Different third value
      final h5 = Hash.hash4(10, 1, 30, 40, 0); // Different second value
      final h6 = Hash.hash4(2, 20, 30, 40, 0); // Different first value

      check(h1).isA<int>();
      check(h1).not((it) => it.equals(h2));
      check(h1).not((it) => it.equals(h3));
      check(h1).not((it) => it.equals(h4));
      check(h1).not((it) => it.equals(h5));
      check(h1).not((it) => it.equals(h6));
    });

    // Test that combine and finish are used by the hashX methods
    // by ensuring a simple case works as expected.
    // This isn't strictly necessary if hashX tests pass, but confirms linkage.
    test('Hash.hash internally uses combine and finish', () {
      // Replicate Hash.hash(val, seed) manually
      final val = 12345;
      final seed = 67890;
      var expectedHash = seed;
      expectedHash = Hash.combine(expectedHash, val);
      expectedHash = Hash.finish(expectedHash);

      check(Hash.hash(val, seed)).equals(expectedHash);
    });
  });
}
