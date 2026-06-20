## `seq[T]` 上的最大堆操作。标准库的 `std/heapqueue` 是最小堆；
## 本模块是书中使用的最大堆对应实现。

proc heapParent(i: int): int = (i - 1) div 2
proc heapLeftChild(i: int): int = 2 * i + 1
proc heapRightChild(i: int): int = 2 * i + 2

proc heapifyOne*[T](a: var seq[T], i: int, heapsize = -1) =
  ## 恢复索引 `i` 处的最大堆性质。
  let heapsize = if heapsize < 0: a.len else: heapsize
  let left = heapLeftChild(i)
  let right = heapRightChild(i)
  var largest = i
  if left < heapsize and a[left] > a[largest]:
    largest = left
  if right < heapsize and a[right] > a[largest]:
    largest = right
  if largest != i:
    swap(a[i], a[largest])
    heapifyOne(a, largest, heapsize)

proc heapify*[T](a: var seq[T]) =
  ## 将 `a` 重排为最大堆。O(n)。
  for i in countdown(a.len div 2 - 1, 0):
    heapifyOne(a, i)

proc heapsort*[T](a: var seq[T]) =
  ## 原地堆排序。O(n log n)。
  heapify(a)
  for i in countdown(a.len - 1, 1):
    swap(a[0], a[i])
    heapifyOne(a, 0, i)

proc heapPop*[T](a: var seq[T]): T =
  ## 移除并返回堆的最大元素。
  if a.len < 1:
    raise newException(IndexDefect, "Heap Underflow")
  result = a[0]
  a[0] = a[^1]
  a.setLen(a.len - 1)
  if a.len > 0:
    heapifyOne(a, 0)

proc heapPush*[T](a: var seq[T], value: T) =
  ## 将 `value` 插入堆中，保持最大堆性质。
  a.add value
  var i = a.len - 1
  while i > 0:
    let j = heapParent(i)
    if a[j] < a[i]:
      swap(a[i], a[j])
      i = j
    else:
      break
