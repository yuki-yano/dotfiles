import { assert, assertEquals } from "jsr:@std/assert@1";

const source = await Deno.readTextFile(".config/nvim/lua/plugins/ime.lua");

Deno.test("editprompt stash records the current buffer in history before pushing stash", () => {
  assert(
    /local function stash_buffer_to_history\(\)[\s\S]*editprompt_utils\.save_buffer\(\)[\s\S]*editprompt_history\.push\(original\)[\s\S]*editprompt\.stash_push\(\)/
      .test(
        source,
      ),
  );
});

Deno.test("editprompt stash mappings use the history-aware stash helper", () => {
  assertEquals((source.match(/stash_buffer_to_history\(\)/g) ?? []).length, 3);
});
