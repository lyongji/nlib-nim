## 通用记忆化工具。

import std/tables

proc memoize*[K, V](f: proc(self: proc(x: K): V, x: K): V):
                     proc(x: K): V =
  ## 返回 `f` 的记忆化版本。递归函数 `f`
  ## 将记忆化闭包作为其第一个参数，以便通过缓存进行递归。
  var storage = initTable[K, V]()
  proc memoized(x: K): V =
    if x in storage: return storage[x]
    result = f(memoized, x)
    storage[x] = result
  return memoized
