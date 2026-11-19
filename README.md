# C++ 演算法解題 2：動態規劃與圖論

作者：林子祐

「註解 Annotated 演算法系列」的第 2 本，接在[《C++ 演算法解題 1：APCS 實作題核心》](https://github.com/AkizumiFox/cpp-algorithms-book)之後讀。 第 1 本的排序、二分搜、前綴和、堆疊與佇列、貪心、遞迴、一維和格子的動態規劃、BFS／DFS、樹，這本書都假設已經會了，用到時寫出在第 1 本的第幾章。 書裡寫「第 1 本第 9 章」就是指那本書的第 9 章；沒有寫哪一本的章號，指的是這本書。

這本書分兩條線：動態規劃（背包、子序列、區間、位元、數位、樹形）和圖論（DAG 與拓樸排序、並查集、加權最短路徑、最小生成樹），最後一章是綜合練習。 寫法和第 1 本一樣，例題照「題意、想法、程式、複雜度、常見錯誤」的順序寫，動態規劃要說明狀態的意義。 章末有觀念題（附解答）和 Aki-Judge 上的實作題單（只列題名，不附解答）。

- 全書 PDF（草稿，11 章，319 頁）：[`output/book.pdf`](output/book.pdf)
- 網頁版：[annotated.codes/learn/algorithms-2](https://annotated.codes/learn/algorithms-2)（一節一頁，手機也好讀）
- 各章 PDF：[1](output/chapters/01_Knapsack.pdf)、[2](output/chapters/02_SubsequenceDP.pdf)、[3](output/chapters/03_IntervalDP.pdf)、[4](output/chapters/04_BitmaskDP.pdf)、[5](output/chapters/05_DigitDP.pdf)、[6](output/chapters/06_DAGTopo.pdf)、[7](output/chapters/07_DSUCyclesBipartite.pdf)、[8](output/chapters/08_ShortestPaths.pdf)、[9](output/chapters/09_MST.pdf)、[10](output/chapters/10_TreeDP.pdf)、[11](output/chapters/11_Capstone.pdf)
- 原始碼：`src/`（XeLaTeX）

## 章節

章號一開始就定好，還沒寫的章先空著，之後補上時已寫的章不用改號。

| # | 章 | 狀態 |
|---|---|---|
| 1 | 背包 DP | 草稿 |
| 2 | 子序列 DP | 草稿 |
| 3 | 區間 DP | 草稿 |
| 4 | 位元 DP 與旅行推銷員 | 草稿 |
| 5 | 數位 DP | 草稿 |
| 6 | DAG 與拓樸排序 | 草稿 |
| 7 | 並查集、環與二分圖 | 草稿 |
| 8 | 加權圖的最短路徑 | 草稿 |
| 9 | 最小生成樹 | 草稿 |
| 10 | 樹形 DP | 草稿 |
| 11 | 綜合練習 | 草稿 |

第 1、2、3、6、7、10 章原本是第 1 本的第 15–20 章，拆書時搬到這裡。

## 註解 Annotated 演算法系列

| # | 書名 | 狀態 |
|---|---|---|
| 1 | 《C++ 演算法解題 1：APCS 實作題核心》 | 草稿，[cpp-algorithms-book](https://github.com/AkizumiFox/cpp-algorithms-book) |
| 2 | 《C++ 演算法解題 2：動態規劃與圖論》 | 本書，草稿（11 章寫完） |
| 3 | 《C++ 演算法解題 3：進階資料結構、數學與競賽》 | 規劃中 |

三本都用 C++17，一本接一本讀。

## 編譯

需要 XeLaTeX、latexmk 與 Python 的 Pygments（minted 上色用）。 中文字型在 macOS 上用 Songti TC／PingFang TC，找不到時改用 Noto Serif／Sans CJK TC。

```
make ch6     # 單章，輸出到 output/chapters/
make book    # 全書，輸出到 output/book.pdf
```

還沒動筆的章在 `src/book.tex` 裡是註解掉的，`Makefile` 的 `WRITTEN` 列出已經動筆的章。 已寫的章前面用 `\setcounter{chapter}` 定好章號。

## 測試書上的程式

書上每一個標題寫著 `(檔名.cpp)` 的範例都是完整的程式。 `make test` 會把它們從 `.tex` 抽出來（`scripts/extract_code.py`），用

```
g++ -std=c++17 -O2 -Wall -Wextra -fsanitize=address,undefined
```

編譯，有任何警告就算失敗；範例後面緊接著輸入輸出範例的，再拿輸入去跑，和書上印的輸出逐字比對。 片語（`code` 環境）只是片段，不抽。

`make test-judge` 用例題的完整測資檢查例題程式，並記錄最慢一筆的時間，書上「在本書測試的環境下約 0.05 秒」這類數字就是從這裡來的。 題目資料不在這個 repo 裡，要另外設定 `AJ_PROBLEMS`（題目資料的根目錄）和 `AJ_JUDGE_MAP`（每行「`chNN/檔名.cpp`、Tab、題目目錄」的對照表），細節見 `scripts/test_judge.sh`。

## 本書測試的環境

書中「在本書測試的環境下」都是指：

- Ubuntu 24.04，AMD Ryzen 9 9900X
- g++ 13.3.0，`-std=c++17 -O2`
- 時間是單次執行的實際經過時間，包含讀輸入

## Aki-Judge 題目的引用

書中引用 Aki-Judge 的題目一律寫成 `\akiref{代號}{中文題名}`（定義在 `src/packages/sleek-aki.sty`）。 目前只印出「中文題名（Aki-Judge）」；題號固定之後改這個巨集就好，各章不用動。

## 授權

CC BY-NC-SA 4.0。 可自由用於教學與非商業用途，改作請沿用相同授權並註明出處。
