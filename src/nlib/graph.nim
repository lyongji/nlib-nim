## 图算法：BFS、DFS、不相交集、最小生成树（Kruskal/Prim）、Dijkstra。

import std/[algorithm, math, random]

# --- BFS / DFS 广度优先/深度优先搜索 -------------------------------------

proc breadthFirstSearch*[V](
    graph: tuple[vertices: seq[V], links: seq[(int, int)]],
    start: int): seq[int] =
  ## 在图上执行 BFS。返回从 `start` 开始的访问顺序。
  var blacknodes: seq[int] = @[]
  var graynodes = @[start]
  var neighbors = newSeq[seq[int]](graph.vertices.len)
  for link in graph.links:
    neighbors[link[0]].add link[1]
  while graynodes.len > 0:
    let current = graynodes.pop()
    for neighbor in neighbors[current]:
      if neighbor notin blacknodes and neighbor notin graynodes:
        graynodes.insert(neighbor, 0)
    blacknodes.add current
  result = blacknodes

proc depthFirstSearch*[V](
    graph: tuple[vertices: seq[V], links: seq[(int, int)]],
    start: int): seq[int] =
  ## 在图上执行 DFS。返回从 `start` 开始的访问顺序。
  var blacknodes: seq[int] = @[]
  var graynodes = @[start]
  var neighbors = newSeq[seq[int]](graph.vertices.len)
  for link in graph.links:
    neighbors[link[0]].add link[1]
  while graynodes.len > 0:
    let current = graynodes.pop()
    for neighbor in neighbors[current]:
      if neighbor notin blacknodes and neighbor notin graynodes:
        graynodes.add neighbor
    blacknodes.add current
  result = blacknodes

# --- 不相交集（Union-Find）---------------------------------------------

type
  DisjointSets* = ref object
    sets*: seq[int]
    counter*: int

proc newDisjointSets*(n: int): DisjointSets =
  result = DisjointSets(sets: newSeq[int](n), counter: n)
  for i in 0 ..< n: result.sets[i] = -1

proc parent*(d: DisjointSets, i: int): int =
  var i = i
  while true:
    let j = d.sets[i]
    if j < 0: return i
    i = j

proc join*(d: DisjointSets, i, j: int): bool =
  let pi = d.parent(i)
  let pj = d.parent(j)
  if pi != pj:
    d.sets[pi] += d.sets[pj]
    d.sets[pj] = pi
    dec d.counter
    return true
  return false

proc joined*(d: DisjointSets, i, j: int): bool =
  d.parent(i) == d.parent(j)

proc len*(d: DisjointSets): int = d.counter

# --- 迷宫 ---------------------------------------------------------------

proc makeMaze*(n, d: int): tuple[walls, tornDownWalls: seq[(int, int)]] =
  ## 生成一个 `n^d` 迷宫，随机拆墙直到所有格子连通。
  ## 返回（剩余墙壁, 已拆除墙壁）。
  var walls: seq[(int, int)] = @[]
  let total = n ^ d
  for i in 0 ..< n * n:
    for j in 0 ..< d:
      if (i div (n ^ j)) mod n + 1 < n:
        walls.add (i, i + n ^ j)
  var tornDownWalls: seq[(int, int)] = @[]
  let ds = newDisjointSets(total)
  shuffle(walls)
  for wall in walls:
    if ds.join(wall[0], wall[1]):
      tornDownWalls.add wall
    if ds.len == 1:
      break
  var remaining: seq[(int, int)] = @[]
  for wall in walls:
    if wall notin tornDownWalls:
      remaining.add wall
  (remaining, tornDownWalls)

# --- Kruskal 最小生成树 -------------------------------------------------

proc kruskal*[V](
    graph: tuple[vertices: seq[V],
                 links: seq[(int, int, float)]]
    ): seq[(int, int, float)] =
  ## 在无向带权图上执行 Kruskal 最小生成树算法。
  var links = graph.links
  links.sort(proc(a, b: (int, int, float)): int = cmp(a[2], b[2]))
  let s = newDisjointSets(graph.vertices.len)
  for link in links:
    let (source, dest, length) = link
    if s.join(source, dest):
      result.add (source, dest, length)

# --- Prim 最小生成树 / Dijkstra 最短路径 -----------------------------------

const PRIM_INFINITY* = 1e100

type
  PrimVertex* = ref object
    id*: int
    closest*: PrimVertex
    closestDist*: float
    neighbors*: seq[(int, float)]

proc newPrimVertex*(id: int, links: seq[(int, int, float)]): PrimVertex =
  result = PrimVertex(id: id, closest: nil, closestDist: PRIM_INFINITY)
  for link in links:
    if link[0] == id:
      result.neighbors.add (link[1], link[2])

proc `<`*(a, b: PrimVertex): bool = a.closestDist < b.closestDist

proc prim*[V](
    graph: tuple[vertices: seq[V], links: seq[(int, int, float)]],
    start: int): seq[(int, int, float)] =
  ## Prim 最小生成树算法。返回（id, 最近点 id, 距离）元组。
  var p: seq[PrimVertex] = @[]
  for i in 0 ..< graph.vertices.len:
    p.add newPrimVertex(i, graph.links)
  var q: seq[PrimVertex] = @[]
  for i in 0 ..< graph.vertices.len:
    if i != start: q.add p[i]
  var vertex = p[start]
  while q.len > 0:
    for (neighborId, length) in vertex.neighbors:
      let neighbor = p[neighborId]
      if neighbor in q and length < neighbor.closestDist:
        neighbor.closest = vertex
        neighbor.closestDist = length
    q.sort(proc(a, b: PrimVertex): int = cmp(a.closestDist, b.closestDist))
    vertex = q[0]
    q.delete(0)
  for v in p:
    if v.id != start:
      result.add (v.id, v.closest.id, v.closestDist)

proc dijkstra*[V](
    graph: tuple[vertices: seq[V], links: seq[(int, int, float)]],
    start: int): seq[(int, int, float)] =
  ## Dijkstra 单源最短路径算法。
  var p: seq[PrimVertex] = @[]
  for i in 0 ..< graph.vertices.len:
    p.add newPrimVertex(i, graph.links)
  var q: seq[PrimVertex] = @[]
  for i in 0 ..< graph.vertices.len:
    if i != start: q.add p[i]
  var vertex = p[start]
  vertex.closestDist = 0
  while q.len > 0:
    for (neighborId, length) in vertex.neighbors:
      let neighbor = p[neighborId]
      let dist = length + vertex.closestDist
      if neighbor in q and dist < neighbor.closestDist:
        neighbor.closest = vertex
        neighbor.closestDist = dist
    q.sort(proc(a, b: PrimVertex): int = cmp(a.closestDist, b.closestDist))
    vertex = q[0]
    q.delete(0)
  for v in p:
    if v.id != start:
      result.add (v.id, v.closest.id, v.closestDist)
