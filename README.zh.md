# nlib —— 注解版 Nim 算法

`nlib` 是 *Annotated Algorithms in Nim — Applications in Physics, Biology, Finance*（作者 Massimo Di Pierro）的配套 Nim 包。本书是将此前最初在 DePaul 大学计算学院十多年讲座中用 Python 编写的版本移植到 Nim。内容涵盖算法设计与分析、科学计算、蒙特卡洛模拟和并行算法的核心思想，并附有金融、物理、生物学和计算机科学领域的完整实例。

本库是与书籍同步演进的可用代码：书中的每个算法都在此定义，并被后续章节使用。

## 目录结构

```
nim/
├── book/             # 书籍源代码（LaTeX、插图）
├── src/
│   ├── nlib.nim      # 伞模块；重新导出所有子模块
│   └── nlib/
│       ├── sorting.nim     bst.nim       heap.nim
│       ├── graph.nim       text.nim      compression.nim
│       ├── matrix.nim      linalg.nim    calculus.nim
│       ├── taylor.nim      solvers.nim   fitting.nim
│       ├── integration.nim stats.nim     randomgen.nim
│       ├── montecarlo.nim  cluster.nim   neural.nim
│       ├── finance.nim     memoize.nim   persistent.nim
│       ├── plotting.nim    timer.nim
└── tests/            # 每个子模块对应一个测试文件
```

使用者只需 `import nlib` 即可访问所有公开名称；子模块也可以单独导入以减少依赖体积。

## 内容概览

| 主题 | 子模块 | 代表性名称 |
|------|--------|-----------|
| 排序与搜索 | `nlib/sorting` | `insertionSort`, `mergesort`, `quicksort`, `binarySearch` |
| 堆 | `nlib/heap` | `heapify`, `heapsort`, `heapPush`, `heapPop` |
| 树 | `nlib/bst` | `BinarySearchTree` |
| 图 | `nlib/graph` | `breadthFirstSearch`, `kruskal`, `prim`, `dijkstra` |
| 压缩 | `nlib/compression` | `encodeHuffman`, `decodeHuffman` |
| 序列比对 | `nlib/text` | `lcs`, `needlemanWunsch` |
| 矩阵代数 | `nlib/matrix` | `Matrix`, `+`, `*`, `inv`, `T` |
| 数值线性代数 | `nlib/linalg` | `cholesky`, `jacobiEigenvalues`, `invertBicgstab` |
| 微分 | `nlib/calculus` | `D`, `DD`, `partial`, `gradient`, `hessian`, `jacobian` |
| 泰勒逼近 | `nlib/taylor` | `myexp`, `mysin`, `mycos` |
| 求解器/优化 | `nlib/solvers` | `solveBisection`, `optimizeNewton`, `solveNewtonMulti` |
| 曲线拟合 | `nlib/fitting` | `fitLeastSquares`, `polynomial`, `fit` |
| 积分 | `nlib/integration` | `integrate`, `QuadratureIntegrator` |
| 统计 | `nlib/stats` | `mean`, `variance`, `correlation` |
| 随机数生成器 | `nlib/randomgen` | `MCG`, `MarsenneTwister`, `RandomSource`, distributions |
| 蒙特卡洛 | `nlib/montecarlo` | `bootstrap`, `MCEngine`, `valueAtRisk` |
| 聚类 | `nlib/cluster` | `Cluster`, 层次凝聚 |
| 神经网络 | `nlib/neural` | `NeuralNetwork`, 反向传播 |
| 金融 | `nlib/finance` | `markowitz`, `Trader`, `fakeStockPrices` |
| 记忆化 | `nlib/memoize` | `memoize` |
| 持久化 | `nlib/persistent` | `PersistentDictionary`（基于 JSON） |
| 绘图 | `nlib/plotting` | `savePlot`, `saveHistogram`, ...（gnuplot 封装） |
| 计时 | `nlib/timer` | `timef` |

## 构建

仓库附带 [`rigx`](https://github.com/example/rigx) 配置，提供两个目标：

```sh
rigx build pdf       # 渲染 book/book_numerical.pdf
rigx test            # 构建并运行 Nim 测试套件
```

直接调用同样可行：

```sh
nim r --path:src tests/all.nim    # 运行所有测试
nimble test                       # 通过包清单运行测试
```

测试仅使用 Nim 标准库；绘图辅助函数在可用时会调用 `gnuplot`。

## 许可

BSD 3-Clause。由作者发布。
