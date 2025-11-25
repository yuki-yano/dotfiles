// Generate Karabiner complex_modifications via karabiner.ts (Deno edition).
import {
  ifApp,
  ifInputSource,
  map,
  rule,
  withMapper,
  writeToProfile,
} from "https://deno.land/x/karabinerts@1.35.1/deno.ts";

const profileName = "Default profile";

const alacritty = ifApp("^org\\.alacritty$");
const cursorEditor = ifApp("^com\\.todesktop\\.230313mzl4w4u92$");
const englishInput = ifInputSource({ language: "en" });
const nonEnglishInput = englishInput.unless();

const eisuu = "japanese_eisuu";
const kana = "japanese_kana";

const alacrittyRules = [
  rule(
    "Command+Shift+[ to disable IME and Option+Shift+[ in Alacritty for tmux yank from Neovim",
  ).manipulators([
    map("open_bracket", ["command", "shift"])
      .condition(alacritty)
      .to(eisuu)
      .to("open_bracket", ["option", "shift"]),
  ]),
  rule(
    "Command+Return and Shift+Return to backslash+Enter in Alacritty for Claude Code",
  ).manipulators([
    map("return_or_enter", "command")
      .condition(alacritty, englishInput)
      .to("backslash")
      .toDelayedAction([{ key_code: "return_or_enter" }], [])
      .parameters({ "basic.to_delayed_action_delay_milliseconds": 20 }),
    map("return_or_enter", "command")
      .condition(alacritty, nonEnglishInput)
      .to(eisuu)
      .to("backslash")
      .toDelayedAction(
        [
          { key_code: "return_or_enter" },
          { key_code: kana },
        ],
        [],
      )
      .parameters({ "basic.to_delayed_action_delay_milliseconds": 80 }),
    map("return_or_enter", "shift")
      .condition(alacritty, englishInput)
      .to("backslash")
      .toDelayedAction([{ key_code: "return_or_enter" }], [])
      .parameters({ "basic.to_delayed_action_delay_milliseconds": 20 }),
    map("return_or_enter", "shift")
      .condition(alacritty, nonEnglishInput)
      .to(eisuu)
      .to("backslash")
      .toDelayedAction(
        [
          { key_code: "return_or_enter" },
          { key_code: kana },
        ],
        [],
      )
      .parameters({ "basic.to_delayed_action_delay_milliseconds": 80 }),
  ]),
  rule(
    "Command+Shift+] to disable IME and Option+Shift+] in Alacritty for tmux paste",
  ).manipulators([
    map("close_bracket", ["command", "shift"])
      .condition(alacritty)
      .to(eisuu)
      .to("close_bracket", ["option", "shift"]),
  ]),
  rule("Command+] to disable IME in Alacritty").manipulators([
    map("close_bracket", "command")
      .condition(alacritty)
      .to(eisuu)
      .to("close_bracket", "command"),
  ]),
  rule("Control+Y to disable IME in Alacritty").manipulators([
    map("y", "control")
      .condition(alacritty)
      .to(eisuu)
      .to("y", "control"),
  ]),
  rule("Command+[ to disable IME in Alacritty").manipulators([
    map("open_bracket", "command")
      .condition(alacritty)
      .to(eisuu)
      .to("open_bracket", "command"),
  ]),
  rule("Command+H to Command+Shift+H in Alacritty for tmux").manipulators([
    map("h", "command")
      .condition(alacritty)
      .to("h", ["command", "shift"]),
  ]),
];

const cursorEditorRules = [
  rule("Emacs-style Cursor Movement in Cursor Editor").manipulators([
    map("n", "control").condition(cursorEditor).to("down_arrow"),
    map("p", "control").condition(cursorEditor).to("up_arrow"),
    map("f", "control").condition(cursorEditor).to("right_arrow"),
    map("b", "control").condition(cursorEditor).to("left_arrow"),
    map("a", "control").condition(cursorEditor).to("home"),
  ]),
];

const imeControlRules = [
  rule("Control IME with Command key alone and Command+Space").manipulators([
    map({
      key_code: "left_command",
      modifiers: { optional: ["any"] },
    })
      .to("left_command")
      .toIfAlone(eisuu),
    map("spacebar", "command").to(kana),
    map({
      key_code: "right_command",
      modifiers: { optional: ["any"] },
    })
      .condition(alacritty.unless())
      .to("right_command")
      .toIfAlone(kana),
  ]),
  rule("Press ESC to enter Japanese input as English characters").manipulators([
    map({
      key_code: "escape",
      modifiers: { optional: ["any"] },
    })
      .to(eisuu)
      .to("escape"),
    map({
      key_code: "open_bracket",
      modifiers: { mandatory: ["left_control"], optional: [] },
    })
      .to(eisuu)
      .to("escape"),
  ]),
];

const imeRules = [
  rule("Disable IME with Ctrl-{num}").manipulators([
    withMapper([1, 2, 3, 4, 5])((n) =>
      map(n as 1 | 2 | 3 | 4 | 5, "control")
        .to(eisuu)
        .to(n as 1 | 2 | 3 | 4 | 5, "control")
    ),
  ]),
  rule("Disable IME with tmux operation").manipulators([
    withMapper(["h", "j", "k", "l"])((key) =>
      map(key, "control")
        .condition(alacritty)
        .to(eisuu)
        .to(key, "control")
    ),
    withMapper(["h", "j", "k", "l", "v", "s"])((key) =>
      map(key, "right_command").to(eisuu).to(key, "right_command")
    ),
  ]),
];

const candsRules = [
  rule("Send ctrl on space when used as modifiers").manipulators([
    map("spacebar").to("left_control").toIfAlone("spacebar"),
  ]),
  rule("Send ctrl on lang2 when used as modifiers").manipulators([
    map("lang2").to("left_control").toIfAlone("spacebar"),
  ]),
  rule("Send ctrl on lang1 when used as modifiers").manipulators([
    map("lang1").to("left_control").toIfAlone("spacebar"),
  ]),
];

const rules = [...alacrittyRules, ...cursorEditorRules, ...imeControlRules, ...imeRules];

writeToProfile(profileName, rules);
