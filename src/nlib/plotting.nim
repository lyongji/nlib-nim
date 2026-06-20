## `gnuplot` 的薄封装，用于生成书中的图表。
## 每个辅助函数将数据写入 `<filename>.dat`，
## 然后调用 `gnuplot` 渲染 `<filename>`
##（输出格式由文件扩展名决定；以下模板默认使用 PNG）。

import std/[math, osproc, strutils]

proc writeXY(path: string, xs, ys: openArray[float]) =
  var f = open(path, fmWrite)
  for i in 0 ..< xs.len:
    f.writeLine xs[i].formatFloat(ffDecimal, 6) & " " &
                ys[i].formatFloat(ffDecimal, 6)
  f.close()

proc savePlot*(filename: string, xs, ys: openArray[float],
               title = "", xlab = "x", ylab = "y") =
  ## `(xs, ys)` 的折线图。
  let dataPath = filename & ".dat"
  writeXY(dataPath, xs, ys)
  discard execCmd("gnuplot -e \"" &
                  "set terminal pngcairo; " &
                  "set output '" & filename & "'; " &
                  "set title '" & title & "'; " &
                  "set xlabel '" & xlab & "'; " &
                  "set ylabel '" & ylab & "'; " &
                  "plot '" & dataPath & "' with lines\"")

proc saveHistogram*(filename: string, xs: openArray[float],
                    title = "", xlab = "x", ylab = "count",
                    bins = 20) =
  ## `xs` 中值的一维直方图。
  let dataPath = filename & ".dat"
  var f = open(dataPath, fmWrite)
  for x in xs: f.writeLine x.formatFloat(ffDecimal, 6)
  f.close()
  discard execCmd("gnuplot -e \"" &
                  "set terminal pngcairo; " &
                  "set output '" & filename & "'; " &
                  "set title '" & title & "'; " &
                  "set xlabel '" & xlab & "'; " &
                  "set ylabel '" & ylab & "'; " &
                  "set style fill solid; " &
                  "binwidth = " & $((xs.len.float).pow(0.5)) & "; " &
                  "bin(x, w) = w*floor(x/w); " &
                  "plot '" & dataPath &
                  "' using (bin($1, binwidth)):(1.0) " &
                  "smooth freq with boxes\"")

proc saveErrorbar*(filename: string,
                   xs, ys, dys: openArray[float],
                   title = "", xlab = "x", ylab = "y") =
  ## 绘制 `(xs, ys)` 并带垂直误差线 `dys`。
  let dataPath = filename & ".dat"
  var f = open(dataPath, fmWrite)
  for i in 0 ..< xs.len:
    f.writeLine xs[i].formatFloat(ffDecimal, 6) & " " &
                ys[i].formatFloat(ffDecimal, 6) & " " &
                dys[i].formatFloat(ffDecimal, 6)
  f.close()
  discard execCmd("gnuplot -e \"" &
                  "set terminal pngcairo; " &
                  "set output '" & filename & "'; " &
                  "set title '" & title & "'; " &
                  "set xlabel '" & xlab & "'; " &
                  "set ylabel '" & ylab & "'; " &
                  "plot '" & dataPath &
                  "' using 1:2:3 with errorbars\"")

proc saveErrorbarSeries*[K](filename: string,
                            data: openArray[(K, seq[(float, float, float)])],
                            xlab = "x", ylab = "y") =
  ## 绘制由 `K` 索引的一组误差线序列。
  ## 每个序列为 `(x, y, dy)` 三元组。
  let dataPath = filename & ".dat"
  var f = open(dataPath, fmWrite)
  for (label, series) in data:
    f.writeLine "# series " & $label
    for (x, y, dy) in series:
      f.writeLine x.formatFloat(ffDecimal, 6) & " " &
                  y.formatFloat(ffDecimal, 6) & " " &
                  dy.formatFloat(ffDecimal, 6)
    f.writeLine ""
    f.writeLine ""
  f.close()
  discard execCmd("gnuplot -e \"" &
                  "set terminal pngcairo; " &
                  "set output '" & filename & "'; " &
                  "set xlabel '" & xlab & "'; " &
                  "set ylabel '" & ylab & "'; " &
                  "plot for [i=0:*] '" & dataPath &
                  "' index i using 1:2:3 with errorbars\"")

proc saveHeatmap*(filename: string, grid: seq[seq[float]],
                  title = "", xlab = "x", ylab = "y") =
  ## 将二维矩阵渲染为热力图。
  let dataPath = filename & ".dat"
  var f = open(dataPath, fmWrite)
  for row in grid:
    for v in row:
      f.write v.formatFloat(ffDecimal, 6) & " "
    f.writeLine ""
  f.close()
  discard execCmd("gnuplot -e \"" &
                  "set terminal pngcairo; " &
                  "set output '" & filename & "'; " &
                  "set title '" & title & "'; " &
                  "set xlabel '" & xlab & "'; " &
                  "set ylabel '" & ylab & "'; " &
                  "plot '" & dataPath &
                  "' matrix with image\"")
