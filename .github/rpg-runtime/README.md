# CrocoDS EmulatorJS candidate

The fork starts at EmulatorJS/libretro-crocods commit
be00fb904da08d66221017f6708508298f17ff07. Restoring a machine snapshot dismisses
the disk autorun picker opened by the new instance and waits for neutral input.
The picker is frontend state outside the snapshot and otherwise prevents input
from reaching the restored game.

`build-candidate.sh` first runs the native menu regression, then snapshots the
worktree and uses the pinned emsdk image and RetroArch linker. It emits the
Wasm core, license, complete core sources and candidate identity/digests.

Local PFB candidates remain unpublished until explicitly promoted. The downstream repository URL expresses
the intended identity; this script creates no remote repository or release.
Real Retrom import, preview, gameplay, snapshot, fresh-Launch restore, continued
input and exit remain required before release. Test games are never published.

Formal publication uses `build-release.py --output <absolute-empty-directory> --tag <tag>`.
The workflow runs the same native regression and pinned Web build for PRs and tags.
Only annotated tags reachable from the declared maintenance branch may publish;
release assets include the complete core source archive, license and integrity report.
