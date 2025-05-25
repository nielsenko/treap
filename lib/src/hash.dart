// Copyright 2024 - 2025, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause

abstract final class Hash {
  // Use 32-bit constants suitable for dart2js
  static const int _c1 = 0xcc9e2d51;
  static const int _c2 = 0x1b873593;
  static const int _n = 0xe6546b64;

  @pragma('vm:prefer-inline')
  static int combine(int hash, int value) {
    // A 32-bit mixing function inspired by MurmurHash3
    value = (value * _c1) & 0xFFFFFFFF;
    value = (value << 15 | value >>> (32 - 15)) & 0xFFFFFFFF; // rotateLeft
    value = (value * _c2) & 0xFFFFFFFF;

    hash ^= value;
    hash = (hash << 13 | hash >>> (32 - 13)) & 0xFFFFFFFF; // rotateLeft
    hash = (hash * 5 + _n) & 0xFFFFFFFF;
    return hash;
  }

  @pragma('vm:prefer-inline')
  static int finish(int hash) {
    // Final mixing (avalanching)
    hash ^= hash >>> 16;
    hash = (hash * 0x85ebca6b) & 0xFFFFFFFF;
    hash ^= hash >>> 13;
    hash = (hash * 0xc2b2ae35) & 0xFFFFFFFF;
    hash ^= hash >>> 16;
    return hash;
  }

  static int hash(int v1, int seed) {
    int hash = seed;
    hash = combine(hash, v1);
    return finish(hash);
  }

  static int hash2(int v1, int v2, int seed) {
    int hash = seed;
    hash = combine(hash, v1);
    hash = combine(hash, v2);
    return finish(hash);
  }

  static int hash3(int v1, int v2, int v3, int seed) {
    int hash = seed;
    hash = combine(hash, v1);
    hash = combine(hash, v2);
    hash = combine(hash, v3);
    return finish(hash);
  }

  static int hash4(int v1, int v2, int v3, int v4, int seed) {
    int hash = seed;
    hash = combine(hash, v1);
    hash = combine(hash, v2);
    hash = combine(hash, v3);
    hash = combine(hash, v4);
    return finish(hash);
  }
}
