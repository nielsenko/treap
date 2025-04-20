// Copyright 2024 - 2024, kasper@byolimit.com
// SPDX-License-Identifier: BSD-3-Clause

abstract final class Hash {
  @pragma('vm:prefer-inline')
  static int combine(int hash, int value) {
    hash ^= value + 0x9e3779b97f4a7c15;
    hash = (hash ^ (hash >> 30)) * 0xbf58476d1ce4e5b9;
    hash = (hash ^ (hash >> 27)) * 0x94d049bb133111eb;
    return hash;
  }

  @pragma('vm:prefer-inline')
  static int finish(int hash) {
    hash ^= hash >> 33;
    hash *= 0xff51afd7ed558ccd;
    hash ^= hash >> 33;
    hash *= 0xc4ceb9fe1a85ec53;
    hash ^= hash >> 33;
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

  static int foo(int key) {
    key = (~key + (key << 21)) & 0xFFFFFFFFFFFFFFFF;
    key = key ^ (key >> 33);
    key = ((key + (key << 3)) + (key << 8)) & 0xFFFFFFFFFFFFFFFF;
    key = key ^ (key >> 29);
    key = ((key + (key << 2)) + (key << 4)) & 0xFFFFFFFFFFFFFFFF;
    key = key ^ (key >> 47);
    return key;
  }

  // add more as needed ..
}
