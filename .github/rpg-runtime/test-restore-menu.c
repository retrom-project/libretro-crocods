#include <assert.h>
#include "../../libretro.c"

static unsigned loaded;
static void picker(core_crocods_t *core, u16 keys) {(void)core; (void)keys;}
void LireSnapshotMem(core_crocods_t *core, u8 *bytes) {
    assert(core == &gb);
    assert(bytes[0] == 42);
    loaded++;
}
int main(void) {
    const unsigned char bytes[] = {42};
    gb.runApplication = picker;
    gb.wait_key_released = 0;
    assert(retro_unserialize(bytes, sizeof(bytes)));
    assert(loaded == 1);
    assert(gb.runApplication == NULL);
    assert(gb.wait_key_released == 1);
    return 0;
}
