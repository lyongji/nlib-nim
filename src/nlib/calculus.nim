## 数值导数、梯度、Hessian 矩阵和 Jacobian 矩阵。

import ./matrix

proc D*(f: proc(x: float): float, h = 1e-6): proc(x: float): float =
  ## `f` 的一阶导数（中心差分）。
  result = proc(x: float): float = (f(x + h) - f(x - h)) / 2.0 / h

proc DD*(f: proc(x: float): float, h = 1e-6): proc(x: float): float =
  ## `f` 的二阶导数（中心差分）。
  result = proc(x: float): float =
    (f(x + h) - 2.0 * f(x) + f(x - h)) / (h * h)

proc partial*(f: proc(x: seq[float]): float, i: int, h = 1e-4):
              proc(x: seq[float]): float =
  ## 标量值多元函数的第 i 个偏导数。
  result = proc(x: seq[float]): float =
    var x = x
    x[i] += h
    let fPlus = f(x)
    x[i] -= 2.0 * h
    let fMinus = f(x)
    (fPlus - fMinus) / (2.0 * h)

proc partial*(f: proc(x: seq[float]): seq[float], i: int, h = 1e-4):
              proc(x: seq[float]): seq[float] =
  ## 向量值函数的第 i 个偏导数。
  result = proc(x: seq[float]): seq[float] =
    var x = x
    x[i] += h
    let fPlus = f(x)
    x[i] -= 2.0 * h
    let fMinus = f(x)
    result = newSeq[float](fPlus.len)
    for k in 0 ..< fPlus.len:
      result[k] = (fPlus[k] - fMinus[k]) / (2.0 * h)

proc gradient*(f: proc(x: seq[float]): float,
               x: seq[float], h = 1e-4): Matrix =
  newMatrix(x.len, 1, proc(r, c: int): float = partial(f, r, h)(x))

proc hessian*(f: proc(x: seq[float]): float,
              x: seq[float], h = 1e-4): Matrix =
  newMatrix(x.len, x.len,
    proc(r, c: int): float = partial(partial(f, r, h), c, h)(x))

proc jacobian*(f: proc(x: seq[float]): seq[float],
               x: seq[float], h = 1e-4): Matrix =
  var partials: seq[seq[float]] = @[]
  for c in 0 ..< x.len:
    partials.add partial(f, c, h)(x)
  newMatrix(partials[0].len, x.len,
    proc(r, c: int): float = partials[c][r])
