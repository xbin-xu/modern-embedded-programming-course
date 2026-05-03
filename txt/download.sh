#!/usr/bin/env bash
set -euo pipefail

URL_PREFIX="https://www.state-machine.com/course"
TOTAL=56
CONCURRENT=8

echo "Downloading ${TOTAL} lessons with ${CONCURRENT} concurrent connections..."

download_one() {
	local i=$1
	local padded=$(printf "%02d" "$i")
	if curl --retry 3 --connect-timeout 10 -sS -o "lesson-${i}.txt" \
		"${URL_PREFIX}/lesson-${padded}.txt" 2>/dev/null; then
		echo "[OK] lesson-${i}.txt"
	else
		echo "[FAIL] lesson-${i}.txt"
	fi
}

export -f download_one
export URL_PREFIX

seq 1 "$TOTAL" | xargs -n1 -P"$CONCURRENT" -I{} bash -c 'download_one "$1"' _ {}

echo ""
echo "=== Verification ==="
ok=0
fail=0
for i in $(seq 1 "$TOTAL"); do
	if [[ -f "lesson-${i}.txt" ]]; then
		((ok++))
	else
		echo "[MISSING] lesson-${i}.txt"
		((fail++))
	fi
done
echo "Downloaded: ${ok}/${TOTAL}, Failed: ${fail}"
