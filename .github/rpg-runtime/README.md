# CrocoDS EmulatorJS candidate

The fork starts at EmulatorJS/libretro-crocods commit
be00fb904da08d66221017f6708508298f17ff07. Restoring a machine snapshot dismisses
the disk autorun picker opened by the new instance and waits for neutral input.
The picker is frontend state outside the snapshot and otherwise prevents input
from reaching the restored game.

`build-candidate.sh` first runs the native menu regression, then snapshots the
worktree and uses the pinned emsdk image and RetroArch linker. It emits the
Wasm core, license, complete core sources and candidate identity/digests.

This is an unpublished PFB candidate. The downstream repository URL expresses
the intended identity; this script creates no remote repository or release.
Real Retrom import, preview, gameplay, snapshot, fresh-Launch restore, continued
input and exit remain required before release. Test games are never published.
