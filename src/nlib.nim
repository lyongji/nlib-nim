## nlib —— 随书附带的数值算法库
## 《注解版 Nim 算法》（Massimo Di Pierro 著）
##
## 这是一个轻量伞模块，重新导出 `src/nlib/` 下所有子模块的内容，
## 用户代码只需
##
##   import nlib
##
## 即可访问整个库。子模块也可单独导入以减小依赖体积。

import nlib/sorting;        export sorting
import nlib/heap;           export heap
import nlib/bst;            export bst
import nlib/graph;          export graph
import nlib/compression;    export compression
import nlib/text;           export text
import nlib/matrix;         export matrix
import nlib/calculus;       export calculus
import nlib/taylor;         export taylor
import nlib/linalg;         export linalg
import nlib/solvers;        export solvers
import nlib/fitting;        export fitting
import nlib/integration;    export integration
import nlib/stats;          export stats
import nlib/randomgen;      export randomgen
import nlib/montecarlo;     export montecarlo
import nlib/cluster;        export cluster
import nlib/neural;         export neural
import nlib/memoize;        export memoize
import nlib/persistent;     export persistent
import nlib/finance;        export finance
import nlib/timer;          export timer
import nlib/plotting;       export plotting
