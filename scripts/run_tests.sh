#!/usr/bin/env bash
# 編譯 extract_code.py 抽出的每一支範例，有 iosample 的就拿輸入跑，和預期輸出比對。
# 用法：scripts/run_tests.sh build/code
set -u
root=${1:?usage: run_tests.sh <code-dir>}
CXXFLAGS="-std=c++17 -O2 -Wall -Wextra -fsanitize=address,undefined"
pass=0; fail=0
for src in "$root"/*/*.cpp; do
    stem=${src%.cpp}
    name=${src#"$root"/}
    if ! warn=$(g++ $CXXFLAGS "$src" -o "$stem.bin" 2>&1) || [ -n "$warn" ]; then
        echo "FAIL (compile) $name"; echo "$warn" | head -20
        fail=$((fail + 1)); continue
    fi
    if [ -f "$stem.out" ]; then
        if [ -f "$stem.in" ]; then input="$stem.in"; else input=/dev/null; fi
        if ! "$stem.bin" < "$input" > "$stem.actual" 2> "$stem.err"; then
            echo "FAIL (runtime) $name"; head -20 "$stem.err"
            fail=$((fail + 1)); continue
        fi
        if ! diff -q "$stem.actual" "$stem.out" > /dev/null; then
            echo "FAIL (output) $name"; diff "$stem.actual" "$stem.out" | head -20
            fail=$((fail + 1)); continue
        fi
        echo "ok   $name"
    else
        echo "ok   $name (compile only)"
    fi
    pass=$((pass + 1))
done
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
