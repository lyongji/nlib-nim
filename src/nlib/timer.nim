## 挂钟计时辅助函数。

import std/times

proc timef*(f: proc(), ns = 1000, dt = 60.0): float =
  ## 重复调用 `f` 并返回每次调用的平均挂钟时间，
  ## 最多 `ns` 次迭代或 `dt` 秒。
  let t0 = epochTime()
  var t = t0
  var k = 1
  while k < ns:
    f()
    t = epochTime()
    if t - t0 > dt: break
    inc k
  result = (t - t0) / float(k)
