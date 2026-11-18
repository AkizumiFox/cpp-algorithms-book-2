#!/usr/bin/env bash
# 例題對完整測資：用題目的全部測資檢查書上的例題程式，並記錄最慢一筆的時間。
# 題目資料不在這個 repo 裡，要另外設定兩個環境變數：
#   AJ_PROBLEMS    題目資料的根目錄
#   AJ_JUDGE_MAP   對照表，每行「chNN/檔名.cpp<TAB>題目目錄（相對 AJ_PROBLEMS）」
# 每個題目目錄底下要有 tests/*.in 與對應的 .out。
# 用法：scripts/test_judge.sh build/code
set -u
root=${1:?usage: test_judge.sh <code-dir>}
: "${AJ_PROBLEMS:?set AJ_PROBLEMS to the problem data root}"
: "${AJ_JUDGE_MAP:?set AJ_JUDGE_MAP to the example-to-problem map}"
fail=0
while IFS=$'\t' read -r example dir; do
    [ -z "$example" ] && continue
    case "$example" in \#*) continue ;; esac
    src="$root/$example"
    bin="${src%.cpp}.judge"
    g++ -std=c++17 -O2 -Wall -Wextra "$src" -o "$bin" || { echo "FAIL (compile) $example"; fail=1; continue; }
    ok=0; bad=0; slowest=0; slowname=-
    for tin in "$AJ_PROBLEMS/$dir"/tests/*.in; do
        start=$(date +%s%N)
        "$bin" < "$tin" > "$bin.actual"
        end=$(date +%s%N)
        ms=$(( (end - start) / 1000000 ))
        if [ "$ms" -gt "$slowest" ] || [ "$slowname" = - ]; then slowest=$ms; slowname=$(basename "$tin"); fi
        if diff -q "$bin.actual" "${tin%.in}.out" > /dev/null; then ok=$((ok + 1)); else bad=$((bad + 1)); fi
    done
    echo "$example: $ok passed, $bad failed, slowest $slowname ${slowest} ms"
    [ "$bad" -eq 0 ] || fail=1
done < "$AJ_JUDGE_MAP"
exit $fail
