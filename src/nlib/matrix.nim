## 稠密浮点矩阵，行主序存储，重载算术运算。
## 书中的 NeuralNetwork、Markowitz、特征值和稀疏求解器代码均基于此类型。

import std/sequtils

type
  Matrix* = ref object
    nrows*, ncols*: int
    data*: seq[float]    # 行主序

proc newMatrix*(rows: int, cols = 1, fill = 0.0): Matrix =
  ## 一个用 `fill` 填充的 `rows x cols` 矩阵。
  Matrix(nrows: rows, ncols: cols,
         data: newSeqWith(rows * cols, fill))

proc newMatrix*(rows, cols: int, fill: proc(r, c: int): float): Matrix =
  ## 一个 `rows x cols` 矩阵，元素 (r, c) 为 `fill(r, c)`。
  result = Matrix(nrows: rows, ncols: cols,
                  data: newSeq[float](rows * cols))
  for r in 0 ..< rows:
    for c in 0 ..< cols:
      result.data[r * cols + c] = fill(r, c)

proc newMatrix*(rows: seq[seq[float]]): Matrix =
  ## 从行序列构建。
  let n = rows.len
  let m = rows[0].len
  result = newMatrix(n, m)
  for r in 0 ..< n:
    for c in 0 ..< m:
      result.data[r * m + c] = rows[r][c]

proc newMatrix*(values: seq[float]): Matrix =
  ## 从一维序列构建列向量。
  newMatrix(values.len, 1, proc(r, c: int): float = values[r])

proc `[]`*(a: Matrix, i, j: int): float = a.data[i * a.ncols + j]
proc `[]=`*(a: Matrix, i, j: int, value: float) =
  a.data[i * a.ncols + j] = value

proc tolist*(a: Matrix): seq[seq[float]] =
  for r in 0 ..< a.nrows:
    var row = newSeq[float](a.ncols)
    for c in 0 ..< a.ncols: row[c] = a[r, c]
    result.add row

proc `$`*(a: Matrix): string = $a.tolist()

proc flatten*(a: Matrix): seq[float] = a.data

proc reshape*(a: Matrix, n, m: int): Matrix =
  if n * m != a.nrows * a.ncols:
    raise newException(ValueError, "Impossible reshape")
  let flat = a.data
  newMatrix(n, m, proc(r, c: int): float = flat[r * m + c])

proc swapRows*(a: Matrix, i, j: int) =
  for c in 0 ..< a.ncols:
    swap(a.data[i * a.ncols + c], a.data[j * a.ncols + c])

proc identity*(rows = 1, e = 1.0): Matrix =
  newMatrix(rows, rows,
    proc(r, c: int): float = (if r == c: e else: 0.0))

proc diagonal*(d: seq[float]): Matrix =
  newMatrix(d.len, d.len,
    proc(r, c: int): float = (if r == c: d[r] else: 0.0))

# 逐元素加减法；对标量广播（方阵或向量矩阵）遵循书中约定。

proc `+`*(a, b: Matrix): Matrix =
  if a.nrows != b.nrows or a.ncols != b.ncols:
    raise newException(ArithmeticDefect, "incompatible dimensions")
  result = newMatrix(a.nrows, a.ncols)
  for i in 0 ..< a.data.len:
    result.data[i] = a.data[i] + b.data[i]

proc `+`*(a: Matrix, x: float): Matrix =
  if a.nrows == a.ncols:
    return a + identity(a.nrows, x)
  if a.nrows == 1 or a.ncols == 1:
    return a + newMatrix(a.nrows, a.ncols, x)
  raise newException(ArithmeticDefect, "incompatible dimensions")

proc `+`*(x: float, a: Matrix): Matrix = a + x

proc `-`*(a: Matrix): Matrix =
  newMatrix(a.nrows, a.ncols, proc(r, c: int): float = -a[r, c])

proc `-`*(a, b: Matrix): Matrix = a + (-b)
proc `-`*(a: Matrix, x: float): Matrix = a + (-x)
proc `-`*(x: float, a: Matrix): Matrix = (-a) + x

proc `*`*(x: float, a: Matrix): Matrix =
  result = newMatrix(a.nrows, a.ncols)
  for i in 0 ..< a.data.len:
    result.data[i] = x * a.data[i]

proc `*`*(a: Matrix, x: float): Matrix = x * a

proc `*`*(a, b: Matrix): Matrix =
  ## 矩阵乘法。作为便利，两个等长列向量返回其标量积，封装在 1x1 矩阵中。
  if a.ncols == 1 and b.ncols == 1 and a.nrows == b.nrows:
    var s = 0.0
    for r in 0 ..< a.nrows: s += a[r, 0] * b[r, 0]
    result = newMatrix(1, 1, s)
    return result
  if a.ncols != b.nrows:
    raise newException(ArithmeticDefect, "Incompatible dimension")
  result = newMatrix(a.nrows, b.ncols)
  for r in 0 ..< a.nrows:
    for c in 0 ..< b.ncols:
      var s = 0.0
      for k in 0 ..< a.ncols:
        s += a[r, k] * b[k, c]
      result[r, c] = s

proc inv*(a0: Matrix, x = 1.0): Matrix =
  ## 使用部分主元 Gauss-Jordan 消去法计算 x * a⁻¹。
  let n = a0.ncols
  if a0.nrows != n:
    raise newException(ArithmeticDefect, "matrix not squared")
  let a = newMatrix(a0.tolist())
  let b = identity(n, x)
  for c in 0 ..< n:
    for r in c + 1 ..< n:
      if abs(a[r, c]) > abs(a[c, c]):
        a.swapRows(r, c)
        b.swapRows(r, c)
    let p = a[c, c]
    for k in 0 ..< n:
      a[c, k] = a[c, k] / p
      b[c, k] = b[c, k] / p
    for r in 0 ..< n:
      if r == c: continue
      let pr = a[r, c]
      for k in 0 ..< n:
        a[r, k] = a[r, k] - a[c, k] * pr
        b[r, k] = b[r, k] - b[c, k] * pr
  result = b

proc `/`*(x: float, a: Matrix): Matrix = inv(a, x)
proc `/`*(a: Matrix, x: float): Matrix = (1.0 / x) * a
proc `/`*(a, b: Matrix): Matrix = a * (1.0 / b)

proc T*(a: Matrix): Matrix =
  ## `a` 的转置。
  newMatrix(a.ncols, a.nrows, proc(r, c: int): float = a[c, r])

proc isAlmostSymmetric*(a: Matrix, ap = 1e-6, rp = 1e-4): bool =
  if a.nrows != a.ncols: return false
  for r in 0 ..< a.nrows:
    for c in 0 ..< r:
      let delta = abs(a[r, c] - a[c, r])
      if delta > ap and delta > max(abs(a[r, c]), abs(a[c, r])) * rp:
        return false
  return true

proc isAlmostZero*(a: Matrix, ap = 1e-6, rp = 1e-4): bool =
  for r in 0 ..< a.nrows:
    for c in 0 ..< a.ncols:
      let delta = abs(a[r, c] - a[c, r])
      if delta > ap and delta > max(abs(a[r, c]), abs(a[c, r])) * rp:
        return false
  return true
