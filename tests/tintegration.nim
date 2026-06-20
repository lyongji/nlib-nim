import std/[unittest, math]
import nlib/integration

suite "integration":
  test "trapezoidal on sin from 0 to pi":
    proc f(x: float): float = sin(x)
    check abs(integrateNaive(f, 0.0, PI, n = 200) - 2.0) < 1e-3

  test "adaptive integrate matches analytical sin integral":
    proc f(x: float): float = sin(x)
    check abs(integrate(f, 0.0, 3.0) - (1.0 - cos(3.0))) < 1e-3

  test "quadrature integrator at order 4":
    # 覆盖整个 [0, 3] 区间的 4 点求积公式精度仅为 ~h⁴；
    # 下面的 integralQuadratureNaive 驱动是细分域的精确实体。
    proc f(x: float): float = sin(x)
    let q = newQuadratureIntegrator(order = 4)
    check abs(q.integrate(f, 0.0, 3.0) - (1.0 - cos(3.0))) < 5e-2

  test "quadrature naive driver":
    proc f(x: float): float = x * x
    # x² 从 0 到 1 的积分为 1/3
    check abs(integrateQuadratureNaive(f, 0.0, 1.0,
                                        n = 5, order = 3) - 1.0/3.0) < 1e-6
