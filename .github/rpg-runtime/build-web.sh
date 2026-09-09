#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
output=${1:?absolute empty output directory is required}
python3 "$root/.github/rpg-runtime/candidate_descriptor.py" prepare "$output"
mkdir -p "$root/build"
work=$(mktemp -d "$root/build/retrom-crocods-web.XXXXXX")
trap 'rm -rf "$work"' EXIT INT TERM
mkdir -p "$work/raw" "$work/build"
cc -w -O0 -ffunction-sections -fdata-sections "$root/.github/rpg-runtime/test-restore-menu.c" -Wl,--gc-sections -lm -o "$work/test-restore-menu"
"$work/test-restore-menu"
source_digest=$(python3 "$root/.github/rpg-runtime/candidate_descriptor.py" digest "$output")
python3 "$root/.github/rpg-runtime/candidate_descriptor.py" paths "$output" > "$work/source-files"
tar -C "$root" --null --verbatim-files-from -T "$work/source-files" -cf "$work/source.tar"

export RETROM_HOST_UID="$(id -u)"
export RETROM_HOST_GID="$(id -g)"
if ! docker run --rm --platform linux/amd64 --hostname retrom-crocods \
  --env RETROM_HOST_UID --env RETROM_HOST_GID \
  --volume "$work/source.tar:/source.tar:ro" \
  --volume "$root/.github/rpg-runtime:/recipe:ro" \
  --volume "$work/build:/work" \
  --volume "$work/raw:/output" \
  emscripten/emsdk@sha256:af45409f3199d88db4b1b03af0098532c8fb33a375ac257463eeb0a622870d06 \
  /recipe/build-emulatorjs-core.sh crocods \
  >"$work/build.log" 2>&1; then
  tail -200 "$work/build.log" >&2
  exit 1
fi

test "$source_digest" = "$(python3 "$root/.github/rpg-runtime/candidate_descriptor.py" digest "$output")"
stage="$work/stage"
mkdir -p "$stage"
install -m 0644 "$work/raw/crocods_libretro.js" "$stage/"
install -m 0644 "$work/raw/crocods_libretro.wasm" "$stage/"
install -m 0644 "$root/LICENSE" "$stage/license.txt"
printf '%s\n' '{"minimumEJSVersion":"4.2.2","version":"2.0.2"}' > "$stage/build.json"
printf '%s\n' '{"name":"crocods","extensions":["dsk","sna","kcr"],"makeoptions":{"buildpath":"./","makescript":"Makefile","arguments":[]},"options":{},"save":false,"license":"LICENSE","repo":"https://github.com/retrom-project/libretro-crocods"}' > "$stage/core.json"

(cd "$stage" && 7z a -mtm=off -mta=off -mtc=off -bd -bso0 -bsp0 -t7z "$output/crocods-wasm.data" \
  crocods_libretro.js crocods_libretro.wasm build.json core.json license.txt)
install -m 0644 "$root/LICENSE" "$output/LICENSE"

gzip -n -c "$work/source.tar" > "$output/source.tar.gz"
