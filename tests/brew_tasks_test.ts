import { assert, assertEquals, assertFalse, assertStringIncludes } from "@std/assert";
import { buildBrewCommandOptions, loadBrewCommands } from "../tasks.ts";

const brewfile = new URL("../Brewfile", import.meta.url).pathname;
const caskfile = new URL("../Caskfile", import.meta.url).pathname;
const brewEnv = new URL("../.config/homebrew/brew.env", import.meta.url).pathname;

function commandTokens(commands: string[]): string[] {
  return commands.flatMap((command) => command.split(/\s+/));
}

Deno.test("Brewfile keeps install separate from maintenance and scopes HEAD to Neovim", async () => {
  const commands = await loadBrewCommands(brewfile);
  const tokens = commandTokens(commands);

  assertEquals(commands.filter((command) => command.includes("--HEAD")), ["install neovim --HEAD"]);
  assertFalse(commands.some((command) => ["update", "upgrade", "cleanup"].includes(command)));
  assert(tokens.includes("herdr"));
  for (
    const removed of ["rtk", "node", "oven-sh/bun/bun", "go", "python", "waydabber/betterdisplay/betterdisplaycli"]
  ) {
    assertFalse(tokens.includes(removed), `${removed} should not be managed by Brewfile`);
  }
});

Deno.test("Caskfile uses the current Arto tap and excludes maintenance commands", async () => {
  const commands = await loadBrewCommands(caskfile);
  const rendered = commands.join("\n");

  assertStringIncludes(rendered, "arto-app/tap/arto");
  assertFalse(rendered.includes("lambdalisue/arto/arto"));
  assertFalse(commands.some((command) => ["update", "upgrade", "cleanup"].includes(command)));
});

Deno.test("Homebrew confirmations are disabled through the managed brew environment", async () => {
  assertEquals(await Deno.readTextFile(brewEnv), "HOMEBREW_NO_ASK=1\n");
});

Deno.test("Homebrew tasks disable confirmations before dotfiles are linked", () => {
  const options = buildBrewCommandOptions("install ripgrep");

  assertEquals(options.args, ["install", "ripgrep"]);
  assertEquals(options.env, { HOMEBREW_NO_ASK: "1" });
});
