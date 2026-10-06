#!/usr/bin/env -S deno run --allow-run=tmux,env

type LayoutCell = {
  t: string;
  w: number;
  h: number;
  x: number;
  y: number;
  I?: string;
  c?: LayoutCell[];
};

const target = Deno.args[0];
if (!/^%\d+$/.test(target || "")) {
  console.error("Usage: tmux-editprompt.ts %pane-id");
  Deno.exit(1);
}

const decoder = new TextDecoder();
function tmux(...args: string[]): string {
  const result = new Deno.Command("tmux", {
    args,
    stdout: "piped",
    stderr: "piped",
  }).outputSync();
  if (!result.success) throw new Error(decoder.decode(result.stderr).trim());
  return decoder.decode(result.stdout).trim();
}
const quote = (value: string) => "'" + value.replace(/'/g, "'\\''") + "'";

// Keep the source and editor in one layout subtree. When the editor closes,
// tmux returns its space to the source, including after kill-pane or resizing.
function groupEditor(node: LayoutCell, editor: string): boolean {
  const children = node.c || [];
  const index = children.findIndex((child) => child.I === target);
  if (index >= 0) {
    const source = children[index];
    const prompt = children[index + 1];
    if (
      node.t !== "v" || !prompt || prompt.I !== editor ||
      source.w !== prompt.w || source.x !== prompt.x ||
      source.y + source.h + 1 !== prompt.y
    ) {
      throw new Error("The editor is no longer directly below its source pane");
    }
    if (children.length === 2) return true;
    children.splice(index, 2, {
      t: "v",
      w: source.w,
      h: source.h + prompt.h + 1,
      x: source.x,
      y: source.y,
      c: [source, prompt],
    });
    return true;
  }
  return children.some((child) => groupEditor(child, editor));
}

let editor: string | undefined;
let grouped = false;
let sourceHeight = "";
try {
  const work = tmux("display-message", "-p", "-t", target, "#{@vde_category}") === "work";
  const envArgs = work ? ["-u", "PANEPILOT_API_KEY"] : [];
  const prefix = [...envArgs, "NODE_NO_WARNINGS=1", "editprompt"];
  const resumed = new Deno.Command("env", {
    args: [...prefix, "resume", "--target-pane", target, "--quiet"],
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
  }).outputSync();
  if (resumed.success) Deno.exit(0);

  sourceHeight = tmux("display-message", "-p", "-t", target, "#{pane_unzoomed_height}");
  const channel = `editprompt-layout-${crypto.randomUUID()}`;
  const open = ["env", ...prefix, "open", "--target-pane", target, "--env", "NVIM_NOTTYFAST=1", "--quiet"].map(quote)
    .join(" ");
  editor = tmux(
    "split-window",
    "-v",
    "-l",
    "12",
    "-t",
    target,
    "-c",
    "#{pane_current_path}",
    "-P",
    "-F",
    "#{pane_id}",
    `tmux wait-for ${quote(channel)} && exec ${open}`,
  );

  const previous = tmux("display-message", "-p", "-t", target, "#{window_layout}");
  const layout: { V: number; L?: LayoutCell } = JSON.parse(previous);
  if (layout.V !== 2 || !layout.L || !groupEditor(layout.L, editor)) {
    throw new Error("Cannot find the source and editor in the tmux layout");
  }
  tmux("set-option", "-p", "-t", editor, "@editprompt_setup_layout", previous);
  const applied = tmux(
    "if-shell",
    "-F",
    "-t",
    editor,
    "#{==:#{window_layout},#{@editprompt_setup_layout}}",
    `select-layout -t ${target} ${quote(JSON.stringify(layout))}; display-message -p layout-applied`,
    "display-message -p layout-changed",
  );
  if (applied !== "layout-applied") {
    throw new Error("The window layout changed while opening editprompt");
  }
  grouped = true;
  tmux("set-option", "-pu", "-t", editor, "@editprompt_setup_layout");
  tmux("wait-for", "-S", channel);
} catch (error) {
  if (editor) {
    try {
      tmux("kill-pane", "-t", editor);
      if (!grouped) tmux("resize-pane", "-t", target, "-y", sourceHeight);
    } catch { /* The window or source may already have been closed. */ }
  }
  console.error(`tmux-editprompt.ts: ${error instanceof Error ? error.message : String(error)}`);
  Deno.exitCode = 1;
}
